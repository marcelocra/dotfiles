module Library

open System.Text.Json
open System
open System.Diagnostics


let getJson value =
    let json = JsonSerializer.Serialize(value)
    value, json


let private isUnix = Environment.OSVersion.Platform = PlatformID.Unix


/// <summary>Runs the given command in a shell and returns the output.</summary>
let runShellCommand (command: string) : string =
    // Perhaps use /usr/bin/env bash -S instead of /bin/bash?
    let osExecutor = if isUnix then "/bin/bash" else "cmd.exe"
    let osExecutorArgs = sprintf (if isUnix then "-c \"%s\"" else "/C %s") command

    let proc = new Process()
    proc.StartInfo.FileName <- osExecutor
    proc.StartInfo.Arguments <- osExecutorArgs
    proc.StartInfo.UseShellExecute <- false
    proc.StartInfo.RedirectStandardOutput <- true

    proc.Start() |> ignore

    let output = proc.StandardOutput.ReadToEnd()
    proc.WaitForExit()

    output
