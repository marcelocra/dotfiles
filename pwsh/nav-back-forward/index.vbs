Set shell = CreateObject("WScript.Shell")
Set fso   = CreateObject("Scripting.FileSystemObject")

' Find the folder this VBS is in
scriptFolder = fso.GetParentFolderName(WScript.ScriptFullName)

' Build the pwsh command with full absolute path
psCmd = "pwsh -NoProfile -WindowStyle Hidden -File """ & _
         scriptFolder & "\index.ps1"""

' Run hidden, do not wait
shell.Run psCmd, 0, False
