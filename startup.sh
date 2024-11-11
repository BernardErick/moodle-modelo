#!/bin/sh
crond -l 8 -b > /dev/stdout 2> /dev/stderr &
tail -f /var/log/apache2/error.log

