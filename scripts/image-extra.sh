#!/bin/bash -ex
sudo apt-get update && sudo apt-get install -y linux-image-extra-$(uname -r)
