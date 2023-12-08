terraform {
  required_providers {
    tfe = {
      version = "~> 0.46.0"
    }
    http = {
      source = "hashicorp/http"
      version = "3.4.0"
    }
  }
}

provider "tfe" {
  hostname = var.hostname
}

resource "tfe_workspace" "child" {
  count        = 10
  organization = var.organization
  name         = "zzchild-${count.index}-${random_id.child_id.id}"

  lifecycle {
    postcondition {
      condition     = self.organization == var.organization 
      error_message = "org name failed"
    }
  }
  queue_all_runs = true
  auto_apply = true
}

resource "random_id" "child_id" {
  byte_length = 8
}

resource "tfe_variable" "test-var" {
  key = "test_var"
  value = random_id.child_id.id
  category = "env"
  workspace_id = tfe_workspace.child[0].id
  description = "This allows the build agent to call back to TFC when executing plans and applies"

  lifecycle {
    postcondition {
      condition = self.category == "env"
      error_message = "var name postcondition failed"
    }
  }
}

data "http" "google" {
  url = "https://www.google.com"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}

################################ MODULES ################################

module "empty" {
 source  = "dasmeta/empty/null"
 version = "1.0.0"
}

module "null_label" {
 source = "cloudposse/label/null"
 version = "0.25.0"
}

module "null0220" {
 source = "cloudposse/label/null"
 version = "0.22.0"
}

module "null0230" {
 source = "cloudposse/label/null"
 version = "0.23.0"
}

module "cloudposse241" {
  source = "cloudposse/label/null"
  version = "0.24.1"
}

module "eg_prod_bastion" {
  source = "cloudposse/label/null"
  version = "0.25.0"

  namespace  = "eg"
  stage      = "prod"
  name       = "bastion"
  attributes = ["public"]
  delimiter  = "-"

  tags = {
    "BusinessUnit" = "XYZ",
    "Snapshot"     = "true"
  }
}

module "hello" {
  source  = "app.staging.terraform.io/soak-test-projects_large-2/hello/random"
  version = "6.0.0"
  # insert required variables here
  hellos = {
    hello        = "this is a hello"
    second_hello = "this is again a hello"
  }
  some_key = "this_is the key again"
}

module "uuid" {
  source  = "Invicton-Labs/uuid/random"
  version = "0.2.0"
}

module "labels" {
  source  = "clouddrove/labels/aws"
  version = "1.3.0"
}

module "boolean-true" {
  source  = "devops-workflow/boolean/local"
  value   = "true"
}

module "boolean-false" {
  source  = "devops-workflow/boolean/local"
  value   = "false"
}



# priv org
# module "hello" {
#  source  = "simontest.ngrok.io/hashicorp/hello/random"
#  version = "6.0.0"
#  hellos = {
#    hello        = "this is a hello"
#    second_hello = "this is again a hello"
#  }
#  some_key = "this_is the key"
#}

