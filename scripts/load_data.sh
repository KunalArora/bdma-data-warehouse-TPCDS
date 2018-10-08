#!/bin/bash

# Through the current script it will be possible to generate data
# from tpcds tool and load it to the data warehouse through SparkSQL

print_line() {
  echo "#############################"
}

fatal() {
  print_line
  echo "$1"
  print_line
  exit 0
}

verify_result() {
  if [ $? -ne 0 ]; then
    fatal "$1"
  fi
}

check_env() {
  if [ -z "$SPARK_HOME" ]; then
    fatal "SPARK_HOME env variable needs to be set"
  fi

  GEN_DATA=${GEN_DATA:="true"}

  if [ -z "$DATA_DIR" ]; then
    fatal "Directory for the data needs to be set"
  fi
}


# Set all the environment variables
. ./set_env.sh
check_env

if [ "$GEN_DATA" = "true" ]; then
  current_dir=$(pwd)
  cd $TPCDS_ROOT_DIR/tools/
  ./dsdgen -SCALE 1 -DIR $DATA_DIR -FORCE -VERBOSE
  verify_result "Generation of dataset has failed"
  cd $current_dir
fi

# Evaluating the ddl scripts
# according to the actual env variables
DDL=$(pwd)/../ddl
while read line; do
  eval "echo \"$line\"";
done < $DDL/create_database_template.sql > $DDL/create_database.sql

while read line; do
  line=${line//\"/\\\"}
  eval "echo \"$line\"";
done < $DDL/create_tables_template.sql > $DDL/create_tables.sql


# Executing the command in SparkSQL
current_dir=$(pwd)
cd $SPARK_HOME
bin/spark-sql --conf spark.sql.catalogImplementation=hive -f ${DDL}/create_database.sql > ${DDL}/create_database.out
verify_result "Error in creating the database"

bin/spark-sql --conf spark.sql.catalogImplementation=hive -f ${DDL}/create_tables.sql > ${DDL}/create_tables.out
verify_result "Error in loading the tables"

bin/spark-sql --conf spark.conf.catalogImplementation=hive -f ${DDL}/../query/select.sql
verify_result "Error in querying the database"