# Verwendung – godot-changelog-generator

Beispiele, Ausgabeformat und Einschränkungen von `generate_changelog.sh`. Die Optionen stehen im
[README](../README.md) und in `generate_changelog.sh --help`.

## Commit-Typen und Sortierung

Die Typen kommen aus dem [Git-Workflow](dev/workflow.md). Im Changelog werden die Commits innerhalb eines Datums in
dieser Reihenfolge sortiert:

`Add` → `Fix` → `Chg` → `Upd` → `Rem` → `Docs` → `Cfg` → `Fmt` → `Ref` → `Ren` → `Mov` → sonstige

- Commits ohne erkannten Typ stehen am Ende des Datumsblocks bzw. unter „Sonstige“.
- Präfixe aus älteren Historien werden zugeordnet: `Del` → `Rem`, `Mve` → `Mov`, `Ign` → `Cfg`, `Dis` → `Cfg`,
  `TryFix` → `Fix`.
- Alte Schreibweisen werden erkannt: `Fix:`, `Fix;`, `Chg.` und Präfix ohne Doppelpunkt (`Add Kommentare`).
- Die Groß- und Kleinschreibung zählt: `fix:` ist kein Typ.

## Was ausgewertet wird

- **Datum:** das Autordatum. Ein rebaster oder per Cherry-Pick übernommener Commit bleibt an seinem ursprünglichen
  Tag. Datumsgrenzen in `-s`/`-u` beziehen sich ebenfalls auf das Autordatum.
- **Merges:** Merge-Commits werden ausgeblendet, die Commits aus dem Branch erscheinen einzeln.
- **Message:** nur die erste Zeile. Details im Body erscheinen nicht.
- **Links:** aus `remote.origin.url`. SSH- und HTTPS-Adressen werden in die Web-Adresse umgewandelt
  (`git@github.com:owner/repo.git` → `https://github.com/owner/repo`). Ohne Remote steht nur der Hash.

## Quelle und Zeitfenster

`-b` ist die Quelle, also der Branch, aus dessen Historie die Commits kommen. `-s` und `-u` setzen das Fenster
innerhalb dieser Historie.

| Grenze | `-s` (Start) | `-u` (Ende) |
|---|---|---|
| Tag | Tag-Commit ausgeschlossen (Änderungen *seit* dem Release) | Tag-Commit eingeschlossen |
| Datum `JJJJ-MM-TT` | ab 00:00 Uhr des Tages | bis 23:59:59 Uhr des Tages |
| Konstante | `FIRST` = erster Commit (Standard) | `LATEST` = letzter Commit von `-b` (Standard) |

Fehler mit Exit-Code 1:

- `-b` ist kein Branch (z. B. ein Tag): ab einem Tag stattdessen `-s <Tag>` verwenden
- ein Tag liegt nicht in der Historie von `-b`
- `-s` liegt nach `-u`
- unbekannter Wert oder unlesbares Datum

## Beispiele

### Gesamtes Repository

```bash
bash generate_changelog.sh
```

Erzeugt `<repo-root>/CHANGELOG.md` mit allen Commits des aktuellen Branches.

### Bestimmter Branch, seit einem Release

```bash
bash generate_changelog.sh -b development -s v1.0.0 -o docs/CHANGELOG_dev.md
```

Alle Commits auf `development` nach `v1.0.0`. Remote-Branches gehen ebenfalls: `-b origin/development`.

### Zeitraum

```bash
bash generate_changelog.sh -s 2026-01-01 -u 2026-03-31 -o docs/CHANGELOG_Q1.md
```

Der 31.03. ist eingeschlossen.

### Zwischen zwei Tags

```bash
bash generate_changelog.sh -s v1.0.0 -u v1.1.0 -o docs/CHANGELOG_v1.1.md
```

Datum und Tag lassen sich mischen: `-s 2026-01-01 -u v1.1.0`.

### Pfade und Dateiendungen

