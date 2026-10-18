# Update-Plan – Anpassung an den neuen Git-Workflow

Stand 2026-10-16. Erstellt aus einer Sitzung im Projekt Multiplayer-Template. Dort wurde git-cliff als Ersatz für
dieses Script getestet und verworfen (siehe `Multiplayer-Template/docs/notes/tooling-anpassungen.md`). Stattdessen
wird dieses Script an den neuen Workflow angepasst. Die Datei kann nach der Umsetzung gelöscht werden.

## Ausgangslage

- Repo: `git@github.com:Fox-Alpha/godot-changelog-generator.git`, nur Branch `main`, sauber, Stand `b1e9897`.
- `generate_changelog.sh` (261 Zeilen) ist identisch mit der alten Kopie im Monorepo `godot-tool-sammelsurium`.
- `~/.local/bin/gitchggen` zeigt auf beiden Rechnern noch auf die Kopie im Monorepo (Pfade siehe unten).
- Keine `CLAUDE.md` oder `AGENTS.md`: Die Regeln aus dem neuen Workflow greifen hier noch nicht.
- Commit-Messages bisher auf Englisch, `CHANGELOG.md` im Keep-a-Changelog-Format (Deutsch, Versionen 0.1.0 und 1.0.0).

## Rechner und Pfade

Gearbeitet wird auf zwei Rechnern mit unterschiedlicher Ordnerstruktur. Pfadangaben in diesem Plan
(`Multiplayer-Template/…`) beziehen sich auf den jeweiligen Ordner des Rechners.

| | Rechner mit `~/Projekte` | Rechner `zocker-nix` (`~/Development`) |
|---|---|---|
| dieses Repo | `~/Projekte/ai/godot/godot-changelog-generator` | `~/Development/godot/00.tools/godot-changelog-generator` |
| Multiplayer-Template | `~/Projekte/ai/godot/Multiplayer-Template` | `~/Development/godot/01.featured-projects/multiplayer-template` |
| Ziel von `~/.local/bin/gitchggen` | `~/Projekte/Godot/godot-tool-sammelsurium/changelog_generator/generate_changelog.sh` | `~/Projekte/godot/godot-tool-sammelsurium/changelog_generator/generate_changelog.sh` (Ziel existiert nicht mehr, Link ist tot) |
| git-cliff | `~/.cargo/bin/git-cliff` | nicht installiert |

## Phase 0 – Vorbereitung (vor jeder Code-Änderung)

1. **Anweisungsdatei anlegen:** nur `CLAUDE.md` (entschieden; OpenCode liest sie ebenfalls, per Env-Var oder
   Startparameter) mit:
   - Verweis auf den Git-Workflow: Kopie von `Multiplayer-Template/docs/dev/workflow.md` nach `docs/dev/workflow.md`,
     oben mit Hinweis auf die Quelle (entschieden)
   - Projekteinstellungen: Commit-Sprache Deutsch (entschieden, die englische Historie bleibt), Standardbranch `main`,
     Quellordner (Repo-Wurzel)
   - Antworten und Kommentare auf Deutsch
   - kurze Projektbeschreibung: Bash + eingebettetes Python 3, keine weiteren Abhängigkeiten
2. **Ist-Stand taggen:** `v1.0.0` auf `b1e9897` (entschieden).
3. **Branches:** `development` von `main` abzweigen, darauf `feature/workflow-anpassung` (erledigt am 2026-10-16,
   zusammen mit dem Commit dieses Plans).
4. Die Anweisungsdatei als ersten Commit auf dem Feature-Branch. Danach eine neue Sitzung in diesem Ordner starten,
   damit die Regeln geladen sind.

## Phase 1 – Script anpassen (`generate_changelog.sh`)

Je Punkt ein Commit.

1. **Toten Code entfernen:** Zeilen 163–260 sind eine ältere Kopie hinter dem ersten `exit 0`.
2. **Commit-Links:** Remote-URL umwandeln: `git@github.com:owner/repo.git` → `https://github.com/owner/repo`, auch
   für GitLab und `https://…git`. Im Moment entstehen Links wie `git@github.com:…git/commit/<hash>`.
