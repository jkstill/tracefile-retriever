
package dates;

import oracle.jdbc.*;
import java.sql.*;
import java.util.*;
import oracle.jdbc.pool.OracleDataSource;
 
public class OraDates{

	public static String getSysDate(Connection con ) {

		ResultSet rs=null;
		String retDate=null;

		try{

			Statement stmt=con.createStatement();
			rs=stmt.executeQuery("select sysdate from dual");
			rs.next();
			retDate = rs.getString(1);

		}
		catch(Exception e){ System.out.println(e);}

		return retDate;
	}

}

