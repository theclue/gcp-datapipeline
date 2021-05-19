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
  garhits_default_subscription = format("%s-%s-%s", var.options.garhits.topic, "default", "subscription")
 }

/***********************************************
  PubSub Topic and Subscriptions
 ***********************************************/

module "garhits_pubsub" {
  source  = "terraform-google-modules/pubsub/google"
  version = "~> 1.8"

  count                       = var.options.garhits.enable == true ? 1 : 0
  topic                       = var.options.garhits.topic
  project_id                  = var.project_id
  push_subscriptions = [
    {
      name                       = format("%s-%s", local.garhits_default_subscription, "push")
      ack_deadline_seconds       = 20
      push_endpoint              = "https://${var.project_id}.appspot.com/"
      x-goog-version             = "v1beta1"
      expiration_policy          = "1209600s"
      max_delivery_attempts      = 5
      maximum_backoff            = "600s"
      minimum_backoff            = "300s"
      enable_message_ordering    = false
    }
  ]
  pull_subscriptions = [
    {
      name                       = format("%s-%s", local.garhits_default_subscription, "pull")
      ack_deadline_seconds       = 20
      max_delivery_attempts      = 5
      maximum_backoff            = "600s"
      minimum_backoff            = "300s"
      enable_message_ordering    = false
    }
  ]
}

/***********************************************
  GARHits Collector Cloud Function
 ***********************************************/

module "garhits_function" {
   count                = var.options.garhits.enable == true ? 1 : 0
   suffix               = random_id.suffix.hex
   source               = "./modules/function"
   project              = var.project_id
   region               = var.region
   function_name        = "garhits"
   function_entry_point = "index"
   source_code          = "../cloudfunctions/garhits"

   depends_on = [
    module.garhits_pubsub,
  ]
}

