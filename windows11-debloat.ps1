

function Get-AppList {
    param (
        $appListPath
    )

    $appList = @()

    # Read app list from provided file
    foreach ($app in (Get-Content -Path $appListPath | Where-Object { $_ -notmatch '^#.*' -and $_ -notmatch '^\s*$' } )) {
        # Remove comments after app names
        if ( -not ($app.IndexOf('#') -eq 1 )) {
            $app = $app.Substring(0, $app.IndexOf('#'))
        }
        
        # Remove spaces
        $appString = $app.Trim('*')
        $appList += $appString
    }

    return $appList
}

# Removes apps from all users and from the OS image
function Remove-Apps {
    param (
        $appList
    )
    
    foreach ( $app in $appList ) {
        Write-Output "Attempting to remove $app..."

        $app = '*' + $app + '*'

        # Use Remove-AppxPackage to remove apps
        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers

        # Remove provisioned app from OS image to prevent installing for new users
        Get-AppxProvisionedPackage -Online | Where-Object { $_PackageName -like $app } | Foreach { Remove-AppxProvisionedPackage -Online -AllUsers -PackageName $_PackageName }
    }
}