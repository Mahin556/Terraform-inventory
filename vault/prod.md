```bash
================ HASHICORP VAULT – PRODUCTION DEPLOYMENT (VERY DETAILED)
      RAFT STORAGE • INIT • UNSEAL • UI • REST API • BTS
=============================================================================

---------------- 1️⃣ WHY DEV MODE IS NOT PRODUCTION-READY ----------------
Command used in dev:
  vault server -dev

Behavior in dev mode:
* Secrets stored in RAM only
* Auto-unsealed
* Auto root token generated
* Data is LOST on restart

Behind the scenes:
* Encryption keys live in memory
* No persistence layer
* No HA support
* No real security boundaries

Conclusion:
DEV mode = learning/testing only, NEVER production

----------------------------------------------------------------------------

---------------- 2️⃣ STOPPING DEV MODE SAFELY ----------------
Stop server:
  Ctrl + C

Verify:
  vault status

Expected output:
  connection refused

Meaning:
* Vault process stopped
* No listener running
* Safe to move to production mode

----------------------------------------------------------------------------

---------------- 3️⃣ WHY WE UNSET VAULT_TOKEN ----------------
Command:
  unset VAULT_TOKEN

Behind the scenes:
* Dev mode auto-exports a root token
* If not removed:
  - CLI may think it’s authenticated
  - Causes confusion during prod init
* Production Vault must generate:
  - New root token
  - New unseal keys

Rule:
ALWAYS clear dev credentials before prod

----------------------------------------------------------------------------

---------------- 4️⃣ PRODUCTION VAULT CONFIG (config.hcl) ----------------
Complete single-node Raft config:

storage "raft" {
  path    = "./vault/data"
  node_id = "node1"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"
}

api_addr     = "http://127.0.0.1:8200"
cluster_addr = "http://127.0.0.1:8201"
ui           = true

----------------------------------------------------------------------------

---------------- 🔍 CONFIG FIELD BREAKDOWN ----------------

storage "raft":
* Built-in persistent storage
* No external DB required
* Supports replication, HA, snapshots

path = "./vault/data"
* Disk location for encrypted data

node_id = "node1"
* Unique Raft cluster member ID

listener "tcp":
address = "0.0.0.0:8200"
* 127.0.0.1 → local only
* 0.0.0.0 → browser, Terraform, remote access

tls_disable = "true"
* HTTP only (demo/lab)
* REAL PROD → TLS MUST be enabled

api_addr:
* Used internally by Vault
* Used by CLI, REST API, cluster nodes

cluster_addr:
* Used for Raft replication
* Leader election
* Mandatory even for single node

ui = true:
* Enables Web UI
* UI uses REST API internally
* Same permissions as CLI

----------------------------------------------------------------------------

---------------- 5️⃣ CREATE STORAGE DIRECTORIES ----------------
Command:
  mkdir -p ./vault/data

Why:
* Vault does NOT create storage paths
* Missing directory = startup failure

----------------------------------------------------------------------------

---------------- 6️⃣ START VAULT IN PRODUCTION MODE ----------------
Command:
  vault server -config=config.hcl

Internals:
* Config loaded
* Listener starts on 8200
* Raft initialized
* Vault enters SEALED state

----------------------------------------------------------------------------

---------------- 7️⃣ EXPORT VAULT ADDRESS ----------------
Command:
  export VAULT_ADDR="http://127.0.0.1:8200"

Why:
* CLI communicates via REST API
* This tells CLI where Vault lives

----------------------------------------------------------------------------

---------------- 8️⃣ INITIALIZE VAULT (CRITICAL STEP) ----------------
Command:
  vault operator init

Internals:
* Master encryption key generated
* Key split using Shamir’s Secret Sharing
* Encrypted data key stored in Raft

Output:
* 5 Unseal Keys
* 1 Root Token

Example:
Unseal Key 1: xxxx
Unseal Key 2: xxxx
Unseal Key 3: xxxx
Unseal Key 4: xxxx
Unseal Key 5: xxxx
Initial Root Token: hvs.xxxxx

Important:
* Losing unseal keys = data locked forever
* Root token = superuser access

----------------------------------------------------------------------------

---------------- 9️⃣ SEALED STATE (BTS) ----------------
When Vault is sealed:
* Data is encrypted
* Encryption key is split
* Vault refuses:
  - Read
  - Write
  - Authentication

Analogy:
“Vault is running, but the safe is locked”

----------------------------------------------------------------------------

---------------- 🔟 UNSEALING VAULT ----------------

CLI method:
  vault operator unseal
* Enter 3 different unseal keys
* Default threshold = 3 of 5

UI method (recommended for learning):
1) Open:
   http://<PUBLIC_IP>:8200/ui
2) Enter 3 unseal keys
3) Login using root token

Internals:
* Encryption key reconstructed
* Raft data unlocked
* Vault becomes ACTIVE

----------------------------------------------------------------------------

---------------- 1️⃣1️⃣ ACCESSING VAULT UI ----------------
URL:
  http://<PUBLIC_IP>:8200/ui

You can now:
* Enable secret engines
* Create policies
* Configure auth methods
* Monitor Vault health

Note:
UI is NOT a separate service
UI = REST API client

----------------------------------------------------------------------------

---------------- 1️⃣2️⃣ REST API ACCESS ----------------
Example:
  curl http://127.0.0.1:8200/v1/sys/health

Response:
  initialized: true
  sealed: false

Why REST matters:
* Terraform uses REST
* Vault Agent uses REST
* Kubernetes auth uses REST

----------------------------------------------------------------------------

---------------- 1️⃣3️⃣ DEV vs PROD COMPARISON ----------------

Feature        | Dev Mode | Prod Mode
-------------- | -------- | ----------
Storage        | Memory   | Disk (Raft)
Initialization | Auto     | Manual
Unseal         | Auto     | Manual
Root Token     | Auto     | Generated
HA             | ❌       | ✅
Security       | ❌       | ✅

----------------------------------------------------------------------------

---------------- 1️⃣4️⃣ WHAT COMES NEXT (REAL PROJECTS) ----------------
* Enable AWS secrets engine
* Generate dynamic AWS credentials
* Use AppRole / Kubernetes auth
* Integrate Terraform with Vault
* Multi-node Raft HA setup

----------------------------------------------------------------------------

---------------- INTERVIEW ONE-LINER ----------------
“In production, Vault runs with persistent Raft storage, requires manual
initialization and unsealing, and exposes secure APIs and UI for managing secrets.”

=============================================================================
```