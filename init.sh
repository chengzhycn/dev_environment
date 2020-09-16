#!/bin/bash

set -x


########## BEG ENVIRONMENTS ##########
SUPPORT_SHELL=("zsh" "fish")
SUPPORT_OS=("mac" "ubuntu" "centos")
DEFAULT_SHELL="bash"
DEFAULT_OS="mac"

DEFAULT_PATH=/usr/local/bin


########## END ENVIRONMENTS ##########


########## BEG SHELL ##########
# init zsh use oh-my-zsh
function init_zsh() {
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

    git clone git://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

}

function init_fish() {

}

########## END SHELL ##########


########## BEG HOMEBREW ##########
function install_brew() {
    xcode-select --install || true

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" ||
        {
            echo "install brew failed."
            return 1
        }
    return 0
}

function change_brew_src {
    # Homebrew
    git -C "$(brew --repo)" remote set-url origin https://mirrors.ustc.edu.cn/brew.git

    # Homebrew Core
    git -C "$(brew --repo homebrew/core)" remote set-url origin https://mirrors.ustc.edu.cn/homebrew-core.git

    # Homebrew Cask
    git -C "$(brew --repo homebrew/cask)" remote set-url origin https://mirrors.ustc.edu.cn/homebrew-cask.git

    # Homebrew-bottles
    case "${DEFAULT_SHELL}" in
    "bash")
        echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.bash_profile
        return 0
        ;;
    "zsh")
        echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.zshrc
        return 0
        ;;
    "fish")
        echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.config/fish/config.fish
        return 0
        ;;
    *)
        echo "error: unsupport shell!!!"
        return 1
        ;;
    esac

}

########## END HOMEBREW ##########

########## BEG BASIC TOOLS ##########
function install_basic_tools() {
    if [[ "${DEFAULT_OS}" == "mac" ]]; then
        # install some useful tools
        brew install zsh lua go lrzsz jq bat fish starship llvm

        # for nerd fonts
        brew tap homebrew/cask-fonts

        brew cask install font-ubuntu-mono-nerd-font
    fi
    
}

function install_enhanced_tools() {
    # z.lua
    git clone https://github.com/skywind3000/z.lua.git -C ~/.z.lua > /dev/null 2>&1 ||
        {
            echo "cloning z.lua failed"
            return 1
        }

    case "${DEFAULT_SHELL}" in
    "bash")
        echo 'eval "$(lua ~/.z.lua --init bash enhanced once fzf)"' >> ~/.bashrc
        ;;
    "zsh")
        echo 'eval "$(lua /path/to/z.lua --init zsh)"' >> ~/.zshrc
        ;;
    "fish")
        mkdir -p ~/.config/fish/conf.d
        echo 'source (lua /path/to/z.lua --init fish | psub)' >> ~/.config/fish/conf.d/z.fish
        ;;
    *)
        echo "error: unsupport shell!!!"
        return 1
        ;;
    esac

}


# for local kubernetes
function install_k8s() {
    if [[ "${DEFAULT_OS}" == "mac" ]]; then
        brew install kind kubectl octant
    else
        # install kind
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.8.1/kind-linux-amd64
        chmod +x ./kind
        mv ./kind /"${DEFAULT_PATH}"/kind
    fi
}



########## END BASIC TOOLS ##########


########## BEG BASIC FUNCTIONS ##########
function contains_element() {
    local element="$1"
    local arr
    shift

    for arr; do
        [[ "$element" == $"arr" ]] && return 0
    done

    return 1
}

function usage() {
    local prog=$(basename $0)
    echo "USAGE:"
    echo -e "\t${prog} []"

}

########## END BASIC FUNCTIONS ##########


########## BEG MAIN ##########
while getopts ":ho:s:" arg; do
    case "${arg}" in
        o)
            DEFAULT_OS="${OPTARG}"
            contains_element "${DEFAULT_OS}" "${SUPPORT_OS[@]}" ||
                {
                    echo "unsupport os: " "${DEFAULT_OS}"
                    exit 1
                }
            ;;
        s)
            DEFAULT_SHELL="${OPTARG}"
            contains_element "${DEFAULT_SHELL}" "${SUPPORT_SHELL[@]}" ||
                {
                    echo "error: unsupport shell: " "${DEFAULT_SHELL}"
                    exit 1
                }
            ;;
        *)
            echo "error: unknown options."
            usage
            exit 1
            ;;
    esac
done
        
######### END MAIN ##########
