### REFERENCES:
- https://developer.hashicorp.com/vault/install

---

#### Install Vault on the EC2 instance
To install Vault on the EC2 instance, you can use the following steps:
**Install gpg**
```
sudo apt update && sudo apt install gpg
```

**Download the signing key to a new keyring**
```
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

**Verify the key's fingerprint**
```
gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
```

**Add the HashiCorp repo**
```
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
```
```
sudo apt update
```

**Finally, Install Vault**
```
sudo apt install vault
```

```bash
vault version
Vault v1.21.1 (2453aac2638a6ae243341b4e0657fd8aea1cbf18), built 2025-11-18T13:04:32Z
```

## Start Vault.
To start Vault development server, you can use the following command:
```
vault server -dev -dev-listen-address="0.0.0.0:8200"
```
```bash
WARNING! dev mode is enabled! In this mode, Vault runs entirely in-memory
and starts unsealed with a single unseal key. The root token is already
authenticated to the CLI, so you can immediately begin using Vault.

You may need to set the following environment variables:

    $ export VAULT_ADDR='http://0.0.0.0:8200'

The unseal key and root token are displayed below in case you want to
seal/unseal the Vault or re-authenticate.

Unseal Key: 43DKhrC3yCopTaImRLekWpQWmytU2LfU9rUrpxupwgk=
Root Token: hvs.OsvZzRjCxuEBv8BGnaapQPMb

Development mode should NOT be used in production installations!
```
```bash
[root@slurm-master ~]# ps -ef | grep -i vault
root       38236    7356  1 14:50 pts/0    00:00:01 vault server -dev -dev-listen-address=0.0.0.0:8200
root       40196   40124  0 14:52 pts/1    00:00:00 grep --color=auto -i vault
```
```bash
[root@slurm-master ~]# vault server -dev -dev-listen-address="0.0.0.0:8200"
==> Vault server configuration:

Administrative Namespace:
             Api Address: http://0.0.0.0:8200
                     Cgo: disabled
         Cluster Address: https://0.0.0.0:8201
   Environment Variables: BASH_FUNC_which%%, DBUS_SESSION_BUS_ADDRESS, DEBUGINFOD_IMA_CERT_PATH, HISTCONTROL, HISTSIZE, HOME, HOSTNAME, LANG, LESSOPEN, LOGNAME, LS_COLORS, MAIL, MANPATH, MOTD_SHOWN, PATH, PWD, SHELL, SHLVL, SSH_CLIENT, SSH_CONNECTION, SSH_TTY, TERM, USER, XDG_DATA_DIRS, XDG_RUNTIME_DIR, XDG_SESSION_CLASS, XDG_SESSION_ID, XDG_SESSION_TYPE, _, which_declare
              Go Version: go1.25.4
              Listener 1: tcp (addr: "0.0.0.0:8200", cluster address: "0.0.0.0:8201", disable_request_limiter: "false", max_json_array_element_count: "10000", max_json_depth: "300", max_json_object_entry_count: "10000", max_json_string_value_length: "1048576", max_request_duration: "1m30s", max_request_size: "33554432", tls: "disabled")    
               Log Level:
                   Mlock: supported: true, enabled: false
           Recovery Mode: false
                 Storage: inmem
                 Version: Vault v1.21.1, built 2025-11-18T13:04:32Z
             Version Sha: 2453aac2638a6ae243341b4e0657fd8aea1cbf18

==> Vault server started! Log data will stream in below:
```

```bash
Unseal Key: KIG/DGZxHQniRbULqsdYFK4bql5bvrTztG+Bktymy0U=
Root Token: hvs.yoJt6OhKGxXVPullHFLrAII1
```
```bash
export VAULT_ADDR=""
export VAULT_TOKEN=""
```

## Configure Terraform to read the secret from Vault.
Detailed steps to enable and configure AppRole authentication in HashiCorp Vault:
1. **Enable AppRole Authentication**:
To enable the AppRole authentication method in Vault, you need to use the Vault CLI or the Vault HTTP API.
**Using Vault CLI**:
Run the following command to enable the AppRole authentication method:
```bash
vault auth enable approle
```
This command tells Vault to enable the AppRole authentication method.

2. **Create an AppRole**:
We need to create policy first,
```
vault policy write terraform - <<EOF
path "*" {
  capabilities = ["list", "read"]
}

path "secrets/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "kv/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "auth/token/create" {
capabilities = ["create", "read", "update", "list"]
}
EOF
```
Now you'll need to create an AppRole with appropriate policies and configure its authentication settings. Here are the steps to create an AppRole:

**a. Create the AppRole**:

```bash
vault write auth/approle/role/terraform \
    secret_id_ttl=10m \
    token_num_uses=10 \
    token_ttl=20m \
    token_max_ttl=30m \
    secret_id_num_uses=40 \
    token_policies=terraform
```

3. **Generate Role ID and Secret ID**:
After creating the AppRole, you need to generate a Role ID and Secret ID pair. The Role ID is a static identifier, while the Secret ID is a dynamic credential.

**a. Generate Role ID**:
You can retrieve the Role ID using the Vault CLI:
```bash
vault read auth/approle/role/terraform/role-id
```
Save the Role ID for use in your Terraform configuration.

**b. Generate Secret ID**:
To generate a Secret ID, you can use the following command:
```bash
vault write -f auth/approle/role/terraform/secret-id
   ```
This command generates a Secret ID and provides it in the response. Save the Secret ID securely, as it will be used for Terraform authentication.


---

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.27.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.6.0"
    }
  }
}

provider "aws" {
  region  = "ap-south-1"
  profile = "tf-user"
}

provider "vault" {
  address          = "http://192.168.29.173:8200"
  skip_child_token = true

  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = "4d864e62-c033-9e27-f04f-f365c3b7c209"
      secret_id = "f8bdad4b-b30e-539d-cb73-ec524897361b"
    }
  }
}

data "vault_kv_secret_v2" "example" {
  mount = "kv"
  name  = "myapp/database"
}

resource "aws_s3_bucket" "name" {
  bucket = data.vault_kv_secret_v2.example.data["username"]
}

output "name" {
  value     = data.vault_kv_secret_v2.example.data["username"]
  sensitive = true
}
```
