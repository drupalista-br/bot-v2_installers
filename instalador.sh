#!/bin/sh
# POSIX‐compliant installer for Bót
#
# Usage: curl -fsSL https://instalador.xn--bt-5ja.srv.br/nix | sh

set -eu

if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" = "nixos" ]; then
        echo "⚠️ Este script não é compatível com o NixOS."
        echo "Veja: https://xn--bt-5ja.srv.br/instalação/nixos"
        exit 1
    fi
fi

export NIXPKGS_ALLOW_UNFREE=1
php_min_ver="8.3"
node_min_ver=22
folderpath_git_repo="$HOME/.bót-install"
filepath_nix_profile="$HOME/.nix-profile/etc/profile.d/nix.sh"

isLinux() {
    if [ "$(uname -s)" = "Linux" ]; then
        return 0
    fi
    return 1
}
notInstalled() {
    if ! command -v "$1" >/dev/null 2>&1; then
        return 0
    fi
    return 1
}
installPhp() {
    outdated() {
        if ! php -r "exit(version_compare(PHP_VERSION, '$php_min_ver', '>=') ? 0 : 1);" 2>/dev/null; then
            return 0
        fi
        return 1
    }
    if notInstalled php || outdated; then
        echo "→ Instalando o Php..."
        nix-env -iA nixpkgs.php
    fi
}
installNodeJs() {
    outdated() {
        if ! node -e "process.exit(Number(process.version.split('.')[0].slice(1)) >= $node_min_ver ? 0 : 1)" 2>/dev/null; then
            return 0
        fi
        return 1
    }
    if notInstalled node || outdated; then
        echo "→ Instalando o Nodejs..."
        nix-env -iA nixpkgs.nodejs
    fi
}
installBrave() {
    if notInstalled brave-browser && notInstalled brave; then
        echo "→ Instalando Brave..."
        nix-env -iA nixpkgs.brave
        filepath_brave="$(command -v brave)"
        folderpath="$(dirname "${filepath_brave}")"
        if [ ! -e "${folderpath}/brave-browser" ]; then
            ln -s "${filepath_brave}" "${folderpath}/brave-browser"
        fi
    fi
}
desktopShortcut() {
    echo "⏳ Criando atalho na área de trabalho..."
    filepath_icon="${folderpath_git_repo}/logo.ico"
    folderpath_bin="$HOME/.nix-profile/bin"
    if isLinux; then
        folderpath_desktop=$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")
        mkdir -p "${folderpath_desktop}"
        cat > "${folderpath_desktop}/bót.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Bót
Exec=bash -c "source ${filepath_nix_profile}; ${folderpath_bin}/bót-dashboard"
Icon=${filepath_icon}
Terminal=false
EOF
        chmod +x "${folderpath_desktop}/bót.desktop"
        echo "✓ Atalho criado em ${folderpath_desktop}/bót.desktop"
        return
    fi

    # Mac
    folderpath_desktop="$HOME/Desktop"
    mkdir -p "${folderpath_desktop}"
    cp "${filepath_icon}" "${folderpath_desktop}/logo.ico"
    filepath_shortcut="${folderpath_desktop}/Bót.command"
    cat > "${filepath_shortcut}" <<EOF
#!/bin/bash
exec "${folderpath_bin}/bót-dashboard"
EOF
    chmod +x "${filepath_shortcut}"
    echo "✓ Atalho criado em ${filepath_shortcut}"
}

# 1. Install nix package mananger if missing
if notInstalled nix; then
    filepath_user_profiles=("$HOME/.zshrc" "$HOME/.zprofile") # macOS
    notSourced() {
        is_sourced=$(grep -F "${filepath_nix_profile}" "$1" 2>/dev/null || true)
        if [ -z "$is_sourced" ]; then
            return 0;
        fi
        return 1;
    }
    if isLinux; then
        filepath_user_profiles=("$HOME/.bashrc" "$HOME/.profile")
    fi

    echo "→ Instalando o Nix Gerenciador de Pacotes."
    curl -L https://nixos.org/nix/install | bash
    if [ -f "${filepath_nix_profile}" ]; then
        . "${filepath_nix_profile}"
        for filepath_user_profile in "${filepath_user_profiles[@]}"; do
            if notSourced "${filepath_user_profile}"; then
                echo "🔧 Sourcing nix.sh em ${filepath_user_profile}"
                echo ". \"${filepath_nix_profile}\"" >> "${filepath_user_profile}"
            fi
        done
    fi
else
    echo "✓ Nix Gerenciador de Pacotes já está instalado."
fi

# 2. Install packages
packages="duckdb pnpm git openssl zip unzip unrar fastfetch fd gedit"
for pkg in $packages; do
    if notInstalled "${pkg}"; then
        echo "→ Instalando ${pkg}"
        nix-env -iA nixpkgs."${pkg}"
    fi
done
installPhp
installNodeJs
installBrave

# 3. Install Bót
if [ -d "${folderpath_git_repo}" ]; then
    echo "🗘 Atualizando o instalador do Bót..."
    git -C "${folderpath_git_repo}" pull origin nixos
else
    echo "📥 Fazendo o download do instalador do Bót..."
    git clone -b nixos https://github.com/drupalista-br/bot-v2_installers.git "${folderpath_git_repo}"
fi
cd "${folderpath_git_repo}"

echo "📦 Instalando o Bót..."
nix-env -f "bót.nix" -i

desktopShortcut

echo "🎉 Pronto! O Bót foi instalado."
