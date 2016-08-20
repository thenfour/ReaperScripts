#!/usr/bin/env bash

echo "------------------------------------------------------------------"

# this puts us in /Scripts/tenfour-step/include/
cd "${0%/*}"
# this puts us in /Scripts/
cd ../..

echo ''
echo ''
echo 'deleting existing...'
rm -rfv ~/github/ReaperScripts/tenfour-step



echo ''
echo ''
echo 'copying...'
cp -rv tenfour-step ~/github/ReaperScripts/

echo ''
echo ''
echo 'copied.'



