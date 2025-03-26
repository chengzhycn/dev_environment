#!/bin/bash

CARGO_CONFIG_DIR=$HOME/.cargo
CARGO=$(command -v cargo 2>/dev/null)
CARGO_TOOLS=(starship fd-find exa bat)

function tools() {
    sudo apt install zsh shellcheck lua5.3 jq git make curl tig silversearcher-ag -y
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
}

function rust() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh ||
        {
            echo "error install rust: " "$?"
            return 1
        }

    if [[ ! -d "${CARGO_CONFIG_DIR}" ]]; then
        mkdir "${CARGO_CONFIG_DIR}"
    fi

    cat > "${CARGO_CONFIG_DIR}"/config.toml << EOF
[source.crates-io]
registry = "https://github.com/rust-lang/crates.io-index"
replace-with = 'tuna'

[source.ustc]
# registry = "https://mirrors.ustc.edu.cn/crates.io-index"
registry = "git://mirrors.ustc.edu.cn/crates.io-index"

[source.tuna]
registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"

[source.rustcc]
registry = "https://code.aliyun.com/rustcc/crates.io-index.git"
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

function zsh() {
    if ! command -v zsh >/dev/null 2>&1; then
        echo "zsh is not installed, install it first"
        return 1
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

    # apply starship prompt
    echo 'eval "$(starship init zsh)"' >> "${HOME}"/.zshrc
    # source "${HOME}"/.zshrc
}

function bashrc() {
    cat >> $HOME/.bashrc << EOF

export GOPATH=$HOME/.go
export GOMODCACHE=$GOPATH/pkg/mod
export GOPROXY=https://goproxy.io,direct

export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup

export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

eval "$(starship init bash)"

. "$HOME/.cargo/env"
EOF

    cat >> $HOME/.bash_profile << EOF
if [ -f $HOME/.bashrc ]; then
    source $HOME/.bashrc
fi
EOF
}

#apt_source
tools || exit 1
# rust || exit 1
# rust_tools || exit 1
# zsh || exit 1
bashrc || exit 1
