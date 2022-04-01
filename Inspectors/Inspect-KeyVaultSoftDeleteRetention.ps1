function Inspect-KeyVaultSoftDeleteRetention {
    Try {
        $results = @()
        
        $keyVaults = Get-AzKeyVault -WarningAction SilentlyContinue

        Foreach ($vault in $keyVaults){
            $vault = Get-AzKeyVault -VaultName $vault.VaultName -WarningAction SilentlyContinue
            If (($vault.EnableSoftDelete -eq $true) -and ($vault.SoftDeleteRetentionInDays -lt 90)){
                $result = New-Object psobject
                $result | Add-Member -MemberType NoteProperty -name 'Vault' -Value $vault.VaultName -ErrorAction SilentlyContinue
                $result | Add-Member -MemberType NoteProperty -name 'Location' -Value $vault.Location -ErrorAction SilentlyContinue
                $result | Add-Member -MemberType NoteProperty -name 'SoftDeleteRetentionInDays' -Value $vault.SoftDeleteRetentionInDays -ErrorAction SilentlyContinue

                $results += $result
            }
        }

            
        If ($results.Count -NE 0) {
            $findings = @()
            foreach ($x in $results){
                $findings += "Cluster Name: $($x.Vault), Location: $($x.Location), Soft Delete Retention Period: $($x.SoftDeleteRetentionInDays)"
            }
            return $findings
        }
        
        return $null
    }
    Catch {
        Write-Warning "Error message: $_"
    
        $message = $_.ToString()
        $exception = $_.Exception
        $strace = $_.ScriptStackTrace
        $failingline = $_.InvocationInfo.Line
        $positionmsg = $_.InvocationInfo.PositionMessage
        $pscommandpath = $_.InvocationInfo.PSCommandPath
        $failinglinenumber = $_.InvocationInfo.ScriptLineNumber
        $scriptname = $_.InvocationInfo.ScriptName
        Write-Verbose "Write to log"
        Write-ErrorLog -message $message -exception $exception -scriptname $scriptname -failinglinenumber $failinglinenumber -failingline $failingline -pscommandpath $pscommandpath -positionmsg $pscommandpath -stacktrace $strace
        Write-Verbose "Errors written to log"
    }
}

return Inspect-KeyVaultSoftDeleteRetention