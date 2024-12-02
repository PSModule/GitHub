$inFileContent = @'
zen=Non-blocking is better than blocking.
something={"MyOutput":"Hello, World!", "MyArray":[1,2,3]}
MY_VALUE<<EOF
multi
line
value
EOF
'@ -split "`n"

$outputs = ConvertFrom-GitHubOutput -InputData $inFileContent
$outputs | Format-List
$outputs.something
$outputs.something.MyOutput
$outputs.something.MyArray


$outputs = $inFileContent | ConvertFrom-GitHubOutput -AsHashtable
$outputs | Format-List
$outputs.something

$outFileContent = ConvertTo-GitHubOutput -InputObject $outputs
$outFileContent

$env:PSMODULE_GITHUB_SCRIPT = $false
Set-GitHubOutput -Name 'MyOutput' -Value 'Hello, World!'
Set-GitHubOutput -Name 'MyArray' -Value (@(1, 2, 3) | ConvertTo-Json)

$env:PSMODULE_GITHUB_SCRIPT = $true
Set-GitHubOutput -Name 'MyOutput' -Value 'Hello, World!'
Set-GitHubOutput -Name 'MyArray' -Value @(1, 2, 3)

Get-GitHubOutput -Path '.\GITHUB_OUTPUT'
