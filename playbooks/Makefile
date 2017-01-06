WHOAMI := $(lastword $(MAKEFILE_LIST))
SSHCONFIG=.ssh-config
INVENTORY=hosts
VERSION=0.2.1
.PHONY: menu all up roles force-roles ping ip update version

menu:
	@echo 'up: Create VMs'
	@echo 'roles: Populate Galaxy roles from "roles.yml" or "config/roles.yml"'
	@echo 'force-roles: Update all roles, overwrting when required'
	@echo 'ansible.cfg: Create default ansible.cfg'
	@echo '$(SSHCONFIG): Create ssh configuration (use "make <file> SSHCONFIG=<file>" to override name)'
	@echo '$(INVENTORY): Create ansible inventory (use "make <file> INVENTORY=<file>" to overrride name)'
	@echo 'ip: Display the IPs of all the VMs'
	@echo 'all: Create all of the above'
	@echo
	@echo '"make all SSHCONF=sshconf INVENTORY=ansible-inv"'
	@echo ''
	@echo 'version: Prints current version'
	@echo 'udpate: Downloads latest version from github'
	@echo '        WARNING: this *will* overwrite $(WHOAMI).'

all: up roles ansible.cfg $(SSHCONFIG) $(INVENTORY) ip

up:
	@vagrant up

roles: $(wildcard roles.yml config/roles.yml)
	@echo 'Downloading roles'
	@ansible-galaxy install --role-file=$< --roles-path=roles

force-roles:
	@echo 'Downloading roles'
	@ansible-galaxy install --role-file=$< --roles-path=roles --force


ansible.cfg: $(SSHCONFIG) $(INVENTORY)
	@echo "Creating $@"
	@echo '[defaults]' > $@
	@echo 'inventory = $(INVENTORY)' >> $@
	@echo '' >> $@
	@echo '[ssh_connection]' >> $@
	@echo 'ssh_args = -C -o ControlMaster=auto -o ControlPersist=60s -F $(SSHCONFIG)' >> $@

$(SSHCONFIG): $(wildcard .vagrant/machines/*/*/id) Vagrantfile
	@echo "Creating $@"
	@vagrant ssh-config > $@ \
		|| ( RET=$$?; rm $@; exit $$RET; )

# Because of the pipe, extrodinary means have to be used to save the return
# code of "vagrant status"
$(INVENTORY): $(wildcard .vagrant/machines/*/*/id) Vagrantfile
	@echo "Creating $@"
	@( ( ( vagrant status; echo $$? >&3 ) \
		|  perl -nE 'if (/^$$/.../^$$/){say qq($$1) if /^(\S+)/;}' > $@ ) 3>&1 ) \
		|  ( read x; exit $$x ) \
		|| ( RET=$$?; rm $@; exit $$RET )

Vagrantfile:
	@echo 'Either use "vagrant init <box>" to create a Vagrantfile,'
	@echo '"cp Vagrantfile.sample Vagrantfile" if you cloned the repo, or download'
	@echo 'https://github.com/jhriv/vagrant-as-infrastructure/raw/master/Vagrantfile.sample'
	@false

ping:
	@ansible -m ping all

ip:
	@ansible -a 'hostname -I' all

update:
	@wget --quiet https://github.com/jhriv/vagrant-as-infrastructure/raw/master/Makefile --output-document=$(WHOAMI)

version:
	@ echo '$(VERSION)'
