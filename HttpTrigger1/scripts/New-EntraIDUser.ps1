<#
  .Synopsis
  Create a new user in Entra ID.

  .Description
  Create a new user in Entra ID with the specified attributes. This script is mostly just a wrapper for New-MgUser.

  .Example
  Create a new user with the minimum required attributes.
  New-EntraIDUser -accountEnabled $false -firstName Test -lastName User

  Create a new user with a title, department, and location.
  New-EntraIDUser -accountEnabled $false -firstName Test -lastName User -title Tester -department Testing -officeLocation Seattle
#>

function New-EntraIDUser {
  param(
    [Parameter(Mandatory = $true)]
    [boolean]$accountEnabled,
    [Parameter(Mandatory = $true)]
    [string]$firstName,
    [Parameter(Mandatory = $true)]
    [string]$lastName,
    [string]$title,
    [string]$department,
    [string]$employeeType,
    [string]$officeLocation,
    [string]$companyName,
    [string]$streetAddress,
    [string]$city,
    [string]$state,
    [string]$zipCode,
    [string]$country
  )

  [string]$emailDomain = '' # Add your email domain here. Omit the @.
  [string]$displayName = $firstName + ' ' + $lastName
  [string]$mailNickname = $firstname.ToLower() + '.' + $lastName.ToLower()
  [string]$emailAddress = $mailNickname + '@' + $emailDomain

  if ($emailDomain -eq '') {
    return "The emailDomain variable is blank! Edit New-EntraIDUser.ps1 and populate it on line 36."
  }

  $password = New-Passphrase

  $passwordProfile = @{
    Password                      = $password
    ForceChangePasswordNextSignIn = $true
  }

  # Uncomment & fill out the below to specify a location (city, building name, etc.) on the command line and have the address populated for you.
  # Duplicate this if statement for each location you have.
  # if ($officeLocation -eq 'Seattle') {
  #   $streetAddress = '701 5th Ave, Ste 100'
  #   $city = 'Seattle'
  #   $state = 'WA'
  #   $zipCode = '98101'
  #   $country = 'United States'
  # }

  $commandArgs = @{
    AccountEnabled    = $accountEnabled
    DisplayName       = $displayName
    MailNickname      = $mailNickname
    UserPrincipalName = $emailAddress
    PasswordProfile   = $passwordProfile
    Mail              = $emailAddress
    GivenName         = $firstName
    Surname           = $lastName
  }

  if ($title) { $commandArgs.Add('JobTitle', $title) }
  if ($department) { $commandArgs.Add('Department', $department) }
  if ($employeeType) { $commandArgs.Add('EmployeeType', $employeeType) }
  if ($officeLocation) { $commandArgs.Add('OfficeLocation', $officeLocation) }
  if ($companyName) { $commandArgs.Add('Company', $companyName) }
  if ($streetAddress) { $commandArgs.Add('StreetAddress', $streetAddress) }
  if ($city) { $commandArgs.Add('City', $city) }
  if ($state) { $commandArgs.Add('State', $state) }
  if ($zipCode) { $commandArgs.Add('PostalCode', $zipCode) }
  if ($country) { $commandArgs.Add('Country', $country) }

  $user = New-MgUser @commandArgs -ErrorAction Stop

  return @{
    Username = $user.UserPrincipalName
    Password = $password
  }
}