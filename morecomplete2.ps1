clear-host
$combine=@()
$weekintevalndayofweek=@{}
$dayinterval=@{}
$importtrack=@()
#$taskname=@()
#$task=@()
#$triggerler=@()
$splittingsymbol="T"
$arraydatentime=@{}
$disabledcounter=0
$splitting=@()
$startboundary=@()
$startboundarytimecatch=@()
##############################
$tasknamearray=@() #to collect the input form user in array form
$referencetaskname=@{}
$newtasknamearray=@{}
$temparray1=@()
$scheduledtaskinfoarray=@()
$scheduledtaskarray=@()
$failrecordtime=@{}
$successrecordtime=@{}
$arrayformailing=@{}
[int]$disable=0#to record number of time that the task disable
[int]$enable=0#to record number of time that the task enable
$failledtaskname=@{}# store the value and key that the scheudled task is fail
$successtaskname=@{}# store the value and key that the scheudled task is success
$test=(test-path C:\Alert\record.csv)#to check where this false is create 
$test1=(test-path C:\Alert\taskname.csv)
$test2=(test-path C:\Alert\completedata.csv)
$retrieveuserinput=import-csv C:\Alert\taskname.csv
$retrieveuseremail=import-csv C:\Alert\email.csv
$retrieveuserinputname=@()
$directsuccesscompletedata=@{}
$datacount=($getdata.psobject.properties.name).count
[int]$counter=0
if($test -eq $false){ 
if($test1 -eq $true){
for($a=0 ; $a -lt $datacount;$a++){#for the $numberofscheduledtaskneedtohost have to change to the size of the (taskname.csv).count 
$retrieveuserinputname+=$retrieveuserinput.psobject.properties.name[$a]#retrieve userarray 
$tasknamearray+=$retrieveuserinputname[$a]
[string]$key=$tasknamearray[$a] 
$value=$a+1
$referencetaskname.add($key,$value)
$retrieveemail=$retrieveuseremail.$key
$arrayformailing.add($key,$retrieveemail)
}
}

else{
$numberofscheduledtaskneedtohost=read-host "enter the total number of scheduled task"#ask the user that hw many sheduledtask that user want to host 
for($a=1 ; $a -le $numberofscheduledtaskneedtohost;$a++){
$taskname=read-host "pls enter the task name that u want to host"
$mailingaddress=read-host "pls enter the mailing address for $taskname to senf if fail"
$tasknamearray+=$taskname#store the user input into array 
$mailsaver+=$mailingaddress
$referencetaskname.add($taskname,$a)
$arrayformailing.add($taskname,$mailingaddress)
$temptaskname=$taskname
$task=get-scheduledtask -taskname $temptaskname 
$triggerler=$task.triggers 
$triggerler| export-csv C:\Alert\triggerdata$temptaskname.csv
}
}
###############################################################
for($b=0;$b -lt $numberofscheduledtaskneedtohost ;$b++){
$temptaskname=$tasknamearray[$b]
$datatriggerle=import-csv C:\Alert\triggerdata$temptaskname.csv
$startboundary+=$datatriggerle.psobject.properties.name
$startboundarytimecatch+=$datatriggerle.startboundary
$tempstartboundarytimecatch=$startboundarytimecatch[$b]
$splitting+=$tempstartboundarytimecatch.split($splittingsymbol)
}

for($c=0;$c -lt  $numberofscheduledtaskneedtohost ;$c++){
$temptaskname=$tasknamearray[$c]
$key=$temptaskname
$d=$c*2
$arraymerge=$splitting[$c*2]+" "+$splitting[$d+1]
$arraydatentime.add($key,$arraymerge)
}

for($e=0;$e -lt $numberofscheduledtaskneedtohost ;$e++){
$temptaskname=$tasknamearray[$e]
$importtrack+=import-csv C:\Alert\triggerdata$temptaskname.csv
if($importtrack[$e] -match "daysinterval"){
$temptaskname=$tasknamearray[$e]
$key=$temptaskname
$dinterval=$importtrack[$e].daysinterval
$dayinterval.add($key,$dinterval)
}
elseif(($importtrack[$e] -match "weeksinterval")-and ($importtrack[$e] -match "daysofweek")){
$temptaskname=$tasknamearray[$e]
$key=$temptaskname
$winterval=$importtrack[$e].weeksinterval
$dofweek=$importtrack[$e].daysofweek 
$combine=($winterval+","+$dofweek)
$weekintevalndayofweek.add($key,$combine)
}

}
$dailyinterval=new-object psobject -property $dayinterval
$dailyinterval | Export-Csv C:\Alert\dayinterval.csv 
$weeklyintervaldayofweek=new-object psobject -property $weekintevalndayofweek
$weeklyintervaldayofweek | Export-Csv C:\Alert\weekintervalndaysofweek.csv
$arraysdatentime=new-object psobject -property $arraydatentime
$arraysdatentime | Export-Csv C:\Alert\time.csv

###############################################################
$a=0
do{
$temptaskname=$tasknamearray[$a]
$getscheduledtaskinfo= get-scheduledtask -taskname "$temptaskname" | get-scheduledtaskinfo | select-object -property lastruntime #get the full detail of scheduled task info 
$getscheduledtask= get-scheduledtask -taskname "$temptaskname" | select-object -property taskname,state #get the selected detail of scheduled task info
$scheduledtaskinfoarray+=$getscheduledtaskinfo # store the full scheduled task info into it own array
$scheduledtaskarray+=$getscheduledtask# store the selected info of the scheduled task into it own array
if($getscheduledtask.state -eq "disable"){ # check whether the scheduled task that used hosted is disable or not
$disable=1
$disabledcounter+=1
$ttemptaskname=$temptaskname+"-disable" #store the taskname and re-lable into it own situation
$key=$ttemptaskname #set it taskname as a key 
$value=$disable#set the counter as a value 
$failledtaskname.add($key,$value)# store the key and value intoit own hashted array
$failrecordtime.add($key,$scheduledtaskinfoarray[$a])
write-host "task name ($temptaskname): rebooting `n "# let the user known that which taskname is rebooting
get-scheduledtask -taskname "$temptaskname" | enable-scheduledtask #rebooting the task that the state is disable
################################################################

$splittingforexecution=" "
$ts = New-TimeSpan -seconds 10
[string]$execution=(get-date) + $ts
$execution
$formatedexecution=$execution.split($splittingforexecution)
$value=$formatedexecution[1]
$Time = New-ScheduledTaskTrigger -At $value -once
Set-ScheduledTask -TaskName "$temptaskname" -Trigger $Time
#test
write-host "gg"
###############################################################
}
else{
$enable=1
$ttemptaskname=$temptaskname+"-enable"  #store the taskname and re-lable into it own situation
$key=$ttemptaskname#set it taskname as a key
$value=$enable#set the counter as a value
$successtaskname.add($key,$value)# store the key and value into it own hashted array
$successrecordtime.add($key,$scheduledtaskinfoarray[$a])
write-host "`n task name ($temptaskname): are run well and smooth `n"# let the user known that which taskname is run smoothly
}
$a+=1
}while($a -lt $numberofscheduledtaskneedtohost ) #only the first time for user set-up , so loop one time only
$successcount=$successtaskname.count 
$inputcount=$tasknamearray.count
$newcount=$inputcount+1
$newcount
if($successcount -eq $inputcount){
for($a=0; $a -le $newcount ; $a++){
if($a -eq 0){
$temparray2=@()
$temparray2+="name"
$temparray2+="numberofrun"
$temparray2+="lastruntime"
$temparray1+=($temparray2 -join ",")
}
else{
$temparray2=@()
$key=$tasknamearray[$a-1]+"-enable"
[string]$countvalue=$successtaskname.$key
[string]$timevalue=$successrecordtime.$key
$lastruntimeformat=[regex]::matches($timevalue,'(?<=@{lastruntime=).+?(?=})').value
$temparray2+=$key
$temparray2+=$countvalue
$temparray2+=$lastruntimeformat
$temparray1+=($temparray2 -join ",")
}
}
$temparray1 |Select-Object -Unique |Set-Content -Encoding ASCII C:\Alert\completedata.csv
#$temparray1 |Select-Object -Unique |Set-Content -Encoding ASCII C:\Alert\completedata2.csv
#Get-Content C:\Alert\completedata2.csv, C:\Alert\completedata.csv |Set-Content -Encoding ASCII C:\Alert\completedata3.csv
}
#$scheduledtaskinfoarray#show up the scheduled task info

$failrecordtime
$mergingrecordtask=$failrecordtime+$successrecordtime
$formatrecordtime=new-object psobject -property $mergingrecordtask # finding the origin 
$formatrecordtime | export-csv C:\Alert\recordtime.csv
$scheduledtaskarray#show up the selected info of the scheduled task 
write-host "total current disable: $disabledcounter `n" #shpw the total current disable scheduled task
$recordtask=$successtaskname+$failledtaskname # join to array into one array
$formatrecordtask=new-object psobject -property $recordtask
$formatrecordtask | export-csv C:\Alert\record.csv
$formatemail=new-object psobject -property $arrayformailing
$formatemail | export-csv C:\Alert\email.csv 
$formattaskname=new-object psobject -property $referencetaskname
$formattaskname | Export-Csv C:\Alert\taskname.csv 
$counter=1

}

