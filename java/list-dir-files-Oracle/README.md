
Tracefile Listing with Oracle Java
==================================


## Install

### create-directory.sql 

Create the `BDUMP` Oracle directory.

This will point to the location on the file system of the trace files.

### grants.sql

Adjust as needed.

Probably needs to be updated for RDS if used there.


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



