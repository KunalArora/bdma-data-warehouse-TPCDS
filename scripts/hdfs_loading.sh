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

if [ "$GEN_DATA" = "true" ]; then
  current_dir=$(pwd)

  cd $TPCDS_ROOT_DIR/tools/
  echo "Generating the data..."
  
  ./dsdgen -SCALE 1 -DIR $DATA_DIR_ONDISC -FORCE -VERBOSE
  verify_result "Generation of dataset has failed"

  cd $current_dir
fi


echo "Starting loading data to hdfs..."

dataFiles=$(ls ${DATA_DIR_ONDISC})
for dataFile in $dataFiles; do

    dir=${dataFile%.*}
    # Creation of the directory for each CSV file
    hdfs dfs -mkdir -p ${DATA_DIR}/${dir}
    verify_result "Error creating the directory on the HDFS"
    echo "path ${DATA_DIR}/${dir} created in HDFS"

    # Loading the data on the hdfs
    hdfs dfs -put ${DATA_DIR_ONDISC}/${dataFile} ${DATA_DIR}/${dir}
    verify_result "Error on loading the data in the HDFS"
    echo "${dataFile} loaded in HDFS"

done
