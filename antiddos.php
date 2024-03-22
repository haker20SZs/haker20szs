<?php

    $packetThreshold = "15000";

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

            if ($attackIp) {

                echo("Обнаружена атака от IP " . $attackIp . "\n");

            }

        }

    }

?>
