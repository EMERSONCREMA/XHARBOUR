/*

 MaxVid.prg
 Descricao: Biblioteca de funcoes para exibicao de relatorios
 Desenvolvido por MAX SCALLA Informatica Ltda.

 EMERSON DA SILVA CREMA
 25/10/13 * Implementado o parametro lOpcSalva em DisplayFile().
 06/12/06 * Mudada condicao de Eject() p/ ejetar apenas quando DESTIN <> V.
 05/01/06 * Desenvolvimento de vidDefPermiss().
          * Implementada possibilidade de consistencia interna p/ impedir
            gravacao da visualicado em arquivo.
 27/09/05 * Correcao em setArqTxt(). Os arquivos criados com fCreate() ficam
            abertos e isto causa erro no windows XP. Agora esta sendo
            utilizado o fClose().
 15/09/05 * Implementada opcao de salvar o arquivo visualizado no encerramento
            da visualizacao.
 17/01/95 * Inicio do desenvolvimento.

*/

#include "std.ch"
#include "inkey.ch"
#include "fileIO.ch"
#include "Fbrwsdef.ch"
#include "Futils.ch"
#include "Tbutils.ch"

STATIC bPermiss := { || .T. }


FUNCTION DisplayFile( cFName, cLStatus, cTitle, aFunc, lOpcSalva )

   #define K_SEARCH_FORWARD  K_F2
   #define K_SEARCH_BACKWARD K_F3

   LOCAL GetList := {}
   LOCAL aState  := {}

   LOCAL lOpcao         := .F.
   LOCAL lExitRequested := .F.
   LOCAL cSearcher      := Space( 40 )
   LOCAL CorTela        := "15/1,0/7,,,15/1"
   LOCAL CorStat        := "0/3"
   LOCAL LineIni        := If( cTitle = NIL, 0, 1 )

   LOCAL oTbr, oTbc, nSavefPos, nKey, nFunc, nOpcRel, cFSave, cFMsg, aOpc
   
   vDef( @lOpcSalva, .T. )
   
   SaveState( @aState )

   SET SCOR OFF

   BEGIN SEQUENCE

      IF cFName = NIL .OR. ! File( cFName )
         BREAK
      ENDIF

      IF HB_FSize( cFName ) <= 0
         MsgDlg( MS050 )
         BREAK
      ENDIF

      SetColor( CorTela )

      @ LineIni,00 CLEAR TO 23,79

      IF LineIni <> 0
         @ 00,00 SAY PadC( cTitle, 80 ) COLOR CorStat
      ENDIF

      @ 24,00 SAY PadC( cLStatus, 80 ) COLOR CorStat

      IF ( oTbr := FBrowseNew() ) = NIL
         BREAK
      ENDIF

      FBrowseOpen( oTbr, cFName )
      oTbr:nTop    := LineIni
      oTbr:nLeft   := 00
      oTbr:nBottom := 23
      oTbr:nRight  := 79
      oTbc:= TBColumnNew( NIL, {|| Subs( oTbr:fileLine, oTbr:lineOffset ) } )

      oTbc:width := 80
      oTbr:addColumn( oTbc )

      DO WHILE ! lExitRequested

         SetCursor(0)

         DO WHILE ! oTbr:stabilize()
         ENDDO

         nKey := mxInKey()

         DO CASE
            CASE nKey = K_ESC

                 DO WHILE .T.

                    IF impDuplaGrv()
                       nOpcRel := MsgDlg( "O que deseja fazer neste momento ?", { "&Continuar", "&Abandonar", "&Imprimir" } )
                    ELSE
                       aOpc := { "&N„o", "&Sim" }
                       IF lOpcSalva
                          aAdd( aOpc, "Salvar &Arquivo" )
                       ENDIF
                       nOpcRel := MsgDlg( "Deseja realmente abandonar a visualiza‡„o ?", aOpc )
                    ENDIF

                    IF nOpcRel = 2 .OR. ( nOpcRel = 3 .AND. ! impDuplaGrv() )

                       IF nOpcRel = 2

                          FClose( oTbr:FileHandle )

                       ELSEIF nOpcRel = 3

                          IF ! Eval( bPermiss )

                             lOpcao := .T.

                          ELSE

                             cFSave := PadR( StrTran( Upper( GetNameFile( cFName ) ), "TEMP", "REL" ), 25 )

                             DO WHILE .T.

                                mxGetBox( "Informe o nome do arquivo", @cFSave, "@!K", .T. )

                                lOpcao := ( LastKey() = K_ESC )

                                IF lOpcao
                                   EXIT
                                ENDIF

                                cFMsg := CurPath() + "\TEMP\" + Trim( cFSave )

                                IF File( cFMsg ) .AND. MsgDlg( "O arquivo;^" + cFMsg + "^;j  existe !;" + ;
                                                               "Deseja sobrescrever ?", NaoSim ) = 1
                                   LOOP

                                ENDIF

                                EXIT

                             ENDDO

                          ENDIF

                          IF ! lOpcao

                             FClose( oTbr:FileHandle )

                             mxMd( "TEMP" )
                             mxFCopy( cFName, "TEMP\" + cFSave )

                             MsgDlg( "Arquivo salvo em:;" + cFMsg, NIL, NIL, NIL, NIL, NIL, .T. )

                          ENDIF

                       ENDIF

                       IF ! lOpcao
                          lExitRequested := .T.
                       ENDIF

                    ENDIF

                    IF ! lOpcao
                       EXIT
                    ENDIF
                    lOpcao := .F.

                 ENDDO

            CASE nKey = K_LEFT

                 IF oTbr:lineOffset > 1
                    oTbr:lineOffset --
                    oTbr:refreshall()
                 ENDIF

            CASE nKey = K_RIGHT

                 IF oTbr:lineOffset < len( oTbr:fileLine )
                    oTbr:lineOffset ++
                    oTbr:refreshall()
                 ENDIF

            CASE nKey = K_HOME

                 oTbr:lineOffset := 1
                 oTbr:refreshall()

            CASE nKey = K_END

                 oTbr:lineOffset := Max( 1, Len( oTbr:fileLine ) - oTbc:width + 1 )
                 oTbr:refreshAll()

                 #define TAB_SIZE 10

            CASE nKey = K_CTRL_RIGHT

                 IF oTbr:lineOffset <= Len( oTbr:fileLine ) - TAB_SIZE
                    oTbr:lineOffset += TAB_SIZE
                    oTbr:refreshAll()
                 ENDIF

            CASE nKey = K_CTRL_LEFT

                 oTbr:lineOffset := Max( 1, oTbr:lineOffset - TAB_SIZE )
                 oTbr:refreshall()

            CASE nKey = K_SEARCH_FORWARD .OR. nKey = K_SH_F2

                 IF nKey = K_SEARCH_FORWARD

                    SetPos( 24, 00 )
                    DefCursor()
                    SetColor( CorStat + ",0/7,,," + CorStat )

                    @ 24,00 SAY PadC( "Digite a palavra a procurar [" + Space( 40 ) +"]", 80 )
                    @ 24,34 ;
                      GET   cSearcher ;
                      PICT  "@K" ;
                      VALID ! mxEmpty( cSearcher )

                    READ

                    SetColor( CorTela + ",0/7,,," + CorTela )
                    SetPos( 24, 00 )
                    SetCursor( 0 )

                 ENDIF

                 IF ! ESC

                    IF FrwdSrch( oTbr, Trim( cSearcher ) )
                       oTbr:refreshAll()
                    ELSE
                       Alert( AllTrim(cSearcher) + " n„o encontrado", { "OK" }, "B/W, W/B" )
                    ENDIF

                 ENDIF

                 @ 24,00 SAY PadC( cLStatus, 80 ) COLOR CorStat

            CASE nKey = K_SEARCH_BACKWARD .OR. nKey = K_SH_F3

                 IF nKey = K_SEARCH_BACKWARD

                    SetPos( 24, 00 )
                    DefCursor()
                    SetColor( CorStat + ",0/7,,," + CorStat )

                    @ 24,00 SAY PadC( "Digite a palavra a procurar [" + Space( 40 ) +"]", 80 )
                    @ 24,34 ;
                      GET   cSearcher ;
                      PICT  "@K" ;
                      VALID ! mxEmpty( cSearcher )

                    READ

                    SetColor( CorTela + ",0/7,,," + CorTela )
                    SetPos( 24, 00 )
                    SetCursor( 0 )

                 ENDIF

                 IF ! ESC

                    IF BkwdSrch( oTbr, Trim( cSearcher ) )
                       nSavefPos := FilePos( oTbr )
                       oTbr:refreshAll()
                       DO WHILE !oTbr:stabilize()
                       ENDDO

                       DO WHILE FilePos( oTbr ) <> nSavefPos
                          oTbr:up()
                          DO WHILE !oTbr:stabilize()
                          ENDDO
                       ENDDO
                    ELSE
                       Alert( AllTrim( cSearcher ) + " n„o encontrado", { "OK" }, "B/W, W/B" )
                    ENDIF

                 ENDIF

                 @ 24,00 SAY PadC( cLStatus, 80 ) COLOR CorStat

            CASE aFunc <> NIL .AND. ( nFunc := aScan( aFunc, { |f| f[1] = nKey } ) ) > 0

                 Eval( aFunc[ nFunc, 2 ], oTbr )

            OTHERWISE

                 StdMeth( oTbr, nKey )

         ENDCASE

      ENDDO

   ENDSEQUENCE

   RestState( aState, .F., .F., .T., .T. )

RETURN( NIL )



FUNCTION FilePos( oTbr )
RETURN( FTell( oTbr:fileHandle ) )



FUNCTION FBrowseNew

   LOCAL oTbr := TBrowseNew()

   oTbr:cargo := Array( FILE_BRWS_NUM_IVARS )
   oTbr:lineOffset := 1

   oTbr:goTopBlock    := {| | FileGoFirst( oTbr ) }
   oTbr:goBottomBlock := {| | FileGoLast( oTbr )  }
   oTbr:skipBlock     := {|n| FileSkip( n, oTbr ) }

RETURN( oTbr )



FUNCTION FBrowseOpen( oTbr, cFileName )

   LOCAL fHandle := FOpen( cFileName )

   IF fHandle >= 0
      oTbr:fileHandle := fHandle
      FileGoFirst( oTbr )
   ENDIF

RETURN( fHandle > 0 )



PROCEDURE FileBrowseClose( oTbr )

   FClose( oTbr:filehandle )

RETURN



STATIC PROCEDURE FileGoFirst( oTbr )

   LOCAL cLine
   LOCAL fHandle := oTbr:fileHandle

   FSeek( fHandle, 0, FS_SET )
   FReadLn( fHandle, @cline, MAX_LINE_LEN )
   oTbr:fileLine := cLine
   FSeek( fHandle, 0, FS_SET )

RETURN



STATIC PROCEDURE FileGoLast( oTbr )

   FSeek( oTbr:fileHandle, 0, FS_END )
   GoPrevLn( oTbr )

RETURN



STATIC FUNCTION FileSkip( n, oTbr )

   LOCAL nSkipped := 0

   IF n > 0
      DO WHILE nSkipped <> n .AND. GoNextLn( oTbr )
         nSkipped ++
      ENDDO
   ELSE
      DO WHILE nSkipped <> n .AND. GoPrevLn( oTbr )
         nSkipped --
      ENDDO
   ENDIF

RETURN( nSkipped )



FUNCTION GoNextLn( oTbr )

   LOCAL fHandle  := oTbr:fileHandle
   LOCAL nSavePos := FTell(fHandle)
   LOCAL cBuff    := ""

   LOCAL lMoved, nNewPos

   FSeek( fHandle, Len( oTbr:fileLine ) + 2, FS_RELATIVE )
   nNewPos := FTell( fHandle )
   IF FReadLn( fHandle, @cBuff, MAX_LINE_LEN )
      lMoved := .T.
      oTbr:fileLine := cBuff
      FSeek( fHandle, nNewPos, FS_SET )
   ELSE
      lMoved := .F.
      FSeek( fHandle, nSavePos, FS_SET )
   ENDIF

RETURN( lMoved )



FUNCTION GoPrevLn( oTbr )

   LOCAL fHandle  := oTbr:fileHandle
   LOCAL nOrigPos := FTell( fHandle )

   LOCAL nMaxRead, nNewPos, lMoved, cBuff, nWhereCrLf, nPrev, cTemp

   IF nOrigPos = 0
      lMoved := .F.
   ELSE
      lMoved := .T.
      FSeek( fHandle, -2, FS_RELATIVE )
      cTemp := Space( 2 )
      FRead( fHandle, @cTemp, 2 )
      IF cTemp = CRLF
         FSeek( fHandle, -2, FS_RELATIVE )
      ENDIF
      nMaxRead := Min( MAX_LINE_LEN, FTell( fHandle ) )

      cBuff := Space( nMaxRead )
      nNewPos := FSeek( fHandle, -nMaxRead, FS_RELATIVE )
      FRead( fHandle, @cBuff, nMaxRead )
      nWhereCrLf := Rat( CRLF, cBuff )
      IF nWhereCrLf = 0
         nPrev := nNewPos
         oTbr:fileLine := cBuff
      ELSE
         nPrev := nNewPos + nWhereCrLf + 1
         oTbr:fileLine := SubStr( cBuff, nWhereCrLf + 2 )
      ENDIF

      FSeek( fHandle, nPrev, FS_SET )
   ENDIF

RETURN( lMoved )



FUNCTION FrwdSrch( oTbr, cString )

   LOCAL fHandle := oTbr:fileHandle
   LOCAL lFound := .F.
   LOCAL nSavePos := FTell( oTbr:fileHandle )
   LOCAL cSavecLine := oTbr:fileLine

   DO WHILE !lFound .AND. GoNextLn( oTbr )
      lFound := cString $ oTbr:fileLine
   ENDDO

   IF ! lFound
      FSeek( fHandle, nSavePos, FS_SET )
      oTbr:fileLine := cSavecLine
   ENDIF

RETURN( lFound )



FUNCTION bkwdSrch( oTbr, cString )

   LOCAL lFound := .F.
   LOCAL fHandle := oTbr:fileHandle
   LOCAL nSavePos := FTell( fHandle )
   LOCAL cSavecLine := oTbr:fileLine

   DO WHILE ! lFound .AND. GoPrevLn( oTbr )
      lFound := cString $ oTbr:fileLine
   ENDDO

   IF ! lFound
      FSeek( fHandle, nSavePos, FS_SET )
      oTbr:fileLine := cSavecLine
   ENDIF

RETURN( lFound )



FUNCTION FReadLn( fHandle, cBuffer, nMaxLine )

   LOCAL cLine, nEol, nNumRead, nSavePos

   cLine   := Space( nMaxLine )
   cBuffer := ""

   nSavePos := FTell( fHandle )

   nNumRead := FRead( fHandle, @cLine, nMaxLine )

   IF ( nEol := At( CRLF, Left( cLine, nNumRead ) ) ) = 0
      cBuffer := cLine
   ELSE
      cBuffer := Left( cLine, nEol -1 )

      FSeek( fHandle, nSavePos + nEol + 1, FS_SET )
   ENDIF

RETURN( nNumRead <> 0 )



FUNCTION StdMeth( oTbr, nKey )

   LOCAL lKeyHandled := .T.
   DO CASE
      CASE nKey = K_DOWN;       oTbr:down()
      CASE nKey = K_UP;         oTbr:up()
      CASE nKey = K_PGDN;       oTbr:pageDown()
      CASE nKey = K_PGUP;       oTbr:pageUp()
      CASE nKey = K_CTRL_PGUP;  oTbr:goTop()
      CASE nKey = K_CTRL_PGDN;  oTbr:goBottom()
      CASE nKey = K_RIGHT;      oTbr:right()
      CASE nKey = K_LEFT;       oTbr:left()
      CASE nKey = K_HOME;       oTbr:home()
      CASE nKey = K_END;        oTbr:end()
      CASE nKey = K_CTRL_LEFT;  oTbr:panLeft()
      CASE nKey = K_CTRL_RIGHT; oTbr:panRight()
      CASE nKey = K_CTRL_HOME;  oTbr:panHome()
      CASE nKey = K_CTRL_END;   oTbr:panEnd()
      OTHERWISE;                lKeyHandled := .F.
   ENDCASE

RETURN( lKeyHandled )



FUNCTION SetArqTxt( cArqTxt )

   LOCAL cAux

   PUBLIC GerArq := ( cArqTxt = NIL )
   
   PUBLIC cArqVid, cArqImp

   IF cArqTxt = NIL

      DO WHILE .T.

         cAux := mxDirTemp() + "TEMP" + StrZero( Val( Subs( Time(), 4, 2 ) + Subs( Time(), 7, 2 ) ), 4 )

         cArqVid := cAux + ".TXT"
         cArqImp := cAux + ".PRN"

         IF ! File( cArqVid ) .AND. ! File( cArqImp )

            fClose( fCreate( cArqVid, FC_NORMAL ) )

            IF impDuplaGrv()
               fClose( fCreate( cArqImp, FC_NORMAL ) )
            ENDIF
            EXIT

         ENDIF

      ENDDO

   ELSE

      cArqVid := cArqTxt

   ENDIF

   SET PRIN TO &cArqVid  // ADDITIVE

RETURN( NIL )



FUNCTION Eject()

   IF DESTIN <> "V"
      EJECT
   ENDIF

RETURN( NIL )



FUNCTION vidDefPermiss( bDefPermiss )

   bPermiss := bDefPermiss

RETURN( NIL )