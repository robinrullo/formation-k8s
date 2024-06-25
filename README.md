#
- Initialiser devcontainers
- Initialiser scaleway cli : `scw init`

## 1
- `cd 01-tf-backend`
- `terraform init`
- `terraform plan`
- `terraform apply`

- `tf output -raw backend_conn_str`
- Then, in terraform block using
```hcl
backend "pg" {
  schema_name = "backend_state"    
}
```
use `terraform init -backend-config="conn_str=YOUR_CONN_STR"` equals to `backend_conn_str` output (yes, it's not a good idea to store tfstates in db deployed by this terraform module...)