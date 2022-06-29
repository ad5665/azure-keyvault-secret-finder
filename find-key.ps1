<#
  .SYNOPSIS
  Tool for searching multiple Azure KeyVaults 

  .DESCRIPTION
  Loops through all subscriptions and keyvaults to help speed up locating a certain key
 
  .PARAMETER c
  If provided this will update the local keyvault cache, this will take several minutes and is dependant on the number of subscriptions in azure config 

  .PARAMETER s
  Searches the cache for a keypair matching the provided string

  .PARAMETER g
  Fetches the secret from keyvault, you must provide the exact name

  .INPUTS
  None. You cannot pipe objects

  .OUTPUTS
  None. does not generate any output.

  .EXAMPLE
  PS> .\find-key.ps1 -c

  .EXAMPLE
  PS> .\find-key.ps1 -c -s superDBpassword

  .EXAMPLE
  PS> .\find-key.ps1 -g superDBpassword-2020

#>

param (
    [switch]$c =$false,
    [string]$s,
    [string]$g 
)

if ($c)
{
    $subs = (az account list | ConvertFrom-Json).name

    $vaults = @()
    foreach ($sub in $subs)
    {
        $vaultsInSub = az keyvault list --subscription $sub | ConvertFrom-Json
        foreach ($vaultInSub in $vaultsInSub)
        {
            $vault = new-object PSObject
            $vault | Add-Member -Type NoteProperty -Name name -Value $vaultInSub.name
            $vault | Add-Member -Type NoteProperty -Name resourceGroup -Value $vaultInSub.resourceGroup
            $vault | Add-Member -Type NoteProperty -Name sub -Value $sub

            $vaults += $vault
        }
    }
    $secrets = @()
    foreach ($vault in $vaults)
    {
        $secretsInVault = az keyvault secret list --vault-name $vault.name --subscription $vault.sub | ConvertFrom-Json
        foreach ($secretInVault in $secretsInVault)
        {
            $secret = new-object PSObject
            $secret | Add-Member -Type NoteProperty -Name name -Value $secretInVault.name
            $secret | Add-Member -Type NoteProperty -Name resourceGroup -Value $vault.resourceGroup
            $secret | Add-Member -Type NoteProperty -Name sub -Value $vault.sub
            $secret | Add-Member -Type NoteProperty -Name vaultName -Value $vault.name

            $secrets += $secret
        }
    }

    ## export cache
    $secrets | Export-Csv -Path .\cache.csv
}

$secrets = Import-csv -Path .\cache.csv

if ($s -ne "")
{
    $secrets.Where({$_.name -like "*$s*"})
}

if ($g -ne "")
{
    $key = $secrets.Where(({$_.name -eq $g}))
    if ($key.count -lt 1)
    {
        "Please check provided string matches the keypair naming"
    }
    else 
    {
        foreach ($k in $key)
        {
            az keyvault secret show --name $k.name --vault-name $k.vaultName --subscription $k.sub
        }
        
    }  
}