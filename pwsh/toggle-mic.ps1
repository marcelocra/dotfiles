# Write-Host "Executed!" | Out-File "C:\tmp\debug.txt" -Append

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
