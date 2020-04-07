/*

 MaxMenu.prg
 Descricao: Biblioteca de funcoes de menu.
 Desenvolvido por MAX SCALLA Informatica Ltda.
 
 EMERSON DA SILVA CREMA
 22/07/15 * Implementado o parametro cStatus em aSelect().

 DENIS MAZZUCATTO RODRIGUES
 07/08/09 * Implementado parametro aLeg em Key_Modulo() e implementada
            inclusao direta das teclas padroes de acesso.

 EMERSON DA SILVA CREMA
 03/07/08 * Implementados os parametros cC2Ativ e cC2Inat em mxMenuRead() e
            mxMenuDisplay().
 09/01/07 * Movida MaxChoice() p/ as versoes 2.12c e 3.07.
 29/08/06 * Implementada utilizacao de divisoes em aSelect().
          * Implementacao de mxMenuRead() e mxPrompt() em aSelect().
 31/07/06 * Implementados os parametros nRow, nCol e nItens em MenuList().
 25/07/06 * Implementado SeqToChr() em mnuFormatOpc().
          * Desenvolvimento de MenuList().
 25/07/06 * Alteracao em MenuRead() p/ permitir atalho por "0".

 DENIS MAZZUCATTO RODRIGUES
 25/07/05 * Desenvolvimento de SeleOpcMsg().
 25/07/05 * Modificacao em mxMenuRead() p/ emitir alerta sonoro qdo ocorrer
            erro no CSW.

 EMERSON DA SILVA CREMA
 24/05/05 * Correcao em mxMenuRead() pois nao acessava as opcoes de forma
            correta atraves da tecla de atalho.
 02/02/05 * Implementado parametro nLines em aSelect().
          * Inclusa barra lateral na janela de aSelect() qdo o numero de
            itens da lista e maior q o numero de linhas visiveis.
 09/09/04 * Desenvolvimento de menuSetaAtiva().
 29/08/04 * Corrigido o problema em MenuRead() e mxMenuRead() pois qdo era
            executada uma funcao por set key, qdo finalizava a funcao e
            retornava p/ o mInkey() e teclava-se o atalho p/ a opcao acabava
            desposicionando a tela. Substituicao de mInkey() por mxInKey().

*/

#include "std.ch"
#include "inkey.ch"

STATIC lSetaAtiva := .F.


FUNCTION SeleOpc( cMensagem, cOpcoes, nQuadro, nBackGround, nModo )

   LOCAL cColor    := SetColor( "0/7,15/7,,,0/7" )
   LOCAL cTela     := SaveScreen( 01, 00, MaxRow(), 79 )
   LOCAL cResposta := Left( cOpcoes, 1 )
   LOCAL nOpcao    := 0

   LOCAL nTamanho, nColuna, nLinha

   DO WHILE .T.

      @ MaxRow(), 00 SAY Space(80)

      IF nQuadro <> NIL

         BackGround( 01, 00, MaxRow() - 1, 79, nBackGround )

         Limpa( ;
                Int( MaxRow() / 2 ) - 1                          ,;
                ( 78 - ( nTamanho := Len( cMensagem ) + 5 ) ) / 2,;
                Int( MaxRow() / 2 ) + 1                          ,;
                81 - ( ( 80 - nTamanho ) / 2 )                   ,;
                "S"                                               ;
              )

         nLinha  := Int( MaxRow() / 2 )
         nColuna := ( 80 - nTamanho ) / 2 + 1

      ELSE

         nLinha  := MaxRow()
         nColuna := ( 80 - ( Len( cMensagem ) + 4 ) ) / 2

      ENDIF

      @ nLinha, nColuna ;
        SAY   cMensagem + " " + Chr( 26 ) ;
        GET   cResposta ;
        PICT  "!" ;
        VALID cResposta $ cOpcoes

      READ

      IF LastKey() = K_ESC
         IF nModo <> NIL
            RestScreen( 01, 00, MaxRow(), 79, cTela )
            SetColor( cColor )
            EXIT
         ENDIF
      ELSE
         nOpcao := At( cResposta, cOpcoes )
         EXIT
      ENDIF

   ENDDO

   RestScreen( 01, 00, MaxRow(), 79, cTela )
   SetColor( cColor )

RETURN( nOpcao )



FUNCTION MenuOpen()

   PUBLIC ArrMenu := {}
   PUBLIC ArrKeys := {}

RETURN( NIL )



FUNCTION Prompt( nLin, nCol, cOption, cMsg )

   LOCAL nPos := At( "&", cOption )
   LOCAL cCharKey

   IF nPos = 0
      cCharKey := Left( Ltrim( cOption ), 1 )
      nPos     := Len( cOption ) - Len( Ltrim( cOption ) ) + 1
   ELSE
      cCharKey := Subs( cOption, nPos + 1, 1 )
      cOption  := Left( cOption, nPos - 1 ) + " " + ;
                  Subs( cOption, nPos + 2 )
   ENDIF

   aAdd( ArrMenu, { nLin, nCol, cOption, cCharKey, nCol + nPos - 1, cMsg } )
   aAdd( ArrKeys, Upper( cCharKey ) )

RETURN( NIL )



