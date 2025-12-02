function Get-RemoteControl {
    <#
    .SYNOPSIS
        Allows to get remote control over a user connected on a remote computer (Works for console or RDP)
    .DESCRIPTION
        This was made to make it easier and faster to remote control over a user session on a remote computer.
        Using the shadow volumes by extracting the session ID from the remote session (meaning you need to be able to do remote commands on the remote computer)
        For this command to work you must allow RDP over the remote computer, the firewall rules "RemoteDesktop-Shadow-In-TCP" and "FPS-SMB-In-TCP" must be enabled.
        Settings configuration on the remote commputer:
        Windows Components > Remote Desktop Services > Remote Desktop Session Host > Connections
            Options: (Device) = Full Control without user's permission
            Allow users to connect remotely by using Remote Desktop Services = Enabled
            Set rules for remote control of Remote Desktop Services user sessions = Enabled
    .NOTES
        The consent prompt should be a default behavior.
        If UAC is set up to use the secure desktop you won't be able to elevate applications. In that case change UAC behavior to elevate without secure desktop or use RemoteHelp Intune feature is available.
    .EXAMPLE
        Get-RemoteControl -ComputerName COMPUTER01
        Starts a remote control session over COMPUTER01
    #>


    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]$ComputerName
    )

    process {
        $choices = '&Yes', '&No'
        $parse = Invoke-Command -Session $session -ScriptBlock {
            #The match should be changed depending on the computer OS language
            ($(query user /server:$env:COMPUTERNAME) -match "Active" -split '\s')
        }
        $array = @()
        foreach ($elem in $parse) {
            if ($elem -ne "") {
                $array += $elem
            }
        }
        $shadowid = $array[2]
        $user = $array[0]
        if ($null -eq $shadowid) {
            Write-Error -Message "Session ID could not be retrieved."
        }
        Write-Host "User: $user"
        Write-Host "ComputerName: $ComputerName"
        Write-Host "Shadow ID: $shadowid"
        $decision = $host.ui.PromptForChoice("", "Asks for user's consent for remote control?", $choices, 1)

        if ($decision) {
            mstsc.exe /control /shadow:$shadowid /v:$ComputerName
        }
        else {
            mstsc.exe /noconsentprompt /control /shadow:$shadowid /v:$ComputerName
        }
    }
}