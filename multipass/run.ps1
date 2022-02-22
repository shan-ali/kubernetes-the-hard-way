#start vms
echo "Starting VMs"
multipass launch --cloud-init controller-cloud-config.yml --disk 5G --mem 1G --cpus 1 --name controller-1
multipass launch --cloud-init controller-cloud-config.yml --disk 5G --mem 1G --cpus 1 --name controller-2
multipass launch --cloud-init controller-cloud-config.yml --disk 5G --mem 1G --cpus 1 --name loadbalancer
multipass launch --cloud-init worker-cloud-config.yml --disk 5G --mem 1G --cpus 1 --name worker-1
multipass launch --cloud-init worker-cloud-config.yml --disk 5G --mem 1G --cpus 1 --name worker-2

echo "Copying netplan yaml"
multipass transfer 01-controller-1-network.yaml controller-1:01-controller-1-network.yaml
multipass transfer 01-controller-2-network.yaml controller-2:01-controller-2-network.yaml
multipass transfer 01-loadbalancer-network.yaml loadbalancer:01-loadbalancer-network.yaml
multipass transfer 01-worker-1-network.yaml worker-1:01-worker-1-network.yaml
multipass transfer 01-worker-2-network.yaml worker-2:01-worker-2-network.yaml

echo "Moving netplan yaml to /etc/netplan"
multipass exec controller-1 -- sudo cp 01-controller-1-network.yaml /etc/netplan/ 
multipass exec controller-2 -- sudo cp 01-controller-2-network.yaml /etc/netplan/ 
multipass exec loadbalancer -- sudo cp 01-loadbalancer-network.yaml /etc/netplan/ 
multipass exec worker-1 -- sudo cp 01-worker-1-network.yaml /etc/netplan/ 
multipass exec worker-2 -- sudo cp 01-worker-2-network.yaml /etc/netplan/ 

echo "Applying netplan for controller-1"
multipass exec controller-1 -- sudo timeout 60s netplan apply
echo "Applying netplan for controller-2"
multipass exec controller-2 -- sudo timeout 60s netplan apply
echo "Applying netplan for loadbalancer"
multipass exec loadbalancer -- sudo timeout 60s netplan apply
echo "Applying netplan for worker-1"
multipass exec worker-1 -- sudo timeout 60s netplan apply
echo "Applying netplan for worker-2"
multipass exec worker-2 -- sudo timeout 60s netplan apply

echo "Completed"