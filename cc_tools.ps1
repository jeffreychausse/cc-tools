# Description: Various Powershell functions to help with CC programming
# By: Jeffrey Chausse (2023)

###################################
########## Module Import ##########
###################################

Import-Module Mdbc # https://github.com/nightroman/Mdbc

##########################################
########## Variable Declaration ##########
##########################################

$ccIp = "172.29.222.237" # Enter the Control Center IP Address
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

#########################################
############# Function Call #############
#########################################

#Remove-Devices -Containing BND
#Remove-Devices -All
Remove-Taskflows -All

#################################
########## End Of File ##########
#################################