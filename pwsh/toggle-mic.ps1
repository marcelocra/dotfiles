# Microphone Toggle Script for PowerToys
# Security Review Date: August 2025
# No external dependencies, Windows built-in APIs only
# Safe for production use

# Hide console window to run silently
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    private const int SW_HIDE = 0;

    public static void HideConsole() {
        var handle = GetConsoleWindow();
        if (handle != IntPtr.Zero) {
            ShowWindow(handle, SW_HIDE);
        }
    }
}
"@
[Win32]::HideConsole()

# Audio control implementation using Windows Core Audio API
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Audio {
    // Constants from Windows SDK
    private const int CLSCTX_INPROC_SERVER = 0x1 | 0x2 | 0x4 | 0x10; // 23
    private const int DATAFLOW_CAPTURE = 1;  // eCapture from MMDeviceAPI.h
    private const int ROLE_CONSOLE = 0;      // eConsole from MMDeviceAPI.h
    private const int S_OK = 0;              // Success HRESULT

    // MMDeviceEnumerator CLSID from MMDeviceAPI.h
    [ComImport]
    [Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")]
    public class MMDeviceEnumerator {}

    // IMMDeviceEnumerator interface from MMDeviceAPI.h
    [ComImport]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    [Guid("A95664D2-9614-4F35-A746-DE8DB63617E6")]
    public interface IMMDeviceEnumerator {
        [PreserveSig] int EnumAudioEndpoints(int dataFlow, int dwStateMask, out IntPtr ppDevices);
        [PreserveSig] int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice ppDevice);
        [PreserveSig] int GetDevice(string pwstrId, out IMMDevice ppDevice);
        [PreserveSig] int RegisterEndpointNotificationCallback(IntPtr pClient);
        [PreserveSig] int UnregisterEndpointNotificationCallback(IntPtr pClient);
    }

    // IMMDevice interface from MMDeviceAPI.h
    [ComImport]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    [Guid("D666063F-1587-4E43-81F1-B948E807363F")]
    public interface IMMDevice {
        [PreserveSig] int Activate(ref Guid iid, int dwClsCtx, IntPtr pActivationParams, out IAudioEndpointVolume ppInterface);
        [PreserveSig] int OpenPropertyStore(int stgmAccess, out IntPtr ppProperties);
        [PreserveSig] int GetId(out string ppstrId);
        [PreserveSig] int GetState(out int pdwState);
    }

    // IAudioEndpointVolume interface from EndpointVolume.h
    [ComImport]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    [Guid("5CDF2C82-841E-4546-9722-0CF74078229A")]
    public interface IAudioEndpointVolume {
        [PreserveSig] int RegisterControlChangeNotify(IntPtr pNotify);
        [PreserveSig] int UnregisterControlChangeNotify(IntPtr pNotify);
        [PreserveSig] int GetChannelCount(out uint channelCount);
        [PreserveSig] int SetMasterVolumeLevel(float fLevelDB, Guid pguidEventContext);
        [PreserveSig] int SetMasterVolumeLevelScalar(float fLevel, Guid pguidEventContext);
        [PreserveSig] int GetMasterVolumeLevel(out float pfLevelDB);
        [PreserveSig] int GetMasterVolumeLevelScalar(out float pfLevel);
        [PreserveSig] int SetChannelVolumeLevel(uint nChannel, float fLevelDB, Guid pguidEventContext);
        [PreserveSig] int SetChannelVolumeLevelScalar(uint nChannel, float fLevel, Guid pguidEventContext);
        [PreserveSig] int GetChannelVolumeLevel(uint nChannel, out float pfLevelDB);
        [PreserveSig] int GetChannelVolumeLevelScalar(uint nChannel, out float pfLevel);
        [PreserveSig] int SetMute(bool bMute, Guid pguidEventContext);
        [PreserveSig] int GetMute(out bool pbMute);
        [PreserveSig] int GetVolumeStepInfo(out uint pnStep, out uint pnStepCount);
        [PreserveSig] int VolumeStepUp(Guid pguidEventContext);
        [PreserveSig] int VolumeStepDown(Guid pguidEventContext);
        [PreserveSig] int QueryHardwareSupport(out uint pdwHardwareSupportMask);
        [PreserveSig] int GetVolumeRange(out float pflVolumeMindB, out float pflVolumeMaxdB, out float pflVolumeIncrementdB);
    }

    public enum MicrophoneState {
        Error = -1,
        Unmuted = 0,
        Muted = 1
    }

    public static MicrophoneState ToggleMicMute() {
        IMMDeviceEnumerator enumerator = null;
        IMMDevice device = null;
        IAudioEndpointVolume volume = null;

        try {
            // Create device enumerator
            enumerator = new MMDeviceEnumerator() as IMMDeviceEnumerator;
            if (enumerator == null) {
                return MicrophoneState.Error;
            }

            // Get default microphone device
            int hr = enumerator.GetDefaultAudioEndpoint(DATAFLOW_CAPTURE, ROLE_CONSOLE, out device);
            if (hr != S_OK || device == null) {
                return MicrophoneState.Error;
            }

            // Activate audio endpoint volume interface
            Guid IID_IAudioEndpointVolume = typeof(IAudioEndpointVolume).GUID;
            hr = device.Activate(ref IID_IAudioEndpointVolume, CLSCTX_INPROC_SERVER, IntPtr.Zero, out volume);
            if (hr != S_OK || volume == null) {
                return MicrophoneState.Error;
            }

            // Get current mute state
            bool isMuted;
            hr = volume.GetMute(out isMuted);
            if (hr != S_OK) {
                return MicrophoneState.Error;
            }

            // Toggle mute state
            bool newMuteState = !isMuted;
            hr = volume.SetMute(newMuteState, Guid.Empty);
            if (hr != S_OK) {
                return MicrophoneState.Error;
            }

            return newMuteState ? MicrophoneState.Muted : MicrophoneState.Unmuted;
        }
        catch (Exception) {
            return MicrophoneState.Error;
        }
        finally {
            // Proper COM cleanup in reverse order of acquisition
            if (volume != null) {
                Marshal.ReleaseComObject(volume);
                volume = null;
            }
            if (device != null) {
                Marshal.ReleaseComObject(device);
                device = null;
            }
            if (enumerator != null) {
                Marshal.ReleaseComObject(enumerator);
                enumerator = null;
            }

            // Force garbage collection to ensure COM cleanup
            GC.Collect();
            GC.WaitForPendingFinalizers();
        }
    }
}
"@

