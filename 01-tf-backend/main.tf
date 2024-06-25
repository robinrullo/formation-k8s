terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.41.2"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.2"
    }
  }
}


provider "scaleway" {
  project_id = "d3ee25a1-a929-4d6d-9c6b-95586bef33e4"
}

resource "scaleway_rdb_instance" "tf_state" {
  name           = "tf-state"
  node_type      = "db-dev-s"
  engine         = "PostgreSQL-15"
  is_ha_cluster  = false
  disable_backup = true
  tags           = ["tf-state"]
}

resource "scaleway_rdb_database" "tf_state" {
  name        = "tf_state"
  instance_id = scaleway_rdb_instance.tf_state.id
}

resource "random_password" "tf_state" {
  length           = 16
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
  override_special = "_-"
}

resource "scaleway_rdb_user" "tf_state" {
  name        = "tf_state"
  instance_id = scaleway_rdb_instance.tf_state.id
  is_admin    = false
  password    = random_password.tf_state.result
}

resource "scaleway_rdb_privilege" "tf_state" {
  instance_id = scaleway_rdb_instance.tf_state.id
  user_name = scaleway_rdb_user.tf_state.name
  database_name = scaleway_rdb_database.tf_state.name
  permission = "all"
}

output "instance_info" {
  value = scaleway_rdb_instance.tf_state.load_balancer[0]
}
output "backend_conn_str" {
  value     = "postgres://${scaleway_rdb_user.tf_state.name}:${scaleway_rdb_user.tf_state.password}@${scaleway_rdb_instance.tf_state.load_balancer[0].ip}:${scaleway_rdb_instance.tf_state.load_balancer[0].port}/${scaleway_rdb_database.tf_state.name}"
  sensitive = true
}
