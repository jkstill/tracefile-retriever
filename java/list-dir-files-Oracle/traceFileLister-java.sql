
-- pass only an oracle directory name
-- otherwise the caller can read anything on the file system that Oracle has access to

create or replace and compile java source named "traceFileLister" as
import java.lang.*;
import java.io.*;
import java.sql.*;
import oracle.jdbc.*;
import java.util.Arrays;

public class traceFileLister {

    public static String[] getDirListArray(String directory) {
			String path = getDirPath(directory);
			File myDir = null;
			try {
				myDir = new File (path);
			}
			catch(Exception e){
				System.err.println(e);
			}	

			String[] files = myDir.list();

			Arrays.sort(files);

        return files;
    }


	public static String getDirPath(String dirName) {
		PreparedStatement prepStmt=null;
		String dirPath = null;
		Connection conn = null;

		try {
			conn = DriverManager.getConnection("jdbc:default:connection:");
		}
		catch (SQLException e) {
			System.err.println(e);
		}

		try {
			prepStmt=conn.prepareStatement("select directory_path from dba_directories where directory_name = upper(?)");
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



    public static java.sql.Array array_wrapper(
        String typeName,
        Object elements
    ) throws java.sql.SQLException {

		oracle.jdbc.OracleDriver ora = new oracle.jdbc.OracleDriver();

		Connection conn = null;

		try {
			conn = DriverManager.getConnection("jdbc:default:connection:");
		}
		catch (SQLException e) {
			System.err.println(e);
		}
        oracle.jdbc.OracleConnection oraConn =
            (oracle.jdbc.OracleConnection)conn;
        /* Yeah - typeName have to be UPPERCASE, really. */
        java.sql.Array arr = 
            oraConn.createARRAY(typeName.toUpperCase(), elements);
        return arr;
    }

    public static java.sql.Array getDirListArrayWrapped(String directory)
    throws java.sql.SQLException {
        return array_wrapper("filelist_t", getDirListArray(directory));
    }
};
/
show errors java source "so19ja"

