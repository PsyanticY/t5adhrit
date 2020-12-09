## Vault Agent With AWS Auth And Caching


https://learn.hashicorp.com/tutorials/vault/agent-caching


```hcl
exit_after_auth = false
pid_file = "./pidfile"

auto_auth {
   method "aws" {
       mount_path = "auth/aws"
       config = {
           type = "iam"
           role = "app-role"
       }
   }

   sink "file" {
       config = {
           path = "/home/ubuntu/vault-token-via-agent"
       }
   }
}

cache {
   use_auto_auth_token = true
}

listener "tcp" {
   address = "127.0.0.1:8200"
   tls_disable = true
}

vault {
   address = "http://<vault-server-host>:8200"
}
```


Sink: where the token is stored

Cache: Enable Caching

The `wrap_ttl` parameter in the sink block. This configuration uses the sink method to response-wrap the retrieved tokens.

To use wrapping in sink

```hcl
    sink "file" {
        wrap_ttl = "5m"
        config = {
            path = "/home/ubuntu/vault-token-via-agent"
        }
    }
```
