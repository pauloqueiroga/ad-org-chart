# Build Number: $(Build.BuildNumber)
param (
    [Parameter(Mandatory=$true)]
    [string]$server,
    [Parameter(Mandatory=$true)]
    [string]$nameMatchingString
)

function Get-ADTopDown([string]$nameMatchingString, [string]$prefix) {
    $userIdentity = $nameMatchingString

    $user = Get-ADUser -server $server -filter "name -like '$nameMatchingString'" -Properties "Manager"

    if($user.DistinguishedName) {
        $userIdentity = $user.DistinguishedName
    }

    $printName = $user.Name
    Write-Output "$prefix $printName"

    $team = Get-ADUser -server $server -Filter "manager -eq '$userIdentity'" -Properties Manager | Sort-Object -Property Name 
    $count = 1

    foreach ($teamMember in $team) {
        Get-ADTopDown -nameMatchingString $teamMember.Name -prefix "   $prefix.$count"
        $count = $count + 1
        Start-Sleep -Seconds 1
    }
}

Get-ADTopDown -nameMatchingString $nameMatchingString -prefix "1"
