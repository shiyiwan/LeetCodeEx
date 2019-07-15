--1. 各一级部门及分公司 大投行系统 登录人数及次数   
SELECT (SELECT o.organization_name FROM ouser.t_xtgl_organization o WHERE o.organization_id = a.org) AS "部门"
       ,COUNT(1) AS "登录人数"
       ,SUM(cnt) AS "登录次数"
  FROM (SELECT (SELECT CASE
                         WHEN o.team_id0 = 209998 THEN
                          o.team_id1
                         ELSE
                          o.team_id0
                       END
                  FROM ouser.t_xtgl_user_organization o
                 WHERE o.user_id = t.user_id) AS org
              ,COUNT(1) AS cnt
              ,t.user_id
          FROM bibuser.t_log_login_his t
         WHERE t.login_date >= 20190101
         GROUP BY t.user_id) a
 GROUP BY a.org;
  
--2. 各部门及分公司当前有效员工数
SELECT (SELECT o.organization_name FROM ouser.t_xtgl_organization o WHERE o.organization_id = a.org) AS "部门"
       ,COUNT(1)
  FROM (SELECT (SELECT CASE
                         WHEN o.team_id0 = 209998 THEN
                          o.team_id1
                         ELSE
                          team_id0
                       END
                  FROM ouser.t_xtgl_user_organization o
                 WHERE o.user_id = t.user_id) AS org
              ,COUNT(1) AS cnt
              ,t.user_id
          FROM ouser.t_xtgl_user t
         WHERE t.rec_status = 1
         GROUP BY t.user_id) a
 GROUP BY a.org;
  
-- 3. 过去一个月各部门及分公司 大投行系统 登陆次数
WITH conf AS
 (SELECT to_char(trunc(SYSDATE - 8, 'D') + 1, 'YYYYMMDD') bdate FROM dual),
tmp AS
 (SELECT (SELECT organization_name FROM ouser.t_xtgl_organization o WHERE o.organization_id = b.team_id0) AS org_name
        ,b.team_id0 porg_id
        ,SUM(CASE
               WHEN login_date BETWEEN to_char(to_date(d.bdate, 'yyyymmdd') - 21, 'yyyymmdd') AND
                    to_char(to_date(d.bdate, 'yyyymmdd') - 15, 'yyyymmdd') THEN
                1
               ELSE
                0
             END) AS w1
        ,SUM(CASE
               WHEN login_date BETWEEN to_char(to_date(d.bdate, 'yyyymmdd') - 14, 'yyyymmdd') AND
                    to_char(to_date(d.bdate, 'yyyymmdd') - 8, 'yyyymmdd') THEN
                1
               ELSE
                0
             END) AS w2
        ,SUM(CASE
               WHEN login_date BETWEEN to_char(to_date(d.bdate, 'yyyymmdd') - 7, 'yyyymmdd') AND
                    to_char(to_date(d.bdate, 'yyyymmdd') - 1, 'yyyymmdd') THEN
                1
               ELSE
                0
             END) AS w3
        ,SUM(CASE
               WHEN login_date BETWEEN d.bdate AND to_char(to_date(d.bdate, 'yyyymmdd') + 6, 'yyyymmdd') THEN
                1
               ELSE
                0
             END) AS w4
        ,COUNT(1) AS wt
    FROM bibuser.t_log_login_his t
   INNER JOIN conf d
      ON t.login_date <= to_char(to_date(d.bdate, 'yyyymmdd') + 6, 'yyyymmdd')
     AND t.login_date >= to_char(to_date(d.bdate, 'yyyymmdd') - 21, 'yyyymmdd')
   INNER JOIN (SELECT CASE
                       WHEN team_id0 = 209998 THEN
                        team_id1
                       ELSE
                        team_id0
                     END AS team_id0
                    ,user_id
                FROM ouser.t_xtgl_user_organization) b
      ON t.user_id = b.user_id
     AND b.team_id0 IS NOT NULL
   GROUP BY b.team_id0)
