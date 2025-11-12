<#
.SYNOPSIS
    Microphone Mute/Unmute Toggle using Windows Core Audio API (WASAPI)

.DESCRIPTION
    This script uses the same Windows Core Audio API that professional audio libraries
    like NAudio use to control microphone mute state. It's completely safe and only
    touches the microphone mute setting.

.NOTES
    Author: Based on NAudio library implementation
    PowerShell: Requires PowerShell 7 (Core) for best COM interop support
    Safety: Uses only Windows built-in COM interfaces, no external dependencies

.AUDIO API EXPLANATION
    Windows Core Audio API (WASAPI) Components:

    • Audio Endpoints: These are audio devices like microphones, speakers, headphones.
      Think of them as the "pipes" that audio flows through.

    • MMDeviceEnumerator: A factory that lets you discover and access audio endpoints.
      Like a "phone book" for audio devices.

    • IMMDevice: Represents a specific audio device (like your microphone).
      This is the actual device object you can control.

    • IAudioEndpointVolume: The volume and mute controller for a specific device.
      This is what actually changes the mute state.

    GUIDs (Global Unique Identifiers):
    These are Windows' way of uniquely identifying COM interfaces. Think of them as
    "addresses" that tell Windows exactly which audio interface you want to use.
    Each audio interface has a unique GUID that never changes.

    • BCDE0395-E52F-467C-8E3D-C4579291692E = MMDeviceEnumerator class
    • A95664D2-9614-4F35-A746-DE8DB63617E6 = IMMDeviceEnumerator interface
    • D666063F-1587-4E43-81F1-B948E807363F = IMMDevice interface
    • 5CDF2C82-841E-4546-9722-0CF74078229A = IAudioEndpointVolume interface

    Why COM Interfaces?
    Windows audio is implemented as COM (Component Object Model) interfaces.
    These are standardized contracts that define exactly how to communicate with
    Windows audio subsystem. Every audio application uses these same interfaces.
#>

using namespace System.Runtime.InteropServices
using namespace System.Windows.Forms

Add-Type -AssemblyName System.Windows.Forms

# Define Windows Core Audio API interfaces
# These are the exact same interfaces that NAudio and other audio libraries use
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

