<#
.SYNOPSIS
    File Name   : CitiInstall-Global.ps1
    Author      : CITIATM Global Team
    PreRequisite: PowerShell v2 ++, PowerShell Unrestricted Policy or Signed script
    Version     : GD1404 HO2
#>

Begin
{
    #Start-Transcript "C:\CITIATMDeploymentStore\CitiInstall-Global.ps1.log"
}
process
{ 

function SetInstallationType
 {
 
        Param
        (
        # Param1 help description
        [Parameter(Mandatory=$true , Position=0)]
        $InstallationType
        )
       
        Try
        {
        Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
        
        if(Test-Path "C:\CITI.dat")
           {
 		Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Installation Type or Version is: $InstallationType" 
                $xml=[xml](get-content -Path "C:\CITI.dat")
				
				if ($InstallationType -eq "Scratch" -Or $InstallationType -eq "Upgrade" -Or $InstallationType -eq "Patch"){
				
                $xml.MediaVarList.var | 
                Where-Object { $_.name -eq "INSTALLATIONTYPE" } | 
                ForEach-Object  { [void]$xml.MediaVarList.RemoveChild($_) }

                $xml | Select-Xml -XPath '/MediaVarList'
                $InstallationNode = $xml.createelement("var")
                #<![CDATA[INSTALLED]]>

                $InstallationNode.setattribute("name","INSTALLATIONTYPE")
                $InstallationNode.set_InnerXML("<![CDATA[" + $InstallationType + "]]>") 

                $xml.selectsinglenode("/MediaVarList").appendchild($InstallationNode)
                $xml.save("C:\CITI.dat")
                Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Updated CITI.dat file based on the installation Type"
				}
				else
				{
				$xml.MediaVarList.var | 
                Where-Object { $_.name -eq "INSTALLATIONVERSION" } | 
                ForEach-Object  { [void]$xml.MediaVarList.RemoveChild($_) }

                $xml | Select-Xml -XPath '/MediaVarList'
                $InstallationVersNode = $xml.createelement("var")
                #<![CDATA[INSTALLED]]>

                $InstallationVersNode.setattribute("name","INSTALLATIONVERSION")
                $InstallationVersNode.set_InnerXML("<![CDATA[" + $InstallationType + "]]>") 

                $xml.selectsinglenode("/MediaVarList").appendchild($InstallationVersNode)
                $xml.save("C:\CITI.dat")
                Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Updated CITI.dat file based on the installation Version"
				}
            }
            else
            {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "CITI.dat file does not exist"
            }
            
        }
 
        Catch
            {
                Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
                Exit $LastExitCode
            }
     }

function EnableMSMQ
	{
	 TRY
       {

         Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
         Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"
		 Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "****************** in EnableMSMQ ************"
         $MSMQStatus=(Get-WmiObject -Query "SELECT * FROM Win32_Service WHERE Name = 'MSMQ'").Status

        if($MSMQStatus -eq "OK")
        {
             Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) MSMQ Service already Exists."
        }
        else
        { 
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) MSMQ Service doesnot Exists, So Enabling the Windows MSMQ Feature"
            start -wait OCsetup "MSMQ-Container /norestart /quiet"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) MSMQ Service Successfully Enabled"
        }
        
        Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode" 
        Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
     }
    Catch
     {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
     }

	}
	
	function Install-DataMonitoringAgent() 
     {
        Try
        {
			$ServiceName="DataMonitoringAgent"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "**********in Install-DataMonitoringAgent*********************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"
			Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Input Parameters ServiceName- $ServiceName for scrach installation" 
            If (!(Get-Service -Name $ServiceName -ErrorAction SilentlyContinue))
            {
				Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) $ServiceName doesnot Exists."
			   if(Test-Path("C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\CitiATM\DataMonitoring\DataMonitoringAgent.exe"))
				{                                
					Copy-Item -Path "C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\CitiATM\DataMonitoring\DataMonitoringAgent.exe" -Destination "C:\Program Files\KAL\CITIKAP\Imports\" -Force
				    if($?)
                    {
                        Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) copied agent exe"
                    }
                    else
                    {
                        Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) error in copying agent exe"
                    }
				}	
				
				if(Test-Path("C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\CitiATM\DataMonitoring\DataMonitoringConfigurator.dll"))
				{                                
			        Copy-Item -Path "C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\CitiATM\DataMonitoring\DataMonitoringConfigurator.dll" -Destination "C:\Program Files\KAL\CITIKAP\Imports\" -Force
                    if($?)
                    {
                         Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) copied configurator dll"
                    }
                    else
                    {
                        Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) error in copying configurator dll"
                    }
				}
                Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Install2 $ServiceName service"
				Invoke-Command -ScriptBlock {C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe /install "C:\Program Files\KAL\CITIKAP\Imports\DataMonitoringAgent.exe"}
                if($?)
                {
			         Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) installed agent"	
                }				

                Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Install $ServiceName service successfully"
				
            
            }
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"    
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Not returning any code. function called by other powershell function and not MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
			Exit 0 
		}
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }
	
	
	function Copy-DataMonitoringDependents()
	{
	Try
	{
	     Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "********************************************************************************************************"
         Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"
		 Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) in Copy-DataMonitoringDependents Input Parameters "
		
		
		if(Test-Path("C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\CITIATM\DataMonitoring\MessageQueueAdapter.dll"))
        {                                
            Copy-Item -Path "C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\CITIATM\DataMonitoring\MessageQueueAdapter.dll" -Destination "C:\Program Files\KAL\CitiKAP\Imports\" -Force
			Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*********copied MessageQueueAdapter.dll ************"
        }	
		
		if(Test-Path("C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\CITIATM\KAL\CITIKAP\Configuration\Business.xml"))
        {                                
            Copy-Item -Path "C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\CITIATM\KAL\CITIKAP\Configuration\Business.xml" -Destination "C:\Program Files\KAL\CitiKAP\Configuration\" -Force
			Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*********copied business.xml ************"
        }
		
		if(Test-Path("C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\CITIATM\KAL\CITIKAP\Configuration\datamonitoring2.rules"))
        {                                
            Copy-Item -Path "C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\CITIATM\KAL\CITIKAP\Configuration\datamonitoring2.rules" -Destination "C:\Program Files\KAL\CitiKAP\Configuration\" -Force
			Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*********copied datamonitoring2.rules ************"
        }
		
		
		 Start-Service "DataMonitoringAgent"
		 Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*********DataMonitoringAgent service started************"
		 Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"    
            
         Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Not returning any code. function called by other powershell function and not MDT"
         Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
		 Exit 0 
		
	}
    Catch
    {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
    }
	
	
	}

	 
    function Install-LanguagePack
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"       
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"
            & rundll32.exe shell32.dll,Control_RunDLL "intl.cpl,, /f:C:\CITIATM_VOBS\CITIATM_CM\Utilities\RegionSettings.txt" | Out-Host
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0            
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }
    
    function Install-DisableUAC
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Install-DisableUAC"
            regedit /s UAC.reg
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Install-DisableUAC"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"  
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0            
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }

    function Configure-K3ARestart
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before creating necessary registry keys for K3ARestart"
            regedit /s K3ARestart.reg
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After creating necessary registry keys for K3ARestart"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"  
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0            
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }

    function Install-DotNetFramework
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before .Net Install"
            $process = Start-Process ".\NDP452-KB2901907-x86-x64-AllOS-ENU.exe" "/q /norestart" -wait -PassThru
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After .Net Install 4.5.2"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                          
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }
    # set-location C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\UTILITIES
      function Uninstall-VPN_SW
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before uninstall-VPN_SW"
           
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
              
            Stop-Service PanGPS -Force -PassThru 
			 
			Start-Sleep 10  
		   
			$file = "GlobalProtect-3.1.6.msi"

           & msiexec.exe /x  $file /quiet /norestart | Out-Null

            Start-Sleep 10              
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Uninstall-VPN_SW"                
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                          
        }

        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }
	 function Install-VPN_SW
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Install-VPN_SW"
           
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
              
            
           $file = "GlobalProtect-4.1.1.msi"

           & msiexec.exe /i  $file CONNECTMETHOD="pre-logon" CERTIFICATESTORELOOKUP="machine" ENABLEADVANCEDVIEW="no" SHOWAGENTICON="no" SHOWSYSTEMTRAYNOTIFICATIONS="no" CANCHANGEPORTAL="no" CANCONTINUEIFPORTALCERTINVALID="no" CANPROMPTUSERCREDENTIAL="no" PORTALTIMEOUT="30" CONNECTTIMEOUT="60" RECEIVETIMEOUT="30" /quiet /norestart | Out-Null

            Start-Sleep 10              
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Install-VPN_SW"                
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"
            
            Stop-Service PanGPS -Force -PassThru 
            Set-Service -name PanGPS -StartupType Manual
			Set-Service -name NlaSvc -StartupType Manual
			Set-Service -name netprofm -StartupType Manual
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Stopped PanGPS service and changed to manual"
           
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                          
        }

        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }
    
    function Install-Powershell
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Install-Powershell"
           
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
              
            
            $file = "Win7-KB3134760-x86.msu"

            & wusa.exe /wait $file /quiet /norestart | Out-Null



            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Install-Powershell"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                          
        }

        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }
    
    function Install-ADModule
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Install-ADModule"
          
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
        
           
          $file = "Windows6.1-KB958830-x86-RefreshPkg.msu"

            & wusa.exe /wait $file /quiet /norestart | Out-Null

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Install-ADModule"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                          
        }

        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }

    function Install-IE11Prerequisites
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Install-IE11Prerequisites"
            $process = Start-Process ".\IE11Prerequisites.exe" -wait -PassThru
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
            Start-Sleep 2
            cd IE11Prerequisites
            foreach($file in Get-ChildItem -Path .)
            {
                $argList = "$file", "/quiet", "/norestart"
                $p = Start-Process  WUSA -ArgumentList $argList -PassThru
                if(!$p.WaitForExit(3000000))
                {
                    Add-Content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) ERROR: Update $file.Name taking too long. Skip and continue with the rest.."
                    $p.Kill();
                }
            }

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Install-IE11Prerequisites"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                          
        }

        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }

    function Install-IE11
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Install-IE11"
            $process = Start-Process ".\IE11-Windows6.1-x86-en-us.exe"  "/quiet /norestart " -wait -PassThru
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
            
            #Wait-Process -Name IE11_Windows6.1_x86_en_us
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Install-IE11"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode" 
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                         
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }
   
    function Install-SAPI
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before SAPI"
            $process = Start-Process ".\SAPI.msi" -wait -PassThru
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) AFter SAPI"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode" 
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                         
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }

    function Install-LOQUENDO
    {
        Try
        {
        
             [xml]$installVars = Get-Content C:\Citi.dat
	         $Version=$installVars.MediaVarList.var | where { $_.name.startsWith("LOQUENDO") }
	         $LOQUENDO = $Version.Innertext
             
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Loquendo and Configured Value $LOQUENDO"
            Switch ($LOQUENDO)
             {
                "YES"  
                {
                 Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Loquendo set as YES and Installation started"
                 copy-item C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\Loquendo -destination C:\"Program Files"\Loquendo -Force -recurse
                 Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Loquendo set as YES and Installation completed"
                
                }
                "NO"  {Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o)  Loquendo Configured as NO and Skipping the Installation"}
                Default 
                {
                  Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Loquendo Value not defined and Installation started by default"
                  copy-item C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\Loquendo -destination C:\"Program Files"\Loquendo -Force -recurse
                  Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Loquendo Value not defined and Installation completed by default"
                }
             }
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Loquendo"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                          
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }
	function Install-NUANCE
    {
        Try
        {
		  Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
          Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"
		  
		   Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Nuance Installation started by default"
           copy-item C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\Nuance -destination C:\"Program Files"\Nuance -Force -recurse
  
		   Copy-Item -Path "C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\Nuance\common\speech\components\ve.dll" -Destination "C:\Windows\System32" -Force 	
		   Copy-Item -Path "C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\Nuance\common\speech\components\msvcr110.dll" -Destination "C:\Windows\System32" -Force 
  
           Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Nuance Installation completed"
           
		   Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Nuance"
           Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"
            
           Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
           Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
           Exit 0                          
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }	
	
		
	function Install-NUANCE-Upgrade
    {
        Try
        {
		  Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
          Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"
		  
		   Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Nuance Installation started by default"
           copy-item C:\CITIATMDeploymentStore\Applications\Upgrade\GlobalApps\Nuance -destination C:\"Program Files"\Nuance -Force -recurse
  
		   Copy-Item -Path "C:\CITIATMDeploymentStore\Applications\Upgrade\GlobalApps\Nuance\common\speech\components\ve.dll" -Destination "C:\Windows\System32" -Force 	
		   Copy-Item -Path "C:\CITIATMDeploymentStore\Applications\Upgrade\GlobalApps\Nuance\common\speech\components\msvcr110.dll" -Destination "C:\Windows\System32" -Force 
  
           Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Nuance Installation completed"
           
		   Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Nuance"
           Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"
            
           Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
           Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
           Exit 0                          
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }	
	
    function Install-A2iA
    {
        Try
        { 
        
            [xml]$installVars = Get-Content C:\Citi.dat
	         $Version=$installVars.MediaVarList.var | where { $_.name.startsWith("A2IA") }
	         $A2IA = $Version.Innertext
             
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before A2iA and Configured Value $A2IA"
            Switch ($A2IA)
             {
                "YES"   
                {
                 Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) A2IA set as YES and Installation started"
                 & .\A2iA_CheckReaderSetup.exe /silent | Out-Host
                 Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) A2IA set as YES and Installation completed"
                
                }
                "NO"  {Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) A2IA Configured as NO and Skipping the installation"}
                Default 
                {
                  Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) A2IA Value not defined and Installation started by default"
                  & .\A2iA_CheckReaderSetup.exe /silent | Out-Host
                  Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) A2IA Value not defined and Installation completed by default"
                  
                }
             }
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After A2iA"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"  
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                        
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }

    function Install-Kalignite
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Install-Kalignite"
            & taskkill /im TsProgressUI.exe /f
            $process = start-process ".\Setup.exe" "-kalman -300 -kxproduction -nokxtracebackup -pwd 857438502" -wait -PassThru
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Setup.exe"
            Start-Sleep -Seconds 90
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Sleep"
            & taskkill /im WerFault.exe /f
           
            #C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\Utilities\waitproc [_isDel.exe,setup.exe]
            Wait-Process -Name _ISDel, Setup
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Wait"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Install-Kalignite"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0              
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }

    function Get-TraceBackup
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before TraceBackup"
            $process = Start-Process ".\KXTraceBackup.msi" "/qb /norestart /l*v C:\CITIATMDeploymentStore\KXTraceBackup.log" -wait -PassThru
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After TraceBackup"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode" 
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                        
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }
    
    
    function GrantAdminAccess_KAL
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"   
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before GrantAdminAccess_KAL"
            $perm="(OI)(CI)F"
            icacls C:\ProgramData\KAL\* /grant Administrators:$perm
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After GrantAdminAccess_KAL"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"  
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                        
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }

	function Install-EMV
    {    
         Try
         {
            
             [xml]$installVars = Get-Content C:\Citi.dat
	         $Version=$installVars.MediaVarList.var | where { $_.name.startsWith("EMVVERSION") }
	         $EMV = $Version.Innertext
             
             Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
             Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"
             Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) EMV Version chosen by regional team is $Version.Innertext and EMV Kernel Version is: EMVKernel_V$EMV.msi"

             if($EMV)
             {
             Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Inside Install-EMV version is $EMV "
             $process = Start-Process "msiexec" "/i EMVKernel_V$EMV.msi /passive /l C:\Common\Logs\EMV.log" -wait -PassThru
             Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
             }
             else
             {
              Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Inside Install-EMV version 6 by Default "
              $process = Start-Process "msiexec" "/i EMVKernel_V6.msi /passive /l C:\Common\Logs\EMV.log" -wait -PassThru
              Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
             }
              
             Start-Sleep -Seconds 30
             Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Installing EMV Version"
             Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode" 
             Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Installed EMV "
             
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                           
         }
         Catch
         {
             Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
             Exit $LastExitCode
         }
     }    
   
     
    
    function Install-K3A
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Inside Install-K3A"
            md "C:\Common\Logs"
            $process = Start-Process "msiexec" "/i K3AInstaller4_5_4.msi /qb PASSWORD=91723658 /l C:\Common\Logs\K3A.log" -wait -PassThru
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
            
            Start-Sleep -Seconds 30
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After K3A"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode" 
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                                     
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }

    function Register-K3A
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Inside Register-K3A"           
            $process = Start-Process ".\RegisterK3A.exe" -wait -PassThru
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Process : $($process.ExitCode)"
            
            Start-Sleep -Seconds 30
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Register-K3A"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode" 
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                                     
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }
    
    function Install-KALPlatformUpgrade
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before KAL Platform Upgrade"
            $process = Start-Process ".\KalignitePlatform_4-4-1_Upgrade.exe" -wait -PassThru
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
            
            Start-Sleep -Seconds 2
            Wait-Process -Name KalignitePlatform_4-4-1_Upgrade.exe
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After KAL Platform Upgrade"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"  
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                        
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }

    function KAL-InstallSignCertificate
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Inside KAL-InstallSignCertificate"
            md "C:\Common\Logs"
            $process = Start-Process "msiexec" "/i KALInstallSignCertificate.msi /l C:\Common\Logs\KAL-InstallSignCertificate.log" -wait -PassThru
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Process : $($process.ExitCode)"
            
            Start-Sleep -Seconds 30
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After KAL-InstallSignCertificate"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode" 
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                        
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }
	
	function Copy-Hotfix
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date -f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date -f o) Before starting  Copying HotFix"
            if(Test-Path -Path C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\MICROSOFT\HotFix\WSUS.cab)
            {
				Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date -f o) HotFix available in the path C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\MICROSOFT\HotFix\WSUS.cab "
                Copy-Item -Path "C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\MICROSOFT\HotFix\WSUS.cab" -Destination "C:\SB" -Force 
            }
			if(Test-Path -Path C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\MICROSOFT\HotFix\OS.cab)
            {
				Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date -f o) HotFix available in the path C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\MICROSOFT\HotFix\OS.cab "
                Copy-Item -Path "C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\MICROSOFT\HotFix\OS.cab" -Destination "C:\SB" -Force 
            }
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date -f o) After completing copying Hotfix"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }
	
    function Install-Hotfix
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date -f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"
            
			if(Test-Path -Path C:\SB\WSUS.cab)
			{
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date -f o) Before starting CATMGDWSUS1501 HO1  HotFix Installation"
            if(Test-Path -Path C:\WSUSImport)
            {
                Remove-Item -Recurse -Force C:\WSUSImport
            }
            New-Item -ItemType directory -Path C:\WSUSImport
            expand C:\SB\WSUS.cab /F:* C:\WSUSImport
            $Process = Start-Process "C:\WSUSImport\WSUSInstall.bat" -wait -PassThru
            Remove-Item -Recurse -Force C:\SB\WSUS.cab
            Remove-Item -Recurse -Force C:\WSUSImport
            Remove-Item -Recurse -Force C:\Common\runtime\WSUS\wsuscontent
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date -f o) After Completing CATMGDWSUS1501 HO1  Hotfix installtion"
			}
			
			if(Test-Path -Path C:\SB\OS.cab)
			{
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date -f o) Before starting CATMCMW71601P1HO3 HotFix Installation"
            if(Test-Path -Path C:\WSUSImport)
            {
                Remove-Item -Recurse -Force C:\WSUSImport
            }
            New-Item -ItemType directory -Path C:\WSUSImport
            expand C:\SB\OS.cab /F:* C:\WSUSImport
            $Process = Start-Process "C:\WSUSImport\Install.bat" -wait -PassThru
            Remove-Item -Recurse -Force C:\SB\OS.cab
            Remove-Item -Recurse -Force C:\WSUSImport
            Remove-Item -Recurse -Force C:\Common\runtime\WSUS\wsuscontent
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date -f o) After Completing CATMCMW71601P1HO3 Hotfix installtion"
			}
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }
	
	function Install-SMB
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date -f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"
            
			if(Test-Path -Path C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\Utilities\SMB.reg)
			{
			Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date -f o) Starting SMB installation for scratch"
			regedit /S C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\UTILITIES\SMB.reg
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date -f o) SMB installation successful in Scratch installation"
			}
            if(Test-Path -Path C:\CITIATMDeploymentStore\Applications\Upgrade\GlobalApps\Utilities\SMB.reg)
			{
			Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date -f o) Starting SMB installation for Upgrade"
			regedit /S C:\CITIATMDeploymentStore\Applications\Upgrade\GlobalApps\Utilities\SMB.reg
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date -f o) Executing SMB registry file for Upgrade installation"
			}            
            Exit 0
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }
	
	function Delete-LMS
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date -f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date -f o) Before starting LMS Service deletion Installation"
            if(Test-Path -Path C:\SB\DRIVERS\ME_SW_Pocono\LMS\LMS.exe)
            {
                Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date -f o) LMS.exe is available in this path C:\SB\DRIVERS\ME_SW_Pocono\LMS\LMS.exe"
				Remove-Item -Recurse -Force C:\SB\DRIVERS\ME_SW_Pocono\LMS\LMS.exe
            }
			
			if(Test-Path -Path C:\SB\DRIVERS\AMT_Talladega\LMS\LMS.exe)
            {
                Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date -f o) LMS.exe is available in this path C:\SB\DRIVERS\AMT_Talladega\LMS\LMS.exe"
				Remove-Item -Recurse -Force C:\SB\DRIVERS\AMT_Talladega\LMS\LMS.exe
            }            
           
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date -f o) After Completing LMS Service deletion"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }

    function Install-GlobalCITIATM
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Install-GlobalCITIATM"
            $process = Start-Process ".\CitiATM.exe" -wait -PassThru
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
            
            Start-Sleep -Seconds 2
            Wait-Process -Name Installer
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Install-GlobalCITIATM"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"  
            
            #KAL HO2 changes for CPK support - start
            Set-Location -LiteralPath C:\TMD
            $process = Start-Process "C:\Windows\Microsoft.NET\Framework\v4.0.30319\regasm.exe" "HIDWrapper.dll /tlb: HIDWrapper.tlb /codebase" -wait -PassThru
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After generating HIDWrapper.tlb for CPK"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode" 
            If(Test-Path("C:\TMD\HIDWrapper.tlb")) { Copy-Item -Path "HIDWrapper.tlb" -Destination "C:\Program Files\KAL\Kalignite\Dll" -Force } 
            Else { Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) HIDWrapper.tlb is not generated" }
            #KAL HO2 changes for CPK support - end
                                 
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                        
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }
    
    #This fuction is not being called from Tasksequence as secondary logon service will be running in os by default
   <# function Apply-PreLockdownWorkaround
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Install-LockdownWorkaround"
            sc.exe start seclogon
            Sc.exe config seclogon start= auto
            xcopy /Y C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\CITIATM\KAL\Kalignite\Lockdown\KXLockdown.exe "C:\Program Files\KAL\Kalignite\dll"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Install-LockdownWorkaround"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"  
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                        
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }
    #>
    
    function Install-KTCInstaller
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Install-KTCInstaller"
            $process = Start-Process "msiexec" "/i KTCTrustedInstaller.msi /passive" -wait -PassThru
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
            
            # R142 Propagation
    	    regsvr32 /s "C:\Program Files\KAL\Kalignite\Dll\KTC2.dll"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Install-KTCInstaller"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"    
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                      
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }

    function Install-KXSecurity
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Install-KXSecurity"
            $process = Start-Process "msiexec" "/i KXSecurity.msi /passive" -wait -PassThru
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Install-KXSecurity"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode" 
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                         
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }

    function Install-CitiService
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Install-CitiService"
            $process = Start-Process "msiexec" "/i CitiServiceInstaller.msi /passive" -wait -PassThru
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Install-CitiService"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"  
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                        
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }
	
	function Install-CitiServiceMonitor
    {
        Try
        {
            if (Get-Service "CSM" -ErrorAction SilentlyContinue)
            {
                $Process = Start-Process "C:\Program Files\KAL\CitiKAP\Configuration\checkservices1.exe" -wait -PassThru
                Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from CSM Process : $($process.ExitCode)"
                Set-Service -Name "CSM" -StartupType "Automatic"
                Exit 0
            }
            else
            {
                Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
                Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

                Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Install-CitiServiceMonitor"
    			
    			$destination = "C:\Program Files\KAL\CitiKAP\Configuration"
                Copy-Item -Path ".\checkservices1.exe" -Destination $destination -Force 
    			Copy-Item -Path ".\citiservicesmonitor.exe" -Destination $destination -Force 
    			Copy-Item -Path ".\csm.reg" -Destination $destination -Force
    		    Copy-Item -Path ".\install.bat" -Destination "C:\KTC2temp" -Force
    	        CD 'C:\KTC2temp'
                Start-Process ".\install.bat" "-I" -wait   
    			$Process = Start-Process ".\install.bat" -wait -PassThru
                Remove-Item -Recurse -Force ".\install.bat"
    			Remove-Item -Recurse -Force "C:\Program Files\KAL\CitiKAP\Configuration\csm.reg"
    			
                Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
                
                Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Install-CitiServiceMonitor"
                Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"  
                
                Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
                Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
                Exit 0
            }                        
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }

    function Install-CitiOIService
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Install-CitiOIService"
            $process = Start-Process "msiexec" "/i MonitorOIEntitlementServiceSetup.msi /passive" -wait -PassThru
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Install-CitiOIService"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0              
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }

   function Start-CitiSec
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Install-Start-CitiSec"
            $copydir = "C:\Program Files\KTCTrustedInstaller"
            Copy-Item -Path ".\CITISEC.exe" -Destination $copydir -Force 
            Copy-Item -Path "Interop.NetFwTypeLib.dll" -Destination $copydir -Force 
	        CD 'C:\Program Files\KTCTrustedInstaller'
            Start-Process ".\CitiSec.exe" "-I" -wait                      
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Install-Start-CitiSec"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode" 
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                         
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }

    function Apply-Lockdown
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Copying lockdown.exe to kaliginite\Dll"
            xcopy /Y C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\CITIATM\KAL\Kalignite\Lockdown\KXLockdown.exe "C:\Program Files\KAL\Kalignite\dll"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Apply-Lockdown"
            #Temp Workaround for lockdown -Appuser should be run with *
            $process = Start-Process ".\KXLockdown.exe" "-SETUP AppUser * no" -wait -PassThru
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Apply-Lockdown"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"    
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            #Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value
 
	        net localgroup "Network Configuration Operators" AppUser /ADD
	        Add-content "C:\CITIATMDeploymentStore\GlobalApps.log"  -value "Added AppUser to Network Configuration Operators group"