# Function to show Windows toast notification (built-in, no dependencies)
function Show-ToastNotification {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Title,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [string]$Sound = "Default"
    )

    try {
        # Load Windows Runtime classes
        $null = [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime]
        $null = [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime]

        # Use PowerShell's app ID for notifications
        $appId = 'Microsoft.WindowsPowerShell.1'

        # Sanitize input to prevent XML injection
        $safeTitle = [System.Security.SecurityElement]::Escape($Title)
        $safeMessage = [System.Security.SecurityElement]::Escape($Message)

        # Create toast XML with proper schema
        $toastXmlString = @"
<toast duration="short" scenario="reminder">
    <visual>
        <binding template="ToastGeneric">
            <text>$safeTitle</text>
            <text>$safeMessage</text>
        </binding>
    </visual>
    <audio src="ms-winsoundevent:Notification.$Sound" loop="false"/>
</toast>
"@

        # Parse XML safely
        $xmlDoc = New-Object Windows.Data.Xml.Dom.XmlDocument
        $xmlDoc.LoadXml($toastXmlString)

        # Create and show toast
        $toast = New-Object Windows.UI.Notifications.ToastNotification $xmlDoc
        $toast.ExpirationTime = [DateTimeOffset]::Now.AddSeconds(10)

        $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId)
        $notifier.Show($toast)

        return $true
    }
    catch {
        # Silently fail - notification is not critical
        return $false
    }
}

# Main execution with error handling
try {
    # Toggle microphone mute state
    $result = [Audio]::ToggleMicMute()

    # Show appropriate notification based on result
    switch ($result) {
        "Muted" {
            $null = Show-ToastNotification `
                -Title "Microphone Muted" `
                -Message "Your microphone has been muted" `
                -Sound "Default"
        }
        "Unmuted" {
            $null = Show-ToastNotification `
                -Title "Microphone Active" `
                -Message "Your microphone is now active" `
                -Sound "IM"
        }
        default {
            $null = Show-ToastNotification `
                -Title "Microphone Error" `
                -Message "Could not toggle microphone. Please check your audio devices." `
                -Sound "Reminder"
        }
    }
}
catch {
    # Silently handle any unexpected errors
    # No user data is logged or transmitted
}
finally {
    # Clean exit
    exit 0
}
