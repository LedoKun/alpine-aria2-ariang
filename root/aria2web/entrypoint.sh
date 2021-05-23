#!/bin/bash
if [ -e /aria2web/config/aria2.conf ]
then
    echo "Config file found!"
else
    echo "Creating new config file!"
    cp /aria2web/aria2.conf /aria2web/config/aria2.conf
fi

/root/go/bin/goreman start