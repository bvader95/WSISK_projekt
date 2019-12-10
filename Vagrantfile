Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/bionic64"
  config.vm.box_version = "1.0.282"
  config.vm.provider "virtualbox" do |providerConfig|
    providerConfig.gui = true
  end
 #  config.vm.provision "shell", inline: "sudo apt-get update; sudo apt-get install xubuntu-core^ -y; reboot"
  # config.vm.provision "file", source: "files/atom-amd64.deb", destination: "/home/vagrant/"
  # config.vm.provision "shell", path: "install.sh"
end
