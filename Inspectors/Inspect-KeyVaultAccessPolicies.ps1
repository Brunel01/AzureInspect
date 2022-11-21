
$ErrorActionPreference = "Stop"

$errorHandling = "$((Get-Item $PSScriptRoot).Parent.FullName)\Write-ErrorLog.ps1"

. $errorHandling

function Inspect-KeyVaultAccessPolicies {
    Try {
        $results = @()
        
        $keyVaults = Get-AzKeyVault -WarningAction SilentlyContinue

        Foreach ($vault in $keyVaults){
            $vault = Get-AzKeyVault -VaultName $vault.VaultName -WarningAction SilentlyContinue
            
            $displayNames = (Get-AzKeyVault -VaultName $vault.VaultName).accesspolicies.displayname 
            
            ForEach ($name in $displayNames) {
                foreach ($domain in (Get-AzDomain).Domains){
                    If ($name -match $domain){
                        $result = New-Object psobject
                        $result | Add-Member -MemberType NoteProperty -name 'User' -Value $name -ErrorAction SilentlyContinue
                        $result | Add-Member -MemberType NoteProperty -name 'Vault' -Value $vault.VaultName -ErrorAction SilentlyContinue
                        $result | Add-Member -MemberType NoteProperty -name 'Location' -Value $vault.Location -ErrorAction SilentlyContinue

                        $results += $result
                    }
                }
            }
        }

            
        If ($results.Count -NE 0) {
            $findings = @()
            foreach ($x in $results){
                $findings += "User $($x.User) holds direct assignment to Vault Name: $($x.Vault), Location: $($x.Location)"
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

return Inspect-KeyVaultAccessPolicies