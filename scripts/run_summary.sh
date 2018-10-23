#!/bin/bash

# This script is run in order to generate 
# a benchmark summary of previous execution


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
    QUERY_OUTPUT_DIR=${QUERY_OUTPUT_DIR:=.}
    OUTPUT_DIR=${OUTPUT_DIR:=.}
}

. ./set_env.sh
check_env

outFile=$OUTPUT_DIR/summary$$.txt

print_line > $outFile
echo -e "Query number\t|\tExecution Time" >> $outFile
echo "" >> $outFile

for query_res_file in $(ls $QUERY_OUTPUT_DIR | grep .log)
do
    query=${query_res_file%.log}
    executionTime=$(cat $QUERY_OUTPUT_DIR/$query_res_file | grep Fetched | cut -f 5 -d ' ')
    echo -e "$query\t|\t$executionTime" >> $outFile
done

print_line >> $outFile