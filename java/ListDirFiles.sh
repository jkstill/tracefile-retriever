:


export PATH=$PATH:$ORACLE_HOME/jdk/bin
export CLASSPATH=./:$ORACLE_HOME/jdbc/lib/ojdbc6.jar
# this Java is in the package oraConnect, and so must live in the oraConnect directory
# obvious to Java developers, new to me
# using -d oraConnect will nest a level deeper - oraConnect/oraConnect/OracleConnect.class
# by default the oraConnect directory is used
[[ oraConnect/OracleConnect.java -nt oraConnect/OracleConnect.class ]] && {
	echo Building oraConnect/OracleConnect.class
	javac -Xdiags:verbose -d oraConnect oraConnect/OracleConnect.java
}


[[ ListDirFiles.java -nt ListDirFiles.class ]] && {
	echo Building ListDirFiles.class
	javac -Xdiags:verbose  ListDirFiles.java
}

# database username password
# database can be EZ Connect
java ListDirFiles "$ORADB" "$ORAUSER" "$ORAPASSWORD" BDUMP_2
#java ListDirFiles "$ORADB" "$ORAUSER" "$ORAPASSWORD" BDUMP_2
#

