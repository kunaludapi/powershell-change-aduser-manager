##############################
#.SYNOPSIS
#Add or update user's manager in Active Directory.
#
#.DESCRIPTION
#The Update-ADUserManager cmdlet add or update users properties (Manager Name under Orgnaization Tab) from CSV file, Once properties updated successfully
#
#.PARAMETER File
#This is a File path of CSV with name (samaccountname) of user and his manager name.Below is the CSV file format example, Make sure you don't have empty or null values in user's or manger's cell.
#Name	    Manager
#---------- ------------
#Adam.Baum	Bud.Wieser
#Adam.Zapel	Bud.Wieser
#Art.Major	Adam.Baum
#
#.EXAMPLE
#Update-ADUserManager -File C:\temp\users.csv
#
#.NOTES
#http://vcloud-lab.com
#Written using powershell version 5
#Script code version 1.0
###############################
[CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Medium')]
param(
	[Parameter(
        Position=0, 
        Mandatory=$true,
        ValueFromPipeline=$true,
        HelpMessage='Type the full path of CSV file'
    )]
    [alias('Path', 'CSV')]
    [ValidateScript({
        If (Test-Path $_) {
            $true
        }
        else{
            "Invalid path given: $_"
        }
    })]
    [System.String]$File
)  
Begin {
    If (!(Get-Module ActiveDirectory)) {
        Import-Module ActiveDirectory
    }
    $username = Import-Csv -Path $File
    $Report = @()
}
Process {
    foreach ($user in $username) {
        $SamAccountName = $user.Name 
        Try {
            $GADuser = Get-ADUser -Filter {SamAccountName -eq $SamAccountName} -ErrorAction Stop
            $GADuser | Set-ADuser -Manager $user.Manager -ErrorAction Stop
            $Report += Get-ADUser -Filter {SamAccountName -eq $SamAccountName}  -Properties Manager | select Name, @{N='Manager';E={(Get-ADUser $_.Manager).Name}}
            Write-Verbose -Message "Record updated for $SamAccountName"
        }
        catch {
            Write-Error -Message "$SamAccountName or its manager does not exist please check in Active Directory"
        }
    }
}
End {
    $temp = [System.IO.Path]::GetTempFileName()
    $report | Out-file -FilePath $temp
    Write-Verbose -Message 'Opening report'
    Notepad $temp
    #c:\temp\users.csv
}