function Get-MailboxSMTPForwardAddress {
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
                Write-Information "$mailboxIdentity mailbox doesn't exist"
            }
            Write-Host "$mailboxIdentity -> " -NoNewline
            Write-Host $(if ($null -eq $userMailbox.ForwardingSmtpAddress) {
                    "None"
                }
                else {
                    $userMailbox.ForwardingSmtpAddress
                }
            ) -ForegroundColor Yellow
        }
    }

    end {
        Write-Information "Disconnectiong from ExchangeOnline"
        Disconnect-ExchangeOnline -WhatIf:$WhatIfPreference
    }
}