
# =============================================================================
# GLOBALS
# =============================================================================

# read some params from settings.json

$params = Get-Content settings.json | ConvertFrom-Json

$user = $params.site_vsphere_user
$password = $params.site_vsphere_password
$vcenter = $params.site_vsphere_host

$datacenter = $params.site_vsphere_datacenter
$cluster = $params.site_vsphere_cluster
$dstoreName = $params.site_vsphere_datastore

$PublicNetName = $params.site_vsphere_public_network
$PrivateNetName = $params.site_vsphere_private_network

$OvaFilePath = '/Volumes/anhdle/TA-Images/3.3.2.2/orchestrator-3.3.2.2.ova'

$ConfigurationNetName = 'Core|Tetration|Tet-Pub'
$IP = '192.168.30.100'
$Netmask = '255.255.255.0'
$Gateway = '192.168.30.1'

$OrchName = 'orchestrator-1'

# =============================================================================
# MAIN
# =============================================================================

Connect-VIServer -Server $vcenter -User $user -Password $password

# retrieve the host with the most RAM and the public and private port groups (DVS)

$TargetHost = (Get-Datacenter SGP | Get-Cluster Hx-2 | Get-VMHost)[3]
$Private = Get-VDPortgroup -Name $PrivateNetName
$Public = Get-VDPortgroup -Name $PublicNetName
$Configuration = Get-VDPortgroup -Name $ConfigurationNetName

#$Location = Get-Datacenter $datacenter | Get-Cluster $cluster
$Datastore = Get-Datastore $dstoreName

# The OVF configuration is contained within the OVF itself. First we grab that
# definition, then set:
# - network config (IP, subnet, gateway)
# - network mapping (mapping vNics to port groups)
# - deployment option (VM size); we set it to default

$OvfConfig = Get-OvfConfiguration $OvaFilePath

$OvfConfig.com.cisco.tetrationanalytics.IP.Value = $IP
$OvfConfig.com.cisco.tetrationanalytics.Netmask.Value = $Netmask
$OvfConfig.com.cisco.tetrationanalytics.Gateway.Value = $Gateway

$OvfConfig.NetworkMapping.Private.Value = $Private
$OvfConfig.NetworkMapping.Public.Value = $Public
$OvfConfig.NetworkMapping.Configuration.Value = $Configuration

$OvfConfig.DeploymentOption.Value = $OvfConfig.DeploymentOption.DefaultValue

$MyVm = Import-VApp -Source $OvaFilePath -OvfConfiguration $OvfConfig -Name $OrchName -Datastore $Datastore -VMHost $TargetHost

$MyVm | Start-VM

Disconnect-VIServer * -Confirm:$false
