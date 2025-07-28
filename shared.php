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
    static function copy(string $folderpath_installer) {
        $folderpath_root = dirname($folderpath_installer, 2);
        $folderpath_from = "{$folderpath_root}/bins";
        $folderpath_to = Fs::mkdir($folderpath_installer);
        $folders = ['bin', 'js'];
        $delete = function() use ($folderpath_installer, $folders) {
            foreach($folders as $folder) {
                $folderpath_to = "{$folderpath_installer}/{$folder}";
                if (file_exists($folderpath_to)) {
                    $failed = !Exec::foreground('rm', ['-rf', "'{$folderpath_to}'"]);
                    if ($failed)
                        throw new \Exception(Exec::$error);
                }
            }
        };
        $copy = function() use ($folderpath_from, $folderpath_installer, $folders) {
            foreach($folders as $folder) {
                $folderpath_to = "{$folderpath_installer}/{$folder}";
                if (file_exists($folderpath_to)) {
                    $failed = !Exec::foreground('rm', ['-rf', "'{$folderpath_to}'"]);
                    if ($failed)
                        throw new \Exception(Exec::$error);
                }
                mkdir($folderpath_to, recursive: TRUE);
                $failed = !Exec::foreground('cp', ['-r', "'{$folderpath_from}/{$folder}'/*", "'{$folderpath_to}'/"]);
                if ($failed)
                    throw new \Exception(Exec::$error);
            }
        };
        $delete();
        $copy();
    }
}
