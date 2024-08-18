<#
    Name: file mover by extension
    Author: teenween
    Version: 0.0.2
    Published: 06/12/2023
    Updated: 06/12/2023
    Notes: objective is to sort files and place them in directories with their respective extensions
    Reformatting script to be more formal
#>


function Assert-Path{
    param(
        [Parameter (
        Position=0,
        Mandatory=$true
        )]
        [string]$path
    )

    #validating input
    if (Test-Path -Path $path) {
        return $true
    } else {
        return $false
    }
}

function Move-Files{

<#
    .SYNOPSIS
    Sorts files by its extension in a given directory
    .DESCRIPTION
    function takes in a directory from the user and sorts unsorted files to new or existing files by their extensions
    .PARAMETER FilePath
    This is a string for an asboslute file path (must be a file)
    [CmdletBinding()]
    .PARAMETER Access
    This is the access you want to add or remove entered in as DOMAIN ACCOUNT
#>
    param(
        [Parameter (
        Position=0,
        Mandatory=$true
        )]
        [string]$path
    )

    $directory = Get-Item $path

    if(!$directory.PSIsContainer){
        Write-Host "path is not a directory"
        exit
    }

    get-childItem -Path $directory | Foreach-object {
        if (!$_.PSIsContainer){
            return
        }
        
        $folderName = $_.Name

        if(!($folderName -match '^\d')){
            return
        }

        $ext_folder = $_.FullName

        get-childItem -Path $ext_folder | ForEach-Object{
            Move-Item -Path $_.FullName -Destination $directory
        }

        Remove-Item $ext_folder
    }
}

function Move-Year{
    $path = Read-Host -Prompt 'Input directory path'
    # Remove surrounding quotes, if any
    $path =  $path -replace '"',''
    
    if(-not (Assert-Path $path)){
        exit
    }

    $directory = Get-Item $path

    if(!$directory.PSIsContainer){
        Write-Host "path is not a directory"
        exit
    }

    get-childItem -Path $directory | Foreach-object {
        if(($_.Name.StartsWith('20'))){
            return
        }
        
        $fileYear = $_.LastWriteTime.Year

        $newFolder = $path + "\$($fileYear)"

        if(!(Test-Path -Path $newFolder)) {
            New-Item -Path $newFolder -ItemType Directory
        }

        Move-Item -Path $_.FullName -Destination $newFolder
    }

    get-childItem -Path $directory | ForEach-Object {
        if(!($_.Name.StartsWith('20'))){
            return
        }

        Move-Files $_.FullName
        Move-Month $_.FullName
    }
}



function Move-Month {
    # Parameter help description
    param(
        [Parameter (
        Position=0,
        Mandatory=$true
        )]
        [string]$path
    )
    
    if(-not (Assert-Path $path)){
        exit
    }

    $directory = Get-Item $path

    if(!$directory.PSIsContainer){
        Write-Host "path is not a directory"
        exit
    }

    get-childItem -Path $directory | Foreach-object {
        $fileMonth = $_.LastWriteTime.Month.ToString("00")
        
        $newFolder = $path + "\$($fileMonth)"

        if(!(Test-Path -Path $newFolder)) {
            New-Item -Path $newFolder -ItemType Directory
        }

        Move-Item -Path $_.FullName -Destination $newFolder
    }
}

Move-Year
