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
    schema_name = "kubernetes_main"
  }
}


provider "scaleway" {
  project_id = "d3ee25a1-a929-4d6d-9c6b-95586bef33e4"
}

resource "scaleway_vpc" "vpc" {
  name           = "learn_vpc_${terraform.workspace}"
  enable_routing = true
}

resource "scaleway_vpc_private_network" "k8s_pn" {
  name   = "learn_k8s_pn"
  vpc_id = scaleway_vpc.vpc.id
}

resource "scaleway_k8s_cluster" "cluster" {
  name                        = "learn_k8s_cluster"
  version                     = "1.29.1"
  cni                         = "cilium"
  private_network_id          = scaleway_vpc_private_network.k8s_pn.id
  delete_additional_resources = true
}

resource "scaleway_k8s_pool" "pool1" {
  cluster_id = scaleway_k8s_cluster.cluster.id
  name       = "pool1"
  node_type  = "DEV1-M"
  size       = 1
  # size = "${var.pool_size}"
}

resource "scaleway_registry_namespace" "main" {
  name        = "learn_k8s_rrullo_${terraform.workspace}"
  description = "Container registry namespace for environment ${terraform.workspace}"
  is_public   = false
}

output "kubeconfig" {
  value       = scaleway_k8s_cluster.cluster.kubeconfig
  description = "Kubeconfig for the created Kubernetes cluster"
  sensitive   = true
}
