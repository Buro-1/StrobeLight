#!/bin/zsh

xcodebuild -project StrobeLight.xcodeproj -derivedDataPath docsData -scheme StrobeLight -destination 'platform=iOS Simulator,name=iPhone 14 Pro' -parallelizeTargets docbuild
mkdir doc_archives
cp -R `find docsData -type d -name "*.doccarchive"` doc_archives
$(xcrun --find docc) process-archive transform-for-static-hosting ./doc_archives/StrobeLight.doccarchive --hosting-base-path StrobeLight/ --output-path docs/$ARCHIVE_NAME