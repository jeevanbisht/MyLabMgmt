####################################################################################################
##
## ZTNA Lab Manager
## V1.0 9/11/2022
## for comments @jeevanb
##
####################################################################################################

Connect-AzAccount
Get-AzSubscription
Select-AzSubscription "27fb9e75-fdfd-4da3-bcbe-fa90382cc860"

Clear-Host
Write-Host "#############################################################" -ForegroundColor DarkYellow
Write-Host Starting 
Write-Host "#############################################################" -ForegroundColor DarkYellow


#############################################################################
## MASTER CONFIG DO NOT EDIT        ########
#############################################################################
$ProdResourceGroups = "NaaSContosoProd", "NaaSFabrikamProd","NaaSLitwareProd"
$DogFoodResourceGroups = "DogFood1","LitwareInc","FourthCoffees","AdatumLabs"
$ZTNAALL = "NaaSContosoProd", "NaaSFabrikamProd","NaaSLitwareProd","DogFood1","LitwareInc","FourthCoffees","AdatumLabs"
#Check State of VMs
$NumOfRunningVMs=0
$NumOfOtherVMs=0
#-----------------------------------------------------------------------------


#############################################################################
# Define Upgrade SKUs
##############################################################################
#$UpgradeSKU="Standard_D2ads_v5"  ## USD 75 - Not available on all clusters
#$UpgradeSKU="Standard_B4ms"     ## USD 121  8/16
#$UpgradeSKU="Standard_D4_v3"   ## USD 140  4/16 -- working
#$UpgradeSKU="Standard_D4s_v3"  ## USD 140  4/16
$UpgradeSKU="Standard_B2s"     ## USD  30  2/4
#-----------------------------------------------------------------------------



#Query All ProdResourceGroups
############################################################################
$ActionResourceGroups = $ProdResourceGroups
#$ActionResourceGroups = $ZTNAALL
#-----------------------------------------------------------------------------

## Operation ## Supported value  - - changeSKU/Status/Shutdown/reboot/poweron
############################################################################
#$Operation="shutdown"
#$Operation="changeSKU"
#$Operation="reboot"
#$Operation="poweron"
$Operation="Status"
#$Operation="shutdown"
#-----------------------------------------------------------------------------



## Variable to making UI Responsive and running Task in the Background
$JobList = @()
## 

