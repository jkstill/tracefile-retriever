
create or replace function get_file_lines(fh_in in utl_file.file_type)
	return filetext_row_set
pipelined is
	out_rec filetext_typ := filetext_typ(null);
	buf varchar2(32767);
	f_pos varchar2(38);
begin
	while true
	loop
		begin
			utl_file.get_line(fh_in, buf, 32767);
			f_pos := to_char(utl_file.fgetpos(fh_in));
			-- preface with file position
			out_rec.text := f_pos || '|' || buf;
			pipe row(out_rec);

		exception
		when NO_DATA_FOUND then
			exit;
		when others then
			raise;
		end;
	end loop;

	return;

end; 
/

show errors function get_file_lines

grant execute on get_file_lines to public;
