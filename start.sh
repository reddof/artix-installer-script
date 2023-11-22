#!/bin/bash

DIR=$(pwd)
MY_CHROOT=/mnt

clear

#     3.2 Membuat user baru
set-user () {
clear
read -p "
Apakah anda ingin membuat user baru ?

[Y/n] : " yn
    case $yn in
        [Yy]*) read -p "
Masukkan nama user baru : " name
            useradd -m $name -G wheel
            read -p "
Apakah anda ingin menjadikan $name menjadi sudoer?

[Y/n] : " yn
                case $yn in
                    [Yy]*) vim /etc/sudoers
                        read -p "
Membuat user baru berhasil
Tekan enter untuk kembali ke menu sebelumnya" ret
                            case $ret in
                                *) after-inst
                                ;;
                            esac
                    ;;
                    [Nn]*) read -p "
Membuat user baru berhasil
Tekan enter untuk kembali ke menu sebelumnya" ret
                            case $ret in
                                *) after-inst
                                ;;
                            esac
                    ;;
                    *) clear
                        read -p "
Input yang anda masukkan salah tekan enter untuk kembali" ret
                            case $ret in
                                *) set-user
                                ;;
                            esac
                    ;;
                esac
        ;;
        [Nn]*) clear
        after-inst
        ;;
        *) clear
        read -p "
Input yang anda masukkan salah tekan enter untuk kembali" ret
            case $ret in
                *) set-user
                ;;
            esac
        ;;
    esac
}

#     3.1 Mengaktifkan semua service
set-services () {
clear

read -p "
Apakah anda ingin mengaktifkan semua services ?

[Y/n] : " yn
    case $yn in
        [Yy]*) ln -sf /etc/runit/sv/ntpd /run/runit/service
            ln -sf /etc/runit/sv/NetworkManager /run/runit/service
			ln -sf /etc/runit/sv/cupsd /run/runit/service
			ln -sf /etc/runit/sv/sshd /run/runit/service
			nmtui
            read -p "
Semua services sudah berhasil diaktifkan
Tekan enter untuk kembali ke menu sebelumnya" ret
                case $ret in
                    *) after-inst
                    ;;
                esac
        ;;
        [Nn]*) clear
        after-inst
        ;;
        *) clear
        read -p "
Input yang anda masukkan salah tekan enter untuk kembali" ret
            case $ret in
                *) set-services
                ;;
            esac
        ;;
    esac
}

# 3. Setelah Reboot
after-inst () {
clear
read -p "
   ### MENU SETELAH REBOOT ###
PASTIKAN ANDA MELAKUKAN LANGKAH INI
SETELAH REBOOT

1. Mengaktifkan semua services
2. Membuat User baru

q. Kembali  ke menu sebelumnya

Silakan masukkan nomor pilihan anda : " pilihan
    case $pilihan in
        1) set-services
        ;;
        2) set-user
        ;;
        [Qq]*) return
        ;;
        *) clear
            read -p "
Input yang anda masukkan salah tekan enter untuk kembali" ret
                case $ret in
                    *) after-inst
                    ;;
                esac
        ;;
    esac
}

#     2.5 Install dan konfigurasi grub
set-grub () {
clear
read -p "
Apakah anda ingin install dan konfigurasi Grub ?

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
Tekan enter untuk kembali ke menu sebelumnya" ret
                            case $ret in
                                *) post-inst
                                ;;
                            esac
                    ;;
                    [Nn]*) clear
                    post-inst
                    ;;
                    *) read -p "
Input yang anda masukkan salah tekan enter untuk kembali" ret
                        case $ret in
                            *) set-grub
                            ;;
                        esac
                esac
        ;;
        [Nn]*) clear
        post-inst
        ;;
        *) clear
        read -p "
Input yang anda masukkan salah tekan enter untuk kembali" ret
            case $ret in
                *) set-grub
                ;;
            esac
        ;;
    esac
}