"*****************************************************************************************************"
            Exit 0                      
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }


    function Apply_PostLockdownWorkaround
    {
       Try
       {
           Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
           Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

           Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Apply_PostLockdownWorkaround"
           #Temp Workaround for lockdown    
           schtasks /create /tn "DeleteAutoLogonEntry" /tr "C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\UTILITIES\Startup.bat" /sc onstart /ru System
           
           #$regkey  = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
           #New-ItemProperty -Path $regkey -Name DefaultPassword -PropertyType String -Value C1t1bank
           #net user AppUser C1t1bank

           Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Apply_PostLockdownWorkaround"
           Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"
           
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                        
       }
       Catch
       {
           Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
           Exit $LastExitCode
       }
    }

     function Create-ScheduleTasks
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Create-ScheduleTasks"
            #schtasks /create /tn "CitiRun" /tr "C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\Utilities\Run.cmd" /sc onlogon /ru System
            schtasks /create /tn "CitiRun" /XML "C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\Utilities\CitiRun.xml"
            schtasks /create /tn "CATMMLog" /tr "C:\Progra~1\KAL\CitiKAP\CATMMLog\catmmlog_r.exe"  /sc onlogon /ru System
			schtasks /create /tn "Powercfg" /tr "C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\Utilities\PowerSettings.cmd" /sc minute /mo 15 /ru System /f
			schtasks /create /tn "MonitorAdminAccount" /tr "C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\Utilities\DisableAdmin.bat" /sc ONEVENT /ec Security /mo "*[System[Provider[@Name='Microsoft-Windows-Security-Auditing'] and EventID=4740]]" /ru System /f
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Create-ScheduleTasks"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"   
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                       
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }
	
	
	 function Create-WSUSchtask
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Create-ScheduleTasks for WSUS "
            SchTasks /Create /SC WEEKLY /D SUN /TN “WSUSInstall” /TR “C:\CITIATMDeploymentStore\Scripts\WSUSPreInstallCheck.wsf” /RU "NT AUTHORITY\SYSTEM" /ST 03:00
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Disable ScheduleTasks for WSUS "
	    SchTasks /Change /TN “WSUSInstall” /Disable

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Create-ScheduleTasks for WSUS"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"   
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                       
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }
	
	
    function Install-Certificates
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Install-Certificates(PROD)"
            $process = Start-Process ".\CertificateInstaller.exe" '"C:\Program Files\CitiBank"' -wait
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Install-Certificates(PROD)"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
            
            Start-Sleep -Seconds 30
            $CertFolderExist = Test-Path "C:\TestCert"
            if ($CertFolderExist)
                {
                  $CertFileExist = Get-ChildItem "C:\TestCert" | Measure-Object
                    if ($CertFileExist.Count -eq 0)
                        {
                            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Folder is empty."
                            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Copy Certificates might have failed."
                         }
                    else
                        {
                            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Install-Certificates(Test Environment)"
                            $process = Start-Process ".\CertificateInstaller.exe" '"C:\TestCert"' -wait
                            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Install-Certificates"
                            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"  
                        }
                    }
            else
                {
                  Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) C:\TestCert doesn't exits. Production mode"  
                }
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                        
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }

    function Create-InstallerAccount
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Create-InstallerAccount"
            $process = Start-Process ".\CitiInstaller.exe" "C" -wait -PassThru
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Create-InstallerAccount"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"   
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                       
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }

    function Create-AdminAccount
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Create-AdminAccount"
            $process = Start-Process ".\CitiInstaller.exe" "P -ACCT administrator -PWF AdminAct.PWF" -wait -PassThru
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Create-AdminAccount"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0              
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }
    
    function Stop-Services
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Stop-Services"
            $process = Start-Process ".\StopService.cmd" -wait -PassThru
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
            
    	    & taskkill /im WerFault.exe /f
            $process = Start-Process ".\StopPowerSave.exe" -wait -PassThru
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Exit Code from Install Process : $($process.ExitCode)"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Stop-Services"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"   
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0                      
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }

