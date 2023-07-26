$schemaEventId = [guid]::NewGuid().ToString()
$body = '{
    "id": "$schemaEventId",
    "operational": {
      "id": "40478db2-05a3-42a9-8d63-f938ae2d105a",
      "nextExecution": "2023-07-24T12:16:45.803Z",
      "timesTriggered": 2637,
      "privileges": null
    },
    "name": "Reload License Monitor Schema",
    "enabled": true,
    "eventType": 0,
    "privileges": null
  },'


$sessionId = [guid]::NewGuid().ToString()
$userDirectory = "XX"
$userId = "XX"
# $body = '{
#     "UserDirectory": "$userDirectory",
#     "UserId": "$userId",
#     "Attributes":
#     [],
#     "SessionId": "$sessionId"
# }'
$xrfkey = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 16 | ForEach-Object {[char]$_})
$hdrs = @{}
$hdrs.Add("X-Qlik-Xrfkey","$xrfkey")
$hdrs.Add("X-Qlik-User","UserDirectory=$userDirectory;UserId=$userId")
$cert = Get-ChildItem -Path "Cert:\CurrentUser\My" | Where-Object {$_.Subject -like '*QlikClient*'}
$Data = Get-Content C:\ProgramData\Qlik\Sense\Host.cfg
$FQDN = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($($Data)))
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]'Tls12' 
$url = "https://$($FQDN):4242/qrs/ReloadTask/create?xrfkey=$($xrfkey)"
Invoke-RestMethod -Uri $url -Method Put -Body $body -ContentType 'application/json' -Headers $hdrs -Certificate $cert -UseDefaultCredentials
