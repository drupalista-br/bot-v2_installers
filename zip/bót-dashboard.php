<?php
$filepath_dashboard_phar = __DIR__ . DIRECTORY_SEPARATOR . 'bót-dashboard';
$github_phar = 'https://raw.githubusercontent.com/drupalista-br/bot-v2_bin/refs/heads/master/b%C3%B3t-dashboard';
$phar_does_exist = !file_exists($filepath_dashboard_phar);
if ($phar_does_exist)
    copy($phar, $filepath_dashboard_phar);
require $filepath_dashboard_phar;
