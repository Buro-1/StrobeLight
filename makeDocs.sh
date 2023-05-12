#!/bin/zsh

swift package \
    --allow-writing-to-directory ./docs \
    generate-documentation \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path StrobeLight \
    --output-path ./docs

