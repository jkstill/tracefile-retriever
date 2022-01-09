
-- this may be called directly as shown in demo-sqlplus.sql
-- or used in a PIPE ROW function so that it can be called directly with SELECT
-- see demo-pipe.sql

create or replace function get_dir_list_array(directory varchar2) return filelist_t as
language java name 'traceFileLister.getDirListArrayWrapped(java.lang.String) return java.sql.Array';
/
show errors function get_dir_list_array

