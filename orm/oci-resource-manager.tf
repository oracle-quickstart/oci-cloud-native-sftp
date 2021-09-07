variable "target_directory" {
    default = ""
}

variable "archive_name" {

  default = "orm"
}

locals {

  timestamp = formatdate("YYYYMMDDhhmmss", timestamp())
  archive_filename = "${var.archive_name}-${local.timestamp}.zip"
}

data "archive_file" "generate_zip" {

  type        = "zip"
  output_path = (var.target_directory != "" ? "${var.target_directory}/${local.archive_filename}" : "${path.module}/target/${local.archive_filename}")
  source_dir = "../"
  excludes    = [
    ".git",
    ".gitignore",
    ".terraform",
    "terraform.lock.hcl",
    ".DS_STORE",
    "LICENSE",
    "orm",
    "packer",
    "provider.tf",
    "README.md",
    "terraform.tfstate",
    "terraform.tfstate.backup",
    "terraform.tfvars", 
    "terraform.tfvars.template"
  ]
}