# not using this function now as we are using latest KAL pkg need to do reg changes
#this is manual process of updating reg for lockdown for accounts
    function Update-Registry
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Update Registry"
    	    & regedit /S VM.reg
    	  
            & regedit /S CELockdown.reg
            
            sleep 30
            [xml]$CitiDatXml = Get-Content C:\Citi.dat
            $RegionVar = $CitiDatXml.MediaVarList.var | where { $_.name.startsWith("REGION") }
            #echo $RegionVar.Innertext
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "The region is found to be $($RegionVar.Innertext)"
        	if (-not ($RegionVar.Innertext -eq "CBNA")) { 
                Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before setting CitiKAP.K3a application for Non CBNA business"
                $RegKey = 'HKLM:\SOFTWARE\KAL\Kalignite\Lockdown\Run\001'
                $value = """C:\Program Files\KAL\K3A\Dll\K3A.Executive.exe"" ""C:\Program Files\KAL\CitiKAP\CitiKAP.k3a"""
                Set-ItemProperty -Path $RegKey -Name "CommandLine" -Value $value
                Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After setting CitiKAP.K3a application for Non CBNA business"
            }
        	
            & regedit /S IE_11.reg
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Update Registry"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"    
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0               
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }
function Copy-EPPFirmware
    {
	Try
        {
	
	  $EPPHandler_Dest = "C:\EPPFirmware"
	 Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before remove eppfirmware directory"
	 if((Test-Path($EPPHandler_Dest))) {Remove-Item $EPPHandler_Dest -Recurse -Force} 
	 Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After remove eppfirmware directory"
    	  
	 Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before copy eppfirmware"
 	 Copy-Item -Path "C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\EPPFirmware" -Destination "C:\" -Force -recurse          
	 Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Copying the EPP standalone pacakge"
	 Exit 0
	}
	Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }
