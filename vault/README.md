Use this master template to deploy. Customization may be needed
https://fwd.aws/RMmpW
setup on aws doc: https://aws-quickstart.s3.amazonaws.com/quickstart-hashicorp-vault/doc/hashicorp-vault-on-the-aws-cloud.pdf


### Vault and Consul
Vault vs. Consul

Consul is a system for service discovery, monitoring, and configuration that is distributed and highly available. Consul also supports an ACL system to restrict access to keys and service information.

While Consul can be used to store secret information and gate access using ACLs, it is not designed for that purpose. As such, data is not encrypted in transit nor at rest, it does not have pluggable authentication mechanisms, and there is no per-request auditing mechanism.

Vault is designed from the ground up as a secret management solution. As such, it protects secrets in transit and at rest. It provides multiple authentication and audit logging mechanisms. Dynamic secret generation allows Vault to avoid providing clients with root privileges to underlying systems and makes it possible to do key rolling and revocation.

The strength of Consul is that it is fault tolerant and highly scalable. By using Consul as a backend to Vault, you get the best of both. Consul is used for durable storage of encrypted data at rest and provides coordination so that Vault can be highly available and fault tolerant. Vault provides the higher level policy management, secret leasing, audit logging, and automatic revocation.

Architecture:
2 Vault servers (considered to be consul client) and a Cluster of 3 spot Consul servers where the encrypted data will be stored on disk.

When running in HA mode, Vault servers have two additional states: standby and active. Within a Vault cluster, only a single instance will be active and handles all requests (reads and writes) and all standby nodes redirect requests to the active node.

When unsealing the 2nd vault it goes to standby mode and i cant do authenticating with it. When sealing the first vault the second one goes to active mode seamlessly

Get Consul leaders

```bash
consul members
consul operator raft list-peers
```

Start with `vault init` to get the key shards and root token

Unseal Key 1: blabla-blabla-blabla-blabla-blabla
Unseal Key 2: blabla-blabla-blabla-blabla-blabla
Unseal Key 3: blabla-blabla-blabla-blabla-blabla
Unseal Key 4: blabla-blabla-blabla-blabla-blabla
Unseal Key 5: blabla-blabla-blabla-blabla-blabla

Initial Root Token: blabla-blab-blablabla-blablabla-bal


*we need this for some reason*
export VAULT_ADDR='http://127.0.0.1:8201'

vault operator unseal;vault operator unseal;vault operator unseal;

check vault status: `vault status`
check port running on vault:
```bash
netstat -apn | grep 8201
netstat -apn | grep 820
```
to be able to run commands from the backend use the root token or a user token: `export VAULT_TOKEN=dsqdsqdds-dsqd-dssq-dsqdq-sqdsqsqdqsdqs`

