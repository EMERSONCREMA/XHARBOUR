/*----------------------------------------------------------------------------
 MaxInput.prg
 Descricao: Biblioteca de funcoes de entrada de dados (digitacao).
 Desenvolvido por MAX SCALLA Informatica Ltda.
 
 EMERSON DA SILVA CREMA
 14/09/17 * Implementado em senGetKey() a utilizacao da tecla F2.
 29/11/16 * Removido mxGetKey() de mxInkey().
 29/08/16 * Desenvolvido e implementado mxGetKey().
 17/10/16 * Desenvolvido:
            - chrSubst().
            - key_ChrSubst().
            - key_ChrSubst_Aux().
 29/08/16 * Desenvolvido e implementado mxGetKey().
 09/09/15 * Implementado a mensagem "ESCúCancela/Retorna" em MsgDlg_status().
 05/06/14 * Implementado controle lButton em MsgDlg() p/ aumento de linhas.
 17/02/14 * Implementado mxErrorLog() em MsgDlg().
 27/09/13 * Padronizados logs na pasta LOGS\.
 21/08/13 * Correcao em MsgDlg() no ajuste da janela qdo utilizado uMessage
            como matriz com mais de 15 itens.
          * Desenvolvido MsgDlg_status().
 27/03/13 * Ateracao na funcao MsgDlg() p/ q na digitacao do "ACEITAR"
            seja "OK".

 DENIS MAZZUCATTO RODRIGUES
 28/08/12 * Desenvolvimento de mxTone().
 02/10/09 * Removidas variaveis MS006, MS008, MS010, MS011, MS030, MS055,
            MS062, LMSG e nTbKey de DefMens().

 EMERSON DA SILVA CREMA
 12/03/09 * Implementada referencia "LOG" p/ o parametro uOpt em MsgDlg().
 01/12/08 * Implementado parametro nKey em RepeatKey().
 04/07/07 * Desenvolvimento de mxKeyEvent() e implementada em mxInKey().
 23/05/07 * Remocao de mLastKey().
 06/03/07 * Correcao em senGetKey() pois estava case-sensitive.
 01/02/07 * Desenvolvimento de senGetKey().
 09/01/07 * Remocao de MInkey().

 DENIS MAZZUCATTO RODRIGUES
 07/12/06 * Desenvolvimento e implementacao de CheckMsgDlg().

 EMERSON DA SILVA CREMA
 13/07/06 * Reformulacoes em ConfInfs(), Mensagem() e ReturnSN().

 DENIS MAZZUCATTO RODRIGUES
 23/05/06 * Correcao na centralizacao da mensagem exibida em MsgDlg() qdo
            tinha mais q um ^.

 EMERSON DA SILVA CREMA
 22/05/06 * Implementada gravacao do log MXCONF.LOG em MsgDlg().
 04/04/06 * Implementado em MsgDlg() a condicao de nao abandonar com ESC a
            digitacao do ACEITAR.
 29/03/06 * Alteracoes em ConfMsg():
            - implementacao de mxPrompt() e mxMenuRead().
            - implementado cores nos caracteres de acesso rapido do prompt.
            - mudado os espacamentos das opcoes.
            - definida variavel nOpc como LOCAL.
 14/09/05 * Implementada opcao "ACE" para o parametro uOpt em MsgDlg().

 DENIS MAZZUCATTO RODRIGUES
 29/08/05 * Correcao em formatMsg() q nao numerava corretamente as mensagens.

 EMERSON DA SILVA CREMA
 04/03/05 * Desenvolvimento de formatMsg()
 22/02/05 * Implementado parametro de valid em mxGetBox().
 17/09/04 * Remocao de Msg().
 13/04/04 * Incluso parametro nOption em MsgDlg().
----------------------------------------------------------------------------*/

#include "std.ch"
#include "set.ch"
#include "inkey.ch"

#define KE_WAIT 1
#define KE_KEY  2
#define KE_PROC 3

#define KEY_SUBST { ;
                    {  39, 34  },;   // aspas simples
                    {  94, 32  },;   // circunflexo
                    { 126, 32  },;   // tio
                    { 132, 97  },;   // a com trema
                    { 133, 97  },;   // a com acento crase
                    { 160, 97  },;   // a com acento agudo
                    { 198, 97  },;   // a com tio
                    { 131, 97  },;   // a com acento circunflexo
                    { 166, 97  },;   // a (sinal primeiria)
                    { 143, 65  },;   // A com tio
                    { 181, 65  },;   // A maiusculo com acento agudo
                    { 182, 65  },;   // A maiusculo com acento circunflexo
                    { 183, 65  },;   // A maiusculo com acento crase
                    { 199, 65  },;   // A maiusculo com tio
                    { 135, 99  },;   // c cidilha
                    { 231, 99  },;   // c
                    { 130, 101 },;   // e com acento agudo
                    { 136, 101 },;   // e com acento circunflexo
                    { 137, 101 },;   // e com trema
                    { 138, 101 },;   // e com acento crase
                    { 144, 69  },;   // E maiusculo com acento agudo
                    { 210, 69  },;   // E maiusculo com acento circunflexo
                    { 211, 69  },;   // E maiusculo com trema
                    { 212, 69  },;   // E maiusculo com acento crase
                    { 139, 105 },;   // i com trema
                    { 140, 105 },;   // i com acento circunflexo
                    { 141, 105 },;   // i com acento crase
                    { 161, 105 },;   // i com acento agudo
                    { 214, 73  },;   // i maiusculo com acento agudo
                    { 215, 73  },;   // i maiusculo com acento circunflexo
                    { 216, 73  },;   // i maiusculo com trema
                    { 222, 73  },;   // i maiusculo com acento crase
                    { 147, 111 },;   // o com acento circunflexo
                    { 148, 111 },;   // o com trema
                    { 149, 111 },;   // o com acento crase
                    { 162, 111 },;   // o com acento agudo
                    { 167, 111 },;   // o (sinal primeirio)
                    { 228, 111 },;   // o com cidilha
                    { 168, 111 },;   // o
                    { 243, 111 },;   // o
                    { 244, 111 },;   // o
                    { 245, 111 },;   // o
                    { 229, 79  },;   // O maiusculo com tio
                    { 224, 79  },;   // O maiusculo com acento agudo
                    { 226, 79  },;   // O maiusculo com acento circunflexo
                    { 227, 79  },;   // O maiusculo com acento crase
                    { 153, 79  },;   // O maiusculo com trema
                    { 129, 117 },;   // u com trema
                    { 163, 117 },;   // u com acento agudo
                    { 150, 117 },;   // u com acento circunflexo
                    { 250, 117 },;   // u
                    { 233, 85  },;   // U maiusculo com acento agudo
                    { 234, 85  },;   // U maiusculo com acento circunflexo
                    { 128, 67  } ;   // C maiusculo com cidilha
                  }

