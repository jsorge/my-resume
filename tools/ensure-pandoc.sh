#!/usr/bin/env bash

set -e
set -o pipefail
set -u

required_version="$(cat .pandoc-version)"
install_location=./vended
download="pandoc"
exe_path="$install_location/$download"

install() {
  if [ ! -d $install_location ]; then
    mkdir $install_location;
  fi;

  rm -f ./tmp/pandoc ./tmp/pandoc.tar.gz

  curl --location --fail --retry 5 \
    https://github.com/jgm/pandoc/releases/download/"$required_version"/pandoc-"$required_version"-macOS.zip \
    --output $install_location/$download.zip

  (
    cd $install_location
    unzip -o $download.zip -d download > /dev/null
    mv download/$download-$required_version/bin/pandoc pandoc
    rm -rf $download.zip download
  )

  echo "Installed $download locally"
}

if [ ! -x $exe_path ]; then
  install
elif ! diff <(echo "pandoc $required_version") <($exe_path version -v | head -n 1) > /dev/null; then
  install
else
  echo "$download up to date"
fi
