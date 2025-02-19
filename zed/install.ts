#!/usr/bin/env -S deno run -A
// Symlink files in array to proper location.

import * as path from "jsr:@std/path";

const HOME = Deno.env.get("HOME");

if (!HOME) {
  console.error("HOME is not set");
  Deno.exit(1);
}

// Symlink to ~/.config/zed.
const SYMLINK_TO = path.join(HOME, "/.config/zed");
console.log(SYMLINK_TO);

// TODO: write this later.
