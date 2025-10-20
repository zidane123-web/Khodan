$ErrorActionPreference = "Stop"

flutter format --set-exit-if-changed lib test
flutter analyze
flutter test
