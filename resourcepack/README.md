# Safari Net resource pack

Reskins the CaptureNet "catch item" (a `minecraft:snowball` with
`custom_model_data: 1`, as set in `config.yml`) from the default vanilla
snowball into a woven net bundle, so it reads as a Safari Net rather than a
Poké Ball.

## What's inside

- `assets/minecraft/items/snowball.json` — modern (1.21.4+) item definition;
  dispatches to the Safari Net model when `custom_model_data` is `1`, falls
  back to the vanilla snowball model otherwise.
- `assets/minecraft/models/item/snowball.json` — legacy predicate-override
  equivalent, kept only for compatibility with pre-1.21.4 clients/servers.
- `assets/minecraft/models/item/safari_net.json` — the actual model
  (single flat texture, same render style as the vanilla snowball).
- `assets/minecraft/textures/item/safari_net.png` — 16x16 placeholder
  texture (a tan woven net bundle with a drawstring knot). Swap this file
  for your own art any time — nothing else needs to change.

## Packaging

Zip the *contents* of this folder (not the folder itself) so `pack.mcmeta`
sits at the root of the zip:

```
cd resourcepack
zip -r ../safari_net_pack.zip .
```

## Deploying it

Host `safari_net_pack.zip` somewhere reachable over HTTPS (your nginx setup
can serve it as a static file), then compute its hash:

```
sha1sum safari_net_pack.zip
```

**Option A — let the plugin push it (recommended):** set these in
`config.yml` and the plugin will send the pack to every player on join:

```yaml
ResourcePack:
    enabled: true
    url: "https://your-host/safari_net_pack.zip"
    sha1: "<sha1sum output>"
    prompt: "&aThis server uses a Safari Net resource pack for the catch item!"
    force: false
```

**Option B — server.properties:** if you'd rather Paper handle it directly
(and don't need the plugin's join-time push), set instead:
```
resource-pack=https://your-host/safari_net_pack.zip
resource-pack-sha1=<sha1sum output>
require-resource-pack=false
```

Don't enable both at once — that'll prompt players twice.

Bump `pack.mcmeta`'s `min_format`/`max_format` if you're troubleshooting on
a specific client version — check the exact numbers for your version with
`/version` or F3+V in-game.
