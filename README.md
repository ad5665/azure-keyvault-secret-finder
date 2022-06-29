# azure keyvault secret finder
Loops through all subscriptions and keyvaults to help speed up locating a certain key

Vaules are not saved locally, so when running the get parameter, `az keyvault secret show` is ran to fetch the vaule. 


## Usage
```powershell
.\find-key.ps1 -c ## Creates/Updates cache.csv 

.\find-key.ps1 -s "my secret" ## Uses the cache file to quickly find any secrets with this vaule

.\find-key.ps1 -s "uk-*-secret" ## Wildcards can be used 

.\find-key.ps1 -g "my secret" ## Retrieves the secret value 
```


## Examples
```powershell
\find-key.ps1 -s sql

name                                          resourceGroup   sub         vaultName
----                                          -------------   ---         ---------
dev-sql-server-admin-credentials-password     dev-platform    Dev/Test    dev-vault
tst-sql-server-admin-credentials-password     tst-platform    Dev/Test    tst-vault

\find-key.ps1 -g dev-sql-server-admin-credentials-password

{
  "attributes": {
    "created": "2022-01-01T09:49:57+00:00",
    "enabled": true,
    "expires": null,
    "notBefore": null,
    "recoveryLevel": "Purgeable",
    "updated": "2022-01-01T09:49:57+00:00"
  },
  "contentType": null,
  "id": "https://dev-vault.vault.azure.net/secrets/dev-sql-server-admin-credentials-password/###########################",
  "kid": null,
  "managed": null,
  "name": "dev-sql-server-admin-credentials-password",
  "tags": null,
  "value": "TotalyNotPassword123"
}

.\find-key.ps1 -g "dev-sql-server-admin-credentials-pa$$word"
Please check provided string matches the keypair naming
```