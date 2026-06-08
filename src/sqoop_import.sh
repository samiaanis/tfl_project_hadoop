```bash
#!/bin/bash

set -e

echo "==========================================="
echo "Starting PostgreSQL to HDFS Full Load"
echo "==========================================="

# PostgreSQL Configuration
DB_HOST="13.42.152.118"
DB_PORT="5432"
DB_NAME="testdb"
DB_USER="admin"
DB_PASS="admin123"

# HDFS Target Directory
HDFS_DIR="/tmp/tfl_project_hadoop"

echo "Creating HDFS directory..."

hdfs dfs -mkdir -p ${HDFS_DIR}

echo "-------------------------------------------"
echo "Importing dim_networks_full_load"
echo "-------------------------------------------"

sqoop import \
--connect jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME} \
--username ${DB_USER} \
--password ${DB_PASS} \
--table aparna.dim_networks_full_load \
--target-dir ${HDFS_DIR}/dim_networks_full_load \
--delete-target-dir \
-m 1

echo "-------------------------------------------"
echo "Importing dim_lines_full_load"
echo "-------------------------------------------"

sqoop import \
--connect jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME} \
--username ${DB_USER} \
--password ${DB_PASS} \
--table aparna.dim_lines_full_load \
--target-dir ${HDFS_DIR}/dim_lines_full_load \
--delete-target-dir \
-m 1

echo "-------------------------------------------"
echo "Importing dim_stations_full_load"
echo "-------------------------------------------"

sqoop import \
--connect jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME} \
--username ${DB_USER} \
--password ${DB_PASS} \
--table aparna.dim_stations_full_load \
--target-dir ${HDFS_DIR}/dim_stations_full_load \
--delete-target-dir \
-m 1

echo "-------------------------------------------"
echo "Importing fact_station_lines_full_load"
echo "-------------------------------------------"

sqoop import \
--connect jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME} \
--username ${DB_USER} \
--password ${DB_PASS} \
--table aparna.fact_station_lines_full_load \
--target-dir ${HDFS_DIR}/fact_station_lines_full_load \
--delete-target-dir \
-m 1

echo "-------------------------------------------"
echo "Importing dim_date_full_load"
echo "-------------------------------------------"

sqoop import \
--connect jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME} \
--username ${DB_USER} \
--password ${DB_PASS} \
--table aparna.dim_date_full_load \
--target-dir ${HDFS_DIR}/dim_date_full_load \
--delete-target-dir \
-m 1

echo "-------------------------------------------"
echo "Importing fact_passenger_entry_exit_full_load"
echo "-------------------------------------------"

sqoop import \
--connect jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME} \
--username ${DB_USER} \
--password ${DB_PASS} \
--table aparna.fact_passenger_entry_exit_full_load \
--target-dir ${HDFS_DIR}/fact_passenger_entry_exit_full_load \
--delete-target-dir \
-m 2

echo "==========================================="
echo "FULL LOAD COMPLETED SUCCESSFULLY"
echo "==========================================="

echo "Listing imported HDFS directories..."

hdfs dfs -ls ${HDFS_DIR}

echo "==========================================="
echo "Pipeline finished successfully."
echo "==========================================="
```

