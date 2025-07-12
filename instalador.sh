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
pnpm_min_ver=10
node_min_ver=22
duckdb_min_ver=1.2
GIT_REPO_DIR="$HOME/.bót-install"

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
installPnpm() {
    outdated() {
        current=$(pnpm -v)
        echo "🔍 Pnpm version: $current requires ≥ $pnpm_min_ver"
        [ "$(printf '%s\n' "$pnpm_min_ver" "$current" | sort -V | head -n1)" != "$pnpm_min_ver" ]
    }
    if notInstalled pnpm || outdated; then
        echo "→ Instalando o pnpm..."
        nix-env -iA nixpkgs.pnpm
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
installDuckdb() {
    outdated() {
        current=$(duckdb --version | sed -E 's/^v?([0-9]+\.[0-9]+\.[0-9]+).*/\1/')
        echo "🔍 DuckDB version: $current requires ≥ $duckdb_min_ver"
        [ "$(printf '%s\n' "$current" "$duckdb_min_ver" | sort -V | head -n1)" != "$duckdb_min_ver" ]
    }
    if notInstalled duckdb || outdated; then
        echo "→ Instalando o duckdb"
        nix-env -iA nixpkgs.duckdb
    fi
}
installBrave() {
    if notInstalled brave-browser && notInstalled brave; then
        echo "→ Instalando Brave..."
        nix-env -iA nixpkgs.brave
    fi
}
desktopShortcut() {
    echo "⏳ Criando atalho na área de trabalho..."
    ICON_PATH="$GIT_REPO_DIR/logo.ico"
    BIN="$HOME/.nix-profile/bin"
    if isLinux; then
        DESKTOP_DIR=$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")
        mkdir -p "$DESKTOP_DIR"
        cat > "$DESKTOP_DIR/bót.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Bót
Exec=$BIN/bót-dashboard %U
Icon=$ICON_PATH
Terminal=true
Categories=Utility;
EOF
        chmod +x "$DESKTOP_DIR/bót.desktop"
        echo "✓ Atalho criado em $DESKTOP_DIR/bót.desktop"
        return
    fi

    # Mac
    DESKTOP_DIR="$HOME/Desktop"
    mkdir -p "$DESKTOP_DIR"
    cp "$ICON_PATH" "$DESKTOP_DIR/logo.ico"
    SHORTCUT="$DESKTOP_DIR/Bót.command"
    cat > "$SHORTCUT" <<EOF
#!/bin/bash
exec "$BIN/bót-dashboard" "\$@"
EOF
    chmod +x "$SHORTCUT"
    echo "✓ Atalho criado em $SHORTCUT"
}

# 1. Install nix package mananger if missing
if notInstalled nix; then
    NIX_PROFILE="$HOME/.nix-profile/etc/profile.d/nix.sh"
    PROFILES=("$HOME/.zshrc" "$HOME/.zprofile") # macOS
    notSourced() {
        is_sourced=$(grep -F "$NIX_PROFILE" "$1" 2>/dev/null || true)
        if [ -z "$is_sourced" ]; then
            return 0;
        fi
        return 1;
    }
    if isLinux; then
        PROFILES=("$HOME/.bashrc" "$HOME/.profile")
    fi

    echo "→ Instalando o Nix Gerenciador de Pacotes."
    curl -L https://nixos.org/nix/install | bash
    if [ -f "$NIX_PROFILE" ]; then
        . "$NIX_PROFILE"
        for profile in "${PROFILES[@]}"; do
            if notSourced "$profile"; then
                echo "🔧 Sourcing nix.sh em $profile"
                echo ". \"$NIX_PROFILE\"" >> "$profile"
            fi
        done
    fi
else
    echo "✓ Nix Gerenciador de Pacotes já está instalado."
fi

# 2. Install packages
packages="git openssl zip unzip unrar"
for pkg in $packages; do
    if notInstalled "$pkg"; then
        echo "→ Instalando $pkg"
        nix-env -iA nixpkgs."$pkg"
    fi
done
installPhp
installPnpm
installNodeJs
installDuckdb
installBrave

# 3. Install Bót
echo "📥 Fazendo o download do instalador do Bót..."
git clone -b nixos https://github.com/drupalista-br/bot-v2_installers.git "$GIT_REPO_DIR"
cd "$GIT_REPO_DIR"

echo "📦 Instalando o Bót..."
nix-env -f "bót.nix" -i

desktopShortcut

echo "🎉 Pronto! O Bót foi instalado."
