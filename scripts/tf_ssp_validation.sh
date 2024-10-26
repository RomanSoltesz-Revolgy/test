# Based on licence below
#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

#!/bin/bash

# Accept Command Line Arguments
SKIPVALIDATIONFAILURE=$1
tfValidate=$2
tfFormat=$3
tfLint=$4
tfCheckov=$5
tfTfsec=$6
# -----------------------------

echo "### VALIDATION Overview ###"
echo "-------------------------"
echo "Skip Validation Errors on Failure : ${SKIPVALIDATIONFAILURE}"
echo "Terraform Validate : ${tfValidate}"
echo "Terraform Format   : ${tfFormat}"
echo "Terraform Lint     : ${tfLint}"
echo "Terraform checkov  : ${tfCheckov}"
echo "Terraform tfsec    : ${tfTfsec}"
echo "------------------------"

terraform init

# terraform validate
if (( ${tfValidate} == "Y"))
then
    echo "## VALIDATION : Validating Terraform code ..."
    terraform validate
fi
tfValidateOutput=$?

# terraform fmt -recursive
if (( ${tfFormat} == "Y"))
then
    echo "## VALIDATION : Formatting Terraform code ..."
    terraform fmt -recursive
fi
tfFormatOutput=$?

# tflint
if (( ${tfLint} == "Y"))
then
    echo "## VALIDATION : Running tflint ..."
    tflint --init
    tflint
fi    
    tflintOutput=$?

# checkov
if (( ${tfCheckov} == "Y"))
then
    echo "## VALIDATION : Running checkov ..."
    checkov --framework terraform -d ./
fi
tfCheckovOutput=$?

# tfsec
if (( ${tfTfsec} == "Y"))
then
    echo "## VALIDATION : Running tfsec ..."
    tfsec ./
fi
tfTfsecOutput=$?

echo "## VALIDATION Summary ##"
echo "------------------------"
echo "Terraform Validate : ${tfValidateOutput}"
echo "Terraform Format   : ${tfFormatOutput}"
echo "Terraform Lint     : ${tflintOutput}"
echo "Terraform checkov  : ${tfCheckovOutput}"
echo "Terraform tfsec    : ${tfTfsecOutput}"
echo "------------------------"

if (( ${SKIPVALIDATIONFAILURE} == "Y" ))
then
  #if SKIPVALIDATIONFAILURE is set as Y, then validation failures are skipped during execution
  echo "## VALIDATION : Skipping validation failure checks..."
elif (( $tfValidateOutput == 0 && $tfFormatOutput == 0 && $tflintOutput == 0 && $tfCheckovOutput == 0  && $tfTfsecOutput == 0 ))
then
  echo "## VALIDATION : Checks Passed!!!"
else
  # When validation checks fails, build process stops.
  echo "## ERROR : Validation Failed"
  exit 1;
fi
