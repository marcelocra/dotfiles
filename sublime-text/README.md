# Sublime Text settings

The `User` folder contains Sublime Text 4's `User` directory, usually found at:

- Linux: `~/config/sublime-text/Packages/User`
- Windows: `~/AppData/Roaming/Sublime Text/Packages/User`

Usually I symlink my configs, but it seems that Sublime Text doesn't like that. When you do, editing the symlinked settings won't apply instantaneously until you restart Sublime.

If you don't care about that, go for it. If you do, try a backup cronjob.

## How to use

Copy these files to the appropriate location, backing up any existing content.

```sh
cp ./sublime-text/User/* ~/.config/sublime-text/Packages/User/*
```

Create a cronjob to backup stuff back here.

```sh
$ crontab -e

# Add this to the crontab file.
*/60 * * * * cp -r $HOME/.config/sublime-text/Packages/User/* `$(pwd)`/sublime-text/
```
