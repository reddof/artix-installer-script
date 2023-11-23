#!/bin/bash

# Dalam script ini saya kumpulkan semua perintah perintah
# untuk install Artix Linux secara manual
# layaknya kita install Arch Linux.

DIR=$(pwd)
MY_CHROOT=/mnt
CHOICE="Silakan Masukkan Pilihan Anda"
ERROR="Input yang anda masukkan salah tekan enter untuk kembali"

# MAIN MENU
MAIN_MENU () {
clear
read -p "
### MAIN MENU ###

1. Install Base
2. Post Install
3. Setelah Reboot

q. Keluar

$CHOICE : " pilihan
    case $pilihan in
        1) BASE_INST
        ;;
        2) POST_INST
        ;;
        3) AFTER_INST
        ;;
        [Qq]*) clear
        exit
        ;;
        *) clear
        read -p "
$ERROR " ret
            case $ret in
                *) MAIN_MENU
                ;;
            esac
        ;;
    esac
}
# 1. Install Base
BASE_INST () {
clear
read -p "
### BASE INSTALL ###

1. Install Kernel
2. Membuat file fstab

q. Kembali ke menu sebelumnya

$CHOICE : " pilihan
    case $pilihan in
        1) KERN_INST
        ;;
        2) GEN_FSTAB
        ;;
        [Qq]*) clear
        MAIN_MENU
        ;;
        *) clear
        read -p "
$ERROR " ret
            case $ret in
                *) BASE_INST
                ;;
            esac
        ;;
    esac
}
#     1.1. Install Kernel
KERN_INST () {
clear
read -p "
Apakah anda ingin install kernel dan packages  pendukung ?

[Y/n] : " yn
    case $yn in
        [Yy]*) clear
        read -p "
Silakan masukkan kernel yang ingin anda install
misalnya linux, linux-lts, linux-zen
list kernel bisa dilihat di Arch Wiki

kernel : " kern
        basestrap /mnt base base-devel elogind-runit runit $kern linux-firmware intel-ucode cups cups-runit cups-pdf networkmanager networkmanager-runit vim ntfs-3g man-db ntp ntp-runit openssh openssh-runit --overwrite "*"
        read -p "
$kern berhasil diinstall tekan enter untuk kembali " ret
            case $ret in
                *) BASE_INST
                ;;
            esac
        ;;
        [Nn]*) BASE_INST
        ;;
        *) clear
        read -p "
$ERROR " ret
            case $ret in
                *) KERN_INST
                ;;
            esac
        ;;
    esac
}
#     1.2. Membuat fili fstab
GEN_FSTAB () {
clear
read -p "
Apakah anda ingin membuat file fstab ?

[Y/n] : " yn
    case $yn in
        [Yy]*) clear
        fstabgen -U $MY_CHROOT > $MY_CHROOT/etc/fstab
        cat $MY_CHROOT/etc/fstab
        read -p "
File fsatab berhasil dibuat tekan enter untuk kembali " ret
            case $ret in
                *) BASE_INST
                ;;
            esac
        ;;
        [Nn]*) clear
        BASE_INST
        ;;
        *) clear
        read -p "
$ERROR " ret
            case $ret in
                *) GEN_FSTAB
                ;;
            esac
        ;;
    esac
}
# 2. Post Install
POST_INST () {
clear
read -p "
### POST INSTALL ###

LAKUKAN LANGKAH INI SETELAH
MEMASUKI MODE CHROOT

1. Setting Password
2. Setting Bahasa
3. Setting Timezone
4. Setting Hostname
5. Install dan konfigurasi Grub

q. Kembali ke menu sebelumnya

$CHOICE : " pilihan
    case $pilihan in
        1) SET_PASSWD
        ;;
        2) SET_LANG
        ;;
        3) SET_TZ
        ;;
        4) SET_HOSTNAME
        ;;
        5) SET_GRUB
        ;;
        [Qq]*) clear
        MAIN_MENU
        ;;
        *) clear
        read -p "
$ERROR " ret
            case $ret in
                *) POST_INST
                ;;
            esac
        ;;
    esac
}
#     2.1. Setting Password
SET_PASSWD () {
clear
read -p "
Apakah anda ingin setting password root ?

[Y/n] : " yn
    case $yn in
        [Yy]*) clear
        passwd
        read -p "
