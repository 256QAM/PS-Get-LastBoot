function Get-LastBoot {
	[CmdletBinding()]
	param(
		[Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
		[string[]]$Computer=($Env:COMPUTERNAME),
		[System.Management.Automation.CredentialAttribute()]$Credential
    )
	
	begin {}
	
	process {
		foreach ($ComputerName in $Computer) {
			if (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) {
				try {
					$wmi = Get-WmiObject Win32_OperatingSystem -ComputerName $ComputerName -Credential $Credential -ErrorAction Stop
				} catch {
					$WMIError = $_.exception.message
					$wmi = $null
				}
				if ($wmi -ne $null) {
					$Result = [PSCustomObject]@{
						ComputerName = $wmi.csname
						BootTime = [string]$wmi.ConvertToDateTime($wmi.LastBootUpTime)
					}
				} else {
					$Result = [PSCustomObject]@{
						ComputerName = $ComputerName
						BootTime = $WMIError
					}
				}
			} else {
				$Result = [PSCustomObject]@{
					ComputerName = $ComputerName
					BootTime = @("Not Reachable")
				}
			}
			Write-Output $Result
		}
	}
	
	end {}
}