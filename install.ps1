param(
    [string]$InstallDir = (Join-Path $env:LOCALAPPDATA 'Programs\ClipBoardMess'),
    [switch]$NoModifyPath,
    [switch]$NoStartup,
    [string]$SourceExe
)

$ErrorActionPreference = 'Stop'
$downloadUrl = 'https://anytokin.github.io/ClipBoardMess/ClipBoardMess.exe'
$InstallDir = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($InstallDir)
$exePath = Join-Path $InstallDir 'ClipBoardMess.exe'

New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
$temporaryPath = Join-Path $InstallDir ([IO.Path]::GetRandomFileName())
$restart = $false

try {
    if ($SourceExe) {
        Copy-Item -LiteralPath $SourceExe -Destination $temporaryPath
    }
    else {
        Write-Host 'Downloading ClipBoardMess...'
        Invoke-WebRequest -Uri $downloadUrl -OutFile $temporaryPath -UseBasicParsing
    }

    $reader = [IO.BinaryReader]::new([IO.File]::OpenRead($temporaryPath))
    try {
        if ($reader.BaseStream.Length -lt 64 -or $reader.ReadUInt16() -ne 0x5a4d) {
            throw 'The installer did not receive a Windows executable.'
        }
        $reader.BaseStream.Position = 0x3c
        $peOffset = $reader.ReadUInt32()
        if ($peOffset -gt ($reader.BaseStream.Length - 4)) {
            throw 'The installer received a truncated Windows executable.'
        }
        $reader.BaseStream.Position = $peOffset
        if ($reader.ReadUInt32() -ne 0x00004550) {
            throw 'The installer did not receive a Windows executable.'
        }
    }
    finally {
        $reader.Dispose()
    }

    if (Test-Path -LiteralPath $exePath -PathType Leaf) {
        if ((Get-FileHash -LiteralPath $temporaryPath).Hash -eq (Get-FileHash -LiteralPath $exePath).Hash) {
            Write-Host 'ClipBoardMess is already installed.'
        }
        else {
            $running = @(Get-Process -Name 'ClipBoardMess' -ErrorAction SilentlyContinue |
                Where-Object { $_.Path -eq $exePath })
            if ($running.Count -gt 0) {
                Stop-Process -InputObject $running
                $restart = $true
                foreach ($process in $running) {
                    if (-not $process.WaitForExit(5000)) {
                        throw 'ClipBoardMess did not stop in time to update.'
                    }
                }
            }
            [IO.File]::Replace($temporaryPath, $exePath, [NullString]::Value)
        }
    }
    else {
        [IO.File]::Move($temporaryPath, $exePath)
    }
}
finally {
    if (Test-Path -LiteralPath $temporaryPath) {
        Remove-Item -LiteralPath $temporaryPath -Force
    }
    if ($restart) {
        Start-Process -FilePath $exePath -WorkingDirectory $InstallDir -WindowStyle Hidden
    }
}

if (-not $NoStartup) {
    $startupDir = [Environment]::GetFolderPath('Startup', 'Create')
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut((Join-Path $startupDir 'ClipBoardMess.lnk'))
    $shortcut.TargetPath = $exePath
    $shortcut.WorkingDirectory = $InstallDir
    $shortcut.Save()
    Write-Host 'ClipBoardMess will run when you sign in to Windows.'
}

if (-not $NoModifyPath) {
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if (($userPath -split ';') -notcontains $InstallDir) {
        $newPath = (@($InstallDir, $userPath) | Where-Object { $_ }) -join ';'
        [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
        Write-Host 'Open a new terminal to run ClipBoardMess from PATH.'
    }
}

Write-Host "Installed ClipBoardMess at $exePath"