FUNCTION MenuRead( nOptPrompt, cCorAtiv, cCorInat, cCorChrAt, cCorChrIn, cCorMens, nMode, bEval, cCorMold, lUpDown )

   LOCAL nCursor   := SetCursor(0)
   LOCAL nOption   := If( nOptPrompt <= 0 .OR. nOptPrompt > Len( ArrMenu ), 1, nOptPrompt )
   LOCAL nNewPos   := nOption
   LOCAL lPressKey := .F.
   LOCAL nKey      := 0
   LOCAL aTela     := {}

   LOCAL cKey, nPrompt, cTelaMov

   vDef( @cCorAtiv , "15/0" )
   vDef( @cCorInat , "0/7"  )
   vDef( @cCorChrIn, "15/7" )
   vDef( @cCorChrAt, "15/0" )
   vDef( @cCorMens , "0/7"  )
   vDef( @cCorMold , "0/15" )

   FOR nPrompt := 1 TO Len( ArrMenu )

       IF If( nMode = NIL, .F., mxIn( nMode, { 1, 2 } ) )

          aAdd( aTela, SaveScreen( ArrMenu[ nPrompt, 1 ], ArrMenu[ nPrompt, 2 ], ArrMenu[ nPrompt, 1 ] + 1, ArrMenu[ nPrompt, 2 ] + Len( ArrMenu[ nPrompt, 3 ] ) + 1 ) )

       ENDIF

       IF nPrompt = nOption
          @ ArrMenu[ nPrompt, 1 ], ArrMenu[ nPrompt, 2 ] SAY ModePromp( ArrMenu[ nPrompt, 3 ], nMode ) COLOR cCorAtiv
       ELSE
          @ ArrMenu[ nPrompt, 1 ], ArrMenu[ nPrompt, 2 ] SAY ArrMenu[ nPrompt, 3 ] COLOR cCorInat
       ENDIF

       @ ArrMenu[ nPrompt, 1 ], ArrMenu[ nPrompt, 5 ] SAY ArrMenu[ nPrompt, 4 ] COLOR If( nPrompt = nOption, cCorChrAt, cCorChrIn )

       IF If( nMode = NIL, .F., mxIn( nMode, { 1, 2 } ) )
          SayMold( ArrMenu[ nPrompt, 1 ], ArrMenu[ nPrompt, 2 ], ArrMenu[ nPrompt, 3 ], cCorMold )
       ENDIF

   NEXT

   DO WHILE ( ! lPressKey .AND. ! mxIn( nKey, { K_PGDN, K_PGUP, K_ENTER, K_ESC, K_SPACE } ) )

      @ MaxRow(), 00 SAY Padr( ArrMenu[ nOption, 6 ], 80 ) COLOR cCorMens

      IF bEval <> NIL
         EVal( bEval, nOption )
      ENDIF

      nKey := mxInkey()

      IF mxIn( nKey, { K_UP, K_LEFT } )

         IF nOption = 1
            nNewPos := Len( ArrMenu )
         ELSE
            nNewPos --
         ENDIF

      ELSEIF mxIn( nKey, { K_DOWN, K_RIGHT } )

         IF nOption = Len( ArrMenu )
            nNewPos := 1
         ELSE
            nNewPos ++
         ENDIF

      ELSEIF mxIn( nKey, { K_HOME, K_CTRL_HOME, K_CTRL_PGUP } )

         nNewPos := 1

      ELSEIF mxIn( nKey, { K_END, K_CTRL_END, K_CTRL_PGDN } )

         nNewPos := Len( ArrMenu )

      ELSEIF ( nKey > 64 .AND. nKey < 123 ) .OR. ( nKey > 47 .AND. nKey < 58 )

         cKey := Upper( Chr( nKey ) )

         IF AScan( ArrKeys, cKey ) > 0

            nNewPos   := AScan( ArrKeys, cKey )
            lPressKey := .T.

         ENDIF

      ELSEIF nKey = K_ESC

         nOption := 0

      ELSEIF If( lUpDown = NIL, ! ( StrZero( nKey, 2 ) $ "03*13*18*27*32" .OR. lPressKey ), .F. )

         LOOP

      ENDIF

      IF lUpDown <> NIL .AND. ( StrZero( nKey, 2 ) $ "05*13*24*27*32" .OR. lPressKey )

         IF lPressKey
            nOption := nNewPos
         ENDIF

         KEYB Chr(0) + If( nKey = K_ESC .OR. lPressKey, Chr( K_DOWN ), Chr( nKey ) )
         EXIT

      ENDIF

      IF nOption <> 0 .AND. nNewPos <> nOption

         @ ArrMenu[ nOption, 1 ], ArrMenu[ nOption, 2 ] SAY ArrMenu[ nOption, 3 ] COLOR cCorInat
         @ ArrMenu[ nOption, 1 ], ArrMenu[ nOption, 5 ] SAY ArrMenu[ nOption, 4 ] COLOR cCorChrIn

         @ ArrMenu[ nOption := nNewPos, 1 ], ArrMenu[ nNewPos, 2 ] SAY ModePromp( ArrMenu[ nNewPos, 3 ], nMode ) COLOR cCorAtiv
         @ ArrMenu[ nNewPos           , 1 ], ArrMenu[ nNewPos, 5 ] SAY            ArrMenu[ nNewPos, 4 ]          COLOR cCorChrAt

      ENDIF

      IF StrZero( nKey, 2 ) $ "03*13*18*32" .OR. lPressKey

         IF If( nMode = NIL, .F., mxIn( nMode, { 1, 2 } ) )

            cTelaMov := SaveScreen( ArrMenu[ nOption, 1 ], ArrMenu[ nOption, 2 ], ArrMenu[ nOption, 1 ], ArrMenu[ nOption, 2 ] + Len( ArrMenu[ nOption, 3 ] ) - 1 )

            RestScreen( ArrMenu[ nOption, 1 ], ArrMenu[ nOption, 2 ]    , ArrMenu[ nOption, 1 ] + 1, ArrMenu[ nOption, 2 ] + Len( ArrMenu[ nOption, 3 ] ) + 1, aTela[ nOption ] )
            RestScreen( ArrMenu[ nOption, 1 ], ArrMenu[ nOption, 2 ] + 1, ArrMenu[ nOption, 1 ]    , ArrMenu[ nOption, 2 ] + Len( ArrMenu[ nOption, 3 ] )    , cTelaMov         )
            mxInKey( 0.1 )
            @ ArrMenu[ nOption, 1 ], ArrMenu[ nOption, 2 ] SAY ModePromp( ArrMenu[ nOption, 3 ], nMode ) COLOR cCorAtiv
            @ ArrMenu[ nOption, 1 ], ArrMenu[ nOption, 5 ] SAY            ArrMenu[ nOption, 4 ]          COLOR cCorChrAt

            SayMold( ArrMenu[ nOption, 1 ], ArrMenu[ nOption, 2 ], ArrMenu[ nOption, 3 ], cCorMold )
            mxInKey( 0.1 )

         ENDIF

         IF bEval <> NIL
            EVal( bEval, nOption )
         ENDIF

         SetPos( MaxRow(), 00 )

      ENDIF

   ENDDO

   SetCursor( nCursor )
   ArrMenu := {}
   ArrKeys := {}

RETURN( nOptPrompt := nOption )



FUNCTION ModePromp( cPrompt, nMode )

   IF nMode = NIL
      RETURN( cPrompt )
   ELSEIF mxIn( nMode, { 0, 2 } )
      RETURN( Chr(16) + Subs( cPrompt, 2, Len( cPrompt ) - 2 ) + Chr(17) )
   ELSEIF nMode = 1
      RETURN( cPrompt )
   ENDIF

RETURN( NIL )



FUNCTION SayMold( nLin, nCol, nLen, cCor )

   @ nLin    , nCol + Len( nLen ) SAY      "‹"                 COLOR cCor
   @ nLin + 1, nCol + 1           SAY Repl( "ﬂ", Len( nLen ) ) COLOR cCor

RETURN( NIL )



FUNCTION menuSetaDireita()
   KEYB Chr( K_ESC ) + Chr( K_RIGHT ) + Chr( K_ENTER )
   menuSetaAtiva(.F.)
RETURN(.T.)



FUNCTION menuSetaEsquerda()
   KEYB Chr( K_ESC ) + Chr( K_LEFT ) + Chr( K_ENTER )
   menuSetaAtiva(.F.)
RETURN(.T.)



FUNCTION Seta_Baixo()
   KEYB Chr( K_ENTER )
RETURN(.T.)



