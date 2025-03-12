param(
    [Parameter(Mandatory=$true)]
    [string]$KeyVaultName,
    [Parameter(Mandatory=$true)]
    [string[]]$DomainNames
)

$certFolder = "certificates"

Push-Location $certFolder

$i = 0

Write-Host ("Creating and uploading {0} certificates on Key Vault {1} ..." -f $DomainNames.Count, $KeyVaultName) -ForegroundColor Blue
Write-Host ""

$DomainNames | ForEach-Object {
    $i++
    Write-Host ("{0,3}. Creating certificate for domain: {1} ..." -f $i, $_) -ForegroundColor Green
    $sanitizedDomainName = $_ -replace '\.', '-'
    openssl req -new -x509 -nodes -out "$sanitizedDomainName.crt" -keyout "$sanitizedDomainName.key" -subj "/CN=$_" -addext "subjectAltName=DNS:$_"
    Get-Content "$sanitizedDomainName.key", "$sanitizedDomainName.crt" | Set-Content -Path "$sanitizedDomainName.pem" -Encoding Ascii
    Remove-Item "$sanitizedDomainName.key", "$sanitizedDomainName.crt"

    Write-Host ("     Uploading to key vault secret {0}..." -f "ssl-$sanitizedDomainName") -ForegroundColor Gray
    az keyvault certificate import --vault-name $KeyVaultName --name "ssl-$sanitizedDomainName" -f "$sanitizedDomainName.pem"
}

Write-Host ""
Write-Host "Operation completed!"  -ForegroundColor Blue

Pop-Location