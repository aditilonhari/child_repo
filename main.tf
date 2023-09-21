terraform {
  required_providers {
    tfe = {
      version = "~> 0.46.0"
    }
  }
}

provider "tfe" {
  hostname = var.hostname
}

resource "tfe_workspace" "child" {
  count        = 1
  organization = var.organization
  name         = "child-${count.index}-${random_id.child_id.id}"

  lifecycle {
    postcondition {
      condition     = self.organization == var.organization 
      error_message = "org name failed"
    }
  }
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

module "empty" {
 source  = "dasmeta/empty/null"
 version = "1.0.0"
}

# priv org
module "hello" {
  source  = "simontest.ngrok.io/hashicorp/hello/random"
  version = "0.0.1"
  hellos = {
    hello        = "this is a hello"
    second_hello = "this is again a hello"
  }
  some_key = "this_is the key"
}

module "null_label" {
 source = "cloudposse/label/null"
 version = "0.25.0"
}
