# Google Cloud Platform Digital Data Pipeline

## Bootstrap

This step must be done manually the first time, as it creates all the resources needed to run Terraform itself in Cloud Build. Following executions are then be made in CI/CD fashion.

To perform the operations below you must have the following installed on your development environment:

* The Google Cloud SDK version 319.0.0 or later
* Terraform version 0.13.6.

1. Go into 0-bootstrap directory
	`cd 0-bootstrap`
2. Rename terraform.tfvars.example to terraform.tfvars and update the file with values from your environment. Please note the latter file is on `.gitignore` by default to avoid pushing sensitive data on git repository by mistake. Feel free to allow versioning on this file if you have a secure git repository to use.
	`mv terraform.tfvars.example terraform.tfvars`
3. Run `terraform init`.
4. Run `terraform plan` and check if everything is ok.
5. Run `terraform apply` and follow the execution of the task.
6. Run `terraform output terraform_service_account` to get the email address of the service account used by Terraform
7. Copy the backend definition file. As above, this file is also ignored by git by default.
	`cp backend.tf.example backend.tf`
8. Update the name of the bucket which will store the terraform state file with the one created during the last apply
	`sed -i "s/CHANGEME/$(terraform output -raw tfstate_bucket)/g"`
9. Copy the service account credentials file to a proper location. If you change the default location below, you'll need to change the path on the `backend.tf` file accordingly:
	`terraform output -raw terraform_sa_key > ../../keys/terraform_sa.json`
10. Encrypt the credentials file in the current directory:
	`gcloud kms encrypt --location "$(terraform output -raw region)" \
	     --keyring "$(terraform output -raw keyring)" \
	     --key "terraform-key" \
	     --plaintext-file ../../keys/terraform_sa.json \
	     --ciphertext-file terraform_sa.json.enc`
11. Do `terraform init` again. When Terraform asks if you want to copy the state file in Cloud Storage, just say Yes.
12. Finally, do a `terraform plan` and a `terraform apply` to upload the encoded key into the service bucket. This will be used by Cloud Build during the CI/CD pipelines.