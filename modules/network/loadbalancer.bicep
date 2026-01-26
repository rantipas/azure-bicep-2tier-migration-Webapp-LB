param location string
param lbName string = 'lb-web-prod'

// 1. Create a Public IP for the Load Balancer
resource publicIp 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: '${lbName}-pip'
  location: location
  sku: {
    name: 'Standard' // Standard SKU is required for Standard Load Balancer
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// 2. Create the Public Load Balancer
resource loadBalancer 'Microsoft.Network/loadBalancers@2024-05-01' = {
  name: lbName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    // FRONTEND: Connects to the Public IP
    frontendIPConfigurations: [
      {
        name: 'LoadBalancerFrontend'
        properties: {
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
    
    // BACKEND POOL: Where VMs connect
    backendAddressPools: [
      {
        name: 'backend-pool-web'
      }
    ]
    
    // HEALTH PROBE: Checks Port 80
    probes: [
      {
        name: 'HealthProbe-HTTP'
        properties: {
          protocol: 'Tcp'
          port: 80
          intervalInSeconds: 15
          numberOfProbes: 2
        }
      }
    ]
    
    // RULE: Send Traffic from Public IP -> Backend Pool
    loadBalancingRules: [
      {
        name: 'LBRule-HTTP'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', lbName, 'LoadBalancerFrontend')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, 'backend-pool-web')
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', lbName, 'HealthProbe-HTTP')
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          idleTimeoutInMinutes: 15
        }
      }
    ]
  }
}

// Output the Pool ID for the VMs
output backendPoolId string = resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lbName, 'backend-pool-web')
