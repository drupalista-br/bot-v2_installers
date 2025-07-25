<?php
use Bót\Utils\Args;
use Bót\Utils\Zip;
use Bót\Utils\Fs;
use Bót\Utils\f;
require __DIR__ . "/vendor/autoload.php";
f::warningsAreExceptions();
[$version] = Args::fixedNumber($argv, total_expected: 1);

$_GET['folderpath_zip'] = __DIR__ . "/zip";
$delete_zip = function() {
    foreach(glob(__DIR__ . "/*.zip") as $filepath_zip)
        unlink($filepath_zip);
};
/**
 * From: ../../bins/bin/*
 * To: zip/bin/*
 */
$mk_bin_and_ps1_folders = function() {
    $folderpath_root = dirname(__DIR__, 2);
    $delete_folder = function(string $folderpath) {
        if (file_exists($folderpath)) {
            $failed = !Exec::foreground('rm', ['-rf', "'{$folderpath}'"]);
            if ($failed)
                throw new \Exception(Exec::$error);
        }
    };
    $folderpath_bin = [
        'from' => "{$folderpath_root}bins/bin",
        'to' => (function() use ($delete_folder) : string {
            $folderpath = "{$_GET['folderpath_zip']}/bin";
            $delete_folder($folderpath);
            return Fs::mkdir($folderpath);
        })(),
    ];
    $folderpath_ps1 = (function() use ($delete_folder) : string {
        $folderpath = "{$_GET['folderpath_zip']}/ps1";
        $delete_folder($folderpath);
        return Fs::mkdir($folderpath);
    })();
    $mk_bot_browser_ps1 = function() use ($folderpath_ps1) {
        $filepath_ps1 = "{$folderpath_ps1}\\bót-browser.ps1";
        $content = <<<PS1
        param(
            [Parameter(ValueFromRemainingArguments = \$true)]
            [string[]]\$Args
        )
        \$browsers = @("chromium", "chrome")
        foreach (\$browser in \$browsers) {
            if (Get-Command \$browser -ErrorAction SilentlyContinue) {
                Start-Process \$browser -ArgumentList \$Args
                break
            }
        }
        PS1;
        file_put_contents($filepath_ps1, $content);
    };
    $mk_ps1 = function(string $filename_phar) use ($folderpath_ps1) {
        $filepath_ps1 = "{$folderpath_ps1}\\{$filename_phar}";
        $content = <<<PS1
        \$lc_o_acute = [char]0x00F3    # ó
        \$folderpath_bin = Join-Path (scoop prefix "b\${lc_o_acute}t") 'bin'
        \$filepath_phar = Join-Path \$folderpath_bin '{$filename_phar}'
        & php -f "\${filepath_phar}" -- @args
        PS1;
        file_put_contents($filepath_ps1, $content);
    };
    $mk_bot_browser_ps1();
    foreach(glob("{$folderpath_bin['from']}/*") as $filepath_phar_from) {
        $filename_phar = pathinfo($filepath_phar)['filename'];
        $filepath_phar_to = "{$folderpath_bin['to']}/{$filename_phar}";
        $mk_ps1($filename_phar);
        copy($filepath_phar_from, $folderpath_bin['to']);
    }
};
$mk_zip_and_bót_json_files = function() use ($version) {
    $filename_zip = "bót-{$version}.zip";
    $filepath_zip = (function() use ($filename_zip) : string {
        $folderpath = __DIR__;
        $filepath_zip = "{$folderpath}/{$filename_zip}";
        Zip::folder($_GET['folderpath_zip'], $filepath_zip);
        return $filepath_zip;
    })();
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
$delete_zip();
$mk_bin_and_ps1_folders();
$mk_zip_and_bót_json_files();
