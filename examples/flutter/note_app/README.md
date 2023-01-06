# note_app

A simple note-taking app to demonstrate the use of the [Codenic Clean Architecture](https://arch.codenic.dev/) in Flutter.
The app contains the following features:
- Create, update and delete notes.
- View all notes in a paginated manner.
- Stream the 10 most recent notes.
- Automatically log success and failed operations.

## Video demo

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/7iZQWsIjXkU/maxresdefault.jpg)](https://www.youtube.com/watch?v=7iZQWsIjXkU)

## Getting Started

### 1. Clean the project
```bash
flutter clean 
flutter clean modules/domain
flutter clean modules/infrastructure
flutter clean modules/presentation
```

### 2. Fetch dependencies
```bash
flutter pub get modules/domain
flutter pub get modules/infrastructure
flutter pub get modules/presentation
flutter pub get
```
### 3. Run build runner
```bash
cd modules/infrastructure
flutter pub run build_runner build --delete-conflicting-outputs
```

### Alternative
If you have a Mac, you can run the `tool/prebuild.sh` command to do steps 1 to 3 all at once.

### 4. Run the project
```bash
flutter run
```

**Note:** Currently, the app can only run on Android, IOS and macOS platforms.
