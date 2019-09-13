1. ### Enable SSH for remote access with commands below or through raspi-config
sudo systemctl enable ssh  
sudo systemctl start ssh  
  
  
2. ### Do the following with "sudo raspi-config"  
Set hostname (master, worker1, 2, etc.)  
Set locale properties  
Set keyboard (for some keyboards, you will need to reboot after setting up internet access before the right keyboard option appears)  
set time zone  
  
  
3. ### Execute update/upgrade  
    sudo apt update && sudo apt -y upgrade 
  
4. ### Execute worker install script 1 (Install Docker) - reboot after completion of the Docker install
> After rebooting, you can test Docker install with "docker run hello-world"
 
5. ### Execute worker install script 2 (disable swap, install kubeadm, update cmdline.txt)
> Note: make sure you modify the script to use your master node IP address
   
6. ### Execute kubeadm join command to join the node to the cluster
> This is the kubeadm join command structure.  You will need the right token and certificate hash.  
> Those values come from the initial install of the kubernetes master node 

7 See 4_worker_joint.md for instructions on joining the workers to the cluster  
    
8. ### The node should now be added to the cluster as a worker node
> To verify, run 'kubectl get nodes' on the workers.  Depending on how many nodes you've added, you should see something similar to this:
#### pi@kub-master:~ $ kubectl get nodes
| NAME       | STATUS | ROLES  | AGE | VERSION |
| ---------- | ------ | ------ | --- | ------- |
| kub-master    | Ready  | master | 26h | v1.15.3 |
| kub-worker-01 | Ready  | worker | 23h | v1.15.3 |
| kub-worker-02 | Ready  | worker | 21h | v1.15.3 |
| kub-worker-03 | Ready  | worker | 27h | v1.15.3 |

9. ### On the master, execute the kubectl label command to define the new node as a worker
    kubectl label node kub-worker-01 node-role.kubernetes.io/worker=worker 
> Only change: 'kub-worker-01' should be your host name of the node.  There is a script within the "2-master" folder called "5_label_workers.sh" that will automatically label the workers.
