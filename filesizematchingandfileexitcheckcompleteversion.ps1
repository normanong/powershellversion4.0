clear-host
$filename=@()
$filesize=@()
$scheduledtaskname=@()
$getdata= import-csv C:\Alert\testerforpowershell.csv
$filetocheck=import-csv C:\Alert\filetocheck.csv
$filetocheckcount=$filetocheck.count
if($filetocheckcount -eq 1){
for($a=0;$a -lt $filetocheckcount;$a++){
$filename=$filetocheck."file name"
$filesize=$filetocheck."file size"
$scheduledtaskname=$filetocheck."name of handled scheduletask"
}
}
else{
for($a=0;$a -lt $filetocheckcount;$a++){
$filename+=$filetocheck."file name"[$a]
$filesize+=$filetocheck."file size"[$a]
$scheduledtaskname+=$filetocheck."name of handled scheduletask"[$a]
}
}
$filecount=$filename.count
$getdatacount=$getdata.count
for($b=0; $b -lt $filecount ; $b++){
$founded=0
$missing=0
$correct=0
$tempfilename=$filename[$b]
[int]$tempfilesize=$filesize[$b]
for($c=0;$c -lt $getdatacount ; $c++){

if($tempfilename -match $getdata."file name"[$c]){
$founded=1
[int]$size=$getdata."size"[$c]
$tempfilesize
[int]$maxsize=$size+0.5
[int]$minsize=$size-0.5
if($tempfilesize -notin $minsize..$maxsize){
write-host "FKUP"
}else{
$correct=1
}
}
else{
$missing=1
}
}
if(($missing -eq 1 )-and($founded -eq 0)){
write-host "$tempfilename doesn't exits"
$tempscheduledtaskname=$scheduledtaskname[$b]
$tempscheduledtaskname
get-scheduledtask -taskname $tempscheduledtaskname | disable-scheduledtask 
}
elseif(($founded -eq 1) -and( $correct -eq 0)){
write-host "$tempfilename doesn't generate completely"
$tempscheduledtaskname=$scheduledtaskname[$b]
$tempscheduledtaskname
get-scheduledtask -taskname $tempscheduledtaskname | disable-scheduledtask 
}
elseif(($founded -eq 1) -and( $correct -eq 1)){
write-host "$tempfilename generate completely"
}

}
