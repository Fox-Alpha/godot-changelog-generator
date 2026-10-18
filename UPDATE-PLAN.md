# Update-Plan – offene Punkte

Die Anpassung an den neuen Git-Workflow ist mit v2.0.0 abgeschlossen (2026-10-18). Hier stehen nur noch die offenen
Punkte. Den vollständigen Plan mit Parameterkonzept und Entscheidungen enthält die Git-Historie dieser Datei
(`git log -p -- UPDATE-PLAN.md`, Stand `9ceabc1`). Die Datei wird gelöscht, wenn alle Punkte erledigt sind.

## Rechner und Pfade

Gearbeitet wird auf zwei Rechnern mit unterschiedlicher Ordnerstruktur.

| | Rechner mit `~/Projekte` | Rechner `zocker-nix` (`~/Development`) |
|---|---|---|
| dieses Repo | `~/Projekte/ai/godot/godot-changelog-generator` | `~/Development/godot/00.tools/godot-changelog-generator` |
| Multiplayer-Template | `~/Projekte/ai/godot/Multiplayer-Template` | `~/Development/godot/01.featured-projects/multiplayer-template` |
| Befehl `git-chlog` | noch alter Link `~/.local/bin/gitchggen` → `~/Projekte/Godot/godot-tool-sammelsurium/changelog_generator/generate_changelog.sh` | eingerichtet am 2026-10-18 (v2.1.0) |
| git-cliff | `~/.cargo/bin/git-cliff` | nicht installiert |

## Offen

1. **Befehl `git-chlog` auf dem Rechner mit `~/Projekte` einrichten** (auf `zocker-nix` erledigt). Das Tool liegt
   in einem eigenen Ordner für freigegebene Versionen, nicht direkt im Repo:

   ```bash
   mkdir -p ~/.local/lib/tools/changelog-generator
   git -C <repo> show v2.1.0:generate_changelog.sh > ~/.local/lib/tools/changelog-generator/generate_changelog.sh
   chmod 755 ~/.local/lib/tools/changelog-generator/generate_changelog.sh
   ln -s ~/.local/lib/tools/changelog-generator/generate_changelog.sh ~/.local/bin/git-chlog
   ```

   Danach den alten Link `~/.local/bin/gitchggen` entfernen. Aufruf als `git chlog …`, Hilfe mit `git chlog -h`
   (`git chlog --help` sucht eine Manpage). Bei einem neuen Release die Kopie aus dem neuen Tag erneuern.
2. **Multiplayer-Template aufräumen:**
   - die Änderungen an `CLAUDE.md` und `docs/dev/workflow.md` (Release-Trailer) auf einem eigenen Branch committen
   - Branch `feature/git-cliff` löschen (nur noch auf dem Remote). Der Vergleich mit git-cliff entfällt, entschieden
     am 2026-10-18.
   - entscheiden, ob das Template eine `CHANGELOG.md` bekommt (bisher keine vorhanden), dann mit `git chlog` erzeugen
   - `docs/notes/tooling-anpassungen.md` abschließen: Changelog-Tool mit v2.0.0/v2.1.0 umgesetzt, git-cliff
     endgültig verworfen

## Testvorgehen

Nur lesend gegen das Multiplayer-Template, Ausgaben in den Scratchpad (`-o`), Schreibtests nur in Wegwerf-Klonen.
Zum Abgleich `git log --no-merges` mit denselben Grenzen und Pathspecs, Stand 2026-10-18 auf `development`:
275 Einträge, 27 Datumsabschnitte, `-s Godot_Engine_4.6_beta_1`: 101, `-e gd`: 163.
