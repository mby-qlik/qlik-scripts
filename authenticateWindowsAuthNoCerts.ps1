#This works when run in the server
$Data = Get-Content C:\ProgramData\Qlik\Sense\Host.cfg
$FQDN = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($($Data)))

#Create unique GUID for xrfkey
$xrfkey = -join ((48..57) + (65..90) +  (97..122) | Get-Random -Count 16 | ForEach-Object {[char]$_})

#Add xrfkey to headers
$hdrs = @{}
$hdrs.Add("X-Qlik-xrfkey","$xrfkey")

#Authenticate User - this will prompt the user to input their credentials
$cred = Get-Credential 

#URL to connect to. About is a simple and light endpoint to use. We only want this to authenticate the request.
$url = "https://$($FQDN)/qrs/about?xrfkey=$($xrfkey)"

#Retrieve the URL to authenticate like https://servername/internal_windows_authentication/?targetId=...
$Result = Invoke-WebRequest -Method Get -Uri $url -MaximumRedirection 0 -ErrorAction Ignore -SkipHttpErrorCheck -Credential $cred -Headers $hdrs

#Get the Auth URL - returns an array with 1 object, storing only the object
$AuthURL = $Result.Headers.Location[0]

#Authenticate to the AuthURL, and create a SessionVariable 
$Results = Invoke-RestMethod -Method Get -Uri $AuthURL -ErrorAction SilentlyContinue -Credential $cred -Headers $hdrs -SessionVariable AuthenticatedSession

#Using now the Session variable URL 
#Invoke-RestMethod -WebSession $AuthenticatedSession -Uri $URL

#Example, trigger a reload of a task
$taskId = "12a4753e-f77e-4e80-b5b8-77867b8ce746"
$url = "https://$($FQDN)/qrs/task/$($taskId)/start/synchronous?xrfkey=$($xrfkey)"

#Reloading a task requires a POST call
Invoke-RestMethod -WebSession $AuthenticatedSession -Uri $url -Method Post
