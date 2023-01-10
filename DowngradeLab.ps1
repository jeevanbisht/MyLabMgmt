

Get-VM -Name sec504 | Stop-VM
Get-VM -Name sec504-sling | Stop-VM



Set-VMMemory -VMName sec504 -StartupBytes 2gb
Set-VMMemory -VMName sec504-sling -StartupBytes 2gb
Set-VMProcessor -VMName sec504 -Count 2
Set-VMProcessor -VMName sec504-sling -Count 2


Get-VM -Name sec504 | Start-VM
Get-VM -Name sec504-sling | Start-VM


