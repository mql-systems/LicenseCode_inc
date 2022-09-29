<?php

# Generate type
# =================
echo "License Server".PHP_EOL;
echo "=====================".PHP_EOL;
echo "Generate:".PHP_EOL;
echo "1. Key (salt)".PHP_EOL;
echo "2. License".PHP_EOL;

switch (getAge())
{
    // generate Key
    case 1:
    {
        echo "Key (salt):".PHP_EOL;
        echo "1. For Lifetime license".PHP_EOL;
        echo "2. For Limited license".PHP_EOL.PHP_EOL;

        # for Lifetime license
        $lifetimeKey = getRandStr();
        $lifetimeKeyCnt = strlen($lifetimeKey);

        for ($i = (int)($lifetimeKeyCnt/3); $i>0; $i--)
            $lifetimeKey = substr_replace($lifetimeKey, getRandSpecSymbol(), random_int(0, $lifetimeKeyCnt-1), 1);
        
        $age = getAge();
        
        echo "------".PHP_EOL;
        echo "Key for Lifetime: ".$lifetimeKey.PHP_EOL;

        # for Limited license
        if ($age == 2)
            echo "Key for Limited: ".getRandStr().PHP_EOL;
        
        echo "------".PHP_EOL;
        break;
    }

    // generate License
    case 2:
    {
        echo "License:".PHP_EOL;
        echo "1. Lifetime license".PHP_EOL;
        echo "2. Limited license".PHP_EOL.PHP_EOL;

        $licenseType = getAge();

        $userLogin;
        $lifetimeKey;

        // user login
        do {
            $userLogin = trim(readline("Enter your trading account login: "));
            if (strlen($userLogin) > 0)
                break;
        }
        while (true);

        // Lifetime key
        do {
            $lifetimeKey = trim(readline("Enter Lifetime key (salt): "));
            if (strlen($lifetimeKey) > 0)
                break;
        }
        while (true);

        # Lifetime license
        if ($licenseType == 1)
        {
            echo "------".PHP_EOL;
            echo "Lifetime license: ".mb_strtoupper(md5($lifetimeKey.$userLogin)).PHP_EOL;
        }
        # Limited license
        else
        {
            $limitedKey;

            // Limited key
            do {
                $limitedKey = trim(readline("Enter Limited key (salt) "));
                if (strlen($limitedKey) > 0)
                    break;
            }
            while (true);

            // Limited time
            do {
                $limitedDatetime = strtotime(trim(readline("Enter the license expiration date and time (".date("Y-m-d H:i")."): ")));
                if ($limitedDatetime > 0)
                    break;
            }
            while (true);

            $checkMd5 = mb_strtoupper(md5($lifetimeKey.$userLogin.$limitedDatetime));
            
            echo "------".PHP_EOL;
            echo "Limited license: ".openssl_encrypt($checkMd5.$limitedDatetime, 'aes-256-ecb', $limitedKey).PHP_EOL;
        }

        echo "------".PHP_EOL;
        break;
    }
}

function getAge()
{
    $age;

    do {
        $age = readline("Enter item: ");
        if (is_numeric($age))
        {
            $age = (int)$age;
            if ($age >= 1 && $age <= 2)
                break;
            else
                echo "Wrong number!".PHP_EOL;
        }
        else
            echo "Enter the number!".PHP_EOL;
    }
    while (true);

    return $age;
}

function getRandStr()
{
    return bin2hex(openssl_random_pseudo_bytes(16));
}

function getRandSpecSymbol()
{
    return substr("!@#$&()?/+=", random_int(0,10), 1);
}
