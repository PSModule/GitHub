﻿Connect-GitHub -ClientID $ClientID -PrivateKey $PrivateKey -HostName 'msx.ghe.com'

$deliveries = Get-GitHubAppWebhookDelivery | ForEach-Object {
    [pscustomobject]@{
        Success        = ($_.status_code -lt 300) -and ($_.status_code -ge 200)
        StatusCode     = $_.status_code
        Status         = $_.status
        ID             = $_.id
        GUID           = $_.guid
        Date           = $_.delivered_at
        Duration       = $_.duration
        Redelivery     = $_.redelivery
        Event          = $_.event
        Action         = $_.action
        InstallationID = $_.installation.id
        RepositoryID   = $_.repository.id
        URL            = $_.url
        ThrottledAt    = $_.throttled_at
    }
}

$deliveries | Where-Object { $_.Event -eq 'team' } | Format-Table -AutoSize




$Return.Response | Format-Table -AutoSize

Switch-GitHubContext -Context 'msx.ghe.com/Marius-Storhaug'

1..10 | ForEach-Object {
    New-GitHubTeam -Organization 'my-org' -Name "Test$_"
}