3. **Typen und Reihenfolge:** Add → Fix → Chg → Upd → Rem → Docs → Cfg → Fmt → Ref → Ren → Mov → Sonstige.
   - alte Präfixe zuordnen: `Del`→Rem, `Mve`→Mov, `Ign`→Cfg, `Dis`→Cfg, `TryFix`→Fix
   - alte Schreibweisen tolerieren: `Fix;`, `Chg.`, `Add Kommentare` (Präfix ohne Doppelpunkt)
   - Kopfzeilentext mit der neuen Reihenfolge
4. **Merges ausblenden:** `--no-merges`.
5. **Nur die erste Zeile der Message:** `%s` fasst bei alten Commits ohne Leerzeile nach dem Betreff den ganzen
   Absatz zusammen. Stattdessen `%B` lesen und die erste Zeile nehmen, Felder mit `%x1f`/`%x1e` trennen statt `|`
   (der Betreff kann `|` enthalten). Den `===`-Workaround entfernen.
6. **Datum:** Autordatum (`%ad`) beibehalten. Commit-Datum würde rebaste Commits dem Tag des Rebase zuordnen.
7. **Bereichslogik korrigieren:**
   - `-b` zusammen mit `-s <Tag>` ergibt im Moment `branch` plus `tag..HEAD`, also auch Commits außerhalb des
     Branches. Richtig: `tag..branch` bzw. `since..until` auf dem Branch.
   - Datum und Tag gemischt (`-s 2026-01-01 -u v1.1.0`) prüfen.
8. **Release-Notes:** neue Option `-r, --release`:
   - nur sichtbare Typen: Add, Fix, Chg, Upd, Rem
   - Trailer per `%(trailers:key=Release,valueonly)` lesen: `skip` blendet aus, `show` nimmt auf (Vorrang vor dem Typ)
   - Gliederung nach Typ, im Kopf Zeitraum (erster bis letzter Tag) und Anzahl der Änderungen, kein Datum je Eintrag
     (Variante B, entschieden). Der Präfix steht unter der Typ-Überschrift nicht noch einmal im Eintrag.
   - der vollständige Changelog bleibt unverändert und zeigt alle Commits
   - Beispiel für das Format (Variante B, echte Commits aus Multiplayer-Template, gekürzt):

     ```markdown
     ## Multiplayer-Template v0.2.0

     **Zeitraum:** 2026-10-12 – 2026-10-14 · 14 Änderungen

     ### Add
     - Umbau-Plan für die Styleguide-Anpassung ([7d3fdea](https://github.com/Fox-Alpha/Multiplayer-Template/commit/7d3fdea))
     - GDScript Styleguide ([f52037e](https://github.com/Fox-Alpha/Multiplayer-Template/commit/f52037e))

     ### Fix
     - Styleguide format_on_save auf true ([7887107](https://github.com/Fox-Alpha/Multiplayer-Template/commit/7887107))

     ### Upd
     - Verweise von doc/ auf docs/ angepasst ([e609cf9](https://github.com/Fox-Alpha/Multiplayer-Template/commit/e609cf9))
     ```

     Verworfen wurden Variante A (zusätzlich Datum je Eintrag) und C (nur Datum je Eintrag, kein Zeitraum). Die Daten
     je Commit stehen im vollständigen Changelog.
9. **Standardausgabe:** `<repo-root>/CHANGELOG.md` statt `docs/CHANGELOG.md`.
10. **Parameterlogik überdenken:** Alle Parameter, ihre Kombinationen und die Ausgabepfade (auch bei `-p`) vorher
    gemeinsam durchsprechen (offene Frage 4). Bekannte Fehler:
    - `-u <Datum>` schließt den genannten Tag aus (`--until=2026-03-31` = 31.03. 00:00 Uhr)
    - `-s <Tag>` ignoriert `-b` (ergibt `branch` plus `tag..HEAD`)
    - `-u <Tag>` ohne `-s` hängt den Tag als zweiten Startpunkt an, mit `-b` vermischen sich zwei Refs