elseif($test2 -eq $false){
[string][ValidateNotNullOrEmpty()] $userPassword = "ming1234"
$userpass = ConvertTo-SecureString -String $userPassword -AsPlainText -Force
$userCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "normanong888@gmail.com", $userpass
$mailcounter=0
$disablecounter=0
$hashedarraytime=@{}
$hashedarray=@{}
$newformatarray=@{}
$newformattimearray=@{}
$pointedstatus=@()
$latesttimeinfoarray=@()
$latestscheduledtaskarray=@()
$newscheduledtaskinfoarray=@()
$newscheduledtaskarray=@()
$datachecker=@()
$keyarray=@()#store the $key that store in csv file
$csvtaskname=@()#store the complete spliting $key version that we want
$gettime=import-csv C:\Alert\recordtime.csv
$getdata=import-csv C:\Alert\record.csv # import the recorded data 
$getemail=import-csv C:\Alert\email.csv
$numberofreferencetask=($getdata.psobject.properties.name).count# count total $key that store in csv file 
$numberofreferencetask
for($a=0; $a -lt $numberofreferencetask;$a++){
$key=$getdata.psobject.properties.name[$a]
$timeinname=$gettime.$key
$hashedarraytime.add($key,$timeinname)
$value=$getdata.$key
$hashedarray.add($key,$value)
}
 
if($numberofreferencetask -gt 2){
for($a=0; $a -lt $numberofreferencetask;$a++){#for this loop is to store the $key that store in csv file into new array 
$keyarray+= $getdata.psobject.properties.name[$a]                          
}
}
else{
$keyarray+=$getdata.psobject.properties.name
}
$splitingpart="-"# spliitting symbol
$keyarray
$aftersplitcount=($keyarray.split($splitingpart)).count # to get the total amount after splitting those data

if($aftersplitcount -gt 2){
for($a=0;$a -lt ($aftersplitcount/2);$a++){ #this looping is to collect that spliting part that we need 
$csvtaskname+=$keyarray.split($splitingpart)[$a*2]# the reason of multiply two cuz for every scehduledtadk we add the situation behind so example: array[0]:joker,array[1]:-disable,array[2]:jonker,array[3]:-disable and we just want the joker and jonker
}

}
elseif($aftersplitcount -le 2){
for($a=0;$a -lt $numberofscheduledtaskneedtohost;$a++){ #this looping is to collect that spliting part that we need 
$csvtaskname+=$keyarray.split($splitingpart)[$a]# the reason of multiply two cuz for every scehduledtadk we add the situation behind so example: array[0]:joker,array[1]:-disable,array[2]:jonker,array[3]:-disable and we just want the joker and jonker
}

}

$disableloopingcount=$csvtaskname.count

for($a=0;$a -lt $disableloopingcount  ;$a++){#

$passcsvtaskname=$csvtaskname[$a]# the variable will store the completekey in the array and use on the get-scheudled task since it cannot directly use in array form
$getnewscheduletaskinfo= get-scheduledtask -taskname $passcsvtaskname | get-scheduledtaskinfo |select-object -property lastruntime
$getnewscheduledtask= get-scheduledtask -taskname $passcsvtaskname  | select-object -property taskname,state
$newscheduledtaskinfoarray+=$getnewscheduletaskinfo#those scheduled task info are store into its own array
$newscheduledtaskarray+=$getnewscheduledtask #those selected info of scheduled task are store into its own array
}


$countcsvtaskname=($newscheduledtaskarray.state -eq 'disable').count
for($a=0; $a -lt $countcsvtaskname;$a++){
$disablecounter+=1
}

for($a=0;$a -lt $disableloopingcount;$a++){#*change to count disable task name 
#this loop is to assign the complete $key splitting into a TEMPARARILYKEY array
$tempkey=$keyarray[$a]
if($getdata.$tempkey -lt 2 ){#if the $value of the $key is less than 2 then process 
for($b=0;$b -lt $disableloopingcount;$b++){ #this looping is to loop the multiple scheduled task one by one and check whether there is still got disable state 
if($newscheduledtaskarray.state[$b] -eq 'disable') {#to check whether the state of the scheduled task is still disable
$csvtaskname[$b]
$matchingname=$csvtaskname[$b]+"-disable"#store the scheduled task name with their current situation 
[int]$valueinside=$getdata.$matchingname#get the current $value od the $key
$newvalue=$valueinside+1#adding the value if previous it will and currently fail again 
get-scheduledtask -taskname $csvtaskname[$b] | enable-scheduledtask # enable the scheduled task name that the state is disable 
if($newvalue -gt 2){
$newvalue=2
$getdata.$matchingname-$newvalue
}

##############################################

$splittingforexecution=" "
$ts = New-TimeSpan -seconds 20
[string]$execution=(get-date) + $ts
$execution
$formatedexecution=$execution.split($splittingforexecution)
$value=$formatedexecution[1]
$Time = New-ScheduledTaskTrigger -At $value -once
Set-ScheduledTask -TaskName $csvtaskname[$b] -Trigger $Time

##############################################

$getdata.$matchingname=$newvalue#adding back the newvalue into the $key
$latestscheduledtasktime=get-scheduledtask -taskname $csvtaskname[$b] | get-scheduledtaskinfo | select-object -property lastruntime 
$latestscheduledtaskstate=get-scheduledtask -taskname $csvtaskname[$b] | select-object -property taskname,state
$latesttimeinfoarray+=$latestscheduledtasktime
$latestscheduledtaskarray+=$latestscheduledtaskstate
$countforlatestscheduledtaskarray=$latestscheduledtaskarray.count

if($latestscheduledtaskarray.state[$b] -eq 'ready'){
$currentname=$csvtaskname[$b]+"-disable"
$newmatchingname=$csvtaskname[$b]+"-enable"
$name=$newmatchingname
$getthetime=$latesttimeinfoarray[$b]
$enablevalue=1
$newformatarray.add($name,$enablevalue)
$newformattimearray.add($name,$getthetime)
$mailcounter+=1
}
if(($getdata.$tempkey -eq 2) -and ($latestscheduledtaskarray.state[$a] -eq "ready") -and ($mailcounter -le $disablecounter )){#*if the $key value is loop adding until 2 it will send message
$sendfailtaskname=$csvtaskname[$b]
$mail=$getemail.$sendfailtaskname
$From = "normanong888@gmail.com"
$To = "$mail "
#$Cc = "AThirdUser@somewhere.com"
#$Attachment = "C:\users\Username\Documents\SomeTextFile.txt"
$Subject = "Here's the Email Subject"
$Body = "$sendfailtaskname scheduledtask are fail to run "
$SMTPServer = "smtp.gmail.com"
$SMTPPort = "587"
Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential $userCredential –DeliveryNotificationOption OnSuccess
}
}
}
}
}
$tranformarray2=@{}
$previoustaskkey=@()
$previoustaskvalue=@()
$previoustasktime=@()
$completeprevioustasktimestamp=@{}
$completeprevioustaskhistory=@{}
$compilearray=@{}
$keystore=@()
$array1=@()
$array2=@{}
$array2time=@{}
$duplicatedarray=@()
$completename=@()
$compilearray=$hashedarray+$newformatarray
$newformatarraycount=$newformatarray.count


$array2=$hashedarray+$newformatarray
$array2time=$hashedarraytime+$newformattimearray
$hashedarray
write-host "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"
$newformatarray
write-host "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"
$hashedarraytime 
write-host "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"
$newformattimearray


$compilearraycount=($compilearray).count
$previousdatcount=($getdata.psobject.properties.name).count
for($a=0;$a -lt $previousdatcount ;$a++){
$previoustaskkey+=$getdata.psobject.properties.name[$a]
}

for($a=0;$a -lt $previousdatcount ;$a++){
$transmitter=$previoustaskkey[$a]
$previoustaskvalue+=$getdata.$transmitter
$previoustasktime+=$gettime."$transmitter"
}

for($a=0;$a -lt $previousdatcount ;$a++){
$completeprevioustaskhistory.add($previoustaskkey[$a],$previoustaskvalue[$a])
$completeprevioustasktimestamp.add($previoustaskkey[$a],$previoustasktime[$a])
}

for($a=0;$a -lt $compilearraycount;$a++){
$array1+=$compilearray.keys[$a]
}
$splittingsymbolforarray="-"
$splittingsymbolforarraycount=($array1.split($splittingsymbolforarray)).count 
for($a=0;$a -lt $splittingsymbolforarraycount;$a++){
$completename+=$array1.split($splittingsymbolforarray)[$a*2]
}
$duplicatedarray+=($completename | Group | ?{$_.count -eq 2}).Name
$countduplicatedarray=$duplicatedarray.count
if(($countduplicatedarray -gt 0)){
for($a=0; $a -lt $countduplicatedarray; $a++){
$checkername=($duplicatedarray[$a]+"-disable")
if($checkername -match $array2.keys[$a+1]){
$removename=$checkername
$array2time.remove("$removename")
$array2.remove("$removename")
}
}
}

$getdata
$getdata | export-csv C:\Alert\record.csv -NoTypeInformation #update the value 
#########################################################

foreach($name in $array2.keys){

$keystore+=$name
}

$arraycounter=$array2.count

for($z=0;$z -lt $arraycounter  ;$z++){

$name=$keystore[$z]
$key=$name
$value=$array2.$name
$tranformarray2.add($key,$value)
}

#$tranformarray2
#$tranformarray2.count
$formatttt = new-object psobject -property $tranformarray2
$formatttt| export-csv C:\Alert\record1.csv 

#########################################################

#condition replacement 
<#
for($a=0;$a -lt $compilearraycount;$a++){
if(($array2.keys[$a] -match "-disable")-and ($array2time.keys[$a] -match "-disable")){
$array2.keys[$a] -replace "-disable","-enable"
$array2time.keys[$a] -replace "-disable","-enable"
}
}
#>

$ggg=new-object psobject -property $array2time
$ggg| export-csv C:\Alert\recordtime1.csv

$getlatestcount=import-csv C:\Alert\record1.csv
$getlatestlastruntime=import-csv  C:\Alert\recordtime1.csv

$getlatestcountcounter=($getlatestcount.psobject.Properties.name).count
$getlatestcountcounter+=1
$getlatestcountcounter
$completearray=@()
for($a=0 ; $a-lt $getlatestcountcounter ;$a++){
if($a -eq 0){
$temparray=@()
$temparray+="name"
$temparray+="numberofrun"
$temparray+="lastruntime"
$completearray+=($temparray -join ",")
}
else{
$temparray=@()
$conditionname=$keystore[$a-1]
$temparray+=$conditionname
$temparray+=$getlatestcount.$conditionname
$lastruntime=$getlatestlastruntime.$conditionname
$temparray+=[regex]::matches($lastruntime,'(?<=@{lastruntime=).+?(?=})').value
$completearray+=($temparray -join ",")
##write-host "GGGGGGGGGGGGGGGGGGGGGGGGGGGG"
}
}
$completearray
$completearray |Select-Object -Unique |Set-Content -Encoding ASCII C:\Alert\completedata.csv
#Get-Content C:\Alert\record1.csv, C:\Alert\recordtime1.csv |Select-Object -Unique |Set-Content -Encoding ASCII C:\Alert\completedata.csv
#$completedata
#$getnewdata = import-csv C:\Alert\record1.csv
#$getnewtimedata=import-csv C:\recordtime1.csv 
#$getnewdata | export-csv C:\Alert\recordtime.csv
$counter=1
}

