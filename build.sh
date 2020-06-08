#!/bin/bash

comand=$1
packages_folder="$(pwd)"

cat build-order | while read line; do
    path="$line"
    name="$line"
    echo "######## $name ###########################################################"
    cd "$packages_folder/$line"
    make setup
    make getsrc
    make "$1"
    if [[ $1 =~ "deb" ]]; then
        dpkg -i build/**/zimbra-*.deb
    fi
done
