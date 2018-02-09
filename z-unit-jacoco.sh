#!/usr/bin/env bash

# this script need gradle android hone

# change this for module
android_build_modules=
android_build_modules[0]=test
#android_build_modules[1]=module

product_flavors=""
product_flavors_list="osDev osTest osGld osProductive"
build_mode="Release"
hint_build_mode="release"

# change this for middle or last build job
android_build_task_middle="generate${product_flavors}${build_mode}Sources"
android_build_task_last="jacoco${product_flavors}${build_mode}Report"


is_clean_before_build=1

shell_run_path=$(cd `dirname $0`; pwd)
shell_run_name=$(basename $0)
shell_run_path=$(cd `dirname $0`; pwd)

pV(){
    echo -e "\033[;36m$1\033[0m"
}
pI(){
    echo -e "\033[;32m$1\033[0m"
}
pD(){
    echo -e "\033[;34m$1\033[0m"
}
pW(){
    echo -e "\033[;33m$1\033[0m"
}
pE(){
    echo -e "\033[;31m$1\033[0m"
}
#pV "V"
#pI "I"
#pD "D"
#pW "W"
#pE "E"
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
    if [ ! -n "${android_build_modules}" ]; then
        pE "you set [ android_build_modules ] is empty"
        exit 1
    fi

    setting_gradle_path="${shell_run_path}/settings.gradle"
    if [ ! -f "${setting_gradle_path}" ]; then
        pE "Can not find settings gradle at ${shell_run_path} exit"
        exit 1
#    else
#        echo "Find settings gradle at: ${setting_gradle_path}"
    fi
    for module in ${android_build_modules[@]};
    do
        find_module_set=`cat ${setting_gradle_path} | grep "$module" | awk 'gsub(/^ *| *$/,"")'`
        if [ ! -n "$find_module_set" ]; then
            pE "Check gradle module [ ${module} ] error\nYou are not setting $module at ${setting_gradle_path}"
            exit 1
        else
            cut_module_set=$(echo ${find_module_set} | cut -c 1-2)
#            echo -e "cut_module_set -> ${cut_module_set}"
            if [ "${cut_module_set}" == "//" ]; then
                pE "Check gradle module [ ${module} ] error\nAt Path: ${setting_gradle_path}\n-> include setting is: ${find_module_set}"
                exit 1
            else
                echo -e "check gradle module [ ${module} ] success\nAt Path: ${setting_gradle_path}\n-> include setting is: ${find_module_set}"
            fi
        fi
        module_path="${shell_run_path}/${module}"
        echo -e "module_path -> ${module_path}"
        if [ ! -d "${module_path}" ]; then
            pE "=> Check gradle module [ ${module} ] error\nCode path not find\n->Set at: ${module}\n-> Want Path: ${module_path}"
            exit 1
        else
            pI "Check gradle module [ ${module} ] success"
        fi
    done
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

if [ -n "$1" ];then
    pW "you are not set product_flavors, like ${product_flavors_list}, use default"
else
    product_flavors=$1
    android_build_task_middle="generate${product_flavors}${build_mode}Sources"
    android_build_task_last="jacoco${product_flavors}${build_mode}Report"
fi

if [ ${is_clean_before_build} -eq 1 ]; then
    echo "=> gradle task clean"
    ${shell_run_path}/gradlew clean
    checkFuncBack "${shell_run_path}/gradlew clean"
fi

for module in ${android_build_modules[@]};
do
    pI "-> gradle task ${module}:dependencies"
    ./gradlew -q ${module}:dependencies
    checkFuncBack "./gradlew -q ${module}:dependencies"
#    echo "-> gradle task ${module}:dependencies --refresh-dependencies"
#    ./gradlew -q ${module}:dependencies --refresh-dependencies
    pI "-> gradle task ${module}:${android_build_task_middle}"
    ./gradlew ${module}:${android_build_task_middle}
    checkFuncBack "./gradlew ${module}:${android_build_task_middle}"
    pI "-> gradle task ${module}:${android_build_task_last}"
    ./gradlew ${module}:${android_build_task_last}
    checkFuncBack "./gradlew ${module}:${android_build_task_last}"
    done

# jenkins config JUnit first Invoke Gradle script
echo -e "\nJenkins config \033[;36mInvoke Gradle script\033[0m"
echo -e "\033[;34mTasks\033[0m"
echo -e "clean --refresh-dependencies
generateReleaseSources
compileReleaseJavaWithJavac"

# jenkins config JUnit test Invoke Gradle script
echo -e "\nJenkins config \033[;36mInvoke Gradle script\033[0m"
echo -e "\033[;34mTasks\033[0m"
for module in ${android_build_modules[@]};
do
    echo -e ":${module}:jacoco${build_mode}Report"
    done

# jenkins config JUnit test result report
echo -e "\nJenkins config \033[;36mPublish JUnit test result report\033[0m"
echo -e "\033[;34mTest Report XML\033[0m"
for module in ${android_build_modules[@]};
do
#    echo -e "${module}/build/test-results/test${build_mode}UnitTest/${hint_build_mode}/*.xml,"
    echo -e "${module}/build/test-results/${hint_build_mode}/*.xml,"
    done

# jenkins config Record JaCoco coverage report
echo -e "\nJenkins config \033[;36mRecord JaCoco coverage report\033[0m"

echo -e "\033[;34mPath to exec files\033[0m"
for module in ${android_build_modules[@]};
do
    echo -e "${module}/build/jacoco/**.exec,"
    done
echo -e "\033[;34mPath to class directories\033[0m"
for module in ${android_build_modules[@]};
do
    echo -e "${module}/build/intermediates/classes/${hint_build_mode},"
    done
echo -e "\033[;34mPath to source directories\033[0m"
for module in ${android_build_modules[@]};
do
    echo -e "${module}/src/main/java,"
    done

echo -e "\033[;33mExclusions\033[0m"
echo -e "**/*Test.class,**/R.class,**/R\$*.class,**/Manifest*.*,android/**/*.*,**/BuildConfig.*,**/*\$ViewBinder*.*,**/*\$ViewInjector*.*,**/Lambda\$*.class,**/Lambda.class,**/*Lambda.class,**/*Lambda*.class,**/*\$.class,**/*ARouter\$*.class"

