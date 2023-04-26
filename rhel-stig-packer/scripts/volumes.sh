#!/bin/sh

dnf install -y lvm2

# Create and format all disks
# /var/log/ /var/log/audit
/sbin/pvcreate /dev/$(lsblk | grep 15G | awk '{print $1}')
/sbin/vgcreate logs /dev/$(lsblk | grep 15G | awk '{print $1}')
/sbin/lvcreate -l 60%FREE -n varlog logs
/sbin/mkfs.xfs /dev/logs/varlog
/sbin/lvcreate -l 100%FREE -n varlogaudit logs
/sbin/mkfs.xfs /dev/logs/varlogaudit
# /var/lib
/sbin/pvcreate /dev/$(lsblk | grep 300G | awk '{print $1}')
/sbin/vgcreate containers /dev/$(lsblk | grep 300G | awk '{print $1}')
/sbin/lvcreate -l 80%FREE -n rancher containers
/sbin/mkfs.xfs /dev/containers/rancher
/sbin/lvcreate -l 100%FREE -n kubelet containers
/sbin/mkfs.xfs /dev/containers/kubelet
# /var /var/tmp /tmp
/sbin/pvcreate /dev/$(lsblk | grep 21G | awk '{print $1}')
/sbin/vgcreate tmpvartmp /dev/$(lsblk | grep 21G | awk '{print $1}')
/sbin/lvcreate -l 40%FREE -n var tmpvartmp
/sbin/mkfs.xfs /dev/tmpvartmp/var
/sbin/lvcreate -l 50%FREE -n tmp tmpvartmp
/sbin/mkfs.xfs /dev/tmpvartmp/tmp
/sbin/lvcreate -l 100%FREE -n vartmp tmpvartmp
/sbin/mkfs.xfs /dev/tmpvartmp/vartmp
# /home
/sbin/pvcreate /dev/$(lsblk | grep 10G | awk '{print $1}')
/sbin/vgcreate userhome /dev/$(lsblk | grep 10G | awk '{print $1}')
/sbin/lvcreate -l 100%FREE -n home userhome
/sbin/mkfs.xfs /dev/userhome/home

# Copy existing files and mount
# Stop logging services while copying logs
systemctl stop crond
systemctl stop rsyslog
# Cannot use systemctl because of dependency
service auditd stop

mkdir -p /run/varlogaudit
mount /dev/logs/varlogaudit /run/varlogaudit
cp -dRx --preserve=all /var/log/audit/* /run/varlogaudit
umount /run/varlogaudit
mount /dev/logs/varlogaudit /var/log/audit
restorecon -vvFR /var/log/audit

mkdir -p /run/varlog
mount /dev/logs/varlog /run/varlog
cp -dRx --preserve=all /var/log/* /run/varlog
umount /run/varlog
mount /dev/logs/varlog /var/log
restorecon -vvFR /var/log

# Restart logging
service auditd start
systemctl start rsyslog
systemctl start crond

mkdir -p /run/vartmp
mount /dev/tmpvartmp/vartmp /run/vartmp
cp -dRx --preserve=all /var/tmp/* /run/vartmp
umount /run/vartmp
mount /dev/tmpvartmp/vartmp /var/tmp
restorecon -vvFR /var/tmp

rm -rf /var/lib/rancher
rm -rf /var/lib/kubelet
mkdir -p /var/lib/rancher
mkdir -p /var/lib/kubelet
mount /dev/containers/rancher /var/lib/rancher
mount /dev/containers/kubelet /var/lib/kubelet

mkdir -p /run/tmpvar
mount /dev/tmpvartmp/var /run/tmpvar
cp -dRx --preserve=all /var/* /run/tmpvar
umount /run/tmpvar
mount /dev/tmpvartmp/var /var
restorecon -vvFR /var

mv /home /run/userhome
mkdir -p /home
mount /dev/userhome/home /home
mv /run/userhome/* /home

# /var/log/audit must be mounted before /var/log
/bin/echo '/dev/logs/varlogaudit  /var/log/audit  xfs  noatime,nodev,nosuid,noexec 0 0' | tee -a /etc/fstab
/bin/echo '/dev/logs/varlog  /var/log  xfs  noatime,nodev,nosuid,noexec 0 0' | tee -a /etc/fstab
/bin/echo '/dev/tmpvartmp/vartmp  /var/tmp  xfs  defaults,nodev,nosuid,noexec 0 0' | tee -a /etc/fstab
/bin/echo '/dev/containers/rancher  /var/lib/rancher  xfs  defaults 0 0' | tee -a /etc/fstab
/bin/echo '/dev/containers/kubelet  /var/lib/kubelet  xfs  defaults 0 0' | tee -a /etc/fstab
/bin/echo '/dev/tmpvartmp/var  /var  xfs  defaults 0 0' | tee -a /etc/fstab
/bin/echo '/dev/tmpvartmp/tmp  /tmp  xfs  defaults,nodev,nosuid,noexec 0 0' | tee -a /etc/fstab
/bin/echo '/dev/userhome/home  /home  xfs   defaults,noatime,nosuid 0 0' | tee -a /etc/fstab
