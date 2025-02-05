function Get-FunctionsMissingDefaultParameterSet {
    param (
        [string]$Path = 'C:\Repos\GitHub\PSModule\Module\GitHub\src',
        [switch]$Fix = $true
    )

    function Get-IntFunctionsMissingDefaultParameterSet {
        param (
            [string]$ScriptPath
        )

        $scriptContent = Get-Content -Raw -Path $ScriptPath

        try {
            $ast = [System.Management.Automation.Language.Parser]::ParseInput($scriptContent, [ref]$null, [ref]$null)
        } catch {
            Write-Warning "Failed to parse $ScriptPath"
            return
        }

        $functions = $ast.FindAll({ param ($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)

        $fixesNeeded = @()

        foreach ($function in $functions) {
            $cmdletBinding = $function.Body.ParamBlock?.Attributes | Where-Object { $_.TypeName.Name -eq 'CmdletBinding' }

            if ($cmdletBinding) {
                $hasParameterSets = $function.Body.ParamBlock.Parameters | Where-Object { $_.Attributes.NamedArguments -match 'ParameterSetName' }

                if ($hasParameterSets) {
                    $defaultParamSet = $cmdletBinding.NamedArguments | Where-Object { $_.ArgumentName -eq 'DefaultParameterSetName' }

                    if (-not $defaultParamSet) {
                        $fixesNeeded += [PSCustomObject]@{
                            FilePath   = $ScriptPath
                            Function   = $function.Name
                            LineNumber = $function.Extent.StartLineNumber
                            Extent     = $function.Extent
                        }
                    }
                }
            }
        }

        return $fixesNeeded
    }

    function Fix-Script {
        param (
            [string]$ScriptPath,
            [System.Management.Automation.Language.IScriptExtent]$FunctionExtent
        )

        $scriptContent = Get-Content -Raw -Path $ScriptPath

        # Ensure the correct format for the `[CmdletBinding()]` attribute
        $updatedContent = $scriptContent -replace '(?<=\[CmdletBinding\(\s*)\)', "DefaultParameterSetName = '__AllParameterSets')"

        if ($updatedContent -ne $scriptContent) {
            Set-Content -Path $ScriptPath -Value $updatedContent
            Write-Host "Updated: $ScriptPath -> Added DefaultParameterSetName to function at line $($FunctionExtent.StartLineNumber)"
        }
    }

    $results = @()
    $files = Get-ChildItem -Path $Path -Filter *.ps1 -Recurse
    $files += Get-ChildItem -Path $Path -Filter *.psm1 -Recurse

    foreach ($file in $files) {
        $missingDefaults = Get-IntFunctionsMissingDefaultParameterSet -ScriptPath $file.FullName
        if ($missingDefaults) {
            $results += $missingDefaults

            if ($Fix) {
                foreach ($item in $missingDefaults) {
                    Fix-Script -ScriptPath $item.FilePath -FunctionExtent $item.Extent
                }
            }
        }
    }

    if (-not $Fix) {
        if ($results) {
            $results | Format-Table -AutoSize
        } else {
            Write-Host 'No issues found.'
        }
    } else {
        Write-Host 'Fix applied where necessary.'
    }
}
