# 🎓 TP : Configuration d'un VPN WireGuard

Guide pratique pour configurer et tester un VPN WireGuard sur votre système.

## 🎯 Objectifs du TP

À la fin de ce TP, vous serez capable de :
- ✅ Installer WireGuard sur votre système
- ✅ Générer des clés cryptographiques
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

```bash
sudo apt update && sudo apt upgrade -y
```

**Pourquoi ?** Pour avoir les dernières versions des paquets et correctifs de sécurité.

#### 1.2 Installer WireGuard

```bash
sudo apt install wireguard -y
```

#### 1.3 Vérifier l'installation

```bash
wg --version
```

**Résultat attendu :**
```
wireguard-tools v1.x.x
```

### ✅ Critères de validation

- [ ] La commande `wg --version` affiche une version
- [ ] Aucune erreur lors de l'installation

### 💡 Questions de réflexion

1. Pourquoi est-il important de mettre à jour le système avant d'installer ?
2. Que se passe-t-il si WireGuard n'est pas dans les dépôts ?

<details>
<summary>💡 Voir les réponses</summary>

1. Pour éviter les conflits de dépendances et avoir les derniers correctifs de sécurité
2. Il faut ajouter le dépôt officiel WireGuard ou compiler depuis les sources
</details>

---

## Étape 2 : Générer les clés cryptographiques

### 🎯 Objectif
Créer une paire de clés (privée/publique) pour l'authentification.

### 📝 Instructions

#### 2.1 Créer un dossier pour les clés

```bash
mkdir -p ~/wireguard-keys
cd ~/wireguard-keys
```

#### 2.2 Générer la clé privée

```bash
wg genkey | tee privatekey
```

**Ce qui se passe :**
- `wg genkey` : Génère une clé privée aléatoire
- `tee privatekey` : Affiche ET sauvegarde dans le fichier

#### 2.3 Générer la clé publique

```bash
cat privatekey | wg pubkey > publickey
```

**Ce qui se passe :**
- On lit la clé privée
- On génère la clé publique correspondante
- On sauvegarde dans `publickey`

#### 2.4 Afficher les clés

```bash
echo "=== Clé privée (À GARDER SECRÈTE) ==="
cat privatekey
echo ""
echo "=== Clé publique (Peut être partagée) ==="
cat publickey
```

#### 2.5 Sécuriser les permissions

```bash
# Seul le propriétaire peut lire la clé privée
chmod 600 privatekey

# Vérifier les permissions
ls -l
```

### ✅ Critères de validation

- [ ] Les fichiers `privatekey` et `publickey` existent
- [ ] Les deux clés sont différentes
- [ ] La clé privée a les permissions 600 (-rw-------)

### 💡 Questions de réflexion

1. Pourquoi la clé privée doit-elle rester secrète ?
2. Que se passe-t-il si quelqu'un obtient votre clé privée ?
3. Peut-on régénérer la même clé publique à partir de la clé privée ?

<details>
<summary>💡 Voir les réponses</summary>

