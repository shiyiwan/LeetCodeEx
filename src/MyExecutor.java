package com.idle;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Properties;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class MyExecutor {
	
	public static Connection conn;
	/*
	public MyExecutor() {
		String driver = "org.postgresql.Driver";
		String url = getQuerySQL("pgUrl");
		String user = getQuerySQL("pguse");
		String password = getQuerySQL("pgpwd");
		try {
			if(conn == null || conn.isClosed()) {
				try {
					Class.forName(driver).newInstance();
					conn = DriverManager.getConnection(url, user, password);
					System.out.println(conn.toString());
				} catch (ClassNotFoundException e) {
					e.printStackTrace();
				} catch (SQLException e) {
					e.printStackTrace();
				} catch (Exception e) {
					e.printStackTrace();
				}
				}
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	*/
	
	public static Connection getConnection(String driver, String url, String user, String password) throws SQLException {
		if(conn == null || conn.isClosed()) {
		try {
			Class.forName(driver).newInstance();
			conn = DriverManager.getConnection(url, user, password);
			//System.out.println(conn.toString());
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		} catch (SQLException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}
		}
		return conn;
	}
	
	public void DBExecuteQuery(String driver, String url, String user, String password, String vsql) {
		try {
			//conn = getConnection(driver, url, user, password);
			PreparedStatement stmt = getConnection(driver, url, user, password).prepareStatement(vsql);
			ResultSet rs = stmt.executeQuery();
			while (rs.next()) {
				@SuppressWarnings("unused")
				int rsvalue = rs.getInt(1);
			}
			rs.close();
			stmt.close();
		}catch (SQLException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}

	}
	
	public void DBExecuteWrite(String driver, String url, String user, String password, String vsql) {
		try {
			//conn = getConnection(driver, url, user, password);
			PreparedStatement stmt = getConnection(driver, url, user, password).prepareStatement(vsql);
			stmt.execute();
			stmt.close();
		}catch (SQLException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}

	}
	

	private ExecutorService executor = Executors.newCachedThreadPool();

	public void runInterface(int whichone) throws Exception {

		executor.submit(new Runnable() {

			public void run() {
				long starttime = System.currentTimeMillis();

				// OracleQuery();
				  MysqlQuery();
				// PostGresQuery();
				 // DMQuery();
				
				// write test
				 // DMWrite();
				 // PostGresWrite();
				 //MysqlWrite();
				System.out.print("*********Thread:" + whichone + " completed.");
				System.out.println(System.currentTimeMillis()-starttime);
			}
		});
	}
	
	public void DMWrite() {
		String driver = "dm.jdbc.driver.DmDriver";
		String url = getQuerySQL("dmUrl");
		String user = getQuerySQL("dmuse");
		String password = getQuerySQL("dmpwd");
		String vsql = "insert into afaer.t_write_stress_test(id, name, create_date) values(1, 'hello DM', sysdate)";
		DBExecuteWrite(driver, url, user, password, vsql);
		
	}
	public void DMQuery() {
		String driver = "dm.jdbc.driver.DmDriver";
		String url = getQuerySQL("dmUrl");
		String user = getQuerySQL("dmuse");
		String password = getQuerySQL("dmpwd");
		// 模糊查询场景
		String vsql1 = "select count(*) from (\r\n" + 
				"SELECT /*+ENABLE_RQ_TO_NONREF_SPL(2)*/\r\n" + 
				" 产品类型, 交易代码, 产品名称, to_char(评审通过时间, 'YYYY-MM-DD hh24:mi:ss') 评审通过时间\r\n" + 
				"  FROM (SELECT t.product_id\r\n" + 
				"              ,t.seccode 交易代码\r\n" + 
				"              ,t.product_code 产品代码\r\n" + 
				"              ,t.product_name 产品名称\r\n" + 
				"              ,t.product_table_id 产品类型\r\n" + 
				"              ,t.insert_time 创建日期\r\n" + 
				"              ,coalesce((SELECT MIN(pas.end_time)\r\n" + 
				"                          FROM t_pub_actrevies_status pas\r\n" + 
				"                         WHERE pas.business_id = t.product_id\r\n" + 
				"                           AND pas.business_cate IN ('P_PRODUCT_REVIEW_CATEGORY', 'P_PROFESSION_REVIEW_CATEGORY')\r\n" + 
				"                           AND pas.actrevies_status = '3'),\r\n" + 
				"                        (SELECT MIN(pas.end_time)\r\n" + 
				"                            FROM t_pub_actrevies_status pas\r\n" + 
				"                           WHERE pas.json LIKE '%\\_' || t.product_id || '\"%' ESCAPE\r\n" + 
				"                           '\\'\r\n" + 
				"                             AND pas.business_cate IN ('P_PRODUCT_REVIEW_CATEGORY', 'P_PROFESSION_REVIEW_CATEGORY')\r\n" + 
				"                             AND pas.actrevies_status = '3')) 评审通过时间\r\n" + 
				"          FROM t_prod_product t\r\n" + 
				"         WHERE t.rec_status IN ('1', '2')) tt\r\n" + 
				" WHERE 评审通过时间 < DATE '2017-4-1'\r\n" + 
				"   AND 评审通过时间 >= DATE '2017-1-1'\r\n" + 
				" ORDER BY 评审通过时间 DESC ) mm";
		String vsql2 = "SELECT u.user_id, u.user_name, organization_name from afaer.t_xtgl_user u, afaer.t_xtgl_organization o where u.organization_id = o.organization_id limit 20";
		DBExecuteQuery(driver, url, user, password, vsql2);
	}
	
	public void PostGresWrite() {
		String driver = "org.postgresql.Driver";
		String url = getQuerySQL("pgUrl");
		String user = getQuerySQL("pguse");
		String password = getQuerySQL("pgpwd");
		String vsql = "insert into afaer.t_write_stress_test(id, name, create_date) values(1,'Hello Ps', now())";
		DBExecuteWrite(driver, url, user, password, vsql);
	}
	
	public void MysqlWrite() {
		String driver = "com.mysql.cj.jdbc.Driver";
		String url = getQuerySQL("mysqlUrl");
		String user = getQuerySQL("mysqluse");
		String password = getQuerySQL("mysqlpwd");
		String vsql = "insert into testdb.t_write_stress_test(id, name, create_date) values(1,'Hello My', now())";
		DBExecuteWrite(driver, url, user, password, vsql);
	}
	public void PostGresQuery() {
		String driver = "org.postgresql.Driver";
		String url = getQuerySQL("pgUrl");
		String user = getQuerySQL("pguse");
		String password = getQuerySQL("pgpwd");
		//String vsql = getQuerySQL("postgres");
		// 模糊查询场景
		String vsql1 = "SELECT COUNT(*)\r\n" + 
				"  FROM (SELECT 产品类型, 交易代码, 产品名称, to_char(评审通过时间, 'YYYY-MM-DD hh24:mi:ss') 评审通过时间\r\n" + 
				"          FROM (SELECT t.product_id\r\n" + 
				"                      ,t.seccode 交易代码\r\n" + 
				"                      ,t.product_code 产品代码\r\n" + 
				"                      ,t.product_name 产品名称\r\n" + 
				"                      ,t.product_table_id 产品类型\r\n" + 
				"                      ,t.insert_time 创建日期\r\n" + 
				"                      ,coalesce((SELECT MIN(pas.end_time)\r\n" + 
				"                                  FROM prodma.t_pub_actrevies_status pas\r\n" + 
				"                                 WHERE pas.business_id = t.product_id\r\n" + 
				"                                   AND pas.business_cate IN\r\n" + 
				"                                       ('P_PRODUCT_REVIEW_CATEGORY', 'P_PROFESSION_REVIEW_CATEGORY')\r\n" + 
				"                                   AND pas.actrevies_status = '3'),\r\n" + 
				"                                (SELECT MIN(pas.end_time)\r\n" + 
				"                                    FROM prodma.t_pub_actrevies_status pas\r\n" + 
				"                                   WHERE pas.json LIKE '%\\_' || t.product_id || '\"%' ESCAPE\r\n" + 
				"                                   '\\'\r\n" + 
				"                                     AND pas.business_cate IN ('P_PRODUCT_REVIEW_CATEGORY', 'P_PROFESSION_REVIEW_CATEGORY')\r\n" + 
				"                                     AND pas.actrevies_status = '3')) 评审通过时间\r\n" + 
				"                  FROM prodma.t_prod_product t\r\n" + 
				"                 WHERE t.rec_status IN ('1', '2')) tt\r\n" + 
				"         WHERE 评审通过时间 < DATE '2017-4-1'\r\n" + 
				"           AND 评审通过时间 >= DATE '2017-1-1'\r\n" + 
				"         ORDER BY 评审通过时间 DESC) mm" ;
		String vsql2 = "SELECT u.user_id, u.user_name, organization_name from afaer.t_xtgl_user u, afaer.t_xtgl_organization o where u.organization_id = o.organization_id limit 20";
		DBExecuteQuery(driver, url, user, password, vsql2);
	}
    
	public void MysqlQuery() {

		String driver = "com.mysql.cj.jdbc.Driver";
		String url = getQuerySQL("mysqlUrl");
		String user = getQuerySQL("mysqluse");
		String password = getQuerySQL("mysqlpwd");
		// 模糊查询场景
		String vsql1 = "SELECT COUNT(*)\r\n" + 
				"  FROM (SELECT 产品类型, 交易代码, 产品名称, 评审通过时间\r\n" + 
				"          FROM (SELECT t.product_id\r\n" + 
				"                      ,t.seccode 交易代码\r\n" + 
				"                      ,t.product_code 产品代码\r\n" + 
				"                      ,t.product_name 产品名称\r\n" + 
				"                      ,t.product_table_id 产品类型\r\n" + 
				"                      ,t.insert_time 创建日期\r\n" + 
				"                      ,coalesce((SELECT MIN(pas.end_time)\r\n" + 
				"                                  FROM testdb.t_pub_actrevies_status pas\r\n" + 
				"                                 WHERE pas.business_id = t.product_id\r\n" + 
				"                                   AND pas.business_cate IN\r\n" + 
				"                                       ('P_PRODUCT_REVIEW_CATEGORY', 'P_PROFESSION_REVIEW_CATEGORY')\r\n" + 
				"                                   AND pas.actrevies_status = '3'),\r\n" + 
				"                                (SELECT MIN(pas.end_time)\r\n" + 
				"                                    FROM testdb.t_pub_actrevies_status pas\r\n" + 
				"                                   WHERE pas.json LIKE concat_ws('', '%/_', t.product_id, '\"%') ESCAPE\r\n" + 
				"                                   '/'\r\n" + 
				"                                     AND pas.business_cate IN ('P_PRODUCT_REVIEW_CATEGORY', 'P_PROFESSION_REVIEW_CATEGORY')\r\n" + 
				"                                     AND pas.actrevies_status = '3')) 评审通过时间\r\n" + 
				"                  FROM testdb.t_prod_product t\r\n" + 
				"                 WHERE t.rec_status IN ('1', '2')) tt\r\n" + 
				"         WHERE 评审通过时间 < DATE '2017-4-1'\r\n" + 
				"           AND 评审通过时间 >= DATE '2017-1-1'\r\n" + 
				"         ORDER BY 评审通过时间 DESC) mm";
		String vsql2 = "SELECT u.user_id, u.user_name, o.organization_name FROM testdb.T_XTGL_USER u, testdb.t_xtgl_organization o where u.organization_id = o.organization_id limit 20";
		String vsql3 = "SELECT u.user_id, u.user_name, o.organization_name, r.role_id FROM testdb.T_XTGL_USER u, testdb.t_xtgl_organization o, testdb.T_XTGL_USERROLE r where u.organization_id = o.organization_id and r.user_id = u.user_Id limit 20";

		DBExecuteQuery(driver, url, user, password, vsql2);
	}

	public void OracleQuery() {
		String url = "jdbc:oracle:thin:@xxx.xx.xxx.xx:1521:xxxx";
		String user = "xxxx";
		String password = "xxxx";
		String driver = "oracle.jdbc.driver.OracleDriver";
		String vsql = getQuerySQL("oracle");
		DBExecuteQuery(driver, url, user, password, vsql);
	}
	
	public String getQuerySQL(String key) {
		String query = null;
		Properties prop = new Properties();
		try {
			File properties = new File("src/db.properties");
			InputStream in = new BufferedInputStream(new FileInputStream(properties.getAbsoluteFile()));
			prop.load(in);
			query = prop.getProperty(key);
			in.close();

		} catch (Exception e) {
			System.out.println(e);
		}
		return query;
	}
	



}
