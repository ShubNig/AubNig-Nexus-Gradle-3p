#!/usr/bin/env bash

# this script need gradle android hone

# change this for module
android_build_modules=
android_build_modules[0]=plugintemp
#android_build_modules[1]=next

# change this for default build Type
android_build_type="Release"
# change this for root job
android_build_task_generate="generate${android_build_type}Sources --refresh-dependencies"
android_build_task_compile="compile${android_build_type}JavaWithJavac"

# change this for module middle or last build job
android_build_task_first="dependencies"
android_build_task_middle="generate${android_build_type}Sources"
android_build_task_last="uploadArchives"

run_path=$(pwd)
shell_run_name=$(basename $0)
shell_run_path=$(cd `dirname $0`; pwd)

# build mode
build_mode="release"
is_force_build=0
is_clean_before_build=0
is_not_refresh_dependencies=0
is_all_product_flavors_build=0
default_origin_name="origin"

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

checkGitStatusClean(){
    git_status_line=$(git status -s | wc -l)
#    echo -e "git_status_line ${git_status_line}"
    if [[ git_status_line -ne 0 ]]; then
        pE "Now path: ${run_path}\nNot clean! You must use [ git status ] to check this"
        exit 1
    else
        pI "Check path: ${run_path}\nRun git status success"
    fi
}

local_tag_name=""
checkLocalIsGitTag(){
    now_commit_code=$(git branch -v | awk 'NR==1{print $3}')
#    echo -e "non_branch_code => ${now_commit_code}"
    local_tag_name=$(git tag --points-at ${now_commit_code})
#    echo -e "now_commit_code_tag => ${local_tag_name}"
}

checkGitRemoteSameBranchSame(){
    if [ -n "${local_tag_name}" ]; then
        echo -e "local git is tag => ${local_tag_name}"
        echo -e "No need to check local as ${default_origin_name}"
    else
        now_branch=$(git branch -v | grep "\*" | awk 'NR==1{print $2}')
        echo -e "now_branch => ${now_branch}"
        diff_branch_is_same=$(git remote show ${default_origin_name} | grep "^.*${now_branch} pushes to ${now_branch}.*$" | grep "up to date" | wc -l | awk 'gsub(/^ *| *$/,"")')
        echo -e "diff_branch_is_same => ${diff_branch_is_same}"
        if [ ${diff_branch_is_same} -ne 1 ]; then
            pE "Now path: ${run_path}\nNot same as origin! You must use [ git remote show origin ] to check this"
            exit 1
        else
            pI "Check path: ${run_path}\nLocal between origin as the same"
        fi
    fi
}

