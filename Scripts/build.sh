#!/bin/bash

# Application name
APP_NAME="YTPull"

# Application file name with `.app` extension
APP_FILE="$APP_NAME.app"

# Build directory
DIR="build"

# Clean up build directory
rm -rf $DIR/*

# Build
xcodebuild -project ../$APP_NAME.xcodeproj -scheme "$APP_NAME" -config Release -archivePath ./$DIR/$APP_NAME.xcarchive archive

# Archive
xcodebuild -archivePath ./$DIR/$APP_NAME.xcarchive -exportArchive -exportPath ./$DIR/ -exportOptionsPlist exportOptions.plist

# Go to build directory.
cd $DIR

# We need to verify whether the application file
# -d flag will be true if the YTPull.app name exists
if [ -d "$APP_FILE" ]; then

    # if application control will enter
    # creating a variable  filename to hold the 
    # new file name i.e. YTPull.app 
    # it will end with the extension ".zip".
    filename="$APP_NAME.zip"
    
    # Using tar --create option to create the
    # archive and --file to set the new filename
    tar --create --file="$filename" "$APP_FILE"
    echo -e "\033[1m** ARCHIVE $filename SUCCEEDED **"
    
    # if the application file does not exists 
    # we will simply display the following message 
    # to the screen
    else
        echo "WARNING: $APP_FILE doesn't exists"
  
fi