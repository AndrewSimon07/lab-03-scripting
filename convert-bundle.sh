#!/bin/bash
set -euo pipefail

curl -o bundle.tar.gz https://s3.amazonaws.com/ds2002-resources/labs/lab3-bundle.tar.gz

tar -xzf bundle.tar.gz

awk '!/^[[:space:]]*$/' lab3_data.tsv > lab3_data_cleaned.tsv
tr '\t' ',' < lab3_data_cleaned.tsv > lab3_data_cleaned.csv
line_count=$(wc -l < lab3_data_cleaned.csv)
line_count=$((line_count - 1))
echo "Line count: $line_count"
tar -czf converted-archive.tar.gz lab3_data_cleaned.csv

