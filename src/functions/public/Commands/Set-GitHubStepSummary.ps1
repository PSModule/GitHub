function Set-GitHubStepSummary {
    <#
        .SYNOPSIS
        Set a summary for the step in GitHub Actions

        .DESCRIPTION
        You can set some custom Markdown for each job so that it will be displayed on the summary page of a workflow run.
        You can use job summaries to display and group unique content, such as test result summaries, so that someone viewing
        the result of a workflow run doesn't need to go into the logs to see important information related to the run, such as failures.

        Job summaries support GitHub flavored Markdown, and you can add your Markdown content for a step to the `GITHUB_STEP_SUMMARY`
        environment file. `GITHUB_STEP_SUMMARY` is unique for each step in a job. For more information about the per-step file that
        `GITHUB_STEP_SUMMARY` references, see [Environment files](https://docs.github.com/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions?utm_source=chatgpt.com#environment-files).

        When a job finishes, the summaries for all steps in a job are grouped together into a single job summary and are shown on the
        workflow run summary page. If multiple jobs generate summaries, the job summaries are ordered by job completion time.

        .EXAMPLE
        Set-GitHubStepSummary -Summary 'Hello, World!'

        .NOTES
        [Adding a job summary](https://docs.github.com/actions/writing-workflows/choosing-what-your-workflow-does/workflow-commands-for-github-actions?utm_source=chatgpt.com#adding-a-job-summary)
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidLongLines', '', Scope = 'Function',
        Justification = 'Long doc links'
    )]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions', '', Scope = 'Function',
        Justification = 'Does not change system state significantly'
    )]
    [OutputType([void])]
    [Alias('Summary')]
    [CmdletBinding()]
    param(
        # Summary of the step
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [AllowNull()]
        [string] $Summary,

        # Whether to overwrite the existing summary
        [switch] $Overwrite
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        Write-Verbose 'Step summary:'
        Write-Verbose $Summary

        $Append = -not $Overwrite
        if ($env:GITHUB_ACTIONS -eq 'true') {
            $Summary | Out-File -FilePath $env:GITHUB_STEP_SUMMARY -Encoding utf8 -Append:$Append
        } else {
            Write-Host "$Summary"
        }
    }

    end {
        Write-Debug "[$stackPath] - End"
    }
}
