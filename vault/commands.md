```bash
* There is no `terraform vault` command
* Vault is a separate tool from Terraform
* Terraform integrates with Vault using the Vault provider
* Vault itself is managed using the `vault` CLI

------------------------------------------------------------

* Check Vault version
  * vault version

* Check Vault server status
  * vault status

* Set Vault address
  * export VAULT_ADDR=http://127.0.0.1:8200

* Set Vault token
  * export VAULT_TOKEN=<token>

------------------------------------------------------------

* Initialize Vault (only once)
  * vault operator init

* Unseal Vault
  * vault operator unseal

* Seal Vault
  * vault operator seal

* Re-key Vault
  * vault operator rekey

------------------------------------------------------------

* Login using token
  * vault login <token>

* Login using method (example: GitHub)
  * vault login -method=github

------------------------------------------------------------

* Enable a secrets engine
  * vault secrets enable <engine>
  * vault secret enable -path=aws aws

* Disable a secrets engine
  * vault secrets disable <path> 
  * vault secrets disable aws 

* List enabled secrets engines
  * vault secrets list

* Tune secrets engine
  * vault secrets tune <path>

------------------------------------------------------------

* Write a secret
  * vault kv put secret/app username=admin password=123

* Read a secret
  * vault kv get secret/app

* Read secret (JSON output)
  * vault kv get -format=json secret/app

* Update secret
  * vault kv put secret/app password=456

* Delete secret (KV v2 – soft delete)
  * vault kv delete secret/app

* Destroy secret (KV v2 – permanent)
  * vault kv destroy secret/app

* List secrets
  * vault kv list secret/

------------------------------------------------------------

* Enable auth method
  * vault auth enable <method>

* Disable auth method
  * vault auth disable <path>

* List auth methods
  * vault auth list

------------------------------------------------------------

* Create policy
  * vault policy write mypolicy mypolicy.hcl

* Read policy
  * vault policy read mypolicy

* List policies
  * vault policy list

* Delete policy
  * vault policy delete mypolicy

------------------------------------------------------------

* Create token
  * vault token create

* Create token with policy
  * vault token create -policy=mypolicy

* Lookup token
  * vault token lookup

* Revoke token
  * vault token revoke <token>

------------------------------------------------------------

* Enable Kubernetes auth
  * vault auth enable kubernetes

* Enable AWS auth
  * vault auth enable aws

* Enable AppRole auth
  * vault auth enable approle

------------------------------------------------------------

* Create AppRole
  * vault write auth/approle/role/myrole token_policies=mypolicy

* Get AppRole role-id
  * vault read auth/approle/role/myrole/role-id

* Generate AppRole secret-id
  * vault write -f auth/approle/role/myrole/secret-id

------------------------------------------------------------

* Enable audit logging
  * vault audit enable file file_path=/var/log/vault_audit.log

* Disable audit logging
  * vault audit disable file

* List audit devices
  * vault audit list

------------------------------------------------------------

* Take snapshot (Enterprise / Raft)
  * vault operator raft snapshot save backup.snap

* Restore snapshot
  * vault operator raft snapshot restore backup.snap

------------------------------------------------------------

* Common Terraform + Vault usage notes
  * Terraform uses the vault provider
  * Terraform reads secrets using data "vault_kv_secret_v2"
  * Terraform still stores values in tfstate
  * Vault authentication happens before Terraform runs
```