Invoke-ScriptAnalyzer `
    -Path "$PSScriptRoot/../src/all_my_modules" `
    -Settings @{
    Severity     = @('Error', 'Warning', 'Information')
    ExcludeRules = @('PSUseToExportFieldsInManifest')
} `
    -Recurse