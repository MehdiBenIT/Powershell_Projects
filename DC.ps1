## Script Création Active Directory
## v1.0
## Crée par : Mehdi B.
## CREATION FORET AD

Get-WindowsFeature

# Installer le rôle AD-DS
Add-WindowsFeature  -Name AD-Domain-Services  -IncludeManagementTools

# Configurer la création d'une FORET AD
Install-ADDSForest  -CreateDnsDelegation:$false `
    -DomainName "esgi.lab"  -DomainNetbiosName  "ESGI"  `
    -InstallDns:$true  -ForestMode 7  -DomainMode 7  `
    -DatabasePath "C:\Windows\NTDS"  -SysvolPath "C:\Windows\SYSVOL"  `
    -LogPath  "C:\Windows\NTDS"    `
    -NoRebootOnCompletion:$false -Force:$true  -WhatIf

