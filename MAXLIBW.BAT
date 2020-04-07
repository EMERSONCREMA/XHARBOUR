@echo OFF

if "%HB_DIR%" == ""  goto erro

if exist %MAXLIB_DIR%\MAXLIBW.BAK  del %MAXLIB_DIR%\MAXLIBW.BAK
if exist %MAXLIB_DIR%\MAXLIBW.LIB  del %MAXLIB_DIR%\MAXLIBW.LIB

HBMAKE MAXLIBW.BC

goto end

:erro
   echo Erro encontrado.
   goto end

:end
   if exist MAKEFILE.LNK  del MAKEFILE.LNK
   if exist MAXLIBW.LOG   del MAXLIBW.LOG
   if exist TRACE.LOG     del TRACE.LOG
   if exist *.TMP         del *.TMP
   if exist *.BAK         del *.BAK
