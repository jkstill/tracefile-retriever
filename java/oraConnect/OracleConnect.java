
package oraConnect;

import oracle.jdbc.*;
import java.sql.*;
import java.util.*;
import oracle.jdbc.pool.OracleDataSource;
 
public class OracleConnect{

	public static void main(String args[]){

		StringBuilder dbString = new StringBuilder();
		StringBuilder username = new StringBuilder();
		StringBuilder password = new StringBuilder();

		dbString.append(args[0]);
		username.append(args[1]);
		password.append(args[2]);

		Connection con = null;

		try {
			con = getConnection(username.toString() + "/" + password.toString() + "@" + dbString.toString());
		}
		catch(Exception e){
			System.out.println(e);
		}

		getDate(con);

		try {
			con.close();
		}
		catch(Exception e){
			System.out.println(e);
		}	
	}

	
	public static Connection getConnection(String connectString) {

		//String connectString = username + "/" + password + "@" + db;
		Connection con = null;

		//Class.forName("oracle.jdbc.driver.OracleDriver");

		try{

			OracleDataSource ods = new OracleDataSource();
			ods.setURL("jdbc:oracle:thin:" + connectString);
			con = ods.getConnection();

		}
		catch(Exception e){ 
			System.out.println(e);
		}

		return con;

	}

	public static void getDate(Connection con ) {

		//String connectString = username + "/" + password + "@" + db;

		//for (String s: args) {
			//System.out.println(s);
		//}

		//for (int i = 0; i < args.length; i++) {
			//System.out.println("i: " + i + " " + args[i]);
		//}

		
		//System.out.println("connectString: " + connectString);


		try{

			// the 3 '/' are important to make it a URL
			// System.setProperty("java.security.egd", "file:///dev/urandom");  

			//Class.forName("oracle.jdbc.driver.OracleDriver");

			//OracleDataSource ods = new OracleDataSource();
			// with EZ Connect
			//System.setProperty("oracle.net.tns_admin", "/home/jkstill/presentations/sqlnet-troubleshooting-files/entropy");

			//ods.setURL("jdbc:oracle:thin:" + connectString);

			// with TNS string
			//ods.setURL("jdbc:oracle:thin:jkstill/XXXXX@(DESCRIPTION=(ENABLE=BROKEN)(CONNECT_DATA=(SERVICE_NAME=js1.jks.com))(ADDRESS=(PROTOCOL=TCP)(HOST=ora122rac-scan)(PORT=1521)))");

			//Connection con = ods.getConnection();
			//Connection con = getConnection(connectString);

			// /* 
			Statement stmt=con.createStatement();
			
			ResultSet rs=stmt.executeQuery("select sysdate from dual");
			while(rs.next())
			System.out.println("Date: " + rs.getString(1));

			// */

			//con.close();

		}
		catch(Exception e){ System.out.println(e);}

	}

	public static void closeCon(Connection con) {
		try {
			con.close();
		}
		catch(Exception e){ 
			System.out.println(e);
		}

	}
}

