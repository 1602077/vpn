#!/bin/bash
# tears down environment

(
	gcloud projects list
	cd terraform/build
	terraform destroy
)
