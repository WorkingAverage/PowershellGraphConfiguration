function Remove-MailboxSMTPForwardAddress {
    <#
.SYNOPSIS
    Removing any SMTP Forward from one or multiple mailboxes.
.EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>
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
            $userMailbox = Get-Mailbox -Identity $mailboxIdentity
            if ($null -eq $userMailbox) {
                Write-Error "$User mailbox doesn't exist"
                return 1
            }
            Write-Host "Current user smtp foward: " -NoNewline
            Write-Host $userMailbox.ForwardingSmtpAddress -ForegroundColor Yellow
            Write-H
            Write-Host $user -ForegroundColor Red
            Write-Verbose "Removing the smtp forward address"
            $userMailbox | Set-Mailbox -ForwardingSmtpAddress $null -Confirm:$true
        }
    }

    end {
        Write-Verbose "Disconnectiong from ExchangeOnline"
        Disconnect-ExchangeOnline -Confirm:$false
    }
}