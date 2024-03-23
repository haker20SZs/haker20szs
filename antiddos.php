<?php

    $packetThreshold = "15000";
    $packet = "5000";

    $interface = trim(shell_exec("ip route show default | awk '/default/ {print $5}'"));
    $filename = (__DIR__ . "/" . basename(__FILE__));
    $perms = fileperms($filename);

    if ($perms !== false) {

        $octalPerms = substr(sprintf('%o', $perms), -4);

        if (!($octalPerms === '0777')) {

            echo("Файл " . $filename . " не имеет прав доступа 777" . "\n");

            exit();

        }

    } else {

        echo("Не удалось получить права доступа к файлу " . $filename . "\n");

        exit();

    }

    if (empty(shell_exec('which iptables'))) {

        echo("iptables не установлен на сервере - apt install iptables -y." . "\n");

        exit();

    } else if (empty(shell_exec('which mpstat'))) {

        echo("sysstat не установлен на сервере - apt install sysstat -y." . "\n");

        exit();

    } else if (empty(shell_exec('which tcpdump'))) {

        echo("tcpdump не установлен на сервере - apt install tcpdump -y." . "\n");

        exit();

    } else if (empty(shell_exec('which ufw'))) {

        echo("ufw не установлен на сервере - apt install ufw -y && sudo ufw enable." . "\n");

        exit();

    } else if (empty(shell_exec('which firewalld'))) {

        echo("firewalld не установлен на сервере - apt install firewalld -y && systemctl start firewalld && systemctl enable firewalld." . "\n");

        exit();

    }

    echo("Защита активирована и ожидает атаки." . "\n");

    while (true) {

        $cpuUsage = shell_exec("mpstat 1 1 | awk '/all/ {print 100 - \$NF}'");

        $rxPacketsInitial = shell_exec("cat /sys/class/net/$interface/statistics/rx_packets");

        sleep(5);

        $rxPacketsFinal = shell_exec("cat /sys/class/net/$interface/statistics/rx_packets");
        $packetsPerSecond = $rxPacketsFinal - $rxPacketsInitial;

        if ($cpuUsage > 75 || $packetsPerSecond > $packetThreshold) {

            shell_exec('tcpdump -i ' . $interface . ' -n -c ' . $packetThreshold . ' | awk \'{print $3}\' > traffic.log');

            $tempFile = tempnam(sys_get_temp_dir(), 'sort');

            shell_exec("awk '{count[$1]++} END {for (ip in count) print ip, count[ip]}' traffic.log | sort -nr -k2 > $tempFile");

            $getip = shell_exec("head -n 1 $tempFile | awk '{print $1}'");

            unlink($tempFile);

            $explode = explode('.', $getip);
            $attackIp = ($explode[0] . '.' . $explode[1] . '.' . $explode[2] . '.' . $explode[3]);

            $output = shell_exec("sudo tcpdump -n -c 100 -i " . $interface . " src " . $attackIp);

            $lines = explode("\n", $output);
            $count = 0;

            foreach ($lines as $line) {

                if (preg_match('/(\d+) packets captured/', $line, $matches)) {

                    $count = $matches[1];

                }

            }

            if ($attackIp) {

                if ($count < $packet) {

                    //$log = shell_exec("sudo tcpdump -i " . $interface . " 'src host {$attackIp}'");
                    //$check_ip = shell_exec("sudo firewall-cmd --query-rich-rule='rule family='ipv4' source address='" . $attackIp . "' drop'");

                    echo("Обнаружена атака от IP " . $attackIp . "\n");

                    shell_exec("sudo ufw deny in on " . $interface . " from " . $attackIp);
                    shell_exec("sudo ufw deny in on lo from " . $attackIp);

                    shell_exec("sudo iptables -A INPUT -s " . $attackIp . " -j DROP");
                    shell_exec("sudo iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP");
                    shell_exec("sudo iptables -P OUTPUT DROP");
                    shell_exec("sudo iptables -P FORWARD DROP");
                    shell_exec("sudo iptables -A OUTPUT -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT");
                    shell_exec("sudo iptables -t nat -A PREROUTING -s '" . $attackIp . "' -j DNAT --to-destination '" . $attackIp . "'");
                    shell_exec("sudo sh -c '/sbin/iptables-save > /etc/iptables/rules.v4'");

                    shell_exec("sudo firewall-cmd --permanent --add-rich-rule='rule family='ipv4' source address='" . $attackIp . "' drop'");
                    shell_exec("sudo firewall-cmd --reload");

                }

            }

        }

    }

?>
