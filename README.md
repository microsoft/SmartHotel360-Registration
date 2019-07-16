# SmartHotel360

We are happy to announce the release of SmartHotel360. This release intends to share a simplified version of SmartHotel360 reference sample apps used at Connect(); 2017 Keynotes. If you missed it, you can watch <a href="https://channel9.msdn.com/Events/Connect/2017/K100">Scott Guthrie’s Keynote: Journey to the Intelligent Cloud in Channel 9</a>.

We updated the code for this repository to support Scott Hanselman's General Session from Ignite 2018, [An end-to-end tour of the Microsoft developer platform](https://myignite.techcommunity.microsoft.com/sessions/66696#ignite-html-anchor). 

# SmartHotel360 Repos
For this reference app scenario, we built several consumer and line-of-business apps and an Azure backend. You can find all SmartHotel360 repos in the following locations:

- [SmartHotel360](https://github.com/Microsoft/SmartHotel360)
- [IoT](https://github.com/Microsoft/SmartHotel360-IoT)
- [Mixed Reality](https://github.com/Microsoft/SmartHotel360-MixedReality)
- [Backend](https://github.com/Microsoft/SmartHotel360-Backend)
- [Website](https://github.com/Microsoft/SmartHotel360-Website)
- [Mobile](https://github.com/Microsoft/SmartHotel360-Mobile)
- [Sentiment Analysis](https://github.com/Microsoft/SmartHotel360-SentimentAnalysis)
- [Registration](https://github.com/Microsoft/SmartHotel360-Registration)

# SmartHotel360 - Registration

The application we are using in this sample is a hotel front-desk registration application. It's basic functionality is to check guest in and out.

![pods working](Documents/Images/website_deploy.png)

# Getting Started 

To modernize the application, it is followed a lift and shift approach to move it to Azure. To do so, we first need to containerize the application and later host it in Azure Kubernetes Service (AKS).

The application is the existing WebForms, WCF and Azure SQL Database pieces, as depicted below. This is a very traditional three-tire application, using Entity Framework to integrate with the data in the Azure SQL database, exposing it through a WCF service, which the WebForms application then interacts with.

![Architecture Overview](Documents/Images/arch_overview.PNG)


## Key Takeaways
The key takeaways of this demo are:

Lift and shift Full Framework applications to Azure.
Deploy the SmartHotel 360 Registration in an AKS with Windows nodes

## Demo Scenario

- Deploy locally with Docker
Illustrates how easy it is to deploy.

- Deploy on AKS (with windows Containers)
Instructs the steps to deploy apps to Azure Kubernetes Service.

## Setup

You will need:

- Windows 10
- Visual Studio 2017 Version 15.5 or higher.
- You need to have the Azure and .NET workload enabled
- Docker
- Aks-preview CLI extension
- Download and install helm

## Exercise 1: Deploy lift and shift locally 

1. Open Visual Studio as Administrator.

2. Open the SmartHotel.Registration solution.

3. Open and set Docker with Windows Containers.

4. Publish the two projects: SmartHotel.Registration.Wcf and SmartHotel.Registration.Web using Visual Studio. This publish will generate necessary files to run the project locally with docker. In this case we have published these projects in obj\Docker\publish in accordance with docker files project (COPY ${source:-obj/Docker/publish} .)

![Publish option](Documents/Images/publish.PNG)

![Publish routes](Documents/Images/publish_route.PNG)

5. Now we are ready to run. Located where docker-compose.yml is, run docker-compose build and docker-compose up to deploy all resources needed.
If it is your first time remember that docker-compose build may take some time because is creating all images.

6. After docker-compose up finishes website will be deployed and accessible at http://localhost:5000/

![Docker finished](Documents/Images/dockercomposeup_finish.PNG)

The Web app shows a list of customer registrations. If so, it means that all services are up and running.

![website deploy options](Documents/Images/website_deploy.png)

We could to debug the apps and services locally running these projects with Visual Studio.

## Exercise 2: Deploy lift and shift with Azure Kubernetes Service (AKS)

This tutorial is a starting point for deploy the SmartHotel 360 Registration in an AKS with Windows nodes.

1. Building the AKS
First step is configure and enable the AKS Cluster ready for windows, for doing this, you have to follow this steps:

### Install aks-preview CLI extension

The CLI commands to create and manage multiple node pools are available in the aks-preview CLI extension. Install the aks-preview Azure CLI extension using the az extension add command, as shown in the following example:

```bash
az extension add --name aks-preview
```

If you've previously installed the aks-preview extension, install any available updates using the az extension update ```--name aks-preview``` command.

### Register Windows preview feature
To create an AKS cluster that can use multiple node pools and run Windows Server containers, first enable the WindowsPreview feature flags on your subscription. The WindowsPreview feature also uses multi-node pool clusters and virtual machine scale set to manage the deployment and configuration of the Kubernetes nodes. Register the WindowsPreview feature flag using the az feature register command as shown in the following example:

```bash
az feature register --name WindowsPreview --namespace Microsoft.ContainerService
```
 
> Any AKS cluster you create after you've successfully registered the WindowsPreview feature flag use this preview cluster experience. To continue to create regular, fully-supported clusters, don't enable preview features on production subscriptions. Use a separate test or development Azure subscription for testing preview features.

It takes a few minutes for the status to show Registered. You can check on the registration status using the az feature list command:

```bash
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/WindowsPreview')].{Name:name,State:properties.state}"
```

When ready, refresh the registration of the Microsoft.ContainerService resource provider using the az provider register command:

```bash
az provider register --namespace Microsoft.ContainerService
``` 

> _Limitations_
The following limitations apply when you create and manage AKS clusters that support multiple node pools:
>Multiple node pools are available for clusters created after you've successfully registered the WindowsPreview. Multiple node pools are also available if you register the MultiAgentpoolPreview and VMSSPreview features for your subscription. You can't add or manage node pools with an existing AKS cluster created before these features were successfully registered.
You can't delete the first node pool.
While this feature is in preview, the following additional limitations apply:
> - The AKS cluster can have a maximum of eight node pools.
> - The AKS cluster can have a maximum of 400 nodes across those eight node pools.
> - The Windows Server node pool name has a limit of 6 characters.

### Create a resource group

An Azure resource group is a logical group in which Azure resources are deployed and managed. When you create a resource group, you are asked to specify a location. This location is where resource group metadata is stored, it is also where your resources run in Azure if you don't specify another region during resource creation. Create a resource group using the az group create command.

The following example creates a resource group named myResourceGroup in the eastus location.

```bash
az group create --name myResourceGroup --location eastus
```

The following example output shows the resource group created successfully:

```json
{
  "id": "/subscriptions/<guid>/resourceGroups/myResourceGroup",
  "location": "eastus",
  "managedBy": null,
  "name": "myResourceGroup",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": null
}
```

### Create AKS cluster using the CLI
In order to run an AKS cluster that supports node pools for Windows Server containers, your cluster needs to use a network policy that uses Azure CNI (advanced) network plugin. For more detailed information to help plan out the required subnet ranges and network considerations, see configure Azure CNI networking. Use the az aks create command to create an AKS cluster named myAKSCluster. This command will create the necessary network resources if they don't exist.

The cluster is configured with one node
The windows-admin-password and windows-admin-username parameters set the admin credentials for any Windows Server containers created on the cluster.
Provide your own secure PASSWORD_WIN. 

```bash
PASSWORD_WIN="P@ssw0rd1234"

az aks create \
    --resource-group myResourceGroup \
    --name myAKSCluster \
    --node-count 1 \
    --enable-addons monitoring \
    --kubernetes-version 1.14.0 \
    --generate-ssh-keys \
    --windows-admin-password $PASSWORD_WIN \
    --windows-admin-username azureuser \
    --enable-vmss \
    --network-plugin azure
```

After a few minutes, the command completes and returns JSON-formatted information about the cluster.

**Note**: If using Powershell you can use the script `/Deploy/CreateAks.ps1` instead

### Add a Windows Server node pool
By default, an AKS cluster is created with a node pool that can run Linux containers. Use az aks nodepool add command to add an additional node pool that can run Windows Server containers.

```bash
az aks nodepool add \
    --resource-group myResourceGroup \
    --cluster-name myAKSCluster \
    --os-type Windows \
    --name npwin \
    --node-count 1 \
    --kubernetes-version 1.14.0
```

The above command creates a new node pool named npwin and adds it to the myAKSCluster. When creating a node pool to run Windows Server containers, the default value for node-vm-size is Standard_D2s_v3. If you choose to set the node-vm-size parameter, please check the list of restricted VM sizes. The minimum recommended size is Standard_D2s_v3. The above command also uses the default subnet in the default vnet created when running az aks create.

**Note**: If using Powershell you can use the script `/Deploy/CreateAks.ps1` instead

### Creating AKS using PowerShell

Instead of using `az` to create the AKS and add the node pool, if using PowerShell you can use the script `/Deploy/CreateAks.ps1` instead. The script will create an AKS and add the windows node pool. Parameters of the script are:

* `aksName`: Name of the AKS to create
* `resourceGroup`: Resource group where to create the AKS. It must exist
* `clientId`: Service principal ID to use for create the AKS. If ommited a new service principal will be created.
* `clientPassword`: Password of the service principal to use for create the AKS. If ommited a new service principal will be created.
* `winuser`: Windows user of the windows machines. Defaults to `azureuser`
* `winpwd`: Password of the user of the windows machines.
* `aksVersion`: Kubernetes version to use. If ommited the latest version available in the resource group location will be used.
* `windowsNodes`: Number of windows nodes. Defaults to `2`.
* `linuxNodes`: Number of linux nodes. Defaults to `2`.

### Connect to the cluster
To manage a Kubernetes cluster, you use kubectl, the Kubernetes command-line client. If you use Azure Cloud Shell, kubectl is already installed. To install kubectl locally, use the az aks install-cli command:

```bash
az aks install-cli
```

>**Note** Please ensure that the kubectl version is **at least** 1.14.3. If a previous version is installed update the Azure CLI or [install kubectl manually](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

To configure kubectl to connect to your Kubernetes cluster, use the az aks get-credentials command. This command downloads credentials and configures the Kubernetes CLI to use them.

```bash
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
```

To verify the connection to your cluster, use the command `kubectl get nodes -o wide` to return a list of the cluster nodes. Nodes of the two nodepools should be listed:

![Output of kubectl get nodes](./Documents/Images/get-nodes.png)

### Download and install helm

**Note** Helm is used only to install the Nginx ingress controller. SmartHotel 360 registration itself is installed using [Kustomize](https://kustomize.io/).

Please refer to [Helm installation page](https://github.com/helm/helm#install) to get the instructions on how get Helm for your system.

After that you can install helm going to the folder `Deploy\k8s` and type this commands:

```bash
$ kubectl apply -f tiller-rbac.yaml
$ helm init --node-selectors "beta.kubernetes.io/os"="linux" --service-account tiller
```

This installs helm on the cluster, in the linux nodes (helm pods are linux pods, you have to install this tooling in the linux nodes).

Now it's time to setup the ingress controller. This controller has the responsability of route the traffic to the appropiate pod, you can setup this doing:

```bash
helm install stable/nginx-ingress \ 
    --name smgateway \
    --namespace kube-system \
    --set controller.replicaCount=2 
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux  \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux
```

To ensure the Nginx ingress controller is running you can type `kubectl get pods -n kube-system -l app=nginx-ingress` and check the nginx ingress controller pods are running:

![Nginx controller pods](./Documents/Images/get-pods-nginx.png)

### Deploy the Application

Once time you have completed this stage, you can install the application executing the powershell script `deploy.ps1`. When installing the app you must pass the `dnsname` parameter. 

This accepts the following parameters:

 * `dnsname`: The DNS name to use to access your application. If the DNS contains any dot character it is considered a fully-qualified domain name (FQDN). If `dnsname` do not contain any dot is considered a subdomain name.

If `dnsname` is set to a FQDN you can enable SSL on the cluster. Following parameters are needed when enabling SSL:

* `tlsCertFile`: Name of the certificate file (PEM) that contains the TLS certificate. If not passed SSL is not enabled
* `tlsKeyFile`: Name of the private key file of the certificate. Must be unencrypted (with no password).
* `tlsSecretName`: Kubernetes secret name where TLS certificate will be stored. Defaults to `sh360-reg-tls`.

**Important**: If the parameter `dnsname` is a subdomain the script will auto-configure the public ip of the ingress controller to ensure it has the subdomain applied. But if the parameter `dnsname` is a FQDN the script assumes that the public IP is already configured.

Once script is finished, the SmartHotel registration is installed. A `kubectl get pods` should list the three pods:

![pods working](Documents/Images/pods_working.png)

### Accessing the Application

The ingress is configured to the domain you passed in the `dnsname` parameter of the `deploy.ps1` script. If `dnsname` where a domain, the full domain is `$dnsname.<region>.cloudapp.azure.com`. The full DNS is output by the `deploy.ps1` script:

![Output of the deploy.ps1 script when subdomain is used](./Documents/Images/deploy-output-subdomain.png)

Another way to find the domain configured is by `kubectl get ing`. This will show the ingress resource alongside its full domain name:

![Output of kubectl get ing](Documents/Images/get-ing.png)

If you navigate to this URL the web should appear.

## Summary
Docker and Azure Kubernetes Service allow us to deploy Full Framework applications and bring them to Azure providing all the benefits of the cloud such as reliability and scalability.

## Contributing
This project welcomes contributions and suggestions. Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the Microsoft Open Source Code of Conduct. For more information see the Code of Conduct FAQ or contact opencode@microsoft.com with any additional questions or comments.