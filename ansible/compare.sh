#!/bin/bash

# Définir les adresses et les utilisateurs SSH pour les deux machines
HOST1="ansible@192.168.50.101"
HOST2="mapr@192.168.56.109"

# Chemin du dossier à comparer
DIRECTORY="/opt/mapr"

# Nom du fichier où stocker les résultats
OUTPUT_FILE="diff_report.txt"

# Utiliser rsync pour comparer le contenu du répertoire entre les deux machines
echo "Comparaison des fichiers entre $HOST1 et $HOST2 dans le répertoire $DIRECTORY"
echo "Les différences sont enregistrées dans $OUTPUT_FILE"

# Exécuter rsync et rediriger la sortie vers un fichier
rsync -avun --delete "$HOST1:$DIRECTORY/" "$HOST2:$DIRECTORY/" > $OUTPUT_FILE
