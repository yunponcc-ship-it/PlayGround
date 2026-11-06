# Neon Breakout

A complete, self-contained Roblox parkour / data-heist mini-game built as a Rojo place. It lives alongside the Cmdr framework without changing the existing package project.

## Run it

From the repository root, build a place with Rojo:

```sh
rojo build neon-breakout.project.json -o NeonBreakout.rbxlx
```

Open the resulting place in Roblox Studio and press **Play**. The server script builds the full neon city course at runtime; no external assets are required.

## Play

- Traverse the floating rooftops and gather all **10 data shards**.
- Hold **E** (or use the proximity prompt) to breach each of the **3 network relays**.
- Use **Shift** to glitch-dash across gaps and **Q** to pulse-stun nearby sentinels. Both abilities spend regenerating energy.
- Avoid sentinels, reach the escape beacon, and press **Run it back** after winning to reset your route.
- Standard Roblox movement works on keyboard, controller, and mobile; the ability buttons are clickable/touch-friendly.

Progress, pickups, relay activation, ability costs/cooldowns, and sentinel hits are validated on the server. Abilities are designed as fictional mechanics within this game, not as tools for manipulating other Roblox experiences.
