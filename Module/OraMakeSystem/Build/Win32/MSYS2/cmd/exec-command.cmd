@echo off
setlocal

rem OMS version ( changed by "make set-oms-version")
set omsVersion=2.2.2

rem Save path to root installation directory ( without slash)
set OMS_ROOT=%~dp0

rem remove "/cmd/" from tail
set OMS_ROOT=%OMS_ROOT:~0,-5%

rem Save original PATH if it was not saved before ( it is important for a
rem recursive call when testing installation ( "make test"))
if "%OMS_SRC_PATH%" == "" set OMS_SRC_PATH=%PATH%

rem Arguments for runing command
set OMS_CMD_ARGS=%*

rem This script name
set scriptName=%~nx1

rem Use truncated path ( 1 - yes, 0 - no, see --use-truncated-path)
set useTruncatedPathFlag=1

rem Windows codepage for changing ( "-" if don't change)
set changeCodepage=-

rem Current Windows codepage ( "" if unknown)
set currentCodepage=

rem LANG value for setting ( "-" if don't set)
set setLang=

goto process_static_params



:shift_cmd_args_func
rem Skip first argument ( non spaces chars including subsequent spaces)
rem in OMS_CMD_ARGS

if not defined OMS_CMD_ARGS exit /b
set OMS_CMD_ARGS=%OMS_CMD_ARGS:~1%
if not defined OMS_CMD_ARGS exit /b
if not "%OMS_CMD_ARGS:~0,1%%OMS_CMD_ARGS:~0,1%" == "  " goto shift_cmd_args_func
:shift_cmdArgs_del_space
set OMS_CMD_ARGS=%OMS_CMD_ARGS:~1%
rem Compare two characters to exclude errors in case of quotation marks
if "%OMS_CMD_ARGS:~0,1%%OMS_CMD_ARGS:~0,1%" == "  " goto shift_cmdArgs_del_space
exit /b



:check_param_func
rem Check arguments is option in form <optName>[=<optValue>].
rem
rem Function parameters:
rem %~1       - optName
rem %~2       - first checked argument
rem
rem Return value:
rem 0         - it is not optName
rem 1         - optName without optValue
rem 2         - optName with optValue
rem
if not "%~1" == "%~2" exit /b 0

rem Set tmpLen to length( "<optName>= ")
set /A tmpLen=0
set "tmpStr=%~1"
:check_param_len_next
if "%tmpStr%" == "" goto check_param_len_end
set /A tmpLen+=1
set "tmpStr=%tmpStr:~1%"
goto check_param_len_next
:check_param_len_end
set /A tmpLen+=2

rem Add space char for correct processing last argument in command line
call set "tmpStr=%%OMS_CMD_ARGS:~0,%tmpLen%%% "
call set "tmpStr=%%tmpStr:~0,%tmpLen%%%"
set tmpLen=
if "%tmpStr:~0,-2%" == "%~1 " set "tmpStr=%~1= "
if "%tmpStr%" == "%~1= " (
  set tmpStr=
  exit /b 1
) else (
  set tmpStr=
  exit /b 2
)



:set_currentCodepage_func
rem Save current codepage to currentCodepage variable
for /F "usebackq delims=" %%i in (`chcp`) do set currentCodepage=%%i
set currentCodepage=%currentCodepage:*: =%
exit /b



:truncate_path_func
rem Set PATH to default Windows paths with adding path to sqlplus.exe and
rem svn.exe ( unconditionally excluding path to cygcheck.exe)

rem Set PATH to default Windows path ( used in MSYS2)
set PATH=C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0

rem Set fSrcPath to source paths without path to Cygwin
set fSrcPath=%OMS_SRC_PATH%;
set fCmd="cygcheck.exe"
:remove_cygwin
set fPath=""
rem find fCmd in PATH directories
for %%i in (%fCmd%) do set fPath=%%~dp$fSrcPath:i
if not "%fPath%" == "" (
  rem "expansion into expansion" not work without "call"...
  call set fSrcPath=%%fSrcPath:%fPath:~0,-1%;=%%
  goto :remove_cygwin
)

rem Add path to Oracle client
set fCmd="sqlplus.exe"
set fPath=""
rem find fCmd in PATH directories
for %%i in (%fCmd%) do set fPath=%%~dp$fSrcPath:i
if "%fPath%" == "" (
  echo %topScript%: Warning: %fCmd% not found in PATH
) else (
  rem add fPath without trailing slash
  set PATH=%PATH%;%fPath:~0,-1%
)

rem Add path to Subversion client
set fCmd="svn.exe"
set fPath=""
rem find fCmd in PATH directories
for %%i in (%fCmd%) do set fPath=%%~dp$fSrcPath:i
if not "%fPath%" == "" (
  rem add fPath without trailing slash
  set PATH=%PATH%;%fPath:~0,-1%
)

rem Delete temporary variables
set fSrcPath=
set fCmd=
set fPath=
exit /b



:process_static_params
rem Process static parameters

rem Top running script
set topScript=%1
shift & call :shift_cmd_args_func

rem Command to executing
set OMS_EXEC_CMD=%1
shift & call :shift_cmd_args_func

if not "%topScript%" == "" (
  if not "%OMS_EXEC_CMD%" == "" goto check_params
)

echo exec-command.cmd: mandatory arguments not specified
echo Usage:
echo     exec-command.cmd topScript execCommand [OMS options] [command parameters]
exit /b 15



:check_params
rem Process optional parameters

rem Stop checking parameters if there are quotes in the parameter value
rem ( simplified workaround for a problem with unpaired quotes)
set tmpStr=%~1
set tmpStr=%tmpStr:"=%
if not "%~1%~1" == "%tmpStr%%tmpStr%" goto check_params_end



rem Print Help
if "%~1" == "/?" goto print_help
if not "%~1" == "-?" goto print_help_end
:print_help
echo Usage:
echo     %topScript% [OMS options] [command parameters]
echo.
echo OMS options:
echo     --change-codepage[=NNN]    Change Windows codepage to NNN;
echo                                don't change if "-" specified as NNN
echo                                or NNN is not specified
echo                                ( used by default^)
echo     --oms-version              Print the version number of script and exit
echo     --set-lang[=LOCALE]        Set environment variable LANG=^<LOCALE^>;
echo                                don't set if "-" specified as LOCALE;
echo                                set LANG=C.CP1251 if LOCALE is not specified
echo                                and codepage 866 or 1251 is used
echo                                ( used by default^)
echo     --use-full-path            Use full currnent PATH variable instead of
echo                                truncating to minimal
echo     --use-truncated-path       Use truncated PATH variable with default
echo                                Windows paths with adding path to
echo                                sqlplus.exe and svn.exe unconditionally
echo                                excluding path to cygcheck.exe
echo                                ( used by default^)
echo     -? ^| /?                    Display this help and exit
exit /b 0
:print_help_end



rem Check --change-codepage
call :check_param_func --change-codepage "%~1"
if not "%ERRORLEVEL%" == "0" (
  if "%ERRORLEVEL%" == "2" (
    set changeCodepage=%~2
    shift
  ) else (
    set changeCodepage=
  )
  shift & call :shift_cmd_args_func & goto check_params
)



rem Check --oms-version
if "%~1" == "--oms-version" (
  echo %scriptName% (OMS^) %omsVersion%
  exit /b 0
)



rem Check --set-lang
call :check_param_func --set-lang "%~1"
if not "%ERRORLEVEL%" == "0" (
  if "%ERRORLEVEL%" == "2" (
    set setLang=%~2
    shift
  ) else (
    set setLang=
  )
  shift & call :shift_cmd_args_func & goto check_params
)



rem Check --use-full-path
if "%~1" == "--use-full-path" (
  set useTruncatedPathFlag=0
  shift & call :shift_cmd_args_func & goto check_params
)



rem Check --use-truncated-path
if "%~1" == "--use-truncated-path" (
  set useTruncatedPathFlag=1
  shift & call :shift_cmd_args_func & goto check_params
)

:check_params_end



if "%useTruncatedPathFlag%" == "1" call :truncate_path_func

rem Add paths to OMS scripts and MSYS2 binaries
set PATH=%OMS_ROOT%\usr\local\bin;%OMS_ROOT%\usr\bin;%PATH%

rem Use full currnent PATH variable instead of triming to minimal in MSYS2 bash
set MSYS2_PATH_TYPE=inherit

rem Use current directory as working directory in MSYS2 bash
set CHERE_INVOKING=enabled_from_arguments

rem Change Windows codepage
if "%changeCodepage%" == "-" goto chcp_end
if "%changeCodepage%" == "" goto chcp_end
chcp %changeCodepage% >nul && set currentCodepage=%changeCodepage%
:chcp_end

rem Set LANG
if "%setLang%" == "-" goto set_lang_end
if not "%setLang%" == "" goto set_lang_set
rem Set LANG=C.CP1251 for 866 and 1251 codepages by default
if "%currentCodepage%" == "" call :set_currentCodepage_func
if "%currentCodepage%" == "866" set setLang=C.CP1251
if "%currentCodepage%" == "1251" set setLang=C.CP1251
if "%setLang%" == "" goto set_lang_end
:set_lang_set
set LANG=%setLang%
:set_lang_end

rem Check OMS_ROOT
if not exist "%OMS_ROOT%\usr\bin\bash.exe" (
  echo %topScript%: Incorrect value for OMS_ROOT was determined: "%OMS_ROOT%"
  exit /b 16
)

rem Add special option for make
if not "%scriptName%" == "make.cmd" goto make_args_end
if not "%OMS_EXEC_CMD%" == "make" goto make_args_end
if not defined OMS_CMD_ARGS (
  set OMS_CMD_ARGS=--eval=SHELL=/bin/bash
) else (
  set OMS_CMD_ARGS=--eval=SHELL=/bin/bash %OMS_CMD_ARGS%
)
:make_args_end

rem Delete temporary variables
set omsVersion=2.2.2
set scriptName=
set useTruncatedPathFlag=
set changeCodepage=
set currentCodepage=
set setLang=
set topScript=
set tmpStr=

rem Run command
%OMS_ROOT%\usr\bin\bash -c '%OMS_EXEC_CMD% %OMS_CMD_ARGS%'
exit /b %ERRORLEVEL%
