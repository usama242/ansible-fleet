#!/usr/bin/env python3
"""
Validates Python syntax across scripts and checks that required project files
exist.
"""

import pathlib
import py_compile
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent

REQUIRED_FILES = [
    "README.md",
    "docs/README.md",
    "LICENSE",
    ".gitignore",
    "Makefile",
    "Vagrantfile",
    "ansible.cfg",
    "requirements.txt",
    "inventory/hosts.yml",
    "group_vars/all.yml",
    "playbooks/site.yml",
    "playbooks/audit.yml",
    "playbooks/patch.yml",
    "playbooks/verify.yml",
    "roles/common/tasks/main.yml",
    "roles/patching/tasks/main.yml",
    "roles/patching/handlers/main.yml",
    "roles/reporting/tasks/main.yml",
    "roles/reporting/templates/report.json.j2",
    "roles/reporting/templates/report.md.j2",
    "scripts/preflight.sh",
    "scripts/run-lab.sh",
    "scripts/destroy-lab.sh",
    "scripts/validate-python.py",
    ".github/workflows/lint.yml",
    "docs/operations-runbook.txt",
    "docs/security.txt",
    "reports/.gitkeep",
]


def main() -> int:
    missing = [rel for rel in REQUIRED_FILES if not (ROOT / rel).is_file()]
    if missing:
        print(f"[ERROR] Missing required project files: {missing}", file=sys.stderr)
        return 1

    for path in ROOT.rglob("*.py"):
        if ".venv" in path.parts:
            continue
        py_compile.compile(str(path), doraise=True)

    print("[OK] Project structure and Python files validated successfully.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
