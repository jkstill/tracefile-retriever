

create or replace type filetext_typ as object ( text varchar2(32767))
/

create or replace type filetext_row_set as table of filetext_typ
/


