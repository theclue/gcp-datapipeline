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
  Segment Service Account
 ******************************************/

output "segment_sa_email" {
  description = "Email for the service account used by Segment."
  value       = google_service_account.segment_sa[0].email
}

output "segment_sa_name" {
  description = "Fully qualified name for the service account used by Segment."
  value       = google_service_account.segment_sa[0].name
}

output "segment_sa_key" {
  description = "JSON key used by the service account used by Segment."
  value = base64decode(google_service_account_key.segment_sa_key[0].private_key)
  sensitive = true
}

/******************************************
  Segment Bucket Storage
 ******************************************/

 output "segment_bucket" {
  description = "Bucket used to store Segment events."
  value       = google_storage_bucket.segment_bucket[0].name
}