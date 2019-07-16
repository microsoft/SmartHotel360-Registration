Param(
        [parameter(Mandatory=$false)][string]$dnsname="smhotel360win",
        [parameter(Mandatory=$false)][string]$tlsCertFile="",
        [parameter(Mandatory=$false)][string]$tlsKeyFile="",
        [parameter(Mandatory=$false)][string]$tlsSecretName="sh360-reg-tls"
)

Write-Host "Resolving DNS to Gateway public IP" -ForegroundColor Green
$ipaddress = $(kubectl get service smgateway-nginx-ingress-controller -n kube-system)[1] | %{ $_.Split('   ')[9];}
$query = "[?ipAddress!=null]|[?contains([ipAddress], '$ipaddress')]"
$ip = $(az network public-ip list --query $query --output json | ConvertFrom-Json)
$resid=$ip.id
$isFqdn=$false
$useSsl=$false
if ($dnsname.Contains(".")) {
    $isFqdn=$true
    $externalDns=$dnsName
    Write-Host "Will use $dnsName as a FQDN. Please ensure the IP '$resid' ($ipaddress) is correctly configured in the portal " -ForegroundColor Yellow
    $useSsl= -not [String]::IsNullOrEmpty($tlsCertFile) -and -not [String]::IsNullOrEmpty($tlsKeyFile)
}

if (-not $isFqdn) {
    Write-Host "Configuring IP $ipAddress to use DNS $dnsName..." -ForegroundColor Yellow
    $jsonresponse = az network public-ip update --ids $ip.id --dns-name $dnsname
    $externalDns = ($jsonresponse | ConvertFrom-Json).dnsSettings.fqdn
    Write-Host "$externalDns is pointing to Cluster public ip $ipaddress" -ForegroundColor Yellow
}

Write-Host "Ingress will be configured against DNS: $externalDns" -ForegroundColor Yellow
if ($useSsl) {
    Write-Host "SSL will be enabled using cert file $tlsCertFile and key file $tlsKeyFile" -ForegroundColor Yellow
    kubectl create secret tls $tlsSecretName --cert $tlsCertFile --key $tlsKeyFile
    Write-Host "Secret $tlsSecretName created" -ForegroundColor Yellow
}
# Gateway Generation
.\token-replace.ps1 -tokens @{ApplicationHost=$externalDns;TlsSecretName=$tlsSecretName} -inputFile .\kustomize\ingress\deployment.template -outputFile .\kustomize\ingress\deployment.yaml
Write-Host "Deploying application"
kubectl apply -k .\kustomize