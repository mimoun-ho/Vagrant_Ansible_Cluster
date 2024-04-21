
bash script_ansible.sh
ansible-playbook -i inventory.ini deploy_mapr.yml --ask-vault-pass -K
ansible-vault edit "/home/ansible/Vagrant_Ansible_Cluster/ansible/mapr_configuration/vars/creds.yml"
ansible-playbook -i inventory.ini deploy_mapr.yml --ask-vault-pass --tags "configure_cluster"
ssh-keygen -R 192.168.50.101

sudo /opt/mapr/server/configure.sh -R

ansible-playbook -i inventory.ini add_services.yml --ask-vault-pass -K 

cd /opt/mapr
sudo find . -type d -name "*.new"
sudo cp -r /opt/mapr/conf/conf.d.new/* /opt/mapr/conf/conf.d/
sudo cp -r /opt/mapr/conf.new/* /opt/mapr/conf/
sudo cp -r /opt/mapr//zookeeper/zookeeper-3.4.11/conf.new/* /opt/mapr/zookeeper/zookeeper-3.4.11/conf/
sudo cp -r /opt/mapr//apiserver/conf.new/* /opt/mapr/apiserver/conf/

cat /opt/mapr/conf/mapr-clusters.conf