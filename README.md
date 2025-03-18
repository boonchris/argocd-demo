# Simple ArgoCD demo

This repo is used to demonstrate how to deploy a simple application using [ArgoCD](https://argo-cd.readthedocs.io/en/stable/). 

## Kubernetes cluster
This guide assumes you have a access to a (fresh) Kubernetes cluster and have Kubectl installed. The steps in this demo can be applied on any type of Kubernetes Cluster. 

I used a local [Minikube](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fwindows%2Fx86-64%2Fstable%2F.exe+download) cluster on my Windows machine, using Podman in WSL2 to manage the container. I copied the Kubeconfig from Windows to my WSL so I can access the cluster from my trusted WSL shell.

## Getting started

Clone this repository so you can access it locally.

Install ArgoCD CLI locally
```bash
brew install argocd
```

Create a namespace and install ArgoCD in your cluster
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Check if all the pods have started.
```bash
kubectl get pods -n argocd
```

ArgoCD auto-generates an initial password for the admin account. Retrieve the password. This password must always be changed immediately in real-world clusters. 
```bash
argocd admin initial-password -n argocd
```

Check the service ports and port-forward the ArgoCD frontend to port 8080
```bash
kubectl get svc -n argocd
kubectl port-forward -n argocd svc/argocd-server 8080:443
```

Copy the forwarded address and open it in your browser. Skip the warning about the invalid certificate (we have not configured this) and advance to the ArgoCD UI. Use username ```admin``` the previously copied password. You will now be greeted with an empty User Interface.

It's now time to deploy our first application. In your shell, navigate to the root of this repository and run.
```bash
kubectl apply -f application.yaml
```
ArgoCD will now deploy the frontend and backend based on the manifests in the azure-vote-app directory of this repository. 


## References
Check [ArgoCD: Getting Started](https://argo-cd.readthedocs.io/en/stable/getting_started/#1-install-argo-cd)