function Remove-GitHubVariableOnEnvironment {
    <#
        .SYNOPSIS

        .DESCRIPTION

        .EXAMPLE

        .LINK
        []()
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

        # The name of the repository environment.
        [Parameter(Mandatory)]
        [string] $Environment,

        # The name of the variable.
        [Parameter(Mandatory)]
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
            Method      = 'DELETE'
            APIEndpoint = "/repos/$Owner/$Repository/environments/$Environment/variables/$Name"
            Context     = $Context
        }

        if ($PSCmdlet.ShouldProcess("variable [$Name] on [$Owner/$Repository/$Environment]", 'Delete')) {
            Invoke-GitHubAPI @inputObject
            # Invoke-GitHubAPI @inputObject | ForeEach-Object {
            #     Write-Output $_.Response
            # }
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
