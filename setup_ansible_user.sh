#!/bin/bash

# Créer l'utilisateur ansible
useradd -m -s /bin/bash ansible

# Sans mot de passe pour l'utilisateur (optionnel, pour démo ou environnements contrôlés)
echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible

# Configuration initiale pour SSH (facultatif, dépend de votre setup Ansible)
mkdir -p /home/ansible/.ssh
chmod 700 /home/ansible/.ssh
touch /home/ansible/.ssh/authorized_keys
chmod 600 /home/ansible/.ssh/authorized_keys
chown -R ansible:ansible /home/ansible/.ssh
