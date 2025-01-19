filter ConvertFrom-IssueBody {
    <#
        .SYNOPSIS
        Converts the issue body content into a hashtable or object.

        .DESCRIPTION
        Aligns with the issue body content structure and converts it into a hashtable or object.
        Section titles become keys and their content becomes values.

        .EXAMPLE
        @'
        ### Section 1
        Content 1
        Content 2

        ### Section 2
        - [ ] Item 1
        - [x] Item 2
        '@ | ConvertFrom-IssueBody
        Section 1            Section 2
        ---------            ---------
        Content 1…           {[Item 2, True], [Item 1, False]}

        Converts the issue body content into a hashtable.

    #>
    [OutputType([PSCustomObject])]
    [OutputType([hashtable])]
    [CmdletBinding()]
    param(
        # The issue body content to parse.
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [string] $IssueBody,

        # If set, the output will be a hashtable instead of an object.
        [Parameter()]
        [switch] $AsHashtable
    )

    begin {
        $stackPath = Get-PSCallStackPath
        Write-Debug "[$stackPath] - Start"
    }

    process {
        # Clean up the issue body
        $content = $IssueBody -replace '<!--[\s\S]*?-->'
        $content = $content.Split([Environment]::NewLine).Trim() | Where-Object { $_ -ne '' }

        $results = @()
        $currentHeader = ''
        $currentParagraph = @()

        foreach ($line in $content) {
            Write-Verbose "Processing line: [$line]"

            if ($line -match '^### (.+)$') {
                Write-Verbose ' - Is header'
                # If a new header is found, store the current header and paragraph in the results
                if ($currentHeader -ne '') {
                    $results += [PSCustomObject]@{
                        Header    = $currentHeader
                        Paragraph = $currentParagraph.Trim()
                    }
                }

                # Update the newly detected header and reset the paragraph
                $currentHeader = $matches[1]
                $currentParagraph = @()
            } else {
                # Append the line to the current paragraph
                $currentParagraph += $line
            }
        }

        # Add the last header and paragraph to the results
        if ($currentHeader -ne '') {
            $results += [PSCustomObject]@{
                Header    = $currentHeader
                Paragraph = $currentParagraph.Trim()
            }
        }

        # Process each entry
        $data = @{}
        foreach ($entry in $results) {
            $header = $entry.Header
            $paragraph = $entry.Paragraph

            if ($paragraph -is [string]) {
                # Assign string value directly
                $data[$header] = $paragraph
            } elseif ($paragraph -is [array]) {
                # Check if it's a multi-line string or checkbox list
                if ($paragraph -match '^\s*- \[.\]\s') {
                    # It's a checkbox list, process as key-value pairs
                    $checkboxHashTable = @{}
                    foreach ($line in $paragraph) {
                        if ($line -match '^\s*- \[(x| )\]\s*(.+)$') {
                            $checked = $matches[1] -eq 'x'
                            $item = $matches[2]
                            $checkboxHashTable[$item] = $checked
                        }
                    }
                    $data[$header] = $checkboxHashTable
                } else {
                    # It's a multi-line string
                    $data[$header] = $paragraph -join [System.Environment]::NewLine
                }
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
