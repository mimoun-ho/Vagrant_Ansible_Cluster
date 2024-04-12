
bash script_ansible.sh
ansible-playbook -i inventory.ini deploy_mapr.yml --ask-vault-pass
ansible-vault edit "/home/ansible/ansible copy/mapr_configuration/vars/creds.yml"