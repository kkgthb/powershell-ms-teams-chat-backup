function Get-DateViaPicker {
    <#
    .SYNOPSIS
        Shows a Windows Forms date picker and returns the selected date.
    .DESCRIPTION
        Launches a modal date picker dialog. Returns the selected date as a [datetime] object, or $null if cancelled.
    .EXAMPLE
        $date = Get-DateViaPicker
    #>
    [CmdletBinding()]
    Param() # end Param

    Begin {
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
    } # end BEGIN

    Process {

        $form = New-Object Windows.Forms.Form -Property @{
            StartPosition = [Windows.Forms.FormStartPosition]::CenterScreen
            Size          = New-Object Drawing.Size 243, 230
            Text          = 'Select a Date'
            Topmost       = $true
        }

        $calendar = New-Object Windows.Forms.MonthCalendar -Property @{
            ShowTodayCircle   = $false
            MaxSelectionCount = 1
        }
        $form.Controls.Add($calendar)

        $okButton = New-Object Windows.Forms.Button -Property @{
            Location     = New-Object Drawing.Point 38, 165
            Size         = New-Object Drawing.Size 75, 23
            Text         = 'OK'
            DialogResult = [Windows.Forms.DialogResult]::OK
        }
        $form.AcceptButton = $okButton
        $form.Controls.Add($okButton)

        $cancelButton = New-Object Windows.Forms.Button -Property @{
            Location     = New-Object Drawing.Point 113, 165
            Size         = New-Object Drawing.Size 75, 23
            Text         = 'Cancel'
            DialogResult = [Windows.Forms.DialogResult]::Cancel
        }
        $form.CancelButton = $cancelButton
        $form.Controls.Add($cancelButton)

        $form.BringToFront()
        $result = $form.ShowDialog()

        if ($result -eq [Windows.Forms.DialogResult]::OK) {
            return $calendar.SelectionStart
        }
        else {
            return $null
        }

    } # end PROCESS

    End {} # end END
} #end Get-DateViaPicker