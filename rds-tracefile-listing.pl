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

$dbh->do(q{alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss'});
$dbh->do(q{begin rdsadmin.manage_tracefiles.refresh_tracefile_listing;end;});

$sql = q{select filename, type, filesize, mtime from table(rdsadmin.rds_file_util.listdir('} . uc($dumpDir) . q{')) order by lower(filename)};
my $sth = $dbh->prepare($sql,{ora_check_sql => 0});
$sth->execute;

printf "%-60s  %10s %10s %-30s\n",'FILENAME', 'TYPE', 'SIZE', 'MODTIME';
while ( my ($filename, $type, $filesize, $mtime) = $sth->fetchrow_array  )  {
	printf "%-60s  %10s %10d %-30s\n",$filename, $type, $filesize, $mtime;
}

$dbh->disconnect;

sub usage {
	my $exitVal = shift;
	$exitVal = 0 unless defined $exitVal;
	use File::Basename;
	my $basename = basename($0);
	print qq/

List the tracefiles in the '--dumpdir' directory of an RDS database

usage: $basename

  -database      target instance
  -username      target instance account name
  -password      target instance account password
                 
                 user will be prompted for password if necessary

  -dumpdir       the name of the dump directory
  -sysdba        logon as sysdba
  -sysoper       logon as sysoper

  example:

  $basename -database dv07 -username scott -password tiger -sysdba 


/;

   exit $exitVal;
};


sub sigclean {
	print "Caught Signal $!\n";
	print "Cleanup and Exit\n";
	$dbh->disconnect if $dbh;
	die;
}

