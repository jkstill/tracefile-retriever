#!/usr/bin/env perl

# get tracefile from remote DB, such as an RDS instance

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

#print "DUMPDIR: $dumpDir\n";
#print "tracefile: $tracefileName\n";

$sql = "select bfilename(?, ?) from dual";
my $sth = $dbh->prepare($sql, {ora_auto_lob=>0}) or die;
$sth->execute($dumpDir, $tracefileName);
# LOB Locator
my ($loc) = $sth->fetchrow_array();

my $blksz=2**20;
for (my $off=1; 1; $off += $blksz) {
	my $piece = $dbh->ora_lob_read($loc, $off, $blksz);
	last if length($piece) == 0;
	print $piece;
}

$sth->finish;
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

  Note: This script uses dbms_output to move the data
  due to this, the entire trace file is buffered on the server side (PGA memory)
  be careful with very large trace files.

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

  This script uses  bfilename() and ora_lob_read().

  These are quite fast compared to the built in method provided by AWS, about 3.5x faster

  See tracefile-retriever-SLOW.pl


=cut


