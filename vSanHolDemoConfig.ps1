
Connect-VIServer vcsa-01a.corp.local

# Configure Host 04 VMkernal for vSAN
$myVMHost = Get-VMHost -Name "esx-04a.corp.local"
$myVDSwitch = Get-VDSwitch -Name "RegionA01-vDS-COMP"
New-VMHostNetworkAdapter -VMHost $myVMHost -PortGroup "vSAN-RegionA01-vDS-COMP" -VirtualSwitch $myVDSwitch -IP 192.168.130.54 -SubnetMask 255.255.255.0 -VsanTrafficEnabled:$true

$esxName = 'esx-04a.corp.local'
$vmkName = 'vmk3'


$esx = Get-VMHost -Name $esxName

$esxcli = Get-EsxCli -VMHost $esx -V2

$if = $esxcli.network.ip.interface.ipv4.get.Invoke(@{interfacename=$vmkName})

$iArg = @{

    netmask = $if[0].IPv4Netmask
    type    = $if[0].AddressType.ToLower()
    ipv4    = $if[0].IPv4Address
    interfacename = $if[0].Name
    gateway = '192.168.130.1'

}

$esxcli.network.ip.interface.ipv4.set.Invoke($iArg)
$esxcli.network.ip.interface.ipv4.get.Invoke(@{interfacename=$vmkName})


# Configure Host 05 VMkernal for vSAN
$myVMHost = Get-VMHost -Name "esx-05a.corp.local"
$myVDSwitch = Get-VDSwitch -Name "RegionA01-vDS-COMP"
New-VMHostNetworkAdapter -VMHost $myVMHost -PortGroup "vSAN-RegionA01-vDS-COMP" -VirtualSwitch $myVDSwitch -IP 192.168.130.55 -SubnetMask 255.255.255.0 -VsanTrafficEnabled:$true

$esxName = 'esx-05a.corp.local'
$vmkName = 'vmk3'

$esx = Get-VMHost -Name $esxName
$esxcli = Get-EsxCli -VMHost $esx -V2
$if = $esxcli.network.ip.interface.ipv4.get.Invoke(@{interfacename=$vmkName})

$iArg = @{

    netmask = $if[0].IPv4Netmask
    type    = $if[0].AddressType.ToLower()
    ipv4    = $if[0].IPv4Address
    interfacename = $if[0].Name
    gateway = '192.168.130.1'

}

$esxcli.network.ip.interface.ipv4.set.Invoke($iArg)
$esxcli.network.ip.interface.ipv4.get.Invoke(@{interfacename=$vmkName})


# Configure Host 06 VMkernal for vSAN
$myVMHost = Get-VMHost -Name "esx-06a.corp.local"
$myVDSwitch = Get-VDSwitch -Name "RegionA01-vDS-COMP"
New-VMHostNetworkAdapter -VMHost $myVMHost -PortGroup "vSAN-RegionA01-vDS-COMP" -VirtualSwitch $myVDSwitch -IP 192.168.130.56 -SubnetMask 255.255.255.0 -VsanTrafficEnabled:$true

$esxName = 'esx-06a.corp.local'
$vmkName = 'vmk3'

$esx = Get-VMHost -Name $esxName
$esxcli = Get-EsxCli -VMHost $esx -V2
$if = $esxcli.network.ip.interface.ipv4.get.Invoke(@{interfacename=$vmkName})

$iArg = @{

    netmask = $if[0].IPv4Netmask
    type    = $if[0].AddressType.ToLower()
    ipv4    = $if[0].IPv4Address
    interfacename = $if[0].Name
    gateway = '192.168.130.1'

}

$esxcli.network.ip.interface.ipv4.set.Invoke($iArg)
$esxcli.network.ip.interface.ipv4.get.Invoke(@{interfacename=$vmkName})


# Configure Host 07 VMkernal for vSAN
$myVMHost = Get-VMHost -Name "esx-07a.corp.local"
$myVDSwitch = Get-VDSwitch -Name "RegionA01-vDS-COMP"
New-VMHostNetworkAdapter -VMHost $myVMHost -PortGroup "vSAN-RegionA01-vDS-COMP" -VirtualSwitch $myVDSwitch -IP 192.168.130.57 -SubnetMask 255.255.255.0 -VsanTrafficEnabled:$true

$esxName = 'esx-07a.corp.local'
$vmkName = 'vmk3'

$esx = Get-VMHost -Name $esxName
$esxcli = Get-EsxCli -VMHost $esx -V2
$if = $esxcli.network.ip.interface.ipv4.get.Invoke(@{interfacename=$vmkName})

$iArg = @{

    netmask = $if[0].IPv4Netmask
    type    = $if[0].AddressType.ToLower()
    ipv4    = $if[0].IPv4Address
    interfacename = $if[0].Name
    gateway = '192.168.130.1'

}

$esxcli.network.ip.interface.ipv4.set.Invoke($iArg)
$esxcli.network.ip.interface.ipv4.get.Invoke(@{interfacename=$vmkName})


# Create vSAN Cluster
New-Cluster -Location (Get-Datacenter -Name RegionA01) -Name vSAN-Demo -HAEnabled -DrsEnabled -VsanEnabled -Confirm:$false



# Add ESX Hosts 5-7 to vSAN Cluster
Move-VMHost -VMHost esx-0[5-7]a.corp.local -Destination (Get-Cluster -Name vSAN-Demo) -Confirm:$false