STATIC aKeyEvent := NIL


FUNCTION mxInKey( nWait, uKeyAbort )

   LOCAL lTKey := .F.

   LOCAL nKey, bKey, cTStart

   IF nWait = NIL .AND. aKeyEvent <> NIL .AND. ( aKeyEvent[ KE_PROC ] = NIL .OR. mxIn( ProcName( 2 ), aKeyEvent[ KE_PROC ] ) )
      nWait := aKeyEvent[ KE_WAIT ]
      lTKey := .T.
   ELSE
      vDef( @nWait, 0 )
   ENDIF

   #ifdef MINIGUI_MODE

      IF nWait = 0 .AND. IsDef( "CS_MINIGUI" ) .AND. ! CS_MINIGUI
         ShowConsole()
      ENDIF

   #endif

   DO WHILE .T.
      IF aKeyEvent <> NIL
         cTStart := Time()
      ENDIF
      nKey := InKey( nWait, INKEY_ALL )
      /*
      IF IsDef( "DEBUG" )
         nKey := InKey( nWait, INKEY_ALL )
      ELSE
         nKey := mxGetKey( nWait )
      ENDIF
      */
      IF nWait = 0 .AND. mxIntervalo( nKey, K_MINMOUSE, K_MAXMOUSE, .F. )
         IF nKey <> K_LDBLCLK
            LOOP
         ENDIF
         nKey := K_ESC
      ENDIF
      IF nKey > 512
         nKey -= 512
      ENDIF
      IF lTKey .AND. nKey = 0 .AND. Secs( ElapTime( cTStart, Time() ) ) >= aKeyEvent[ KE_WAIT ]
         nKey := aKeyEvent[ KE_KEY ]
         mxKeyEvent( 0 )
      ENDIF
      sysDateConf()
      IF ( bKey := SetKey( nKey ) ) = NIL
         IF uKeyAbort = NIL .OR. If( ValType( uKeyAbort ) = "N", nKey = uKeyAbort, aScan( uKeyAbort, nKey ) > 0 )
            EXIT
         ENDIF
      ENDIF
      IF nKey <> 0 .AND. bKey <> NIL
         Eval( bKey )
         nKey := 0
      ENDIF
      IF nWait <> 0
         EXIT
      ENDIF
   ENDDO

RETURN( nKey )



FUNCTION mxGetKey( nWait )

   LOCAL cTime := Time()
   LOCAL nKey

   DO WHILE .T.
      IF ( nKey := InKey() ) <> 0
         EXIT
      ELSEIF nWait = NIL
         EXIT
      ELSEIF nWait <> 0 .AND. Secs( ElapTime( cTime, Time() ) ) > nWait
         EXIT
      ENDIF
   ENDDO

RETURN( nKey )



PROCEDURE mxTone( nFreq, nTime )

   IF ! IsDef( "NO_TONE" )
      Tone( nFreq, nTime )
   ENDIF

RETURN( NIL )



FUNCTION mxKeyEvent( nWait, nKey, uProc )

   LOCAL aReturn := aKeyEvent

   IF nWait <> NIL
      IF nWait = 0
         aKeyEvent := NIL
      ELSE
         IF ValType( uProc ) <> "A"
            uProc := { uProc }
         ENDIF
         aKeyEvent := { nWait, nKey, uProc }
      ENDIF
   ENDIF

RETURN( aReturn )



FUNCTION Digito( cTipDig )

   // Verifica se a tecla digitada e um digito numerico, alfanumerico ou todos

   IF Upper( cTipDig ) $ "N"
      RETURN( ( LastKey() > 47 .AND. LastKey() < 58 ) .OR. LastKey() = 46 )
   ELSEIF Upper( cTipDig ) $ "C"
      RETURN( LastKey() > 32 .AND. LastKey()< 126 .AND. ! Chr( LastKey() ) $ ".+-*/1234567890 " )
   ENDIF

RETURN( ( LastKey() > 47 .AND. LastKey() < 58 ) .OR. LastKey() = 46 ) .OR.;
        ( LastKey() > 32 .AND. LastKey() < 126 .AND. ! Chr( LastKey() ) $ ".+-*/1234567890[]{} " )



