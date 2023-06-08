# Description: Various Powershell functions to help with CC programming
# By: Jeffrey Chausse (2023)

###################################
########## Module Import ##########
###################################

Import-Module Mdbc # https://github.com/nightroman/Mdbc

##########################################
########## Variable Declaration ##########
##########################################

$ccIp = "172.26.156.86" # Enter the Control Center IP Address
#$ProjectId = "bnd" # Enter the project identifier

#########################################
########## Function Definition ##########
#########################################

function Remove-Devices {

    # Requires one of the following parameters
    param(
    [switch]$All,
    [string]$StartingWith,
    [string]$Containing
    )

    # Connect the client
    Connect-Mdbc -ConnectionString "mongodb://$($ccIp):27055"

    # Then set the database/collection we want to work on
    $Database = Get-MdbcDatabase sc-datastore
    $Collection = Get-MdbcCollection -Name devices -Database $Database

    # Removes all devices
    if ($All) {
        $result = Remove-MdbcData -Collection $Collection -Filter @{} -Many -Result # Sends an empty document to match all existing documents
    }

    # Removes all devices starting with...
    if ($StartingWith) {
        $regex = "^" + $StartingWith
        $result = Remove-MdbcData -Collection $Collection -Many -Result -Filter @{deviceName = @{'$in' = @([regex]$regex)}} # $in is a MongoDB expression
    }

    # Removes all devices that contains...
    if ($Containing) {
        $result = Remove-MdbcData -Collection $Collection -Many -Result -Filter @{deviceName = @{'$in' = @([regex]$Containing)}} # $in is a MongoDB expression
    }

    if ($result.IsAcknowledged) {
        Write-Host "$($result.DeletedCount) devices have been deleted"
    }

}

function Remove-Taskflows {

    # Requires one of the following parameters
    param(
    [switch]$All,
    [string]$StartingWith,
    [string]$Containing
    )

    # Connect the client
    Connect-Mdbc -ConnectionString "mongodb://$($ccIp):27055"

    # Then set the database/collection we want to work on
    $Database = Get-MdbcDatabase sc-datastore
    $Collection = Get-MdbcCollection -Name taskflows -Database $Database

    # Removes all taskflows
    if ($All) {
        $result = Remove-MdbcData -Collection $Collection -Filter @{} -Many -Result # Sends an empty document to match all existing documents
    }

    # Removes all taskflows starting with...
    if ($StartingWith) {
        $regex = "^" + $StartingWith
        $result = Remove-MdbcData -Collection $Collection -Many -Result -Filter @{displayName = @{'$in' = @([regex]$regex)}} # $in is a MongoDB expression
    }

    # Removes all taskflows that contains...
    if ($Containing) {
        $result = Remove-MdbcData -Collection $Collection -Many -Result -Filter @{displayName = @{'$in' = @([regex]$Containing)}} # $in is a MongoDB expression
    }

    if ($result.IsAcknowledged) {
        Write-Host "$($result.DeletedCount) taskflows have been deleted"
    }

}

function Update-DevicePrefix {
    
    # Requires 2 parameters. The first param is the old prefix and the second param will be the new prefix.
    if ($args.Length -ne 2) {throw "Invalid parameter count. Two parameters are required."}

    $oldPrefix = $args[0]
    $newPrefix = $args[1]

    $regex = "^" + $oldPrefix

    # Connect the client
    Connect-Mdbc -ConnectionString "mongodb://$($ccIp):27055"

    # Then set the database/collection we want to work on
    $Database = Get-MdbcDatabase sc-datastore
    $Collection = Get-MdbcCollection -Name devices -Database $Database

    $document = Get-MdbcData -Filter @{deviceName = @{'$in' = @([regex]$regex)}} -Collection $Collection -First 1

    if ($null -eq $document) {throw "No device name is matching the provided prefix."}

    $i = 0

    while ($null -ne $document) {
        Get-MdbcData -Filter @{_id = $document._id} -Update @{'$set' = @{deviceName = $document.deviceName.Replace($oldPrefix, $newPrefix)}} -Collection $Collection | Out-Null
        
        $document = Get-MdbcData -Filter @{deviceName = @{'$in' = @([regex]$regex)}} -Collection $Collection -First 1
        $i++
    }

    Write-Host $i "device names have been updated."

}

#########################################
############# Function Call #############
#########################################

#Remove-Devices -Containing INT0
#Remove-Devices -All
#Remove-Taskflows -All
Update-DevicePrefix HUX ATI

#################################
########## End Of File ##########
#################################