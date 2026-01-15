# Progress

## Phase 1: Core Foundation ✅
- Projektstruktur, Vehicle mit Arcade-Steuerung, Teststrecke, Kollisionen

## Phase 2: Multiplayer Local ✅
- Input für 2 Spieler (WASD + Pfeiltasten), Controller-Support vorbereitet
- Out-of-Bounds System, Rundensystem, HUD
- **Score-System**: Punkte werden vergeben wenn ein Spieler Out-of-Bounds geht (alle anderen bekommen +1)

## 3D-Umbau ✅
**Kompletter Umbau von 2D auf 3D für "Wrecked"-Style geneigte Kamera-Perspektive**

### 3D Auto-Modell ✅
- **Doge-Car**: GLB-Modell aus Car-Demo Projekt integriert
- Body: `assets/models/doge/doge-body.glb`
- 4 Räder: `assets/models/doge/Wheel.glb` (WheelFL, WheelFR, WheelRL, WheelRR)

### Sprung-Physik ✅
- Gravitation und vertikale Velocity implementiert
- Rampen-Erkennung via `get_floor_normal()`
- Kicker/Rampe auf Teststrecke zum Testen

### Zentrale Konfiguration ✅
- **GameConfig Resource** als Single Source of Truth
- Alle Spielparameter in `resources/game_config.tres`
- Zugriff über `GameManager.config`

## Konfiguration (game_config.tres)
```
player_count: 2
max_rounds: 5
max_lives: 3

Camera:
  default_height: 25
  min_height: 25
  max_height: 100
  smooth_speed: 4.0
  height_smooth_speed: 8.0

Gameplay:
  out_of_bounds_margin: 15

Vehicle Physics:
  max_speed: 40
  acceleration: 60
  brake_power: 80
  gravity: 40
```

## Wichtige Dateien:

| Datei | Beschreibung |
|-------|--------------|
| `resources/game_config.tres` | Zentrale Konfiguration (Single Source of Truth) |
| `scripts/autoload/game_config.gd` | GameConfig Resource-Klasse |
| `scripts/autoload/game_manager.gd` | Lädt Config, verwaltet Spielzustand |
| `scripts/game.gd` | Hauptspiellogik, Out-of-Bounds, Score-Vergabe |
| `scripts/race/race_tracker.gd` | Position-Tracking mit Path3D/Curve3D |
| `scripts/vehicles/vehicle.gd` | CharacterBody3D, Sprung-Physik |
| `scripts/vehicles/dynamic_camera.gd` | Wrecked-Style Kamera, dynamischer Zoom |
| `scripts/ui/hud.gd` | HUD mit Score, Leben, Platzierung |
| `scenes/vehicles/vehicle.tscn` | Doge-Car mit 4 Rädern |
| `scenes/tracks/test_track.tscn` | 3D-Strecke mit Kicker |

## Nächste Phase: 3 - Combat System
- Power-up Spawner auf der Strecke
- Waffen-System (Raketen, Boost, Schild, Mine)
- Treffer-Feedback und Effekte
