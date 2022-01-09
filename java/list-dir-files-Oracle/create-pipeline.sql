

create or replace package tracefile_lister
is
	function filepipe ( dump_dir varchar2 ) return filelist_t pipelined;
end;
/

show errors package tracefile_lister

create or replace package body tracefile_lister
is

	function filepipe ( dump_dir varchar2 ) return filelist_t pipelined
	is
		files filelist_t;
	begin
		files := get_dir_list_array('BDUMP');

		for i in files.first .. files.last
		loop
			pipe row(files(i));
		end loop;
	end;

end;
/

show errors package body tracefile_lister



