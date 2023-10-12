#!/bin/bash

service cron restart
service ssh restart
apache2ctl -D FOREGROUND
