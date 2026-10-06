#!/usr/bin/env bash
# Build the provider against a go-unifi with the dev_id_override patch applied.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
work="${WORK_DIR:-$root/.patched-build}"
out="${OUT:-$work/terraform-provider-unifi}"
sdk_version="$(awk '$1 == "github.com/filipowm/go-unifi" {print $2; exit}' "$root/go.mod")"

rm -rf "$work/sdk"
mkdir -p "$work"
git clone -q --depth 1 --branch "$sdk_version" https://github.com/filipowm/go-unifi.git "$work/sdk"
git -C "$work/sdk" apply "$root/patches/go-unifi-dev-id-override.patch"

printf 'go %s\n\nuse (\n\t%s\n\t%s\n)\n' "$(awk '/^go / {print $2}' "$root/go.mod")" "$root" "$work/sdk" > "$work/go.work"

# Low settings keep memory use modest on small hosts.
GOWORK="$work/go.work" GOMAXPROCS="${GOMAXPROCS:-2}" GOFLAGS="-p=1" GOMEMLIMIT="${GOMEMLIMIT:-1200MiB}" \
  go build -o "$out" "$root"
echo "built $out (go-unifi $sdk_version + dev-id-override patch)"
