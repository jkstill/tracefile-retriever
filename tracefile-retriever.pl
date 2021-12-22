#!/usr/bin/env perl

# template for DBI programs

use warnings;
use strict;
use DBI;
use DBD::Oracle qw(:ora_types);
use sigtrap qw{handler sigclean normal-signals};
use Getopt::Long;

my %optctl = ();
my($db, $username, $password, $connectionMode, $dumpDir, $tracefileName, $sql, $help);
my $exitCode=0;

Getopt::Long::GetOptions(
	\%optctl, 
	"database=s" => \$db,
	"username=s" => \$username,
	"password=s" => \$password,
	"dumpdir=s" => \$dumpDir,
	"tracefile=s" => \$tracefileName,
	"sysdba!",
	"sysoper!",
	"z","h","help" => \$help
);

usage(0) if $help;

$connectionMode = 0;
if ( $optctl{sysoper} ) { $connectionMode = 4 }
if ( $optctl{sysdba} ) { $connectionMode = 2 }

if ( ! defined($db) ) {
	usage(1);
}

if ( ! defined($username) ) {
	usage(2);
}

if ( ! defined($password) ) {

	print STDERR qq{

password: };

	$password = <STDIN>;
	chomp $password
}

my $dbh = DBI->connect(
	'dbi:Oracle:' . $db, 
	$username, $password, 
	{ 
		RaiseError => 1, 
		AutoCommit => 0,
		ora_session_mode => $connectionMode
	} 
	);

die "Connect to  $db failed \n" unless $dbh;


$exitCode=0;

$dbh->{ora_check_sql} = 0;
$dbh->{RowCacheSize} = 100;

# reads up to 100M bytes
# max possible it 2B

my $sth = $dbh->prepare($sql,{ora_check_sql => 0});

$sth->bind_param( ':DUMPDIR', $dumpDir, { ora_type => ORA_VARCHAR2 } );
$sth->bind_param( ':tracefile_name_in', $tracefileName, { ora_type => ORA_VARCHAR2 } );
$sth->execute;

while ( my $line = $dbh->func('dbms_output_get')) {
	print "$line";
	exit $exitCode if $exitCode;
}

$dbh->disconnect;

sub usage {
	my $exitVal = shift;
	$exitVal = 0 unless defined $exitVal;
	use File::Basename;
	my $basename = basename($0);
	print qq/

usage: $basename

  -database      target instance
  -username      target instance account name
  -password      target instance account password
  -dumpdir       the name of the dump directory
  -tracefile     the name of the tracefile to retrieve
  -sysdba        logon as sysdba
  -sysoper       logon as sysoper

  example:

  $basename -database dv07 -username scott -password tiger -sysdba 

  Note: This script uses dbms_output to move the data
  due to this, the entire trace file is buffered on the server side (PGA memory)
  be careful with very large trace files.

  Why not use CLOB?  See the notes in 'perldoc $basename'

  Why not use PIPE ROW?  Because it requires creating database objects,
  which is frequently either inconvenient, or not possible

/;

   exit $exitVal;
};


sub sigclean {
	print "Caught Signal $!\n";
	print "Cleanup and Exit\n";
	$dbh->disconnect if $dbh;
	die;
}

BEGIN {
$sql = q{
declare

	-- could set dynamically for windows
	line_terminator varchar2(4) := chr(10);

	DEBUG boolean := false;

	v_trace_file_name varchar2(256);
	v_line varchar2(32767);
	i_file_size pls_integer;
	i_file_pos pls_integer;
	i_alert_pos pls_integer;
	i_start_op_time number;
	i_elapsed_seconds number;
	fh_tracefile utl_file.file_type;

	i_lines_limit pls_integer := 10 * 1e6;
	i_curr_line pls_integer := 0;

	buf varchar2(32767);

	function does_trace_file_exist (file_name_in varchar2)
	return boolean
	is
		v_file_exists boolean;
		i_file_length pls_integer;
		i_file_blocksize pls_integer;
	begin
		utl_file.fgetattr(
			upper(:DUMPDIR),
			file_name_in,
			v_file_exists,
			i_file_length,
			i_file_blocksize
		);

		return v_file_exists;
	end;

	function get_file_size (file_name_in varchar2)
	return pls_integer
	is
		v_file_exists boolean;
		i_file_length pls_integer;
		i_file_blocksize pls_integer;
	begin
		utl_file.fgetattr(
			upper(:DUMPDIR),
			file_name_in,
			v_file_exists,
			i_file_length,
			i_file_blocksize
		);

		return i_file_length;
	end;

	function get_fh(v_trace_file_in varchar2) return utl_file.file_type
	is
		f_fh utl_file.file_type;
	begin
		f_fh := utl_file.fopen(upper(:DUMPDIR),v_trace_file_in, 'r', 32763);
		return f_fh;
	end;

	procedure close_fh(fh_in in out utl_file.file_type)
	is
	begin
		utl_file.fclose(fh_in);
	end;

	-- where to start reading - always start at zero in this case
	-- we always want the entire trace file
	procedure fileseek(fh_in in out utl_file.file_type)
	is
	begin
		utl_file.fseek(fh_in,0);
	end;

begin

	v_trace_file_name := :tracefile_name_in;

	if not does_trace_file_exist(v_trace_file_name) then
		raise_application_error(-20001,'Trace file ' || v_trace_file_name || ' does not exist');
	end if;

	i_file_size := get_file_size(v_trace_file_name);

	fh_tracefile := get_fh(v_trace_file_name);

	--i_lines_limit := 1000;
	i_curr_line := 0;

	-- size is unlimitet when null passed
	dbms_output.enable(null);

	while true
	loop
		begin
			utl_file.get_line(fh_tracefile, buf, 32763);
			-- add the line terminator
			-- this will preserve blank lines
			buf := buf || line_terminator;
			dbms_output.put_line(buf);
		exception
		when NO_DATA_FOUND then
			exit;
		when others then
			raise;
		end;

		i_curr_line := i_curr_line + 1;
		if (i_curr_line > i_lines_limit) then
			exit;
		end if;
		
	end loop;

	close_fh(fh_tracefile);

end;

};

};

