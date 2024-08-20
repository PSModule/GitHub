filter Start-GitHubRepositoryEvent {
    <#
        .SYNOPSIS
        Create a repository dispatch event

        .DESCRIPTION
        You can use this endpoint to trigger a webhook event called `repository_dispatch` when you want activity
        that happens outside of GitHub to trigger a GitHub Actions workflow or GitHub App webhook. You must configure
        your GitHub Actions workflow or GitHub App to run when the `repository_dispatch`
        event occurs. For an example `repository_dispatch` webhook payload, see
        "[RepositoryDispatchEvent](https://docs.github.com/webhooks/event-payloads/#repository_dispatch)."

        The `client_payload` parameter is available for any extra information that your workflow might need.
        This parameter is a JSON payload that will be passed on when the webhook event is dispatched. For example,
        the `client_payload` can include a message that a user would like to send using a GitHub Actions workflow.
        Or the `client_payload` can be used as a test to debug your workflow.

        This endpoint requires write access to the repository by providing either:

        - Personal access tokens with `repo` scope. For more information, see
        "[Creating a personal access token for the command line](https://docs.github.com/articles/creating-a-personal-access-token-for-the-command-line)"
        in the GitHub Help documentation.
        - GitHub Apps with both `metadata:read` and `contents:read&write` permissions.

        This input example shows how you can use the `client_payload` as a test to debug your workflow.

        .EXAMPLE
        $params = @{
            EventType = 'on-demand-test'
            ClientPayload = @{
                unit = false
                integration = true
            }
        }
        Start-GitHubRepositoryEvent @params

        Starts a repository event with the name `on-demand-test` and a `client_payload` that includes `unit` and `integration`.

        .NOTES
        [Create a repository dispatch event](https://docs.github.com/rest/repos/repos#create-a-repository-dispatch-event)

    #>
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidLongLines', '', Justification = 'Long links')]
    param (
        # The account owner of the repository. The name is not case sensitive.
        [Parameter()]
        [Alias('org')]
        [string] $Owner = (Get-GitHubConfig -Name Owner),

        # The name of the repository without the .git extension. The name is not case sensitive.
        [Parameter()]
        [string] $Repo = (Get-GitHubConfig -Name Repo),

        # A custom webhook event name. Must be 100 characters or fewer.
        [Parameter(Mandatory)]
        [Alias('event_type')]
        [string] $EventType,

        # JSON payload with extra information about the webhook event that your action or workflow may use.
        # The maximum number of top-level properties is 10.
        [Parameter()]
        [Alias('client_payload')]
        [object] $ClientPayload
    )

    $PSCmdlet.MyInvocation.MyCommand.Parameters.GetEnumerator() | ForEach-Object {
        $paramName = $_.Key
        $paramDefaultValue = Get-Variable -Name $paramName -ValueOnly -ErrorAction SilentlyContinue
        $providedValue = $PSBoundParameters[$paramName]
        Write-Verbose "[$paramName]"
        Write-Verbose "  - Default:  [$paramDefaultValue]"
        Write-Verbose "  - Provided: [$providedValue]"
        if (-not $PSBoundParameters.ContainsKey($paramName) -and ($null -ne $paramDefaultValue)) {
            Write-Verbose '  - Using default value'
            $PSBoundParameters[$paramName] = $paramDefaultValue
        } else {
            Write-Verbose '  - Using provided value'
        }
    }

    $body = $PSBoundParameters | ConvertFrom-HashTable | ConvertTo-HashTable -NameCasingStyle snake_case
    Remove-HashtableEntry -Hashtable $body -RemoveNames 'Owner', 'Repo' -RemoveTypes 'SwitchParameter'

    $inputObject = @{
        APIEndpoint = "/repos/$Owner/$Repo/dispatches"
        Method      = 'POST'
        Body        = $body
    }

    Invoke-GitHubAPI @inputObject | ForEach-Object {
        Write-Output $_.Response
    }
}
