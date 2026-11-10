# godot-changelog-generator

Bash-Script (`generate_changelog.sh`) mit eingebettetem Python 3, das aus der Git-Historie einen Markdown-Changelog
erzeugt. Keine weiteren Abhängigkeiten außer Git, Bash und Python 3.

## Git-Workflow

Es gilt [`.claude/workflow.md`](.claude/workflow.md), Details in
[`.claude/workflow-details.md`](.claude/workflow-details.md). Bewusst ohne `@`-Import:

- Start in der Projektsammlung (`claudeprojekte`): Deren Workflow ist bereits geladen und gilt.
- Start in diesem Repo: `.claude/workflow.md` vor dem ersten Commit, Branch-Wechsel oder Merge lesen.

## Projekteinstellungen

- Commit-Sprache: Deutsch (die bisherige englische Historie bleibt unverändert)
- Standardbranch: `main`
- Quellordner: Repo-Wurzel
- Zusätze: keine

## Pflegehinweise

- Die Commit-Typen stehen an mehreren Stellen und müssen zusammen geändert werden:
  - `.claude/workflow.md`: Kopie des Workflows der Projektsammlung (`claudeprojekte/.claude/workflow.md`), dort
    zuerst ändern
  - `docs/commit-types.md`: Nutzer-Doku mit Typen, Reihenfolge, Sichtbarkeit und alten Präfixen
  - `generate_changelog.sh`: `TYPE_ORDER`, `TYPE_ALIASES`, `VISIBLE_TYPES` und der Abschnitt „Inhalt“ in `usage()`
- Ändert sich der Workflow in der Projektsammlung, die Kopie in `.claude/` nachziehen und prüfen, ob
  `docs/commit-types.md` und das Script mit angepasst werden müssen.
- `.claude/` gehört nicht in die Release-Archive (`.gitattributes`), Nutzer-Doku liegt direkt in `docs/`.

## Release-Trailer

Regeln im Workflow, Abschnitt „Release-Notes“. In diesem Repo:

- `Release: show`: `Docs:` an der Nutzer-Doku (`README.md`, `LICENSE`, `docs/*.md`) und `Cfg:`,
  die den Inhalt der Release-Archive ändern (`.gitattributes`)
- `Release: skip`: `Upd: Version x.y.z` und Fixes an Fehlern aus dem noch nicht veröffentlichten Stand
- ohne Trailer, also intern: `CHANGELOG.md` neu erzeugt, `CLAUDE.md`, `.claude/`
- Den Trailer im selben Block wie `Co-Authored-By:` setzen, ohne Leerzeile dazwischen.

## Sprache

- Antworten und Code-Kommentare auf Deutsch.
