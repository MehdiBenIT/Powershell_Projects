#import of the active directory module
Import-Module ActiveDirectory

$ErrorActionPreference = 'silentlycontinue' #Errors in silently mode
$dir = "C:\Users\Medlo\Desktop\SCRIPTS" #Directory
$log_file = "securityG_log.log" #Definition of the log file
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
    }elseif($message -match "error" -or $message -match "already"){
        Write-Host $message -ForegroundColor Red
    }elseif($message -match "..."){
        Write-Host $message -ForegroundColor Yellow
    }else{
        Write-Host $message
    }
}

#Declaration of the paths for the groups 
$FullOU = "OU=Groups,OU=ESGI,DC=SRC-1,DC=esgi,DC=lab"
#length of the OU lower-level
$len = $subOU.Length

#loop for each OU
for ($i=0; $i -lt $len; $i++){
    $lensub = $subOU[$i].Length
    $ou = $tabOU[$i]
    #Declare the security group name
    $securityGroup = "G-" + $ou
    $searchOU = "OU=$ou,$DC"

    #exception handling for the creation of the security group
     try{
        #Creation of a security group for the current OU
        New-ADGroup -Name "$securityGroup" -SamAccountName $securityGroup -GroupCategory Security -GroupScope Global -DisplayName "Security Group $ou" -Path "$FullOU" -Description "Security group of $ou OU"
        #Adding all the users of the current OU in the security group
        Get-ADUser -SearchBase "$searchOU" -Filter * | ForEach-Object {Add-ADGroupMember -Identity "$securityGroup" -Members $_ }


        write_to_log("The security group has been successfully created and users in the OU have been added.")
       }catch{
        write_to_log("Error during the creation of the security group...")
        #Displaying the error message
        write_to_log("$($_.exception.message)")
       }

    #loop for each OU lower-level
    for($s=0; $s -lt $lensub;$s++){
       $sub = $subOU[$i][$s]
       #Declare the security group name
       $securityGroup = "G-" + $sub
       $search = "OU=$sub,OU=$ou,$DC"
      
       #exception handling for the creation of the security group
       try{
        #Creation of a security group for the current OU lower-level
        New-ADGroup -Name "$securityGroup" -SamAccountName $securityGroup -GroupCategory Security -GroupScope Global -DisplayName "Security Group $subOU" -Path "$FullOU" -Description "Security group of $sub OU"
        #Adding all the users of the current OU lower-level in the security group
        Get-ADUser -SearchBase "$search" -Filter * | ForEach-Object {Add-ADGroupMember -Identity "$securityGroup" -Members $_ }

        write_to_log("The security group has been successfully created and users in the OU have been added.")
       }catch{
        write_to_log("Error during the creation of the security group...")
        #Displaying the error message
        write_to_log("$($_.exception.message)")
       }
    }
}