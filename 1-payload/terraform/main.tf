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

resource "random_id" "suffix" {
  byte_length = 4
}

/***********************************************
  Additional permissions for Terraform SA
 ***********************************************/

resource "google_service_account_iam_member" "cloudbuild_terraform_sa_impersonate_permissions" {

  service_account_id = var.terraform_sa_email
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${var.project_number}@cloudbuild.gserviceaccount.com"
}

/***********************************************
  Google Analytics Clickstream Collector
 ***********************************************/

module "gacollector_function" {
   source               = "./modules/function"
   project              = var.project_id
   function_name        = "ga-collector"
   function_entry_point = "app"
}
