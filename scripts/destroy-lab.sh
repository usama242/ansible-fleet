#!/usr/bin/env bash
set -euo pipefail

if ! command -v vagrant >/dev/null 2>&1; then
  echo "[WARN] vagrant is not installed; nothing to destroy."
  exit 0
fi

echo "[INFO] Destroying Vagrant lab VMs..."
vagrant destroy -f
