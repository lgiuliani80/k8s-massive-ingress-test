param (
    [strig]$Namespace
)

$delim = "-----BEGIN "

Write-Host "* Deploying sample service..." -ForegroundColor Yellow
kubectl apply -f k8s\myservice.yaml -n $Namespace
Write-Host "  Done." -ForegroundColor Gray

Write-Host "* Reading ingress yaml file..." -ForegroundColor Yellow
$output = Get-Content k8s\all-ingresses.yaml | ConvertFrom-Yaml -AllDocuments
Write-Host "  Done." -ForegroundColor Gray

$i = 0
$output | ForEach-Object {
    $i++
    
    Write-Host ("{0,4}. Deploying ingress for domain: {1} ..." -f $i, $_.metadata.name) -ForegroundColor Green

    $ingress = $_
    
    $secretName = $ingress.spec.tls[0].secretName
    $pemFile = "certificates\$($secretName -replace 'keyvault-ingress-', '').pem"
    $pem = Get-Content -Raw $pemFile
    $pemSplit = $pem -split $delim
    ($delim + ($pemSplit | Where-Object { $_.StartsWith("CERTIFICATE") } | Select-Object -First 1)) | Set-Content -Path "$($secretName).crt" -Encoding ascii
    ($delim + ($pemSplit | Where-Object { $_.StartsWith("PRIVATE KEY") } | Select-Object -First 1)) | Set-Content -Path "$($secretName).key" -Encoding ascii
    
    kubectl create secret tls $secretName --cert="$($secretName).crt" --key="$($secretName).key" -n $Namespace

    Remove-Item "$($secretName).crt", "$($secretName).key" -Force

    $ingress | ConvertTo-Yaml | kubectl apply -n $Namespace -f -
    Start-Sleep -Seconds 2
}

Write-Host "Operation completed!"  -ForegroundColor Blue