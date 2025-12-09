function Remove-MailboxSMTPForwardAddress {
    <#
.SYNOPSIS
    Removing any SMTP Forward from one or multiple mailboxes.
#>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory = $true)][String[]]$User
    )

    begin {
        try {
            Import-Module ExchangeOnlineManagement
            Connect-ExchangeOnline -ShowBanner:$false
        }
        catch {
            Write-Error $_
        }
    }

    process {
        foreach ($mailboxIdentity in $user) {
            $userMailbox = Get-Mailbox -Identity $mailboxIdentity
            if ($null -eq $userMailbox) {
                Write-Error "$mailboxIdentity mailbox doesn't exist"
            }
            Write-Host "$mailboxIdentity -> " -NoNewline
            Write-Host $userMailbox.ForwardingSmtpAddress -ForegroundColor Yellow
            Write-Host $userMailbox -ForegroundColor Red
            $userMailbox | Set-Mailbox -ForwardingSmtpAddress $Null -WhatIf:$WhatIfPreference
        }
    }

    end {
        Write-Verbose "Disconnectiong from ExchangeOnline"
        Disconnect-ExchangeOnline -WhatIf:$WhatIfPreference
    }
}