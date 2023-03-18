<?php

if($curl = curl_init()){

    $headers = [];

    $post_data = [
        'lang' => $_POST["lang"],
        'text' => $_POST["text"],
        'key' => "Z2ZqNDc4anM0ZGE",
    ];

    $post_data = http_build_query($post_data);

    $method = 'aes-256-cbc';
    $url_file = "aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL2hha2VyMjBTWnMvaGFrZXIyMHN6cy9tYWluL3NyYy91cmwuanNvbg==";
    $file = json_decode(file_get_contents(base64_decode($url_file)), true)['url'];
    $password = substr(hash('sha256', base64_decode("ZmppcTg5NDNoMXM="), true), 0, 32);
    $iv = chr(0x0) . chr(0x0) . chr(0x0) . chr(0x0) . chr(0x0) . chr(0x0) . chr(0x0) . chr(0x0) . chr(0x0) . chr(0x0) . chr(0x0) . chr(0x0) . chr(0x0) . chr(0x0) . chr(0x0) . chr(0x0);
    $decrypted = openssl_decrypt(base64_decode($file), $method, $password, OPENSSL_RAW_DATA, $iv);
    $url = ((!empty($_SERVER['HTTPS'])) ? 'https' : 'http') . $decrypted;
    
    curl_setopt($curl, CURLOPT_URL, $url . '/src/API.php');
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($curl, CURLOPT_HTTPHEADER, $headers);
    curl_setopt($curl, CURLOPT_VERBOSE, true);
    curl_setopt($curl, CURLOPT_POSTFIELDS, $post_data);
    curl_setopt($curl, CURLOPT_POST, true);

    $exec = curl_exec($curl);

    $get_text = json_decode($exec, true)['text'];
    
    curl_close($curl);
}

?>

<!DOCTYPE html>
<html>
<head>
    <title>Test Lang API - 1.0.0</title>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width,initial-scale=1,shrink-to-fit=no">
</head>
<body>
    <h3>Форма переводчика ATLORS - TEST</h3>
    <form method="POST">

        <p>Текст: <input type="text" name="text"/></p>
        <p>Язык: 
            <select required name="lang">
                <option value="en" selected>Английский</option>
                <option value="uk" selected>Украинский</option>
                <option value="ru" selected>Русский</option>
                <option value="fr" selected>Французский</option>
                <option value="be" selected>Беларуский</option>
                <option selected disabled hidden>Выберете язык</option>
            </select>
        </p>

        <input type="submit" value="Отправить"></input>

    </form>

    <?php echo("<br>" . $get_text); ?>

</body>
</html>
