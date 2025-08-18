drop table if exists ords_sessions_table;

create table ords_sessions_table 
as select * from gv$session
where 1=2;

drop table if exists ords_sql_plan_table;
create table ords_sql_plan_table (inst_id  number(10),
                                  sid      number(10), 
                                  serial#  number(10), 
                                  sql_id   varchar2(200),
                                  sql_plan clob);
