@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION



:PROCESS_CMD
    SET "utility_folder=%~dp0"
    SET "utility_software_folder=%utility_folder%software"
    SET "utility_sfx=%utility_folder%software.exe"

    CALL "%utility_folder%..\win-utils\setup.cmd" cecho 7zip

    SET help_arg=false
    SET pack_arg=false
    SET unpack_arg=false

    SET current_arg=%1
    IF  [%current_arg%] EQU [-h]       SET help_arg=true
    IF  [%current_arg%] EQU [--help]   SET help_arg=true
    IF  [%current_arg%] EQU [--pack]   SET pack_arg=true
    IF  [%current_arg%] EQU [--unpack] SET unpack_arg=true

    IF  [%help_arg%] EQU [true] (
        CALL :SHOW_HELP
    ) ELSE (
        IF  [%pack_arg%] EQU [true]  (
            CALL :PACK
        ) ELSE (
            IF  [%unpack_arg%] EQU [true]  (
                CALL :UNPACK
            ) ELSE (
                CALL :MAIN %*
                IF !ERRORLEVEL! NEQ 0 (
                    EXIT /B !ERRORLEVEL!
                )
            )
        )
    )

    REM All changes to variables within this script, will have local scope. Only
    REM variables specified in the following block can propagates to the outside
    REM world (For example, a calling script of this script).
    ENDLOCAL & (
        SET "TOOLSET_GIT_PATH=%utility_software_folder%"
        SET "PATH=%PATH%"
    )
EXIT /B 0



:MAIN
    CALL :UNPACK

    SET "windows_find_cmd=%windir%\System32\find.exe"
    SET "msys_cygpath_cmd=%utility_software_folder%\usr\bin\cygpath.exe"

    REM Mode 1.
    REM     Always put the 'path_to_git_mode1' in the system path, if it is not 
    REM     already present.
    SET "path_to_git_mode1=%utility_software_folder%"
    ECHO "!PATH!" | "%windows_find_cmd%" /I "%path_to_git_mode1%" >NUL && ( call  ) || (
        SET "PATH=%path_to_git_mode1%;!PATH!"
        CALL :SHOW_INFO "Utility added to system path."
        CALL :SHOW_DETAIL "Paths added to system path (mode 1): %path_to_git_mode1%"
    )

    SET "current_arg=%1"
    IF "%current_arg%" EQU "--mode" (
        SHIFT
        CALL SET "current_arg=%%1"

        REM Mode 2.
        IF "!current_arg!" EQU "2" (
            SET "path_to_git_mode2=%utility_software_folder%\cmd"
            ECHO "!PATH!" | "%windows_find_cmd%" /I "!path_to_git_mode2!">NUL && ( call ) || (
               SET "PATH=!path_to_git_mode2!;!PATH!"
               CALL :SHOW_INFO "Utility added to system path."
               CALL :SHOW_DETAIL "Paths added to system path (mode 2): !path_to_git_mode2!"
            )
        ) ELSE (
            REM Mode 3.
            IF "!current_arg!" EQU "3" (
                SET "path_to_git_mode3=%utility_software_folder%\bin"
                ECHO "!PATH!" | "%windows_find_cmd%" /I "!path_to_git_mode3!">NUL && ( call ) || (
                   SET "PATH=!path_to_git_mode3!;!PATH!"
                   CALL :SHOW_INFO "Utility added to system path."
                   CALL :SHOW_DETAIL "Paths added to system path (mode 3): !path_to_git_mode3!"
                )
            ) ELSE (
                REM Mode 4.
                IF "!current_arg!" EQU "4" (
                   SET "path_to_git_mode4=%utility_software_folder%\mingw64\bin;%utility_software_folder%\usr\local\bin;%utility_software_folder%\usr\bin;%utility_software_folder%\bin;%utility_software_folder%\usr\bin\vendor_perl;%utility_software_folder%\usr\bin\core_perl"
                   ECHO "!PATH!"| "%windows_find_cmd%" /I "!path_to_git_mode4!">NUL && ( call ) || (
                      SET "PATH=!path_to_git_mode4!;!PATH!"
                      CALL :SHOW_INFO "Utility added to system path."
                      CALL :SHOW_DETAIL "Paths added to system path (mode 4): !path_to_git_mode4!"
                   )
                ) ELSE (
                    IF "!current_arg!" NEQ "1" (
                        REM Unknown mode.
                        CALL :SHOW_ERROR "An unknown mode was specified ^(Value: '!current_arg!'^)"
                        EXIT /B -1
                    )
                )
            )
        )
    )

    SHIFT
    CALL SET "current_arg=%1"

    IF "%current_arg%" EQU "--home-path"  (
        SHIFT
        CALL SET "current_arg=%%1"

        CALL :SHOW_INFO "Set 'HOME' environment variable according to the '--home-path' specified."
        CALL :SHOW_DETAIL "The original --home-path: !current_arg!"

        SET "HOME_NORMALIZED=!current_arg!"
        FOR /f "delims=" %%i IN ('%%msys_cygpath_cmd%% -w %%HOME_NORMALIZED%%') DO SET HOME_NORMALIZED=%%i
        CALL :SHOW_DETAIL "The normalized --home-path: !HOME_NORMALIZED!"

        IF NOT EXIST "!HOME_NORMALIZED!" MKDIR "!HOME_NORMALIZED!"
    )
