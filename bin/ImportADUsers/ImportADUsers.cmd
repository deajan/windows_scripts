@echo off
:: AD Import script from CSV file (tab separated for easier reading)

:: Configure the following variables according to your setup

set domain=dc=contoso,dc=local
set organizationalUnit=ou=Prades
set importFile=pointnetinfo.txt
set profilePath=\\somepath\profiles$
set initialPassword=p@ssw0rd
set logonScript=logon.cmd

IF EXIST .\%importFile% GOTO OK
GOTO USAGE

:OK

:: Rename administrator account to something else 
REM dsmod user "cn=Administrator,cn=Users,%domain%" -ln "MyAdministrator" -upn "MyAdministrator"

:: Create Organizational Units
dsadd ou "%organizationalUnit%,%domain%"

:: Add other OUs here
::dsadd ou "ou=SomeOU,%organizationalUnit%,%domain%"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::: NOTHING TO EDIT BELOW THIS LINE

FOR /F "skip=8 tokens=1,2,3,* delims=	" %%i in (%importFile%) do (

	IF "%%i"=="--GROUPS--" (
		ECHO GRP > GRP
		
	)

	IF "%%i"=="--USERS--" (
		ECHO USR > USR
		@DEL GRP /S /Q > NUL
	)

	IF EXIST "GRP" IF NOT "%%i"=="--GROUPES--" (
		dsadd group cn="%%i",ou=Utilisateurs,%organizationalUnit%,%domain% -desc "%%j"
	)

	IF EXIST "USR" IF NOT "%%i"=="--UTILISATEURS--" (
		dsadd user cn="%%i",ou=Utilisateurs,%organizationalUnit%,%domain% -fn "%%j" -ln "%%k" -display "%%j %%k" -pwd %initialPassword% -profile %profilePath% -loscr %logonScript% -mustchpwd yes -pwdneverexpires yes
		FOR /f "tokens=1,2,3,4 delims=," %%1 in ("%%l") do (
			IF NOT "%%1"=="" dsmod group cn="%%1",ou=Utilisateurs,%organizationalUnit%,%domain% -addmbr cn="%%i",ou=Utilisateurs,%organizationalUnit%,%domain%
			IF NOT "%%2"=="" dsmod group cn="%%2",ou=Utilisateurs,%organizationalUnit%,%domain% -addmbr cn="%%i",ou=Utilisateurs,%organizationalUnit%,%domain%
			IF NOT "%%3"=="" dsmod group cn="%%3",ou=Utilisateurs,%organizationalUnit%,%domain% -addmbr cn="%%i",ou=Utilisateurs,%organizationalUnit%,%domain%
			IF NOT "%%4"=="" dsmod group cn="%%4",ou=Utilisateurs,%organizationalUnit%,%domain% -addmbr cn="%%i",ou=Utilisateurs,%organizationalUnit%,%domain%
		)
	)
)
@DEL USR /S /Q > NUL

:: Export AD to LDIF format
ldifde -f ExportADUsers.ldif -d dc=%domain%

GOTO END

:USAGE
ECHO USAGE:
echo %0 %importFile%
:END