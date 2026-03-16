#!/bin/bash
set -euo pipefail

function step(){
  echo "$(tput setaf 10)$1$(tput sgr0)"
}

function skip(){
  echo "$(tput setaf 11)  ⏭ $1 already installed, skipping$(tput sgr0)"
}

function brew_install(){
  if brew list "$1" &>/dev/null; then
    skip "$1"
  else
    brew install "$1"
  fi
}

function brew_install_cask(){
  if brew list --cask "$1" &>/dev/null; then
    skip "$1"
  else
    brew install --cask "$1"
  fi
}

function append_if_missing(){
  local file="$1"
  local line="$2"
  grep -qF "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

step "Configure git"
git config --global user.name "Marsgoat"
git config --global user.email "johnny3681@gmail.com"
git config --global pull.rebase false

step "Get HomeBrew"
if command -v brew &>/dev/null; then
  skip "HomeBrew"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ $(uname -p) == 'arm' ]]; then
    step "Set Apple Silicon HomeBrew Path"
    append_if_missing "${HOME}/.zprofile" 'eval "$(/opt/homebrew/bin/brew shellenv)"'
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

step "Set default shell to zsh"
if [ "$SHELL" = "/bin/zsh" ]; then
  skip "zsh (already default shell)"
else
  chsh -s /bin/zsh
fi

step "Install utils"
for pkg in htop tree openssh cmake coreutils; do
  brew_install "$pkg"
done
for cask in the-unarchiver mos topnotch; do
  brew_install_cask "$cask"
done

step "Install Java"
brew_install_cask "temurin"
append_if_missing ~/.zshrc 'export JAVA_HOME=$(/usr/libexec/java_home -v 21)'
append_if_missing ~/.zshrc 'export PATH=$JAVA_HOME/bin:$PATH'

step "Set ssh"
if [ -f ~/.ssh/id_rsa ]; then
  skip "SSH key"
else
  [ -d ~/.ssh ] || mkdir ~/.ssh
  ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -q -N "" <<< y
  echo "" # newline
fi

step "Font"
brew_install "font-sauce-code-pro-nerd-font"
brew_install "font-caskaydia-cove-nerd-font"

step "Modify Terminal Font"
osascript -e '
tell application "Terminal"
  set font name of settings set "Basic" to "CaskaydiaCove Nerd Font"
  set font size of settings set "Basic" to 16
end tell
'

step "Get oh-my-zsh"
if [ -d ~/.oh-my-zsh ]; then
  skip "oh-my-zsh"
else
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
fi
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"
if [ -d "${ZSH_CUSTOM_DIR}/plugins/zsh-autosuggestions" ]; then
  skip "zsh-autosuggestions"
else
  git clone https://github.com/zsh-users/zsh-autosuggestions.git "${ZSH_CUSTOM_DIR}/plugins/zsh-autosuggestions"
fi
if [ -d "${ZSH_CUSTOM_DIR}/plugins/zsh-syntax-highlighting" ]; then
  skip "zsh-syntax-highlighting"
else
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM_DIR}/plugins/zsh-syntax-highlighting"
fi
if [ -d "${ZSH_CUSTOM_DIR}/themes/powerlevel10k" ]; then
  skip "powerlevel10k"
else
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM_DIR}/themes/powerlevel10k"
fi
cp .p10k.zsh .zshrc ${HOME}/

step "Get HyperTerminal"
brew_install_cask "hyper"
cp .hyper.js ${HOME}/

step "Get python & yapf"
PYTHON="python@3.11"
brew_install "${PYTHON}"
append_if_missing ~/.zshrc "export PATH=\$(brew --prefix)/opt/${PYTHON}/bin:\$PATH"
append_if_missing ~/.zshrc "export PATH=\$(brew --prefix)/opt/${PYTHON}/libexec/bin:\$PATH"
export PATH=$(brew --prefix)/opt/$PYTHON/bin:$PATH
export PATH=$(brew --prefix)/opt/$PYTHON/libexec/bin:$PATH
if command -v yapf &>/dev/null; then
  skip "yapf"
else
  pip install yapf
fi
[ -d ${HOME}/.config/yapf ] || mkdir -p ${HOME}/.config/yapf
cat <<EOF | tee ${HOME}/.config/yapf/style
[style]
based_on_style = google
EOF

step "Miniconda 3"
brew_install_cask "miniconda"
conda init "$(basename "${SHELL}")"
conda config --set auto_activate_base false

step "Get nvm"
brew_install "nvm"
[ -d ~/.nvm ] || mkdir ~/.nvm
append_if_missing ~/.zshrc 'export NVM_DIR="$HOME/.nvm"'
append_if_missing ~/.zshrc '[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"'
append_if_missing ~/.zshrc '[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"'
source ~/.zshrc
nvm install --lts
