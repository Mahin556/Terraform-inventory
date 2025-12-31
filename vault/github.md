```bash
================ HASHICORP VAULT TOKEN & GITHUB AUTH (IN ONE BOX)
        TOKEN AUTHENTICATION + GITHUB AUTH FLOW (DETAILED)
===================================================================

---------------- WHAT THIS SESSION COVERS ----------------
* What Vault tokens are
* Why token authentication is required
* How to create, login, and revoke tokens
* How GitHub authentication works in Vault
* How GitHub orgs and teams map to Vault policies
* How to enable, use, and disable GitHub auth

===================================================================

---------------- TOKEN AUTHENTICATION (CORE CONCEPT) ----------------
* Vault does NOT use username/password
* Vault uses TOKENS for authentication
* Every request to Vault must include a valid token
* Root token has FULL access (admin-level)

===================================================================

---------------- CREATE TOKEN ----------------
* Generates a new token
* Token can be root or policy-based

vault token create

* Output includes:
  - token value
  - token policies
  - TTL

===================================================================

---------------- VAULT LOGIN USING TOKEN ----------------
* Authenticates CLI with Vault using token

vault login

* Paste token when prompted
* Successful login means:
  - Vault trusts the token
  - You can now access Vault APIs

===================================================================

---------------- REVOKE TOKEN ----------------
* Immediately invalidates token
* Token cannot be used again

vault token revoke YOUR_TOKEN_STRING

* Any login using revoked token will FAIL

===================================================================

---------------- AUTH METHODS ----------------
* Auth methods define HOW tokens are issued
* Examples:
  - token (default)
  - GitHub
  - AWS
  - Kubernetes
  - AppRole

List enabled auth methods:
vault auth list

===================================================================

---------------- ENABLE GITHUB AUTH ----------------
* Allows users to login using GitHub accounts

vault auth enable github

===================================================================

---------------- GITHUB AUTH – PREREQUISITES ----------------
* GitHub account required
* GitHub Organization must exist
* GitHub Team must exist inside organization
* User must be part of that team

===================================================================

---------------- CONFIGURE GITHUB ORGANIZATION ----------------
* Org name must MATCH GitHub org name exactly

vault write auth/github/config organization=jhooq-test-org-2

===================================================================

---------------- MAP GITHUB TEAM TO VAULT POLICIES ----------------
* Team members get policies automatically after login

vault write auth/github/map/teams/my-teams value=default,application

Meaning:
* Members of "my-teams" GitHub team get:
  - default policy
  - application policy

===================================================================

---------------- LOGIN USING GITHUB AUTH ----------------
* Uses GitHub Personal Access Token (PAT)

vault login -method=github

* Paste GitHub PAT when prompted
* Vault validates:
  - GitHub user
  - Organization membership
  - Team membership
* Vault issues a Vault token with mapped policies

===================================================================

---------------- REVOKE GITHUB AUTH TOKENS ----------------
* Revokes all tokens issued via GitHub auth

vault token revoke -mode path auth/github

===================================================================

---------------- DISABLE GITHUB AUTH METHOD ----------------
* Completely removes GitHub authentication

vault auth disable github

===================================================================

---------------- KEY TAKEAWAYS ----------------
* Token is mandatory to access Vault
* Root token = full control (use carefully)
* Tokens can be created, revoked, and expired
* GitHub auth enables SSO-style login
* Policies are attached via GitHub teams
* Authentication (auth method) ≠ Authorization (policy)

===================================================================
```