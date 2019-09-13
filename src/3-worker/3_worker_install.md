## Join the workers to the cluster.  
> The join command must be run on each worker node.
> The command is output during the init phase on the master node but if you didn't copy it, the following command will create it again

    kubeadm token create --print-join-command

#### The output should look similar to the line below.
    kubeadm join 192.168.8.100:6443 --token rn7mtr.mtaprb1gzbgwwo9j --discovery-token-ca-cert-hash sha256:1ab50dffe00b9ae416ade8b66d9449e9ab65ffebfb38a671c69c353efa27c5e8
#### Copy it and run it on each worker node to connect it to the cluster
