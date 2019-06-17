Param(
        [parameter(Mandatory=$false)][string]$dnsname="smhotel360win" 
)

Write-Host "Resolving DNS to Gateway public IP" -ForegroundColor Green
$ipaddress = $(kubectl get service smgateway-nginx-ingress-controller -n kube-system)[1] | %{ $_.Split('   ')[9];}
Write-Host $ipaddress
$query = "[?ipAddress!=null]|[?contains([ipAddress], '$ipaddress')].[id]"
Write-Host $query
$resid = az network public-ip list --query $query --output tsv
Write-Host $resid
$jsonresponse = az network public-ip update --ids $resid --dns-name $dnsname
$externalDns = ($jsonresponse | ConvertFrom-Json).dnsSettings.fqdn
Write-Host "$externalDns is pointing to Cluster public ip $ipaddress"
Read-Host -Prompt "Press Enter to continue"
# Gateway Generation
.\token-replace.ps1 -tokens @{ApplicationHost=$externalDns} -inputFile .\kustomize\ingress\deployment.template -outputFile .\kustomize\ingress\deployment.yaml
Read-Host -Prompt "Press Enter to continue"
Write-Host "Deploying application"
kubectl apply -k .\kustomize