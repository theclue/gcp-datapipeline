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

locals {
  bucket_name       = var.random_suffix == true ? format("%s-%s-%s", var.project_id, "tfstate", random_id.suffix.hex) : format("%s-%s", var.project_id, "tfstate")
  keyring_name      = var.keyring != "" ? var.keyring : var.random_suffix == true ? format("%s-%s-%s", var.project_id, "keyring", random_id.suffix.hex) : format("%s-%s", var.project_id, "keyring")
 }

resource "random_id" "suffix" {
  byte_length = 4
}

/***********************************************
  Service account for Terraform
 ***********************************************/

resource "google_service_account" "terraform_sa" {
  project      = var.project_id
  account_id   = "${var.project_id}-terraform"
  display_name = "Terraform Service Account"
}

resource "google_service_account_key" "terraform_sa_key" {
  service_account_id = google_service_account.terraform_sa.name
}

/***********************************************
  GCS Bucket for Terraform
 ***********************************************/

resource "google_storage_bucket" "terraform_state" {
  project                     = var.project_id
  name                        = local.bucket_name
  location                    = var.region
  uniform_bucket_level_access = true
  versioning {
    enabled = true
  }
}

/***********************************************
  Permissions for Terraform.
 ***********************************************/

resource "google_storage_bucket_iam_member" "terraform_state_iam" {
  bucket = google_storage_bucket.terraform_state.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.terraform_sa.email}"
}

/***********************************************
 * Keyring and Terraform key
 ***********************************************/

module "kms" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 1.2"

  project_id         = var.project_id
  location           = var.region
  keyring            = local.keyring_name
  keys               = ["terraform-key"]
  set_owners_for     = ["terraform-key"]
  owners = [
    "serviceAccount:${google_service_account.terraform_sa.email}"
  ]
}

/***********************************************
 * Upload encoded files to GCS
 ***********************************************/

resource "null_resource" "upload_encoded_keys" {

 triggers = {
   file_hashes = jsonencode({
   for fn in fileset(".", "*.json.enc") :
   fn => filesha256("./${fn}")
   })
 }

 provisioner "local-exec" {
   command = "gsutil cp -r ./*.json.enc gs://${google_storage_bucket.terraform_state.name}/keys/"
 }
}