FUNCTION aSelect( ;
                  aOpcArray,;
                  cTitle   ,;
                  lRestore ,;
                  nOption  ,;
                  lWrap    ,;
                  nColumn  ,;
                  nColor   ,;
                  aPos     ,;
                  nLines   ,;
                  cStatus   ;
                )

   #define ASEL_PROMPT If( ValType( aArray[ nCount ] ) = "A", aArray[ nCount, 1 ], aArray[ nCount ] )
   #define ASEL_MSG    If( ValType( aArray[ nCount ] ) = "A", aArray[ nCount, 2 ], NIL              )

   LOCAL aArray    := aClone( aOpcArray )
   LOCAL aDefArray := {}
   LOCAL aPrompt   := {}
   LOCAL nLen      := 0
   LOCAL lChar     := .F.
   LOCAL cColor    := SetColor( "9/15,15/4,,,8/7" )

   LOCAL nRow, nCol, nPos, nRowMenu, nCount, nRowAjust

   vDef( @nLines  , If( Len( aArray ) > 16, 16, Len( aArray ) ) )
   vDef( @lRestore, .T. )
   vDef( @lWrap   , .T. )
   vDef( @nOption ,  1  )
   vDef( @cStatus , "Tecle Ÿ para selecionar uma opáÑo ou ESC para cancelar" )

   IF nColumn <> NIL
      aEval( aArray, { |a| aAdd( aDefArray, a[ nColumn ] ) } )
      aArray := aClone( aDefArray )
   ENDIF

   nPos := nOption

   IF nOption = 0
      nOption := 1
   ENDIF

   IF lRestore
      ScreenSave()
      IF nColor <> NIL
         Muda_Cor( 01, 00, MaxRow()-1, 79, nColor )
      ENDIF
      Status( cStatus )
   ENDIF

   FOR nCount := 1 TO Len( aArray )

      IF ASEL_PROMPT = "-"
         LOOP
      ENDIF

      IF ValType( aArray[ nCount ] ) = "A"
         aArray[ nCount, 1 ] := AllTrim( aArray[ nCount, 1 ] )
      ELSE
         aArray[ nCount ] := AllTrim( aArray[ nCount ] )
      ENDIF

      IF ( ! lChar ) .AND. At( "&", ASEL_PROMPT ) > 0
         lChar := .T.
      ENDIF
      nLen := Max( nLen, Len( StrTran( ASEL_PROMPT, "&", "" ) ) + 2 )

   NEXT

   nRowAjust := 0

   IF cTitle <> NIL
      nRowAjust ++
      IF nLen < Len( cTitle )
         nLen := Len( cTitle ) + 2
      ENDIF
   ENDIF

   FOR nCount := 1 TO Len( aArray )

      IF ASEL_PROMPT = "-"
         LOOP
      ENDIF

      IF ValType( aArray[ nCount ] ) = "A"
         aArray[ nCount, 1 ] := PadR( " " + ASEL_PROMPT, nLen + If( At( "&", ASEL_PROMPT ) = 0, 0, 1 ) )
      ELSE
         aArray[ nCount ]    := PadR( " " + ASEL_PROMPT, nLen + If( At( "&", ASEL_PROMPT ) = 0, 0, 1 ) )
      ENDIF

   NEXT

   IF aPos = NIL
      nRow := Int( ( 25 - nLines ) / 2 ) -1
      nCol := Int( ( 80 - nLen + 2 ) / 2 ) - 2
   ELSE
      nRow := aPos[1]
      nCol := aPos[2]
   ENDIF

   IF cTitle <> NIL
      @ nRow, nCol SAY PadC( cTitle, nLen + 2 ) COLOR "15/4"
   ENDIF

   @ nRow + nRowAjust, nCol CLEAR TO nRow + nLines + 1 + nRowAjust, nCol + nLen + 1
   @ nRow + nRowAjust, nCol       TO nRow + nLines + 1 + nRowAjust, nCol + nLen + 1

   IF Len( aArray ) > nLines
      vSay( Chr( 24 ) + Repl( "±", nLines - 2 ) + Chr( 25 ), nRow + nRowAjust + 1, nCol + nLen + 1, 1 )
   ENDIF

   Shadow( nRow, nCol, nRow + nLines + 1 + nRowAjust, nCol + nLen + 1 )

   IF lWrap

      nCount := 0

      FOR nRowMenu := ( nRow + 1 + nRowAjust ) TO ( nRow + nLines + nRowAjust )

         nCount ++

         IF ASEL_PROMPT = "-"
            @ nRowMenu, nCol + 1 SAY Repl( "ƒ", nLen ) COLOR "9/15"
         ELSE
            mxPrompt( nRowMenu, nCol + 1, ASEL_PROMPT, aPrompt, ASEL_MSG )
         ENDIF

      NEXT

      mxMenuRead( @nPos, aPrompt, "15/1", "8/15", "12/1", "12/15", "8/15" )

   ELSE

      SetColor( "0/15,15/1,,,0/15" )

      nPos := aChoice(  ;
                        nRow + 1 + nRowAjust     ,;
                        nCol + 1                 ,;
                        nRow + nLines + nRowAjust,;
                        nCol + nLen              ,;
                        aArray                   ,;
                        NIL                      ,;
                        NIL                      ,;
                        nOption                   ;
                     )
   ENDIF

   IF lRestore
      ScreenRest()
   ENDIF

   SetColor( cColor )

   nOption := nPos
 
RETURN( nPos )



/*----------------------------------------------------------------------------
 Adiciona um novo prompt a matriz de menu

 Parametros

 nLPos   : Linha da posicao
 nCPos   : Coluna da posicao
 sPrompt : Caption do prompt
 aMenu   : Matriz a ser adicionado o prompt
----------------------------------------------------------------------------*/

FUNCTION mxPrompt( nLPos, nCPos, sPrompt, aMenu, sMessage, bEval )

   LOCAL nSeek := At( "&", sPrompt )
   LOCAL cChrDisp, cChrSeek, nSpcIni

   IF nSeek = 0
      nSpcIni := Len( sPrompt ) - Len( LTrim( sPrompt ) )
      sPrompt := Space( nSpcIni ) + "&" + LTrim( sPrompt )
      nSeek   := nSpcIni +1
   ENDIF

   IF nSeek > 0
      cChrDisp := Subs( sPrompt, nSeek +1, 1 )
      cChrSeek := Upper( cChrDisp )
      sPrompt  := Subs( sPrompt, 1, nSeek -1 ) + Subs( sPrompt, nSeek +1 )
   ENDIF

   aAdd( aMenu, { nLPos, nCPos, sPrompt, nCPos + nSeek -1, cChrDisp, cChrSeek, sMessage, bEval } )

RETURN( NIL )



/*----------------------------------------------------------------------------
 Le uma matriz de prompts para menu

 Parametros

 OpcReturn : Variavel de opcao
 aMenu     : Matriz com prompts
 sCOpcAtiv : cor da opcao ativa
 sCOpcInat : cor da opcao inativa
 sCChrAtiv : cor da letra em destaque da opcao ativa
 sCChrInat : cor da letra em destaque da opcao inativa
 sMess     : cor da mensagem de status
 nStatus   : numero do tipo de prompt
 bExecute  : codigo de bloco a ser executado.
             Sera passado a ele como parametro o numero do prompt ativo
 cColorMold: cor da moldura (p/ nStatus = 5 ou 7)

 Retorno : Numero da opcao selecionada.
----------------------------------------------------------------------------*/

