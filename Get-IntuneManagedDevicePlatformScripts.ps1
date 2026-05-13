<#
.SYNOPSIS
	This script retrieves all the scripts from intune. It can be used to retrieve scripts from one computer using the display name
.NOTES
	If the permission are not set it will be asked the first time to valid them.
	The script is calling the BETA GRAPH API
.LINK
https://learn.microsoft.com/en-us/graph/api/intune-shared-devicemanagementscript-get?view=graph-rest-beta
.EXAMPLE
	Get-IntuneManagedDevicePlatformScripts
	Returns the different scripts that are available on Intune

	Get-IntuneManagedDevicePlatformScripts -DisplayName "PC01"
	Returns the scripts applied on this particular device
#>

function Get-IntuneManagedDevicePlatformScripts {
	[CmdletBinding()]
	param (
		[Parameter()][String]$DisplayName
	)

	begin {
		Connect-MgGraph -Scopes "DeviceManagementScripts.Read.All" -NoWelcome -ContextScope Process
	}

	process {
		try {
			$res = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts" -Method GET -SkipHttpErrorCheck
		}
		catch {
			Write-Error "Error happened in the request"
			Write-Error $_
		}
		$platformScripts = $res.value | ForEach-Object { [PSCustomeObject]$_ }
		if ($PSBoundParameters.ContainsKey('DisplayName')) {
			$platformScripts = $res.value | Where-Object displayName -Match $DisplayName
		}
		return $platformScripts
	}

	end {

	}
}