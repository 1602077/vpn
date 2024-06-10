#!/bin/zsh
# runs terraform apply to deploy vm.

print-bold() {echo -e "\033[1m$@\033[0m"}

declare -A GCP_REGIONS
GCP_REGIONS=(
	[Berlin]=europe-west10
	[London]=europe-west2
	[Oregon]=us-west1
	[Paris]=europe-west9
	[Sydney]=australia-southeast1
	[Zurich]=europe-west6
)
declare -a GCP_PROJECTS=($(gcloud projects list | awk '{print $1}' | tail -n +2))

print-bold ">> Creating VPN"
echo -e "Available projects: ${GCP_PROJECTS}"
vared -p "Enter project name: " -c GCP_PROJECT_NAME
echo -e "Available cities: ${(k)GCP_REGIONS}"

# If no default region passed by environment variable prompt for input.
if [[ -z $GCP_REGION ]]; then
  vared -p "Enter a city: " -c CITY
  GCP_REGION=${GCP_REGIONS[$CITY]}
fi

IPSEC_PSK=${IPSEC_PSK:=$RANDOM$RANDOM$RANDOM$RANDOM}
IPSEC_USERNAME=${IPSEC_USERNAME:="vpnuser"}
IPSEC_PASSWORD=${IPSEC_PASSWORD:=$(LC_ALL=C tr -dc A-Za-z0-9_ </dev/urandom | head -c 20 | tr -d "\n")}
GCP_VM_HOSTNAME=${GCP_VM_HOSTNAME:="vpn-001"}
GCP_REGION=${GCP_REGION:="europe-west2"}
GCP_ZONE=${GCP_ZONE:="europe-west2-c"}


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

print-bold "VPN created succesfully - you may need to wait up to 10 minutes for startup script to finish\n"
echo "Create a CISCO IPSEC VPN with the below config to get started:"
echo "GCP VM EXTERNAL IP: $(gcloud compute instances describe $GCP_VM_HOSTNAME --format='get(networkInterfaces[0].accessConfigs[0].natIP)' --zone $GCP_ZONE)"
echo "IPSEC USERNAME: $IPSEC_USERNAME"
echo "IPSEC PASSWORD: $IPSEC_PASSWORD"
echo "IPSEC PSK: $IPSEC_PSK"
