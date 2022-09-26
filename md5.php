<?php

if (!empty($argv[1]) && !empty($argv[2]))
    echo mb_strtoupper(md5($argv[2].$argv[1]));
else
    echo "code and salt (key)";

echo PHP_EOL;
