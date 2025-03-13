#!/bin/bash

terraform fmt

for repository in $(ls . | tr '\n' ' ')
do

    if [ -d "${repository}" ]
    then
        echo "Terraform fmt to ${repository}"
        cd "${repository}"
        terraform fmt
        cd ..
    fi
done