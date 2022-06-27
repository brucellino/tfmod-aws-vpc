provider "vault" {

}

variable "vault_aws_secrets_path" {
  type        = string
  description = "Path on Vault where the AWS secrets store is mounted"
}

variable "vault_aws_access_credentials_role_name" {
  type        = string
  description = "Name of the role requested with AWS credentials"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}
data "vault_aws_access_credentials" "creds" {
  backend = var.vault_aws_secrets_path
  role    = var.vault_aws_access_credentials_role_name
}

provider "aws" {
  access_key = data.vault_aws_access_credentials.creds.access_key
  secret_key = data.vault_aws_access_credentials.creds.secret_key
  region     = var.aws_region
}

terraform {
  backend "consul" {
    path = "tfmod_aws_vpc/tagged"
  }
}


module "example" {
  source = "../../"
  vpc_tags = {
    Name        = "infra-${var.aws_region}"
    Environment = "nonprod"
    Scope       = "internal"
  }
}
