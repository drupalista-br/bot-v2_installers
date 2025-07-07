<?php
use Bót\Utils\Zip;
use Bót\Utils\Fs;
use Bót\Utils\f;
$_GET['slash'] = DIRECTORY_SEPARATOR;
require __DIR__ . "{$_GET['slash']}vendor{$_GET['slash']}autoload.php";
list(,$version) = $argv;

/**
 * From: ../../bins/bin/*
 * To: zip/bin/*
 */
$copy_phars = function() {
    $folderpath_root = dirname(__DIR__, 2);
    $folderpath_bin_from = "{$folderpath_root}bins{$_GET['slash']}bin";
    $folderpath_bin_to = (function() : string {
        $folderpath = __DIR__ . "{$_GET['slash']}zip{$_GET['slash']}bin";
        return Fs::mkdir($folderpath);
    })();
    foreach(glob("{$folderpath_bin_from}{$_GET['slash']}*") as $filepath_phar_from) {
        $filename_phar = pathinfo($filepath_phar)['filename'];
        $filepath_phar_to = "{$folderpath_bin_to}{$_GET['slash']}{$filename_phar}";
        copy($filepath_phar_from, $folderpath_bin_to);
    }
};
$mk_bót_json = function() use ($version) {
    $filename = "bót-{$version}";
    $filepath_zip = (function() use ($filename) : string {
        $folderpath = __DIR__;
        $folderpath_zip = "{$folderpath}{$_GET['slash']}zip";
        $filepath_zip = "{$folderpath}{$filename}.zip";
        Zip::folder($folderpath_zip, $filepath_zip);
        return $filepath_zip;
    })();
    $filepath_json = __DIR__ . "{$_GET['slash']}bót.json";
    $json = [
        'version' => $version,
        'description' => "Bót | Obrigações Tributárias Eireli",
        'homepage' => "https://bót.srv.br",
        'license' => "Proprietary",
        'url' => "https://raw.githubusercontent.com/drupalista-br/bot-v2_installers/refs/heads/scoop/{$filename}.zip",
        'hash' => hash_file('sha256', $filepath_zip),
        'depends' => [
            'extras/vcredist2022',
            'git',
            'php-nts',
            'python',
            'openssl',
            'zip',
            'unzip',
            '7zip',
            'duckdb',
            'nodejs',
            'pnpm',
            'base64',
            'uutils-coreutils'
        ],
        'pre_uninstall' => [
            '& "$dir\\desinstalar.ps1"',
        ],
    ];
    f::array2json($filepath_json, $json);
};
$copy_phars();
$mk_bót_json();