FUNCTION mxMenuRead( nOpcRet, aMenu, cCOpcAtiv, cCOpcInat, cCChrAtiv, cCChrInat, cCMess, nStatus, bExecute, cColorMold, lSaveScr, cC2Ativ, cC2Inat )

   LOCAL nSaveCursor := SetCursor(0)
   LOCAL lExit       := .F.
   LOCAL lNewPos     := .T.
   LOCAL aKeys       := {}

   LOCAL lErrorCSW := ( IsProcedure( "DefError" ) .AND. IsProcedure( "CSW" ) )

   LOCAL nKey, nNextOpc, nPos, tScrOpc, cScreen

   aAdd( aKeys, { "0", 385 } )
   aAdd( aKeys, { "1", 376 } )
   aAdd( aKeys, { "2", 377 } )
   aAdd( aKeys, { "3", 378 } )
   aAdd( aKeys, { "4", 379 } )
   aAdd( aKeys, { "5", 380 } )
   aAdd( aKeys, { "6", 381 } )
   aAdd( aKeys, { "7", 382 } )
   aAdd( aKeys, { "8", 383 } )
   aAdd( aKeys, { "9", 384 } )

   aAdd( aKeys, { "A", 286 } )
   aAdd( aKeys, { "B", 304 } )
   aAdd( aKeys, { "C", 302 } )
   aAdd( aKeys, { "D", 288 } )
   aAdd( aKeys, { "E", 274 } )
   aAdd( aKeys, { "F", 289 } )
   aAdd( aKeys, { "G", 290 } )
   aAdd( aKeys, { "H", 291 } )
   aAdd( aKeys, { "I", 279 } )
   aAdd( aKeys, { "J", 292 } )
   aAdd( aKeys, { "K", 293 } )
   aAdd( aKeys, { "L", 294 } )
   aAdd( aKeys, { "M", 306 } )
   aAdd( aKeys, { "N", 305 } )
   aAdd( aKeys, { "O", 280 } )
   aAdd( aKeys, { "P", 281 } )
   aAdd( aKeys, { "Q", 272 } )
   aAdd( aKeys, { "R", 275 } )
   aAdd( aKeys, { "S", 287 } )
   aAdd( aKeys, { "T", 276 } )
   aAdd( aKeys, { "U", 278 } )
   aAdd( aKeys, { "V", 303 } )
   aAdd( aKeys, { "W", 273 } )
   aAdd( aKeys, { "X", 301 } )
   aAdd( aKeys, { "Y", 277 } )
   aAdd( aKeys, { "Z", 300 } )

   vDef( @cCOpcAtiv, SlColor( SetColor(), 2 ) )
   vDef( @cCOpcInat, SlColor( SetColor(), 3 ) )
   vDef( @cCChrAtiv, SlColor( SetColor(), 2 ) )
   vDef( @cCChrInat, SlColor( SetColor(), 3 ) )
   vDef( @cCMess   , SlColor( SetColor(), 3 ) )

   vDef( @cC2Ativ, cCOpcAtiv )
   vDef( @cC2Inat, cCOpcInat )

   vDef( @nStatus ,  0  )
   vDef( @nOpcRet ,  1  )
   vDef( @lSaveScr, .T. )

   IF nOpcRet > Len( aMenu )
      nOpcRet := 1
   ELSE
      nOpcRet := GetNoEmpty( nOpcRet, 1 )
   ENDIF

   // mxMenuDisplay

   FOR nPos := 1 TO Len( aMenu )

      Say( aMenu[ nPos, 1 ], aMenu[ nPos, 2 ], aMenu[ nPos, 3 ], If( nPos = nOpcRet, cC2Ativ, cC2Inat ), If( nPos = nOpcRet, cCOpcAtiv, cCOpcInat ) )

      IF aMenu[ nPos, 5 ] <> NIL
         @ aMenu[ nPos, 1 ], aMenu[ nPos, 4 ] ;
         SAY   aMenu[ nPos, 5 ] ;
         COLOR If( nPos = nOpcRet, cCChrAtiv, cCChrInat )
      ENDIF

      IF mxIn( nStatus, { 2, 4 } )

         @ aMenu[ nPos, 1 ] -1, aMenu[ nPos, 2 ] -1 TO ;
           aMenu[ nPos, 1 ] +1, aMenu[ nPos, 2 ] + Len( StrTran( aMenu[ nPos, 3 ], "^", "" ) );
           COLOR If( nStatus = 4, SlValColor( cCOpcInat, 2 ) + "/" +;
                                  SlValColor( cCOpcInat, 2 ),;
                     cCOpcInat )

      ELSEIF mxIn( nStatus, { 5, 7 } )

         SayMold( aMenu[ nPos, 1 ], aMenu[ nPos, 2 ], aMenu[ nPos, 3 ], cColorMold )

      ENDIF

   NEXT

   //

   DO WHILE ! lExit

      nNextOpc := nOpcRet

      Say( aMenu[ nOpcRet, 1 ], aMenu[ nOpcRet, 2 ], mxModePrompt( aMenu[ nOpcRet, 3 ], nStatus ), cC2Ativ, cCOpcAtiv )

      IF aMenu[ nOpcRet, 5 ] <> NIL
         @ aMenu[ nOpcRet, 1 ], aMenu[ nOpcRet, 4 ] SAY aMenu[ nOpcRet, 5 ] COLOR cCChrAtiv
      ENDIF

      IF lNewPos .AND. mxIn( nStatus, { 1, 2, 3, 4 } )

         tScrOpc := SaveScreen( aMenu[ nOpcRet, 1 ] - 1,;
                                aMenu[ nOpcRet, 2 ] - 1,;
                                aMenu[ nOpcRet, 1 ] + 1,;
                                aMenu[ nOpcRet, 2 ] + Len( StrTran( aMenu[ nOpcRet, 3 ], "^", "" ) ) )

         @ aMenu[ nOpcRet, 1 ] - 1,  ;
           aMenu[ nOpcRet, 2 ] - 1 TO;
           aMenu[ nOpcRet, 1 ] + 1,  ;
           aMenu[ nOpcRet, 2 ] + Len( StrTran( aMenu[ nOpcRet, 3 ], "^", "" ) );
           COLOR If( nStatus > 2, SlValColor( cCOpcAtiv, 2 ) + "/" +;
                                  SlValColor( cCOpcAtiv, 2 ),;
                                              cCOpcAtiv )

      ENDIF

      IF aMenu[ nOpcRet, 7 ] <> NIL
         @ MaxRow(), 00 SAY PadR( aMenu[ nOpcRet, 7 ], 80 ) COLOR cCMess
      ENDIF

      cScreen := NIL

      IF bExecute <> NIL
         IF lSaveScr
            cScreen := SaveScreen()
         ENDIF
         EVal( bExecute, nOpcRet )
      ENDIF

      lNewPos := .F.

      IF Len( aMenu[ nOpcRet ] ) >= 8 .AND. aMenu[ nOpcRet, 8 ] <> NIL
         Eval( aMenu[ nOpcRet, 8 ] )
      ENDIF

      IF lErrorCSW
         mxTone( 499, 5 )
         nKey := mxInKey( 0.5 )
      ELSE
         nKey := mxInKey()
      ENDIF

      IF cScreen <> NIL
         RestScreen( ,,,, cScreen )
      ENDIF

      DO CASE
         CASE mxIn( nKey, { K_ENTER, K_PGDN, K_PGUP, K_SPACE } )
              lExit := .T.
         CASE nKey = K_ESC
              nOpcRet := 0 ; lExit := .T.
              LOOP
         CASE nKey = 1
              nNextOpc := 1
         CASE nKey = 6
              nNextOpc := Len( aMenu )
         CASE mxIn( nKey, { 24, 04 } )
              IF nOpcRet = Len( aMenu )
                 nNextOpc := 1
              ELSE
                 nNextOpc ++
              ENDIF
         CASE mxIn( nKey, { 19, 05 } )
              IF nOpcRet = 1
                 nNextOpc := Len( aMenu )
              ELSE
                 nNextOpc --
              ENDIF
         CASE ( nKey > 64 .AND. nKey < 123 ) .OR. ( nKey > 47 .AND. nKey < 58 ) .OR. ( aScan( aKeys, { |k| k[2] = nKey } ) > 0 )

              nNextOpc := aScan( aMenu, { |x| x[6] = Upper( Chr( nKey ) ) } )

              IF nNextOpc = 0
                 nNextOpc := aScan( aMenu, { |x| Left( Upper( LTrim( StrTran( x[3], "^", "" ) ) ), 1 ) = Upper( Chr( nKey ) ) } )
              ENDIF

              IF nNextOpc = 0
                 nNextOpc := aScan( aKeys, { |k| k[2] = nKey } )
                 IF nNextOpc = 0
                    nNextOpc := nOpcRet
                 ELSE
                    nNextOpc := aScan( aMenu, { |x| x[6] = aKeys[ nNextOpc, 1 ] } )
                    IF nNextOpc = 0
                       nNextOpc := nOpcRet
                    ELSE
                       lExit := .T.
                    ENDIF
                 ENDIF
              ELSE
                 lExit := .T.
              ENDIF
      ENDCASE

      IF lExit .AND. mxIn( nStatus, { 6, 7 } )
         @ aMenu[ nOpcRet, 1 ], aMenu[ nOpcRet, 2 ]                                                     SAY " " COLOR cCOpcAtiv
         @ aMenu[ nOpcRet, 1 ], aMenu[ nOpcRet, 2 ] + Len( StrTran( aMenu[ nOpcRet, 3 ], "^", "" ) ) -1 SAY " " COLOR cCOpcAtiv
      ENDIF

      IF nNextOpc <> nOpcRet
       
         IF mxIn( nStatus, { 1, 2, 3, 4 } )
            RestScreen( aMenu[ nOpcRet, 1 ] - 1,;
                        aMenu[ nOpcRet, 2 ] - 1,;
                        aMenu[ nOpcRet, 1 ] + 1,;
                        aMenu[ nOpcRet, 2 ] + Len( StrTran( aMenu[ nOpcRet, 3 ], "^", "" ) ),;
                        tScrOpc )
         ENDIF

         Say( aMenu[ nOpcRet, 1 ], aMenu[ nOpcRet, 2 ], aMenu[ nOpcRet, 3 ], cC2Inat, cCOpcInat )

         IF aMenu[ nOpcRet, 5 ] <> NIL
            @ aMenu[ nOpcRet, 1 ], aMenu[ nOpcRet, 4 ] SAY aMenu[ nOpcRet, 5 ] COLOR cCChrInat
         ENDIF

         nOpcRet := nNextOpc

         lNewPos := .T.

         IF lExit

            Say( aMenu[ nNextOpc, 1 ], aMenu[ nNextOpc, 2 ], aMenu[ nNextOpc, 3 ], cC2Ativ, cCOpcAtiv )

            IF aMenu[ nNextOpc, 5 ] <> NIL
               @ aMenu[ nNextOpc, 1 ], aMenu[ nNextOpc, 4 ] SAY aMenu[ nNextOpc, 5 ] COLOR cCChrAtiv
            ENDIF

         ENDIF

      ENDIF

   ENDDO

   IF bExecute <> NIL .AND. nOpcRet <> 0
      EVal( bExecute, nOpcRet )
   ENDIF

   SetCursor( nSaveCursor )

