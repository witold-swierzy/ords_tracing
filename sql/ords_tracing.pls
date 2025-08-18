create or replace package ords_tracing
is

	fmt_text constant integer := 1;
	fmt_json constant integer := 2;

	type session_array_type is table of gv$session%rowtype;

	function list_ords_sessions return session_array_type pipelined parallel_enable;
	procedure snapshot;
	procedure create_snapshot_job(freq integer);
	procedure drop_snapshot_job;
	function report return clob;
	procedure purge_logs;
end;
/