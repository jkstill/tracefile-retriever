
-- kudos to Tim Hall for sorting out the permission requirements
-- https://oracle-base.com/articles/misc/list-files-in-a-directory-from-plsql-and-sql-java

def username=JKSTILL

CREATE USER &username IDENTIFIED BY testuser1 QUOTA UNLIMITED ON users;

GRANT CREATE SESSION, CREATE PROCEDURE, CREATE TYPE, CREATE VIEW TO &username;

EXEC DBMS_JAVA.grant_permission('&username', 'java.io.FilePermission', '<>', 'read')
EXEC DBMS_JAVA.grant_permission('&username', 'SYS:java.lang.RuntimePermission', 'readFileDescriptor', '')

GRANT JAVAUSERPRIV TO &username;

grant select on dba_directories to &username;

