
-- trace-file-retriever.sql

@clear_for_spool

set term off
set linesize 32767
spool test.trc

var n_elapsed_seconds number

def s_tracefile_name='ORCL_ora_6064.trc'
declare

	DUMPDIR CONSTANT varchar(128) := 'BDUMP';

	DEBUG boolean := false;

	v_trace_file_name varchar2(256);
	v_line varchar2(32767);
	i_file_size pls_integer;
	i_file_pos pls_integer;
	i_alert_pos pls_integer;
	i_start_op_time number;
	i_elapsed_seconds number;
	fh_tracefile utl_file.file_type;

	i_lines_limit pls_integer := 10 * 1e6;
	i_curr_line pls_integer := 0;

	/*
	== abstracted interface to dbms_output
	*/

	-- do not set these outside of the control procedures
	b_p_enabled boolean := false;

	/*
	===============================================
	== function p_enabled
	== return true/false to check if dbms_output
	== is enabled internally
	===============================================
	*/
	function p_enabled return boolean
	is
	begin
		return b_p_enabled;
	end;

	/*
	===============================================
	== procedure p_enable
	== enable dbms_output
	===============================================
	*/
	procedure p_enable 
	is 
	begin
		-- NULL == unlimited
		dbms_output.enable(null);
	end;

	/*
	===============================================
	== procedure p_on
	== internally enable dbms_output use via p() and pl()
	===============================================
	*/
	procedure p_on
	is
	begin
		p_enable;
		b_p_enabled := true;
	end;

	/*
	===============================================
	== procedure p_off
	== internally disable dbms_output use via p() and pl()
	===============================================
	*/
	procedure p_off
	is
	begin
		b_p_enabled := false;
	end;


	/*
	===============================================
	== procedure p
	== print a line without linefeed
	===============================================
	*/
	procedure p (p_in varchar2)
	is
	begin
		if p_enabled then
			dbms_output.put(p_in);
		end if;
	end;

	/*
	===============================================
	== procedure p;
	== print a line with linefeed
	===============================================
	*/
	procedure pl (p_in varchar2)
	is
	begin
		if p_enabled then
			p(p_in);
			dbms_output.new_line;
		end if;
	end;

	/*
	===============================================
	== procedure banner;
	== print a line of 80 '='
	== specify an optional character with v_banner_char_in
	===============================================
	*/

	procedure banner( v_banner_char_in varchar2 default '=')
	is
	begin
		pl(rpad(v_banner_char_in,80,v_banner_char_in));
	end;

	function get_instance_name return varchar2
	is
		v_instance_name varchar2(20);
	begin

		select instance_name into v_instance_name from v$instance;
		return v_instance_name;
	
	end;


	function does_trace_file_exist (file_name_in varchar2)
	return boolean
	is
		v_file_exists boolean;
		i_file_length pls_integer;
		i_file_blocksize pls_integer;
	begin
		utl_file.fgetattr(
			DUMPDIR,
			file_name_in,
			v_file_exists,
			i_file_length,
			i_file_blocksize
		);

		return v_file_exists;
	end;

	function get_file_size (file_name_in varchar2)
	return pls_integer
	is
		v_file_exists boolean;
		i_file_length pls_integer;
		i_file_blocksize pls_integer;
	begin
		utl_file.fgetattr(
			DUMPDIR,
			file_name_in,
			v_file_exists,
			i_file_length,
			i_file_blocksize
		);

		return i_file_length;
	end;

	function get_fh(v_trace_file_in varchar2) return utl_file.file_type
	is
		f_fh utl_file.file_type;
	begin
		f_fh := utl_file.fopen(DUMPDIR,v_trace_file_in, 'r', 32767);
		return f_fh;
	end;

	procedure close_fh(fh_in in out utl_file.file_type)
	is
	begin
		utl_file.fclose(fh_in);
	end;

	-- where to start reading - always start at zero in this case
	-- we always want the entire trace file
	procedure fileseek(fh_in in out utl_file.file_type)
	is
	begin
		utl_file.fseek(fh_in,0);
	end;

begin

	v_trace_file_name := '&s_tracefile_name';

	p_on;

	if does_trace_file_exist(v_trace_file_name) then
		--pl(v_trace_file_name || ': file exists');
		null;
	else
		pl('file does NOT exist');
		raise_application_error(-20001,'Trace file ' || v_trace_file_name || ' does not exist');
	end if;

	i_file_size := get_file_size(v_trace_file_name);
	--pl('file size: ' || to_char(i_file_size));

	fh_tracefile := get_fh(v_trace_file_name);

	-- now read the file
	-- the perl script will track the location to start reading
	-- just hard coding it for now

	i_start_op_time := dbms_utility.get_time;
	--goto THE_END;

	--i_lines_limit := 100;
	i_curr_line := 0;

	for orec in (select text from table(get_file_lines(fh_tracefile)))
	loop
		-- text returned as file_position|text
		i_alert_pos := to_number(substr(orec.text,1,instr(orec.text,'|')-1));
		v_line := substr(orec.text,instr(orec.text,'|')+1);

		-- output skews the read time
		if DEBUG then
			pl(to_char(i_alert_pos));
			pl(to_char(v_line));
		end if;

		pl(v_line);

		i_curr_line := i_curr_line + 1;
		if (i_curr_line > i_lines_limit) then
			exit;
		end if;
		
	end loop;

	close_fh(fh_tracefile);

	i_elapsed_seconds := (dbms_utility.get_time - i_start_op_time) / 100;
	:n_elapsed_seconds := i_elapsed_seconds;
	

	<<THE_END>>

	null; -- must be a line of code following a label


end;
/

spool off

prompt Read Time in Seconds:
print :n_elapsed_seconds


