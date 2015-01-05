@echo off

:: Takes a user account as argument and sets Password Never expires option

IF "%1"=="" GOTO USAGE

WMIC USERACCOUNT WHERE "Name='%1'" SET PasswordExpires=FALSE

GOTO END

:USAGE
echo %0 [useraccount]
GOTO END

:END