FUNCTION DigProc( uSeek, cMsg, cMask )

   LOCAL GetList := {}
   LOCAL aPos    := { Row(), Col() }
   LOCAL lDate   := ( ValType( uSeek ) = "D" )

   LOCAL nLen, nIni, nFim, cColor1, cColor2

   ScreenSave()

   IF lDate
      uSeek := Space(10)
      cMask := "99.99.9999"
   ENDIF

   IF cMask = NIL
      nLen := Len( uSeek )
   ELSE
      nLen := Len( Tran( uSeek, cMask ) )
   ENDIF

   vDef( @cMask, "@!" )

   nIni := ( 74 - ( nLen + Len( cMsg ) ) ) / 2
   nFim := nIni + nLen + Len( cMsg ) + 6

   IF IsDef( "CFICO5CTR" )
      cColor1 := CFICO5CTR
   ELSE
      cColor1 := SlColor( SetColor(), 1 )
   ENDIF

   IF IsDef( "CFICO7CTR" )
      cColor2 := CFICO7CTR
   ELSE
      cColor2 := SlColor( SetColor(), 2 )
   ENDIF

   Status( MS000 )
   RepeatKey()
   Muda_Cor( 01, 00, 23, 79, CFIFUNCTR )
   Limpa( 18, nIni, 20, nFim, "S", NIL, cColor1 )

   @ 19,nIni + 2 ;
     SAY   cMsg + " :" ;
     COLOR cColor1 ;
     GET   uSeek ;
     COLOR cColor2 ;
     PICT  cMask ;
     VALID ! lDate .OR. CPL_DATA( @uSeek )

   READ

   IF lDate
      uSeek := CtoD( uSeek )
   ENDIF

   ScreenRest()
   SetPos( aPos[1], aPos[2] )

RETURN( !ESC )



FUNCTION Cpl_Data( cData )

   cData := If( Empty( Subs( cData, 4, 2 ) ), Left( cData, 3 ) + Right( DtoC( Date() ), 7 ), If( Empty( Subs( cData, 9, 2 ) ), Left( cData, 6 ) + Right( DtoC( Date() ), 4 ), cData ) )

RETURN( ! Empty( CtoD( cData ) ) )



FUNCTION ReturnSN( uCond )

   LOCAL cReturn

   IF ValType( uCond ) = "C"
      cReturn := If( Upper( uCond ) = "S", "Sim", If( Upper( uCond ) = "N", "N„o", "   " ) )
   ELSE
      cReturn := If( uCond, "Sim", "N„o" )
   ENDIF

RETURN( cReturn )



FUNCTION Mensagem( cMsg, nStatus, lWindow )

   LOCAL cDevice := Set( _SET_DEVICE, "SCREEN" )
   LOCAL GetList := {}
   LOCAL lWait   := .T.
   LOCAL nCursor := SetCursor(0)
   LOCAL nCol    := Int( ( 80 - Len( cMsg ) ) / 2 )

   LOCAL cEsq, cDir, cRot, nTam, cTela

   vDef( @lWindow, .F. )

   cTela := SaveScreen( If( lWindow, 1, MaxRow() ), 00, MaxRow(), 79 )

   IF ( lWindow .OR. nStatus = 3 )

      Muda_Cor( 01, 00, MaxRow() -1, 79, CFIFUNCTR )

      Status( If( nStatus = 2, MS014, If( nStatus = 3, MS014, MS000 ) ) )

      Limpa( Int( MaxRow() / 2 ) -1, nCol -1, Int( MaxRow() / 2 ) +1, nCol + Len( cMsg ), "S", NIL, "0/7" )

      @ Int( MaxRow() / 2 ),nCol SAY cMsg COLOR "0/7"
      mxTone( 499, 5 )

      DO CASE
         CASE nStatus = 0
              mxInKey( 2 )
         CASE nStatus = 2
              mxInKey( 0 )
         CASE nStatus = 3
              DO WHILE lWait
                 FOR nTam := 1 TO Len( cMsg ) -1
                    cEsq := Left( cMsg, nTam )
                    cDir := Right( cMsg, Len( cMsg ) - nTam )
                    cRot := cDir + cEsq
                    @ Int( MaxRow() / 2 ), nCol SAY Left( cRot, Len( cMsg ) ) COLOR "0/7"
                    IF mxInKey( 0.2 ) <> 0
                       lWait := .F.
                       nTam  := Len( cMsg ) - 1
                    ENDIF
                 NEXT
              ENDDO
         OTHERWISE
              mxInKey( nStatus )
      ENDCASE
      IF nStatus <> 1
         RestScreen( 01, 00, MaxRow(), 79, cTela )
      ENDIF
   ELSE
      @ MaxRow(),00 SAY PadC( AllTrim( cMsg ), 80 ) COLOR "0/7"
      IF cMsg <> MS000
         mxTone( 499, 5 )
      ENDIF
      IF nStatus = 0
         mxInKey( 1 )
      ELSEIF nStatus = 2
         mxInKey( 0 )
      ENDIF
      IF nStatus <> 1
         RestScreen( MaxRow(), 00, MaxRow(), 79, cTela )
      ENDIF
   ENDIF
   SetCursor( nCursor )
   Set( _SET_DEVICE, cDevice  )

RETURN( .T. )



FUNCTION DefMens()

   PUBLIC MS000, MS001, MS002, MS003, MS004, MS005, MS007,;
          MS009, MS012, MS013, MS014, MS031, MS050, MS060

   MS000 := Space(80)
   MS001 := "Confirma"
   MS002 := "Confirma dados"
   MS003 := "Confirma exclus„o"
   MS004 := "C¢digo n„o incluso!"
   MS005 := "C¢digo j  incluso!"
   MS007 := "Aguarde, otimizando arquivos..."
   MS009 := "Confirma parametriza‡”es"
   MS012 := "Imprimindo..."
   MS013 := "Aguarde..."
   MS014 := "Tecle algo para continuar..."
   MS031 := "Imprimindo relat¢rio"
   MS050 := "Nenhuma informa‡„o foi apurada para;a emiss„o do relat¢rio!"
   MS060 := "Nenhuma informa‡„o foi apurada para;a gera‡„o do(s) arquivo(s)!"

