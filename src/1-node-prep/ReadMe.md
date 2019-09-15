## 1. Prep the Raspberry Pi's

### Do This First (for all RPi's in the cluster)

1. Load an SD card with Raspian Lite - no GUI is needed with the cluster
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
    * And, when I do start over, I can immediately start using SSH to control the Pi's - major benefit with a headless cluster
    
> When I created my first RPi with the steps above, I used a smaller SD card than I was going to use on the real system.  I did this because Win32DiskImager will create an img file using the full size of the SD card - even all the empty space.  With a smaller card, the img file is smaller and it takes less time to copy img files to SD cards.  This will make it easier/quicker to recover from a mistake especially if (when) I mess things up across the whole cluster and have to restart all machines.  
> I've looked into shrinking the image file but wow, what a pile of steps that requires.

## 2. Network Setup
1. Set up static IP addresses for each of the RPi's that will be part of the cluster
    * This will make management and configuration MUCH easier
    * It's pretty much required for the cluster to work
    * One suggestion is to purchase a "travel router".  This type of router makes it easy to set up static IP addresses that don't need to be within your home/work IP space.  This also makes the cluster portable.  For example, my home wifi uses "10.0.\*.\*" for its IP space.  My travel router uses "192.168.8.\*".  Setting the router up in "repeater mode" lets you use a single IP address on your home/work network and your travel router gives your cluster 200+ spaces.  
    * As an example ONLY: this is the travel router I purchased: https://www.amazon.com/gp/product/B07GBXMBQF/ref=ppx_yo_dt_b_asin_title_o09_s02?ie=UTF8&psc=1.  I am not making any claims as to its abilities and I'm not recommending anything.  It just happens to be the one I bought.  There are others that will be suitable as well.
    * Each router will have its own method for setting static IP addresses so I will leave that part out.

## 3. Set up the "update hosts" script

> This step will create a script that will be used to update each Raspberry Pi with host names used by Kubernetes.  The file is also used as input to a scripted step that will update the host name of each machine.

1. Copy the file "4_update_hosts.sh" file down to one of the RPi's.
    * curl -O https://raw.githubusercontent.com/marknic/RaspberryPiraeus/master/src/1-node-prep/4_update_hosts.sh
    
2. Edit the file
    * nano 4_update_hosts.sh
    
3. The cluster needs to be described in the file.  Outside of the comments at the top, it will look similar to this:  
    echo '192.168.8.100  kub-master' >> /etc/hosts  
    echo '192.168.8.101  kub-worker-01' >> /etc/hosts  
    echo '192.168.8.102  kub-worker-02' >> /etc/hosts  
    echo '192.168.8.103  kub-worker-03' >> /etc/hosts  
    echo '192.168.8.104  kub-worker-04' >> /etc/hosts  
    echo '192.168.8.105  kub-worker-05' >> /etc/hosts  
    
4. Modify the file with your cluster's information
    * One line for each machine
    * Different host names for each machine. Hint: use a naming convention that lets you figure out which machine is which.  In my case, the master is the topmost in my tower.  Machines below it are the workers and they're numbered 0-5 giving me 6 total machines in the cluster.
    * Do not change the structure of this file - just change the IP addresses and the host names
    * Ensure each line keeps the spacing
    * Ensure each line keeps the single quotes surrounding the IP and host name
    * Do not add any additional commands outside of an echo command for each machine in the cluster

