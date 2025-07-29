#!/usr/bin/env -S dotnet fsi

open System.Diagnostics
open System.IO

let runCommand command args =
    let psi = new ProcessStartInfo(command, args)
    psi.RedirectStandardOutput <- true
    psi.RedirectStandardError <- true
    psi.UseShellExecute <- false
    psi.CreateNoWindow <- true
    let p = Process.Start(psi)
    let output = p.StandardOutput.ReadToEnd()
    let error = p.StandardError.ReadToEnd()
    p.WaitForExit()
    if p.ExitCode <> 0 then
        failwithf "Command failed: %s" error
    output

let sessionExists sessionName =
    let output = runCommand "tmux" (sprintf "has-session -t %s 2>/dev/null || echo false" sessionName)
    not (output.Contains("false"))

let attachSession sessionName =
    runCommand "tmux" (sprintf "attach -t %s" sessionName)

let createSession sessionName =
    runCommand "tmux" (sprintf "new-session -d -s %s" sessionName)

let isTmuxActiveWindow sessionName =
    let output = runCommand "tmux" "display-message -p '#S'"
    output.Trim() = sessionName

let bringSessionToFront sessionName =
    runCommand "tmux" (sprintf "switch-client -t %s" sessionName)

let detachTmuxSession sessionName =
    runCommand "tmux" "detach"

let sessionName = "my-tmux-session" // Replace with the desired session name

if sessionExists sessionName then
    if isTmuxActiveWindow sessionName then
        detachTmuxSession sessionName
    else
        bringSessionToFront sessionName
else
    createSession sessionName
    attachSession sessionName