RETURN( .T. )



FUNCTION TDigito( cTipDig, nKey )

   LOCAL lReturn

   vDef( @nKey, LastKey() )

   IF Upper( cTipDig ) = "N"

      lReturn := ( ( StrZero( nKey, 2 ) $ "08*13*27*43*45*46*47" .AND. !Empty( CprAll ) ) .OR. ( nKey > 47 .AND. nKey < 58 ) )

   ELSEIF Upper( cTipDig ) = "C"

      lReturn := ( ( StrZero( nKey, 2 ) $ "08*13*27"             .AND. !Empty( CprAll ) ) .OR. ( nKey > 32 .AND. nKey < 126 .AND. !Chr( nKey ) $ ".+-*/1234567890 " ) )

   ELSE

      lReturn := ( ( StrZero( nKey, 2 ) $ "08*13*27"             .AND. !Empty( CprAll ) ) .OR. ( nKey > 31 .AND. nKey < 126 .AND. ( !Empty( CprAll ) .OR. !Chr( nKey ) $ ".+-*/[]{} " ) ) )

   ENDIF

RETURN( lReturn )



FUNCTION TCprAll( nLen )

   IF Empty( CPRALL )
      CPRALL := "|"
   ELSE
      IF CPRALL = "|"
         CPRALL := ""
      ENDIF
      CPRALL := If( LastKey() = K_BS, Left( CPRALL, Len( CPRALL ) - 1 ), CPRALL + Upper( Chr( LastKey() ) ) )
   ENDIF
   IF Empty( CPRALL) .OR. Len( CPRALL ) > nLen .OR. mxIn( LastKey(), { K_ESC, K_ENTER } )
      CPRALL := "."
      RETURN( .F. )
   ENDIF

RETURN( .T. )



PROCEDURE ClearKeybBuffer  // Limpa o buffer do teclado

   KEYB Chr( 0 )
   
   DO WHILE InKey() <> 0
      KEYB Chr( 0 )
   ENDDO

RETURN( NIL )



FUNCTION ConfMsg( ;       // Exibe mensagem com opcoes para selecao no rodape da tela
                  cMsg,;  // Mensagem
                  aOpc ;  // Array com as opcoes
                )
                
   LOCAL nOpc := 0
   LOCAL cDevice, cTela, cColor, aPrompt, nCursor, nAux, nCol

   cMsg := AllTrim( cMsg )

   IF At( "?", cMsg ) = 0
      cMsg += "?"
   ENDIF

   BEGIN SEQUENCE

      #ifdef MINIGUI_MODE

         IF IsDef( "CS_MINIGUI" ) .AND. CS_MINIGUI
            nOpc := MsgOptions( StrTran( cMsg, "^", "" ), "Confirmação", aOpc, NIL, NIL, "msg_help" )
            BREAK
         ENDIF

      #endif

      cMsg += " "
      aEval( aOpc, { |o| cMsg += " " + o + " " } )
      cMsg := PadC( cMsg, If( "^" $ cMsg, 82, 80 ) )

      cDevice := Set( _SET_DEVICE, "SCREEN" )
      cTela   := SaveScreen( 24, 00, 24, 79 )
      cColor  := SetColor( "0/15,15/1,,,15/1" )
      nCursor := SetCursor( 0 )
      aPrompt := {}

      DO WHILE nOpc = 0

         nCol := At( "?", cMsg )
         IF ! "^" $ cMsg
            nCol ++
         ENDIF

         Say( MaxRow(),00, cMsg, "4/15", "1/15" )

         IF Len( aPrompt ) = 0

            FOR nAux := 1 TO Len( aOpc )

               mxPrompt( 24, nCol, " " + aOpc[ nAux ] + " ", aPrompt )

               nCol += Len( aOpc[ nAux ] ) + 2

            NEXT

         ENDIF

         mxMenuRead( @nOpc, aPrompt, "15/1", "0/15", "12/1", "4/15" )

      ENDDO

      RestScreen( 24, 00, 24, 79, cTela )
      SetCursor( nCursor )
      SetColor( cColor )
      SetLastKey( 13 )

      Set( _SET_DEVICE, cDevice )

   ENDSEQUENCE

RETURN( nOpc )



FUNCTION FTitle( cTitle, nEvent )

   DO CASE
      CASE nEvent = K_INCLUIR   ; cTitle := "Inclus„o de "  + cTitle
      CASE nEvent = K_ALTERAR   ; cTitle := "Altera‡„o de " + cTitle
      CASE nEvent = K_EXCLUIR   ; cTitle := "Exclus„o de "  + cTitle
      CASE nEvent = K_CONSULTAR ; cTitle := "Consulta de "  + cTitle
      OTHE                      ; cTitle := Upper( Left( cTitle, 1 ) ) + Subs( cTitle, 2 )
   ENDCASE

RETURN( cTitle )



