# Deploying the DNS Cluster Add-on

In this lab you will deploy the [DNS add-on](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/) which provides DNS based service discovery, backed by [CoreDNS](https://coredns.io/), to applications running inside the Kubernetes cluster.

We will be following the steps outlined in the official [CoreDNS GitHub Repository](https://github.com/coredns/deployment/tree/master/kubernetes)

## The DNS Cluster Add-on

Get the coredns.yaml template and deploy.sh

On `controller-1`

```
curl -O https://raw.githubusercontent.com/coredns/deployment/master/kubernetes/deploy.sh
curl -O https://raw.githubusercontent.com/coredns/deployment/master/kubernetes/coredns.yaml.sed
```

`deploy.sh` is a convenience script to generate a manifest for running CoreDNS on a cluster that is currently running standard kube-dns. Using the `coredns.yaml.sed` file as a template, it creates a ConfigMap and a CoreDNS deployment, then updates the Kube-DNS service selector to use the CoreDNS deployment. By re-using the existing service, there is no disruption in servicing requests.

Run `deploy.sh` to generate the coredns.yaml. We are passing `-i 10.96.0.10` to specify the cluster DNS IP address.

```
bash ./deploy.sh -s -i 10.96.0.10 -t coredns.yaml.sed > coredns.yaml
```

Set `replicas: 2`
```
sed -i 's/# replicas: not specified here:/replicas: 2/' coredns.yaml
```

Deploy the `coredns` cluster add-on:

```
kubectl apply -f coredns.yaml
```

> output
```
serviceaccount/coredns created
clusterrole.rbac.authorization.k8s.io/system:coredns created
clusterrolebinding.rbac.authorization.k8s.io/system:coredns created
configmap/coredns created
deployment.apps/coredns created
service/kube-dns created
```

List the pods created by the `kube-dns` deployment:

```
kubectl get pods -l k8s-app=kube-dns -n kube-system -o wide
```

> output

```
NAME                       READY   STATUS    RESTARTS   AGE     IP             NODE       NOMINATED NODE   READINESS GATES
coredns-76c67cf7f4-77wvz   1/1     Running   0          3m53s   10.142.0.69    worker-1   <none>           <none>
coredns-76c67cf7f4-dpksl   1/1     Running   0          3m53s   10.142.0.198   worker-2   <none>           <none>
```

Reference: https://kubernetes.io/docs/tasks/administer-cluster/coredns/#installing-coredns

## Verification

Create a `busybox` deployment:

```
kubectl run busybox --image=busybox:1.28 --command -- sleep 3600
```

List the pod created by the `busybox` deployment:

```
kubectl get pods -l run=busybox
```

> output

```
NAME                      READY   STATUS    RESTARTS   AGE
busybox-bd8fb7cbd-vflm9   1/1     Running   0          10s
```

Execute a DNS lookup for the `kubernetes` service inside the `busybox` pod:

```
kubectl exec -ti busybox -- nslookup kubernetes
```

> output

```
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kubernetes
Address 1: 10.96.0.1 kubernetes.default.svc.cluster.local
```

## Clean Up

```
kubectl delete pod busybox --force
```
Next: [Smoke Test](15-smoke-test.md)
