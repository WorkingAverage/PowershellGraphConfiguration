<#
.SYNOPSIS
    Set the tenant setting "AllowedToReadOthers" to $true. Make sure you have the right permissions or to consent when the login windows pops-up.
.DESCRIPTION
    This is a common error fix for tenants that use Microsoft Teams, setting this value to $false will break it.
.NOTES
    The script is to replace the many documentations that can still be found saying to use MSOnline module which has been deprecated in 2024.
    With the commands Get-MsolCompanyInformation and Set-MsolCompanySettings.
.LINK
    https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.identity.signins/update-mgpolicyauthorizationpolicy
.EXAMPLE
   .\Update-AllowedToReadOtherUsers.ps1 -AllowedToReadOtherUsers:$true
#>

param(
    [Parameter(Mandatory = $true)]
    [bool]$AllowedToReadOtherUsers
)
#Current Graph version 2.28.0
#Permissions needed for updating the policies only
Connect-MgGraph -Scopes "Policy.Read.All, Policy.ReadWrite.Authorization" -NoWelcome
#(Find-MgGraphCommand Get-MgPolicyAuthorizationPolicy).permissions for confirming the authorization
$policies = Get-MgPolicyAuthorizationPolicy
$default_user_role_permissions = ($policies).DefaultUserRolePermissions
#If you are using Microsoft Teams should keep this setting on $true, this will break the ability of users to add members to channels and such or see their names in the channels
$default_user_role_permissions.AllowedToReadOtherUsers = $AllowedToReadOtherUsers
#Remove the WhatIf to properly make the changes
Update-MgPolicyAuthorizationPolicy -DefaultUserRolePermissions $default_user_role_permissions -Confirm:$true -WhatIf

