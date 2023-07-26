$sessionId = [guid]::NewGuid().ToString()
$userDirectory = "XX"
$userId = "XX"
$body = '{
    "UserDirectory": "$userDirectory",
    "UserId": "$userId",
    "Attributes":
      [],
    "SessionId": "$sessionId"
}'
$xrfkey = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 16 | ForEach-Object {[char]$_})
$hdrs = @{}
$hdrs.Add("X-Qlik-Xrfkey","$xrfkey")
$hdrs.Add("X-Qlik-User","UserDirectory=$userDirectory;UserId=$userId")
$cert = Get-ChildItem -Path "Cert:\CurrentUser\My" | Where-Object {$_.Subject -like '*QlikClient*'}
$Data = Get-Content C:\ProgramData\Qlik\Sense\Host.cfg
$FQDN = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($($Data)))
#$url = "https://$($FQDN):4243/qps/ticket?xrfkey=$($xrfkey)"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]'Tls12' 
#$ticket = (Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType 'application/json' -Headers $hdrs -Certificate $cert -UseDefaultCredentials).Ticket
#Write-Output $ticket
$url = "https://$($FQDN):4242/qrs/user?filter=userDirectory eq '33K'&xrfkey=$($xrfkey)"
$userList = Write-Output (Invoke-RestMethod -Uri $url -Method Get -Headers $hdrs -ContentType 'application/json' -Certificate $cert -UseDefaultCredentials).id
#$reducedUserList = $userList[0..4]
#Write-Output $reducedUserList

ForEach ($user in $userList) {
    #Invoke-RestMethod -Uri $url -Method Get -Headers $hdrs -ContentType 'application/json' -Certificate $cert
    #Write-Output $user
    $url = "https://$($FQDN):4242/qrs/user/$($user)?xrfkey=$($xrfkey)"
    #Write-Output $url
    Invoke-RestMethod -Uri $url -Method Delete -Headers $hdrs -ContentType 'application/json' -Certificate $cert -UseDefaultCredential
}
