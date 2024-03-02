#!/bin/bash

set -x 

CARGO_CONFIG_DIR=$HOME/.cargo
CARGO=$(command -v cargo 2>/dev/null)
CARGO_TOOLS=(starship fd-find exa bat ripgrep)

USER=vagrant

export RUSTUP_DIST_SERVER=https://rsproxy.cn
export RUSTUP_UPDATE_ROOT=https://rsproxy.cn/rustup
export GOPATH=$HOME/.go
export GOMODCACHE=$GOPATH/pkg/mod
export GOPROXY=https://goproxy.io,direct
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin:/opt/nvim-linux64/bin:/usr/local/node-v20.11.1-linux-x64/bin

function tools() {
    sudo apt install build-essential zsh shellcheck python3-pip lua5.3 jq git make cmake curl tig silversearcher-ag -y
    return $?
}

function apt_source {
    cat > /tmp/sources.list << EOF
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-security main restricted universe multiverse

# deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-proposed main restricted universe multiverse
# deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ focal-proposed main restricted universe multiverse
EOF

    sudo mv /etc/apt/sources.list /etc/apt/sources.list.bak
    sudo mv /tmp/sources.list /etc/apt/sources.list
    sudo apt update
}

function rust() {
    curl --proto '=https' --tlsv1.2 -sSf https://rsproxy.cn/rustup-init.sh | sh -s -- -y ||
        {
            echo "error install rust: " "$?"
            return 1
        }

    if [[ ! -d "${CARGO_CONFIG_DIR}" ]]; then
        mkdir "${CARGO_CONFIG_DIR}"
    fi

    cat > "${CARGO_CONFIG_DIR}"/config << EOF
#[source.crates-io]
#registry = "https://github.com/rust-lang/crates.io-index"
#replace-with = 'ustc'
#
#[source.ustc]
## registry = "https://mirrors.ustc.edu.cn/crates.io-index"
#registry = "git://mirrors.ustc.edu.cn/crates.io-index"
#
#[source.tuna]
#registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"
#
#[source.rustcc]
#registry = "https://code.aliyun.com/rustcc/crates.io-index.git"
[source.crates-io]
replace-with = 'rsproxy-sparse'
[source.rsproxy]
registry = "https://rsproxy.cn/crates.io-index"
[source.rsproxy-sparse]
registry = "sparse+https://rsproxy.cn/index/"
[registries.rsproxy]
index = "https://rsproxy.cn/crates.io-index"
[net]
git-fetch-with-cli = true
EOF

    source "${HOME}"/.cargo/env
    CARGO=$(command -v cargo 2>/dev/null)
    if [[ "${CARGO}" == "" ]]; then
        echo "error install rust"
        return 1
    fi
}

function rust_tools() {
    # TODO: check if cargo has been installed.
    for tool in "${CARGO_TOOLS[@]}"; do
        "${CARGO}" install --locked "${tool}" ||
        {
            echo "error install ${tool}"
            return 1
        }
    done
}

function neovim() {
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
    sudo rm -rf /opt/nvim
    sudo tar -C /opt -xzf nvim-linux64.tar.gz
    rm -rf nvim-linux64.tar.gz
}

function go() {
    curl -LO https://go.dev/dl/go1.21.7.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.7.linux-amd64.tar.gz
    rm -rf go1.21.7.linux-amd64.tar.gz
}

function cnpm() {
    curl -LO https://nodejs.org/dist/v20.11.1/node-v20.11.1-linux-x64.tar.xz
    sudo rm -rf /usr/local/node-v20.11.1-linux-x64 && sudo tar -C /usr/local -xf node-v20.11.1-linux-x64.tar.xz
    rm -rf node-v20.11.1-linux-x64.tar.xz

    /usr/local/node-v20.11.1-linux-x64/bin/npm install cnpm -g --registry=https://registry.npmmirror.com
}


function zsh() {
    if ! command -v zsh >/dev/null 2>&1; then
        echo "zsh is not installed, install it first"
        return 1
    fi

    if [[ -d "${HOME}/.oh-my-zsh" ]]; then
        return 0
    fi 
    # oh-my-zsh
    curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o /tmp/install.sh ||
        {
            echo "curl oh-my-zsh install script failed."
            return 1
        }

    bash /tmp/install.sh --unattended ||
        {
            rm -rf /tmp/install.sh
            echo "install oh-my-zsh failed."
            return 1
        }

    rm -rf /tmp/install.sh

    cat >> $HOME/.zshrc << EOF

export GOPATH=$HOME/.go
export GOMODCACHE=$GOPATH/pkg/mod
export GOPROXY=https://goproxy.io,direct

#export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
#export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
export RUSTUP_DIST_SERVER=https://rsproxy.cn
export RUSTUP_UPDATE_ROOT=https://rsproxy.cn/rustup

export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin:/opt/nvim-linux64/bin:/usr/local/node-v20.11.1-linux-x64/bin

eval '"$(starship init zsh)"'

. "$HOME/.cargo/env"
EOF
}

function bashrc() {
    cat >> $HOME/.bashrc << EOF

export GOPATH=$HOME/.go
export GOMODCACHE=$GOPATH/pkg/mod
export GOPROXY=https://goproxy.io,direct

#export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
#export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
export RUSTUP_DIST_SERVER=https://rsproxy.cn
export RUSTUP_UPDATE_ROOT=https://rsproxy.cn/rustup

export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin:/usr/local/node-v20.11.1-linux-x64/bin

eval '"$(starship init bash)"'

. "$HOME/.cargo/env"
EOF

    cat >> $HOME/.bash_profile << EOF
if [ -f $HOME/.bashrc ]; then
    source $HOME/.bashrc
fi
EOF
}

apt_source
tools || exit 1
go || exit 1
cnpm || exit 1
rust || exit 1
rust_tools || exit 1
zsh || exit 1
neovim || exit 1
#bashrc || exit 1

