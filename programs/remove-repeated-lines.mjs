#!/usr/bin/env node

/**
 * Removes all repeated lines from a file, keeping the ones that appeared
 * first.
 *
 * To simplify its usage, consider adding a symlink to this script in one of
 * the folders in your path:
 *
 *  $ ln -s ./path/to/remove-repeated-lines.mjs ~/bin/rrl
 */

import fs from 'node:fs'

const ARGS = process.argv.slice(2)
const INPUT_FILE_PATH_ARG_NAME = '--input'
const OUTPUT_FILE_PATH_ARG_NAME = '--output'

const helpMessage = `Usage: rrl ./path-to-input ./path-to-output [--input=path-to-input --output=path-to-output]`

// Need at least the file path.
if (ARGS.length < 2) {
  console.error(helpMessage)
  process.exit(1)
}

// Accepts the input file path either as the first positional argument or as a
// named argument.
let INPUT_FILE_PATH = ARGS[0]
if (!fs.existsSync(INPUT_FILE_PATH)) {
  INPUT_FILE_PATH = ARGS.find(arg => arg.startsWith(INPUT_FILE_PATH_ARG_NAME)).split(/[= ]/)
  if (!fs.existsSync(INPUT_FILE_PATH)) {
    console.error(`Could not find file: '${INPUT_FILE_PATH}'`)
    process.exit(1)
  }
}

// Accepts the output file path either as the second positional argument or as
// a named argument.
let OUTPUT_FILE_PATH = ARGS[1]
// TODO: allow named argument.

// Create a set as a memo for lines.
const memo = new Set()
const result = []
const file = fs.readFileSync(INPUT_FILE_PATH)
for (const line of file.toString().split('\n')) {
  if (memo.has(line)) {
    continue
  }

  memo.add(line)
  result.push(line)
}

fs.writeFileSync(OUTPUT_FILE_PATH, result.join('\n'))

console.log('Done!')
