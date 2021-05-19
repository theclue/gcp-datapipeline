# Poorman's Single Customer View and Marketing Data Lake

This is a set of template scripts you can use to boostrap a Single Customer View and a Makering Data Lake on the Google Cloud Platform in minutes, using Terraform, Node.js and various Google Cloud serverless services among others.

These scripts are intended to be a starting point for your configurations. Although they _can_ create a Data Lake which is ok to run in productions, this will be very vanilla. Thus, please modify those scripts for adapating your needs: they are easy to read and to customize and heavily commented.

## Prerequisites

In order to perform the operations below you must have the following installed on your development environment:

* The [Google Cloud SDK](https://cloud.google.com/sdk/docs/quickstart) version 319.0.0 or later
* [Terraform](https://terraform.io) version 0.13.6.
* [Docker](https://www.docker.com/get-started) is also highly reccomended

## Steps

Each subfolder has its own README file to help you in the configuration.