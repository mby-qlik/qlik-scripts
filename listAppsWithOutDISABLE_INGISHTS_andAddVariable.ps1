# Get all app Ids and Names

$allApps = qlik app ls
$appIds = @()
$appNames = @()

# Process the output
$allApps -split "`n" | ForEach-Object {
    If($_ -notmatch "ID\s+NAME") {
        $appId, $appName = $_ -split '\s+', 2
        $appIds += $appId
        $appNames += $appName
    }
}

$allVariables = @()
$cleanVariables = @()
$cleanNames = @()

foreach ($id in $appIds) {

    # Check for errors opening files
    $variables = qlik app variable ls --app $id 2>&1

    if($LASTEXITCODE -eq 0) {

        Write-Output "Reading variables from $id"

        $variables -split "`n" | ForEach-Object {
            If($_ -notmatch "ID\s+TITLE") {
                $variableName = ($_ -split '\s+')[1]
                Break
                $variableId, $variableName = $_ -split '\s+', 2
                $cleanVariables += $variableId
                $cleanNames += $variableName
            }
        }

        # if the variable "DISABLE_INSIGHTS" is not in the app, add the appId to the list
        foreach ($cleanVariableName in $cleanNames) {
            if($cleanVariableName -notcontains "DISABLE_INSIGHTS") {

                $allVariables += New-Object PSObject -Property @{
                    "appId" = $id
                }
            }
        }
    # process errors, here an example if processing 403
    } else {
        if($variables -like '*403*') {
            Write-Output "Ignoring app $id because ""Forbidden 403"" errors"
            continue
        } else {
            throw $variables
        }
    }
}

# Get only disctinct appIds
$distinctIds = $allVariables | Group-Object -Property appId | ForEach-Object { $_.Group | Select-Object -First 1 }

# Store into CSV
$distinctIds | Export-Csv -Path "no_DISABLE_INSIGHTS_variable.csv" -NoTypeInformation

# Add the DISABLE_INSIGHTS variable to the apps in the list

# Variables must be on a JSON file somewhere
$DISABLE_INSIGHTS_path = "C:\Users\mby\OneDrive - QlikTech Inc\Documents\VSCode\DISABLE_INSIGHTS_variable.json"

# Read the list of apps without the variable
$appsWithoutDISABLE_INSIGHT = Import-Csv '.\no_DISABLE_INSIGHTS_variable.csv'

# Loop through the apps and add the variable
# CAUTION! this does not process errors saving apps or opening apps to write
foreach ($app in $appsWithoutDISABLE_INSIGHT) {
    Write-Output "Creating DISABLE_INSIGHTS in $app"
    qlik app variable set $DISABLE_INSIGHTS_path --app $app.appId
}



