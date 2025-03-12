$output = Get-Content .\all-ingresses.yaml | ConvertFrom-Yaml -AllDocuments

$i = 0
$output | ForEach-Object {
    $i++
    Write-Host ("{0,4}. Deploying ingress for domain: {1} ..." -f $i, $_.metadata.name) -ForegroundColor Green
    $_ | ConvertTo-Yaml | kubectl apply -n ts-commerce-ingress-demo -f -
    Start-Sleep -Seconds 2
}