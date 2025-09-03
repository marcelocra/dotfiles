#!/usr/bin/env sh

code --list-extensions | sort > extensions-installed.txt
code --list-extensions --show-versions | sort > extensions-installed-with-version.txt

