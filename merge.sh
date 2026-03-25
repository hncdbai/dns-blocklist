#!/bin/bash
set -e

# ===== 时间 =====
NOW=$(date -u '+%Y-%m-%d %H:%M:%S UTC')

# ===== 临时文件 =====
TMP_ALL="all_rules.txt"
TMP_CLEAN="clean_rules.txt"

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

# ===== 清洗规则（保留ABP格式）=====
clean_rules () {
  grep -vE '^!|^\[|^#' \          # 去注释
  | sed 's/\r//' \
  | grep -E '^\|\||^@@\|\|' \     # 只保留 || 和 @@||
  | grep -vE '/|\$|#' \           # 去路径规则/参数规则
  | sort -u
}

echo "Downloading rules..."

download_list sources-main.txt main.txt
download_list sources-cn.txt cn.txt
download_list sources-extra.txt extra.txt

# ===== FULL =====
echo "Generating FULL..."

cat main.txt cn.txt extra.txt > $TMP_ALL

cat $TMP_ALL | clean_rules > $TMP_CLEAN

COUNT=$(wc -l < $TMP_CLEAN)

{
echo "! ========================================="
echo "! DNS Blocklist (FULL - ABP Mode)"
echo "! Generated: $NOW"
echo "! Total Rules: $COUNT"
echo "! ========================================="
echo ""
cat $TMP_CLEAN
} > $OUT_FULL

# ===== CN =====
echo "Generating CN..."

cat main.txt cn.txt > $TMP_ALL

cat $TMP_ALL | clean_rules > $TMP_CLEAN

COUNT=$(wc -l < $TMP_CLEAN)

{
echo "! ========================================="
echo "! DNS Blocklist (CN - ABP Mode)"
echo "! Generated: $NOW"
echo "! Total Rules: $COUNT"
echo "! ========================================="
echo ""
cat $TMP_CLEAN
} > $OUT_CN

# ===== GLOBAL =====
echo "Generating GLOBAL..."

cat main.txt extra.txt \
| grep -vE 'baidu|qq\.com|taobao|jd\.com|\.cn' \
> $TMP_ALL

cat $TMP_ALL | clean_rules > $TMP_CLEAN

COUNT=$(wc -l < $TMP_CLEAN)

{
echo "! ========================================="
echo "! DNS Blocklist (GLOBAL - ABP Mode)"
echo "! Generated: $NOW"
echo "! Total Rules: $COUNT"
echo "! ========================================="
echo ""
cat $TMP_CLEAN
} > $OUT_GLOBAL

# ===== 统计 =====
echo "Generating stats..."

FULL_COUNT=$(grep -v '^!' $OUT_FULL | wc -l)
CN_COUNT=$(grep -v '^!' $OUT_CN | wc -l)
GLOBAL_COUNT=$(grep -v '^!' $OUT_GLOBAL | wc -l)

cat > stats.json <<EOF
{
  "generated": "$NOW",
  "full": $FULL_COUNT,
  "cn": $CN_COUNT,
  "global": $GLOBAL_COUNT
}
EOF

# ===== 清理 =====
rm -f main.txt cn.txt extra.txt $TMP_ALL $TMP_CLEAN

echo "Done!"
