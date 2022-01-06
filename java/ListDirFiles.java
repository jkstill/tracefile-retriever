
import oracle.jdbc.*;
import java.sql.*;
import java.util.*;
import java.io.*;
import oracle.jdbc.pool.OracleDataSource;

import oraConnect.*;
import dates.*;

public class ListDirFiles {
	public static void main(String[] args){

		StringBuilder dbString = new StringBuilder();
		StringBuilder username = new StringBuilder();
		StringBuilder password = new StringBuilder();
		StringBuilder dumpDir = new StringBuilder();

		dbString.append(args[0]);
		username.append(args[1]);
		password.append(args[2]);
		dumpDir.append(args[3]);

		Connection con = null;

		try {
			con = OracleConnect.getConnection(username.toString() + "/" + password.toString() + "@" + dbString.toString());
		}
		catch(Exception e){
			System.err.println(e);
		}

		String dirPath = getDirPath(con,dumpDir.toString());
		System.out.println("dumpDir: " + dirPath);
		getFileList(con, dirPath);

		try {
			OracleConnect.closeCon(con);
		}
		catch(Exception e){
			System.err.println(e);
		}	
	}

	public static String getDirPath(Connection con, String dirName) {
		PreparedStatement prepStmt=null;
		String dirPath = null;

		try {
			prepStmt=con.prepareStatement("select directory_path from all_directories where directory_name = upper(?)");
			prepStmt.setString(1,dirName);
			ResultSet rs = prepStmt.executeQuery();
			rs.next();
			dirPath = rs.getString(1);
			rs.close();
		}
		catch(Exception e){
			System.err.println(e);
		}	

		return dirPath;
	}

	public static void getFileList(Connection con, String dirPath) {

		Statement stmt=null;
		PreparedStatement prepStmt=null;

		String plsqlBlock = "declare ns varchar2(2000) := null; pattern varchar2(2000) := ? ; begin dbms_backup_restore.searchfiles (pattern => pattern, ns => ns ); end;";

		try {
			prepStmt = con.prepareStatement(plsqlBlock);
			prepStmt.setString(1,dirPath);
			prepStmt.execute();
			prepStmt.close();
		}
		catch(Exception e){
			System.err.println(e);
			System.err.println("dbms_backup_restore.searchfiles");
			System.err.println("PL/SQL: " + plsqlBlock);
		}	

		try {
			stmt=con.createStatement();
			// tried getting the size via the SIZE_KRBMSFT column, but it is always 0
			ResultSet rs=stmt.executeQuery("select fname_krbmsft as file_name from x$krbmsft order by 1");

			if (rs.next() == false ) {
				System.err.println("no files found");
			} else {
				do {
					String fname = rs.getString("file_name");
					System.err.println(fname);

				} while(rs.next());
				rs.close();
			}
		}
		catch(Exception e){
			System.err.println(e);
			System.err.println("Error querying x$krbmsft x$krbmsft");
		}	


	}

}
 




