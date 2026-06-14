#!/bin/bash
# push-daily.sh — 将日报 HTML + MP3 提交并推送到 GitHub Pages
# 用法: ./push-daily.sh <html_file_path> [日期]

set -euo pipefail
REPO_DIR="/home/guancn/myhermes/daily-ai"
HTML_FILE="${1:-}"
DATE="${2:-$(date +%Y-%m-%d)}"

if [ -z "$HTML_FILE" ]; then
  echo "用法: $0 <html_file_path> [日期]"
  exit 1
fi

cp "$HTML_FILE" "$REPO_DIR/$DATE.html"

# 提取正文文本用于朗读（跳过 CSS/JS）
python3 /home/guancn/myhermes/daily-ai/extract-text.py "$HTML_FILE" > /tmp/tts-input.txt

if [ -s /tmp/tts-input.txt ]; then
  /home/guancn/.hermes/hermes-agent/venv/bin/edge-tts \
    --voice zh-CN-XiaoxiaoNeural \
    --text "$(cat /tmp/tts-input.txt)" \
    --write-media "$REPO_DIR/$DATE.mp3" 2>/dev/null
  echo "  🎧 MP3 已生成 ($(stat -c%s "$REPO_DIR/$DATE.mp3" 2>/dev/null) bytes)"
fi

cd "$REPO_DIR"

# 更新文件列表
python3 -c "
import json, glob, os
files = sorted(os.path.basename(f) for f in glob.glob('2*.html'))
files = [f for f in files if f not in ('index.html', 'template.html')]
with open('filelist.json', 'w') as fp:
    json.dump(files, fp, ensure_ascii=False)
"

# 提交并推送
git add "$DATE.html" "$DATE.mp3" filelist.json CNAME index.html
git commit -m "🤖 AI日报 - $DATE" 2>/dev/null || echo "  ⏭ 无新变更"
git push origin main 2>&1

echo "✅ https://daily.guancn.me/$DATE.html"
