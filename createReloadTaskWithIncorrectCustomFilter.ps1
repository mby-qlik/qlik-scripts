$body = '{
"task": {
    "app": {
        "id": "bc2cf9e2-7034-4d94-9845-6ec690fbdac1"
    },
    "name": "Test Reload Task"
},
"schemaEvents":[{
    "timeZone": "America/New_York",
    "daylightSavingTime": 0,
    "startDate": "2017-01-11T12:05:46.000",
    "expirationDate": "9999-01-01T00:00:00.000",
    "schemaFilterDescription": [
                    "* * - * 1-5 * * *"
    ],
    "incrementDescription": "0 0 1 0",
    "incrementOption": 5,                                     
    "name": "CustomTrigger",
    "enabled": true
}]
}'


$sessionId = [guid]::NewGuid().ToString()
$userDirectory = "QTSEL"
$userId = "MBY"
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
Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType 'application/json' -Headers $hdrs -Certificate $cert -UseDefaultCredentials
#$url = "https://$($FQDN):4242/qrs/ReloadTask/0a350b90-9e2b-4dbf-bf46-7aa509f819f6?xrfkey=$($xrfkey)"
#Invoke-RestMethod -Uri $url -Method Get -Body $body -ContentType 'application/json' -Headers $hdrs -Certificate $cert -UseDefaultCredentials
