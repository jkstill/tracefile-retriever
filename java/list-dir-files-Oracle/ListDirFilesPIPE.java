
import oracle.jdbc.*;
import java.sql.*;
import java.util.*;
import java.io.*;
import oracle.jdbc.pool.OracleDataSource;

import oraConnect.*;
import dates.*;

public class ListDirFilesPIPE {
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

		//String dirPath = getDirPath(con,dumpDir.toString());
		getFileList(con, dumpDir.toString());

		try {
			OracleConnect.closeCon(con);
		}
		catch(Exception e){
			System.err.println(e);
		}	
	}


	public static void getFileList(Connection con, String dumpDir) {

		Statement stmt=null;
		PreparedStatement prepStmt=null;

		String getFilesSQL = "select column_value as filename from table(tracefile_lister.filepipe(?))";

		try {
			prepStmt=con.prepareStatement(getFilesSQL);
			prepStmt.setString(1,dumpDir);
			ResultSet rs=prepStmt.executeQuery();

			if (rs.next() == false ) {
				System.out.println("no files found");
			} else {
				do {
					String filename = rs.getString("filename");
					System.out.println(filename);

				} while(rs.next());
				rs.close();
				prepStmt.close();
			}
		}
		catch(Exception e){
			System.err.println(e);
			System.err.println("Error querying tracefile_lister.filepipe");
		}	


	}

}
 


