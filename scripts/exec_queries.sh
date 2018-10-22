#!/bin/bash

# This script is responsible for the execution of the tpcds queries 
# on top of Cloudera Impala Data Warehouse


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
    which impala-shell > /dev/null
    verify_result "Impala shell is not reachable from this directory. Exiting..."

    if [ -z "$QUERY_DIR" ]; then
        fatal "Directory for the data needs to be set"
    fi

    QUERY_OUTPUT_DIR=${QUERY_OUTPUT_DIR:=.}
}

. ./set_env.sh
check_env


# currentDir=$(pwd)
# cd $TPCDS_ROOT_DIR/tools
# i=1
# while [ $i -lt 100 ]
# do
#     ./dsqgen \
#     -SCALE 1 \
#     -QUIET \
#     -DIRECTORY ../query_templates \
#     -OUTPUT_DIR ${QUERY_DIR} \
#     -DIALECT netezza \
#     -TEMPLATE query${i}.tpl
    
#     mv ${QUERY_DIR}/query_0.sql ${QUERY_DIR}/query_${i}.sql
#     let i++
# done
# cd $currentDir

# sleep 2
failed=0
for query in $(ls ${QUERY_DIR})
do
    echo "use ${DB_NAME};" > ${QUERY_DIR}/${query}.copy
    head -n -2 ${QUERY_DIR}/${query} >> ${QUERY_DIR}/${query}.copy # On Linux
    # cat ${QUERY_DIR}/${query} | tail -r | tail -n +2 | tail -r # on Mac

    print_line
    echo "Executing $query..."
    print_line

    impala-shell -f ${QUERY_DIR}/${query}.copy > ${QUERY_OUTPUT_DIR}/${query}.res 2> ${QUERY_OUTPUT_DIR}/${query}.log
    result=$?
    rm ${QUERY_DIR}/${query}.copy
    sleep 1

    print_line
    if [ $result -ne 0 ]; then
        echo "Execution of $query failed."
        let failed++
    else
        echo "Execution of query $query succesful."
    fi
    print_line

    
    
done

print_line
echo "$failed queries have failed"
echo "Exiting..."
print_line