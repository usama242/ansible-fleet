# Ansible Fleet Lab

Ansible project for bootstrapping, auditing, verifying, and patching a small Debian or Ubuntu server fleet. The default inventory contains three Ubuntu 24.04 Vagrant nodes (`app01`–`app03`) on private addresses `192.168.56.11`–`.13`.

## What it does

- `site.yml` installs a baseline, applies SSH and sysctl settings, and configures nginx health endpoints.
- `audit.yml` performs read-only compliance and pending-update checks and writes timestamped reports.
- `patch.yml` upgrades hosts in serial batches, with an interactive `PATCH` confirmation by default, optional maintenance mode and reboot handling, and a report even when a host task fails.
- `verify.yml` checks nginx and the `/healthz` JSON endpoint.

Supported targets are Debian and Ubuntu systems using apt and systemd. Bootstrap and patching require SSH access and privilege escalation (sudo). Patching and bootstrap change target systems; review `docs/security.txt` and `docs/operations-runbook.txt` before running them outside a disposable lab.

## Requirements

- Python 3 and `make`
- A Debian/Ubuntu target fleet reachable over SSH
- For the included disposable lab: Vagrant and a compatible provider (VirtualBox or libvirt). Vagrant does not work reliably with the default x86_64 box on Apple Silicon; use compatible existing VMs there.

## Install and prepare

```sh
make venv
make preflight
```

`make venv` installs the pinned-range Ansible and lint dependencies into `.venv/`. The repository's `ansible.cfg` uses `inventory/hosts.yml` by default.

### Use the included Vagrant lab

```sh
make lab-up
```

The inventory expects Vagrant-generated SSH keys under `.vagrant/machines/`. Do not commit those generated credentials.

### Use existing servers

Create a separate inventory file, for example `inventory/production.yml`, with your hosts, SSH users, and key paths. Keep secrets in a vault or an approved secret store; do not put passwords or private keys in version control. Then pass it with `INVENTORY`:

```sh
make audit INVENTORY=inventory/production.yml
```

Ensure the remote SSH user can use sudo. For custom inventories, host variables should provide `ansible_host`, and connectivity should be checked before changing playbooks:

```sh
.venv/bin/ansible -i inventory/production.yml app_servers -m ping
```

## Run workflows

Run commands from the repository root:

```sh
make bootstrap     # enforce baseline and configure health service
make audit         # read-only audit and reports
make verify        # verify nginx and /healthz
make patch-check   # Ansible check-mode preview; not a guarantee of apt outcomes
make patch         # live staged patching; type PATCH when prompted
```

`make patch-yes` skips the prompt and `make patch-serial-all` patches all inventory hosts in one batch. Use these only when that behavior is intentional. Common overrides can be supplied directly, for example:

```sh
.venv/bin/ansible-playbook -i inventory/hosts.yml playbooks/patch.yml \
  -e patch_auto_approve=true -e patch_serial_batch=1
```

Generated JSON and Markdown reports are written to `reports/` and ignored by Git. `make clean-reports` removes those generated reports.

## Check and validate

```sh
make lint
```

This runs the repository structure/Python check, yamllint, and ansible-lint. CI runs the same checks on pushes and pull requests. The workflow file is `.github/workflows/lint.yml`.

To check inventory syntax and reachability without changing hosts:

```sh
.venv/bin/ansible-inventory -i inventory/hosts.yml --graph
.venv/bin/ansible -i inventory/hosts.yml app_servers -m ping
```

Ansible `--check` is a simulation, especially for apt and reboot behavior. It cannot predict all package-manager side effects or failures.

## Tear down

For the disposable Vagrant lab:

```sh
make lab-destroy
```

For more operational detail, variable reference, failure simulation, and recovery guidance, see [docs/README.md](docs/README.md) and the [operations runbook](docs/operations-runbook.txt).
