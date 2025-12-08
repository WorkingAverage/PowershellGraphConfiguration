function Get-PrinterCountMeters {
    [CmdletBinding()]
    param (
        [Parameter()][PSCustomObject]$PrinterName
    )

    ##TODO: TRANSFORM THIS INTO A VALIDATE SET ARGUMENT INSTEAD
    $printers = @(
        [PSCustomObject]@{Name = "PRINTER"; Description = "DESCRIPTION1"; Color = 1 },
        [PSCustomObject]@{Name = "PRINTER"; Description = "DESCRIPTION1"; Color = 1 },
        [PSCustomObject]@{Name = "PRINTER2"; Description = "DESCRIPTION1"; Color = 0 }
    )
    if ($null -ne $printerName) {
        $printers = $printers -match $printername
    }

    $oids_black = @(
        "1.3.6.1.4.1.18334.1.1.1.5.7.2.2.1.5.1.1",
        "1.3.6.1.4.1.18334.1.1.1.5.7.2.2.1.5.1.2"
    )

    $oids_color = @(
        "1.3.6.1.4.1.18334.1.1.1.5.7.2.2.1.5.2.1",
        "1.3.6.1.4.1.18334.1.1.1.5.7.2.2.1.5.2.2"
    )

    function Get-SNMPOid($var) {
        Write-Verbose -Message "$($var[0])"
        $snmp = New-Object -ComObject olePrn.OleSNMP
        $snmp.open($var[0], 'public', 2, 1000)
        $res = $snmp.get(".$($var[1])")
        Write-Verbose $res
        $snmp.close()
        return $res
    }
    $black_count = 0;
    $color_count = 0;
    $res = @()
    foreach ($printer in $printers) {
        if (-not (Test-Connection -ComputerName $printer.name -Count 1 -Quiet)) {
            break
        }
        Write-Verbose "[$($printer.name)]"
        foreach ($oid in $oids_black) {
            Write-Verbose "Calling oid : $oid"
            $black_count += [int](Get-SNMPOid($printer.name, $oid))
        }
        if ($printer.Color) {
            foreach ($oid in $oids_color) {
                Write-Verbose "Calling oid : $oid"
                $color_count += [int](Get-SNMPOid($printer.name, $oid))
            }
        }
        $res += [PSCustomObject]@{
            Name        = $printer.name
            Description = $printer.description
            BlackCount  = $black_count
            ColorCount  = $color_count
        }
    }
    return $res
}