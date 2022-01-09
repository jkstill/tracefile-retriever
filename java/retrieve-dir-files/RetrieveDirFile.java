
import oracle.jdbc.*;
import java.sql.*;
import java.util.*;
import java.io.*;
import oracle.jdbc.pool.OracleDataSource;
import oracle.sql.BFILE;
import java.lang.Math;

import oraConnect.*;
import dates.*;


public class RetrieveDirFile {

	public static void main(String[] args){

		StringBuilder dbString = new StringBuilder();
		StringBuilder username = new StringBuilder();
		StringBuilder password = new StringBuilder();
		StringBuilder dumpDir = new StringBuilder();
		StringBuilder filename = new StringBuilder();

		dbString.append(args[0]);
		username.append(args[1]);
		password.append(args[2]);
		dumpDir.append(args[3]);
		filename.append(args[4]);

		Connection con = null;

		try {
			con = OracleConnect.getConnection(username.toString() + "/" + password.toString() + "@" + dbString.toString());
		}
		catch(Exception e){
			System.err.println(e);
		}

		try {
			dumpFile(con, dumpDir.toString(), filename.toString());
		} 
		catch(Exception e){
			System.err.println(e);
			System.err.println("While calling dumpFile()");
		}	

		try {
			OracleConnect.closeCon(con);
		}
		catch(Exception e){
			System.err.println(e);
		}	
	}

	public static int getBufSz() {
		int bufsz = 4096;
		return bufsz;
	}


	// I cannot find decent docs for using newer methods...
	@SuppressWarnings("deprecation")
	public static void dumpFile(Connection con, String dumpDir, String filename) throws Exception {

		PreparedStatement prepStmt=null;
		String bfileLocSQL = "select bfilename(?, ?) bloc from dual";
		BFILE bfileLOC = null;
		ResultSet rs = null;

		try {
			// get locator
			prepStmt = con.prepareStatement(bfileLocSQL);
			prepStmt.setString(1,dumpDir);
			prepStmt.setString(2,filename);
			rs = prepStmt.executeQuery();

			if (rs.next()) {
				bfileLOC = ((OracleResultSet)rs).getBFILE(1);
			}

		}
		catch(Exception e){
			System.err.println(e);
			System.err.println("error getting locator for " + dumpDir + ":" + filename);
			prepStmt.close();
		}	

		// read and dump file
		try {
			bfileLOC.openFile();
			InputStream in = bfileLOC.getBinaryStream();
			int length = (int)bfileLOC.length();
			System.err.println("retrieving " + filename + ": " + length + " bytes");
			
			int bufsz = getBufSz();

			byte[] buff = new byte[1024];
			while (( length = in.read(buff)) != -1 ) {
				System.out.write(buff,0,length);
			}

			bfileLOC.closeFile();
			System.out.flush();

		}
		catch(Exception e){
			System.err.println(e);
		}	

		try {
			prepStmt.close();
		}
		catch(Exception e){
			System.err.println(e);
			System.err.println("closing prepStmt");
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
		}
		catch(Exception e){
			System.err.println(e);
		}	

		return dirPath;
	}


}
 




