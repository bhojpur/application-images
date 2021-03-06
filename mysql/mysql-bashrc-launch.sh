#!/bin/bash

# This script is intended to be called from .bashrc
# This is a workaround for not having something like supervisord

if [ ! -e /var/run/mysqld/bhojpur-init.lock ]
then
    touch /var/run/mysqld/bhojpur-init.lock

    # initialize database structures on disk, if needed
    [ ! -d /application/mysql ] && mysqld --initialize-insecure

    # launch database, if not running
    [ ! -e /var/run/mysqld/mysqld.pid ] && mysqld --daemonize

    rm /var/run/mysqld/bhojpur-init.lock
fi