RETURN( nOpcRet )



FUNCTION mxModePrompt( cString, nStatus )

   IF nStatus <> NIL .AND. mxIn( nStatus, { 6, 7 } )
      cString := Chr(16) + Subs( cString, 2, Len( cString ) - 2) + Chr(17)
   ENDIF

RETURN( cString )



FUNCTION menuSetaAtiva( lSet )

   LOCAL lReturn := lSetaAtiva

   IF lSet <> NIL
      lSetaAtiva := lSet
   ENDIF

RETURN( lReturn )



FUNCTION SeleOpcMsg( aOpc, nLin, nCol, cTitulo )

   #define OPC_CHECK ( Len( aOpc[1] ) = 3 )

   LOCAL nColOpc := 0
   LOCAL nColMsg := 0
   LOCAL nMaxLin := Len( aOpc )
   LOCAL aMenu   := {}
   LOCAL aMsg    := {}

   LOCAL nCount, nLenOpc, uReturn

   vDef( @nLin, 2 )
   vDef( @nCol, 1 )

   IF cTitulo = NIL
      IF OPC_CHECK
         cTitulo := "Marque as opáîes desejadas"
      ELSE
         cTitulo := "Selecione uma opáÑo"
      ENDIF
   ENDIF

   aEval( aOpc, { |x| nColOpc := Max( nColOpc, Len( x[1] ) ) } )

   FOR nCount := 1 TO Len( aOpc )

       aAdd( aMsg, mxCtoA( aOpc[ nCount, 2 ] ) )

       nMaxLin := Max( nMaxLin, Len( aMsg[ nCount ] ) )

       aEval( aMsg[ nCount ], { |x| nColMsg := Max( nColMsg, Len( x ) ) } )

   NEXT

   nMaxLin += 3
   nLenOpc := nColOpc

   IF OPC_CHECK
      nColOpc += 3
   ENDIF

   nColOpc += nCol +4
   nColMsg += nColOpc +4

   ScreenSave()

   Muda_Cor( 01, 00, 23, 79, CFIFUNCTR )

   @ nLin,nCol SAY PadC( cTitulo, nColMsg - nCol +1 ) COLOR "15/4"

   DispBox( nLin +1, nCol      , nLin + nMaxLin +1, nColMsg   , "€€€€€€€€€", "7/7" )
   DispBox( nLin +2, nCol    +1, nLin + nMaxLin   , nColOpc   , "€€€€€€€€€", "15/15" )
   DispBox( nLin +2, nColOpc +2, nLin + nMaxLin   , nColMsg -1, "€€€€€€€€€", "15/15" )

   FOR nCount := 1 TO Len( aOpc )
       IF OPC_CHECK
          aAdd( aMenu, { nLin + nCount +2, nCol +2, PadR( aOpc[ nCount, 1 ], nLenOpc ) + " ", aOpc[ nCount, 3 ] } )
       ELSE
          mxPrompt( nLin + nCount +2, nCol +2, " " + PadR( aOpc[ nCount, 1 ], nLenOpc ) + " ", aMenu )
       ENDIF
   NEXT

   IF OPC_CHECK
      uReturn := SelectCheck( aMenu, "15/9", "1/15", "15/9", "1/15", 2, NIL, { |x| DispSele( aMsg[ x ], nLin +2, nColOpc +3, nMaxLin -3, nColMsg -1 ) } )
      IF uReturn
         FOR nCount := 1 TO Len( aMenu )
             aSize( aOpc[ nCount ], 1 )
             aOpc[ nCount ] := aMenu[ nCount, 4 ]
         NEXT
      ENDIF
   ELSE
      mStatus( ;
               { { "Use "             , "0/7"  },;
                 { "ESC "             , "15/7" },;
                 { "para retornar ou ", "0/7"  },;
                 { "Ÿ "              , "15/7" },;
                 { "para selecionar"  , "0/7"  } ;
               }, 2 )
      uReturn := 1
      mxMenuRead( @uReturn, aMenu, "15/9", "1/15", "15/9", "1/15", NIL, NIL, { |x| DispSele( aMsg[ x ], nLin +2, nColOpc +3, nMaxLin -3, nColMsg -1 ) } )
   ENDIF

   ScreenRest()

