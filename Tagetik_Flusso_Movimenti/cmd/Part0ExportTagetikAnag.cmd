@ECHO OFF

SET LOG_FILE=%DD_PART0_WORKDIR%\LOG\Part0ExportFlussi.log

call %SETENV%\setenv_PART0.cmd

SET DD_PART0_PATH_LOG=%DD_PART0_WORKDIR%\LOG\
REM SET DD_PART0_PATH_INPUT=%DD_PART0_PATHITT%\DATA\IN\
REM SET DD_PART0_PATH_FORMAT_FILE=%DD_PART0_PATHITT%\DATA\IN\

SET DD_PART0_PATH_OUTPUT=%DD_PART0_WORKDIR%\DATA\OUT\
REM SET DD_PART0_PATH_STORICO=%DD_PART0_WORKDIR%\DATA\IN\STORICO\
SET DD_PART0_PATH_OUTPUT_STORICO=%DD_PART0_WORKDIR%\DATA\OUT\STORICO\
SET DD_PART0_PATH_SCRIPTS=%DD_PART0_WORKDIR%\SCRIPT


echo ************************************************************ >> %LOG_FILE%
echo *********************  PRODUZIONE ************************** >> %LOG_FILE%
echo [INFORMATION] - %DATE% %TIME% >> %LOG_FILE%
echo [INFORMATION] - Estrazione flusso Tagetik  >> %LOG_FILE%
echo [INFORMATION] - Richiamo la procedura per l'estrazione dei dati ExportFlussi.exe 34 null %DATE% M null null null null >> %LOG_FILE%
call %DD_PART0_WORKDIR%\BIN\ExportFlussi.exe 34 null %DATE% M null null null null >> %LOG_FILE%

set retCode=%ERRORLEVEL%

IF "x%retCode%"=="x0" (

  echo [INFORMATION] - Estrazione flusso Tagetik Anag terminata correttamente >> %LOG_FILE%

) ELSE (

  echo [ERROR]       - Estrazione flusso Tagetik Anag terminata con errore %retCode% >> %LOG_FILE%

)


echo ************************************************************ >> %LOG_FILE%
echo *********************  PRODUZIONE ************************** >> %LOG_FILE%
echo [INFORMATION] - %DATE% %TIME% >> %LOG_FILE%
echo [INFORMATION] - Estrazione flusso Tagetik  >> %LOG_FILE%
echo [INFORMATION] - Richiamo la procedura per l'estrazione dei dati ExportFlussi.exe 34 null %DATE% M null null null null >> %LOG_FILE%
call %DD_PART0_WORKDIR%\BIN\ExportFlussi.exe 35 null %DATE% M null null null null >> %LOG_FILE%

set retCode=%ERRORLEVEL%

IF "x%retCode%"=="x0" (

  echo [INFORMATION] - Estrazione flusso Tagetik Anag terminata correttamente >> %LOG_FILE%

) ELSE (

  echo [ERROR]       - Estrazione flusso Tagetik Anag terminata con errore %retCode% >> %LOG_FILE%

)




exit /b %retCode%
