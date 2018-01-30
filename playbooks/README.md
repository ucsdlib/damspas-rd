DAMS 5 "damspas-rd" Ansible Playbook
================================

Installs dependencies for Hyrax as listed on [Hyrax repository][hyrax].

Vagrant Steps
-------------

1.  `cd playbooks; make all`

    Creates the VM(s), downloads the required Ansible roles, create the Ansible
    inventory, and Ansible/ssh configurations.

2.  `ansible-playbook playbook.yml`

    Runs the playbook against the Vagrant VM.

If you need the /vagrant sync'd folder, be certain to remove the
*box.vm.synced_folder* option from the *Vagrantfile*.

### Makefile supported Commands

* **up**: Creates the VM(s)
* **roles**: Install Ansible roles, if not already present
* **force-roles**: (Re)Installs Ansible roles, regardless of presence
* **ip**: Displays IP addresses of all present and running VMs
* **ping**: Verifies VMs are running and accessible

### Additional Makefile commands

* **hosts**: Creates Ansible inventory
* **.ssh-config**: Creates ssh configuration
* **ansible.cfg**: Creates Ansible configuration

vSphere / Physical System Steps
-------------------------------

1.  `cd playbooks; make roles`

    Downloads required Ansible roles

2.  `ansible-playbook playbook.yml`

    Runs the playbook. This assumes a global Ansible inventory, proper ssh
    configuration, passwordless keys, and passwordless sudo. Use additional
    Ansible command line arguments (`-i <inventory> -l <host/group> -K -k`) as appropriate


[hyrax]: https://github.com/projecthydra-labs/hyrax#prerequisites
