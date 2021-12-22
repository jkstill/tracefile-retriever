#!/usr/bin/env perl

# template for DBI programs

use warnings;
use FileHandle;
use DBI;
use DBD::Oracle qw(:ora_types);
use strict;

use Getopt::Long;

my %optctl = ();

Getopt::Long::GetOptions(
	\%optctl, 
	"database=s",
	"username=s",
	"password=s",
	"sysdba!",
	"sysoper!",
	"z","h","help");

my($db, $username, $password, $connectionMode);

$connectionMode = 0;
if ( $optctl{sysoper} ) { $connectionMode = 4 }
if ( $optctl{sysdba} ) { $connectionMode = 2 }

if ( ! defined($optctl{database}) ) {
	usage(1);
}
$db=$optctl{database};

if ( ! defined($optctl{username}) ) {
	usage(2);
}

$username=$optctl{username};
$password = $optctl{password};

#print "USERNAME: $username\n";
#print "DATABASE: $db\n";
#print "PASSWORD: $password\n";
#exit;

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

$dbh->do(q{alter session set tracefile_identifier='CLOB-ISSUE'});
#$dbh->do(q{alter session set events '10046 trace name context forever, level 12'});

# apparently not a database handle attribute
# but IS a prepare handle attribute
#$dbh->{ora_check_sql} = 0;
$dbh->{RowCacheSize} = 100;

# reads up to 100M bytes
# max possible it 2B
$dbh->{LongReadLen} = 100000000;
$dbh->{LongTruncOk}=1;

# some test pl/sql
my $sql=q{declare
	v_mydate varchar2(25);
begin
	v_mydate := to_char(sysdate,'yyyy-mm-dd hh24:mi:ss');
	dbms_output.enable(null);
	dbms_output.put_line(v_mydate);
	--raise dup_val_on_index;
end;};

my $sth = $dbh->prepare($sql,{ora_check_sql => 0});

$sth->execute;

my @dbms_output_buffer = $dbh->func('dbms_output_get');
print @dbms_output_buffer, "\n";


$sql = q{declare

	DUMPDIR CONSTANT varchar(128) := 'BDUMP_2';

	DEBUG boolean := false;

	v_trace_file_name varchar2(256);
	v_line varchar2(32767);
	i_file_size pls_integer;
	i_file_pos pls_integer;
	i_alert_pos pls_integer;
	i_start_op_time number;
	i_elapsed_seconds number;
	fh_tracefile utl_file.file_type;

	trace_data clob;

	/*
	== abstracted interface to dbms_output
	*/

	function does_trace_file_exist (file_name_in varchar2)
	return boolean
	is
		v_file_exists boolean;
		i_file_length pls_integer;
		i_file_blocksize pls_integer;
	begin
		utl_file.fgetattr(
			DUMPDIR,
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
			DUMPDIR,
			file_name_in,
			v_file_exists,
			i_file_length,
			i_file_blocksize
		);

		return i_file_length;
	end;

	function get_clob (filename_in varchar2) return clob
	is
		temp_clob clob;
		trace_bfile bfile;
		l_dest_offset   integer := 1;
		l_src_offset    integer := 1;
		l_bfile_csid    number  := 0;
		l_lang_context  integer := 0;
		l_warning       integer := 0;

	begin
		dbms_lob.createtemporary(lob_loc => temp_clob, cache => false, dur => dbms_lob.session);
		trace_bfile := bfilename(DUMPDIR, filename_in);
		dbms_lob.fileopen(trace_bfile, dbms_lob.file_readonly);

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

		return temp_clob;

	end;

begin

	v_trace_file_name := :tracefile_name_in;
	--v_trace_file_name := 'ORCL_ora_6064.trc';

	if does_trace_file_exist(v_trace_file_name) then
		null;
	else
		raise_application_error(-20001,'Trace file ' || v_trace_file_name || ' does not exist');
	end if;

	i_file_size := get_file_size(v_trace_file_name);

	-- now read the file
	-- the perl script will track the location to start reading
	-- just hard coding it for now

	i_start_op_time := dbms_utility.get_time;
	--goto THE_END;

	i_elapsed_seconds := (dbms_utility.get_time - i_start_op_time) / 100;
	<<THE_END>>

	--trace_data := get_clob(v_trace_file_name);
	--:out := get_clob(v_trace_file_name);
	:out := to_clob('this is a test CLOB');

end;};

$sth = $dbh->prepare($sql,{ora_check_sql => 0});
#$sth->{TraceLevel} = '6|SQL';
$sth->{TraceLevel} = '0';

my $traceDataCLOB;
my $tracefileName=q{ORCL_ora_6064.trc};
$tracefileName=q{cdb2_ora_24755.trc};
$sth->bind_param( ':tracefile_name_in', $tracefileName, { ora_type => ORA_VARCHAR2 } );
$sth->bind_param_inout( ':out', \$traceDataCLOB, 0, { ora_type => ORA_CLOB } );

$sth->execute;

#@dbms_output_buffer = $dbh->func('dbms_output_get');
#print @dbms_output_buffer, "\n";

#print "$traceDataCLOB\n";

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
  -sysdba        logon as sysdba
  -sysoper       logon as sysoper

  example:

  $basename -database dv07 -username scott -password tiger -sysdba 
/;
   exit $exitVal;
};



