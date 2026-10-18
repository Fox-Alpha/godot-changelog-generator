#!/bin/bash
# Generiert ein Markdown-Changelog aus der Git-Historie.

VERSION="2.0.0"

usage() {
    local n
    n=$(basename "$0")
    cat <<EOF
Aufruf: $n [OPTIONEN]

Erzeugt aus der Git-Historie einen Markdown-Changelog oder Release-Notes.

Quelle und Zeitfenster:
  -b, --branch <Branch>  Quelle: lokaler oder Remote-Branch (z. B. origin/development).
                         Standard: aktueller Branch, bei detached HEAD HEAD.
                         Tags sind nicht erlaubt, ab einem Tag: -s <Tag>.
  -s, --since <Start>    Beginn: Tag (Tag-Commit ausgeschlossen), Datum JJJJ-MM-TT
                         (eingeschlossen) oder FIRST. Standard: FIRST (erster Commit)
  -u, --until <Ende>     Ende: Tag (eingeschlossen), Datum JJJJ-MM-TT (ganzer Tag
                         eingeschlossen) oder LATEST. Standard: LATEST
                         Tags müssen in der Historie von -b liegen.

Filter:
  -p, --path <Pfad> ...  ein oder mehrere Pfade (Dateien oder Verzeichnisse), relativ
                         zum Aufrufverzeichnis. Alle Argumente bis zur nächsten Option
                         gelten als Pfade; Pfade mit '-' am Anfang als ./-name.
  -e, --ext <Endungen>   Dateiendungen kommagetrennt ohne Punkt, z. B. gd,tscn.
                         Kombinierbar mit -p.

Ausgabe:
  -r, --release          Release-Notes statt vollständigem Changelog
  -o, --output <Datei>   Ausgabedatei relativ zum Aufrufverzeichnis, '-' = Standardausgabe
  -f, --force            vorhandene Ausgabedatei überschreiben
  -t, --title <Titel>    Überschrift. Standard: <Repo> (<Branch>), bei -r <Repo> <Version>,
                         ergänzt um die Filter von -p/-e

  -V, --version          Version anzeigen
  -h, --help             diese Hilfe anzeigen

Standard-Ausgabepfade (ohne -o):
  ohne Filter            <repo-root>/CHANGELOG.md
  -p src/player/         <repo-root>/docs/CHANGELOG_src_player.md
  -p src/a.gd -e gd      <repo-root>/docs/CHANGELOG_src_a_gd.md (Dateiendung des Pfads entfällt)
  -e gd,tscn             <repo-root>/docs/CHANGELOG_gd_tscn.md
  -r -u v1.2.0           <repo-root>/docs/releases/v1.2.0.md
  -r ohne Tag in -u      <repo-root>/docs/releases/unreleased.md (Filter werden angehängt)
  Existiert die Datei, bricht das Script ohne -f ab.

Inhalt:
  - Datum ist das Autordatum, Grenzen mit Datum beziehen sich ebenfalls darauf.
  - Merge-Commits werden ausgeblendet, ihre Commits erscheinen einzeln.
  - Je Commit zählt nur die erste Zeile der Message.
  - Changelog: nach Datum gegliedert, je Datum nach Typ sortiert:
    Add, Fix, Chg, Upd, Rem, Docs, Cfg, Fmt, Ref, Ren, Mov, sonstige.
    Alte Präfixe: Del=Rem, Mve=Mov, Ign=Cfg, Dis=Cfg, TryFix=Fix.
  - Release-Notes: nur Add, Fix, Chg, Upd, Rem, nach Typ gegliedert. Der Git-Trailer
    "Release: skip" blendet einen Commit aus, "Release: show" nimmt ihn auf.
  - Links auf Commits entstehen aus remote.origin.url (GitHub, GitLab o. Ä.),
    ohne Remote steht nur der Hash.
  - Pfadfilter gelten für den Pfad im jeweiligen Commit: Commits vor einem Verschieben
    oder Umbenennen fallen heraus.

Exit-Codes:
  0  Datei erzeugt, oder keine Treffer (Hinweis auf stderr, keine Datei)
  1  Fehler, z. B. unbekannte Option, Tag nicht in der Historie, -s nach -u,
     Ausgabedatei existiert

Beispiele:
  $n
  $n -b development -s v1.0.0
  $n -s 2026-01-01 -u 2026-03-31 -o docs/CHANGELOG_Q1.md
  $n -p src/player/ src/enemy/ -e gd
  $n -r -s v1.0.0 -u v1.1.0
  $n -r -o - | less
EOF
}