SELECT '' 部门
      ,to_char(to_date(d.bdate, 'yyyymmdd') - 21, 'mm"月"dd"日"') || '-' ||
       to_char(to_date(d.bdate, 'yyyymmdd') - 15, 'mm"月"dd"日"') AS 四周前
      ,to_char(to_date(d.bdate, 'yyyymmdd') - 14, 'mm"月"dd"日"') || '-' ||
       to_char(to_date(d.bdate, 'yyyymmdd') - 8, 'mm"月"dd"日"') AS 三周前
      ,to_char(to_date(d.bdate, 'yyyymmdd') - 7, 'mm"月"dd"日"') || '-' ||
       to_char(to_date(d.bdate, 'yyyymmdd') - 1, 'mm"月"dd"日"') AS 两周前
      ,to_char(to_date(d.bdate, 'yyyymmdd'), 'mm"月"dd"日"') || '-' ||
       to_char(to_date(d.bdate, 'yyyymmdd') + 6, 'mm"月"dd"日"') AS 上周
      ,to_char(to_date(d.bdate, 'yyyymmdd') - 21, 'mm"月"dd"日"') || '-' ||
       to_char(to_date(d.bdate, 'yyyymmdd') + 6, 'mm"月"dd"日"') AS 前四周
  FROM conf d
UNION ALL
SELECT org_name
      ,nvl('' || w1, '0') AS w1
      ,nvl('' || w2, '0') AS w2
      ,nvl('' || w3, '0') AS w3
      ,nvl('' || w4, '0') AS w4
      ,nvl('' || wt, '0') AS w5
  FROM tmp
 ORDER BY 1 NULLS FIRST;
  
-- 4. 20190101 以来 大投行系统 新增客户数
SELECT (SELECT l.organization_name FROM ouser.t_xtgl_organization l WHERE l.organization_id = org) AS org, SUM(num)
  FROM (SELECT CASE
                 WHEN n.team_id0 = 209998 THEN
                  n.team_id1
                 ELSE
                  n.team_id0
               END AS org
              ,f.client_majorcate
              ,COUNT(1) AS num
          FROM ouser.t_cm_clientinfo f, ouser.t_serv_relation r, ouser.t_xtgl_user_organization n
         WHERE f.sys = 4
           AND f.client_id = r.client_id
           AND r.relation_type = 4
           AND f.rec_status = '1'
           AND r.user_id = n.user_id
           AND f.create_time >= to_date('20190101', 'yyyymmdd')
         GROUP BY CASE
                    WHEN n.team_id0 = 209998 THEN
                     n.team_id1
                    ELSE
                     n.team_id0
                  END
                 ,f.client_majorcate)
 GROUP BY org;
  
-- 5.20190401 - 20190430 之间 大投行系统 各菜单访问次数
SELECT t.menu_id, m.modular_name, COUNT(*)
  FROM bibuser.t_log_operate_his t, bibuser.t_xtgl_modular m
 WHERE t.menu_id = m.modular_id
   AND t.operate_datetime BETWEEN to_date('20190401', 'yyyymmdd') AND to_date('20190430', 'yyyymmdd')
   AND t.operate_date BETWEEN 20190401 AND 20190430
   AND t.USER_ID > 1
 GROUP BY t.menu_id, m.modular_name;
  
-- 6. 20190101 以来每月 发起流程的数量
SELECT trunc(pi.create_time, 'MM'), COUNT(*) cnt
  FROM bibuser.t_pm_projourinst pi
 WHERE pi.create_time >= to_date('20190101', 'yyyymmdd')
 GROUP BY trunc(pi.create_time, 'MM');
    
-- 7. 20190101 大投行系统 登录总次数  
SELECT SUM(cnt)
  FROM (SELECT COUNT(*) cnt
          FROM bibuser.t_log_login d
         WHERE d.login_date >= 20190101
        UNION ALL
        SELECT COUNT(*) cnt
          FROM bibuser.t_log_login_his d
         WHERE d.login_date >= 20190101);
 
-- 8. 2019年 新增项目数
-- business_type：1 股权 2 财务顾问 3 债权 4 新三板挂牌 5 新三板衍生 31 债券存续期
SELECT CASE p.business_type WHEN 1 THEN '股权' WHEN 2 THEN '财务顾问' WHEN 3 THEN '债权' WHEN 4 THEN '新三板挂牌' WHEN 5 THEN '新三板衍生' WHEN 31 THEN '债券存续期' END AS business_type_desc, COUNT(*)
  FROM bibuser.v_pm_projectinfo p
 WHERE p.project_code LIKE '19%'
 GROUP BY p.business_type;
   
