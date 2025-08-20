# "$(Get-Date): Started" | Out-File "C:\tmp\debug.log" -Append
# "Args: $args" | Out-File "C:\tmp\debug.log" -Append

# Hide the PowerShell window
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0) # 0 = SW_HIDE


Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class AudioControl {
    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);
    public const int VK_VOLUME_MUTE = 0xAD;
    public const uint KEYEVENTF_KEYUP = 0x0002;
}
"@

# Simulate pressing the microphone mute key
[AudioControl]::keybd_event(0xAD, 0, 0, [UIntPtr]::Zero)
[AudioControl]::keybd_event(0xAD, 0, 0x0002, [UIntPtr]::Zero)

# "$(Get-Date): Finished" | Out-File "C:\tmp\debug.log" -Append
