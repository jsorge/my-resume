#!/usr/bin/env bash

set -e
set -o pipefail
set -u

required_version="$(cat .wkhtmltopdf-version)"
install_location=./vended
download="wkhtmltopdf"
exe_path="$install_location/$download"

install() {
  if [ ! -d $install_location ]; then
    mkdir $install_location;
  fi;

  rm -f $exe_path

  # download the package. the current download version appends a -1 to the end of the download so this will
  # likely break in a future release of wkhtmltopdf
  curl --location --fail --retry 5 \
    https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/"$required_version"/wkhtmltox-"$required_version"-1.macos-cocoa.pkg \
    --output $install_location/$download.pkg

  (
    # unpack the package and installs the executable from the inner tarball
	cd $install_location
	pkgutil --expand wkhtmltopdf.pkg wkhtmltoxpkg
	tar xvf ./wkhtmltoxpkg/Payload
	cp ./usr/local/share/wkhtmltox-installer/wkhtmltox.tar.gz .
	mkdir wkhtmltox
	tar xvzf wkhtmltox.tar.gz -C wkhtmltox/
	mv ./wkhtmltox/bin/wkhtmltopdf wkhtmltopdf
	rm -rf wkhtmltox
	rm wkhtmltopdf.pkg
	rm wkhtmltox.tar.gz
	rm -rf usr
	rm -rf wkhtmltoxpkg
  )

  echo "Installed $download locally"
}

if [ ! -x $exe_path ]; then
  install
elif [[ $($exe_path -V) != *"$required_version"* ]]; then
  install
else
  echo "$download up to date"
fi
