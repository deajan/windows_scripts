@echo off

:: Install script for ServerAlert
:: Takes a list of services to watch from watch_service_list.txt
:: Adds them to ServiceAlert.cmd surveillanceert.cmd

set curdir=%~dp0
set curdir=%curdir:~0,-1%

for /F %%i in (%curdir%\Watch_Service_List.txt) do sc failure %%i reset= 120 command= "%curdir%\ServiceAlert.cmd \"%%i\"" actions= run/5000/run/5000