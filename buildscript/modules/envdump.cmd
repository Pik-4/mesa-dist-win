@IF NOT EXIST %mesa%\mesa-dist-win\buildinfo md %mesa%\mesa-dist-win\buildinfo
@echo Dumping build environment information. This will take a short while...
@echo.

@rem Dump Windows version
@FOR /F "USEBACKQ tokens=4" %%a IN (`ver`) DO @set winver=%%a
@set winver=%winver:~0,-1%
@IF %toolchain%==msvc FOR /F "USEBACKQ" %%a IN (`%pythonloc% -c "print('.'.join('%winver%'.split('.')[:3]))"`) do @set winver=%%a
@IF %toolchain%==gcc echo python2 -c "print('.'.join('%winver%'.split('.')[:3]))">%mesa%\mesa-dist-win\buildinfo\temp.sh
@IF %toolchain%==gcc FOR /F "USEBACKQ" %%a IN (`%msysloc%\usr\bin\bash --login %mesa%\mesa-dist-win\buildinfo\temp.sh`) do @set winver=%%a
@IF %toolchain%==gcc del %mesa%\mesa-dist-win\buildinfo\temp.sh
@IF %toolchain%==gcc echo Windows %winver%>%mesa%\mesa-dist-win\buildinfo\mingw.txt
@IF %toolchain%==msvc echo Windows %winver%>%mesa%\mesa-dist-win\buildinfo\msvc.txt

@rem Dump Resource Hacker version
@set rhstate=2
@set ERRORLEVEL=0
@where /q ResourceHacker.exe
@IF ERRORLEVEL 1 set rhstate=1
@IF %rhstate%==1 IF NOT EXIST %mesa%\resource-hacker\ResourceHacker.exe set rhstate=0
@IF %rhstate%==1 SET PATH=%mesa%\resource-hacker\;%PATH%
@IF %rhstate% GTR 0 FOR /F "USEBACKQ tokens=*" %%a IN (`where ResourceHacker.exe`) do @set rhloc="%%a"
@IF %rhstate% GTR 0 ResourceHacker.exe -open %rhloc% -action extract -mask VERSIONINFO,, -save %mesa%\mesa-dist-win\buildscript\assets\temp.rc -log NUL
@IF %rhstate% GTR 0 set PATH=%oldpath%
@IF %rhstate% GTR 0 FOR /F "tokens=2 skip=2 USEBACKQ" %%a IN (`type %mesa%\mesa-dist-win\buildscript\assets\temp.rc`) do @set rhver=%%a&GOTO doneenvcommon

:doneenvcommon
@IF %rhstate% GTR 0 IF %toolchain%==gcc echo Ressource Hacker %rhver:,=.%>>%mesa%\mesa-dist-win\buildinfo\mingw.txt
@IF %rhstate% GTR 0 IF %toolchain%==msvc echo Ressource Hacker %rhver:,=.%>>%mesa%\mesa-dist-win\buildinfo\msvc.txt

@rem Dump MSYS2 environment
@IF %toolchain%==gcc echo.>>%mesa%\mesa-dist-win\buildinfo\mingw.txt
@IF %toolchain%==gcc echo MSYS2 environment>>%mesa%\mesa-dist-win\buildinfo\mingw.txt
@IF %toolchain%==gcc echo ----------------->>%mesa%\mesa-dist-win\buildinfo\mingw.txt
@IF %toolchain%==gcc %msysloc%\usr\bin\bash --login -c "pacman -Q">>%mesa%\mesa-dist-win\buildinfo\mingw.txt

@rem Dump Visual Studio environment
@IF %toolchain%==msvc echo Visual Studio %msvcver%>>%mesa%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc call %vsenv% %vsabi%>nul 2>&1
@IF %toolchain%==msvc set PATH=%oldpath%
@IF %toolchain%==msvc echo Windows SDK %WindowsSDKVersion:~0,-1%>>%mesa%\mesa-dist-win\buildinfo\msvc.txt

@rem Dump Python environment
@IF %toolchain%==msvc echo Python %fpythonver%>>%mesa%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc echo.>>%mesa%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc echo Python packages>>%mesa%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc echo --------------->>%mesa%\mesa-dist-win\buildinfo\msvc.txt
@IF %toolchain%==msvc FOR /F "USEBACKQ skip=2 tokens=*" %%a IN (`%pythonloc% -W ignore -m pip list --disable-pip-version-check`) do @echo %%a>>%mesa%\mesa-dist-win\buildinfo\msvc.txt

@rem Finished environment information dump.
@echo Done.
@IF %toolchain%==gcc echo Environment information has been written to %mesa%\mesa-dist-win\buildinfo\mingw.txt.
@IF %toolchain%==msvc echo Environment information has been written to %mesa%\mesa-dist-win\buildinfo\msvc.txt.
@echo.