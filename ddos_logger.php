<?php

    $packetThreshold = "7500";
    $packet = "5000";

    $interface = trim(shell_exec("ip route show default | awk '/default/ {print $5}' | uniq"));
    $filename = (__DIR__ . "/" . basename(__FILE__));
    $perms = fileperms($filename);

    $data = "@reboot screen -dmS ddos_logger php8.3 " . $filename;

    $crontab = shell_exec('crontab -l');

    if (!(strpos($crontab, $data) !== false)) {

        shell_exec('(crontab -l; echo "' . $data . '") | crontab -');

        exit();

    }

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

    if (empty(shell_exec('which mpstat'))) {

        echo("sysstat не установлен на сервере - apt install sysstat -y." . "\n");

        exit();

    } else if (empty(shell_exec('which tcpdump'))) {

        echo("tcpdump не установлен на сервере - apt install tcpdump -y." . "\n");

        exit();

    } else if (empty(shell_exec('which screen'))) {

        echo("screen не установлен на сервере - apt install screen -y." . "\n");

        exit();

    }

    echo("Защита активирована и ожидает атаки." . "\n");

    while (true) {
        
        $cpuUsage = shell_exec("mpstat 1 1 | awk '/all/ {print 100 - \$NF}'");

        if (is_dir("/sys/class/net/$interface")) {

            $rxPacketsInitial = shell_exec("cat /sys/class/net/$interface/statistics/rx_packets");

            sleep(5);

            $rxPacketsFinal = shell_exec("cat /sys/class/net/$interface/statistics/rx_packets");

        } else {

            echo("Интерфейс $interface не найден." . "\n");

            exit();

        }

        $packetsPerSecond = ($rxPacketsFinal - $rxPacketsInitial) / 5;

        if ($cpuUsage > 75 || $packetsPerSecond > $packetThreshold) {

            $getip = exec('tcpdump -i ' . $interface . ' -n -s 0 -c ' . $packetThreshold . ' | awk \'{print $3}\'');

            $str_ip = strrpos($getip, ".");
            $get_ips = substr($getip, 0, $str_ip);

            if (!empty($get_ips)) {

                $explode = explode('.', $get_ips);

                if (count($explode) == 4) {

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

                            if (!isset($ip) == $attackIp) {

                                unset($ip);

                                $rxPacketsInitial = shell_exec("cat /sys/class/net/$interface/statistics/rx_bytes");

                                sleep(5);

                                $rxPacketsFinal = shell_exec("cat /sys/class/net/$interface/statistics/rx_bytes");
                                $bytesPerSecond = $rxPacketsFinal - $rxPacketsInitial;

                                $mbPerSecond = $bytesPerSecond / 1000000;

                                if (number_format($mbPerSecond, 2) > 10.00) {

                                    $my_ip = shell_exec("ifconfig $interface | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | head -1");

                                    if ($attackIp != $my_ip) {

                                        $supplier = json_decode(file_get_contents("https://ipwho.is/" . $attackIp), true)['connection']['org'];

                                        $title = "** ``🔔`` Оповещение об атаке:**";

                                        $message = "

                                        Обнаружена атака на бота:

                                        > IP адрес атакующего: ``" . $attackIp . "``
                                        > Провайдер атакующего: ``" . onText($supplier, 10) . "``
                                        > Пакетов в секунду: ``" . onText($packetsPerSecond, 30) . "``
                                        > Скорость атаки: ``" . onText(number_format($mbPerSecond, 2), 20) . " MB/s``

                                        Не переживайте, это обычное уведомление
                                        об атаке сервера под защитой.

                                        ";

                                        $webhook_url = 'URL';

                                        onSendMessage(str_replace("  ", "", $message), $title, $webhook_url);

                                        shell_exec("ipset add blacklist $attackIp && ipset save");

                                    }

                                }

                            }

                            $ip = $attackIp;

                        }

                    }

                } else {

                    echo("Неверный IP-адрес: " . $get_ips . "\n");

                }

            } else {

                echo("IP-адрес не найден." . "\n");

            }

        }

    }

    function onText($text, $count) {

        if (strlen($text) > $count) {

            $truncatedText = substr($text, 0, $count) . '...';

        } else {

            $truncatedText = $text;

        }

        return $truncatedText;

    }

    function onSendMessage($message, $title, $webhook_url) {

        $embed_data = [

            'title' => $title,
            'description' => $message,
            'color' => 0xFEE75C,

        ];

        $data = ['embeds' => [$embed_data]];

        $json_data = json_encode($data);

        $ch = curl_init($webhook_url);

        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'POST');
        curl_setopt($ch, CURLOPT_POSTFIELDS, $json_data);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [

            'Content-Type: application/json',
            'Content-Length: ' . strlen($json_data)

        ]);

        curl_exec($ch);

        curl_close($ch);

    }

?>
