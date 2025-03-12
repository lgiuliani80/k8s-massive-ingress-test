helm install --dry-run --generate-name -f .\myvalues.yaml .\multidomain-ingress > k8s\all-ingresses.yaml
$yamls = Get-Content k8s\all-ingresses.yaml | ConvertFrom-Yaml -AllDocuments
$yamls = $yamls[1..$yamls.Count]  # Removes the first YAML, which is the Helm template manifest
$yamls | ConvertTo-Yaml | Set-Content k8s\all-ingresses.yaml -Encoding ascii
