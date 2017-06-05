param(
	[string] $aadClientSecret,
	[string] $keyVaultName,
	[string] $keyVaultResourceGroupName,
	[string] $vmEncryptionKeyName,
	[string] $appDisplayName
)

## STEP 1) CREATE A CLIENT ID IN AZURE AD
# Create the Azure AD Application
$azureAdApplication = New-AzureRmADApplication -DisplayName $appDisplayName -HomePage "https://www.microsoft.com/$appDisplayName" -IdentifierUris "https://www.microsoft.com/$appDisplayName" -Password $aadClientSecret
Write-Host "AAD Application: $($azureAdApplication.ApplicationId)"
# Create the service principal, the principal to access KeyVault...
New-AzureRmADServicePrincipal -ApplicationId $azureAdApplication.ApplicationId

## STEP 2) SET THE Key Vault Access Policy on the service principal
$aadClientID = $azureAdApplication.ApplicationId
$rgname = $keyVaultResourceGroupName
Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -ServicePrincipalName $aadClientID -PermissionsToKeys 'WrapKey' -PermissionsToSecrets 'Set' -ResourceGroupName $rgname

## STEP 3) Set up an encryption key
Add-AzureKeyVaultKey -VaultName $keyVaultName -Name $vmEncryptionKeyName -Destination Software

## STEP 4) Set keyvault permissions - No need here since this was set in the ARM template
#Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -ResourceGroupName $rgname -EnabledForDiskEncryption
