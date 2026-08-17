# VS Code AppImage

Unofficial AppImage build of Visual Studio Code for Linux.

This project repackages the official Visual Studio Code `.deb` package into
an AppImage.

## Disclaimer

This is an unofficial community project and is not affiliated with,
endorsed by, or officially supported by Microsoft.

Visual Studio Code is a product of Microsoft.

## How it works

The build process is:

1. Download the official VS Code `.deb` package.
2. Extract `data.tar.*`.
3. Create an AppImage AppDir.
4. Add the `AppRun` launcher.
5. Fix the desktop entry for AppImage execution.
6. Add AppImage metadata.
7. Build the final `.AppImage` using `appimagetool`.

## Building locally

Requirements:

- Bash
- `curl`
- `ar`
- `tar`
- `appimagetool`

Set the VS Code version:
```bash
export VERSION=1.133.0
```

Set the path to `appimagetool`:
```bash
export APPIMAGETOOL="$PWD/appimagetool"
```

Then:
```bash
chmod +x build.sh
./build.sh
```

The resulting file will be:
```bash
VSCode-x86_64-1.133.0.AppImage
```

## GitHub Actions

Releases are automatically built when a `v*` Git tag is pushed.

Example:
```bash
git tag v1.133.0
git push origin v1.133.0
```

GitHub Actions will build the AppImage and create a GitHub Release
automatically.

## License

The build scripts in this repository are provided under the GNU General
Public License v3.0.

Visual Studio Code and its trademarks belong to Microsoft.