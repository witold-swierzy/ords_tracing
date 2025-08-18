create or replace package body ords_tracing
is
	
	function list_ords_sessions return session_array_type
	pipelined
	parallel_enable
	is
	begin
	   for r in (select * 
                          from gv$session 
                          where program = 'Oracle REST Data Services'
                          and username <> 'ORDS_PUBLIC_USER' ) loop
			pipe row (r);	
		end loop;
	end;

	procedure snapshot
	is
		v_plan clob := '';
	begin
		for r1 in (select * 
		          from table(list_ords_sessions)
		          where  (sid,serial#,prev_sql_id) 
		          not in (select sid, serial#, prev_sql_id 
		          from ords_sessions_table)) loop
			insert into ords_sessions_table values r1;
			
			for r2 in (select * from dbms_xplan.display_cursor(r1.prev_sql_id)) loop
				v_plan := v_plan || r2.plan_table_output || chr(10);
			end loop;
			
			insert into ords_sql_plan_table values 
			(r1.inst_id, r1.sid, r1.serial#, r1.prev_sql_id, v_plan);
		end loop;
		commit;
	end;

	procedure create_snapshot_job(freq integer)
	is
		n_of_jobs number(10);
	begin
		
		select count(*)
		into n_of_jobs
		from user_scheduler_jobs
		where job_name = 'ORDS_TRACING_JOB';

		if n_of_jobs <> 0 then
			raise_application_error(-20001,'An ORDS tracing job is already running. Delete it first.');
		end if;

		dbms_scheduler.create_job('ORDS_TRACING_JOB',
                                  'STORED_PROCEDURE',
                                  'ORDS_TRACING.SNAPSHOT',
                                  enabled => true,
                                  repeat_interval => 'FREQ=SECONDLY;INTERVAL='||freq);

	end;

	procedure drop_snapshot_job
	is
	begin
		dbms_scheduler.drop_job('ORDS_TRACING_JOB',
		                        defer => true);
	end;

	function report return clob
	is
		v_rep clob := '';
	begin
		for r in (select *
		          from ords_sessions_table) loop
				v_rep := v_rep || 'session details : '||chr(10)||
				                  '===================================================='||chr(10)||
								  'username : '||r.username||chr(10)||
								  'client machine : '||r.machine||chr(10)||
								  'inst_id, sid, serial# : '||r.inst_id||', '||r.sid||', '||r.serial#||chr(10)||
								  chr(10);
				dbms_output.put_line(v_rep);							
				for s in (select * from ords_sql_plan_table
				          where inst_id = r.inst_id
						    and sid     = r.sid
							and serial# = r.serial#) loop
					v_rep := v_rep || s.sql_plan||chr(10);
				end loop;
			v_rep := v_rep||'======================================================================'||chr(10)||chr(10);
		end loop;
		return v_rep;
	end;

	procedure purge_logs
	is
	begin
		delete from ords_sql_plan_table;
		delete from ords_sessions_table;
		commit;
	end;
end;
/
