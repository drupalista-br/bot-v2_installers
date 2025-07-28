<?php
use Bót\Utils\Exec;
use Bót\Utils\Args;
use Bót\Utils\Fs;
use Bót\Utils\f;
require __DIR__ . "/vendor/autoload.php";
f::warningsAreExceptions();
[$version] = Args::fixedNumber($argv, total_expected: 1);
/**
 * From: ../../bins/bin/*
 * To: bin/*
 */
$copy = function() {
    $folderpath_root = dirname(__DIR__, 2);
    $folderpath_from = "{$folderpath_root}/bins";
    $folderpath_to = Fs::mkdir(__DIR__);
    $bin_failed = function() use ($folderpath_from, $folderpath_to) : bool {
        $folderpath_to_bin = "{$folderpath_to}/bin";
        if (!file_exists($folderpath_to_bin))
            mkdir($folderpath_to_bin, recursive: TRUE);
        return !Exec::foreground('cp', ['-r', "{$folderpath_from}/bin/*", "{$folderpath_to_bin}/"]);
    };
    $js_failed = function() use ($folderpath_from, $folderpath_to) : bool {
        $folderpath_to_js = "{$folderpath_to}/js";
        if (!file_exists($folderpath_to_js))
            mkdir($folderpath_to_js, recursive: TRUE);
        return !Exec::foreground('cp', ['-r', "{$folderpath_from}/js/*", "{$folderpath_to_js}/"]);
    };
    if ($bin_failed())
        throw new \Exception(Exec::$error);
    if ($js_failed())
        throw new \Exception(Exec::$error);
};
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
$copy();
$mk_bot_nix();
