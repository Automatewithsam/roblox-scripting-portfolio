# Admin Panel

A role-based admin command system. Commands are parsed server-side, permission-checked against a rank table, and executed through a small, extensible command registry.

## Structure

- `AdminService.lua` (ServerScriptService) — permission checks, command registry, and execution.
- `AdminCommands.lua` (ServerScriptService) — the actual command implementations (kick, teleport, give item, etc.), kept separate from the permission/dispatch logic.
- `AdminRemotes.lua` (ReplicatedStorage) — remote definitions.

## Key Design Points

- **Permissions checked on every single command**, not just when opening the panel — prevents a client from caching a stale "I have access" state and firing privileged commands later.
- **Command registry pattern.** Adding a new admin command means writing one function and registering it — no touching the dispatch/permission logic.
- **Rank tiers**, not a flat admin/non-admin boolean, so e.g. moderators can kick but not grant items.
