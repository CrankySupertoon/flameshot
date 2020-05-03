#!/bin/bash

# Update and install QT in system
brew update > /dev/null
brew install qt

# Setting QT and build folders
QT_FOLDER=/usr/local/opt/qt
BUILD_FOLDER=build/

# Move to root and assign .pro and dist vars
cd ..
PRO_FILE=$(/bin/pwd)/flameshot.pro
DIST_FOLDER=$(/bin/pwd)/dist

# Clean previous build
rm -rf $BUILD_FOLDER

# Create build folder and go to it
mkdir $BUILD_FOLDER
cd $BUILD_FOLDER

# Update build folder
BUILD_FOLDER=$(/bin/pwd)

# Qmake and Make
qmake CONFIG-=debug CONFIG+=release CONFIG+=packaging $PRO_FILE
make

# Clone macdeployqtfix to adjust .app
git clone https://github.com/aurelien-rainone/macdeployqtfix.git

# Run QT macdeployqt
${QT_FOLDER}/bin/macdeployqt flameshot.app

# Run macdeployqtfix to adjust .app
python macdeployqtfix/macdeployqtfix.py flameshot.app/Contents/MacOS/flameshot ${QT_FOLDER}

# Create dist folder
mkdir -p $DIST_FOLDER
cd $DIST_FOLDER

# Make Flameshot dmg folder
mkdir Flameshot
cd Flameshot

# Move flameshot.app folder to dmg and create Applications shortcut in it
mv $BUILD_FOLDER/flameshot.app .
ln -s /Applications ./Applications

# Go back to dist folder
cd ..

# Generate dmg file
hdiutil create -srcfolder ./Flameshot -format UDBZ ./flameshot.dmg

# Remove build folder
rm -rf $BUILD_FOLDER