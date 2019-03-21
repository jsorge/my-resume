#! /usr/bin/env bash

if [ ! -d "markdown-resume" ]; then
	git clone https://github.com/there4/markdown-resume.git
fi

pushd ./markdown-resume
git checkout tags/2.3.1
composer install
popd

./markdown-resume/bin/md2resume pdf ./Jared-Sorge-Resume.md .
