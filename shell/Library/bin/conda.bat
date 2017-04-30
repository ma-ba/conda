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
@CALL :CALL_COMMAND_WITH_PROMPT_UPDATE shell.activate %2 %3
@IF NOT ERRORLEVEL 1 GOTO :End
@REM special error handling for activate
@GOTO :End

:DO_DEACTIVATE
@CALL :CALL_COMMAND_WITH_PROMPT_UPDATE shell.deactivate %2
@IF NOT ERRORLEVEL 1 GOTO :End
@REM special error handling for deactivate
@GOTO :End

:DO_REACTIVATE
@CALL :CALL_COMMAND shell.reactivate %2
@IF NOT ERRORLEVEL 1 GOTO :End
@REM special error handling for reactivate
@GOTO :End


:CALL_COMMAND_WITH_PROMPT_UPDATE
@IF "%CONDA_PROMPT_MODIFIER%" == "" GOTO skip_prompt
    @CALL SET "PROMPT=%%PROMPT:%CONDA_PROMPT_MODIFIER%=%_empty_not_set_%%%"
:skip_prompt
@CALL :CALL_COMMAND %*
@IF NOT ERRORLEVEL 1 GOTO :update_prompt
    @SET "CONDA_PROMPT_MODIFIER="
    @EXIT /B 1
:update_prompt
@SET PROMPT="%CONDA_PROMPT_MODIFIER%%PROMPT%"
@EXIT /B 0

:CALL_COMMAND
@SET "_TEMP_SCRIPT_PATH="
@FOR /F "delims=" %%i IN ('CMD /C @CALL "%_CONDA_EXE%" %1 cmd.exe %2 %3 ^|^| ECHO _ERR_LVL_%%^^ERRORLEVEL%%') DO @SET "_TEMP_SCRIPT_PATH=%%i"
@REM if call failed with error code x, _TEMP_SCRIPT_PATH is set to string _ERR_LVL_x
@IF DEFINED _TEMP_SCRIPT_PATH GOTO check_error
    @REM TODO: handle zero length output
    @EXIT /B 1
:check_error
@IF NOT "%_TEMP_SCRIPT_PATH:~0,9%" == "_ERR_LVL_" GOTO call_temp_script
    @SET "_ERR_LVL=%_TEMP_SCRIPT_PATH:~9%"
    @REM TODO: handle failed call which returned error code %_ERR_LVL%
    @SET _TEMP_SCRIPT_PATH=
    @EXIT /B %_ERR_LVL%
:call_temp_script
@CALL "%_TEMP_SCRIPT_PATH%"
@DEL /F /Q "%_TEMP_SCRIPT_PATH%"
@SET _TEMP_SCRIPT_PATH=
@EXIT /B 0


:End
@SET _CONDA_EXE=
@GOTO :eof
