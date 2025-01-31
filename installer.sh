#!/bin/bash

IP=$(ip -4 addr show $(ip route show default | awk '/default/ {print $5}') | grep inet | awk '{print $2}')
INTERFACE=$(ip route show default | awk '/default/ {print $5}')

case "$1" in

    install)

        clear

        echo "DDoS protection is installing, please wait."

        echo "Package updates."

        add-apt-repository ppa:ondrej/php
        apt-get update -y >> /dev/null && apt-get upgrade -y >> /dev/null

        echo "Installing modules."

        apt-get install php8.3-{cli,curl} -y >> /dev/null
        apt-get install curl -y >> /dev/null
        apt-get install net-tools -y >> /dev/null
        apt-get install tcpdump -y >> /dev/null
        apt-get install dsniff -y >> /dev/null
        apt-get install grepcidr -y >> /dev/null
        apt-get install vnstat -y >> /dev/null
        apt-get install sysstat -y >> /dev/null
        apt-get install screen -y >> /dev/null
        apt-get install unzip -y >> /dev/null
        apt-get install iptables -y >> /dev/null
        apt-get install ipset -y >> /dev/null
        apt-get install netfilter-persistent -y >> /dev/null
        apt-get install ipset-persistent -y >> /dev/null
        apt-get install nftables -y >> /dev/null

        echo "Network reset."

        iptables -t nat -F
        iptables -t mangle -F && iptables -X
        iptables -t nat -X && iptables -t mangle -X
        iptables -Z && iptables -t nat -Z && iptables -t mangle -Z
        iptables -F INPUT
        
        iptables -Z INPUT
        iptables -P INPUT ACCEPT
        
        iptables -F OUTPUT
        iptables -Z OUTPUT
        iptables -P OUTPUT ACCEPT
        
        iptables -F FORWARD
        iptables -Z FORWARD
        iptables -P FORWARD ACCEPT

        echo "Crontab setup in progress."

        (crontab -l ; echo '@reboot ipset create blacklist hash:ip hashsize 4096 && sudo iptables -I INPUT  -m set --match-set blacklist src -j DROP && sudo iptables -I FORWARD  -m set --match-set blacklist src -j DROP') | crontab -

        #Blocking IP addresses
        #ipset add blacklist 1.1.1.1

        echo "Packet limit is set."

        ulimit -s 256
        ulimit -i 120000

        echo 1 > /proc/sys/net/ipv4/tcp_syncookies
        echo 30 > /proc/sys/net/ipv4/tcp_syn_retries
        echo 120000 > /proc/sys/kernel/threads-max
        echo 600000 > /proc/sys/vm/max_map_count
        echo 200000 > /proc/sys/kernel/pid_max
        echo 1024 > /proc/sys/net/ipv4/tcp_max_syn_backlog
        echo 1 > /proc/sys/net/ipv4/tcp_synack_retries
        echo 30 > /proc/sys/net/ipv4/tcp_fin_timeout
        echo 5 > /proc/sys/net/ipv4/tcp_keepalive_probes
        echo 15 > /proc/sys/net/ipv4/tcp_keepalive_intvl
        echo 20000 > /proc/sys/net/core/netdev_max_backlog
        echo 20000 > /proc/sys/net/core/somaxconn
        echo 1 > /proc/sys/net/ipv4/tcp_syncookies
        echo 0 > /proc/sys/net/ipv4/icmp_echo_ignore_all
        echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
        echo 1 > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses

        for i in /proc/sys/net/ipv4/conf/*/rp_filter; do echo 1 > "$i"; done
        for i in /proc/sys/net/ipv4/conf/*/log_martians; do echo 1 > "$i"; done
        for i in /proc/sys/net/ipv4/conf/*/accept_redirects; do echo 0 > "$i"; done
        for i in /proc/sys/net/ipv4/conf/*/send_redirects; do echo 0 > "$i"; done
        for i in /proc/sys/net/ipv4/conf/*/accept_source_route; do echo 0 > "$i"; done
        for i in /proc/sys/net/ipv4/conf/*/proxy_arp; do echo 0 > "$i"; done
        for i in /proc/sys/net/ipv4/conf/*/secure_redirects; do echo 1 > "$i"; done
        for i in /proc/sys/net/ipv4/conf/*/bootp_relay; do echo 0 > "$i"; done

        echo "Scripts are loading."

        wget https://raw.githubusercontent.com/haker20SZs/haker20szs/refs/heads/main/ddos_logger.php -O ddos_logger.php 2> /dev/null

        echo "Sysctl is configured."

        echo -e "

