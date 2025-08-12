Import-Module 'Metadata' -RequiredVersion '1.5.7'
Import-Module 'Configuration' -RequiredVersion '1.6.0'
Import-Module 'ModuleBuilder' -RequiredVersion '3.0.2'

# Note:  At the moment, ModuleBuilder for PowerShell expects a [Version]-compatible string, 
#   not a [SemVer]-compatible string.
#   Leading 9 is arbitrary integer just to make sure not a leading zero.
#   "ff" is as far as we can go without getting an [Int32] conversion error out of ModuleBuilder.
$current_date = Get-Date -AsUTC
$sysdate_based_version_number_suggestion = [String][Version]::New(
    $null, `
        $null, `
        $current_date.ToString('yyyyMMdd'), `
        '9' + $current_date.ToString('hhmmssff')
)

$module_dirs = Get-ChildItem `
    -Path "$PSScriptRoot/../src/all_my_modules" `
    -Directory
| Where-Object { $_.Name -ne 'PSScriptAnalyzerNUnit' }
| Where-Object { $_.Name -ne 'parse_chats' } # TODO:  remove once this exists

$module_dirs | ForEach-Object {
    Push-Location $_.FullName
    Build-Module `
        -SourcePath $_.FullName `
        -OutputDirectory ([System.IO.Path]::GetFullPath("$PSScriptRoot/../.ignoreme/cicd_build_output/$($_.Name)")) `
        -VersionedOutputDirectory `
        -Version $sysdate_based_version_number_suggestion
    Pop-Location
}