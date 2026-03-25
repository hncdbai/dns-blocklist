#!/bin/bash
set -e

# ===== 远程白名单 =====
REMOTE_WHITELIST_URL="https://raw.githubusercontent.com/BlueSkyXN/AdGuardHomeRules/master/ok.txt"
REMOTE_WHITELIST="whitelist-remote.txt"

# ===== 临时文件 =====
TMP_MAIN="tmp_main.txt"
TMP_CN="tmp_cn.txt"
TMP_EXTRA="tmp_extra.txt"

# ===== 输出 =====
OUT_FULL="blocklist-full.txt"
OUT_CN="blocklist-cn.txt"
OUT_GLOBAL="blocklist-global.txt"

# ===== 下载函数 =====
download_list () {
  local file=$1
  local output=$2
  > $output

  while read url; do
    [[ "$url" =~ ^#.*$ || -z "$url" ]] && continue
    echo "Fetching: $url"
    curl -s "$url" >> $output
    echo "" >> $output
  done < $file
}

# ===== 清洗域名 =====
clean_domains () {
  grep -Eo '([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}' \
  | tr '[:upper:]' '[:lower:]' \
  | sort -u
}

echo "Downloading MAIN..."
download_list sources-main.txt $TMP_MAIN

echo "Downloading CN..."
download_list sources-cn.txt $TMP_CN

echo "Downloading EXTRA..."
download_list sources-extra.txt $TMP_EXTRA

# ===== 下载远程白名单 =====
echo "Downloading REMOTE whitelist..."
curl -s $REMOTE_WHITELIST_URL > $REMOTE_WHITELIST || echo "Failed to download remote whitelist"

echo "Cleaning rules..."

cat $TMP_MAIN | clean_domains > main.txt
cat $TMP_CN | clean_domains > cn.txt
cat $TMP_EXTRA | clean_domains > extra.txt

# ===== 处理白名单 =====
echo "Preparing whitelist..."

touch whitelist.txt whitelist-auto.txt $REMOTE_WHITELIST

cat whitelist.txt whitelist-auto.txt $REMOTE_WHITELIST > whitelist-all.txt

# 清理格式
sed -i 's/\r//' whitelist-all.txt

# 去掉注释和空行
grep -v '^#' whitelist-all.txt | grep -v '^$' > whitelist-final.txt

# ===== FULL（全部规则）=====
echo "Generating FULL..."
cat main.txt cn.txt extra.txt \
| sort -u \
| grep -v -f whitelist-final.txt \
> $OUT_FULL || cp main.txt $OUT_FULL

# ===== CN（国内优先）=====
echo "Generating CN..."
cat main.txt cn.txt \
| sort -u \
| grep -v -f whitelist-final.txt \
> $OUT_CN || cp main.txt $OUT_CN

# ===== GLOBAL（去国内）=====
echo "Generating GLOBAL..."
cat main.txt extra.txt \
| grep -v -E '\.cn$|qq\.com|baidu|taobao|jd\.com' \
| sort -u \
| grep -v -f whitelist-final.txt \
> $OUT_GLOBAL || cp main.txt $OUT_GLOBAL

# ===== 清理 =====
rm -f tmp_*.txt main.txt cn.txt extra.txt whitelist-all.txt

echo "Done!"
