#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PY'
from pathlib import Path
import re
import xml.etree.ElementTree as ET
root = Path.cwd()
required = [
    root / 'app/src/main/AndroidManifest.xml',
    root / 'app/src/main/java/com/tajirpro/app/MainActivity.java',
    root / 'app/src/main/assets/index.html',
    root / 'app/src/main/res/mipmap-hdpi/ic_launcher.png',
]
missing = [str(p.relative_to(root)) for p in required if not p.is_file()]
if missing:
    raise SystemExit('Missing project files: ' + ', '.join(missing))
ET.parse(root / 'app/src/main/AndroidManifest.xml')
html = (root / 'app/src/main/assets/index.html').read_text(encoding='utf-8')
blocks = re.findall(r'<script[^>]*>(.*?)</script>', html, re.S)
if not blocks:
    raise SystemExit('No inline JavaScript found to validate')
Path('/tmp/tajirpro-inline.js').write_text('\n'.join(blocks), encoding='utf-8')
print('Project files and AndroidManifest.xml: OK')
PY
node --check /tmp/tajirpro-inline.js
echo 'Inline JavaScript syntax: OK'
