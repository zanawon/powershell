# Done By: ZANAOWN and Jovi848

cls


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

$ScheduledTasks = $Tasks | Where-Object {$_.Author -match "Anything" } | Select-Object -Property TaskName, Author, "Task To Run"

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


exit