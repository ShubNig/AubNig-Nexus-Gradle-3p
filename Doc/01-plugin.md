# Dependency

at root project `build.gradle`

```gradle
...

allprojects {
    repositories {
        // do not use same URL with job module!
        if (isReleaseBuild()) {
            maven { url RELEASE_REPOSITORY_URL }
        } else {
            maven { url SNAPSHOT_REPOSITORY_URL }
        }
        jcenter()
    }
}
```

- RELEASE_REPOSITORY_URL set `Job module`at `${ProjectRoot}/gradle.properties`
- SNAPSHOT_REPOSITORY_URL set `Job module`at `${ProjectRoot}/gradle.properties`

you can set like `file:///Users/user/Downloads/mvn-repo/release/` when use local build

in module `build.gradle`

```gradle
dependencies {
    compile 'com.sinlov.android:plugin:0.0.1'
}
```

out `*.apk` in `app/build/outApk/`

# Usage

`just write use of lib`