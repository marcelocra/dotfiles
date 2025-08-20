Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class MicrophoneManager {
    [ComImport, Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    private interface IMMDeviceEnumerator {
        int NotImpl1();
        int NotImpl2();
        [PreserveSig]
        int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice ppDevice);
    }

    [ComImport, Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    private interface IMMDevice {
        [PreserveSig]
        int Activate(ref Guid iid, int dwClsCtx, IntPtr pActivationParams, [MarshalAs(UnmanagedType.IUnknown)] out object ppInterface);
    }

    [ComImport, Guid("5CDF2C82-841E-4546-9722-0CF74078229A"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    private interface IAudioEndpointVolume {
        int NotImpl1();
        int NotImpl2();
        int NotImpl3();
        int NotImpl4();
        int NotImpl5();
        int NotImpl6();
        int NotImpl7();
        int NotImpl8();
        int NotImpl9();
        int SetMute([MarshalAs(UnmanagedType.Bool)] bool bMute, ref Guid guidEventContext);
        int GetMute(out bool bMute);
    }

    private static readonly Guid CLSID_MMDeviceEnumerator = new Guid("BCDE0395-E52F-467C-8E3D-C4579291692E");
    private static readonly Guid IID_IAudioEndpointVolume = new Guid("5CDF2C82-841E-4546-9722-0CF74078229A");
    private const int DEVICE_STATE_ACTIVE = 0x00000001;
    private const int DEVICE_FLOW_CAPTURE = 2;
    private const int ROLE_COMMUNICATIONS = 2;

    [DllImport("ole32.dll")]
    private static extern int CoCreateInstance(ref Guid clsid, IntPtr pUnkOuter, uint dwClsContext, ref Guid iid, out object ppv);

    public static bool ToggleMicrophoneMute() {
        object MMDeviceEnumeratorInterface = null;
        IMMDeviceEnumerator deviceEnumerator = null;
        IMMDevice device = null;
        object EndpointVolumeInterface = null;
        IAudioEndpointVolume endpointVolume = null;
        bool currentMute = false;
        Guid IID_IMMDeviceEnumerator = typeof(IMMDeviceEnumerator).GUID;
        Guid empty = Guid.Empty;

        try {
            // Create device enumerator
            CoCreateInstance(ref CLSID_MMDeviceEnumerator, IntPtr.Zero, 1, ref IID_IMMDeviceEnumerator, out MMDeviceEnumeratorInterface);
            deviceEnumerator = (IMMDeviceEnumerator)MMDeviceEnumeratorInterface;

            // Get default recording device (microphone)
            deviceEnumerator.GetDefaultAudioEndpoint(DEVICE_FLOW_CAPTURE, ROLE_COMMUNICATIONS, out device);

            // Activate the audio endpoint volume interface
            device.Activate(ref IID_IAudioEndpointVolume, 0, IntPtr.Zero, out EndpointVolumeInterface);
            endpointVolume = (IAudioEndpointVolume)EndpointVolumeInterface;

            // Get current mute state
            endpointVolume.GetMute(out currentMute);

            // Toggle mute state
            endpointVolume.SetMute(!currentMute, ref empty);

            // Return new mute state
            return !currentMute;
        }
        catch (Exception ex) {
            Console.WriteLine("Error toggling microphone: " + ex.Message);
            return false;
        }
        finally {
            // Release COM objects
            if (endpointVolume != null) Marshal.ReleaseComObject(endpointVolume);
            if (EndpointVolumeInterface != null) Marshal.ReleaseComObject(EndpointVolumeInterface);
            if (device != null) Marshal.ReleaseComObject(device);
            if (deviceEnumerator != null) Marshal.ReleaseComObject(deviceEnumerator);
            if (MMDeviceEnumeratorInterface != null) Marshal.ReleaseComObject(MMDeviceEnumeratorInterface);
        }
    }
}
"@

# Toggle microphone mute state
$newMuteState = [MicrophoneManager]::ToggleMicrophoneMute()

# Provide feedback
if ($newMuteState) {
    Write-Host "Microphone MUTED"
} else {
    Write-Host "Microphone UNMUTED"
}

# Optional: Show notification
Add-Type -AssemblyName System.Windows.Forms
$global:balmsg = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -id $pid).Path
$balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
$balmsg.BalloonTipText = if ($newMuteState) {"Microphone MUTED"} else {"Microphone UNMUTED"}
$balmsg.BalloonTipTitle = "Mic Status"
$balmsg.Visible = $true
$balmsg.ShowBalloonTip(2000)
Start-Sleep -Seconds 2
$balmsg.Dispose()