11. **TODO `--help` überarbeiten:** Die Hilfe ist unvollständig und irreführend.
    - `-o` ist relativ zum Aufrufverzeichnis, nicht zum Repo-Root (README behauptet das Gegenteil)
    - Standardtitel bei `-p` ist „Changelog für <Pfad>“, nicht „Pfad“
    - `-p -` wird nicht erklärt
    - fehlt: verwendetes Datum (Autordatum), Umgang mit Merges, keine Datei ohne Treffer, Typ-Reihenfolge

## Parameterkonzept

Grundsatz vom Nutzer: `-b` ist die **Quelle**, also der Branch, aus dessen Historie der Bereich geholt wird. `-s` und
`-u` legen das Zeitfenster innerhalb dieser Historie fest. Liegt eine Grenze nicht in der Historie von `-b`, gibt es
keine Ausgabe (Hinweis auf stderr, keine Datei).

| Parameter | Bedeutung | Werte | Standard |
|---|---|---|---|
| `-b <Branch>` | Quelle | lokaler oder Remote-Branch (`origin/development`) | aktueller Branch, bei detached HEAD `HEAD` |
| `-s <Start>` | Beginn des Fensters | Tag (ausgeschlossen), Datum (eingeschlossen), `FIRST` | `FIRST` (erster Commit) |
| `-u <Ende>` | Ende des Fensters, immer der Endpunkt | Tag, Datum (eingeschlossen, bis 23:59:59), `LATEST` | `LATEST` (letzter Commit von `-b`) |
| `-p <Pfad> [<Pfad> …]` | Filter auf Pfade, nimmt alle Argumente bis zur nächsten Option (beginnt mit `-`) | ein oder mehrere Pfade, durch Leerzeichen getrennt | ganzes Repo |
| `-e <Endungen>` | Filter auf Dateitypen, kombinierbar mit `-p` | kommagetrennt ohne Punkt, z. B. `gd,tscn` | alle |
| `-o <Datei>` | Ausgabedatei, relativ zum Aufrufverzeichnis, `-` = Standardausgabe | Pfad oder `-` | siehe unten |
| `-t <Titel>` | Überschrift | Text | Repo-Name (Branch), bei `-p` zusätzlich die Pfade |
| `-r` | Release-Notes statt vollständigem Changelog | – | aus |
| `-f`, `--force` | vorhandene Ausgabedatei überschreiben | – | aus: Abbruch, wenn die Datei existiert |
| `-V` | Version anzeigen | – | – |
| `-h` | Hilfe | – | – |

Entschieden: `-b` nimmt nur Branches (ab Tag → `-s <Tag>`), `-s`/`-u` haben die Standardwerte `FIRST`/`LATEST`, `-e`
für Dateitypen.

Entschieden am 2026-10-18:
- `-b` nimmt lokale und Remote-Branches, Tags und Commit-Hashes werden mit Fehler abgelehnt. Ohne `-b` bei
  detached HEAD ist die Quelle `HEAD`, der Standardtitel lautet `<Repo> (HEAD)`.
- `-p` nimmt alle folgenden Argumente bis zum nächsten, das mit `-` beginnt, und muss deshalb nicht am Ende stehen:
  `-p src/a src/b -e gd -o x.md`. Pfade, die mit `-` beginnen, gehen mit `./-name`.
- `-r` ist mit `-p`/`-e` kombinierbar, der Filter kommt nach derselben Regel wie beim Changelog in den Dateinamen
  (siehe Ausgabepfade).
- Die Detailregeln unten gelten wie vorgeschlagen.

Ausgabepfade:
- vollständiger Changelog: `<repo-root>/CHANGELOG.md`
- mit `-p`: `<repo-root>/docs/CHANGELOG_<pfade>.md`, Pfad mit `_` statt `/`, Dateiendung entfällt, z. B.
  `src/player/` → `docs/CHANGELOG_src_player.md`, `src/player/player.gd` → `docs/CHANGELOG_src_player_player.md`,
  mehrere Pfade aneinandergehängt
