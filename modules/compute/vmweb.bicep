param vmName string
param location string
param adminUsername string
param subnetId string

@secure()
param adminPassword string

param lbBackendPoolId string

resource nicWeb 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
           loadBalancerBackendAddressPools: [
            {
              id: lbBackendPoolId
            }
          ]
        }
      }
    ]
  }
}

resource vmweb 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
      }
    }
  }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicWeb.id
        }
      ]
    }
  }
}

// ... (Existing parameters and resources above) ...

// 3. VM Extension: Install IIS, Web Deploy, and configure Windows Firewall
resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2024-07-01' = {
  parent: vmweb
  name: 'install-iis-webdeploy' // MUST MATCH the existing failed extension name
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      // ONE LINE ONLY. Do not press Enter inside this string.
      commandToExecute: '''powershell -ExecutionPolicy Unrestricted -Command "& { Install-WindowsFeature -Name Web-Server,Web-Asp-Net45,Web-Net-Ext45,Web-ISAPI-Ext,Web-ISAPI-Filter,Web-Mgmt-Service,Web-Mgmt-Tools; Set-Service -Name WMSVC -StartupType Automatic; Start-Service -Name WMSVC; New-NetFirewallRule -Name 'AllowInboundPort8172' -DisplayName 'Allow Inbound Port 8172' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8172 -Profile Any }"'''
    }
  }
}

// ... (Existing output below) ...
output vmId string = vmweb.id


output vmWebId string = vmweb.id
