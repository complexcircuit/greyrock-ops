terraform {
  cloud {
    organization = "grey-rock"
    workspaces {
      name = "greyrock-auth0-provisioner"
    }
  }

  required_providers {
    auth0 = {
      source  = "auth0/auth0"
      version = "0.42.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.2.1"
    }
  }
}

module "onepassword_item_auth0" {
  source = "github.com/Doonga/terraform-1password-item?ref=main"
  vault  = "Automation"
  item   = "auth0"
}

module "onepassword_item_mailgun" {
  source = "github.com/Doonga/terraform-1password-item?ref=main"
  vault  = "Services"
  item   = "mailgun"
}

module "greyrock" {
  source = "./modules/greyrock"

  secrets = {
    auth0_domain        = module.onepassword_item_auth0.fields.greyrock_domain
    auth0_client_id     = module.onepassword_item_auth0.fields.terraform_client_id
    auth0_client_secret = module.onepassword_item_auth0.fields.terraform_client_secret
    users = {
      todd = {
        email    = module.onepassword_item_auth0.fields.user_todd_email
        password = module.onepassword_item_auth0.fields.user_todd_password
      }
      andy = {
        email    = module.onepassword_item_auth0.fields.user_andy_email
        password = module.onepassword_item_auth0.fields.user_andy_password
      }
    }
    mailgun = {
      api_key = module.onepassword_item_mailgun.fields.auth0_smtp_password
    }
  }
}