-- 9. 20190101 年反洗钱
SELECT COUNT(*)
  FROM (SELECT DISTINCT ci.client_id, ci.client_name
          FROM ouser.t_cm_clientinfo ci, bibuser.t_pm_projour_pub a, bibuser.t_pm_projour_clobattr t
         WHERE ci.client_id = a.attribute_value
           AND a.projour_id = t.projour_id
           AND t.attribute_code = 'clientriskassessment'
           AND a.attribute_code = 'clientId'
           AND a.attribute_value IS NOT NULL
           AND a.projour_id IN (SELECT i.projour_id
                                  FROM bibuser.t_pm_projourinst i
                                 WHERE i.stage_id = 265
                                   AND i.create_time >= to_date('20190101', 'yyyymmdd')));
  
  
 
-- 10. 流程 发起总数 按表划分
 SELECT f.source_table, COUNT(DISTINCT(d.projour_id))
   FROM bibuser.t_pm_projourinst d, bibuser.v_pm_projour_info f
  WHERE d.create_time >= to_date('20190101', 'yyyymmdd')
    AND d.projour_id = f.projour_id
  GROUP BY f.source_table
     
-- 11. 流程 按部门 划分
SELECT create_user_org, o.organization_name, COUNT(*) cnt
  FROM bibuser.t_pm_projourinst pi, ouser.t_xtgl_organization o
 WHERE pi.create_time >= to_date('20190101', 'yyyymmdd')
   AND pi.create_user_org = o.organization_id(+)
 GROUP BY create_user_org, o.organization_name;
  
   
   
-- 12. 每月立项项目数 2018年1月至4月
SELECT P.BUSINESS_TYPE
        ,sum(
            CASE
               WHEN SETUP_DECLARE_TIME BETWEEN TO_DATE('20180101', 'yyyymmdd') AND TO_DATE('20180131', 'yyyymmdd') THEN
                1
               ELSE
                0
             END
        ) as "2018年1月"
        ,sum(
          CASE
               WHEN SETUP_DECLARE_TIME BETWEEN TO_DATE('20180201', 'yyyymmdd') AND TO_DATE('20180228', 'yyyymmdd') THEN
                1
               ELSE
                0
             END
        ) as "2018年2月"
        ,sum(
         CASE
               WHEN SETUP_DECLARE_TIME BETWEEN TO_DATE('20180301', 'yyyymmdd') AND TO_DATE('20180331', 'yyyymmdd') THEN
                1
               ELSE
                0
             END
        ) as "2018年3月"
        ,sum(
         CASE
               WHEN SETUP_DECLARE_TIME BETWEEN TO_DATE('20180401', 'yyyymmdd') AND TO_DATE('20180430', 'yyyymmdd') THEN
                1
               ELSE
                0
             END
        ) as "2018年4月"
    FROM BIBUSER.V_PM_PROJECTINFO P
   WHERE P.SETUP_DECLARE_TIME >= TO_DATE('20180101', 'yyyymmdd')
   GROUP BY P.BUSINESS_TYPE;
  
-- 13. 2019年1月1日至7日间最大在线人数
SELECT a.min_time, COUNT(*)
  FROM (SELECT to_date('20190101 00:00:00', 'yyyymmdd HH24:MI:SS') + (rownum - 1) / 24 / 60 AS min_time
          FROM dual
        CONNECT BY rownum <= 24 * 7 * 60) a
      ,bibuser.t_log_login_his t
 WHERE a.min_time >= to_date(to_char(t.login_date) || ' ' || t.login_time, 'yyyymmdd HH24:MI:SS')
   AND (a.min_time <= to_date(to_char(t.logout_date) || ' ' || t.login_time, 'yyyymmdd HH24:MI:SS') OR
       t.logout_date IS NULL)
   AND t.login_date >= 20190101
   AND (t.logout_date <= 20190107 OR t.logout_date IS NULL)
 GROUP BY a.min_time;
