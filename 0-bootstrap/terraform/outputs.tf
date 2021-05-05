/**
 * Copyright 2021 Gabriele Baldassarre
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/******************************************
 General
 ******************************************/ 

output "project_id" {
  description = "The GCP project where the resources have been deployed."
  value       = var.project_id
}

output "region" {
  description = "The region where the resources have been deployed."
  value       = var.region
}

/******************************************
  Service Account
 ******************************************/

output "terraform_sa_email" {
  description = "Email for privileged service account for Terraform."
  value       = google_service_account.terraform_sa.email
}

output "terraform_sa_name" {
  description = "Fully qualified name for privileged service account for Terraform."
  value       = google_service_account.terraform_sa.name
}

output "terraform_sa_key" {
  description = "JSON key used with Terraform Service Account."
  value = base64decode(google_service_account_key.terraform_sa_key.private_key)
  sensitive = true
}

/******************************************
  GCS Terraform Storage Buckets
 ******************************************/

output "tfstate_bucket" {
  description = "Bucket used to store Terraform state."
  value       = google_storage_bucket.terraform_state.name
}

/******************************************
  Keyring
 ******************************************/

output "keyring" {
  description = "The name of the keyring."
  value       = module.kms.keyring_resource.name
}

output "keys" {
  description = "List of created key names."
  value       = keys(module.kms.keys)
}