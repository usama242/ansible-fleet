SHELL := /bin/bash
VENV_DIR ?= .venv
PYTHON := $(VENV_DIR)/bin/python
PIP := $(VENV_DIR)/bin/pip
ANSIBLE_PLAYBOOK := $(VENV_DIR)/bin/ansible-playbook
ANSIBLE_LINT := $(VENV_DIR)/bin/ansible-lint
YAMLLINT := $(VENV_DIR)/bin/yamllint
INVENTORY ?= inventory/hosts.yml

.PHONY: help venv preflight lab-up bootstrap audit patch-check patch patch-yes patch-serial-all verify lint clean-reports lab-destroy

help:
	@echo "Available targets:"
	@echo "  make venv             - Create local Python virtualenv and install dependencies"
	@echo "  make preflight        - Run workstation preflight checks"
	@echo "  make lab-up           - Start Vagrant lab VMs (app01, app02, app03)"
	@echo "  make bootstrap        - Configure baseline compliance and nginx health service"
	@echo "  make audit            - Run read-only compliance and patch audit (generates report)"
	@echo "  make patch-check      - Run patch workflow in Ansible check mode (dry-run simulation)"
	@echo "  make patch            - Run interactive staged patching (prompts for confirmation)"
	@echo "  make patch-yes        - Run non-interactive staged patching (explicit opt-in)"
	@echo "  make patch-serial-all - Run non-interactive patching across all hosts at once (batch=3)"
	@echo "  make verify           - Verify nginx systemd state and HTTP JSON health endpoints"
	@echo "  make lint             - Run Python validation, yamllint, and ansible-lint"
	@echo "  make clean-reports    - Delete generated JSON and Markdown runtime reports"
	@echo "  make lab-destroy      - Destroy Vagrant VMs"

venv:
	python3 -m venv $(VENV_DIR)
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt

preflight:
	./scripts/preflight.sh

lab-up:
	./scripts/run-lab.sh up

bootstrap:
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) playbooks/site.yml

audit:
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) playbooks/audit.yml

patch-check:
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) playbooks/patch.yml --check -e "patch_Execution_mode=check"

patch:
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) playbooks/patch.yml

patch-yes:
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) playbooks/patch.yml -e "patch_auto_approve=true"

patch-serial-all:
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) playbooks/patch.yml -e "patch_auto_approve=true" -e "patch_serial_batch=3" -e "patch_batch_pause_seconds=0"

verify:
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) playbooks/verify.yml

lint:
	python3 ./scripts/validate-python.py
	$(YAMLLINT) -c .yamllint.yml playbooks roles inventory group_vars .github
	$(ANSIBLE_LINT) playbooks/site.yml playbooks/audit.yml playbooks/patch.yml playbooks/verify.yml

clean-reports:
	rm -f reports/*.json reports/*.md

lab-destroy:
	./scripts/destroy-lab.sh
