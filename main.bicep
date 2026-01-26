// Vnet Module Params
@description('the name of the Virtual Network')
param vnetName string

@description('the location of the Virtual Network')
param location string = resourceGroup().location

@description('the address prefixes for the Virtual Network')
param vnetAddressPrefixes array

@description('Specify Network Security Groups and Rules for subnets')
param webNsgName string
param webRules array
param dbNsgName string
param dbRules array


@description('Parameters for Virtual Machines')
param vmName string
param adminUsername string
@secure()
param adminPassword string



@description('The following will deploy WEB NSG and DB NSG')
module webNsgModule 'modules/security/appnsg.bicep' = {
  name: 'webNsgDeployment'
  params: {
    location: location
    nsgName: webNsgName
    securityRules: webRules
  }
}


module dbNsgModule 'modules/security/appnsg.bicep' = {
  name: 'dbNsgDeployment'
  params: {
    location: location
    nsgName: dbNsgName
    securityRules: dbRules
  }
}


@description('Manually assign NSG to subnets in VNet Module')
var finalSubnets = [
  {
    name: 'web-subnet'
    addressPrefix: '10.0.0.0/24'
    networkSecurityGroup: {
      id: webNsgModule.outputs.nsgId
    }
    routeTable: null
  }
  {
    name: 'db-subnet'
    addressPrefix: '10.0.1.0/24'
    networkSecurityGroup: {
      id: dbNsgModule.outputs.nsgId
    }
    routeTable: null
  }
]


module vnetModule 'modules/network/vnet.bicep' = {
  name: 'vnetDeployment'
  params: {
    vnetName: vnetName
    location: location
    vnetAddressPrefixes: vnetAddressPrefixes
    subnets: finalSubnets
  }
} 


module lbModule 'modules/network/loadbalancer.bicep' = {
  name: 'lbDeployment'
  params: {
    location: location
   
  }
}


// New Parameter: How many Web VMs do you want? (Default to 2)
param vmCount int = 2 

// --- WEB VM LOOP (Tier 1) ---
// We use the [for] syntax to create multiple instances
module vmWebModule 'modules/compute/vmweb.bicep' = [for i in range(0, vmCount): {
  // Unique name for the deployment
  name: 'vmWebDeployment-${i}'
  params: {
    // Logic: prodvm01-web-0, prodvm01-web-1, etc.
    vmName: '${vmName}-web-${i}'
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    
    // Connect ALL these VMs to the Web Subnet (Index 0)
    subnetId: vnetModule.outputs.subnetList[0].id   

    lbBackendPoolId: lbModule.outputs.backendPoolId
  }
}]


module sqlModule 'modules/database/sql.bicep' = {
  name: 'sqlDeployment'
  params: {
    location: location
    // Creates a unique name like: sql-server-x7y8z9
    serverName: 'sql-server-${uniqueString(resourceGroup().id)}'
    sqlDbName: 'appdb'
    adminUsername: adminUsername
    adminPassword: adminPassword
  }
}


// ... (Your SQL Module is above here) ...

// --- NEW: PRIVATE ENDPOINT ---
module sqlPeModule 'modules/network/privateendpoint.bicep' = {
  name: 'sqlPeDeployment'
  params: {
    location: location
    vnetName: 'vnet-uae-prod-01' // Ensure this matches your VNet name
    subnetName: 'db-subnet'
    sqlServerId: sqlModule.outputs.sqlServerId // We need to add this Output to sql.bicep!
  }
}
