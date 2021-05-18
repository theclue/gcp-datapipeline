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
  bucket_name       = var.random_suffix == true ? format("%s-%s-%s", var.project_id, var.options.segment.bucket_name, random_id.suffix.hex) : format("%s-%s", var.project_id, var.options.segment.bucket_name)
 }

/***********************************************
  Service Account
 ***********************************************/

resource "google_service_account" "segment_sa" {
  count                       = var.options.segment.enable == true ? 1 : 0
  project                     = var.project_id
  account_id                  = "${var.project_id}-segment"
  display_name                = "Segmento Service Account"
}

resource "google_service_account_key" "segment_sa_key" {
  count                       = var.options.segment.enable == true ? 1 : 0
  service_account_id          = google_service_account.segment_sa[count.index].name
}

resource "google_service_account_key" "terraform_sa_key" {
  count                       = var.options.segment.enable == true ? 1 : 0
  service_account_id          = google_service_account.segment_sa[count.index].name
}

/***********************************************
  GCS Bucket for Segment
 ***********************************************/

resource "google_storage_bucket" "segment_bucket" {
  count                       = var.options.segment.enable == true ? (var.options.segment.bucket_name != "" ? 1 : 0) : 0
  project                     = var.project_id
  name                        = local.bucket_name
  location                    = var.region
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "segment_bucket_iam" {
  count                       = var.options.segment.enable == true ? (var.options.segment.bucket_name != "" ? 1 : 0) : 0
  bucket                      = google_storage_bucket.segment_bucket[count.index].name
  role                        = "roles/storage.admin"
  member                      = "serviceAccount:${google_service_account.segment_sa[count.index].email}"
}

/***********************************************
  BigQuery Resources for Segment
 ***********************************************/

 resource "google_bigquery_dataset" "segment_dataset" {
  count                       = var.options.segment.enable == true ? (var.options.segment.dataset_name != "" ? 1 : 0) : 0
  dataset_id                  = var.options.segment.dataset_name
  project                     = var.project_id
  friendly_name               = "Segment Syncronized Datalake"
  description                 = "This dataset is where Segment will push its events into."
  location                    = var.region

  labels = {
    source                    = "segment"
  }
}


resource "google_bigquery_dataset_iam_member" "segment_bq_owner" {
  count                       = var.options.segment.enable == true ? (var.options.segment.dataset_name != "" ? 1 : 0) : 0
  dataset_id                  = google_bigquery_dataset.segment_dataset[0].dataset_id
  project                     = var.project_id
  role                        = "roles/bigquery.dataOwner"
  member                      = "serviceAccount:${google_service_account.segment_sa[count.index].email}"
}

resource "google_project_iam_member" "segment_bq_jobuser" {
  count                       = var.options.segment.enable == true ? (var.options.segment.dataset_name != "" ? 1 : 0) : 0
  project                     = var.project_id
  role                        = "roles/bigquery.jobUser"
  member                      = "serviceAccount:${google_service_account.segment_sa[count.index].email}"
}