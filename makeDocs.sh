#!/bin/zsh

swift package \
    --allow-writing-to-directory ./docs \
    generate-documentation --target StrobeLight \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path StrobeLightDocs \
    --output-path ./docs

