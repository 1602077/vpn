#!/bin/bash
# runs terraform apply to deploy vm.

IPSEC_PSK=${IPSEC_PSK:=$RANDOM$RANDOM$RANDOM$RANDOM}
IPSEC_USERNAME=${IPSEC_USERNAME:="vpnuser"}
IPSEC_PASSWORD=${IPSEC_PASSWORD:=$(LC_ALL=C tr -dc A-Za-z0-9_ </dev/urandom | head -c 20 | tr -d '\n')}
GCP_VM_HOSTNAME=${GCP_VM_HOSTNAME:="vpn-001"}
GCP_REGION=${GCP_REGION:="europe-west2"}
GCP_ZONE=${GCP_ZONE:="europe-west2-c"}

gcloud projects list
echo ""

# GCP_PROJECT_NAME is the only variable where a sensible default can not be
# set: prompt from user.
read -p "Enter gcp project name: " GCP_PROJECT_NAME

(
	cd terraform/build
	terraform apply \
		-var "gcp_project_name=$GCP_PROJECT_NAME" \
		-var "gcp_region=$GCP_REGION" \
		-var "ipsec-password=$IPSEC_PASSWORD" \
		-var "ipsec-psk=$IPSEC_PSK" \
		-var "ipsec-username=$IPSEC_USERNAME" \
		-var "vm_name=$GCP_VM_HOSTNAME" \
		-auto-approve
)

echo "Create a CISCO IPSEC VPN with the below config to get started:"
echo "GCP VM EXTERNAL IP: $(gcloud compute instances describe $GCP_VM_HOSTNAME --format='get(networkInterfaces[0].accessConfigs[0].natIP)' --zone $GCP_ZONE)"
echo "IPSEC USERNAME: $IPSEC_USERNAME"
echo "IPSEC PASSWORD: $IPSEC_PASSWORD"
echo "IPSEC PSK: $IPSEC_PSK"
