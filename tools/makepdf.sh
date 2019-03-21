#! /usr/bin/env bash

if [ ! -d "markdown-resume" ]; then
	git clone https://github.com/there4/markdown-resume.git
	pushd ./markdown-resume
	composer install
	popd
fi

./markdown-resume/bin/md2resume pdf ./Jared-Sorge-Resume.md .
