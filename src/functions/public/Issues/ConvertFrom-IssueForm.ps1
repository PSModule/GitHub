function ConvertFrom-IssueForm {
    <#
        .SYNOPSIS
        Converts the issue form content into a hashtable or object.

        .DESCRIPTION
        Aligns with the issue form content structure and converts it into a hashtable or object.
        Section titles become keys and their content becomes values.

        .EXAMPLE
        @'
        ### Section 1
        Content 1
        Content 2

        ### Section 2
        - [ ] Item 1
        - [x] Item 2
        '@ | ConvertFrom-IssueForm
        Section 1            Section 2
        ---------            ---------
        Content 1…           {[Item 2, True], [Item 1, False]}

        Converts the issue form content into a hashtable.

    #>
    [OutputType([PSCustomObject])]
    [OutputType([hashtable])]
    [CmdletBinding()]
    param(
        # The issue form content to parse.
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [string] $IssueForm,

        # If set, the output will be a hashtable instead of an object.
        [Parameter()]
        [switch] $AsHashtable
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        # Properly remove HTML comments
        $content = $IssueForm -replace '(?s)<!--.*?-->'
        $content = $content -split '\r?\n' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }

        $results = @()
        $currentHeader = ''
        $currentParagraph = @()

        foreach ($line in $content) {
            Write-Verbose "Processing line: [$line]"

            if ($line -match '^### (.+)$') {
                Write-Verbose ' - Is header'
                if ($currentHeader -ne '') {
                    $results += [PSCustomObject]@{
                        Header    = $currentHeader
                        Paragraph = $currentParagraph
                    }
                }

                $currentHeader = $matches[1]
                $currentParagraph = @()
            } else {
                $currentParagraph += $line
            }
        }

        if ($currentHeader -ne '') {
            $results += [PSCustomObject]@{
                Header    = $currentHeader
                Paragraph = $currentParagraph
            }
        }

        $data = @{}
        foreach ($entry in $results) {
            $header = $entry.Header
            $paragraph = $entry.Paragraph

            if ($paragraph -match '^\s*-\s*\[.\]\s+') {
                $checkboxHashTable = @{}
                foreach ($line in $paragraph) {
                    if ($line -match '^\s*-\s*\[(x| )\]\s*(.+)$') {
                        $checked = $matches[1] -eq 'x'
                        $item = $matches[2]
                        $checkboxHashTable[$item] = $checked
                    }
                }
                $data[$header] = $checkboxHashTable
            } else {
                $data[$header] = ($paragraph | ForEach-Object { $_.Trim(); Write-Verbose $_ }) -join [Environment]::NewLine
            }
        }

        if ($AsHashtable) {
            return $data
        }

        [PSCustomObject]$data
    }


    end {
        Write-Debug "[$stackPath] - End"
    }
}
