
import oracle.jdbc.*;
import java.sql.*;
import java.util.*;
import oracle.jdbc.pool.OracleDataSource;

import oraConnect.*;
import dates.*;

public class GetCurrDate {
	public static void main(String[] args){

		StringBuilder dbString = new StringBuilder();
		StringBuilder username = new StringBuilder();
		StringBuilder password = new StringBuilder();

		dbString.append(args[0]);
		username.append(args[1]);
		password.append(args[2]);

		Connection con = null;

		try {
			con = OracleConnect.getConnection(username.toString() + "/" + password.toString() + "@" + dbString.toString());
		}
		catch(Exception e){
			System.err.println(e);
		}

		String sysDate = OraDates.getSysDate(con);
		System.out.println("sysdate: " + sysDate);

		try {
			OracleConnect.closeCon(con);
		}
		catch(Exception e){
			System.err.println(e);
		}	
	}
}
 

