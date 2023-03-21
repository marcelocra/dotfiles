#!/usr/bin/env -S dotnet fsi

#load "Functions.fsx"
open Functions

runShellCommand "echo -n 'hello world!'"
