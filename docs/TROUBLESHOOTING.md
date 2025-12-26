# 🔧 Guide de dépannage WireGuard

Ce guide vous aide à résoudre les problèmes courants avec WireGuard.

## 📋 Diagnostic de base

### Vérifier si WireGuard est installé

```bash
wg --version
```

**Résultat attendu :** `wireguard-tools vX.X.X`

**Si erreur :** Réinstallez WireGuard
```bash
sudo apt update
sudo apt install wireguard -y
```

---

### Vérifier le statut du VPN

```bash
sudo wg show
```

**Si "Unable to access interface: No such device"**
→ Le VPN n'est pas actif

**Si affiche des informations**
→ Le VPN est actif ✅

---

## 🚫 Le VPN ne démarre pas

### Erreur : "RTNETLINK answers: Operation not permitted"

**Cause :** Pas de privilèges root

**Solution :**
```bash
sudo wg-quick up wg0
```

---

### Erreur : "Unable to access interface wg0"

**Cause :** Le module WireGuard n'est pas chargé

**Solution :**
```bash
# Charger le module
sudo modprobe wireguard

# Vérifier
lsmod | grep wireguard
```

---

### Erreur : "Configuration parsing error"

**Cause :** Erreur de syntaxe dans wg0.conf

**Solution :**
```bash
# Vérifier la syntaxe
sudo cat /etc/wireguard/wg0.conf

# Vérifier les permissions
ls -l /etc/wireguard/wg0.conf
# Devrait être : -rw------- (600)

# Corriger si nécessaire
sudo chmod 600 /etc/wireguard/wg0.conf
```

---

### Erreur : "Name or service not known"

**Cause :** Impossible de résoudre le nom de domaine du serveur

**Solution :**
```bash
# Tester la résolution DNS
nslookup vpn.monserveur.com

# Si ça ne marche pas, utilisez l'IP directement
# Dans wg0.conf, remplacez:
# Endpoint = vpn.monserveur.com:51820
# Par:
# Endpoint = 203.0.113.1:51820
```

---

## 🌐 Pas d'accès Internet avec le VPN

### Vérifier le DNS

```bash
# Voir le DNS actuel
cat /etc/resolv.conf

# Tester la résolution
nslookup google.com

# Si erreur, essayez un autre DNS dans wg0.conf
DNS = 1.1.1.1, 8.8.8.8
```

---

### Vérifier le routage

```bash
# Afficher les routes
ip route show

# Devrait contenir une ligne avec wg0
# Exemple: default dev wg0 scope link
```

**Si pas de route via wg0 :**
```bash
# Redémarrer le VPN
sudo wg-quick down wg0
sudo wg-quick up wg0
```

---

### Vérifier AllowedIPs

```bash
sudo wg show wg0 allowed-ips
```

**Pour tout router via le VPN, devrait afficher :**
```
peer [clé publique]: 0.0.0.0/0, ::/0
```

**Si différent :** Modifiez wg0.conf
```ini
AllowedIPs = 0.0.0.0/0, ::/0
```

---

## 🐌 Connexion lente

### Test de vitesse

```bash
# Installer speedtest
sudo apt install speedtest-cli -y

# Test SANS VPN
sudo wg-quick down wg0
speedtest-cli

# Test AVEC VPN
sudo wg-quick up wg0
speedtest-cli
```

---

### Optimisations possibles

#### 1. Changer le MTU

Dans `/etc/wireguard/wg0.conf` :
```ini
[Interface]
MTU = 1420
# Essayez aussi: 1380, 1350, 1280
```

#### 2. Changer le serveur DNS

```ini
DNS = 1.1.1.1, 1.0.0.1  # Cloudflare (rapide)
# ou
DNS = 9.9.9.9           # Quad9
```

#### 3. Essayer un autre serveur VPN

Si votre fournisseur propose plusieurs serveurs, essayez-en d'autres.

---

## 🔌 Déconnexions fréquentes

