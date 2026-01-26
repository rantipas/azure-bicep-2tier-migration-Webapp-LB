param location string
param vnetName string
param subnetName string = 'subnet-db' // Connecting to the DB subnet
param sqlServerId string // The ID of the SQL Server we created earlier

// 1. Get the Subnet ID (Needed for the Endpoint)
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' existing = {
  name: '${vnetName}/${subnetName}'
}

// 2. Create the Private Endpoint
resource sqlPrivateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: 'pe-sql-prod'
  location: location
  properties: {
    subnet: {
      id: subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: 'plsc-sql'
        properties: {
          privateLinkServiceId: sqlServerId
          groupIds: [
            'sqlServer' // Targets the SQL Server resource type
          ]
        }
      }
    ]
  }
}

// 3. Create a Private DNS Zone (Crucial for hostname resolution)
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink${environment().suffixes.sqlServerHostname}' // <--- The correct dynamic way
  location: 'global'
}

// 4. Link DNS Zone to VNet
resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: 'link-to-vnet'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', vnetName)
    }
  }
}

// 5. Register the Endpoint in the DNS Zone
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-05-01' = {
  parent: sqlPrivateEndpoint
  name: 'dnsgroup-sql'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
}
