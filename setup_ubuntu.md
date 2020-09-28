# Raspberry Pi 4 on Ubuntu

Piraeus on Docker in Kubernetes on Ubuntu Linux on RPi Cluster

Ubuntu has been used because it runs very well in 64 bit on the ARM-based Raspberry Pi 4.  Version 20.04.1 was used on the RPi machines during development of the Ansible script process.

## Setup Raspberry Pi on Ubuntu (Do this first)

Setting up Ubuntu on the Raspberry Pi 4 is very straight-forward and most SD card imager software can be used:

- [Win32 Disk Imager](https://sourceforge.net/projects/win32diskimager/)
- [balenaEtcher](https://www.balena.io/etcher/)
- [Raspberry Pi Imager](https://www.raspberrypi.org/downloads/)

The Raspberry Pi Imager was used in this development.  It managed the SD cards very well and made copying the images to SD cards very easy.

**Setup Process:**

1. Boot up Ubuntu on the Raspberry Pi. Allow sufficient time for the operating system to complete. During the initial boot up process, the OS will automatically generate SSH keys at the end and takes a little time to complete.
2. Login to Ubuntu - this can be done with an attached keyboard but also can be done remotely via SSH.  ID/PW: "ubuntu"/"ubuntu" is the initial login.
3. After a successful login, the OS will require a password change. To make the Ansible script process easier to manage, a common password is used across all cluster machines. "raspberry" is that common password.  So, enter "ubuntu" as the current password and then enter "raspberry" twice to change the password.

This is all the setup necessary for the Raspberry Pi's running Ubuntu.
