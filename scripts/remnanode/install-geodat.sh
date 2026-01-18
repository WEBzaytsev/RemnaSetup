#!/bin/bash

source "/opt/remnasetup/scripts/common/colors.sh"
source "/opt/remnasetup/scripts/common/functions.sh"
source "/opt/remnasetup/scripts/common/languages.sh"

install_geodat() {
    info "$(get_string "install_geodat_start")"
    
    if [ ! -d "/opt/remnanode" ]; then
        error "$(get_string "install_geodat_node_not_found")"
        read -n 1 -s -r -p "$(get_string "install_geodat_press_key")"
        exit 1
    fi
    
    mkdir -p /opt/remnanode/geodat
    
    info "$(get_string "install_geodat_downloading_geoip")"
    curl -fsSL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -o /opt/remnanode/geodat/geoip.dat || {
        error "$(get_string "install_geodat_geoip_failed")"
    }
    
    info "$(get_string "install_geodat_downloading_geosite")"
    curl -fsSL https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -o /opt/remnanode/geodat/geosite.dat || {
        error "$(get_string "install_geodat_geosite_failed")"
    }
    
    if ! grep -q "geoip.dat" /opt/remnanode/docker-compose.yml 2>/dev/null; then
        info "$(get_string "install_geodat_updating_compose")"
        sed -i '/\/var\/log\/remnanode/a\      - /opt/remnanode/geodat/geoip.dat:/usr/local/share/xray/geoip.dat' /opt/remnanode/docker-compose.yml
        sed -i '/geoip.dat/a\      - /opt/remnanode/geodat/geosite.dat:/usr/local/share/xray/geosite.dat' /opt/remnanode/docker-compose.yml
        
        info "$(get_string "install_geodat_restarting")"
        cd /opt/remnanode
        docker compose down
        docker compose up -d
    fi
    
    success "$(get_string "install_geodat_complete")"
}

main() {
    install_geodat
    read -n 1 -s -r -p "$(get_string "install_geodat_press_key")"
    exit 0
}

main
