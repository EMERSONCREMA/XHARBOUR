/*

 MaxArq.prg
 Descricao: Biblioteca de funcoes de tratamento de arquivos.
 Desenvolvido por MAX SCALLA Informatica Ltda.
 
 EMERSON DA SILVA CREMA
 21/05/19 * Colocado .F. em todos os parametros lTrans de sqlExecute()
            quando eh um comando "SELECT".
            
 DENIS MAZZUCATTO RODRIGUES
 17/03/16 * Desenvolvimento de xlsCellFont(), xlsOpen() e xlsClose().
          * Implementada nova forma de criar o XLS em xlsNew() e xlsSave().
 
 EMERSON DA SILVA CREMA
 26/01/15 * Implementado lRetry em mxFMove().
 01/11/13 * Implementado IsDirectory() em IsDirExist().

 DENIS MAZZUCATTO RODRIGUES
 05/07/12 * Implementado o parametro cDir em mxDirTemp().
 29/06/12 * Desenvolvimento de mxDirTemp().
 06/06/12 * Implementado parametro hFile em mxFAddLine().

 EMERSON DA SILVA CRMEA
 19/05/12 * Implementacao de sqlDefUser() em mxMd().

 DENIS MAZZUCATTO RODRIGUES
 01/03/12 * Desenvolvimento de xlsNew(), xlsWrite() e xlsSave().
 07/07/11 * Desenvolvimento de ConsoleChangeX().
 08/09/10 * Desenvolvimento de GetShortFileName().

 EMERSON DA SILVA CREMA
 22/05/09 * Implementado formatacao de campo data em fSay()
          * Implementado tambem em fSay() o parametro uDefault.
 20/05/09 * Desenvolvimento de fSay().
 26/01/09 * Implementado parametro lRetry em mxFOpen().
          * Implementada mensagem de confirmacao p/ lRetry em mxFCreate().
 26/06/08 * Desenvolvimento e implementacao de mxWinDir().
 24/06/08 * Correcao no funcionamento de mxSubDir().
 08/05/08 * Alteracao em getFSystem() p/ q localize a pasta correta dos
            arquivos quando em plataforma NT.
          * Correcao em SearchText().
 27/07/07 * Desenvolvimento de outToFile().
 23/05/07 * Remocao de Del().
 07/02/07 * Correcoes em mxCopy().
 21/12/06 * Correcao em mxFMove(), pois qdo os arquivos eram de unidades
            diferentes nao era possivel mover o arquivo.
 12/05/06 * Implementado parametro uProgress em mxFEval().
          * Alteracao em mxFSize() p/ retornar a posicao anterior.
 06/04/06 * Desenvolvimento de mxFEval().
 03/02/06 * Desenvolvimento de IsDifDrv().
 16/08/05 * Desenvolvimento de GetDrive().
          * Reformulacao em mxMd() p/ compatibilidade com o WINDOWS XP.
 28/07/05 * Implementado parametro aExcept em mxSubDir().
 20/06/05 * Desenvolvimento de mxFSize().
 01/06/05 * Desenvolvimento de mxFCopy().
 20/05/05 * Desenvolvimento de mxSubDir().
 12/04/05 * Implementado parametro nTotRetry em mxFDel().
 20/07/04 * Desenvolvimento de getFSystem().

*/

#include "std.ch"
#include "inkey.ch"
#include "fileIO.ch"

#define SQLRDD ( cRdd <> NIL .AND. Upper( cRdd ) = "SQLRDD" )

STATIC nHandleXLS, cFileXLS, nTypeXLS, oExcelXLS, oSheetXLS, aFontXLS, cDirTemp

/*----------------------------------------------------------------------------
 Copia um arquivo para um destino qualquer.

 Parametros

 cFile    : Nome do arquivo de origem.
 cDest    : Nome do arquivo de destino.
 bExecute : Bloco de codigos que pode ser incluido opcionalmente. Sera
            executado a cada gravacao no arquivo de destino e recebe
            como parametros o total de bytes que estao sendo copiados,
            o total de bytes que foram copiados, e o nome do arquivo de
            origem.
 lMsg     : Exibir Mensagens de Erro

 Retorno : .T., se a operacao for bem sucedida.
----------------------------------------------------------------------------*/

FUNCTION mxCopy( aFile, cDest, lProgress, lMsg )

   #define COPY_SIZE_BUFFER 4096

   LOCAL lReturn   := .F.
   LOCAL lFileOpen := .F.
   LOCAL lDestOpen := .F.
   LOCAL nFile     := 1

   LOCAL hFile, hDest, nSize, nCopy, cBuffer, nRest, nBuffer, cFile

   vDef( @lProgress, .F. )
   vDef( @lMsg     , .T. )

   IF ValType( aFile ) = "C"
      aFile := { aFile }
   ENDIF

   DO WHILE .T.

      cFile   := aFile[ nFile ]
      lReturn := .F.

      BEGIN SEQUENCE

         IF ! lProgress
            COPY FILE ( cFile ) TO ( cDest )
            lReturn := .T.
            BREAK
         ENDIF

         hFile := FOpen( cFile, FO_READ + FO_SHARED )

         IF FError() <> 0
            IF lMsg
               MsgDlg( "Erro ao tentar abrir o arquivo de origem !" )
            ENDIF
            BREAK
         ENDIF

         lFileOpen := .T.

         IF nFile = 1
            hDest := mxFCreate( cDest )
            IF FError() <> 0
               IF lMsg
                  MsgDlg( "Erro ao tentar criar o arquivo de destino !" )
               ENDIF
               BREAK
            ENDIF
            lDestOpen := .T.
         ENDIF

         nSize := mxFSize( hFile )
         nRest := nSize
         nCopy := 0

         nBuffer := Int( nSize / 10 )

         DO CASE
            CASE nBuffer > COPY_SIZE_BUFFER ; nBuffer := COPY_SIZE_BUFFER
            CASE nBuffer = 0                ; nBuffer := 1
         ENDCASE

         IF lProgress
            prgsStart( "Copiando " + cFile + " para " + cDest, nSize, 1 )
         ENDIF

         DO WHILE nRest > 0

            IF nRest < nBuffer
               nBuffer := nRest
            ENDIF

            cBuffer := Space( nBuffer )

            IF FRead( hFile, @cBuffer, nBuffer ) < nBuffer
               IF lMsg
                  MsgDlg( "Problemas ao tentar gravar !" )
               ENDIF
               BREAK
            ENDIF

            IF FWrite( hDest, cBuffer ) < nBuffer
               IF lMsg
                  MsgDlg( "Problemas ao tentar gravar !" )
               ENDIF
               BREAK
            ENDIF

            nRest -= nBuffer
            nCopy += nBuffer

            IF lProgress
               prgsNext( nCopy )
            ENDIF

         ENDDO

         lReturn := .T.

      ENDSEQUENCE

      IF lFileOpen
         FClose( hFile )
      ENDIF

      IF ( ! lProgress ) .OR. nFile = Len( aFile ) .OR. ( ! lReturn )
         EXIT
      ENDIF

      nFile ++

   ENDDO

   IF lDestOpen
      FClose( hDest )
   ENDIF

