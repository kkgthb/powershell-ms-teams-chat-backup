function Get-Chats {

    <#
    .Synopsis
        TODO
    .DESCRIPTION
        TODO
    .EXAMPLE
        Get-Chats

        TODO:  (document output)
    .NOTES
        Author: Katie Kodes
        Date: 2025-08-12
        Company: Katie Kodes
    #>

    [CmdletBinding()]
    Param (
        [Parameter(
            HelpMessage = 'The start date of chats you would like to download'
        )]
        [ValidateNotNullOrWhiteSpace()]
        [System.DateTime[]]$StartDateTime
    ) # end Param

    Begin {
        if (-not (Get-Module -Name 'Microsoft.Graph.Authentication')) {
            Import-Module -Name 'Microsoft.Graph.Authentication' -RequiredVersion '2.26.1'
        }
        if (-not (Get-Module -Name 'Microsoft.Graph.Beta.Teams')) {
            Import-Module -Name 'Microsoft.Graph.Beta.Teams' -RequiredVersion '2.26.1'
        }
        Connect-MgIfNecessary
        $todays_date_yyyymmdd = Get-Date -Format "yyyyMMdd"
    } # end BEGIN

    Process {

        ForEach ($sdt in $StartDateTime) {
            Write-Host $todays_date_yyyymmdd
            $formatted_midnight_start_date = $sdt.Date.ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
            Write-Host $formatted_midnight_start_date
            $chat_timestamp_filter = "viewpoint/lastMessageReadDateTime gt $formatted_midnight_start_date"

            $all_chats = Get-MgBetaChat `
                -All `
                -Filter $chat_timestamp_filter `
                -ExpandProperty @('members', 'lastMessagePreview')

            If (-not $all_chats -or $all_chats.Count -eq 0) {
                Write-Host('There were no chats downloaded.')
                Continue
            }
            Write-Host "Fetched $($all_chats.Count) chats."
            $all_chats | ConvertTo-Json -Depth 100 | Out-File -Path "c:\example\teamschats$($todays_date_yyyymmdd).json"
            Write-Host "Wrote chats to disk with suffix `"$todays_date_yyyymmdd`"."

            $message_timestamp_filter = "lastModifiedDateTime gt $formatted_midnight_start_date"
            [System.Collections.ArrayList]$all_message_clumps = New-Object System.Collections.ArrayList
            $the_messages = $null
            $all_chats.Id | ForEach-Object {
                $the_messages = Get-MgBetaChatMessage `
                    -ChatId "$_" `
                    -All `
                    -Filter $message_timestamp_filter
                $all_message_clumps.Add($the_messages) | Out-Null
                $the_messages = $null
            }
        
            $all_messages = $all_message_clumps | ForEach-Object { $_ }

            If (-not $all_messages -or $all_messages.Count -eq 0) {
                Write-Host('There were no messages downloaded.')
                Continue
            }
            Write-Host "Fetched $($all_messages.Count) messages."
            $all_messages | ConvertTo-Json -Depth 100 | Out-File -Path "c:\example\mychats$($todays_date_yyyymmdd).json"
            Write-Host "Wrote messages to disk with suffix `"$todays_date_yyyymmdd`"."
        }

    } # end PROCESS

    End {} # end END

} #End Get-Chats