RETURN( uReturn )



STATIC FUNCTION DispSele( aMsg, nLin, nCol, nMaxLin, nMaxCol )

   LOCAL nCount, cTitulo

   FOR nCount := 1 TO nMaxLin

       @ nLin + nCount, nCol SAY Space( nMaxCol - nCol ) COLOR "15/15"
       
       IF nCount <= Len( aMsg )

          cTitulo := aMsg[ nCount ]

          IF "^" = Left(  AllTrim( cTitulo ), 1 ) .AND. ;
             "^" = Right( AllTrim( cTitulo ), 1 )

             cTitulo := StrTran( cTitulo, "^", "" )

             @ nLin + nCount, nCol SAY cTitulo COLOR "4/15"

          ELSE

             @ nLin + nCount, nCol SAY cTitulo COLOR "8/15"

          ENDIF

       ENDIF

   NEXT

RETURN( .T. )



FUNCTION Key_Modulo( aKey, aLeg, lKeyRight )

   LOCAL cSavCor := SetColor()
   LOCAL nSavCur := SetCursor( 0 )
   LOCAL aSavKey := KeyReset( { K_F1 } )
   LOCAL aSavPos := { Row(), Col() }
   LOCAL nLenKey := 0
   LOCAL nLenDes := 0
   LOCAL nPosMnu := 0
   LOCAL lExit   := .F.
   LOCAL aCols   := { 5, 3, 2 }

   LOCAL nRow1, nCol1, nRow2, nCol2, nKey, nLenArr, nCount
   LOCAL oBrowse, oCol, cCol, cKey, aAux

   PRIV nOpcKey := 1
   PRIV aNewKey := {}

   vDef( @lKeyRight, .F. )

   BEGIN SEQUENCE

      IF lKeyRight .AND. LastKey() <> K_RIGHT
         BREAK
      ENDIF

      IF aKey = NIL .OR. Len( aKey ) = 0
         BREAK
      ENDIF

      ClearKeybBuffer()

      IF ValType( aKey[ 1, 1 ] ) = "C"

         cCol := aKey[ 1, 1 ] + "|"
         aAux := aClone( aKey )
         aKey := {}

         DO WHILE Len( cCol ) > 0

            cKey := Left( cCol, At( "|", cCol ) -1 )
            cCol := Subs( cCol, At( "|", cCol ) +1 )

            nCount := aScan( aAux, { |a| a[2] = cKey }, 2 )

            DO CASE
               CASE nCount > 0
                    aAdd( aKey, aAux[ nCount ] )
                    aDelPos( aAux, nCount )
               CASE cKey = "+"   ; aAdd( aKey, { K_INCLUIR  , "+"  , "Inclui"    , "Inclui nov" + aAux[ 1, 2 ]                   , Len( aAux[1] ) = 2 .OR. aAux[ 1, 3 ] } )
               CASE cKey = "*"   ; aAdd( aKey, { K_ALTERAR  , "*"  , "Altera"    , "Altera dados d" + aAux[ 1, 2 ]               , Len( aAux[1] ) = 2 .OR. aAux[ 1, 3 ] } )
               CASE cKey = "-"   ; aAdd( aKey, { K_EXCLUIR  , "-"  , "Exclui"    , "Exclui "  + LTrim( Subs( aAux[ 1, 2 ], 3 ) ) , Len( aAux[1] ) = 2 .OR. aAux[ 1, 3 ] } )
               CASE cKey = "C"   ; aAdd( aKey, { K_EXCLUIR  , "-"  , "Cancela"   , "Cancela " + LTrim( Subs( aAux[ 1, 2 ], 3 ) ) , Len( aAux[1] ) = 2 .OR. aAux[ 1, 3 ] } )
               CASE cKey = "SPC" ; aAdd( aKey, { K_CONSULTAR, "SPC", "Consulta"  , "Consulta dados d" + aAux[ 1, 2 ]             , .T.                                  } )
               CASE cKey = "F4"  ; aAdd( aKey, { K_F4       , "F4" , "Muda ordem", "Muda a disposiáÑo dos dados na lista"        , .T.                                  } )
               CASE cKey = "F10" ; aAdd( aKey, { K_F10      , "F10", "Impressîes", "Permite acessar menu com opáîes de impressÑo", .T.                                  } )
            ENDCASE

         ENDDO

         aDelPos( aAux, 1 )
         aAppend( aKey, aAux )

      ENDIF

      IF aLeg <> NIL .AND. Trim( aKey[ Len( aKey ), 3 ] ) <> "Legenda de cores"
         aAdd( aKey, { 0, "", "Legenda de cores", "Informaáîes sobre as cores dos registros na lista", .T. } )
      ENDIF

      FOR nCount := 1 TO Len( aKey )

         IF Len( aKey[ nCount ] ) = 4 .OR. aKey[ nCount, 5 ]

            aAdd( aNewKey, { ;
                             aKey[ nCount, 1 ]        ,;
                             aKey[ nCount, 2 ]        ,;
                             aKey[ nCount, 3 ]        ,;
                             aKey[ nCount, 4 ]        ,;
                             mnuFormatOpc( ++nPosMnu ) ;
                           } )

            nLenKey := Max( Len( AllTrim( aKey[ nCount, 2 ] ) ), nLenKey )
            nLenDes := Max( Len( AllTrim( aKey[ nCount, 3 ] ) ), nLenDes )

         ENDIF

      NEXT

      FOR nCount := 1 TO Len( aNewKey )
         aNewKey[ nCount, 2 ] := " " + PadR( aNewKey[ nCount, 2 ], nLenKey +1 )
         aNewKey[ nCount, 3 ] := "˘" + PadR( aNewKey[ nCount, 3 ], nLenDes +1 )
      NEXT

      nLenArr := Len( aNewKey )

      IF nLenArr = 0
         BREAK
      ENDIF

      nRow1 := 22 - Min( 20, nLenArr )
      nCol1 := 72 - nLenKey - nLenDes
      nRow2 := 23
      nCol2 := 79

      ScreenSave()

      Limpa( nRow1, nCol1, nRow2, nCol2, "s", NIL, "9/15" )

      IF Len( aNewKey ) > 20
         h_Print( nRow1 + 1, nRow2 - 1, nCol2, Chr(24), "±", Chr(25), "9/15" )
      ENDIF

      oBrowse := TBrowseNew( nRow1 +1, nCol1 +1, nRow2 -1, nCol2 -1 )

      oBrowse:ColorSpec := "08/15," + ;
                           "15/01," + ;
                           "12/15," + ;
                           "15/04," + ;
                           "12/01"

      oBrowse:SkipBlock     := { |nRequest| TbrSkip( aNewKey, nRequest, @nOpcKey ) }
      oBrowse:GoBottomBlock := { || nOpcKey := Len( aNewKey ) }
      oBrowse:GoTopBlock    := { || nOpcKey := 1 }

      oBrowse:ColSep  := ""
      oBrowse:FootSep := ""
      oBrowse:HeadSep := ""

      FOR nCount := 1 TO Len( aCols )

         cCol := "aNewKey[ nOpcKey, " + LTrim( Str( aCols[ nCount ] ) ) + "]"

         oCol := TbColumnNew( NIL, { || &cCol } )

         DO CASE
            CASE nCount = 1 ; oCol:ColorBlock := { || { 3, 2 } }
            CASE nCount = 2 ; oCol:ColorBlock := { || { 1, 2 } }
            CASE nCount = 3 ; oCol:ColorBlock := { || { 4, 4 } }
         ENDCASE

         oBrowse:AddColumn( oCol )

      NEXT

      ClearKeybBuffer()

      DO WHILE ! lExit

         mxDispBegin()

         oBrowse:RefreshCurrent()

         DO WHILE ! oBrowse:Stabilize()
         ENDDO

         @ 24,00 SAY PadR( " " + aNewKey[ nOpcKey, 4 ], 67 ) + " ESC˙Retorna " COLOR "8/15"

         oBrowse:ColorRect( { oBrowse:RowPos, 1, oBrowse:RowPos, 1                   }, { 5, 1 } )
         oBrowse:ColorRect( { oBrowse:RowPos, 2, oBrowse:RowPos, oBrowse:ColCount -1 }, { 2, 1 } )

         mxDispEnd()

         nKey := mxInKey()

         DO CASE
            CASE nKey = K_END .OR. ( nKey = K_UP .AND. nOpcKey = 1 )
                 oBrowse:goBottom()
            CASE nKey = K_HOME .OR. ( mxIn( nKey, { K_RIGHT, K_DOWN } ) .AND. nOpcKey = nLenArr )
                 oBrowse:goTop()
            CASE nKey = K_RIGHT
                 oBrowse:down()
            CASE mxIn( nKey, { K_ESC, K_LEFT } )
                 nOpcKey := 0
                 lExit   := .T.
            CASE mxIn( nKey, { K_ENTER, K_SPACE } )
                 lExit := .T.
            CASE BrwKey( oBrowse, nKey )
                 // Nada a executar.
            CASE Digito( "T" )
                 nPosMnu := aScan( aNewKey, { |x| x[5] = " " + Upper( Chr( nKey ) ) } )
                 IF nPosMnu > 0
                    nOpcKey := nPosMnu
                    lExit   := .T.
                 ENDIF
         ENDCASE

      ENDDO

      ScreenRest()

      IF aLeg <> NIL .AND. Len( aLeg ) > 0 .AND. nOpcKey <> 0 .AND. aNewKey[ nOpcKey, 1 ] = 0

         nRow1 := 22 - Len( aLeg )
         nCol2 := 0

         aEval( aLeg, { |a| nCol2 := Max( nCol2, Len( a[2] ) ) } )

         nCol2 += 6

         ScreenSave()

         @ nRow1 -1,00 SAY PadC( "Legenda de cores" + If( nCol2 < 26, "", " da lista" ), nCol2 +1 ) COLOR "15/4"

         Limpa( nRow1, 0, 23, nCol2, "s", NIL, "9/15" )

         aEval( aLeg, { |a,n| Say( nRow1 + n, 01, "€€€ " + PadR( a[2], nCol2 -5), NIL, a[1] + "/" + SlValColor( CFICO5CTR, 2 ) ) } )

         @ 24,00 SAY PadC( MS014, 80 ) COLOR "8/15"
         Inkey(0)

         ScreenRest()

      ENDIF

      SetLastKey( If( nOpcKey = 0, 0, aNewKey[ nOpcKey, 1 ] ) )

   ENDSEQUENCE

   KeyRestore( aSavKey )
   SetCursor( nSavCur )
   SetColor( cSavCor )
   SetPos( aSavPos[1], aSavPos[2] )

