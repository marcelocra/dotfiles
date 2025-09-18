param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("back", "forward")]
  [string]$Direction
)

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class MouseNav {
  [DllImport("user32.dll")]
  public static extern void mouse_event(uint dwFlags, int dx, int dy, uint dwData, UIntPtr dwExtraInfo);

  public const uint MOUSEEVENTF_XDOWN = 0x0080;
  public const uint MOUSEEVENTF_XUP   = 0x0100;
  public const uint XBUTTON1          = 0x0001; // Back
  public const uint XBUTTON2          = 0x0002; // Forward

  public static void SendBack() {
    mouse_event(MOUSEEVENTF_XDOWN, 0, 0, XBUTTON1, UIntPtr.Zero);
    mouse_event(MOUSEEVENTF_XUP, 0, 0, XBUTTON1, UIntPtr.Zero);
  }

  public static void SendForward() {
    mouse_event(MOUSEEVENTF_XDOWN, 0, 0, XBUTTON2, UIntPtr.Zero);
    mouse_event(MOUSEEVENTF_XUP, 0, 0, XBUTTON2, UIntPtr.Zero);
  }
}
"@

if ($Direction -eq "back") {
  [MouseNav]::SendBack()
}
else {
  [MouseNav]::SendForward()
}