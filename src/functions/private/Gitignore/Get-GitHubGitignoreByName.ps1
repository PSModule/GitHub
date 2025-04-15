filter Get-GitHubGitignoreByName {
    <#
        .SYNOPSIS
        Get a gitignore template

        .DESCRIPTION
        The API also allows fetching the source of a single template.
        Use the raw [media type](https://docs.github.com/rest/overview/media-types/) to get the raw contents.

        .EXAMPLE
        Get-GitHubGitignoreList

        Get all gitignore templates

        .NOTES
        https://docs.github.com/rest/gitignore/gitignore#get-a-gitignore-template

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string] $Name,

        # If specified, makes an anonymous request to the GitHub API without authentication.
        [Parameter()]
        [switch] $Anonymous,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        if (-not $Anonymous) {
            Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
        }
    }

    process {
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/gitignore/templates/$Name"
            Accept      = 'application/vnd.github.raw+json'
            Anonymous   = $Anonymous
            Context     = $Context
        }

        Invoke-GitHubAPI @inputObject | ForEach-Object {
            Write-Output $_.Response
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
