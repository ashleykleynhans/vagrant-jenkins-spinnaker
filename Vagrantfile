IMAGE = "ashleykleynhans/ubuntu2604-arm64"

Vagrant.configure("2") do |config|
    config.vm.box = IMAGE
    config.vm.box_check_update = false

    # Provision Jenkins
    config.vm.define "jenkins" do |jenkins|
        jenkins.vm.provider "utm" do |u|
            u.name = "jenkins"
            u.memory = 2048
            u.cpus = 2
        end
        jenkins.vm.hostname = "jenkins"
        jenkins.vm.network :forwarded_port, guest: 8080, host: 8080
        jenkins.vm.provision "ansible" do |ansible|
            ansible.compatibility_mode = "2.0"
            ansible.playbook = "ansible/playbooks/jenkins.yml"
        end
    end

    # Provision Spinnaker
    config.vm.define "spinnaker" do |spinnaker|
        spinnaker.vm.provider "utm" do |u|
            u.name = "spinnaker"
            u.memory = 12288
            u.cpus = 6
        end
        spinnaker.vm.hostname = "spinnaker"
        spinnaker.vm.network :forwarded_port, guest: 81, host: 9000
        spinnaker.vm.provision "ansible" do |ansible|
            ansible.compatibility_mode = "2.0"
            ansible.playbook = "ansible/playbooks/spinnaker.yml"
        end
    end
end
