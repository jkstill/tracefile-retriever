
Tracefile Listing with Oracle Java
==================================

Here a combination of Oracle Java, client Java, and PL/SQL is used to list the files in the tracefile directory.

There is no limit on the number of files that may be shown.

## Install

Just run the create scripts in the order shown

### create-directory.sql 

Create the `BDUMP` Oracle directory.

This will point to the location on the file system of the trace files.

### grants.sql

Adjust as needed.

This *may* work with Oracle on RDS if the proper permissions can be set.

### filelist-type.sql

Create the stored type for the procedures

### traceFileLister-java.sql

Create the Java Stored Procedure.

### create-getTraceFiles.sql

Note: this is not done - needs to PIPE ROW

Create the PL/SQL wrapper for the Java call.

### demo-sqlplus.sql

Demo of calling the file listing function directly from a PL/SQL block.

### demo-pipe.sql

Using SELECT to call the tracefile_lister.filepipe function.


## Notes

This stackoverflow article helped with some array bits
https://stackoverflow.com/questions/7872688/how-to-return-an-array-from-java-to-pl-sql



