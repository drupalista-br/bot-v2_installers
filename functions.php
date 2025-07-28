<?php
use Bót\Utils\Exec;
use Bót\Utils\Fs;
class Functions {
    static function folderpathBins() {
        $folderpath_root = dirname(__DIR__, 2);
        return "{$folderpath_root}/bins";
    }
    static function delete(string $folderpath_installer, array $folders) {
        foreach($folders as $folder) {
            $folderpath_to = "{$folderpath_installer}/{$folder}";
            if (file_exists($folderpath_to)) {
                $failed = !Exec::foreground('rm', ['-rf', "'{$folderpath_to}'"]);
                if ($failed)
                    throw new \Exception(Exec::$error);
            }
        }
    }
    static function copyFromBinsTo(string $folderpath_installer, array $folders) {
        $folderpath_from = self::folderpathBins();
        $folderpath_to = Fs::mkdir($folderpath_installer);
        foreach($folders as $folder) {
            $folderpath_to = "{$folderpath_installer}/{$folder}";
            mkdir($folderpath_to, recursive: TRUE);
            $failed = !Exec::foreground('cp', ['-r', "'{$folderpath_from}/{$folder}'/*", "'{$folderpath_to}'/"]);
            if ($failed)
                throw new \Exception(Exec::$error);
        }
    }
}
