<body>
  <div style="text-align: center;">
    <img src="https://github.com/NUTT1101/CatchBall/assets/95519633/320e05cc-55cf-4623-93e7-498578462ec9" alt="Plugin icon"width="150" height="150">
  </div>
</body>

# CaptureNet

CaptureNet is a fork of [MagicTeaMC/CatchBall2](https://github.com/MagicTeaMC/CatchBall2),
reskinned as a Safari Net-themed capture item instead of the original
Poké Ball style catch item.

## Download:
This is a customized fork, not the original release. Grab a build from
this repo's [Releases](https://github.com/dpembo/CaptureNet/releases),
or build it yourself (see below). For the unmodified upstream plugin,
see [Modrinth](https://modrinth.com/plugin/catchball).

## Building:
- Gradle: `./gradlew shadowJar` (or use `build-gradle.sh`)
- Maven: `mvn clean package`

## Usage:
Core mechanics are unchanged from upstream, so the original
[Wiki](https://github.com/MagicTeaMC/CatchBall2/wiki) still applies.

## Support plugins:
- Residence
- GriefPrevention
- Lands
- RedProtect
- SimpleClaimSystem
- MythicMobs
- PlaceholderAPI

## Language:
- English(Default)
- ChineseTW(繁體中文)
- Custom at `./CaptureNet/locale/`

## Safari Net look:
This fork reskins the catch item as a Safari Net instead of the default
snowball look. See [`resourcepack/`](resourcepack) for the resource pack
and deployment instructions, and `customModelData` / `ResourcePack` in
`config.yml` to configure it.
