#!/bin/bash
# Generiert ein Markdown-Changelog aus der Git-Historie.

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONEN]

Generiert ein Markdown-Changelog aus der Git-Historie.
Commits werden nach Datum gruppiert und innerhalb eines Datums nach Typ sortiert.

Optionen:
  -p, --path <Pfad>     Datei oder Verzeichnis filtern; '-' steht fuer gesamtes Repo
  -o, --output <Datei>  Ausgabepfad der Markdown-Datei
                        Standard: abhaengig von --path (siehe unten)
  -b, --branch <Ref>    Branch oder Tag (Standard: aktueller Branch)
  -s, --since <Ref>     Commits nach Datum (2026-01-01) oder ab Tag (v1.0.0)
  -u, --until <Ref>     Commits bis Datum oder Tag
  -t, --title <Titel>   Ueberschrift in der Ausgabedatei
                        Standard: Repo-Name + Branch (kein --path), sonst Pfad
  -h, --help            Diese Hilfe anzeigen

Standard-Ausgabepfade:
  Kein --path           <repo-root>/docs/CHANGELOG.md
  --path foo/           <repo-root>/docs/CHANGELOG_foo.md
  --path bar.sh         <repo-root>/docs/CHANGELOG_bar.md

Beispiele:
  $(basename "$0")
  $(basename "$0") -p src/player/ -b development
  $(basename "$0") -s 2026-01-01 -u 2026-03-31 -o docs/CHANGELOG_Q1.md
  $(basename "$0") --since v1.0.0 --until v1.1.0 -o docs/CHANGELOG_v1.1.md
  $(basename "$0") -t "Release v2.0" -o docs/CHANGELOG_v2.0.md
EOF
}

PATH_ARG=""
OUTPUT_ARG=""
BRANCH_ARG=""
SINCE_ARG=""
UNTIL_ARG=""
TITLE_ARG=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--path)   PATH_ARG="$2";   shift 2 ;;
        -o|--output) OUTPUT_ARG="$2"; shift 2 ;;
        -b|--branch) BRANCH_ARG="$2"; shift 2 ;;
        -s|--since)  SINCE_ARG="$2";  shift 2 ;;
        -u|--until)  UNTIL_ARG="$2";  shift 2 ;;
        -t|--title)  TITLE_ARG="$2";  shift 2 ;;
        -h|--help)   usage; exit 0 ;;
        *) echo "Unbekannte Option: $1" >&2; usage >&2; exit 1 ;;
    esac
done

if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Fehler: $(pwd) ist kein Git-Repository." >&2
    exit 1
fi

REMOTE=$(git config --get remote.origin.url 2>/dev/null || true)
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
REPO_NAME=$(basename "$REPO_ROOT")
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")
DOCS_DIR="${REPO_ROOT}/docs"

if [ -d "$PATH_ARG" ]; then
    TARGET_TYPE="dir"
    TARGET="$PATH_ARG"
    DIRNAME=$(basename "${PATH_ARG%/}")
    OUTPUT=${OUTPUT_ARG:-${DOCS_DIR}/CHANGELOG_${DIRNAME}.md}
elif [ -n "$PATH_ARG" ] && [ "$PATH_ARG" != "-" ]; then
    TARGET_TYPE="file"
    TARGET="$PATH_ARG"
    OUTPUT=${OUTPUT_ARG:-${DOCS_DIR}/CHANGELOG_$(basename "${PATH_ARG%.*}").md}
else
    TARGET_TYPE="all"
    TARGET=""
    OUTPUT=${OUTPUT_ARG:-${DOCS_DIR}/CHANGELOG.md}
fi

python3 - "$TARGET_TYPE" "$TARGET" "$OUTPUT" "$REMOTE" "$BRANCH_ARG" "$SINCE_ARG" "$UNTIL_ARG" "$TITLE_ARG" "$REPO_NAME" "$CURRENT_BRANCH" <<'PYTHON'
import sys, subprocess, os, re, datetime
target_type    = sys.argv[1]
target         = sys.argv[2]
output         = sys.argv[3]
remote         = sys.argv[4]
branch         = sys.argv[5]
since          = sys.argv[6]
until          = sys.argv[7]
title_arg      = sys.argv[8]
repo_name      = sys.argv[9]
current_branch = sys.argv[10]

def web_url(url):
    """Remote-URL (SSH oder HTTPS) in die Web-Adresse des Repos umwandeln."""
    url = url.strip()
    if not url:
        return ""
    m = re.match(r'^[\w.-]+@([^:/]+):(.+)$', url)          # git@github.com:owner/repo.git
    if m:
        host, path = m.groups()
    else:
        m = re.match(r'^(?:ssh|git|https?)://(?:[^@/]+@)?([^/:]+)(?::\d+)?/(.+)$', url)
        if not m:
            return ""
        host, path = m.groups()
    path = re.sub(r'\.git/?$', '', path.rstrip('/'))
    return f"https://{host}/{path}"

repo_url = web_url(remote)

def commit_link(h):
    return f" [{h}]({repo_url}/commit/{h})" if repo_url else f" {h}"

DATE_RE = re.compile(r'^\d{4}-\d{2}-\d{2}$')

def fail(msg):
    print(f"Fehler: {msg}", file=sys.stderr)
    print("Siehe --help.", file=sys.stderr)
    sys.exit(1)

def git_ok(*args):
    return subprocess.run(['git', *args], capture_output=True, text=True).returncode == 0

def is_branch(name):
    return any(git_ok('rev-parse', '--verify', '--quiet', f'{ns}/{name}^{{commit}}')
               for ns in ('refs/heads', 'refs/remotes'))

def is_tag(name):
    return git_ok('rev-parse', '--verify', '--quiet', f'refs/tags/{name}^{{commit}}')

