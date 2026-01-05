# 🎓 TP : Configuration d'un VPN WireGuard - Version Complète avec Serveur Local

Guide pratique pour configurer et tester un VPN WireGuard avec serveur et client sur votre système.

## 🎯 Objectifs du TP

À la fin de ce TP, vous serez capable de :
- ✅ Installer WireGuard sur votre système
- ✅ Générer des clés cryptographiques pour serveur et client
- ✅ Configurer un serveur VPN local
- ✅ Configurer un client VPN
- ✅ Établir une connexion VPN sécurisée
- ✅ Vérifier et tester votre connexion VPN

## ⏱️ Durée estimée

1 à 2 heures

---

## Étape 1 : Préparer l'environnement

### 🎯 Objectif
Installer WireGuard et s'assurer que le système est prêt.

### 📝 Instructions

#### 1.1 Mettre à jour le système

sudo apt update && sudo apt upgrade -y

Pourquoi ? Pour avoir les dernières versions des paquets et correctifs de sécurité.

#### 1.2 Installer WireGuard

sudo apt install wireguard -y

#### 1.3 Vérifier l'installation

wg --version

Résultat attendu :
wireguard-tools v1.x.x

### ✅ Critères de validation

- [ ] La commande wg --version affiche une version
- [ ] Aucune erreur lors de l'installation

### 💡 Questions de réflexion

1. Pourquoi est-il important de mettre à jour le système avant d'installer ?
2. Que se passe-t-il si WireGuard n'est pas dans les dépôts ?

Réponses :
1. Pour éviter les conflits de dépendances et avoir les derniers correctifs de sécurité
2. Il faut ajouter le dépôt officiel WireGuard ou compiler depuis les sources

---

## Étape 2 : Générer les clés cryptographiques

### 🎯 Objectif
Créer les paires de clés (privée/publique) pour le serveur ET le client.

### 📝 Instructions

#### 2.1 Créer un dossier pour les clés

mkdir -p ~/wireguard-keys
cd ~/wireguard-keys

#### 2.2 Générer les clés du CLIENT

wg genkey | tee client_private
cat client_private | wg pubkey > client_public

#### 2.3 Générer les clés du SERVEUR

wg genkey | tee server_private
cat server_private | wg pubkey > server_public

#### 2.4 Afficher toutes les clés

echo "========================================="
echo "🔑 CLÉ PRIVÉE CLIENT (à garder secrète)"
echo "========================================="
cat client_private
echo ""
echo "========================================="
echo "🔓 CLÉ PUBLIQUE CLIENT"
echo "========================================="
cat client_public
echo ""
echo "========================================="
echo "🔑 CLÉ PRIVÉE SERVEUR (à garder secrète)"
echo "========================================="
cat server_private
echo ""
echo "========================================="
echo "🔓 CLÉ PUBLIQUE SERVEUR"
echo "========================================="
cat server_public

📝 NOTEZ CES 4 CLÉS quelque part, vous en aurez besoin pour la configuration !

#### 2.5 Sécuriser les permissions

chmod 600 client_private server_private
ls -l

### ✅ Critères de validation

- [ ] Les 4 fichiers existent (client_private, client_public, server_private, server_public)
- [ ] Toutes les clés sont différentes
- [ ] Les clés privées ont les permissions 600 (-rw-------)

### 💡 Questions de réflexion

1. Pourquoi génère-t-on 2 paires de clés (serveur + client) ?
2. Que se passe-t-il si on inverse les clés publiques/privées ?
3. Peut-on utiliser la même paire de clés pour serveur et client ?

Réponses :
1. Chaque entité (serveur et client) a besoin de sa propre identité cryptographique
2. La connexion ne fonctionnera pas - chaque entité doit avoir SA clé privée
3. Techniquement oui, mais c'est une très mauvaise pratique de sécurité

---

## Étape 3 : Configurer le serveur VPN

### 🎯 Objectif
Créer et démarrer le serveur WireGuard qui acceptera les connexions.

### 📝 Instructions

#### 3.1 Créer le fichier de configuration du serveur

sudo nano /etc/wireguard/wg1.conf

#### 3.2 Ajouter la configuration du serveur

Copiez cette configuration et REMPLACEZ les valeurs entre crochets :

