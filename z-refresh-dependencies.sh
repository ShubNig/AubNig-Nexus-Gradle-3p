#!/usr/bin/env bash

# this script need gradle android hone

# change this for module
android_build_module="test"

run_path=$(pwd)
shell_run_name=$(basename $0)
shell_run_path=$(cd `dirname $0`; pwd)

checkFuncBack(){
  if [ $? -ne 0 ]; then
    echo -e "\033[;31mRun [ $1 ] error exit code 1\033[0m"
    exit 1
  # else
  #   echo -e "\033[;30mRun [ $1 ] success\033[0m"
  fi
}

checkEnv(){
  evn_checker=`which $1`
  checkFuncBack "which $1"
  if [ ! -n "evn_checker" ]; then
    echo -e "\033[;31mCheck event [ $1 ] error exit\033[0m"
    exit 1
  # else
  #   echo -e "\033[;32mCli [ $1 ] event check success\033[0m\n-> \033[;34m$1 at Path: ${evn_checker}\033[0m"
  fi
}

checkGradleModule(){
    setting_gradle_path="${shell_run_path}/settings.gradle"
    if [ -f "${setting_gradle_path}" ]; then
        echo "Find settings gradle at: ${setting_gradle_path}"
    else
        echo "\033[;31mcan not find settings gradle at ${shell_run_path} exit\033[0m"
        exit 1
    fi
    find_module_set=`cat ${setting_gradle_path} | grep "$android_build_module"`
        if [ ! -n "$find_module_set" ]; then
            echo -e "\033[;31mcheck gradle module [ ${android_build_module} ] error\nYou are not setting $android_build_module at ${setting_gradle_path}\033[0m"
            exit 1
        else
            echo -e "check gradle module [ ${android_build_module} ] success\nAt Path: ${setting_gradle_path}\n-> setting is: ${find_module_set}"
        fi
        module_path="${shell_run_path}/${android_build_module}"
        if [ ! -d "${module_path}" ]; then
            echo -e "\033[;31mcheck gradle module [ ${android_build_module} ] error\nCode path not find\n->Set at: ${android_build_module}\n-> Want Path: ${module_path}\033[0m"
            exit 1
        fi
}


checkEnv git
checkEnv java
checkEnv android
checkEnv gradle
checkGradleModule

echo -e "now git pull, please wait..."
git pull
checkFuncBack "git pull"
git branch -v
git status

if [ ! -x "gradlew" ]; then
    echo "this path gradlew not exec just try to fix!"
    chmod +x gradlew
else
    echo "=> local gradlew can use"
fi

./gradlew -q ${android_build_module}:generateReleaseSources --refresh-dependencies