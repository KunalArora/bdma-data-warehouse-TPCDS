#!/bin/bash

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

checkEnv() {
    if [ -z ${DATA_DIR_ONDISC} ]; then
        fatal "Data directory on local file system must be set"
    fi

    DATA_DIR=${DATA_DIR:=/user/hive/tpcds}

    hdfs dfs -ls / > /dev/null
    verify_result "Erro trying to connect to hdfs"
}


. ./set_env.sh
checkEnv

echo "Starting loading data to hdfs..."

dataFiles=$(ls ${DATA_DIR_ONDISC})
for dataFile in $dataFiles; do

    dir=${dataFile%.*}
    hdfs dfs -mkdir -p ${DATA_DIR}/${dir} # Creation of the directory for each CSV file
    echo "path ${DATA_DIR}/${dir} created in HDFS"

    hdfs dfs -put ${DATA_DIR_ONDISC}/${dataFile} ${DATA_DIR}/${dir} # Loading the data on the hdfs
    echo "${dataFile} loaded in HDFS"

done
