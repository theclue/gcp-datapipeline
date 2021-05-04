variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

variable "region" {
	description = "Default region to create resources where applicable."
	type		= string
}

variable "random_suffix" {
  description = "Add a random suffix to default names of all resources created by Terraform"
  type        = bool
  default     = true
}

variable "keyring" {
  description = "Keyring name."
  type        = string
  default     = ""
}
