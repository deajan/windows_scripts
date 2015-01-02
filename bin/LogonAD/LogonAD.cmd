:: Small logonscript for AD - Should work on any computer running Windows 2000 or better
:: v1.5 by Orsiris de Jong - http://www.netpower.fr - ozy@netpower.fr

:: The following script is an example. Please change server, share, group, user and computer names according to your setup.

:: Will mount network drives depending on user's group membership and depending on domain controller server
:: Equivalent group membership command on a DC would be: dsquery user -samid %username% |dsget user -memberof -expand | find /I /C "OFFICE GROUP"
:: Keep in mind that global and local groups are not processed the same way (NET GROUP /DOMAIN or NET LOCALGROUP)
:: NET GROUP "your group name" /DOMAIN | find /I /C "%USERNAME%"
:: NET LOCALGROUP "your local group name" /DOMAIN | find /I /C "%USERNAME%"

@echo off

SET LOG_FILE="\\DOMAINCONTROLLER1\CNXLOG$\connect.log"

:: Prevent using find.exe from msys if installed
IF EXIST %systemroot%\system32\find.exe set findcmd=%systemroot%\system32\find.exe
IF NOT EXIST %systemroot%\system32\find.exe set findcmd=find

:: Determine on which server we log
IF "%LOGONSERVER%"=="\\DOMAINCONTROLLER1" GOTO DC1
IF "%LOGONSERVER%"=="\\DOMAINCONTROLLER2" GOTO DC2
IF "%LOGONSERVER%"=="\\REMOTEDC1" GOTO REMOTEDC1
GOTO NOLOGONSERVER

:DOMAINCONTROLLER1
SET LOGFILE="\\DOMAINCONTROLLER1\CNXLOG$\connect.log"
call:Log "%USERNAME% logged on %COMPUTERNAME% using %LOGONSERVER%"
GOTO CENTRALOFFICE

:DOMAINCONTROLLER2
SET LOGFILE="\\DOMAINCONTROLLER1\CNXLOG$\connect.log"
call:Log "%USERNAME% logged on %COMPUTERNAME% using %LOGONSERVER%"
GOTO CENTRALOFFICE

:REMOTEDC1
SET LOGFILE="\\REMOTEDC1\CNXLOG$\connect.log"
call:Log "%USERNAME% logged on %COMPUTERNAME% using %LOGONSERVER%"

:CENTRALOFFICE
:: Insert whatever lines you'd need for mapping the central office

NET USE * /DELETE /YES

NET GROUP "TECH" /DOMAIN | %findcmd% /I /C "%USERNAME%"
IF %ERRORLEVEL%==0 NET USE G: \\example.com\tech

NET GROUP "HUMAN RESSOURCES" /DOMAIN | %findcmd% /I /C "%USERNAME%"
IF %ERRORLEVEL%==0 NET USE G: \\example.com\replication\hr

NET GROUP "ADMIN" /DOMAIN | %findcmd% /I /C "%USERNAME%"
IF %ERRORLEVEL%==0 NET USE S: \\example.com\bigadminshare

:: Execute more scripts 
\\DOMAINCONTROLLER1.example.com\deploy$\spark.cmd

GOTO END

:REMOTEOFFICE
:: Insert whatever you'd need here

:NOLOGONSERVER

echo No logonserver available

set FQDN_SUFFIX=%USERDOMAIN%
IF NOT "%USERDNSDOMAIN%"=="" set FQDN_SUFFIX=%USERDNSDOMAIN% 
echo %USERNAME%@%FQDN_SUFFIX% AS %COMPUTERNAME% ON %LOGONSERVER% cannot login.

ping 127.0.0.1 -n 10 > nul

GOTO END

:GetTime
:: English Date /T returns Day MM/DD/YYYY whereas French one returns DD/MM/YYYY, Try to catch both
FOR /F "tokens=1,2,3,4 delims=/" %%a IN ('Date /T') DO (
IF "%%d"=="" set now_date=%%a-%%b-%%c
IF NOT "%%d"=="" set now_date=%%a-%%b-%%c-%%d
)
set now_time=%TIME:~0,2%:%TIME:~3,2%:%TIME:~6,2%
GOTO:EOF

:Log
call:GetTime
echo %now_date% - %now_time% %~1 >> "%LOG_FILE%"
IF "%DEBUG%"=="yes" echo %~1
GOTO:EOF

:END