- mit `-e`: Endungen angehängt, z. B. `-p src/scenes/player/ -e gd` → `docs/CHANGELOG_src_scenes_player_gd.md`,
  nur `-e gd,tscn` → `docs/CHANGELOG_gd_tscn.md`
- Release-Notes (`-r`): `<repo-root>/docs/releases/<Version>.md`, Version aus `-u`, wenn es ein Tag ist, sonst
  `unreleased.md`. Mit `-p`/`-e` wird der Filter angehängt, z. B. `docs/releases/v2.0.0_src_player_gd.md`,
  `docs/releases/unreleased_gd.md`

Detailregeln (entschieden am 2026-10-18):
- `-s <Tag>` schließt den Tag-Commit aus (Änderungen *seit* dem Release), `-u <Tag>` schließt ihn ein.
- `-s <Datum>` und `-u <Datum>` schließen den Tag ein (00:00:00 bis 23:59:59 Ortszeit).
- `-s` nach `-u` oder eine Grenze, die nicht in der Historie von `-b` liegt: Hinweis auf stderr, keine Datei,
  Exit-Code ungleich 0.
- Keine Treffer: Hinweis auf stderr, keine Datei, Exit-Code 0.
- Unbekannte Konstante oder unlesbares Datum: Fehler mit Hinweis auf `--help`.
- Standardtitel: `<Repo> (<Branch>)`, mit `-p`/`-e` ergänzt um die Filter, bei `-r` um die Version.
- Version des Tools als Konstante im Script, ausgegeben von `-V`.
- Überschreibschutz (entschieden): Existiert die Ausgabedatei, bricht das Script ohne `-f` mit Hinweis ab
  (Exit-Code ungleich 0). Gilt nicht für `-o -`.
- Zusätze im Commit-Body beginnen nach dem neuen Workflow mit `-` (Markdown-Liste) statt `===:`. Das Script wertet
  weiterhin nur die erste Zeile aus; alte `===:`-Commits brauchen keine Sonderbehandlung mehr.

Umsetzung der Filter über Git-Pathspecs: `-e gd -p src/x/` → `':(glob)src/x/**/*.gd'`. Getestet im
Multiplayer-Template: `*.gd` 163 Commits, `*.gd *.tscn` 192, `src/scenes/player/*.gd` 15.

Einschränkung für `--help`: Pfadfilter greifen auf den Pfad im jeweiligen Commit. Commits vor einem Verschieben oder
Umbenennen fallen heraus (im Multiplayer-Template: `src/**/*.gd` 63 statt 163, weil das Projekt nach `src/` verschoben
wurde). `--follow` gibt es nur für einzelne Dateien.

Entfällt: `-p -` (der Fall „Gesamt-Repo mit eigenem `-o`“ geht schon ohne `-p`).

## Phase 2 – Doku

- `README.md` und `docs/usage.md`: Typen, Reihenfolge, neue Option `--release`, Ausgabepfad, Trailer.
- `CHANGELOG.md` des Tools mit dem angepassten Tool neu erzeugen (ersetzt die veraltete Fassung von Hand).

## Phase 3 – Test

Nur lesend gegen das Repo Multiplayer-Template, Ausgaben in den Scratchpad:

- Branch `development`: 272 Einträge ohne Merges, 25 Datumsabschnitte (Stand `94916b5`; neuere Commits erhöhen die
  Zahl).
- Referenzausgabe aus git-cliff auf Branch `feature/git-cliff` des Multiplayer-Templates:
  `~/.cargo/bin/git-cliff -o <scratchpad>/ref.md`. Einträge, Gruppierung und Links vergleichen.
  Installation auf einem Rechner ohne git-cliff (Ubuntu-rustc 1.85 ist zu alt, git-cliff braucht 1.88+): vorhandene
  rustup-Toolchain aktualisieren (`rustup update stable`), dann mit ihr bauen:
  `TC=~/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin; RUSTC="$TC/rustc" "$TC/cargo" install git-cliff --locked`.
  `rustup run stable cargo …` reicht nicht, cargo greift dann trotzdem auf das System-rustc zurück.