Setting password roort berhasil tekan enter untuk kembali " ret
            case $ret in
                *) POST_INST
                ;;
            esac
        ;;
        [Nn]*) clear
        POST_INST
        ;;
        *) clear
        read -p "
$ERROR " ret
            case $ret in
                *) SET_PASSWD
                ;;
            esac
        ;;
    esac
}
#     2.2. Setting Bahasa
SET_LANG () {
clear
read -p "
Apakah anda ingin mengatur bahasa?

[Y/n] : " yn
    case $yn in
        [Yy]*) clear
        read -p "
Silakan masukkan bahasa utama anda misalnya en_US untuk bahasa Inggris

" lang1
        read -p "
Silakan masukkan bahasa kedua anda misalnya id_ID untuk bahasa Indonesia

" lang2
        read -p "
Apakah anda ingin mengatur $lang1 sebagai bahasa utama dan $lang2 sebagai bahasa kedua?

[Y/n] : " yn
            case $yn in
                [Yy]*) echo "$lang1.UTF-8 UTF-8" >> /etc/locale.gen
                    echo "$lang2.UTF-8 UTF-8" >> /etc/locale.gen
                    locale-gen
                    echo "LANG=$lang1.UTF-8" > /etc/locale.conf
                    read -p "
Setting bahasa utama $lang1 dan bahasa kedua $lang2 berhasil
Tekan enter untuk kembali " ret
                        case $ret in
                            *) POST_INST
                            ;;
                        esac
                ;;
                [Nn]*) clear
                POST_INST
                ;;
                *) clear
                read -p "
$ERROR " ret
                    case $ret in
                        *) SET_LANG
                        ;;
                    esac
                ;;
            esac
        ;;
        [Nn]*) clear
        POST_INST
        ;;
        *) clear
        read -p "
$ERROR " ret
            case $ret in
                *) SET_LANG
                ;;
            esac
        ;;
    esac
}
#     2.3. Setting Timezone
SET_TZ () {
clear
read -p "
Apakah anda ingin mengatur timezone ?

[Y/n] : " yn
    case $yn in
        [Yy]*) clear
        read -p "
Masukkan region anda diawali huruf kapital, misalnya Asia : " region
        read -p "
Masukkan kota anda diawali huruf kapital, misalnya Jakarta : " kota
        read -p "
Apakah anda ingin mengatur zona waktu ke $region/$kota ?

[Y/n] : " yn
                case $yn in
                    [Y/y]*) ln -sf /usr/share/zoneinfo/$region/$kota /etc/localtime
                    hwclock -w -l
                    read -p "

Setting timezone berhasil tekan enter untuk kembali " ret
                        case $ret in
                            *) POST_INST
                            ;;
                        esac
                        ;;
                    [N/n]*) POST_INST
                    ;;
                    *) clear
                    read -p "
$ERROR " ret
                        case $ret in
                            *) SET_TZ
                            ;;
                        esac
                    ;;
                esac
        ;;
        [Nn]*) clear
        POST_INST
        ;;
        *) clear
        read -p "
$ERROR " ret
            case $ret in
                *) SET_TZ
                ;;
            esac
        ;;
    esac
}
#     2.4. Setting Hostname
SET_HOSTNAME () {
clear
read -p "
Apakah anda ingin mengatur hostname ?

[Y/n] : " yn
    case $yn in
        [Yy]*) clear
        read -p "
Masukkan hostname untuk komputer anda : " hostname
        read -p "
Apakah anda ingin $hostname menjadi hostname komputer anda :

[Y/n] : " yn
            case $yn in
                [Yy]*) echo "$hostname" > /etc/hostname
                read -p "
Setting Hostname berhasil tekan enter untuk kembali " ret
                            case $ret in
                                *) clear
                                POST_INST
                                ;;
                            esac
                ;;
                [Nn]*) clear
                POST_INST
                ;;
                *) clear
                read -p "
$ERROR " ret
                        case $ret in
                            *) SET_HOSTNAME
                        esac
                    ;;
            esac
        read -p "
Setting hostname berhasil tekan enter untuk kembali " ret
            case $ret in
                *) POST_INST
                ;;
            esac
        ;;
        [Nn]*) clear
        POST_INST
        ;;
        *) clear
        read -p "
