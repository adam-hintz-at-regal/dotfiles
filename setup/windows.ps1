param (
    [switch]$Reset
)

function mklink-if-not-exists {
    param (
        [string]$destination,
        [string]$source,
        [bool]$override = $false
    )
    Write-Host "Linking $source to $destination"
    if ($Reset -and (Test-Path $destination)) {
        Remove-Item -Path $destination
    }
    $exists = Test-Path $destination
    $notSymlink = $true
    if ($exists) {
        $linkType = (Get-ChildItem $destination).LinkType
        $notSymlink = ($null -ne $linkType) -and ($linkType.ToString() -ne "SymbolicLink")
        if ($notSymlink) {
            Write-Host "[WARNING] Skipped making link because $destination is already a file, but it's not a symlink"
        } elseif ($notSymlink -and (!$override)) {
            Write-Host "[OK] Skipped making link because $destination is already a symlink"
        } else {
            Remove-Item -Path $destination
            cmd /c mklink $destination $source
        }
    } else {
        cmd /c mklink $destination $source
    }
    Write-Host "Done"
}

## Make links to RC files

Write-Host "NOTE: Any call to mklink requires admin privileges, so make sure you're running this as Admin if you're getting errors"
Write-Host "NOTE: Or, turn on Developer Mode (Settings -> Advanced -> Developer Mode)"

mklink-if-not-exists $HOME\.gitignore (Join-Path -Path (Get-Location) -ChildPath "gitignore")
mklink-if-not-exists $HOME\.gitconfig (Join-Path -Path (Get-Location) -ChildPath "gitconfig")
mklink-if-not-exists $HOME\.tmux.conf (Join-Path -Path (Get-Location) -ChildPath "tmux.conf")

$nvimConfigPath="$HOME\AppData\Local\nvim"
if (!(Test-Path -path $nvimConfigPath)) {
    New-Item -Type directory $nvimConfigPath
}
mklink-if-not-exists "$nvimConfigPath\init.lua" (Join-Path -Path (Get-Location) -ChildPath "config\nvim\init.lua")

if (!(Test-Path -path (Split-Path $PROFILE))) {
    New-Item -Type directory (Split-Path $PROFILE)
}
mklink-if-not-exists $PROFILE (Join-Path -Path (Get-Location) -ChildPath "Microsoft.PowerShell_profile.ps1")

# Copy `profile-imports.txt`. This is a custom file that loads powershell modules, and is
# currently very under-utilized, but that might change.
# In general, I want this copied because a machine might have specific modules but if I want
# to backport it, I want that to be an intentional choice.
if (!Test-Path -path "$HOME\Documents\Powershell\profile-imports.txt") {
    Copy-Item (Join-Path -Path (Get-Location) -ChildPath "profile-imports.txt") "$HOME\Documents\Powershell\profile-imports.txt"
}
