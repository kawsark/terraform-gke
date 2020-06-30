#!/bin/bash

if [ -z "$TFH_token" ] || [ -z "$TFH_org" ] || [ -z "$GOOGLE_CREDENTIALS_PATH" ] || [ -z "GOOGLE_PROJECT" ];
then
  echo "You must set TFH_token, GOOGLE_CREDENTIALS_PATH, GOOGLE_PROJECT and TFH_org"
  exit 1
fi

echo "Listing available clusters"
gcloud container clusters list

echo "Enter a cluster name for your GKE cluster. A new name if creating a new cluster, or existing name if destroying."
read cluster_name
echo "Using cluster name: $cluster_name"
export TFH_name="terraform-gke-k8s-$cluster_name"

echo 'Enter "apply" or "destroy" for this cluster (without quotes)'
read operation
echo "Going to perform terraform $operation on workspace $TFH_name"

echo "Enter a GCP region. E.g. us-east4"
read region

echo "Enter a zone in $region. E.g. us-east4-b"
read zone

export machine_type="n1-standard-2"
export node_count=3
echo "Defaulting to machine_type: $machine_type and node_count: $node_count"

cat <<EOF >./backend.tf
terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "${TFH_org}"
    workspaces {
      name = "${TFH_name}"
    }
  }
}
EOF

terraform init
workspace_id=$(curl -s --header "Authorization: Bearer ${TFH_token}" --header "Content-Type: application/vnd.api+json" "https://app.terraform.io/api/v2/organizations/${TFH_org}/workspaces/${TFH_name}" | jq -r .data.id)

tfh pushvars -var "masterAuthPass=solstice-vault-021219" -var "masterAuthUser=solstice-k8s" -var "serviceAccount=k8s-vault" -var "project=${GOOGLE_PROJECT}" -var "region=$region" -var "zone=$zone" -var "cluster_name=${cluster_name}" -var "node_count=${node_count}" -var "machine_type=${machine_type}" -env-var "CONFIRM_DESTROY=1" -overwrite-all -dry-run false

echo "Setting new GOOGLE_CREDENTIALS from $GOOGLE_CREDENTIALS_PATH"
export GOOGLE_CREDENTIALS=$(tr '\n' ' ' < $GOOGLE_CREDENTIALS_PATH | sed -e 's/\"/\\\\"/g' -e 's/\//\\\//g' -e 's/\\n/\\\\\\\\n/g')
sed -e "s/my-key/GOOGLE_CREDENTIALS/" -e "s/my-hcl/false/" -e "s/my-value/${GOOGLE_CREDENTIALS}/" -e "s/my-category/env/" -e "s/my-sensitive/true/" -e "s/my-workspace-id/${workspace_id}/" < api_templates/variable.json.template  > variable.json;
curl --header "Authorization: Bearer ${TFH_token}" --header "Content-Type: application/vnd.api+json" --data @variable.json "https://app.terraform.io/api/v2/vars"
rm -f variable.json

terraform $operation

echo "Sleeping 10 seconds before proceeding"

if [ $operation == "apply" ]; then

  echo "Checking for existing context with this cluster name"
  context=$(kubectl config get-contexts | grep $cluster_name | awk '{print $2}')
  if [ ! -z $context ]; then
    echo "Deleting previous context: $context"
    kubectl config delete-context $context
  fi

  echo "Generating kubeconfig"
  gcloud container clusters get-credentials $cluster_name --zone $zone --project $GOOGLE_PROJECT

  context=$(kubectl config get-contexts | grep $cluster_name | awk '{print $2}')
  echo "Switching context to: $context"
  kubectl config use-context $context
  kubectl config current-context

  echo "Dumping cluster-info:"
  kubectl cluster-info
fi
