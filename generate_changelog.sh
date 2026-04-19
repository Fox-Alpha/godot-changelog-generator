#!/bin/bash
# Generiert ein Markdown-Changelog aus der Git-Historie.
#
# Usage: ./generate_changelog.sh [OPTIONEN]
#
# Optionen:
#   --path <Pfad>     Datei oder Verzeichnis filtern (- = gesamtes Repo, Standard: gesamtes Repo)
#   --output <Datei>  Ausgabepfad (Standard: abhaengig von --path)
#   --branch <Ref>    Branch oder Tag (Standard: aktueller Branch)
#   --since <Ref>     Nur Commits nach diesem Datum oder Tag (z.B. 2026-01-01 oder v1.0.0)
#   --until <Ref>     Nur Commits bis zu diesem Datum oder Tag

PATH_ARG=""
OUTPUT_ARG=""
BRANCH_ARG=""
SINCE_ARG=""
UNTIL_ARG=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --path)   PATH_ARG="$2";   shift 2 ;;
        --output) OUTPUT_ARG="$2"; shift 2 ;;
        --branch) BRANCH_ARG="$2"; shift 2 ;;
        --since)  SINCE_ARG="$2";  shift 2 ;;
        --until)  UNTIL_ARG="$2";  shift 2 ;;
        *) echo "Unbekannte Option: $1" >&2; exit 1 ;;
    esac
done

REMOTE=$(git config --get remote.origin.url 2>/dev/null || true)

if [ -d "$PATH_ARG" ]; then
    TARGET_TYPE="dir"
    TARGET="$PATH_ARG"
    DIRNAME=$(basename "${PATH_ARG%/}")
    OUTPUT=${OUTPUT_ARG:-../docs/CHANGELOG_${DIRNAME}.md}
elif [ -n "$PATH_ARG" ] && [ "$PATH_ARG" != "-" ]; then
    TARGET_TYPE="file"
    TARGET="$PATH_ARG"
    OUTPUT=${OUTPUT_ARG:-../docs/CHANGELOG_$(basename "${PATH_ARG%.*}").md}
else
    TARGET_TYPE="all"
    TARGET=""
    OUTPUT=${OUTPUT_ARG:-../docs/CHANGELOG.md}
fi

python3 - "$TARGET_TYPE" "$TARGET" "$OUTPUT" "$REMOTE" "$BRANCH_ARG" "$SINCE_ARG" "$UNTIL_ARG" <<'PYTHON'
import sys, subprocess, os, re
target_type = sys.argv[1]
target      = sys.argv[2]
output      = sys.argv[3]
remote      = sys.argv[4]
branch      = sys.argv[5]
since       = sys.argv[6]
until       = sys.argv[7]

cmd = ['git','log','--pretty=format:%ad|%h|%s','--date=short']
if branch:
    cmd += [branch]
if since:
    cmd += [f'--since={since}'] if re.match(r'^\d{4}-\d{2}-\d{2}$', since) else [f'{since}..HEAD']
if until:
    # until as date
    if re.match(r'^\d{4}-\d{2}-\d{2}$', until):
        cmd += [f'--until={until}']
    else:
        # replace HEAD in a potential since..HEAD range, or add as upper bound
        cmd = [f'{since}..{until}' if since and not re.match(r'^\d{4}-\d{2}-\d{2}$', since)
               else c for c in cmd]
        if not since or re.match(r'^\d{4}-\d{2}-\d{2}$', since):
            cmd += [until]
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

