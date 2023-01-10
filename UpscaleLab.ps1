Get-VM -Name sec504 | Stop-VM
Get-VM -Name sec504-sling | Stop-VM

Set-VMMemory -VMName sec504 -StartupBytes 4gb
Set-VMMemory -VMName sec504-sling -StartupBytes 4gb
Set-VMProcessor -VMName sec504 -Count 4
Set-VMProcessor -VMName sec504-sling -Count 4

Get-VM -Name sec504 | Start-VM
Get-VM -Name sec504-sling | Start-VM
