#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-up}"

if ! command -v vagrant >/dev/null 2>&1; then
  echo "[ERROR] vagrant is not installed. Either install Vagrant + a supported provider," >&2
  echo "        or point inventory/hosts.yml at three existing Ubuntu 24.04 VMs." >&2
  exit 1
fi

case "${ACTION}" in
  up)
    echo "[INFO] Bringing up Vagrant fleet VMs (app01, app02, app03)..."
    vagrant up
    vagrant status
    ;;
  status)
    vagrant status
    ;;
  halt)
    vagrant halt
    ;;
  *)
    echo "Usage: $0 {up|status|halt}" >&2
    exit 1
    ;;
esac
