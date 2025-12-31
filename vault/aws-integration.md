* Think of Vault as a **secure middleman** between:
  * Your application
  * AWS IAM

* **Before anything starts**
  * AWS has:
    * IAM service
    * Permissions model
  * Vault has:
    * No access to AWS by default

* **STEP 1: Enable AWS secret engine**
  * Command:
    ```
    vault secrets enable -path=aws aws
    ```
  * BTS:
    * Vault loads AWS plugin
    * Vault now knows **how to talk to AWS APIs**
    * No credentials are created yet

* **STEP 2: Configure AWS root/admin credentials**
  * Command:
    ```
    vault write aws/config/root ...
    ```
  * BTS:
    * Vault stores AWS admin credentials securely
    * These credentials are **never given to applications**
    * Vault uses them internally to:
      * Create IAM users
      * Attach policies
      * Delete IAM users

* **STEP 3: Create a Vault role**
  * Command:
    ```
    vault write aws/roles/my-ec2-role ...
    ```
  * BTS:
    * You are NOT creating an AWS role
    * You are creating a **Vault role**
    * This role defines:
      * What AWS permissions will be given
      * How credentials will be generated
    * Vault stores the IAM policy JSON internally

* **STEP 4: Application asks for credentials**
  * Command:
    ```
    vault read aws/creds/my-ec2-role
    ```
  * BTS (this is the MOST IMPORTANT part):
    * Vault talks to AWS IAM
    * Vault creates a **new IAM user**
    * Vault attaches the EC2 policy to that user
    * Vault generates:
      * access_key
      * secret_key
    * Vault returns credentials to the caller
    * Vault records:
      * lease_id
      * expiration time (TTL)

* **STEP 5: Application uses credentials**
  * BTS:
    * App uses access_key & secret_key
    * AWS allows actions ONLY defined in the policy
    * Credentials are temporary

* **STEP 6: Lease expiration (automatic cleanup)**
  * BTS:
    * TTL expires
    * Vault automatically:
      * Deletes the IAM user
      * Revokes access key
    * No manual cleanup needed

* **STEP 7: Manual revocation (optional)**
  * Command:
    ```
    vault lease revoke <lease_id>
    ```
  * BTS:
    * Vault immediately:
      * Deletes IAM user
      * Invalidates access key
    * Credentials stop working instantly

```
================ VISUAL FLOW =================

Application
     |
     |  vault read aws/creds/my-ec2-role
     v
Vault
     |
     |  (uses stored root credentials)
     v
AWS IAM
     |
     |  create IAM user + policy
     v
Vault
     |
     |  return temporary credentials
     v
Application
```

* **WHY THIS IS SECURE**

  * No hard-coded AWS keys
  * Credentials are short-lived
  * Automatic rotation
  * Easy revocation
  * Least privilege enforced

* **WHY THIS IS BETTER THAN STATIC KEYS**
  * Static keys:
    * Long-lived
    * Hard to rotate
    * Easy to leak
  * Dynamic keys:
    * Short-lived
    * Auto-deleted
    * Vault-controlled

* **ONE-LINE INTERVIEW ANSWER**
  * “Vault generates temporary AWS IAM users on demand using stored admin credentials and revokes them automatically using leases.”

```bash
---------------- STEP 1: ENABLE AWS SECRET ENGINE ----------------

vault secrets enable -path=aws aws

---------------------------------------------------------------

---------------- STEP 2: VERIFY SECRET ENGINES ------------------

vault secrets list

---------------------------------------------------------------

---------------- STEP 3: CONFIGURE AWS ROOT / ADMIN CREDENTIALS -

vault write aws/config/root \
  access_key=YOUR_ACCESS_KEY \
  secret_key=YOUR_SECRET_KEY \
  region=eu-north-1

---------------------------------------------------------------

---------------- STEP 4: CREATE VAULT ROLE ----------------------

vault write aws/roles/my-ec2-role \
  credential_type=iam_user \
  policy_document=-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF

---------------------------------------------------------------

---------------- STEP 5: GENERATE DYNAMIC AWS CREDENTIALS -------

vault read aws/creds/my-ec2-role

---------------------------------------------------------------

---------------- STEP 6: REVOKE DYNAMIC CREDENTIALS -------------

vault lease revoke aws/creds/my-ec2-role/<LEASE_ID>

---------------------------------------------------------------

================ VAULT POLICIES ================================

---------------- POLICY: READ DYNAMIC AWS CREDS ----------------

File: aws-dynamic-read.hcl

path "aws/creds/my-ec2-role" {
  capabilities = ["read"]
}

---------------------------------------------------------------

---------------- POLICY: AWS ADMIN (ONE-TIME SETUP) -------------

File: aws-admin.hcl

path "aws/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

---------------------------------------------------------------

---------------- APPLY POLICIES --------------------------------

vault policy write aws-dynamic-read aws-dynamic-read.hcl
vault policy write aws-admin aws-admin.hcl

---------------------------------------------------------------

================ APPROLE (OPTIONAL) =============================

vault auth enable approle

vault write auth/approle/role/aws-app \
  token_policies="aws-dynamic-read" \
  token_ttl=1h \
  token_max_ttl=4h

vault read auth/approle/role/aws-app/role-id

vault write -f auth/approle/role/aws-app/secret-id

vault write auth/approle/login \
  role_id=ROLE_ID \
  secret_id=SECRET_ID

```