- Sonderfälle in der Historie: `Fix;`, `Chg.`, `Add Kommentare`, `===:`-Commits, `initial commit`, Commit ohne Präfix
  (`Sichtbarkeit auf der Minimap angepasst`).
- Bereiche: `-b development -s Godot_Engine_4.6_beta_1` muss dieselben Commits liefern wie
  `git log --no-merges Godot_Engine_4.6_beta_1..development` (git-cliff: 98).
- Trailer nur in einer Wegwerf-Kopie mit Test-Commits prüfen (`git clone` in den Scratchpad, `--allow-empty`,
  `--trailer "Release: skip"` usw.), nie im echten Repo.
- Dieses Repo selbst: Ausgabe mit englischen Messages und ohne Remote-Links (Fallback ohne Remote).

Stand 2026-10-18 (Rechner `zocker-nix`, Template-Branch `development`):
- erledigt: 275 Einträge = `git log --no-merges`, 27 Datumsabschnitte, Sonderfälle erkannt, Links korrekt;
  Bereiche `-s`/`-u` mit Tags und Datum, `-e`, `-p` mit `-e` stimmen mit `git log` überein (z. B.
  `-s Godot_Engine_4.6_beta_1`: 101); Trailer, Fehlerfälle und Ausgabepfade in Wegwerf-Repos geprüft
- übersprungen: Vergleich mit git-cliff (auf `zocker-nix` nicht installiert). Ob er noch nötig ist, ist offen;
  bei Bedarf auf dem Rechner mit `~/Projekte` nachholen.

## Phase 4 – Abschluss

- Merge `feature/workflow-anpassung` → `development` → `main` nur nach Freigabe, Versions-Tag setzen.
  - erledigt 2026-10-18: Merge nach `development` (`768f0d5`, lokal), Feature-Branch lokal und auf dem Remote
    gelöscht
  - offen: `CHANGELOG.md` neu erzeugen, Merge nach `main`, Tag `v2.0.0`, danach `development`, `main` und Tag
    pushen (nötig für den zweiten Rechner)
- `~/.local/bin/gitchggen` umstellen (Freigabe nötig, auf dem zweiten PC ebenfalls). Ziel noch offen, wird ganz am
  Ende entschieden. Vorschlag: nicht direkt ins Repo zeigen (bricht bei Branch-Wechseln und halbfertigen Ständen),
  sondern auf einen eigenen Ordner für freigegebene Tool-Versionen, z. B. `~/.local/lib/tools/`, in den der
  getaggte Stand kopiert wird.
- Im Multiplayer-Template: Branch `feature/git-cliff` löschen, `CHANGELOG.md` neu erzeugen und committen,
  Notiz in `docs/notes/tooling-anpassungen.md` abschließen. `feature/git-cliff` erst löschen, wenn feststeht, dass
  der git-cliff-Vergleich (Phase 3) entfällt, der Branch ist dafür die Referenz.

## Entscheidungen und offene Fragen

1. **Git-Workflow:** entschieden – Kopie ins Repo nach `docs/dev/workflow.md` mit Hinweis auf die Quelle.
2. **Commit-Sprache:** entschieden – ab jetzt Deutsch.
3. **Release-Notes:** entschieden – nach Typ gruppiert, Zeitraum und Anzahl im Kopf, kein Datum je Eintrag (Variante B).
   Das vollständige Changelog enthält die Daten.
4. **Parameter und Ausgabepfade:** entschieden am 2026-10-18, siehe Abschnitt „Parameterkonzept“.
5. **Versionen:** entschieden – den Ist-Stand (`b1e9897`) vor Beginn taggen, nach den Änderungen einen neuen Tag.
   Die vorhandene `CHANGELOG.md` des Tools ist veraltet (Keep-a-Changelog-Format von Hand, keine Präfixe aus der
   Historie, Versionen ohne Tags). Sie wird nach der Anpassung mit dem Tool selbst neu erzeugt.
   Entschieden: Ist-Stand `v1.0.0`, Ziel `v2.0.0` (Major: Ausgabepfad, Format und Parameterlogik ändern sich).
