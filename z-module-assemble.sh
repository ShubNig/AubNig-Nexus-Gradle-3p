#!/usr/bin/env bash

# this script need gradle android hone
gradle_tools_version="3"

# change this for module
android_build_modules=
android_build_modules[0]="test"
#android_build_modules[1]=next

# change this for productFlavors
product_flavors=
#product_flavors[0]="Dev"
#product_flavors[1]="Test"
#product_flavors[2]="Prod"

# change this for default build Type
android_build_type="Debug"
# change this for root job
android_build_task_env="buildEnvironment"
android_build_task_root_compile="compile${android_build_type}Sources"

# change this for module middle or last build job
android_build_task_dependencies="dependencies"
android_build_task_gen="generate${android_build_type}Sources compile${android_build_type}JavaWithJavac"
android_build_task_last="assemble${android_build_type}"

# dependencies config default set
android_build_task_dependencies_config="compile"

run_path=$(pwd)
shell_run_name=$(basename $0)
shell_run_path=$(cd `dirname $0`; pwd)

# build mode
build_mode="release"
is_force_build=0
is_clean_before_build=0
is_not_refresh_dependencies=0
is_run_task_root_compile=1
is_all_product_flavors_build=0
is_run_module_generate=0
default_origin_name="origin"
only_product_flavors_build=""

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

strEachHeadUpperCase(){
    echo $* | awk '{for (i=1;i<=NF;i++)printf toupper(substr($i,0,1))substr($i,2,length($i))" ";printf "\n"}' | awk 'gsub(/^ *| *$/,"")'
}

strEachHeadLowerCase(){
    echo $* | awk '{for (i=1;i<=NF;i++)printf tolower(substr($i,0,1))substr($i,2,length($i))" ";printf "\n"}' | awk 'gsub(/^ *| *$/,"")'
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
    now_commit_code=$(git rev-parse HEAD)
#    echo -e "non_branch_code => ${now_commit_code}"
    local_tag_name=$(git tag --points-at ${now_commit_code})
#    echo -e "now_commit_code_tag => ${local_tag_name}"
}