#     2.4 Mengatur Hostname
set-hostname () {

clear
read -p "
Apakah anda ingin mengatur hostname ?

[Y/n] : " yn
    case $yn in
        [Yy]*) read -p "
Masukkan hostname untuk komputer anda : " hostname
            read -p "
Apakah anda ingin $hostname menjadi hostname komputer anda :

[Y/n] : " yn
                case $yn in
                    [Yy]*) echo "$hostname" > /etc/hostname
                        read -p "
Setting Hostname berhasil
tekan enter untuk kembali ke menu sebelumnya" ret
                            case $ret in
                                *) clear
                                post-inst
                                ;;
                            esac
                    ;;
                    [Nn]*) clear
                    post-inst
                    ;;
                    *) clear
                    read -p "
Input yang anda masukkan salah tekan enter untuk kembali" ret
                        case $ret in
                            *) set-hostname
                        esac
                    ;;
                esac
        ;;
        [Nn]*) clear
        post-inst
        ;;
        *) clear
        read -p "
Input yang anda masukkan salah tekan enter untuk kembali ke menu sebelumnya" ret
            case $ret in
             *) set-hostname
             ;;
            esac
        ;;
    esac
}

#     2.3 Mengatur timezone
set-timezone () {

clear
read -p "
Apakah anda ingin mengatur timezone?

[Y/n] : " yn
    case $yn in
        [Yy]*) read -p "
Masukkan region anda diawali huruf kapital, misalnya Asia :

" region
            read -p "
Masukkan kota anda diawali huruf kapital, misalnya Jakarta :

" kota
            read -p "
Apakah anda ingin mengatur zona waktu ke $region/$kota ? [Y/n] :

" yn

                case $yn in
                    [Y/y]*) ln -sf /usr/share/zoneinfo/$region/$kota /etc/localtime
                    hwclock -w -l
                    read -p "

Settting timezone berhasil
Tekan enter untuk kembali ke menu sebelumnya" ret
                        case $ret in
                            *) post-inst
                            ;;
                        esac
                        ;;
                    [N/n]*) post-inst
                    ;;
                    *) clear
                    read -p "
Input yang anda masukkan salah tekan enter untuk kembali" ret
                        case $ret in
                            *) set-timezone
                            ;;
                        esac
                    ;;
                esac
        ;;
        [Nn]*) clear
        post-inst
        ;;
        *) clear
        read -p "
Input yang anda masukkan salah tekan enter untuk kembali" ret
            case $ret in
                *) set-timezone
                ;;
            esac
        ;;
    esac
}

#     2.2 Mengatur bahasa
set-lang () {

clear

read -p "
Apakah anda ingin mengatur bahasa ?

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
Tekan enter untuk kembali ke menu sebelumnya" ret
                    case $ret in
                        *) post-inst
                        ;;
                    esac
                ;;
                [Nn]*) clear
                post-inst
                ;;
                *) clear
                read -p "
Input yang anda masukkan salah tekan enter untuk kembali" ret
                    case $ret in
                        *) set-lang
                        ;;
                    esac
                ;;
            esac
        ;;
        [Nn]*) post-inst
        ;;
        *) clear
        read -p "
Input yang anda masukkan salah tekan enter untuk kembali" ret
            case $ret in
                *) clear
                set-lang
                ;;
            esac
        ;;
    esac
}

#     2.1 Membuat password root
set-password () {

clear

read -p "
Apakah anda akan membuat password root sekarang?

[Y/n] : " yn
    case $yn in
        [Yy]*) passwd
        read -p "
Password root berhasil dibuat
tekan enter untuk kembali ke menu sebelumnya" ret
            case $ret in
                *) clear
                post-inst
                ;;
            esac
        ;;
        [Nn]*) clear
        post-inst
        ;;
        *) clear
        read -p "
Input yang anda masukkan salah tekan enter untuk kembali " ret
            case $ret in
                *) clear
                set-password
                ;;
            esac
        ;;
    esac
}

