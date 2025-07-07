<#
.SINOPSE
  Instala o Scoop e o Bót com verificação de restrições por Política de Grupo.

  Comando original:
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  Invoke-RestMethod -Uri https://instalador.xn--bt-5ja.srv.br/win | Invoke-Expression

  Liberar política de grupo:
  Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
#>
# ------------------------------
# 🔠 Acentos
# ------------------------------
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$lc_a_acute = [char]0x00E1    # á
$lc_a_tilde = [char]0x00E3    # ã
$lc_e_acute = [char]0x00E9    # é
$uc_e_acute = [char]0x00C9    # É
$lc_i_acute = [char]0x00ED    # í
$lc_o_acute = [char]0x00F3    # ó
$lc_o_tilde = [char]0x00F5    # õ
$lc_c_cedilla = [char]0x00E7  # ç


Write-Host ""
Write-Host "🚀 Este assistente ir${lc_a_acute}:"
Write-Host "  • Verificar se sua pol${lc_i_acute}tica de execu${lc_c_cedilla}${lc_a_tilde}o ${lc_e_acute} restritiva (Pol${lc_i_acute}tica de Grupo)"
Write-Host "  • Instalar o gerenciador de pacotes Scoop (caso necess${lc_a_acute}rio) | https://scoop.sh"
Write-Host "  • Instalar o programa B${lc_o_acute}t | https://b${lc_o_acute}t.srv.br/win-instalar"
Write-Host ""

# ------------------------------
# 🔎 Verificar Política de Grupo
# ------------------------------
$gpPolicy = Get-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\PowerShell" -Name ExecutionPolicy -ErrorAction SilentlyContinue

if ($gpPolicy.ExecutionPolicy) {
    Write-Host "🚫 A execu${lc_c_cedilla}${lc_a_tilde}o via powershell ${lc_e_acute} controlada por uma Pol${lc_i_acute}tica de Grupo corporativa:"
    Write-Host "   Pol${lc_i_acute}tica aplicada: $($gpPolicy.ExecutionPolicy)"
    Write-Host ""
    Write-Host "💡 ${uc_e_acute} necess${lc_a_acute}rio remover a restri${lc_c_cedilla}${lc_a_tilde}o da pol${lc_i_acute}tica de grupo. Comunique o seu TI antes de executar o comando abaixo."
    Write-Host "   • Ap${lc_o_acute}s autorizado pelo seu TI, copie e cole o seguinte comando:"
    Write-Host ""
    Write-Host "     Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force"
    Write-Host ""
    Write-Host "   • Em seguida execute novamente:"
    Write-Host ""
    Write-Host "     Invoke-RestMethod -Uri https://xn--bt-5ja.srv.br/win-instalar | Invoke-Expression"
    Write-Host ""
    Write-Host ""
    exit
}

# ------------------------------
# 🛑 Confirmação do usuário
# ------------------------------
$proseguir = Read-Host "Continua com a instala${lc_c_cedilla}${lc_a_tilde}o? (Digite S para sim)"
if ($proseguir -notin @("S", "s")) {
    Write-Host "`n❌ Instala${lc_c_cedilla}${lc_a_tilde}o cancelada."
    exit
}

# ------------------------------
# 📦 Instalando o Scoop (se necessário)
# ------------------------------
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "`n⬇️  Instalando o Scoop..."
    Invoke-RestMethod https://get.scoop.sh | Invoke-Expression
} else {
    Write-Host "`n✅ Scoop j${lc_a_acute} est${lc_a_acute} instalado."
}

# ------------------------------
# 📦 Adicionando o bucket extras
# ------------------------------
if (!(scoop bucket list | Select-String -Quiet 'extras')) {
    scoop bucket add extras
}

# ------------------------------
# Instalando o Curl
# ------------------------------
if (-not (Get-Command curl.exe -ErrorAction SilentlyContinue)) {
    Write-Host "`n🦁 Instalando o Curl."
    scoop install curl
} else {
    Write-Host "`n✅ Curl j${lc_a_acute} est${lc_a_acute} instalado."
}

# ------------------------------
# 🦁 Instalando o Brave
# ------------------------------
if (-not (Get-Command brave.exe -ErrorAction SilentlyContinue)) {
    Write-Host "`n🦁 Instalando Brave. Usado como GUI do B${lc_o_acute}t."
    scoop install brave
} else {
    Write-Host "`n✅ Brave j${lc_a_acute} est${lc_a_acute} instalado."
}