def in_history(ref, source):
    return git_ok('merge-base', '--is-ancestor', ref, source)

def parse_bound(value, option, constant):
    """Grenze einlesen: ('none', None), ('date', 'JJJJ-MM-TT') oder ('tag', Name)."""
    if not value or value == constant:
        return ('none', None)
    if DATE_RE.match(value):
        try:
            datetime.date.fromisoformat(value)
        except ValueError:
            fail(f"{option}: unlesbares Datum '{value}'")
        return ('date', value)
    if is_tag(value):
        return ('tag', value)
    fail(f"{option}: '{value}' ist weder Tag noch Datum (JJJJ-MM-TT) noch {constant}")

# Quelle: der Branch, aus dessen Historie das Fenster geholt wird
if branch:
    if not is_branch(branch):
        fail(f"-b: '{branch}' ist kein lokaler oder Remote-Branch (ab einem Tag: -s <Tag>)")
    source = branch
else:
    source = current_branch or 'HEAD'

start_kind, start = parse_bound(since, '-s', 'FIRST')
end_kind, end = parse_bound(until, '-u', 'LATEST')

for kind, value, option in ((start_kind, start, '-s'), (end_kind, end, '-u')):
    if kind == 'tag' and not in_history(value, source):
        fail(f"{option}: Tag '{value}' liegt nicht in der Historie von '{source}'")
if start_kind == end_kind == 'tag' and not in_history(start, end):
    fail(f"-s '{start}' liegt nicht vor -u '{end}'")
if start_kind == end_kind == 'date' and start > end:
    fail(f"-s {start} liegt nach -u {end}")

# Felder mit %x1f, Commits mit %x1e trennen: der Betreff kann '|' enthalten.
# Autordatum (%ad) statt Commit-Datum (%cd): Sonst würden rebaste oder per
# Cherry-Pick übernommene Commits dem Tag des Rebase zugeordnet.
cmd = ['git','log','--no-merges','--pretty=format:%ad%x1f%h%x1f%B%x1e','--date=short']
# -u <Tag> schließt den Tag-Commit ein, -s <Tag> schließt ihn aus
cmd += [end if end_kind == 'tag' else source]
if start_kind == 'tag':
    cmd += [f'^{start}']
if target_type == "dir":
    cmd += ['--', target + '/']
elif target_type == "file":
    cmd += ['--', target]

proc = subprocess.run(cmd, capture_output=True, text=True)
if proc.returncode != 0:
    fail(proc.stderr.strip() or "git log fehlgeschlagen")

entries = []
for record in proc.stdout.split('\x1e'):
    parts = record.lstrip('\n').split('\x1f', 2)
    if len(parts) < 3: continue
    # Nur die erste Zeile: %s würde bei Commits ohne Leerzeile nach dem Betreff
    # den ganzen ersten Absatz zusammenfassen
    body = parts[2].strip()
    msg = body.splitlines()[0].strip() if body else ''
    # Datumsgrenzen auf dem angezeigten Autordatum prüfen, nicht mit --since/--until:
    # die filtern nach dem Commit-Datum. Beide Grenztage sind eingeschlossen.
    if start_kind == 'date' and parts[0] < start: continue
    if end_kind == 'date' and parts[0] > end: continue
    entries.append({'date':parts[0],'hash':parts[1],'msg':msg})

if not entries:
    label = target if target else "das Repository"
    print(f"Keine Git-Einträge für '{label}' gefunden, keine Datei erzeugt.", file=sys.stderr)
    sys.exit(0)

# group by date preserving order
from collections import OrderedDict
groups = OrderedDict()
for e in entries:
    groups.setdefault(e['date'], []).append(e)

# Typen in Ausgabereihenfolge, alles andere landet unter "sonstige"
TYPE_ORDER = ['Add','Fix','Chg','Upd','Rem','Docs','Cfg','Fmt','Ref','Ren','Mov']
# Präfixe aus älteren Historien
TYPE_ALIASES = {'Del':'Rem', 'Mve':'Mov', 'Ign':'Cfg', 'Dis':'Cfg', 'TryFix':'Fix'}
# Präfix am Anfang, toleriert alte Schreibweisen: "Fix:", "Fix;", "Chg.", "Add Kommentare"
TYPE_RE = re.compile(r'^([A-Za-z]+)(?:[:;.]|\s)')

def commit_type(msg):
    m = TYPE_RE.match(msg)
    if not m:
        return None
    word = m.group(1)
    word = TYPE_ALIASES.get(word, word)
    return word if word in TYPE_ORDER else None

def type_rank(msg):
    t = commit_type(msg)
    return TYPE_ORDER.index(t) if t else len(TYPE_ORDER)

# Determine title
if title_arg:
    title = title_arg
elif target_type == "all":
    title = f"{repo_name} ({source})"
else:
    title = f"Changelog für {target}"

lines = []
lines.append(f"# {title}\n")
lines.append("Die folgenden Einträge wurden automatisch aus der Git-Historie generiert. Die Reihenfolge der Typen ist " + " → ".join(TYPE_ORDER) + " → sonstige.\n")

for date, ents in groups.items():
    lines.append(f"## {date}\n")
    # sorted() ist stabil: innerhalb eines Typs bleibt die Git-Reihenfolge erhalten
    for e in sorted(ents, key=lambda e: type_rank(e['msg'])):
        lines.append(f"- {e['msg']}{commit_link(e['hash'])}\n")
    lines.append("\n")

os.makedirs(os.path.dirname(os.path.abspath(output)), exist_ok=True)
with open(output, 'w', encoding='utf-8') as f:
    f.writelines(lines)
print(f"Changelog generiert: {output}")
PYTHON

# Exit-Code von Python weitergeben
exit $?
