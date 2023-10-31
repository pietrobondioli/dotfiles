# i3 Dots

Just another i3 rice.

Screenshot:

![Screenshot](./sample.png)

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
yay -S linux-headers base-devel wget git curl xorg-xrandr arandr man-db

# i3
yay -S i3 i3status i3lock-colors i3blocks bumblebee-status

# Theming and appearance
yay -S thunar xfce4-settings gtk3 dracula-gtk-theme dracula-icons-git lxappearance materia-gtk-theme papirus-icon-theme bibata-cursor-theme vimix-cursors

# Utilities and system tools
yay -S gvfs polkit-gnome rofi dunst brightnessctl pavucontrol xclip feh polybar picom gnome-keyring seahorse btop man-db pacman-contrib vi vim neovim mpd mpc flameshot neofetch timeshift gparted bluez bluez-utils blueman nm-connection-editor networkmanager-openvpn qimgv

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

## Nvidia config

### Default Prerequisites

- If you are using anything other than the regular linux kernel, such as linux-lts, you need to make changes accordingly.
- Do not reboot before you have finished all the steps below.

### Step 1: Installing the driver packages

1. This step might be a bit confusing. First find your [nvidia card from this list here](https://nouveau.freedesktop.org/CodeNames.html)
2. After reading if you still don't know what driver you need, take a look of that list on gentoo wiki [here](https://wiki.gentoo.org/wiki/NVIDIA#Feature_support) that lists the latest driver that supports your CHIPSET. For example, if you have a GTX 3060, you need to install the latest version of nvidia, so just `yay -S nvidia nvidia-utils lib32-nvidia-utils`.
3. Check what driver packages you need to install from the list below

| Driver name                                      | Base driver       | OpenGL             | OpenGL (multilib)        |
| ------------------------------------------------ | ----------------- | ------------------ | ------------------------ | --- |
| Maxwell (NV110) series and newer                 | nvidia            | nvidia-utils       | lib32-nvidia-utils       | m   |
| Kepler (NVE0) series                             | nvidia-470xx-dkms | nvidia-470xx-utils | lib32-nvidia-470xx-utils |
| GeForce 400/500/600 series cards [NVCx and NVDx] | nvidia-390xx      | nvidia-390xx-utils | lib32-nvidia-390xx-utils |

3. Install the correct packages, for example `yay -S nvidia-470xx-dkms nvidia-470xx-utils lib32-nvidia-470xx-utils`
4. I also recommend you to install nvidia-settings via `yay -S nvidia-settings`

In my case I have a GeForce RTX 3060 Ti, which is a NV110 card, so I installed the following packages:

```bash
yay -S nvidia nvidia-utils lib32-nvidia-utils
```

### Step 2: Enabling DRM kernel mode setting

1. Add the kernel parameter

   A. If you are using grub:

   - Go to your grub file with `sudo nano /etc/default/grub`
   - Find `GRUB_CMDLINE_LINUX_DEFAULT`
   - Append the line with `nvidia-drm.modeset=1`
   - For example: `GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nvidia-drm.modeset=1"`
   - Save the file with _CTRL+O_
   - Finish the grub config with `sudo grub-mkconfig -o /boot/grub/grub.cfg`

   B. If you are using systemd-boot:

   - Go to your systemd-boot file with `sudo nano /boot/loader/entries/arch.conf`
   - Find `options`
   - Append the line with `nvidia-drm.modeset=1`
   - For example: `options root=UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx rw quiet nvidia-drm.modeset=1`
   - Save the file

In my case I am using systemd-boot, so my file was:

```bash
# Created by: archinstall
# Created on: 2023-10-29_22-09-49
title   Arch Linux (linux)
linux   /vmlinuz-linux
initrd  /amd-ucode.img
initrd  /initramfs-linux.img
options root=PARTUUID=1a3bdf5e-4121-47cf-b93c-df8686e8bf49 zswap.enabled=0 rootflags=subvol=@ rw rootfstype=btrfs
```

And I changed it to:

```bash
# Created by: archinstall
# Created on: 2023-10-29_22-09-49
title   Arch Linux (linux)
linux   /vmlinuz-linux
initrd  /amd-ucode.img
initrd  /initramfs-linux.img
options root=PARTUUID=1a3bdf5e-4121-47cf-b93c-df8686e8bf49 zswap.enabled=0 rootflags=subvol=@ rw rootfstype=btrfs nvidia-drm.modeset=1
```

2. Add the early loading

- Go to your mkinitcpio configuration file with `sudo nano /etc/mkinitcpio.conf`
- Find `MODULES=()`
- Edit the line to match `MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)`
- Save the file with _CTRL+O_
- Finish the mkinitcpio configuration with `sudo mkinitcpio -P`

3. Adding the pacman hook

- Find the _nvidia.hook_ in this repository ([here](./nvidia/nvidia.hook)), make a local copy and open the file with your preferred editor
- Find `Target=nvidia`
- Replace the _nvidia_ with the base driver you installed, e.g. `nvidia-470xx-dkms`
- Save the file and move it to `/etc/pacman.d/hooks/` , for example with `sudo mv ./nvidia.hook /etc/pacman.d/hooks/`

## 4. Development

These are packages and utilities related to software development.

### IDEs

```bash
# Install Visual Studio Code and Rider
yay -S visual-studio-code-bin rider
```

Change vscode desktop to exec from shell to fix PATH issues:

```bash
# Open vscode desktop file
sudo vim /usr/share/applications/code.desktop

# Change the exec line to
Exec=zsh -i -c "code"
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
