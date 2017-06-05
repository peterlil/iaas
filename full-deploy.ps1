Login-Pat

cd C:\src\github\peterlil\IaaS

$Location = 'West Europe'
$Tier0RgName = 'enterprise-network-tier0'
$SolutionRgName = 'enterprise-network-solution'
$DeployStorageAccountName = 'peterlildeploywe'
$keyVaultRgName = $Tier0RgName
$vmEncryptionKeyName = 'vm-encryption-key'

#Get hold of the JSON parameters
$Tier0NwParams = ((Get-Content -Raw .\enterprise-tier0-network\azuredeploy.parameters.json) | ConvertFrom-Json)
$keyVaultName = $Tier0NwParams.parameters.keyVaultName.value

$DCParams = ((Get-Content -Raw .\enterprise-tier0-dc\azuredeploy.parameters.json) | ConvertFrom-Json)
$DNSServerIp = $DCParams.parameters.privateIpAddress.value


# enterprise-tier0-network
.\enterprise-tier0-network\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation $Location -ResourceGroupName $Tier0RgName `
    -UploadArtifacts -StorageAccountName $DeployStorageAccountName -StorageContainerName "$($DeployStorageAccountName)-stageartifacts" `
    -TemplateFile .\azuredeploy.json -TemplateParametersFile .\azuredeploy.parameters.json

# vm-encryption-preparation.ps1
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
$aadClientSecret = [Microsoft.VisualBasic.Interaction]::InputBox("Enter the AAD Client Secret", "AAD Client Secret")
if(!($aadClientSecret)) {
    Write-Host 'No client secret entered. Exiting'
    exit
}   
.\enterprise-tier0-network\vm-encryption-preparation.ps1 -aadClientSecret $aadClientSecret -keyVaultName $keyVaultName `
    -keyVaultResourceGroupName $keyVaultRgName -vmEncryptionKeyName $vmEncryptionKeyName 

# enterprise-solution-network
.\enterprise-solution-network\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation $Location -ResourceGroupName $SolutionRgName `
    -TemplateFile .\azuredeploy.json -TemplateParametersFile .\azuredeploy.parameters.json

# enterprise-tier0-peering with azuredeploy.tier0.parameters.json
.\enterprise-tier0-peering\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation $Location -ResourceGroupName $Tier0RgName `
    -TemplateFile .\azuredeploy.json -TemplateParametersFile .\azuredeploy.tier0.parameters.json

# enterprise-tier0-peering with azuredeploy.solution.parameters.json
.\enterprise-tier0-peering\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation $Location -ResourceGroupName $SolutionRgName `
    -TemplateFile .\azuredeploy.json -TemplateParametersFile .\azuredeploy.solution.parameters.json

# enterprise-tier0-dc
.\enterprise-tier0-dc\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation $Location -ResourceGroupName $Tier0RgName `
    -UploadArtifacts -StorageAccountName $DeployStorageAccountName -StorageContainerName "$($DeployStorageAccountName)-stageartifacts" `
    -TemplateFile .\azuredeploy.json -TemplateParametersFile .\azuredeploy.parameters.json `
    -DSCSourceFolder .\DSC

.\enterprise-tier0-dc\change-dns.ps1 -ResourceGroupName $Tier0RgName -VnetName $Tier0NwParams.parameters.t0nwName.value -DnsServerIp $DNSServerIp