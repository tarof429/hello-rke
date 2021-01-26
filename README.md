# Readme for Hello-RKE

## Introduction

This example is based on a video by Adrian Goins at https://www.youtube.com/watch?v=iqVt5mbvlJ0&t=272s to setup metallb with Nginx and rancher. Some steps were added/modified for rke.

## Requirements

- vagrant 2.2.14
- RKE 1.2.4

## Setup

1. Use vagrant to start the VM.

  ```
  vagrant up
  ```

2. Download RKE from https://github.com/rancher/rke/releases. 

  ```
  rke up
  ```

3. Let's install rancher so we have a UI. To run rancher, we need to run a docker container inside the master node. This step only needs to be done once. Afterwards, you can just access rancher from the browser.

```
vagrant ssh -c "docker run -d --restart=unless-stopped -p 8080:8080 rancher/server"
```

4. Access rancher from the browser at http://192.168.36.3:8080. 

6. Follow directions to register the master node with rancher 

7. Copy kube_config_cluster.config to ~/.kube/config so kubectl will work properly.

```
cp kube_config_cluster.yml ~/.kube/config
kubectl get nodes
NAME           STATUS   ROLES                      AGE   VERSION
192.168.36.3   Ready    controlplane,etcd,worker   21h   v1.19.6
```

## Setup MetalLB

1. First we must disable the default nginx controller. To do this, we have changed cluster.yml and set ingress provider to none. When you run rke up again, you should see the line:

```
INFO[0017] [ingress] removing installed ingress controller
```

This can take a minute or two, but should eventually complete.

Next, we will install metallb. To do this, we will use kustomize. Install kustomize if it's not already present.

First lets generate the secret.

```
cd metallb
sh ./generate-secret.sh

```

Next, we use kustomize to build the objects and apply it using kubectl.

```
kustomize build . | kubectl apply -f -
```

Afterwards metallb is running.

```
kubectl get pods -n metallb-system
NAME                          READY   STATUS    RESTARTS   AGE
controller-65db86ddc6-cw56q   1/1     Running   2          20h
speaker-f6pb4                 1/1     Running   2          20h
```

## Install nginx

```
cd nginx
kustomize build . | kubectl apply -f -
```

When we see the ingress-nginx service, we see that the service type is LoadBalancer.

```
kubectl get svc --namespace ingress-nginx
NAME            TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)                      AGE
ingress-nginx   LoadBalancer   10.43.219.54   192.168.36.30   80:32538/TCP,443:30537/TCP   3m18s
```

## Run demo

```
cd demo
kustomize build . | kubectl apply -f -
curl http://192.168.36.30
```


## References

- https://www.youtube.com/watch?v=iqVt5mbvlJ0&t=272s

- https://gitlab.com/monachus/channel.git

- https://cncn.io/
