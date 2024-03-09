<?php

    $packet = "10000";

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

    } elseif (empty(shell_exec('which mpstat'))) {

        echo("sysstat не установлен на сервере - apt install sysstat -y." . "\n");

        exit();

    } elseif (empty(shell_exec('which tcpdump'))) {

        echo("tcpdump не установлен на сервере - apt install tcpdump -y." . "\n");

        exit();

    }

    echo("Защита активирована и ожидает атаки." . "\n");

    while (True) {

        $get_cpu = shell_exec('mpstat 1 1 | awk \'/all/ {print 100 - $NF}\'');

        $command = "cat /sys/class/net/$interface/statistics/rx_packets";

        $initialRxPackets = shell_exec($command);

        sleep(1);

        $finalRxPackets = shell_exec($command);

        $packetsPerSecond = $finalRxPackets - $initialRxPackets;

        $cpu_info = shell_exec('cat /proc/cpuinfo');
        $cpu_count = substr_count($cpu_info, "processor");

        if ($get_cpu > (100 / $cpu_count) * 0.75) {

            shell_exec('tcpdump -i ' . $interface . ' -n -c ' . $packet . ' | awk \'{print $3}\' > traffic.log');

            $tempFile = tempnam(sys_get_temp_dir(), 'sort');

            shell_exec("awk '{count[$1]++} END {for (ip in count) print ip, count[ip]}' traffic.log | sort -nr -k2 > $tempFile");

            $getip = shell_exec("head -n 1 $tempFile | awk '{print $1}'");

            unlink($tempFile);

            $explode = explode('.', $getip);
            $ip = ($explode[0] . '.' . $explode[1] . '.' . $explode[2] . '.' . $explode[3]);

            shell_exec("sudo iptables -A OUTPUT -s " . $ip . " -j DROP");

            echo("IP address blocked - " . $ip . "\n");

        } else if ($packetsPerSecond > $packet) {

            shell_exec('tcpdump -i ' . $interface . ' -n -c ' . $packet . ' | awk \'{print $3}\' > traffic.log');

            $tempFile = tempnam(sys_get_temp_dir(), 'sort');

            shell_exec("awk '{count[$1]++} END {for (ip in count) print ip, count[ip]}' traffic.log | sort -nr -k2 > $tempFile");

            $getip = shell_exec("head -n 1 $tempFile | awk '{print $1}'");

            unlink($tempFile);

            $explode = explode('.', $getip);
            $ip = ($explode[0] . '.' . $explode[1] . '.' . $explode[2] . '.' . $explode[3]);
                    
            shell_exec("sudo iptables -A OUTPUT -s " . $ip . " -j DROP");

            echo("IP address blocked - " . $ip . " - " . $packetsPerSecond . "\n");

        }

    }

    //crontab -e || @reboot php /root/antiddos.php

?>
