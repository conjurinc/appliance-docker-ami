#!/bin/bash -ex
apt-get update && apt-get install -y linux-image-extra-$(uname -r)
