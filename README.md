# Installation Guide

## Preparation

1. [Download](https://archlinux.org/download/) ISO and GPG files
1. Verify the ISO file: `$ pacman-key -v archlinux-<version>-dual.iso.sig`
1. Create a bootable usb with: `# dd if=archlinux*.iso of=/dev/sdX && sync`

## UEFI

1. Set boot mode to UEFI, disable Legacy mode entirely.
1. Temporarily disable Secure Boot.
1. Make sure a strong UEFI administrator password is set.
1. Delete preloaded OEM keys for Secure Boot, allow custom ones.
1. Set SATA operation to AHCI mode.

## Boot from USB drive

1. Plug in network cable or connect to wifi with `# wifi-menu`, ensure you have internet access.
1. Enable NTP: `# timedatectl set-ntp true`
1. Set larger font if needed:
    - `# pacman -Sy terminus-font`
    - `# setfont ter-132n`

## Partition the disk

1. Note the disk name with:

    ```sh
    # fdisk -l
    ```

1. Run `# fdisk` for that disk and select label type `gpt`.
1. Create partitions:
    - 100M - EFI system
    - 100% - Linux filesystem
1. Create file system on the EFI partition:

    ```sh
    # mkfs.vfat -n EFI -F32 /dev/sdX1
    ```

1. Encrypt the Linux partition:

    ```sh
    # cryptsetup luksFormat --type luks1 /dev/sdX2
    # cryptsetup luksOpen /dev/sdX2 luks
    ```

1. Create file system on the encrypted Linux partition:

    ```sh
    # mkfs.btrfs -L btrfs /dev/mapper/luks
    ```

1. Create and mount subvolumes:

    ```sh
    # mount /dev/mapper/luks /mnt
    # btrfs subvolume create /mnt/root
    # btrfs subvolume create /mnt/home
    # btrfs subvolume create /mnt/pkgs
    # btrfs subvolume create /mnt/logs
    # btrfs subvolume create /mnt/tmp
    # btrfs subvolume create /mnt/snapshots
    # umount /mnt
    # mount -o relatime,discard,compress=lzo,subvol=root /dev/mapper/luks /mnt
    # mkdir -p /mnt/mnt/btrfs-root
    # mkdir -p /mnt/boot/efi
    # mkdir -p /mnt/home
    # mkdir -p /mnt/var/cache/pacman
    # mkdir -p /mnt/var/log
    # mkdir -p /mnt/var/tmp
    # mkdir -p /mnt/.snapshots
    # mount /dev/sdX1 /mnt/boot/efi
    # mount -o relatime,discard,compress=lzo,subvol=/ /dev/mapper/luks /mnt/mnt/btrfs-root
    # mount -o relatime,discard,compress=lzo,subvol=home /dev/mapper/luks /mnt/home
    # mount -o relatime,discard,compress=lzo,subvol=pkgs /dev/mapper/luks /mnt/var/cache/pacman
    # mount -o relatime,discard,compress=lzo,subvol=logs /dev/mapper/luks /mnt/var/log
    # mount -o relatime,discard,compress=lzo,subvol=tmp /dev/mapper/luks /mnt/var/tmp
    # mount -o relatime,discard,compress=lzo,subvol=snapshots /dev/mapper/luks /mnt/.snapshots
    ```

## Install Arch Linux

1. Install packages:

    ```sh
    # pacstrap /mnt base base-devel linux linux-firmware
                    grub efibootmgr  # bootloader
                    amd-ucode        # or intel-ucode, microcode
                    zsh              # default shell
                    git openssh      # for dotfiles
                    terminus-font    # for pretty console
                    vim              # for editing files
                    networkmanager   # automatic network management
                    chezmoi          # config files
                    pass             # password manager
    ```

1. Generate fstab entries:

    ```
    # genfstab -U /mnt >> /mnt/etc/fstab
    ```

1. Enter the new system:

    ```
    # arch-chroot /mnt
    ```

1. Persist using larger console font after reboot:

    ```
    # echo "FONT=ter-c12n" > /etc/vconsole.conf
    # echo "KEYMAP=ru" >> /etc/vconsole.conf
    ```

1. Setup time zone:

    ```
    # ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
    ```

1. Configure hardware clock:

    ```
    # hwclock --systohc --utc
    ```

1. Configure system locate:

    ```
    # echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
    # echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
    # locale-gen
    # echo "LANG=en_US.UTF-8" > /etc/locale.conf
    ```

1. Configure hostname:

    ```
    # echo HOSTNAME > /etc/hostname
    # vi /etc/hosts

    127.0.0.1	localhost.localdomain	localhost
    ::1		localhost.localdomain	localhost
    127.0.1.1	HOSTNAME.localdomain	HOSTNAME
    ```

1. Configure passwordless unlock of root partition:

    ```
    # dd bs=512 count=4 if=/dev/urandom of=/crypto_keyfile.bin
    # chmod 000 /crypto_keyfile.bin
    # chmod 600 /boot/initramfs-linux*
    # cryptsetup luksAddKey /dev/sdX2 /crypto_keyfile.bin
    ```

1. Generate initial ramdisk environment:

    ```
    # vim /etc/mkinitcpio.conf
    - Add `consolefont` to HOOKS after `base`
    - Add `encrypt` to HOOKS before `filesystems`
    - Remove `fsck` from HOOKS
    - Add `/crypto_keyfile.bin` to FILES

    # mkinitcpio -p linux
    ```

1. Configure bootloader:

    ```
    # vim /etc/default/grub
    - Set:         GRUB_CMDLINE_LINUX="cryptdevice=/dev/sdX2:luks:allow-discards"
    - Set:         GRUB_GFXMODE=1280x1024x32,1024x768x32,auto
    - Uncomment:   GRUB_ENABLE_CRYPTODISK=y
    - Comment out: GRUB_GFXPAYLOAD_LINUX (terminus font is great at native resolution)

    # grub-mkconfig -o /boot/grub/grub.cfg
    # grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
    ```

1. Generate machine id:

    ```
    # dbus-uuidgen --ensure
    ```

1. Set `zsh` as default shell for root:

    ```
    # chsh -s /bin/zsh
    ```

1. Uncomment `multilib` repository.

    ```
    $ sudoedit /etc/pacman.conf

    [multilib]
    Include = /etc/pacman.d/mirrorlist
    ```

1. Create a user:

    ```
    # useradd -m -g users -G wheel -s /bin/zsh USERNAME
    # passwd USERNAME
    # EDITOR=vim visudo
    - Uncomment sudo access for `wheel` group
    ```

1. Exit new system and reboot:

    ```
    # exit
    # umount -R /mnt
    # reboot
    ```

## Final system configuration

1. Login as the new user
1. Start NetworkManager service:

    ```
    $ systemctl --now enable NetworkManager
    ```

1. Configure pass:

    ```
    $ git clone GIT_REPOSITORY ~/.password-store
    ```

1. Setup dotfiles:

    ```
    $ chezmoi init THIS_GIT_REPOSITORY
    ```

1. Install packages and plugins (needed resolve package conflicts):

    ```
    $ chezmoi cd
    $ make install
    ```

    While installing packages may be errors of GPG, Git and others, fix it and continue installing.

1. Configure fwupdmgr:

    ```
    $ sudo cp -r /usr/lib/fwupdate/EFI /boot/efi
    ```

1. Sign bootloader for Secure Boot:

    ```
    $ sudo cryptboot-efikeys create
    $ sudo cryptboot-efikeys enroll
    $ sudo cryptboot-efikeys sign /boot/efi/EFI/arch/grubx64.efi
    $ sudo cryptboot-efikeys sign /boot/efi/EFI/arch/fwupx64.efi
    ```

1. Disable root password:

    ```
    # passwd -dl root
    ```

1. Reboot and enable Secure Boot in UEFI.
