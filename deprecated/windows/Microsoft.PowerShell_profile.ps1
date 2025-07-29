# The `~\.userEnvsPath.ps1` should define the $env:USER_ENVS_PATH like so:
#
#   Set-Content env:USER_ENVS_PATH "PATH_TO_YOUR_ENV_FILE_HERE"
# 
# If that file exists, this first block will load all env variables defined
# there. It respects comments (lines starting with '#').
$userEnvsPath = "C:\Users\$env:USERNAME\.userEnvsPath.ps1"
if ( Test-Path $userEnvsPath ) {
  # Load user env path.
  . $userEnvsPath

  # Uses the user env path to load their envs, 
  get-content "$env:USER_ENVS_PATH" | foreach {
    $name, $value = $_.split('=')
    if ( $name -match '^[# ]' ) {
        return
    }

    set-content env:\$name $value

  } 
}

# Provides an interactive menu, somewhat like what zsh does on tab.
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# [ FUNCTIONS ] ----------------------------------------------------------------

# Facilitates running Docker commands.
function docker-images-sort-by-size {
  docker images --format="{{json .}}" |
  convertfrom-json |
  sort-object { [int]$_.Size } |
  select-object Repository,Tag,ID,CreatedSince,Size |
  format-table
}

function docker-images-sort-by-repository {
  docker images --format="{{json .}}" |
  convertfrom-json |
  sort-object Repository |
  select-object Repository,Tag,ID,CreatedSince,Size |
  format-table
}

function docker-images-sort-by-name-and-size {
  docker images --format="{{json .}}" |
  convertfrom-json |
  sort-object Repository, { [int]$_.Size } |
  select-object Repository,Tag,ID,CreatedSince,Size |
  format-table
}

function docker-run-standard {
  Param(
    [PSDefaultValue(Help = 'The Docker image name')]
    $Image = "ubuntu",
    [PSDefaultValue(Help = 'Which command to run')]
    $Cmd = "bash")
  docker run --rm -it -v ${PWD}:/home/dev --workdir=/home/app $Image $Cmd
}

# Facilitates jumping between folders.
function jump-to-private-repos {
  pushd $env:MCRA_PRIVATE_REPOS
}

function jump-to-public-repos {
  pushd $env:MCRA_PUBLIC_REPOS
}

# [ ENVIRONMENT STUFF ] --------------------------------------------------------

$env:GITHUB_MARCELOCODES = "67549662+marcelocodes@users.noreply.github.com"
$env:GITHUB_MARCELOCRA = "2532492+marcelocra@users.noreply.github.com"

oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/jandedobbeleer.omp.json" | Invoke-Expression

# [ ALIASES ] ------------------------------------------------------------------

Set-Alias -Name di-sort-by-size -Value docker-images-sort-by-size
Set-Alias -Name di-sort-by-name -Value docker-images-sort-by-repository
Set-Alias -Name di-sort-by-name-and-size -Value docker-images-sort-by-name-and-size
Set-Alias -Name dr-rm-it -Value docker-run-standard
Set-Alias -Name vim -Value subl
Set-Alias -Name l -Value ls
Set-Alias -Name jpr -Value jump-to-private-repos
Set-Alias -Name jpu -Value jump-to-public-repos
Set-Alias -Name less -Value "C:\\Program Files\\Git\\usr\\bin\\less.exe"
