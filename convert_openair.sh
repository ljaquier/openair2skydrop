#!/bin/bash

openair_file=$1
curl -s --request POST \
  --url https://xcglobe.com/airspace/upload-file \
  --header 'Content-Type: multipart/form-data' \
  --form file="@$openair_file" > /dev/null

uploaded_openair_file=$(basename "$openair_file")
exported_aip_file=source/export.aip
curl -s --request POST \
  --url https://xcglobe.com/airspace/export-file \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data sourceType=openair \
  --data sourceName="$uploaded_openair_file" \
  --data destType=aip \
  --data saveto=disk \
  --data _noAjaxSubmit= \
  --data 'airsJson=[]' | \
sed 's/CATEGORY="R"/CATEGORY="RESTRICTED"/g' | \
sed 's/CATEGORY="Q"/CATEGORY="DANGER"/g' | \
sed 's/CATEGORY="P"/CATEGORY="PROHIBITED"/g' | \
sed 's/CATEGORY="GP"/CATEGORY="PROHIBITED"/g' | \
sed 's/CATEGORY="W"/CATEGORY="WAVE"/g' > "$exported_aip_file"

rm -r data 2> /dev/null
python3 -m pip install --upgrade -r requirements.txt -t libs
PYTHONPATH=./libs python3 convert.py $exported_aip_file
