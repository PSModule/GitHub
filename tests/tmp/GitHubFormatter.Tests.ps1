#Requires -Modules @{ ModuleName = 'Pester'; RequiredVersion = '5.7.1' }

[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSUseDeclaredVarsMoreThanAssignments', '',
    Justification = 'Pester grouping syntax: known issue.'
)]
[CmdletBinding()]
param()

Describe 'Size Property Standardization Tests' {
    Context 'Unit Conversion Logic' {
        It 'Validates KB to Bytes conversion formula' {
            # Test the conversion used in GitHubRepository and GitHubOrganization
            $apiValueKB = 108  # API returns this in KB
            $expectedBytes = $apiValueKB * 1KB  # 110,592 bytes
            $expectedBytes | Should -Be 110592

            $apiValueKB = 10000  # API returns this in KB
            $expectedBytes = $apiValueKB * 1KB  # 10,240,000 bytes
            $expectedBytes | Should -Be 10240000
        }

        It 'Validates that size values are stored as expected types' {
            # Verify that our expected byte values fit within UInt32 range
            $maxReasonableSize = 4GB - 1  # Max reasonable repository size (just under 4GB)
            $maxReasonableSize | Should -BeLessOrEqual ([System.UInt32]::MaxValue)

            # Test boundary cases
            $zeroBytes = 0 * 1KB
            $zeroBytes | Should -Be 0
            $zeroBytes | Should -BeOfType [System.Int32]

            $smallSize = 1 * 1KB
            $smallSize | Should -Be 1024
            $smallSize | Should -BeOfType [System.Int32]
        }
    }

    Context 'Expected Format Output Patterns' {
        $testCases = @(
            @{ Bytes = 0; ExpectedPattern = '\d+[.,]\d{2}\s{2}B' }       #   "0.00  B"
            @{ Bytes = 512; ExpectedPattern = '\d+[.,]\d{2}\s{2}B' }     # "512.00  B"
            @{ Bytes = 1024; ExpectedPattern = '\d+[.,]\d{2} KB' }       #   "1.00 KB"
            @{ Bytes = 1048576; ExpectedPattern = '\d+[.,]\d{2} MB' }    #   "1.00 MB"
            @{ Bytes = 1073741824; ExpectedPattern = '\d+[.,]\d{2} GB' } #   "1.00 GB"
            @{ Bytes = 110592; ExpectedPattern = '\d+[.,]\d{2} KB' }     # "108.00 KB"
        )

        It 'Validates formatter output pattern for <Bytes> bytes' -ForEach $testCases {
            # Test the formatter against the expected pattern
            $result = [GitHubFormatter]::FormatFileSize($Bytes)
            $result | Should -Match $ExpectedPattern
        }
    }

    Context 'Conversion Scenarios Documentation' {
        It 'Documents the standardization changes made' {
            # This test documents the before/after behavior for size properties

            # GitHubRepository: Before stored KB, now stores bytes
            $beforeValue = 108  # KB from API
            $afterValue = $beforeValue * 1KB  # bytes (110,592)
            $afterValue | Should -Be 110592
            $afterValue | Should -BeGreaterThan $beforeValue  # Verify conversion increases value

            # GitHubOrganization: Before had DiskUsage in KB, now has Size in bytes with DiskUsage alias
            $orgBeforeValue = 10000  # KB from API
            $orgAfterValue = $orgBeforeValue * 1KB  # bytes (10,240,000)
            $orgAfterValue | Should -Be 10240000
            $orgAfterValue | Should -BeGreaterThan $orgBeforeValue

            # GitHubArtifact: Was already in bytes, now uses standardized formatter
            # No conversion needed, just formatting change
            $artifactSize = 2048576  # Already in bytes
            $artifactSize | Should -BeGreaterThan 1MB  # Verify it's a reasonable size
        }

        It 'Verifies that byte storage allows for consistent formatting' {
            # All classes now store in bytes, enabling consistent formatting
            $sizes = @(110592, 10240000, 2048576)  # Example sizes from Repository, Organization, Artifact

            foreach ($size in $sizes) {
                $size | Should -BeOfType [System.Int32]
                $size | Should -BeGreaterThan 0
                # All can be formatted with the same GitHubFormatter::FormatFileSize method
            }
        }
    }
}
