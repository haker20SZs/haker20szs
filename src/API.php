<?php

if($curl = curl_init()){

    $headers = [];

    $post_data = [
        'lang' => $_GET["lang"],
        'text' => $_GET["text"],
        'key' => "Z2ZqNDc4anM0ZGE",
    ];

    $post_data = http_build_query($post_data);

    $method = 'AES-192-CBC';
    $decrypted = openssl_decrypt("2mdUqb3+qxAeFHuYhlrjPBNoqrx4OY1BzeqIMxKovfAbiucdAV/DrGF7G16cyrFn7VgZF9+9OyD5IFhecKALxw==", $method, base64_decode("WmxvZ2dlcg=="));
    $url = ((!empty($_SERVER['HTTPS'])) ? 'https' : 'http') . base64_decode($decrypted);

    curl_setopt($curl, CURLOPT_URL, $url . '/src/API.php');
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($curl, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($curl, CURLOPT_VERBOSE, true);
    curl_setopt($curl, CURLOPT_POSTFIELDS, $post_data);
    curl_setopt($curl, CURLOPT_POST, true);

    $result = curl_exec($curl);
    $error = curl_error($curl);

    if($error){

        print_R($error);

    } else {

        print_R($result);

    }
    
    curl_close($curl);
    
}

?>