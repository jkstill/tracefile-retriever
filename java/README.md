Java Tracefile Utilities for Oracle
===================================


Several different Java programs for listing trace files are available here, along with one Java program for retrieving trace files.

One of the different listing methods may work for you, depending on the environment.

## Environment files

The `.javeenv-example` file is an example of the `.javaenv` file that I use when building and testing these programs.

Their use is not mandatory, it is just a convenience.

## Build and Test scripts

As there are few Java files required, the building and testing is done via simple shell scripts.

If a class needs to be compiled, the script will compile it, and then run it.

The following is an example of one of them

### RetrieveDirFile.sh

```text
$  touch RetrieveDirFile.java

$  ./RetrieveDirFile.sh  js01_lgwr_18448.trc > trace/js01_lgwr_18448.trc
Building RetrieveDirFile.class
retrieving js01_lgwr_18448.trc: 2420 bytes

real	0m0.757s
user	0m0.632s
sys	0m0.104s
```

## Libraries

Some classes are used in some or all of the Java programs.

Each utility directory has soft link back to these directories.

### dates

The `OraDates` class is in the `dates` package, found at `./dates`.

### oraConnect

The `OracleConnect` class is in the `oraConnect` package, found at `./oraConnect`.

## Trace File Listing Utilties

Each of the following are a directory with Java code for listing the files in the trace file directory.

Each does this job a little differently, so pick the one most appropriate for you.

### ./list-dir-files-Oracle

Java programs that use a combination of Java in the database, Java on the client, and PL/SQL, to list the files in the trace file directory.

It may sound somewhat complicated, but it does work well.,

This should also work with Oracle databases on Amazon RDS.  The `grants.sql` script may require some adjustment first.

To help prevent abuse of this, the Oracle Java code could be implemented in a database utility account, created by you, and locked so that it cannot be logged into.

Users that need the functionality could be allowed to use Oracle Proxy logins to run the code.

This is a good article by [Simon Pane](https://blog.pythian.com/author/pane/) explaining how that works [The power of the Oracle Database Proxy authenticated connections](https://blog.pythian.com/the-power-of-the-oracle-database-proxy-authenticated-connections/)

This program requires an Oracle Directory name as an input.

### ./list-dir-files-RDS

The Java program in this directory can be used with an Oracle database on Amazon RDS, by using the RDS `rdsadmin.tracefile_listing` procedure.

The method used is described here [AWS - Oracle database log files ](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_LogAccess.Concepts.Oracle.html)

This will work by logging in as the ADMIN user, or an equivalent user.

This program requires an Oracle Directory name as an input.


### ./list-dir-files-RMAN

This is yet another method to get the list of files. It relies on an undocumented feature of the `dbms_backup_restore` package.

As it requires SYSDBA access, it probably is not for everybody, but nonetheless, you can see how to do it here.

This program requires an full path name as an input. That does make it somewhat dangerous to use.

### ./retrieve-dir-files

This Java program can be used to retrieve a tracefile.  It works equally well on Oracle databases on RDS as it does on on-premises databases.

Following is an exmaple of listing the trace file directory with the Oracle Java program, and then retrieving a trace file.


#### list the files - local network

```text
$  cd list-dir-files-Oracle

$  ./ListDirFilesPIPE.sh 

$  ./ListDirFilesPIPE.sh 
alert_js01.log
js01_arc0_18470.trc
js01_arc0_18470.trm
js01_arc1_18472.trc
js01_arc1_18472.trm
...
```

#### retrieve the file - local network

```text
$  cd ../retrieve-dir-files/

$  ./RetrieveDirFile.sh alert_js01.log > trace/alert_js01.log
retrieving alert_js01.log: 52517963 bytes

real	0m1.589s
user	0m0.884s
sys	0m0.240s
```



