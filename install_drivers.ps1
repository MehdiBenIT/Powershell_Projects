#Name          :   install_drivers.ps1
#Date          :   25/07/2022
#Description   :   Ce script permet d'installer automatiquement les pilotes correspondant au modèle du PC sur lequel le script est éxécuté.
#Auteur        :   Mehdi Bennouar

$infosComputer = Get-CimInstance -ClassName Win32_ComputerSystem -Property *

$BrandPc = $infosComputer.Manufacturer
$ModelPc = $infosComputer.Model
$SystemName = $infosComputer.SystemFamily

Write-Host "
Marque du PC        : $BrandPc
Model du PC         : $ModelPc
Model complet du PC : $SystemName"

$cheminPilotes = "C:\$BrandPc\$ModelPc\"


#Installation de tous les pilotes présent dans le dossier prévu pour ce modèle de PC
#Get-ChildItem $cheminPilotes -Recurse -Filter "*.inf" | 
#ForEach-Object { PNPUtil.exe /add-driver $_.FullName /install }