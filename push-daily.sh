#!/bin/bash
# push-daily.sh — 将日报 HTML 提交并推送到 GitHub Pages
# 用法: ./push-daily.sh <html_file_path> [日期]

set -euo pipefail
REPO_DIR="/home/guancn/myhermes/daily-ai"
HTML_FILE="${1:-}"
DATE="${2:-$(date +%Y-%m-%d)}"

if [ -z "$HTML_FILE" ]; then
  echo "用法: $0 <html_file_path> [日期]"
  exit 1
fi

# 复制 HTML 到仓库
cp "$HTML_FILE" "$REPO_DIR/$DATE.html"

cd "$REPO_DIR"

# 更新文件列表
python3 -c "
import json, os, glob
files = sorted(os.path.basename(f) for f in glob.glob('2*.html'))
# 排除 index.html 和 template.html
files = [f for f in files if f not in ('index.html', 'template.html')]
# 按文件名排序（日期）
files.sort()
with open('filelist.json', 'w') as fp:
    json.dump(files, fp, ensure_ascii=False)
"

# 提交并推送
git add "$DATE.html" filelist.json CNAME index.html
git commit -m "🤖 AI日报 - $DATE"
git push origin main

echo "✅ 已发布: https://daily.guancn.me/$DATE.html"
