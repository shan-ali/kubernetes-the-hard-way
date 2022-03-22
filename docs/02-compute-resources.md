# Provisioning Compute Resources

## Multipass Cloud Init

Multipass takes advantage of [cloud-init](https://ubuntu.com/blog/using-cloud-init-with-multipass) yaml files to customize instances on launch. In the `multipass` directory there are two cloud-init files that are used to create all of the instances.

1. `controller-cloud-config.yaml`
    - used for controller-1, controller-2, and loadbalancer

2. `worker-cloud-config.yaml`
    - used for worker-1 and worker-2
    - installs docker 20.10.12 as outlined in the [offical docker installation documention](https://docs.docker.com/engine/install/ubuntu/)

## Netplan

By default multipass will dynamically allocate an IP Address for each instance. However, for kubernetes setup we need to maintain static IPs across the hosts. In order to set static IPs we will be using [Netplan](https://netplan.io/) yaml configuration files. In the `multipass` directory there are netplan configuration files for each instance which will be copied to `/etc/netplan/` on each respective host. Lastly, we will run `netplan apply` to apply the configuration.  

e.g `01-controller-1-network.yaml` looks like the following:

```
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
      addresses: 
        - 172.22.5.11/20
```
## Starting the VMs

There is a `run.ps1` in the `multipass` directory that will run all of the multipass commands to setup our VM hosts.

This does the below:

- Deploys 5 VMs - 2 Controllers, 2 Workers and 1 Loadbalancer
- All are running the latest Ubuntu LTS (20.04 LTS at the moment)
- Install's Docker on Worker nodes
- Runs the below command on all nodes to allow for network forwarding in IP Tables.
  This is required for kubernetes networking to function correctly.
    > sysctl net.bridge.bridge-nf-call-iptables=1
- Copies the netplan yaml to each host and set's IP addresses in the range 172.55.5.*

```
cd multipass

.\run.ps1
```

## Instances

| VM Name      | Purpose       | IP          |
|--------------|---------------|-------------|
| controller-1 | Control Plane | 172.55.5.11 |
| controller-2 | Control Plane | 172.55.5.12 |
| worker-1     | Worker        | 172.55.5.21 |
| worker-2     | Worker        | 172.55.5.22 |
| loadbalancer | LoadBalancer  | 172.55.5.30 |

List all instances in multipass (note: each instances will have two IP addresses, one that was origianlly dynamically allocated and one static address that we added via netplan). Our IP address may not show in the list command below. 
```
multipass list
```

## Connect to the instances

```
multipass shell controller-1
```

## Verify Environment

- Ensure all VMs are up
- Ensure VMs are assigned the above IP addresses
- Ensure you can connect to each of the instances
- Ensure the VMs can ping each other
- Ensure the worker nodes have Docker installed on them
  > command `sudo docker version`

## Troubleshooting Tips

If any of the VMs failed to provision, or is not configured correct, delete the vms using the commands below and then follow the steps in `run.ps1` pertaining the failed vm.

```
multipass stop <vm>
multipass delete <vm>
```

Alternatively you can delete all instances with the following

```
multipass stop --all
multipass delete --all
multipass purge
```

