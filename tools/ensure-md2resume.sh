#!/usr/bin/env bash

set -e
set -o pipefail
set -u

version_file=md2resume-version
required_version="$(cat .$version_file)"
install_location=./vended
download="markdown-resume"
exe_path="$install_location/$download/bin/md2resume"

install() {
  if [ ! -d $install_location ]; then
    mkdir $install_location;
  fi;

  (
    pushd $install_location

	# md2resume has to be checked out to a given tag version instead of downloading the actual version
	if [ ! -d $download ]; then
		git clone https://github.com/there4/markdown-resume.git
	fi

	pushd $download

	# fetch the latest version of master
	git checkout master
	git fetch --tags
	git pull

	# checkout the release we want
	git checkout tags/$required_version
	composer install

	popd
	popd
  )

  echo "Installed $download locally"
}

if [ ! -x $exe_path ]; then
  install
elif ! diff <(echo "$required_version") <($exe_path version) > /dev/null; then
  install
else
  echo "md2resume up to date"
fi
