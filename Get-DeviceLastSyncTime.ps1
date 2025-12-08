function Get-DeviceLastSyncTime {
    param (
        [Parameter(Mandatory = $true)]$ComputerName
    )

    begin {
        try {
            Import-Module -Name "Microsoft.Graph.Authentication"
            Connect-MgGraph -Scopes Device.Read.All -NoWelcome -ContextScope Process
        }
        catch {
            Write-Error $_
        }
    }

    process {
        $devices = Invoke-MgGraphRequest -Method GET "https://graph.microsoft.com/v1.0/deviceManagement/manageddevices?`$select=devicename,lastsyncdatetime&`$filter=(contains(devicename,`'$computername`'))" -SkipHttpErrorCheck
        $device = $devices.value | Where-Object { $_.devicename -eq $ComputerName }
        $computername = $device.devicename
        $lastsyncdatetime = $device.lastsyncdatetime.ToLocalTime()
        return [PSCustomObject]@{"ComputerName" = $computername; "LastSyncDateTime" = $lastsyncdatetime }
    }

    end {
        Disconnect-MgGraph | Out-Null
    }
}