# Take ESX Hosts 5-7 out of Maintenance Mode
Set-VMHost -VMHost esx-0[5-7]a.corp.local -State Connected -Confirm:$false


# Rename vSAN Datastore
Get-Cluster vSAN-Demo | Get-Datastore vsan* | Set-Datastore -Name vSAN-DemoDS -Confirm:$false


# Add Host 5 Disks to vSAN
$vmHost05 = Get-VMHost -Name esx-05a.corp.local
$host05cache = Get-ScsiLun -VmHost esx-05a.corp.local | Where-Object {$_.CapacityGB -eq 6}
$host05capacity = Get-ScsiLun -VmHost esx-05a.corp.local | Where-Object {$_.CapacityGB -eq 12}
New-VsanDiskGroup -VMHost $vmHost05 -SsdCanonicalName $host05cache.CanonicalName -DataDiskCanonicalName $host05capacity[0].CanonicalName,$host05capacity[1].CanonicalName


# Add Host 6 Disks to vSAN
$vmHost06 = Get-VMHost -Name esx-06a.corp.local
$host06cache = Get-ScsiLun -VmHost esx-06a.corp.local | Where-Object {$_.CapacityGB -eq 6}
$host06capacity = Get-ScsiLun -VmHost esx-06a.corp.local | Where-Object {$_.CapacityGB -eq 12}
New-VsanDiskGroup -VMHost $vmHost06 -SsdCanonicalName $host06cache.CanonicalName -DataDiskCanonicalName $host06capacity[0].CanonicalName,$host06capacity[1].CanonicalName


# Add Host 7 Disks to vSAN
$vmHost07 = Get-VMHost -Name esx-07a.corp.local
$host07cache = Get-ScsiLun -VmHost esx-07a.corp.local | Where-Object {$_.CapacityGB -eq 6}
$host07capacity = Get-ScsiLun -VmHost esx-07a.corp.local | Where-Object {$_.CapacityGB -eq 12}
New-VsanDiskGroup -VMHost $vmHost07 -SsdCanonicalName $host07cache.CanonicalName -DataDiskCanonicalName $host07capacity[0].CanonicalName,$host07capacity[1].CanonicalName

# Create RAID-1 Storage Policy
New-SpbmStoragePolicy -Name vSAN-Demo-RAID1 -Description "RAID1 Policy Created with PowerCLI for Demo" -AnyOfRuleSets `
(New-SpbmRuleSet `
(New-SpbmRule -Capability (Get-SpbmCapability -Name "VSAN.hostFailuresToTolerate" ) -Value 1),`
(New-SpbmRule -Capability (Get-SpbmCapability -Name "VSAN.stripeWidth" ) -Value 1),`
(New-SpbmRule -Capability (Get-SpbmCapability -Name "VSAN.replicaPreference" ) -Value "RAID-1 (Mirroring) - Performance")`
)

# Create RAID-5 Storage Policy
New-SpbmStoragePolicy -Name vSAN-Demo-RAID5 -Description "RAID5 Policy Created with PowerCLI for Demo" -AnyOfRuleSets `
(New-SpbmRuleSet `
(New-SpbmRule -Capability (Get-SpbmCapability -Name "VSAN.hostFailuresToTolerate" ) -Value 1),`
(New-SpbmRule -Capability (Get-SpbmCapability -Name "VSAN.stripeWidth" ) -Value 1),`
(New-SpbmRule -Capability (Get-SpbmCapability -Name "VSAN.replicaPreference" ) -Value "RAID-5/6 (Erasure Coding) - Capacity")`
)



# Clone VM to vSAN-Demo cluster
$VM1 = New-VM -Name "vSAN-DemoVM-1" -VM "core-A" -Datastore vsanDatastore -VMHost "esx-05a.corp.local"

# Clone VM to Region01A-COMP01 cluster
$VM2 = New-VM -Name vSAN-DemoVM-2 -VM core-A -Datastore vSAN-DemoDS -VMHost esx-01a.corp.local

# Add ESX Host 4 to vSAN Cluster
Move-VMHost -VMHost esx-04a.corp.local -Destination (Get-Cluster -Name vSAN-Demo) -Confirm:$false

# Add Host 4 Disks to vSAN
$vmHost04 = Get-VMHost -Name esx-04a.corp.local
$host04cache = Get-ScsiLun -VmHost esx-04a.corp.local | Where-Object {$_.CapacityGB -eq 6}
$host04capacity = Get-ScsiLun -VmHost esx-04a.corp.local | Where-Object {$_.CapacityGB -eq 12}
New-VsanDiskGroup -VMHost $vmHost04 -SsdCanonicalName $host04cache[0].CanonicalName -DataDiskCanonicalName $host04capacity[0].CanonicalName,$host04capacity[1].CanonicalName
# New-VsanDiskGroup -VMHost $vmHost04 -SsdCanonicalName $host04cache[1].CanonicalName -DataDiskCanonicalName $host04capacity[2].CanonicalName,$host04capacity[3].CanonicalName




New-VM -Name Test1 -VM core-A  -Datastore vsanDatastore -ResourcePool vSAN-Demo -AdvancedOption (Get-SpbmStoragePolicy "vSAN Default Storage Policy") | Set-SpbmEntityConfiguration -StoragePolicy "vSAN Default Storage Policy"