#!/usr/bin/env bash

# this script need gradle android hone

# change this for module
android_build_modules=
android_build_modules[0]=plugintemp
#android_build_modules[1]=next

# change this for middle or last build job
android_build_task_middle="generateReleaseSources"
android_build_task_last="uploadArchives"

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

checkGradleModules(){
    module_len=${#android_build_modules[@]}
    if [ ${module_len} -le 0 ]; then
        echo "you set [ android_build_modules ] is empty"
        exit 1
    fi

    setting_gradle_path="${shell_run_path}/settings.gradle"
    if [ -f "${setting_gradle_path}" ]; then
        echo "Find settings gradle at: ${setting_gradle_path}"
    else
        echo "can not find settings gradle at ${shell_run_path} exit"
        exit 1
    fi
    for module in ${android_build_modules[@]};
    do
        find_module_set=`cat ${setting_gradle_path} | grep "$module"`
        if [ ! -n "$find_module_set" ]; then
            echo -e "check gradle module [ ${module} ] error\nYou are not setting $module at ${setting_gradle_path}"
            exit 1
        else
            echo -e "check gradle module [ ${module} ] success\nAt Path: ${setting_gradle_path}\n-> setting is: ${find_module_set}"
        fi
        module_path="${shell_run_path}/${module}"
        if [ ! -d "${module_path}" ]; then
            echo -e "check gradle module [ ${module} ] error\nCode path not find\n->Set at: ${module}\n-> Want Path: ${module_path}"
            exit 1
        fi
    done
}

checkGitStatus(){
    git_status_line=$(git status -s | wc -l)
#    echo -e "git_status_line ${git_status_line}"
    if [[ git_status_line -ne 0 ]]; then
        echo -e "\033[;31mNow path: ${run_path}\nNot clean! You must use [ git status ] to check this\033[0m"
        exit 1
    else
        echo -e "\033[;36mCheck path: ${run_path}\nRun git status success\033[0m"
    fi
}

checkGitRemoteSameBranchSame(){
    now_branch=$(git branch -v | awk 'NR==1{print $2}')
    echo -e "now_branch => ${now_branch}"
    diff_branch_is_same=$(git remote show origin | grep "^.*${now_branch} pushes to ${now_branch}.*$" | grep "up to date" | wc -l | awk 'gsub(/^ *| *$/,"")')
    echo -e "diff_branch_is_same => ${diff_branch_is_same}"
    if [ ${diff_branch_is_same} -ne 1 ]; then
        echo -e "\033[;31mNow path: ${run_path}\nNot same as origin! You must use [ git remote show origin ] to check this\033[0m"
        exit 1
    else
        echo -e "\033[;36mCheck path: ${run_path}\nRun git origin as the same\033[0m"
    fi
}

if [ ! -n "$ANDROID_HOME" ]; then
    echo "You are not setting ANDROID_HOME stop build"
    exit 1
else
    echo -e "You are setting ANDROID_HOME\nAt Path: ${ANDROID_HOME}"
fi

checkEnv git
checkEnv java
checkEnv android
checkEnv gradle
checkGradleModules

if [ ! -x "gradlew" ]; then
    echo "this path gradlew not exec just try to fix!"
    chmod +x gradlew
else
    echo "=> local gradlew can use"
fi

echo -e "now git pull, please wait..."
git pull
checkFuncBack "git pull"
git branch -v
git status
checkGitStatus
checkGitRemoteSameBranchSame

# if want clean unlock this
echo "-> gradle task clean"
./gradlew clean

for module in ${android_build_modules[@]};
do
    echo "-> gradle task ${module}:dependencies"
    ./gradlew -q ${module}:dependencies
#    echo "-> gradle task ${module}:dependencies --refresh-dependencies"
#    ./gradlew -q ${module}:dependencies --refresh-dependencies
    echo "-> gradle task ${module}:${android_build_task_middle}"
    ./gradlew ${module}:${android_build_task_middle}
    echo "-> gradle task ${module}:${android_build_task_last}"
    ./gradlew ${module}:${android_build_task_last}
    done

# jenkins config first Invoke Gradle script
echo -e "\nJenkins config \033[;36mInvoke Gradle script\033[0m"
echo -e "\033[;34mTasks\033[0m"
echo -e "clean
generateReleaseSources --refresh-dependencies
compileReleaseJavaWithJavac"

# jenkins config test Invoke Gradle script
echo -e "\nJenkins config \033[;36mInvoke Gradle script\033[0m"
echo -e "\033[;34mTasks\033[0m"
for module in ${android_build_modules[@]};
do
    echo -e ":${module}:uploadArchives"
    done

