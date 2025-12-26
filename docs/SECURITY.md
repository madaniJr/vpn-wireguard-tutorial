# 🔐 Sécurité et Bonnes Pratiques

Guide complet pour utiliser WireGuard de manière sécurisée.

## 🛡️ Sécurité des clés

### Protection de la clé privée

**RÈGLE D'OR :** Votre clé privée est votre identité. Ne la partagez JAMAIS.

```bash
# Permissions correctes
sudo chmod 600 /etc/wireguard/privatekey
sudo chmod 600 /etc/wireguard/wg0.conf

# Vérifier
ls -l /etc/wireguard/
# Devrait afficher: -rw------- (600)
```

---

### Stockage sécurisé

```bash
# Sauvegarder dans un endroit sûr
sudo cp /etc/wireguard/privatekey ~/backup/privatekey.backup

# Chiffrer la sauvegarde
gpg -c ~/backup/privatekey.backup

# Supprimer l'original non chiffré
shred -u ~/backup/privatekey.backup
```

---

### Rotation des clés

**Recommandation :** Changez vos clés tous les 6-12 mois.

```bash
# 1. Générer de nouvelles clés
cd /etc/wireguard
sudo wg genkey | tee privatekey.new | wg pubkey > publickey.new

# 2. Mettre à jour wg0.conf avec la nouvelle clé privée
sudo nano /etc/wireguard/wg0.conf

# 3. Envoyer la nouvelle clé publique à votre serveur

# 4. Redémarrer le VPN
sudo wg-quick down wg0
sudo wg-quick up wg0

# 5. Supprimer les anciennes clés de manière sécurisée
sudo shred -u privatekey.old
```

---

## 🔒 Configuration sécurisée

### Utiliser une PresharedKey

Ajoute une couche de sécurité supplémentaire (protection post-quantique).

```bash
# Générer une clé pré-partagée
wg genpsk > presharedkey

# Dans wg0.conf
[Peer]
PublicKey = CLÉ_PUBLIQUE_SERVEUR
PresharedKey = CONTENU_DE_PRESHAREDKEY
Endpoint = vpn.example.com:51820
AllowedIPs = 0.0.0.0/0
```

---

### DNS sécurisé

Utilisez des DNS qui respectent la vie privée :

```ini
# Cloudflare (privacy-focused)
DNS = 1.1.1.1, 1.0.0.1

# Quad9 (bloque les malwares)
DNS = 9.9.9.9, 149.112.112.112

# Mullvad DNS (anti-tracking)
DNS = 194.242.2.2

# Évitez:
# DNS = 8.8.8.8  # Google (tracking possible)
```

---

### Kill Switch

Empêche toute connexion Internet si le VPN tombe.

**Méthode 1 : Avec PostUp/PostDown**

```ini
[Interface]
PrivateKey = VOTRE_CLÉ
Address = 10.0.0.2/24
DNS = 1.1.1.1

# Bloquer tout sauf le VPN
PostUp = iptables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
PreDown = iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT

[Peer]
PublicKey = CLÉ_SERVEUR
Endpoint = vpn.example.com:51820
AllowedIPs = 0.0.0.0/0
```

**Méthode 2 : Script de kill switch**

```bash
#!/bin/bash
# killswitch.sh

# Bloquer tout le trafic sortant
sudo iptables -P OUTPUT DROP

# Autoriser localhost
sudo iptables -A OUTPUT -o lo -j ACCEPT

# Autoriser le VPN
sudo iptables -A OUTPUT -o wg0 -j ACCEPT

# Autoriser la connexion au serveur VPN
sudo iptables -A OUTPUT -d [IP_SERVEUR_VPN] -j ACCEPT

# Autoriser DNS
sudo iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
```

---

## 🌐 Protection contre les fuites

### Tester les fuites DNS

```bash
# Avant le VPN
nslookup google.com

# Avec le VPN
sudo wg-quick up wg0
nslookup google.com

# Doit utiliser le DNS configuré dans wg0.conf
```

**Sites de test :**
- https://dnsleaktest.com/
- https://www.dnsleaktest.org/
- https://ipleak.net/

---

### Tester les fuites IPv6

```bash
# Désactiver IPv6 si nécessaire
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1

# Rendre permanent
echo "net.ipv6.conf.all.disable_ipv6=1" | sudo tee -a /etc/sysctl.conf
```

Ou dans wg0.conf, incluez IPv6 :
```ini
AllowedIPs = 0.0.0.0/0, ::/0
```

---

### Tester les fuites WebRTC

WebRTC peut révéler votre vraie IP dans le navigateur.

**Firefox :**
1. Tapez `about:config` dans la barre d'adresse
2. Cherchez `media.peerconnection.enabled`
3. Double-cliquez pour mettre à `false`

**Chrome/Brave :**
Installez l'extension "WebRTC Leak Prevent"

**Test :** https://browserleaks.com/webrtc

---

## 🔥 Firewall

### Configuration UFW

