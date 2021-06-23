#!/bin/bash

# Variables
red='\e[1;31m%s\e[0m\n'
green='\e[1;32m%s\e[0m\n'
blue='\e[1;34m%s\e[0m\n'

# Set your Azure Subscription
SUBSCRIPTION=xxxxxxxxxxxxx-xxxxxxxx-xxxx-x

# choice of dev|prod
ENVIRONMENT=local
APP_PREFIX=TestAKS
RG_NAME="rg-${APP_PREFIX}-Cluster-${ENVIRONMENT}"
RG_VNET_NAME="rg-${APP_PREFIX}-Networking-${ENVIRONMENT}"
VNET_NAME="vnet-${ENVIRONMENT}-AKSPrivateKubenet"
LOCATION=northeurope
DEPLOYMENT_NAME=deployAks
PARAM_FILE="./${DEPLOYMENT_NAME}.parameters.${ENVIRONMENT}.json"




# Code - do not change anything here on deployment
# 1. Set the right subscription
printf "$blue" "*** Setting the subsription to $SUBSCRIPTION ***"
az account set --subscription "$SUBSCRIPTION"

# 2. Create main Resource group if not exists
az group create --name $RG_NAME --location $LOCATION
printf "$green" "*** Resource Group $SUBSCRIPTION created (or Existed) ***"


# 4. start the BICEP deployment
printf "$blue" "starting BICEP AKS deployment for ENV: $ENVIRONMENT"
az deployment group create \
    -f ./$DEPLOYMENT_NAME.bicep \
    -g $RG_NAME \
    -p $PARAM_FILE

printf "$green" "*** Deployment finished for ENV: $ENVIRONMENT.  ***"
printf "$green" "***************************************************"

# get the outputs of the deployment
outputs=$(az deployment group show --name $DEPLOYMENT_NAME -g $RG_NAME --query properties.outputs)

# store them in variables
aksID=$(jq -r .aksID.value <<<$outputs)
aksNodesRG=$(jq -r .aksNodesRG.value <<<$outputs)
aksTenantID=$(jq -r .aksTenantID.value <<<$outputs)
aksSPID=$(jq -r .aksSPID.value <<<$outputs)
aksIdentityType=$(jq -r .aksIdentityType.value <<<$outputs)

printf "$green" "AKS  ID:           $aksID"
printf "$green" "AKS managed RG:    $aksNodesRG"
printf "$green" "AKS Tenant ID:     $aksTenantID"
printf "$green" "AKS SP ID:         $aksSPID"
printf "$green" "AKS Identity Type: $aksIdentityType"




# 5. Get the AKS SPID role assignment network contributor on VNET
VNET_ID=$(az network vnet show --resource-group $RG_VNET_NAME --name $VNET_NAME --query id -o tsv)
printf "$green" "VNET ID:           $VNET_ID"
az role assignment create --assignee $aksSPID --scope $VNET_ID --role "Network Contributor"

# az aks nodepool show -g rg-TestAKS-Cluster-local --cluster-name aks-kubenet-b6oy4p5fr7gtk -n systempool
# az aks show -g rg-TestAKS-Cluster-local -n aks-kubenet-b6oy4p5fr7gtk --query "servicePrincipalProfile"


# az aks get-credentials -g rg-TestAKS-Cluster-local -n aks-kubenet-b6oy4p5fr7gtk