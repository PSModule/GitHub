function New-FunctionTemplate {
    <#
        .SYNOPSIS
        Short description

        .DESCRIPTION
        Long description

        .EXAMPLE
        An example

        .NOTES
        [Ttle](link)
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The name of the organization.
        [Parameter()]
        [string]$Owner,

        # The name of the organization.
        [Parameter()]
        [string]$Repo,

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

        if ([string]::IsNullOrEmpty($Enterprise)) {
            $Enterprise = $Context.Enterprise
        }
        Write-Debug "Enterprise : [$($Context.Enterprise)]"

        if ([string]::IsNullOrEmpty($Owner)) {
            $Owner = $Context.Owner
        }
        Write-Debug "Owner : [$($Context.Owner)]"

        if ([string]::IsNullOrEmpty($Repo)) {
            $Repo = $Context.Repo
        }
        Write-Debug "Repo : [$($Context.Repo)]"
    }

    process {
        try {
            $body = @{
                per_page = $PerPage
            }

            $inputObject = @{
                Context     = $Context
                APIEndpoint = "/orgs/$OrganizationName/blocks"
                Method      = 'GET'
                Body        = $body
            }

            if ($PSCmdlet.ShouldProcess('Target', 'Operation')) {
                Invoke-GitHubAPI @inputObject | ForEach-Object {
                    Write-Output $_.Response
                }
            }
        } catch {
            Write-Debug "Error: $_"
        } finally {
            Write-Debug 'Finally'
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }

    clean {
        Write-Debug 'Clean'
    }
}
