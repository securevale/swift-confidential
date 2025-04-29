#!/usr/bin/env bash

set -Eeuo pipefail

readonly LOGIN_SHELLS_FILE_PATH="/etc/shells"

readonly HOMEBREW_BASH_FORMULA="bash"
readonly HOMEBREW_BASH_X86_INSTALL_DIR="/usr/local/bin/bash"
readonly HOMEBREW_BASH_ARM_INSTALL_DIR="/opt/homebrew/bin/bash"

if ! command -v "brew" &>/dev/null
then
    echo "Error: 'brew' command not found. Please install Homebrew before running this script." 1>&2
    exit 1
fi

echo "-------------------------------- UPGRADE BASH --------------------------------"

if ! brew list $HOMEBREW_BASH_FORMULA &>/dev/null
then
    echo "Installing Bash ⚙️"
    brew install $HOMEBREW_BASH_FORMULA > /dev/null
else
    echo "Updating Bash ⚙️"
    brew upgrade $HOMEBREW_BASH_FORMULA > /dev/null
fi

if [[ -f "$HOMEBREW_BASH_ARM_INSTALL_DIR" ]]
then
    HOMEBREW_BASH_INSTALL_DIR="$HOMEBREW_BASH_ARM_INSTALL_DIR"
else
    HOMEBREW_BASH_INSTALL_DIR="$HOMEBREW_BASH_X86_INSTALL_DIR"
fi

if ! grep -q $HOMEBREW_BASH_INSTALL_DIR $LOGIN_SHELLS_FILE_PATH
then
    echo $HOMEBREW_BASH_INSTALL_DIR | sudo tee -a $LOGIN_SHELLS_FILE_PATH
fi

sudo chsh -s $HOMEBREW_BASH_INSTALL_DIR

echo -e "\n$(bash --version)"

echo "------------------------------ END UPGRADE BASH ------------------------------"
