<#
.SINOPSE
  Instala o Scoop e o Bót com verificação de restrições por Política de Grupo.

  Comando original:
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  Invoke-RestMethod -Uri https://xn--bt-5ja.srv.br/win-instalar | Invoke-Expression

  Liberar política de grupo:
  Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force
#>
# ------------------------------
# 🔠 Acentos
# ------------------------------
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$lc_a_acute = [char]0x00E1    # á
$lc_c_cedilla = [char]0x00E7  # ç
$lc_e_acute = [char]0x00E9    # é
$lc_i_acute = [char]0x00ED    # í
$lc_o_acute = [char]0x00F3    # ó
$lc_a_tilde = [char]0x00E3    # ã
$uc_e_acute = [char]0x00C9    # É

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
# 📦 Instala o Scoop (se necessário)
# ------------------------------
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "`n⬇️  Instalando o Scoop..."
    Invoke-RestMethod https://get.scoop.sh | Invoke-Expression
} else {
    Write-Host "`n✅ Scoop j${lc_a_acute} est${lc_a_acute} instalado."
}
$folderpath_app = (scoop prefix bot)

# ------------------------------
# 🦁 Instala o Brave
# ------------------------------
if (-not (Get-Command brave.exe -ErrorAction SilentlyContinue)) {
    Write-Host "`n🦁 Instalando Brave. Usado como GUI do B${lc_o_acute}t."
    scoop install brave
} else {
    Write-Host "`n✅ Brave j${lc_a_acute} est${lc_a_acute} instalado."
}

# ------------------------------
# 📝 Instala o LibreOffice
# ------------------------------
if (-not (Get-Command soffice.exe -ErrorAction SilentlyContinue)) {
    Write-Host "`n📝 Instalando Libreoffice. Usado para converter planilhas em Tsv."
    scoop install extras/libreoffice
} else {
    Write-Host "`n✅ LibreOffice j${lc_a_acute} est${lc_a_acute} instalado."
}

# ------------------------------
# 📥 Instala o Bót
# ------------------------------
Write-Host "`n📦 Instalando o b${lc_o_acute}t..."
scoop install https://xn--bt-5ja.srv.br/instalar.json

# ------------------------------
# 🧷 Atalho direto para o script PHP
# ------------------------------
$shortcutName    = "B${lc_o_acute}t.lnk"
$desktopPath     = [Environment]::GetFolderPath("Desktop")
$shortcutPath    = Join-Path $desktopPath $shortcutName
$phpScript       = Join-Path $folderpath_app "b${lc_o_acute}t-dashboard.php"

$wshShell = New-Object -ComObject WScript.Shell
$shortcut = $wshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "php"
$shortcut.Arguments  = "`"$phpScript`""
$shortcut.WorkingDirectory = $folderpath_app
$shortcut.IconLocation     = Join-Path $folderpath_app "logo.ico"
$shortcut.WindowStyle      = 7  # Oculto
$shortcut.Save()

Write-Host "`n🎉 Pronto! O B${lc_o_acute}t foi instalado. O ${lc_i_acute}cone do programa est${lc_a_acute} na sua ${lc_a_acute}rea de trabalho."
