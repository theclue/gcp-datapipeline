# Google Cloud Platform Digital Data Pipeline

## Bootstrap

This step must be done manually the first time, as it creates all the resources needed to run Terraform itself in Cloud Build. Following executions are then be made in CI/CD fashion.

To perform the operations below you must have the following installed on your development environment:

* The Google Cloud SDK version 319.0.0 or later
* Terraform version 0.13.6.

1. Go into 0-bootstrap directory
	`cd 0-bootstrap`
2. Rename terraform.tfvars.example to terraform.tfvars and update the file with values from your environment. If you don't know the current project number use this command `gcloud projects list --filter="<PROJECT NAME>" --format="value(PROJECT_NUMBER)"`
	`mv terraform.tfvars.example terraform.tfvars`
3. You need to allow Google Cloud Build to access the Github repository you put into the variable files. Go to https://console.cloud.google.com/cloud-build/triggers/connect?project=<PROJECT NUMBER> and follow the instructions there.
4. Run `terraform init`.
5. Run `terraform plan` and check if everything is ok.
6. Run `terraform apply` and follow the execution of the task.
7. Run `terraform output terraform_service_account` to get the email address of the service account used by Terraform. You're going to use later.
8. Copy the example backend definition file.
	`cp backend.tf.example backend.tf`
9. Update the name of the bucket which will store the terraform state file with the one created during the last apply
	`sed -i "s/CHANGEME/$(terraform output -raw tfstate_bucket)/g" backend.tf`
10. Copy the service account credentials file to the keys directory. If you change the default location below, you'll need to change the path on a lot of different files, so please don't do that.
	`terraform output -raw terraform_sa_key > ../../keys/terraform_sa.json`
11. Encrypt the credentials file in the current directory:
	`gcloud kms encrypt --location "$(terraform output -raw region)" \
	     --keyring "$(terraform output -raw keyring)" \
	     --key "terraform-key" \
	     --plaintext-file ../../keys/terraform_sa.json \
	     --ciphertext-file terraform_sa.json.enc`
12. Do `terraform init` again. When Terraform asks if you want to copy the state file in Cloud Storage, just say Yes.
13. Finally, do a `terraform plan` and a `terraform apply` to upload the encoded key into the service bucket. This will be used by Cloud Build during the CI/CD pipelines.