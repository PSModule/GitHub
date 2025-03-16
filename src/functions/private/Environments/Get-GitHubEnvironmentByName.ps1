filter Get-GitHubEnvironmentByName {
    <#
        .SYNOPSIS
        Retrieves details of a specified GitHub environment.

        .DESCRIPTION
        This function retrieves information about a specific environment in a GitHub repository.
        To get information about name patterns that branches must match in order to deploy to this environment,
        see "[Get a deployment branch policy](https://docs.github.com/rest/deployments/branch-policies#get-a-deployment-branch-policy)."

        Anyone with read access to the repository can use this function.
        OAuth app tokens and personal access tokens (classic) need the `repo` scope
        to use this function with a private repository.

        .EXAMPLE
        Get-GitHubEnvironmentByName -Owner "my-org" -Repository "my-repo" -Name "production" -Context $GitHubContext

        Output:
        ```powershell
        Name        : production
        URL         : https://github.com/my-org/my-repo/environments/production
        Protection  : @{WaitTimer=0; Reviewers=@()}
        ```

        Retrieves details of the "production" environment in the specified repository.

        .OUTPUTS
        PSCustomObject

        .NOTES
        Contains environment details, including name, URL, and protection settings.

        .LINK
        https://psmodule.io/GitHub/Functions/Get-GitHubEnvironmentByName/
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [Alias('Organization', 'User')]
        [string] $Owner,

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $Repository,

        # The name of the environment.
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName
        )]
        [string] $Name,

        # The context to run the command in. Used to get the details for the API call.
        # Can be either a string or a GitHubContext object.
        [Parameter(Mandatory)]
        [object] $Context
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
        Assert-GitHubContext -Context $Context -AuthType IAT, PAT, UAT
    }

    process {
        $inputObject = @{
            Method      = 'GET'
            APIEndpoint = "/repos/$Owner/$Repository/environments/$Name"
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
