Param(
    [parameter(Mandatory=$true)][string]$subscriptionId,
    [parameter(Mandatory=$false)][string]$location="eastus",
    [parameter(Mandatory=$true)][string]$resourceGroupName,
    [parameter(Mandatory=$true)][string]$vaultName,
    [parameter(Mandatory=$true)][string]$vaultPwd,
    [parameter(Mandatory=$true)][string]$clustername,
    [parameter(Mandatory=$true)][string]$clusterAdminUser,
    [parameter(Mandatory=$true)][string]$clusterAdminPwd,
    [parameter(Mandatory=$true)][string]$dbAdminUser,
    [parameter(Mandatory=$true)][string]$dbAdminPwd,
    [parameter(Mandatory=$false)][string]$dnsName="$clustername.$location.cloudapp.azure.com",
    [parameter(Mandatory=$false)][string]$clustersize=5,
    [parameter(Mandatory=$false)][string]$databaseName="shregistrationdb",
    [parameter(Mandatory=$false)][string]$acr="shregistrationacr",
    [parameter(Mandatory=$false)][string]$vmsku="Standard_D2s_v3"
)

Login-AzureRmAccount
Set-AzureRmContext -SubscriptionId $subscriptionId

Write-Host "Creating Azure resource group..." -ForegroundColor Yellow
New-AzureRmResourceGroup –Name $resourceGroupName –Location $location

Write-Host "Creating Azure KeyVault..." -ForegroundColor Yellow
$vault = New-AzureRmKeyVault -VaultName $vaultName -ResourceGroupName $resourceGroupName -Location $location -EnabledForDeployment -EnabledForTemplateDeployment -EnabledForDiskEncryption 

Unblock-File -Path “$PSScriptRoot\sf-helpers\ServiceFabricRPHelpers.psm1”
Import-Module “$PSScriptRoot\sf-helpers\ServiceFabricRPHelpers.psm1”

Write-Host "Adding certificate to KeyVault..." -ForegroundColor Yellow
$vault = Invoke-AddCertToKeyVault -SubscriptionId $subscriptionId -ResourceGroupName $resourceGroupName -Location $location -VaultName $vaultName  -CertificateName ‘servicefabriccert’ -Password $vaultPwd -CreateSelfSignedCertificate -DnsName $dnsName -OutputPath "$PSScriptRoot\certificates\"

Write-Host "Importing certificate servicefabriccert..." -ForegroundColor Yellow
Import-PfxCertificate -Exportable -CertStoreLocation Cert:\CurrentUser\My -FilePath "$PSScriptRoot\certificates\servicefabriccert.pfx" -Password ($vaultPwd | ConvertTo-SecureString -AsPlainText -Force)

Write-Host "Creating the Service Fabric cluster..." -ForegroundColor Yellow
$templateFile="$PSScriptRoot\templates\template.json"
$params = @{clusterName=$clustername;adminUsername=$clusterAdminUser;adminPassword=$clusterAdminPwd;certificateThumbprint=$vault.CertificateThumbprint;sourceVaultResourceId=$vault.SourceVault;certificateUrlValue=$vault.CertificateURL;nodeTypeSize=$vmsku;sqlAdminUser=$dbAdminUser;sqlAdminPwd=$dbAdminPwd;databaseName=$databaseName;acr_name=$acr}
New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFile -TemplateParameterObject $params 

Write-Host "Deployment finished!" -ForegroundColor Yellow