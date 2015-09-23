#!/bin/bash -ex
version=$(uname -r)
apt-get install -y linux-image-extra-$version
apt-mark hold linux-image-$version linux-image-extra-$version
