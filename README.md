[TOC]

# Env

Project Runtime:

|title|description|
|-----|-----------|
|jdk|1.8.+|
|gradle|3.3.+|
|Android Studio|3.0.1|
|com.android.tools.build:gradle|3.0.1|
|appcompat-v7|26.1.0|
|compile SDK version|26|
|build tools version|26.0.0|
|target SDK version|16|
|min SDK version|16|

## Less Runtime

- Android API 26
- Android Studio 3.0.0
- appcompat-v7:23.4.0
- Gradle 3.3
- com.android.tools.build:gradle:3.0.0
- minSdkVersion 15

test Runtime see `package.gradle` test_implement


# Last Version Info

- version 0.0.1
- repo at

provides :
- ~~Full method count 00~~

# Depends

load by `root build.gradle`

```
apply from: rootProject.file("package.gradle")
```

and all depend see in `$project_root/package.gradle`

use by

```gradle
dependencies{
    // in app
    implementation depends.butterknife
    // in moudle
    api depends_com_android_support.appcompat_7
}
```

# Build

- module-all-uploadArchives

```sh
./z-module-all-uploadArchives
```

> windows just edit and run `z-module-all-uploadArchives.bat`

- APK for test

```
./gradlew installDebug
```

- change uploadArchives

edit root `gradle.properties`

|key|value|
|-----|--------|
|VERSION_NAME|version of project name|
|VERSION_CODE|version of code|
|NEXUS_USERNAME|nexus user name|
|NEXUS_PASSWORD|nexus pass word|
|RELEASE_REPOSITORY_URL|release url|
|SNAPSHOT_REPOSITORY_URL|snapshot url|

> VERSION_NAME has `SNAPSHOT` will upload to snapshot!

edit module `gradle.properties`

|key|value|
|-----|--------|
|POM_ARTIFACT_ID|artifact id|


### License

---
