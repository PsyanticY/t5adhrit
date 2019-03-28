# Allow Vault to Grant cross-Account access to users.

Note: All steps are taken from [here](https://www.vaultproject.io/docs/secrets/aws/index.html)

## Initial setup:

1- Enable aws secret engine
```bash 
vault secrets enable -path aws-access aws
```

2- Configure the credentials that Vault uses to communicate with AWS to generate the IAM credentials: (use access keys or an IAM role)

```bash
vault write aws-access/config/root \
    access_key=dovahassassin \
    secret_key=dovahassassinkingreedmilimnava \
    region=us-east-1
```

Or use the IAM role recommanded by Hashicorp

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:AttachUserPolicy",
        "iam:CreateAccessKey",
        "iam:CreateUser",
        "iam:DeleteAccessKey",
        "iam:DeleteUser",
        "iam:DeleteUserPolicy",
        "iam:DetachUserPolicy",
        "iam:ListAccessKeys",
        "iam:ListAttachedUserPolicies",
        "iam:ListGroupsForUser",
        "iam:ListUserPolicies",
        "iam:PutUserPolicy",
        "iam:RemoveUserFromGroup"
      ],
      "Resource": [
        "arn:aws:iam::ACCOUNT-ID-WITHOUT-HYPHENS:user/vault-*"
      ]
    }
  ]
}
```

For only using the assume role feature we can just use this: 
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "*"
    }
  ]
}
```

here we can also just use the role we want to assumes as resources
`"*"` => `"arn:aws:iam::ACCOUNT-ID-WITHOUT-HYPHENS:role/RoleNameToAssume"`

3- Create a "deploy" policy using the arn of our role to assume:

```bash
vault write aws-access/roles/deploy \
    role_arns=arn:aws:iam::ACCOUNT-ID-WITHOUT-HYPHENS:role/RoleNameToAssume \
    credential_type=assumed_role
```

4- To generate a new set of STS assumed role credentials, we again write to the role using the aws/sts endpoint:

```bash
vault write aws-access/sts/deploy ttl=60m
```

=> Create a script to manually do all the jobs which can be easely done with curl and jq commands.

5- if vault is integrated with ldap we can just create a group and grant it the ability to generate tokens like in 4