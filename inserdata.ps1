clear-host
$data=import-csv C:\Alert\completedata.csv
$datacount=($data).count 
for($a=0;$a -lt $datacount; $a++){
$condition=$data.name[$a]
$count=$data.numberofrun[$a]
$lastruntime=$data.lastruntime[$a]

$insertquery="
INSERT INTO [dbo].[servicetable]
([stating],[name],[displayname])
VALUES
('$condition','$count','$lastruntime')
GO
"
Invoke-SQLcmd -ServerInstance "192.168.200.130" -query $insertquery -U sa -Password gmtonline -Database ProjMgmt
}