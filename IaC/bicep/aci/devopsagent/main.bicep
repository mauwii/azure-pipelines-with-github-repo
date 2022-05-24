@description('Name for the container group')
param name string = 'acilinuxpublicipcontainergroup'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Container image to deploy. Should be of the form repoName/imagename:tag for images stored in public Docker Hub, or a fully qualified URI for other registries. Images from private registries require additional registry credentials.')
param image string = 'mcr.microsoft.com/azuredocs/aci-helloworld'

@description('Port to open on the container and the public IP address.')
param port int = 80

@description('The number of CPU cores to allocate to the container.')
param cpuCores int = 1

@description('The amount of memory to allocate to the container in gigabytes.')
param memoryInGb int = 2

@description('The behavior of Azure runtime if container has stopped.')
@allowed([
  'Always'
  'Never'
  'OnFailure'
])
param restartPolicy string = 'Always'

@description('URL of the DevOps Organisation')
param AZP_URL string

@description('ADO-PAT with permission to Read/Write Build-Agents')
@secure()
param AZP_TOKEN string

@description('Name of the DevOps-Agent')
param AZP_AGENT_NAME string

@description('Name of the Agent Pool')
param AZP_POOL string

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2021-09-01' = {
  name: name
  location: location
  properties: {
    containers: [
      {
        name: name
        properties: {
          image: image
          ports: [
            {
              port: port
              protocol: 'TCP'
            }
          ]
          environmentVariables: [
            {
              name: 'AZP_URL'
              value: AZP_URL
            }
            {
              name: 'AZP_TOKEN'
              secureValue: AZP_TOKEN
            }
            {
              name: 'AZP_AGENT_NAME'
              secureValue: AZP_AGENT_NAME
            }
            {
              name: 'AZP_POOL'
              secureValue: AZP_POOL
            }
          ]
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb
            }
          }
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: restartPolicy
    ipAddress: {
      type: 'Public'
      ports: [
        {
          port: port
          protocol: 'TCP'
        }
      ]
    }
  }
}

output containerIPv4Address string = containerGroup.properties.ipAddress.ip
