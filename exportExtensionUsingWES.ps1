# $sessionId = [guid]::NewGuid().ToString()
# $directory = $env:USERDOMAIN
# $userId = $env:USERNAME
# $body = '{
#     "UserDirectory": "$directory",
#     "UserId": "$userId",
#     "Attributes":
#       [],
#     "SessionId": "$($sessionId)"
# }'
$hdrs = @{}
$xrfkey = -join ((48..57) + (65..90) +  (97..122) | Get-Random -Count 16 | ForEach-Object {[char]$_})
$hdrs.Add("X-Qlik-xrfkey","$xrfkey")
$cert = Get-ChildItem -Path "Cert:\CurrentUser\My" | Where-Object {$_.Subject -like '*QlikClient*'}
$Data = Get-Content C:\ProgramData\Qlik\Sense\Host.cfg
$FQDN = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($($Data)))
$url = "https://$($FQDN):4243/qps/ticket?xrfkey=$xrfkey"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]'Tls12' 
$ticket = (Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType 'application/json' -Headers $hdrs -Certificate $cert).Ticket
Write-Output $ticket
Invoke-RestMethod -Uri "https://$($FQDN)/api/wes/v1/extensions/export/First?xrfkey=$xrfkey&qlikTicket=$ticket" -Method Get -Headers $hdrs -ContentType 'application/json' -Certificate $cert -OutFile .\extension.zip


