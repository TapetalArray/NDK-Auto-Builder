#!/bin/bash


if [[ "$(uname -o)" = "Android" ]] || [[ ! -d /usr/local/bin ]]
then
    echo "This script does not support direct use in Termux"
    exit
fi

cp ./ndk-auto-builder.sh /usr/local/bin/ndk-auto-builder
chmod +x /usr/local/bin/ndk-auto-builder

echo "Install finished"
echo "Now execute ndk-auto-builder to create common configuration file"
