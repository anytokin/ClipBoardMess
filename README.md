# ClipBoardMess

ClipBoardMess watches the Windows clipboard and occasionally replaces copied text with a prompt.

## Install on Windows

For this private repository, sign in with GitHub CLI, then download and run the release installer from a new directory.

```powershell
gh release download -R anytokin/ClipBoardMess --pattern install.ps1 --pattern ClipBoardMess.exe
powershell -ExecutionPolicy Bypass -File .\install.ps1 -SourceExe .\ClipBoardMess.exe
```

The installer puts the EXE in `%LOCALAPPDATA%\Programs\ClipBoardMess`, adds it to your user PATH, and creates a shortcut in your Windows Startup folder. The app starts at your next sign-in. Use `-NoStartup` to skip creating the shortcut or manage the existing entry in **Settings > Apps > Startup**. Use `-NoModifyPath` to skip the PATH change.

When GitHub Pages is enabled with GitHub Actions as the publishing source, the tagged release workflow also publishes the installer and EXE to Pages.

```powershell
powershell -ExecutionPolicy Bypass -c "irm https://anytokin.github.io/ClipBoardMess/install.ps1 | iex"
```

## Build from source

```powershell
uv sync --locked
uv run --locked pyinstaller --onefile --noconsole --name ClipBoardMess --add-data "src/clipboardmess/prompts.txt:." src/clipboardmess/main.py
```
