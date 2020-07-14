#!/bin/bash

packages_folder=$(pwd)

check_os_tag() {
    local distro
    distro="$(./get_plat_tag.sh)"

    local ostag
    case ${distro} in
    ASTRALINUX_64*)
        ostag="a2"
        ;;
    UBUNTU20_64*)
        ostag="u20"
        ;;
    UBUNTU18_64)
        ostag="u18"
        ;;
    RHEL8*)
        ostag="r8"
        ;;
    RHEL7*)
        ostag="r7"
        ;;
    esac
    echo "${distro}.${ostag}"
}

os_tag="$(check_os_tag)"

cat build-order | while read line; do
    path=$line
    name=${line/zimbra\//}
    zimbra_name=$(echo "zimbra-$name" | sed 's/thirdparty\///g')
    echo "######## $zimbra_name ###############################################################"
    cd "$packages_folder/$line"

    if [[ "${os_tag%%.*}" =~ "UBUNTU" ]] || [[ "${os_tag%%.*}" =~ "ASTRALINUX" ]]; then
        if [[ $(ls build/"${os_tag%%.*}"/zimbra-*.deb 2>&1) == *"No such"* ]]; then
            if [[ $line == "thirdparty"* ]]; then
                make setup
                if [[ $(grep -r "^getsrc:" Makefile) != "" ]]; then
                    make getsrc
                fi
                if [[ $line == "thirdparty/openssl" ]]; then
                    make build
                fi
                make $1
                if [[ $1 != "clean" ]]; then
                    if [[ $(ls build/"${os_tag%%.*}"/zimbra-*.deb 2>&1) == *"No such"* ]]; then
                        echo "Compilation error!"
                        exit 1
                    else
                        dpkg -i build/"${os_tag%%.*}"/zimbra-*.deb
                    fi
                fi
            fi
        fi
    else
        if [[ $(ls build/"${os_tag%%.*}"/"$zimbra_name"/rpm/RPMS/x86_64/*.rpm 2>&1) == *"No such"* ]]; then
            if [[ $line == "thirdparty"* ]]; then
                make setup
                if [[ $(grep -r "^getsrc:" Makefile) != "" ]]; then
                    make getsrc
                fi
                if [[ $line == "thirdparty/openssl" ]]; then
                    make build
                fi
                make $1
                if [[ $1 != "clean" ]]; then
                    if [[ $(ls build/"${os_tag%%.*}"/"$zimbra_name"/rpm/RPMS/x86_64/*.rpm 2>&1) == *"No such"* ]]; then
                        echo "Compilation error!"
                        exit 1
                    else
                        rpm -i build/"${os_tag%%.*}"/"$zimbra_name"/rpm/RPMS/x86_64/zimbra-*.rpm
                    fi
                fi
            fi
        fi
    fi
done
