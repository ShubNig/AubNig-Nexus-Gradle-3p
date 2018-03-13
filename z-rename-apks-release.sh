#!/usr/bin/env bash

build_tag="Sinlov-App"
build_module_name="test"
build_product_flavors=
build_product_flavors[0]="dev"
build_product_flavors[1]="prod"
#build_product_flavors[2]="test"
build_mode="release"

check_count_apk_for_rename(){
    if [ -d "${build_module_name}/build/outputs/apk/" ]; then
        rename_apk_count=$(find "${build_module_name}/build/outputs/apk/" -name "*.apk" | wc -l | awk 'gsub(/^ *| *$/,"")')
        echo -e "Find Out build Apk Count: ${rename_apk_count}\n"
    else
        echo -e "can not find outputs apk!"
        exit 1
    fi
}

rename_apk(){
    apk_file=$(find "${build_module_name}/build/outputs/apk" -name "*-*$1.apk")
    if [ -n "${apk_file}" ]; then
        now_time=$(date "+%Y-%m-%d-%H-%M")
        new_tag="${now_time}__$RANDOM"
        new_name="${build_module_name}/build/outputs/apk/${build_tag}-${project_version_name}-$1-${new_tag}.apk"
        echo -e "From apk: ${apk_file} \nTo NewApk: ${new_name}"
        mv "${apk_file}" "${new_name}"
    fi
}
rename_apk_by_module(){
    apk_file=$(find "${build_module_name}/build/outputs/apk" -name "*$1-*$2.apk")
    if [ -n "${apk_file}" ]; then
        now_time=$(date "+%Y-%m-%d-%H-%M")
        new_tag="${now_time}__$RANDOM"
        new_name="${build_module_name}/build/outputs/apk/${build_tag}-${project_version_name}-$1-${new_tag}.apk"
        echo -e "From apk: ${apk_file} \nTo NewApk: ${new_name}"
        mv "${apk_file}" "${new_name}"
    fi
}


# get from gradle.properties
version_name_line=`cat gradle.properties | grep VERSION_NAME=`
versionNameTmp=`echo ${version_name_line#*\"}`
versionNameStr=`echo ${versionNameTmp%\"*}`
version_code_line=`cat gradle.properties | grep VERSION_CODE=`
versionCodeTmp=`echo ${version_code_line#*\"}`
versionCodeStr=`echo ${versionCodeTmp%\"*}`


# slice lines
OLD_IFS="$IFS"
IFS="="
version_name_arr=(${versionNameStr})
version_code_arr=(${versionCodeStr})
IFS="$OLD_IFS"

project_version_name=${version_name_arr[1]}
project_version_code=${version_code_arr[1]}

if [ ! -n "${project_version_name}" ]; then
    echo "gradle.properties VERSION_NAME is empty"
    exit 1
fi

if [ ! -n "${project_version_code}" ]; then
    echo "gradle.properties VERSION_CODE is empty"
    exit 1
fi

module_len=${#build_product_flavors[@]}
if [ ${module_len} -le 0 ]; then
    echo "you set [ build_product_flavors ] size is 0"
    exit 1
fi

echo -e "Now Rename Info\n
\tBuild Tag: ${build_tag}
\tModule_name: ${build_module_name}
\tProduct_flavors: ${build_product_flavors[@]}
\tBuild_mode: ${build_mode}
\tVersionName: ${project_version_name}
\tVersionCode: ${project_version_code}
\n"

check_count_apk_for_rename
echo -e "${build_product_flavors[@]}"
if [ -n ${#build_product_flavors[@]} ]; then
       echo "-> rename apk build mode: ${build_mode}"
      rename_apk ${build_mode}
else
    for product_flavor in ${build_product_flavors[@]};
    do
        echo "-> rename apk product_flavor name: ${product_flavor}"
        rename_apk_by_module "${product_flavor}" ${build_mode}
        done
    exit 0
fi
