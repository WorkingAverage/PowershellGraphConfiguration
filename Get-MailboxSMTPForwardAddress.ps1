function Get-MailboxSMTPForwardAddress {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][String]$User
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
            $userMailbox = Get-Mailbox -Identity $User
            if ($null -eq $userMailbox) {
                Write-Error "$User mailbox doesn't exist"
                return 1
            }
            Write-Host "Current user smtp forward: " -NoNewline
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
        Write-Verbose "Disconnectiong from ExchangeOnline"
        Disconnect-ExchangeOnline -Confirm:$false | Out-Null
    }
}