FUNCTION ConfEvent( nEvent, cMsg )

   LOCAL uReturn

   BEGIN SEQUENCE

      #ifdef MINIGUI_MODE

         IF IsDef( "CS_MINIGUI" ) .AND. CS_MINIGUI
            uReturn := wConfEvent( nEvent, cMsg )
            BREAK
         ENDIF

      #endif

      uReturn := .F.

      DO CASE
         CASE nEvent = K_INCLUIR   ; cMsg := MS001
         CASE nEvent = K_ALTERAR   ; cMsg := MS002
         CASE nEvent = K_PROCESSAR ; cMsg := MS002
         CASE nEvent = K_EXCLUIR   ; cMsg := MS003
         OTHERWISE
              Mensagem( MS014, 2 )
              BREAK
      ENDCASE

      IF ESC
         BREAK
      ELSEIF nEvent = K_EXCLUIR
         IF ConfMsg( cMsg, NaoSim ) = 1
            BREAK
         ENDIF
      ELSEIF ConfMsg( cMsg, SimNao ) = 2
         BREAK
      ENDIF

      uReturn := .T.

   ENDSEQUENCE

RETURN( uReturn )



/*----------------------------------------------------------------------------
 Exibe um quadro para a digitacao de uma informacao qualquer.

 Parametros

 cSay  : Mensagem exibida.
 uGet  : Variavel para digitacao.
 cPict : Picture para uGet.

 Retorno : uGet com o seu valor alterado.
----------------------------------------------------------------------------*/

FUNCTION mxGetBox( cSay, uGet, cPict, lRestore, nBackGround, bValid, nScreen, nRow )

   LOCAL GetList := {}

   LOCAL nLen, nLenGet, nLenSay, aState, nCol1, nCol2

   vDef( @lRestore, .T.        )
   vDef( @bValid  , { || .T. } )
   vDef( @nScreen , 1          )
   vDef( @nRow    , 11         )

   SaveState( @aState )

   IF nScreen = 1
      SetColor( "15/9,1/15,,,15/9" )
   ELSE
      SetColor( "7/15,4/15,,,4/15" )
   ENDIF

   IF cPict <> NIL
      cPict := AllTrim( cPict )
      IF Left( cPict, 1 ) = "@"
         cPict := Subs( cPict, 1, At( " ", cPict ) ) + LTrim( Subs( cPict, At( " ", cPict ) ) )
      ENDIF
   ENDIF

   IF nScreen = 1
      cSay += " :"
   ENDIF

   DO CASE
      CASE cPict <> NIL          ; nLenGet := Len( Tran( uGet, cPict ) )
      CASE ValType( uGet ) = "N" ; nLenGet := Len( Str( uGet ) )
      CASE ValType( uGet ) = "D" ; nLenGet := Len( DtoC( uGet ) )
      OTHERWISE                  ; nLenGet := Len( uGet )
   ENDCASE

   IF nScreen = 1
      nLen := Len( cSay ) + nLenGet + 1
   ELSE
      nLen := nLenGet
   ENDIF

   IF nBackGround <> NIL
      BackGround( 1, 0, MaxRow() -1, 79, nBackGround )
   ENDIF

   nCol1 :=   ( 80 - nLen ) / 2 - 2
   nCol2 := ( ( 80 - nLen ) / 2 ) + nLen + 1

   IF nScreen = 1
      @ nRow - 1, nCol1 CLEAR TO nRow + 1, nCol2
      @ nRow - 1, nCol1       TO nRow + 1, nCol2
   ELSE
      @ nRow - 2, nCol1,         nRow + 2, nCol2 BOX "ÛÛÛÛÛÛÛÛ "
      Shadow( nRow - 2, nCol1, nRow + 2, nCol2 )
   ENDIF

   DefCursor()

   IF nScreen = 1
      @ nRow, ( 80 - nLen ) / 2 SAY cSay
      nLenSay := Len( cSay ) + 1
   ELSE
      @ nRow - 2, nCol1 + 2 SAY PadC( cSay, Len( cSay ) + 2 ) COLOR "15/4"
      nLenSay := 0
   ENDIF

   IF cPict = NIL
      @ nRow, ( ( 80 - nLen ) / 2 ) + nLenSay GET uGet VALID Eval( bValid, uGet )
   ELSE
      @ nRow, ( ( 80 - nLen ) / 2 ) + nLenSay GET uGet VALID Eval( bValid, uGet ) PICT cPict
   ENDIF

   READ

   RestState( aState, .F., .F., .T., lRestore )

RETURN( uGet )



FUNCTION RepeatKey( nKey )

   vDef( @nKey, LastKey() )

   KEYB Chr( nKey )

RETURN( .T. )



FUNCTION senGetKey( cSenhaDig )

   LOCAL nKey := mxInkey(0)
   LOCAL lSom := .T.

   IF mxIntervalo( nKey, 33, 126, .F. ) .OR. nKey = K_BS .OR. nKey = K_F2

      IF nKey <> K_BS
         cSenhaDig += Upper( Chr( nKey ) )
      ELSEIF Len( cSenhaDig ) > 0
         cSenhaDig := Left( cSenhaDig, Len( cSenhaDig ) - 1 )
      ELSE
         lSom := .F.
      ENDIF

      IF lSom
         mxTone( 100, 0.01 )
      ENDIF

   ENDIF

RETURN( nKey )



/*----------------------------------------------------------------------------
 Exibe mensagem com opcoes para selecao.

 Parametros para uOpt:

 NIL    = Mostra apenas o botao de "Ok".
 "NP"   = Mostra apenas a mensagem, sem botoes.
 Matriz = Matriz com opcoes para selecao, ex: { "Sim","Nao" }.
 "LOG"  = Cria LOG em mxError.LOG
 "ACE"  = Traz campo para digitacao da constante "OK". Neste caso, ESC
          retornar 0, e ENTER retorna 1.
 "ACEF" = Traz campo para digitacao da constante "OK", igual ao
          parametro anterior, mas nao permite teclar ESC.
----------------------------------------------------------------------------*/

