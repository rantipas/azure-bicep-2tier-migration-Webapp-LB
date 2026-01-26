param location string
param serverName string
param sqlDbName string = 'appdb'
param adminUsername string
@secure()
param adminPassword string

// 1. Create the SQL Server
resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: serverName
  location: location
  properties: {
    administratorLogin: adminUsername
    administratorLoginPassword: adminPassword
  }
}

// 2. Create the SQL Database ("appdb")
resource sqlDb 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sqlServer
  name: sqlDbName
  location: location
  sku: {
    name: 'Basic' // "Basic" is the cheapest option (approx $5/month)
    tier: 'Basic'
    capacity: 5   // 5 DTUs
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 2147483648 // 2 GB
  }
}

// 3. Allow Azure Services (Allows your VMs to talk to the DB for now)
resource allowAzureServices 'Microsoft.Sql/servers/firewallRules@2021-11-01' = {
  parent: sqlServer
  name: 'AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

output sqlServerName string = sqlServer.name
output sqlDbName string = sqlDb.name
output sqlServerId string = sqlServer.id
