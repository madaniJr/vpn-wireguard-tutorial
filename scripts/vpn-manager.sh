#!/bin/bash

#############################################
# Script de gestion WireGuard
# Auteur: VPN Tutorial
# Description: Gestion simplifiée du VPN
#############################################

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Interface WireGuard
INTERFACE="wg0"

# Fonction d'affichage
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

# Vérifier si l'utilisateur est root
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        print_error "Ce script doit être exécuté en tant que root (utilisez sudo)"
        exit 1
    fi
}

# Démarrer le VPN
start_vpn() {
    print_info "Démarrage du VPN..."
    
    if wg-quick up "$INTERFACE" 2>/dev/null; then
        print_success "VPN activé avec succès"
        sleep 1
        show_ip
    else
        print_error "Erreur lors du démarrage du VPN"
        print_info "Le VPN est peut-être déjà actif. Essayez 'status' ou 'restart'"
        exit 1
    fi
}

# Arrêter le VPN
stop_vpn() {
    print_info "Arrêt du VPN..."
    
    if wg-quick down "$INTERFACE" 2>/dev/null; then
        print_success "VPN désactivé avec succès"
    else
        print_error "Erreur lors de l'arrêt du VPN"
        print_info "Le VPN est peut-être déjà inactif"
        exit 1
    fi
}

# Redémarrer le VPN
restart_vpn() {
    print_info "Redémarrage du VPN..."
    stop_vpn
    sleep 2
    start_vpn
}

# Afficher le statut
show_status() {
    print_info "État du VPN:"
    echo ""
    
    if wg show "$INTERFACE" &>/dev/null; then
        wg show "$INTERFACE"
        echo ""
        print_success "VPN est ACTIF"
    else
        print_error "VPN est INACTIF"
    fi
}

# Afficher l'IP publique
show_ip() {
    print_info "Récupération de votre IP publique..."
    
    IP=$(curl -s --max-time 5 ifconfig.me)
    
    if [ -n "$IP" ]; then
        echo ""
        echo "┌────────────────────────────────┐"
        echo "│  🌐 Votre IP publique :        │"
        echo "│     $IP"
        echo "└────────────────────────────────┘"
        echo ""
        
        # Informations détaillées
        print_info "Récupération des informations détaillées..."
        curl -s ipinfo.io 2>/dev/null | grep -E "ip|city|region|country|org" || true
    else
        print_error "Impossible de récupérer l'IP (pas de connexion Internet?)"
    fi
}

# Test de connexion
test_connection() {
    print_info "Test de connexion..."
    echo ""
    
    # Test ping
    print_info "Test ping vers 8.8.8.8..."
    if ping -c 3 -W 2 8.8.8.8 &>/dev/null; then
        print_success "Ping OK"
    else
        print_error "Ping échoué"
    fi
    
    # Test DNS
    print_info "Test de résolution DNS..."
    if nslookup google.com &>/dev/null; then
        print_success "DNS OK"
    else
        print_error "DNS échoué"
    fi
    
    # Test HTTP
    print_info "Test de connexion web..."
    if curl -s --max-time 5 -I https://www.google.com &>/dev/null; then
        print_success "Connexion web OK"
    else
        print_error "Connexion web échouée"
    fi
    
    echo ""
    print_success "Tests terminés"
}

# Afficher les logs
show_logs() {
    print_info "Derniers logs du VPN (appuyez sur CTRL+C pour quitter):"
    echo ""
    journalctl -u wg-quick@"$INTERFACE" -f
}

# Afficher l'aide
show_help() {
    cat << EOF
┌──────────────────────────────────────────────────────┐
│           🔐 Script de gestion VPN WireGuard         │
└──────────────────────────────────────────────────────┘

Usage: sudo $0 [COMMANDE]

COMMANDES DISPONIBLES:

  start, up, on        Démarrer le VPN
  stop, down, off      Arrêter le VPN
  restart              Redémarrer le VPN
  status               Afficher le statut du VPN
  ip                   Afficher l'IP publique
  test                 Tester la connexion
  logs                 Afficher les logs en temps réel
  help, -h, --help     Afficher cette aide

EXEMPLES:

  sudo $0 start        # Démarrer le VPN
  sudo $0 status       # Voir le statut
  sudo $0 ip           # Voir votre IP actuelle
  sudo $0 test         # Tester la connexion

NOTES:

  - Ce script doit être exécuté avec sudo
  - L'interface par défaut est: $INTERFACE
  - Configuration: /etc/wireguard/$INTERFACE.conf

EOF
}

# Programme principal
main() {
    # Vérifier les privilèges root pour certaines commandes
    case "$1" in
        ip)
            # Pas besoin de root pour afficher l'IP
            show_ip
            ;;
        help|-h|--help)
            # Pas besoin de root pour l'aide
            show_help
            ;;
        *)
            # Toutes les autres commandes nécessitent root
            check_root
            
            case "$1" in
                start|up|on)
                    start_vpn
                    ;;
                stop|down|off)
                    stop_vpn
                    ;;
                restart|reboot)
                    restart_vpn
                    ;;
                status|state)
                    show_status
                    ;;
                test|check)
                    test_connection
                    ;;
                logs|log)
                    show_logs
                    ;;
                "")
                    print_error "Aucune commande spécifiée"
                    echo ""
                    show_help
                    exit 1
                    ;;
                *)
                    print_error "Commande inconnue: $1"
                    echo ""
                    show_help
                    exit 1
                    ;;
            esac
            ;;
    esac
}

# Exécuter le programme principal
main "$@"
