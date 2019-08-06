clear-host
$bigdata=@()
$numberoffile=read-host "pls enter the number of the file that you want to host"
[int]$numberoffile+=1
$numberoffile
for($a=0 ; $a -lt $numberoffile ; $a++){
if($a -eq 0){
$combine=@()
$completecombination=@()
$combine+="file name"
$combine+="file size"
$combine+="name of handled scheduletask" 
$completecombination+=($combine -join ",")
$bigdata+=$completecombination
}
else{
$combine=@()
$completecombination=@()
$filename=read-host "pls enter the file name"
$filesize=read-host "pls enter the file size"
$scheduledtaskname=read-host "pls enter the scheduled task name"
$combine+=$filename 
$combine+=$filesize 
$combine+=$scheduledtaskname
$completecombination+=($combine -join ",")
$bigdata+=$completecombination
}
}

$bigdata|Select-Object -Unique |Set-Content -Encoding ASCII C:\Alert\filetocheck.csv