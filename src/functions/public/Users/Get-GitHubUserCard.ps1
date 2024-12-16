filter Get-GitHubUserCard {
    <#
        .SYNOPSIS
        Get contextual information for a user

        .DESCRIPTION
        Provides hovercard information when authenticated through basic auth or OAuth with the `repo` scope.
        You can find out more about someone in relation to their pull requests, issues, repositories, and organizations.

        The `subject_type` and `subject_id` parameters provide context for the person's hovercard, which returns
        more information than without the parameters. For example, if you wanted to find out more about `octocat`
        who owns the `Spoon-Knife` repository via cURL, it would look like this:

        ```shell
        curl -u username:token
        https://api.github.com/users/octocat/hovercard?subject_type=repository&subject_id=1300192
        ```

        .EXAMPLE

        .NOTES
        [Get contextual information for a user](https://docs.github.com/rest/users/users#get-contextual-information-for-a-user)

    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string] $Username,

        [Parameter()]
        [ValidateSet('organization', 'repository', 'issue', 'pull_request')]
        [string] $SubjectType,

        [Parameter()]
        [int] $SubjectID = '',

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter()]
        [object] $Context = (Get-GitHubContext)
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        $Context = Resolve-GitHubContext -Context $Context
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        try {
            $body = @{
                subject_type = $SubjectType
                subject_id   = $SubjectID
            }

            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/users/$Username/hovercard"
                Method      = 'GET'
                Body        = $body
            }

            Invoke-GitHubAPI @inputObject | ForEach-Object {
                Write-Output $_.Response
            }
        } catch {
            throw $_
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
