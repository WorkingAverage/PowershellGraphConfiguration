function Get-DeviceLastSyncTime {
    <#
    .SYNOPSIS
        Returns the last sync datetime value from Intune devices. Time will be converted to local machine time.
    #>
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string[]]$ComputerName
    )

    begin {
        try {
            Import-Module -Name "Microsoft.Graph.Authentication"
            Connect-MgGraph -Scopes "Device.Read.All" -NoWelcome -ContextScope Process
        }
        catch {
            Write-Error $_
        }
    }

    process {
        $devices = [pscustomobject]@()
        $devices = ($ComputerName | ForEach-Object { Invoke-MgGraphRequest -Method GET "https://graph.microsoft.com/v1.0/deviceManagement/manageddevices?`$select=devicename,lastSyncDateTime&`$filter=(contains(devicename,`'$_`'))" -SkipHttpErrorCheck }).value
        $devices = $devices | ForEach-Object { [pscustomobject]$_ }
        $devices | Where-Object { $_.lastsyncdatetime = $_.lastsyncdatetime.tolocaltime() }
        return $devices
    }

    end {
        Disconnect-MgGraph | Out-Null
    }
}