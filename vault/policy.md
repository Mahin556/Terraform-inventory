```bash
================ HASHICORP VAULT POLICIES – FULL SESSION (IN ONE BOX)
        COMMANDS + POLICY FORMAT + AUTH METHOD FLOW (DETAILED)
===================================================================

---------------- WHAT THIS SESSION COVERS ----------------
* What a Vault policy is and why it is required
* How Vault policies are written and structured
* How PATH + CAPABILITIES control access to secrets
* How to test policies by writing and reading secrets
* How policies are attached to tokens
* How policies are associated with auth methods (AppRole)

===================================================================

---------------- VAULT PATH CONCEPT ----------------
* Vault stores secrets at logical paths (similar to directories)
* Every secret lives under a path such as:
    secret/data/credits
    secret/data/foo

* Policies DO NOT store secrets
* Policies only decide:
  - WHICH path can be accessed
  - WHAT operations are allowed on that path

* Common capabilities:
  create  → create a new secret
  read    → read an existing secret
  update  → modify an existing secret
  delete  → delete a secret
  list    → list secrets under a path

===================================================================

---------------- POLICY FILE FORMAT ----------------
* Vault policies are written in HCL format
* File extension should be `.hcl` (recommended by HashiCorp)
* One policy can define rules for MULTIPLE paths
* Same policy can be reused for many users, tokens, or auth methods

Example: my-policy.hcl

path "secret/data/*" {
  capabilities = ["create", "update"]
}

path "secret/data/foo" {
  capabilities = ["read"]
}

Meaning:
* Any path under secret/data/*:
  - Secrets can be created or updated
* Path secret/data/foo:
  - Secrets can ONLY be read
  - Write/update/delete are NOT allowed

===================================================================

---------------- POLICY CLI COMMANDS ----------------

1) List all existing policies
* Shows policy names only (not contents)

vault policy list

---------------------------------------------------

2) Write a policy (inline, without a file)
* Creates or updates the policy in Vault

vault policy write my-policy - <<EOF
path "secret/data/*" {
  capabilities = ["create", "update"]
}

path "secret/data/foo" {
  capabilities = ["read"]
}
EOF

---------------------------------------------------

3) Read policy content
* Displays the exact rules inside the policy

vault policy read my-policy

---------------------------------------------------

4) Delete a policy
* Removes policy completely from Vault

vault policy delete my-policy

===================================================================

---------------- ATTACH POLICY TO TOKEN ----------------
* Tokens are how users/apps authenticate to Vault
* Policies define what that token is allowed to do

* Create a token and attach policy
* Export it so Vault CLI uses it automatically

export VAULT_TOKEN="$(vault token create -field token -policy=my-policy)"

===================================================================

---------------- TEST POLICY (VERIFY ACCESS CONTROL) ----------------

Allowed operation:
* Path matches secret/data/*
* create/update is allowed

vault kv put secret/credits username=admin password=123

---------------------------------------------------

Denied operation:
* Path secret/data/foo allows only READ
* Write attempt is blocked

vault kv put secret/foo key=value
→ permission denied (EXPECTED BEHAVIOR)

===================================================================

---------------- AUTH METHODS ----------------
* Auth methods define HOW users/apps authenticate to Vault
* Examples:
  - AppRole (machines, CI/CD, Terraform)
  - GitHub (users)
  - AWS
  - Kubernetes

* Policies are NOT authentication
* Auth methods issue tokens WITH policies attached

List enabled auth methods:
vault auth list

Enable AppRole authentication:
vault auth enable approle

===================================================================

---------------- ASSOCIATE POLICY WITH APPROLE ----------------
* AppRole is designed for machine-to-machine authentication
* Policy is attached at role level
* Tokens created via this role inherit the policy

vault write auth/approle/role/my-role \
  secret_id_ttl=10m \
  secret_id_num_uses=40 \
  token_num_uses=10 \
  token_ttl=20m \
  token_max_ttl=30m \
  token_policies=my-policy

Explanation:
* secret_id_ttl        → validity of secret_id
* secret_id_num_uses  → how many times it can be used
* token_ttl           → token lifetime
* token_max_ttl       → max renewable lifetime
* token_policies      → policies applied to token

===================================================================

---------------- GENERATE ROLE ID ----------------
* Role ID = username equivalent

export ROLE_ID="$(vault read -field=role_id auth/approle/role/my-role/role-id)"

---------------- GENERATE SECRET ID ----------------
* Secret ID = password equivalent

export SECRET_ID="$(vault write -f -field=secret_id auth/approle/role/my-role/secret-id)"

===================================================================

---------------- APPROLE LOGIN (TEST AUTHENTICATION) ----------------
* Role ID + Secret ID → Vault token
* Token has permissions defined by policy

vault write auth/approle/login \
  role_id=$ROLE_ID \
  secret_id=$SECRET_ID

===================================================================

---------------- KEY TAKEAWAYS ----------------
* Policies control WHAT can be done
* Auth methods control HOW you log in
* Tokens carry policies
* AppRole is best for automation and CI/CD
* Always follow least privilege principle

===================================================================
```