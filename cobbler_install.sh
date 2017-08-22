#!/usr/bin/bash

yum -y install epel-release
yum -y update
yum -y install createrepo httpd mkisofs mod_wsgi mod_ssl python-cheetah python-netaddr python-simplejson python-urlgrabber PyYAML rsync syslinux tftp-server yum-utils pykickstart cobbler fence-agents wget vim tftp tcpdump net-tools xinetd nmap

# Disable Selinux in /etc/sysconfig/selinux
# Enable TFTP in /etc/xinetd.d/tftp
# Set current server ip in /etc/cobbler/settings
# Set pxe_just_once: 1

cp /usr/share/syslinux/pxelinux.0 /var/lib/cobbler/loaders/
cp /usr/share/syslinux/chain.c32 /var/lib/tftpboot
cp /usr/share/syslinux/vesamenu.c32 /var/lib/tftpboot

echo "ui vesamenu.c32
PROMPT 0
MENU TITLE Cobbler | http://cobbler.github.io/
TIMEOUT 10
TOTALTIMEOUT 6000
ONTIMEOUT \$pxe_timeout_profile

LABEL local
        MENU LABEL (local)
        MENU DEFAULT
        KERNEL chain.c32
        APPEND hd0 0

\$pxe_menu_items

MENU end" > /etc/cobbler/pxe/pxedefault.template


systemctl start httpd
systemctl enable httpd

systemctl start rsyncd.service
systemctl enable rsyncd.service

systemctl start tftp
systemctl enable tftp

systemctl start xinetd
systemctl enable xinetd

systemctl disable firewalld
systemctl stop firewalld

cobbler get-loaders

systemctl start cobbler
systemctl enable cobbler

systemctl start cobblerd
systemctl enable cobblerd


cobbler sync