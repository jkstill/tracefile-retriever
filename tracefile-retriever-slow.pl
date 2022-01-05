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

$dbh->{ora_check_sql} = 0;
$dbh->{RowCacheSize} = 100;

# just found this method in AWS docs - they have more than one way documented, but this one works.
# see https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_LogAccess.Concepts.Oracle.html
# look for 'shows the text of a log file'
# dunno why they do not use this same code for 'Retrieving trace files', but that code 
# relies on an external table with a varchar2(400) column - it does not work properly
# Note: this is about 3.5x slower than the method used in tracefile-retriever.pl
$sql = q{SELECT text FROM TABLE(rdsadmin.rds_file_util.read_text_file(:DUMPDIR,:tracefile_name_in))};

my $sth = $dbh->prepare($sql,{ora_check_sql => 0});

#print "DUMPDIR: $dumpDir\n";
#print "tracefile: $tracefileName\n";

$sth->bind_param( ':DUMPDIR', $dumpDir, { ora_type => ORA_VARCHAR2 } );
$sth->bind_param( ':tracefile_name_in', $tracefileName, { ora_type => ORA_VARCHAR2 } );
$sth->execute;

while ( my ($text) = $sth->fetchrow_array) {
	# handle blank lines
	$text = defined($text) ? $text : '';
	print "$text\n";
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

                 user will be prompted for password if necessary

  -dumpdir       the name of the dump directory
  -tracefile     the name of the tracefile to retrieve
  -sysdba        logon as sysdba
  -sysoper       logon as sysoper

  example:

  $basename -database dv07 -username scott -password tiger -sysdba 

  Why not use CLOB?  See the notes in 'perldoc $basename'
  (CLOB should be faster)

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

=head1 tracefile-retriever.pl

 usage: 

  -database      target instance
  -username      target instance account name
  -password      target instance account password
                 user will be prompted for password if necessary
  -dumpdir       the name of the dump directory
  -tracefile     the name of the tracefile to retrieve
  -sysdba        logon as sysdba
  -sysoper       logon as sysoper

  example:

  tracefile-retriever.pl -database dv07 -username scott -password tiger 

  Why not use CLOB?  See the following notes.

  Why not use PIPE ROW?  Because it requires creating database objects,
  which is frequently either inconvenient, or not possible


=cut


