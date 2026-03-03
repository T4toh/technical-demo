# Copilot Instructions

## Project

Godot 4.6 technical demo. The main scene is `party_screen.tscn` (a `Control`-based UI scene).

## Architecture

- **`Character` (`character.gd`)** — `Resource` subclass representing a single party member. Exported fields (`name`, `max_hp`, `attack`, `defense`) are meant to be set via the Godot Inspector or code. `current_hp` is runtime state initialized in `_init()`.
- **`Party` (`party.gd`)** — `Resource` subclass holding an `Array[Character]`. Manages membership and filters alive members.
- **`scripts/party_screen.gd`** — `Control` node script (main scene entry point). Instantiates `Party` and `Character` at runtime and drives the UI.

## Key Conventions

- Data models (`Character`, `Party`) extend `Resource`, not `Node` — they are not added to the scene tree.
- Scene node references use `$NodePath` shorthand (e.g., `$VBoxContainer/Label`).
- Damage formula: `max(amount - defense, 0)` — defense fully absorbs up to its value.
- Physics engine is **Jolt Physics** (not the default Godot physics).
- Renderer is configured for **Forward Plus** with D3D12 on Windows.