RETURN( lReturn )



FUNCTION mxFMove( cOri, cDes, uRdd, lRetry, lMsg )

   // Tambem pode ser utilizada p/ arquivos SQL.

   LOCAL lReturn := .F.
   LOCAL lAbort  := .F.
   LOCAL nRetry  := 0

   LOCAL cScreen, cRddOri, cRddDes, cError

   vDef( @uRdd  , ""  )
   vDef( @lMsg  , .T. )
   vDef( @lRetry, .T. )

   IF ValType( uRdd ) = "A"
      cRddOri := uRdd[1]
      cRddDes := uRdd[2]
   ELSE
      cRddOri := uRdd
      cRddDes := uRdd
   ENDIF

   BEGIN SEQUENCE

      IF Empty( cOri ) .OR. Empty( cDes )
         BREAK
      ELSEIF ! dbFile( cOri, cRddOri )
         BREAK
      ENDIF

      DO WHILE .T.
         IF mxFDel( cDes, NIL, NIL, cRddDes )
            EXIT
         ENDIF
         IF ++ nRetry = 50
            IF ! lRetry
               BREAK
            ENDIF
            lAbort := .T.
            IF cScreen = NIL
               cScreen := SaveScreen()
            ENDIF
            IF lMsg
               MsgDlg( "N„o foi poss¡vel excluir o arquivo;" + cDes + " !;;ESC abandona.", "NP" )
            ENDIF
         ENDIF
         IF nRetry <> 1 .AND. lAbort .AND. mxInKey( 0.01 ) = K_ESC
            BREAK
         ENDIF
      ENDDO

      nRetry := 0

      DO WHILE ! dbFile( cDes, cRddDes ) .AND. dbFile( cOri, cRddOri )

         nRetry ++

         IF cRddOri <> cRddDes
            IF dbConverte( { cOri, cRddOri }, { cDes, cRddDes }, .T., { "Movendo", 1 }, @cError )
               mxFDel( cOri, NIL, NIL, cRddOri )
            ELSE
               IF lMsg
                  MsgDlg( cError )
               ENDIF
               BREAK
            ENDIF
         ELSEIF cRddOri = "SQLRDD"
            sqlRenameTable( cOri, cDes )
         ELSE
            IF lMsg
               Status( "Movendo " + cOri, NIL, 1 )
            ENDIF
            IF IsDifDrv( cOri, cDes )
               FileCopy( cOri, cDes )
            ELSE
               FileMove( cOri, cDes )
            ENDIF
            IF File( cDes )
               FileDelete( cOri )
            ENDIF
         ENDIF

         IF nRetry = 50
            IF ! lRetry
               BREAK
            ENDIF
            lAbort := .T.
            IF cScreen = NIL
               cScreen := SaveScreen()
            ENDIF
            IF lMsg
               MsgDlg( "N„o foi poss¡vel renomear o arquivo;" + cOri + ";para;" + cDes + " !;;ESC abandona.", "NP" )
            ENDIF
         ENDIF

         IF nRetry <> 1 .AND. lAbort .AND. mxInKey( 0.01 ) = K_ESC
            BREAK
         ENDIF

      ENDDO

      lReturn := .T.

   ENDSEQUENCE

   IF cScreen <> NIL
      RestScreen( ,,,, cScreen )
   ENDIF

RETURN( lReturn )



FUNCTION mxFCopy( cOri, cDes, lRetry, uRdd, lStatus )

   // Tambem pode ser utilizada p/ arquivos SQL.

   #define MSG_FCOPY "N„o foi poss¡vel copiar o arquivo;de " + cOri + " para " + cDes + " !;;"

   LOCAL lReturn := .T.
   LOCAL cWait, lMsg, nRetry, cRddOri, cRddDes

   vDef( @lRetry , .T. )
   vDef( @lStatus, .T. )
   vDef( @uRdd   , ""  )

   IF ValType( uRdd ) = "A"
      cRddOri := uRdd[1]
      cRddDes := uRdd[2]
   ELSE
      cRddOri := uRdd
      cRddDes := uRdd
   ENDIF

   IF isCsw()
      ScreenSave()
      cWait := Time()
      lMsg  := .T.
   ENDIF

   BEGIN SEQUENCE

      IF cRddOri <> "RQBRDD" .AND. ! dbFile( cOri, cRddOri )
         lReturn := .F.
         BREAK
      ENDIF

      mxFDel( cDes, NIL, NIL, cRddDes )

      DO WHILE .T.

         FOR nRetry := 1 TO 5
            IF cRddOri <> cRddDes
               IF dbConverte( { cOri, cRddOri }, { cDes, cRddDes }, .T., { "Copiando", 1 } )
                  BREAK
               ENDIF
            ELSEIF cRddOri = "SQLRDD"
               IF sqlCopyTable( cOri, cDes )
                  BREAK
               ENDIF
            ELSE
               IF lStatus
                  Status( "Copiando " + cDes, NIL, 1 )
               ENDIF
               IF isCsw() .AND. ! File( cOri )
                  mxInkey( 5 )
                  lReturn := .F.
                  BREAK
               ENDIF
               FileCopy( cOri, cDes )
               IF File( cDes )
                  BREAK
               ENDIF
            ENDIF
         NEXT

         IF lRetry
            IF isCsw()
               IF mxInkey( 0.01 ) = K_ESC
                  EXIT
               ENDIF
               IF lMsg
                  lMsg := .F.
                  mxInkey( 5 )
                  MsgDlg( MSG_FCOPY + "Tecle ^ESC^ para abortar.", "NP" )
               ENDIF
               IF lStatus
                  Status( "Aguarde, tentando copiar arquivo... (Tempo restante: " + Elaptime( Elaptime( cWait, Time() ), "00:05:00" ) + ") " )
               ENDIF
               IF Elaptime( cWait, Time() ) > "00:05:00"
                  EXIT
               ENDIF
            ELSEIF MsgDlg( MSG_FCOPY + "Tentar novamente ?", SimNao ) = 2
               EXIT
            ENDIF
         ENDIF

      ENDDO

      lReturn := .F.

   ENDSEQUENCE

   IF isCsw()
      ScreenRest()
   ENDIF

RETURN( lReturn )



