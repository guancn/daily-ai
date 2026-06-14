#!/usr/bin/env python3
"""从日报 HTML 中提取正文文本，用于 TTS 朗读"""
import re, sys

with open(sys.argv[1], 'r') as f:
    html = f.read()

# 取 summary 和 content 区域
parts = []
m = re.search(r'<div class="summary">(.*?)</div>', html, re.DOTALL)
if m:
    parts.append(re.sub(r'<[^>]+>', '', m.group(1)).strip())

# 取 item 里的 name 和 desc
for m in re.finditer(r'<div class="name">(.*?)</div>', html, re.DOTALL):
    parts.append(re.sub(r'<[^>]+>', '', m.group(1)).strip())

# 取 pulse-text
m = re.search(r'<div class="pulse-text">(.*?)</div>', html, re.DOTALL)
if m:
    parts.append(re.sub(r'<[^>]+>', '', m.group(1)).strip())

text = '。'.join(p for p in parts if p)
text = re.sub(r'\s+', ' ', text).strip()[:2000]
if text:
    print(text)