PATHS=()
EXT_ARG=""
OUTPUT_ARG=""
BRANCH_ARG=""
SINCE_ARG=""
UNTIL_ARG=""
TITLE_ARG=""
FORCE=0
RELEASE=0

# Bricht ab, wenn eine Option ohne Wert am Ende steht
need_value() {
    if [[ $# -lt 2 || -z "$2" ]]; then
        echo "Fehler: $1 erwartet einen Wert. Siehe --help." >&2
        exit 1
    fi
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--path)
            # alle Argumente bis zur nächsten Option sind Pfade
            shift
            while [[ $# -gt 0 && "$1" != -* ]]; do PATHS+=("$1"); shift; done
            if [[ ${#PATHS[@]} -eq 0 ]]; then
                echo "Fehler: -p erwartet mindestens einen Pfad (Pfade mit '-' am Anfang als ./-name). Siehe --help." >&2
                exit 1
            fi
            ;;
        -e|--ext)    need_value "$@"; EXT_ARG="$2";    shift 2 ;;
        -o|--output) need_value "$@"; OUTPUT_ARG="$2"; shift 2 ;;
        -b|--branch) need_value "$@"; BRANCH_ARG="$2"; shift 2 ;;
        -s|--since)  need_value "$@"; SINCE_ARG="$2";  shift 2 ;;
        -u|--until)  need_value "$@"; UNTIL_ARG="$2";  shift 2 ;;
        -t|--title)  need_value "$@"; TITLE_ARG="$2";  shift 2 ;;
        -f|--force)  FORCE=1; shift ;;
        -r|--release) RELEASE=1; shift ;;
        -V|--version) echo "$(basename "$0") $VERSION"; exit 0 ;;
        -h|--help)   usage; exit 0 ;;
        *) echo "Unbekannte Option: $1" >&2; usage >&2; exit 1 ;;
    esac
done

if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Fehler: $(pwd) ist kein Git-Repository." >&2
    exit 1
fi

REMOTE=$(git config --get remote.origin.url 2>/dev/null || true)
REPO_ROOT=$(git rev-parse --show-toplevel)
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")

# Pfade kommen als letzte Argumente, ihre Anzahl ist beliebig
python3 - "$OUTPUT_ARG" "$REMOTE" "$BRANCH_ARG" "$SINCE_ARG" "$UNTIL_ARG" "$TITLE_ARG" \
    "$REPO_ROOT" "$CURRENT_BRANCH" "$EXT_ARG" "$FORCE" "$RELEASE" "${PATHS[@]}" <<'PYTHON'
import sys, subprocess, os, re, datetime
output_arg     = sys.argv[1]
remote         = sys.argv[2]
branch         = sys.argv[3]
since          = sys.argv[4]
until          = sys.argv[5]
title_arg      = sys.argv[6]
repo_root      = sys.argv[7]
current_branch = sys.argv[8]
ext_arg        = sys.argv[9]
force          = sys.argv[10] == '1'
release        = sys.argv[11] == '1'
paths          = sys.argv[12:]
repo_name      = os.path.basename(repo_root)

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

