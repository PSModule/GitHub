function Get-ContextTokenStatus {
    param(
        [Parameter(Mandatory)]
        $Context
    )

    # Determine type and total life
    switch ($Context.AuthType) {
        'UAT' { $totalLife = [timespan]::FromHours(8) }
        'IAT' { $totalLife = [timespan]::FromHours(1) }
        default {  }
    }

    $now = Get-Date
    $expires = $Context.TokenExpirationDate
    $timeLeft = $expires - $now

    if ($null -eq $Context.TokenExpirationDate) {
        return 'N/A'
    }
    if ($timeLeft.TotalSeconds -le 0) {
        $color = $PSStyle.Foreground.Red
        $status = 'Expired'
    } elseif ($timeLeft.TotalSeconds -le ($totalLife.TotalSeconds / 2)) {
        $color = $PSStyle.Foreground.Yellow
        $status = "$($timeLeft | Format-TimeSpan)"
    } else {
        $color = $PSStyle.Foreground.Green
        $status = "$($timeLeft | Format-TimeSpan)"
    }

    return "$color$status$($PSStyle.Reset)"
}

$contexts = Get-GitHubContext -ListAvailable
$contexts | ForEach-Object {
    $status = Get-ContextTokenStatus -Context $_
    Write-Host "$status"
}
