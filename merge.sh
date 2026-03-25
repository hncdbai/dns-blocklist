#!/bin/bash

set -e

REMOTE_WHITELIST_URL="https://raw.githubusercontent.com/BlueSkyXN/AdGuardHomeRules/master/ok.txt"
REMOTE_WHITELIST="whitelist-remote.txt"

TMP_ALL="tmp_all.txt"
TMP_CLEAN="tmp_clean.txt"

FULL="blocklist-full.txt"
CN="blocklist-cn.txt"
GLOBAL="blocklist-global.txt"

> $TMP_ALL

echo "Downloading sources..."

echo "Downloading remote whitelist..."
curl -s $REMOTE_WHITELIST_URL > $REMOTE_WHITELIST

while read url; do
  [[ "$url" =~ ^#.*$ || -z "$url" ]] && continue
  echo "Fetching: $url"
  curl -s "$url" >> $TMP_ALL
  echo "" >> $TMP_ALL
done < sources.txt

echo "Cleaning..."

# 提取域名（适配 DNS）
cat $TMP_ALL \
| sed 's/\r//g' \
| grep -v '^!' \
| grep -v '^#' \
| grep -v '^$' \
| grep -Eo '([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}' \
| tr '[:upper:]' '[:lower:]' \
| sort -u \
> $TMP_CLEAN

echo "Applying whitelist..."

# 去掉白名单
cat whitelist.txt whitelist-auto.txt $REMOTE_WHITELIST > whitelist-all.txt

# 清理格式（很重要）
sed -i 's/\r//' whitelist-all.txt

# 去掉注释和空行
grep -v '^#' whitelist-all.txt | grep -v '^$' > whitelist-final.txt

# 应用白名单
grep -v -f whitelist-final.txt $TMP_CLEAN > $FULL || cp $TMP_CLEAN $FULL

echo "Generating CN list..."

# CN版本（全部）
cp $FULL $CN

echo "Generating GLOBAL list..."

# GLOBAL：去掉明显国内域名
grep -v -E '\.cn$|baidu|qq\.com|taobao|jd\.com|bilibili' $FULL > $GLOBAL

# 清理
rm $TMP_ALL $TMP_CLEAN

echo "Done!"
