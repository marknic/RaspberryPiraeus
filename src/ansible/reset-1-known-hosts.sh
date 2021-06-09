
#!/bin/bash


ssh-keygen -f "/home/marknic/.ssh/known_hosts" -R "192.168.1.100"
ssh-keygen -f "/home/marknic/.ssh/known_hosts" -R "192.168.1.101"
ssh-keygen -f "/home/marknic/.ssh/known_hosts" -R "192.168.1.102"
ssh-keygen -f "/home/marknic/.ssh/known_hosts" -R "192.168.1.103"
ssh-keygen -f "/home/marknic/.ssh/known_hosts" -R "192.168.1.104"
ssh-keygen -f "/home/marknic/.ssh/known_hosts" -R "192.168.1.105"
ssh-keygen -f "/home/marknic/.ssh/known_hosts" -R "192.168.1.106"
ssh-keygen -f "/home/marknic/.ssh/known_hosts" -R "192.168.1.107"



sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "192.168.1.100"
sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "192.168.1.101"
sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "192.168.1.102"
sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "192.168.1.103"
sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "192.168.1.104"
sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "192.168.1.105"
sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "192.168.1.106"
sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "192.168.1.107"


ssh ubuntu@192.168.1.100
ssh ubuntu@192.168.1.101
ssh ubuntu@192.168.1.102
ssh ubuntu@192.168.1.103
ssh ubuntu@192.168.1.104
ssh ubuntu@192.168.1.105
ssh ubuntu@192.168.1.106
ssh ubuntu@192.168.1.107

sudo ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@192.168.1.100
sudo ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@192.168.1.101
sudo ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@192.168.1.102
sudo ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@192.168.1.103
sudo ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@192.168.1.104
sudo ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@192.168.1.105
sudo ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@192.168.1.106
sudo ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@192.168.1.107

