#!/bin/bash

if [ ! -e "composer.phar" ]; then
    curl -sS https://getcomposer.org/installer | php
fi

# if composer.phar is over 30 days old
if test "`find composer.phar -mtime +30`"; then
    php composer.phar --ansi self-update
fi

php composer.phar --ansi install

if [ ! -e "build.properties" ]; then
    touch build.properties
    echo "You may have to fill build.properties to override build.default.properties."
fi

# install selenium server
if [ ! -e "bin/selenium-server-standalone.jar" ]; then
    wget http://selenium-release.storage.googleapis.com/2.42/selenium-server-standalone-2.42.1.jar \
        -O vendor/selenium-server-standalone-2.42.1.jar
    ln -s ../vendor/selenium-server-standalone-2.42.1.jar bin/selenium-server-standalone.jar
fi

# install phantomjs
if [ ! -e "bin/phantomjs" ]; then
    wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.7-linux-x86_64.tar.bz2 \
        -O phantomjs-1.9.7-linux-x86_64.tar.bz2
    tar xvvjf phantomjs-1.9.7-linux-x86_64.tar.bz2
    mv phantomjs-1.9.7-linux-x86_64 vendor
    ln -s ../vendor/phantomjs-1.9.7-linux-x86_64/bin/phantomjs bin/phantomjs
    rm -rf phantomjs-1.9.7-linux-x86_64.tar.bz2
fi