```bash
# Installer UFW si nécessaire
sudo apt install ufw -y

# Règles de base
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Autoriser SSH (important!)
sudo ufw allow 22/tcp

# Autoriser WireGuard
sudo ufw allow 51820/udp

# Activer le firewall
sudo ufw enable

# Vérifier
sudo ufw status verbose
```

---

### Configuration iptables avancée

```bash
# Bloquer tout par défaut
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# Autoriser localhost
sudo iptables -A INPUT -i lo -j ACCEPT

# Autoriser les connexions établies
sudo iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Autoriser WireGuard
sudo iptables -A INPUT -p udp --dport 51820 -j ACCEPT

# Sauvegarder les règles
sudo iptables-save | sudo tee /etc/iptables/rules.v4
```

---

## 🕵️ Anonymat et vie privée

### Ce que le VPN protège

✅ **Protégé :**
- Votre adresse IP réelle
- Votre trafic Internet (chiffré)
- Votre localisation approximative
- Votre activité vis-à-vis de votre FAI

❌ **PAS protégé :**
- Cookies et tracking dans le navigateur
- Empreinte digitale du navigateur
- Informations que vous partagez volontairement
- Comptes auxquels vous vous connectez

---

### Améliorer l'anonymat

1. **Utilisez un navigateur axé sur la vie privée**
   - Firefox avec extensions (uBlock Origin, Privacy Badger)
   - Brave
   - Tor Browser (avec VPN)

2. **Bloquez les trackers**
   ```bash
   # Installer Pi-hole
   curl -sSL https://install.pi-hole.net | bash
   ```

3. **Utilisez des conteneurs**
   - Firefox Multi-Account Containers
   - Compartimentez vos activités

4. **Paiement anonyme**
   - Payez votre VPN en crypto-monnaie
   - Utilisez des cartes prépayées

---

## 📱 Sécurité mobile

### Configuration iOS/Android

```ini
# Optimisé pour mobile
[Interface]
PrivateKey = VOTRE_CLÉ
Address = 10.0.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = CLÉ_SERVEUR
Endpoint = vpn.example.com:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25  # Important pour mobile!
```

---

### Économiser la batterie

```ini
# Augmenter l'intervalle keep-alive
PersistentKeepalive = 60

# Ou désactiver complètement
# PersistentKeepalive = 0
# (Peut causer des déconnexions sur certains réseaux)
```

---

## 🚨 Que faire en cas de compromission

### Si vous pensez que votre clé a été compromise

1. **Révoquez immédiatement**
   ```bash
   # Arrêter le VPN
   sudo wg-quick down wg0
   ```

2. **Générez de nouvelles clés**
   ```bash
   cd /etc/wireguard
   sudo wg genkey | tee privatekey.new | wg pubkey > publickey.new
   ```

3. **Informez votre serveur VPN**
   - Envoyez la nouvelle clé publique
   - Demandez la révocation de l'ancienne

4. **Détruisez les anciennes clés**
   ```bash
   sudo shred -u privatekey.old
   sudo shred -u publickey.old
   ```

5. **Auditez vos systèmes**
   - Scannez les malwares
   - Changez tous vos mots de passe
   - Activez l'authentification 2FA

---

## 🔍 Audit et monitoring

### Surveiller l'activité

```bash
# Script de monitoring
watch -n 2 'sudo wg show && echo "---" && ip a show wg0'

# Logs en temps réel
sudo journalctl -u wg-quick@wg0 -f

# Statistiques de trafic
sudo wg show wg0 transfer
```

---

### Alertes automatiques

```bash
#!/bin/bash
# vpn-monitor.sh

while true; do
    if ! sudo wg show wg0 &>/dev/null; then
        echo "⚠️ VPN DOWN!" | mail -s "VPN Alert" votre@email.com
        # Ou utilisez ntfy.sh
        curl -d "VPN is down!" ntfy.sh/votre-topic
    fi
    sleep 60
done
```

---

## 📚 Checklist de sécurité

Avant de déployer en production :

- [ ] Clés privées protégées (chmod 600)
- [ ] PresharedKey configurée
- [ ] DNS sécurisé configuré
- [ ] Kill switch actif
- [ ] Firewall configuré
- [ ] Pas de fuites DNS/IPv6/WebRTC
- [ ] Logs monitored
- [ ] Sauvegarde des clés (chiffrées)
- [ ] Plan de rotation des clés
- [ ] Documentation à jour

---

## ⚠️ Avertissements légaux

- Vérifiez la légalité des VPN dans votre pays
- N'utilisez pas un VPN pour des activités illégales
- Un VPN ne garantit pas l'anonymat total
- Lisez la politique de confidentialité de votre fournisseur
- Certains services peuvent bloquer les VPN

---

## 🔗 Ressources

- [WireGuard Security](https://www.wireguard.com/protocol/)
- [Privacy Tools](https://www.privacytools.io/)
- [That One Privacy Site](https://thatoneprivacysite.net/)
- [r/PrivacyGuides](https://www.reddit.com/r/PrivacyGuides/)

---

**La sécurité est un processus continu, pas un état final !** 🔐
