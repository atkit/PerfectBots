# Makefile for SwiftBot
.DEFAULT_GOAL := build

# Few shortcuts for swift package manager

install:
	Scripts/install.py Sources/SwiftBot/config.swift

generate:
	swift package generate-xcodeproj

test:
	swift test

build:
	swift build
	
lint:
	if which swiftlint >/dev/null; then swiftlint; else echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"; fi	

debug:
	if [ "$(brew services list mysql | grep '^mysql' | awk '{print $$2}')" == "started" ]; then brew services start mysql ; mysql -uroot <<<"CREATE DATABASE IF NOT EXISTS swiftbot" ; fi
	.build/debug/PerfectBot
