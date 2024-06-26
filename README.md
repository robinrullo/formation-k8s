#
- Initialiser devcontainers
- Initialiser scaleway cli : `scw init`

## 1 - Terraform backend in Postgres
- `cd 01-tf-backend`
- `tf init`
- `tf plan`
- `tf apply`

- `tf output -raw backend_conn_str`
- Then, in terraform block using
```hcl
backend "pg" {
  schema_name = "backend_state"    
}
```
use `terraform init -backend-config="conn_str=YOUR_CONN_STR"` equals to `backend_conn_str` output (yes, it's not a good idea to store tfstates in db deployed by this terraform module...)

## 2 - K8S Cluster deployment
- `cd 02-tf-kubernetes`
- `tf init -backend-config="conn_str=YOUR_CONN_STR"`
- `tf plan`
- `tf workspace show`
- `tf workspace new staging`
