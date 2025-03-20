#!/bin/bash


echo =================================================
echo 1 RUNNING MASTER BRANCH - Uyuni

git fetch --all && git pull -ff
make clean && make configure-uyuni && make antora-uyuni-en

echo ==== END OF RUNNING MASTER BRANCH - Uyuni
echo =================================================


echo =================================================
echo 2 RUNNING MANAGER-5.0 BRANCH

git checkout manager-5.0
git fetch --all && git pull -ff
make clean && make configure-suma && make antora-suma-en

echo ==== END OF RUNNING MANAGER-5.0 BRANCH
echo =================================================


echo =================================================
echo 3 RUNNING MANAGER-4.3 BRANCH

git checkout manager-4.3
git fetch --all && git pull -ff
make clean && make configure-suma && make antora-suma-en

echo ==== END OF RUNNING MANAGER-4.3 BRANCH
echo =================================================


echo =================================================
echo 4 RUNNING MASTER BRANCH - SUSE MLM

git checkout master
git fetch --all && git pull -ff
alias uy='make clean && make configure-uyuni && make antora-uyuni-en'
make clean && make configure-mlm && make antora-mlm-en

echo ==== END OF RUNNING MASTER BRANCH - SUSE MLM
echo =================================================

