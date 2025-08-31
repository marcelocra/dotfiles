---
title: "kitty.conf"
source: "https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.action_alias"
author:
  - "[[kitty]]"
published:
created: 2025-03-07
description: "kitty is highly customizable, everything from keyboard shortcuts, to rendering frames-per-second. See below for an overview of all customization possibilities. You can open the config file within k..."
tags:
  - "clippings"
---
*kitty* is highly customizable, everything from keyboard shortcuts, to rendering frames-per-second. See below for an overview of all customization possibilities.

You can open the config file within *kitty* by pressing [`ctrl+shift+f2`](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Edit-config-file) (⌘+, on macOS). A `kitty.conf` with commented default configurations and descriptions will be created if the file does not exist. You can reload the config file within *kitty* by pressing [`ctrl+shift+f5`](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Reload-kitty.conf) (⌃+⌘+, on macOS) or sending *kitty* the `SIGUSR1` signal with `kill -SIGUSR1 $KITTY_PID`. You can also display the current configuration by pressing [`ctrl+shift+f6`](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Debug-kitty-configuration) (⌥+⌘+, on macOS).

*kitty* looks for a config file in the OS config directories (usually `~/.config/kitty/kitty.conf`) but you can pass a specific path via the [`kitty --config`](https://sw.kovidgoyal.net/kitty/invocation/#cmdoption-kitty-config) option or use the [`KITTY_CONFIG_DIRECTORY`](https://sw.kovidgoyal.net/kitty/glossary/#envvar-KITTY_CONFIG_DIRECTORY) environment variable. See [`kitty --config`](https://sw.kovidgoyal.net/kitty/invocation/#cmdoption-kitty-config) for full details.

**Comments** can be added to the config file as lines starting with the `#` character. This works only if the `#` character is the first character in the line.

**Lines can be split** by starting the next line with the `\` character. All leading whitespace and the `\` character are removed.

You can **include secondary config files** via the `include` directive. If you use a relative path for `include`, it is resolved with respect to the location of the current config file. Note that environment variables are expanded, so `${USER}.conf` becomes `name.conf` if `USER=name`. A special environment variable [`KITTY_OS`](https://sw.kovidgoyal.net/kitty/glossary/#envvar-KITTY_OS) is available, to detect the operating system. It is `linux`, `macos` or `bsd`. Also, you can use `globinclude` to include files matching a shell glob pattern and `envinclude` to include configuration from environment variables. Finally, you can dynamically generate configuration by running a program using `geninclude`. For example:

```conf
# Include other.conf
includeother.conf
# Include *.conf files from all subdirs of kitty.d inside the kitty config dir
globincludekitty.d/**/*.conf
# Include the *contents* of all env vars starting with KITTY_CONF_
envincludeKITTY_CONF_*
# Run the script dynamic.py placed in the same directory as this config file
# and include its :file:\`STDOUT\`. Note that Python scripts are fastest
# as they use the embedded Python interpreter, but any executable script
# or program is supported, in any language. Remember to mark the script
# file executable.
genincludedynamic.py
```

Note

Syntax highlighting for `kitty.conf` in vim is available via [vim-kitty](https://github.com/fladson/vim-kitty).

## Fonts¶

kitty has very powerful font management. You can configure individual font faces and even specify special fonts for particular characters.

font\_family, bold\_font, italic\_font, bold\_italic\_font[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.font_family "Link to this definition")

```conf
font_familymonospace
bold_fontauto
italic_fontauto
bold_italic_fontauto
```

You can specify different fonts for the bold/italic/bold-italic variants. The easiest way to select fonts is to run the `kitten choose-fonts` command which will present a nice UI for you to select the fonts you want with previews and support for selecting variable fonts and font features. If you want to learn to select fonts manually, read the [font specification syntax](https://sw.kovidgoyal.net/kitty/kittens/choose-fonts/#font-spec-syntax).

font\_size[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.font_size "Link to this definition")

```conf
font_size11.0
```

Font size (in pts).

force\_ltr[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.force_ltr "Link to this definition")

```conf
force_ltrno
```

kitty does not support BIDI (bidirectional text), however, for RTL scripts, words are automatically displayed in RTL. That is to say, in an RTL script, the words “HELLO WORLD” display in kitty as “WORLD HELLO”, and if you try to select a substring of an RTL-shaped string, you will get the character that would be there had the string been LTR. For example, assuming the Hebrew word ירושלים, selecting the character that on the screen appears to be ם actually writes into the selection buffer the character י. kitty’s default behavior is useful in conjunction with a filter to reverse the word order, however, if you wish to manipulate RTL glyphs, it can be very challenging to work with, so this option is provided to turn it off. Furthermore, this option can be used with the command line program [GNU FriBidi](https://github.com/fribidi/fribidi#executable) to get BIDI support, because it will force kitty to always treat the text as LTR, which FriBidi expects for terminals.

symbol\_map[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.symbol_map "Link to this definition")

Has no default values. Example values are shown below:

```conf
symbol_mapU+E0A0-U+E0A3,U+E0C0-U+E0C7PowerlineSymbols
```

Map the specified Unicode codepoints to a particular font. Useful if you need special rendering for some symbols, such as for Powerline. Avoids the need for patched fonts. Each Unicode code point is specified in the form `U+<code point in hexadecimal>`. You can specify multiple code points, separated by commas and ranges separated by hyphens. This option can be specified multiple times. The syntax is:

```conf
symbol_mapcodepointsFont Family Name
```

narrow\_symbols[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.narrow_symbols "Link to this definition")

Has no default values. Example values are shown below:

```conf
narrow_symbolsU+E0A0-U+E0A3,U+E0C0-U+E0C7 1
```

Usually, for Private Use Unicode characters and some symbol/dingbat characters, if the character is followed by one or more spaces, kitty will use those extra cells to render the character larger, if the character in the font has a wide aspect ratio. Using this option you can force kitty to restrict the specified code points to render in the specified number of cells (defaulting to one cell). This option can be specified multiple times. The syntax is:

```conf
narrow_symbolscodepoints [optionally the number of cells]
```

disable\_ligatures[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.disable_ligatures "Link to this definition")

```conf
disable_ligaturesnever
```

Choose how you want to handle multi-character ligatures. The default is to always render them. You can tell kitty to not render them when the cursor is over them by using `cursor` to make editing easier, or have kitty never render them at all by using `always`, if you don’t like them. The ligature strategy can be set per-window either using the kitty remote control facility or by defining shortcuts for it in `kitty.conf`, for example:

```conf
mapalt+1disable_ligatures_in active always
mapalt+2disable_ligatures_in all never
mapalt+3disable_ligatures_in tab cursor
```

Note that this refers to programming ligatures, typically implemented using the `calt` OpenType feature. For disabling general ligatures, use the [`font_features`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.font_features) option.

font\_features[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.font_features "Link to this definition")

Has no default values. Example values are shown below:

```conf
font_featuresnone
```

Choose exactly which OpenType features to enable or disable. Note that for the main fonts, features can be specified when selecting the font using the choose-fonts kitten. This setting is useful for fallback fonts.

Some fonts might have features worthwhile in a terminal. For example, Fira Code includes a discretionary feature, `zero`, which in that font changes the appearance of the zero (0), to make it more easily distinguishable from Ø. Fira Code also includes other discretionary features known as Stylistic Sets which have the tags `ss01` through `ss20`.

For the exact syntax to use for individual features, see the [HarfBuzz documentation](https://harfbuzz.github.io/harfbuzz-hb-common.html#hb-feature-from-string).

Note that this code is indexed by PostScript name, and not the font family. This allows you to define very precise feature settings; e.g. you can disable a feature in the italic font but not in the regular font.

On Linux, font features are first read from the FontConfig database and then this option is applied, so they can be configured in a single, central place.

To get the PostScript name for a font, use the `fc-scan file.ttf` command on Linux or the [Font Book tool on macOS](https://apple.stackexchange.com/questions/79875/how-can-i-get-the-postscript-name-of-a-ttf-font-installed-in-os-x).

Enable alternate zero and oldstyle numerals:

```conf
font_featuresFiraCode-Retina +zero +onum
```

Enable only alternate zero in the bold font:

```conf
font_featuresFiraCode-Bold +zero
```

Disable the normal ligatures, but keep the `calt` feature which (in this font) breaks up monotony:

```conf
font_featuresTT2020StyleB-Regular -liga +calt
```

In conjunction with [`force_ltr`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.force_ltr), you may want to disable Arabic shaping entirely, and only look at their isolated forms if they show up in a document. You can do this with e.g.:

```conf
font_featuresUnifontMedium +isol -medi -fina -init
```

modify\_font[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.modify_font "Link to this definition")

Modify font characteristics such as the position or thickness of the underline and strikethrough. The modifications can have the suffix `px` for pixels or `%` for percentage of original value. No suffix means use pts. For example:

```conf
modify_fontunderline_position -2
modify_fontunderline_thickness 150%
modify_fontstrikethrough_position 2px
```

Additionally, you can modify the size of the cell in which each font glyph is rendered and the baseline at which the glyph is placed in the cell. For example:

```conf
modify_fontcell_width 80%
modify_fontcell_height -2px
modify_fontbaseline 3
```

Note that modifying the baseline will automatically adjust the underline and strikethrough positions by the same amount. Increasing the baseline raises glyphs inside the cell and decreasing it lowers them. Decreasing the cell size might cause rendering artifacts, so use with care.

box\_drawing\_scale[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.box_drawing_scale "Link to this definition")

```conf
box_drawing_scale0.001, 1, 1.5, 2
```

The sizes of the lines used for the box drawing Unicode characters. These values are in pts. They will be scaled by the monitor DPI to arrive at a pixel value. There must be four values corresponding to thin, normal, thick, and very thick lines.

undercurl\_style[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.undercurl_style "Link to this definition")

```conf
undercurl_stylethin-sparse
```

The style with which undercurls are rendered. This option takes the form `(thin|thick)-(sparse|dense)`. Thin and thick control the thickness of the undercurl. Sparse and dense control how often the curl oscillates. With sparse the curl will peak once per character, with dense twice.

text\_composition\_strategy[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.text_composition_strategy "Link to this definition")

```conf
text_composition_strategyplatform
```

Control how kitty composites text glyphs onto the background color. The default value of `platform` tries for text rendering as close to “native” for the platform kitty is running on as possible.

A value of `legacy` uses the old (pre kitty 0.28) strategy for how glyphs are composited. This will make dark text on light backgrounds look thicker and light text on dark backgrounds thinner. It might also make some text appear like the strokes are uneven.

You can fine tune the actual contrast curve used for glyph composition by specifying up to two space-separated numbers for this setting.

The first number is the gamma adjustment, which controls the thickness of dark text on light backgrounds. Increasing the value will make text appear thicker. The default value for this is `1.0` on Linux and `1.7` on macOS. Valid values are `0.01` and above. The result is scaled based on the luminance difference between the background and the foreground. Dark text on light backgrounds receives the full impact of the curve while light text on dark backgrounds is affected very little.

The second number is an additional multiplicative contrast. It is percentage ranging from `0` to `100`. The default value is `0` on Linux and `30` on macOS.

If you wish to achieve similar looking thickness in light and dark themes, a good way to experiment is start by setting the value to `1.0 0` and use a dark theme. Then adjust the second parameter until it looks good. Then switch to a light theme and adjust the first parameter until the perceived thickness matches the dark theme.

text\_fg\_override\_threshold[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.text_fg_override_threshold "Link to this definition")

```conf
text_fg_override_threshold0
```

The minimum accepted difference in luminance between the foreground and background color, below which kitty will override the foreground color. It is percentage ranging from `0` to `100`. If the difference in luminance of the foreground and background is below this threshold, the foreground color will be set to white if the background is dark or black if the background is light. The default value is `0`, which means no overriding is performed. Useful when working with applications that use colors that do not contrast well with your preferred color scheme.

WARNING: Some programs use characters (such as block characters) for graphics display and may expect to be able to set the foreground and background to the same color (or similar colors). If you see unexpected stripes, dots, lines, incorrect color, no color where you expect color, or any kind of graphic display problem try setting [`text_fg_override_threshold`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.text_fg_override_threshold) to `0` to see if this is the cause of the problem.

## Text cursor customization¶

cursor[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.cursor "Link to this definition")

```conf
cursor#cccccc
```

Default text cursor color. If set to the special value `none` the cursor will be rendered with a “reverse video” effect. Its color will be the color of the text in the cell it is over and the text will be rendered with the background color of the cell. Note that if the program running in the terminal sets a cursor color, this takes precedence. Also, the cursor colors are modified if the cell background and foreground colors have very low contrast. Note that some themes set this value, so if you want to override it, place your value after the lines where the theme file is included.

cursor\_text\_color[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.cursor_text_color "Link to this definition")

```conf
cursor_text_color#111111
```

The color of text under the cursor. If you want it rendered with the background color of the cell underneath instead, use the special keyword: background. Note that if [`cursor`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.cursor) is set to `none` then this option is ignored. Note that some themes set this value, so if you want to override it, place your value after the lines where the theme file is included.

cursor\_shape[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.cursor_shape "Link to this definition")

```conf
cursor_shapeblock
```

The cursor shape can be one of `block`, `beam`, `underline`. Note that when reloading the config this will be changed only if the cursor shape has not been set by the program running in the terminal. This sets the default cursor shape, applications running in the terminal can override it. In particular, [shell integration](https://sw.kovidgoyal.net/kitty/shell-integration/#shell-integration) in kitty sets the cursor shape to `beam` at shell prompts. You can avoid this by setting [`shell_integration`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.shell_integration) to `no-cursor`.

cursor\_shape\_unfocused[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.cursor_shape_unfocused "Link to this definition")

```conf
cursor_shape_unfocusedhollow
```

Defines the text cursor shape when the OS window is not focused. The unfocused cursor shape can be one of `block`, `beam`, `underline`, `hollow` and `unchanged` (leave the cursor shape as it is).

cursor\_beam\_thickness[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.cursor_beam_thickness "Link to this definition")

```conf
cursor_beam_thickness1.5
```

The thickness of the beam cursor (in pts).

cursor\_underline\_thickness[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.cursor_underline_thickness "Link to this definition")

```conf
cursor_underline_thickness2.0
```

The thickness of the underline cursor (in pts).

cursor\_blink\_interval[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.cursor_blink_interval "Link to this definition")

```conf
cursor_blink_interval-1
```

The interval to blink the cursor (in seconds). Set to zero to disable blinking. Negative values mean use system default. Note that the minimum interval will be limited to [`repaint_delay`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.repaint_delay). You can also animate the cursor blink by specifying an [easing function](https://sw.kovidgoyal.net/kitty/glossary/#term-easing-function). For example, setting this to option to `0.5 ease-in-out` will cause the cursor blink to be animated over a second, in the first half of the second it will go from opaque to transparent and then back again over the next half. You can specify different easing functions for the two halves, for example: `-1 linear ease-out`. kitty supports all the [CSS easing functions](https://developer.mozilla.org/en-US/docs/Web/CSS/easing-function). Note that turning on animations uses extra power as it means the screen is redrawn multiple times per blink interval. See also, [`cursor_stop_blinking_after`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.cursor_stop_blinking_after).

cursor\_stop\_blinking\_after[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.cursor_stop_blinking_after "Link to this definition")

```conf
cursor_stop_blinking_after15.0
```

Stop blinking cursor after the specified number of seconds of keyboard inactivity. Set to zero to never stop blinking.

cursor\_trail[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.cursor_trail "Link to this definition")

```conf
cursor_trail0
```

Set this to a value larger than zero to enable a “cursor trail” animation. This is an animation that shows a “trail” following the movement of the text cursor. It makes it easy to follow large cursor jumps and makes for a cool visual effect of the cursor zooming around the screen. The actual value of this option controls when the animation is triggered. It is a number of milliseconds. The trail animation only follows cursors that have stayed in their position for longer than the specified number of milliseconds. This prevents trails from appearing for cursors that rapidly change their positions during UI updates in complex applications. See [`cursor_trail_decay`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.cursor_trail_decay) to control the animation speed and [`cursor_trail_start_threshold`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.cursor_trail_start_threshold) to control when a cursor trail is started.

cursor\_trail\_decay[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.cursor_trail_decay "Link to this definition")

```conf
cursor_trail_decay0.10.4
```

Controls the decay times for the cursor trail effect when the [`cursor_trail`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.cursor_trail) is enabled. This option accepts two positive float values specifying the fastest and slowest decay times in seconds. The first value corresponds to the fastest decay time (minimum), and the second value corresponds to the slowest decay time (maximum). The second value must be equal to or greater than the first value. Smaller values result in a faster decay of the cursor trail. Adjust these values to control how quickly the cursor trail fades away.

cursor\_trail\_start\_threshold[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.cursor_trail_start_threshold "Link to this definition")

```conf
cursor_trail_start_threshold2
```

Set the distance threshold for starting the cursor trail. This option accepts a positive integer value that represents the minimum number of cells the cursor must move before the trail is started. When the cursor moves less than this threshold, the trail is skipped, reducing unnecessary cursor trail animation.

## Scrollback¶

scrollback\_lines[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.scrollback_lines "Link to this definition")

```conf
scrollback_lines2000
```

Number of lines of history to keep in memory for scrolling back. Memory is allocated on demand. Negative numbers are (effectively) infinite scrollback. Note that using very large scrollback is not recommended as it can slow down performance of the terminal and also use large amounts of RAM. Instead, consider using [`scrollback_pager_history_size`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.scrollback_pager_history_size). Note that on config reload if this is changed it will only affect newly created windows, not existing ones.

scrollback\_indicator\_opacity[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.scrollback_indicator_opacity "Link to this definition")

```conf
scrollback_indicator_opacity1.0
```

The opacity of the scrollback indicator which is a small colored rectangle that moves along the right hand side of the window as you scroll, indicating what fraction you have scrolled. The default is one which means fully opaque, aka visible. Set to a value between zero and one to make the indicator less visible.

scrollback\_pager[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.scrollback_pager "Link to this definition")

```conf
scrollback_pagerless --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER
```

Program with which to view scrollback in a new window. The scrollback buffer is passed as STDIN to this program. If you change it, make sure the program you use can handle ANSI escape sequences for colors and text formatting. INPUT\_LINE\_NUMBER in the command line above will be replaced by an integer representing which line should be at the top of the screen. Similarly CURSOR\_LINE and CURSOR\_COLUMN will be replaced by the current cursor position or set to 0 if there is no cursor, for example, when showing the last command output.

scrollback\_pager\_history\_size[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.scrollback_pager_history_size "Link to this definition")

```conf
scrollback_pager_history_size0
```

Separate scrollback history size (in MB), used only for browsing the scrollback buffer with pager. This separate buffer is not available for interactive scrolling but will be piped to the pager program when viewing scrollback buffer in a separate window. The current implementation stores the data in UTF-8, so approximately 10000 lines per megabyte at 100 chars per line, for pure ASCII, unformatted text. A value of zero or less disables this feature. The maximum allowed size is 4GB. Note that on config reload if this is changed it will only affect newly created windows, not existing ones.

scrollback\_fill\_enlarged\_window[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.scrollback_fill_enlarged_window "Link to this definition")

```conf
scrollback_fill_enlarged_windowno
```

Fill new space with lines from the scrollback buffer after enlarging a window.

wheel\_scroll\_multiplier[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.wheel_scroll_multiplier "Link to this definition")

```conf
wheel_scroll_multiplier5.0
```

Multiplier for the number of lines scrolled by the mouse wheel. Note that this is only used for low precision scrolling devices, not for high precision scrolling devices on platforms such as macOS and Wayland. Use negative numbers to change scroll direction. See also [`wheel_scroll_min_lines`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.wheel_scroll_min_lines).

wheel\_scroll\_min\_lines[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.wheel_scroll_min_lines "Link to this definition")

```conf
wheel_scroll_min_lines1
```

The minimum number of lines scrolled by the mouse wheel. The [`scroll multiplier`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.wheel_scroll_multiplier) only takes effect after it reaches this number. Note that this is only used for low precision scrolling devices like wheel mice that scroll by very small amounts when using the wheel. With a negative number, the minimum number of lines will always be added.

touch\_scroll\_multiplier[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.touch_scroll_multiplier "Link to this definition")

```conf
touch_scroll_multiplier1.0
```

Multiplier for the number of lines scrolled by a touchpad. Note that this is only used for high precision scrolling devices on platforms such as macOS and Wayland. Use negative numbers to change scroll direction.

## Mouse¶

mouse\_hide\_wait[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.mouse_hide_wait "Link to this definition")

```conf
mouse_hide_wait3.0
```

Hide mouse cursor after the specified number of seconds of the mouse not being used. Set to zero to disable mouse cursor hiding. Set to a negative value to hide the mouse cursor immediately when typing text. Disabled by default on macOS as getting it to work robustly with the ever-changing sea of bugs that is Cocoa is too much effort.

url\_color, url\_style[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.url_color "Link to this definition")

```conf
url_color#0087bd
url_stylecurly
```

The color and style for highlighting URLs on mouse-over. [`url_style`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.url_color) can be one of: `none`, `straight`, `double`, `curly`, `dotted`, `dashed`.

open\_url\_with[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.open_url_with "Link to this definition")

```conf
open_url_withdefault
```

The program to open clicked URLs. The special value `default` will first look for any URL handlers defined via the [Scripting the mouse click](https://sw.kovidgoyal.net/kitty/open_actions/) facility and if non are found, it will use the Operating System’s default URL handler (**open** on macOS and **xdg-open** on Linux).

url\_prefixes[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.url_prefixes "Link to this definition")

```conf
url_prefixesfile ftp ftps gemini git gopher http https irc ircs kitty mailto news sftp ssh
```

The set of URL prefixes to look for when detecting a URL under the mouse cursor.

detect\_urls[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.detect_urls "Link to this definition")

```conf
detect_urlsyes
```

Detect URLs under the mouse. Detected URLs are highlighted with an underline and the mouse cursor becomes a hand over them. Even if this option is disabled, URLs are still clickable. See also the [`underline_hyperlinks`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.underline_hyperlinks) option to control how hyperlinks (as opposed to plain text URLs) are displayed.

url\_excluded\_characters[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.url_excluded_characters "Link to this definition")

Additional characters to be disallowed from URLs, when detecting URLs under the mouse cursor. By default, all characters that are legal in URLs are allowed. Additionally, newlines are allowed (but stripped). This is to accommodate programs such as mutt that add hard line breaks even for continued lines. `\n` can be added to this option to disable this behavior. Special characters can be specified using backslash escapes, to specify a backslash use a double backslash.

show\_hyperlink\_targets[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.show_hyperlink_targets "Link to this definition")

```conf
show_hyperlink_targetsno
```

When the mouse hovers over a terminal hyperlink, show the actual URL that will be activated when the hyperlink is clicked.

underline\_hyperlinks[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.underline_hyperlinks "Link to this definition")

```conf
underline_hyperlinkshover
```

Control how hyperlinks are underlined. They can either be underlined on mouse `hover`, `always` (i.e. permanently underlined) or `never` which means that kitty will not apply any underline styling to hyperlinks. Note that the value of `always` only applies to real (OSC 8) hyperlinks not text that is detected to be a URL on mouse hover. Uses the [`url_style`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.url_color) and [`url_color`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.url_color) settings for the underline style. Note that reloading the config and changing this value to/from `always` will only affect text subsequently received by kitty.

copy\_on\_select[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.copy_on_select "Link to this definition")

```conf
copy_on_selectno
```

Copy to clipboard or a private buffer on select. With this set to `clipboard`, selecting text with the mouse will cause the text to be copied to clipboard. Useful on platforms such as macOS that do not have the concept of primary selection. You can instead specify a name such as `a1` to copy to a private kitty buffer. Map a shortcut with the `paste_from_buffer` action to paste from this private buffer. For example:

```conf
copy_on_selecta1
mapshift+cmd+vpaste_from_buffer a1
```

Note that copying to the clipboard is a security risk, as all programs, including websites open in your browser can read the contents of the system clipboard.

paste\_actions[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.paste_actions "Link to this definition")

```conf
paste_actionsquote-urls-at-prompt,confirm
```

A comma separated list of actions to take when pasting text into the terminal. The supported paste actions are:

`quote-urls-at-prompt`:

If the text being pasted is a URL and the cursor is at a shell prompt, automatically quote the URL (needs [`shell_integration`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.shell_integration)).

`replace-dangerous-control-codes`

Replace dangerous control codes from pasted text, without confirmation.

`replace-newline`

Replace the newline character from pasted text, without confirmation.

`confirm`:

Confirm the paste if the text to be pasted contains any terminal control codes as this can be dangerous, leading to code execution if the shell/program running in the terminal does not properly handle these.

`confirm-if-large`

Confirm the paste if it is very large (larger than 16KB) as pasting large amounts of text into shells can be very slow.

`filter`:

Run the filter\_paste() function from the file `paste-actions.py` in the kitty config directory on the pasted text. The text returned by the function will be actually pasted.

`no-op`:

Has no effect.

strip\_trailing\_spaces[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.strip_trailing_spaces "Link to this definition")

```conf
strip_trailing_spacesnever
```

Remove spaces at the end of lines when copying to clipboard. A value of `smart` will do it when using normal selections, but not rectangle selections. A value of `always` will always do it.

select\_by\_word\_characters[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.select_by_word_characters "Link to this definition")

```conf
select_by_word_characters@-./_~?&=%+#
```

Characters considered part of a word when double clicking. In addition to these characters any character that is marked as an alphanumeric character in the Unicode database will be matched.

select\_by\_word\_characters\_forward[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.select_by_word_characters_forward "Link to this definition")

Characters considered part of a word when extending the selection forward on double clicking. In addition to these characters any character that is marked as an alphanumeric character in the Unicode database will be matched.

If empty (default) [`select_by_word_characters`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.select_by_word_characters) will be used for both directions.

click\_interval[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.click_interval "Link to this definition")

```conf
click_interval-1.0
```

The interval between successive clicks to detect double/triple clicks (in seconds). Negative numbers will use the system default instead, if available, or fallback to 0.5.

focus\_follows\_mouse[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.focus_follows_mouse "Link to this definition")

```conf
focus_follows_mouseno
```

Set the active window to the window under the mouse when moving the mouse around. On macOS, this will also cause the OS Window under the mouse to be focused automatically when the mouse enters it.

pointer\_shape\_when\_grabbed[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.pointer_shape_when_grabbed "Link to this definition")

```conf
pointer_shape_when_grabbedarrow
```

The shape of the mouse pointer when the program running in the terminal grabs the mouse.

default\_pointer\_shape[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.default_pointer_shape "Link to this definition")

```conf
default_pointer_shapebeam
```

The default shape of the mouse pointer.

pointer\_shape\_when\_dragging[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.pointer_shape_when_dragging "Link to this definition")

```conf
pointer_shape_when_draggingbeam
```

The default shape of the mouse pointer when dragging across text.

### Mouse actions¶

Mouse buttons can be mapped to perform arbitrary actions. The syntax is:

```none
mouse_map button-name event-type modes action
```

Where `button-name` is one of `left`, `middle`, `right`, `b1` … `b8` with added keyboard modifiers. For example: `ctrl+shift+left` refers to holding the Ctrl+Shift keys while clicking with the left mouse button. The value `b1` … `b8` can be used to refer to up to eight buttons on a mouse.

`event-type` is one of `press`, `release`, `doublepress`, `triplepress`, `click`, `doubleclick`. `modes` indicates whether the action is performed when the mouse is grabbed by the program running in the terminal, or not. The values are `grabbed` or `ungrabbed` or a comma separated combination of them. `grabbed` refers to when the program running in the terminal has requested mouse events. Note that the click and double click events have a delay of [`click_interval`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.click_interval) to disambiguate from double and triple presses.

You can run kitty with the [`kitty --debug-input`](https://sw.kovidgoyal.net/kitty/invocation/#cmdoption-kitty-debug-input) command line option to see mouse events. See the builtin actions below to get a sense of what is possible.

If you want to unmap a button, map it to nothing. For example, to disable opening of URLs with a plain click:

```conf
mouse_mapleftclickungrabbed
```

See all the mappable actions including mouse actions [here](https://sw.kovidgoyal.net/kitty/actions/).

Note

Once a selection is started, releasing the button that started it will automatically end it and no release event will be dispatched.

clear\_all\_mouse\_actions[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.clear_all_mouse_actions "Link to this definition")

```conf
clear_all_mouse_actionsno
```

Remove all mouse action definitions up to this point. Useful, for instance, to remove the default mouse actions.

Click the link under the mouse or move the cursor[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Click-the-link-under-the-mouse-or-move-the-cursor "Link to this definition")

```conf
mouse_mapleftclickungrabbedmouse_handle_clickselection link prompt
```

First check for a selection and if one exists do nothing. Then check for a link under the mouse cursor and if one exists, click it. Finally check if the click happened at the current shell prompt and if so, move the cursor to the click location. Note that this requires [shell integration](https://sw.kovidgoyal.net/kitty/shell-integration/#shell-integration) to work.

Click the link under the mouse or move the cursor even when grabbed[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Click-the-link-under-the-mouse-or-move-the-cursor-even-when-grabbed "Link to this definition")

```conf
mouse_mapshift+leftclickgrabbed,ungrabbedmouse_handle_clickselection link prompt
```

Same as above, except that the action is performed even when the mouse is grabbed by the program running in the terminal.

Click the link under the mouse cursor[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Click-the-link-under-the-mouse-cursor "Link to this definition")

```conf
mouse_mapctrl+shift+leftreleasegrabbed,ungrabbedmouse_handle_clicklink
```

Variant with Ctrl+Shift is present because the simple click based version has an unavoidable delay of [`click_interval`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.click_interval), to disambiguate clicks from double clicks.

Discard press event for link click[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Discard-press-event-for-link-click "Link to this definition")

```conf
mouse_mapctrl+shift+leftpressgrabbeddiscard_event
```

Prevent this press event from being sent to the program that has grabbed the mouse, as the corresponding release event is used to open a URL.

Paste from the primary selection[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Paste-from-the-primary-selection "Link to this definition")

```conf
mouse_mapmiddlereleaseungrabbedpaste_from_selection
```

Start selecting text[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Start-selecting-text "Link to this definition")

```conf
mouse_mapleftpressungrabbedmouse_selectionnormal
```

Start selecting text in a rectangle[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Start-selecting-text-in-a-rectangle "Link to this definition")

```conf
mouse_mapctrl+alt+leftpressungrabbedmouse_selectionrectangle
```

Select a word[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Select-a-word "Link to this definition")

```conf
mouse_mapleftdoublepressungrabbedmouse_selectionword
```

Select a line[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Select-a-line "Link to this definition")

```conf
mouse_maplefttriplepressungrabbedmouse_selectionline
```

Select line from point[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Select-line-from-point "Link to this definition")

```conf
mouse_mapctrl+alt+lefttriplepressungrabbedmouse_selectionline_from_point
```

Select from the clicked point to the end of the line. If you would like to select the word at the point and then extend to the rest of the line, change line\_from\_point to word\_and\_line\_from\_point.

Extend the current selection[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Extend-the-current-selection "Link to this definition")

```conf
mouse_maprightpressungrabbedmouse_selectionextend
```

If you want only the end of the selection to be moved instead of the nearest boundary, use `move-end` instead of `extend`.

Paste from the primary selection even when grabbed[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Paste-from-the-primary-selection-even-when-grabbed "Link to this definition")

```conf
mouse_mapshift+middlereleaseungrabbed,grabbedpaste_selection
mouse_mapshift+middlepressgrabbeddiscard_event
```

Start selecting text even when grabbed[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Start-selecting-text-even-when-grabbed "Link to this definition")

```conf
mouse_mapshift+leftpressungrabbed,grabbedmouse_selectionnormal
```

Start selecting text in a rectangle even when grabbed[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Start-selecting-text-in-a-rectangle-even-when-grabbed "Link to this definition")

```conf
mouse_mapctrl+shift+alt+leftpressungrabbed,grabbedmouse_selectionrectangle
```

Select a word even when grabbed[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Select-a-word-even-when-grabbed "Link to this definition")

```conf
mouse_mapshift+leftdoublepressungrabbed,grabbedmouse_selectionword
```

Select a line even when grabbed[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Select-a-line-even-when-grabbed "Link to this definition")

```conf
mouse_mapshift+lefttriplepressungrabbed,grabbedmouse_selectionline
```

Select line from point even when grabbed[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Select-line-from-point-even-when-grabbed "Link to this definition")

```conf
mouse_mapctrl+shift+alt+lefttriplepressungrabbed,grabbedmouse_selectionline_from_point
```

Select from the clicked point to the end of the line even when grabbed. If you would like to select the word at the point and then extend to the rest of the line, change line\_from\_point to word\_and\_line\_from\_point.

Extend the current selection even when grabbed[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Extend-the-current-selection-even-when-grabbed "Link to this definition")

```conf
mouse_mapshift+rightpressungrabbed,grabbedmouse_selectionextend
```

Show clicked command output in pager[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Show-clicked-command-output-in-pager "Link to this definition")

```conf
mouse_mapctrl+shift+rightpressungrabbedmouse_show_command_output
```

Requires [shell integration](https://sw.kovidgoyal.net/kitty/shell-integration/#shell-integration) to work.

## Performance tuning¶

repaint\_delay[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.repaint_delay "Link to this definition")

```conf
repaint_delay10
```

Delay between screen updates (in milliseconds). Decreasing it, increases frames-per-second (FPS) at the cost of more CPU usage. The default value yields ~100 FPS which is more than sufficient for most uses. Note that to actually achieve 100 FPS, you have to either set [`sync_to_monitor`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.sync_to_monitor) to `no` or use a monitor with a high refresh rate. Also, to minimize latency when there is pending input to be processed, this option is ignored.

input\_delay[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.input_delay "Link to this definition")

```conf
input_delay3
```

Delay before input from the program running in the terminal is processed (in milliseconds). Note that decreasing it will increase responsiveness, but also increase CPU usage and might cause flicker in full screen programs that redraw the entire screen on each loop, because kitty is so fast that partial screen updates will be drawn. This setting is ignored when the input buffer is almost full.

sync\_to\_monitor[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.sync_to_monitor "Link to this definition")

```conf
sync_to_monitoryes
```

Sync screen updates to the refresh rate of the monitor. This prevents [screen tearing](https://en.wikipedia.org/wiki/Screen_tearing) when scrolling. However, it limits the rendering speed to the refresh rate of your monitor. With a very high speed mouse/high keyboard repeat rate, you may notice some slight input latency. If so, set this to `no`.

## Terminal bell¶

enable\_audio\_bell[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.enable_audio_bell "Link to this definition")

```conf
enable_audio_bellyes
```

The audio bell. Useful to disable it in environments that require silence.

visual\_bell\_duration[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.visual_bell_duration "Link to this definition")

```conf
visual_bell_duration0.0
```

The visual bell duration (in seconds). Flash the screen when a bell occurs for the specified number of seconds. Set to zero to disable. The flash is animated, fading in and out over the specified duration. The [easing function](https://sw.kovidgoyal.net/kitty/glossary/#term-easing-function) used for the fading can be controlled. For example, `2.0 linear` will casuse the flash to fade in and out linearly. The default if unspecified is to use `ease-in-out` which fades slowly at the start, middle and end. You can specify different easing functions for the fade-in and fade-out parts, like this: `2.0 ease-in linear`. kitty supports all the [CSS easing functions](https://developer.mozilla.org/en-US/docs/Web/CSS/easing-function).

visual\_bell\_color[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.visual_bell_color "Link to this definition")

```conf
visual_bell_colornone
```

The color used by visual bell. Set to `none` will fall back to selection background color. If you feel that the visual bell is too bright, you can set it to a darker color.

window\_alert\_on\_bell[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.window_alert_on_bell "Link to this definition")

```conf
window_alert_on_bellyes
```

Request window attention on bell. Makes the dock icon bounce on macOS or the taskbar flash on Linux.

bell\_on\_tab[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.bell_on_tab "Link to this definition")

```conf
bell_on_tab"🔔 "
```

Some text or a Unicode symbol to show on the tab if a window in the tab that does not have focus has a bell. If you want to use leading or trailing spaces, surround the text with quotes. See [`tab_title_template`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.tab_title_template) for how this is rendered.

For backwards compatibility, values of `yes`, `y` and `true` are converted to the default bell symbol and `no`, `n`, `false` and `none` are converted to the empty string.

command\_on\_bell[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.command_on_bell "Link to this definition")

```conf
command_on_bellnone
```

Program to run when a bell occurs. The environment variable [`KITTY_CHILD_CMDLINE`](https://sw.kovidgoyal.net/kitty/glossary/#envvar-KITTY_CHILD_CMDLINE) can be used to get the program running in the window in which the bell occurred.

bell\_path[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.bell_path "Link to this definition")

```conf
bell_pathnone
```

Path to a sound file to play as the bell sound. If set to `none`, the system default bell sound is used. Must be in a format supported by the operating systems sound API, such as WAV or OGA on Linux (libcanberra) or AIFF, MP3 or WAV on macOS (NSSound).

linux\_bell\_theme[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.linux_bell_theme "Link to this definition")

```conf
linux_bell_theme__custom
```

The XDG Sound Theme kitty will use to play the bell sound. Defaults to the custom theme name specified in the [XDG Sound theme specification](https://specifications.freedesktop.org/sound-theme-spec/latest/sound_lookup.html) with the contents:

> \[Sound Theme\]
>
> Inherits=name-of-the-sound-theme-you-want-to-use

Replace `name-of-the-sound-theme-you-want-to-use` with the actual theme name. Now all compliant applications should use sounds from this theme.

## Window layout¶

remember\_window\_size, initial\_window\_width, initial\_window\_height[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.remember_window_size "Link to this definition")

```conf
remember_window_sizeyes
initial_window_width640
initial_window_height400
```

If enabled, the [OS Window](https://sw.kovidgoyal.net/kitty/glossary/#term-os_window) size will be remembered so that new instances of kitty will have the same size as the previous instance. If disabled, the [OS Window](https://sw.kovidgoyal.net/kitty/glossary/#term-os_window) will initially have size configured by initial\_window\_width/height, in pixels. You can use a suffix of “c” on the width/height values to have them interpreted as number of cells instead of pixels.

enabled\_layouts[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.enabled_layouts "Link to this definition")

```conf
enabled_layouts*
```

The enabled window layouts. A comma separated list of layout names. The special value `all` means all layouts. The first listed layout will be used as the startup layout. Default configuration is all layouts in alphabetical order. For a list of available layouts, see the [Layouts](https://sw.kovidgoyal.net/kitty/overview/#layouts).

window\_resize\_step\_cells, window\_resize\_step\_lines[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.window_resize_step_cells "Link to this definition")

```conf
window_resize_step_cells2
window_resize_step_lines2
```

The step size (in units of cell width/cell height) to use when resizing kitty windows in a layout with the shortcut [`ctrl+shift+r`](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Start-resizing-window). The cells value is used for horizontal resizing, and the lines value is used for vertical resizing.

window\_border\_width[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.window_border_width "Link to this definition")

```conf
window_border_width0.5pt
```

The width of window borders. Can be either in pixels (px) or pts (pt). Values in pts will be rounded to the nearest number of pixels based on screen resolution. If not specified, the unit is assumed to be pts. Note that borders are displayed only when more than one window is visible. They are meant to separate multiple windows.

draw\_minimal\_borders[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.draw_minimal_borders "Link to this definition")

```conf
draw_minimal_bordersyes
```

Draw only the minimum borders needed. This means that only the borders that separate the window from a neighbor are drawn. Note that setting a non-zero [`window_margin_width`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.window_margin_width) overrides this and causes all borders to be drawn.

window\_margin\_width[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.window_margin_width "Link to this definition")

```conf
window_margin_width0
```

The window margin (in pts) (blank area outside the border). A single value sets all four sides. Two values set the vertical and horizontal sides. Three values set top, horizontal and bottom. Four values set top, right, bottom and left.

single\_window\_margin\_width[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.single_window_margin_width "Link to this definition")

```conf
single_window_margin_width-1
```

The window margin to use when only a single window is visible (in pts). Negative values will cause the value of [`window_margin_width`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.window_margin_width) to be used instead. A single value sets all four sides. Two values set the vertical and horizontal sides. Three values set top, horizontal and bottom. Four values set top, right, bottom and left.

window\_padding\_width[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.window_padding_width "Link to this definition")

```conf
window_padding_width0
```

The window padding (in pts) (blank area between the text and the window border). A single value sets all four sides. Two values set the vertical and horizontal sides. Three values set top, horizontal and bottom. Four values set top, right, bottom and left.

single\_window\_padding\_width[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.single_window_padding_width "Link to this definition")

```conf
single_window_padding_width-1
```

The window padding to use when only a single window is visible (in pts). Negative values will cause the value of [`window_padding_width`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.window_padding_width) to be used instead. A single value sets all four sides. Two values set the vertical and horizontal sides. Three values set top, horizontal and bottom. Four values set top, right, bottom and left.

placement\_strategy[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.placement_strategy "Link to this definition")

```conf
placement_strategycenter
```

When the window size is not an exact multiple of the cell size, the cell area of the terminal window will have some extra padding on the sides. You can control how that padding is distributed with this option. Using a value of `center` means the cell area will be placed centrally. A value of `top-left` means the padding will be only at the bottom and right edges. The value can be one of: `top-left`, `top`, `top-right`, `left`, `center`, `right`, `bottom-left`, `bottom`, `bottom-right`.

active\_border\_color[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.active_border_color "Link to this definition")

```conf
active_border_color#00ff00
```

The color for the border of the active window. Set this to `none` to not draw borders around the active window.

inactive\_border\_color[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.inactive_border_color "Link to this definition")

```conf
inactive_border_color#cccccc
```

The color for the border of inactive windows.

bell\_border\_color[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.bell_border_color "Link to this definition")

```conf
bell_border_color#ff5a00
```

The color for the border of inactive windows in which a bell has occurred.

inactive\_text\_alpha[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.inactive_text_alpha "Link to this definition")

```conf
inactive_text_alpha1.0
```

Fade the text in inactive windows by the specified amount (a number between zero and one, with zero being fully faded).

hide\_window\_decorations[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.hide_window_decorations "Link to this definition")

```conf
hide_window_decorationsno
```

Hide the window decorations (title-bar and window borders) with `yes`. On macOS, `titlebar-only` and `titlebar-and-corners` can be used to only hide the titlebar and the rounded corners. Whether this works and exactly what effect it has depends on the window manager/operating system. Note that the effects of changing this option when reloading config are undefined. When using `titlebar-only`, it is useful to also set [`window_margin_width`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.window_margin_width) and [`placement_strategy`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.placement_strategy) to prevent the rounded corners from clipping text. Or use `titlebar-and-corners`.

window\_logo\_path[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.window_logo_path "Link to this definition")

```conf
window_logo_pathnone
```

Path to a logo image. Must be in PNG/JPEG/WEBP/GIF/TIFF/BMP format. Relative paths are interpreted relative to the kitty config directory. The logo is displayed in a corner of every kitty window. The position is controlled by [`window_logo_position`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.window_logo_position). Individual windows can be configured to have different logos either using the [`launch`](https://sw.kovidgoyal.net/kitty/actions/#action-launch) action or the [remote control](https://sw.kovidgoyal.net/kitty/remote-control/) facility.

window\_logo\_position[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.window_logo_position "Link to this definition")

```conf
window_logo_positionbottom-right
```

Where to position the window logo in the window. The value can be one of: `top-left`, `top`, `top-right`, `left`, `center`, `right`, `bottom-left`, `bottom`, `bottom-right`.

window\_logo\_alpha[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.window_logo_alpha "Link to this definition")

```conf
window_logo_alpha0.5
```

The amount the logo should be faded into the background. With zero being fully faded and one being fully opaque.

window\_logo\_scale[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.window_logo_scale "Link to this definition")

```conf
window_logo_scale0
```

The percentage (0-100\] of the window size to which the logo should scale. Using a single number means the logo is scaled to that percentage of the shortest window dimension, while preserving aspect ratio of the logo image.

Using two numbers means the width and height of the logo are scaled to the respective percentage of the window’s width and height.

Using zero as the percentage disables scaling in that dimension. A single zero (the default) disables all scaling of the window logo.

resize\_debounce\_time[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.resize_debounce_time "Link to this definition")

```conf
resize_debounce_time0.10.5
```

The time to wait (in seconds) before asking the program running in kitty to resize and redraw the screen during a live resize of the OS window, when no new resize events have been received, i.e. when resizing is either paused or finished. On platforms such as macOS, where the operating system sends events corresponding to the start and end of a live resize, the second number is used for redraw-after-pause since kitty can distinguish between a pause and end of resizing. On such systems the first number is ignored and redraw is immediate after end of resize. On other systems only the first number is used so that kitty is “ready” quickly after the end of resizing, while not also continuously redrawing, to save energy.

resize\_in\_steps[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.resize_in_steps "Link to this definition")

```conf
resize_in_stepsno
```

Resize the OS window in steps as large as the cells, instead of with the usual pixel accuracy. Combined with [`initial_window_width`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.remember_window_size) and [`initial_window_height`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.remember_window_size) in number of cells, this option can be used to keep the margins as small as possible when resizing the OS window. Note that this does not currently work on Wayland.

visual\_window\_select\_characters[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.visual_window_select_characters "Link to this definition")

```conf
visual_window_select_characters1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ
```

The list of characters for visual window selection. For example, for selecting a window to focus on with [`ctrl+shift+f7`](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Visually-select-and-focus-window). The value should be a series of unique numbers or alphabets, case insensitive, from the set ``0-9A-Z`-=[];',./\``. Specify your preference as a string of characters.

confirm\_os\_window\_close[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.confirm_os_window_close "Link to this definition")

```conf
confirm_os_window_close-1
```

Ask for confirmation when closing an OS window or a tab with at least this number of kitty windows in it by window manager (e.g. clicking the window close button or pressing the operating system shortcut to close windows) or by the [`close_tab`](https://sw.kovidgoyal.net/kitty/actions/#action-close_tab) action. A value of zero disables confirmation. This confirmation also applies to requests to quit the entire application (all OS windows, via the [`quit`](https://sw.kovidgoyal.net/kitty/actions/#action-quit) action). Negative values are converted to positive ones, however, with [`shell_integration`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.shell_integration) enabled, using negative values means windows sitting at a shell prompt are not counted, only windows where some command is currently running. Note that if you want confirmation when closing individual windows, you can map the [`close_window_with_confirmation`](https://sw.kovidgoyal.net/kitty/actions/#action-close_window_with_confirmation) action.

## Tab bar¶

tab\_bar\_edge[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.tab_bar_edge "Link to this definition")

```conf
tab_bar_edgebottom
```

The edge to show the tab bar on, `top` or `bottom`.

tab\_bar\_margin\_width[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.tab_bar_margin_width "Link to this definition")

```conf
tab_bar_margin_width0.0
```

The margin to the left and right of the tab bar (in pts).

tab\_bar\_margin\_height[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.tab_bar_margin_height "Link to this definition")

```conf
tab_bar_margin_height0.00.0
```

The margin above and below the tab bar (in pts). The first number is the margin between the edge of the OS Window and the tab bar. The second number is the margin between the tab bar and the contents of the current tab.

tab\_bar\_style[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.tab_bar_style "Link to this definition")

```conf
tab_bar_stylefade
```

The tab bar style, can be one of:

`fade`

Each tab’s edges fade into the background color. (See also [`tab_fade`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.tab_fade))

`slant`

Tabs look like the tabs in a physical file.

`separator`

Tabs are separated by a configurable separator. (See also [`tab_separator`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.tab_separator))

`powerline`

Tabs are shown as a continuous line with “fancy” separators. (See also [`tab_powerline_style`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.tab_powerline_style))

`custom`

A user-supplied Python function called draw\_tab is loaded from the file `tab_bar.py` in the kitty config directory. For examples of how to write such a function, see the functions named `draw_tab_with_*` in kitty’s source code: `kitty/tab_bar.py`. See also [this discussion](https://github.com/kovidgoyal/kitty/discussions/4447) for examples from kitty users.

`hidden`

The tab bar is hidden. If you use this, you might want to create a mapping for the [`select_tab`](https://sw.kovidgoyal.net/kitty/actions/#action-select_tab) action which presents you with a list of tabs and allows for easy switching to a tab.

tab\_bar\_align[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.tab_bar_align "Link to this definition")

```conf
tab_bar_alignleft
```

The horizontal alignment of the tab bar, can be one of: `left`, `center`, `right`.

tab\_bar\_min\_tabs[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.tab_bar_min_tabs "Link to this definition")

```conf
tab_bar_min_tabs2
```

The minimum number of tabs that must exist before the tab bar is shown.

tab\_switch\_strategy[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.tab_switch_strategy "Link to this definition")

```conf
tab_switch_strategyprevious
```

The algorithm to use when switching to a tab when the current tab is closed. The default of `previous` will switch to the last used tab. A value of `left` will switch to the tab to the left of the closed tab. A value of `right` will switch to the tab to the right of the closed tab. A value of `last` will switch to the right-most tab.

tab\_fade[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.tab_fade "Link to this definition")

```conf
tab_fade0.250.50.751
```

Control how each tab fades into the background when using `fade` for the [`tab_bar_style`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.tab_bar_style). Each number is an alpha (between zero and one) that controls how much the corresponding cell fades into the background, with zero being no fade and one being full fade. You can change the number of cells used by adding/removing entries to this list.

tab\_separator[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.tab_separator "Link to this definition")

```conf
tab_separator" ┇"
```

The separator between tabs in the tab bar when using `separator` as the [`tab_bar_style`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.tab_bar_style).

tab\_powerline\_style[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.tab_powerline_style "Link to this definition")

```conf
tab_powerline_styleangled
```

The powerline separator style between tabs in the tab bar when using `powerline` as the [`tab_bar_style`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.tab_bar_style), can be one of: `angled`, `slanted`, `round`.

tab\_activity\_symbol[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.tab_activity_symbol "Link to this definition")

```conf
tab_activity_symbolnone
```

Some text or a Unicode symbol to show on the tab if a window in the tab that does not have focus has some activity. If you want to use leading or trailing spaces, surround the text with quotes. See [`tab_title_template`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.tab_title_template) for how this is rendered.

tab\_title\_max\_length[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.tab_title_max_length "Link to this definition")

```conf
tab_title_max_length0
```

The maximum number of cells that can be used to render the text in a tab. A value of zero means that no limit is applied.

tab\_title\_template[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.tab_title_template "Link to this definition")

```conf
tab_title_template"{fmt.fg.red}{bell_symbol}{activity_symbol}{fmt.fg.tab}{tab.last_focused_progress_percent}{title}"
```

A template to render the tab title. The default just renders the title with optional symbols for bell and activity. If you wish to include the tab-index as well, use something like: `{index}:{title}`. Useful if you have shortcuts mapped for `goto_tab N`. If you prefer to see the index as a superscript, use `{sup.index}`. All data available is:

`title`

The current tab title.

`index`

The tab index usable with [`goto_tab N`](https://sw.kovidgoyal.net/kitty/actions/#action-goto_tab) shortcuts.

`layout_name`

The current layout name.

`num_windows`

The number of windows in the tab.

`num_window_groups`

The number of window groups (a window group is a window and all of its overlay windows) in the tab.

`tab.active_wd`

The working directory of the currently active window in the tab (expensive, requires syscall). Use `tab.active_oldest_wd` to get the directory of the oldest foreground process rather than the newest.

`tab.active_exe`

The name of the executable running in the foreground of the currently active window in the tab (expensive, requires syscall). Use `tab.active_oldest_exe` for the oldest foreground process.

`max_title_length`

The maximum title length available.

`keyboard_mode`

The name of the current [keyboard mode](https://sw.kovidgoyal.net/kitty/mapping/#modal-mappings) or the empty string if no keyboard mode is active.

`tab.last_focused_progress_percent`

If a command running in a window reports the progress for a task, show this progress as a percentage from the most recently focused window in the tab. Empty string if no progress is reported.

`tab.progress_percent`

If a command running in a window reports the progress for a task, show this progress as a percentage from all windows in the tab, averaged. Empty string is no progress is reported.

Note that formatting is done by Python’s string formatting machinery, so you can use, for instance, `{layout_name[:2].upper()}` to show only the first two letters of the layout name, upper-cased. If you want to style the text, you can use styling directives, for example: `{fmt.fg.red}red{fmt.fg.tab}normal{fmt.bg._00FF00}greenbg{fmt.bg.tab}`. Similarly, for bold and italic: `{fmt.bold}bold{fmt.nobold}normal{fmt.italic}italic{fmt.noitalic}`. The 256 eight terminal colors can be used as `fmt.fg.color0` through `fmt.fg.color255`. Note that for backward compatibility, if `{bell_symbol}` or `{activity_symbol}` are not present in the template, they are prepended to it.

active\_tab\_title\_template[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.active_tab_title_template "Link to this definition")

```conf
active_tab_title_templatenone
```

Template to use for active tabs. If not specified falls back to [`tab_title_template`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.tab_title_template).

active\_tab\_foreground, active\_tab\_background, active\_tab\_font\_style, inactive\_tab\_foreground, inactive\_tab\_background, inactive\_tab\_font\_style[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.active_tab_foreground "Link to this definition")

```conf
active_tab_foreground#000
active_tab_background#eee
active_tab_font_stylebold-italic
inactive_tab_foreground#444
inactive_tab_background#999
inactive_tab_font_stylenormal
```

Tab bar colors and styles.

tab\_bar\_background[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.tab_bar_background "Link to this definition")

```conf
tab_bar_backgroundnone
```

Background color for the tab bar. Defaults to using the terminal background color.

tab\_bar\_margin\_color[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.tab_bar_margin_color "Link to this definition")

```conf
tab_bar_margin_colornone
```

Color for the tab bar margin area. Defaults to using the terminal background color for margins above and below the tab bar. For side margins the default color is chosen to match the background color of the neighboring tab.

## Color scheme¶

foreground, background[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.foreground "Link to this definition")

```conf
foreground#dddddd
background#000000
```

The foreground and background colors.

background\_opacity[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.background_opacity "Link to this definition")

```conf
background_opacity1.0
```

The opacity of the background. A number between zero and one, where one is opaque and zero is fully transparent. This will only work if supported by the OS (for instance, when using a compositor under X11). Note that it only sets the background color’s opacity in cells that have the same background color as the default terminal background, so that things like the status bar in vim, powerline prompts, etc. still look good. But it means that if you use a color theme with a background color in your editor, it will not be rendered as transparent. Instead you should change the default background color in your kitty config and not use a background color in the editor color scheme. Or use the escape codes to set the terminals default colors in a shell script to launch your editor. See also [`transparent_background_colors`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.transparent_background_colors). Be aware that using a value less than 1.0 is a (possibly significant) performance hit. When using a low value for this setting, it is desirable that you set the [`background`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.foreground) color to a color the matches the general color of the desktop background, for best text rendering. If you want to dynamically change transparency of windows, set [`dynamic_background_opacity`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.dynamic_background_opacity) to `yes` (this is off by default as it has a performance cost). Changing this option when reloading the config will only work if [`dynamic_background_opacity`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.dynamic_background_opacity) was enabled in the original config.

background\_blur[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.background_blur "Link to this definition")

```conf
background_blur0
```

Set to a positive value to enable background blur (blurring of the visuals behind a transparent window) on platforms that support it. Only takes effect when [`background_opacity`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.background_opacity) is less than one. On macOS, this will also control the blur radius (amount of blurring). Setting it to too high a value will cause severe performance issues and/or rendering artifacts. Usually, values up to 64 work well. Note that this might cause performance issues, depending on how the platform implements it, so use with care. Currently supported on macOS and KDE.

background\_image[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.background_image "Link to this definition")

```conf
background_imagenone
```

Path to a background image. Must be in PNG/JPEG/WEBP/TIFF/GIF/BMP format.

background\_image\_layout[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.background_image_layout "Link to this definition")

```conf
background_image_layouttiled
```

Whether to tile, scale or clamp the background image. The value can be one of `tiled`, `mirror-tiled`, `scaled`, `clamped`, `centered` or `cscaled`. The `scaled` and `cscaled` values scale the image to the window size, with `cscaled` preserving the image aspect ratio.

background\_image\_linear[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.background_image_linear "Link to this definition")

```conf
background_image_linearno
```

When background image is scaled, whether linear interpolation should be used.

transparent\_background\_colors[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.transparent_background_colors "Link to this definition")

A space separated list of upto 7 colors, with opacity. When the background color of a cell matches one of these colors, it is rendered semi-transparent using the specified opacity.

Useful in more complex UIs like editors where you could want more than a single background color to be rendered as transparent, for instance, for a cursor highlight line background or a highlighted block. Terminal applications can set this color using [The kitty color control](https://sw.kovidgoyal.net/kitty/color-stack/#id1) escape code.

The syntax for specifying colors is: `color@opacity`, where the `@opacity` part is optional. When unspecified, the value of [`background_opacity`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.background_opacity) is used. For example:

```conf
transparent_background_colorsred@0.5 #00ff00@0.3
```

dynamic\_background\_opacity[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.dynamic_background_opacity "Link to this definition")

```conf
dynamic_background_opacityno
```

Allow changing of the [`background_opacity`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.background_opacity) dynamically, using either keyboard shortcuts ([`ctrl+shift+a>m`](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Increase-background-opacity) and [`ctrl+shift+a>l`](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Decrease-background-opacity)) or the remote control facility. Changing this option by reloading the config is not supported.

background\_tint[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.background_tint "Link to this definition")

```conf
background_tint0.0
```

How much to tint the background image by the background color. This option makes it easier to read the text. Tinting is done using the current background color for each window. This option applies only if [`background_opacity`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.background_opacity) is set and transparent windows are supported or [`background_image`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.background_image) is set.

background\_tint\_gaps[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.background_tint_gaps "Link to this definition")

```conf
background_tint_gaps1.0
```

How much to tint the background image at the window gaps by the background color, after applying [`background_tint`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.background_tint). Since this is multiplicative with [`background_tint`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.background_tint), it can be used to lighten the tint over the window gaps for a *separated* look.

dim\_opacity[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.dim_opacity "Link to this definition")

```conf
dim_opacity0.4
```

How much to dim text that has the DIM/FAINT attribute set. One means no dimming and zero means fully dimmed (i.e. invisible).

selection\_foreground, selection\_background[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.selection_foreground "Link to this definition")

```conf
selection_foreground#000000
selection_background#fffacd
```

The foreground and background colors for text selected with the mouse. Setting both of these to `none` will cause a “reverse video” effect for selections, where the selection will be the cell text color and the text will become the cell background color. Setting only selection\_foreground to `none` will cause the foreground color to be used unchanged. Note that these colors can be overridden by the program running in the terminal.

### The color table¶

The 256 terminal colors. There are 8 basic colors, each color has a dull and bright version, for the first 16 colors. You can set the remaining 240 colors as color16 to color255.

color0, color8[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.color0 "Link to this definition")

```conf
color0#000000
color8#767676
```

black

color1, color9[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.color1 "Link to this definition")

```conf
color1#cc0403
color9#f2201f
```

red

color2, color10[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.color2 "Link to this definition")

```conf
color2#19cb00
color10#23fd00
```

green

color3, color11[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.color3 "Link to this definition")

```conf
color3#cecb00
color11#fffd00
```

yellow

color4, color12[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.color4 "Link to this definition")

```conf
color4#0d73cc
color12#1a8fff
```

blue

color5, color13[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.color5 "Link to this definition")

```conf
color5#cb1ed1
color13#fd28ff
```

magenta

color6, color14[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.color6 "Link to this definition")

```conf
color6#0dcdcd
color14#14ffff
```

cyan

color7, color15[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.color7 "Link to this definition")

```conf
color7#dddddd
color15#ffffff
```

white

mark1\_foreground[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.mark1_foreground "Link to this definition")

```conf
mark1_foregroundblack
```

Color for marks of type 1

mark1\_background[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.mark1_background "Link to this definition")

```conf
mark1_background#98d3cb
```

Color for marks of type 1 (light steel blue)

mark2\_foreground[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.mark2_foreground "Link to this definition")

```conf
mark2_foregroundblack
```

Color for marks of type 2

mark2\_background[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.mark2_background "Link to this definition")

```conf
mark2_background#f2dcd3
```

Color for marks of type 1 (beige)

mark3\_foreground[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.mark3_foreground "Link to this definition")

```conf
mark3_foregroundblack
```

Color for marks of type 3

mark3\_background[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.mark3_background "Link to this definition")

```conf
mark3_background#f274bc
```

Color for marks of type 3 (violet)

## Advanced¶

shell[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.shell "Link to this definition")

```conf
shell.
```

The shell program to execute. The default value of `.` means to use the value of of the [`SHELL`](https://sw.kovidgoyal.net/kitty/glossary/#envvar-SHELL) environment variable or if unset, whatever shell is set as the default shell for the current user. Note that on macOS if you change this, you might need to add `--login` and `--interactive` to ensure that the shell starts in interactive mode and reads its startup rc files. Environment variables are expanded in this setting.

editor[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.editor "Link to this definition")

```conf
editor.
```

The terminal based text editor (such as **vim** or **nano**) to use when editing the kitty config file or similar tasks.

The default value of `.` means to use the environment variables [`VISUAL`](https://sw.kovidgoyal.net/kitty/glossary/#envvar-VISUAL) and [`EDITOR`](https://sw.kovidgoyal.net/kitty/glossary/#envvar-EDITOR) in that order. If these variables aren’t set, kitty will run your [`shell`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.shell) (`$SHELL -l -i -c env`) to see if your shell startup rc files set [`VISUAL`](https://sw.kovidgoyal.net/kitty/glossary/#envvar-VISUAL) or [`EDITOR`](https://sw.kovidgoyal.net/kitty/glossary/#envvar-EDITOR). If that doesn’t work, kitty will cycle through various known editors (**vim**, **emacs**, etc.) and take the first one that exists on your system.

close\_on\_child\_death[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.close_on_child_death "Link to this definition")

```conf
close_on_child_deathno
```

Close the window when the child process (usually the shell) exits. With the default value `no`, the terminal will remain open when the child exits as long as there are still other processes outputting to the terminal (for example disowned or backgrounded processes). When enabled with `yes`, the window will close as soon as the child process exits. Note that setting it to `yes` means that any background processes still using the terminal can fail silently because their stdout/stderr/stdin no longer work.

remote\_control\_password[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.remote_control_password "Link to this definition")

Allow other programs to control kitty using passwords. This option can be specified multiple times to add multiple passwords. If no passwords are present kitty will ask the user for permission if a program tries to use remote control with a password. A password can also *optionally* be associated with a set of allowed remote control actions. For example:

```conf
remote_control_password"my passphrase" get-colors set-colors focus-window focus-tab
```

Only the specified actions will be allowed when using this password. Glob patterns can be used too, for example:

```conf
remote_control_password"my passphrase" set-tab-* resize-*
```

To get a list of available actions, run:

```conf
kitten@ --help
```

A set of actions to be allowed when no password is sent can be specified by using an empty password. For example:

```conf
remote_control_password"" *-colors
```

Finally, the path to a python module can be specified that provides a function `is_cmd_allowed` that is used to check every remote control command. For example:

```conf
remote_control_password"my passphrase" my_rc_command_checker.py
```

Relative paths are resolved from the kitty configuration directory. See [Customizing authorization with your own program](https://sw.kovidgoyal.net/kitty/remote-control/#rc-custom-auth) for details.

allow\_remote\_control[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.allow_remote_control "Link to this definition")

```conf
allow_remote_controlno
```

Allow other programs to control kitty. If you turn this on, other programs can control all aspects of kitty, including sending text to kitty windows, opening new windows, closing windows, reading the content of windows, etc. Note that this even works over SSH connections. The default setting of `no` prevents any form of remote control. The meaning of the various values are:

`password`

Remote control requests received over both the TTY device and the socket are confirmed based on passwords, see [`remote_control_password`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.remote_control_password).

`socket-only`

Remote control requests received over a socket are accepted unconditionally. Requests received over the TTY are denied. See [`listen_on`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.listen_on).

`socket`

Remote control requests received over a socket are accepted unconditionally. Requests received over the TTY are confirmed based on password.

`no`

Remote control is completely disabled.

`yes`

Remote control requests are always accepted.

listen\_on[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.listen_on "Link to this definition")

```conf
listen_onnone
```

Listen to the specified socket for remote control connections. Note that this will apply to all kitty instances. It can be overridden by the [`kitty --listen-on`](https://sw.kovidgoyal.net/kitty/invocation/#cmdoption-kitty-listen-on) command line option. For UNIX sockets, such as `unix:${TEMP}/mykitty` or `unix:@mykitty` (on Linux). Environment variables are expanded and relative paths are resolved with respect to the temporary directory. If `{kitty_pid}` is present, then it is replaced by the PID of the kitty process, otherwise the PID of the kitty process is appended to the value, with a hyphen. For TCP sockets such as `tcp:localhost:0` a random port is always used even if a non-zero port number is specified. See the help for [`kitty --listen-on`](https://sw.kovidgoyal.net/kitty/invocation/#cmdoption-kitty-listen-on) for more details. Note that this will be ignored unless [`allow_remote_control`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.allow_remote_control) is set to either: `yes`, `socket` or `socket-only`. Changing this option by reloading the config is not supported.

env[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.env "Link to this definition")

Specify the environment variables to be set in all child processes. Using the name with an equal sign (e.g. `env VAR=`) will set it to the empty string. Specifying only the name (e.g. `env VAR`) will remove the variable from the child process’ environment. Note that environment variables are expanded recursively, for example:

```conf
envVAR1=a
envVAR2=${HOME}/${VAR1}/b
```

The value of `VAR2` will be `<path to home directory>/a/b`.

filter\_notification[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.filter_notification "Link to this definition")

Specify rules to filter out notifications sent by applications running in kitty. Can be specified multiple times to create multiple filter rules. A rule specification is of the form `field:regexp`. A filter rule can match on any of the fields: `title`, `body`, `app`, `type`. The special value of `all` filters out all notifications. Rules can be combined using Boolean operators. Some examples:

```conf
filter_notificationtitle:hello or body:"abc.*def"
# filter out notification from vim except for ones about updates, (?i)
# makes matching case insensitive.
filter_notificationapp:"[ng]?vim" and not body:"(?i)update"
# filter out all notifications
filter_notificationall
```

The field `app` is the name of the application sending the notification and `type` is the type of the notification. Not all applications will send these fields, so you can also match on the title and body of the notification text. More sophisticated programmatic filtering and custom actions on notifications can be done by creating a notifications.py file in the kitty config directory (`~/.config/kitty`). An annotated sample is [available](https://github.com/kovidgoyal/kitty/blob/master/docs/notifications.py).

watcher[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.watcher "Link to this definition")

Path to python file which will be loaded for [Watching launched windows](https://sw.kovidgoyal.net/kitty/launch/#watchers). Can be specified more than once to load multiple watchers. The watchers will be added to every kitty window. Relative paths are resolved relative to the kitty config directory. Note that reloading the config will only affect windows created after the reload.

exe\_search\_path[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.exe_search_path "Link to this definition")

Control where kitty finds the programs to run. The default search order is: First search the system wide `PATH`, then `~/.local/bin` and `~/bin`. If still not found, the `PATH` defined in the login shell after sourcing all its startup files is tried. Finally, if present, the `PATH` specified by the [`env`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.env) option is tried.

This option allows you to prepend, append, or remove paths from this search order. It can be specified multiple times for multiple paths. A simple path will be prepended to the search order. A path that starts with the `+` sign will be append to the search order, after `~/bin` above. A path that starts with the `-` sign will be removed from the entire search order. For example:

```conf
exe_search_path/some/prepended/path
exe_search_path+/some/appended/path
exe_search_path-/some/excluded/path
```

update\_check\_interval[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.update_check_interval "Link to this definition")

```conf
update_check_interval24
```

The interval to periodically check if an update to kitty is available (in hours). If an update is found, a system notification is displayed informing you of the available update. The default is to check every 24 hours, set to zero to disable. Update checking is only done by the official binary builds. Distro packages or source builds do not do update checking. Changing this option by reloading the config is not supported.

startup\_session[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.startup_session "Link to this definition")

```conf
startup_sessionnone
```

Path to a session file to use for all kitty instances. Can be overridden by using the [`kitty --session`](https://sw.kovidgoyal.net/kitty/invocation/#cmdoption-kitty-session) `=none` command line option for individual instances. See [Startup Sessions](https://sw.kovidgoyal.net/kitty/overview/#sessions) in the kitty documentation for details. Note that relative paths are interpreted with respect to the kitty config directory. Environment variables in the path are expanded. Changing this option by reloading the config is not supported. Note that if kitty is invoked with command line arguments specifying a command to run, this option is ignored.

clipboard\_control[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.clipboard_control "Link to this definition")

```conf
clipboard_controlwrite-clipboard write-primary read-clipboard-ask read-primary-ask
```

Allow programs running in kitty to read and write from the clipboard. You can control exactly which actions are allowed. The possible actions are: `write-clipboard`, `read-clipboard`, `write-primary`, `read-primary`, `read-clipboard-ask`, `read-primary-ask`. The default is to allow writing to the clipboard and primary selection and to ask for permission when a program tries to read from the clipboard. Note that disabling the read confirmation is a security risk as it means that any program, even the ones running on a remote server via SSH can read your clipboard. See also [`clipboard_max_size`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.clipboard_max_size).

clipboard\_max\_size[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.clipboard_max_size "Link to this definition")

```conf
clipboard_max_size512
```

The maximum size (in MB) of data from programs running in kitty that will be stored for writing to the system clipboard. A value of zero means no size limit is applied. See also [`clipboard_control`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.clipboard_control).

file\_transfer\_confirmation\_bypass[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.file_transfer_confirmation_bypass "Link to this definition")

The password that can be supplied to the [file transfer kitten](https://sw.kovidgoyal.net/kitty/kittens/transfer/) to skip the transfer confirmation prompt. This should only be used when initiating transfers from trusted computers, over trusted networks or encrypted transports, as it allows any programs running on the remote machine to read/write to the local filesystem, without permission.

allow\_hyperlinks[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.allow_hyperlinks "Link to this definition")

```conf
allow_hyperlinksyes
```

Process [hyperlink](https://sw.kovidgoyal.net/kitty/glossary/#term-hyperlinks) escape sequences (OSC 8). If disabled OSC 8 escape sequences are ignored. Otherwise they become clickable links, that you can click with the mouse or by using the [hints kitten](https://sw.kovidgoyal.net/kitty/kittens/hints/). The special value of `ask` means that kitty will ask before opening the link when clicked.

shell\_integration[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.shell_integration "Link to this definition")

```conf
shell_integrationenabled
```

Enable shell integration on supported shells. This enables features such as jumping to previous prompts, browsing the output of the previous command in a pager, etc. on supported shells. Set to `disabled` to turn off shell integration, completely. It is also possible to disable individual features, set to a space separated list of these values: `no-rc`, `no-cursor`, `no-title`, `no-cwd`, `no-prompt-mark`, `no-complete`, `no-sudo`. See [Shell integration](https://sw.kovidgoyal.net/kitty/shell-integration/#shell-integration) for details.

allow\_cloning[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.allow_cloning "Link to this definition")

```conf
allow_cloningask
```

Control whether programs running in the terminal can request new windows to be created. The canonical example is [clone-in-kitty](https://sw.kovidgoyal.net/kitty/shell-integration/#clone-shell). By default, kitty will ask for permission for each clone request. Allowing cloning unconditionally gives programs running in the terminal (including over SSH) permission to execute arbitrary code, as the user who is running the terminal, on the computer that the terminal is running on.

clone\_source\_strategies[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.clone_source_strategies "Link to this definition")

```conf
clone_source_strategiesvenv,conda,env_var,path
```

Control what shell code is sourced when running **clone-in-kitty** in the newly cloned window. The supported strategies are:

`venv`

Source the file `$VIRTUAL_ENV/bin/activate`. This is used by the Python stdlib venv module and allows cloning venvs automatically.

`conda`

Run `conda activate $CONDA_DEFAULT_ENV`. This supports the virtual environments created by **conda**.

`env_var`

Execute the contents of the environment variable [`KITTY_CLONE_SOURCE_CODE`](https://sw.kovidgoyal.net/kitty/glossary/#envvar-KITTY_CLONE_SOURCE_CODE) with `eval`.

`path`

Source the file pointed to by the environment variable [`KITTY_CLONE_SOURCE_PATH`](https://sw.kovidgoyal.net/kitty/glossary/#envvar-KITTY_CLONE_SOURCE_PATH).

This option must be a comma separated list of the above values. Only the first valid match, in the order specified, is sourced.

notify\_on\_cmd\_finish[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.notify_on_cmd_finish "Link to this definition")

```conf
notify_on_cmd_finishnever
```

Show a desktop notification when a long-running command finishes (needs [`shell_integration`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.shell_integration)). The possible values are:

`never`

Never send a notification.

`unfocused`

Only send a notification when the window does not have keyboard focus.

`invisible`

Only send a notification when the window both is unfocused and not visible to the user, for example, because it is in an inactive tab or its OS window is not currently active.

`always`

Always send a notification, regardless of window state.

There are two optional arguments:

First, the minimum duration for what is considered a long running command. The default is 5 seconds. Specify a second argument to set the duration. For example: `invisible 15`. Do not set the value too small, otherwise a command that launches a new OS Window and exits will spam a notification.

Second, the action to perform. The default is `notify`. The possible values are:

`notify`

Send a desktop notification. The subsequent arguments are optional and specify when the notification is automatically cleared. The set of possible events when the notification is cleared are: `focus` and `next`. `focus` means that when the notification policy is `unfocused` or `invisible` the notification is automatically cleared when the window regains focus. The value of `next` means that the previous notification is cleared when the next notification is shown. The default when no arguments are specified is: `focus next`.

`bell`

Ring the terminal bell.

`command`

Run a custom command. All subsequent arguments are the cmdline to run.

Some more examples:

```conf
# Send a notification when a command takes more than 5 seconds in an unfocused window
notify_on_cmd_finishunfocused
# Send a notification when a command takes more than 10 seconds in a invisible window
notify_on_cmd_finishinvisible 10.0
# Ring a bell when a command takes more than 10 seconds in a invisible window
notify_on_cmd_finishinvisible 10.0 bell
# Run 'notify-send' when a command takes more than 10 seconds in a invisible window
# Here %c is replaced by the current command line and %s by the job exit code
notify_on_cmd_finishinvisible 10.0 command notify-send "job finished with status: %s" %c
# Do not clear previous notification when next command finishes or window regains focus
notify_on_cmd_finishinvisible 5.0 notify
```

term[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.term "Link to this definition")

```conf
termxterm-kitty
```

The value of the [`TERM`](https://sw.kovidgoyal.net/kitty/glossary/#envvar-TERM) environment variable to set. Changing this can break many terminal programs, only change it if you know what you are doing, not because you read some advice on “Stack Overflow” to change it. The [`TERM`](https://sw.kovidgoyal.net/kitty/glossary/#envvar-TERM) variable is used by various programs to get information about the capabilities and behavior of the terminal. If you change it, depending on what programs you run, and how different the terminal you are changing it to is, various things from key-presses, to colors, to various advanced features may not work. Changing this option by reloading the config will only affect newly created windows.

terminfo\_type[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.terminfo_type "Link to this definition")

```conf
terminfo_typepath
```

The value of the [`TERMINFO`](https://sw.kovidgoyal.net/kitty/glossary/#envvar-TERMINFO) environment variable to set. This variable is used by programs running in the terminal to search for terminfo databases. The default value of `path` causes kitty to set it to a filesystem location containing the kitty terminfo database. A value of `direct` means put the entire database into the env var directly. This can be useful when connecting to containers, for example. But, note that not all software supports this. A value of `none` means do not touch the variable.

forward\_stdio[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.forward_stdio "Link to this definition")

```conf
forward_stdiono
```

Forward STDOUT and STDERR of the kitty process to child processes. This is useful for debugging as it allows child processes to print to kitty’s STDOUT directly. For example, `echo hello world >&$KITTY_STDIO_FORWARDED` in a shell will print to the parent kitty’s STDOUT. Sets the `KITTY_STDIO_FORWARDED=fdnum` environment variable so child processes know about the forwarding. Note that on macOS this prevents the shell from being run via the login utility so getlogin() will not work in programs run in this session.

menu\_map[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.menu_map "Link to this definition")

Specify entries for various menus in kitty. Currently only the global menubar on macOS is supported. For example:

```conf
menu_mapglobal "Actions::Launch something special" launch --hold --type=os-window sh -c "echo hello world"
```

This will create a menu entry named “Launch something special” in an “Actions” menu in the macOS global menubar. Sub-menus can be created by adding more levels separated by the `::` characters.

## OS specific tweaks¶

wayland\_titlebar\_color[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.wayland_titlebar_color "Link to this definition")

```conf
wayland_titlebar_colorsystem
```

The color of the kitty window’s titlebar on Wayland systems with client side window decorations such as GNOME. A value of `system` means to use the default system colors, a value of `background` means to use the background color of the currently active kitty window and finally you can use an arbitrary color, such as `#12af59` or `red`.

macos\_titlebar\_color[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.macos_titlebar_color "Link to this definition")

```conf
macos_titlebar_colorsystem
```

The color of the kitty window’s titlebar on macOS. A value of `system` means to use the default system color, `light` or `dark` can also be used to set it explicitly. A value of `background` means to use the background color of the currently active window and finally you can use an arbitrary color, such as `#12af59` or `red`. WARNING: This option works by using a hack when arbitrary color (or `background`) is configured, as there is no proper Cocoa API for it. It sets the background color of the entire window and makes the titlebar transparent. As such it is incompatible with [`background_opacity`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.background_opacity). If you want to use both, you are probably better off just hiding the titlebar with [`hide_window_decorations`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.hide_window_decorations).

macos\_option\_as\_alt[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.macos_option_as_alt "Link to this definition")

```conf
macos_option_as_altno
```

Use the Option key as an Alt key on macOS. With this set to `no`, kitty will use the macOS native Option+Key to enter Unicode character behavior. This will break any Alt+Key keyboard shortcuts in your terminal programs, but you can use the macOS Unicode input technique. You can use the values: `left`, `right` or `both` to use only the left, right or both Option keys as Alt, instead. Note that kitty itself always treats Option the same as Alt. This means you cannot use this option to configure different kitty shortcuts for Option+Key vs. Alt+Key. Also, any kitty shortcuts using Option/Alt+Key will take priority, so that any such key presses will not be passed to terminal programs running inside kitty. Changing this option by reloading the config is not supported.

macos\_hide\_from\_tasks[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.macos_hide_from_tasks "Link to this definition")

```conf
macos_hide_from_tasksno
```

Hide the kitty window from running tasks on macOS (⌘+Tab and the Dock). Changing this option by reloading the config is not supported.

macos\_quit\_when\_last\_window\_closed[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.macos_quit_when_last_window_closed "Link to this definition")

```conf
macos_quit_when_last_window_closedno
```

Have kitty quit when all the top-level windows are closed on macOS. By default, kitty will stay running, even with no open windows, as is the expected behavior on macOS.

macos\_window\_resizable[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.macos_window_resizable "Link to this definition")

```conf
macos_window_resizableyes
```

Disable this if you want kitty top-level OS windows to not be resizable on macOS.

macos\_thicken\_font[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.macos_thicken_font "Link to this definition")

```conf
macos_thicken_font0
```

Draw an extra border around the font with the given width, to increase legibility at small font sizes on macOS. For example, a value of `0.75` will result in rendering that looks similar to sub-pixel antialiasing at common font sizes. Note that in modern kitty, this option is obsolete (although still supported). Consider using [`text_composition_strategy`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.text_composition_strategy) instead.

macos\_traditional\_fullscreen[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.macos_traditional_fullscreen "Link to this definition")

```conf
macos_traditional_fullscreenno
```

Use the macOS traditional full-screen transition, that is faster, but less pretty.

macos\_show\_window\_title\_in[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.macos_show_window_title_in "Link to this definition")

```conf
macos_show_window_title_inall
```

Control where the window title is displayed on macOS. A value of `window` will show the title of the currently active window at the top of the macOS window. A value of `menubar` will show the title of the currently active window in the macOS global menu bar, making use of otherwise wasted space. A value of `all` will show the title in both places, and `none` hides the title. See [`macos_menubar_title_max_length`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.macos_menubar_title_max_length) for how to control the length of the title in the menu bar.

macos\_menubar\_title\_max\_length[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.macos_menubar_title_max_length "Link to this definition")

```conf
macos_menubar_title_max_length0
```

The maximum number of characters from the window title to show in the macOS global menu bar. Values less than one means that there is no maximum limit.

macos\_custom\_beam\_cursor[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.macos_custom_beam_cursor "Link to this definition")

```conf
macos_custom_beam_cursorno
```

Use a custom mouse cursor for macOS that is easier to see on both light and dark backgrounds. Nowadays, the default macOS cursor already comes with a white border. WARNING: this might make your mouse cursor invisible on dual GPU machines. Changing this option by reloading the config is not supported.

macos\_colorspace[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.macos_colorspace "Link to this definition")

```conf
macos_colorspacesrgb
```

The colorspace in which to interpret terminal colors. The default of `srgb` will cause colors to match those seen in web browsers. The value of `default` will use whatever the native colorspace of the display is. The value of `displayp3` will use Apple’s special snowflake display P3 color space, which will result in over saturated (brighter) colors with some color shift. Reloading configuration will change this value only for newly created OS windows.

linux\_display\_server[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.linux_display_server "Link to this definition")

```conf
linux_display_serverauto
```

Choose between Wayland and X11 backends. By default, an appropriate backend based on the system state is chosen automatically. Set it to `x11` or `wayland` to force the choice. Changing this option by reloading the config is not supported.

wayland\_enable\_ime[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.wayland_enable_ime "Link to this definition")

```conf
wayland_enable_imeyes
```

Enable Input Method Extension on Wayland. This is typically used for inputting text in East Asian languages. However, its implementation in Wayland is often buggy and introduces latency into the input loop, so disable this if you know you dont need it. Changing this option by reloading the config is not supported, it will not have any effect.

## Keyboard shortcuts¶

Keys are identified simply by their lowercase Unicode characters. For example: `a` for the A key, `[` for the left square bracket key, etc. For functional keys, such as Enter or Escape, the names are present at [Functional key definitions](https://sw.kovidgoyal.net/kitty/keyboard-protocol/#functional). For modifier keys, the names are ctrl (control, ⌃), shift (⇧), alt (opt, option, ⌥), super (cmd, command, ⌘).

Simple shortcut mapping is done with the `map` directive. For full details on advanced mapping including modal and per application maps, see [Making your keyboard dance](https://sw.kovidgoyal.net/kitty/mapping/). Some quick examples to illustrate common tasks:

```conf
# unmap a keyboard shortcut, passing it to the program running in kitty
mapkitty_mod+space
# completely ignore a keyboard event
mapctrl+alt+f1discard_event
# combine multiple actions
mapkitty_mod+ecombine : new_window : next_layout
# multi-key shortcuts
mapctrl+x>ctrl+y>zaction
```

The full list of actions that can be mapped to key presses is available [here](https://sw.kovidgoyal.net/kitty/actions/).

kitty\_mod[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.kitty_mod "Link to this definition")

```conf
kitty_modctrl+shift
```

Special modifier key alias for default shortcuts. You can change the value of this option to alter all default shortcuts that use [`kitty_mod`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.kitty_mod).

clear\_all\_shortcuts[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.clear_all_shortcuts "Link to this definition")

```conf
clear_all_shortcutsno
```

Remove all shortcut definitions up to this point. Useful, for instance, to remove the default shortcuts.

action\_alias[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.action_alias "Link to this definition")

Has no default values. Example values are shown below:

```conf
action_aliaslaunch_tab launch --type=tab --cwd=current
```

Define action aliases to avoid repeating the same options in multiple mappings. Aliases can be defined for any action and will be expanded recursively. For example, the above alias allows you to create mappings to launch a new tab in the current working directory without duplication:

```conf
mapf1launch_tab vim
mapf2launch_tab emacs
```

Similarly, to alias kitten invocation:

```conf
action_aliashints kitten hints --hints-offset=0
```

kitten\_alias[¶](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.kitten_alias "Link to this definition")

Has no default values. Example values are shown below:

```conf
kitten_aliashints hints --hints-offset=0
```

Like [`action_alias`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.action_alias) above, but specifically for kittens. Generally, prefer to use [`action_alias`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.action_alias). This option is a legacy version, present for backwards compatibility. It causes all invocations of the aliased kitten to be substituted. So the example above will cause all invocations of the hints kitten to have the [`--hints-offset=0`](https://sw.kovidgoyal.net/kitty/kittens/hints/#cmdoption-kitty-kitten-hints-hints-offset) option applied.

### Clipboard¶

Copy to clipboard[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Copy-to-clipboard "Link to this definition")

```conf
mapctrl+shift+ccopy_to_clipboard
mapcmd+ccopy_to_clipboard 🍎
```

There is also a [`copy_or_interrupt`](https://sw.kovidgoyal.net/kitty/actions/#action-copy_or_interrupt) action that can be optionally mapped to Ctrl+C. It will copy only if there is a selection and send an interrupt otherwise. Similarly, [`copy_and_clear_or_interrupt`](https://sw.kovidgoyal.net/kitty/actions/#action-copy_and_clear_or_interrupt) will copy and clear the selection or send an interrupt if there is no selection.

Paste from clipboard[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Paste-from-clipboard "Link to this definition")

```conf
mapctrl+shift+vpaste_from_clipboard
mapcmd+vpaste_from_clipboard 🍎
```

Paste from selection[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Paste-from-selection "Link to this definition")

```conf
mapctrl+shift+spaste_from_selection
mapshift+insertpaste_from_selection
```

Pass selection to program[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Pass-selection-to-program "Link to this definition")

```conf
mapctrl+shift+opass_selection_to_program
```

You can also pass the contents of the current selection to any program with [`pass_selection_to_program`](https://sw.kovidgoyal.net/kitty/actions/#action-pass_selection_to_program). By default, the system’s open program is used, but you can specify your own, the selection will be passed as a command line argument to the program. For example:

```conf
mapkitty_mod+opass_selection_to_program firefox
```

You can pass the current selection to a terminal program running in a new kitty window, by using the `@selection` placeholder:

```conf
mapkitty_mod+ynew_window less @selection
```

### Scrolling¶

Scroll line up[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Scroll-line-up "Link to this definition")

```conf
mapctrl+shift+upscroll_line_up
mapctrl+shift+kscroll_line_up
mapopt+cmd+page_upscroll_line_up 🍎
mapcmd+upscroll_line_up 🍎
```

Scroll line down[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Scroll-line-down "Link to this definition")

```conf
mapctrl+shift+downscroll_line_down
mapctrl+shift+jscroll_line_down
mapopt+cmd+page_downscroll_line_down 🍎
mapcmd+downscroll_line_down 🍎
```

Scroll page up[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Scroll-page-up "Link to this definition")

```conf
mapctrl+shift+page_upscroll_page_up
mapcmd+page_upscroll_page_up 🍎
```

Scroll page down[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Scroll-page-down "Link to this definition")

```conf
mapctrl+shift+page_downscroll_page_down
mapcmd+page_downscroll_page_down 🍎
```

Scroll to top[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Scroll-to-top "Link to this definition")

```conf
mapctrl+shift+homescroll_home
mapcmd+homescroll_home 🍎
```

Scroll to bottom[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Scroll-to-bottom "Link to this definition")

```conf
mapctrl+shift+endscroll_end
mapcmd+endscroll_end 🍎
```

Scroll to previous shell prompt[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Scroll-to-previous-shell-prompt "Link to this definition")

```conf
mapctrl+shift+zscroll_to_prompt -1
```

Use a parameter of `0` for [`scroll_to_prompt`](https://sw.kovidgoyal.net/kitty/actions/#action-scroll_to_prompt) to scroll to the last jumped to or the last clicked position. Requires [shell integration](https://sw.kovidgoyal.net/kitty/shell-integration/#shell-integration) to work.

```conf
mapctrl+shift+xscroll_to_prompt 1
```

Browse scrollback buffer in pager[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Browse-scrollback-buffer-in-pager "Link to this definition")

```conf
mapctrl+shift+hshow_scrollback
```

You can pipe the contents of the current screen and history buffer as `STDIN` to an arbitrary program using [`launch --stdin-source`](https://sw.kovidgoyal.net/kitty/launch/#cmdoption-launch-stdin-source). For example, the following opens the scrollback buffer in less in an [overlay](https://sw.kovidgoyal.net/kitty/glossary/#term-overlay) window:

```conf
mapf1launch --stdin-source=@screen_scrollback --stdin-add-formatting --type=overlay less +G -R
```

For more details on piping screen and buffer contents to external programs, see [The launch command](https://sw.kovidgoyal.net/kitty/launch/).

Browse output of the last shell command in pager[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Browse-output-of-the-last-shell-command-in-pager "Link to this definition")

```conf
mapctrl+shift+gshow_last_command_output
```

You can also define additional shortcuts to get the command output. For example, to get the first command output on screen:

```conf
mapf1show_first_command_output_on_screen
```

To get the command output that was last accessed by a keyboard action or mouse action:

```conf
mapf1show_last_visited_command_output
```

You can pipe the output of the last command run in the shell using the [`launch`](https://sw.kovidgoyal.net/kitty/actions/#action-launch) action. For example, the following opens the output in less in an [overlay](https://sw.kovidgoyal.net/kitty/glossary/#term-overlay) window:

```conf
mapf1launch --stdin-source=@last_cmd_output --stdin-add-formatting --type=overlay less +G -R
```

To get the output of the first command on the screen, use `@first_cmd_output_on_screen`. To get the output of the last jumped to command, use `@last_visited_cmd_output`.

Requires [shell integration](https://sw.kovidgoyal.net/kitty/shell-integration/#shell-integration) to work.

### Window management¶

New window[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.New-window "Link to this definition")

```conf
mapctrl+shift+enternew_window
mapcmd+enternew_window 🍎
```

You can open a new [kitty window](https://sw.kovidgoyal.net/kitty/glossary/#term-window) running an arbitrary program, for example:

```conf
mapkitty_mod+ylaunch mutt
```

You can open a new window with the current working directory set to the working directory of the current window using:

```conf
mapctrl+alt+enterlaunch --cwd=current
```

You can open a new window that is allowed to control kitty via the kitty remote control facility with [`launch --allow-remote-control`](https://sw.kovidgoyal.net/kitty/launch/#cmdoption-launch-allow-remote-control). Any programs running in that window will be allowed to control kitty. For example:

```conf
mapctrl+enterlaunch --allow-remote-control some_program
```

You can open a new window next to the currently active window or as the first window, with:

```conf
mapctrl+nlaunch --location=neighbor
mapctrl+flaunch --location=first
```

For more details, see [The launch command](https://sw.kovidgoyal.net/kitty/launch/).

New OS window[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.New-OS-window "Link to this definition")

```conf
mapctrl+shift+nnew_os_window
mapcmd+nnew_os_window 🍎
```

Works like [`new_window`](https://sw.kovidgoyal.net/kitty/actions/#action-new_window) above, except that it opens a top-level [OS window](https://sw.kovidgoyal.net/kitty/glossary/#term-os_window). In particular you can use [`new_os_window_with_cwd`](https://sw.kovidgoyal.net/kitty/actions/#action-new_os_window_with_cwd) to open a window with the current working directory.

Close window[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Close-window "Link to this definition")

```conf
mapctrl+shift+wclose_window
mapshift+cmd+dclose_window 🍎
```

```conf
mapctrl+shift+]next_window
```

Previous window[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Previous-window "Link to this definition")

```conf
mapctrl+shift+[previous_window
```

Move window forward[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Move-window-forward "Link to this definition")

```conf
mapctrl+shift+fmove_window_forward
```

Move window backward[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Move-window-backward "Link to this definition")

```conf
mapctrl+shift+bmove_window_backward
```

Move window to top[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Move-window-to-top "Link to this definition")

```conf
mapctrl+shift+\`move_window_to_top
```

Start resizing window[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Start-resizing-window "Link to this definition")

```conf
mapctrl+shift+rstart_resizing_window
mapcmd+rstart_resizing_window 🍎
```

First window[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.First-window "Link to this definition")

```conf
mapctrl+shift+1first_window
mapcmd+1first_window 🍎
```

Second window[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Second-window "Link to this definition")

```conf
mapctrl+shift+2second_window
mapcmd+2second_window 🍎
```

Third window[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Third-window "Link to this definition")

```conf
mapctrl+shift+3third_window
mapcmd+3third_window 🍎
```

Fourth window[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Fourth-window "Link to this definition")

```conf
mapctrl+shift+4fourth_window
mapcmd+4fourth_window 🍎
```

Fifth window[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Fifth-window "Link to this definition")

```conf
mapctrl+shift+5fifth_window
mapcmd+5fifth_window 🍎
```

Sixth window[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Sixth-window "Link to this definition")

```conf
mapctrl+shift+6sixth_window
mapcmd+6sixth_window 🍎
```

Seventh window[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Seventh-window "Link to this definition")

```conf
mapctrl+shift+7seventh_window
mapcmd+7seventh_window 🍎
```

Eighth window[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Eighth-window "Link to this definition")

```conf
mapctrl+shift+8eighth_window
mapcmd+8eighth_window 🍎
```

Ninth window[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Ninth-window "Link to this definition")

```conf
mapctrl+shift+9ninth_window
mapcmd+9ninth_window 🍎
```

Tenth window[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Tenth-window "Link to this definition")

```conf
mapctrl+shift+0tenth_window
```

Visually select and focus window[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Visually-select-and-focus-window "Link to this definition")

```conf
mapctrl+shift+f7focus_visible_window
```

Display overlay numbers and alphabets on the window, and switch the focus to the window when you press the key. When there are only two windows, the focus will be switched directly without displaying the overlay. You can change the overlay characters and their order with option [`visual_window_select_characters`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.visual_window_select_characters).

Visually swap window with another[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Visually-swap-window-with-another "Link to this definition")

```conf
mapctrl+shift+f8swap_with_window
```

Works like [`focus_visible_window`](https://sw.kovidgoyal.net/kitty/actions/#action-focus_visible_window) above, but swaps the window.

### Tab management¶

```conf
mapctrl+shift+rightnext_tab
mapshift+cmd+]next_tab 🍎
mapctrl+tabnext_tab
```

Previous tab[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Previous-tab "Link to this definition")

```conf
mapctrl+shift+leftprevious_tab
mapshift+cmd+[previous_tab 🍎
mapctrl+shift+tabprevious_tab
```

New tab[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.New-tab "Link to this definition")

```conf
mapctrl+shift+tnew_tab
mapcmd+tnew_tab 🍎
```

Close tab[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Close-tab "Link to this definition")

```conf
mapctrl+shift+qclose_tab
mapcmd+wclose_tab 🍎
```

Close OS window[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Close-OS-window "Link to this definition")

```conf
mapshift+cmd+wclose_os_window 🍎
```

Move tab forward[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Move-tab-forward "Link to this definition")

```conf
mapctrl+shift+.move_tab_forward
```

Move tab backward[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Move-tab-backward "Link to this definition")

```conf
mapctrl+shift+,move_tab_backward
```

Set tab title[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Set-tab-title "Link to this definition")

```conf
mapctrl+shift+alt+tset_tab_title
mapshift+cmd+iset_tab_title 🍎
```

You can also create shortcuts to go to specific [tabs](https://sw.kovidgoyal.net/kitty/glossary/#term-tab), with `1` being the first tab, `2` the second tab and `-1` being the previously active tab, `-2` being the tab active before the previously active tab and so on. Any number larger than the number of tabs goes to the last tab and any number less than the number of previously used tabs in the history goes to the oldest previously used tab in the history:

```conf
mapctrl+alt+1goto_tab 1
mapctrl+alt+2goto_tab 2
```

Just as with [`new_window`](https://sw.kovidgoyal.net/kitty/actions/#action-new_window) above, you can also pass the name of arbitrary commands to run when using [`new_tab`](https://sw.kovidgoyal.net/kitty/actions/#action-new_tab) and [`new_tab_with_cwd`](https://sw.kovidgoyal.net/kitty/actions/#action-new_tab_with_cwd). Finally, if you want the new tab to open next to the current tab rather than at the end of the tabs list, use:

```conf
mapctrl+tnew_tab !neighbor [optional cmd to run]
```

### Layout management¶

```conf
mapctrl+shift+lnext_layout
```

You can also create shortcuts to switch to specific [layouts](https://sw.kovidgoyal.net/kitty/glossary/#term-layout):

```conf
mapctrl+alt+tgoto_layout tall
mapctrl+alt+sgoto_layout stack
```

Similarly, to switch back to the previous layout:

```conf
mapctrl+alt+plast_used_layout
```

There is also a [`toggle_layout`](https://sw.kovidgoyal.net/kitty/actions/#action-toggle_layout) action that switches to the named layout or back to the previous layout if in the named layout. Useful to temporarily “zoom” the active window by switching to the stack layout:

```conf
mapctrl+alt+ztoggle_layout stack
```

### Font sizes¶

You can change the font size for all top-level kitty OS windows at a time or only the current one.

Increase font size[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Increase-font-size "Link to this definition")

```conf
mapctrl+shift+equalchange_font_size all +2.0
mapctrl+shift+pluschange_font_size all +2.0
mapctrl+shift+kp_addchange_font_size all +2.0
mapcmd+pluschange_font_size all +2.0 🍎
mapcmd+equalchange_font_size all +2.0 🍎
mapshift+cmd+equalchange_font_size all +2.0 🍎
```

Decrease font size[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Decrease-font-size "Link to this definition")

```conf
mapctrl+shift+minuschange_font_size all -2.0
mapctrl+shift+kp_subtractchange_font_size all -2.0
mapcmd+minuschange_font_size all -2.0 🍎
mapshift+cmd+minuschange_font_size all -2.0 🍎
```

Reset font size[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Reset-font-size "Link to this definition")

```conf
mapctrl+shift+backspacechange_font_size all 0
mapcmd+0change_font_size all 0 🍎
```

To setup shortcuts for specific font sizes:

```conf
mapkitty_mod+f6change_font_size all 10.0
```

To setup shortcuts to change only the current OS window’s font size:

```conf
mapkitty_mod+f6change_font_size current 10.0
```

### Select and act on visible text¶

Use the hints kitten to select text and either pass it to an external program or insert it into the terminal or copy it to the clipboard.

Open URL[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Open-URL "Link to this definition")

```conf
mapctrl+shift+eopen_url_with_hints
```

Open a currently visible URL using the keyboard. The program used to open the URL is specified in [`open_url_with`](https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.open_url_with).

Insert selected path[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Insert-selected-path "Link to this definition")

```conf
mapctrl+shift+p>fkitten hints --type path --program -
```

Select a path/filename and insert it into the terminal. Useful, for instance to run **git** commands on a filename output from a previous **git** command.

Open selected path[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Open-selected-path "Link to this definition")

```conf
mapctrl+shift+p>shift+fkitten hints --type path
```

Select a path/filename and open it with the default open program.

Insert selected line[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Insert-selected-line "Link to this definition")

```conf
mapctrl+shift+p>lkitten hints --type line --program -
```

Select a line of text and insert it into the terminal. Useful for the output of things like: `ls -1`.

Insert selected word[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Insert-selected-word "Link to this definition")

```conf
mapctrl+shift+p>wkitten hints --type word --program -
```

Select words and insert into terminal.

Insert selected hash[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Insert-selected-hash "Link to this definition")

```conf
mapctrl+shift+p>hkitten hints --type hash --program -
```

Select something that looks like a hash and insert it into the terminal. Useful with **git**, which uses SHA1 hashes to identify commits.

Open the selected file at the selected line[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Open-the-selected-file-at-the-selected-line "Link to this definition")

```conf
mapctrl+shift+p>nkitten hints --type linenum
```

Select something that looks like `filename:linenum` and open it in your default editor at the specified line number.

Open the selected hyperlink[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Open-the-selected-hyperlink "Link to this definition")

```conf
mapctrl+shift+p>ykitten hints --type hyperlink
```

Select a [hyperlink](https://sw.kovidgoyal.net/kitty/glossary/#term-hyperlinks) (i.e. a URL that has been marked as such by the terminal program, for example, by `ls --hyperlink=auto`).

The hints kitten has many more modes of operation that you can map to different shortcuts. For a full description see [hints kitten](https://sw.kovidgoyal.net/kitty/kittens/hints/).

### Miscellaneous¶

Show documentation[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Show-documentation "Link to this definition")

```conf
mapctrl+shift+f1show_kitty_doc overview
```

Toggle fullscreen[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Toggle-fullscreen "Link to this definition")

```conf
mapctrl+shift+f11toggle_fullscreen
mapctrl+cmd+ftoggle_fullscreen 🍎
```

Toggle maximized[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Toggle-maximized "Link to this definition")

```conf
mapctrl+shift+f10toggle_maximized
```

Toggle macOS secure keyboard entry[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Toggle-macOS-secure-keyboard-entry "Link to this definition")

```conf
mapopt+cmd+stoggle_macos_secure_keyboard_entry 🍎
```

Unicode input[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Unicode-input "Link to this definition")

```conf
mapctrl+shift+ukitten unicode_input
mapctrl+cmd+spacekitten unicode_input 🍎
```

Edit config file[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Edit-config-file "Link to this definition")

```conf
mapctrl+shift+f2edit_config_file
mapcmd+,edit_config_file 🍎
```

Open the kitty command shell[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Open-the-kitty-command-shell "Link to this definition")

```conf
mapctrl+shift+escapekitty_shell window
```

Open the kitty shell in a new `window` / `tab` / `overlay` / `os_window` to control kitty using commands.

Increase background opacity[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Increase-background-opacity "Link to this definition")

```conf
mapctrl+shift+a>mset_background_opacity +0.1
```

Decrease background opacity[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Decrease-background-opacity "Link to this definition")

```conf
mapctrl+shift+a>lset_background_opacity -0.1
```

Make background fully opaque[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Make-background-fully-opaque "Link to this definition")

```conf
mapctrl+shift+a>1set_background_opacity 1
```

Reset background opacity[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Reset-background-opacity "Link to this definition")

```conf
mapctrl+shift+a>dset_background_opacity default
```

Reset the terminal[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Reset-the-terminal "Link to this definition")

```conf
mapctrl+shift+deleteclear_terminal reset active
mapopt+cmd+rclear_terminal reset active 🍎
```

You can create shortcuts to clear/reset the terminal. For example:

```conf
# Reset the terminal
mapf1clear_terminal reset active
# Clear the terminal screen by erasing all contents
mapf1clear_terminal clear active
# Clear the terminal scrollback by erasing it
mapf1clear_terminal scrollback active
# Scroll the contents of the screen into the scrollback
mapf1clear_terminal scroll active
# Clear everything on screen up to the line with the cursor or the start of the current prompt (needs shell integration)
mapf1clear_terminal to_cursor active
# Same as above except cleared lines are moved into scrollback
mapf1clear_terminal to_cursor_scroll active
```

If you want to operate on all kitty windows instead of just the current one, use all instead of active.

Some useful functions that can be defined in the shell rc files to perform various kinds of clearing of the current window:

```sh
clear-only-screen(){
printf"\e[H\e[2J"
}

clear-screen-and-scrollback(){
printf"\e[H\e[3J"
}

clear-screen-saving-contents-in-scrollback(){
printf"\e[H\e[22J"
}
```

For instance, using these escape codes, it is possible to remap Ctrl+L to both scroll the current screen contents into the scrollback buffer and clear the screen, instead of just clearing the screen. For ZSH, in `~/.zshrc`, add:

```zsh
ctrl_l(){
builtinprint-rn--$'\r\e[0J\e[H\e[22J'>"$TTY"
builtinzle.reset-prompt
builtinzle-R
}
zle-Nctrl_l
bindkey'^l'ctrl_l
```

Alternatively, you can just add `map ctrl+l clear_terminal to_cursor_scroll active` to `kitty.conf` which works with no changes to the shell rc files, but only clears up to the prompt, it does not clear anytext at the prompt itself.

Clear to start[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Clear-to-start "Link to this definition")

```conf
mapcmd+kclear_terminal to_cursor active 🍎
```

Clear scrollback[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Clear-scrollback "Link to this definition")

```conf
mapoption+cmd+kclear_terminal scrollback active 🍎
```

Clear screen[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Clear-screen "Link to this definition")

```conf
mapcmd+ctrl+lclear_terminal to_cursor_scroll active 🍎
```

Reload kitty.conf[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Reload-kitty.conf "Link to this definition")

```conf
mapctrl+shift+f5load_config_file
mapctrl+cmd+,load_config_file 🍎
```

Reload `kitty.conf`, applying any changes since the last time it was loaded. Note that a handful of options cannot be dynamically changed and require a full restart of kitty. Particularly, when changing shortcuts for actions located on the macOS global menu bar, a full restart is needed. You can also map a keybinding to load a different config file, for example:

```conf
mapf5load_config /path/to/alternative/kitty.conf
```

Note that all options from the original `kitty.conf` are discarded, in other words the new configuration *replace* the old ones.

Debug kitty configuration[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Debug-kitty-configuration "Link to this definition")

```conf
mapctrl+shift+f6debug_config
mapopt+cmd+,debug_config 🍎
```

Show details about exactly what configuration kitty is running with and its host environment. Useful for debugging issues.

Send arbitrary text on key presses[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Send-arbitrary-text-on-key-presses "Link to this definition")

You can tell kitty to send arbitrary (UTF-8) encoded text to the client program when pressing specified shortcut keys. For example:

```conf
mapctrl+alt+asend_text all Special text
```

This will send “Special text” when you press the Ctrl+Alt+A key combination. The text to be sent decodes [ANSI C escapes](https://www.gnu.org/software/bash/manual/html_node/ANSI_002dC-Quoting.html) so you can use escapes like `\e` to send control codes or `\u21fb` to send Unicode characters (or you can just input the Unicode characters directly as UTF-8 text). You can use `kitten show-key` to get the key escape codes you want to emulate.

The first argument to `send_text` is the keyboard modes in which to activate the shortcut. The possible values are `normal`, `application`, `kitty` or a comma separated combination of them. The modes `normal` and `application` refer to the DECCKM cursor key mode for terminals, and `kitty` refers to the kitty extended keyboard protocol. The special value `all` means all of them.

Some more examples:

```conf
# Output a word and move the cursor to the start of the line (like typing and pressing Home)
mapctrl+alt+asend_text normal Word\e[H
mapctrl+alt+asend_text application Word\eOH
# Run a command at a shell prompt (like typing the command and pressing Enter)
mapctrl+alt+asend_text normal,application some command with arguments\r
```

Open kitty Website[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Open-kitty-Website "Link to this definition")

```conf
mapshift+cmd+/open_url https://sw.kovidgoyal.net/kitty/ 🍎
```

Hide macOS kitty application[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Hide-macOS-kitty-application "Link to this definition")

```conf
mapcmd+hhide_macos_app 🍎
```

Hide macOS other applications[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Hide-macOS-other-applications "Link to this definition")

```conf
mapopt+cmd+hhide_macos_other_apps 🍎
```

Minimize macOS window[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Minimize-macOS-window "Link to this definition")

```conf
mapcmd+mminimize_macos_window 🍎
```

Quit kitty[¶](https://sw.kovidgoyal.net/kitty/conf/#shortcut-kitty.Quit-kitty "Link to this definition")

```conf
mapcmd+qquit 🍎
```

## Sample kitty.conf¶

You can download a sample `kitty.conf` file with all default settings and comments describing each setting by clicking: [`sample kitty.conf`](https://sw.kovidgoyal.net/kitty/_downloads/433dadebd0bf504f8b008985378086ce/kitty.conf).

A default configuration file can also be generated by running:

```conf
kitty+runpy 'from kitty.config import *; print(commented_out_default_config())'
```

This will print the commented out default config file to `STDOUT`.

## All mappable actions¶

See the [list of all the things you can make |kitty| can do](https://sw.kovidgoyal.net/kitty/actions/).
