function Update-GitHubVariableOnRepository {
    <#
        .SYNOPSIS
        Update a repository variable.

        .DESCRIPTION
        Updates a repository variable that you can reference in a GitHub Actions workflow.
        Authenticated users must have collaborator access to a repository to create, update, or read variables.
        OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

        .EXAMPLE
        Update-GitHubVariableOnRepository -Owner 'octocat' -Repository 'Hello-World' -Name 'HOST_NAME' -Value 'github.com' -Context $GitHubContext

        Updates the repository variable named `HOST_NAME` with the value `github.com` in the specified repository.

        .LINK
        [Update a repository variable](https://docs.github.com/rest/actions/variables#update-a-repository-variable)
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The account owner of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Owner,

        # The name of the repository. The name is not case sensitive.
        [Parameter(Mandatory)]
        [string] $Repository,

        # The name of the variable.
        [Parameter(Mandatory)]
        [string] $Name,

        # The new name of the variable.
        [Parameter()]
        [string] $NewName,

        # The value of the variable.
        [Parameter()]
        [string] $Value,

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
        $body = @{}
        if ($PSBoundParameters.ContainsKey('NewName')) {
            $body.name = $NewName
        }
        if ($PSBoundParameters.ContainsKey('Value')) {
            $body.value = $Value
        }

        $inputObject = @{
            Method      = 'PATCH'
            APIEndpoint = "/repos/$Owner/$Repository/actions/variables/$Name"
            Body        = $body
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("variable [$Name] on [$Owner/$Repository]", 'Update')) {
            $null = Invoke-GitHubAPI @inputObject
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
