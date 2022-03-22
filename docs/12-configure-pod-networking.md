# Provisioning Pod Network

We chose to use CNI - [calico](https://projectcalico.docs.tigera.io/about/about-calico) as our networking option.

We will be following the official documentation for installing calico [on-premises deployments](https://projectcalico.docs.tigera.io/getting-started/kubernetes/self-managed-onprem/onpremises)


## Deploy Calico Network

on `controller-1`

Download the Calico networking manifest for the Kubernetes API datastore.
```
curl https://projectcalico.docs.tigera.io/archive/v3.22/manifests/calico.yaml -O
```

If you are using pod CIDR `192.168.0.0/16`, skip to the next step. If you are using a different pod CIDR with kubeadm, no changes are required - Calico will automatically detect the CIDR based on the running configuration. For other platforms, make sure you uncomment the `CALICO_IPV4POOL_CIDR` variable in the manifest and set it to the same value as your chosen pod CIDR.

For our purposes we will change the pod CIDR to `10.142.0.0/24`

```
vim calico.yaml
```

Change the configuration to look like the following

```
            - name: CALICO_IPV4POOL_CIDR
              value: "10.142.0.0/24"
```

Apply the manifest using the following command.

```
kubectl apply -f calico.yaml
```

## Verification

List the registered Kubernetes nodes from the `controller-1` node:

```
kubectl get pods -n kube-system -o wide
```

> output

```
NAME                                       READY   STATUS    RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES
calico-kube-controllers-56fcbf9d6b-v6hx5   1/1     Running   0          17m   10.142.0.65   worker-1   <none>           <none>
calico-node-647l2                          1/1     Running   0          17m   172.22.5.21   worker-1   <none>           <none>
calico-node-mn7fb                          1/1     Running   0          17m   172.22.5.22   worker-2   <none>           <none>
```

Next: [Kube API Server to Kubelet Connectivity](13-kube-apiserver-to-kubelet.md)
