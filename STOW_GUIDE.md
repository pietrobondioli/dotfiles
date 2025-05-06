# Managing Dotfiles with GNU Stow

## Overview

This dotfiles repository uses [GNU Stow](https://www.gnu.org/software/stow/) to manage configuration files across different systems. Stow creates symlinks from this repository to your home directory, allowing you to keep all configurations in one place while maintaining a clean separation by program/category.

## Prerequisites

- GNU Stow:
  - Arch Linux: `sudo pacman -S stow`
  - Ubuntu/Debian: `sudo apt install stow`
  - macOS: `brew install stow`

## Basic Structure

```
dotfiles/
├── bash/              # Package for bash configuration
│   └── .bashrc        # Will be symlinked to ~/.bashrc
├── git/               # Package for git configuration
│   └── .gitconfig     # Will be symlinked to ~/.gitconfig
├── vim/               # Package for vim configuration
│   └── .vimrc         # Will be symlinked to ~/.vimrc
└── xorg/              # Package for X11 configuration
    └── .Xresources    # Will be symlinked to ~/.Xresources
```

## Commands

### Setting Up Symlinks

To create symlinks for a package:

```bash
cd ~/dotfiles
stow bash              # Creates symlinks for the bash package
stow vim git xorg      # Creates symlinks for multiple packages at once
```

### Removing Symlinks

To remove symlinks for a package:

```bash
cd ~/dotfiles
stow -D bash           # Removes symlinks for the bash package
```

### Restowing (Update Symlinks)

To update symlinks after adding/removing files:

```bash
cd ~/dotfiles
stow -R bash           # Updates symlinks for the bash package
```

### Adding Existing Dotfiles

To add an existing dotfile to your repository:

1. Create the appropriate package directory structure:

```bash
mkdir -p ~/dotfiles/new-package
```

2. Move the file to the package:

```bash
mv ~/.config-file ~/dotfiles/new-package/
```

3. Create the symlink:

```bash
cd ~/dotfiles
stow new-package
```

### Adopting Existing Files

To incorporate existing files without manually moving them:

```bash
cd ~/dotfiles
stow --adopt new-package
```

**Warning**: `--adopt` will overwrite files in your stow package with the versions from your home directory.

## Tips

- Create packages based on programs (vim, bash) or categories (editors, shell)
- Use `.stow-local-ignore` to exclude files from stowing
- Use `--no-folding` if you need direct symlinks instead of directory symlinks
- For subdirectories, maintain the same structure in your package:

  ```
  dotfiles/nvim/.config/nvim/init.vim → ~/.config/nvim/init.vim
  ```

## Troubleshooting

- **Conflicts**: Use `stow -n package` (dry run) to check for conflicts
- **Existing files**: Back up and remove existing dotfiles before stowing, or use `--adopt`
- **Permissions**: Ensure you have write permissions to your home directory
