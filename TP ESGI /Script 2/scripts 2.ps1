Import-Module ActiveDirectory

$ErrorActionPreference = 'silentlycontinue' #Errors in silently mode
$dir = "C:\Users\Medlo\Desktop\SCRIPTS\" #Directory
$log_file = "users_log.log" #Definition of the log file
$log_file_path = Join-Path $dir $log_file #log file path

try{
    $users = Import-Csv -Delimiter ";" -Path "C:\Users\Medlo\Desktop\SCRIPTS\users.csv"
}catch{
    Write-Host "The CSV file has not been imported" -ForegroundColor Red
    exit
}

#Tableau pour créer les OU principals
$tabOU = @(('Services','Production','Recherche','Ventes')) 
#Tableau avec les OU enfants
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
    Write-Host $message
}


foreach($user in $users){

    $lastname = $user.Lastname
    $firstname = $user.Firstname
    $fullName = "$firstname $lastname"
    $sam = $firstname.Substring(0,1) + $lastname
    $sam = $sam.ToLower()
    $email = "$sam@esgi.lab"
    $phone = $user.phone
    $service = $user.Service
    $role = [int]$user.role
    $DC = "DC=SRC-1,DC=esgi,DC=lab"
    $passwd = "Pa55W0rd"
    $mail = "$sam@esgi.lab"
    $upn = $mail

    Write-Host "  "
    Write-Host "$role  "
    Write-Host "   "

    if (($role -ge 01)  -AND ($role -le 99)){
        $role = "EMPLOYE"
    }elseif (($role -ge 100) -AND ($role -le 199)){
        $role = "CADRE"
    }else{
        $role = "CADRE-SUP"
    }
        echo "service : " $service

    for($i=0;$i-lt $tabOU.length;$i++){
        for($s=0;$s -lt $subOU[$i].Length;$s++){
    echo "subOU I : " $subOU[$i][$s]
    Start-Sleep -Seconds 2
        if($subOU[$i] -eq $service){
            $ou = $tabOU[$i]
            $FullOU = "OU=$ou,OU=$service,$DC"
        }else{
            $ou = $service
            $FullOU = "OU=$ou,$DC"
        }
    } 
    }

    echo $FullOU
     New-ADUser  -GivenName $firstname  -Surname $lastname  `
        -Name $lastname  -DisplayName $lastname  `
        -Description $role -Office $service `
        -OfficePhone $phone  -EmailAddress $mail  `
        -SamAccountName $sam  -UserPrincipalName $upn  `
        -AccountPassword(ConvertTo-SecureString -AsPlainText $passwd -Force)  `
        -ChangePasswordAtLogon $true  -Title $fonction  `
        -Path $FullOU  -Enabled $true

    write_to_log("Présent dans l'OU $ou in $FullOU")
    write_to_log("L'utilisateur $fullName dont son numéro de téléphone est : $phone travaillera au service $service et aura un role $role.")
    Write-Host "   "

}