function UpdateCasetteDet
    {
	Try
        {
	Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before adding CastteInfo xml"
	Start-Process "C:\Program Files\KAL\K3A\Dll\UpdateCasetteInfo.exe" -wait -PassThru
	 
	 Exit 0
	}
	Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
	
    }
    function Copy-Files
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Copy-Files"

            Copy-Item -Path ".\restart.bat" -Destination "C:\Users\Public\Desktop\" -Force

            $copydir = "C:\Common\Runtime"
            if(!(Test-Path($copydir))) {New-Item -Path $copydir -ItemType "directory" -Force} 
            Copy-Item -Path ".\makecert.exe" -Destination $copydir -Force
            
            $copydir = "C:\Program Files\KAL\Kalignite\Dll"
            if(!(Test-Path($copydir))) {New-Item -Path $copydir -ItemType "directory" -Force} 
            Copy-Item -Path ".\makecert.exe" -Destination $copydir -Force
            # BitLocker File Information
            $copydir = "C:\BitLocker"  
            if(!(Test-Path($copydir))) {New-Item -Path $copydir -ItemType "directory" -Force} 
            
            if(Test-Path("C:\CITIATMDeploymentStore\Scripts\ManageBitlocker.vbs"))
            {                                
            Copy-Item -Path "C:\CITIATMDeploymentStore\Scripts\ManageBitlocker.vbs" -Destination $copydir -Force 
            }
            
            if(Test-Path("C:\CITIATMDeploymentStore\Scripts\BitLockerUSBOnlyMode.pol"))
            {   
            Copy-Item -Path "C:\CITIATMDeploymentStore\Scripts\BitLockerUSBOnlyMode.pol" -Destination $copydir -Force            
            }
            # Updated LocalPol.exe reference to Templates folder
            if(Test-Path("C:\CITIATMDeploymentStore\Templates\Win7SP1-MDTGPOPack\LocalPol.exe"))
            { 
            Copy-Item -Path "C:\CITIATMDeploymentStore\Templates\Win7SP1-MDTGPOPack\LocalPol.exe" -Destination $copydir -Force   
            }
	                   
            # AppLocker File Information
            $copydir = "C:\AppLocker"  
            
            if(!(Test-Path($copydir))) {New-Item -Path $copydir -ItemType "directory" -Force} 

	    if(Test-Path("C:\CITIATMDeploymentStore\Scripts\DenyList.txt"))
            {                                
            Copy-Item -Path "C:\CITIATMDeploymentStore\Scripts\DenyList.txt" -Destination $copydir -Force 
            }
            # Updated LocalPol.exe reference to Templates folder
            if(Test-Path("C:\CITIATMDeploymentStore\Templates\Win7SP1-MDTGPOPack\LocalPol.exe"))
            { 
            Copy-Item -Path "C:\CITIATMDeploymentStore\Templates\Win7SP1-MDTGPOPack\LocalPol.exe" -Destination $copydir -Force   
            }

            if(Test-Path("C:\CITIATMDeploymentStore\Scripts\AppLockerAuditOnlyMode.pol"))
            {                                
            Copy-Item -Path "C:\CITIATMDeploymentStore\Scripts\AppLockerAuditOnlyMode.pol" -Destination $copydir -Force 
            }
            
            if(Test-Path("C:\CITIATMDeploymentStore\Scripts\AppLockerAuditOnlyMode_DLL.pol"))
            {                                
            Copy-Item -Path "C:\CITIATMDeploymentStore\Scripts\AppLockerAuditOnlyMode_DLL.pol" -Destination $copydir -Force 
            }
            
            if(Test-Path("C:\CITIATMDeploymentStore\Scripts\AppLockerAuditOnlyMode_EXE.pol"))
            {                                
            Copy-Item -Path "C:\CITIATMDeploymentStore\Scripts\AppLockerAuditOnlyMode_EXE.pol" -Destination $copydir -Force 
            }
            
            if(Test-Path("C:\CITIATMDeploymentStore\Scripts\AppLockerAuditOnlyMode_MSI.pol"))
            {                                
            Copy-Item -Path "C:\CITIATMDeploymentStore\Scripts\AppLockerAuditOnlyMode_MSI.pol" -Destination $copydir -Force 
            }
            
            if(Test-Path("C:\CITIATMDeploymentStore\Scripts\AppLockerAuditOnlyMode_Script.pol"))
            {                                
            Copy-Item -Path "C:\CITIATMDeploymentStore\Scripts\AppLockerAuditOnlyMode_Script.pol" -Destination $copydir -Force 
            }
            
            if(Test-Path("C:\CITIATMDeploymentStore\Scripts\AppLockerEnforceRulesMode.pol"))
            {                                
            Copy-Item -Path "C:\CITIATMDeploymentStore\Scripts\AppLockerEnforceRulesMode.pol" -Destination $copydir -Force 
            }
            
            if(Test-Path("C:\CITIATMDeploymentStore\Scripts\AppLockerEnforceRulesMode_DLL.pol"))
            {                                
            Copy-Item -Path "C:\CITIATMDeploymentStore\Scripts\AppLockerEnforceRulesMode_DLL.pol" -Destination $copydir -Force 
            }
            
            if(Test-Path("C:\CITIATMDeploymentStore\Scripts\AppLockerEnforceRulesMode_EXE.pol"))
            {                                
            Copy-Item -Path "C:\CITIATMDeploymentStore\Scripts\AppLockerEnforceRulesMode_EXE.pol" -Destination $copydir -Force 
            }
            
            if(Test-Path("C:\CITIATMDeploymentStore\Scripts\AppLockerEnforceRulesMode_MSI.pol"))
            {                                
            Copy-Item -Path "C:\CITIATMDeploymentStore\Scripts\AppLockerEnforceRulesMode_MSI.pol" -Destination $copydir -Force 
            }
            
            if(Test-Path("C:\CITIATMDeploymentStore\Scripts\AppLockerEnforceRulesMode_Script.pol"))
            {                                
            Copy-Item -Path "C:\CITIATMDeploymentStore\Scripts\AppLockerEnforceRulesMode_Script.pol" -Destination $copydir -Force 
            }
            
             if(Test-Path("C:\CITIATMDeploymentStore\Scripts\AppLockerNotConfiguredMode.pol"))
            {                                
            Copy-Item -Path "C:\CITIATMDeploymentStore\Scripts\AppLockerNotConfiguredMode.pol" -Destination $copydir -Force 
            }
            
            if(Test-Path("C:\CITIATMDeploymentStore\Scripts\AppLockerNotConfiguredMode_EXE.pol"))
            {                                
            Copy-Item -Path "C:\CITIATMDeploymentStore\Scripts\AppLockerNotConfiguredMode_EXE.pol" -Destination $copydir -Force 
            }
            
            if(Test-Path("C:\CITIATMDeploymentStore\Scripts\AppLockerNotConfiguredMode_MSI.pol"))
            {                                
            Copy-Item -Path "C:\CITIATMDeploymentStore\Scripts\AppLockerNotConfiguredMode_MSI.pol" -Destination $copydir -Force 
            }
            
            if(Test-Path("C:\CITIATMDeploymentStore\Scripts\AppLockerNotConfiguredMode_DLL.pol"))
            {                                
            Copy-Item -Path "C:\CITIATMDeploymentStore\Scripts\AppLockerNotConfiguredMode_DLL.pol" -Destination $copydir -Force 
            }
            
             if(Test-Path("C:\CITIATMDeploymentStore\Scripts\AppLockerNotConfiguredMode_Script.pol"))
            {                                
            Copy-Item -Path "C:\CITIATMDeploymentStore\Scripts\AppLockerNotConfiguredMode_Script.pol" -Destination $copydir -Force 
            }
            
             if(Test-Path("C:\CITIATMDeploymentStore\Scripts\AppLockerOperations.ps1"))
            {                                
            Copy-Item -Path "C:\CITIATMDeploymentStore\Scripts\AppLockerOperations.ps1" -Destination $copydir -Force 
            }
            
                        
             if(Test-Path("C:\CITIATMDeploymentStore\Scripts\DefaultRules.xml"))
            {                                
            Copy-Item -Path "C:\CITIATMDeploymentStore\Scripts\DefaultRules.xml" -Destination $copydir -Force 
            }
            
                       
             if(Test-Path("C:\CITIATMDeploymentStore\Scripts\EmptyConditionRules.xml"))
            {                                
            Copy-Item -Path "C:\CITIATMDeploymentStore\Scripts\EmptyConditionRules.xml" -Destination $copydir -Force 
            }
            
                        
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Copy-Files"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0              
            
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }

    function Clean-Files
    {
        Try
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) PowerShell Command Invoked from MDT : $($myInvocation.MyCommand)"

            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before Clean-Files"
            if (Test-Path -PathType Any "C:\Program Files\Citibank\ATMDigitalSiginigPubCert.cer") { del /f "C:\Program Files\Citibank\ATMDigitalSiginigPubCert.cer"}
            if (Test-Path -PathType Any "C:\Program Files\Citibank\ATMUserEncryptionCert.p12") { del /f "C:\Program Files\Citibank\ATMUserEncryptionCert.p12"}
            if (Test-Path -PathType Any "C:\Program Files\Citibank\Map.xml") {del /f "C:\Program Files\Citibank\Map.xml"}

            if (Test-Path -PathType Any  C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\Utilities\AdminAct.PWF) {del /f C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\Utilities\AdminAct.PWF}
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Clean-Files"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Last Exit code from PowerShell Function : $LastExitCode"
            
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Returning 0 as SUCCESS code for MDT"
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "*****************************************************************************************************"
            Exit 0              
        }
        Catch
        {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value $_.Exception.Message
            Exit $LastExitCode
        }
    }

    function Log-Details
    {
        echo stopping

        echo starting
        # Determine where to do the logging 
        $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment 
        $logPath = $tsenv.Value("_SMSTSLogPath") 
        $logFile = "$logPath\$($myInvocation.MyCommand).log"

        # Start the logging 
        Start-Transcript $logFile

        # Insert your real logic here 
        Write-Host "We are logging to $logFile"

        # Write all the variables and their values 
        $tsenv.GetVariables() | % { Write-Host "$_ = $($tsenv.Value($_))" }

        # Stop logging 
        Stop-Transcript

    }
    Function CopyPowerShellConfig
		{
			Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) Before CopyPowerShellConfig"
			
			$Config_Dest = "C:\Windows\System32\WindowsPowerShell\v1.0\"
			$Config_Src = "C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\UTILITIES"

			if(!(Test-Path($Config_Dest))) {New-Item -Path $Config_Src -ItemType "directory" -Force} 
			
			Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Creating the ReleaseVerionHandler Folder"
				Copy-Item -Path "C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\UTILITIES\PowerShell.Exe.config" -Destination "C:\Windows\System32\WindowsPowerShell\v1.0" -Force
				Copy-Item -Path "C:\CITIATMDeploymentStore\Applications\Scratch\GlobalApps\UTILITIES\powershell_ise.exe.config" -Destination "C:\Windows\System32\WindowsPowerShell\v1.0" -Force
			Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "$(Get-Date –f o) After Copying the ReleaseVerionHandler Dll and Xml"
		}	 

Function LogInstallEnd
	{
		if(Test-Path "C:\Citi.dat")
           {
                $InstallENDTime = Get-Date
				$xml=[xml](get-content -Path "C:\Citi.dat")
                $xml.MediaVarList.var | 
                Where-Object { $_.name -eq "INSTALLEND" } | 
                ForEach-Object  { [void]$xml.MediaVarList.RemoveChild($_) }
			
                $xml | Select-Xml -XPath '/MediaVarList'
                $InstallationNode = $xml.createelement("var")
                #<![CDATA[INSTALLED]]>

                $InstallationNode.setattribute("name","INSTALLEND")
                $InstallationNode.set_InnerXML("<![CDATA[" + $InstallENDTime + "]]>") 

                $xml.selectsinglenode("/MediaVarList").appendchild($InstallationNode)
                $xml.save("C:\Citi.dat")}
                Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "Installation Ends right here"
            }
            else
            {
            Add-content "C:\CITIATMDeploymentStore\GlobalApps.log" -value "CITI.dat file does not exist"
            }
    }

End
{
    #Stop-Transcript
}





