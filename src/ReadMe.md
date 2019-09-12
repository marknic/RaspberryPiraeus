### Prep the Raspberry Pi

1. Load an SD card with Raspian Lite - no GUI is needed 
    * You can download the smaller image from here:  https://www.raspberrypi.org/downloads/raspbian/
2. Size recommendation for the SD card is > 8GB
3. Turn on SSH
    * Option 1: Do this in raspi-config under the Interfacing Options" section 
        * Enable remote command line access to your Pi using SSH
    * Option 2: Execute the following 2 commands from the RPi:
        * sudo systemctl enable ssh
        * sudo systemctl start ssh
4. Set up the Localisation Options (using "sudo raspi-config")
    * Change Locale (I unchecked "en_GB.UTF-8 UTF-8" and then checked "en_US.UTF-8 UTF-8")
        * Then hit enter on the next page
    * Change Timezone
    * I changed the keyboard to "Generic 101-key PC" but only after I rebooted would it display that option
        * I also changed the Keyboard Layout to "English (US)" and accepted the defaults for "AltGr" and "Compose key"
    * I also changed the WiFi Country
5. I ran the following commands to update the OS to current
    * sudo apt update
    * sudo apt -y upgrade
6. At this point, I used "Win32DiskImager" to make a copy image file of my SD card.  This will let me:
    * Spin up multiple SD cards for my cluster with all of them starting at the same point in time
    * Start over quickly when I make mistakes
    * You will save steps since most of the time consuming ones are already done 
    * And, when I do start over, I can immediately start using SSH to control the Pi's - this is a big pain with a headless cluster
    
