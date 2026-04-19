#!/bin/bash
# Generiert ein Markdown-Changelog aus der Git-Historie.
# Usage: ./generate_changelog.sh [Pfad/zu/Datei_oder_Verzeichnis|-] [Ziel/CHANGELOG.md]
#   Kein Argument    -> alle Commits im Repository
#   -                -> alle Commits im Repository (Platzhalter, ermöglicht Angabe von $2)
#   Verzeichnis      -> alle Commits, die Dateien im Verzeichnis betreffen
#   Datei            -> alle Commits, die diese Datei betreffen

ARG=${1:-}
REMOTE=$(git config --get remote.origin.url 2>/dev/null || true)

if [ -d "$ARG" ]; then
    TARGET_TYPE="dir"
    TARGET="$ARG"
    DIRNAME=$(basename "${ARG%/}")
    OUTPUT=${2:-../docs/CHANGELOG_${DIRNAME}.md}
elif [ -n "$ARG" ] && [ "$ARG" != "-" ]; then
    TARGET_TYPE="file"
    TARGET="$ARG"
    OUTPUT=${2:-../docs/CHANGELOG_$(basename "${ARG%.*}").md}
else
    TARGET_TYPE="all"
    TARGET=""
    OUTPUT=${2:-../docs/CHANGELOG.md}
fi

python3 - "$TARGET_TYPE" "$TARGET" "$OUTPUT" "$REMOTE" <<'PYTHON'
import sys, subprocess, os, re
target_type = sys.argv[1]
target      = sys.argv[2]
output      = sys.argv[3]
remote      = sys.argv[4]

cmd = ['git','log','--pretty=format:%ad|%h|%s','--date=short']
if target_type == "dir":
    cmd += ['--', target + '/']
elif target_type == "file":
    cmd += ['--', target]

proc = subprocess.run(cmd, capture_output=True, text=True)
if proc.returncode != 0 or not proc.stdout.strip():
    label = target if target else "das Repository"
    print(f"Keine Git-Einträge für '{label}' gefunden.")
    sys.exit(0)

entries = []
for line in proc.stdout.splitlines():
    parts = line.split('|',2)
    if len(parts) < 3: continue
    entries.append({'date':parts[0],'hash':parts[1],'msg':parts[2]})

# group by date preserving order
from collections import OrderedDict
groups = OrderedDict()
for e in entries:
    groups.setdefault(e['date'], []).append(e)

prefix_order = ['Add','Fix','Upd','Chg','Del','Docs','Ref','Mve','Rem','Ren']

lines = []
if target_type == "all":
    lines.append("# Changelog\n")
    lines.append("Die folgenden Einträge wurden automatisch aus der Git-Historie generiert. Die Reihenfolge der Typen ist Add → Fix → Upd → Chg → Del → Docs → Ref → Mve → Rem → Ren → sonstige.\n")
else:
    lines.append(f"# Changelog für {target}\n")
    lines.append("Die folgenden Einträge wurden automatisch aus der Git-Historie generiert. Die Reihenfolge der Typen ist Add → Fix → Upd → Chg → Del → Docs → Ref → Mve → Rem → Ren → sonstige.\n")

for date, ents in groups.items():
    lines.append(f"## {date}\n")
    for pref in prefix_order:
        for e in ents:
            if e['msg'].startswith(pref + ':') or e['msg'].startswith(pref + ' '):
                msg = e['msg'].replace('===', '\n  - ===')
                link = f" [{e['hash']}]({remote}/commit/{e['hash']})" if remote else f" {e['hash']}"
                lines.append(f"- {msg}{link}\n")
    for e in ents:
        if not re.match(r'^(Add|Fix|Upd|Chg|Del|Docs|Ref|Mve|Rem|Ren)[: ]', e['msg']):
            msg = e['msg'].replace('===', '\n  - ===')
            link = f" [{e['hash']}]({remote}/commit/{e['hash']})" if remote else f" {e['hash']}"
            lines.append(f"- {msg}{link}\n")
    lines.append("\n")

os.makedirs(os.path.dirname(os.path.abspath(output)), exist_ok=True)
with open(output, 'w', encoding='utf-8') as f:
    f.writelines(lines)
print(f"Changelog generiert: {output}")
PYTHON

exit 0
