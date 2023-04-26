#!/bin/sh

# Skip if not performing STIG
if [ -z $STIG_ENABLE ]; then
  exit 0
fi

# DISA Stig Ansible RHEL 8
mkdir -p /tmp/stig
cd /tmp/stig
curl -LO $(curl https://public.cyber.mil/stigs/supplemental-automation-content/ | grep -A5 "Red Hat Enterprise Linux 8 STIG for Ansible" | grep zip | awk -F=\" '{ print $2 }' | awk -F \" '{ print $1 }' | head -n1)
dnf update -y
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf install -y unzip ansible
unzip U_RHEL_8_*_STIG_Ansible.zip
unzip rhel8STIG-ansible.zip
chmod +x enforce.sh
echo "  vars:" >> site.yml
echo "    rhel8STIG_stigrule_244544_Manage: False" >> site.yml
sh /tmp/stig/enforce.sh

echo "Applying STIG Controls Missed by the Ansible Script"
  echo "Remediating V-230235"
  if [[ ! -e /boot/grub2/user.cfg ]]; then
    echo "GRUB2_PASSWORD=grub.pbkdf2.sha512.10000.1106FD04D12145CCE2B9EED21CA540AE6FF37DC44C40BD980C6E655E8501533F53A4A33A66A268E173E2C68BF699CAC3EAEBEF6AA86AD3A722706FBD71AEF5E3.8D324CEA28BB7BF4BA05713066399418BEC9AA35C1A2DB7A955A7729699D95F26B4D8C2EDF75D84DB178E52604876C69B9C00632EAB24854258A029F7219BFCD" > /boot/grub2/user.cfg
    chmod 600 /boot/grub2/user.cfg
    grub2-mkconfig -o /boot/grub2/grub.cfg
  fi
  echo "Remediating V-230531"
  if ! grep CtrlAltDelBurstAction=none /etc/systemd/system.conf; then
    echo "CtrlAltDelBurstAction=none" >> /etc/systemd/system.conf
  fi
  echo "Remediating V-230311"
  if ! grep "kernel.core_pattern=|/bin/false" /etc/sysctl.d/50-coredump.conf; then
    echo "kernel.core_pattern=|/bin/false" >> /etc/sysctl.d/50-coredump.conf
    sysctl --system > /dev/null
  fi
  echo "Remediating V-230341"
  if ! grep ^silent /etc/security/faillock.conf; then
    echo silent >> /etc/security/faillock.conf
  fi
  echo "Remediating V-230343"
  if ! grep ^audit /etc/security/faillock.conf; then
    echo audit >> /etc/security/faillock.conf
  fi
  echo "Remediating V-230348"
  if ! grep ^bind /etc/tmux.conf; then
    echo "bind X lock-session" >> /etc/tmux.conf
  fi
  echo "Remediating V-230439"
  if ! grep "\-S rename,unlink,rmdir,renameat,unlinkat -F" /etc/audit/audit.rules; then
    sed -i "s/-S.*rename.*-F/-S rename,unlink,rmdir,renameat,unlinkat -F auid>=1000 -F/" /etc/audit/audit.rules
  fi
  echo "Remediating V-230503"
  if ! grep "install usb-storage /bin/true" /etc/modprobe.d/*; then
    echo "install usb-storage /bin/true" >> /etc/modprobe.d/usb-storage.conf
  fi
  if ! grep "blacklist usb-storage" /etc/modprobe.d/*; then
    echo "blacklist usb-storage" >> /etc/modprobe.d/usb-storage.conf
  fi
  echo "Remediating V-230507"
  if ! grep "install bluetooth /bin/true" /etc/modprobe.d/*; then
    echo "install bluetooth /bin/true" >> /etc/modprobe.d/bluetooth.conf
  fi
  if ! grep "blacklist bluetooth" /etc/modprobe.d/*; then
    echo "blacklist bluetooth" >> /etc/modprobe.d/bluetooth.conf
  fi
  echo "Remediating V-230510"
  if ! grep shm /etc/fstab; then
    echo "tmpfs /dev/shm tmpfs defaults,nodev,nosuid,noexec 0 0" >> /etc/fstab
  fi
  echo "Remediating V-230546"
  if grep "^kernel.yama.ptrace_scope = 0" /lib/sysctl.d/10-default-yama-scope.conf; then
    sed -i "s/^kernel.yama.ptrace_scope = 0/kernel.yama.ptrace_scope = 1/" /lib/sysctl.d/10-default-yama-scope.conf
  fi
  if grep "^kernel.yama.ptrace_scope = 0" /usr/lib/sysctl.d/10-default-yama-scope.conf; then
    sed -i "s/^kernel.yama.ptrace_scope = 0/kernel.yama.ptrace_scope = 1/" /usr/lib/sysctl.d/10-default-yama-scope.conf
  fi
  echo "Remediating V-230050"
  if grep tmux /etc/shells; then
    grep -v tmux /etc/shells > shells2; mv shells2 /etc/shells
  fi
  echo "Remediating V-230485"
  if ! grep "port 0" /etc/chrony.conf; then
    echo "port 0" >> /etc/chrony.conf
  fi
  echo "Remediating V-230486"
  if ! grep "cmdport 0" /etc/chrony.conf; then
    echo "cmdport 0 " >> /etc/chrony.conf
  fi
  echo "Remediating V-230494"
  if ! grep "install atm /bin/true" /etc/modprobe.d/*; then
    echo "install atm /bin/true" >> /etc/modprobe.d/atm.conf
  fi
  if ! grep "blacklist atm" /etc/modprobe.d/*; then
    echo "blacklist atm" >> /etc/modprobe.d/atm.conf
  fi
  echo "Remediating V-230495"
  if ! grep "install can /bin/true" /etc/modprobe.d/*; then
    echo "install can /bin/true" >> /etc/modprobe.d/can.conf
  fi
  if ! grep "blacklist can" /etc/modprobe.d/*; then
    echo "blacklist can" >> /etc/modprobe.d/can.conf
  fi
  echo "Remediating V-230496"
  if ! grep "install sctp /bin/true" /etc/modprobe.d/*; then
    echo "install sctp /bin/true" >> /etc/modprobe.d/sctp.conf
  fi
  if ! grep "blacklist sctp" /etc/modprobe.d/*; then
    echo "blacklist sctp" >> /etc/modprobe.d/sctp.conf
  fi
  echo "Remediating V-230497"
  if ! grep "install tipc /bin/true" /etc/modprobe.d/*; then
    echo "install tipc /bin/true" >> /etc/modprobe.d/tipc.conf
  fi
  if ! grep "blacklist tipc" /etc/modprobe.d/*; then
    echo "blacklist tipc" >> /etc/modprobe.d/tipc.conf
  fi
  echo "Remediating V-230498"
  if ! grep "install cramfs /bin/true" /etc/modprobe.d/*; then
    echo "install cramfs /bin/true" >> /etc/modprobe.d/cramfs.conf
  fi
  if ! grep "blacklist cramfs" /etc/modprobe.d/*; then
    echo "blacklist cramfs" >> /etc/modprobe.d/cramfs.conf
  fi
  echo "Remediating V-230499"
  if ! grep "install firewire-core /bin/true" /etc/modprobe.d/*; then
    echo "install firewire-core /bin/true" >> /etc/modprobe.d/firewire-core.conf
  fi
  if ! grep "blacklist firewire-core" /etc/modprobe.d/*; then
    echo "blacklist firewire-core" >> /etc/modprobe.d/firewire-core.conf
  fi

# enable fips mode
if [ ! -z $FIPS_ENABLE ]; then
  /bin/fips-mode-setup --enable
fi

cd /tmp
rm -rf /tmp/stig

dnf remove -y ansible
