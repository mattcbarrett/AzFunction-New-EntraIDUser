# Before deploying
Populate the $emailDomain variable in HttpTrigger1\scripts\New-EntraIDUser.ps1

Ensure the proper "Connect-MgGraph" command is uncommented in profile.ps1, see comments in the file.

# Deploy with the Azure Functions extension in VScode


# Enable system-assigned identity and give it permissions within Entra ID
Install Azure CLI: [here](https://learn.microsoft.com/en-us/cli/azure/)

Create service principal
```
az webapp identity assign --name name_of_function_app --resource-group name_of_resource_group
```

Assign Entra ID permissions to the managed identity (service principal)
```
Connect-AzAccount
$managedIdentitySPN = ''
$msGraphPermissions = 'User.ReadWrite.All'

$msGraphAppId = '00000003-0000-0000-c000-000000000000'
$msGraphSPN = Get-AzADServicePrincipal -Filter "appId eq '$msGraphAppId'"
$appRoles = $msGraphSPN.AppRole | Where-Object {$_.Value -in $msGraphPermissions -and $_.AllowedMemberType -contains 'Application'}
$appRoles | % { New-AzADServicePrincipalAppRoleAssignment -ServicePrincipalId $managedIdentitySPN -ResourceId $msGraphSPN.Id -AppRoleId $_.Id }
```