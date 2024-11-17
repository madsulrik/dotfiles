# Dotfiles Repository

## Introduction

This repository contains my personal dotfiles for various tools I use on a daily basis. It includes configurations for Doom Emacs and Neovim, tailored to enhance productivity and functionality.


## Installation

```bash
git clone https://github.com/madsulrik/dotfiles.git
cd dotfiles


# Link Alacritty configuration
ln -s $(pwd)/alacritty ~/.config/alacritty

# Link Tmux configuration
ln -s $(pwd)/tmux ~/.config/tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Link Doom Emacs configuration
ln -s $(pwd)/doom-emacs ~/.config/.doom.d

# Link Neovim configuration
ln -s $(pwd)/nvim ~/.config/nvim
```
