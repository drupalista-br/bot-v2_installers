param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$_args
)
$browser_names = @("chrome", "chromium")
$filepath_where = {
    param($browser_name)
    $output = where.exe $browser_name 2>$null
    if ($output.Count -gt 1) {
        return $output[0]
    }
    return $output
}
$get_filepath_scoop = {
    param($folderpath_prefix)
    $filepath_exe = {
        foreach ($browser_name in $browser_names) {
            $filepath_exe = Join-Path $folderpath_prefix "${browser_name}.exe"
            if (Test-Path -Path $filepath_exe) {
                return $filepath_exe
            }
        }
        return $null
    }
    if ($folderpath_prefix) {
        return &$filepath_exe
    }
    return $null
}
$launched = $false
foreach ($browser_name in $browser_names) {
    # `scoop prefix` will stdout `Could not find app path for 'BROWSER_NAME'`
    # instead of stderr. Ignore it.
    $folderpath_prefix = scoop prefix $browser_name 2>$null
    $filepath_scoop = &$get_filepath_scoop $folderpath_prefix
    $filepath_exe = if ($filepath_scoop) {$filepath_scoop} else {&$filepath_where $browser_name}
    if ($filepath_exe) {
        $launched = $true
        Write-Host "exe: '${filepath_exe}'"
        Start-Process $filepath_exe -ArgumentList $_args
        break
    }
}
if (-not $launched) {
    Write-Host "Instale o Chromium com o comando 'scoop install extras/chromium'"
    exit 1
}
