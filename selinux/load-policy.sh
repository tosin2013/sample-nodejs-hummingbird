#!/bin/bash
set -euo pipefail

POLICY_DIR="$(dirname "$0")"

for cil in "$POLICY_DIR"/*.cil; do
  POLICY_NAME=$(basename "$cil" .cil)
  echo "Loading policy: $POLICY_NAME"
  sudo semodule -i "$cil" \
    /usr/share/udica/templates/{base_container.cil,net_container.cil}
done

echo "All policies loaded successfully"
sudo semodule -l | grep hummingbird
