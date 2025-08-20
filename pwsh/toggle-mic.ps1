# Microphone Toggle for PowerShell 7 (Core)
# Using .NET 6+ features and better COM interop

using namespace System.Runtime.InteropServices

Add-Type -AssemblyName System.Windows.Forms

# Use PowerShell 7's improved Add-Type with better .NET support
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

namespace AudioControl
{
    [ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")]
    public class MMDeviceEnumerator
    {
    }

    [ComImport]
    [Guid("A95664D2-9614-4F35-A746-DE8DB63617E6")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IMMDeviceEnumerator
    {
        [PreserveSig]
        int EnumAudioEndpoints(int dataFlow, int stateMask, out IntPtr devices);

        [PreserveSig]
        int GetDefaultAudioEndpoint(int dataFlow, int role, out IntPtr endpoint);

        [PreserveSig]
        int GetDevice([MarshalAs(UnmanagedType.LPWStr)] string id, out IntPtr deviceName);

        [PreserveSig]
        int RegisterEndpointNotificationCallback(IntPtr client);

        [PreserveSig]
        int UnregisterEndpointNotificationCallback(IntPtr client);
    }

    [ComImport]
    [Guid("D666063F-1587-4E43-81F1-B948E807363F")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IMMDevice
    {
        [PreserveSig]
        int Activate(ref Guid iid, int dwClsCtx, IntPtr pActivationParams, out IntPtr ppInterface);

        [PreserveSig]
        int OpenPropertyStore(int stgmAccess, out IntPtr ppProperties);

        [PreserveSig]
        int GetId(out IntPtr ppstrId);

        [PreserveSig]
        int GetState(out int pdwState);
    }

    [ComImport]
    [Guid("5CDF2C82-841E-4546-9722-0CF74078229A")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IAudioEndpointVolume
    {
        [PreserveSig]
        int RegisterControlChangeNotify(IntPtr pNotify);

        [PreserveSig]
        int UnregisterControlChangeNotify(IntPtr pNotify);

        [PreserveSig]
        int GetChannelCount(out int pnChannelCount);

        [PreserveSig]
        int SetMasterVolumeLevel(float fLevelDB, ref Guid pguidEventContext);

        [PreserveSig]
        int SetMasterVolumeLevelScalar(float fLevel, ref Guid pguidEventContext);

        [PreserveSig]
        int GetMasterVolumeLevel(out float pfLevelDB);

        [PreserveSig]
        int GetMasterVolumeLevelScalar(out float pfLevel);

        [PreserveSig]
        int SetChannelVolumeLevel(int nChannel, float fLevelDB, ref Guid pguidEventContext);

        [PreserveSig]
        int SetChannelVolumeLevelScalar(int nChannel, float fLevel, ref Guid pguidEventContext);

        [PreserveSig]
        int GetChannelVolumeLevel(int nChannel, out float pfLevelDB);

        [PreserveSig]
        int GetChannelVolumeLevelScalar(int nChannel, out float pfLevel);

        [PreserveSig]
        int SetMute([MarshalAs(UnmanagedType.Bool)] bool bMute, ref Guid pguidEventContext);

        [PreserveSig]
        int GetMute([MarshalAs(UnmanagedType.Bool)] out bool pbMute);

        [PreserveSig]
        int GetVolumeStepInfo(out int pnStep, out int pnStepCount);

        [PreserveSig]
        int VolumeStepUp(ref Guid pguidEventContext);

        [PreserveSig]
        int VolumeStepDown(ref Guid pguidEventContext);

        [PreserveSig]
        int QueryHardwareSupport(out int pdwHardwareSupportMask);

        [PreserveSig]
        int GetVolumeRange(out float pflVolumeMindB, out float pflVolumeMaxdB, out float pflVolumeIncrementdB);
    }

    public static class MicrophoneController
    {
        public static int ToggleMute()
        {
            IntPtr deviceEnumeratorPtr = IntPtr.Zero;
            IntPtr devicePtr = IntPtr.Zero;
            IntPtr endpointVolumePtr = IntPtr.Zero;

            try
            {
                // Create device enumerator
                var deviceEnumerator = new MMDeviceEnumerator();
                deviceEnumeratorPtr = Marshal.GetIUnknownForObject(deviceEnumerator);
                var enumerator = Marshal.GetObjectForIUnknown(deviceEnumeratorPtr) as IMMDeviceEnumerator;

                // Get default capture device (microphone)
                const int eCapture = 1;
                const int eConsole = 0;

                int hr = enumerator.GetDefaultAudioEndpoint(eCapture, eConsole, out devicePtr);
                if (hr != 0) return -1;

                var device = Marshal.GetObjectForIUnknown(devicePtr) as IMMDevice;

                // Activate audio endpoint volume interface
                var iid = new Guid("5CDF2C82-841E-4546-9722-0CF74078229A");
                hr = device.Activate(ref iid, 1, IntPtr.Zero, out endpointVolumePtr);
                if (hr != 0) return -1;

                var endpointVolume = Marshal.GetObjectForIUnknown(endpointVolumePtr) as IAudioEndpointVolume;

                // Get current mute state
                hr = endpointVolume.GetMute(out bool isMuted);
                if (hr != 0) return -1;

                // Toggle mute state
                var eventContext = Guid.Empty;
                bool newMuteState = !isMuted;
                hr = endpointVolume.SetMute(newMuteState, ref eventContext);
                if (hr != 0) return -1;

                return newMuteState ? 1 : 0; // 1 = now muted, 0 = now unmuted
            }
            catch (Exception)
            {
                return -1;
            }
            finally
            {
                if (endpointVolumePtr != IntPtr.Zero) Marshal.Release(endpointVolumePtr);
                if (devicePtr != IntPtr.Zero) Marshal.Release(devicePtr);
                if (deviceEnumeratorPtr != IntPtr.Zero) Marshal.Release(deviceEnumeratorPtr);
            }
        }
    }
}
'@

# Execute the toggle
try {
    $result = [AudioControl.MicrophoneController]::ToggleMute()

    # Create notification
    $balloon = New-Object System.Windows.Forms.NotifyIcon
    $path = if ($PSVersionTable.PSEdition -eq 'Core') {
        # PowerShell 7 path
        (Get-Process -Id $PID).Path
    } else {
        # Fallback for Windows PowerShell
        "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
    }

    $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
    $balloon.Visible = $true

    switch ($result) {
        1 {
            $balloon.BalloonTipTitle = "Microphone"
            $balloon.BalloonTipText = "Microphone Muted"
            $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
        }
        0 {
            $balloon.BalloonTipTitle = "Microphone"
            $balloon.BalloonTipText = "Microphone Unmuted"
            $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
        }
        default {
            $balloon.BalloonTipTitle = "Microphone"
            $balloon.BalloonTipText = "Failed to toggle microphone"
            $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Error
        }
    }

    $balloon.ShowBalloonTip(3000)
    Start-Sleep -Milliseconds 500
    $balloon.Dispose()
}
catch {
    # Silent failure
}
