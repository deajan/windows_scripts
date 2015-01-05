@echo off

:: W32Time config script for Win2K8+

w32tm /config /manualpeerlist:"0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org pool.ntp.org",0*8 /syncfromflags:MANUAL /reliable:yes
w32tm /config /update
net stop w32time
net start w32time
w32tm /resync /rediscover