FUNCTION mxFDel( uFiles, uNoDel, nTotRetry, cRdd )

   // Tambem pode ser utilizada p/ arquivos SQL.

   LOCAL lReturn := .T.
   LOCAL aDel    := {}
   LOCAL aNoDel  := {}

   LOCAL nFiles, nRetry, nConnSave, cFile, cDel

   vDef( @nTotRetry, 10 )
   vDef( @cRdd     , "" )

   DO CASE
      CASE ValType( uFiles ) = "C" ; AuxDel( uFiles, @aDel, cRdd )
      CASE ValType( uFiles ) = "A" ; aEval( uFiles, { |f| AuxDel( f, @aDel, cRdd ) } )
   ENDCASE

   DO CASE
      CASE ValType( uNoDel ) = "C" ; AuxDel( uNoDel, @aNoDel, cRdd )
      CASE ValType( uNoDel ) = "A" ; aEval( uNoDel, { |f| AuxDel( f, @aNoDel, cRdd ) } )
   ENDCASE

   FOR nFiles := 1 TO Len( aDel )

      IF ( uNoDel = NIL ) .OR. ( aScan( aNoDel, aDel[ nFiles ] ) = 0 )

         cFile := aDel[ nFiles ]

         IF SQLRDD

            nConnSave := sqlSetConn( NIL                          ,;
                                     sqlGetInfo( cFile, "DTB"    ),;
                                     sqlGetInfo( cFile, "SCHEMA" ) )

         ENDIF

         FOR nRetry := 1 TO nTotRetry

            IF ! dbFile( cFile, cRdd )
               EXIT
            ENDIF

            IF SQLRDD
               IF GetExt( cFile ) = ".CDX"
                  cDel := DelExt( DelPath( cFile ) )
                  sqlDeleteIndex( cDel )
               ELSE
                  cDel := sqlGetInfo( cFile, "FILE" )
                  SR_Exec( { || SR_DropTable( cDel ) } )

                  sqlExecute( { "DROP SEQUENCE " + sqlGetInfo( cFile, "SCHEMA" ) + "." + cDel + "_sq CASCADE",;
                                "DELETE FROM "   + sqlGetInfo( cFile, "SCHEMA" ) + ".sr_mgmnttables  WHERE UPPER(TABLE_) = '" + Upper( cDel ) + "'",;
                                "DELETE FROM "   + sqlGetInfo( cFile, "SCHEMA" ) + ".sr_mgmntindexes WHERE UPPER(TABLE_) = '" + Upper( cDel ) + "'" } )
               ENDIF
            ELSE
               FErase( cFile )
            ENDIF

            IF nRetry <> 1
               mxInKey( 0.01 )
            ENDIF

         NEXT

         IF lReturn .AND. dbFile( cFile, cRdd )
            lReturn := .F.
         ENDIF

         IF SQLRDD
            sqlSetConn( nConnSave )
         ENDIF

      ENDIF

   NEXT

RETURN( lReturn )



