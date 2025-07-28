<?php
use Bót\Utils\Exec;
use Bót\Utils\Args;
use Bót\Utils\Fs;
use Bót\Utils\f;
require __DIR__ . '/vendor/autoload.php';
require __DIR__ . '/shared.php';
f::warningsAreExceptions();
[$version] = Args::fixedNumber($argv, total_expected: 1);
$mk_bot_nix = function() use ($version) {
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
            mkdir -p \$out/bot-js
            cp \$src/bin/* \$out/bin/
            cp \$src/js/* \$out/bot-js/
            chmod +x \$out/bin/*
        '';
    }

    NIX;
    file_put_contents($filepath, $content);
};
Shared::copy();
$mk_bot_nix();