checkGitRemoteSameBranchSame(){
    if [ -n "${local_tag_name}" ]; then
        echo -e "local git is tag => ${local_tag_name}"
        echo -e "No need to check local as ${default_origin_name}"
    else
        now_branch=$(git branch -vv | grep "\*" | awk 'NR==1{print $2}')
        cut_now_branch=$(echo ${find_module_set} | cut -c 1-2)
        if [ "${now_branch}" == "(" ]; then
            now_branch=$(git branch -vv | grep "\*" | awk 'NR==1{print $6}')
            now_branch=$($(git branch -vv | grep ${now_branch}) | awk 'NR==1{print $2}')
        fi
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
\t\t moduleName\033[;32m only use snapshot tag release\033[0m\n
\t-t [buildType] set \033[;33mDefault build type is ${android_build_type}\033[0m\n
\t\t buildType \033[;32m only use debug release\033[0m\n
\t-p [productFlavors] \033[;36m ${shell_run_name} do only this productFlavors tasks\033[0m\n
\t-a [all] productFlavors \033[;36m ${shell_run_name} force do all productFlavors tasks\033[0m\n
\t\t \033[;32m-a will cover -p\033[0m\n
\t-c [clean] do clean task at begin of build\033[;36m ${shell_run_name} -c\033[0m\n
\t-s [silence] not run task at root ${android_build_task_root_compile} \033[;36m ${shell_run_name} -s\033[0m\n
\t-n [no-refresh] not --refresh-dependencies at ${android_build_task_env} \033[;36m ${shell_run_name} -r\033[0m\n
\t-g [gen] task ${android_build_task_gen} \033[;36m ${shell_run_name} -g run at checked module gen\033[0m\n
\t-f [force] \033[;36m ${shell_run_name} -f force do gradle tasks not check\033[0m\n
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
    while getopts "hfcangsm:t:p:" arg #after param has ":" need option
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
            a)
                is_all_product_flavors_build=1
            ;;
            n)
                is_not_refresh_dependencies=1
            ;;
            g)
                is_run_module_generate=1
            ;;
            s)
                is_run_task_root_compile=0
            ;;
            m)
                echo -e "=> Set build mode is [ \033[;32m${OPTARG}\033[0m ]"
                if [ ${OPTARG} == "snapshot" ]; then
                    build_mode=${OPTARG}
                elif [ ${OPTARG} == "tag" ]; then
                    build_mode=${OPTARG}
                elif [ ${OPTARG} == "release" ]; then
                    android_build_type=${OPTARG}
                else
                    pE "Build mode is not support [ ${OPTARG} ]"
                    echo -e "Only support\033[;33m ( snapshot tag release )\033[0m"
                    exit 1
                fi
            ;;
            t)
                echo -e "-> Set build type is [ \033[;32m${OPTARG}\033[0m ]"
                if [ ${OPTARG} == "debug" ]; then
                    android_build_type="Debug"
                elif [ ${OPTARG} == "release" ]; then
                    android_build_type="Release"
                else
                    pE "Build type is not support [ ${OPTARG} ]"
                    echo -e "Only support\033[;33m ( debug release )\033[0m"
                    exit 1
                fi
                android_build_task_env="buildEnvironment"
                android_build_task_root_compile="compile${android_build_type}Sources"
                android_build_task_gen="generate${android_build_type}Sources compile${android_build_type}JavaWithJavac"
                android_build_task_last="assemble${android_build_type}"
            ;;
            p)
                echo -e "=> Set productFlavors only is [ \033[;32m${OPTARG}\033[0m ]"
                only_product_flavors_build=${OPTARG}
            ;;
        esac
    done
    if [ ${is_not_refresh_dependencies} -eq 1 ]; then
        android_build_task_env="buildEnvironment"
    else
        android_build_task_env="buildEnvironment --refresh-dependencies"
    fi
    if [[ "${gradle_tools_version}" == "3" ]]; then
        android_build_task_dependencies_config="compileClasspath"
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
#checkFuncBack "git pull"
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
else
    pW "=> now build mode is force, not check!"
fi

if [ ! -x "gradlew" ]; then
    pW "=> this path gradlew not exec just try to fix!"
    chmod +x gradlew
#else
#    echo "=> local gradlew can use"
fi

if [ ${is_clean_before_build} -eq 1 ]; then
    echo "=> gradle task clean"
    ${shell_run_path}/gradlew clean
    checkFuncBack "${shell_run_path}/gradlew clean"
else
    pW "=> this build not run task graldew clean"
fi

echo "=> gradle task ${android_build_task_env}"
${shell_run_path}/gradlew ${android_build_task_env}
checkFuncBack "${shell_run_path}/gradlew ${android_build_task_env}"

if [ ${is_run_task_root_compile} -eq 1 ]; then
    echo "=> gradle task ${android_build_task_root_compile}"
    ${shell_run_path}/gradlew ${android_build_task_root_compile}
    checkFuncBack "${shell_run_path}/gradlew ${android_build_task_root_compile}"
else
    pW "=> now project not run task ${android_build_task_root_compile}"
fi

for module in ${android_build_modules[@]};
do
    if [ ! -n "${only_product_flavors_build}" ]; then
        if [ ! -n "${product_flavors}" ]; then
            pI "You set build productFlavor is None, so do All"
            pD "=> gradle task ${shell_run_path}/gradlew -q ${module}:${android_build_task_dependencies}"
            ${shell_run_path}/gradlew -q ${module}:${android_build_task_dependencies}
            checkFuncBack "${shell_run_path}/gradlew -q ${module}:${android_build_task_dependencies}"
        else
            for product_flavor in ${product_flavors[@]};
            do
                dependencies_config="`strEachHeadLowerCase ${product_flavor}``strEachHeadUpperCase ${android_build_type}``strEachHeadUpperCase ${android_build_task_dependencies_config}`"
                android_build_task_dependencies_each="${android_build_task_dependencies} --configuration ${dependencies_config}"
                pD "=> gradle task ${shell_run_path}/gradlew -q ${module}:${android_build_task_dependencies_each}"
                ${shell_run_path}/gradlew -q ${module}:${android_build_task_dependencies_each}
                checkFuncBack "${shell_run_path}/gradlew -q ${module}:${android_build_task_dependencies_each}"
                done
        fi
    else
        dependencies_config="`strEachHeadLowerCase ${only_product_flavors_build}``strEachHeadUpperCase ${android_build_type}``strEachHeadUpperCase ${android_build_task_dependencies_config}`"
        android_build_task_dependencies="${android_build_task_dependencies} --configuration ${dependencies_config}"
        pD "=> gradle task ${shell_run_path}/gradlew -q ${module}:${android_build_task_dependencies}"
        ${shell_run_path}/gradlew -q ${module}:${android_build_task_dependencies}
        checkFuncBack "${shell_run_path}/gradlew -q ${module}:${android_build_task_dependencies}"
    fi

    last_run_head=""
    if [ ${is_not_refresh_dependencies} -eq 1 ]; then
        last_run_head="/gradlew --profile"
    else
        last_run_head="/gradlew --profile --refresh-dependencies"
    fi
    if [ ${is_all_product_flavors_build} -eq 1 ];then
        pI "You set build productFlavor is All"
        pI "=> gradle task ${shell_run_path}/gradlew ${module}:${android_build_task_last}"
        ${shell_run_path}${last_run_head} ${module}:${android_build_task_last}
        checkFuncBack "${shell_run_path}${last_run_head} ${module}:${android_build_task_last}"
    else
        if [ ! -n "${only_product_flavors_build}" ]; then
            if [ ! -n "${product_flavors}" ]; then
                pI "You set build productFlavor is None, so do All"
                pI "=> gradle task ${shell_run_path}${last_run_head} ${module}:${android_build_task_last}"
                ${shell_run_path}${last_run_head} ${module}:${android_build_task_last}
                checkFuncBack "${shell_run_path}${last_run_head} ${module}:${android_build_task_last}"
            else
                for product_flavor in ${product_flavors[@]};
                do
                    if [ ${is_run_module_generate} -eq 1 ]; then
                        android_build_task_gen=":${module}:generate${product_flavors}${android_build_type}Sources :${module}:compile${product_flavors}${android_build_type}JavaWithJavac"
                        pD "-> gradle task -q ${android_build_task_gen}"
                        ${shell_run_path}/gradlew -q ${android_build_task_gen}
                        checkFuncBack "${shell_run_path}/gradlew -q ${android_build_task_gen}"
                    fi
                    android_build_task_last="assemble${product_flavors}${android_build_type}"
                    ${shell_run_path}${last_run_head} ${module}:tasks --all| grep ${android_build_task_last}
                    checkFuncBack "${shell_run_path}${last_run_head} ${module}:tasks --all | grep ${android_build_task_last}"
                    pI "=> gradle task ${shell_run_path}${last_run_head} ${module}:${android_build_task_last}"
                    ${shell_run_path}${last_run_head} ${module}:${android_build_task_last}
                    checkFuncBack "${shell_run_path}${last_run_head} ${module}:${android_build_task_last}"
                done
            fi
        else
            if [ ${is_run_module_generate} -eq 1 ]; then
                android_build_task_gen=":${module}:generate${only_product_flavors_build}${android_build_type}Sources :${module}:compile${only_product_flavors_build}${android_build_type}JavaWithJavac"
                pD "-> gradle task -q ${android_build_task_gen}"
                ${shell_run_path}/gradlew -q ${android_build_task_gen}
                checkFuncBack "${shell_run_path}/gradlew -q ${android_build_task_gen}"
            fi
            android_build_task_last="assemble${only_product_flavors_build}${android_build_type}"
            ${shell_run_path}${last_run_head} ${module}:tasks --all| grep ${android_build_task_last}
            checkFuncBack "${shell_run_path}${last_run_head} ${module}:tasks --all| grep ${android_build_task_last}"
            pI "=> gradle task ${shell_run_path}${last_run_head} ${module}:${android_build_task_last}"
            ${shell_run_path}${last_run_head} ${module}:${android_build_task_last}
            checkFuncBack "${shell_run_path}${last_run_head} ${module}:${android_build_task_last}"
        fi
    fi
    done


# jenkins config first Invoke Gradle script
echo -e "\nJenkins config \033[;36mInvoke Gradle script\033[0m"
echo -e "\033[;34mTasks\033[0m"
echo -e "clean
buildEnvironment --refresh-dependencies
compileReleaseSources"

# jenkins config test Invoke Gradle script
echo -e "\nJenkins config \033[;36mInvoke Gradle script\033[0m"
echo -e "\033[;34mTasks\033[0m"
for module in ${android_build_modules[@]};
do
    echo -e ":${module}:assemble"
    done

