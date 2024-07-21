function Find-APIMethod {
    <#
        .SYNOPSIS
        Find API methods in a directory
    #>
    param (
        [Parameter(Mandatory)]
        [string] $SearchDirectory,

        [Parameter(Mandatory)]
        [string] $Method,

        [Parameter(Mandatory)]
        [string] $Path
    )

    $pathPattern = $Path -replace '\{[^}]+\}', '.+'
    $methodPattern = "Method\s*=\s*'$method'"
    Get-ChildItem -Path $SearchDirectory -Recurse -Filter *.ps1 | ForEach-Object {
        $filePath = $_.FullName
        $stringMatches = Select-String -Path $filePath -Pattern $pathPattern -AllMatches
        if ($stringMatches.Count -gt 0) {
            $putMatches = Select-String -Path $filePath -Pattern $methodPattern -AllMatches
            foreach ($match in $stringMatches) {
                foreach ($putMatch in $putMatches) {
                    Write-Verbose "Match found in file: $filePath"
                    Write-Verbose "API Endpoint: $($match.Matches.Value) near line $($match.LineNumber)"
                    Write-Verbose "Method: $($putMatch.Matches.Value) near line $($putMatch.LineNumber)"
                    return $true
                }
            }
        }
    }
    return $false
}

$APIDocURI = 'https://raw.githubusercontent.com/github/rest-api-description/main'
$Bundled = '/descriptions/api.github.com/api.github.com.json'
$APIDocURI = $APIDocURI + $Bundled
$response = Invoke-RestMethod -Uri $APIDocURI -Method Get

# Get a list of all
$functions = 0
$coveredFunctions = 0
$paths = [System.Collections.Generic.List[pscustomobject]]::new()
$SearchDirectory = '.\src'
$response.paths.PSObject.Properties | ForEach-Object {
    $path = $_.Name
    $object = [pscustomobject]@{
        Path   = $path
        DELETE = ''
        GET    = ''
        PATCH  = ''
        POST   = ''
        PUT    = ''
    }
    $_.Value.psobject.Properties.Name | ForEach-Object {
        $method = $_.ToUpper()
        $found = Find-APIMethod -SearchDirectory $SearchDirectory -Method $method -Path $path
        $object.$method = $found -contains $true ? ':white_check_mark:' : ':x:'
        if ($found) {
            $coveredFunctions++
        }
        $functions++
    }
    $paths.Add($object)
}

# Output the context of $paths to a markdown table and into the Coverage.md file
$coverageContent = @"
# Coverage report

## Statistics

<table>
    <tr>
        <td>Available functions</td>
        <td>$functions</td>
    </tr>
    <tr>
        <td>Covered functions</td>
        <td>$coveredFunctions</td>
    </tr>
    <tr>
        <td>Missing functions</td>
        <td>$($functions - $coveredFunctions)</td>
    </tr>
    <tr>
        <td>Coverage</td>
        <td>$([math]::Round(($coveredFunctions / $functions) * 100, 2))%</td>
    </tr>
</table>

## API Endpoints

$($paths | New-MDTable)

"@
$coverageContent | Out-File -FilePath '.\Coverage.md'
Get-Content -Path '.\Coverage.md' | foreach { Write-Verbose $_ -Verbose }

