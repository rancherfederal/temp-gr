#!/bin/sh

# Generate better fstab that uses UUID instead of device mapper
curl -fsSL https://github.com/glacion/genfstab/releases/download/2.0/genfstab -o /usr/local/sbin/genfstab
chmod 0777 /usr/local/sbin/genfstab
# Don't include the sysfs and selinuxfs mounts that are handled by systemd on boot
/usr/local/sbin/genfstab -U / | grep -v -E 'none|selinuxfs' > /etc/fstab
