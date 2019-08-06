clear-host
$folder=@()
$folder2=@()
$tempfolder=@()
$bigdata=@()
$completebigdata=@()

    # Load WinSCP .NET assembly
    Add-Type -Path "C:\WinSCP-5.15.2-Automation\WinSCPnet.dll"
 
    # Setup session options
    $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
        Protocol = [WinSCP.Protocol]::Sftp
        HostName = "192.168.200.132"
        UserName = "appadmin"
        Password = ".H3ll0W3b4pp."
        SshHostKeyFingerprint = "ssh-ed25519 256 OxPbugkDFw03JhZRkato3Dkl5CIF6y7NmnROLfe1BIE="
    }
 
    $session = New-Object WinSCP.Session
   
        # Connect
        $session.Open($sessionOptions)
        $smallarray=@()
        $directory = $session.ListDirectory("/var/www/gsbapp/DailyRpt/template2/template/halice")
        $path="/var/www/gsbapp/DailyRpt/template2/template/halice"

 
        foreach ($fileInfo in $directory.Files)
        {
               if(($fileInfo.Length/1KB)-eq 0){
                if(($fileInfo -notmatch "." ) -or($fileInfo -notmatch "\." )){
               $folder+=$fileInfo.Name
               }  
               } 
               else{
               $completearray=@()
               $smallarray=@()
               $smallarray+=($fileInfo.Name)
               $smallarray+=($fileInfo.Length/1KB)
               $smallarray+=$path
               $completearray+=($smallarray -join ",")
               $bigdata+=$completearray
               
               } 
        
        }
        
        $foldercount=$folder.count
        if($foldercount -gt 0){
        for($a=0;$a -lt $foldercount ; $a++){
        $tempfolder+=$folder[$a]
        $temp2folder=$tempfolder[$a]+"/"
         $directory2 = $session.ListDirectory("/var/www/gsbapp/DailyRpt/template2/template/halice/$temp2folder")
         $path2="/var/www/gsbapp/DailyRpt/template2/template/halice/$temp2folder"
         $folder2=@()
          foreach ($fileInfo2 in $directory2.Files)
         {
          #Write-Host ("$($fileInfo2.Name) with size $($fileInfo2.Length/1KB)")
          if(($fileInfo2.Length/1KB)-eq 0){
          if(($fileInfo2 -notmatch ".")-or($fileInfo2 -notmatch "\.")){
          $folder2+=$fileInfo2.Name+"/"
          }#closing the not match on line 50+-
          
          } #closing the size measure in line 49  +-
          else{
          $completearray=@()
               $smallarray=@()
               $smallarray+=($fileInfo2.Name)
               $smallarray+=($fileInfo2.Length/1KB)
               $smallarray+=$path2
               $completearray+=($smallarray -join ",")
               $bigdata+=$completearray

          }
         
         
        }#closing the line 46+-
         
         $folder2count= $folder2.count
         if($folder2count-gt 0){
         for($b=0; $b -lt $folder2count ;$b++){
         $tempfolder2=$folder2[$b]
         $directory3 = $session.ListDirectory("/var/www/gsbapp/DailyRpt/template2/template/halice/$temp2folder$tempfolder2")
         $path3="/var/www/gsbapp/DailyRpt/template2/template/halice/$temp2folder$tempfolder2"
         $folder3=@()
          foreach ($fileInfo3 in $directory3.Files)
         {
          
          #Write-Host ("$($fileInfo2.Name) with size $($fileInfo2.Length/1KB)")
          if(($fileInfo3.Length/1KB)-eq 0){
          if(($fileInfo3 -notmatch ".")-or($fileInfo3 -notmatch "\.")){
          $folder3+=$fileInfo3.Name+"/"
          }#closing the not match on line 71+-
          
          } #closing the size measure in line 70  +-
         else{
           $completearray=@()
               $smallarray=@()
               $smallarray+=($fileInfo3.Name)
               $smallarray+=($fileInfo3.Length/1KB)
               $smallarray+=$path3
               $completearray+=($smallarray -join ",")
               $bigdata+=$completearray
         }
         
        }#closing the line 67+-

        $folder3count=$folder3.count
        #$tempfolder2
        #$folder3count
        if($folder3count -gt 0){
        for($c=0; $c -lt $folder3count ; $c++){
        $temp3folder=$folder3[$c]
        $directory4=$session.ListDirectory("/var/www/gsbapp/DailyRpt/template2/template/halice/$temp2folder$tempfolder2$temp3folder") 
        $path4="/var/www/gsbapp/DailyRpt/template2/template/halice/$temp2folder$tempfolder2$temp3folder"
        $folder4=@()
        foreach ($fileInfo4 in $directory4.Files)
         {
          
          #Write-Host ("$($fileInfo2.Name) with size $($fileInfo2.Length/1KB)")
          if(($fileInfo4.Length/1KB)-eq 0){
          if(($fileInfo4 -notmatch ".")-or($fileInfo4 -notmatch "\.")){
          $folder4+=$fileInfo4.Name+"/"
          }#closing the not match on line 92+-
          
          } #closing the size measure in line 91 +- 
          else{
             $completearray=@()
               $smallarray=@()
               $smallarray+=($fileInfo4.Name)
               $smallarray+=($fileInfo4.Length/1KB)
               $smallarray+=$path4
               $completearray+=($smallarray -join ",")
               $bigdata+=$completearray

          }
         
        }#closing the line 88+-
        $folder4count=$folder4.count
        if($folder4count -gt 0){
        for($d=0;$d -lt $folder4count ; $d++){
        $temp4folder=$folder4[$d]
        $directory5=$session.ListDirectory("/var/www/gsbapp/DailyRpt/template2/template/halice/$temp2folder$tempfolder2$temp3folder$temp4folder") 
        $path5="/var/www/gsbapp/DailyRpt/template2/template/halice/$temp2folder$tempfolder2$temp3folder$temp4folder"
        $folder5=@()
        foreach ($fileInfo5 in $directory5.Files)
         {
          
          #Write-Host ("$($fileInfo2.Name) with size $($fileInfo2.Length/1KB)")
          if(($fileInfo5.Length/1KB)-eq 0){
          if(($fileInfo5 -notmatch ".")-or($fileInfo5 -notmatch "\.")){
          $folder5+=$fileInfo5.Name+"/"
          }#closing the not match on line 108+-
          
          } #closing the size measure in line 109 +- 
          else{
            $completearray=@()
               $smallarray=@()
               $smallarray+=($fileInfo5.Name)
               $smallarray+=($fileInfo5.Length/1KB)
               $smallarray+=$path5
               $completearray+=($smallarray -join ",")
               $bigdata+=$completearray

          }

         
        }#closing the line 104+-

        $folder5count=$folder5.count
        if($folder5count -gt 0){
        for($e=0; $e -lt $folder5count; $e++){
        $temp5folder=$folder5[$e]
        $directory6=$session.ListDirectory("/var/www/gsbapp/DailyRpt/template2/template/halice/$temp2folder$tempfolder2$temp3folder$temp4folder$temp5folder") 
        $path6="/var/www/gsbapp/DailyRpt/template2/template/halice/$temp2folder$tempfolder2$temp3folder$temp4folder$temp5folder"
        $folder6=@()
         foreach ($fileInfo6 in $directory6.Files)
         {
          
          #Write-Host ("$($fileInfo2.Name) with size $($fileInfo2.Length/1KB)")
          if(($fileInfo6.Length/1KB)-eq 0){
          if(($fileInfo6 -notmatch ".")-or($fileInfo6 -notmatch "\.")){
          $folder6+=$fileInfo6.Name+"/"
          }#closing the not match on line 128+-
          
          } #closing the size measure in line 129 +- 
          else{
           $completearray=@()
               $smallarray=@()
               $smallarray+=($fileInfo6.Name)
               $smallarray+=($fileInfo6.Length/1KB)
               $smallarray+=$path6
               $completearray+=($smallarray -join ",")
               $bigdata+=$completearray

          }

         
        }#closing the line 124+-

        }#closing the line on 120

        }#closing the line on 119


        }#closing the line on 100 

        }#closing the line on 99 
        
        }#closing the line  on 82 +-

        }#closing the line on 81 +-

         }#closing for the for loopin lie 62+-

         }#closing for the if in line 61+-
       
        }#closing the line 38+-

        }#closing the line 37+-
     $bigdata |Select-Object -Unique |Set-Content -Encoding ASCII C:\Alert\tester.csv
     $bigdatacount=$bigdata.count
     $bigdatacount+=1
     for($h=0;$h -lt $bigdatacount;$h++){
     $h
     $partialcompletebigdata=@()
     if($h -eq 0){
     $partialcompletebigdata+="file name"
     $partialcompletebigdata+="size"
     $partialcompletebigdata+="file path"
     $completebigdata+=($partialcompletebigdata -join ",")
     }
     else{
     $completebigdata+=$bigdata[$h-1]
     }
     }
     $completebigdata|Select-Object -Unique |Set-Content -Encoding ASCII C:\Alert\testerforpowershell.csv
   

