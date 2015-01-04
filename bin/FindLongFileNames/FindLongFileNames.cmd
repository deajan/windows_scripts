@echo off

:: Script for finding long path and filenames, generates a report including every entry longer than MaxAllowedLength
:: Usage: FindLongFileNames.cmd "c:\path\to\check" [MaxAllowedLength]
:: If MaxAllowedLength isn't specified, the default value 248 is used.
:: v1.2 by Orsiris de Jong - http://www.netpower.fr - ozy@netpower.fr

:: Changelog
:: 04/01/2015 - Added some compression program sanity checks and support for pigz
:: 02/01/2015 - Merged codebase with other scripts
:: Somewhere in 2009: Initial version of this script

:: Path and filenames longer than this value will be reported
set MaxAllowedLength=248

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
set WARNING_MESSAGE=WARNING, long filenames found
:: Mail server encryption, possible values are tls, ssl, none
set SECURITY=tls

:: Misc
:: Get Script working dir to find out where gzip.exe, base64.exe and mailsend.exe executables are.
set curdir=%~dp0
set curdir=%curdir:~0,-1%

:: Log file
set LOG_FILE=%curdir%\FindLongFileNames.log
:: ---------------------------------------------------------------------------------------------------------------------------

setlocal enabledelayedexpansion

:: Sanity check, remove doublequotes if there are some, so we'll add them and be sure there are no more than one double quote at a time
set search_path=%1
set search_path=%search_path:"=%

IF NOT EXIST "%search_path%" GOTO Usage

IF "%COMPRESS%"=="1" (
IF EXIST "%curdir%\gzip.exe" set COMPRESS_PROGRAM=gzip.exe && set COMPRESS_EXTENSION=.gz
:: Finally use pigz if available, which is the threaded version of gzip
IF EXIST "%curdir%\pigz.exe" set COMPRESS_PROGRAM=pigz.exe && set COMPRESS_EXTENSION=.gz
IF "!COMPRESS_PROGRAM!"=="" set COMPRESS=0
)
IF NOT "%2"=="" set MaxAllowedLength=%2%
call:GetComputerName
call:SetOutputFile
call:Log "Beginning search for path length over %MaxAllowedLength% chars in %search_path%"
"%curdir%\findverylongfilenames.exe" "%search_path%" %MaxAllowedLength% > "%curdir%\%REPORT_FILE%"
call "%curdir%\filesize.cmd" "%curdir%\%REPORT_FILE%"
IF NOT %ERRORLEVEL% LEQ 0 IF "%SEND_ALERTS%"=="yes" (
call:Log "Exceeding path length found."
call:Mailer
)
call "%curdir%\filesize.cmd" "%curdir%\%REPORT_FILE%"
IF %ERRORLEVEL% LEQ 0 call:Log "No exceeding path length found on this run." && del "%curdir%\%REPORT_FILE%" /F /Q
GOTO END

:SetOutputFile
set day=%DATE:~0,2%
set month=%DATE:~3,2%
set year=%DATE:~6,4%
set hour=%TIME:~0,2%
set min=%TIME:~3,2%
set sec=%TIME:~6,2%

:: Remove slashes and colons from path
set writable_search_path=%search_path:\=_%
set writable_search_path=%writable_search_path::=%
set REPORT_FILE=%day%-%month%-%year%_%hour%H%min%m%sec%s_LongFiles__%writable_search_path%.txt
GOTO:EOF

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
IF "%SMTP_PW%"=="" IF NOT "%SMTP_PWB64%"=="" FOR /F %%i IN ('"echo %SMTP_PWB64% | "%curdir%\base64.exe" -d"') DO SET SMTP_PW=%%i
GOTO:EOF

:Mailer
IF NOT "%SEND_ALERTS%"=="yes" GOTO:EOF
set SUBJECT=Too long filenames on %COMPUTER_FQDN%
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
"%curdir%\mailsend.exe" -f "%SENDER%" -t "%RECEIVER%" -sub "%SUBJECT%" -M "%MAIL_CONTENT%" %attachment% -smtp "%SMTP_SERVER%" -port %SMTP_PORT% %smtpuser% %smtppassword% %encrypt% -log "%LOG_FILE%"
IF NOT %ERRORLEVEL%==0 set SCRIPT_ERROR=1 && call:Log "Sending mail using mailsend failed."
GOTO:EOF

:Usage
echo Usage:
echo.
echo FindLongFileNames.cmd "c:\path\to\check" [MaxAllowedLength]
echo Generates a report file including every path / file exceeding MAxAllowedLength.
echo If MaxAllowedLength is not specified, default value of 248 is used.
GOTO END

:END