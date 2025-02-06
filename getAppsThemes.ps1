# Language: Powershell (qlik-cli)
# List Themes used in the App 
# Author: Miguel Angel Baeyens

# Folder to create the unbuild folders with app data
# Note the trailing "\"
$UnbuildRootFolder = "C:\Users\mby\OneDrive - QlikTech Inc\Documents\VSCode\"

# Get all apps with their ID
$Apps = qlik app ls | Select-Object -Skip 1
#$Apps.Count
#$AppN = $Apps.Count -1

Set-Location $($UnbuildRootFolder + "Unbuilds\")

#$Run = 0
$AppsThemes = @()

Foreach($App in $Apps) {
    $AppTheme = $null
    $AppName = $App.Substring(41,$($App.Length -41))
    $AppId = $App.Substring(0,36)
    # Clean up some unwanted characters from the app name 
    $UnbuildAppFolderName = $($($($AppName.Replace(" ","-")).Replace(".","-")).Replace("(","-")).Replace(")","-") 

    #Write-Host "Getting theme info for App $AppName N $Run of $AppN "

    qlik app unbuild --app $AppId
    
    # The file from the unbuild that stores the app properties where the theme name is is called "appprops-GUIDHERE" within the "objects" subfolder
	# There is only one appprops file per app, but the GUID in the file name is not that of the app
    $AppsThemeJsonFile = Get-ChildItem $($UnbuildRootFolder + "Unbuilds\" + $UnbuildAppFolderName + "-unbuild") -Recurse -Include appprops* 

    $AppTheme = Get-Content $AppsThemeJsonFile | ConvertFrom-Json 

    $AppThemeInfo = @{            
        AppId         = $AppId
        AppName       = $AppName           
        AppTheme      = $AppTheme.theme
        }

    $AppsThemes += New-Object PSObject -Property $AppThemeInfo
    
    # Comment to keep app data created by qlik app unbuild
    Remove-Item $($UnbuildRootFolder + "Unbuilds\" + $UnbuildAppFolderName + "-unbuild") -Recurse

    #$Run += 1
}

# Export the results to CSV
$AppsThemes | Select-Object "AppId", "AppName", "AppTheme" | Export-Csv -Path $($UnbuildRootFolder + "AppsThemes.csv") -Delimiter ',' -Force -UseQuotes Always
