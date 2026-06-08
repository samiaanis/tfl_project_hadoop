#!/bin/bash

echo "========================================="
echo "Starting Sqoop Full Load from PostgreSQL"
echo "========================================="

# PostgreSQL connection variables (injected by Jenkins)
PG_CONN="jdbc:postgresql://${PG_HOST}:${PG_PORT}/${PG_DB}"

TABLES=(
    "dim_networks_full_load"
    "dim_lines_full_load"
    "dim_stations_full_load"
    "fact_station_lines_full_load"
    "dim_date_full_load"
    "fact_passenger_entry_exit_full_load"
)

for TABLE in "${TABLES[@]}"; do
    echo "-----------------------------------------"
    echo "Importing table: ${TABLE}"
    echo "-----------------------------------------"

    sqoop import \
        --connect "${PG_CONN}" \
        --username "${PG_USER}" \
        --password "${PG_PASSWORD}" \
        --table "${PG_SCHEMA}.${TABLE}" \
        --target-dir "${HDFS_DIR}/${TABLE}" \
        --delete-target-dir \
        --as-parquetfile \
        --num-mappers 1

    if [ $? -ne 0 ]; then
        echo "❌ Sqoop import failed for table: ${TABLE}"
        exit 1
    else
        echo "✅ Successfully imported: ${TABLE}"
    fi
done

echo "========================================="
echo "Sqoop Full Load Completed Successfully"
echo "========================================="
