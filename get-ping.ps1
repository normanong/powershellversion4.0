clear-host
#Get-Ping -Server www.google.com -Minutes 1
#Test-Connection -ComputerName "http://192.168.200.132/DailyRpt"
#$server="http://192.168.200.132/DailyRpt"
#$ping = ping $Server -n 1 | Where-Object {$_ -match "Reply" -or $_ -match "Request timed out" -or $_ -match "Destination host unreachable"} 
#$ping
$timeoutSeconds = 5 # set your timeout value here
$j = Start-Job -ScriptBlock {
$HTTP_Request = [System.Net.WebRequest]::Create('http://192.168.200.132/DailyRpt')

# We then get a response from the site.
$HTTP_Response = $HTTP_Request.GetResponse()
# We then get the HTTP code as an integer.
$HTTP_Status = [int]$HTTP_Response.StatusCode
    }
"job id = " + $j.id # report the job id as a diagnostic only
Wait-Job $j -Timeout $timeoutSeconds | out-null
if ($j.State -eq "Completed") { "done!" }
elseif ($j.State -eq "Running") 
{ get-scheduledtask -taskname "windowlooping" |Disable-ScheduledTask   
Write-host "GGGGGGGGGGGGGGGGGGGGGG"
}
Remove-Job -force $j #cleanup