=head1 tracefile-retriever.pl

 usage: 

  -database      target instance
  -username      target instance account name
  -password      target instance account password
  -dumpdir       the name of the dump directory
  -tracefile     the name of the tracefile to retrieve
  -sysdba        logon as sysdba
  -sysoper       logon as sysoper

  example:

  tracefile-retriever.pl -database dv07 -username scott -password tiger 

  Note: This script uses dbms_output to move the data
  due to this, the entire trace file is buffered on the server side (PGA memory)
  be careful with very large trace files.

  Why not use CLOB?  See the following notes.

  Why not use PIPE ROW?  Because it requires creating database objects,
  which is frequently either inconvenient, or not possible


=head2 ORA-24801

 All attempts to use a bind variable back to perl fail with ORA-24801


   with ParamValues: :out=undef, :tracefile_name_in='cdb2_ora_24755.trc'] at ./t2.pl line 160.
   DBD::Oracle::st execute failed: ORA-24801: illegal parameter value in OCI lob function (DBD ERROR: OCILobRead) ...


 The 2 lines with a comment of ORA-24801 will exhibit this behavior

 The dest database is 19c, and the client is 12c

 DBD::Oracle 1.80 is the most recent version
 DBI 1.636 is receent.
 Running the code on the server gets the same results.

 The use of outputting to dbms_output is a workaround.

 On any recent version of Oracle (the last 12 years or so, as of 2021), the amount of output from dbms_output is unlimited


 Interestingly, this test program works just fine:

 # reads up to 100M bytes
 # max possible it 2B
 $dbh->{LongReadLen} = 100000000;
 $dbh->{LongTruncOk}=1;

 my $in_clob = "<document>\n";
 $in_clob .= "  <value>$_</value>\n" for 1 .. 100_000;
 $in_clob .= "</document>\n";

 my $out_clob;

 my $sth = $dbh->prepare(<<PLSQL_END);
          -- extract 'value' nodes
          DECLARE
            x XMLTYPE := XMLTYPE(:in);
          BEGIN
            :out := x.extract('/document/value').getClobVal();
          END;

 PLSQL_END

 $sth->bind_param( ':in', $in_clob, { ora_type => ORA_CLOB } );
 $sth->bind_param_inout( ':out', \$out_clob, 0, { ora_type => ORA_CLOB } );
 $sth->execute;
 
 print $out_clob;


=head2 ORA-24801 code

 my $sql=q{declare

	DUMPDIR CONSTANT varchar(128) := 'BDUMP_2';

	trace_bfile bfile;

	l_dest_offset   integer := 1;
	l_src_offset    integer := 1;
	l_bfile_csid    number  := 0;
	l_lang_context  integer := 0;
	l_warning       integer := 0;

	temp_clob clob;

 begin

	trace_bfile := bfilename(DUMPDIR, :tracefile_name_in);
	dbms_lob.fileopen(trace_bfile, dbms_lob.file_readonly);
	dbms_lob.createtemporary(lob_loc => temp_clob, cache => false, dur => dbms_lob.session);

	dbms_lob.loadclobfromfile (
		dest_lob      => temp_clob,
		src_bfile     => trace_bfile,
		amount        => dbms_lob.lobmaxsize,
		dest_offset   => l_dest_offset,
		src_offset    => l_src_offset,
		bfile_csid    => l_bfile_csid ,
		lang_context  => l_lang_context,
		warning       => l_warning
	);

	dbms_lob.fileclose(trace_bfile);

	-- ORA-24801
	--:out := temp_clob;
	-- also ORA-24801
	--select temp_clob into :out from dual;

	-- work around for just returning a CLOB directly - see ORA-24801 comments
	--dbms_output.enable(null);
	--dbms_output.put_line(temp_clob);


 end;};

=cut


