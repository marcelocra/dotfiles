#!/usr/bin/env sh
#
# Map some key combinations to particular characters. This is very useful when
# typing foreign characters (like ç) in an English keyboard layout.
#
# TODO: figure out why this is not working.
#
# To see all keycodes, run `xmodmap -pke` in your terminal.
#
. $HOME/bin/.rc.common

if [ "$1" = "reset" ]; then
    # Resets the mappings in the current keyboard layout.
    echo 'Reset!'
    setxkbmap
    echo 'Done!'
    exit
fi

all_keycodes="$(xmodmap -pke)"

# Gets the keycodes for a key automatically. You might want to doublecheck the
# values once per new system, just to be sure.
get_keycode() {
    # Echoing without double quotes merges all the lines into one, facilitating
    # detection.
    echo $all_keycodes | sed -E -e "s/.*keycode\s+([0-9]+)\s+=\s+$1 .*/\1/"
}

# This contains the string that should be searched in the output of xmodmap.
# The regex to get them considers that they are the first part of the string
# after the `=`, but that is not the case for `ccedilla`. Therefore we change
# the search string for something that will match.

k_alt_r='Alt_R'
k_alt_l='Alt_L'
k_shift_l='Shift_L'

alt_r="$(get_keycode $k_alt_r)"
debug "$k_alt_r = $alt_r"

alt_l="$(get_keycode $k_alt_l)"
debug "$k_alt_l = $alt_l"

shift_l="$(get_keycode $k_shift_l)"
debug "$k_shift_l = $shift_l"

# For a.
k_letter_a='a'
k_letter_q='q'
k_letter_z='z'

letter_a="$(get_keycode $k_letter_a)"
debug "$k_letter_a = $letter_a"

letter_q="$(get_keycode $k_letter_q)"
debug "$k_letter_q = $letter_q"

letter_z="$(get_keycode $k_letter_z)"
debug "$k_letter_z = $letter_z"

# For e.
k_letter_s='s'

letter_s="$(get_keycode $k_letter_s)"
debug "$k_letter_s = $letter_s"

# For i.
k_letter_d='d'

letter_d="$(get_keycode $k_letter_d)"
debug "$k_letter_d = $letter_d"

# For o.
k_letter_f='f'
k_letter_r='r'

letter_f="$(get_keycode $k_letter_f)"
debug "$k_letter_f = $letter_f"

letter_r="$(get_keycode $k_letter_r)"
debug "$k_letter_r = $letter_r"

# For u.
k_letter_g='g'

letter_g="$(get_keycode $k_letter_g)"
debug "$k_letter_g = $letter_g"

# For c.
k_letter_c='c'

letter_c="$(get_keycode $k_letter_c)"
debug "$k_letter_c = $letter_c"


if is_debug; then
    exit
fi

# Mappings
# --------
# Keeping the most commonly used keys in home row, with alternatives up or down
# from it.



### Cedilla


# Alt_R + c -> ç
xmodmap -e "keycode $alt_r + $letter_c = ccedilla"



### Letter a


# Alt_R + a -> ã
xmodmap -e "keycode $alt_r + $letter_a = atilde"

# Alt_R + q -> á
xmodmap -e "keycode $alt_r + $letter_q = aacute"

# Alt_R + z -> à
xmodmap -e "keycode $alt_r + $letter_z = agrave"



### Letter e


# Alt_R + s -> é
xmodmap -e "keycode $alt_r + $letter_s = eacute"



### Letter i


# Alt_R + d -> í
xmodmap -e "keycode $alt_r + $letter_d = iacute"



### Letter o


# Alt_R + f -> õ
xmodmap -e "keycode $alt_r + $letter_f = otilde"

# Alt_R + r -> ó
xmodmap -e "keycode $alt_r + $letter_r = oacute"



### Letter u


# Alt_R + g -> ú
xmodmap -e "keycode $alt_r + $letter_g = uacute"

