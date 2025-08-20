declare
    v_cnt number(10);
begin
    select count(*) 
    into v_cnt
    from user_objects
    where object_name = 'ORDS_TRC_PKG';

    if v_cnt > 0 then
        ords_trc_pkg.drop_all_jobs;
    end if;
end;
/

@tables.sql
@ords_tracing.pls
@ords_tracing.plb
