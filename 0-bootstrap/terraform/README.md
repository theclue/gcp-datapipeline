# Google Cloud Platform Terraform Bootstrap

This sequence can be used to easily bootstrap a Terraform environment and a CI/CD minimal infrastructure to trigger Terraform actions.

Please bear in mind that you need a local Terraform setup to perform the first run. This is because the first run will eventually create the bucket which will host the Terraform state file and the service account for Terraform itself. Subsequent runs won't need to be executed locally; in facts, they will be added to the Cloud Build default pipelines.

At the end of this sequence you'll have:

* A Google KMS keyring and a default key `terraform-key`.
* A Google Storage bucket to store the Terraform state files and the credentials files. This bucket is encypted at rest with the aforementioned key.
* Two Cloud Build triggers against a Github repository:
	* One responds to __develop__ branch pushes and it will perform a _terraform plan_ only.
	* One responds to __main__ branch pushes and it will do a _terraform plan+apply_.

## Prerequisites

In order to perform the operations below you must have the following installed on your development environment:

* The [Google Cloud SDK](https://cloud.google.com/sdk/docs/quickstart) version 319.0.0 or later
* [Terraform](https://terraform.io) version 0.13.6.

All the needed modules and dependencies will be automatically downloaded and installed upon the first `terraform init`

Don't forget to authenticate with a Google Cloud account which has at least the `projectEdit` role for the project you want to create the resource into.

> `gcloud auth login`
> `gcloud config set project <PROJECT_ID>`

## Quick start

1. Fork this repository and rename it. Edit the root `.gitignore` file and comment the last two lines.
	* If you _don't_ rename the repository, Cloud Build triggers will be created in a _disabled_ state. Use this repository just as a template!
2. Go into terraform directory
	> `cd terraform`
3. Rename the file terraform.tfvars.example to terraform.tfvars and update the file with values from your environment. If you don't know the current project number use this command `gcloud projects list --filter="<PROJECT NAME>" --format="value(PROJECT_NUMBER)"`
	> `mv terraform.tfvars.example terraform.tfvars`
	> `emacs terraform.tfvars`
4. You need to allow Google Cloud Build to access the Github repository you put into the variable files. Go to `https://console.cloud.google.com/cloud-build/triggers/connect?project=<PROJECT NUMBER>` and follow the instructions there.
5. Run `terraform init`.
6. Run `terraform plan` and check if everything is ok.
7. Run `terraform apply` and follow the execution of the task.
8. Run `terraform output terraform_service_account` to get the email address of the service account used by Terraform. You're going to use later.
9. Copy the example backend definition file.
	> `cp backend.tf.example backend.tf`
10. Update the name of the bucket which will store the terraform state file with the one created during the last apply:
	> `sed -i "s/CHANGEME/$(terraform output -raw tfstate_bucket)/g" backend.tf`
11. Copy the service account credentials file to the keys directory. If you change the default location below, you'll need to change the path on a lot of different files, so please don't do that.
	> `terraform output -raw terraform_sa_key > ../../keys/terraform_sa.json`
12. Do `terraform init` again. When Terraform asks if you want to copy the state file in Cloud Storage, just say Yes.
13. Finally, do a `terraform plan` and a `terraform apply` to upload the encoded key into the service bucket. This is the location from Cloud Build will take the credentials file to authenticate into the CI/CD pipelines.