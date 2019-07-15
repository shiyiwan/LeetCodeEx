/*
将脚本中的 B.PROJECT_CODE = '?'  替换为需要删除的项目 PROJECT_CODE
*/
    
-- 1. 执行删除前将以下sql结果查出，并xls导出，
-- 为后期删除附件做准备。
SELECT b.project_name, b.project_code, b.project_id, t.projour_id
  FROM bibuser.v_pm_projectinfo b, bibuser.v_pm_projour_info t
 WHERE b.project_code = '170069_固收_北京业务部'
   AND b.project_id = t.project_id;
    
-- 2. 删除记录部分
-- 针对多个项目删除的情形，只需要把FOR i in (SELECT project_id
--             FROM bibuser.v_pm_projectinfo b
--             WHERE (b.project_code = vs_project_code ...)
-- 中的 b.project_code = vs_project_code
-- 替换为 b.project_code in ( 'project_code1','project_code2'...)
DECLARE
  vn_code         INT;
  vs_note         VARCHAR2(3000);
  vs_project_code VARCHAR2(200) := '170069_固收_北京业务部';
BEGIN
  FOR i IN (SELECT project_id
              FROM bibuser.v_pm_projectinfo b
             WHERE (b.project_code = vs_project_code)) LOOP
    FOR x IN (SELECT inst_id
                FROM bibuser.t_pm_projourinst
               WHERE project_id = i.project_id
              -- 此处视情况解注释 或者 加注释
              --(因为部分流程如用印送审和历史数据录入 未写入项目流水表，无法完全删除，
              -- 需解开注释，条件task title like部分改成该项目公司名，如 展鹏科技IPO )
              -- UNION SELECT inst_id FROM bibuser.t_flow_rutaskrela fr WHERE fr.task_title LIKE '%展鹏科技IPO%'
              ) LOOP
      DELETE FROM bibuser.t_flow_core_ru_borrow WHERE proc_inst_id = x.inst_id;
      DELETE FROM bibuser.t_flow_core_ru_suggest_reply r
       WHERE EXISTS (SELECT 1
                FROM bibuser.t_flow_core_ru_suggest s
               WHERE s.proc_inst_id = x.inst_id
                 AND r.suggestion_id = s.suggestion_id);
      DELETE FROM bibuser.t_flow_core_ru_suggest WHERE proc_inst_id = x.inst_id;
      DELETE FROM bibuser.t_flow_core_ru_notice_receive r
       WHERE EXISTS (SELECT 1
                FROM bibuser.t_flow_core_ru_notice_send s
               WHERE s.proc_inst_id = x.inst_id
                 AND r.send_id = s.send_id);
      DELETE FROM bibuser.t_flow_core_ru_notice_send WHERE proc_inst_id = x.inst_id;
      DELETE FROM bibuser.t_flow_core_his_task_variable WHERE proc_inst_id = x.inst_id;
      DELETE FROM bibuser.t_flow_core_ru_task_variable WHERE proc_inst_id = x.inst_id;
      DELETE FROM bibuser.t_flow_core_his_task_user WHERE proc_inst_id = x.inst_id;
      DELETE FROM bibuser.t_flow_core_ru_task_user WHERE proc_inst_id = x.inst_id;
      DELETE FROM bibuser.t_flow_core_his_task WHERE proc_inst_id = x.inst_id;
      DELETE FROM bibuser.t_flow_core_ru_task WHERE proc_inst_id = x.inst_id;
      DELETE FROM bibuser.t_flow_core_his_node_relation WHERE proc_inst_id = x.inst_id;
      DELETE FROM bibuser.t_flow_core_ru_node_relation WHERE proc_inst_id = x.inst_id;
      DELETE FROM bibuser.t_flow_core_ru_node WHERE proc_inst_id = x.inst_id;
      DELETE FROM bibuser.t_flow_core_his_node WHERE proc_inst_id = x.inst_id;
      DELETE FROM bibuser.t_flow_core_ru_procinst WHERE proc_inst_id = x.inst_id;
      bibuser.pkg_flow_util.pro_delete_inst(vn_code, vs_note, x.inst_id);
      DELETE FROM bibuser.t_flow_rutaskrela a WHERE a.inst_id = x.inst_id;
      DELETE FROM bibuser.t_pm_projourinst a WHERE a.inst_id = x.inst_id;
    END LOOP;
    -- 删除附件信息 per project_id
    DELETE FROM bibuser.t_pub_attachment_export m
     WHERE EXISTS (SELECT 1
              FROM bibuser.t_pub_attachment p
             WHERE p.attachment_id = m.attachment_id
               AND p.business_id = i.project_id);
    DELETE FROM bibuser.t_pub_attachment_process m
     WHERE EXISTS (SELECT 1
              FROM bibuser.t_pub_attachment p
             WHERE p.attachment_id = m.attachment_id
               AND p.business_id = i.project_id);
    DELETE FROM bibuser.t_pub_attachment m WHERE m.business_id = i.project_id;
    -- 删除附件信息 per PROJOUR_ID
    DELETE FROM bibuser.t_pub_attachment_export m
     WHERE EXISTS
     (SELECT 1
              FROM bibuser.t_pub_attachment p
             WHERE p.attachment_id = m.attachment_id
               AND p.business_id IN
                   (SELECT DISTINCT t.projour_id FROM bibuser.v_pm_projour_info t WHERE t.project_id = i.project_id));
    DELETE FROM bibuser.t_pub_attachment_process m
     WHERE EXISTS
     (SELECT 1
              FROM bibuser.t_pub_attachment p
             WHERE p.attachment_id = m.attachment_id
               AND p.business_id IN
                   (SELECT DISTINCT t.projour_id FROM bibuser.v_pm_projour_info t WHERE t.project_id = i.project_id));
    DELETE FROM bibuser.t_pub_attachment m
     WHERE m.business_id IN
           (SELECT DISTINCT t.projour_id FROM bibuser.v_pm_projour_info t WHERE t.project_id = i.project_id);
    DELETE FROM bibuser.t_pm_project_bondissue WHERE project_id = i.project_id;
    DELETE FROM bibuser.t_pm_projectagency WHERE project_id = i.project_id;
    DELETE FROM bibuser.t_pm_projectcontact WHERE project_id = i.project_id;
    DELETE FROM bibuser.t_pm_projectinfo WHERE project_id = i.project_id;
    DELETE FROM bibuser.t_pm_projectmember WHERE project_id = i.project_id;
    DELETE FROM bibuser.t_pm_project_clob WHERE project_id = i.project_id;
    DELETE FROM bibuser.t_pm_project_contractor WHERE project_id = i.project_id;
    DELETE FROM bibuser.t_pm_project_hisbondissue WHERE project_id = i.project_id;
    DELETE FROM bibuser.t_pm_project_ibma WHERE project_id = i.project_id;
    DELETE FROM bibuser.t_pm_project_ibstockissue WHERE project_id = i.project_id;
    DELETE FROM bibuser.t_pm_project_pefundsetup WHERE project_id = i.project_id;
    DELETE FROM bibuser.t_pm_project_pepromanage WHERE project_id = i.project_id;
    DELETE FROM bibuser.t_pm_project_tbdirrefin WHERE project_id = i.project_id;
    DELETE FROM bibuser.t_pm_project_tbrlisting WHERE project_id = i.project_id;
    DELETE FROM bibuser.t_pm_projour_bondissue WHERE project_id = i.project_id;
    DELETE FROM bibuser.t_pm_projour_clobattr WHERE project_id = i.project_id;
    DELETE FROM bibuser.t_pm_projour_ibma WHERE project_id = i.project_id;
    DELETE FROM bibuser.t_pm_projour_ibstockissue WHERE project_id = i.project_id;
    DELETE FROM bibuser.t_pm_projour_pefundsetup WHERE project_id = i.project_id;
    DELETE FROM bibuser.t_pm_projour_pepromanage WHERE project_id = i.project_id;
    DELETE FROM bibuser.t_pm_projour_tbdirrefin WHERE project_id = i.project_id;
    DELETE FROM bibuser.t_pm_projour_tbrlisting WHERE project_id = i.project_id;
    -- 删除债券存续期管理项目计划提醒人信息
    DELETE FROM bibuser.t_pm_projour_bd_plan_recipient m
     WHERE m.bond_plan_id IN
           (SELECT bond_plan_id FROM bibuser.t_pm_projour_bondduration_plan WHERE project_id = i.project_id);
    -- 删除债券存续期管理项目计划信息
    DELETE FROM bibuser.t_pm_projour_bondduration_plan t WHERE t.project_id = i.project_id;
    -- 删除债券存续期管理项目流程流水
    DELETE FROM bibuser.t_pm_projour_bondduration m WHERE m.project_id = i.project_id;
    -- 删除债券存续期管理项目项目流水
    DELETE FROM bibuser.t_pm_project_bondduration m WHERE m.project_id = i.project_id;
   
    -- 项目中介列表
    DELETE FROM bibuser.t_pm_projectagency t WHERE t.project_id = i.project_id;
   
    -- 项目联席信息
    DELETE FROM bibuser.t_pm_jointtrader t WHERE t.project_id = i.project_id;
   
    -- 项目关注问题
    DELETE FROM bibuser.t_pm_concernschedule t WHERE t.project_id = i.project_id;
   
    -- 项目协议送审
    DELETE FROM bibuser.t_protocol_approval t WHERE t.project_id = i.project_id;
   
    -- 首发项目网下禁止配售对象
    DELETE FROM bibuser.t_pm_lockuptarget t WHERE t.project_id = i.project_id;
   
    -- 项目底稿
    DELETE FROM bibuser.t_pm_manuscript t WHERE t.project_id = i.project_id;
   
    -- 基金设立-管理费用
    DELETE FROM bibuser.t_pm_pefund_manageexpense t WHERE t.project_id = i.project_id;
   
    -- 借阅人查询项目权限表
    DELETE FROM bibuser.t_pm_borrower_qry_auth t WHERE t.project_id = i.project_id;
  
    -- 项目投票列表
    DELETE FROM bibuser.t_flow_votelist t WHERE t.project_id = i.project_id;
   
    -- 项目会议信息
    DELETE FROM bibuser.t_flow_meeting t WHERE t.project_id = i.project_id;
   
    -- 协议录入项目信息表
    DELETE FROM bibuser.t_protocol_appr_project t WHERE t.project_id = i.project_id;
   
    -- 项目简报
    DELETE FROM bibuser.t_pm_project_brief t WHERE t.project_id = i.project_id;
   
    -- 债券发行项目可交换债信息
    DELETE FROM bibuser.t_pm_bondissue_eb_info t WHERE t.project_id = i.project_id;
   
    -- 项目公共流水表
    DELETE FROM bibuser.t_pm_projour_pub t WHERE t.project_id = i.project_id;
   
    -- 项目成员变更日志
    DELETE FROM bibuser.t_pm_projectmember_change_log t WHERE t.project_id = i.project_id;
   
    -- 项目状态变更日志
    DELETE FROM bibuser.t_pm_project_status_log t WHERE t.project_id = i.project_id;
   
    -- 项目流程打分情况
    DELETE FROM bibuser.t_pm_projour_quality_score t WHERE t.project_id = i.project_id;
   
    -- 项目禁售名单对吧
    DELETE FROM bibuser.t_pm_lockup_listcompare t WHERE t.project_id = i.project_id;
   
    -- 项目用印材料表
    DELETE FROM bibuser.t_pm_seal_material t WHERE t.project_id = i.project_id;
   
    dbms_output.put_line(i.project_id || ': DELETED.');
  END LOOP;
  COMMIT;
  dbms_output.put_line('DELETE SUCCESS.');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
/
    
-- 3.将以下sql中的 123, 3434 替换为查询1结果中 PROJOUR_ID 以及 PROJECT_ID，在大投行附件数据库执行
BEGIN
  FOR i IN (SELECT p.business_id, p.attachment_id FROM bibuser.t_pub_attachment p WHERE p.business_id IN (123, 3434)) LOOP
    DELETE FROM bibuser.t_pub_attachment_export m WHERE m.attachment_id = i.attachment_id;
    DELETE FROM bibuser.t_pub_attachment_process m WHERE m.attachment_id = i.attachment_id;
    DELETE FROM bibuser.t_pub_attachment m WHERE m.attachment_id = i.attachment_id;
    COMMIT;
  END LOOP;
END;
/
