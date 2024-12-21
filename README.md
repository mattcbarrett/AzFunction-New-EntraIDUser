# Before deploying
Populate the $emailDomain variable in HttpTrigger1\scripts\New-EntraIDUser.ps1

"Connect-MgGraph -NoWelcome -Identity" is uncommented by default in profile.ps1. If you're developing locally, go uncomment the line without the "-Identity" switch.

# Deploy to Azure via zip file
[MS Documentation](https://learn.microsoft.com/en-us/azure/azure-functions/deployment-zip-push)

Create a resource group and services in azure
```
az group create --name azfunc-new-entraiduser --location westus2
az deployment group create --resource-group azfunc-new-entraiduser --template-file .\bicep\main.bicep
```

Zip the project for deployment
```
Compress-Archive -Path .\requirements.psd1, .\profile.ps1, .\host.json, .\HttpTrigger1\ -DestinationPath .\project.zip
```

Deploy it
```
az functionapp deployment source config-zip -g azfunc-new-entraiduser -n name_of_function_app --src project.zip
```


# Give the function's managed identity permissions within MS Graph
Install Azure CLI: [here](https://learn.microsoft.com/en-us/cli/azure/)

Retrieve the system-assigned identity's service principal
```
az webapp identity show --name name_of_function_app --resource-group azfunc-new-entraiduser
```

Assign MS Graph permissions to the managed identity (service principal). Populate $managedIdentitySPN with the "default" key from the last step and paste the code below into a terminal window.
```
Connect-AzAccount
$managedIdentitySPN = ''
$msGraphPermissions = 'User.ReadWrite.All'

$msGraphAppId = '00000003-0000-0000-c000-000000000000'
$msGraphSPN = Get-AzADServicePrincipal -Filter "appId eq '$msGraphAppId'"
$appRoles = $msGraphSPN.AppRole | Where-Object {$_.Value -in $msGraphPermissions -and $_.AllowedMemberType -contains 'Application'}
$appRoles | % { New-AzADServicePrincipalAppRoleAssignment -ServicePrincipalId $managedIdentitySPN -ResourceId $msGraphSPN.Id -AppRoleId $_.Id }
```
This can take an hour to apply.

# Usage
Get the app's function key
```
az functionapp keys list --name name_of_function_app --resource-group azfunction-new-entraiduser
```

Get the app's hostname
```
az functionapp config hostname list --webapp-name name_of_function_app --resource-group azfunction-new-entraiduser
```

Build the URL: https://hostname/api/HttpTrigger1?code=function_key

Trigger the function by sending a POST request to the url with a JSON payload.

Minimum required attributes:
```
{
  "firstName": "Test",
  "lastName": "User"
}
```

All available attributes:
```
{
  "firstName": "Test",
  "lastName": "User",
  "title": "Tester",
  "department": "Testing",
  "employeeType": "FTE",
  "officeLocation": "Seattle",
  "companyName": "Testers, Inc.",
  "streetAddress": "701 5th Ave, Ste 100",
  "city": "Seattle",
  "state": "WA",
  "zipCode": "98101",
  "country": "United States"
}
```