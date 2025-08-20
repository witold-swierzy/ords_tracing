create or replace package ords_trc_pkg
is
	type job_record_type is record ( job_name varchar2(200),
	                                 frequency number(10) );
	type session_array_type is table of gv$session%rowtype;
	type job_array_type is table of job_record_type;
	
	procedure snapshot(p_username varchar2 := null);

	procedure create_job(p_username  varchar2 := null,
	                     p_frequency integer := 5);

	procedure drop_job(p_username varchar2 := null, 
	                   p_purge_logs boolean := false);

	procedure drop_all_jobs(p_purge_logs boolean := false);

	function get_jobs return job_array_type
	pipelined
	parallel_enable;

	procedure print_jobs;

	function get_sessions(p_username varchar2 := null) return session_array_type
	pipelined
	parallel_enable;

	procedure print_sessions(p_username varchar2 := null);

	function get_report(p_username varchar2 := null) return clob;

	procedure print_report(p_username varchar2 := null);

	procedure purge_logs(p_username varchar2 := null);
end;
/