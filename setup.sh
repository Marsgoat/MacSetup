#!/bin/bash
set -euo pipefail

function step(){
  echo "$(tput setaf 10)$1$(tput sgr0)"
}

step "Configure git"
git config --global user.name "Marsgoat"
git config --global user.email "johnny3681@gmail.com"
git config --global pull.rebase false

step "Get HomeBrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
if [[ $(uname -p) == 'arm' ]]; then
  step "Set Apple Silicon HomeBrew Path"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ${HOME}/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

step "Install utils"
brew install htop tree openssh cmake julia
brew install --cask the-unarchiver mos
brew install --cask topnotch # hide the notch

step "Install Java"
brew install --cask adoptopenjdk
echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 17)' >> ~/.zshrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.zshrc
source ~/.zshrc


step "Set ssh"
[ -d ~/.ssh ] || mkdir ~/.ssh
ssh-keygen -b 4096 -t rsa -f ~/.ssh/id_rsa -q -N "" <<< y
echo "" # newline

step "Font"
brew tap homebrew/cask-fonts
brew install font-sauce-code-pro-nerd-font
brew install font-caskaydia-cove-nerd-font

step "Modify Terminal Font"
osascript -e '
tell application "Terminal"
  set font name of settings set "Basic" to "CaskaydiaCove Nerd Font"
  set font size of settings set "Basic" to 16
end tell
'

step "Get oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
cp .p10k.zsh .zshrc ${HOME}/

step "Get HyperTerminal"
brew install --cask hyper
cp .hyper.js ${HOME}/

step "Get python & yapf"
PYTHON="python@3.11"
brew install ${PYTHON}
echo "export PATH=\$(brew --prefix)/opt/"${PYTHON}"/bin:\$PATH" >> ~/.zshrc
echo "export PATH=\$(brew --prefix)/opt/"${PYTHON}"/libexec/bin:\$PATH" >> ~/.zshrc
export PATH=$(brew --prefix)/opt/$PYTHON/bin:$PATH
export PATH=$(brew --prefix)/opt/$PYTHON/libexec/bin:$PATH
pip install yapf
[ -d ${HOME}/.config/yapf ] || mkdir -p ${HOME}/.config/yapf
cat <<EOF | tee ${HOME}/.config/yapf/style
[style]
based_on_style = google
EOF

step "Miniconda 3"
brew install --cask miniconda
conda init "$(basename "${SHELL}")"
conda config --set auto_activate_base false

step "Get nvm"
brew install nvm
mkdir ~/.nvm
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
echo '[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"' >> ~/.zshrc
echo '[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"' >> ~/.zshrc
source ~/.zshrc
nvm install node
