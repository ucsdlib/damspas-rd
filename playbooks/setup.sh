#!/bin/sh

cd $(dirname "$0")

echo 'Installing required Ansible roles... '

ansible-galaxy install --role-file=config/roles.yml --roles-path=roles
