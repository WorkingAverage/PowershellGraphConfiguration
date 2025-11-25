function Get-IntuneManagedDeviceConfigurationProfiles {
    <#
    .SYNOPSIS
        This function allows to retrieve the configuration profiles on a particular intune device(s)
    .DESCRIPTION
        This should be used on one Intune device to allow to retrieve all the configuration applied to it. Since configuration profiles tends to appply each time that an user logs on a device this was meant to be clearer as to know if the configuration was applied on the device.
        It automatically search for the device ID using the name inputted as parameter.
    .NOTES
        This script was meant to be used for diagnosis purposes it doesn't deal well with multiple computer names at the same time.
        Author: WorkingAverage
        Date: 2025-11-25
    .LINK
        https://learn.microsoft.com/en-us/graph/api/resources/intune-deviceconfig-deviceconfigurationdevicestatus
    .PARAMETER ComputerName
        Configuration profiles will be retrieved from the device specified
    .EXAMPLE
        Get-IntuneManagedDeviceConfigurationProfiles -ComputerName "COMPUTER01"
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]$ComputerName
    )

    begin {
        Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"  -ContextScope Process -NoWelcome
    }

    process {
        $ids = @()
        $res = @()
        #Retrieving Intune IDs based
        $ids += ($ComputerName | ForEach-Object {
                Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/deviceManagement/manageddevices?`$select=devicename,id&`$filter=devicename eq '$_'" -SkipHttpErrorCheck
            }).value
        $res += ($ids | ForEach-Object {
                Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/$($_.id)/deviceConfigurationStates" -SkipHttpErrorCheck
            }).value
        $data = @()
        $res | ForEach-Object { $data += [pscustomobject]@{
                'id'          = $_.id
                'displayname' = $_.displayname
            } }
        return $data | Sort-Object -Unique -Property displayname
    }

    end {
        Disconnect-MgGraph | Out-Null
    }
}