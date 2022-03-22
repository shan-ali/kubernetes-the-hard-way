## RBAC for Kubelet Authorization

In this section you will configure RBAC permissions to allow the Kubernetes API Server to access the Kubelet API on each worker node. Access to the Kubelet API is required for retrieving metrics, logs, and executing commands in pods.

### Test current permissions

If we were to try to get logs from our calico pod, we would see the following:

```
kubectl logs calico-node-8mpt6 -n kube-system
```
> output

```
Error from server (Forbidden): Forbidden (user=kube-apiserver, verb=get, resource=nodes, subresource=proxy) ( pods/log calico-node-8mpt6)
```

### Set permissions

> This tutorial sets the Kubelet `--authorization-mode` flag to `Webhook`. Webhook mode uses the [SubjectAccessReview](https://kubernetes.io/docs/admin/authorization/#checking-api-access) API to determine authorization.

Create the `system:kube-apiserver-to-kubelet` [ClusterRole](https://kubernetes.io/docs/admin/authorization/rbac/#role-and-clusterrole) with permissions to access the Kubelet API and perform most common tasks associated with managing pods:

On `controller-1`

```
cat <<EOF | kubectl apply --kubeconfig admin.kubeconfig -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
    verbs:
      - "*"
EOF
```
Reference: https://kubernetes.io/docs/reference/access-authn-authz/rbac/#role-and-clusterrole

The Kubernetes API Server authenticates to the Kubelet as the `system:kube-apiserver` user using the client certificate as defined by the `--kubelet-client-certificate` flag.

Bind the `system:kube-apiserver-to-kubelet` ClusterRole to the `system:kube-apiserver` user:

```
cat <<EOF | kubectl apply --kubeconfig admin.kubeconfig -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: kube-apiserver
EOF
```

### Test New Permissions

Now if we try to get the logs from the calico pod, it will be successful

```
kubectl logs calico-node-8mpt6 -n kube-system
```
> output

```
2022-03-21 19:22:29.041 [INFO][69] felix/summary.go 100: Summarising 12 dataplane reconciliation loops over 1m2.9s: avg=2ms longest=3ms ()
2022-03-21 19:23:24.338 [INFO][72] monitor-addresses/autodetection_methods.go 103: Using autodetected IPv4 address on interface eth0: 172.22.5.21/20
2022-03-21 19:23:30.706 [INFO][69] felix/summary.go 100: Summarising 10 dataplane reconciliation loops over 1m1.7s: avg=1ms longest=3ms (resync-nat-v4)
```

Reference: https://kubernetes.io/docs/reference/access-authn-authz/rbac/#rolebinding-and-clusterrolebinding

Next: [DNS Addon](14-dns-addon.md)
