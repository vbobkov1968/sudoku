fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### test_all

```sh
[bundle exec] fastlane test_all
```

Run tests across all platforms

### analyze

```sh
[bundle exec] fastlane analyze
```

Run Flutter analyze

### upgrade_dependencies

```sh
[bundle exec] fastlane upgrade_dependencies
```

Run Flutter pub upgrade

### build_all

```sh
[bundle exec] fastlane build_all
```

Build all platforms (macOS, iOS, Android)

### clean_builds

```sh
[bundle exec] fastlane clean_builds
```

Clean build artifacts

### prepare_release

```sh
[bundle exec] fastlane prepare_release
```

Prepare for release: analyze, test, clean

----


## iOS

### ios build_ios

```sh
[bundle exec] fastlane ios build_ios
```

Build iOS app

### ios build_ios_test

```sh
[bundle exec] fastlane ios build_ios_test
```

Build iOS app for testing

----


## Mac

### mac build_macos

```sh
[bundle exec] fastlane mac build_macos
```

Build macOS app

### mac build_macos_test

```sh
[bundle exec] fastlane mac build_macos_test
```

Build macOS app for testing

----


## Android

### android build_android_apk

```sh
[bundle exec] fastlane android build_android_apk
```

Build Android app (APK)

### android build_android_aab

```sh
[bundle exec] fastlane android build_android_aab
```

Build Android app (AAB for Play Store)

### android build_android_test

```sh
[bundle exec] fastlane android build_android_test
```

Build Android app for testing

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
