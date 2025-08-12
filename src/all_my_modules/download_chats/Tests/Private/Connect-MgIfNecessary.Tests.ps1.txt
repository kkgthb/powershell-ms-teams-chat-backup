BeforeAll {
    Import-Module ([IO.Path]::Combine($PSScriptRoot, '..', '..')) `
        -Scope 'Local' `
        -Force
    . "$PSScriptRoot\..\..\Private\Connect-MgIfNecessary.ps1"
}

Describe "Connect-MgIfNecessary" {

    It "Should connect to Microsoft Graph if not already connected" {
        # Disconnect if already connected, for test isolation
        try { Disconnect-MgGraph } catch {}
        $context | Should -BeNullOrEmpty
        $context = Get-MgContext

        $did_connection = $false
        $did_connection = Connect-MgIfNecessary
        $did_connection | Should -BeTrue

        $context = Get-MgContext
        $context | Should -Not -BeNullOrEmpty
        $context.Scopes | Should -Contain 'Chat.Read'
    }

    It "Should not reconnect if already connected with required scope" {
        Connect-MgGraph -Scopes 'Chat.Read'
        $context_before = Get-MgContext
        $context_before | Should -Not -BeNullOrEmpty

        $did_connection = $false
        $did_connection = Connect-MgIfNecessary
        $did_connection | Should -BeFalse

        $context_after = Get-MgContext
        $context_after.Scopes | Should -Contain 'Chat.Read'
        $context_after.Account | Should -Be $context_before.Account
    }
}

AfterAll {
    Remove-Item 'Function:Connect-MgIfNecessary' `
        -ErrorAction 'SilentlyContinue'
}