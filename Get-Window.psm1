Function Get-Window
{
    Param (
        [int]$Id
    )
    
    Try
    {
        [void][Window]
    }
    Catch
    {
        Add-Type @"
            using System;
            using System.Runtime.InteropServices;
            public class Window
            {
                [DllImport("user32.dll")]
                [return: MarshalAs(UnmanagedType.Bool)]
                public static extern bool GetWindowRect(
                    IntPtr hWnd, out RECT lpRect);

                [DllImport("user32.dll")]
                [return: MarshalAs(UnmanagedType.Bool)]
                public extern static bool MoveWindow(
                    IntPtr handle, int x, int y, int width, int height, bool redraw);

                [DllImport("user32.dll")]
                [return: MarshalAs(UnmanagedType.Bool)]
                public static extern bool ShowWindow(
                    IntPtr handle, int state);
            }
            public struct RECT
            {
                public int Left;        // x position of upper-left corner
                public int Top;         // y position of upper-left corner
                public int Right;       // x position of lower-right corner
                public int Bottom;      // y position of lower-right corner
            }
"@
    }

    $Rectangle = New-Object RECT
    $Process = Get-Process -Id $Id -ErrorAction SilentlyContinue

    $Handle = $Process.MainWindowHandle

    Write-Verbose "$($Process.ProcessName) `(Id=$($Process.Id), Handle=$Handle`)"

    if ( $Handle -eq [System.IntPtr]::Zero ) { return }
    if ( $Handle -eq "" ) { return }

    $Rectangle = New-Object RECT
    $Return = [Window]::GetWindowRect($Handle, [ref]$Rectangle)

    If ( $Return )
    {
        $Height = $Rectangle.Bottom - $Rectangle.Top
        $Width = $Rectangle.Right  - $Rectangle.Left
        $Size = New-Object System.Management.Automation.Host.Size -ArgumentList $Width, $Height
        $TopLeft = New-Object System.Management.Automation.Host.Coordinates -ArgumentList $Rectangle.Left , $Rectangle.Top
        $BottomRight = New-Object System.Management.Automation.Host.Coordinates -ArgumentList $Rectangle.Right, $Rectangle.Bottom
        $Minimized = $false

        If ($Rectangle.Top -lt 0 -AND
            $Rectangle.Bottom -lt 0 -AND
            $Rectangle.Left -lt 0 -AND
            $Rectangle.Right -lt 0)
        {
            $Minimized = $true
        }

        $Object = [PSCustomObject]@{
            Id = $Process.Id
            ProcessName = $Process.ProcessName
            Size = $Size
            TopLeft = $TopLeft
            BottomRight = $BottomRight
            WindowTitle = $Process.MainWindowTitle
            Minimized = $Minimized
        }
        
        $Object
    }
}