```bash
bash generate_changelog.sh -p src/player/                 # docs/CHANGELOG_src_player.md
bash generate_changelog.sh -p src/player/ src/enemy/      # docs/CHANGELOG_src_player_src_enemy.md
bash generate_changelog.sh -p src/player/player.gd        # docs/CHANGELOG_src_player_player.md
bash generate_changelog.sh -e gd,tscn                     # docs/CHANGELOG_gd_tscn.md
bash generate_changelog.sh -p src/player/ -e gd           # docs/CHANGELOG_src_player_gd.md
```

Pfade gelten relativ zum Aufrufverzeichnis, der Dateiname wird aus dem Pfad relativ zum Repo-Root gebildet. `-p`
nimmt alle Argumente bis zur nächsten Option, die Reihenfolge der Optionen ist also frei.

### Release-Notes

```bash
bash generate_changelog.sh -r -s v1.0.0 -u v1.1.0         # docs/releases/v1.1.0.md
bash generate_changelog.sh -r -s v1.1.0                   # docs/releases/unreleased.md
bash generate_changelog.sh -r -s v1.0.0 -u v1.1.0 -o -    # auf die Standardausgabe
```

### Titel, Ausgabe und Überschreiben

```bash
bash generate_changelog.sh -t "Release v2.0" -o docs/CHANGELOG_v2.0.md
bash generate_changelog.sh -f                             # vorhandene CHANGELOG.md überschreiben
bash generate_changelog.sh -o - | less
```

Das Ausgabeverzeichnis wird bei Bedarf angelegt. Ohne `-f` bricht das Script ab, wenn die Datei existiert.

## Ausgabeformat

### Changelog

```markdown
# godot-changelog-generator (main)

Die folgenden Einträge wurden automatisch aus der Git-Historie generiert. Die Reihenfolge der Typen ist Add → Fix → Chg → Upd → Rem → Docs → Cfg → Fmt → Ref → Ren → Mov → sonstige.

## 2026-10-18

- Add: Release-Notes mit -r/--release [c66f0b0](https://github.com/owner/repo/commit/c66f0b0)
- Fix: Commit-Links aus SSH-Remote-URLs fehlerhaft [b6e8626](https://github.com/owner/repo/commit/b6e8626)
- Docs: README an die neue Parameterlogik angepasst [3ee6953](https://github.com/owner/repo/commit/3ee6953)
```

Der Changelog zeigt alle Commits, unabhängig von Typ und Release-Trailer.

### Release-Notes

```markdown
## godot-changelog-generator v2.0.0

**Zeitraum:** 2026-10-16 – 2026-10-18 · 3 Änderungen

### Add

- Release-Notes mit -r/--release ([c66f0b0](https://github.com/owner/repo/commit/c66f0b0))

### Fix

- Commit-Links aus SSH-Remote-URLs fehlerhaft ([b6e8626](https://github.com/owner/repo/commit/b6e8626))

### Chg

- Merge-Commits im Changelog ausblenden ([98953d0](https://github.com/owner/repo/commit/98953d0))
```

- Nur die sichtbaren Typen `Add`, `Fix`, `Chg`, `Upd`, `Rem`.
- Der Präfix steht unter der Typ-Überschrift nicht noch einmal im Eintrag.
- Kein Datum je Eintrag, der Zeitraum steht im Kopf. Die Daten je Commit stehen im Changelog.

### Release-Trailer

Mit einem Git-Trailer in der letzten Zeile des Bodys lässt sich der Typ übersteuern:

```text
Fix: Tippfehler im Log-Aufruf

Release: skip
```

- `Release: skip` blendet einen sonst sichtbaren Commit aus.
- `Release: show` nimmt einen sonst internen Commit auf. Ohne erkannten Typ erscheint er unter „Sonstige“.
- Setzen mit `git commit --trailer "Release: skip"`.

## Einschränkungen

- Pfadfilter gelten für den Pfad im jeweiligen Commit. Commits vor einem Verschieben oder Umbenennen fallen heraus,
  z. B. wenn das Projekt später nach `src/` verschoben wurde. `git log --follow` funktioniert nur für einzelne
  Dateien und wird nicht verwendet.
- Ohne Treffer entsteht keine Datei. Es gibt einen Hinweis auf stderr und Exit-Code 0.
