#!/bin/bash

DIR="build"

rm -rf $DIR/*

xcodebuild -project YTPull.xcodeproj -scheme "YTPull" -config Release -archivePath ./$DIR/YTPull.xcarchive archive

xcodebuild -archivePath ./$DIR/YTPull.xcarchive -exportArchive -exportPath ./$DIR/ -exportOptionsPlist exportOptions.plist