# ------------------------------
# 📝 Instalando o LibreOffice
# ------------------------------
<#
if (-not (Get-Command soffice.exe -ErrorAction SilentlyContinue)) {
    Write-Host "`n📝 Instalando Libreoffice. Usado para converter planilhas em Tsv."
    scoop install extras/libreoffice
} else {
    Write-Host "`n✅ LibreOffice j${lc_a_acute} est${lc_a_acute} instalado."
}
#>

# ------------------------------
# 📥 Instalando o Bót
# ------------------------------
Write-Host "`n📦 Instalando o b${lc_o_acute}t..."
scoop install "https://raw.githubusercontent.com/drupalista-br/bot-v2_installers/refs/heads/scoop/b${lc_o_acute}t.json"

# ------------------------------
# 🧷 Setando as variáveis, as funções e as validações
# ------------------------------
$folderpath_php = scoop prefix php
$folderpath_app = scoop prefix "b${lc_o_acute}t"
$filepath_php_exe = Join-Path $folderpath_php 'php.exe'
$folderpath_bin  = Join-Path $folderpath_app  'bin'
$folderpath_scoop = if ($Env:SCOOP) { $Env:SCOOP } else { Join-Path $Env:USERPROFILE 'scoop' }
$folderpath_shims  = Join-Path $folderpath_scoop 'shims'
$filepath_shortcuts = Join-Path $folderpath_app 'atalhos.json'
foreach($dir_file in @($folderpath_bin, $filepath_shortcuts, $folderpath_shims)) {
    if (-not (Test-Path $dir_file)) {
        throw "Item NÃO encontrado: ${dir_file}"
    }
}

function mkShim {
    param (
        [string]$filepath_phar,
        [string]$filename_exe
    )
    $shim_cmd = "`"${filepath_php_exe}`" -f `"${filepath_phar}`""
    scoop shim add $filename_exe $shim_cmd -f
}

function mkShortcut {
    param (
        [string]$filepath_exe,
        [string]$filename_exe,
        [ValidateSet('Desktop', 'Programs')]
        [string]$location,
        [string]$description = $null
    )
    $folderpath_lnk = [Environment]::GetFolderPath($location)
    $filepath_lnk = Join-Path $folderpath_lnk ("${filename_exe}.lnk")

    $wshShell = New-Object -ComObject WScript.Shell
    $shortcut = $wshShell.CreateShortcut($filepath_lnk)
    $shortcut.TargetPath = $filepath_exe
    $shortcut.WorkingDirectory = Split-Path $filepath_exe
    if ($description) {
        $shortcut.Description = $description
    }
    $shortcut.Save()
}

# ------------------------------
# 🧷 Criando os .EXEs
# ------------------------------
Get-ChildItem -Path $folderpath_bin -File | ForEach-Object {
    $filename_exe = [System.IO.Path]::GetFileName($_.FullName)
    $params = @{
        filepath_phar = $_.FullName
        filename_exe = $filename_exe
    }
    mkShim @params
}

# ------------------------------
# 🧷 Criando os atalhos na área de trabalho
# ------------------------------
$atalhos = Get-Content $filepath_shortcuts -Raw | ConvertFrom-Json
foreach ($atalho in $atalhos) {
    $filepath_exe = Join-Path $folderpath_shims "${atalho}.exe"
    $params = @{
        filepath_exe = $filepath_exe
        filename_exe = $atalho
        location = 'Desktop'
    }
    mkShortcut @params
}

# ------------------------------
# 🧷 Criando o atalho no menu Startup
# ------------------------------
$filename_exe = "b${lc_o_acute}-dashboard.exe"
$filepath_exe = Join-Path $folderpath_shims $filename_exe
$params = @{
    filepath_exe = $filepath_exe
    filename_exe = $filename_exe
    location = 'Programs'
    description = "B${lc_o_acute}t | Obriga${lc_c_cedilla}${lc_o_tilde}es Fiscais Eireli"
}
mkShortcut @params

Write-Host "`n🎉 Pronto! O B${lc_o_acute}t foi instalado."
