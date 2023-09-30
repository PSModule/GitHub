function Get-GitHubEmojis {
    <#
        .NOTES
        https://docs.github.com/en/rest/reference/emojis#get-emojis
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string] $Destination
    )

    $inputObject = @{
        APIEndpoint = '/emojis'
        Method      = 'GET'
    }

    $response = (Invoke-GitHubAPI @inputObject).Response

    if (Test-Path -Path $Destination) {
        $response.PSObject.Properties | ForEach-Object -Parallel {
            Invoke-WebRequest -Uri $_.Value -OutFile "$using:Destination/$($_.Name).png"
        }
    } else {
        $response
    }
}
