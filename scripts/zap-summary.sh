#!/usr/bin/env bash
set -euo pipefail

REPORT="${1:?Uso: zap-summary.sh REPORTE.html}"

python3 - "$REPORT" <<'PY'
import html
import re
import sys

path = sys.argv[1]
text = open(path, encoding="utf-8", errors="ignore").read()

print(f"Reporte: {path}")
site = re.search(r'<td class="site"[^>]*>(.*?)</td>', text, re.S)
if site:
    print(f"Sitio: {html.unescape(re.sub('<[^>]+>', '', site.group(1))).strip()}")

summary = re.search(
    r'<h3 class="left-header">Summary of Alerts</h3>(.*?)</table>',
    text,
    re.S,
)
if summary:
    rows = re.findall(
        r'<td class="risk-[^"]*">\s*<div>(.*?)</div>\s*</td>\s*'
        r'<td align="center">\s*<div>(.*?)</div>',
        summary.group(1),
        re.S,
    )
    print("Resumen de alertas:")
    for name, count in rows:
        print(f"  {html.unescape(re.sub('<[^>]+>', '', name)).strip():<18} {count.strip()}")

alerts = re.search(r'<h3 class="left-header">Alerts</h3>(.*?)</table>', text, re.S)
if alerts:
    names = re.findall(
        r'<td class="risk-[^"]*">\s*<div>([^<]+)</div>\s*</td>.*?'
        r'<td align="center">\s*<div>([^<]+)</div>',
        alerts.group(1),
        re.S,
    )
    if names:
        print("Alertas detectadas:")
        for name, count in names:
            print(f"  - {name.strip()} ({count.strip()} instancia/s)")
    else:
        print("Alertas detectadas: ninguna")
PY
