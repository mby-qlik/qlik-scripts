# Look for the DISABLE_INSIGHTS variable on each app
$variable = "DISABLE_INSIGHTS"

# get all the apps
$apps = qlik app ls | Select-Object -Skip 1

# loop through the apps to identify those without the variable
foreach ($app in $apps) {
    # read the variables from the app
    $appId = $app.Substring(0,36)
    Write-Output "Reading $($app)"
    $variables = qlik app variable ls --app $appId --quiet
Break
    #Check if the variable is present
    If ($variables.name -contains $variable) {
        $AppsVariables = @{            
            AppId         = $AppId
            VariablePresent   = "Yes"
            }
    
        $AppsWithVariables += New-Object PSObject -Property $AppsVariables
    } else {
        
    }
    #Break
}
    
# Export the results to CSV
$AppsWithVariables | Select-Object "AppId", "VariablePresent" | Export-Csv -Path $("AppsVariables.csv") -Delimiter ',' -Force -UseQuotes Always
