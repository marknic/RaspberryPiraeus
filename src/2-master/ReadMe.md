1. ### Execute master install script 1 (Install Docker)
    * sudo reboot # (after reboot, you can test Docker install with "docker run hello-world"
 
2. ### Execute master install script 2 (disable swap, install kubernetes, initializing kubernetes)
    * Note: make sure you modify the script to use your master node IP address
  
3. ### Execute master install script 3 (install networking, join the cluster)
    * Note: make sure you modify the script to use your master node IP address and change the networking if you want something other than Flannel

4. ### The node should now be added to the cluster as the master
> To verify, run 'kubectl get nodes' on the master.  Depending on how many nodes you've added, you should see something similar to this:
#### pi@kub-master:~ $ kubectl get nodes
| NAME       | STATUS | ROLES  | AGE | VERSION |
| ---------- | ------ | ------ | --- | ------- |
| kub-master | Ready  | master | 26h | v1.15.3 |

5. ### When all of the worker nodes are created, run 5_label_workers.sh to set their roles within the cluster.
