#import of the active directory module
Import-Module ActiveDirectory

$ErrorActionPreference = 'silentlycontinue' #Errors in silently mode
$dir = "C:\Users\Medlo\Desktop\SCRIPTS" #Directory
$log_file = "OU_log.log" #Definition of the log file
$log_file_path = Join-Path $dir $log_file #log file path

#Array with the names of the main OU
$tabOU = @(('Services','Production','Recherche','Ventes')) 
#Multi-array for declaring the names of all the OU inside the main OU
$subOU = (('Direction','Ressources Humaines','Comptabilité','Paye','Informatique'),('Usine','Logistique','Méthodes','Support'),('Prospective','Développement','Assurance Qualité'),('Commercial'  ,'Avant-Vente','Consulting'))

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


#initialization of counting variables
$exists_sub = 0
$exists_OU = 0
$no_existsSub = 0
$no_existsOU = 0

#Declaration of the Path for the main OU which will contain the entire tree structure
$DC = "DC=SRC-1,DC=esgi,DC=lab"
#The command permits to create the main OU
New-ADOrganizationalUnit  -Name "ESGI"  -Path "$DC" -ProtectedFromAccidentalDeletion $true

#Modification of the Path for all the other OU
$DC = "OU=ESGI,$DC"
#Creation of an OU to centralize all the Groups
New-ADOrganizationalUnit  -Name "Groups"  -Path "$DC" -ProtectedFromAccidentalDeletion $true

#loop for each OU
for($i=0;$i-lt $tabOU.length;$i++){
    
    #Storing the information of the current OU in the loop
    $currentOU = $tabOU[$i]
    $newOU = "OU=$currentOU,$DC"
    write_to_log("Creation of the OU $currentOU")

    #Verification of the existence of the OU
    if(Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$newOU'"){
        write_to_log("$currentOU is already existing!")
        #incrementing the counting variable for OU already existing
        $exists_OU += 1
    #If the OU does not exist, we create it
    }else{
        #incrementing the counting variable for OU not existing yet
        $no_existsOU += 1
        #exception handling for the creation of the OU
        try{
            #The command permit to create the current OU in the tree structure
            New-ADOrganizationalUnit  -Name $currentOU  -Path $DC -ProtectedFromAccidentalDeletion $true
            write_to_log("The OU $currentSubOU has been successfully created!")
        }catch{
            #Displaying the error message
            write_to_log("$($_.Exception.Message)")
        }
    }

    for($s=0;$s -lt $subOU[$i].Length;$s++){
        
        #Storing the information of the current OU lower-level in the loop
        $currentSubOU = $subOU[$i][$s]
        $newSubOU = "OU=$currentSubOU,$newOU"
        write_to_log("Creation of the OU $currentSubOU under the OU $currentOU")

        #Verification of the existence of the OU
        if(Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$newSubOU'"){
            write_to_log("$currentSubOU is already existing...")
            #incrementing the counting variable for OU lower-level already existing
            $exists_sub += 1
        #If the OU does not exist, we create it
        }else{
            #incrementing the counting variable for OU lower-level not existing yet
            $no_existsSub += 1
            try{
                #The command permit to create the current OU in the tree structure
                New-ADOrganizationalUnit  -Name $currentSubOU  -Path $newOU -ProtectedFromAccidentalDeletion $true
                write_to_log("the OU $currentSubOU has been successfully created !")
            }catch{
                #Displaying the error message
                write_to_log("$($_.Exception.Message)")
            }
        }

    }

    write-host "   "
}

#Displaying informations about the creations of the OU in our tree structure
if ( $exists_sub -ne 0 -or $exists_OU -ne 0){
    $total = $exists_sub + $exists_OU
    write_to_log("$total was already existing including $exists_sub OU lower-level.")
}else{
    $total = $no_existsSub + $no_existsOU
    write_to_log("$total OU were successfully created!")
}