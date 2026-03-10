# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define "dc01" do |dc|
    dc.vm.box = "gusztavvargadr/windows-server-2022-standard"
    dc.vm.hostname = "dc01.lab.local"
    dc.vm.network "private_network", ip: "10.0.2.10", virtualbox__intnet: "internal"
    dc.vm.provider "virtualbox" do |vb|
      vb.name = "dc01"
      vb.memory = 4096
      vb.cpus = 2
      vb.gui = false
    end
    # Provision DC in one go (no reboot needed before AD DS promotion)
    dc.vm.provision "shell", path: "scripts/dc01_provision.ps1", reboot: true
    # After reboot, ensure services are up (optional)
    dc.vm.provision "shell", inline: "Write-Host 'DC01 ready'", run: "once"
  end

  config.vm.define "web01" do |web|
    web.vm.box = "gusztavvargadr/windows-server-2022-standard"
    web.vm.hostname = "web01.lab.local"
    web.vm.network "private_network", ip: "10.0.1.10", virtualbox__intnet: "dmz"
    web.vm.network "private_network", ip: "10.0.2.11", virtualbox__intnet: "internal"
    web.vm.provider "virtualbox" do |vb|
      vb.name = "web01"
      vb.memory = 4096
      vb.cpus = 2
      vb.gui = false
    end
    # Stage 1: Join domain and reboot
    web.vm.provision "shell", path: "scripts/web01_joindomain.ps1", reboot: true
    # Stage 2: Install IIS and deploy web app (run after reboot)
    web.vm.provision "shell", path: "scripts/web01_configure.ps1", run: "once"
  end
end
