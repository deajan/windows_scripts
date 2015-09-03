:: Returns size of a file given as argument under %ERRORLEVEL% value. If file doesn't exist, returns -1
@IF EXIST %1 @exit /b %~z1
@exit /b -1