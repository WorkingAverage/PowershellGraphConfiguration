# Powershell Graph Configuration and Management (Azure AD / Entra-Joined / Intune)
I created this repository has a toolbox for my fellow sysadmins, where microsoft documentation on Microsoft API is convolated I hope this makes your life easier.

These scripts were meant to be put in a module but I thought adding them as their own standalone will be better to explain how they work.

## Requirements
Preferably install `Microsoft.Graph` powershell module before attempting to run any of these scripts.
```Powershell
Install-Module -Name "Microsoft.Graph" -RequiredVersion "2.31.0"
```

Update-AllowedToReadOtherUsers
----------
It's meant to fix a property that people used to have set to `false` since most google researches will end up with trying [MSOnline](https://techcommunity.microsoft.com/blog/microsoft-entra-blog/important-update-deprecation-of-azure-ad-powershell-and-msonline-powershell-modu/4094536) or [AzureAD](https://techcommunity.microsoft.com/blog/microsoft-entra-blog/important-update-deprecation-of-azure-ad-powershell-and-msonline-powershell-modu/4094536) which are both deprecated.

This setting was set to `false` for security concerns but we reverted this back to `true` since it became a problem when people came to use Teams to add members to a private channel for example.


Get-IntuneManagedDevice
----------
 This script retrieves device(s) properties in intune with or without predefined properties to look up using `devicename` or `id` (intune id)

Get-IntuneManagedDeviceConfigurationProfiles
----------
This script is for retrieving unique configuration profiles applied to a device from Intune. Working in an environmment where you have multiple people logging and out on a device it makes reading the configuration profiles reading more easier to diagnostic.

Get-RemoteControl
----------
Allows to control/view user's session on a remote computer can be used for console/RDP.  
For this command to work you must allow RDP over the remote computer, the firewall rules "RemoteDesktop-Shadow-In-TCP" and "FPS-SMB-In-TCP" must be enabled.
Settings configuration on the remote computer:
- Windows Components > Remote Desktop Services > Remote Desktop Session Host > Connections
    - Options: (Device) = Full Control without user's permission
    - Allow users to connect remotely by using Remote Desktop Services = Enabled
    - Set rules for remote control of Remote Desktop Services user sessions = Enabled

Get-MailboxSMTPForwardAddress
----------
Quick access to check if a user has a forward on their mailbox or not.
This was made to treat a lot of users during a mail server migration to minimize efforts and be combined with the following script

Remove-MailboxSMTPForwardAddress
----------
To be used with the previous scripts to remove mailbox forward from mailboxes.

>Those scripts are quite simple and should be tested thoroughly so that no mistakes will be made. I do intend to improve as much to avoid errors but as of right now it's not the case.  
*The Set-MailboxSMTPForwardAddress doesn't exist but it could be easily made*

Get-DeviceLastSyncTime
----------
Returns the last sync datetime from one or more Intune devices. The time will be converted to local time for easier readability.  

Get-PrinterCountMeters
----------
Retrieve total counters on printers using SNMP
