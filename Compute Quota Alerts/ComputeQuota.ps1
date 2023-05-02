param(
[Parameter (Mandatory = $true)]
[string]$AppId = ‘’,
[Parameter (Mandatory = $true)]
[string]$PWord = ‘’,
[Parameter (Mandatory = $true)]
[string]$TenantId = ‘’,
[Parameter (Mandatory = $true)]
[string]$CustomerId = ‘’,
[Parameter (Mandatory = $true)]
[string]$SharedKey = ‘’,
[Parameter (Mandatory = $true)]
[string]$LogType = ‘’,
[Parameter (Mandatory = $true)]
[string]$subscriptionIds = @(),
[Parameter (Mandatory = $true)]
[string]$locations = @()
)
$body = ([System.Text.Encoding]::UTF8.GetBytes($json))
#AzureLogin
$SPWord = ConvertTo-SecureString $PWord -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($AppId, $SPWord)
Write-Host “Trying to login to Azure using SPN”
#Login-AzureRmAccount -ServicePrincipal -Credential $Credential -TenantId $TenantId
Connect-AzAccount -ServicePrincipal -Credential $Credential -TenantId $TenantId
Write-Output “Login Successful”
# Replace with your Workspace ID
$CustomerId = $CustomerId
# Replace with your Primary Key
$SharedKey = $SharedKey
# Specify the name of the record type that you’ll be creating
$LogType = $LogType
# You can use an optional field to specify the timestamp from the data. If the time field is not specified, Azure Monitor assumes the time is the message ingestion time
$TimeStampField = ""
Foreach ($subscriptionId in $subscriptionIds)
{
$accountSet = Set-AzContext -SubscriptionId $subscriptionId
# Get Storage Quota

# Create the function to create the authorization signature
Function Build-Signature ($customerId, $sharedKey, $date, $contentLength, $method, $contentType, $resource)
{
$xHeaders = “x-ms-date:” + $date
$stringToHash = $method + “`n” + $contentLength + “`n” + $contentType + “`n” + $xHeaders + “`n” + $resource
$bytesToHash = [Text.Encoding]::UTF8.GetBytes($stringToHash)
$keyBytes = [Convert]::FromBase64String($sharedKey)
$sha256 = New-Object System.Security.Cryptography.HMACSHA256
$sha256.Key = $keyBytes
$calculatedHash = $sha256.ComputeHash($bytesToHash)
$encodedHash = [Convert]::ToBase64String($calculatedHash)
$authorization = ‘SharedKey {0}:{1}’ -f $customerId,$encodedHash
return $authorization
}
}

# Create the function to create and post the request
Function Post-LogAnalyticsData($customerId, $sharedKey, $body, $logType)
{
    $method = "POST"
    $contentType = "application/json"
    $resource = "/api/logs"
    $rfc1123date = [DateTime]::UtcNow.ToString("r")
    $contentLength = $body.Length
    $signature = Build-Signature `
        -customerId $customerId `
        -sharedKey $sharedKey `
        -date $rfc1123date `
        -contentLength $contentLength `
        -method $method `
        -contentType $contentType `
        -resource $resource
    $uri = "https://" + $customerId + ".ods.opinsights.azure.com" + $resource + "?api-version=2016-04-01"

    $headers = @{
        "Authorization" = $signature;
        "Log-Type" = $logType;
        "x-ms-date" = $rfc1123date;
        "time-generated-field" = $TimeStampField;
    }

    $response = Invoke-WebRequest -Uri $uri -Method $method -ContentType $contentType -Headers $headers -Body $body -UseBasicParsing
    return $response.StatusCode

}


# Get VM Usage
# Get VM quotas
foreach ($location in $locations)
{
$vmQuotas = Get-AzVMUsage -Location $location
foreach($vmQuota in $vmQuotas)
{
$usage = 0
if ($vmQuota.Limit -gt 0) { $usage = ($vmQuota.CurrentValue / $vmQuota.Limit)*100}
$json = @"
[{ "Name":"$($vmQuota.Name.LocalizedValue)", "Category":"Compute", "Location":"$location", "CurrentValue":$($vmQuota.CurrentValue), "Limit":$($vmQuota.Limit),"PercentageUsage":$usage }]
"@

Post-LogAnalyticsData -customerId $customerId -sharedKey $sharedKey -body ([System.Text.Encoding]::UTF8.GetBytes($json)) -logType $logType
}
}
#$json | Out-File -FilePath C:\Azure\json2.json