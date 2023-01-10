$VHD="3"
$Lab="IPV6"
$VM="$Lab-$vhd"

$Switch="GreenNet-OnlyRouter"
$Switch="Red"

#Create Differencing Disk
#$path="H:\Hyperv\$lab\$vhd.vhdx"
$path="d:\Hyperv\$lab\$vhd.vhdx" ## -- SSD woth Games

#$Parent="G:\baseVM\22.vhdx"
#$Parent="G:\baseVM\ubuntu22\Ubuntu22.vhdx"
$Parent="G:\baseVM\22.vhdx"

##$Parent="G:\baseVM\10.vhdx"
New-VHD  -ParentPath $Parent -Path $path -Differencing


#New-VM -Name $VM -MemoryStartupBytes 4GB -VHDPath $path -SwitchName $Switch -Generation 1
New-VM -Name $VM -MemoryStartupBytes 4GB -VHDPath $path -SwitchName $Switch -Generation 2
Set-VMProcessor -VMName $vM -Count 4
Set-vm -Name $vm -AutomaticCheckpointsEnabled $false -CheckpointType Disabled

Start-VM -Name $vm
