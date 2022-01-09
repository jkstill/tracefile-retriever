

declare
  -- database js01 - 11g
  files constant filelist_t := get_dir_list_array('BDUMP');
begin
  for i in files.first .. files.last loop
    dbms_output.put_line('files(' || i || ') = ' || files(i));
  end loop;
end;
/
