# ClipBoardMess

ClipBoardMess watches the Windows clipboard and occasionally replaces copied text with a prompt.

## Install on Windows

```powershell
powershell -ExecutionPolicy Bypass -c "irm https://anytokin.github.io/ClipBoardMess/install.ps1 | iex"
```

The installer puts the EXE in `%LOCALAPPDATA%\Programs\ClipBoardMess`, adds it to your user PATH, and creates a shortcut in your Windows Startup folder. The app starts at your next sign-in. Use `-NoStartup` to skip creating the shortcut or manage the existing entry in **Settings > Apps > Startup**. Use `-NoModifyPath` to skip the PATH change.

To install from a downloaded release, save `install.ps1` and `ClipBoardMess.exe` in the same directory and run the command below from that directory. [GitHub Releases](https://github.com/anytokin/ClipBoardMess/releases/latest)

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1 -SourceExe .\ClipBoardMess.exe
```

## Build from source

```powershell
uv sync --locked
uv run --locked pyinstaller --onefile --noconsole --name ClipBoardMess --add-data "src/clipboardmess/prompts.txt:." src/clipboardmess/main.py
```
