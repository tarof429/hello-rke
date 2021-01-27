# Readme for Hello-RKE

## Introduction

This example is based on a video at https://www.youtube.com/watch?v=2SmYjj-GFnE

## Requirements

- VirtualBox
- vagrant 2.2.14
- RKE 1.2.4

## Setup

1. Use vagrant to start the VMs. This setup consists of one master node and one worker node.

But before you do this, here are some notes about networking. You must set the virtual box machines with a routable IP address. Otherwise you will have all kinds of problems. A quick way to do this is to configure the VMs to use DHCP. If you do this, then the VMs will have a routable IP. A better wsay is to bring up VirtualBox, go to File -> Host Network Manager, and look for a network with a check box next to DHCP. These networks are valid to use for your VM. 

After configuring Vagrantfile, bring up the VMs.

  ```
  vagrant up
  ```

  If you SSH to a VM using `vagrant ssh` you should see that eth0 is the NAT interface while eth1 is the host-only adapter. We will use the IP address of host-only adapter for our configuration of the nodes. You can test the connection to them by SSH'ing diretly to the VM using the IP address. For example:

  ```
  ssh -i .vagrant/machines/default/virtualbox/private_key vagrant@172.28.128.10 hostname
  kubemaster
  ```


2. Download RKE from https://github.com/rancher/rke/releases. 

  ```
  rke config
  ```

  Before running rke up, edit the generated cluster.yml and set ingress provider to "none" to remove the default ingress controller. (Step needed?)

3. Run rke up

  ```
  rke up
  ```

4. Copy kube_config_cluster.config to ~/.kube/config so kubectl will work properly.

```
cp kube_config_cluster.yml ~/.kube/config
kubectl get nodes
NAME           STATUS   ROLES                      AGE   VERSION
192.168.36.3   Ready    controlplane,etcd,worker   21h   v1.19.6
```

## Setup MetalLB

Setup metallb by following the instructions at https://metallb.universe.tf/. There is one configmap in t he metallb directory that can be used to create the configmap.

Let's deploy nginx.

```
kubectl create deploy nginx --image=nginx
```

Next, create a service of type LoadBalancer.

```
kubectl expose deploy nginx --port=80 --type LoadBalancer
service/nginx exposed
```

If we check the service, we'll see nginx exposed with an external IP.

```
$ kubectl get svc
NAME         TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)        AGE
kubernetes   ClusterIP      10.43.0.1     <none>           443/TCP        31m
nginx        LoadBalancer   10.43.197.0   172.28.128.240   80:31472/TCP   30s
```

We can use w3m which is a console based browser to view the nginx site.

```
w3m http://172.28.128.240
```

Let's deploy another nginx2.

```
kubectl create deploy nginx2 --image=nginx
```

And expose it as a service.

```
kubectl expose deploy nginx2 --port=80 --type LoadBalancer
```

We can see the service.

```
$ kubectl get svc
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
kubernetes   ClusterIP      10.43.0.1       <none>           443/TCP        38m
nginx        LoadBalancer   10.43.197.0     172.28.128.240   80:31472/TCP   7m14s
nginx2       LoadBalancer   10.43.156.189   172.28.128.241   80:31890/TCP   42s
```

Again we casn use w3m to verify nginx.

```
w3m http://172.28.128.241
```

