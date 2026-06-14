#!/usr/bin/env python3
"""从日报 HTML 中提取正文文本，用于 TTS 朗读"""
import re, sys

with open(sys.argv[1], 'r') as f:
    html = f.read()

# 只取内容区域（summary + 后面内容）
start = html.find('<div class="summary"')
end = html.find('<div class="footer"')
if start > 0 and end > start:
    content = html[start:end]
else:
    content = html

# 去标签
text = re.sub(r'<[^>]+>', ' ', content)
# 去多余空白
text = re.sub(r'\s+', ' ', text).strip()
# 截取前 2000 字（约 6-8 分钟）
text = text[:2000]

if text:
    print(text)
