#import of the active directory module
Import-Module ActiveDirectory

$ErrorActionPreference = 'silentlycontinue' #Errors in silently mode
$dir = "C:\Users\Medlo\Desktop\SCRIPTS" #Directory
$log_file = "universalG_log.log" #Definition of the log file
$log_file_path = Join-Path $dir $log_file #log file path

#This function permits to add a message(specified in parameter) in a log file
function write_to_log([string]$message){
    #Verify that the directory for the log file is existing
    if (!(Test-Path $log_file_path)) {
        #If that directory doesn't exist, the directory is created
        New-Item -path $dir -name $log_file -type "file" | Out-Null
    }
    #formatting of the date
    $timestamp = Get-Date -UFormat '%d-%m-%Y %R'
    #add the timestamp to the message
    $message_to_write = "$timestamp $message"
    #add the message to the log file
    Add-Content -Path $log_file_path -Value $message_to_write
    if($message -match "successfully "){
        Write-Host $message -ForegroundColor Green
    }elseif($message -match "erreur" -or $message -match "already"){
        Write-Host $message -ForegroundColor Red
    }elseif($message -match "..."){
        Write-Host $message -ForegroundColor Yellow
    }else{
        Write-Host $message
    }
}

#Array with the names of Universal Groups
$universalGroups = @(('Filiale-Mailing','Managers-Mailing','Dirigeants-Mailing')) 

#storing the number of Universal groups in a variable
$countGroups = $universelGroups.Length

#Path for the Universal groups
$FullOU = "OU=Groups,OU=ESGI,DC=SRC-1,DC=esgi,DC=lab"

#loop for each universal groups
for($i=0; $i -lt $countGroups; $i++){
    #Declare the universal group name
    $group = "G-" + $universalGroups[$i]
    Write-Host "   "
    
    #exception handling for the creation of the universal group
    try{
        #Creation of the universal group
        New-ADGroup -Name "$group" -SamAccountName $group -GroupCategory Distribution -GroupScope Universal -DisplayName "Universal Group $group" -Path "$FullOU" -Description "Universal Group $group"
        write_to_log("The Universal Distribution $group has been successfully created!")
        write_to_log("Users matching the criteria will now be added")
    }catch{
        write_to_log("A problem occurred during the creation of the Universal Distribution $group...")
        #Displaying the error message
        write_to_log("$($_.exception.message)")
    }
    
    #Path for searching the Users to add
    $UsersAddOU = "OU=ESGI,DC=SRC-1,DC=esgi,DC=lab"


    if ($group -eq "G-Filiale-Mailing"){

        #exception handling for adding users in the universal group "G-Filiale-Mailing"
        try{
            #Adding users matching the criteria in the universal group
            Get-ADUser -SearchBase $UsersAddOU -Filter * | ForEach-Object {Add-ADGroupMember -Identity "$group" -Members $_ }
        }catch{
            write_to_log("A problem occurred when adding users to the Universal distribution group...")
            #Displaying the error message
            write_to_log("$($_.exception.message)")
        }
    #If statement for filter the users to add
    }elseif($group -eq "G-Managers-Mailing"){
        $create = 1
        $filter = 'Description -eq "CADRE" -or Description -eq "CADRE-SUP" '
    }elseif($group -eq "G-Dirigeants-Mailing"){
        $create = 1
        $filter = 'Description -eq "CADRE-SUP" '

    }
     
     #Treatement if the variable is equal to one
     if ($create -eq 1) {
     try{
        #Adding users matching the criteria in the universal group
        Get-ADUser -Filter $filter | ForEach-Object {Add-ADGroupMember -Identity "$group" -Members $_ }
        write_to_log("Users for the universal distribution group $group have been added!")
     }catch{
        write_to_log("A problem occurred when adding users to the Universal distribution group...")
        #Displaying the error message
        write_to_log("$($_.exception.message)")
     }
     }
  
}