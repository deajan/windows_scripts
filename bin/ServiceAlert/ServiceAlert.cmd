@echo off

:: Alert script for Windows service surveillance
:: This script has to be set as program to be run on service failure in services.msc or via the install script
:: Will relaunch the service, eventually executing other commands and send an alert via email'affichage correct dans les mails)

:: Changelog
:: 28 Aug 2015 - Fixed missing encryption setting for email, allow mail passwords containing spaces
:: 04 Jan 2015 - Added some compression program sanity checks and support for pigz
:: 03 Jan 2015 - Merged codebase with other scripts
:: 20 Nov 2014 - Corrected a bug when log file isn't specified

:: Compress backup logs before sending by email
set COMPRESS_LOGS=1
:: Compression level, 1=fast, 9=best
set COMPRESS_LEVEL=9

:: Alert email send options
set SEND_ALERTS=yes
set SMTP_SERVER=smtp.example.com
set SMTP_PORT=587
set SMTP_USER=infra@example.com
:: You can set a clear text SMTP password here
set SMTP_PW=
:: Alternatively, you can provide a B64 encoded password here
set SMTP_PWB64=U29Zb3VUcmllZFRoaXM/IA0K
set SENDER=%SMTP_USER%
set RECEIVER=monitor@example.com
set WARNING_MESSAGE=WARNING, SQL Backup alert
:: Mail server encryption, possible values are tls, ssl, none
set SECURITY=tls

:: Misc
:: Get Script working dir to find out where gzip.exe, base64.exe and mailsend.exe executables are.
set curdir=%~dp0
set curdir=%curdir:~0,-1%

:: Log file
set LOG_FILE=%curdir%\ServiceAlert.log

:: ---------------------------------------------------------------------------------------------------------------------------

setlocal enabledelayedexpansion

IF "%1"=="" GOTO Usage

IF "%COMPRESS_LOGS%"=="1" (
IF EXIST "%curdir%\gzip.exe" set COMPRESS_PROGRAM=%curdir%\gzip.exe && set COMPRESS_EXTENSION=.gz
:: Finally use pigz if available, which is the threaded version of gzip
IF EXIST "%curdir%\pigz.exe" set COMPRESS_PROGRAM=%curdir%\pigz.exe && set COMPRESS_EXTENSION=.gz
IF "!COMPRESS_PROGRAM!"=="" set COMPRESS=0
)

call:GetComputerName
call:Log "Restarting service %1"
:: ------------------------------------- RESTART BEGIN
:: You may insert whatever command lines are needed to restart the service here
net start %1 >> "%LOG_FILE%"
:: Wait some seconds
ping 127.0.0.1 -n 4 > NUL
sc query %1 >> "%LOG_FILE%"
:: ------------------------------------- RESTART END
call:Mailer
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

:CheckMailValues
echo "%SENDER%" | findstr /I "@" > nul
IF %ERRORLEVEL%==1 (
	call:Log "Source mail not set"
	GOTO End
	)
echo "%RECEIVER%" | findstr /I "@" > nul
IF %ERRORLEVEL%==1 (
	call:Log "Destination Mail not Set"
	GOTO End
	)
IF "%SUBJECT%"=="" (
	call:Log "Mail subject not set"
GOTO End
	)
echo "%SMTP_SERVER%" | findstr /I "." > nul
IF %ERRORLEVEL%==1 (
	call:Log "Smtp sever not set"
	GOTO End
	)
call:Log "Configuration file check success."
GOTO:EOF

:GetComputerName
set COMPUTER_FQDN=%COMPUTERNAME%
IF NOT "%USERDOMAIN%"=="" set COMPUTER_FQDN=%COMPUTERNAME%.%USERDOMAIN%
IF NOT "%USERDNSDOMAIN%"=="" set COMPUTER_FQDN=%COMPUTERNAME%.%USERDNSDOMAIN%
GOTO:EOF

:GetSMTPPw
IF "%SMTP_PW%"=="" IF NOT "%SMTP_PWB64%"=="" FOR /F "delims=" %%i IN ('"echo %SMTP_PASSWORD% | base64 -d"') DO SET SMTP_PASSWORD=%%i
GOTO:EOF

:Mailer
IF NOT "%SEND_ALERTS%"=="yes" GOTO:EOF
set SUBJECT=Service failure on %COMPUTER_FQDN%
set MAIL_CONTENT=%DATE% - %WARNING_MESSAGE%
call:CheckMailValues
call:SetAttachment
call:MailerMailSend
GOTO:EOF

:SetAttachment
IF NOT EXIST "%REPORT_FILE%" GOTO:EOF
IF "%COMPRESS_LOGS%"=="1" (
	for %%I in (%REPORT_FILE%) do set compressed_file=%%~nxI
	"%COMPRESS_PROGRAM%" -%COMPRESS_LEVEL% -f "%REPORT_FILE%"
	set attachment_filename=%curdir%\!compressed_file!%COMPRESS_EXTENSION%
) ELSE (
	set attachment_filaneme=%curdir%\%REPORT_FILE%
)
:: Check if report file is more than 9MB, if so, don't send it as attachment
call "%curdir%\filesize.cmd" "%attachment_filename%"
IF %ERRORLEVEL% GTR 9000000 call:Log "Report file too big to mail" && GOTO:EOF
set attachment=-attach "%attachment_filename%"
GOTO:EOF

:MailerMailSend
IF "%SECURITY%"=="tls" set encryption=-starttls
IF "%SECURITY%"=="ssl" set encryption=-ssl

IF NOT "%SMTP_USER%"=="" set smtpuser=-auth -user %SMTP_USER%
call:GetSMTPPw
IF NOT "%SMTP_PW%"=="" set smtppassword=-pass %SMTP_PW%
"%curdir%\mailsend.exe" -f "%SENDER%" -t "%RECEIVER%" -sub "%SUBJECT%" -M "%MAIL_CONTENT%" %attachment% -smtp "%SMTP_SERVER%" -port %SMTP_PORT% %smtpuser% %smtppassword% %encryption% -log "%LOG_FILE%"
IF NOT %ERRORLEVEL%==0 set SCRIPT_ERROR=1 && call:Log "Sending mail using mailsend failed."
GOTO:EOF

:Usage
echo Usage:
echo ""
echo Service_alert "servicename"
GOTO END

:END
