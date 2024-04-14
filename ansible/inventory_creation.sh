#!/bin/bash
# Configuration initiale
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_new -N ""  # Création d'une nouvelle clé SSH sans passphrase
START=101
END=110
SUBNET="192.168.50"
USERNAME="ansible"
PASSWORD="ansible"  # Remplacez par votre propre méthode sécurisée de gestion des mots de passe
INVENTORY_FILE="inventory.ini"

# Initialisation du fichier d'inventaire avec les groupes nécessaires
if [ ! -f "$INVENTORY_FILE" ]; then
    echo "[zookeeper_nodes]" > "$INVENTORY_FILE"
    echo "[cldb_nodes]" >> "$INVENTORY_FILE"
    echo "[resource_manager_nodes]" >> "$INVENTORY_FILE"
    echo "[historyserver_nodes]" >> "$INVENTORY_FILE"
    echo "[webserver_nodes]" >> "$INVENTORY_FILE"
    echo "[gateway_nodes]" >> "$INVENTORY_FILE"
    echo "[timelineserver_nodes]" >> "$INVENTORY_FILE"
    echo "[all_nodes]" >> "$INVENTORY_FILE"
fi

# Boucle sur la plage d'adresses IP
for IP in $(seq $START $END); do
    FULL_IP="$SUBNET.$IP"
    echo "Vérification de la joignabilité de $FULL_IP par ping..."
    
    if ping -c 1 $FULL_IP &> /dev/null; then
        echo "$FULL_IP est joignable."
        
        # Tentative de copie de la clé SSH vers le hôte distant
        echo "Tentative de copie de la clé SSH vers $FULL_IP"
        ssh-keygen -R $FULL_IP
        sshpass -p "$PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa_new.pub $USERNAME@$FULL_IP
        
        # Récupère le nom d'hôte et l'OS
        HOSTNAME=$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa_new $USERNAME@$FULL_IP 'hostname' 2>/dev/null)
        OS=$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa_new $USERNAME@$FULL_IP 'cat /etc/os-release | grep PRETTY_NAME | cut -d "=" -f2' 2>/dev/null)

        # Formate l'entrée d'inventaire
        INVENTORY_ENTRY="$HOSTNAME ansible_host=$FULL_IP ansible_user=$USERNAME OS=$OS"

        # Vérifie si l'entrée existe déjà pour éviter les doublons
        if ! grep -Fxq "$INVENTORY_ENTRY" "$INVENTORY_FILE"; then
            if [ ! -z "$HOSTNAME" ]; then
                echo "Le nom d'hôte de $FULL_IP est $HOSTNAME avec OS $OS."
                # Ajoute l'hôte à la section [all_nodes] et à ses rôles spécifiques
                echo "$INVENTORY_ENTRY" >> "$INVENTORY_FILE"
            else
                echo "Échec de la récupération du nom d'hôte pour $FULL_IP."
            fi
        else
            echo "Entrée existante pour $HOSTNAME, pas de mise à jour nécessaire."
        fi
    else
        echo "$FULL_IP n'est pas joignable via ping."
    fi
done

echo "Fichier d'inventaire mis à jour : $INVENTORY_FILE"
