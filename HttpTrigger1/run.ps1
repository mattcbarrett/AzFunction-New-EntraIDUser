using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Source the scripts so we can use them below.
. $PSScriptRoot\scripts\New-Passphrase.ps1
. $PSScriptRoot\scripts\New-EntraIDUser.ps1

# Write to the Azure Functions log stream.
# Write-Host $Request.Body.name

$commandArgs = @{
    accountEnabled = $false
    firstName      = $Request.Body.firstName
    lastName       = $Request.Body.lastName
    title          = $Request.Body.title
    department     = $Request.Body.department
    employeeType   = $Request.Body.employeeType
    officeLocation = $Request.Body.officeLocation
    companyName    = $Request.Body.companyName
    streetAddress  = $Request.Body.streetAddress
    city           = $Request.Body.city
    state          = $Request.Body.state
    zipCode        = $Request.Body.zipCode
    country        = $Request.Body.country
}

Write-Host "Function execution started at $(Get-Date)"
Write-Host "Request Body:" $Request.Body

try {
    $user = New-EntraIDUser @commandArgs

    Write-Host "Successfully created account" $user.Username

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::OK
            Body       = $user
        })
}
catch {
    $errorMessage = $Error[0].Exception.Message
    Write-Host "Failed to create account."
    Write-Host "Error:" $errorMessage

    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::BadRequest
            Body       = $errorMessage
        })
}