FUNCTION MsgDlg( uMessage, uOpt, cColor, lMudaCor, nOption, nRow, lNoRestScr, cTitulo )

   #define MSG_MAXLIN 15 + If( lButton, 0, 2 )

   LOCAL GetList     := {}
   LOCAL aMsg        := {}
   LOCAL cColorSave  := SetColor()
   LOCAL cTelaSave   := SaveScreen()
   LOCAL aPos        := SavePos()
   LOCAL nCursor     := SetCursor()
   LOCAL nLenOptions := 0
   LOCAL nLastLine   := 0
   LOCAL nColAce     := 0
   LOCAL nPointer    := 1
   LOCAL nLineAdjust := 2
   LOCAL cAceitar    := Space(2)
   LOCAL lEsc        := .T.
   LOCAL lLog        := .F.
   LOCAL lButton     := .T.
   LOCAL lScroll     := .F.

   LOCAL nColBeg, nCol, nDefault, nChrLen
   LOCAL nCount, nLen, nLineBeg, nLineEnd, nDefLine
   LOCAL aOptions, aDefMenu, oBrowse, cMsg, cWait, cAux
   
   #ifdef MINIGUI_MODE

      IF IsDef( "CS_MINIGUI" ) .AND. CS_MINIGUI
      
         vDef( @uOpt, { "Ok" } )
         
         uMessage := CharRemove( StrTran( uMessage, ";", _NL ) )
         
         IF cColor <> NIL
            cColor := "msg_" + Lower( cColor )
         ENDIF

         vDef( @cTitulo, "Informação importante" )
         
         RETURN( MsgOptions( uMessage, cTitulo, uOpt, nOption, NIL, cColor ) )

      ENDIF

   #endif

   vDef( @cTitulo, "Informa‡„o importante" )

   vDef( @cColor    , "4" )
   vDef( @lMudaCor  , .F. )
   vDef( @nOption   , 1   )
   vDef( @lNoRestScr, .F. )

   IF uMessage = NIL .OR. Len( uMessage ) = 0
      RETURN( nOption )
   ENDIF
   
   IF ValType( uOpt ) = "C"
      IF uOpt = "LOG"
         aOptions := { " Ok " }
         lLog := .T.
      ELSEIF uOpt = "ACEF"
         uOpt := "ACE"
         lEsc := .F.
      ELSEIF uOpt = "ACEF2"
         uOpt := "ACE2"
         lEsc := .F.
      ELSEIF ! mxIn( uOpt, { "NP","ACE","ACE2" } )
         cWait   := uOpt
      ELSE
         lButton := uOpt <> "NP"
      ENDIF
      IF uOpt <> "LOG"
         aOptions := NIL
      ENDIF
   ELSEIF uOpt = NIL
      aOptions := { " Ok " }
   ELSE
      aOptions := aClone( uOpt )
   ENDIF

   IF aOptions <> NIL

      FOR nCount := 1 TO Len( aOptions )
         aOptions[ nCount ] := PadC( aOptions[ nCount ], Len( aOptions[ nCount ] ) + 2 )
      NEXT

      FOR nCount := 1 TO Len( aOptions )
         nLenOptions += Len( StrTran( aOptions[ nCount ], "&", "" ) )
         IF nCount <> Len( aOptions )
            nLenOptions ++
         ENDIF
      NEXT

   ENDIF

   nLen := nLenOptions

   IF ValType( uMessage ) = "C"
      aMsg := mxCtoA( CheckMsgDlg( uMessage ), ";", MSG_MAXLIN )
   ELSEIF Len( uMessage ) > MSG_MAXLIN
      FOR nDefLine := 1 TO Len( uMessage )
         aAdd( aMsg, { uMessage[ nDefLine ] } )
      NEXT
   ELSE
      aEval( uMessage, { |x| aAdd( aMsg, x ) } )
   ENDIF

   IF aOptions = NIL .AND. mxIn( uOpt, { "ACE","ACE2" } )
      aAdd( aMsg, "" )
      IF uOpt = "ACE" .AND. lEsc
         aAdd( aMsg, "Caso deseje realmente prosseguir" )
         aAdd( aMsg, 'digite ^"OK"^ no campo abaixo'    )
      ELSE
         aAdd( aMsg, 'Digite ^"OK"^ para prosseguir' )
      ENDIF
      aAdd( aMsg, "" )
      aAdd( aMsg, "[  ]" )
   ENDIF

   FOR nDefLine := 1 TO Len( aMsg )

      IF ValType( aMsg[ nDefLine ] ) = "C"
         cAux := aMsg[ nDefLine ]
      ELSE
         cAux := aMsg[ nDefLine, 1 ]
      ENDIF

      cAux := StrTran( cAux, "^", "" )

      nLen := Max( nLen, Len( cAux ) + 2 )

   NEXT

   nLen := Max( nLen, 23 )

   IF nLen <> 0

      IF nRow = NIL
         nLineBeg := Int( ( MaxRow() - Min( Len( aMsg ), MSG_MAXLIN ) ) / 2 ) - nLineAdjust + 1
         IF aOptions = NIL .AND. uOpt = "ACE2"
            nLineBeg ++
         ENDIF
      ELSE
         nLineBeg := nRow
      ENDIF
      
      lScroll := Len( aMsg ) > MSG_MAXLIN

      IF lScroll
         nLineEnd := nLineBeg + MSG_MAXLIN
      ELSE
         nLineEnd := nLineBeg + Len( aMsg )
      ENDIF
      
      IF ! lButton
         nLineEnd += 1
      ENDIF

      nColBeg := Int( ( 80 - nLen ) / 2 )

      DisplayOn()

      IF lMudaCor
         Muda_Cor( 01, 00, MaxRow() -1, 79, CFIFUNCTR )
      ENDIF

      SetColor( "0/7,15/" + cColor + ",,,0/7" )

      IF cColor = "0"
         Muda_Cor( 00, 00, 24, 79, 64 )
         @ nLineBeg - nLineAdjust, nColBeg -2 SAY PadC( "­ Alerta de erro !"   , nLen +4 ) COLOR "15/" + cColor
      ELSE
         @ nLineBeg - nLineAdjust, nColBeg -2 SAY PadC( cTitulo, nLen +4 ) COLOR "15/" + cColor
      ENDIF

      IF aOptions = NIL
         nLineAdjust := 0
      ENDIF

      @ nLineBeg -1              , nColBeg -2,;
        nLineEnd +2 + nLineAdjust, nColBeg +1 + nLen BOX "         " COLOR "15/7"

      @ nLineBeg   , nColBeg -1,;
        nLineEnd +1, nColBeg + nLen  BOX "ÛÛÛÛÛÛÛÛÛ" COLOR "15/7"

      Shadow( nLineBeg -2              , nColBeg -2,;
              nLineEnd +2 + nLineAdjust, nColBeg +1 + nLen )

      MsgDlg_status( If( aOptions = NIL .AND. mxIn( uOpt, { "ACE","ACE2" } ), uOpt, aOptions ) )

      IF lScroll .AND. mxIn( uOpt, { "ACE","ACE2" } ) .AND. nLen > 64

         aMsg[ Len( aMsg ) - 3 ] := 'Caso deseje realmente prosseguir digite ^"OK"^ no campo abaixo'

         aDel( aMsg, Len( aMsg ) - 2 )
         aSize( aMsg, Len( aMsg ) -1 )
         
      ENDIF

      IF lScroll

         SetCursor(0)

         h_Print( nLineBeg +1, nLineEnd, nColBeg + nLen +1, Chr(24), "±", Chr(25) )

         FOR nCount := 1 TO Len( aMsg )
            IF ValType( aMsg[ nCount ] ) = "C"
               aMsg[ nCount ] := { aMsg[ nCount ] }
            ENDIF
            aMsg[ nCount, 1 ] := PadC( StrTran( aMsg[ nCount, 1 ], "^", "" ), nLen )
         NEXT

         IF aOptions <> NIL

            nCol := Int( ( 80 - nLenOptions ) / 2 )

            FOR nCount := 1 TO Len( aOptions )

               Say( nLineEnd +3, nCol, aOptions[ nCount ], "0/7", "15/4" )

               nCol += Len( StrTran( aOptions[ nCount ], "&", "" ) ) +1

            NEXT
            
         ENDIF

         SetColor( "1/15,4/15,,,1/15" )

         oBrowse := TBrowseNew( nLineBeg +1, nColBeg -1,;
                                nLineEnd   , nColBeg + nLen )

         oBrowse:SkipBlock     := { |nRequest| TbrSkip( aMsg, nRequest, @nPointer ) }
         oBrowse:GoBottomBlock := { || nPointer := Len( aMsg ) }
         oBrowse:GoTopBlock    := { || nPointer := 1 }

         oBrowse:AddColumn( TbColumnNew( NIL, { || aMsg[ nPointer, 1 ] } ) )

         DO WHILE .T.

            ForceStable( oBrowse )

            Pointer( nLineBeg +1, nLineEnd, nColBeg + nLen +1, brPointer( oBrowse ) )

            nKey := mxInKey()

            DO CASE
               CASE BrwKey( oBrowse, nKey )
               CASE nKey = K_ENTER
                    EXIT
            ENDCASE

         ENDDO

      ELSE

         FOR nDefLine := 1 TO Len( aMsg )

            nLastLine := nLineBeg + nDefLine
            nChrLen   := Len( aMsg[ nDefLine ] ) - Len( StrTran( aMsg[ nDefLine ], "^", "" ) )
            cMsg      := PadC( aMsg[ nDefLine ], nLen + nChrLen )

            Say( nLastLine, nColBeg, cMsg, "4/15", "1/15" )

            IF aOptions = NIL .AND. mxIn( uOpt, { "ACE","ACE2" } ) .AND. nDefLine = Len( aMsg )
               nColAce := nColBeg + At( "[", PadC( aMsg[ nDefLine ], nLen ) )
            ENDIF

         NEXT

         IF aOptions = NIL .AND. mxIn( uOpt, { "ACE","ACE2" } )

            DO WHILE .T.

               DefCursor()

               @ nLastLine, nColAce ;
                 GET   cAceitar ;
                 PICT  "@!@K" ;
                 VALID ! Empty( cAceitar ) .AND. ;
                       cAceitar = "OK" ;
                 COLOR "4/15"

               READ

               IF LastKey() <> K_ESC
                  EXIT
               ELSEIF lEsc
                  nOption := 0
                  EXIT
               ENDIF

            ENDDO

         ELSEIF aOptions <> NIL .AND. Len( aOptions ) > 0

            nDefault := nOption

            DO WHILE .T.

               nCol := Int( ( 80 - nLenOptions ) / 2 )

               aDefMenu := {}

               FOR nCount := 1 TO Len( aOptions )

                   mxPrompt( nLineEnd +3, nCol, aOptions[ nCount ], aDefMenu )

                   nCol += Len( StrTran( aOptions[ nCount ], "&", "" ) ) +1

               NEXT

               mxMenuRead( @nOption, aDefMenu, "15/4", "0/7", "15/4", "15/7" )

               IF ! ESC
                  EXIT
               ENDIF

               nOption := nDefault

            ENDDO

            SetLastKey( K_ENTER )

         ENDIF

      ENDIF

      IF ( aOptions <> NIL .OR. ( mxIn( uOpt, { "ACE","ACE2" } ) ) ) .AND. ! lNoRestScr
         RestScreen( ,,,, cTelaSave )
      ENDIF

      SetColor( cColorSave )
      RestPos( aPos )
      DisplayRestore()

      IF cWait <> NIL
         mxDelay( cWait, .T. )
      ENDIF

   ENDIF

   IF lLog
   
      cAux := ""
      aEval( aMsg, { |x,n| cAux += StrTran( x, "^", "" ) + _NL } )
      cAux += _NL
      mxErrorLog( cAux )

   ELSEIF ValType( uOpt ) = "C" .AND. mxIn( uOpt, { "ACE","ACE2" } ) .AND. nOption = 1

      mxFAddLine( "LOGS\MXCONF.LOG", "*** " + FDate( Date(), "DD/MM/AAAA" ) + " - " + Time() + " ***" + _NL )
      aEval( aMsg, { |x,n| If( n < Len( aMsg ) -4, mxFAddLine( "LOGS\MXCONF.LOG", StrTran( If( ValType( x ) = "A", x[1], x ), "^", "" ) ), NIL ) } )
      mxFAddLine( "LOGS\MXCONF.LOG", _NL )

   ENDIF

   SetCursor( nCursor )

