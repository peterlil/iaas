# iaas
PoC and Lab solutions on pure IaaS

Deploy in the following order:
1. enterprise-tier0-network
2. vm-encryption-preparation.ps1
3. enterprise-solution-network
4. enterprise-tier0-peering with azuredeploy.tier0.parameters.json
5. enterprise-tier0-peering with azuredeploy.solution.parameters.json
6. enterprise-tier0-dc
7. change-dns.ps1

