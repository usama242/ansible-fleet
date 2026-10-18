#!/usr/bin/env bash
set -euo pipefail

echo "=== Local Linux Fleet Lab: Workstation Preflight ==="

ARCH="$(uname -m)"
OS_NAME="$(uname -s)"
echo "[INFO] Detected workstation OS=${OS_NAME} ARCH=${ARCH}"

if ! command -v python3 >/dev/null 2>&1; then
  echo "[ERROR] python3 is required but was not found in PATH." >&2
  exit 1
fi
echo "[OK] python3 found: $(python3 --version)"

if [[ -x ".venv/bin/ansible-playbook" ]]; then
  echo "[OK] virtualenv ansible-playbook found: $(.venv/bin/ansible-playbook --version | head -n 1)"
elif command -v ansible-playbook >/dev/null 2>&1; then
  echo "[OK] system ansible-playbook found: $(ansible-playbook --version | head -n 1)"
else
  echo "[WARN] ansible-playbook not found yet. Run 'make venv' to install Ansible in .venv."
fi

if [[ "${ARCH}" == "arm64" ert{}ert{} "${ARCH}" == "aarch64" ]]; then
  echo "[WARN] ARM64 / Apple Silicon host detected."
  echo "       VirtualBox and x86_64 boxes do not work reliably on Apple Silicon."
  echo "       If 'vagrant up' fails, use existing Ubuntu 24.04 LTS VMs and update inventory/hosts.yml."
fi

if command -v vagrant >/dev/null 2>&1; then
  echo "[OK] vagrant found: $(vagrant --version)"
else
  echo "[WARN] vagrant not found. Required for 'make lab-up', optional if using existing Linux VMs via inventory/hosts.yml."
fi

if command -v VBoxManage >/dev/null 2>&1; then
  echo "[OK] VirtualBox found: $(VBoxManage --version)"
elif command -v virsh >/dev/null 2>&1; then
  echo "[OK] libvirt (virsh) found."
else
  echo "[WARN] Neither VirtualBox nor libvirt detected. Ensure a compatible hypervisor or external Ubuntu 24.04 VMs are available."
fi

echo "=== Preflight check complete ==="