namespace AudioControl
{
    /// <summary>
    /// COM class for creating MMDeviceEnumerator instances
    /// This is the entry point to Windows audio device discovery
    /// </summary>
    [ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")]
    public class MMDeviceEnumerator
    {
    }

    /// <summary>
    /// Interface for enumerating audio devices (microphones, speakers, etc.)
    /// Think of this as a "device finder" that locates audio hardware
    /// </summary>
    [ComImport]
    [Guid("A95664D2-9614-4F35-A746-DE8DB63617E6")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IMMDeviceEnumerator
    {
        /// <summary>
        /// Lists all audio endpoints (devices) of a specific type
        /// dataFlow: 0=Render(speakers), 1=Capture(microphones), 2=All
        /// stateMask: Device state filter (active, disabled, etc.)
        /// </summary>
        [PreserveSig]
        int EnumAudioEndpoints(int dataFlow, int stateMask, out IntPtr devices);

        /// <summary>
        /// Gets the default audio device for a specific purpose
        /// dataFlow: 1=Capture (microphone), 0=Render (speakers)
        /// role: 0=Console, 1=Multimedia, 2=Communications
        /// </summary>
        [PreserveSig]
        int GetDefaultAudioEndpoint(int dataFlow, int role, out IntPtr endpoint);

        /// <summary>
        /// Gets a specific device by its unique ID string
        /// </summary>
        [PreserveSig]
        int GetDevice([MarshalAs(UnmanagedType.LPWStr)] string id, out IntPtr deviceName);

        /// <summary>
        /// Registers for device change notifications (we don't use these)
        /// </summary>
        [PreserveSig]
        int RegisterEndpointNotificationCallback(IntPtr client);

        [PreserveSig]
        int UnregisterEndpointNotificationCallback(IntPtr client);
    }

    /// <summary>
    /// Interface representing a specific audio device (like your microphone)
    /// This is the actual device object you can interact with
    /// </summary>
    [ComImport]
    [Guid("D666063F-1587-4E43-81F1-B948E807363F")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IMMDevice
    {
        /// <summary>
        /// Activates a specific interface on this device
        /// This is how you get volume control, meter info, etc.
        /// iid: The GUID of the interface you want (like volume control)
        /// </summary>
        [PreserveSig]
        int Activate(ref Guid iid, int dwClsCtx, IntPtr pActivationParams, out IntPtr ppInterface);

        /// <summary>
        /// Opens device properties (we don't use this)
        /// </summary>
        [PreserveSig]
        int OpenPropertyStore(int stgmAccess, out IntPtr ppProperties);

        /// <summary>
        /// Gets the unique device ID string
        /// </summary>
        [PreserveSig]
        int GetId(out IntPtr ppstrId);

        /// <summary>
        /// Gets current device state (active, disabled, unplugged, etc.)
        /// </summary>
        [PreserveSig]
        int GetState(out int pdwState);
    }

    /// <summary>
    /// Interface for controlling volume and mute on an audio device
    /// This is the main interface we use - it actually changes the mute state
    /// </summary>
    [ComImport]
    [Guid("5CDF2C82-841E-4546-9722-0CF74078229A")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IAudioEndpointVolume
    {
        // Volume change notification methods (we don't use these)
        [PreserveSig]
        int RegisterControlChangeNotify(IntPtr pNotify);

        [PreserveSig]
        int UnregisterControlChangeNotify(IntPtr pNotify);

        /// <summary>
        /// Gets number of audio channels (mono=1, stereo=2, etc.)
        /// </summary>
        [PreserveSig]
        int GetChannelCount(out int pnChannelCount);

        // Volume level methods (we don't use these, just mute/unmute)
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

        /// <summary>
        /// THE IMPORTANT METHOD: Sets mute state on/off
        /// bMute: true to mute, false to unmute
        /// pguidEventContext: Event context for notifications (we use empty GUID)
        /// </summary>
        [PreserveSig]
        int SetMute([MarshalAs(UnmanagedType.Bool)] bool bMute, ref Guid pguidEventContext);

        /// <summary>
        /// THE OTHER IMPORTANT METHOD: Gets current mute state
        /// pbMute: receives true if muted, false if unmuted
        /// </summary>
        [PreserveSig]
        int GetMute([MarshalAs(UnmanagedType.Bool)] out bool pbMute);

        // Volume step methods (we don't use these)
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

    /// <summary>
    /// Our main controller class that orchestrates the microphone toggle
    /// This coordinates all the COM interfaces to accomplish the mute/unmute
    /// </summary>
    public static class MicrophoneController
    {
        /// <summary>
        /// Toggles microphone mute state and returns the new state
        /// Returns: 1 = now muted, 0 = now unmuted, -1 = error occurred
        /// </summary>
        public static int ToggleMute()
        {
            // COM interface pointers - these hold references to Windows audio objects
            IntPtr deviceEnumeratorPtr = IntPtr.Zero;
            IntPtr devicePtr = IntPtr.Zero;
            IntPtr endpointVolumePtr = IntPtr.Zero;

            try
            {
                // Step 1: Create the device enumerator (audio device finder)
                var deviceEnumerator = new MMDeviceEnumerator();
                deviceEnumeratorPtr = Marshal.GetIUnknownForObject(deviceEnumerator);
                var enumerator = Marshal.GetObjectForIUnknown(deviceEnumeratorPtr) as IMMDeviceEnumerator;

                // Step 2: Get the default microphone device
                const int eCapture = 1;    // We want capture devices (microphones)
                const int eConsole = 0;    // We want the console/default role

                int hr = enumerator.GetDefaultAudioEndpoint(eCapture, eConsole, out devicePtr);
                if (hr != 0) return -1;   // Failed to get microphone

                var device = Marshal.GetObjectForIUnknown(devicePtr) as IMMDevice;

                // Step 3: Get the volume control interface for this microphone
                var volumeInterfaceId = new Guid("5CDF2C82-841E-4546-9722-0CF74078229A");
                hr = device.Activate(ref volumeInterfaceId, 1, IntPtr.Zero, out endpointVolumePtr);
                if (hr != 0) return -1;   // Failed to get volume control

                var endpointVolume = Marshal.GetObjectForIUnknown(endpointVolumePtr) as IAudioEndpointVolume;

                // Step 4: Read current mute state
                hr = endpointVolume.GetMute(out bool isMuted);
                if (hr != 0) return -1;   // Failed to read mute state

                // Step 5: Toggle the mute state
                var eventContext = Guid.Empty;  // Empty GUID means "no special event context"
                bool newMuteState = !isMuted;    // Flip the current state
                hr = endpointVolume.SetMute(newMuteState, ref eventContext);
                if (hr != 0) return -1;         // Failed to set mute state

                // Return the new state: 1 = now muted, 0 = now unmuted
                return newMuteState ? 1 : 0;
            }
            catch (Exception)
            {
                // Any exception means something went wrong
                return -1;
            }
            finally
            {
                // CRITICAL: Release COM objects to prevent memory leaks
                // This is like closing files - always do it even if errors occurred
                if (endpointVolumePtr != IntPtr.Zero)
                {
                    try { Marshal.Release(endpointVolumePtr); } catch { }
                }
                if (devicePtr != IntPtr.Zero)
                {
                    try { Marshal.Release(devicePtr); } catch { }
                }
                if (deviceEnumeratorPtr != IntPtr.Zero)
                {
                    try { Marshal.Release(deviceEnumeratorPtr); } catch { }
                }
            }
        }
    }
}
'@

# Main execution with bulletproof error handling
try {
    # Attempt to toggle the microphone
    $result = [AudioControl.MicrophoneController]::ToggleMute()

    # Create notification balloon with using-like pattern for disposal
    $balloon = $null
    #try {
    #    $balloon = New-Object System.Windows.Forms.NotifyIcon
#
    #    # Get PowerShell executable path for the notification icon
    #    $path = if ($PSVersionTable.PSEdition -eq 'Core') {
    #        # PowerShell 7 path
    #        (Get-Process -Id $PID).Path
    #    } else {
    #        # Fallback for Windows PowerShell 5.1
    #        "$env:WINDIR\System32\WindowsPowerShell\v1.0\powershell.exe"
    #    }
#
    #    # Set up the balloon notification
    #    $balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
    #    $balloon.Visible = $true
#
    #    # Choose notification based on result
    #    switch ($result) {
    #        1 {
    #            # Microphone was unmuted, now it's muted
    #            $balloon.BalloonTipTitle = "Microphone"
    #            $balloon.BalloonTipText = "Microphone Muted"
    #            $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
    #        }
    #        0 {
    #            # Microphone was muted, now it's unmuted
    #            $balloon.BalloonTipTitle = "Microphone"
    #            $balloon.BalloonTipText = "Microphone Unmuted"
    #            $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
    #        }
    #        default {
    #            # Something went wrong (result = -1)
    #            $balloon.BalloonTipTitle = "Microphone"
    #            $balloon.BalloonTipText = "Failed to toggle microphone"
    #            $balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Error
    #        }
    #    }
#
    #    # Show the notification for 3 seconds
    #    $balloon.ShowBalloonTip(3000)
#
    #    # Brief pause to ensure notification appears
    #    Start-Sleep -Milliseconds 500
    #}
    #catch {
    #    # Even if notification fails, that's OK - the mute toggle might have worked
    #    # We don't want notification errors to crash the main functionality
    #}
    finally {
        # Bulletproof disposal - always clean up the notification icon
        if ($balloon -ne $null) {
            try {
                $balloon.Dispose()
            }
            catch {
                # Even disposal can sometimes fail, but we don't want that to crash anything
            }
        }
    }
}
catch {
    # Ultimate fallback - if everything fails, fail silently
    # We don't want any error popups when using this as a hotkey
}
