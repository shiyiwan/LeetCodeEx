-- 禁用外键
BEGIN
  FOR i IN (SELECT 'alter table ' || t.table_name || ' disable constraint ' || t.constraint_name AS v_sql
              FROM user_constraints t
             WHERE t.constraint_type = 'R'
             ORDER BY t.table_name) LOOP
    EXECUTE IMMEDIATE i.v_sql;
  END LOOP;
END;
/
 
-- 同步角色
truncate TABLE bibuser.t_xtgl_role;
INSERT INTO bibuser.t_xtgl_role
SELECT * FROM bibuser.t_xtgl_role@link_177.regress.rdbms.dev.us.oracle.com;
     
-- 删除无效角色对应的人员角色记录，功能角色记录，模块角色记录
DELETE FROM t_xtgl_userrole r WHERE r.role_id NOt IN (SELECT role_id FROM bibuser.t_xtgl_role);
DELETE FROM t_xtgl_rolefunction r WHERE r.role_id NOt IN (SELECT role_id FROM bibuser.t_xtgl_role);
DELETE FROM t_xtgl_rolemodular r WHERE r.role_id NOt IN (SELECT role_id FROM bibuser.t_xtgl_role);
COMMIT;
 
-- 启用外键
BEGIN
  FOR i IN (SELECT 'alter table ' || t.table_name || ' enable constraint ' || t.constraint_name AS v_sql
              FROM user_constraints t
             WHERE t.constraint_type = 'R'
             ORDER BY t.table_name) LOOP
    EXECUTE IMMEDIATE i.v_sql;
  END LOOP;
END;
/
