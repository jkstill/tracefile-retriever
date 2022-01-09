#!/usr/bin/env bash


export PATH=$PATH:$ORACLE_HOME/jdk/bin
export CLASSPATH=./:$ORACLE_HOME/jdbc/lib/ojdbc6.jar
# this Java is in the package oraConnect, and so must live in the oraConnect directory
# obvious to Java developers, new to me
# using -d oraConnect will nest a level deeper - oraConnect/oraConnect/OracleConnect.class
# by default the oraConnect directory is used
#javac -Xdiags:verbose -d oraConnect oraConnect/OracleConnect.java
[[ GetCurrDate.java -nt GetCurrDate.class ]] && {
	echo Building GetCurrDate >&2
	javac -Xdiags:verbose  GetCurrDate.java
}


[[ dates/OraDates.java -nt dates/OraDates.class ]] && {
	echo building dates/OraDates >&2
	javac -Xdiags:verbose  dates/OraDates.java
}

# database username password
# database can be EZ Connect
java GetCurrDate "$ORADB" "$ORAUSER" "$ORAPASSWORD"

