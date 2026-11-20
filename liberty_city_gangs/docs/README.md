# liberty_city_gangs (foundation)

Independent Liberty City-only mafia/gangs resource scaffold.

## Status
- **Foundation implementation**: DB schema, faction/rank/permission config, server-authoritative core stubs/modules, basic HQ/territory/vehicle data structures.
- **Not fully completed/tested in-game** in this pass. All placements, buildings/interiors, fleets, UI flows, balance, and security require in-game/Debugscript verification.

## Constraints followed
- Liberty City only (no San Andreas coordinates intended).
- Uses existing systems (`ng-database`, `ng-economy`, `ng-inventory`, character identity via `char.id`).
- HQ exterior anchors chosen from real LC map building objects/positions where identified; entrances/interiors require probe/verification and may need adjustment.
- No invented external assets/links. Reuse existing server assets/resources where possible.

## TODO / verification required
- Probe and adjust HQ entrance/garage/interior coordinates in-game (`/lcprobe`, audit tools).
- Confirm real visible exterior buildings and safe entry/exit flows.
- Implement/validate full luxury DX UI (AR/EN/PT), per-faction activities, complete territory capture logic, and full vehicle garage persistence/locking integration.
- Run security tests (server-side validation, anti-duplication/exploit checks) and RP/gameplay tests.
- Add to `mtaserver.conf` and restart resource after review.
