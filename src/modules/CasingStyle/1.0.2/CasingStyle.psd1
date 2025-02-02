@{
    RootModule            = 'CasingStyle.psm1'
    ModuleVersion         = '1.0.2'
    CompatiblePSEditions  = @(
        'Core'
        'Desktop'
    )
    GUID                  = 'a886b80a-1367-46e9-b788-0a74cd786dcd'
    Author                = 'PSModule'
    CompanyName           = 'PSModule'
    Copyright             = '(c) 2025 PSModule. All rights reserved.'
    Description           = 'A PowerShell module that works with casing of text.'
    PowerShellVersion     = '7.4'
    ProcessorArchitecture = 'None'
    TypesToProcess        = @()
    FormatsToProcess      = @()
    FunctionsToExport     = @(
        'ConvertTo-CasingStyle'
        'Get-CasingStyle'
        'Split-CasingStyle'
    )
    CmdletsToExport       = @()
    ModuleList            = @()
    FileList              = 'CasingStyle.psm1'
    PrivateData           = @{
        PSData = @{
            Tags       = @(
                'Linux'
                'MacOS'
                'PSEdition_Core'
                'PSEdition_Desktop'
                'Windows'
            )
            LicenseUri = 'https://github.com/PSModule/CasingStyle/blob/main/LICENSE'
            ProjectUri = 'https://github.com/PSModule/CasingStyle'
            IconUri    = 'https://raw.githubusercontent.com/PSModule/CasingStyle/main/icon/icon.png'
        }
    }
}

