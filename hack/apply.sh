#!/bin/zsh
# runs terraform apply to deploy vm.

print-bold() {echo -e "\033[1m$@\033[0m"}

CITIES=(London Berlin Oregon Paris Sydney Zurich)
declare -A GCP_REGIONS
GCP_REGIONS=(
	[Berlin]=europe-west10
	[London]=europe-west2
	[Oregon]=us-west1
	[Paris]=europe-west9
	[Sydney]=australia-southeast1
	[Zurich]=europe-west6
)
declare -a GCP_PROJECTS=($(gcloud projects list --format="value(projectId)"))

{
  print-bold ">> Creating VPN"

  echo ""
  for ((i=1; i<=${#GCP_PROJECTS[@]}; i++)); do echo "($i): ${GCP_PROJECTS[$i]}"; done
  vared -p "Choose a GCP Project: " -c PROJECT_ID
  GCP_PROJECT_NAME=$GCP_PROJECTS[$PROJECT_ID]


  if [[ -z $GCP_REGION ]]; then
    echo ""
    for ((i=1; i<=${#CITIES[@]}; i++)); do echo "($i): ${CITIES[$i]}"; done
    vared -p "Choose a City: " -c CITY_ID
    CITY=$CITIES[$CITY_ID]
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

  GCP_VM_IP=$(gcloud compute instances describe $GCP_VM_HOSTNAME --format='get(networkInterfaces[0].accessConfigs[0].natIP)' --zone $GCP_ZONE --project $GCP_PROJECT_NAME)

  print-bold "VPN created succesfully - you may need to wait up to 10 minutes for startup script to finish\n"
  echo "Create a CISCO IPSEC VPN with the below config to get started:"
  echo "GCP VM EXTERNAL IP: $GCP_VM_IP"
  echo "IPSEC USERNAME: $IPSEC_USERNAME"
  echo "IPSEC PASSWORD: $IPSEC_PASSWORD"
  echo "IPSEC PSK: $IPSEC_PSK"
}
