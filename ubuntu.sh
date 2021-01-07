#!/bin/bash

CARGO_CONFIG_DIR=$HOME/.cargo
CARGO=$(command -v cargo 2>/dev/null)
CARGO_TOOLS=(starship fd-find exa bat)

function tools() {
    sudo apt install shellcheck lua5.3 jq git make curl -y
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

    cat > "${CARGO_CONFIG_DIR}"/config << EOF
[source.crates-io]
registry = "https://github.com/rust-lang/crates.io-index"
replace-with = 'ustc'

[source.ustc]
# registry = "https://mirrors.ustc.edu.cn/crates.io-index"
registry = "git://mirrors.ustc.edu.cn/crates.io-index"

[source.tuna]
registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"

[source.rustcc]
registry = "https://code.aliyun.com/rustcc/crates.io-index.git"
EOF
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

apt_source
tools || exit 1
rust || exit 1
rust_tools || exit 1
