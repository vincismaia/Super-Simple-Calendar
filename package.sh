#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

package_id="com.vinicius.minicalendar"
dist_dir="$PWD/dist"
package_path="$dist_dir/$package_id.plasmoid"

mkdir -p "$dist_dir"
rm -f "$package_path"

zip -r "$package_path" . \
  -x ".git/*" \
  -x "dist/*" \
  -x "*.plasmoid"

echo "Created $package_path"

