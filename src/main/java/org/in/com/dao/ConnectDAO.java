package org.in.com.dao;

import java.sql.Connection;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

public class ConnectDAO {

	private static DataSource instance = null;

	protected ConnectDAO() {
		// Exists only to defeat instantiation.
	}

	public static void setInstance(DataSource instance) {
		ConnectDAO.instance = instance;
	}

	public static synchronized DataSource getInstance() throws NamingException {

		if (instance == null) {
			InitialContext context = new InitialContext();
			instance = (DataSource) context.lookup("java:comp/env/jdbc/MySQLDB");
			System.out.println("java:comp/env/jdbc/MySQLDB New  DataSource Instance");
		}
		return instance;
	}

	public static Connection getConnection() {
		Connection con = null;
		DataSource dataSource = null;
		try {
			dataSource = ConnectDAO.getInstance();
			con = dataSource.getConnection();
		}
		catch (Exception e) {
			e.printStackTrace();
		}
		if (con == null) {
			System.out.println("ERRJDBC01 Connection pool has been empty");
		}
		return con;
	}
}