# 2. Post Install
post-inst () {

clear

read -p "
      ### POST INSTALL ###

PASTIKAN ANDA MELAKUKAN LANGKAH INI
DALAM MODE CHROOT

1. Membuat password root
2. Mengatur Bahasa
3. Mengatur timezone
4. Mengatur hostname
5. Install dan konfigurasi Grub

q. Kembali ke menu sebelumnya

Masukkan nomor pilihan anda : " pilihan

    case $pilihan in
        1) set-password
        ;;
        2) set-lang
        ;;
        3) set-timezone
        ;;
        4) set-hostname
        ;;
        5) set-grub
        ;;
        [Qq]*) return
        ;;
        *) clear
        read -p "
Input yang anda masukkan salah tekan enter untuk kembali " ret
            case $ret in
                *) post-inst
                ;;
            esac
        ;;
    esac
}

#     1.2 Membuat file fstab.
mk-fstab () {

clear

read -p "
Apakah anda ingin membuat file fstab?

[Y/n] : " yn

    case $yn in
        [Yy]*) fstabgen -U $MY_CHROOT > $MY_CHROOT/etc/fstab
        cat $MY_CHROOT/etc/fstab
        read -p "
File fstab berhasil dibuat
tekan enter untuk kembali ke menu sebelumnya" ret
            case $ret in
                *) base-inst
                ;;
            esac
        ;;
        [Nn]*) base-inst
        ;;
        *) clear
        read -p "
Input yang anda masukkan salah tekan enter untuk kembali " ret
            case $ret in
                *) mk-fstab
                ;;
            esac
        ;;
    esac
}

#     1.1 Install base kernel dan software pendukung.
kernel-inst () {

clear

read -p "
Masukkan kernel yang ingin anda install
misalnya linux, lunux-lts, linux-zen dll

masukkan anda : " kern

read -p "
Aapakah anda ingin install $kern ?

[Y/n] : " yn

    case $yn in
        [Yy]*) basestrap /mnt base base-devel elogind-runit runit $kern linux-firmware intel-ucode cups cups-runit cups-pdf networkmanager networkmanager-runit vim ntfs-3g man-db ntp ntp-runit openssh openssh-runit --overwrite "*"
        read -p "
$kern sudah berhasil diinstall
tekan enter untuk kembali ke menu sebelumnya " ret
            case $ret in
                *) base-inst
                ;;
            esac
        ;;
        [Nn]*) base-inst
        ;;
        *) clear
        read -p "
Inpit yang anda masukkan salah tekan enter untuk kembali " ret
            case $ret in
                *) kernel-inst
                ;;
            esac
        ;;
    esac
}

# 1. Install base
base-inst () {

clear

read -p "
### INSTALL BASE MENU ###

1. Install base dan packages pendukung
2. Membuat file fstab

q. Kembali ke menu sebelumnya

Silakan masukkan nomor pilihan anda : " pilihan

    case $pilihan in
        1) kernel-inst
        ;;
        2) mk-fstab
        ;;
        [Qq]*) return
        ;;
        *) clear
        read -p "
Input yang anda masukkan salah tekan enter untuk kembali " ret
            case $ret in
                *) base-inst
                ;;
            esac
        ;;
    esac
}

# Pesan Error

error () {

clear

read -p "
Input yang anda masukkan salah tekan enter untuk kembali" ret

case $ret in
    *) return
    ;;
esac
}

# Main Menu :
read -p "
### MAIN MENU ###

1. Install Base.
2. Post Install (lakukan setelah chroot).
3. Setelah Reboot (lakukan setelah reboot).

q. Keluar

Silakan masukkan nomor pilihan anda : " pilihan

    case $pilihan in
        1) base-inst
        ;;
        2) post-inst
        ;;
        3) after-inst
        ;;
        [Qq]*) clear
        exit
        ;;
        *) error
        ;;
    esac

$DIR/./start.sh
