Lies CLAUDE.md und progress.md und mach weiter wo du aufgehört hast.
Regeln:
- Vor dem Coden: Lies nur die relevanten Dateien für die aktuelle Aufgabe
- Nach jeder abgeschlossenen Phase: Update progress.md
- Halte progress.md kompakt um das kontext fenster klein zu halten

# Project: Top-Down Combat Racing Game (Godot 4)

## Vision
Inoffizieller spiritueller Nachfolger von "Wrecked: Revenge Revisited" – ein chaotisches Top-Down-Arcade-Rennspiel mit lokalem Multiplayer für 2-4 Spieler. Zielplattform: Steam (Windows, Mac, Linux).

## Tech Stack
- **Engine**: Godot 4.3+
- **Sprache**: GDScript
- **Steam-Integration**: GodotSteam Plugin (später)

## Core Gameplay
- Top-Down-Perspektive mit dynamischer Kamera, die allen Spielern folgt
- Arcade-Physik (kein Sim-Racing)
- Waffen und Power-ups auf der Strecke
- "Last Man Standing": Wer vom Bildschirm fällt, verliert ein Leben
- Runden-basiertes Punktesystem

---

## Entwicklungsphasen

### Phase 1: Core Foundation
- [ ] Godot 4 Projektstruktur aufsetzen
- [ ] Fahrzeug-Scene mit Arcade-Steuerung (Beschleunigen, Bremsen, Lenken)
- [ ] Top-Down-Kamera die dem Spieler folgt
- [ ] Einfache Teststrecke (rechteckig mit Begrenzungen)
- [ ] Kollisionserkennung mit Wänden

### Phase 2: Multiplayer Local
- [ ] Input-System für 2-4 Spieler (Keyboard + Controller)
- [ ] Dynamische Kamera die ALLE Spieler im Bild hält (zoom out wenn nötig)
- [ ] Spieler-Spawn-System
- [ ] Out-of-Bounds-Erkennung (wer vom Bildschirm fällt, verliert Leben)
- [ ] Einfaches Rundensystem mit Punktestand

### Phase 3: Combat System
- [ ] Power-up Spawner auf der Strecke
- [ ] Waffen-System (Raketen, Boost, Schild, Mine)
- [ ] Waffen-Inventar (1 Waffe gleichzeitig)
- [ ] Treffer-Feedback und Effekte
- [ ] Respawn nach Zerstörung

### Phase 4: Polish & Juice
- [ ] Partikeleffekte (Drift-Rauch, Explosionen)
- [ ] Screen-Shake bei Treffern
- [ ] Sound-Effekte (Motor, Waffen, Kollisionen)
- [ ] Musik-System
- [ ] UI: Hauptmenü, Spielerauswahl, Pause, Ergebnisbildschirm

### Phase 5: Content
- [ ] 3-5 verschiedene Strecken mit unterschiedlichen Themes
- [ ] 4+ verschiedene Fahrzeugtypen (kosmetisch oder mit Stats)
- [ ] Verschiedene Spielmodi (Classic, Last Man Standing, Time Attack)

### Phase 6: Steam Release
- [ ] GodotSteam Integration
- [ ] Achievements definieren und implementieren
- [ ] Steam Store Page Assets
- [ ] Export Builds für Windows/Mac/Linux
- [ ] Steam-Testing und Release

---

## Architektur-Richtlinien

### Ordnerstruktur
```
project/
├── scenes/
│   ├── vehicles/
│   ├── weapons/
│   ├── powerups/
│   ├── tracks/
│   └── ui/
├── scripts/
│   ├── autoload/        # Singletons (GameManager, InputManager)
│   ├── vehicles/
│   ├── weapons/
│   └── utils/
├── assets/
│   ├── sprites/
│   ├── audio/
│   └── fonts/
└── resources/           # .tres Dateien für Configs
```

### Code-Konventionen
- GDScript Style Guide folgen
- Singletons für globalen State (GameManager, AudioManager)
- Signals für lose Kopplung zwischen Systemen
- Ressourcen (.tres) für Fahrzeug-/Waffen-Stats

### Wichtige Scenes
- `Main.tscn` - Entry Point, lädt Menü oder Spiel
- `Game.tscn` - Die eigentliche Spielszene
- `Vehicle.tscn` - Basis-Fahrzeug (instanziert pro Spieler)
- `DynamicCamera.tscn` - Kamera die allen folgt

---

## Aktueller Fokus
**Phase 1 starten**: Fahrzeug-Prototyp mit Arcade-Steuerung bauen.

## Notizen
- Placeholder-Grafiken sind OK, erst später polishen
- Immer testbar halten – jede Phase soll spielbar sein
- Controller-Support von Anfang an mitdenken
