#!/bin/bash
# tears down environment
(
	gcloud projects list | awk '{print $1}' | tail -n +2
	cd terraform/build
	terraform destroy \
		-auto-approve
)
