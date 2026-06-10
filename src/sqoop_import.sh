#!/bin/bash

set -e

echo "========================================="
echo "Starting Sqoop Full Load from PostgreSQL"
echo "========================================="

# =========================================

# PostgreSQL Configuration

# =========================================

DB_HOST="13.42.152.118"
DB_PORT="5432"
DB_NAME="testdb"
DB_USER="admin"
DB_PASS="admin123"
DB_SCHEMA="aparna"

# =========================================

# HDFS Target Directory

# =========================================

HDFS_DIR="/tmp/tfl_project_hadoop"

# Create HDFS directory if it doesn't exist

hdfs dfs -mkdir -p ${HDFS_DIR}

# =========================================

# List of tables

# =========================================

TABLES=(
"dim_networks_full_load"
"dim_lines_full_load"
"dim_stations_full_load"
"fact_station_lines_full_load"
"dim_date_full_load"
"fact_passenger_entry_exit_full_load"
)

# =========================================

# Import each table

# =========================================

for TABLE in "${TABLES[@]}"
do

echo "========================================="
echo "Importing ${TABLE}"
echo "========================================="

sqoop import 
--connect jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME} 
--username ${DB_USER} 
--password ${DB_PASS} 
--table ${DB_SCHEMA}.${TABLE} 
--target-dir ${HDFS_DIR}/${TABLE} 
--delete-target-dir 
--as-parquetfile 
--num-mappers 1

if [ $? -eq 0 ]
then
echo "SUCCESS : ${TABLE} imported successfully."
else
echo "FAILED : ${TABLE} import failed."
exit 1
fi

done

echo "========================================="
echo "All Full Load Tables Imported Successfully"
echo "========================================="

echo "========================================="
echo "HDFS Output"
echo "========================================="

hdfs dfs -ls ${HDFS_DIR}