[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = [COLLEZ_ICI_LE_CONTENU_DE_server_private]
PostUp = sysctl -w net.ipv4.ip_forward=1
PostDown = sysctl -w net.ipv4.ip_forward=0

[Peer]
PublicKey = [COLLEZ_ICI_LE_CONTENU_DE_client_public]
AllowedIPs = 10.0.0.2/32

#### 3.3 Comprendre la configuration serveur

Section Interface :
- Address : IP du serveur dans le VPN (10.0.0.1)
- ListenPort : Port d'écoute (51820 par défaut)
- PrivateKey : Identité cryptographique du serveur
- PostUp/PostDown : Commandes au démarrage/arrêt

Section Peer :
- PublicKey : Identité du client autorisé
- AllowedIPs : IP que le client peut utiliser

#### 3.4 Sauvegarder et fermer

CTRL + X
Y (pour Yes)
ENTRÉE

#### 3.5 Sécuriser le fichier

sudo chmod 600 /etc/wireguard/wg1.conf

#### 3.6 Démarrer le serveur

sudo wg-quick up wg1

Résultat attendu :
[#] ip link add wg1 type wireguard
[#] wg setconf wg1 /dev/fd/63
[#] ip -4 address add 10.0.0.1/24 dev wg1
[#] ip link set mtu 1420 up dev wg1
[#] sysctl -w net.ipv4.ip_forward=1

#### 3.7 Vérifier le serveur

sudo wg show wg1

Résultat attendu :
interface: wg1
  public key: [votre clé publique serveur]
  private key: (hidden)
  listening port: 51820

peer: [clé publique du client]
  allowed ips: 10.0.0.2/32

### ✅ Critères de validation

- [ ] Le fichier /etc/wireguard/wg1.conf existe
- [ ] Les permissions sont 600
- [ ] Le serveur démarre sans erreur
- [ ] La commande wg show wg1 affiche les informations

### 💡 Questions de réflexion

1. Pourquoi utilise-t-on wg1 au lieu de wg0 pour le serveur ?
2. À quoi sert PostUp = sysctl -w net.ipv4.ip_forward=1 ?
3. Que signifie AllowedIPs = 10.0.0.2/32 ?

Réponses :
1. Pour différencier serveur (wg1) et client (wg0) sur la même machine
2. Active le routage IP pour que le serveur puisse transférer les paquets
3. Autorise uniquement l'IP 10.0.0.2 pour ce client (le /32 = une seule adresse)

---

## Étape 4 : Configurer le client VPN

### 🎯 Objectif
Créer la configuration client qui se connectera au serveur.

### 📝 Instructions

#### 4.1 Créer le fichier de configuration du client

sudo nano /etc/wireguard/wg0.conf

#### 4.2 Ajouter la configuration du client

Copiez cette configuration et REMPLACEZ les valeurs entre crochets :

[Interface]
PrivateKey = [COLLEZ_ICI_LE_CONTENU_DE_client_private]
Address = 10.0.0.2/24
DNS = 8.8.8.8

[Peer]
PublicKey = [COLLEZ_ICI_LE_CONTENU_DE_server_public]
Endpoint = 127.0.0.1:51820
AllowedIPs = 10.0.0.0/24
PersistentKeepalive = 25

#### 4.3 Comprendre la configuration client

Section Interface :
- PrivateKey : Identité cryptographique du client
- Address : IP du client dans le VPN (10.0.0.2)
- DNS : Serveurs DNS à utiliser

Section Peer :
- PublicKey : Identité du serveur
- Endpoint : Où se connecter (IP:port du serveur)
- AllowedIPs : Quel trafic router via le VPN
- PersistentKeepalive : Maintien de connexion

#### 4.4 Sauvegarder et fermer

CTRL + X
Y
ENTRÉE

#### 4.5 Sécuriser le fichier

sudo chmod 600 /etc/wireguard/wg0.conf

### ✅ Critères de validation

- [ ] Le fichier /etc/wireguard/wg0.conf existe
- [ ] Toutes les valeurs sont remplies (pas de crochets restants)
- [ ] Les permissions sont 600

### 💡 Questions de réflexion

1. Pourquoi Endpoint = 127.0.0.1:51820 ?
2. Que signifie AllowedIPs = 10.0.0.0/24 ?
3. Quelle serait la différence avec AllowedIPs = 0.0.0.0/0 ?

Réponses :
1. 127.0.0.1 = localhost, car le serveur est sur la même machine (pour le TP)
2. Seul le trafic vers le réseau 10.0.0.x passera par le VPN
3. Tout le trafic Internet passerait par le VPN (split tunneling désactivé)

---

## Étape 5 : Établir la connexion VPN

### 🎯 Objectif
Connecter le client au serveur et vérifier la connexion.

### 📝 Instructions

#### 5.1 Vérifier que le serveur est actif

sudo wg show wg1

Si pas actif, redémarrez-le :
sudo wg-quick up wg1

#### 5.2 Démarrer le client

sudo wg-quick up wg0

Résultat attendu :
[#] ip link add wg0 type wireguard
[#] wg setconf wg0 /dev/fd/63
[#] ip -4 address add 10.0.0.2/24 dev wg0
[#] ip link set mtu 1420 up dev wg0

#### 5.3 Vérifier le statut du client

sudo wg show wg0

Résultat attendu :
interface: wg0
  public key: [votre clé publique client]
  private key: (hidden)
  listening port: [port]

peer: [clé publique du serveur]
  endpoint: 127.0.0.1:51820
  allowed ips: 10.0.0.0/24
  latest handshake: [il y a quelques secondes]
  transfer: X B received, Y B sent

⚠️ IMPORTANT : La ligne "latest handshake" doit apparaître ! Cela signifie que la connexion est établie.

#### 5.4 Tester la connexion : Ping du client vers le serveur

ping -c 4 10.0.0.1

Résultat attendu :
PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
64 bytes from 10.0.0.1: icmp_seq=1 ttl=64 time=0.123 ms
64 bytes from 10.0.0.1: icmp_seq=2 ttl=64 time=0.089 ms
...
--- 10.0.0.1 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss

#### 5.5 Test depuis le serveur vers le client

ping -c 4 10.0.0.2

#### 5.6 Vérifier les statistiques en temps réel

watch -n 1 sudo wg show wg1

Ou sur le client (dans un autre terminal) :
watch -n 1 sudo wg show wg0

Vous verrez les compteurs "transfer" augmenter !

### ✅ Critères de validation

- [ ] La commande wg-quick up wg0 réussit sans erreur
- [ ] wg show wg0 affiche "latest handshake"
- [ ] Le ping vers 10.0.0.1 fonctionne
- [ ] Le ping vers 10.0.0.2 fonctionne
- [ ] Les statistiques de transfert augmentent

### 💡 En cas d'erreur

Erreur : "Cannot find device wg0"
sudo modprobe wireguard

Pas de "latest handshake"
sudo cat /etc/wireguard/wg0.conf
sudo cat /etc/wireguard/wg1.conf
sudo wg-quick down wg1 && sudo wg-quick up wg1
sudo wg-quick down wg0 && sudo wg-quick up wg0

Le ping ne fonctionne pas
sudo ufw status
ip route show

---

## Étape 6 : Tests et vérifications avancés

### 🎯 Objectif
S'assurer que le VPN fonctionne correctement.

### 📝 Instructions

#### 6.1 Afficher les interfaces réseau

ip addr show

Vous devriez voir wg0 et wg1 avec leurs adresses IP respectives.

#### 6.2 Afficher les routes

ip route show

Vous devriez voir les routes vers 10.0.0.0/24 via wg0 et wg1.

#### 6.3 Monitorer les connexions en temps réel

Terminal 1 : Stats du serveur
watch -n 1 'sudo wg show wg1'

Terminal 2 : Stats du client
watch -n 1 'sudo wg show wg0'

Terminal 3 : Générer du trafic
ping 10.0.0.1

Observez les compteurs augmenter !

#### 6.4 Test de bande passante

sudo apt install iperf3 -y

Sur le serveur (terminal 1) :
iperf3 -s -B 10.0.0.1

Sur le client (terminal 2) :
iperf3 -c 10.0.0.1 -t 10

#### 6.5 Logs et débogage

sudo journalctl -u wg-quick@wg1 -f
sudo journalctl -u wg-quick@wg0 -f
sudo dmesg | grep wireguard

### ✅ Critères de validation

- [ ] Les interfaces wg0 et wg1 apparaissent dans ip addr
- [ ] Les routes VPN sont présentes
- [ ] Les statistiques changent en temps réel
- [ ] Le test iperf3 fonctionne

---

## Étape 7 : Gestion du VPN

### 🎯 Objectif
Apprendre à gérer le VPN au quotidien.

### 📝 Instructions

#### 7.1 Arrêter le VPN

sudo wg-quick down wg0
sudo wg-quick down wg1

#### 7.2 Redémarrer le VPN

sudo wg-quick down wg1 && sudo wg-quick up wg1
sudo wg-quick down wg0 && sudo wg-quick up wg0

#### 7.3 Activer au démarrage du système

sudo systemctl enable wg-quick@wg1
sudo systemctl enable wg-quick@wg0
sudo systemctl status wg-quick@wg1
sudo systemctl status wg-quick@wg0

#### 7.4 Désactiver le démarrage automatique

sudo systemctl disable wg-quick@wg1
sudo systemctl disable wg-quick@wg0

#### 7.5 Script de gestion rapide

nano ~/vpn-manager.sh

Copiez ce contenu :

#!/bin/bash

case "$1" in
    start-server)
        sudo wg-quick up wg1
        echo "✅ Serveur VPN démarré"
        ;;
    stop-server)
        sudo wg-quick down wg1
        echo "❌ Serveur VPN arrêté"
        ;;
    start-client)
        sudo wg-quick up wg0
        echo "✅ Client VPN connecté"
        ;;
    stop-client)
        sudo wg-quick down wg0
        echo "❌ Client VPN déconnecté"
        ;;
    status)
        echo "=== SERVEUR (wg1) ==="
        sudo wg show wg1
        echo ""
        echo "=== CLIENT (wg0) ==="
        sudo wg show wg0
        ;;
    restart)
        sudo wg-quick down wg1 && sudo wg-quick up wg1
        sudo wg-quick down wg0 && sudo wg-quick up wg0
        echo "🔄 VPN redémarré"
        ;;
    *)
        echo "Usage: $0 {start-server|stop-server|start-client|stop-client|status|restart}"
        exit 1
        ;;
esac

Rendre exécutable :
chmod +x ~/vpn-manager.sh

Utiliser :
~/vpn-manager.sh start-server
~/vpn-manager.sh start-client
~/vpn-manager.sh status
~/vpn-manager.sh restart
~/vpn-manager.sh stop-client
~/vpn-manager.sh stop-server

---

## 🎉 Conclusion

Félicitations ! Vous avez maintenant :
- ✅ Installé WireGuard
- ✅ Configuré un serveur VPN local
- ✅ Configuré un client VPN
- ✅ Établi une connexion sécurisée
- ✅ Testé et vérifié la connexion
- ✅ Appris à gérer le VPN

### 📊 Tableau récapitulatif

Composant | Interface | Adresse IP | Fichier config | Commande
----------|-----------|------------|----------------|----------
Serveur | wg1 | 10.0.0.1/24 | /etc/wireguard/wg1.conf | wg-quick up wg1
Client | wg0 | 10.0.0.2/24 | /etc/wireguard/wg0.conf | wg-quick up wg0

### 🔑 Clés générées

Fichier | Utilisation | Visibilité
--------|-------------|------------
client_private | Config client (PrivateKey) | Secrète
client_public | Config serveur (PublicKey Peer) | Partageable
server_private | Config serveur (PrivateKey) | Secrète
server_public | Config client (PublicKey Peer) | Partageable

### 📚 Pour aller plus loin

1. Tester avec 2 machines différentes
   - Remplacer Endpoint = 127.0.0.1:51820 par l'IP réelle du serveur
   - Configurer le firewall pour autoriser le port 51820

2. Ajouter plusieurs clients
   - Créer de nouvelles paires de clés
   - Ajouter des sections [Peer] supplémentaires dans wg1.conf
   - Attribuer des IP différentes (10.0.0.3, 10.0.0.4, etc.)

3. Router tout le trafic via le VPN
   - Changer AllowedIPs = 0.0.0.0/0 dans la config client
   - Configurer le NAT sur le serveur

4. Sécurité avancée
   - Changer régulièrement les clés
   - Utiliser un kill-switch
   - Configurer des règles firewall strictes

---

## 🆘 Aide et dépannage

### Problèmes courants

Le serveur ne démarre pas
sudo journalctl -xe
sudo netstat -tulpn | grep 51820

Pas de "latest handshake"
- Vérifiez que les clés sont correctes dans les configs
- Vérifiez que le serveur est bien démarré
- Redémarrez serveur puis client

Le ping ne fonctionne pas
- Vérifiez que "latest handshake" est présent
- Vérifiez les routes avec ip route show
- Vérifiez le firewall avec sudo ufw status

### Commandes utiles

sudo wg show all

Supprimer complètement la config :
sudo wg-quick down wg0
sudo wg-quick down wg1
sudo rm /etc/wireguard/wg*.conf

Réinitialiser tout :
cd ~/wireguard-keys
rm -f *

---

## 📖 Ressources

- Documentation officielle WireGuard : https://www.wireguard.com/quickstart/
- Forum WireGuard : https://lists.zx2c4.com/mailman/listinfo/wireguard

---

Bon VPN ! 🔐🚀
