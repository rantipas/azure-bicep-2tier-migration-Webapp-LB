using './main.bicep'

// --- VM Parameters ---
param vmName = 'prodvm01' 
param adminUsername = 'azureuser'
param adminPassword = 'Aa1020304050'

// --- General ---
param location = 'uaenorth'
param vnetName = 'vnet-uae-prod-01'
param vnetAddressPrefixes = [
  '10.0.0.0/16'
]

// --- Web NSG Rules ---
param webNsgName = 'nsg-web'
param webRules = [
  {
    name: 'Allow-HTTP'
    properties: {               
      priority: 100
      direction: 'Inbound'
      access: 'Allow'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '80'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
    }                         
  }
  {
    name: 'Allow-WebDeploy'
    properties: {                
      priority: 300
      direction: 'Inbound'
      access: 'Allow'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '8172'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
    }
  }
  {
    name: 'Allow-rdp'
    properties: {                 
      priority: 200
      direction: 'Inbound'
      access: 'Allow'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '3389'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
    }
  }
]

// --- DB NSG Rules ---
param dbNsgName = 'nsg-db'
param dbRules = [
  {
    name: 'Allow-sqlport-Internal'
    properties: {                 
      priority: 100
      direction: 'Inbound'
      access: 'Allow'
      protocol: 'Tcp'
      sourcePortRange: '*'
      sourceAddressPrefix: '10.0.0.0/24'
      destinationAddressPrefix: '*'
      destinationPortRange: '1433'
    }
  }
]