Generating new root token needs 3 keys shards: check [here](https://www.vaultproject.io/docs/concepts/tokens.html)

## manipulating secrets

Read write secrets (v1)*

```bash
vault kv put secret/psy content=hellovault
vault kv get  secret/psy
```
load a secret from a file:
```bash
vi test
cat test | vault kv put secret/cert1 content=-
vault read  secret/cert1
```

[other ways to load data here](https://www.vaultproject.io/docs/commands/index.html)

Get data in jason format: `vault kv get -format=json secret/psy | jq -r .data'`


Listing secrets: `vault list secret`

Deleting secrets: `vault kv delete secret/password` or `vault kv delete secret/cert-test`
-> `Success! Data deleted (if it existed) at: secret/password`

Enable a Secrets Engine

```bash
# vault secrets enable -path=psy kv
Success! Enabled the kv secrets engine at: psy/
#  vault kv put psy/lolz content=knowpain
Success! Data written to: psy/lolz
# vault kv get -format=json psy/lolz
{
  "request_id": "081d1265-a64b-bcdd-ac69-c2bb6ff01cdf",
  "lease_id": "",
  "lease_duration": 2764800,
  "renewable": false,
  "data": {
    "content": "knowpain"
  },
  "warnings": null
}
# vault list psy
Keys
----
lolz
```

List all secret engines:

```bash
# vault secrets list
Path          Type         Accessor              Description
----          ----         --------              -----------
cubbyhole/    cubbyhole    cubbyhole_61a72cef    per-token private secret storage
identity/     identity     identity_2a564de9     identity store
psy/          kv           kv_60bab74c           n/a
secret/       kv           kv_36c9617a           key/value secret storage
sys/          system       system_03c3cac9       system endpoints used for control, policy and debugging
```

Disable a secret engine: `vault secrets disable psy`

## Vault 0.10 introduced K/V Secrets Engine v2 with Secret Versioning.

basically you can add version and delete them, after deletion you still can restore them

Enable versioning: `$ vault kv enable-versioning secret/`

To retrieve the version 1 of the secret written at secret/customer/acme: `vault kv get -version=1 secret/customer/acme`

To read the metadata of secret/customer/acme: `$ vault kv metadata get secret/customer/acme`

Specify the max number of version to keep: `$ vault write secret/config max_versions=4`

Alternatively, to limit the number of versions only on the secret/customer/acme `$ vault kv metadata put -max-versions=4 secret/customer/acme`

Let's delete versions 4 and 5: `$ vault kv delete -versions="4,5" secret/customer/acme`

To permanently delete all versions of a secret: `$ vault kv destroy -versions=4 secret/customer/acme`

Othere stuff [here](https://www.vaultproject.io/docs/secrets/kv/kv-v2.html).

#### Authenticate and delete a token:

```bash
vault login a402d075-6d59-6129-1ac7-3718796d4346
vault token revoke a402d075-6d59-6129-1ac7-3718796d4346
```

### Run vault with my specific config: `$ vault server -config=config.hcl`


All of Vault's capabilities are accessible via the HTTP API in addition to the CLI. In fact, most calls from the CLI actually invoke the HTTP API. A maximum request size of 32MB is imposed to prevent a denial of service attack with arbitrarily large requests.

## Recommendations:

* Must disable swap on vault and cosnul servers
* Don't run as root (well ...)
* Avoid Root Tokens. Vault provides a root token when it is first initialized. This token should be used to setup the system initially, particularly setting up auth methods so that users may authenticate. We recommend treating Vault configuration as code, and using version control to manage policies. Once setup, the root token should be revoked to eliminate the risk of exposure. Root tokens can be generated when needed, and should be revoked as soon as possible.
* Restrict Storage Access: Prevent data corruption
* Disable Shell Command History (or Disable all vault command history: `$ export HISTIGNORE="&:vault*"`)
* Tweak ulimits. It is possible that your Linux distribution has strict process ulimits. Consider to review ulimits for maximum amount of open files, connections, etc
* The replication model is not designed for active-active usage and enabling two primaries should never be done, as it can lead to data loss if they or their secondaries are ever reconnected.

### Enable LDAP authentication

[Auth with LDAP](https://www.vaultproject.io/docs/auth/ldap.html)

```bash
$ vault auth-enable ldap
$ vault write auth/ldap/config url="ldaps://dovahkin.skyrim.com:636,ldaps://nagatopain.skyrim.com:636" userdn="cn=users,cn=accounts,dc=skyrim,dc=com" groupdn="cn=groups,cn=accounts,dc=skyrim,dc=com" groupattr="cn" userattr="uid" insecure_tls=false starttls=true binddn="uid=vault,cn=users,cn=accounts,dc=skyrim,dc=com" bindpass='somepassword' certificate=@/etc/ssl/certs/somecertificate.crt
```
NOTE: These steps neeed to be run a one time at the first initialization of the vault to set up ldap auth.

Login with ldap user: `$ vault login -method=ldap username=nagato.pain`


### Policies
In Vault, we use policies to govern the behavior of clients and instrument Role-Based Access Control (RBAC) by specifying access privileges (authorization).

* Write ACL policies in HCL format
```
path "<PATH>" {
  capabilities = [ "<LIST_OF_CAPABILITIES>" ]
}
```
* Create policies: `$ vault policy write <POLICY_NAME> <POLICY_FILE>`
example: Create admin policy: `$ vault policy write admin admin-policy.hcl`

NOTE: To update an existing policy, simply re-run the same command by passing your modified policy (`*.hcl`).

* View existing policies: `$ vault policy list`

* To view a specific policy:`$ vault policy read <POLICY_NAME>`

* Check capabilities of a token: `$ vault token capabilities <TOKEN> <PATH>`

* Create a token attached to admin policy: `vault token create -policy="admin"`

* Delete a policy: `vault policy delete <POLICY_NAME>`

## policy creation and assignment

Create a policy: policy called secret will allow access to the secret engine called 'secret'
```bash
# vault policy write secret ops.hcl
Success! Uploaded policy: secret
```
Assigning the secret policy to the ldap group called "aps"
```bash
# vault write auth/ldap/groups/aps policies=secret
Success! Data written to: auth/ldap/groups/aps
```

List policies
```bash
# vault read sys/policy
Key         Value
---         -----
keys        [default ops secret root]
policies    [default ops secret root]
```

Check policies associated to ops and aps groups:
```bash
# vault read auth/ldap/groups/aps
Key         Value
---         -----
policies    [secret]
```

List policies associated with a group

```bash
vault read auth/ldap/groups/ops
```

Creating a full admin policy for ops:

```bash
# vault policy write admin ops.hcl
Success! Uploaded policy: admin
# vault write auth/ldap/groups/ops policies=admin
Success! Data written to: auth/ldap/groups/ops
# cat ops.hcl
path "/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
```

### Authentication (Approle) programmatic users


AppRole is an authentication mechanism within Vault to allow machines or apps to acquire a token to interact with Vault. It uses Role ID and Secret ID for login.

1- Enable AppRole auth method:

`vault auth enable approle`

2- Create a role with policy attached

Create a jenkins policy: `$ vault policy write jenkins jenkins-pol.hcl`

Create a new AppRole: `$ vault write auth/approle/role/<ROLE_NAME> [parameters]`

Example: `vault write auth/approle/role/jenkins policies="jenkins"`

3- Get Role ID and Secret ID

Role ID and Secret ID are like a username and password that a machine or app uses to authenticate. Now, you need to fetch the Role ID and Secret ID of a role.

    `$ vault read auth/approle/role/<ROLE_NAME>/role-id`

To generate a new Secret ID:

    `$ vault write -f auth/approle/role/<ROLE_NAME>/secret-id`

Example:
```
$ vault read auth/approle/role/jenkins/role-id
  Key       Value
  ---       -----
  role_id   675a50e7-cfe0-be76-e35f-49ec009731ea

$ vault write -f auth/approle/role/jenkins/secret-id
  Key                   Value
  ---                   -----
  secret_id             ed0a642f-2acf-c2da-232f-1b21300d5f29
  secret_id_accessor    a240a31f-270a-4765-64bd-94ba1f65703c
```

4- Login with Role ID & Secret ID

The client (in this case, Jenkins) uses the role ID and secret ID passed by the admin to authenticate with Vault. If Jenkins did not receive the role ID and/or secret ID `vault write auth/approle/login role_id="675a50e7-cfe0-be76-e35f-49ec009731ea" secret_id="ed0a642f-2acf-c2da-232f-1b21300d5f29"`

**Using API URL**
```bash
$ cat payload.json
  {
    "role_id": "675a50e7-cfe0-be76-e35f-49ec009731ea",
    "secret_id": "ed0a642f-2acf-c2da-232f-1b21300d5f29"
  }


$ curl -s --request POST --data @payload.json http://127.0.0.1:8200/v1/auth/approle/login | jq
{
  "request_id": "fccae32b-1e6a-9a9c-7666-f5cb07805c1e",
  "lease_id": "",
  "renewable": false,
  "lease_duration": 0,
  "data": null,
  "wrap_info": null,
  "warnings": null,
  "auth": {
    "client_token": "3e7dd0ac-8b3e-8f88-bb37-a2890455ca6e",
    "accessor": "375c077e-bf02-a09b-c864-63d7f967e86b",
    "policies": [
      "default",
      "jenkins"
    ],
    "metadata": {
      "role_name": "jenkins"
    },
    "lease_duration": 2764800,
    "renewable": true,
    "entity_id": "54e0b765-6daf-0ff5-70b9-32c0d491f473"
  }
}
```
-->

```bash
# curl --request POST -s --data @payload.json http://127.0.0.1:8201/v1/auth/approle/login | jq ".auth.client_token"
"e31c620c-3c8c-eb26-e8f1-42e864d0cc8d"
# curl --request POST -s --data @payload.json http://127.0.0.1:8201/v1/auth/approle/login | jq -r ".auth.client_token"
59e829a2-984e-3481-51e5-9cc8e078851d
```

Now you have a client token with default and jenkins policies attached.

5- Read secrets using the AppRole token:

    `vault login 3e7dd0ac-8b3e-8f88-bb37-a2890455ca6e`
    `vault kv get secret/mysql/webapp`

Delete approle:
```bash
# vault delete auth/approle/role/wfm-ap-data0
Success! Data deleted (if it existed) at: auth/approle/role/wfm-ap-data0
```

We can create an approle and restrict the use of the token to given ips thus we bypass the ned for a secret id
`# vault write auth/approle/role/wfm-prodd policies="sharedprod, wfmprod" token_ttl=10m bind_secret_id=false token_max_ttl=15m secret_id_bound_cidrs="10.20.20.20/32"``


If for some reason one time you use http API to add certs it must be JSON-formatted, with newlines replaced with \n,

use `echo -e` to make sure certificates are formatted correctly:
```bash
echo -e `curl -s --header "X-Vault-Token: $VAULT_TOKEN" http://127.0.0.1:8201/v1/secret/cert-test | jq '.data.content'`
echo -e `curl -s --header "X-Vault-Token: $VAULT_TOKEN" https://127.0.0.1:8201/v1/secret/cert-test2 | jq -r '.data.content'`
```

### Enabling audit trail:

```bash
   vault audit enable file file_path=/var/log/vault_audit.log
```

### Snapshot script
Can be used for backups/restore of consul snapshots:

```bash
#!/bin/bash

# log function
log () {
  echo `date +"[%F %T]"` $1
}

# usage function
usage () {
  echo "Usage:"
  echo "    Backup:   $0 --backup"
  echo "    Restore:  $0 --restore <snapshot_s3_object_key>"
  echo
}

S3_PREFIX=s3://vault-bucket-name/backups/
OBJ_NAME_REGEX=^consul-backup-[0-9]{14}\.snap\.tar$


##########
# backup #
##########
if [[ "$1" = "--backup" ]]; then

  # exit if the current node is not the cluster leader (backup may not be reliable)
  if [[ ! $(consul operator raft list-peers | grep leader | grep $(hostname -I)) ]]; then
    echo "[INFO] This node is not the cluster leader. No backup will be created."
    exit 0
  fi;

  SNAP_NAME=consul-backup-`date +%Y%m%d%H%M%S`.snap
  TAR_PATH=$SNAP_NAME.tar

echo $SNAP_NAME

  log "[INFO] Backup started"
  log "[INFO] Creating consul snapshot..."
  consul snapshot save $SNAP_NAME 2>&1
  if [[ "$?" -ne "0" ]]; then
    log "[ERROR] could not backup keys: 'consul snapshot save' failed. Exiting."
    exit 1
  fi

  log "[INFO] Creating snapshot archive..."
  tar -cvf $TAR_PATH $SNAP_NAME 2>&1
  if [[ "$?" -ne "0" ]]; then
    log "[ERROR] Could not create tar file. Exiting."
    exit 1
  fi

  log "[INFO] Uploading archive file to S3..."
  aws s3 cp $TAR_PATH $S3_PREFIX 2>&1
  if [[ "$?" -ne "0" ]]; then
    log "[ERROR] Could not archive backup archive to S3. Exiting."
    exit 1
  fi


###########
# restore #
###########
elif [[ "$1" = "--restore" ]]; then

  if [[ -z "$2" ]]; then
    usage
    exit 1
  fi;

  if [[ ! "$2" =~ $OBJ_NAME_REGEX ]]; then
    echo "[ERROR] Invalid archive name format."
    exit 1
  fi;

  DOWNLOAD_PATH="./$2"
  echo "[INFO] Donwloading snapshot from S3: $S3_PREFIX$2 to $DOWNLOAD_PATH ..."
  aws s3 cp $S3_PREFIX$2 $DOWNLOAD_PATH 2>&1

  if [[ "$?" -ne "0" ]]; then
    echo "[ERROR] Could not download snapshot from S3"
    exit 1
  fi;

  # extract snapshot
  tar -xvf $DOWNLOAD_PATH 2>&1
  if [[ "$?" -ne "0" ]]; then
    echo "[ERROR] Could not extract snapshot archive."
    exit 1
  fi;

  extracted_file=`echo $2 | sed -e 's/\.tar//g'`

  echo "[INFO] Restoring secrets from snapshot..."
  consul snapshot restore $extracted_file 2>&1
  if [[ "$?" -ne "0" ]]; then
    echo "[ERROR] Failed to load restore from snapshot."
    exit 1
  fi;


else
  # unknown operation
  usage
  exit 1

fi;

echo "[INFO] Done."
exit 0
```

