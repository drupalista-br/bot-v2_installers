<?php
use Bót\Utils\Exec;
use Bót\Utils\Fs;
class Shared {
    /**
     * From: ../../bins/bin/*
     * From: ../../bins/js/*
     * To: bin/*
     * To: js/*
     */
    static function copy() {
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
    }
}
