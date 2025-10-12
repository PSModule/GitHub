function New-Function {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .EXAMPLE
    ```pwsh
    New-Function -Path '/user/emails' -Method 'POST'
    ```

    An example

    .NOTES
    General notes
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # Parameter description
        [Parameter(Mandatory)]
        [string] $Path,

        # Parameter description
        [Parameter(Mandatory)]
        [string] $Method
    )

    $APIDocURI = 'https://raw.githubusercontent.com/github/rest-api-description/main'
    $Bundled = '/descriptions/api.github.com/api.github.com.json'
    # $Dereferenced = 'descriptions/api.github.com/dereferenced/api.github.com.deref.json'
    $APIDocURI = $APIDocURI + $Bundled
    $response = Invoke-RestMethod -Uri $APIDocURI -Method Get

    $response.paths.$Path.$Method

    $FunctionName = "$Method-GitHub" + (($response.paths.$path.$method.operationId) -replace '/', '-')

    $folderName = $response.paths.$path.$method.'x-github'.category
    $subFolderName = $response.paths.$path.$method.'x-github'.subcategory

    $template = @"
    function $FunctionName {
        <#
            .SYNOPSIS
            $($response.paths.$path.$method.summary)

            .DESCRIPTION
            $($response.paths.$path.$method.description)

            .EXAMPLE
            An example

            .NOTES
            [$($response.paths.$path.$method.summary)]($($response.paths.$path.$method.externalDocs.url))
        #>
        [OutputType([pscustomobject])]
        [CmdletBinding()]
        param(
            # The context to run the command in.
            [Parameter()]
            [string] `$Context = (Get-GitHubConfig -Name 'DefaultContext')
        )
    }
"@
    if ($PSCmdlet.ShouldProcess('Function', 'Create')) {
        New-Item -Path "src/functions/$folderName/$subFolderName" -Name "$FunctionName.ps1" -ItemType File -Value $template
    }

}
