function Import-GitHubEventData {
    <#
        .SYNOPSIS
        Import data of the event that triggered the workflow

        .DESCRIPTION
        Import data of the event that triggered the workflow

        .EXAMPLE
        Import-GitHubEventData
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '',
        Justification = 'Just setting a value in a variable.'
    )]
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param()

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        try {
            $gitHubEventJson = Get-Content -Path $env:GITHUB_EVENT_PATH
            $gitHubEvent = $gitHubEventJson | ConvertFrom-Json

            $eventAction = $gitHubEvent.action
            $eventSender = $gitHubEvent.sender | Select-Object -Property login, type, id, node_id, html_url
            $eventEnterprise = $gitHubEvent.enterprise | Select-Object -Property name, slug, id, node_id, html_url
            $eventOrganization = $gitHubEvent.organization | Select-Object -Property login, id, node_id
            $eventOwner = $gitHubEvent.repository.owner | Select-Object -Property login, type, id, node_id, html_url
            $eventRepository = $gitHubEvent.repository | Select-Object -Property name, full_name, html_url, id, node_id, default_branch

            $gitHubEvent = $gitHubEvent | Select-Object -ExcludeProperty action, sender, enterprise, organization, repository

            $hashtable = @{}
            $gitHubEvent.PSObject.Properties | ForEach-Object {
                $name = $_.Name
                $name = $name | Convert-StringCasingStyle -To PascalCase
                $hashtable[$_.Name] = $_.Value
            }
            $gitHubEvent = [pscustomobject]$hashtable

            $gitHubEvent | Add-Member -MemberType NoteProperty -Name Name -Value $env:GITHUB_EVENT_NAME -Force
            if ($eventAction) {
                $gitHubEvent | Add-Member -MemberType NoteProperty -Name Action -Value $eventAction -Force
            }
            if ($eventSender) {
                $gitHubEvent | Add-Member -MemberType NoteProperty -Name Sender -Value $eventSender -Force
            }
            if ($eventEnterprise) {
                $gitHubEvent | Add-Member -MemberType NoteProperty -Name Enterprise -Value $eventEnterprise -Force
            }
            if ($eventOrganization) {
                $gitHubEvent | Add-Member -MemberType NoteProperty -Name Organization -Value $eventOrganization -Force
            }
            if ($eventOwner) {
                $gitHubEvent | Add-Member -MemberType NoteProperty -Name Owner -Value $eventOwner -Force
            }
            if ($eventRepository) {
                $gitHubEvent | Add-Member -MemberType NoteProperty -Name Repository -Value $eventRepository -Force
            }
            $script:GitHub.Event = $gitHubEvent
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
