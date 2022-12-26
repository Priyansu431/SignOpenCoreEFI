#!/bin/bash

printMessage "------------ Install Packages if required ------------"

declare -a packageNames=("jq" "wget" "sbsigntool" "unzip")

for package in "${packageNames[@]}"
do
    packgeDetails=$(apt -qq list $package --installed 2>&1 | grep -v "does not have a stable"  )
    
    if [ "$packgeDetails" == "" ]
    then
        printMessage "Installing $package ....."
        sudo apt-get install $package -y
    else
        printMessage "$package Installed "
    fi
done

printMessage "------------ End of Install Packages ------------ \n"