$ERROR " ret
            case $ret in
                *) SET_HOSTNAME
                ;;
            esac
        ;;
    esac
}
#     2.5. Install dan konfigurasi Grub
SET_GRUB () {
clear
read -p "
Apakah anda ingin install dan konfigurasi grub ?

[Y/n] : " yn
    case $yn in
        [Yy]*) pacman -S grub efibootmgr os-prober plymouth
        read -p "
Silakan masukkan efi direktori anda misalnya /boot/efi : " efi
        read -p "Silakan masukkan bootloader id anda misalnya Artix Linux : " bootldrid
        read -p "
Apakah anda ingin install grub di $efi dengan bootloader id $bootldrid

[Y/n] : " yn
            case $yn in
                [Yy]*) grub-install --efi-directory=$efi --bootloader-id="$bootldrid"
                grub-mkconfig -o /boot/grub/grub.cfg
                read -p "
Install dan konfigurasi Grub berhasil
Tekan enter untuk kembali " ret
                            case $ret in
                                *) POST_INST
                                ;;
                            esac
                ;;
                [Nn]*) clear
                POST_INST
                ;;
                *) read -p "
$ERROR " ret
                    case $ret in
                        *) SET_GRUB
                        ;;
                    esac
                ;;
            esac
        ;;
        [Nn]*) clear
        POST_INST
        ;;
        *) clear
        read -p "
$ERROR " ret
            case $ret in
                *) SET_GRUB
                ;;
            esac
        ;;
    esac
}
# 3. Setelah Reboot
AFTER_INST () {
clear
read -p "
### SETELAH REBOOT ###

LAKUKAN LANGKAH INI SETELAH
REBOOT SYSTEM

1. Mengaktifkan Services
2. Membuat User Baru

q. Keluar

$CHOICE : " pilihan
    case $pilihan in
        1) SET_SERVICES
        ;;
        2) SET_USER
        ;;

        [Qq]*) clear
        MAIN_MENU
        ;;
        *) clear
        read -p "
$ERROR " ret
            case $ret in
                *) AFTER_INST
                ;;
            esac
        ;;
    esac
}
#     3.1. Mengaktifkan Services
SET_SERVICES () {
clear
read -p "
Apakah anda ingin mengaktifkan semua services ?

[Y/n] : " yn
    case $yn in
        [Yy]*) clear
        ln -sf /etc/runit/sv/ntpd /run/runit/service
        ln -sf /etc/runit/sv/NetworkManager /run/runit/service
        ln -sf /etc/runit/sv/cupsd /run/runit/service
        ln -sf /etc/runit/sv/sshd /run/runit/service
        nmtui
        read -p "
Semua services sudah berhasil diaktifkan
tekan enter untuk kembali " ret
            case $ret in
                *) AFTER_INST
                ;;
            esac
        ;;
        [Nn]*) clear
        AFTER_INST
        ;;
        *) clear
        read -p "
$ERROR " ret
            case $ret in
                *) SET_SERVICES
                ;;
            esac
        ;;
    esac
}
#     3.2. Membuat User Baru
SET_USER () {
clear
read -p "
Apakah anda ingin membuat user baru ?

[Y/n] : " yn
    case $yn in
        [Yy]*) clear
        read -p "
Masukkan nama user baru : " name
        useradd -m $name -G wheel
        read -p "
Apakah anda ingin menjadikan $name menjadi sudoer?

[Y/n] : " yn
            case $yn in
                [Yy]*) vim /etc/sudoers
                read -p "
Membuat user baru berhasil
Tekan enter untuk kembali " ret
                    case $ret in
                        *) AFTER_INST
                        ;;
                    esac
                ;;
                [Nn]*) clear
                read -p "
Membuat user baru berhasil
Tekan enter untuk kembali " ret
                    case $ret in
                        *) AFTER_INST
                        ;;
                    esac
                ;;
                *) clear
                read -p "
$ERROR " ret
                    case $ret in
                        *) SET_USER
                        ;;
                    esac
                ;;
            esac
        ;;
        [Nn]*) clear
        AFTER_INST
        ;;
        *) clear
        read -p "
$ERROR " ret
            case $ret in
                *) SET_USER
                ;;
            esac
        ;;
    esac
}
MAIN_MENU
