# get_date_via_picker

Provides a function `Get-DateViaPicker` to select a date using a Windows Forms picker dialog.

## Usage
```powershell
Import-Module ./get_date_via_picker.psd1
$date = Get-DateViaPicker
if ($date) {
    Write-Host "You selected: $($date.ToShortDateString())"
} else {
    Write-Host "No date selected."
}
```