# Input Variables
#################

variable "host_id" {
  description = "Mandatory: The host_id on which to deploy the project."
  type        = string
}

variable "image_version" {
  description = "Version of the images to deploy - Leave blank for 'terraform destroy'"
  type        = string
}

# Local variables
#################

# Configuration file paths
locals {
  project_configuration                = join("", ["${abspath(path.root)}/../configuration/configuration_", var.host_id, ".yml"])
  host_configuration                   = join("", ["${abspath(path.root)}/../../ryo-host/configuration/configuration_", var.host_id, ".yml" ])
  mariadb_terraform_user_password_file = join("", [ "${abspath(path.root)}/../../ryo-mariadb/configuration/mariadb_terraform_user_password_", var.host_id, ".yml" ])
  mariadb_nextcloud_user_password_file = join("", [ "${abspath(path.root)}/../configuration/mariadb_gitea_user_password_", var.host_id, ".yml" ])
}

# Basic project variables
locals {
  project_id                    = yamldecode(file(local.project_configuration))["project_id"]
  project_nextcloud_domain_name = yamldecode(file(local.project_configuration))["project_nextcloud_domain_name"]
}

# LXD variables
locals {
  lxd_host_public_ipv4_address  = yamldecode(file(local.host_configuration))["host_public_ip"]
  lxd_host_network_part         = yamldecode(file(local.host_configuration))["lxd_host_network_part"]
}

# Consul variables
locals {
  consul_ip_address  = join("", [ local.lxd_host_network_part, ".1" ])
}

# Variables from module remote states

data "terraform_remote_state" "ryo-mariadb" {
  backend = "local"
  config = {
    path = join("", ["${abspath(path.root)}/../../ryo-mariadb/module-deployment/terraform.tfstate.d/", var.host_id, "/terraform.tfstate"])
  }
}

locals {
  mariadb_ip_address = data.terraform_remote_state.ryo-mariadb.outputs.mariadb_ip_address
}