RETURN( nOption )



STATIC PROCEDURE MsgDlg_status( uMSG_aOptions )

   LOCAL MSG_cMsgStatus
   
   IF uMSG_aOptions = NIL
      MSG_cMsgStatus := ""
   ELSEIF ValType( uMSG_aOptions ) = "C" .AND. uMSG_aOptions = "ACE"
      MSG_cMsgStatus := "ESCúCancela/Retorna"
   ELSEIF Len( uMSG_aOptions ) = 1
      MSG_cMsgStatus := "Tecle Ù para continuar"
   ELSE
      MSG_cMsgStatus := "Selecione uma op‡„o e tecle Ù para continuar"
   ENDIF

   @ MaxRow(), 0 SAY PadC( MSG_cMsgStatus, 80 ) COLOR "0/7"

RETURN




FUNCTION CheckMsgDlg( cMsg )

   LOCAL cReturn := ";" + cMsg + ";"
   LOCAL nPos    := 1

   DO WHILE AtNum( ";", cReturn, nPos ) <> Rat( ";", cReturn )

      IF AtNum( ";", cReturn, nPos +1 ) - AtNum( ";", cReturn, nPos ) > 72
         cReturn := PosIns( cReturn, ";", AtNum( ";", cReturn, nPos ) + 72 )
      ELSE
         nPos++
      ENDIF

   ENDDO

   cReturn := Subs( cReturn, 2, Len( cReturn ) -2 )

