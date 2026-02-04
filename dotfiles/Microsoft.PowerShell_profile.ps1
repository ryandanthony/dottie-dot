# PowerShell Profile - Managed by dottie
# This file is synced across all machines
# Location: $HOME/.config/powershell/Microsoft.PowerShell_profile.ps1

# Aliases - Navigation
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name which -Value Get-Command

function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }

# Git aliases
function gs { git status }
function ga { git add $args }
function gc { git commit $args }
function gp { git push $args }
function gl { git log --oneline -10 }
function gd { git diff $args }
function gco { git checkout $args }
function gb { git branch $args }

# Docker aliases
function dc { docker compose $args }
function dps { docker ps $args }
function dpsa { docker ps -a $args }

# Kubernetes alias
Set-Alias -Name k -Value kubectl

# Azure CLI aliases
function azl { az login $args }
function azs { az account show $args }

# .NET aliases
function dn { dotnet $args }
function dnr { dotnet run $args }
function dnb { dotnet build $args }
function dnt { dotnet test $args }

# Path additions
$env:PATH = "$HOME/bin:$HOME/.local/bin:$env:PATH"

# .NET SDK
$env:DOTNET_ROOT = "$HOME/.dotnet"
$env:PATH = "$env:PATH:$env:DOTNET_ROOT:$env:DOTNET_ROOT/tools"

# Editor
$env:EDITOR = "code"
$env:VISUAL = "code"

# PSReadLine configuration for better command line editing
if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# kubectl completion
if (Get-Command kubectl -ErrorAction SilentlyContinue) {
    kubectl completion powershell | Out-String | Invoke-Expression
}

# helm completion
if (Get-Command helm -ErrorAction SilentlyContinue) {
    helm completion powershell | Out-String | Invoke-Expression
}

# gh completion
if (Get-Command gh -ErrorAction SilentlyContinue) {
    Invoke-Expression -Command $(gh completion -s powershell | Out-String)
}

# Azure CLI tab completion
Register-ArgumentCompleter -Native -CommandName az -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    $completion_file = New-TemporaryFile
    $env:ARGCOMPLETE_USE_TEMPFILES = 1
    $env:_ARGCOMPLETE_STDOUT_FILENAME = $completion_file
    $env:COMP_LINE = $wordToComplete
    $env:COMP_POINT = $cursorPosition
    $env:_ARGCOMPLETE = 1
    $env:_ARGCOMPLETE_SUPPRESS_SPACE = 0
    $env:_ARGCOMPLETE_IFS = "`n"
    $env:_ARGCOMPLETE_SHELL = 'powershell'
    az 2>&1 | Out-Null
    Get-Content $completion_file | Sort-Object | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", $_)
    }
    Remove-Item $completion_file, Env:\_ARGCOMPLETE_STDOUT_FILENAME, Env:\ARGCOMPLETE_USE_TEMPFILES, Env:\COMP_LINE, Env:\COMP_POINT, Env:\_ARGCOMPLETE, Env:\_ARGCOMPLETE_SUPPRESS_SPACE, Env:\_ARGCOMPLETE_IFS, Env:\_ARGCOMPLETE_SHELL -ErrorAction SilentlyContinue
}

# Initialize Starship prompt (must be at the end)
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
