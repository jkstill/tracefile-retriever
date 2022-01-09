
import oracle.jdbc.*;
import java.sql.*;
import java.util.*;
import java.io.*;
import oracle.jdbc.pool.OracleDataSource;

import oraConnect.*;
import dates.*;

public class ListDirFilesRDS {
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

		String setDateFormatSQL = "alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss'";
		String refreshFileListSQL = "begin rdsadmin.manage_tracefiles.refresh_tracefile_listing;end;";
		String getFilesSQL = "select filename, type, filesize, mtime from table(rdsadmin.rds_file_util.listdir(?)) order by lower(filename)";

		try {
			stmt = con.createStatement();
			stmt.execute(setDateFormatSQL);

			stmt = con.createStatement();
			stmt.execute(refreshFileListSQL);
			stmt.close();
		}
		catch(Exception e){
			System.err.println(e);
			System.err.println("rdsadmin.manage_tracefiles.refresh_tracefile_listing");
		}	

		try {
			prepStmt=con.prepareStatement(getFilesSQL);
			prepStmt.setString(1,dumpDir);
			ResultSet rs=prepStmt.executeQuery();

			if (rs.next() == false ) {
				System.out.println("no files found");
			} else {
				do {
					String filename = rs.getString("filename");
					String type = rs.getString("type");
					Integer filesize = rs.getInt("filesize");
					String mtime = rs.getString("mtime");
					System.out.printf("%10s %12d %30s  %-100s%n", type , filesize , mtime, filename);

				} while(rs.next());
				rs.close();
				prepStmt.close();
			}
		}
		catch(Exception e){
			System.err.println(e);
			System.err.println("Error querying rdsadmin.rds_file_util.listdir");
		}	


	}

}
 




