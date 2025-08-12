Import-Module 'Pester' -RequiredVersion '5.7.1'
$my_pester_config = New-PesterConfiguration
$my_pester_config.Run.Path = "$PSScriptRoot/../src/all_my_modules"
$my_pester_config.Run.PassThru = $false
$my_pester_config.Run.Exit = $true
$my_pester_config.CodeCoverage.OutputFormat = 'CoverageGutters'
$my_pester_config.CodeCoverage.Enabled = $true
$my_pester_config.CodeCoverage.OutputPath = "$PSScriptRoot/../.ignoreme/cicd_pester_results/coverageResults.xml"
$my_pester_config.CodeCoverage.Path = "$PSScriptRoot/../src/all_my_modules"
$my_pester_config.TestResult.OutputFormat = 'NUnitXml'
$my_pester_config.TestResult.Enabled = $true
$my_pester_config.TestResult.OutputPath = "$PSScriptRoot/../.ignoreme/cicd_pester_results/testResults.xml"
Invoke-Pester `
    -Configuration $my_pester_config