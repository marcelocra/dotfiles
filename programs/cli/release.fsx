#!/usr/bin/env -S dotnet fsi

#load "functions.fsx"


// Build dotnet project
Functions.runShellCommand "dotnet publish -c Release"

Functions.runShellCommand "cp ./src/App/bin/Release/net7.0/linux-x64/publish/App ./bin/cli"
