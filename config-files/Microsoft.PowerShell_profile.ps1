# Provides an interactive menu, somewhat like what zsh does on tab.
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# [ FUNCTIONS ] ----------------------------------------------------------------

<#------------------------------------------------------------------------------
 # Configures the prompt, to include some newlines between commands, an emoji
 # some details about what kind of terminal this is (debug? admin?) and the full
 # path to the current folder.
 #>
function prompt {
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [Security.Principal.WindowsPrincipal] $identity
  $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator

  $mcra = '▬' * $(Get-Host).UI.RawUI.WindowSize.Width

  "$mcra" +

  $(if (Test-Path variable:/PSDebugContext) { '[DBG] ' }
    elseif($principal.IsInRole($adminRole)) { '[ADMIN] ' }
    else { '' }
  ) + '[' + $(Get-Location) + '] em [' + $(Get-Date -Format "dMMMyy HH:mm") + "] 😎 Rock on!`n" +
  $(if ($NestedPromptLevel -ge 1) { '>>' }) + 'PS> '
}

<#------------------------------------------------------------------------------
 # Facilitates running Docker commands.
 #>
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

function source-profile {
  . $PROFILE
}

# [ ENVIRONMENT STUFF ] --------------------------------------------------------

$env:GITHUB_MARCELOCODES = "67549662+marcelocodes@users.noreply.github.com"
$env:GITHUB_MARCELOCRA = "2532492+marcelocra@users.noreply.github.com"

# [ ALIASES ] ------------------------------------------------------------------

Set-Alias -Name di-sort-by-size -Value docker-images-sort-by-size
Set-Alias -Name di-sort-by-name -Value docker-images-sort-by-repository
Set-Alias -Name di-sort-by-name-and-size -Value docker-images-sort-by-name-and-size
Set-Alias -Name dr-rm-it -Value docker-run-standard
Set-Alias -Name vim -Value subl
Set-Alias -Name l -Value ls
Set-Alias -Name reload-profile -Value source-profile