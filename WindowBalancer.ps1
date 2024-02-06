<#
.SYNOPSIS
    Distributes the main windows of the processes given by name on the available screens.
.DESCRIPTION
    The ProcessName determines the processes whose main windows are moved to separate screens.
.INPUTS
    None.
.Parameter ProcessName
    Process name whose main windows is being moved.
.OUTPUTS
    None.
.NOTES
    Version:        1.1
    Author:         Flandersen
    Creation Date:  06.02.2024
    Purpose/Change:   Windows are placed on the screens by the screen index.
.EXAMPLE
    You can run this script on system start-up after the specified processes have been started.

    powershell .\Set-ProcessWindowPos.ps1 -ProcessName Notepad

    The following hides the powershell window from the user.
    powershell -WindowStyle hidden C:\scripts\Set-ProcessWindowPos.ps1 -ProcessName notepad

    If the execution policy does not allow excuting scripts:
    powershell -WindowStyle hidden -ExecutionPolicy ByPass C:\scripts\Set-ProcessWindowPos.ps1 -ProcessName notepad
#>

param (
    [parameter(
        Mandatory=$True,
        ValueFromPipeline=$False,
        ValueFromPipelineByPropertyName=$False)]
    [string] $ProcessName
)

Import-Module .\Set-Window.psm1

Add-Type -AssemblyName System.Windows.Forms

$AllScreens = [System.Windows.Forms.Screen]::AllScreens
$RunningProcesses = Get-Process | Where-Object { $_.Name -eq $ProcessName }

if ($RunningProcesses.Count -eq 0)
{
    Write-Error -Message "No processes named ""$ProcessName"" are currently running." -ErrorAction Stop
}

$Count = 0

foreach($Process in $RunningProcesses)
{
    $HasWindow = $Process.MainWindowHandle
    Write-Debug "$($Process.Id) has a window = $HasWindow"

    if ($HasWindow)
    {
        if ($Count -lt $AllScreens.Count)
        {
            $Screen = $AllScreens[$Count]
            $Height = $Screen.WorkingArea.Height
            $Width = $Screen.WorkingArea.Width
            $X = $Screen.WorkingArea.x
            $Y = $Screen.WorkingArea.Y

            Set-Window -Id $Process.Id -X $X -Y $Y -Width $Width -Height $Height
            $Count++
        }
        else
        {
            Write-Warning -Message "No free screen available for ProcessID $($Process.Id)."
        }
    }
}
