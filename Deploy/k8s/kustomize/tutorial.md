# SmartHotel 360 on Aks (with windows Containers)

for installing this application you need to have helm installed on your local machine and in your kubernetes cluster. You can achieve this following these instructions:

## Download and install helm

You can download from their releases page on github or install vía chocolatey package manager:

```$ choco install kubernetes-helm```

After that you can install helm doing

```$ kubectl apply -f tiller-rbac.yaml```
```$ helm init --node-selectors "beta.kubernetes.io/os"="linux" --service-account tiller ```

Now it's time to setup the ingress controller. This controller has the responsability of route the traffic to the appropiate pod, you can setup this doing:

```helm install stable/nginx-ingress --name smgateway --namespace kube-system --set controller.replicaCount=2 --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux  --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux```

Once time you have completed this stage, you can install the application executing the command:

```$ kubectl apply -k .```


