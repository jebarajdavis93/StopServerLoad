#Parameters Domain(not FQDN), User name and Password
Param ([string]$ConfigXML)
#---------------Execution Starts Here----------------------
Write-Host "Script execution started."
$global:currentDirectory = get-location
[XML]$global:serverList = get-content $ConfigXML;
[System.Collections.ArrayList]$resultArray = @() 
[System.Collections.ArrayList]$processArray = @()
#$global:cred = ServerCredential -domain $serverList.ServerProcesses.Domain -userName $serverList.ServerProcesses.UserName -password $serverList.ServerProcesses.Password
#Get LocalIPAddress
$global:localIPAddress = (gwmi Win32_NetworkAdapterConfiguration|?{$_.ipenabled}).IPAddress
$commaSeperatedJobIds="";
ForEach($serverProcess in $serverList.ServerProcesses.serverProcess) {
                ForEach ($server in $serverProcess.ServerList.Split(",")) {
                        #Iterate through processes
                        ForEach ($processName in $serverProcess.processList.Split(",")) {
                            $processes=Get-WmiObject -Class Win32_Process -ComputerName $server -Filter "Name='$processName'"                      
							$count=0;
							if($processes)
							{							
								 foreach($process in $processes)
								 {
									 $process.terminate();
									 $count++;
								 }								 
							}	
							$objProcess = [PSCustomObject] @{ ServerName = $server; processName = $processName; ProcessCount = $count; }
                            $processArray.Add($objProcess);							
                        }
                    }
    }
 $outputReport = "<HTML><TITLE align=center> Server Health Check Report </TITLE> 
                     <BODY background-color:peachpuff> 
                     <font color =""#99000"" face=""Microsoft Tai le""> 
                     <H2> Stop server load Report </H2></font> 
                     <font color =""#0000FF"" face=""Microsoft Tai le""> 
                   <H3> Status On Individual VHEs</H3></font>
                   <Table border=1 cellpadding=0 cellspacing=0> 
                        <TR bgcolor=""#CED8AB""><TD><B>ServerName</B></TD>
                        <TD><B>Process Name</B></TD> 
                        <TD><B>Number of processes ended</B></TD></TR>";

Foreach($processEntry in $processArray)  {

	#$tableData = "<TD align=center bgcolor=""green"">$($processEntry.ProcessCount)</TD>";
	$tableData = "<TD align=center >$($processEntry.ProcessCount)</TD>";

    $outputReport +="<TR><TD align=center>$($processEntry.ServerName)</TD><TD align=center>$($processEntry.processName)</TD>" + $tableData + "</TR>";
}
$outputReport += "</Table><BR /></BODY></HTML>";
$fileName = "Results_" + [DateTime]::Now.ToString("yyyyMMddHHmmss") + ".htm"
$outputReport | out-file (Join-Path $currentDirectory.Path -childPath $fileName);  

Write-Host "Script execution completed and results file " $fileName " available in " $currentDirectory.Path " path";
#----------------- Execution ends here--------------------------------------