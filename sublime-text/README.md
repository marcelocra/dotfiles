# Sublime Text settings

This is the Sublime Text 4 `User` directory, to be found in Linux at (usually)
the user's `~/config` dir.

To use this files, remove the existing user folder (if there's any. Make sure to
back it up if needed) and copy stuff there.

```sh
ST_USER_FOLDER="$HOME/.config/sublime-text/Packages/User"
ST_USER_FOLDER_CONTENT="$(pwd)/sublime-text/"

# Backup existing folder.
if [ -d "$ST_USER_FOLDER" ]; then
    mv $ST_USER_FOLDER "${ST_USER_FOLDER}.bak"
else
    mkdir -p $ST_USER_FOLDER
fi

# Copy stuff.
cp $ST_USER_FOLDER_CONTENT/* $ST_USER_FOLDER
```

Create a cronjob to backup stuff from the user folder to here.

```cron
#
#
# Backup Sublime Text `User` directory content.
#
*/60 * * * * cp -r $HOME/.config/sublime-text/Packages/User/* $HOME/projects/dotfiles/sublime-text/

```