EXIT /B 0



:PACK
    IF EXIST "!utility_software_folder!" (
        CALL :SHOW_INFO "Packing utility files."
        7z u -uq0 -mx9 -sfx "!utility_sfx!" "!utility_software_folder!"
    )
EXIT /B 0

:UNPACK
    IF NOT EXIST "!utility_software_folder!" (
        CALL :SHOW_INFO "Unpacking utility files."
        CALL "!utility_sfx!" -y -o"!utility_folder!"
    )
EXIT /B 0



:SHOW_INFO
    cecho {olive}[TOOLSET - UTILS - GIT]{default} INFO: %~1{\n}
EXIT /B 0

:SHOW_DETAIL
    cecho {white}[TOOLSET - UTILS - GIT]{default} DETAIL: %~1{\n}
EXIT /B 0

:SHOW_ERROR
    cecho {olive}[TOOLSET - UTILS - GIT]{red} ERROR: %~1 {default} {\n}
EXIT /B 0

:SHOW_HELP
    SET "script_name=%~n0%~x0"
    ECHO #######################################################################
    ECHO #                                                                     #
    ECHO #                      T O O L   S E T U P                            #
    ECHO #                                                                     #
    ECHO #         'Git' is a distributed version-control system for           #
    ECHO #         tracking changes in source code during software             #
    ECHO #         development at high compression ratio.                      #
    ECHO #                                                                     #
    ECHO # TOOL   : Git                                                        #
    ECHO # VERSION: 2.27.0.windows.1                                           #
    ECHO # ARCH   : x64                                                        #
    ECHO #                                                                     #
    ECHO # USAGE:                                                              #
    ECHO #   %SCRIPT_NAME% {[-h^|--help^|--pack^|--unpack] ^| [--mode (1^|2^|3^|4)]       #
    ECHO #       [--home-path path/to/home]}                                   #
    ECHO #                                                                     #
    ECHO # EXAMPLES:                                                           #
    ECHO #     %script_name%                                                       #
    ECHO #     %script_name% -h                                                    #
    ECHO #     %script_name% --pack                                                #
    ECHO #     %script_name% --mode 3                                              #
    ECHO #     %script_name% --mode 2 --home-path "/home/user"                     #
    ECHO #     %script_name% --mode 4 --home-path "c:/my/home/user"                #
    ECHO #                                                                     #
    ECHO # ARGUMENTS:                                                          #
    ECHO #     -h^|--help    Print this help and exit.                          #
    ECHO #                                                                     #
    ECHO #     --pack    Pack the content of the software folder in one        #
    ECHO #         self-extract executable called 'software.exe'.              #
    ECHO #                                                                     #
    ECHO #     --unpack    Unpack the self-extract executable 'software.exe'   #
    ECHO #         to the software folder.                                     #
    ECHO #                                                                     #
    ECHO #     --mode    When 1, we will have access to the following commands #
    ECHO #         in our windows cmd prompt - 'git-bash' and 'git-cmd'.       #
    ECHO #                                                                     #
    ECHO #         When 2, we will have access to all commands of the 'mode 1' #
    ECHO #         plus the following commands - 'git', 'git-gui' and 'gitk'.  #
    ECHO #                                                                     #
    ECHO #         When 3, we will have access to all commands of the 'mode 1' # 
    ECHO #         plus the following commands - 'bash', 'git' and 'sh'.       #
    ECHO #                                                                     #
    ECHO #         When 4, we will have access to all commands of the 'mode 1' #
    ECHO #         and the following paths of 'msysgit' will be added to the  #
    ECHO #         system path - '/mingw64/bin', '/usr/local/bin', '/usr/bin', #
    ECHO #         '/usr/bin/vendor_perl' and '/usr/bin/core_perl'. With this  #
    ECHO #         we will have access to a lot of unix tools right in the     #
    ECHO #         windows cmd prompt. OBS: Use this with care^^!                #
    ECHO #                                                                     #
    ECHO #     --home-path    Path where the 'home' folder, for the git config # 
    ECHO #         files, will be located. If not specified, the 'home' folder #
    ECHO #         will be defaulted to the following location                 #
    ECHO #         '[drive]:/Users/[user]/'. Example: 'C:/Users/BillGates/'.   #
    ECHO #         This argument must be a valid path to a folder in windows   # 
    ECHO #         or 'msysgit' and must have no spaces in it. If the path     #
    ECHO #         does not exist, it will be created.                         #    
    ECHO #                                                                     #
    ECHO # EXPORTED ENVIRONMENT VARIABLES:                                     #
    ECHO #     TOOLSET_GIT_PATH    Absolute path where this tool is            #
    ECHO #         located.                                                    #
    ECHO #                                                                     #
    ECHO #     PATH    This tool will export all local changes that it made to #
    ECHO #         the path's environment variable.                            #
    ECHO #                                                                     #
    ECHO #     The environment variables will be exported only if this script  #
    ECHO #     executes without any error.                                     #
    ECHO #                                                                     #
    ECHO #######################################################################
EXIT /B 0