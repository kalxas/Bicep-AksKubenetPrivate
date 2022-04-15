// that's the default, but put it here for completeness
targetScope = 'resourceGroup'

// PARAMS General
param resourceTags object = {}


// params exported on param file
param aksName string 
param aksRG string 
param aksManagedRG string 
param aksVnetRG string 
param vnetName string 
param aksSnetID string 
param isAksPrivate bool
param aksDnsPrefix string
param serviceCidr string 
param dnsServiceIP string
param podCidr string 
param dockerBridgeCidr string
param aksLogAnalyticsWSName string
param systemAgentVMSize string
param userAgentVMSize string = 'Standard_F8s_v2'

//Create Resources
module aks 'Modules/aks-kubenet.module.bicep' = {
  name: 'AKSDeployment'
  params: {
    name: aksName
    region: resourceGroup().location
    tags: resourceTags
    vnetSubnetID: aksSnetID
    isAksPrivate: isAksPrivate
    aksDnsPrefix: aksDnsPrefix  
    aksManagedRG: aksManagedRG 
    serviceCidr: serviceCidr 
    dnsServiceIP: dnsServiceIP
    podCidr: podCidr
    dockerBridgeCidr: dockerBridgeCidr
    aksLawsName: aksLogAnalyticsWSName
    systemAgentVMSize: systemAgentVMSize
    userAgentVMSize: userAgentVMSize
  }
}


output aksID string = aks.outputs.aksID
output aksName string = aks.outputs.aksName
output aksApiServerAddress string = aks.outputs.apiServerAddress
output aksNodesRG string = aks.outputs.aksNodesRG
output aksTenantID string = aks.outputs.identity.tenantId
output aksSPID string = aks.outputs.identity.principalId
output aksIdentityType string = aks.outputs.identity.type
output aksRG string = aksRG
output aksVnetRG string = aksVnetRG
output vnetName string = vnetName
