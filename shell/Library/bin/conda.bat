@SET "_CONDA_EXE=%~dp0..\..\Scripts\conda.exe"

@IF "%1"=="activate" GOTO :DO_ACTIVATE
@IF "%1"=="deactivate" GOTO :DO_DEACTIVATE

@CALL "%_CONDA_EXE%" %*

@REM This block should really be the equivalent of
@REM   if "install" in %* GOTO :DO_DEACTIVATE
@IF "%1"=="install" GOTO :DO_DEACTIVATE
@IF "%1"=="update" GOTO :DO_DEACTIVATE
@IF "%1"=="remove" GOTO :DO_DEACTIVATE
@IF "%1"=="uninstall" GOTO :DO_DEACTIVATE

@GOTO :End


:DO_ACTIVATE
@IF "%CONDA_PROMPT_MODIFIER%" == "" GOTO skip_prompt_set_activate
    @CALL SET "PROMPT=%%PROMPT:%CONDA_PROMPT_MODIFIER%=%_empty_not_set_%%%"
:skip_prompt_set_activate
@SET "_TEMP_SCRIPT_PATH="
@FOR /F "delims=" %%i IN ('CMD /C @CALL "%_CONDA_EXE%" shell.activate cmd.exe %2 %3 ^|^| ECHO _ERR_LVL_%%^^ERRORLEVEL%%') DO @SET "_TEMP_SCRIPT_PATH=%%i"
@REM if call failed with error code x, _TEMP_SCRIPT_PATH is set to string _ERR_LVL_x
@IF DEFINED _TEMP_SCRIPT_PATH GOTO check_error_activate
    @REM TODO: handle zero length output
    @GOTO End
:check_error_activate
@IF NOT "%_TEMP_SCRIPT_PATH:~0,9%" == "_ERR_LVL_" GOTO call_temp_script_activate
    @SET "_ERR_LVL=%_TEMP_SCRIPT_PATH:~9%"
    @REM TODO: handle failed call which returned error code %_ERR_LVL%
    @GOTO cleanup_activate
:call_temp_script_activate
@CALL "%_TEMP_SCRIPT_PATH%"
@DEL /F /Q "%_TEMP_SCRIPT_PATH%"
@SET PROMPT="%CONDA_PROMPT_MODIFIER%%PROMPT%"
:cleanup_activate
@SET _TEMP_SCRIPT_PATH=
@GOTO :End

:DO_DEACTIVATE
@IF "%CONDA_PROMPT_MODIFIER%" == "" GOTO skip_prompt_set_deactivate
    @CALL "SET PROMPT=%%PROMPT:%CONDA_PROMPT_MODIFIER%=%_empty_not_set_%%%"
:skip_prompt_set_deactivate
@FOR /F "delims=" %%i IN ('@CALL "%_CONDA_EXE%" shell.deactivate cmd.exe %2') DO @SET "_TEMP_SCRIPT_PATH=%%i"
@CALL "%_TEMP_SCRIPT_PATH%"
@DEL /F /Q "%_TEMP_SCRIPT_PATH%"
@SET _TEMP_SCRIPT_PATH=
@SET "PROMPT=%CONDA_PROMPT_MODIFIER%%PROMPT%"
@GOTO :End

:DO_REACTIVATE
@FOR /F "delims=" %%i IN ('@CALL "%_CONDA_EXE%" shell.reactivate cmd.exe %2') DO @SET "_TEMP_SCRIPT_PATH=%%i"
@CALL "%_TEMP_SCRIPT_PATH%"
@DEL /F /Q "%_TEMP_SCRIPT_PATH%"
@SET _TEMP_SCRIPT_PATH=
@GOTO :End

:End
@SET _CONDA_EXE=
@GOTO :eof
