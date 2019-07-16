Param(
    [parameter(Mandatory=$true)][string]$aksName,
    [parameter(Mandatory=$true)][string]$resourceGroup,
    [parameter(Mandatory=$false)][string]$winuser="azureuser",
    [parameter(Mandatory=$true)][string]$winpwd,
    [parameter(Mandatory=$false)][string]$aksVersion,
    [parameter(Mandatory=$false)][string]$clientId,
    [parameter(Mandatory=$false)][string]$clientPassword,
    [parameter(Mandatory=$false)][int]$windowsNodes=2,
    [parameter(Mandatory=$false)][int]$linuxNodes=2
)

$rg = $(az group show -n $resourceGroup | ConvertFrom-Json)
if (-not $rg) {
    Write-Host "Resource group $resourceGroup do not exists" -ForegroundColor Red
    exit 1
}

if ([String]::IsNullOrEmpty($clientId) -or [String]::IsNullOrEmpty($clientPassword)) {
    Write-Host "No service principal credentials passed. Creating a new service principal..." -ForegroundColor Yellow
    $sp = $(az ad sp create-for-rbac | ConvertFrom-Json)
    $clientId = $sp.appId
    $clientPassword = $sp.password
    Write-Host "Service principal created is $sp" -ForegroundColor Yellow

}

if ([String]::IsNullOrEmpty($aksVersion)) {
    $location=$rg.location
    Write-Host "No k8s version set - Getting available versions from location $location" -ForegroundColor Yellow
    $versions=$(az aks get-versions -l $location | ConvertFrom-Json)
    $aksVersion=$versions.orchestrators[-1].orchestratorVersion
    Write-Host "Will use k8s version $aksVersion" -ForegroundColor Yellow
}

Write-Host "Creating AKS $aksName in RG $resourceGroup..." -ForegroundColor Yellow
az aks create --resource-group $resourceGroup --name $aksName --node-count $linuxNodes --enable-addons monitoring --kubernetes-version $aksVersion --generate-ssh-keys --windows-admin-password $winpwd --windows-admin-username $winuser --enable-vmss --network-plugin azure

Write-Host "Adding win node pool to $aksName in RG $resourceGroup..." -ForegroundColor Yellow
az aks nodepool add --resource-group $resourceGroup --cluster-name $aksName --os-type Windows --name npwin --node-count $windowsNodes --kubernetes-version $aksVersion

Write-Host "AKS created." -ForegroundColor Yellow
Write-Host "To access AKS using kubectl run: " -ForegroundColor Yellow
Write-Host "az aks get-credentials -g $resourceGroup -n $aksName" -ForegroundColor Yellow