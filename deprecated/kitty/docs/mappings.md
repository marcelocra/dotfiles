---
title: "Making your keyboard dance"
source: "https://sw.kovidgoyal.net/kitty/mapping/#making-your-keyboard-dance"
author:
  - "[[kitty]]"
published:
created: 2025-03-07
description: "kitty has extremely powerful facilities for mapping keyboard actions. Things like combining actions, multi-key mappings, modal mappings, mappings that send arbitrary text, and mappings dependent on..."
tags:
  - "clippings"
---
kitty has extremely powerful facilities for mapping keyboard actions. Things like combining actions, multi-key mappings, modal mappings, mappings that send arbitrary text, and mappings dependent on the program currently running in kitty.

Let’s start with the basics. You can map a key press to an action in kitty using the following syntax:

```conf
mapctrl+anew_window_with_cwd
```

This will map the key press Ctrl+a to open a new [window](https://sw.kovidgoyal.net/kitty/glossary/#term-window) with the working directory set to the working directory of the current window. This is the basic operation of the map directive, the tip of the iceberg, for more read the sections below.

## Combining multiple actions on a single keypress¶

Multiple actions can be combined on a single keypress, like a macro. To do this map the key press to the [`combine`](https://sw.kovidgoyal.net/kitty/actions/#action-combine) action:

```conf
mapkeycombine <separator> action1 <separator> action2 <separator> action3 ...
```

For example:

```conf
mapkitty_mod+ecombine : new_window : next_layout
```

This will create a new window and switch to the next available layout. You can also run arbitrarily powerful scripts on a key press. There are two major techniques for doing this, using remote control scripts or using kittens.

### Remote control scripts¶

These can be written in any language and use the “kitten” binary to control kitty via its extensive [Remote control](https://sw.kovidgoyal.net/kitty/remote-control/) API. First, if you just want to run a single remote control command on a key press, you can just do:

```conf
mapf1remote_control set-spacing margin=30
```

This will run the `set-spacing` command, changing window margins to 30 pixels. For more complex scripts, write a script file in any language you like and save it somewhere, preferably in the kitty configuration directory. Do not forget to make it executable. In the script file you run remote control commands by running the “kitten” binary, for example:

```sh
#!/bin/sh

kitten@set-spacingmargin=30
kitten@new_window
...
```

The script can perform arbitrarily complex logic and actions, limited only by the remote control API, that you can browse by running `kitten @ --help`. To run the script you created on a key press, use:

```conf
mapf1remote_control_script /path/to/myscript
```

### Kittens¶

Here, kittens refer to Python scripts. The scripts have two parts, one that runs as a regular command line program inside a kitty window to, for example, ask the user for some input and a second part that runs inside the kitty process itself and can perform any operation on the kitty UI, which is itself implemented in Python. However, the kitty internal API is not documented and can (very rarely) change, so kittens are harder to get started with than remote control scripts. To run a kitten on a key press:

```conf
mapf1kitten mykitten.py
```

Many of kitty’s features are themselves implemented as kittens, for example, [Unicode input](https://sw.kovidgoyal.net/kitty/kittens/unicode_input/), [Hints](https://sw.kovidgoyal.net/kitty/kittens/hints/) and [Changing kitty colors](https://sw.kovidgoyal.net/kitty/kittens/themes/). To learn about writing your own kittens, see [Custom kittens](https://sw.kovidgoyal.net/kitty/kittens/custom/).

## Syntax for specifying keys¶

A mapping maps a key press to some action. In their most basic form, keypresses are `modifier+key`. Keys are identified simply by their lowercase Unicode characters. For example: `a` for the A key, `[` for the left square bracket key, etc. For functional keys, such as Enter or Escape, the names are present at [Functional key definitions](https://sw.kovidgoyal.net/kitty/keyboard-protocol/#functional). For modifier keys, the names are ctrl (control, ⌃), shift (⇧), alt (opt, option, ⌥), super (cmd, command, ⌘).

Additionally, you can use the name [`kitty_mod`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.kitty_mod) as a modifier, the default value of which is ctrl+shift. The default kitty shortcuts are defined using this value, so by changing it in `kitty.conf` you can change all the modifiers used by all the default shortcuts.

On Linux, you can also use XKB names for functional keys that don’t have kitty names. See [XKB keys](https://github.com/xkbcommon/libxkbcommon/blob/master/include/xkbcommon/xkbcommon-keysyms.h) for a list of key names. The name to use is the part after the `XKB_KEY_` prefix. Note that you can only use an XKB key name for keys that are not known as kitty keys.

Finally, you can use raw system key codes to map keys, again only for keys that are not known as kitty keys. To see the system key code for a key, start kitty with the [`kitty --debug-input`](https://sw.kovidgoyal.net/kitty/invocation/#cmdoption-kitty-debug-input) option, kitty will output some debug text for every key event. In that text look for `native_code`, the value of that becomes the key name in the shortcut. For example:

```none
on_key_input: glfw key: 0x61 native_code: 0x61 action: PRESS mods: none text: 'a'
```

Here, the key name for the A key is `0x61` and you can use it with:

```conf
mapctrl+0x61something
```

This maps Ctrl+A to something.

## Multi-key mappings¶

A mapping in kitty can involve pressing multiple keys in sequence, with the syntax shown below:

```conf
mapkey1>key2>key3action
```

For example:

```conf
mapctrl+f>2set_font_size 20
```

The default mappings to run the [hints kitten](https://sw.kovidgoyal.net/kitty/kittens/hints/) to select text on the screen are examples of multi-key mappings.

## Unmapping default shortcuts¶

kitty comes with dozens of default keyboard mappings for common operations. See [Mappable actions](https://sw.kovidgoyal.net/kitty/actions/) for the full list of actions and the default shortcuts that map to them. You can unmap an individual shortcut, so that it is passed on to the program running inside kitty, by mapping it to nothing, for example:

```conf
mapkitty_mod+enter
```

This unmaps the default shortcut [`ctrl+shift+enter`](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.New-window) to open a new window. Almost all default shortcuts are of the form `modifier + key` where the modifier defaults to Ctrl+Shift and can be changed using the [`kitty_mod`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.kitty_mod) setting in `kitty.conf`.

If you want to clear all default shortcuts, you can use [`clear_all_shortcuts`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.clear_all_shortcuts) in `kitty.conf`.

If you would like kitty to completely ignore a key event, not even sending it to the program running in the terminal, map it to [`discard_event`](https://sw.kovidgoyal.net/kitty/actions/#action-discard_event):

```conf
mapkitty_mod+f1discard_event
```

## Conditional mappings depending on the state of the focused window¶

Sometimes, you may want different mappings to be active when running a particular program in kitty, perhaps because it has some native functionality that duplicates kitty functions or there is a conflict, etc. kitty has the ability to create mappings that work only when the currently focused window matches some criteria, such as when it has a particular title or user variable.

Let’s see some examples:

```conf
map--when-focus-ontitle:keyboard.protocolkitty_mod+t
```

This will cause kitty\_mod+t (the default shortcut for opening a new tab) to be unmapped only when the focused window has `keyboard protocol` in its title. Run the show-key kitten as:

```conf
kittenshow-key -m kitty
```

Press ctrl+shift+t and instead of a new tab opening, you will see the key press being reported by the kitten. `--when-focus-on` can test the focused window using very powerful criteria, see [Matching windows and tabs](https://sw.kovidgoyal.net/kitty/remote-control/#search-syntax) for details. A more practical example unmaps the key when the focused window is running an editor:

```conf
map--when-focus-onvar:in_editorkitty_mod+c
```

In order to make this work, you need to configure your editor as show below:

In `~/.vimrc` add:

```vim
let &t_ti = &t_ti . "\033]1337;SetUserVar=in_editor=MQo\007"
let &t_te = &t_te . "\033]1337;SetUserVar=in_editor\007"
```

In `~/.config/nvim/init.lua` add:

> ```lua
> vim.api.nvim_create_autocmd({"VimEnter","VimResume"},{
> group=vim.api.nvim_create_augroup("KittySetVarVimEnter",{clear=true}),
> callback=function()
> io.stdout:write("\x1b]1337;SetUserVar=in_editor=MQo\007")
> end,
> })
>
> vim.api.nvim_create_autocmd({"VimLeave","VimSuspend"},{
> group=vim.api.nvim_create_augroup("KittyUnsetVarVimLeave",{clear=true}),
> callback=function()
> io.stdout:write("\x1b]1337;SetUserVar=in_editor\007")
> end,
> })
> ```

These cause the editor to set the `in_editor` variable in kitty and unset it when exiting. As a result, the ctrl+shift+c key will be passed to the editor instead of copying to clipboard. In the editor, you can map it to copy to the clipboard, thereby allowing use of a common shortcut both inside and outside the editor for copying to clipboard.

## Sending arbitrary text or keys to the program running in kitty¶

This is accomplished by using `map` with [`send_text`](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Send-arbitrary-text-on-key-presses) in `kitty.conf`. For example:

```conf
mapf1send_text normal,application Hello, world!
```

Now, pressing f1 will cause `Hello, world!` to show up at your shell prompt. To have the shell execute a command sent via `send_text` you need to also simulate pressing the enter key which is `\r`. For example:

```conf
mapf1send_text normal,application echo Hello, world!\r
```

Now, if you press f1 when at shell prompt it will run the `echo Hello, world!` command.

To have one key press send another key press, use [`send_key`](https://sw.kovidgoyal.net/kitty/actions/#action-send_key):

```conf
mapalt+ssend_key ctrl+s
```

This causes the program running in kitty to receive the ctrl+s key when you press the alt+s key. To see this in action, run:

```conf
kittenshow-key -m kitty
```

Which will print out what key events it receives.

## Modal mappings¶

kitty has the ability, like vim, to use *modal* key maps. Except that unlike vim it allows you to define your own arbitrary number of modes. To create a new mode, use `map --new-mode <my mode name> <shortcut to enter mode>`. For example, lets create a mode to manage windows: switching focus, moving the window, etc.:

```conf
# Create a new "manage windows" mode (mw)
map--new-modemwkitty_mod+f7

# Switch focus to the neighboring window in the indicated direction using arrow keys
map--modemwleftneighboring_window left
map--modemwrightneighboring_window right
map--modemwupneighboring_window up
map--modemwdownneighboring_window down

# Move the active window in the indicated direction
map--modemwshift+upmove_window up
map--modemwshift+leftmove_window left
map--modemwshift+rightmove_window right
map--modemwshift+downmove_window down

# Resize the active window
map--modemwnresize_window narrower
map--modemwwresize_window wider
map--modemwtresize_window taller
map--modemwsresize_window shorter

# Exit the manage window mode
map--modemwescpop_keyboard_mode
```

Now, if you run kitty as:

```sh
kitty-oenabled_layouts=vertical--session<(echo"launch\nlaunch\nlaunch")
```

Press Ctrl+Shift+F7 to enter the mode and then press the up and down arrow keys to focus the next/previous window. Press Shift+Up or Shift+Down to move the active window up and down. Press t to make the active window taller and s to make it shorter. To exit the mode press Esc.

Pressing an unknown key while in a custom keyboard mode by default beeps. This can be controlled by the `map --on-unknown` option as shown below:

```conf
# Beep on unknown keys
map--new-modeXXX--on-unknownbeep...
# Ingore unknown keys silently
map--new-modeXXX--on-unknownignore...
# Beep and exit the keyboard mode on unknown key
map--new-modeXXX--on-unknownend...
# Pass unknown keys to the program running in the active window
map--new-modeXXX--on-unknownpassthrough...
```

When a key matches an action in a custom keyboard mode, the action is performed and the custom keyboard mode remains in effect. If you would rather have the keyboard mode end after the action you can use `map --on-action` as shown below:

```conf
# Have this keyboard mode automatically exit after performing any action
map--new-modeXXX--on-actionend...
```

## All mappable actions¶

There is a list of [all mappable actions](https://sw.kovidgoyal.net/kitty/actions/).

## Debugging mapping issues¶

To debug mapping issues, kitty has several facilities. First, when you run kitty with the `--debug-input` command line flag it outputs details about all key events it receives form the system and how they are handled.

To see what key events are sent to applications, run kitty like this:

```conf
kittykitten show-key
```

Press the keys you want to debug and the kitten will print out the bytes it receives. Note that this uses the legacy terminal keyboard protocol that does not support all keys and key events. To debug the [full kitty keyboard protocol that](https://sw.kovidgoyal.net/kitty/keyboard-protocol/) that is nowadays being adopted by more and more programs, use:

```conf
kittykitten show-key -m kitty
```
