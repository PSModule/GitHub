[CmdletBinding()]
param()
$baseName = [System.IO.Path]::GetFileNameWithoutExtension($PSCommandPath)
$script:PSModuleInfo = Test-ModuleManifest -Path "$PSScriptRoot\$baseName.psd1"
$script:PSModuleInfo | Format-List | Out-String -Stream | ForEach-Object { Write-Debug $_ }
$scriptName = 'Context'
Write-Debug "[$scriptName] - Importing module"

#region - From [classes] - [public]
Write-Debug "[$scriptName] - [classes] - [public] - Processing folder"

#region - From [classes] - [public] - [Context]
Write-Debug "[$scriptName] - [classes] - [public] - [Context] - Importing"

class Context {
    # The context ID.
    # Context:<Something you choose>
    [string] $ID

    # Creates a context object with the specified ID.
    Context([string]$ID) {
        $this.ID = $ID
    }

    # Creates a context object from a hashtable of key-vaule pairs.
    Context([hashtable]$Properties) {
        foreach ($Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
    }

    # Creates a context object from a PSCustomObject.
    Context([PSCustomObject]$Object) {
        $Object.PSObject.Properties | ForEach-Object {
            $this.($_.Name) = $_.Value
        }
    }

    # Returns the context ID.
    [string] ToString() {
        return $this.ID
    }
}

Write-Debug "[$scriptName] - [classes] - [public] - [Context] - Done"
#endregion - From [classes] - [public] - [Context]

Write-Debug "[$scriptName] - [classes] - [public] - Done"
#endregion - From [classes] - [public]

#region - From [functions] - [private]
Write-Debug "[$scriptName] - [functions] - [private] - Processing folder"

#region - From [functions] - [private] - [JsonToObject]
Write-Debug "[$scriptName] - [functions] - [private] - [JsonToObject] - Processing folder"

#region - From [functions] - [private] - [JsonToObject] - [Convert-ContextHashtableToObjectRecursive]
Write-Debug "[$scriptName] - [functions] - [private] - [JsonToObject] - [Convert-ContextHashtableToObjectRecursive] - Importing"

function Convert-ContextHashtableToObjectRecursive {
    <#
        .SYNOPSIS
        Converts a hashtable to a context object.

        .DESCRIPTION
        This function is used to convert a hashtable to a context object.
        String values that are prefixed with '[SECURESTRING]', are converted back to SecureString objects.
        Other values are converted to their original types, like ints, booleans, string, arrays, and nested objects.

        .EXAMPLE
        Convert-ContextHashtableToObjectRecursive -Hashtable @{
            Name   = 'Test'
            Token  = '[SECURESTRING]TestToken'
            Nested = @{
                Name  = 'Nested'
                Token = '[SECURESTRING]NestedToken'
            }
        }

        This example converts a hashtable to a context object, where the 'Token' and 'Nested.Token' values are SecureString objects.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText', '',
        Justification = 'The securestring is read from the object this function reads.'
    )]
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # Hashtable to convert to context object
        [object] $Hashtable
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
    }

    process {
        try {
            $result = [pscustomobject]@{}

            foreach ($key in $Hashtable.Keys) {
                $value = $Hashtable[$key]
                Write-Debug "Processing [$key]"
                Write-Debug "Value: $value"
                Write-Debug "Type:  $($value.GetType().Name)"
                if ($value -is [string] -and $value -like '`[SECURESTRING`]*') {
                    Write-Debug "Converting [$key] as [SecureString]"
                    $secureValue = $value -replace '^\[SECURESTRING\]', ''
                    $result | Add-Member -NotePropertyName $key -NotePropertyValue ($secureValue | ConvertTo-SecureString -AsPlainText -Force)
                } elseif ($value -is [hashtable]) {
                    Write-Debug "Converting [$key] as [hashtable]"
                    $result | Add-Member -NotePropertyName $key -NotePropertyValue (Convert-ContextHashtableToObjectRecursive $value)
                } elseif ($value -is [array]) {
                    Write-Debug "Converting [$key] as [IEnumerable], including arrays and hashtables"
                    $result | Add-Member -NotePropertyName $key -NotePropertyValue @(
                        $value | ForEach-Object {
                            if ($_ -is [hashtable]) {
                                Convert-ContextHashtableToObjectRecursive $_
                            } else {
                                $_
                            }
                        }
                    )
                } else {
                    Write-Debug "Converting [$key] as regular value"
                    $result | Add-Member -NotePropertyName $key -NotePropertyValue $value
                }
            }
            return $result
        } catch {
            Write-Error $_
            throw 'Failed to convert hashtable to object'
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}

Write-Debug "[$scriptName] - [functions] - [private] - [JsonToObject] - [Convert-ContextHashtableToObjectRecursive] - Done"
#endregion - From [functions] - [private] - [JsonToObject] - [Convert-ContextHashtableToObjectRecursive]
#region - From [functions] - [private] - [JsonToObject] - [ConvertFrom-ContextJson]
Write-Debug "[$scriptName] - [functions] - [private] - [JsonToObject] - [ConvertFrom-ContextJson] - Importing"

function ConvertFrom-ContextJson {
    <#
        .SYNOPSIS
        Converts a JSON string to a context object.

        .DESCRIPTION
        Converts a JSON string to a context object.
        [SECURESTRING] prefixed text is converted to SecureString objects.
        Other values are converted to their original types, like ints, booleans, string, arrays, and nested objects.

        .EXAMPLE
        ConvertFrom-ContextJson -JsonString '{
            "Name": "Test",
            "Token": "[SECURESTRING]TestToken",
            "Nested": {
                "Name": "Nested",
                "Token": "[SECURESTRING]NestedToken"
            }
        }'

        This example converts a JSON string to a context object, where the 'Token' and 'Nested.Token' values are SecureString objects.
    #>
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param (
        # JSON string to convert to context object
        [Parameter()]
        [string] $JsonString = '{}'
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
    }

    process {
        try {
            $hashtableObject = $JsonString | ConvertFrom-Json -Depth 100 -AsHashtable
            return Convert-ContextHashtableToObjectRecursive $hashtableObject
        } catch {
            Write-Error $_
            throw 'Failed to convert JSON to object'
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}

Write-Debug "[$scriptName] - [functions] - [private] - [JsonToObject] - [ConvertFrom-ContextJson] - Done"
#endregion - From [functions] - [private] - [JsonToObject] - [ConvertFrom-ContextJson]

Write-Debug "[$scriptName] - [functions] - [private] - [JsonToObject] - Done"
#endregion - From [functions] - [private] - [JsonToObject]

#region - From [functions] - [private] - [ObjectToJSON]
Write-Debug "[$scriptName] - [functions] - [private] - [ObjectToJSON] - Processing folder"

#region - From [functions] - [private] - [ObjectToJSON] - [Convert-ContextObjectToHashtableRecursive]
Write-Debug "[$scriptName] - [functions] - [private] - [ObjectToJSON] - [Convert-ContextObjectToHashtableRecursive] - Importing"

function Convert-ContextObjectToHashtableRecursive {
    <#
        .SYNOPSIS
        Converts a context object to a hashtable.

        .DESCRIPTION
        This function converts a context object to a hashtable.
        Secure strings are converted to a string representation, prefixed with '[SECURESTRING]'.
        Datetime objects are converted to a string representation using the 'o' format specifier.
        Nested context objects are recursively converted to hashtables.

        .EXAMPLE
        Convert-ContextObjectToHashtableRecursive -Object ([PSCustomObject]@{
            Name = 'MySecret'
            AccessToken = '123123123' | ConvertTo-SecureString -AsPlainText -Force
            Nested = @{
                Name = 'MyNestedSecret'
                NestedAccessToken = '123123123' | ConvertTo-SecureString -AsPlainText -Force
            }
        })

        Converts the context object to a hashtable. Converts the AccessToken and NestedAccessToken secure strings to a string representation.
    #>
    [OutputType([hashtable])]
    [CmdletBinding()]
    param (
        # The object to convert.
        [Parameter()]
        [object] $Object = @{}
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
    }

    process {
        try {
            $result = @{}

            if ($Object -is [hashtable]) {
                Write-Debug 'Converting [hashtable] to [PSCustomObject]'
                $Object = [PSCustomObject]$Object
            } elseif ($Object -is [string] -or $Object -is [int] -or $Object -is [bool]) {
                Write-Debug 'returning as string'
                return $Object
            }

            foreach ($property in $Object.PSObject.Properties) {
                $name = $property.Name
                $value = $property.Value
                Write-Debug "Processing [$name]"
                Write-Debug "Value: $value"
                Write-Debug "Type:  $($value.GetType().Name)"
                if ($value -is [datetime]) {
                    Write-Debug '- as DateTime'
                    $result[$property.Name] = $value.ToString('o')
                } elseif ($value -is [string] -or $Object -is [int] -or $Object -is [bool]) {
                    Write-Debug '- as string, int, bool'
                    $result[$property.Name] = $value
                } elseif ($value -is [System.Security.SecureString]) {
                    Write-Debug '- as SecureString'
                    $value = $value | ConvertFrom-SecureString -AsPlainText
                    $result[$property.Name] = "[SECURESTRING]$value"
                } elseif ($value -is [psobject] -or $value -is [PSCustomObject] -or $value -is [hashtable]) {
                    Write-Debug '- as PSObject, PSCustomObject or hashtable'
                    $result[$property.Name] = Convert-ContextObjectToHashtableRecursive $value
                } elseif ($value -is [System.Collections.IEnumerable]) {
                    Write-Debug '- as IEnumerable, including arrays and hashtables'
                    $result[$property.Name] = @(
                        $value | ForEach-Object {
                            Convert-ContextObjectToHashtableRecursive $_
                        }
                    )
                } else {
                    Write-Debug '- as regular value'
                    $result[$property.Name] = $value
                }
            }
            return $result
        } catch {
            Write-Error $_
            throw 'Failed to convert context object to hashtable'
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}

Write-Debug "[$scriptName] - [functions] - [private] - [ObjectToJSON] - [Convert-ContextObjectToHashtableRecursive] - Done"
#endregion - From [functions] - [private] - [ObjectToJSON] - [Convert-ContextObjectToHashtableRecursive]
#region - From [functions] - [private] - [ObjectToJSON] - [ConvertTo-ContextJson]
Write-Debug "[$scriptName] - [functions] - [private] - [ObjectToJSON] - [ConvertTo-ContextJson] - Importing"

function ConvertTo-ContextJson {
    <#
        .SYNOPSIS
        Takes an object and converts it to a JSON string.

        .DESCRIPTION
        Takes objects or hashtables and converts them to a JSON string.
        SecureStrings are converted to plain text strings and prefixed with [SECURESTRING]. The conversion is recursive for any nested objects.
        Use ConvertFrom-ContextJson to convert back to an object.

        .EXAMPLE
        ConvertTo-ContextJson -Context ([pscustomobject]@{
            Name = 'MySecret'
            AccessToken = '123123123' | ConvertTo-SecureString -AsPlainText -Force
        })

        Returns a JSON string representation of the object.

        ```json
        {
            "Name": "MySecret",
            "AccessToken ": "[SECURESTRING]123123123"
        }
        ```
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param (
        # The object to convert to a Context JSON string.
        [Parameter()]
        [object] $Context = @{},

        # The ID of the context.
        [Parameter(Mandatory)]
        [string] $ID
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
    }

    process {
        try {
            $processedObject = Convert-ContextObjectToHashtableRecursive $Context
            $processedObject['ID'] = $ID
            return ($processedObject | ConvertTo-Json -Depth 100 -Compress)
        } catch {
            Write-Error $_
            throw 'Failed to convert object to JSON'
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}

Write-Debug "[$scriptName] - [functions] - [private] - [ObjectToJSON] - [ConvertTo-ContextJson] - Done"
#endregion - From [functions] - [private] - [ObjectToJSON] - [ConvertTo-ContextJson]

Write-Debug "[$scriptName] - [functions] - [private] - [ObjectToJSON] - Done"
#endregion - From [functions] - [private] - [ObjectToJSON]

#region - From [functions] - [private] - [Get-ContextVault]
Write-Debug "[$scriptName] - [functions] - [private] - [Get-ContextVault] - Importing"

#Requires -Modules @{ ModuleName = 'Microsoft.PowerShell.SecretManagement'; RequiredVersion = '1.1.2' }

function Get-ContextVault {
    <#
        .SYNOPSIS
        Retrieves the context vault.

        .DESCRIPTION
        Connects to a context vault.
        If the vault name is not set in the configuration, it throws an error.
        If the specified vault is not found, it throws an error.
        Otherwise, it returns the secret vault object.

        .EXAMPLE
        Get-ContextVault

        This example retrieves the context vault.
    #>
    [CmdletBinding()]
    param()

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
    }

    process {
        try {
            if (-not $script:Config.Initialized) {
                Initialize-ContextVault
                Write-Debug "Connected to context vault [$($script:Config.VaultName)]"
            }
        } catch {
            Write-Error $_
            throw 'Failed to initialize secret vault'
        }

        try {
            $secretVault = Get-SecretVault -Verbose:$false | Where-Object { $_.Name -eq $script:Config.VaultName }
            if (-not $secretVault) {
                Write-Error $_
                throw "Context vault [$($script:Config.VaultName)] not found"
            }

            return $secretVault
        } catch {
            Write-Error $_
            throw 'Failed to get context vault'
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}

Write-Debug "[$scriptName] - [functions] - [private] - [Get-ContextVault] - Done"
#endregion - From [functions] - [private] - [Get-ContextVault]
#region - From [functions] - [private] - [Initialize-ContextVault]
Write-Debug "[$scriptName] - [functions] - [private] - [Initialize-ContextVault] - Importing"

#Requires -Modules @{ ModuleName = 'Microsoft.PowerShell.SecretManagement'; RequiredVersion = '1.1.2' }
#Requires -Modules @{ ModuleName = 'Microsoft.PowerShell.SecretStore'; RequiredVersion = '1.0.6' }

function Initialize-ContextVault {
    <#
        .SYNOPSIS
        Initialize a context vault.

        .DESCRIPTION
        Initialize a context vault. If the vault does not exist, it will be created and registered.

        The SecretStore is created with the following parameters:
        - Authentication: None
        - PasswordTimeout: -1 (infinite)
        - Interaction: None
        - Scope: CurrentUser

        .EXAMPLE
        Initialize-ContextVault

        Initializes a context vault named 'ContextVault' using the 'Microsoft.PowerShell.SecretStore' module.
    #>
    [OutputType([Microsoft.PowerShell.SecretManagement.SecretVaultInfo])]
    [CmdletBinding()]
    param (
        # The name of the secret vault.
        [Parameter()]
        [string] $Name = $script:Config.VaultName,

        # The type of the secret vault.
        [Parameter()]
        [string] $Type = $script:Config.VaultType
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
    }

    process {
        try {
            $vault = Get-SecretVault -Verbose:$false | Where-Object { $_.ModuleName -eq $Type }
            if (-not $vault) {
                Write-Debug "[$Type] - Configuring vault type"

                $vaultParameters = @{
                    Authentication  = 'None'
                    PasswordTimeout = -1
                    Interaction     = 'None'
                    Scope           = 'CurrentUser'
                    WarningAction   = 'SilentlyContinue'
                    Confirm         = $false
                    Force           = $true
                    Verbose         = $false
                }
                Reset-SecretStore @vaultParameters
                Write-Debug "[$Type] - Done"
                $script:Config.VaultName = $vault.Name
                Write-Debug "[$Name] - Registering vault"
                $secretVault = @{
                    Name         = $Name
                    ModuleName   = $Type
                    DefaultVault = $true
                    Description  = 'SecretStore'
                    Verbose      = $false
                }
                Register-SecretVault @secretVault
                Write-Debug "[$Name] - Done"
            }
            $script:Config.VaultName = $vault.Name

            Get-SecretVault -Verbose:$false | Where-Object { $_.ModuleName -eq $Type }
            Write-Debug "[$Name] - Vault registered"
            $script:Config.Initialized = $true
        } catch {
            Write-Error $_
            throw 'Failed to initialize context vault'
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}

Write-Debug "[$scriptName] - [functions] - [private] - [Initialize-ContextVault] - Done"
#endregion - From [functions] - [private] - [Initialize-ContextVault]

Write-Debug "[$scriptName] - [functions] - [private] - Done"
#endregion - From [functions] - [private]

#region - From [functions] - [public]
Write-Debug "[$scriptName] - [functions] - [public] - Processing folder"

#region - From [functions] - [public] - [Get-Context]
Write-Debug "[$scriptName] - [functions] - [public] - [Get-Context] - Importing"

#Requires -Modules @{ ModuleName = 'Microsoft.PowerShell.SecretManagement'; RequiredVersion = '1.1.2' }

filter Get-Context {
    <#
        .SYNOPSIS
        Retrieves a context from the context vault.

        .DESCRIPTION
        Retrieves a context from the context vault.
        If no name is specified, all contexts from the context vault will be retrieved.

        .EXAMPLE
        Get-Context

        Get all contexts from the context vault.

        .EXAMPLE
        Get-Context -ID 'MySecret'

        Get the context called 'MySecret' from the vault.
    #>
    [OutputType([Context])]
    [CmdletBinding()]
    param(
        # The name of the context to retrieve from the vault.
        [Parameter()]
        [SupportsWildcards()]
        [string] $ID
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        $indent = ((Get-PSCallStack).Count - 1) * " "
        Write-Debug "$indent`[$commandName] - Start"
        $null = Get-ContextVault
        $vaultName = $script:Config.VaultName
        $contextInfos = Get-ContextInfo
    }

    process {
        try {
            if (-not $PSBoundParameters.ContainsKey('ID')) {
                Write-Debug "$indent`Retrieving all contexts from [$vaultName]"
            } elseif ([string]::IsNullOrEmpty($ID)) {
                Write-Debug "$indent`Return 0 contexts from [$vaultName]"
                return
            } elseif ($ID.Contains('*')) {
                Write-Debug "$indent`Retrieving contexts like [$ID] from [$vaultName]"
                $contextInfos = $contextInfos | Where-Object { $_.ID -like $ID }
            } else {
                Write-Debug "$indent`Retrieving context [$ID] from [$vaultName]"
                $contextInfos = $contextInfos | Where-Object { $_.ID -eq $ID }
            }

            Write-Debug "$indent`Found [$($contextInfos.Count)] contexts in [$vaultName]"
            $contextInfos | ForEach-Object {
                $contextJson = Get-Secret -Name $_.SecretName -Vault $vaultName -AsPlainText -Verbose:$false
                [Context](ConvertFrom-ContextJson -JsonString $contextJson)
            }
        } catch {
            Write-Error $_
            throw 'Failed to get context'
        }
    }

    end {
        Write-Debug "$indent`[$commandName] - End"
    }
}

Write-Debug "[$scriptName] - [functions] - [public] - [Get-Context] - Done"
#endregion - From [functions] - [public] - [Get-Context]
#region - From [functions] - [public] - [Get-ContextInfo]
Write-Debug "[$scriptName] - [functions] - [public] - [Get-ContextInfo] - Importing"

function Get-ContextInfo {
    <#
        .SYNOPSIS
        Retrieves all context info from the context vault.

        .DESCRIPTION
        Retrieves all context info from the context vault.

        .EXAMPLE
        Get-ContextInfo

        Get all context info from the context vault.
    #>
    [OutputType([PSCustomObject])]
    [CmdletBinding()]
    param()

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
        $vaultName = $script:Config.VaultName
        $secretPrefix = $script:Config.SecretPrefix
    }

    process {
        Write-Debug "Retrieving all context info from [$vaultName]"

        Get-SecretInfo -Vault $vaultName -Verbose:$false -Name "$secretPrefix*" | ForEach-Object {
            $ID = ($_.Name -replace "^$secretPrefix")
            [pscustomobject]@{
                SecretName = $_.Name
                ID         = $ID
                Metadata   = $_.Metadata
                Type       = $_.Type
                VaultName  = $_.VaultName
            }
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}

Write-Debug "[$scriptName] - [functions] - [public] - [Get-ContextInfo] - Done"
#endregion - From [functions] - [public] - [Get-ContextInfo]
#region - From [functions] - [public] - [Remove-Context]
Write-Debug "[$scriptName] - [functions] - [public] - [Remove-Context] - Importing"

#Requires -Modules @{ ModuleName = 'DynamicParams'; RequiredVersion = '1.1.8' }
#Requires -Modules @{ ModuleName = 'Microsoft.PowerShell.SecretManagement'; RequiredVersion = '1.1.2' }

filter Remove-Context {
    <#
        .SYNOPSIS
        Removes a context from the context vault.

        .DESCRIPTION
        This function removes a context from the vault. It supports removing a single context by name,
        multiple contexts using wildcard patterns, and can also accept input from the pipeline.
        If the specified context(s) exist, they will be removed from the vault.

        .EXAMPLE
        Remove-Context

        Removes all contexts from the vault.

        .EXAMPLE
        Remove-Context -ID 'MySecret'

        Removes the context called 'MySecret' from the vault.
    #>
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The name of the context to remove from the vault.
        [Parameter(Mandatory)]
        [string] $ID
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
        $null = Get-ContextVault
    }

    process {
        try {

            if ($PSCmdlet.ShouldProcess($ID, 'Remove secret')) {
                Get-ContextInfo | Where-Object { $_.ID -eq $ID } | ForEach-Object {
                    Remove-Secret -Name $_.SecretName -Vault $script:Config.VaultName -Verbose:$false
                    Write-Debug "Removed context [$ID]"
                }
            }
        } catch {
            Write-Error $_
            throw 'Failed to remove context'
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}

Write-Debug "[$scriptName] - [functions] - [public] - [Remove-Context] - Done"
#endregion - From [functions] - [public] - [Remove-Context]
#region - From [functions] - [public] - [Rename-Context]
Write-Debug "[$scriptName] - [functions] - [public] - [Rename-Context] - Importing"

function Rename-Context {
    <#
        .SYNOPSIS
        Renames a context.

        .DESCRIPTION
        This function renames a context.
        It retrieves the context with the old ID, sets the context with the new ID, and removes the context with the old ID.

        .EXAMPLE
        Rename-Context -ID 'PSModule.GitHub' -NewID 'PSModule.GitHub2'

        Renames the context 'PSModule.GitHub' to 'PSModule.GitHub2'.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # The ID of the context to rename.
        [Parameter(Mandatory)]
        [string] $ID,

        # The new ID of the context.
        [Parameter(Mandatory)]
        [string] $NewID,

        # Force the rename even if the new ID already exists.
        [Parameter()]
        [switch] $Force
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
        $context = Get-Context -ID $ID
        if (-not $context) {
            throw "Context with ID '$ID' not found."
        }

        $existingContext = Get-Context -ID $NewID
        if ($existingContext -and -not $Force) {
            throw "Context with ID '$NewID' already exists."
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("Renaming context '$ID' to '$NewID'")) {
            try {
                Set-Context -ID $NewID -Context $context
            } catch {
                Write-Error $_
                throw 'Failed to set new context'
            }

            try {
                Remove-Context -ID $ID
            } catch {
                Write-Error $_
                throw 'Failed to remove old context'
            }
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}

Write-Debug "[$scriptName] - [functions] - [public] - [Rename-Context] - Done"
#endregion - From [functions] - [public] - [Rename-Context]
#region - From [functions] - [public] - [Set-Context]
Write-Debug "[$scriptName] - [functions] - [public] - [Set-Context] - Importing"

#Requires -Modules @{ ModuleName = 'Microsoft.PowerShell.SecretManagement'; RequiredVersion = '1.1.2' }

function Set-Context {
    <#
        .SYNOPSIS
        Set a context and store it in the context vault.

        .DESCRIPTION
        If the context does not exist, it will be created. If it already exists, it will be updated.

        .EXAMPLE
        Set-Context -ID 'PSModule.GitHub' -Context @{ Name = 'MySecret' }

        Create a context called 'MySecret' in the vault.

        .EXAMPLE
        Set-Context -ID 'PSModule.GitHub' -Context @{ Name = 'MySecret'; AccessToken = '123123123' }

        Creates a context called 'MySecret' in the vault with the settings.
    #>
    [OutputType([Context])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The ID of the context.
        [Parameter(Mandatory)]
        [string] $ID,

        # The data of the context.
        [Parameter()]
        [object] $Context = @{},

        # Pass the context through the pipeline.
        [Parameter()]
        [switch] $PassThru
    )

    begin {
        $commandName = $MyInvocation.MyCommand.Name
        Write-Debug "[$commandName] - Start"
        $null = Get-ContextVault
        $vaultName = $script:Config.VaultName
        $secretPrefix = $script:Config.SecretPrefix
    }

    process {
        try {
            $secret = ConvertTo-ContextJson -Context $Context -ID $ID
        } catch {
            Write-Error $_
            throw 'Failed to convert context to JSON'
        }

        $param = @{
            Name    = "$secretPrefix$ID"
            Secret  = $secret
            Vault   = $vaultName
            Verbose = $false
        }
        Write-Debug ($param | ConvertTo-Json -Depth 5)

        try {
            if ($PSCmdlet.ShouldProcess($ID, 'Set Secret')) {
                Set-Secret @param
            }
        } catch {
            Write-Error $_
            throw 'Failed to set secret'
        }

        if ($PassThru) {
            [Context](ConvertFrom-ContextJson -JsonString $secret)
        }
    }

    end {
        Write-Debug "[$commandName] - End"
    }
}

Write-Debug "[$scriptName] - [functions] - [public] - [Set-Context] - Done"
#endregion - From [functions] - [public] - [Set-Context]

Write-Debug "[$scriptName] - [functions] - [public] - Done"
#endregion - From [functions] - [public]

#region - From [variables] - [private]
Write-Debug "[$scriptName] - [variables] - [private] - Processing folder"

#region - From [variables] - [private] - [Config]
Write-Debug "[$scriptName] - [variables] - [private] - [Config] - Importing"

$script:Config = [pscustomobject]@{
    Initialized  = $false                             # $script:Config.Initialized
    SecretPrefix = 'Context:'                         # $script:Config.SecretPrefix
    VaultName    = 'ContextVault'                     # $script:Config.VaultName
    VaultType    = 'Microsoft.PowerShell.SecretStore' # $script:Config.VaultType
}

Write-Debug "[$scriptName] - [variables] - [private] - [Config] - Done"
#endregion - From [variables] - [private] - [Config]

Write-Debug "[$scriptName] - [variables] - [private] - Done"
#endregion - From [variables] - [private]

#region - From [completers]
Write-Debug "[$scriptName] - [completers] - Importing"

$usingIDFunctions = @('Get-Context', 'Set-Context', 'Remove-Context', 'Rename-Context')

Register-ArgumentCompleter -CommandName $usingIDFunctions -ParameterName 'ID' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    $null = $commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter

    Get-ContextInfo | Where-Object { $_.ID -like "$wordToComplete*" } |
        ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_.ID, $_.ID, 'ParameterValue', $_.ID)
        }
}
Write-Debug "[$scriptName] - [completers] - Done"
#endregion - From [completers]

# Get the internal TypeAccelerators class to use its static methods.
$TypeAcceleratorsClass = [psobject].Assembly.GetType(
    'System.Management.Automation.TypeAccelerators'
)
# Ensure none of the types would clobber an existing type accelerator.
# If a type accelerator with the same name exists, throw an exception.
$ExistingTypeAccelerators = $TypeAcceleratorsClass::Get
# Define the types to export with type accelerators.
$ExportableEnums = @(
)
$ExportableEnums | Foreach-Object { Write-Verbose "Exporting enum '$($_.FullName)'." }
foreach ($Type in $ExportableEnums) {
    if ($Type.FullName -in $ExistingTypeAccelerators.Keys) {
        Write-Verbose "Enum already exists [$($Type.FullName)]. Skipping."
    } else {
        Write-Verbose "Importing enum '$Type'."
        $TypeAcceleratorsClass::Add($Type.FullName, $Type)
    }
}
$ExportableClasses = @(
    [Context]
)
$ExportableClasses | Foreach-Object { Write-Verbose "Exporting class '$($_.FullName)'." }
foreach ($Type in $ExportableClasses) {
    if ($Type.FullName -in $ExistingTypeAccelerators.Keys) {
        Write-Verbose "Class already exists [$($Type.FullName)]. Skipping."
    } else {
        Write-Verbose "Importing class '$Type'."
        $TypeAcceleratorsClass::Add($Type.FullName, $Type)
    }
}

# Remove type accelerators when the module is removed.
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    foreach ($Type in ($ExportableEnums + $ExportableClasses)) {
        $TypeAcceleratorsClass::Remove($Type.FullName)
    }
}.GetNewClosure()
$exports = @{
    Alias    = '*'
    Cmdlet   = ''
    Function = @(
        'Get-Context'
        'Get-ContextInfo'
        'Remove-Context'
        'Rename-Context'
        'Set-Context'
    )
}
Export-ModuleMember @exports

