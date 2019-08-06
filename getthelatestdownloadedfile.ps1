clear-host
#$getdata=import-csv C:\Users\intern_comm\Downloads\table_dump '('1')'.csv
#$getdata
$filearray=@()
$file=Get-ChildItem -path  C:\Users\intern_comm\Downloads | Where-Object { $_.Name -match 'table_dump_[0-9]{10}.csv$' } 
$filecount=$file.count
if($filecount -gt 1){
for($a=0;$a -lt $filecount ; $a++){
$filearray+=("C:\Users\intern_comm\Downloads\"+$file[$a])
}
$latest=$filearray[$filecount-1]
}
else{
$latest=$file
}
$latest
$arraytaskname=@{}
$arrayrecipient=@{}
$data= import-csv $latest
$datacount=$data.count
$latestdata=$data[$datacount-1] #$datacount-1 -original code
$taskname=import-csv C:\Alert\taskname.csv
$emaildetail=import-csv C:\Alert\email.csv
$tasknamecount=($taskname.psobject.Properties.name).count
$tasknamecount
$emaildetailcount=($emaildetail.psobject.properties.name).count
if($tasknamecount -eq 1){
$temptaskname=$taskname.psobject.Properties.name
$temptasknamevalue=$taskname.$temptaskname
 $arraytaskname.add($temptaskname,$temptasknamevalue)
}
else{
    for($a=0;$a -lt $tasknamecount ;$a++){
    $temptaskname=$taskname.psobject.Properties.name[$a] 
    $temptasknamevalue=$taskname.$temptaskname 
    $arraytaskname.add($temptaskname,$temptasknamevalue)
       }

}
if($emaildetailcount -eq 1){
$temptaskname=$emaildetail.psobject.properties.name
$recipient=$emaildetail.$temptaskname
$arrayrecipient.add($temptaskname,$recipient)
}
else{
    for($a=0;$a -lt $emaildetailcount;$a++){
    $temptaskname=$emaildetail.psobject.properties.name[$a]
    $recipient=$emaildetail.$temptaskname
    $arrayrecipient.add($temptaskname,$recipient)
    }
}
$latestdata
write-host "AAAAAAAAAAAAAAAAAAA"
$newtaskname=$latestdata."SCHEDULETASKNAME"
$recipientemail=$latestdata."RECIPIENTEMAIL"
$value=$tasknamecount
$newtaskname
$recipientemail
$arraytaskname.add($newtaskname,$value)
$arrayrecipient.add($newtaskname,$recipientemail)

$format = new-object psobject -property $arraytaskname
$format | Export-csv C:\Alert\taskname2.csv
$format2 = new-object psobject -property $arrayrecipient
$format2 | Export-csv C:\Alert\email2.csv



