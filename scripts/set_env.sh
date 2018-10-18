#!/bin/bash

# Either true or false
export GEN_DATA=false

# Dataset location
export DATA_DIR=/user/hive/tpcds # On HDFS
export DATA_DIR_ONDISC=../../dataSet #On the local filesystem


# Direcotry for the TPC-DS tool
export TPCDS_ROOT_DIR=~/Desktop/tpcds

# Database information
export DB_NAME=TPCDS_DB

# Output Directory for the result
export OUTPUT_DIR=~/Desktop/out
export QUERY_OUTPUT_DIR=~/Desktop/out/query

# Query directory on disc
export QUERY_DIR=~/Desktop/query
