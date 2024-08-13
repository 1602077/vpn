#!/bin/zsh
# tears down environment

print-bold() {echo -e "\033[1m$@\033[0m"}

(
  print-bold ">> Deleting VPN"

  echo ""
  declare -a GCP_PROJECTS=($(gcloud projects list --format="value(projectId)"))
  for ((i = 1; i <= ${#GCP_PROJECTS[@]}; i++)); do echo "($i): ${GCP_PROJECTS[$i]}"; done
  vared -p "Choose a GCP Project: " -c PROJECT_ID
  GCP_PROJECT_NAME=$GCP_PROJECTS[$PROJECT_ID]

  cd terraform/build
  terraform destroy \
    -var "gcp_project_name=$GCP_PROJECT_NAME" \
    -var "gcp_region= " \
    -var "ipsec-password= " \
    -var "ipsec-psk= " \
    -var "ipsec-username= " \
    -var "vm_name= " \
    -auto-approve
)
