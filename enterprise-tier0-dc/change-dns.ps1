param(
	[string] $ResourceGroupName,
	[string] $VnetName,
    [string] $DnsServerIp
)

$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -name $VnetName 
$vnet.DhcpOptions.DnsServers = $DnsServerIp
#$vnet.DhcpOptions.DnsServers += "Second IP" 
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet