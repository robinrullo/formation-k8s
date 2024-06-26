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
  required_version = ">= 1.5"

  backend "pg" {
    schema_name = "secrets_state"
  }
}

provider "scaleway" {
  project_id = "d3ee25a1-a929-4d6d-9c6b-95586bef33e4"
}


resource "scaleway_iam_application" "external_secrets" {
  name = "external-secrets"

}

resource "scaleway_iam_policy" "external_secrets" {
  name           = "external-secrets"
  application_id = scaleway_iam_application.external_secrets.id
  rule {
    project_ids          = ["d3ee25a1-a929-4d6d-9c6b-95586bef33e4"]
    permission_set_names = ["SecretManagerReadOnly", "SecretManagerSecretAccess"]
  }
}

resource "scaleway_iam_api_key" "external_secrets" {
    application_id = scaleway_iam_application.external_secrets.id
}

output "api_key" {
  value = scaleway_iam_api_key.external_secrets
  sensitive = true
}