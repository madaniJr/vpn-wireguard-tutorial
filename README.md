# 🔐 VPN WireGuard - Guide Complet

Un tutoriel pratique pour configurer et utiliser un VPN WireGuard afin de sécuriser votre connexion Internet et protéger votre vie privée.

![WireGuard](https://img.shields.io/badge/WireGuard-Latest-blue)
![Linux](https://img.shields.io/badge/Linux-Ubuntu%20%7C%20Debian-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## 📚 Table des matières

- [Introduction](#introduction)
- [Qu'est-ce qu'un VPN ?](#quest-ce-quun-vpn)
- [Pourquoi WireGuard ?](#pourquoi-wireguard)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration](#configuration)
- [Utilisation](#utilisation)
- [Tests de compréhension](#tests-de-compréhension)
- [TP guidé](#tp-guidé)
- [Dépannage](#dépannage)

## 🎯 Introduction

Ce tutoriel vous guide pas à pas dans la configuration d'un VPN WireGuard pour :
- 🔒 **Sécuriser** votre connexion sur les réseaux publics
- 🕵️ **Protéger** votre vie privée en ligne
- 🌍 **Contourner** les restrictions géographiques
- 🚀 **Bénéficier** d'une connexion VPN rapide et moderne

## 🤔 Qu'est-ce qu'un VPN ?

Un **VPN (Virtual Private Network)** est un réseau privé virtuel qui permet de :

### 🔐 Sécuriser votre connexion
- Chiffrement de toutes vos données
- Protection contre l'espionnage sur Wi-Fi public
- Tunnel sécurisé entre vous et Internet

### 🎭 Protéger votre vie privée
- Masquage de votre adresse IP réelle
- Empêche le suivi par les FAI et sites web
- Anonymisation de votre navigation

### 🌐 Accéder au contenu restreint
- Contournement de la censure
- Accès aux contenus géo-bloqués
- Simulation d'une connexion depuis un autre pays

## 📊 Comment fonctionne un VPN ?

```
┌─────────────┐                                    ┌──────────────┐
│   VOUS      │                                    │   INTERNET   │
│             │                                    │              │
│  🖥️ Client  │                                    │  🌐 Sites Web │
└──────┬──────┘                                    └──────▲───────┘
       │                                                  │
       │  1. Données chiffrées                           │
       │                                                  │
       ▼                                                  │
┌─────────────────────────────────┐                      │
│      🔒 TUNNEL VPN SÉCURISÉ     │                      │
│                                 │                      │
│   Toutes vos données passent    │                      │
│   par un tunnel chiffré         │                      │
└──────────────┬──────────────────┘                      │
               │                                          │
               │  2. Données déchiffrées                 │
               │                                          │
               ▼                                          │
        ┌──────────────┐                                 │
        │ 🖥️ SERVEUR VPN │─────────────────────────────┘
        │              │  3. Votre IP est masquée
        │ IP: 1.2.3.4  │     Le site voit l'IP du serveur
        └──────────────┘
```

## ⚡ Pourquoi WireGuard ?

WireGuard est un protocole VPN moderne qui surpasse les anciennes solutions :

| Critère | WireGuard | OpenVPN | IPSec |
|---------|-----------|---------|-------|
| **Vitesse** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Sécurité** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Simplicité** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐ |
| **Code** | 4000 lignes | 100k+ lignes | Très complexe |
| **Audit** | ✅ Facile | ❌ Difficile | ❌ Très difficile |

### Avantages de WireGuard :
- ✅ **Ultra-rapide** : Performances supérieures
- ✅ **Code minimal** : Plus facile à auditer et sécuriser
- ✅ **Cryptographie moderne** : ChaCha20, Poly1305, Curve25519
- ✅ **Configuration simple** : Quelques lignes suffisent
- ✅ **Économe en batterie** : Idéal pour mobile
- ✅ **Reconnexion rapide** : "Roaming" transparent

### Inconvénients :
- ⚠️ Plus récent (moins d'historique)
- ⚠️ Certains services bloquent les VPN

## 💻 Prérequis

### Système d'exploitation
- Ubuntu 20.04+ / Debian 11+
- Ou autre distribution Linux avec noyau 5.6+

### Accès
- Accès root ou sudo
- Connexion Internet

### Optionnel
- Un serveur VPN WireGuard (ou utilisez un service commercial)

## 🚀 Installation

### Sur Ubuntu/Debian

```bash
# Mettre à jour le système
sudo apt update && sudo apt upgrade -y

( si pb Importe la clé officielle Kali :

mkdir -p /etc/apt/keyrings
curl -fsSL https://archive.kali.org/archive-key.asc | gpg --dearmor -o /etc/apt/keyrings/kali-archive-keyring.gpg


Vérifie que ton dépôt est bien configuré :

nano /etc/apt/sources.list


Il doit contenir exactement :

deb [signed-by=/etc/apt/keyrings/kali-archive-keyring.gpg] http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware

Ensuite :

apt update )

# Installer WireGuard
sudo apt install wireguard -y

# Vérifier l'installation
wg --version
```

### Sur d'autres systèmes

- **Arch Linux** : `sudo pacman -S wireguard-tools`
- **Fedora** : `sudo dnf install wireguard-tools`
- **macOS** : Installer depuis l'App Store
- **Windows** : Télécharger depuis [wireguard.com](https://www.wireguard.com/install/)

## ⚙️ Configuration

### Génération des clés

```bash
# Générer une clé privée
wg genkey | tee privatekey

# Générer la clé publique correspondante
cat privatekey | wg pubkey > publickey

# Afficher les clés (gardez-les secrètes !)
cat privatekey
cat publickey
```

### Fichier de configuration

Créez le fichier `/etc/wireguard/wg0.conf` :

```ini
[Interface]
# Votre clé privée
PrivateKey = VOTRE_CLÉ_PRIVÉE_ICI
# Adresse IP dans le VPN
Address = 10.0.0.2/24
# Serveur DNS à utiliser
DNS = 8.8.8.8, 1.1.1.1

[Peer]
# Clé publique du serveur VPN
PublicKey = CLÉ_PUBLIQUE_DU_SERVEUR
# Adresse du serveur VPN
Endpoint = vpn.monserveur.com:51820
# Tout le trafic passe par le VPN
AllowedIPs = 0.0.0.0/0, ::/0
# Maintenir la connexion active
PersistentKeepalive = 25
```

## 🎮 Utilisation

### Démarrer le VPN

```bash
# Activer la connexion
sudo wg-quick up wg0

# Vérifier le statut
sudo wg show
```

### Arrêter le VPN

```bash
# Désactiver la connexion
sudo wg-quick down wg0
```

### Activer au démarrage

```bash
# Démarrage automatique
sudo systemctl enable wg-quick@wg0

# Démarrer le service
sudo systemctl start wg-quick@wg0

# Vérifier le statut
sudo systemctl status wg-quick@wg0
```

## 🧪 Vérification

### Tester votre IP

```bash
# IP AVANT le VPN
curl ifconfig.me

# Activer le VPN
sudo wg-quick up wg0

# IP APRÈS le VPN (devrait être différente)
curl ifconfig.me

# Informations détaillées
curl ipinfo.io
```

### Tester la connexion

```bash
# Ping vers un serveur
ping -c 4 8.8.8.8

# Tester la vitesse
curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -
```

## ✅ Tests de compréhension

<details>
<summary>1. Quel est le rôle principal d'un VPN ?</summary>

**Réponse : Sécuriser et anonymiser la connexion**

Un VPN chiffre vos données et masque votre adresse IP pour protéger votre vie privée.
</details>

<details>
<summary>2. Quel protocole VPN est réputé pour sa rapidité et sa sécurité ?</summary>

**Réponse : WireGuard**

WireGuard est le protocole le plus moderne et performant actuellement.
</details>

<details>
<summary>3. Que permet un VPN en termes de confidentialité ?</summary>

**Réponse : Masquer l'adresse IP et chiffrer les données**

Le VPN crée un tunnel chiffré et remplace votre IP par celle du serveur VPN.
</details>

<details>
<summary>4. Quel fichier contient la configuration d'un client WireGuard ?</summary>

**Réponse : /etc/wireguard/wg0.conf**

C'est le fichier de configuration standard pour l'interface wg0.
</details>

<details>
<summary>5. Quelle commande permet d'activer une connexion WireGuard ?</summary>

**Réponse : sudo wg-quick up wg0**

Cette commande active l'interface VPN wg0.
</details>

## 📝 TP guidé

Suivez le [guide du TP complet](./TP.md) pour configurer votre VPN étape par étape.

## 🔧 Dépannage

### Le VPN ne se connecte pas

```bash
# Vérifier les logs
sudo journalctl -u wg-quick@wg0 -f

# Vérifier la configuration
sudo wg show

# Tester la connectivité au serveur
ping vpn.monserveur.com
```

### Pas d'accès Internet avec le VPN

```bash
# Vérifier le DNS
cat /etc/resolv.conf

# Tester le DNS
nslookup google.com

# Redémarrer le VPN
sudo wg-quick down wg0
sudo wg-quick up wg0
```

### Problèmes de performances

```bash
# Changer le serveur DNS dans wg0.conf
DNS = 1.1.1.1, 8.8.8.8

# Essayer un autre serveur VPN si possible
# Modifier Endpoint dans wg0.conf
```

## 📚 Ressources

- [Site officiel WireGuard](https://www.wireguard.com/)
- [Documentation WireGuard](https://www.wireguard.com/quickstart/)
- [Protocole cryptographique](https://www.wireguard.com/protocol/)
- [Comparaison des protocoles VPN](https://restoreprivacy.com/vpn/wireguard-vs-openvpn/)

## 🤝 Contribution

Les contributions sont les bienvenues ! Consultez [CONTRIBUTING.md](CONTRIBUTING.md) pour plus de détails.

## 📜 Licence

Ce projet est sous licence MIT. Voir [LICENSE](LICENSE) pour plus de détails.

## ⚠️ Avertissement

- Utilisez un VPN de manière responsable et légale
- Certains pays interdisent l'utilisation de VPN
- Un VPN ne garantit pas l'anonymat total
- Choisissez un fournisseur VPN de confiance

---

⭐ **Si ce tutoriel vous a été utile, n'oubliez pas de mettre une étoile !**

**Créé avec ❤️ pour protéger votre vie privée en ligne**
