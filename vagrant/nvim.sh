#!/bin/bash

export RUSTUP_DIST_SERVER=https://rsproxy.cn
export RUSTUP_UPDATE_ROOT=https://rsproxy.cn/rustup
export GOPATH=$HOME/.go
export GOMODCACHE=$GOPATH/pkg/mod
export GOPROXY=https://goproxy.io,direct
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin:/opt/nvim-linux64/bin:/usr/local/node-v20.11.1-linux-x64/bin

function python_lib_install() {
    pip3 install --user --upgrade neovim || return 1
}

function lspconfig_install() {
    # Go
    go install golang.org/x/tools/gopls@latest || return 1

    # Bash
    cnpm i -g bash-language-server || return 1

    # Python
    cnpm i -g pyright || return 1

    # C/C++
    sudo apt install clangd-12 -y || return 1  # for ubuntu

    # Rust
    mkdir -p ~/.local/bin           # for linux
    curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz | gunzip -c - > ~/.local/bin/rust-analyzer
    chmod +x ~/.local/bin/rust-analyzer

    # Lua
    mkdir -p ~/.local/lua-language-server   # for linux
    curl -L https://github.com/LuaLS/lua-language-server/releases/download/2.6.7/lua-language-server-2.6.7-linux-x64.tar.gz | tar -xz -C ~/.local/lua-language-server
    ln -s ~/.local/lua-language-server/bin/lua-language-server ~/.local/bin/lua-language-server
}

function plugins_install() {
    for line in $(cat ~/.config/nvim/plugin.list); do 
        git clone ${line} ~/.local/share/nvim/site/pack/packer/start/${line##*/}
    done
}

python_lib_install || exit 1
lspconfig_install || exit 1 

git clone https://github.com/chengzhycn/nvim_config.git ~/.config/nvim/ || exit 1

plugins_install || exit 1
