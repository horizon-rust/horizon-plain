#!/usr/bin/env bash
# Builds Horizon without its extras from one tag of horizon-rust/horizon:
#   ./build.sh <tag> [cargo target]
# The source goes to ./horizon (a fresh shallow clone of that tag), the programs to
# ./horizon/target[/<target>]/release. Exit code 3: the tag has no `horizon-extras` feature yet.
set -euo pipefail

tag="${1:?usage: build.sh <horizon tag> [cargo target]}"
target="${2:-}"
src="horizon"

if [[ -e "$src" ]]; then
  echo "error: ./$src exists; build from an empty folder" >&2
  exit 1
fi
git -c advice.detachedHead=false clone --quiet --depth 1 --branch "$tag" \
  https://github.com/horizon-rust/horizon.git "$src"
cd "$src"

# The client's default features minus horizon-extras (docs/forking.md in horizon); `default` is one line.
default=$(sed -n 's/^default = \[\(.*\)\]$/\1/p' crates/horizon-client/Cargo.toml | head -n 1 | tr -d ' "')
if [[ ",$default," != *",horizon-extras,"* ]]; then
  echo "$tag predates the horizon-extras feature: there is no plain build of it" >&2
  exit 3
fi
features=$(tr ',' '\n' <<<"$default" | grep -vx 'horizon-extras' | paste -sd, -)
echo "Building $tag ($(git rev-parse --short HEAD)) with features: $features"

# The version the game shows, as the official build of that tag says it.
export HORIZON_VERSION="${tag#v}"
# The package holding the plain executable `horizon-client`: horizon-game once it moved there (horizon's
# docs/layers.md, layer plan M6), horizon-client before. Both take the same feature names.
package=horizon-client
if grep -qx 'name = "horizon-client"' crates/horizon-game/Cargo.toml 2>/dev/null; then
  package=horizon-game
fi
cargo build --release --locked ${target:+--target "$target"} \
  -p "$package" --no-default-features --features "$features" --bin horizon-client
# horizon-prepare makes the game's files from the player's own Minecraft install.
cargo build --release --locked ${target:+--target "$target"} -p horizon-prepare --bin horizon-prepare
