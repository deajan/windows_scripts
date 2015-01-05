@echo off

:: Execute commands on certain days of week

set daysofweek=Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday  
for /F "skip=2 tokens=2-4 delims=," %%A in ('WMIC Path Win32_LocalTime Get DayOfWeek /Format:csv') do set daynumber=%%A  
for /F "tokens=%daynumber% delims=," %%B in ("%daysofweek%") do set day=%%B

IF "%day%"=="Friday" GOTO END
IF "%day%"=="Tuesday" GOTO END

:: Commands here will execute everyday except friday and tuesday
shutdown -s -t 360

:END
