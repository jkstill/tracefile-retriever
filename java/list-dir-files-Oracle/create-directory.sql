
col v_diag_trace new_value v_diag_trace noprint;

select value v_diag_trace from v$diag_info where name = 'Diag Trace';

create or replace directory bdump as '&v_diag_trace'
/
