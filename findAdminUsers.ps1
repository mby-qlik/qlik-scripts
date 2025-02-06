# retrieve the list of all users with *Admin* roles
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

# look at the ?filter= part
# &select=name,userId,roles
$url = "https://$($FQDN):4242/qrs/user/full?filter=(roles eq 'RootAdmin' or roles eq 'AuditAdmin' or roles eq 'ContentAdmin' or roles eq 'HubAdmin' or roles eq 'SecurityAdmin' or roles eq 'DeploymentAdmin')&xrfkey=$($xrfkey)"

# obtain the Admin users
$response = Invoke-RestMethod -Uri $url -Method Get -ContentType 'application/json' -Certificate $cert -Headers $hdrs 
$response | Select-Object id, name, userId, roles
#