1. C'est votre identité numérique. Avec elle, quelqu'un peut se faire passer pour vous.
2. Il peut se connecter au VPN en se faisant passer pour vous et voir tout votre trafic.
3. Oui ! La clé publique est mathématiquement dérivée de la clé privée (mais pas l'inverse).
</details>

---

## Étape 3 : Configurer le client VPN

### 🎯 Objectif
Créer le fichier de configuration WireGuard.

### 📝 Instructions

#### 3.1 Créer le fichier de configuration

```bash
sudo nano /etc/wireguard/wg0.conf
```

#### 3.2 Ajouter la configuration

Copiez cette configuration et **remplacez les valeurs** :

```ini
[Interface]
# Votre clé privée générée à l'étape 2
PrivateKey = VOTRE_CLÉ_PRIVÉE_ICI

# Votre adresse IP dans le réseau VPN
# Le /24 signifie un sous-réseau de 256 adresses
Address = 10.0.0.2/24

# Serveurs DNS à utiliser quand le VPN est actif
# 8.8.8.8 = Google DNS
# 1.1.1.1 = Cloudflare DNS
DNS = 8.8.8.8, 1.1.1.1

[Peer]
# Clé publique du SERVEUR VPN
# Vous devez l'obtenir de votre fournisseur VPN
PublicKey = CLÉ_PUBLIQUE_DU_SERVEUR

# Adresse et port du serveur VPN
# Format: domaine.com:port ou IP:port
Endpoint = vpn.monserveur.com:51820

# Quelles IP router via le VPN
# 0.0.0.0/0 = Tout le trafic IPv4
# ::/0 = Tout le trafic IPv6
AllowedIPs = 0.0.0.0/0, ::/0

# Envoyer un paquet keep-alive toutes les 25 secondes
# Utile pour maintenir la connexion à travers les NAT
PersistentKeepalive = 25
```

#### 3.3 Comprendre la configuration

| Section | Paramètre | Description |
|---------|-----------|-------------|
| **Interface** | PrivateKey | Votre identité cryptographique |
| | Address | Votre IP dans le VPN |
| | DNS | Serveurs DNS à utiliser |
| **Peer** | PublicKey | Identité du serveur VPN |
| | Endpoint | Où se connecter |
| | AllowedIPs | Quel trafic router |
| | PersistentKeepalive | Maintien de connexion |

#### 3.4 Sauvegarder et fermer

```
CTRL + X
Y (pour Yes)
ENTRÉE
```

#### 3.5 Vérifier la configuration

```bash
sudo cat /etc/wireguard/wg0.conf
```

#### 3.6 Sécuriser le fichier

```bash
sudo chmod 600 /etc/wireguard/wg0.conf
```

### ✅ Critères de validation

- [ ] Le fichier `/etc/wireguard/wg0.conf` existe
- [ ] Toutes les valeurs sont remplies (pas de "VOTRE_CLÉ" restant)
- [ ] Les permissions sont 600

### 💡 Questions de réflexion

1. Pourquoi utilise-t-on `AllowedIPs = 0.0.0.0/0` ?
2. Que se passerait-il avec `AllowedIPs = 192.168.1.0/24` ?
3. À quoi sert `PersistentKeepalive` ?

<details>
<summary>💡 Voir les réponses</summary>

1. Pour router TOUT le trafic via le VPN (split tunneling désactivé)
2. Seul le trafic vers 192.168.1.x passerait par le VPN (split tunneling)
3. À maintenir la connexion active même sans trafic, évite les déconnexions NAT
</details>

---

## Étape 4 : Établir la connexion VPN

### 🎯 Objectif
Activer le VPN et vérifier la connexion.

### 📝 Instructions

#### 4.1 Vérifier votre IP AVANT le VPN

```bash
echo "=== Votre IP actuelle ==="
curl ifconfig.me
echo ""
echo "=== Informations détaillées ==="
curl ipinfo.io
```

**Notez ces informations !** Vous les comparerez après.

#### 4.2 Activer le VPN

```bash
sudo wg-quick up wg0
```

**Résultat attendu :**
```
[#] ip link add wg0 type wireguard
[#] wg setconf wg0 /dev/fd/63
[#] ip -4 address add 10.0.0.2/24 dev wg0
[#] ip link set mtu 1420 up dev wg0
[#] resolvconf -a wg0 -m 0 -x
[#] wg set wg0 fwmark 51820
[#] ip -4 route add 0.0.0.0/0 dev wg0 table 51820
[#] ip -4 rule add not fwmark 51820 table 51820
[#] ip -4 rule add table main suppress_prefixlength 0
[#] sysctl -q net.ipv4.conf.all.src_valid_mark=1
[#] nft -f /dev/fd/63
```

#### 4.3 Vérifier le statut

```bash
sudo wg show
```

**Résultat attendu :**
```
interface: wg0
  public key: [votre clé publique]
  private key: (hidden)
  listening port: [port]

peer: [clé publique du serveur]
  endpoint: [IP:port du serveur]
  allowed ips: 0.0.0.0/0, ::/0
  latest handshake: [temps depuis la connexion]
  transfer: [données reçues] received, [données envoyées] sent
```

#### 4.4 Vérifier votre nouvelle IP

```bash
echo "=== Votre nouvelle IP (via VPN) ==="
curl ifconfig.me
echo ""
echo "=== Informations détaillées ==="
curl ipinfo.io
```

**L'IP doit être différente !** Elle devrait être celle du serveur VPN.

#### 4.5 Tester la connectivité

```bash
# Test ping
ping -c 4 8.8.8.8

# Test DNS
nslookup google.com

# Test web
curl -I https://www.google.com
```

### ✅ Critères de validation

- [ ] La commande `wg-quick up wg0` réussit sans erreur
- [ ] `wg show` affiche des informations de connexion
- [ ] Votre IP publique a changé
- [ ] Vous pouvez naviguer sur Internet

### 💡 En cas d'erreur

**Erreur : "Cannot find device wg0"**
```bash
# Vérifier que le module est chargé
sudo modprobe wireguard
```

**Erreur : "Cannot resolve host"**
```bash
# Vérifier le DNS
cat /etc/resolv.conf
# Essayer avec une IP directement dans Endpoint
```

**Pas de connexion Internet**
```bash
# Vérifier les routes
ip route show
# Redémarrer le VPN
sudo wg-quick down wg0
sudo wg-quick up wg0
```

---

## Étape 5 : Tests et vérifications avancés

### 🎯 Objectif
S'assurer que le VPN fonctionne correctement et en toute sécurité.

### 📝 Instructions

#### 5.1 Test de fuite DNS

```bash
# Vérifier quel DNS est utilisé
nslookup google.com

# Ou utiliser un site de test
curl https://www.dnsleaktest.com/
```

**Résultat attendu :** Vous devriez voir les DNS configurés dans wg0.conf (8.8.8.8).

#### 5.2 Test de fuite WebRTC

Ouvrez votre navigateur et allez sur :
- https://browserleaks.com/webrtc
- https://ipleak.net/

**Résultat attendu :** Seule l'IP du VPN doit apparaître.

#### 5.3 Test de vitesse

```bash
# Installer speedtest-cli
sudo apt install speedtest-cli -y

# Test SANS VPN
sudo wg-quick down wg0
speedtest-cli

# Test AVEC VPN
sudo wg-quick up wg0
speedtest-cli
```

Comparez les résultats !

#### 5.4 Monitorer la connexion

```bash
# Afficher les stats en temps réel
watch -n 1 sudo wg show
```

Ouvrez un navigateur et naviguez. Vous verrez les statistiques changer.

#### 5.5 Logs et débogage

```bash
# Voir les logs système
sudo journalctl -u wg-quick@wg0 -f

# Ou dans les logs généraux
sudo dmesg | grep wireguard
```

### ✅ Critères de validation

- [ ] Pas de fuite DNS détectée
- [ ] Seule l'IP VPN est visible
- [ ] La connexion est stable
- [ ] Internet fonctionne correctement

---

## Étape 6 : Gestion du VPN

### 🎯 Objectif
Apprendre à gérer le VPN au quotidien.

### 📝 Instructions

#### 6.1 Arrêter le VPN

```bash
sudo wg-quick down wg0
```

#### 6.2 Redémarrer le VPN

```bash
sudo wg-quick down wg0 && sudo wg-quick up wg0
```

#### 6.3 Activer au démarrage du système

```bash
# Activer le service
sudo systemctl enable wg-quick@wg0

# Démarrer maintenant
sudo systemctl start wg-quick@wg0

# Vérifier le statut
sudo systemctl status wg-quick@wg0
```

#### 6.4 Désactiver le démarrage automatique

```bash
sudo systemctl disable wg-quick@wg0
sudo systemctl stop wg-quick@wg0
```

#### 6.5 Script de gestion rapide

Créez un script pratique :

```bash
nano ~/vpn.sh
```

Contenu :

```bash
#!/bin/bash

case "$1" in
    start|up|on)
        sudo wg-quick up wg0
        echo "✅ VPN activé"
        ;;
    stop|down|off)
        sudo wg-quick down wg0
        echo "❌ VPN désactivé"
        ;;
    status)
        sudo wg show
        ;;
    ip)
        curl ifconfig.me
        ;;
    *)
        echo "Usage: $0 {start|stop|status|ip}"
        exit 1
        ;;
esac
```

Rendre exécutable :

```bash
chmod +x ~/vpn.sh
```

Utiliser :

```bash
~/vpn.sh start   # Démarrer
~/vpn.sh stop    # Arrêter
~/vpn.sh status  # Voir le statut
~/vpn.sh ip      # Voir l'IP actuelle
```

---

## 🎉 Conclusion

Félicitations ! Vous avez maintenant :
- ✅ Installé WireGuard
- ✅ Configuré un client VPN
- ✅ Établi une connexion sécurisée
- ✅ Testé et vérifié la connexion
- ✅ Appris à gérer le VPN

### 📚 Pour aller plus loin

1. **Configurer votre propre serveur VPN**
   - Installer WireGuard sur un VPS
   - Configurer le forwarding IP
   - Gérer plusieurs clients

2. **Split tunneling**
   - Router seulement certains sites via le VPN
   - Conserver la vitesse maximale pour le reste

3. **VPN sur mobile**
   - Installer l'application WireGuard
   - Scanner le QR code de configuration

4. **Sécurité avancée**
   - Changer régulièrement les clés
   - Utiliser des kill-switch
   - Configurer des règles firewall

---

## 🆘 Aide et support

- 📖 [Documentation officielle](https://www.wireguard.com/quickstart/)
- 💬 [Forum WireGuard](https://lists.zx2c4.com/mailman/listinfo/wireguard)
- 🐛 Problèmes ? Ouvrez une issue sur GitHub

---

**Bon VPN ! 🔐🚀**
