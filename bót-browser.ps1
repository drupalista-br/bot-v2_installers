param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$_args
)
$browsers = @("chrome", "chromium")
foreach ($browser in $browsers) {
    $filepath_exe = & where.exe $browser 2>$null
    $launch = {
        $is_scoop = $filepath_exe -like "*\scoop\shims\*"
        $filepath_exe_scoop = { Join-Path (scoop prefix $browser) "${browser}.exe" }
        $filepath_exe = &{
            if ($is_scoop) {
                return &$filepath_exe_scoop
            }
            else {
                return $filepath_exe
            }
        }
        Start-Process $filepath_exe -ArgumentList $_args
    }
    if ($filepath_exe) {
        &$launch
        break
    }
}
