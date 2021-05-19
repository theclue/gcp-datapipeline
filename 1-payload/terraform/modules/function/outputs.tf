 output "trigger_url" {
  description = "URL for the GARhits Cloud Function. "
  value       = google_cloudfunctions_function.function.https_trigger_url
}