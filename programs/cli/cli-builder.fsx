#!/usr/bin/env -S dotnet fsi

#r "./src/Library/bin/Release/net7.0/publish/Library.dll"
open Library

// Build dotnet project using `release` mode.
runShellCommand "dotnet publish -c Release"

// Copy the resulting binary to the `~/bin/cli` directory, which is in the PATH.
runShellCommand "cp ./src/App/bin/Release/net7.0/linux-x64/publish/App ~/bin/cli"