help_info="This script \033[;34m${shell_run_name}\033[0m can upload android project by gradle\n
\n
\t-h see help\n
You can use \033[;32m ${shell_run_name} -m snapshot\033[0m\n
\n
More configuration\n
\t-m [moduleName] set \033[;33mDefault mode is ${build_mode}, script will check git branch same as ${default_origin_name}\033[0m\n
\t\t[moduleName]\033[;32m only use snapshot tag release\033[0m\n
\t-c do clean task at begin of build\033[;36m ${shell_run_name} -c\033[0m\n
\t-r not --refresh-dependencies at ${android_build_task_generate} \033[;36m ${shell_run_name} -r\033[0m\n
\t-f force \033[;36m ${shell_run_name} -f force do gradle tasks\033[0m\n
"

if [ $# == 0 ]; then
    pE "unknown params, please see help -h"
    exit 1
elif [ $# == 1 ]; then
    if [ $1 == "-h" ]; then
       echo -e ${help_info}
       exit 0
    fi
else
    run_gradle_module=""
    other_module=""
    while getopts "hfcrm:" arg #after param has ":" need option
    do
        case ${arg} in
            h)
                echo -e ${help_info}
                exit 0
            ;;
            f)
                is_force_build=1
            ;;
            c)
                is_clean_before_build=1
            ;;
            r)
                is_not_refresh_dependencies=1
            ;;
            m)
                echo -e "=> Set build mode is [ \033[;32m${OPTARG}\033[0m ]"
                if [ ${OPTARG} == "snapshot" ]; then
                    build_mode=${OPTARG}
                elif [ ${OPTARG} == "tag" ]; then
                    build_mode=${OPTARG}
                elif [ ${OPTARG} == "release" ]; then
                    build_mode=${OPTARG}
                else
                    pE "Build mode is not support [ ${OPTARG} ]"
                    echo -e "Only support\033[;33m ( snapshot tag release )\033[0m"
                    exit 1
                fi
            ;;
        esac
    done
    if [ ${is_not_refresh_dependencies} -eq 1 ]; then
        android_build_task_generate="generate${android_build_type}Sources"
    fi
fi

if [ ! -n "$ANDROID_HOME" ]; then
    pE "You are not setting ANDROID_HOME stop build"
    exit 1
#else
#    echo -e "\033[;32mYou are setting ANDROID_HOME\nAt Path: ${ANDROID_HOME}\033[0m"
fi

checkEnv git
checkEnv java
checkEnv android
checkEnv gradle

checkGradleModules
echo -e "now git pull, please wait..."
git pull
checkFuncBack "git pull"
git branch -v
git status

#echo -e "is_force_build ${is_force_build}"
if [ ${is_force_build} -eq 0 ]; then
    if [ "${build_mode}" == "snapshot" ]; then
        pD "=> Now build mode is [ ${build_mode} ], script will not check status tag"
    elif [ "${build_mode}" == "tag" ]; then
        pW "=> Now build mode is [ ${build_mode} ], script will check git status and must be tag"
        checkGitStatusClean
        checkLocalIsGitTag
        if [ ! -n "${local_tag_name}" ]; then
            pE "This commit is not tag! So stop build"
            exit 1
        fi
    else
        pW "=> Now build mode is [ ${build_mode} ], script will check full"
        checkGitStatusClean
        checkLocalIsGitTag
        checkGitRemoteSameBranchSame
    fi
fi

if [ ! -x "gradlew" ]; then
    pW "this path gradlew not exec just try to fix!"
    chmod +x gradlew
#else
#    echo "=> local gradlew can use"
fi

if [ ${is_clean_before_build} -eq 1 ];then
    echo "=> gradle task clean"
    ${shell_run_path}/gradlew clean
    checkFuncBack "${shell_run_path}/gradlew clean"
fi

echo "=> gradle task ${android_build_task_generate}"
${shell_run_path}/gradlew ${android_build_task_generate}
checkFuncBack "${shell_run_path}/gradlew ${android_build_task_generate}"

echo "=> gradle task ${android_build_task_compile}"
${shell_run_path}/gradlew ${android_build_task_compile}
checkFuncBack "${shell_run_path}/gradlew ${android_build_task_compile}"

for module in ${android_build_modules[@]};
do
    pD "=> gradle task ${shell_run_path}/gradlew -q ${module}:${android_build_task_first}"
    ${shell_run_path}/gradlew -q ${module}:${android_build_task_first}
    checkFuncBack "${shell_run_path}/gradlew -q ${module}:${android_build_task_first}"
#    pD "-> gradle task ${module}:dependencies --refresh-dependencies"
#    ${shell_run_path}/gradlew -q ${module}:dependencies --refresh-dependencies
#    pD "-> gradle task -q ${module}:${android_build_task_middle}"
#    ${shell_run_path}/gradlew -q ${module}:${android_build_task_middle}
    pD "=> gradle task ${shell_run_path}/gradlew ${module}:${android_build_task_last}"
    ${shell_run_path}/gradlew ${module}:${android_build_task_last}
    checkFuncBack "${shell_run_path}/gradlew ${module}:${android_build_task_last}"
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

