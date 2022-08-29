@echo off

set Logs=C:\Logs

if exist %Logs% rmdir /S/Q %Logs%
mkdir %Logs%

set FileLogger1=/flp1:logfile=%Logs%\BuildInfo.log

set FileLogger2=/flp2:logfile=%Logs%\BuildErrors.log;errorsonly

set FileLogger3=/flp3:logfile=%Logs%\BuildWarnings.log;warningsonly

set buildparams=%FileLogger1%; %FileLogger2%; %FileLogger3%;

if /I "%1"=="Dev" ( 
set BUILD_TYPE="Dev"
) else if /I "%1"=="CM" (
    set BUILD_TYPE="CM"
	goto PatchBuild
) else ( 
 goto Error
)

if /I "%2"=="SKIP" (
goto PatchBuild
) else (
REM msbuild CitiATMCodeAnalysis.proj  /fileLoggerParameters:LogFile=%Logs%\CodeAnalysis.log
) 

:PatchBuild
msbuild patch.proj /t:BuildKickStart /p:BUILD_TYPE=%BUILD_TYPE% /fl1 /fl2 /fl3 %buildparams% 

if %ErrorLevel%==0 ( 
goto Succeeded 
) else ( 
goto Failed 
) 

:Succeeded 
Echo "Build is completed successfully..." 
goto CopyLogs 

:Failed 
Echo "Build is failed..." 
goto CopyLogs 

:Error
Echo:
Echo.   ******Arguments are expected for this script******
Echo.   ******Please pass the build type(Dev/CM) as the argument in the below format
Echo.   Ex: CitiATMBuild.bat Dev or CitiATMBuild.bat CM 
Echo:
goto End

:CopyLogs
Xcopy /y /q /i C:\Logs\*.* "c:\CITIATM Media Store\Logs"
rmdir /s /q "C:\Logs"
goto End

:End
Pause