RETURN( cReturn )



FUNCTION formatMsg( aMsg, lSimples )

   LOCAL cMsg := ""
   LOCAL nMsg := 0
   LOCAL nNum := 0
   LOCAL nCount

   vDef( @lSimples, .F. )

   IF Len( aMsg ) = 1

      cMsg := aMsg[ 1 ]

   ELSEIF lSimples

      FOR nCount := 1 TO Len( aMsg )
         IF ! Empty( cMsg )
            cMsg += ";"
         ENDIF
         cMsg += aMsg[ nCount ]
      NEXT

   ELSE

      FOR nCount := 1 TO Len( aMsg )
         IF Len( aMsg[ nCount ] ) > nMsg
            nMsg := Len( aMsg[ nCount ] )
         ENDIF
      NEXT

      FOR nCount := 1 TO Len( aMsg )
         IF ! Empty( cMsg )
            cMsg += ";"
         ENDIF
         IF Left( aMsg[ nCount ], 1 ) = ")"
            aMsg[ nCount ] := Subs( aMsg[ nCount ], 2 )
         ELSE
            cMsg += "^" + NumToStr( ++nNum ) + ")^ "
         ENDIF
         cMsg += PadR( aMsg[ nCount ], nMsg )
      NEXT

   ENDIF

RETURN( cMsg )



FUNCTION chrSubst( nKey, lRetChr )

   vDef( @lRetChr, .F. )

   IF ValType( nKey ) = "C"
      nKey := Asc( nKey )
   ENDIF

   FOR nCount := 1 TO Len( KEY_SUBST )
      IF nKey = KEY_SUBST[ nCount, 1 ]
         nKey := KEY_SUBST[ nCount, 2 ]
         EXIT
      ENDIF
   NEXT

RETURN( If( lRetChr, Chr( nKey ), nKey ) )



PROCEDURE key_ChrSubst( lOn )

   LOCAL aKeys := {}

   vDef( @lOn, .T. )

   aEval( KEY_SUBST, { |k| aAdd( aKeys, k[1] ) } )

   HB_SetKeyArray( aKeys, If( lOn, { || key_ChrSubst_Aux() }, NIL ) )

RETURN



STATIC PROCEDURE key_ChrSubst_Aux()

   LOCAL nKeyOri := LastKey()
   LOCAL nKey    := chrSubst( nKeyOri )

   IF nKeyOri <> nKey
      ClearKeybBuffer()
      SetLastKey( 0 )
      HB_KeyPut( K_BS )
      HB_KeyPut( nKey )
   ENDIF

RETURN