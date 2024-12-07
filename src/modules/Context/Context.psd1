@{
    RootModule            = 'Context.psm1'
    ModuleVersion         = '999.0.0'
    CompatiblePSEditions  = @(
        'Core'
        'Desktop'
    )
    GUID                  = 'ce48a06e-849a-4916-a953-9bfe59d97490'
    Author                = 'PSModule'
    CompanyName           = 'PSModule'
    Copyright             = '(c) 2024 PSModule. All rights reserved.'
    Description           = 'A PowerShell module that manages contexts with secrets and variables.'
    PowerShellVersion     = '7.4'
    ProcessorArchitecture = 'None'
    RequiredModules       = @(
        @{
            ModuleName      = 'DynamicParams'
            RequiredVersion = '1.1.8'
        }
        @{
            ModuleName      = 'Microsoft.PowerShell.SecretManagement'
            RequiredVersion = '1.1.2'
        }
        @{
            ModuleName      = 'Microsoft.PowerShell.SecretStore'
            RequiredVersion = '1.0.6'
        }
    )
    RequiredAssemblies    = @()
    ScriptsToProcess      = @()
    TypesToProcess        = @()
    FormatsToProcess      = @()
    NestedModules         = @()
    FunctionsToExport     = @(
        'Get-Context'
        'Get-ContextInfo'
        'Remove-Context'
        'Rename-Context'
        'Set-Context'
    )
    CmdletsToExport       = @()
    ModuleList            = @()
    FileList              = 'Context.psm1'
    PrivateData           = @{
        PSData = @{
            Tags       = @(
                'context'
                'Linux'
                'MacOS'
                'powershell'
                'powershell-module'
                'PSEdition_Core'
                'PSEdition_Desktop'
                'Windows'
            )
            LicenseUri = 'https://github.com/PSModule/Context/blob/main/LICENSE'
            ProjectUri = 'https://github.com/PSModule/Context'
            IconUri    = 'https://raw.githubusercontent.com/PSModule/Context/main/icon/icon.png'
        }
    }
}

