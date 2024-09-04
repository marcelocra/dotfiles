# Sublime Text settings

The `PackagesUser` folder contains Sublime Text 4's `User` directory, to be found at the user's `~/config/sublime-text` dir (usually) on Linux machines.

Copy these files to that location (or other appropriate), backing up existing content when needed.

```sh
ST_USER_FOLDER="$HOME/.config/sublime-text/Packages/User"
ST_USER_FOLDER_CONTENT="$(pwd)/sublime-text/"

# (Optional) If folder exits, back it up somewhere.
[ -d $HOME/.tmp ] && mkdir $HOME/.tmp
mv $ST_USER_FOLDER ~/.tmp/backup-sublime-settings

# Copy stuff to User folder.
cp $ST_USER_FOLDER_CONTENT/* $ST_USER_FOLDER
```

Create a cronjob to backup stuff from the user folder to here.

```sh

# Edit the crontab file and copy there the contents below the command.
crontab -e

# Copy the lines below, updating times to whatever you prefer.

#
#
# Backup Sublime Text `User` content frequently.
#
*/60 * * * * cp -r $HOME/.config/sublime-text/Packages/User/* $HOME/projects/dotfiles/sublime-text/
```
