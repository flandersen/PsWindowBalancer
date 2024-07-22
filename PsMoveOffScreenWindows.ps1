param ()

Import-Module .\Get-Window.psm1
Import-Module .\Set-Window.psm1

Add-Type -AssemblyName System.Windows.Forms

function Get-OutsideScreen
{
    param(
        $Bounds
    )

    $AllScreens = [System.Windows.Forms.Screen]::AllScreens
    $OutsideScreens = $true

    foreach($Screen in $AllScreens)
    {
        $ScreenBottomRightX = $Screen.Bounds.X + $Screen.Bounds.Width
        $ScreenBottomRightY = $Screen.Bounds.Y + $Screen.Bounds.Height

        if (($Bounds.TopLeft.X -lt ($ScreenBottomRightX)) -And ($Bounds.BottomRight.X -gt $Screen.Bounds.X) -And ($Bounds.TopLeft.Y -lt $ScreenBottomRightY) -And ($Bounds.BottomRight.Y -gt $Screen.Bounds.Y))
        {
            $OutsideScreens = $false
        }
    }

    $OutsideScreens
}

function Get-PrimaryScreen
{
    $AllScreens = [System.Windows.Forms.Screen]::AllScreens
    $PrimaryScreen = $null

    foreach($Screen in $AllScreens)
    {
        if ($Screen.Primary)
        {
            $PrimaryScreen = $Screen
        }
    }

    $PrimaryScreen
}

$PrimaryScreen = Get-PrimaryScreen

foreach($Process in Get-Process)
{
    $HasWindow = $Process.MainWindowHandle
    Write-Debug "$($Process.Id) has a window = $HasWindow"

    if ($HasWindow)
    {
        $Bounds = Get-Window $Process.Id

        if ($Bounds -And (-Not $Bounds.Minimized))
        {
            $Outside = Get-OutsideScreen $Bounds
            Write-Host "$($Process.Name) ($($Process.Id)): $($Bounds.TopLeft); $($Bounds.BottomRight); $Outside"

            if ($Outside)
            {
                Set-Window -Id $Process.Id -X $PrimaryScreen.WorkingArea.X -Y $PrimaryScreen.WorkingArea.Y
            }
        }        
    }
}