RETURN( NIL )



FUNCTION mnuFormatOpc( nPos, cOpc, nLen )

   LOCAL cReturn := ""

   IF cOpc <> NIL

      cReturn := PadR( cOpc, nLen -2 )

      IF Right( cOpc, 1 ) = ""
         cReturn := PadR( Left( cOpc, Len( cOpc ) -1 ), nLen -4 ) + " "
      ENDIF

   ENDIF

   cReturn := " " + SeqToChr( nPos ) + cReturn

RETURN( cReturn )



FUNCTION MenuList( aMenu, cTitulo, lWrap, nRow, nCol, nItens, nLen, lDefSeq, lRestScreen )

   #define cColorCol "08/15," + ;
                     "15/01," + ;
                     "12/15," + ;
                     "12/01"

   LOCAL nSavCur    := SetCursor( 0 )
   LOCAL cSavCor    := SetColor( "1/15" )
   LOCAL nLenDes    := 0
   LOCAL nRowAjust  := 0
   LOCAL lExit      := .F.
   LOCAL lDispBegin := .F.
   LOCAL aCols      := { 1, 2 }

   LOCAL nRow1, nCol1, nRow2, nCol2, nKey, nLenArr, nCount, nPosMnu, oBrowse
   LOCAL oCol, cCol, bExe

   PRIV nOpc    := 1
   PRIV aNewKey := {}

   vDef( @lWrap      , .T. )
   vDef( @lDefSeq    , .T. )
   vDef( @lRestScreen, .T. )

   IF ! lDefSeq
      aCols := { 2 }
   ENDIF

   ClearKeybBuffer()

   BEGIN SEQUENCE

      IF aMenu = NIL .OR. Len( aMenu ) = 0
         BREAK
      ENDIF

      nPosMnu := 0

      FOR nCount := 1 TO Len( aMenu )

         IF Len( aMenu[1] ) < 3 .OR. aMenu[ nCount, 3 ]

            bExe := NIL

            IF Len( aMenu[ nCount ] ) > 3
               bExe := aMenu[ nCount, 4 ]
            ENDIF

            aAdd( aNewKey, { ;
                             " " + SeqToChr( ++nPosMnu ),;
                             aMenu[ nCount, 1 ]         ,;
                             aMenu[ nCount, 2 ]         ,;
                             bExe                        ;
                           } )

            nLenDes := Max( Len( AllTrim( aMenu[ nCount, 1 ] ) ), nLenDes )

         ENDIF

      NEXT

      IF nLen <> NIL
         nLenDes := nLen
      ENDIF

      IF lDefSeq
         FOR nCount := 1 TO Len( aNewKey )
             IF Right( aNewKey[ nCount, 2 ], 1 ) = ""
                aNewKey[ nCount, 2 ] := "˘" + PadR( Left( aNewKey[ nCount, 2 ], Len( aNewKey[ nCount, 2 ] ) -1 ), nLenDes ) + ""
             ELSE
                aNewKey[ nCount, 2 ] := "˘" + PadR( aNewKey[ nCount, 2 ], nLenDes + 1 )
             ENDIF
         NEXT
      ENDIF

      nLenArr := Len( aNewKey )

      IF nLenArr = 0
         BREAK
      ENDIF

      nLenDes += 4

      IF cTitulo <> NIL
         nRowAjust := 1
      ENDIF

      vDef( @nItens, nLenArr )

      IF nRow = NIL
         nRow1 := 21 - Min( nItens, nLenArr ) - nRowAjust
      ELSE
         nRow1 := nRow
      ENDIF

      IF nCol = NIL
         nCol1 := Int( ( 80 - nLenDes + 2 ) / 2 ) - 2
      ELSE
         nCol1 := nCol
      ENDIF

      nRow2 := nRow1 + Min( nItens, nLenArr ) + nRowAjust + 1
      nCol2 := nCol1 + nLenDes + 1

      IF lRestScreen
         ScreenSave()
      ENDIF

      mxDispBegin()

      IF cTitulo <> NIL
         @ nRow1, nCol1 SAY PadC( cTitulo, nLenDes + 2 ) COLOR "15/4"
      ENDIF

      @ nRow1 + nRowAjust, nCol1 CLEAR TO nRow2, nCol2
      @ nRow1 + nRowAjust, nCol1       TO nRow2, nCol2

      Shadow( nRow1, nCol1, nRow2, nCol2 )

      IF Len( aNewKey ) > nItens
         h_Print( nRow1 + 1 + nRowAjust, nRow2 - 1, nCol2, Chr(24), "±", Chr(25), "9/15" )
      ENDIF

      oBrowse := TBrowseNew( nRow1 + 1 + nRowAjust, nCol1 + 1, nRow2 - 1, nCol2 - 1 )

      oBrowse:ColorSpec := cColorCol

      oBrowse:SkipBlock     := { |nRequest| TbrSkip( aNewKey, nRequest, @nOpc ) }
      oBrowse:GoBottomBlock := { || nOpc := Len( aNewKey ) }
      oBrowse:GoTopBlock    := { || nOpc := 1 }

      oBrowse:ColSep  := ""
      oBrowse:FootSep := ""
      oBrowse:HeadSep := ""

      FOR nCount := 1 TO Len( aCols )

         cCol := "aNewKey[ nOpc, " + LTrim( Str( aCols[ nCount ] ) ) + "]"

         oCol := TbColumnNew( NIL, { || &cCol } )

         DO CASE
            CASE nCount = 1 .AND.  lDefSeq ; oCol:defColor := { 3, 2 }
            CASE nCount = 2 .OR. ! lDefSeq ; oCol:defColor := { 1, 2 }
         ENDCASE

         oBrowse:AddColumn( oCol )

      NEXT

      ClearKeybBuffer()

      DO WHILE ! lExit

         IF lDispBegin
            mxDispBegin()
         ENDIF

         lDispBegin := .T.

         oBrowse:RefreshCurrent()

         DO WHILE ! oBrowse:Stabilize()
         ENDDO

         IF Len( aNewKey ) > nItens
            Pointer( nRow1 + 1 + nRowAjust, nRow2 - 1, nCol2, brPointer( oBrowse ) )
         ENDIF

         @ 24,00 SAY PadR( " " + aNewKey[ nOpc, 3 ], 67 ) + " ESC˙Retorna " COLOR "8/15"

         IF lDefSeq
            oBrowse:ColorRect( { oBrowse:RowPos, 1, oBrowse:RowPos, 1                }, { 4, 1 } )
            oBrowse:ColorRect( { oBrowse:RowPos, 2, oBrowse:RowPos, oBrowse:ColCount }, { 2, 1 } )
         ELSE
            oBrowse:ColorRect( { oBrowse:RowPos, 1, oBrowse:RowPos, oBrowse:ColCount }, { 2, 1 } )
         ENDIF

         mxDispEnd()

         nKey := mxInKey()

         DO CASE
            CASE nKey = K_END .OR. ( lWrap .AND. nKey = K_UP .AND. nOpc = 1 )
                 oBrowse:goBottom()
            CASE nKey = K_HOME .OR. ( lWrap .AND. mxIn( nKey, { K_RIGHT, K_DOWN } ) .AND. nOpc = nLenArr )
                 oBrowse:goTop()
            CASE nKey = K_RIGHT
                 oBrowse:down()
            CASE nKey = K_LEFT
                 oBrowse:Up()
            CASE mxIn( nKey, { K_ENTER, K_SPACE } )
                 lExit := .T.
            CASE nKey = K_ESC
                 lExit := .T.
                 nOpc  := 0
            CASE BrwKey( oBrowse, nKey )
                 // Nada a executar.
            CASE Digito( "T" )
                 nPosMnu := aScan( aNewKey, { |x| x[1] = " " + Upper( Chr( nKey ) ) } )
                 IF nPosMnu > 0
                    nOpc  := nPosMnu
                    lExit := .T.
                 ENDIF
         ENDCASE

      ENDDO

      IF lRestScreen
         ScreenRest()
      ENDIF

   ENDSEQUENCE

   SetCursor( nSavCur )
   SetColor( cSavCor )

   IF nOpc <> 0 .AND. aNewKey[ nOpc, 4 ] <> NIL
      Eval( aNewKey[ nOpc, 4 ] )
   ENDIF

RETURN( nOpc )
