#!/bin/sh

echo 'Clean project...'

flutter clean &
flutter clean modules/domain &
flutter clean modules/infrastructure & flutter clean modules/presentation

echo 'Get dependencies...'

flutter pub get modules/domain
flutter pub get modules/infrastructure & flutter pub get modules/presentation
flutter pub get

echo 'Run builder runner...'

cd modules/infrastructure
flutter pub run build_runner build --delete-conflicting-outputs