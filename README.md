# MacSetup

### Install Requirements

```bash
xcode-select --install
```

If you want to install AdoptOpenJDK on an M1 or M2 chip, you need to first install Rosetta 2.

```bash
softwareupdate --install-rosetta
```

### Usage

Modify this step before running the script.

```bash
step "Configure git"
git config --global user.name "Your Name"
git config --global user.email "youremail@example.com"
git config --global pull.rebase false
```

If you only need certain parts of the `setup.sh` script, you can choose to comment out the parts you don't need.
You can also add new environments or packages that you need.

```bash
git clone https://github.com/Marsgoat/MacSetup.git
cd MacSetup
./setup.sh
```

### Utils

[Top Notch](https://formulae.brew.sh/cask/topnotch)
If you don't like the notch on your MacBook, you can use topnotch to hide it.

```bash
brew install --cask topnotch
```

[The Unarchiver](https://formulae.brew.sh/cask/the-unarchiver)
decompression tool

```bash
brew install --cask the-unarchiver
```

[mos](https://formulae.brew.sh/cask/mos)
mouse controller

```bash
brew install --cask mos
```

[Tree](https://formulae.brew.sh/formula/tree)
a command-line utility that displays the contents of a directory in a tree-like format, making it easy to navigate nested directories and see the file hierarchy.

```bash
brew install tree
```
