#Enter-PSSession -ComputerName jn-crm16-test01.jnbs.com 


cls

#$SavePath ='\\172.17.3.156\Releasemgt$\ReleaseManagement\Powershell\shanzi.csv'
$SavePath ='c:\temp\tro.csv'


#Search xml form of task list to get all actions for task with TaskName $Name
Function MultipleAction{
Param ($Name)
    $Tasks = schtasks /query /xml 
    #$Tasks

    $Output = ""
    $StopReading = $false

    $StartSearchAction = $false
    
    #if string is empty 
 
    if(-not $Name)
    {
         Write-Host -Foreground Red ('Name is empty')
         $StopReading = $true
    }

    $Tasks | ForEach-Object {
        if(-not $StopReading)
        {
            if($_.Contains($Name))
            {
                $StartSearchAction = $true
        
            }
            #checking xml tag 
            if($StartSearchAction -and $_.Contains('<Command>'))
            {
                $result = $_ -match "<Command>(?<content>.*)</Command>"

                #matches magic varible that work with -match
                $Output += $matches['content']+", "
            }

            if($StartSearchAction -and $_.Contains('</Task>'))
            {

                Write-Output "$Output"
                $StopReading = $true
            
            }
        }

    }
    
    
}

$Tasks = schtasks /query /v /fo csv | ConvertFrom-Csv

$ScheduledTasks = $Tasks | Where-Object {$_.Author -match "JNBS_NET" } | Select-Object -Property TaskName, Author, "Task To Run"

#search cvs for field with "Multiple actions" replace it with the actually paths of file using the Multiple action function
$NewCvs = $ScheduledTasks | ForEach-Object {
    if($_."Task To Run" -eq "Multiple actions")
    {
          #update feild
          $_."Task To Run" = MultipleAction $_.TaskName
    }

    $_
}

#$NewCvs | export-csv -Path $SavePath -NoTypeInformation

$NewCvs 
#| forEach-Object{
   # $Name=$_.TaskName
  #  $Dir=$_."Task to run"
#}

#$Name
#$Dir

#$compType= "Concole"


#$inserts =@"
 #   INSERT INTO dbo.Component (ComponentName,InstallDirectory,componentType) VALUES ('$Name','$Dir','$compType')

#"@

#Invoke-Sqlcmd -ServerInstance releasemgmt-svr -Database JnEnvironment -Query $inserts 

exit