##########################################
if($counter -eq 1){
 Start-Sleep -seconds 1
$getdayinterval=import-csv C:\Alert\dayinterval.csv 
$getweekinterval=import-csv  C:\Alert\weekintervalndaysofweek.csv
$getoriginaltime=import-csv C:\Alert\time.csv
$f=0
$calculation=0
$getdayintervalname=@()
$getweekintervalname=@()
$arraytotalcount=0
$charger1=0
$charger2=1
$arraycombinecount=@()
$arraycombine=@()
$gettaskname=@()
$referencetaskname=@()
$timetaskname=@()
$weekinterval=@()
$weekofday=@() 
$timeformat=@()
$valueofdayinterval=@()
$getoriginaltimecount=($getoriginaltime.psobject.properties.name).count
$getdayintervalcount=($getdayinterval.psobject.properties.name).count
$getweekintervalcount=($getweekinterval.psobject.properties.name).count
$totalcount=$getdayintervalcount+$getweekintervalcount
for($a=0 ; $a -lt $getdayintervalcount; $a++){
$getdayintervalname+=$getdayinterval.psobject.properties.name
$timetaskname+=$getdayintervalname[$a]
}

for($a=0 ; $a -lt $getweekintervalcount; $a++){
$getweekintervalname+=$getweekinterval.psobject.properties.name
$timetaskname+=$getweekintervalname[$a]
}

$splittingsymbolofvalueofweekinterval=","
for($aa=0 ; $aa -lt $totalcount ;$aa++){

if($getweekintervalcount -eq 1){
$formationchange=$getweekinterval.psobject.properties.name
}
elseif($getweekintervalcount -gt 1){
$formationchange=$getweekinterval.psobject.properties.name[$aa-$getdayintervalcount]
}


if($timetaskname[$aa] -like $getdayinterval.psobject.properties.name[$aa]){
$tempttaskname=$timetaskname[$aa]
$valueofdayinterval+=$getdayinterval.$tempttaskname
}
elseif($timetaskname[$aa]-like $formationchange){
$tempttaskname=$timetaskname[$aa]
$valueofweekinterval=$getweekinterval.$tempttaskname
#$valueofweekinterval
#write-host "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
$newformatvalueofweekinterval=$valueofweekinterval.split($splittingsymbolofvalueofweekinterval)
#$newformatvalueofweekinterval
#write-host "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
$countarray=($newformatvalueofweekinterval).count
#$countarray
#write-host "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
for($bb=0;$bb -lt $countarray/2;$bb++){
$splittingarray=@()
$splittingarray+=$newformatvalueofweekinterval.split(" ")
#$splittingarray
#write-host "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
$weekinterval=$splittingarray[$bb]
$dayofthewekinterval=$splittingarray[$bb+1]
}
}

if($aa -ge $getdayintervalcount){
[int]$gg=$dayofthewekinterval
for($a=0 ; $a -lt 1; $a++){
$arraydayfweektrigger=@()
$monday=0 
$tuesday=0
$wednesday=0
$thursday=0
$friday=0
$saturday=0 
$sunday=0
if($gg -ge 64){
$saturday=1
$remainder1=$gg%64
$arraydayfweektrigger+="saturday"
if(($remainder1 -ge 32)-and ($remainder1 -ne $gg)){
$friday=1
$remainder1=$remainder1%32
$arraydayfweektrigger+="friday"
}
if(($remainder1 -ge 16)-and ($remainder1 -ne $gg)){
$thursday=1
$remainder1=$remainder1%16
$arraydayfweektrigger+="thursday"
}
if(($remainder1 -ge 8)-and ($remainder1 -ne $gg)){
$wednesday=1
$remainder1=$remainder1%8
$arraydayfweektrigger+="wednesday"
}
if(($remainder1 -ge 4)-and ($remainder1 -ne $gg)){
$tuesday=1
$remainder1=$remainder1%4
$arraydayfweektrigger+="tuesday"
}
if(($remainder1 -ge 2)-and ($remainder1 -ne $gg)){
$monday=1
$remainder1=$remainder1%2
$arraydayfweektrigger+="monday"
}
if(($remainder1 -ge 1)-and ($remainder1 -ne $gg)){
$sunday=1
$remainder1=$remainder1%1
$arraydayfweektrigger+="sunday"
}
}#2
elseif($gg -ge 32){
$friday=1
$remainder1=$gg%32
$arraydayfweektrigger+="friday"
if(($remainder1 -ge 16)-and ($remainder1 -ne $gg)){
$thursday=1
$remainder1=$remainder1%16
$arraydayfweektrigger+="thursday"
}
if(($remainder1 -ge 8)-and ($remainder1 -ne $gg)){
$wednesday=1
$remainder1=$remainder1%8
$arraydayfweektrigger+="wednesday"
}
if(($remainder1 -ge 4)-and ($remainder1 -ne $gg)){
$tuesday=1
$remainder1=$remainder1%4
$arraydayfweektrigger+="tuesday"
}
if(($remainder1 -ge 2)-and ($remainder1 -ne $gg)){
$monday=1
$remainder1=$remainder1%2
$arraydayfweektrigger+="monday"
}
if(($remainder1 -ge 1)-and ($remainder1 -ne $gg)){
$sunday=1
$remainder1=$remainder1%1
$arraydayfweektrigger+="sunday"
}
}#3
elseif($gg -ge 16){
$thursday=1
$remainder1=$gg%16
$arraydayfweektrigger+="thursday"
if(($remainder1 -ge 8)-and ($remainder1 -ne $gg)){
$wednesday=1
$remainder1=$remainder1%8
$arraydayfweektrigger+="wednesday"
}
if(($remainder1 -ge 4)-and ($remainder1 -ne $gg)){
$tuesday=1
$remainder1=$remainder1%4
$arraydayfweektrigger+="tuesday"
}
if(($remainder1 -ge 2)-and ($remainder1 -ne $gg)){
$monday=1
$remainder1=$remainder1%2
$arraydayfweektrigger+="monday"
}
if(($remainder1 -ge 1)-and ($remainder1 -ne $gg)){
$sunday=1
$remainder1=$remainder1%1
$arraydayfweektrigger+="sunday"
}
}#4
elseif($gg -ge 8){
$wednesday=1
$remainder1=$gg%8
$arraydayfweektrigger+="wednesday"
if(($remainder1 -ge 4)-and ($remainder1 -ne $gg)){
$tuesday=1
$remainder1=$remainder1%4
$arraydayfweektrigger+="tuesday"
}
if(($remainder1 -ge 2)-and ($remainder1 -ne $gg)){
$monday=1
$remainder1=$remainder1%2
$arraydayfweektrigger+="monday"
}
if(($remainder1 -ge 1)-and ($remainder1 -ne $gg)){
$sunday=1
$remainder1=$remainder1%1
$arraydayfweektrigger+="sunday"
}
}#5
elseif($gg -ge 4){
$tuesday=1
$remainder1=$gg%4
$arraydayfweektrigger+="tuesday"
if(($remainder1 -ge 2)-and ($remainder1 -ne $gg)){
$monday=1
$remainder1=$remainder1%2
$arraydayfweektrigger+="monday"
}
if(($remainder1 -ge 1)-and ($remainder1 -ne $gg)){
$sunday=1
$remainder1=$remainder1%1
$arraydayfweektrigger+="sunday"
}
}#6
elseif($gg -ge 2){
$monday=1
$remainder1=$gg%2
$arraydayfweektrigger+="monday"
if(($remainder1 -ge 1)-and ($remainder1 -ne $gg)){
$sunday=1
$remainder1=$remainder1%1
$arraydayfweektrigger+="sunday"
}
}#7
elseif($gg -ge 1){
$sunday=1
$arraydayfweektrigger+="sunday"
}
$arraytotalcount+=$arraydayfweektrigger.count
$arraycombinecount+=($arraydayfweektrigger).count
$arraycombine+=$arraydayfweektrigger
}
}
}
#$arraytotalcount
#write-host "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"
#$arraycombinecount
#write-host "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"
#$arraycombine
#write-host "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"
#################################################### <--------------work until here
<#
for($a=0;$a -lt $arraycombinecount.count;$a++){
for($b=0 ;$b -lt $arraycombinecount[$a] ; $b++){
$arraycapture+= $arraycombine[$b+$c]
}
$c+= $arraycombinecount[$a]
}
write-host "GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG"
$arraycapture
#>
####################################################
for($a=0; $a -lt $getoriginaltimecount ; $a++){
$gettaskname+=$getoriginaltime.psobject.properties.name
$referencetaskname+=$gettaskname[$a]
}

$splittingsymboloforginaltime=" "
for($b=0; $b -lt $getoriginaltimecount ; $b++){
$tempttaskname=$referencetaskname[$b]
$tempttaskname

if($getoriginaltime.$tempttaskname -match " "){
$tempttasknamee=$referencetaskname[$b]
$newformattimeforthereference=$getoriginaltime.$tempttasknamee.split($splittingsymboloforginaltime)
$timearray=$newformattimeforthereference[1]
}


if($getdayinterval.psobject.properties.name -contains $referencetaskname[$b] ){
$tasknameee=$referencetaskname[$b]
$valueofinterval= $getdayinterval.$tasknameee
$Time = New-ScheduledTaskTrigger -daily -daysinterval $valueofinterval -At $timearray
Set-ScheduledTask -TaskName $tempttaskname -Trigger $Time
}
elseif ($getweekinterval.psobject.properties.name -contains $referencetaskname[$b] ){
$symbol=","
$tasknameee=$referencetaskname[$b]
$valueofinterval= $getweekinterval.$tasknameee
$splitting= $valueofinterval.split($symbol)
$splitcount=($splitting).count
for($c=0;$c -lt $splitcount/2;$c++){
$dayofweekinterval=$splitting[$c]
$dayofweek=$splitting[$c+1]
}
for($d=$charger1;$d -lt $charger2;$d++){
$arraycapture=@()
$arraycapturevalue=0

for($e=0 ;$e -lt $arraycombinecount[$d] ; $e++){
$arraycapture+= $arraycombine[$e+$f]
}
$f+=$arraycombinecount[$d]
#####################################
if("sunday" -contains $arraycapture){
$arraycapturevalue+=1
}
if("saturday" -contains $arraycapture){
$arraycapturevalue+=64
}
if("friday" -contains $arraycapture){
$arraycapturevalue+=32
}
if("thursday" -contains $arraycapture){
$arraycapturevalue+=16
}
if("wednesday" -contains $arraycapture){
$arraycapturevalue+=8
}
if("tuesday" -contains $arraycapture){
$arraycapturevalue+=4
}
if("monday" -contains $arraycapture){
$arraycapturevalue+=2
}
###########################################
###########################################
if($arraycapturevalue -ne $dayofweek){
$arraycapturevalue=$dayofweek
$arraycapture2=@()
for($a=0 ; $a -lt 1; $a++){
$arraydayfweektrigger2=@()
$monday=0 
$tuesday=0
$wednesday=0
$thursday=0
$friday=0
$saturday=0 
$sunday=0
if($arraycapturevalue -ge 64){
$saturday=1
$remainder1=$arraycapturevalue%64
$arraydayfweektrigger2+="saturday"
if(($remainder1 -ge 32)-and ($remainder1 -ne $arraycapturevalue)){
$friday=1
$remainder1=$remainder1%32
$arraydayfweektrigger2+="friday"
}
if(($remainder1 -ge 16)-and ($remainder1 -ne $arraycapturevalue)){
$thursday=1
$remainder1=$remainder1%16
$arraydayfweektrigger2+="thursday"
}
if(($remainder1 -ge 8)-and ($remainder1 -ne $arraycapturevalue)){
$wednesday=1
$remainder1=$remainder1%8
$arraydayfweektrigger2+="wednesday"
}
if(($remainder1 -ge 4)-and ($remainder1 -ne $arraycapturevalue)){
$tuesday=1
$remainder1=$remainder1%4
$arraydayfweektrigger2+="tuesday"
}
if(($remainder1 -ge 2)-and ($remainder1 -ne $arraycapturevalue)){
$monday=1
$remainder1=$remainder1%2
$arraydayfweektrigger2+="monday"
}
if(($remainder1 -ge 1)-and ($remainder1 -ne $arraycapturevalue)){
$sunday=1
$remainder1=$remainder1%1
$arraydayfweektrigger2+="sunday"
}
}#2
elseif($arraycapturevalue -ge 32){
$friday=1
$remainder1=$arraycapturevalue%32
$arraydayfweektrigger2+="friday"
if(($remainder1 -ge 16)-and ($remainder1 -ne $arraycapturevalue)){
$thursday=1
$remainder1=$remainder1%16
$arraydayfweektrigger2+="thursday"
}
if(($remainder1 -ge 8)-and ($remainder1 -ne $arraycapturevalue)){
$wednesday=1
$remainder1=$remainder1%8
$arraydayfweektrigger2+="wednesday"
}
if(($remainder1 -ge 4)-and ($remainder1 -ne $arraycapturevalue)){
$tuesday=1
$remainder1=$remainder1%4
$arraydayfweektrigger2+="tuesday"
}
if(($remainder1 -ge 2)-and ($remainder1 -ne $arraycapturevalue)){
$monday=1
$remainder1=$remainder1%2
$arraydayfweektrigger2+="monday"
}
if(($remainder1 -ge 1)-and ($remainder1 -ne $arraycapturevalue)){
$sunday=1
$remainder1=$remainder1%1
$arraydayfweektrigger2+="sunday"
}
}#3
elseif($arraycapturevalue -ge 16){
$thursday=1
$remainder1=$arraycapturevalue%16
$arraydayfweektrigger2+="thursday"
if(($remainder1 -ge 8)-and ($remainder1 -ne $arraycapturevalue)){
$wednesday=1
$remainder1=$remainder1%8
$arraydayfweektrigger2+="wednesday"
}
if(($remainder1 -ge 4)-and ($remainder1 -ne $arraycapturevalue)){
$tuesday=1
$remainder1=$remainder1%4
$arraydayfweektrigger2+="tuesday"
}
if(($remainder1 -ge 2)-and ($remainder1 -ne $arraycapturevalue)){
$monday=1
$remainder1=$remainder1%2
$arraydayfweektrigger2+="monday"
}
if(($remainder1 -ge 1)-and ($remainder1 -ne $arraycapturevalue)){
$sunday=1
$remainder1=$remainder1%1
$arraydayfweektrigger2+="sunday"
}
}#4
elseif($arraycapturevalue -ge 8){
$wednesday=1
$remainder1=$arraycapturevalue%8
$arraydayfweektrigger2+="wednesday"
if(($remainder1 -ge 4)-and ($remainder1 -ne $arraycapturevalue)){
$tuesday=1
$remainder1=$remainder1%4
$arraydayfweektrigger2+="tuesday"
}
if(($remainder1 -ge 2)-and ($remainder1 -ne $arraycapturevalue)){
$monday=1
$remainder1=$remainder1%2
$arraydayfweektrigger2+="monday"
}
if(($remainder1 -ge 1)-and ($remainder1 -ne $arraycapturevalue)){
$sunday=1
$remainder1=$remainder1%1
$arraydayfweektrigger2+="sunday"
}
}#5
elseif($arraycapturevalue -ge 4){
$tuesday=1
$remainder1=$arraycapturevalue%4
$arraydayfweektrigger2+="tuesday"
if(($remainder1 -ge 2)-and ($remainder1 -ne $arraycapturevalue)){
$monday=1
$remainder1=$remainder1%2
$arraydayfweektrigger2+="monday"
}
if(($remainder1 -ge 1)-and ($remainder1 -ne $arraycapturevalue)){
$sunday=1
$remainder1=$remainder1%1
$arraydayfweektrigger2+="sunday"
}
}#6
elseif($arraycapturevalue -ge 2){
$monday=1
$remainder1=$gg%2
$arraydayfweektrigger2+="monday"
if(($remainder1 -ge 1)-and ($remainder1 -ne $arraycapturevalue)){
$sunday=1
$remainder1=$remainder1%1
$arraydayfweektrigger2+="sunday"
}
}#7
elseif($arraycapturevalue -ge 1){
$sunday=1
$arraydayfweektrigger2+="sunday"
}
$arraycapture2=$arraydayfweektrigger2
}
[array]::Reverse($arraycapture2)
$days = $arraycapture2 | ForEach-Object {[System.DayOfWeek] $_} 
$Time = New-ScheduledTaskTrigger -Weekly -WeeksInterval $dayofweekinterval -DaysOfWeek $days -At $timearray
Set-ScheduledTask -TaskName $referencetaskname[$b]-Trigger $Time
}
############################################
else{
[array]::Reverse($arraycapture)
$days = $arraycapture | ForEach-Object {[System.DayOfWeek] $_} 
$Time = New-ScheduledTaskTrigger -Weekly -WeeksInterval $dayofweekinterval -DaysOfWeek $days -At $timearray
Set-ScheduledTask -TaskName $referencetaskname[$b]-Trigger $Time
}
}
$charger1+=1
$charger2+=1
}
}
#$getoriginaltime | export-csv C:\Alert\time.csv -NoTypeInformation
#$Time = New-ScheduledTaskTrigger -At $getoriginaltime.$temptaskname -daily
#Set-ScheduledTask -TaskName $temptaskname -Trigger $Time
##########################################
}