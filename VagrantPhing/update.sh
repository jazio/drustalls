#!/bin/bash

BUILD_FILE="/vagrant/trunk/build.xml"
PHING_COMMAND="/home/vagrant/bin/phing"

svn update

vagrant ssh --command "$PHING_COMMAND -f $BUILD_FILE update"
