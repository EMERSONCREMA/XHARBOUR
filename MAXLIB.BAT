@echo OFF

if "%HB_DIR%" == ""  goto erro

if exist %MAXLIB_DIR%\MAXLIB.BAK  del %MAXLIB_DIR%\MAXLIB.BAK
if exist %MAXLIB_DIR%\MAXLIB.LIB  del %MAXLIB_DIR%\MAXLIB.LIB

if     "%1" == "/D" HBMAKE maxlib.bcd
if not "%1" == "/D" HBMAKE maxlib.bc

goto end

:erro
   echo Erro encontrado.
   goto end

:end
   if exist MAKEFILE.LNK  del MAKEFILE.LNK
   if exist MAXLIB.LOG    del MAXLIB.LOG
   if exist TRACE.LOG     del TRACE.LOG
   if exist *.TMP         del *.TMP
   if exist *.BAK         del *.BAK