#!/bin/sh

# set -e

which butler

echo "Checking application versions..."
echo "-----------------------------"
cat ~/.local/share/godot/templates/4.0-rc2/version.txt
godot --version
butler -V
echo "-----------------------------"

mkdir build/
mkdir build/linux/
mkdir build/osx/
mkdir build/win/

echo "EXPORTING FOR LINUX"
echo "-----------------------------"
godot --headless --export-debug "Linux/X11" build/linux/rts-test-4.x86_64 -v
# echo "EXPORTING FOR OSX"
# echo "-----------------------------"
# godot --export "Mac OSX" build/osx/rts-test-4.dmg -v
echo "EXPORTING FOR WINDOZE"
echo "-----------------------------"
godot --headless --export-debug "Windows Desktop" build/win/rts-test-4.exe -v
echo "-----------------------------"

# echo "CHANGING FILETYPE AND CHMOD EXECUTABLE FOR OSX"
# echo "-----------------------------"
# cd build/osx/
# mv rts-test-4.dmg rts-test-4-osx-alpha.zip
# unzip rts-test-4-osx-alpha.zip
# rm rts-test-4-osx-alpha.zip
# chmod +x rts-test-4.app/Contents/MacOS/rts-test-4
# zip -r rts-test-4-osx-alpha.zip rts-test-4.app
# rm -rf rts-test-4.app
# cd ../../

ls -al
ls -al build/
ls -al build/linux/
ls -al build/osx/
ls -al build/win/

echo "ZIPPING FOR WINDOZE"
echo "-----------------------------"
cd build/win/
zip -r rts-test-4-win-alpha.zip rts-test-4.exe rts-test-4.pck
rm -r rts-test-4.exe rts-test-4.pck
cd ../../

echo "ZIPPING FOR LINUX"
echo "-----------------------------"
cd build/linux/
zip -r rts-test-4-linux-alpha.zip rts-test-4.x86_64 rts-test-4.pck
rm -r rts-test-4.x86_64 rts-test-4.pck
cd ../../

echo "Logging in to Butler"
echo "-----------------------------"
butler login

echo "Pushing builds with Butler"
echo "-----------------------------"
butler push build/linux/ synsugarstudio/rts-test:linux-alpha
# butler push build/osx/ synsugarstudio/rts-test:osx-alpha
butler push build/win/ synsugarstudio/rts-test:win-alpha
