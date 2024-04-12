#!/bin/bash
# Configuration initiale
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_new -N ""
START=101
END=110
SUBNET="192.168.50"
USERNAME="ansible"
PASSWORD="ansible"  # Assurez-vous de sécuriser l'utilisation des mots de passe dans les scripts
INVENTORY_FILE="inventory.ini"

# Assurez-vous que le groupe [node_list] existe dans le fichier d'inventaire
if ! grep -q "\[node_list\]" "$INVENTORY_FILE"; then
    echo "[node_list]" >> "$INVENTORY_FILE"
fi

# Boucle sur la plage d'adresses IP
for IP in $(seq $START $END); do
    FULL_IP="$SUBNET.$IP"
    echo "Vérification de la joignabilité de $FULL_IP par ping..."
    
    if ping -c 1 $FULL_IP &> /dev/null; then
        echo "$FULL_IP est joignable."
        echo "Tentative de copie de la clé SSH vers $FULL_IP"
        if sshpass -p "$PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i ~/.ssh/id_rsa_new.pub $USERNAME@$FULL_IP 2>/dev/null; then
            echo "La clé SSH a été copiée vers $FULL_IP"
            # Ajout de l'hôte au fichier d'inventaire avec le format spécifié
            echo "$FULL_IP ansible_host=$FULL_IP ansible_user=$USERNAME" >> $INVENTORY_FILE
        else
            echo "Échec de la copie de la clé vers $FULL_IP."
        fi
    else
        echo "$FULL_IP n'est pas joignable via ping."
    fi
done
echo "Fichier d'inventaire généré : $INVENTORY_FILE"
