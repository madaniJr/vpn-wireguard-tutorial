#!/bin/bash

#############################################
# Script d'installation WireGuard
# Auteur: VPN Tutorial
# Description: Installation et configuration automatique
#############################################

set -e  # Arrêter en cas d'erreur

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Fonctions d'affichage
print_header() {
    echo ""
    echo "╔════════════════════════════════════════════╗"
    echo "║  🔐 Installation WireGuard VPN             ║"
    echo "╚════════════════════════════════════════════╝"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Vérifier si root
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        print_error "Ce script doit être exécuté en tant que root"
        echo "Utilisez: sudo $0"
        exit 1
    fi
}

# Détecter le système d'exploitation
detect_os() {
    print_info "Détection du système d'exploitation..."
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
    else
        print_error "Impossible de détecter le système d'exploitation"
        exit 1
    fi
    
    print_success "Système détecté: $OS $VER"
}

# Mettre à jour le système
update_system() {
    print_info "Mise à jour du système..."
    
    case "$OS" in
        ubuntu|debian)
            apt update && apt upgrade -y
            ;;
        centos|rhel|fedora)
            yum update -y || dnf update -y
            ;;
        arch)
            pacman -Syu --noconfirm
            ;;
        *)
            print_warning "Système non reconnu, passage de la mise à jour"
            ;;
    esac
    
    print_success "Système mis à jour"
}

# Installer WireGuard
install_wireguard() {
    print_info "Installation de WireGuard..."
    
    case "$OS" in
        ubuntu|debian)
            apt install wireguard wireguard-tools -y
            ;;
        centos|rhel|fedora)
            yum install wireguard-tools -y || dnf install wireguard-tools -y
            ;;
        arch)
            pacman -S wireguard-tools --noconfirm
            ;;
        *)
            print_error "Installation automatique non supportée pour $OS"
            print_info "Veuillez installer WireGuard manuellement"
            exit 1
            ;;
    esac
    
    print_success "WireGuard installé"
}

# Vérifier l'installation
verify_installation() {
    print_info "Vérification de l'installation..."
    
    if command -v wg &> /dev/null; then
        WG_VERSION=$(wg --version | head -n 1)
        print_success "WireGuard installé: $WG_VERSION"
    else
        print_error "WireGuard n'est pas installé correctement"
        exit 1
    fi
}

# Générer les clés
generate_keys() {
    print_info "Génération des clés cryptographiques..."
    
    # Créer le dossier de configuration
    mkdir -p /etc/wireguard
    chmod 700 /etc/wireguard
    
    # Générer les clés
    cd /etc/wireguard
    wg genkey | tee privatekey | wg pubkey > publickey
    
    # Sécuriser les permissions
    chmod 600 privatekey publickey
    
    print_success "Clés générées avec succès"
    echo ""
    print_info "Clé privée: /etc/wireguard/privatekey"
    print_info "Clé publique: /etc/wireguard/publickey"
}

# Afficher les clés
display_keys() {
    echo ""
    echo "╔════════════════════════════════════════════╗"
    echo "║           🔑 Vos clés générées             ║"
    echo "╚════════════════════════════════════════════╝"
    echo ""
    
    print_warning "CLÉ PRIVÉE (À GARDER SECRÈTE):"
    cat /etc/wireguard/privatekey
    echo ""
    
    print_info "CLÉ PUBLIQUE (Peut être partagée):"
    cat /etc/wireguard/publickey
    echo ""
    
    print_warning "⚠️  Sauvegardez ces clés dans un endroit sûr!"
    echo ""
}

# Créer une configuration exemple
create_sample_config() {
    print_info "Création d'un exemple de configuration..."
    
    PRIVATE_KEY=$(cat /etc/wireguard/privatekey)
    
    cat > /etc/wireguard/wg0.conf.example << EOF
[Interface]
# Votre clé privée
PrivateKey = $PRIVATE_KEY

# Votre adresse IP dans le VPN
Address = 10.0.0.2/24

# Serveurs DNS à utiliser
DNS = 8.8.8.8, 1.1.1.1

[Peer]
# Clé publique du serveur VPN (À OBTENIR DE VOTRE FOURNISSEUR)
PublicKey = REMPLACER_PAR_CLE_PUBLIQUE_SERVEUR

# Adresse du serveur VPN (À OBTENIR DE VOTRE FOURNISSEUR)
Endpoint = vpn.example.com:51820

# Router tout le trafic via le VPN
AllowedIPs = 0.0.0.0/0, ::/0

# Maintenir la connexion active
PersistentKeepalive = 25
EOF

    chmod 600 /etc/wireguard/wg0.conf.example
    
    print_success "Configuration exemple créée: /etc/wireguard/wg0.conf.example"
}

# Installer les outils supplémentaires
install_extras() {
    print_info "Installation d'outils supplémentaires..."
    
    case "$OS" in
        ubuntu|debian)
            apt install -y curl resolvconf qrencode || true
            ;;
        centos|rhel|fedora)
            yum install -y curl qrencode || dnf install -y curl qrencode || true
            ;;
        arch)
            pacman -S curl qrencode --noconfirm || true
            ;;
    esac
    
    print_success "Outils supplémentaires installés"
}

# Afficher les prochaines étapes
show_next_steps() {
    echo ""
    echo "╔════════════════════════════════════════════╗"
    echo "║      ✅ Installation terminée avec succès  ║"
    echo "╚════════════════════════════════════════════╝"
    echo ""
    
    print_info "PROCHAINES ÉTAPES:"
    echo ""
    echo "1️⃣  Obtenez les informations de votre serveur VPN:"
    echo "   - Clé publique du serveur"
    echo "   - Adresse (IP ou domaine) et port du serveur"
    echo ""
    
    echo "2️⃣  Éditez le fichier de configuration:"
    echo "   sudo nano /etc/wireguard/wg0.conf"
    echo ""
    echo "   Utilisez l'exemple comme base:"
    echo "   sudo cp /etc/wireguard/wg0.conf.example /etc/wireguard/wg0.conf"
    echo ""
    
    echo "3️⃣  Activez le VPN:"
    echo "   sudo wg-quick up wg0"
    echo ""
    
    echo "4️⃣  Vérifiez la connexion:"
    echo "   sudo wg show"
    echo "   curl ifconfig.me"
    echo ""
    
    echo "5️⃣  (Optionnel) Activez au démarrage:"
    echo "   sudo systemctl enable wg-quick@wg0"
    echo ""
    
    print_success "🎉 Profitez de votre VPN sécurisé!"
    echo ""
}

# Programme principal
main() {
    print_header
    
    check_root
    detect_os
    
    echo ""
    read -p "Voulez-vous continuer l'installation? (o/N) " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[OoYy]$ ]]; then
        print_info "Installation annulée"
        exit 0
    fi
    
    echo ""
    update_system
    install_wireguard
    verify_installation
    generate_keys
    create_sample_config
    install_extras
    display_keys
    show_next_steps
}

# Exécuter le programme principal
main
