<?php
use Bót\Utils\Args;
use Bót\Utils\Zip;
use Bót\Utils\f;
require __DIR__ . "/vendor/autoload.php";
require __DIR__ . '/../nixos/functions.php';
f::warningsAreExceptions();
[$version] = Args::fixedNumber($argv, total_expected: 1);
$_GET['folderpath_zip'] = __DIR__ . "/zip";
$filename_zip = "bót-{$version}.zip";
$filepath_zip = function() use ($filename_zip) : string {
    $folderpath = __DIR__;
    $filepath_zip = "{$folderpath}/{$filename_zip}";
    Zip::folder($_GET['folderpath_zip'], $filepath_zip);
    return $filepath_zip;
};
$delete_zip_file = function() {
    foreach(glob(__DIR__ . "/*.zip") as $filepath_zip)
        unlink($filepath_zip);
};
$mk_exe_PS1s = function() {
    $folderpath_ps1 = (function() : string {
        $folderpath = "{$_GET['folderpath_zip']}/ps1";
        mkdir($folderpath, recursive: TRUE);
        return $folderpath;
    })();
    $mk_bót_browser_ps1 = function() use ($folderpath_ps1) {
        $filepath_from = __DIR__ . '/bót-browser.ps1';
        $filepath_to = "{$folderpath_ps1}/bót-browser.ps1";
        copy($filepath_from, $filepath_to);
    };
    $mk_exe_ps1 = function(string $folderpath) use ($folderpath_ps1) {
        $mk_ps1 = function(string $filename_phar) use ($folderpath_ps1) {
            $filepath_ps1 = "{$folderpath_ps1}/{$filename_phar}";
            $content = <<<PS1
            \$lc_o_acute = [char]0x00F3    # ó
            \$folderpath_bin = Join-Path (scoop prefix "b\${lc_o_acute}t") 'bin'
            \$filepath_phar = Join-Path \$folderpath_bin '{$filename_phar}'
            \$env:APP_NAME = "b\${lc_o_acute}t"
            & php -f "\${filepath_phar}" -- @args

            PS1;
            file_put_contents($filepath_ps1, $content);
        };
        foreach(glob("{$folderpath}/*") as $filepath_phar_from) {
            $pathinfo = pathinfo($filepath_phar_from);
            $filename_phar = $pathinfo['filename'];
            $not_json = $pathinfo['extension'] !== 'json';
            if ($not_json)
                $mk_ps1($filename_phar);
        }
    };
    $is_unembbeded_folder = function(string $folderpath) : bool {
        $foldername = pathinfo($folderpath)['filename'];
        return $foldername  === 'scripts' || $foldername  === 'assets';
    };
    $mk_bót_browser_ps1();
    foreach(glob(Functions::folderpathBins() . '/*') as $folderpath) {
        if ($is_unembbeded_folder($folderpath))
            continue;
        $mk_exe_ps1($folderpath);
    }
};
$copy_from_local = function() {
    $filenames = ['desinstalar.ps1', 'logo.ico', 'atalhos.json'];
    foreach($filenames as $filename)
        copy(__DIR__ . "/{$filename}", "{$_GET['folderpath_zip']}/{$filename}");
};
$mk_bót_json = function(string $filepath_zip) use ($version, $filename_zip) {
    $filepath_json = __DIR__ . "/bót.json";
    $json = [
        'version' => $version,
        'description' => "Bót | Obrigações Tributárias Eireli",
        'homepage' => "https://bót.srv.br",
        'license' => "Proprietary",
        'url' => "https://raw.githubusercontent.com/drupalista-br/bot-v2_installers/refs/heads/scoop/{$filename_zip}",
        'hash' => hash_file('sha256', $filepath_zip),
        'depends' => [
            'extras/vcredist2022',
            'php-nts',
            'openssl',
            'zip',
            'unzip',
            'unrar',
            'duckdb',
            'nodejs',
            'pnpm',
            'uutils-coreutils',
            'fastfetch',
            'fd',
        ],
        'pre_uninstall' => [
            '& "$dir\\desinstalar.ps1"',
        ],
    ];
    f::array2json($filepath_json, $json);
};
Functions::delete(__DIR__, ['zip']);
Functions::copyFromBinsTo($_GET['folderpath_zip'], ['scripts', 'assets']);
$delete_zip_file();
$mk_exe_PS1s();
$copy_from_local();
$mk_bót_json($filepath_zip());
