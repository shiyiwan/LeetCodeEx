/*
在开发环境（投行目前以170为开发环境）查询
select max(detail_id) from bibuser.t_Dict_Business_detail
如查询出当前最大值为 46653，则使用 46654 为summary_id, 依次以 46654， 46655 …… 为detail_id
示例如下：
*/

DELETE FROM bibuser.t_dict_business_detail WHERE SUMMARY_ID = 46654 ;
DELETE FROM bibuser.t_dict_business WHERE SUMMARY_ID = 46654 ;
insert into bibuser.t_Dict_Business (SUMMARY_ID, COLUMN_NAME, COLUMN_COMMENT, COLUMN_MAXVALUE, UPDATETIME, COLUMN_SYS)
values (46654, 'CXT_BOND_PROJECT_TYPE', '债券项目类型(参团协议)', null, SYSDATE, null);
insert into bibuser.t_Dict_Business_detail (DETAIL_ID, SUMMARY_ID, VALUE, DISPLAY_VALUE, ORDER_SEC, REMARK, REC_STATUS, UPDATETIME, UPDATEUSER)
values (46654, 46654, '1', '公司债', 1, 'CXT_BOND_PROJECT_TYPE', '1', SYSDATE, '0');
insert into bibuser.t_Dict_Business_detail (DETAIL_ID, SUMMARY_ID, VALUE, DISPLAY_VALUE, ORDER_SEC, REMARK, REC_STATUS, UPDATETIME, UPDATEUSER)
values (46655, 46654, '2', '企业债', 2, 'CXT_BOND_PROJECT_TYPE', '1', SYSDATE, '0');
COMMIT;