net.ipv4.tcp_syncookies=1
net.ipv4.tcp_syn_retries=2
net.ipv4.tcp_invalid_ratelimit=1000
net.ipv4.tcp_max_syn_backlog=2048
net.ipv4.tcp_synack_retries=3

net.ipv4.icmp_echo_ignore_all=1
net.ipv4.icmp_echo_ignore_broadcasts=1

net.ipv4.conf.all.rp_filter=1
net.ipv4.ip_forward=0

net.netfilter.nf_conntrack_tcp_timeout_last_ack=10
net.netfilter.nf_conntrack_tcp_timeout_close=5
net.netfilter.nf_conntrack_tcp_timeout_close_wait=5
net.netfilter.nf_conntrack_tcp_timeout_time_wait=5
net.netfilter.nf_conntrack_tcp_timeout_syn_sent=20
net.netfilter.nf_conntrack_tcp_timeout_syn_recv=20
net.netfilter.nf_conntrack_tcp_timeout_fin_wait=25
net.netfilter.nf_conntrack_tcp_timeout_unacknowledged=20
net.netfilter.nf_conntrack_generic_timeout=300
net.netfilter.nf_conntrack_udp_timeout=10
net.netfilter.nf_conntrack_icmp_timeout=2
net.netfilter.nf_conntrack_icmpv6_timeout=3
net.netfilter.nf_conntrack_tcp_loose=0

net.ipv4.conf.all.drop_gratuitous_arp=1
net.ipv4.conf.all.arp_ignore=1
net.ipv4.conf.all.arp_filter=1

net.ipv4.igmp_link_local_mcast_reports=0

net.nf_conntrack_max=20971520
net.netfilter.nf_conntrack_max=20971520

net.ipv4.tcp_fin_timeout=10
net.ipv4.tcp_keepalive_intvl=15
net.ipv4.tcp_tw_reuse=1
net.core.somaxconn=16096
net.ipv4.tcp_keepalive_probes=5
net.netfilter.nf_conntrack_checksum=0

net.ipv4.icmp_ignore_bogus_error_responses=1

" | tee -a /etc/sysctl.conf > /dev/null

        clear
        history -c

        echo -e "✓ Success."

    ;;

    uninstall)

        clear

        echo "Files are deleted."

        apt-get update -y >> /dev/null && apt-get upgrade -y >> /dev/null && apt-get autoremove >> /dev/null
        rm -R /etc/sysctl.conf && touch /etc/sysctl.conf && chmod -R 777 /etc/sysctl.conf
        crontab -l | grep -vF "@reboot ipset create blacklist hash:ip hashsize 4096 && sudo iptables -I INPUT  -m set --match-set blacklist src -j DROP && sudo iptables -I FORWARD  -m set --match-set blacklist src -j DROP" | crontab -
        iptables -P INPUT ACCEPT && iptables -P OUTPUT ACCEPT && iptables -P FORWARD ACCEPT && iptables -t nat -F && iptables -t mangle -F && iptables -X

        clear
        history -c

        echo -e "✓ Success."

    ;;

    *)

        echo "Usage: {install >> uninstall}"

    ;;

esac

version_id=`cat /etc/*-release| tr "\n" " "`

for version_id in '22.04'

do
 
    if [ $version_id == '22.04' ];

        then

            echo "OS check was successful."

        else

            echo "This OS is not supported."

            kill "$$"

            exit
    
    fi
        

done

if [ "$(id -u)" != "0" ]; then

   echo "This script must be run as root" 
   exit 1

fi
