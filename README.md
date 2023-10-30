x # i3 Dots

## 1. Setting up the `yay` AUR helper

The Arch User Repository (AUR) provides a collection of user-contributed packages. `yay` is a helper that makes it easier to manage these packages. First, you need to install `yay`:

```bash
# Install necessary dependencies
pacman -S --needed git base-devel

# Clone the `yay` repository and install
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

## 2. Installing Essential Dependencies

These are the foundational packages required for setting up the system.

```bash
# General dependencies
yay -S base-devel wget git curl xorg-xrandr arandr man-db

# Theming and appearance
yay -S thunar xfce4-settings gtk3 dracula-gtk-theme dracula-icons-git lxappearance

# Utilities and system tools
yay -S gvfs polkit-gnome rofi dunst brightnessctl pavucontrol xclip feh polybar picom gnome-keyring seahorse btop man-db pacman-contrib vi vim neovim mpd mpc flameshot neofetch timeshift gparted bluez bluez-utils blueman nm-connection-editor networkmanager-openvpn

# Font essentials
yay -S otf-font-awesome ttf-jetbrains-mono-nerd ttf-jetbrains-mono otf-font-awesome-4 ttf-droid ttf-fantasque-sans-mono adobe-source-code-pro-fonts noto-fonts-emoji

# Document viewers
yay -S zathura zathura-pdf-mupdf

# Communication and media apps
yay -S discord spotify
```

## 3. Setting up Zsh with Oh My Zsh

Zsh is an advanced shell, and Oh My Zsh is a framework for managing Zsh configurations.

```bash
# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Add autosuggestions plugin
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

# Add syntax highlighting plugin
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Adjust permissions
chmod 700 ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
```

## 4. Development Dependencies

These are packages and utilities related to software development.

### IDEs

```bash
# Install Visual Studio Code and Rider
yay -S visual-studio-code-bin rider
```

### Node.js with Nvm

Nvm (Node Version Manager) allows you to easily manage multiple versions of Node.js.

```bash
# Install Nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

# Install the latest LTS (Long Term Support) version of Node.js
nvm install lts
```

### .NET Development

.NET is a free, cross-platform, open-source developer platform for building many different types of applications.

```bash
# Install essential .NET packages
yay -S dotnet-targeting-pack-6.0 dotnet-runtime-6.0 dotnet-sdk-6.0 dotnet-runtime dotnet-host dotnet-sdk

# Optional: Install preview versions of .NET packages
yay -S dotnet-targeting-pack-preview-bin dotnet-runtime-preview-bin dotnet-sdk-preview-bin dotnet-host-preview-bin aspnet-targeting-pack-preview-bin aspnet-runtime-preview-bin aspnet-targeting-pack-6.0 aspnet-targeting-pack aspnet-runtime-6.0 aspnet-runtime
```

---
