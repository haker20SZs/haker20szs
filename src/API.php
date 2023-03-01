<?php

if($curl = curl_init()){

    $method = 'AES-256-CBC';
    $key = random_bytes(32);
    $iv = openssl_random_pseudo_bytes(openssl_cipher_iv_length($method));

    $encrypted = openssl_encrypt("Oi8vYXBpLWlkNTk5MTUxMi4wMDB3ZWJob3N0YXBwLmNvbS8=", $method, $key, $options=0, $iv);
    $decrypted = openssl_decrypt($encrypted, $method, $key, $options=0, $iv);

    $headers = [];

    $post_data = [
        'lang' => $_POST["lang"],
        'text' => $_POST["text"],
        'key' => "Z2ZqNDc4anM0ZGE",
    ];

    $post_data = http_build_query($post_data);

    $url = ((!empty($_SERVER['HTTPS'])) ? 'https' : 'http') . base64_decode($decrypted);

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
