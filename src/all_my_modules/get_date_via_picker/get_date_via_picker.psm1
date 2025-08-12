# This file is required for local development.  (You can run "Import-Module" against it.)
# Build-Module doesn't really need this file to exist, but the existence
# of this file in source code doesn't hurt anything, either.
# Also, the existence of this file helps Pester be able to import the module so it can do testing.
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
Foreach ($Import in @($Public + $Private)) {
    Try {
        . $Import.FullName
    } Catch {
        Write-Error -Message "Failed to import function $($Import.FullName): $_"
    }
}
Export-ModuleMember -Function $Public.BaseName