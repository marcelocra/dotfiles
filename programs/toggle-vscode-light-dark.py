#!/usr/bin/env python3

import os
import re

DEBUG = True

settings_path = os.path.join(os.environ['HOME'], '.config', 'Code', 'User', 'settings.json')

f = open(settings_path, 'r')
settings_content = f.read()
f.close()

if DEBUG:
    print(settings_content)

themes = {
        'light': 'Solarized Light',
        'dark': 'GitHub Dark Dimmed',

        'Solarized Light': 'GitHub Dark Dimmed',
        'GitHub Dark Dimmed': 'Solarized Light',
        }

def change_theme(theme):
    theme_from = themes[theme]
    theme_to = themes[theme_from]

    if DEBUG:
        print("from '{}' to '{}'".format(theme_from, theme_to))

    return re.sub('"' + theme_from + '"',
                  '"' + theme_to + '"',
                  settings_content)

new_content = ''
if re.search('colorTheme.*' + themes['light'], settings_content) is not None:
    new_content = change_theme('light')
elif re.search('colorTheme.*' + themes['dark'], settings_content) is not None:
    new_content = change_theme('dark')
else:
    print('Nothing found')
    exit(1)

if DEBUG:
    print(new_content)

f = open(settings_path, 'w')
f.write(new_content)
f.close()

