function Get-UserSignIns {
    param (
        [Parameter()]$UserDisplayName,
        [Parameter()]$Identity,
        [Parameter()]$StartDate,
        [Parameter()]$EndDate,
        [Parameter()]$Top
    )

    begin {
        try {
            Import-Module -Name Microsoft.Graph.Authentication
            Connect-MgGraph -Scopes "AuditLog.Read.All" -NoWelcome -ContextScope Process
        }
        catch {
            Write-Error $_
        }
    }

    process {

        if ($PSBoundParameters.ContainsKey('Identity')) {
            $fullUrl = "https://graph.microsoft.com/v1.0/auditLogs/signIns?`$select=createdDateTime,UserDisplayName,UserPrincipalName,AppDisplayName,DeviceDetail&`$filter=(contains(userPrincipalName,`'$identity`') and appDisplayName eq `'Windows Sign In')"
        }
        else {
            $fullUrl = "https://graph.microsoft.com/v1.0/auditLogs/signIns?`$select=createdDateTime,AppDisplayName,UserPrincipalName,UserDisplayName,DeviceDetail&`$filter=(contains(userDisplayName,`'$userdisplayname`') and appDisplayName eq `'Windows Sign In')"
        }
        if ($PSBoundParameters.ContainsKey('Top') -and $Top -is [int]) {
            $fullUrl += "&`$Top=$Top"
        }
        else {
            $fullUrl += "&`$Top=5"
        }
        $response = Invoke-MgGraphRequest -Uri $fullUrl -SkipHttpErrorCheck
        $report = $response.value | ForEach-Object {
            [pscustomobject]@{
                createdDateTime   = $_.createdDateTime.ToLocalTime()
                userDisplayName   = $_.userDisplayName
                UserPrincipalName = $_.userPrincipalName
                deviceDisplayName = $_.devicedetail.displayName
            }
        }
        return $report
    }

    end {
        Disconnect-MgGraph | Out-Null
    }
}