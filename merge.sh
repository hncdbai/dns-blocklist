#!/bin/bash

OUTPUT="blocklist.txt"
TEMP="temp.txt"

> $TEMP

# 下载所有规则
while read url; do
  curl -s "$url" >> $TEMP
  echo "" >> $TEMP
done < sources.txt

# 清理 + 去重
cat $TEMP \
| sed 's/\r//g' \
| grep -v '^!' \
| grep -v '^#' \
| grep -v '^$' \
| sort -u \
> $OUTPUT

rm $TEMP

echo "Done. Output: $OUTPUT"