STATIC FUNCTION AuxDel( cFiles, aArray, cRdd )

   LOCAL cPath, aFiles

   IF At( "*", cFiles ) = 0 .AND. At( "?", cFiles ) = 0

      IF dbFile( cFiles, cRdd )
         aAdd( aArray, cFiles )
      ENDIF

   ELSE

      IF At( "\", cFiles ) = 0
         cPath := ""
      ELSE
         cPath := Left( cFiles, Rat( "\", cFiles ) )
      ENDIF

      IF SQLRDD
         aFiles := sqlDirectory( cFiles )
      ELSE
         aFiles := Directory( cFiles )
      ENDIF

      IF Len( aFiles ) > 0
         aEval( aFiles, { |file| aAdd( aArray, cPath + file[1] ) } )
      ENDIF

   ENDIF

RETURN( NIL )



FUNCTION mxFCreate( cCreate, lRetry, nHandle )

   LOCAL nReturn := -1
   LOCAL nRetry

   vDef( @lRetry, .F. )
   vDef( @nHandle, FC_NORMAL )

   BEGIN SEQUENCE

      DO WHILE .T.

         FOR nRetry := 1 TO 10
            nReturn := FCreate( cCreate, nHandle )
            IF nReturn >= 0
               BREAK
            ENDIF
         NEXT

         IF ! lRetry .OR. MsgDlg( "N„o foi poss¡vel criar o arquivo !;" + cCreate + ";;Tentar novamente ?", SimNao ) = 2
            EXIT
         ENDIF

      ENDDO

   ENDSEQUENCE

RETURN( nReturn )



FUNCTION mxFOpen( cOpen, nFlag, lRetry )

   LOCAL nRetry

   vDef( @lRetry, .F. )

   DO WHILE .T.

      FOR nRetry := 1 TO 20
         IF ( nReturn := FOpen( cOpen, nFlag ) ) >= 0
            EXIT
         ENDIF
      NEXT

      IF ! lRetry .OR. MsgDlg( "N„o foi poss¡vel abrir o arquivo !;" + cOpen + ";;Tentar novamente ?", SimNao ) = 2
         EXIT
      ENDIF

   ENDDO

RETURN( nReturn )



FUNCTION mxFSize( nHandle )

   LOCAL nCurr := FSeek( nHandle, 0, FS_RELATIVE )
   LOCAL nSize := FSeek( nHandle, 0, FS_END )

   FSeek( nHandle, nCurr, FS_SET )

RETURN( nSize )



FUNCTION mxFAddLine( cFile, cWrite, lReWrite, hFile )

   LOCAL lReturn := .F.
   LOCAL lCreate := .F.
   LOCAL lClose  := ( hFile = NIL )

   LOCAL nLen, cFileTmp

   vDef( @lReWrite, .F. )

   BEGIN SEQUENCE

      IF lReWrite
         FErase( cFile )
      ENDIF

      IF lClose

         cFileTmp := ModExt( cFile, "TMP" )

         FErase( cFileTmp )

         IF File( cFile )
            FRename( cFile, cFileTmp )
         ELSE
            FClose( mxFCreate( cFileTmp ) )
            lCreate := .T.
         ENDIF

         hFile := mxFOpen( cFileTmp, FO_EXCLUSIVE + FO_WRITE )
         
      ELSEIF ! File( cFile )

         FClose( mxFCreate( cFile ) )
         
         hFile   := mxFOpen( cFile, FO_EXCLUSIVE + FO_WRITE )
         lCreate := .T.

      ENDIF

      IF hFile < 0
         BREAK
      ENDIF

      IF ! lCreate
         cWrite := Chr(13) + Chr(10) + cWrite
      ENDIF

      nLen := Len( cWrite )

      FSeek( hFile, 0, FS_END )
      FWrite( hFile, cWrite, nLen )

      IF lClose
         FClose( hFile )
         FRename( cFileTmp, cFile )
         lReturn := File( cFile )
      ELSE
         lReturn := .T.
      ENDIF

   ENDSEQUENCE

RETURN( lReturn )



FUNCTION mxFEval( cFile, bEval, uProgress )

   LOCAL nRead := 0

   LOCAL nOpen, cRead

   IF File( cFile )

      nOpen := mxFOpen( cFile, FO_READ + FO_SHARED )

      IF nOpen >= 0

         DO WHILE LineRead( nOpen, @cRead, NIL, uProgress )
            Eval( bEval, cRead )
            nRead ++
         ENDDO

         fClose( nOpen )

      ENDIF

   ENDIF

RETURN( nRead )



FUNCTION mxMd( cPath, cRdd )

   // Tambem pode ser utilizada p/ arquivos SQL.

   LOCAL nReturn := 0

   LOCAL nPos, nConnSave
   LOCAL cDrvDefault, cDirDefault, cDirCreate, cPathAux, cDrv

   BEGIN SEQUENCE

      IF Empty( cPath )
         BREAK
      ELSEIF IsDirExist( cPath, cRdd )
         BREAK
      ENDIF

      IF SQLRDD

         IF Right( cPath, 1 ) <> "\"
            cPath += "\"
         ENDIF

         nConnSave := sqlGetConn( "CONN" )

         cDrv := Lower( sqlGetInfo( cPath, "DTB" ) )

         IF ! IsDirExist( "\" + cDrv, cRdd )
            IF IsDigit( cDrv )  // Nao pode haver database iniciados por numero
               nReturn := -1
               BREAK
            ELSEIF ! sqlExecute( "CREATE DATABASE " + cDrv + ;
                                 " WITH OWNER = postgres"  + ;
                                 " TEMPLATE = template0"   + ;
                                 " ENCODING = 'WIN1252'", NIL, .F. )
               nReturn := -1
               BREAK
            ENDIF
            IF IsProcedure( "sqlAddConn" )
               BREAK
            ENDIF
            sqlAddConn( "localhost", cDrv )
         ENDIF

         cDirCreate := Lower( sqlGetInfo( cPath, "SCHEMA" ) )

         sqlSetConn( NIL, cDrv )
         
         IF ! IsDirExist( cDirCreate, cRdd )
            IF IsDigit( cDirCreate )  // Nao pode haver schemas iniciados por numeros
               nReturn := -1
            ELSEIF ! sqlExecute( "CREATE SCHEMA " + cDirCreate + " AUTHORIZATION " + sqlDefUser()            , NIL     , .F., NIL, NIL, NIL, NIL, .T. )
               nReturn := -1
            ENDIF
         ENDIF

         sqlSetConn( nConnSave )

      ELSE

         cDrvDefault := DiskName()
         cDirDefault := CurPath()
         cPathAux    := ""

         cDrv := GetDrive( cPath )

         IF ! Empty( cDrv )
            DiskChange( cDrv )
         ENDIF

         cPath := ConfPath( AllTrim( cPath ) )

         IF At( ":", cPath ) = 2
            cPath := Subs( cPath, 3 )
         ENDIF

         IF Left( cPath, 1 ) = "\"
            cPathAux := "\"
            DirChange( "\" )
            cPath := Subs( cPath, 2 )
         ELSE
            cPathAux := CurPath() + "\"
         ENDIF

         DO WHILE ! Empty( cPath )

            nPos := At( "\", cPath )

            IF nPos = 0
               cDirCreate := cPath
               cPath      := ""
            ELSE
               cDirCreate := Left( cPath, nPos -1 )
               cPath      := Subs( cPath, nPos +1 )
            ENDIF

            IF ! IsDirExist( cDirCreate )

               nReturn := DirMake( cDirCreate )

               IF nReturn <> 0
                  EXIT
               ENDIF

            ENDIF

            cPathAux := ConfPath( cPathAux ) + cDirCreate

            DirChange( cPathAux )

         ENDDO
         
         IF ! Empty( cDrv )
            DiskChange( cDrvDefault )
         ENDIF

         DirChange( cDirDefault )
         
      ENDIF

   ENDSEQUENCE

RETURN( nReturn = 0 )



FUNCTION mxSubDir( cDir, bEval, aExcept )

   LOCAL aDir, nDir, cSubDir, nAux

   vDef( @cDir   , "" )
   vDef( @aExcept, {} )

   IF ValType( aExcept ) = "C"
      aExcept := { aExcept }
   ENDIF

   cDir := ConfPath( cDir )
   aDir := Directory( cDir + "*.*", "D" )

   DO WHILE .T.
      nAux := aScan( aDir, { |x| foundStr( Trim( x[1] ), ".|.." ) } )
      IF nAux = 0
         EXIT
      ENDIF
      aDel( aDir, nAux )
      aSize( aDir, Len( aDir ) -1 )
   ENDDO

   Eval( bEval, cDir )

   FOR nDir := 1 TO Len( aDir )

      IF Left( aDir[ nDir, 5 ], 1 ) = "D"

         cSubDir := ConfPath( cDir + aDir[ nDir, 1 ] )

         IF aScan( aExcept, { |x| ConfPath( x ) = cSubDir } ) = 0
            mxSubDir( cSubDir, bEval )
         ENDIF

      ENDIF

   NEXT

RETURN( NIL )



FUNCTION mxWinDir()

   LOCAL cDir := ""

   IF IsWinNT()
      cDir := mxGetEnv( "WINDIR" )
      IF Empty( cDir )
         cDir := mxGetEnv( "SYSTEMROOT" )
      ENDIF
   ELSE
      cDir := mxGetEnv( "WINBOOTDIR" )
   ENDIF

RETURN( ConfPath( cDir ) )



FUNCTION mxDirTemp( cDir )

   IF cDir <> NIL

      cDirTemp := ConfPath( cDir )

   ELSEIF cDirTemp = NIL
   
      IF IsDef( "NO_DIR_TEMP" ) .OR. ! sqlActive()
         cDirTemp := ""
      ELSE
         cDirTemp := AllTrim( GetNoEmpty( mxGetEnv( "TEMP" ), mxGetEnv( "TMP" ) ) )
         IF ! Empty( cDirTemp )
            cDirTemp := ConfPath( cDirTemp )
         ENDIF
         IF ! IsDirExist( cDirTemp )
            cDirTemp := ""
         ENDIF
      ENDIF

   ENDIF

RETURN( cDirTemp )



/*----------------------------------------------------------------------------
  Procura uma String dentro de um arquivo e nao achando pode acrescenta-la
  ProcOk retorna
  0 - Operacao sem sucesso
  1 - String encontrada
  2 - String gravada
  3 - Arquivo nao encontrado
----------------------------------------------------------------------------*/

FUNCTION SearchText( cFileName, uSearch, cStatus, cRemarks )

   #define SEARCH_NOTFOUND     0
   #define SEARCH_FOUND        1
   #define SEARCH_WRITE        2
   #define SEARCH_FILENOTFOUND 3
   #define SEARCH_ERROR        4
   #define SEARCH_UPDATE       5

   #define SS_WRITE    "W"
   #define SS_NOBACKUP "NB"

   LOCAL aWrite     := {}
   LOCAL aSearch    := {}
   LOCAL nSchStatus := SEARCH_NOTFOUND

   LOCAL nFHandle, cBackupFile, cRead, nWrite, nSearch, nSimbol, cRemUpdate

   BEGIN SEQUENCE

      IF ! File( cFileName )
         nSchStatus := SEARCH_FILENOTFOUND
         BREAK
      ENDIF

      IF ValType( uSearch ) = "C"
         aAdd( aSearch, { uSearch, SEARCH_NOTFOUND } )
      ELSE
         aEval( uSearch, { |s| aAdd( aSearch, { s, SEARCH_NOTFOUND } ) } )
      ENDIF

      nFHandle := FOpen( cFileName, 2 )

      DO WHILE LineRead( nFHandle, @cRead )

         nSearch := aScan( aSearch, { |s| AllTrim( Upper( s[1] ) ) = AllTrim( Upper( cRead ) ) } )

         cRemUpdate := ""

         IF nSearch = 0

            nSimbol := At( "=", cRead )

            IF nSimbol <> 0 .AND. foundStr( Upper( Left( cRead, nSimbol -1 ) ), "BUFFERS|FILES|SHELL" )

               nSearch := aScan( aSearch, { |s| Upper( Left( s[1], nSimbol ) ) = Upper( Left( cRead, nSimbol ) ) } )

               IF nSearch <> 0
                  cRemUpdate            := cRemarks
                  cRead                 := aSearch[ nSearch, 1 ]
                  aSearch[ nSearch, 2 ] := SEARCH_UPDATE
               ENDIF

            ENDIF

         ELSE

            aSearch[ nSearch, 2 ] := SEARCH_FOUND

         ENDIF

         IF cRemUpdate <> NIL .AND. ! Empty( cRemUpdate )
            aAdd( aWrite, cRemUpdate )
         ENDIF

         aAdd( aWrite, cRead )

      ENDDO

      fClose( nFHandle )

      IF aScan( aSearch, { |s| s[2] <> SEARCH_FOUND } ) = 0
         nSchStatus := SEARCH_FOUND
      ENDIF

      IF nSchStatus = SEARCH_NOTFOUND .AND. mxIn( cStatus, { SS_WRITE, SS_NOBACKUP } )

         IF cStatus = SS_WRITE

            cBackupFile := Subs( cFileName, 1, At( ".", cFileName ) ) + "BAK"

            FileCopy( cFileName, cBackupFile )
            fErase( cFileName )
            IF File( cFileName )
               nSchStatus := SEARCH_ERROR
               BREAK
            ENDIF

         ENDIF

         nFHandle := mxFCreate( cFileName )

         IF nFHandle = -1
            IF cStatus = SS_WRITE .AND. ! File( cFileName )
               FileCopy( cBackupFile, cFileName )
            ENDIF
            nSchStatus := SEARCH_ERROR
            BREAK
         ENDIF

         FOR nSearch := 1 TO Len( aSearch )
            IF aSearch[ nSearch, 2 ] = SEARCH_NOTFOUND
               IF cRemarks <> NIL
                  aAdd( aWrite, cRemarks )
               ENDIF
               aAdd( aWrite, aSearch[ nSearch, 1 ] )
            ENDIF
         NEXT

         FOR nWrite := 1 TO Len( aWrite )

            IF ! WriteFile( nFHandle, aWrite[ nWrite ] )
               nSchStatus := SEARCH_ERROR
            ENDIF

         NEXT

         fClose( nFHandle )

         IF nSchStatus <> SEARCH_ERROR
            nSchStatus := SEARCH_WRITE
         ENDIF

      ENDIF

   ENDSEQUENCE

RETURN( nSchStatus )



FUNCTION WriteFile( nFile, cStrWrite )

   fSeek( nFile, 0, 2 )

RETURN( FWrite( nFile, cStrWrite + Chr(13) + Chr(10) ) = ( Len( cStrWrite ) +2 ) )



FUNCTION FileCreate( nFile, cFileName, nStatus )

   nFile := FCreate( cFileName, nStatus )

RETURN( !FileError() )



FUNCTION FileOpen( nFile, cFileName, nStatus )

   nFile := FOpen( cFileName, nStatus )

RETURN( !FileError() )



FUNCTION FileRead( nFile, cString, nStrSize )

   nStrSize := FRead( nFile, @cString, nStrSize )

RETURN( !FileError() )



FUNCTION FileWrite( nFile, cString, nStrSize )

   FWrite( nFile, cString, nStrSize )

RETURN( !FileError() )



FUNCTION FileError()

   DO CASE
      CASE FError() =  0 ; RETURN( .F. )
      CASE FError() =  2 ; Mensagem( "Arquivo n„o encontrado ! Tecle algo...", 2 )
      CASE FError() =  3 ; Mensagem( "PATH n„o encontrado ! Tecle algo...", 2 )
      CASE FError() =  4 ; Mensagem( "Excesso de arquivos abertos ! Tecle algo...", 2 )
      CASE FError() =  5 ; Mensagem( "Acesso negado ! Tecle algo...", 2 )
      CASE FError() =  6 ; Mensagem( "Handle inv lido ! Tecle algo...", 2 )
      CASE FError() =  8 ; Mensagem( "Mem¢ria insuficiente ! Tecle algo...", 2 )
      CASE FError() = 15 ; Mensagem( "Drive inv lido ! Tecle algo...", 2 )
      CASE FError() = 19 ; Mensagem( "Tentativa de gravar em disco protegido contra grava‡„o ! Tecle algo...", 2 )
      CASE FError() = 21 ; Mensagem( "Drive n„o est  pronto ! Tecle algo...", 2 )
      CASE FError() = 23 ; Mensagem( "Erro de dado CRC ! Tecle algo...", 2 )
      CASE FError() = 29 ; Mensagem( "Falha na grava‡„o ! Tecle algo...", 2 )
      CASE FError() = 30 ; Mensagem( "Falha na leitura ! Tecle algo...", 2 )
      CASE FError() = 32 ; Mensagem( "Viola‡„o de compartilhamento ! Tecle algo...", 2 )
      CASE FError() = 33 ; Mensagem( "Viola‡„o de lock ! Tecle algo...", 2 )
   ENDCASE

RETURN( .T. )



FUNCTION FindFile( cFile, cDirectory )

   LOCAL lReturn := File( cFile )
   LOCAL cPath   := GetEnv( "PATH" ) + ";"
   LOCAL cSeek   := CurDir() + "\"
   
   IF Left( cSeek, 2 ) <> "\\"
      cSeek := "\" + cSeek
   ENDIF

   DO WHILE ! lReturn .AND. Len( cPath ) > 0

      mxWait( "verificando a existˆncia de " + cFile )

      cSeek := Left( cPath, At( ";", cPath ) -1 )
      cPath := Subs( cPath, Len( cSeek ) +2 )
      cSeek := If( Right( cSeek, 1 ) = ".", Left( cSeek, Len( cSeek ) -1 ), cSeek + "\" )

      lReturn := File( cSeek + cFile )

   ENDDO

   cDirectory := If( lReturn, cSeek, "" )

RETURN( lReturn )



/*----------------------------------------------------------------------------
 Le uma linha em um arquivo texto.
 O fim de cada linha e reconhecido pelo conjunto de caracteres
 Chr(13) + Chr(10).
 Chr(13) = Carriage return (ENTER)
 Chr(10) = LineFeeds (HOME)

 Parametros

 nHandle   : Handle devolvidor pelas funcoes FOpen() ou FCreate().
 cLine     : Variavel para retorno da string com o conteudo da linha.
 cSimbol   : Define outro finalizador de linha
 uProgress : Se .T. ou String, utiliza progressivo.

 Retorno : Se .F., chegou no final do arquivo.
----------------------------------------------------------------------------*/

FUNCTION LineRead( nHandle, cLine, cSimbol, uProgress, cPrgsColor )

   #define SIZE_BUFFER  512
   #define END_SIMBOL   If( cSimbol = NIL, Chr(13) + Chr(10), cSimbol )

   LOCAL lProgress := .F.

   LOCAL cBuffer, nBytes, nEndSearch, nSkip, lStart, nSize

   IF uProgress <> NIL
      lProgress := .T.
      IF ValType( uProgress ) = "L"
         uProgress := "Lendo arquivo"
      ENDIF
   ENDIF

   cLine := ""

   IF lProgress
      lStart := ( FSeek( nHandle, 0, FS_RELATIVE ) = 0 )
   ENDIF

   DO WHILE .T.

      IF lProgress .AND. lStart

         nSize := mxFSize( nHandle )

         prgsStart( uProgress, nSize, 2, cPrgsColor )

         lStart := .F.

      ENDIF

      cBuffer := Space( SIZE_BUFFER )
      nBytes  := FRead( nHandle, @cBuffer, SIZE_BUFFER )

      IF nBytes = 0
         EXIT
      ENDIF

      IF nBytes < SIZE_BUFFER
         cBuffer := Left( cBuffer, nBytes )
      ENDIF

      cLine += cBuffer

      nEndSearch := At( END_SIMBOL, cLine )

      IF nEndSearch <> 0
         IF nEndSearch <> ( nBytes - ( Len( END_SIMBOL ) -1 ) )
            nSkip := ( Len( cLine ) - ( nEndSearch + Len( END_SIMBOL ) - 1 ) )
            IF nSkip <> 0
               FSeek( nHandle, -nSkip, FS_RELATIVE )
            ENDIF
            IF lProgress
               prgsNext( FSeek( nHandle, 0, FS_RELATIVE ), NIL, cPrgsColor )
            ENDIF
         ELSEIF lProgress
            prgsNext( FSeek( nHandle, 0, FS_RELATIVE ), NIL, cPrgsColor )
         ENDIF
         cLine := Left( cLine, nEndSearch -1 )
         EXIT
      ENDIF

      IF lProgress
         prgsNext( FSeek( nHandle, 0, FS_RELATIVE ), NIL, cPrgsColor )
      ENDIF

   ENDDO

   IF ! Empty( cLine )
      cLine := StrTran( cLine, END_SIMBOL, "" )
   ENDIF

RETURN( nBytes > 0 .OR. ( Len( cLine ) <> 0 ) )



FUNCTION Num_TempFile()

   LOCAL nSeconds

   DO WHILE ( nSeconds := Abs( Int( ( Seconds()-Int( Seconds() ) ) * 100 ) ) ) > 99
   ENDDO

RETURN( Subs( Time(), 7, 2 ) + StrZero( nSeconds, 2 ) )



FUNCTION ModExt( cFile, cExt, cDiv )

   vDef( @cDiv, "\" )

   DelExt( @cFile, cDiv )

   IF At( ".", cExt ) = 0
      cFile += "." + cExt
   ELSE
      cFile += cExt
   ENDIF

RETURN( cFile )



FUNCTION DelExt( cFile, cDiv )

   LOCAL nPoint := Rat( ".", cFile )
   
   vDef( @cDiv, "\" )

   IF IsUseExt( cFile, cDiv )
      cFile := Left( cFile, nPoint -1 )
   ENDIF

RETURN( cFile )



FUNCTION DelPath( cFile, cDiv )

   LOCAL nPos

   vDef( @cDiv, "\" )

   DO WHILE ( nPos := At( cDiv, cFile ) ) > 0
      cFile := Subs( cFile, nPos +1 )
   ENDDO

   nPos := At( ":", cFile )

   IF nPos > 0
      cFile := Subs( cFile, nPos + 1 )
   ENDIF

RETURN( cFile )



FUNCTION GetExt( cFile, cDiv )

   LOCAL nPoint := Rat( ".", cFile )
   LOCAL cExt   := ""
   
   vDef( @cDiv, "\" )

   IF IsUseExt( cFile, cDiv )
      cExt := RTrim( Subs( cFile, nPoint ) )
   ENDIF

RETURN( Upper( cExt ) )



FUNCTION GetNameFile( cFile, cDiv )

   vDef( @cDiv, "\" )

   DelPath( @cFile, cDiv )

RETURN( cFile )



FUNCTION GetPath( cFile, cDiv )

   LOCAL cPath := ""

   vDef( @cDiv, "\" )

   IF Rat( cDiv, cFile ) > 0
      cPath := Left( cFile, Rat( cDiv, cFile ) )
   ELSEIF At( ":", cFile ) > 0
      cPath := Left( cFile, 2 )
   ENDIF

RETURN( cPath )



FUNCTION GetDrive( cPath )

   LOCAL cDrive := DiskName()

   IF ! Empty( cPath ) .AND. At( ":", cPath ) > 0 .AND. IsAlpha( Left( cPath, 1 ) )
      cDrive := Left( cPath, 1 )
   ENDIF

RETURN( cDrive )



FUNCTION ConfPath( cPath, cDiv )

   vDef( @cDiv, "\" )

   cPath := AllTrim( cPath )

   IF Len( cPath ) > 0 .AND. Right( cPath, 1 ) <> cDiv
      cPath += cDiv
   ENDIF

RETURN( cPath )



FUNCTION CurPath()

   LOCAL cReturn := CurDir()
   
   IF Left( cReturn, 2 ) <> "\\"
      cReturn := DiskName() + ":\" + cReturn
   ENDIF

RETURN( cReturn )



FUNCTION IsUsePath( cFile )

RETURN( At( "\", cFile ) > 0 .OR. At( ":", cFile ) > 0 )



FUNCTION IsUseExt( cFile, cDiv )

   LOCAL nPoint, nBar
   
   vDef( @cDiv, "\" )

   DO WHILE At( "..", cFile ) > 0
      cFile := StrTran( cFile, "..", "" )
   ENDDO

   nPoint := RAt( "." , cFile )
   nBar   := RAt( cDiv, cFile )

RETURN( nPoint > 1 .AND. nPoint > nBar )



FUNCTION IsDirExist( cDir, cRdd )

   // Tambem pode ser utilizada p/ arquivos SQL.

   LOCAL nResult := 0
   LOCAL aResult := {}

   LOCAL cDirDefault, cDrvDefault, cDrv, nConnSave

   IF SQLRDD

      IF Right( cDir, 1 ) <> "\"
         cDir += "\"
      ENDIF

      BEGIN SEQUENCE

         cDrv := sqlGetInfo( cDir, "DTB" )

         IF Left( cDir, 1 ) = "\"

            // Verifica existencia do Database (valido apenas p/ o IP atual)

            IF sqlExecute( "SELECT datname FROM pg_database WHERE UPPER(datname)='" + cDrv + "'", @aResult, .F. )
               IF Len( aResult ) = 0
                  nResult := -1
                  BREAK
               ENDIF
            ELSE
               nResult := -1
               BREAK
            ENDIF

            aResult := {}

         ENDIF

         cDir := sqlGetInfo( cDir, "SCHEMA" )

         IF cDir = "PUBLIC"  // Schema default (sempre vai existir)
            BREAK
         ENDIF

         // Verifica a existencia do schema (Database precisa estar conectado)

         nConnSave := sqlSetConn( NIL, cDrv )

         IF sqlGetConn( "CONN" ) = 0  // Database nao conectado
            nResult := -1
            BREAK
         ENDIF

         IF sqlExecute( "SELECT nspname FROM pg_namespace WHERE UPPER(nspname)=" + QuotedStr( cDir ), @aResult, .F., NIL, NIL, NIL, NIL, .T. )
            IF Len( aResult ) = 0
               nResult := -1
            ENDIF
         ELSE
            nResult := -1
         ENDIF

      ENDSEQUENCE

      IF nConnSave <> NIL
         sqlSetConn( nConnSave )
      ENDIF

   ELSEIF IsDirectory( AllTrim( cDir ) )
   
      nResult := 0
      
   ELSE
   
      nResult := -1

   ENDIF

RETURN( nResult = 0 )



FUNCTION IsTmpFile( cTmp )

   LOCAL cFile := mxDirTemp() + "TEMP" + cTmp + ".DBF"

RETURN( File( cFile ) )



FUNCTION IsDifDrv( cOri, cDes )

   LOCAL lDif := .F.

   LOCAL cDrvOri, cDrvDes

   IF At( ":", cOri ) <> 0 .OR. At( ":", cDes ) <> 0

      cDrvOri := Left( cOri, At( ":", cOri ) )
      cDrvDes := Left( cDes, At( ":", cDes ) )

      lDif := .T.

   ENDIF

RETURN( lDif )



FUNCTION SpaceFiles( cFiles )

   LOCAL nSpace := 0

   aEval( Directory( cFiles ), { |f| nSpace += f[2] } )

RETURN( nSpace )



/*----------------------------------------------------------------------------
 Trunca o nome do diretorio caso exceda o limite de tamanho permitido.

 Parametros

 cDir : String com o nome do diretorio. Pode haver tambem o nome do arquivo
        no final da string.
 nLen : Tamanho limite.

 Retorno : Nome do diretorio formatado.

 Exemplo :

 Tamanho maximo : 25
 Diretorio      : G:\SISTEMAS\REV45\DADOS\ARQCLI.DBF
 O retono sera  : G:\SISTEMAS\..\ARQCLI.DBF
----------------------------------------------------------------------------*/

FUNCTION FNameDir( cDir, nLen )

   LOCAL cFile

   cDir := AllTrim( cDir )

   IF Len( cDir ) > nLen
      cFile := Subs( cDir, Rat( "\", cDir ) + 1 )
      cDir  := Left( cDir, nLen - Len( cFile ) - 4 ) + "\..\" + cFile
   ENDIF

RETURN( PadR( cDir, nLen ) )



FUNCTION getFSystem( cFile )

   LOCAL cPath

   IF cFile = "CFG"
      cFile := "CONFIG.SYS"
   ELSE
      cFile := "AUTOEXEC.BAT"
   ENDIF

   IF IsWinNT()
      cPath := mxWinDir() + "SYSTEM32\"
      cFile := cPath + ModExt( cFile, "NT" )
   ENDIF

RETURN( cFile )



/*----------------------------------------------------------------------------
 Localiza uma string em um arquivo em seu formato original.
 Opcionalmente pode-se alterar a string encontrada

 Parametros

 cFile           : Nome do arquivo onde sera locazada a string. Caso nao
                    seja do diretorio corrente, deve-se informar o caminho.
 cString         : String de caracteres que deve ser encontrada.
 cReplace        : Parametro opcional que devera substituir a string caso
                   seja encontrada.
 nAfter          : Bytes q devem ser avancados apos a string.
 nLenAfterString : Tamanho do retorno.
 cReturn         : Variavel de retorno.

 Retorno : .T., caso a string seja localizada.
----------------------------------------------------------------------------*/

FUNCTION FSearch( cFile, cString, cReplace, nAfter, nLenAfterString, cReturn )

   LOCAL lReturn := .F.
   LOCAL hFile   := FOpen( cFile, FO_READWRITE + FO_EXCLUSIVE )
   LOCAL nSize   := mxFSize( hFile )
   LOCAL nBlock  := ( 1024 * 4 )   // 4kb

   LOCAL cBuffer, nPosition, nBytes, nPosString

   vDef( @nAfter, 0 )

   DO WHILE .T.

      nPosition := FSeek( hFile, 0, FS_RELATIVE )

      IF ( nSize - nPosition ) < nBlock
         nBlock := nSize - nPosition
      ENDIF

      cBuffer := Space( nBlock )

      nBytes := FRead( hFile, @cBuffer, nBlock )

      nPosString := At( cString, cBuffer )

      IF nPosString <> 0
         IF cReplace <> NIL
            FSeek( hFile, -nBytes, FS_RELATIVE )
            FSeek( hFile, At( cString, cBuffer )-1, FS_RELATIVE )

            FWrite( hFile, cReplace, Len( cReplace ) )
         ENDIF
         IF nAfter <> 0
            FSeek( hFile, -nBytes, FS_RELATIVE )
            FSeek( hFile, At( cString, cBuffer ), FS_RELATIVE )
            FSeek( hFile, Len( cString ), FS_RELATIVE )
            cBuffer := Space( nAfter )
            nBytes  := FRead( hFile, @cBuffer, nAfter )
            cReturn := Space( nLenAfterString )
            nBytes  := FRead( hFile, @cReturn, nLenAfterString )
         ENDIF
         lReturn := .T.
      ENDIF

      IF ( nBytes = 0 ) .OR. lReturn .OR. nBytes <= Len( cString )
         EXIT
      ENDIF

      IF nSize > Len( cString )
         FSeek( hFile, -Len( cString ), FS_RELATIVE )
      ENDIF

   ENDDO

   FClose( hFile )

RETURN( lReturn )



FUNCTION outToFile( cFile, cDir )

   IF cFile = NIL
      SET ALTE OFF
      SET CONS ON
      SET ALTE TO
   ELSE
      IF cDir = NIL
         cDir := ""
      ELSE
         cDir := ConfPath( cDir )
      ENDIF
      cFile := cDir + cFile
      IF ! Empty( cDir ) .AND. ! IsDirExist( cDir )
         mxMd( cDir )
      ENDIF
      SET ALTE TO &cFile
      SET CONS OFF
      SET ALTE ON
   ENDIF

RETURN( NIL )



FUNCTION fSay( nCol, uInfo, uFmt, uDefault )

   LOCAL cSay

   IF uInfo = NIL
      @ nCol, 000  SAY ""
   ELSE
      IF Empty( uInfo ) .AND. uDefault <> NIL
         uInfo := uDefault
      ENDIF
      DO CASE
         CASE uFmt = NIL             ; cSay := uInfo
         CASE ValType( uInfo ) = "D" ; cSay := fDate( uInfo, uFmt )
         CASE ValType( uInfo ) = "N" ; cSay := StrZero( uInfo * 100, uFmt )
         CASE Len( uInfo ) = 1       ; cSay := Repl( uInfo, uFmt )
         OTHERWISE                   ; cSay := PadR( uInfo, uFmt )
      ENDCASE
      @ pRow(), nCol -1  SAY cSay
   ENDIF

RETURN( NIL )



FUNCTION xlsNew( cFile, nType )

   // Cria planilha no formato Microsoft Excel 2.0

   LOCAL lReturn := .T.
   LOCAL cBof
   
   vDef( @nType, 0 )

   nTypeXLS := nType
   cFileXLS := cFile

   IF nType = 0

      cBof := Chr(9) + Chr(0) + Chr(4) + Chr(0) + Chr(2) + Chr(0) + Chr(10) + Chr(0)

      cFile := ModExt( cFile, "TMP" )
      mxFDel( cFile )

      nHandleXLS := FCreate( cFile )

      FWrite( nHandleXLS, cBof, Len( cBof ) )

      lReturn := nHandleXLS > 0

   ELSEIF nType = 1
   
      TRY
         oExcelXLS := CreateObject( "Excel.Application" )
         oExcelXLS:WorkBooks:Add()
         oSheetXLS := oExcelXLS:ActiveSheet
      CATCH
         oExcelXLS := NIL
         oSheetXLS := NIL
         lReturn   := .F.
      END
      
   ENDIF
   
RETURN( lReturn )



PROCEDURE xlsCellFont( aFont )

   aFontXLS := aFont

RETURN



PROCEDURE xlsWrite( nRow, nCol, cString, aFont )

   LOCAL anHeader, nLen, nI
   
   IF nTypeXLS = 0

      #define TXT_ELEMS   12
      #define TXT_OPCO1    1
      #define TXT_OPCO2    2
      #define TXT_LEN1     3
      #define TXT_LEN2     4
      #define TXT_ROW1     5
      #define TXT_ROW2     6
      #define TXT_COL1     7
      #define TXT_COL2     8
      #define TXT_RGBAT1   9
      #define TXT_RGBAT2  10
      #define TXT_RGBAT3  11
      #define TXT_LEN     12

      anHeader               := Array( TXT_ELEMS )  // Matriz p/ armazenar o marcador de registro
      anHeader[ TXT_OPCO1 ]  := 4
      anHeader[ TXT_OPCO2 ]  := 0
      anHeader[ TXT_LEN1 ]   := 10
      anHeader[ TXT_LEN2 ]   := 0
      anHeader[ TXT_ROW2 ]   := 0
      anHeader[ TXT_COL2 ]   := 0
      anHeader[ TXT_RGBAT1 ] := 0
      anHeader[ TXT_RGBAT2 ] := 0
      anHeader[ TXT_RGBAT3 ] := 0
      anHeader[ TXT_LEN ]    := 2

      cString := UtoC( cString )

      nLen := Len( cString )

      anHeader[ TXT_LEN ]  := nLen      // Tamanho do texto a ser escrito
      anHeader[ TXT_LEN1 ] := nLen +8   // Tamanho do registro

      nI                   := nRow -1
      anHeader[ TXT_ROW1 ] := nI - ( Int( nI / 256 ) * 256 )
      anHeader[ TXT_ROW2 ] := Int( nI / 256 )
      anHeader[ TXT_COL1 ] := nCol -1

      aEval( anHeader, { |v| FWrite( nHandleXLS, Chr( v ), 1 ) } )   // Grava o cabecalho

      FOR nI := 1 TO nLen
         FWrite( nHandleXLS, Subs( cString, nI, 1 ), 1 )   // Grava os dados
      NEXT
      
   ELSEIF nTypeXLS = 1
   
      IF oSheetXLS <> NIL

         vDef( @aFont, aFontXLS )
         vDef( @aFont, {} )
         aSize( aFont, 4 )

         oSheetXLS:Cells( nRow, nCol ):Value := cString

         IF aFont[1] <> NIL  // Nome da fonte
            oSheetXLS:Cells( nRow, nCol ):Font:Name := aFont[1]
         ENDIF
         IF aFont[2] <> NIL  // Tamanho da fonte
            oSheetXLS:Cells( nRow, nCol ):Font:Size := aFont[2]
         ENDIF
         IF aFont[3] <> NIL  // Cor da fonte
            oSheetXLS:Cells( nRow, nCol ):Font:Color := aFont[3]
         ENDIF
         IF aFont[4] <> NIL  // Negrito
            oSheetXLS:Cells( nRow, nCol ):Font:Bold := aFont[4]
         ENDIF

      ENDIF
      
   ENDIF
   
RETURN



FUNCTION xlsSave

   LOCAL lReturn := .T.
   LOCAL cEof

   IF ! IsUseExt( cFileXLS )
      cFileXLS := ModExt( cFileXLS, "xls" )
   ENDIF

   mxFDel( cFileXLS )

   IF nTypeXLS = 0

      cEof := Chr(10) + Chr(0) + Chr(0) + Chr(0)

      FWrite( nHandleXLS, cEof, Len( cEof ) )
      FClose( nHandleXLS )

      nHandleXLS := 0

      FRename( ModExt( cFileXLS, "TMP" ), cFileXLS )

   ELSEIF nTypeXLS = 1

      IF oExcelXLS = NIL

         lReturn := .F.

      ELSE

         TRY
            oExcelXLS:ActiveWorkBook:SaveAs( cFileXLS, 18 )
         CATCH
            lReturn := .F.
         END

         xlsClose( @oExcelXLS )

         oSheetXLS := NIL
         oExcelXLS := NIL

      ENDIF
      
   ENDIF
   
   IF lReturn
      lReturn := File( cFileXLS )
   ENDIF

RETURN( lReturn )



FUNCTION xlsOpen( oExcel, oSheet, cFile )

   LOCAL lReturn := .F.
   
   BEGIN SEQUENCE
   
      IF ! File( cFile )
         BREAK
      ENDIF

      TRY
         oExcel := CreateObject( "Excel.Application" )
         oExcel:WorkBooks:Open( cFile )
         oSheet := oExcel:ActiveSheet
      CATCH
         BREAK
      END
      
      lReturn := .T.
      
   ENDSEQUENCE

RETURN( lReturn )



PROCEDURE xlsClose( oExcel )

   IF oExcel <> NIL

      oExcel:ActiveWorkBook:Close()
      oExcel:Quit()

      oExcel := NIL

      #ifdef MINIGUI_MODE

         WaitRun( "KillProc.exe EXCEL.EXE", 2 )
         
      #endif

   ENDIF
   
RETURN



// Retorna o nome do arquivo no formato 8.3

#pragma BEGINDUMP

#include <windows.h>
#include "hbapi.h"

HB_FUNC( GETSHORTFILENAME )
{
   char pszReturn[ MAX_PATH ] ;
   pszReturn[0]= '\0' ;

   GetShortPathName( hb_parcx( 1 ), pszReturn, MAX_PATH -1 ) ;
   hb_retc( pszReturn ) ;
}


HB_FUNC( CONSOLECHANGEX )
{
   char Title[ 255 ] ;
   DWORD dwRet ;
   HWND hWnd ;
   HMENU hMenu ;

   dwRet = GetConsoleTitle( Title, sizeof( Title ) ) ;

   hWnd = FindWindow( NULL, Title ) ;
   hMenu = GetSystemMenu( hWnd, FALSE ) ;

   if ( hb_pcount() == 0 )
      DeleteMenu( hMenu, SC_CLOSE, MF_BYCOMMAND ) ;
   else if ( hb_parl(1) )
      EnableMenuItem( hMenu, SC_CLOSE, MF_ENABLED ) ;
   else
      EnableMenuItem( hMenu, SC_CLOSE, MF_DISABLED && MF_GRAYED ) ;
}

#pragma ENDDUMP