### Augmenter le keep-alive

Dans `/etc/wireguard/wg0.conf` :
```ini
[Peer]
PersistentKeepalive = 15  # Au lieu de 25
```

---

### Vérifier les logs

```bash
# Logs en temps réel
sudo journalctl -u wg-quick@wg0 -f

# Derniers logs
sudo journalctl -u wg-quick@wg0 -n 50
```

---

## 🔥 Problèmes de firewall

### UFW bloque le VPN

```bash
# Autoriser le port WireGuard
sudo ufw allow 51820/udp

# Recharger
sudo ufw reload
```

---

### Autoriser le forwarding

```bash
# Vérifier
cat /proc/sys/net/ipv4/ip_forward
# Devrait afficher: 1

# Si 0, activer:
sudo sysctl -w net.ipv4.ip_forward=1

# Rendre permanent:
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
```

---

## 📱 Problèmes spécifiques mobile

### Pas de connexion en 4G/5G

**Cause :** Certains opérateurs bloquent les VPN

**Solutions :**
1. Changer le port dans wg0.conf (essayez 443, 80, 53)
2. Contacter votre opérateur
3. Essayer un autre opérateur

---

### Batterie se vide rapidement

**Solution :**
```ini
# Augmenter l'intervalle keep-alive
PersistentKeepalive = 60  # Au lieu de 25
```

---

## 🔍 Commandes de diagnostic

### Informations complètes

```bash
# Statut détaillé
sudo wg show all

# Configuration active
sudo wg showconf wg0

# Routes
ip route show table all

# Interfaces réseau
ip addr show

# DNS
resolvectl status
```

---

### Tester la connexion au serveur

```bash
# Ping
ping -c 4 [IP_DU_SERVEUR]

# Traceroute
traceroute [IP_DU_SERVEUR]

# Port ouvert?
nc -zvu [IP_DU_SERVEUR] 51820
```

---

## 🆘 Réinitialisation complète

Si rien ne fonctionne :

```bash
# 1. Arrêter le VPN
sudo wg-quick down wg0

# 2. Désactiver le service
sudo systemctl disable wg-quick@wg0
sudo systemctl stop wg-quick@wg0

# 3. Sauvegarder la config
sudo cp /etc/wireguard/wg0.conf /tmp/wg0.conf.backup

# 4. Supprimer la config
sudo rm /etc/wireguard/wg0.conf

# 5. Recréer depuis zéro
# Suivez le guide d'installation

# 6. Restaurer si besoin
sudo cp /tmp/wg0.conf.backup /etc/wireguard/wg0.conf
```

---

## 📞 Obtenir de l'aide

### Informations à fournir

Quand vous demandez de l'aide, fournissez :

```bash
# Version de WireGuard
wg --version

# Système d'exploitation
cat /etc/os-release

# Statut
sudo wg show

# Logs (dernières lignes)
sudo journalctl -u wg-quick@wg0 -n 50

# Routes
ip route show

# Configuration (CENSUREZ les clés!)
sudo cat /etc/wireguard/wg0.conf | sed 's/PrivateKey.*/PrivateKey = [HIDDEN]/g'
```

---

## 🔗 Ressources utiles

- [Documentation officielle](https://www.wireguard.com/)
- [FAQ WireGuard](https://www.wireguard.com/faq/)
- [Reddit r/WireGuard](https://www.reddit.com/r/WireGuard/)
- [Forum Arch Linux](https://bbs.archlinux.org/)

---

## ⚠️ Sécurité

**Ne partagez JAMAIS :**
- Votre clé privée
- Votre configuration complète
- L'adresse réelle de votre serveur VPN

**Quand vous partagez des logs/configs pour debug :**
- Censurez les clés privées
- Remplacez les IPs réelles par des exemples
- Utilisez `sed` pour masquer automatiquement

---

**Vous ne trouvez pas votre problème ?** Ouvrez une issue sur GitHub ! 🐛
