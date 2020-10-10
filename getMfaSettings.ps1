
## functions ##
function CheckModule() {
    if (Get-Module -ListAvailable -Name Msonline) {
        Write-Host Module exists continue to the script -ForegroundColor Yellow
    } 
    else {
        Write-Host Module does not exist installing Msonline module
        Install-Module Msonline
    }
}

function ShowMenu() {
    param (
        [string]$Title = 'MFA user settings'
    )
             
    Write-Host ================ $Title ================ -ForegroundColor Cyan
    Write-Host 1 Press '1' to get user MFA details on AzureAD -ForegroundColor Green
    write-host 2 press '-1' to exit -ForegroundColor Yellow
}
    
function GetMfaUserSettings() {
    Connect-MsolService
    write-Host Please enter username, example username@domainname.com   -ForegroundColor Green
    $user = read-host
    try { 
        $user = Get-MsolUser -UserPrincipalName $user -ErrorAction Stop
        Write-Host done
    }
    catch [Microsoft.Online.Administration.Automation.MicrosoftOnlineException] {
        if ($_.Exception.Message -notmatch ^User Not Found.) {
            trow
        }
        Write-Host User $user was not Found! Please try again -ForegroundColor red 
        Start-Sleep 1
        Write-Host Back to menu in 3 -ForegroundColor Yellow
        Start-Sleep 1
        Write-Host Back to menu in 2 -ForegroundColor Yellow
        Start-Sleep 1
        Write-Host Back to menu in 1  -ForegroundColor Yellow
        Start-Sleep 1
    }
            
    $properties = @{ }
    $mfaSettings = $user  select strong
    $mfaSettings = $mfaSettings.StrongAuthenticationMethods
    foreach ($dat in $mfasettings) {
        $item = $dat  Where-Object { $_.IsDefault -eq $true }
        if ($item -ne $null) {
            $properties.Add($item.MethodType, 'DefaultMethod')
        }
        else {
            $item = $dat  Where-Object { $_.IsDefault -ne $true }
            $properties.Add($item.MethodType, 'Secondary')
        }
    }
    Write-Host User MFA Settings  -ForegroundColor Green
    Write-Host ------------------ -ForegroundColor Green
    
    write-output $properties
    
}

CheckModule   
#####MENU####

do {
    ShowMenu
    $input = Read-Host Please make a selection
    switch ($input) {
        '1' {
            $data = @{ }
            $data = GetMfaUserSettings
            $data
        }
    } 
    pause
}
until ($input -eq -1)
