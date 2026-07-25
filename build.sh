#!/usr/bin/env bash
#
# build.sh - Build the CaptureNet (CatchBall) plugin jar via Gradle.
#
# Usage:
#   ./build.sh                # run from inside the repo
#   ./build.sh /path/to/CaptureNet
#   ./build.sh /path/to/CaptureNet --stacktrace   # extra args are passed to gradlew
#
# Optional env vars:
#   OUTPUT_DIR   If set, the built jar is copied here after a successful build.

set -euo pipefail

REPO_DIR="."
if [ $# -gt 0 ] && [ -d "$1" ]; then
    REPO_DIR="$1"
    shift
fi
REPO_DIR="$(cd "$REPO_DIR" && pwd)"

if [ ! -f "$REPO_DIR/gradlew" ]; then
    echo "error: no gradlew found in $REPO_DIR (expected the CaptureNet repo root)" >&2
    exit 1
fi

if ! command -v java >/dev/null 2>&1; then
    echo "error: java not found on PATH. This project needs JDK 21." >&2
    exit 1
fi

JAVA_VERSION="$(java -version 2>&1 | head -1 | grep -oE '"[0-9]+' | tr -d '"' || true)"
if [ -n "$JAVA_VERSION" ] && [ "$JAVA_VERSION" -lt 21 ]; then
    echo "warning: detected Java $JAVA_VERSION, but this project targets Java 21 (java.sourceCompatibility in build.gradle.kts). Build may fail." >&2
fi

cd "$REPO_DIR"
chmod +x ./gradlew

echo "==> Building CatchBall shadow jar with Gradle in $REPO_DIR"
./gradlew clean shadowJar --no-daemon "$@"

JAR_DIR="$REPO_DIR/build/libs"
JAR_FILE="$(find "$JAR_DIR" -maxdepth 1 -name '*.jar' ! -name '*-original.jar' 2>/dev/null | sort | tail -1)"

if [ -z "$JAR_FILE" ]; then
    echo "error: build finished but no shaded jar was found in $JAR_DIR" >&2
    exit 1
fi

echo "==> Build succeeded:"
echo "    $JAR_FILE"

if [ -n "${OUTPUT_DIR:-}" ]; then
    mkdir -p "$OUTPUT_DIR"
    cp "$JAR_FILE" "$OUTPUT_DIR/"
    echo "==> Copied to:"
    echo "    $OUTPUT_DIR/$(basename "$JAR_FILE")"
fi
