# specifiy the directory and userid to search for reports
$userDirectory = $env:USERDOMAIN
$userId = $env:USERNAME

# creates the headers for the request
$hdrs = @{}

# creates a random GUID for the xrfkey
$xrfkey = -join ((48..57) + (65..90) +  (97..122) | Get-Random -Count 16 | ForEach-Object {[char]$_})

# adds xrfkey header
$hdrs.Add("X-Qlik-xrfkey","$xrfkey")

# adds user header
# verify the name of the authentication header, here it is X-Qlik-User, but it could be different
# this header is specified in the virtual proxy that the user will use to open the Hub
$hdrs.Add("X-Qlik-User","UserDirectory=$userDirectory;UserId=$userId")

# use the QlikClient certificate to connect to the Repository service
$cert = Get-ChildItem -Path "Cert:\CurrentUser\My" | Where-Object {$_.Subject -like '*QlikClient*'}

# get the hostname 
$Data = Get-Content C:\ProgramData\Qlik\Sense\Host.cfg

# build the FQDN for the server
$FQDN = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($($Data)))

# use the right version of TLS
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]'Tls12' 

# build the endpoint to search for reports
# look at the ?filter= part
# in this example:
#   filter reports where name is equal to the string 'FARS Report'
#   AND where the user is the current user
#   !!! BE CAREFUL WITH THE FILTER !!! You could delete someone else's reports otherwise!
$url = "https://$($FQDN):4242/qrs/sharedcontent/full?filter=(name eq 'FARS Report') and (owner.userId eq '$userId')&xrfkey=$($xrfkey)"

# obtain the reports
$reports = Invoke-RestMethod -Uri $url -Method Get -ContentType 'application/json' -Headers $hdrs -Certificate $cert

# delete each report matching the filter
ForEach ($report in $reports) {
    $reportId = $report.id
    $url = "https://$($FQDN):4242/qrs/sharedcontent/$($reportId)?xrfkey=$($xrfkey)"
    
    # Make sure to change to -Method Delete to actually delete the report
    Invoke-RestMethod -Uri $url -Method Get -Headers $hdrs -ContentType 'application/json' -Certificate $cert
}
