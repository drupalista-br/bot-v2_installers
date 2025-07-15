<?php
use Bót\Utils\Args;
use Bót\Utils\Fs;
use Bót\Utils\f;
require __DIR__ . "/vendor/autoload.php";
f::warningsAreExceptions();
[$version] = Args::fixedNumber($argv, total_expected: 1);

$_GET['folderpath_bin'] = (function() : string {
    $folderpath = __DIR__ . "/bin";
    return Fs::mkdir($folderpath);
})();
/**
 * From: ../../bins/bin/*
 * To: bin/*
 */
$copy_phars = function() {
    $folderpath_root = dirname(__DIR__, 2);
    $folderpath_bin_from = "{$folderpath_root}bins/bin";
    foreach(glob("{$folderpath_bin_from}/*") as $filepath_phar_from) {
        $filename_phar = pathinfo($filepath_phar)['filename'];
        $filepath_phar_to = "{$_GET['folderpath_bin']}/{$filename_phar}";
        copy($filepath_phar_from, $_GET['folderpath_bin']);
    }
};
$mk_bot_nix = function() use ($version) {
    $filepath = __DIR__ . "/bót.nix";
    $phars = (function() : string {
        $return = '';
        foreach(glob("{$_GET['folderpath_bin']}/*") as $filepath_phar) {
            $filename = basename($filepath_phar);
            $return .= "cp \"\${src}/bin/{$filename}\" \"\$out/bin/{$filename}\"\n";
        }
        return $return;
    })();
    $content = <<<NIX
    # Auto-generated Nix package for Bót — do not edit manually

    { pkgs ? import <nixpkgs> {} }:
    pkgs.stdenv.mkDerivation {
        pname = "Bót";
        version = "{$version}";
        src = ./.;
        dontUnpack = true;

        installPhase = ''
            mkdir -p \$out/bin
            {$phars}
            chmod +x \$out/bin/*
        '';
    }

    NIX;
    file_put_contents($filepath, $content);
};
$copy_phars();
$mk_bot_nix();
