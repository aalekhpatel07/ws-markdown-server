#!/usr/bin/env sh

set -euo pipefail;

TERRAFORM_DIR=./terraform
if which terraform > /dev/null; then
    echo "Found terraform. Applying the config stored at: ${TERRAFORM_DIR}";
else
    echo "Unable to find terraform on the system path. Are you sure you have it installed?";
    exit 1
fi

TERRAFORM_TFVARS_FILE=terraform.tfvars
if test -f "$TERRAFORM_TFVARS_FILE"; then
    echo "$TERRAFORM_TFVARS_FILE exists. Proceeding with deployment.";
else
    echo "$TERRAFORM_TFVARS_FILE does not exist. Using the terraform.tfvars.sample file for the required input variables.";
    TERRAFORM_TFVARS_FILE=terraform.tfvars.sample
fi

terraform -chdir=${TERRAFORM_DIR} init;
terraform -chdir=${TERRAFORM_DIR} apply -var-file $TERRAFORM_TFVARS_FILE;

echo "Deployment complete. You may now access the server at the \"dns_name\" provided in the output."