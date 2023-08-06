param(

    [String]$TopTenProperty
)
Function loop_remove{
    param(
        $process_remove,
        $uniqueProcess_remove
    )

    foreach($unque in $uniqueProcess_remove){
        $check_repetition_count=1

        foreach($process in $process_remove){
            if($unque.id -eq $process.id){
            $check_repetition_count=0
        }
    }
    if($check_repetition_count -eq 1){
        $unque.Status ='remove'
        exporting -export $unque
    }
    } 
}
Function loop_add{
    param(
        $process_add,
        $uniqueProcess_add
    )
    foreach($process in $process_add){
        $check_repetition_count=1 

        foreach($unque in $uniqueProcess_add){

            if($unque.id -eq $process.Id){
            $check_repetition_count =0
            }
        }
        if($check_repetition_count -eq 1){ 
            exporting  -export $process
        }
    }
}
function exporting{
    param(
        $export
    )
    $export | Export-csv -Path .\Mathan_9.csv  -NoTypeInformation -Append
}
function processing_data{
    param(
        $processes
    )
    $uniqueProcess= Import-Csv -Path .\Mathan_9.csv
    $take_content= Get-Content -Path .\ProcessMonitor-Settings.txt
    if($take_content -eq $null){  
    
        exporting -export $processes
    }else{
        $processesing +=$processes | Sort-Object -Property $take_content -Descending |select -First 10 
        loop_add -process_add $processesing -uniqueProcess_add $uniqueProcess
        loop_remove -process_remove $processesing -uniqueProcess_remove $uniqueProcess
    }
}

$selectedProperties= Get-Content -path .\PropertyNames.txt
[switch]$file= Test-Path -Path .\Mathan_9.csv
$processes =  Get-Process | Select-Object -Property $selectedProperties 
$processes| Add-Member -MemberType NoteProperty -Name 'ExecutionTime' -Value (get-date).ToString("yyyy-MM-dd--HH-mm-ss")
$processes | Add-Member -MemberType NoteProperty -Name 'Status' -Value 'Added' 
if ($TopTenProperty ) {
    if($file){
        
    
        processing_data  -processes $processes

       "file is there"
    }else{
        $TopTenProperty | Out-File .\ProcessMonitor-Settings.txt
        $processes | Sort-Object -Property $TopTenProperty -Descending |select -First 10|Export-csv -Path .\Mathan_9.csv  -NoTypeInformation -Append
        " create Top Ten Property $TopTenProperty Sucessfully"
    }
}else{
    if($file){
       
        processing_data  -processes $processes
        "created sucessfully"   
    }else{
        New-Item -ItemType File -Path .\ProcessMonitor-Settings.txt
        $processes |Export-csv -Path .\Mathan_9.csv  -NoTypeInformation 
   }
}