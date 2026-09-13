# NoirPad icon setup (run once, ASCII-only file)
# 1. Creates a desktop shortcut "NoirPad" with the Q1 Lite icon
#    that launches Start NoirPad.bat
# 2. Applies the icon to this folder as well

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$ico  = Join-Path $here "NoirPad.ico"
$bat  = Join-Path $here "Start NoirPad.bat"

if (-not (Test-Path $ico)) { Write-Host "NoirPad.ico not found - aborting."; exit 1 }
if (-not (Test-Path $bat)) { Write-Host "Start NoirPad.bat not found - aborting."; exit 1 }

# --- desktop shortcut ---
$desktop = [Environment]::GetFolderPath("Desktop")
$ws  = New-Object -ComObject WScript.Shell
$lnk = $ws.CreateShortcut((Join-Path $desktop "NoirPad.lnk"))
$lnk.TargetPath       = $bat
$lnk.WorkingDirectory = $here
$lnk.IconLocation     = "$ico,0"
$lnk.Description      = "NOIR//PAD - dark typewriter editor"
$lnk.Save()
Write-Host "Desktop shortcut created: NoirPad" -ForegroundColor White

# --- folder icon (desktop.ini) ---
$ini = Join-Path $here "desktop.ini"
if (Test-Path $ini) { attrib -s -h "$ini" }
@"
[.ShellClassInfo]
IconResource=NoirPad.ico,0
InfoTip=NOIR//PAD - dark typewriter editor
"@ | Out-File -FilePath $ini -Encoding ASCII -Force
attrib +s +h "$ini"
attrib +r "$here"
Write-Host "Folder icon applied (may need a restart of Explorer or F5 to show)." -ForegroundColor White
Write-Host ""
Write-Host "Done. You can delete this setup file if you like." -ForegroundColor DarkGray
