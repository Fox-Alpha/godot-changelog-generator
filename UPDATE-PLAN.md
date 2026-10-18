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
| Ziel von `~/.local/bin/gitchggen` | `~/Projekte/Godot/godot-tool-sammelsurium/changelog_generator/generate_changelog.sh` | `~/Projekte/godot/godot-tool-sammelsurium/changelog_generator/generate_changelog.sh` (Ziel existiert nicht mehr, Link ist tot) |
| git-cliff | `~/.cargo/bin/git-cliff` | nicht installiert |

## Offen

1. **`~/.local/bin/gitchggen` umstellen**, auf beiden Rechnern (Freigabe nötig). Ziel noch offen. Vorschlag: nicht
   direkt ins Repo zeigen (bricht bei Branch-Wechseln und halbfertigen Ständen), sondern auf einen eigenen Ordner
   für freigegebene Tool-Versionen, z. B. `~/.local/lib/tools/`, in den der Stand eines Release-Tags kopiert wird.
2. **Vergleich mit git-cliff:** auf `zocker-nix` übersprungen, ob er noch nötig ist, ist offen. Bei Bedarf auf dem
   Rechner mit `~/Projekte` gegen den Branch `feature/git-cliff` des Multiplayer-Templates:
   `~/.cargo/bin/git-cliff -o <scratchpad>/ref.md`, Einträge, Gruppierung und Links vergleichen.
   Installation ohne git-cliff (Ubuntu-rustc 1.85 ist zu alt, git-cliff braucht 1.88+): `rustup update stable`,
   dann `TC=~/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin; RUSTC="$TC/rustc" "$TC/cargo" install git-cliff --locked`.
   `rustup run stable cargo …` reicht nicht, cargo greift dann auf das System-rustc zurück.
3. **Multiplayer-Template aufräumen:** `CHANGELOG.md` mit dem neuen Tool erzeugen und committen, Notiz in
   `docs/notes/tooling-anpassungen.md` abschließen. Branch `feature/git-cliff` erst löschen, wenn Punkt 2 entfällt,
   er ist die Referenz für den Vergleich.

## Testvorgehen

Nur lesend gegen das Multiplayer-Template, Ausgaben in den Scratchpad (`-o`), Schreibtests nur in Wegwerf-Klonen.
Zum Abgleich `git log --no-merges` mit denselben Grenzen und Pathspecs, Stand 2026-10-18 auf `development`:
275 Einträge, 27 Datumsabschnitte, `-s Godot_Engine_4.6_beta_1`: 101, `-e gd`: 163.
