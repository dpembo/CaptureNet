#!/usr/bin/env bash
#
# package-resourcepack.sh
#
# Zips the CaptureNet/Safari Net resource pack (pack.mcmeta at the zip root,
# not the folder itself) and prints its SHA-1, which you'll need for
# config.yml's ResourcePack.url / ResourcePack.sha1.
#
# Usage:
#   ./package-resourcepack.sh
#   ./package-resourcepack.sh /path/to/destination/dir
#   ./package-resourcepack.sh /path/to/destination/safari_net_pack.zip
#
# If a destination is given and it's an existing directory, the zip is copied
# into it under its default name. If it looks like a file path (ends in .zip,
# or its parent directory exists), it's copied to that exact path.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_DIR="${SCRIPT_DIR}/resourcepack"
OUT_NAME="safari_net_pack.zip"
BUILD_DIR="${SCRIPT_DIR}/build"
OUT_ZIP="${BUILD_DIR}/${OUT_NAME}"

DEST="${1:-}"

if [[ ! -d "$PACK_DIR" ]]; then
    echo "Error: resource pack folder not found at: $PACK_DIR" >&2
    exit 1
fi

if [[ ! -f "$PACK_DIR/pack.mcmeta" ]]; then
    echo "Error: $PACK_DIR/pack.mcmeta not found — is this the right folder?" >&2
    exit 1
fi

TEXTURE_PATH="$PACK_DIR/assets/minecraft/textures/item/safari_net.png"
if [[ ! -f "$TEXTURE_PATH" ]]; then
    echo "Warning: safari_net.png not found at $TEXTURE_PATH" >&2
    echo "         The pack will build, but the reskin will be missing its texture." >&2
fi

command -v zip >/dev/null 2>&1 || { echo "Error: 'zip' is not installed." >&2; exit 1; }

mkdir -p "$BUILD_DIR"
rm -f "$OUT_ZIP"

echo "Packaging resource pack from: $PACK_DIR"
(
    cd "$PACK_DIR"
    zip -r -X "$OUT_ZIP" . -x "*.DS_Store" -x "README.md" >/dev/null
)

if [[ ! -f "$OUT_ZIP" ]]; then
    echo "Error: zip creation failed." >&2
    exit 1
fi

# Cross-platform SHA-1 (Linux: sha1sum, macOS: shasum -a 1)
if command -v sha1sum >/dev/null 2>&1; then
    SHA1="$(sha1sum "$OUT_ZIP" | awk '{print $1}')"
elif command -v shasum >/dev/null 2>&1; then
    SHA1="$(shasum -a 1 "$OUT_ZIP" | awk '{print $1}')"
else
    echo "Error: neither 'sha1sum' nor 'shasum' is available to hash the zip." >&2
    exit 1
fi

FINAL_PATH="$OUT_ZIP"

if [[ -n "$DEST" ]]; then
    if [[ -d "$DEST" ]]; then
        cp "$OUT_ZIP" "$DEST/$OUT_NAME"
        FINAL_PATH="$DEST/$OUT_NAME"
    else
        DEST_PARENT="$(dirname "$DEST")"
        if [[ -d "$DEST_PARENT" ]]; then
            cp "$OUT_ZIP" "$DEST"
            FINAL_PATH="$DEST"
        else
            echo "Error: destination '$DEST' is not an existing directory, and its parent" >&2
            echo "       directory '$DEST_PARENT' doesn't exist either." >&2
            exit 1
        fi
    fi
fi

echo
echo "Done."
echo "  Package: $FINAL_PATH"
echo "  SHA-1:   $SHA1"
echo
echo "Update config.yml:"
echo "  ResourcePack:"
echo "    enabled: true"
echo "    url: \"https://<your-host>/<path-to>/${OUT_NAME}\""
echo "    sha1: \"${SHA1}\""
