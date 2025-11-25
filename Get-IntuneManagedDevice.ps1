function Get-IntuneManagedDevice {
    <#
.SYNOPSIS
    Retrieve one or multiples devices managed by Intune using Intune ID or Name. It can also retrieve all devices.
.PARAMETER ComputerName
	Specifies the name of the computer whose properties will be retrieved. This is the go to parameter.
	This will retrieve duplicates (which should be a thing if Intune is properly managed)
.PARAMETER IntuneId
	Specifies the ID(s) of the computer whose properties will be retrieved.
.PARAMETER All
	Switch parameter to retrieve all the devices in Intune
.DESCRIPTION
    This command will retrieve one or multiple Intune managed devices and return the predefined properties.
    As this command use Microsoft Graph you will need the appropriate permissions to get the results.
.NOTES
    The command should be tailored to your needs. Currently returns the following properties:
	devicename,model,serialNumber,osVersion,lastSyncDateTime,deviceEnrollmentType,id,userdisplayname
	The only exception is the parameter -All which will retrieves all devices and all the properties associated to each.
    Author: WorkingAverage
    Date: 2025-11-21
.LINK
    https://learn.microsoft.com/en-us/graph/api/resources/intune-devices-manageddevice?view=graph-rest-1.0
.EXAMPLE
    Get-IntuneManagedDevice -ComputerName "COMPUTER01"
.EXAMPLE
	Get-IntuneManagedDevice -ComputerName "COMPUTER01","PC2"
.EXAMPLE
    Get-IntuneManagedDevice -IntuneId 
.EXAMPLE
    Returns all devices with the predefedined properties
    Get-IntuneManagedDevice
.EXAMPLE
    Get-IntuneManagedDevice -All
#>
    [CmdletBinding()]
    param (
        [Parameter()][string[]]$ComputerName,
        [Parameter(ValueFromRemainingArguments = $false)][string]$IntuneId,
        [Parameter()][switch]$All
    )

    begin {
        #Connecting to Microsoft Graph API v1.0 (Consent will be required if the app doesn't have it)
        Connect-MgGraph -NoWelcome -Scopes "DeviceManagementManagedDevices.Read.All" -ContextScope Process
        $devices = @()
    }

    process {
        #Retrieve all devices from Intune
        if ($All) {
            return (Invoke-MgGraphRequest -Method GET "https://graph.microsoft.com/v1.0/deviceManagement/manageddevices").value
        }
        #Search based on the name
        if ($PSBoundParameters.ContainsKey('ComputerName')) {
            Write-Verbose "Looking for computers with the name(s) $ComputerName"
            $devices += $ComputerName | ForEach-Object {
                Invoke-MgGraphRequest -Method GET "https://graph.microsoft.com/v1.0/deviceManagement/manageddevices?`$select=devicename,model,serialNumber,osVersion,lastSyncDateTime,deviceEnrollmentType,id,userdisplayname&`$filter=devicename eq '$_'" -SkipHttpErrorCheck
            }
        }
        #Search based on Intune Id (not be confused with entra ID)
        elseif ($PSBoundParameters.ContainsKey('IntuneId')) {
            Write-Verbose "Looking for computer(s) with the Intune ID $IntuneId"
            #By using the id this way in the graph request, the reponse data response format is way different than the usual ones (probably should use format imo)
            $devices += $IntuneId | Invoke-MgGraphRequest -Method GET "https://graph.microsoft.com/v1.0/deviceManagement/manageddevices/$_`?`$select=devicename,model,serialNumber,osVersion,lastSyncDateTime,deviceEnrollmentType,id,userdisplayname" -SkipHttpErrorCheck
            return Get-IntuneManagedDeviceEthernetMacAddress -Devices $devices
        }
        else {
            $devices = Invoke-MgGraphRequest -Method GET 'https://graph.microsoft.com/v1.0/deviceManagement/manageddevices?$select=devicename,model,serialNumber,osVersion,lastSyncDateTime,deviceEnrollmentType,id,userdisplayname' -SkipHttpErrorCheck
        }
        #Comment this if you want to return more than just Windows devices
        $devices = ($devices.value | Where-Object { $_.deviceEnrollmentType -match "windowsCoManagement|windowsAzureADJoinUsingDeviceAuth|windowsAzureADJoin" })
        return $devices
    }

    end {
        Disconnect-MgGraph | Out-Null
    }
}