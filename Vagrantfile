# -*- mode: ruby -*-
# vi: set ft=ruby :

# NOTE ON HOST ARCHITECTURE AND PROVIDERS:
# This Vagrantfile targets x86_64 VirtualBox or libvirt by default using the
# bento/ubuntu-24.04 box. VirtualBox does NOT work reliably on Apple Silicon
# (ARM64) hosts, and standard x86_64 boxes cannot run under ARM64 hypervisors.
# If you are on Apple Silicon or prefer another hypervisor (multipass, UTM,
# VMware Fusion, Proxmox, or cloud VMs), provision 3 Ubuntu 24.04 LTS nodes
# manually or via your hypervisor and update inventory/hosts.yml.
# See docs/operations-runbook.txt for fallback instructions.

Vagrant.configure("2") do |config|
  config.vm.box = ENV.fetch("VAGRANT_BOX", "bento/ubuntu-24.04")
  config.vm.box_check_update = false

  nodes = [
    { name: "app01", ip: "192.168.56.11" },
    { name: "app02", ip: "192.168.56.12" },
    { name: "app03", ip: "192.168.56.13" }
  ]

  nodes.each do |node|
    config.vm.define node[:name] do |srv|
      srv.vm.hostname = node[:name]
      srv.vm.network "private_network", ip: node[:ip]

      srv.vm.provider "virtualbox" do |vb|
        vb.name = "local-fleet-#{node[:name]}"
        vb.memory = 1024
        vb.cpus = 1
        vb.gui = false
      end

      srv.vm.provider "libvirt" do |lv|
        lv.memory = 1024
        lv.cpus = 1
      end

      srv.vm.provision "shell", inline: <<-SHELL
        set -eu
        export DEBIAN_FRONTEND=noninteractive
        if ! command -v python3 >/dev/null 2>&1; then
          apt-get update -y
          apt-get install -y python3 python3-apt
        fi
      SHELL
    end
  end
end
