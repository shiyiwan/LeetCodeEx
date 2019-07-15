--1. 各一级部门及分公司登录人数及次数    
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
          FROM ouser.t_log_login_his t
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
 
-- 3. 过去一个月各部门及分公司 登陆次数
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
    FROM ouser.t_log_login_his t
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
 
-- 4. 20190101 以来 机构新增客户数
SELECT (SELECT l.organization_name FROM ouser.t_xtgl_organization l WHERE l.organization_id = org) AS org, SUM(num)
  FROM (SELECT CASE
                 WHEN n.team_id0 = 209998 THEN
                  n.team_id1
                 ELSE
                  n.team_id0
               END AS org
              ,f.client_majorcate
              ,COUNT(1) AS num
          FROM ouser.t_cm_clientinfo f, ouser.t_serv_relation r, ouser.t_xtgl_user_organization n, ouser.t_xtgl_user u
         WHERE f.sys IN (1, 5)
           AND f.client_id = r.client_id
           AND r.relation_type = 4
           AND f.rec_status = '1'
           AND f.business_progress = '1' -- 签约客户
           AND r.user_id = n.user_id
           AND r.user_id = u.user_id
           AND u.rec_status = 1
           AND f.create_time >= to_date('20190101', 'yyyymmdd')
         GROUP BY CASE
                    WHEN n.team_id0 = 209998 THEN
                     n.team_id1
                    ELSE
                     n.team_id0
                  END
                 ,f.client_majorcate)
 GROUP BY org;
 
-- 5.20190401 - 20190430 之间各菜单访问次数
SELECT t.menu_id, m.modular_name, COUNT(*)
  FROM ouser.t_log_operate_his t, ouser.t_xtgl_modular m
 WHERE t.menu_id = m.modular_id
   AND t.operate_datetime BETWEEN to_date('20190401', 'yyyymmdd') AND to_date('20190430', 'yyyymmdd')
   AND t.operate_date BETWEEN 20190401 AND 20190430
   AND t.userid > 1
 GROUP BY t.menu_id, m.modular_name;
