#!/bin/bash
# tears down environment

(
	cd terraform/build
	terraform destroy
)
