BeforeAll {
    Import-Module ([IO.Path]::Combine($PSScriptRoot, '..', '..')) `
        -Scope 'Local' `
        -Force

    . "$PSScriptRoot\..\..\Private\Connect-MgIfNecessary.ps1"

    . "$PSScriptRoot\..\..\Private\Get-Chats.ps1"


    Mock -CommandName 'Get-MgBetaChat' -MockWith {
        $Script:MockGetMgBetaChatCalled = $true
        return @(
            [PSCustomObject]@{ ChatType = 'meeting'; Id = '11111' }
            [PSCustomObject]@{ ChatType = 'oneOnOne'; Id = '22222' }
        )
    }

    Mock -CommandName 'Get-MgBetaChatMessage' -MockWith {
        $return_value = @(
            [PSCustomObject]@{ Id = 'aaaaa'; ChatId = 'example' }
            [PSCustomObject]@{ Id = 'bbbbb'; ChatId = 'example' }
            [PSCustomObject]@{ Id = 'ccccc'; ChatId = 'example' }
        )
        If ($PesterBoundParameters.ChatId) {
            $return_value = $return_value | ForEach-Object {
                $_.ChatId = $PesterBoundParameters.ChatId
                $_
            }
        }
        $Script:MockGetMgBetaChatMessageCalled = $true
        $return_value_stringified = $return_value | ConvertTo-Json -Depth 100 -Compress
        $return_value_stringified_and_chopped = $return_value_stringified.Substring(1, $return_value_stringified.Length - 2)
        $Script:MockGetMgBetaChatMessageStringified = $return_value_stringified_and_chopped
        return $return_value
    }

    Mock -CommandName 'Out-File' -MockWith {
        $Script:MockOutFileCalled = $true
        $input_object_stringified = $PesterBoundParameters.InputObject | ConvertFrom-Json -Depth 100 | ConvertTo-Json -Depth 100 -Compress
        $input_object_stringified_and_chopped = $input_object_stringified.Substring(1, $input_object_stringified.Length - 2)
        $Script:MockOutFileContent = $input_object_stringified_and_chopped
        $Script:MockOutFilePath = $PesterBoundParameters.FilePath
    }
}

Describe "Get-Chats" {

    It "Should call Get-MgBetaChat, Get-MgBetaChatMessage, and Out-File" {
        $Script:MockGetMgBetaChatCalled | Should -BeFalse
        $Script:MockGetMgBetaChatMessageCalled | Should -BeFalse
        $Script:MockOutFileCalled | Should -BeFalse

        $yesterday_as_sample_start_date = (Get-Date).AddDays(-1)
        $todays_date_yyyymmdd = Get-Date -Format "yyyyMMdd"

        Get-Chats -StartDateTime $yesterday_as_sample_start_date

        $Script:MockGetMgBetaChatCalled | Should -BeTrue
        $Script:MockGetMgBetaChatMessageCalled | Should -BeTrue
        $Script:MockOutFileCalled | Should -BeTrue
        ($Script:MockOutFileContent -like "*$Script:MockGetMgBetaChatMessageStringified*") | Should -Be $true
        ($Script:MockOutFilePath -like "*$todays_date_yyyymmdd.json") | Should -Be true
    }
}

AfterAll {
    Remove-Item 'Function:Connect-MgIfNecessary' `
        -ErrorAction 'SilentlyContinue'
}