$ResGroup = get-AzResourceGroup
foreach ($ResourceGroup in $ResGroup)
{
    
    foreach ($ProdResourceGroup in $ActionResourceGroups)
    {
        $SelectedResourceGroup = $ResourceGroup.ResourceGroupName
        if ($ProdResourceGroup -eq $SelectedResourceGroup)
        {
            write-host "---------------------------------------------------------"
            write-host "Processing Resource Group $SelectedResourceGroup "
            write-host "---------------------------------------------------------"
            #$SelectedResourceGroup 
            ## -- We found Matching Resource Group --##
            ## Loop thru all the VMs                 ##
            $VMs=Get-AzVM -ResourceGroupName $SelectedResourceGroup -Status
            foreach ($VM in $VMs)
            {   
                $VMName= $VM.Name
                
                #############################################################################################
                ####### changeSKU  ##########################################################################
                #############################################################################################
                ## Certain VMSKU Change wiil fail                                                          ##
                ## they need to have similar setting like If the previous SKU has temp drive new SKU       ##
                ## should also have temp drive
                #############################################################################################

                if($Operation -ieq "changeSKU") 
                {
                    $currentSKU=$VM.HardwareProfile.VmSize
                    $RequestedSKU=$UpgradeSKU
                    
                    write-host "$VMName : SKU Change Requested, Check if Old and New VM SKU is same" -ForegroundColor Green
                    if($currentSKU -ieq $RequestedSKU)
                    {
                            Write-host "$VMName : $UpgradeSKU is same as Original SKU not action required" -ForegroundColor Red
                    }
                    else {
                            Write-host "$VMName : Attempting to upgrade $currentSKU to $RequestedSKU" -ForegroundColor Blue
                            $vm.HardwareProfile.VmSize = $RequestedSKU
                            $JobList += Update-AzVM -ResourceGroupName $SelectedResourceGroup -VM $VM -AsJob |  Add-Member -MemberType NoteProperty -Name VMName -Value $VMName -PassThru
                            Write-host "$VMName : Job Submitted , will run in background " -ForegroundColor Blue

                            #$JobList += Stop-AzVM -ResourceGroupName $SelectedResourceGroup -Name $VMName -Force -AsJob |  Add-Member -MemberType NoteProperty -Name VMName -Value $VMName -PassThru
                    }

                }

                #############################################################################################
                ####### Shutdown ############################################################################
                #############################################################################################
                ## Only shutsdown VM with "VM Running" State                                               ##
                #############################################################################################
                if($Operation -ieq "shutdown")
                {
                    
                    $VMState = $VM.PowerState
                    write-host "$VMName : Shutdown Requested" -ForegroundColor DarkYellow
                    
                    if($VMState  -ieq "VM running")
                    {
                            Write-host "$VMName : $VMName is in $VMState will proceed with Shutdown " -ForegroundColor Green
                            $JobList += Stop-AzVM -ResourceGroupName $SelectedResourceGroup -Name $VMName -Force -AsJob |  Add-Member -MemberType NoteProperty -Name VMName -Value $VMName -PassThru
                            Write-host "$VMName : Job Submitted , will run in background " -ForegroundColor Blue
                    }
                    else
                    {
                            Write-host "$VMName : $VMName is in $VMState . No action taken" -ForegroundColor Blue
                            
                    }


                }
                

                #############################################################################################
                ####### PowerOn ############################################################################
                #############################################################################################
                if($Operation -ieq "poweron")
                {
                    
                    $VMState = $VM.PowerState
                    write-host "$VMName : PowerUp Requested" -ForegroundColor DarkYellow
                    
                    if($VMState  -ieq "VM running")
                    {
                        Write-host "$VMName : $VMName is in $VMState . No action taken" -ForegroundColor Blue
                    }
                    else
                    {
                            
                            Write-host "$VMName : $VMName is in $VMState will proceed with PowerOn " -ForegroundColor Green
                            $JobList += Start-AzVM -ResourceGroupName $SelectedResourceGroup -Name $VMName  -AsJob |  Add-Member -MemberType NoteProperty -Name VMName -Value $VMName -PassThru
                            Write-host "$VMName : Job Submitted , will run in background " -ForegroundColor Blue

                    }


                }
                
                
                #############################################################################################
                ####### Reboot   ############################################################################
                #############################################################################################
                if($Operation -ieq "reboot")
                {
                    
                    $VMState = $VM.PowerState
                    write-host "$VMName : Reboot Requested" -ForegroundColor DarkYellow
                    
                    if($VMState  -ieq "VM running")
                    {
                            Write-host "$VMName : $VMName is in $VMState will proceed with Reboot " -ForegroundColor Green
                            $JobList += restart-AzVM -ResourceGroupName $SelectedResourceGroup -Name $VMName -AsJob |  Add-Member -MemberType NoteProperty -Name VMName -Value $VMName -PassThru
                            Write-host "$VMName : Job Submitted , will run in background " -ForegroundColor Blue
                    }
                    else
                    {
                            Write-host "$VMName : $VMName is in $VMState . No action taken" -ForegroundColor Blue
                                                                                  
                    }


                }
                


                #############################################################################################
                ####### Status   ############################################################################
                #############################################################################################
                if($Operation -ieq "Status")
                {
                    
                    $VMState = $VM.PowerState
                    $CurrentVMSKU= $VM.HardwareProfile.VmSize
                    if($VMState  -ieq "VM running")
                    {
                        Write-host "$VMName : $VMName is in $VMState and sku is $CurrentVMSKU" -ForegroundColor Green
                        $NumOfRunningVMs++
                    }
                    else 
                    {
                        Write-host "$VMName : $VMName is in $VMState and sku is $CurrentVMSKU" -ForegroundColor Blue
                        $NumOfOtherVMs++
                    }
                    

                }
                
            }



        }
    }
}


if( ($Operation -ieq "reboot") -or ($Operation -ieq "poweron") -or ($Operation -ieq "shutdown") -or ($Operation -ieq "changeSKU") )
{
    Write-Host "Start Job Queue Monitoring"
    $JobList | Wait-Job | Receive-Job
    $JobList | Remove-Job
    Write-Host "Job Queue Empty"
}


if($Operation -ieq "status")
{
Write-Host "Running - $NumOfRunningVMs"
Write-Host "Others  - $NumOfOtherVMs"
}


Write-Host "#############################################################" -ForegroundColor DarkYellow
Write-Host Completed 
Write-Host "#############################################################" -ForegroundColor DarkYellow
