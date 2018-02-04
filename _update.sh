#!/bin/bash
git pull "git://factorcode.org/git/factor.git" master
if [[ $? -eq 0 ]]; then exec "./build.sh" update; else echo "git pull failed"; exit 2; fi
exit 0
