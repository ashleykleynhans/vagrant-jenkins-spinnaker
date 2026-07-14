IMAGE = "generic/ubuntu2604"

Vagrant.configure("2") do |config|
    config.vm.box = IMAGE
    config.vm.box_check_update = false

    # Provision Jenkins
    config.vm.define "jenkins" do |jenkins|
        jenkins.vm.provider "vmware_desktop" do |vmx|
            vmx.vmx["displayname"] = "jenkins"
            vmx.vmx["memsize"] = "2048"
            vmx.vmx["numvcpus"] = "2"
        end
        jenkins.vm.hostname = "jenkins"
        jenkins.vm.network :private_network, ip: "10.10.10.10"
        jenkins.vm.provision "ansible" do |ansible|
            ansible.compatibility_mode = "2.0"
            ansible.playbook = "ansible/playbooks/jenkins.yml"
            ansible.extra_vars = {
                node_ip: "10.10.10.10",
            }
        end
    end

    # Provision Spinnaker
    config.vm.define "spinnaker" do |spinnaker|
        spinnaker.vm.provider "vmware_desktop" do |vmx|
            vmx.vmx["displayname"] = "spinnaker"
            vmx.vmx["memsize"] = "6144"
            vmx.vmx["numvcpus"] = "2"
        end
        spinnaker.vm.hostname = "spinnaker"
        spinnaker.vm.network :private_network, ip: "10.10.10.20"
        spinnaker.vm.provision "ansible" do |ansible|
            ansible.compatibility_mode = "2.0"
            ansible.playbook = "ansible/playbooks/spinnaker.yml"
            ansible.extra_vars = {
                node_ip: "10.10.10.20",
            }
        end
    end
end
