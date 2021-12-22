
@clear_for_spool

col text format a32767
set linesize 32767
set term off

spool ORCL_ora_6064.trc

SELECT text FROM TABLE(rdsadmin.rds_file_util.read_text_file('BDUMP','ORCL_ora_6064.trc'));

spool off

set term on
@clears




