#!/usr/bin/env bash
cd $(dirname "$0")

dpkg-scanpackages -m ./deb > Packages
bzip2 -c Packages > Packages.bz2
gzip -c Packages > Packages.gz
