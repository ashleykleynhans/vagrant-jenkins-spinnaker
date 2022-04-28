VAGRANT_IMAGE_NAME = "ubuntu/jammy64"

Vagrant.configure("2") do |config|
    config.vm.box = VAGRANT_IMAGE_NAME
    config.vm.box_check_update = false
    config.ssh.insert_key = false

    # Provision Jenkins
    config.vm.define "jenkins" do |jenkins|
        jenkins.vm.provider "virtualbox" do |vb|
            vb.name = "jenkins"
            vb.memory = 2048
            vb.cpus = 2
        end
        jenkins.vm.hostname = "jenkins"
        jenkins.vm.network :private_network, ip: "10.10.10.10"
        jenkins.vm.provision "ansible" do |ansible|
            ansible.playbook = "ansible/playbooks/jenkins.yml"
            ansible.extra_vars = {
                node_ip: "10.10.10.10",
            }
        end
    end

    # Provision Spinnaker
    config.vm.define "spinnaker" do |spinnaker|
        spinnaker.vm.provider "virtualbox" do |vb|
            vb.name = "spinnaker"
            vb.memory = 2048
            vb.cpus = 2
        end
        spinnaker.vm.hostname = "spinnaker"
        spinnaker.vm.network :private_network, ip: "10.10.10.20"
        spinnaker.vm.provision "ansible" do |ansible|
            ansible.playbook = "ansible/playbooks/spinnaker.yml"
            ansible.extra_vars = {
                node_ip: "10.10.10.20",
            }
        end
    end
end
