
@description('the name of the Virtual Network')
param vnetName string

@description('the location of the Virtual Network')
param location string

@description('the address prefixes for the Virtual Network')
param vnetAddressPrefixes array

@description('array of subnets for the Virtual Network')
param subnets array 



resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01'  = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressPrefixes
    }
    subnets: [
      for subnet in subnets: {
        name: subnet.name
        properties: {
          addressPrefix: subnet.addressPrefix
          networkSecurityGroup: subnet.networkSecurityGroup
          routeTable: subnet.routeTable
        }
      }

    ]
    
  }
}

output vnetId string = vnet.id

output subnetList array = [
  for (subnet,i) in subnets: {
    name: subnet.name
    id: '${vnet.id}/subnets/${subnet.name}'
  }
]
