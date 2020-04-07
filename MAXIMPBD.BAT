@echo OFF

if "%HB_DIR%" == ""  goto erro

if exist %MAXLIB_DIR%\MAXIMPBD.BAK  del %MAXLIB_DIR%\MAXIMPBD.BAK
if exist %MAXLIB_DIR%\MAXIMPBD.LIB  del %MAXLIB_DIR%\MAXIMPBD.LIB

if     "%1" == "/D" HBMAKE MAXIMPBD.bcd
if not "%1" == "/D" HBMAKE MAXIMPBD.bc

goto end

:erro
   echo Erro encontrado.
   goto end

:end
   if exist MAKEFILE.LNK  del MAKEFILE.LNK
   if exist MAXIMPBD.LOG  del MAXIMPBD.LOG
   if exist TRACE.LOG     del TRACE.LOG
   if exist *.TMP         del *.TMP
   if exist *.BAK         del *.BAK