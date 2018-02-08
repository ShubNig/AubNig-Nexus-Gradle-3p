@rem this script need gradle android hone
where java
where gradle
where android

call gradlew.bat clean

call gradlew.bat plugin:dependencies
@rem call gradlew.bat plugin: --refresh-dependencies
call gradlew.bat plugin:generateReleaseSources --refresh-dependencies
call gradlew.bat plugin:uploadArchives
