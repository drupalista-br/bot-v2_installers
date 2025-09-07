<?php
use Bót\Utils\Exec;
use Bót\Utils\Args;
use Bót\Utils\Fs;
use Bót\Utils\f;
require __DIR__ . '/vendor/autoload.php';
require __DIR__ . '/functions.php';
f::warningsAreExceptions();
[$version] = Args::fixedNumber($argv, total_expected: 1);
$mk_nix_file = function() use ($version) {
    $filepath = __DIR__ . "/bót.nix";
    $content = <<<NIX
    # Auto-generated Nix package for Bót — do not edit manually

    { pkgs ? import <nixpkgs> {} }:
    pkgs.stdenv.mkDerivation {
        pname = "Bot";
        version = "{$version}";
        src = ./.;
        dontUnpack = true;

        installPhase = ''
            mkdir -p \$out/bin
            mkdir -p \$out/scripts
            mkdir -p \$out/assets
            cp \$src/bin/* \$out/bin/
            cp \$src/scripts/* \$out/scripts/
            cp \$src/assets/* \$out/assets/
            chmod +x \$out/bin/*
        '';
    }

    NIX;
    file_put_contents($filepath, $content);
};
$folderpath_installer = __DIR__;
$folders = ['bin', 'scripts', 'assets'];
Functions::delete($folderpath_installer, $folders);
Functions::copyFromBinsTo($folderpath_installer, $folders);
$mk_nix_file();