# Filter: Pfade (-p) und Dateiendungen (-e) als Git-Pathspecs
exts = [x for x in ext_arg.split(',') if x] if ext_arg else []
for x in exts:
    if not re.match(r'^[A-Za-z0-9_]+$', x):
        fail(f"-e: ungültige Endung '{x}' (kommagetrennt ohne Punkt, z. B. gd,tscn)")

def glob_escape(path):
    return re.sub(r'([*?\[\]\\])', r'\\\1', path)

def is_file(path):
    return os.path.isfile(path)

if paths and exts:
    pathspecs = []
    for path in paths:
        for x in exts:
            if is_file(path):
                if path.endswith('.' + x):
                    pathspecs.append(path)
            else:
                pathspecs.append(f":(glob){glob_escape(path.rstrip('/'))}/**/*.{x}")
    if not pathspecs:
        fail("-p und -e: keiner der Pfade passt zu den Endungen")
elif paths:
    pathspecs = list(paths)
elif exts:
    pathspecs = [f":(glob)**/*.{x}" for x in exts]
else:
    pathspecs = []

def path_label(path):
    """Pfad relativ zum Repo-Root für Dateinamen, '/' wird zu '_', Dateiendung entfällt."""
    rel = os.path.relpath(os.path.abspath(path), repo_root)
    if is_file(path):
        rel = os.path.splitext(rel)[0]
    return re.sub(r'[\\/]+', '_', rel.strip('/')).strip('_.') or 'root'

filter_parts = [path_label(p) for p in paths] + exts
ext_desc = ", ".join(f"*.{x}" for x in exts)
if paths and exts:
    filter_desc = f"{', '.join(paths)} ({ext_desc})"
else:
    filter_desc = ", ".join(paths) or ext_desc

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

# Release-Notes: Version aus -u, wenn es ein Tag ist
version = end if end_kind == 'tag' else 'unreleased'

if output_arg:
    output = output_arg
elif release:
    output = os.path.join(repo_root, 'docs', 'releases', f"{'_'.join([version] + filter_parts)}.md")
elif filter_parts:
    output = os.path.join(repo_root, 'docs', f"CHANGELOG_{'_'.join(filter_parts)}.md")
else:
    output = os.path.join(repo_root, 'CHANGELOG.md')

# Überschreibschutz, gilt nicht für die Standardausgabe (-o -)
if output != '-' and os.path.exists(output) and not force:
    fail(f"Ausgabedatei existiert bereits: {output} (mit -f überschreiben)")

# Felder mit %x1f, Commits mit %x1e trennen: der Betreff kann '|' enthalten.
# Autordatum (%ad) statt Commit-Datum (%cd): Sonst würden rebaste oder per
# Cherry-Pick übernommene Commits dem Tag des Rebase zugeordnet.
# Der Release-Trailer steht vor %B, weil der Body beliebigen Text enthalten kann.
cmd = ['git','log','--no-merges',
       '--pretty=format:%ad%x1f%h%x1f%(trailers:key=Release,valueonly,separator=%x2c)%x1f%B%x1e',
       '--date=short']
# -u <Tag> schließt den Tag-Commit ein, -s <Tag> schließt ihn aus
cmd += [end if end_kind == 'tag' else source]
if start_kind == 'tag':
    cmd += [f'^{start}']
cmd += ['--', *pathspecs]

proc = subprocess.run(cmd, capture_output=True, text=True)
if proc.returncode != 0:
    fail(proc.stderr.strip() or "git log fehlgeschlagen")

entries = []
for record in proc.stdout.split('\x1e'):
    parts = record.lstrip('\n').split('\x1f', 3)
    if len(parts) < 4: continue
    date, h, trailer, body = parts
    # Nur die erste Zeile: %s würde bei Commits ohne Leerzeile nach dem Betreff
    # den ganzen ersten Absatz zusammenfassen
    body = body.strip()
    msg = body.splitlines()[0].strip() if body else ''
    # Datumsgrenzen auf dem angezeigten Autordatum prüfen, nicht mit --since/--until:
    # die filtern nach dem Commit-Datum. Beide Grenztage sind eingeschlossen.
    if start_kind == 'date' and date < start: continue
    if end_kind == 'date' and date > end: continue
    # bei mehreren Release-Trailern gilt der letzte
    release_mark = trailer.split(',')[-1].strip().lower() if trailer.strip() else ''
    entries.append({'date':date,'hash':h,'msg':msg,'release':release_mark})

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

