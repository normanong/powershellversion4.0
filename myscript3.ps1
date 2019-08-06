#create a schedule or change task detail through web-base
param
(
$schedulename,
$triggertime,
$triggertype,
$dayofweek,
$dayofinterval,
$weekofinterval
)

$convert=write-host "schedule name: $schedulename triggertime : $triggertime triggertype: $triggertype weekofinterval: $weekofinterval dayofweek: $dayofweek dayofinterval: $dayofinterval"
$convert2=$convert | ConvertTo-Html
return $convert2

if($triggertype -match "daily"){
if($dayofinterval -eq 1){
$action = (New-ScheduledTaskAction -Execute 'Powershell.exe'),(New-ScheduledTaskAction -Execute 'chrome.exe')
$trigger =  New-ScheduledTaskTrigger -Daily -At $triggertime

Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $schedulename -Description "Daily dump of Applog"

$process="trigger type daily n day of interval =1"
$converhtml=$process | ConvertTo-Html
return $converhtml
}
else{
$action = (New-ScheduledTaskAction -Execute 'Powershell.exe'),(New-ScheduledTaskAction -Execute 'chrome.exe')
$trigger =  New-ScheduledTaskTrigger -Daily -DaysIntervals $dayofinterval -At $triggertime

Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $schedulename -Description "Daily dump of Applog"
$process="trigger type daily n day of interval more than 1"
$converhtml=$process | ConvertTo-Html
return $converhtml
}
}
elseif($triggertype -match "weekly"){
if($dayofinterval -eq 1){
$action = (New-ScheduledTaskAction -Execute 'Powershell.exe'),(New-ScheduledTaskAction -Execute 'chrome.exe')
$trigger =  New-ScheduledTaskTrigger -Daily -At $triggertime

Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $schedulename -Weekly -WeeksInterval $weekofinterval -DaysOfWeek $dayofweek -Description "Daily dump of Applog"
$process="trigger type weekly"
$converhtml=$process | ConvertTo-Html
return $converhtml
}
}
