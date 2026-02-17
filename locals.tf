locals {
  common_tags = {
    Organization = var.company
    project      = var.project
    environment  = var.environment
  }


  naming_prefix = var.naming_prefix
}