# In Release-Notes erscheinende Typen
VISIBLE_TYPES = ['Add','Fix','Chg','Upd','Rem']

def in_release(e):
    """Der Trailer 'Release: skip/show' hat Vorrang vor dem Typ."""
    if e['release'] == 'skip':
        return False
    if e['release'] == 'show':
        return True
    return commit_type(e['msg']) in VISIBLE_TYPES

if release:
    entries = [e for e in entries if in_release(e)]

if not entries:
    label = filter_desc or "das Repository"
    print(f"Keine Git-Einträge für '{label}' gefunden, keine Datei erzeugt.", file=sys.stderr)
    sys.exit(0)

# Determine title
if title_arg:
    title = title_arg
else:
    title = f"{repo_name} {version}" if release else f"{repo_name} ({source})"
    if filter_desc:
        title += f" – {filter_desc}"

def strip_type(msg):
    """Präfix entfernen, unter der Typ-Überschrift steht er nicht noch einmal."""
    return re.sub(r'^[A-Za-z]+[:;.]?\s*', '', msg, count=1) if commit_type(msg) else msg

def release_link(h):
    return f" ([{h}]({repo_url}/commit/{h}))" if repo_url else f" ({h})"

lines = []
if release:
    # Release-Notes: nach Typ gegliedert, Zeitraum und Anzahl im Kopf
    dates = sorted(e['date'] for e in entries)
    period = dates[0] if dates[0] == dates[-1] else f"{dates[0]} – {dates[-1]}"
    count = f"{len(entries)} Änderung" + ("" if len(entries) == 1 else "en")
    lines.append(f"## {title}\n\n")
    lines.append(f"**Zeitraum:** {period} · {count}\n\n")
    for t in TYPE_ORDER + [None]:
        ents = [e for e in entries if commit_type(e['msg']) == t]
        if not ents:
            continue
        lines.append(f"### {t or 'Sonstige'}\n")
        for e in ents:
            lines.append(f"- {strip_type(e['msg'])}{release_link(e['hash'])}\n")
        lines.append("\n")
else:
    # Vollständiger Changelog: nach Datum gegliedert, je Datum nach Typ sortiert
    groups = {}
    for e in entries:
        groups.setdefault(e['date'], []).append(e)
    lines.append(f"# {title}\n")
    lines.append("Die folgenden Einträge wurden automatisch aus der Git-Historie generiert. Die Reihenfolge der Typen ist " + " → ".join(TYPE_ORDER) + " → sonstige.\n")
    for date, ents in groups.items():
        lines.append(f"## {date}\n")
        # sorted() ist stabil: innerhalb eines Typs bleibt die Git-Reihenfolge erhalten
        for e in sorted(ents, key=lambda e: type_rank(e['msg'])):
            lines.append(f"- {e['msg']}{commit_link(e['hash'])}\n")
        lines.append("\n")

if output == '-':
    try:
        sys.stdout.writelines(lines)
        sys.stdout.flush()
    except BrokenPipeError:
        # Leser hat vorzeitig beendet (z. B. | head), restliche Ausgabe verwerfen
        os.dup2(os.open(os.devnull, os.O_WRONLY), sys.stdout.fileno())
else:
    os.makedirs(os.path.dirname(os.path.abspath(output)), exist_ok=True)
    with open(output, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    print(f"Changelog generiert: {output}")
PYTHON

# Exit-Code von Python weitergeben
exit $?
