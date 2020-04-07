/*

 MaxTela.prg
 Descricao: Biblioteca de funcoes de tela.
 Desenvolvido por MAX SCALLA Informatica Ltda.

 EMERSON DA SILVA CREMA
 10/07/18 * Correcao de "Error BASE/2022  Argument error: ALLTRIM" em
            TelaParametros().
 25/06/18 * Ajuste em TelaParametros() na definicao dos parametros defaults,
            permitindo aproveitar alguns outros parametros ja personalizados
            na chamada da funcao.
 04/10/16 * Alteracoes em MDisp() p/ permitir retorno com 2 ou mais
            caracteres.
 06/02/15 * Implementado o parametro nTop em TelaParametros().
 26/05/14 * Desenvolvido SaveScrLastRow() e RestScrLastRow().
 26/07/13 * Implementado o parametro cColor em prgsStart(), prgsNext(),
            prgsUpdate() e prgsScreen().
 18/02/10 * Desenvolvimento de rSay().

 DENIS MAZZUCATTO RODRIGUES
 28/07/09 * Implementacao de CharRemove() em Disp_Word().

 EMERSON DA SILVA CREMA
 05/10/07 * Movida olMsgWait() de MAXOLRCV.PRG.
          * Implementado parametro lMsgAguarde em mxWait(), olMsgWait() e
            csWait().
 04/10/07 * Desenvolvimento de csWait().

 DENIS MAZZUCATTO RODRIGUES
 17/04/07 * Remocao de MQuad1(), MQuad2(), MQuad3(), MQuad4(), MQuad5() e
            MQuad6() pois foram implementadas em MQuadro().

 EMERSON DA SILVA CREMA
 09/01/07 * Remocao de Menu_mens(), Stat(), Progress() e Gira().
          * Reprogramada funcao V_Cores_Config().
 27/12/06 * Correcao em TelaParametros() pois os campos de valores e destino
            estavam invertidos.
 11/12/06 * Implementada condicao p/ definir o tamanho maximo das descricoes
            dos campos em TelaParametros().

 DENIS MAZZUCATTO RODRIGUES
 17/11/06 * Implementado parametro cCorBox em Limpa().

 EMERSON DA SILVA CREMA
 25/10/05 * Desenvolvimento de scrDefRest().
 07/07/05 * Desenvolvimento de mxDispBegin() e mxDispEnd().
 06/07/05 * Implementacao de h_print() em Limpa().

 DENIS MAZZUCATTO RODRIGUES
 02/05/05 * Desenvolvimento de TextoFundo().
 20/10/04 * Desenvolvimento de defPosicao().

*/

#include "std.ch"
#include "set.ch"
#include "inkey.ch"

STATIC aDisplaySet := {}
STATIC lDispBegin  := .F.

//*** Variaveis utilizadas nas funcoes de progressivo      ***
//*** BarProgress(), prgsStart(), prgsNext(), prgsUpdate() ***

STATIC nPrgsPerce   := -1
STATIC nPrgsTotal   := 0
STATIC nPrgsCount   := 0
STATIC nPrgsType    := 1
STATIC uPrgsTitle   := NIL
STATIC lPrgsIsDef   := .F.
STATIC nPrgsColumn  := 0
STATIC aSetCursor   := {}
STATIC nPosGira     := 0
STATIC cDispGira    := "-"
STATIC cPrgs1Screen := ""
STATIC cScrLastRow

//***

STATIC aScreen := {}
STATIC aCores  := {}


FUNCTION MensHelp( cMsg, nStatus, nRow )

   LOCAL aPos := SavePos()

   vDef( @nRow, MaxRow() )

   @ nRow, 00 SAY If( nStatus = NIL .OR. nStatus = 1, PadC( cMsg, 80 ),;
                  If(                    nStatus = 2, PadL( cMsg, 80 ),;
                                                      PadR( cMsg, 80 ) ) ) COLOR "0/7"

   RestPos( aPos )

RETURN( .T. )



FUNCTION Limpa( nRow1     ,;
                nCol1     ,;
                nRow2     ,;
                nCol2     ,;
                cBorda    ,;
                cTitulo   ,;
                cCorLimpa ,;
                cCorTitulo,;
                cCorBox )

   // Exibe um quadro em tela ou
   // limpa o espaco da tela nas coordenadas indicadas*

   LOCAL cColor := SetColor()

   IF cCorLimpa <> NIL
      SetColor( cCorLimpa )
   ELSEIF Upper( cBorda ) = "W"
      SetColor( "0/15" )
   ENDIF
   IF cBorda $ "SDQI"
      Shadow( nRow1,nCol1,nRow2,nCol2 )
   ENDIF
   IF cBorda $ "I"
      SetColor( "0/7,15/0,,,1/7" )
   ENDIF
   IF cBorda = "WL"
      @ nRow1,nCol1,nRow2,nCol2 BOX "€€€€€‹€€ " COLOR "15/7"
   ELSEIF mxIn( cBorda, { "W","WB","WB2" } )
      @ nRow1+1,nCol1,nRow2,nCol2 BOX "         "
      IF IsDef( "CORBOX" )
         vDef( @cCorBox, CORBOX )
         IF cBorda = "WB"
            @ nRow1+1,nCol1 TO nRow2,nCol2 COLOR cCorBox
         ELSEIF cBorda = "WB2"
            @ nRow1+1,nCol1 TO nRow2,nCol2 DOUBLE COLOR cCorBox
         ENDIF
      ENDIF
   ELSE
      @ nRow1,nCol1,nRow2,nCol2 BOX If( Upper( cBorda ) = "S" .OR. cBorda = "I" .OR. Upper( cBorda ) = "SD", "⁄ƒø≥Ÿƒ¿≥ ", If( Upper( cBorda ) = "SB", "⁄ƒø≥Ÿƒ¿≥ ", If( Upper( cBorda ) = "SB2", "⁄ƒø±Ÿƒ¿≥ ", If( Upper( cBorda ) = "D", "…Õª∫ºÕ»∫ ", "€ﬂ€€€‹€€ " ) ) ) )
   ENDIF

   IF Upper( cBorda ) = "SB"

      h_Print( nRow1+3, nRow2-1, nCol2, Chr(24), "±", Chr(25) )

   ELSEIF Upper( cBorda ) = "SB2"

      @ nRow1+1,nCol2 SAY Chr(24)
      @ nRow2-1,nCol2 SAY Chr(25)

   ELSEIF Upper( cBorda ) = "Q"

      @ nRow1,nCol1+1 SAY "€"
      @ nRow1,nCol2-1 SAY "€"
      @ nRow2,nCol1+1 SAY "€"
      @ nRow2,nCol2-1 SAY "€"

   ENDIF

   IF cTitulo <> NIL
      IF mxIn( Upper( cBorda ), { "W","WB","WB2" } )
         @ nRow1,nCol1 SAY PadC( cTitulo, nCol2-nCol1+1 ) COLOR If( cCorTitulo = NIL, "15/1", cCorTitulo )
      ELSEIF Upper( cBorda ) = "WL"
         @ nRow1,nCol1 SAY PadC( cTitulo, nCol2-nCol1+1 ) COLOR If( cCorTitulo = NIL, "15/1", cCorTitulo )
      ELSEIF Upper( cBorda ) = "S" .OR. Upper( cBorda ) = "I"
         @ nRow1+2,nCol1   SAY "√" + Repl( "ƒ", nCol2-nCol1-1 ) + "¥"
         @ nRow1+1,nCol1+1 SAY PadC( cTitulo, nCol2-nCol1-1 ) COLOR If( Upper( cBorda ) = "I", "15/8", If( cCorTitulo = NIL, SetColor(), cCorTitulo ) )
      ELSEIF Upper( cBorda ) = "D"
         @ nRow1+2,nCol1   SAY "Ã" + Repl( "Õ", nCol2-nCol1-1 ) + "π"
         @ nRow1+1,nCol1+1 SAY PadC( cTitulo, nCol2-nCol1-1 )
      ELSEIF Upper( cBorda ) = "SB" .OR. Upper( cBorda ) = "SB2"
         @ nRow1,nCol1+1   SAY PadC( cTitulo, nCol2 - nCol1 -1, "ƒ" )
      ELSE
         @ nRow1+1,nCol1+2 SAY PadC( cTitulo, nCol2-nCol1-3 )
      ENDIF
   ENDIF
   IF cBorda <> "I"
      SetColor( cColor )
   ENDIF

RETURN( NIL )



FUNCTION Muda_Cor( nLi, nCi, nLf, nCf, nCor, lSolido )

   LOCAL nTBytes

   IF nCor <> 0

      vDef( @lSolido, .F. )

      IF lSolido
         nCor := Int( nCor / 16 ) * 17
      ENDIF

      nTBytes := Len( SaveScreen( nLi,nCi,nLf,nCf ) )

      RestScreen( nLi,nCi,nLf,nCf, ;
                  If( nTBytes > 2000,;
                      Trans( Subs( SaveScreen( nLi,nCi,nLf,nCf ), 1, 2000 ), Repl( "X" + Chr( nCor ), 2000                                          ) ) + ;
                      Trans( Subs( SaveScreen( nLi,nCi,nLf,nCf ), 2001 )   , Repl( "X" + Chr( nCor ), nTBytes-2000                                  ) )  ,;
                      Trans(       SaveScreen( nLi,nCi,nLf,nCf )           , Repl( "X" + Chr( nCor ), ( ( nLf-nLi ) + 1 ) * ( ( nCf-nCi ) + 1 ) * 2 ) ) ) )
   ENDIF

RETURN(.T.)



FUNCTION Cor_Muda( cCor )

   LOCAL nCor := Val( Subs( cCor, AT( "/", cCor ) + 1, 2 ) ) * 16 + Val( Subs( cCor, 1, AT( "/", cCor ) - 1 ) )

RETURN( nCor )




FUNCTION Memo_Display( cMemo, nRow1, nCol1, nRow2, nCol2, nLen )

   LOCAL nRow

   vDef( @nLen, nCol2 - nCol1 )

   FOR nRow := nRow1 TO nRow2
       @ nRow, nCol1  SAY PadR( MemoLine( cMemo, nCol2 - nCol1, nRow - nRow1 +1 ), nLen )
   NEXT

RETURN( NIL )



FUNCTION MStatus( aString, Mode, Pausa )

   LOCAL cDisplay := Set( _SET_DEVICE, "SCREEN" )
   LOCAL cColor   := SetColor()
   LOCAL aPos     := SavePos()
   LOCAL nStrSize := 0

   SetPos( MaxRow(), 00 )

   IF mxIn( Mode, { 2, 3 } )
      aEval( aString, { |s| nStrSize += Len( s[ 1 ] ) } )
      SetColor( aString[ 1, 2 ] )
      IF Mode = 2
         DevOut( Space( Int( ( 80 - nStrSize ) / 2 ) ) )
      ELSE
         DevOut( Space( 80 - nStrSize ) )
      ENDIF
   ENDIF

   aEval( aString, { |s| SetColor( s[ 2 ] ), DevOut( s[ 1 ] ) } )

   IF mxIn( Mode, { 1, 2 } )
      DevOut( Space( 80 - Col() ) )
   ENDIF

   IF Pausa <> NIL
      IF Pausa = 0
         mxInkey()
      ELSE
         mxTone( 499,5 )
         DO WHILE ( mxInkey() <> K_ESC ) .AND. ! CONSULTA
         ENDDO
      ENDIF
   ENDIF

   SetColor( cColor )
   RestPos( aPos )

   IF Set( _SET_DEVICE ) <> cDisplay
      Set( _SET_DEVICE, cDisplay )
   ENDIF

RETURN( NIL )



FUNCTION Status( cStatus, nPause, nMode )

   LOCAL GetList := {}

   LOCAL cDevice, aPos

   #ifdef MINIGUI_MODE

      IF IsDef( "CS_MINIGUI" ) .AND. CS_MINIGUI
         RETURN( csStatus( CharRemove( cStatus ) ) )
      ENDIF

   #endif

   cDevice := Set( _SET_DEVICE, "SCREEN" )
   aPos    := SavePos()

   @ MaxRow(),00 SAY If( nMode = NIL, PadC(       cStatus      , 80 ),;
                     If( nMode = 1  , PadR( " " + cStatus      , 80 ),;
                                      PadL(       cStatus + " ", 80 ) ) ) COLOR "0/7"

   IF nPause <> NIL
      IF nPause = 0
         mxInkey()
      ELSE
         mxTone( 499,5 )
         mxInKey( NIL, { K_ESC, K_SPACE } )
      ENDIF
   ENDIF

   RestPos( aPos )

   IF cDevice <> "SCREEN"
      Set( _SET_DEVICE, cDevice )
   ENDIF

RETURN( NIL )



FUNCTION H_Print( nRow1, nRow2, nCol, cChrTop, cChrCen, cChrBot, cColor )

   // Imprime uma linha vertical em video podendo ser parametrizado
   // o caracter inicial, final e de meio da linha.

   LOCAL nRow

   vDef( @cChrTop, "≥" )
   vDef( @cChrCen, "≥" )
   vDef( @cChrBot, "≥" )
   vDef( @cColor , SetColor() )

   @ nRow1,nCol SAY cChrTop COLOR cColor

   FOR nRow := nRow1 + 1 TO nRow2 - 1
      @ nRow, nCol SAY cChrCen COLOR cColor
   NEXT

   @ nRow2,nCol SAY cChrBot COLOR cColor

RETURN( NIL )



FUNCTION Pointer( nRow1, nRow2, nCol, nPointer, cDefColor )

   LOCAL aPos    := SavePos()
   LOCAL nCursor := SetCursor(0)
   LOCAL cColor

   IF cDefColor <> NIL
      cColor := SetColor( cDefColor )
   ENDIF

   @ nRow1, nCol SAY If( nPointer = 1, Chr(10), Chr(24) )
   @ nRow2, nCol SAY If( nPointer = 2, Chr(10), Chr(25) )

   SetColor( cColor )
   SetCursor( nCursor )

   RestPos( aPos )

RETURN( NIL )



FUNCTION Shadow( nRow1, nCol1, nRow2, nCol2, nCor )

   LOCAL ShadowC := SaveScreen( nRow1 + 1, nCol2 + 1, nRow2 + 1, nCol2 + 1 )
   LOCAL ShadowL := SaveScreen( nRow2 + 1, nCol1 + 1, nRow2 + 1, nCol2 + 1 )

   vDef( @nCor, 8 )

   RestScreen( nRow1 + 1, nCol2 + 1, nRow2 + 1, nCol2 + 1, Tran( ShadowC, Repl( "X" + Chr( nCor ), Len( ShadowC ) ) ) )
   RestScreen( nRow2 + 1, nCol1 + 1, nRow2 + 1, nCol2 + 1, Tran( ShadowL, Repl( "X" + Chr( nCor ), Len( ShadowL ) ) ) )

RETURN( NIL )



FUNCTION BackGround( nL1, nC1, nL2, nC2, nCor )

   LOCAL cBackGround

   vDef( @nL1, 01          )
   vDef( @nC1, 00          )
   vDef( @nL2, MaxRow() -1 )
   vDef( @nC2, 79          )

   vDef( @nCor, If( IsDef( "CFIFUNCTR" ), CFIFUNCTR, 8 ) )

   cBackGround := SaveScreen( nL1, nC1, nL2, nC2 )

   RestScreen( nL1, nC1, nL2, nC2, Trans( cBackGround, Repl( "X" + Chr( nCor ), Len( cBackGround ) ) ) )

RETURN( NIL )



FUNCTION Say( nRow, nCol, cString, cChrColor, cStrColor )

   LOCAL cDevice, cStrAux, nPosBeg, nPosEnd, nCount, aString

   #ifdef MINIGUI_MODE

      IF IsDef( "CS_MINIGUI" ) .AND. CS_MINIGUI

         IF nRow = 24
            RETURN( csStatus( CharRemove( StrTran( cString, "^", "" ) ) ) )
         ENDIF

      ENDIF

   #endif

   vDef( @cChrColor, SetColor() )
   vDef( @cStrColor, SetColor() )

   cDevice := Set( _SET_DEVICE, "SCREEN" )
   aString := {}

   DO WHILE Len( cString ) > 0

      cStrAux := Left( cString, GetNoEmpty( AtNum( "^", cString, 3 ), Len( cString ) +1 ) -1 )
      cString := Subs( cString, Len( cStrAux ) +1 )

      aAdd( aString, cStrAux )

   ENDDO

   SetPos( nRow, nCol )

   FOR nCount := 1 TO Len( aString )

      cString := aString[ nCount ]

      nPosBeg := At ( "^", cString )
      nPosEnd := Rat( "^", cString )

      IF nPosBeg > 0 .AND. ( nPosBeg <> nPosEnd )

         @ Row(), Col() SAY Subs( cString, 1, nPosBeg - 1 )                     COLOR cStrColor
         @ Row(), Col() SAY Subs( cString, nPosBeg + 1, nPosEnd - nPosBeg - 1 ) COLOR cChrColor
         @ Row(), Col() SAY Subs( cString, nPosEnd + 1 )                        COLOR cStrColor

      ELSEIF nPosBeg > 0 .AND. ( nPosBeg = nPosEnd )

         @ Row(), Col() SAY Subs( cString, 1, nPosBeg - 1 ) COLOR cStrColor
         @ Row(), Col() SAY Subs( cString, nPosBeg + 1 )    COLOR cChrColor

      ELSE

         @ Row(), Col() SAY cString COLOR cStrColor

      ENDIF

   NEXT

   IF cDevice <> "SCREEN"
      Set( _SET_DEVICE, cDevice )
   ENDIF

RETURN( .T. )



FUNCTION MDisp( nRow, nCol, cOption, aMatKeyOptions, aMatOptions, lMenu, nLenSay, cColor )

   LOCAL lReturn := .F.
   LOCAL aPos    := SavePos()
   LOCAL aMenu   := {}
   LOCAL lLeft   := ( aMatOptions = NIL )
   LOCAL nOption := aScan( aMatKeyOptions, { |x| Left( x, 1 ) = cOption .OR. ( At( "˙", x ) > 2 .AND. Left( x, At( "˙", x ) -1 ) = cOption ) } )
   LOCAL nLenOpc := 0
   LOCAL nLenRet := 1

   LOCAL nRowIni, nColIni, nItens, cRestScreen, cDefOption, nAux

   vDef( @aMatOptions, aMatKeyOptions )

   aEVal( aMatOptions, { |x| nLenOpc := Max( nLenOpc, Len( x ) - If( At( "&", x ) = 0, 0, 1 ) ) } )

   vDef( @cColor , SlColor( SetColor(), 1 ) )
   vDef( @nLenSay, nLenOpc )
   vDef( @lMenu  , .F. )

   IF nOption > 0

      lReturn := .T.

   ELSEIF lMenu

      nRowIni := If( nRow + 2 + Len( aMatKeyOptions ) > 22, nRow - 3 - Len( aMatKeyOptions ), nRow )
      nColIni := If( nCol + 2 + nLenOpc               > 77, nCol - 3 - nLenOpc              , nCol )

      cRestScreen := SaveScreen( nRowIni + 1, nColIni, nRowIni + 2 + Len( aMatKeyOptions ), nColIni + 3 + nLenOpc )

      FOR nItens := 1 TO Len( aMatKeyOptions )
         cDefOption := aMatOptions[ nItens ]
         cDefOption := PadR( cDefOption, Max( nLenOpc, Len( cDefOption ) ) ) + " "
         nAux := At( "˙", cDefOption )
         IF At( "&", cDefOption ) = 0 .AND. nAux < 3
            cDefOption := "&" + cDefOption
         ENDIF
         IF nAux > 2
            nLenRet := nAux - 1
         ENDIF
         mxPrompt( nRowIni + 1 + nItens, nColIni + 1, " " + cDefOption, @aMenu )
      NEXT

      Limpa( nRowIni + 1, nColIni, nRowIni + 2 + Len( aMatKeyOptions ), nColIni + 3 + nLenOpc, "s", NIL, "0/7" )

      mxMenuRead( @nOption, aMenu, "7/0", "0/7", "15/0", "15/7" )

      RestScreen( nRowIni + 1, nColIni, nRowIni + 2 + Len( aMatKeyOptions ), nColIni + 3 + nLenOpc, cRestScreen )

      IF nOption > 0

         IF lLeft
            cOption := Left( aMatKeyOptions[ nOption ], nLenRet )
         ELSE
            cOption := AllTrim( aMatKeyOptions[ nOption ] )
         ENDIF

         lReturn := .T.

      ENDIF

   ENDIF

   IF lReturn
      @ nRow, nCol ;
        SAY   PadR( StrTran( aMatOptions[ nOption ], "&", "" ), nLenSay ) ;
        COLOR cColor
   ELSE
      @ nRow, nCol +1 ;
        SAY   Space( nLenSay -1 ) ;
        COLOR cColor
   ENDIF

   RestPos( aPos )

RETURN( lReturn )



FUNCTION C_Cores()

   LOCAL cColor := SetColor()
   LOCAL OPCCOR := 1
   LOCAL OPCCO2 := 1
   LOCAL OPCCO3 := 1
   LOCAL aPrompt

   ScreenSave()

   Muda_COR( 01, 00, 23, 79, CFIFUNCTR )
   Shadow( 05, 26, 13, 52 )
   Limpa( 06, 26, 13, 52, "s", NIL, "9/15" )

   @ 05,26 SAY  "        Configurar         " COLOR "15/4"
   @ 10,27 SAY Repl( "ƒ", 25 )                COLOR "9/15"

   DO WHILE .T.

      aPrompt := {}

      mxPrompt( 07, 27, " &1˙Cor da tela de fundo  ", aPrompt )
      mxPrompt( 08, 27, " &2˙Listas de manutenáÑo  ", aPrompt )
      mxPrompt( 09, 27, " &3˙Janelas de manutenáÑo ", aPrompt )
      mxPrompt( 11, 27, " &4˙Monocrom†tico         ", aPrompt )
      mxPrompt( 12, 27, " &5˙Color                 ", aPrompt )

      mxMenuRead( @OPCCOR, aPrompt, "15/1", "8/15", "12/1", "12/15", "8/15" )

      IF ESC
         EXIT
      ENDIF

      IF OPCCOR = 1

         FUNCTR := ExibCores( FUNCTR, CFIFUNCTR )
         CLEAR GETS

      ELSEIF OPCCOR = 2

         ScreenSave()
         Muda_COR( 01, 00, 23, 79, CFIFUNCTR )
         @ 08,26 SAY "         Configurar         " COLOR "15/4"
         Limpa( 09, 26, 13, 53, "S", NIL, "9/15" )

         DO WHILE .T.

            aPrompt := {}

            mxPrompt( 10, 27, " &1˙Contorno reg. inativos ", aPrompt )
            mxPrompt( 11, 27, " &2˙Barra do reg. ativo    ", aPrompt )
            mxPrompt( 12, 27, " &3˙Cabeáalho              ", aPrompt )

            IF mxMenuRead( @OPCCO2, aPrompt, "15/1", "8/15", "12/1", "12/15", "8/15" ) = 0
               EXIT
            ELSEIF OPCCO2 = 1
               CO5CTR := Config_Cor( CO5CTR, { || MQuadro(4) } )
            ELSEIF OPCCO2 = 3
               CO6CTR := Config_Cor( CO6CTR, { || MQuadro(5) } )
            ELSE
               CO7CTR := Config_Cor( CO7CTR, { || MQuadro(6) } )
            ENDIF

         ENDDO

         CLEAR GETS
         ScreenRest()

      ELSEIF OPCCOR = 3

         ScreenSave()
         Muda_COR( 01, 00, 23, 79, CFIFUNCTR )
         @ 08,28 SAY  "      Configurar       " COLOR "15/4"
         Limpa( 09, 28, 13, 50, "S", NIL, "9/15" )

         DO WHILE .T.

            aPrompt := {}

            mxPrompt( 10, 29, " &1˙T°tulos           ", aPrompt )
            mxPrompt( 11, 29, " &2˙DigitaáÑo ativa   ", aPrompt )
            mxPrompt( 12, 29, " &3˙DigitaáÑo inativa ", aPrompt )

            IF mxMenuRead( @OPCCO3, aPrompt, "15/1", "8/15", "12/1", "12/15", "8/15" ) = 0
               EXIT
            ELSEIF OPCCO3 = 1
               CO1CTR := Config_Cor( CO1CTR, { || MQuadro(1) } )
            ELSEIF OPCCO3 = 2
               CO3CTR := Config_Cor( CO3CTR, { || MQuadro(2) } )
            ELSE
               CO4CTR := Config_Cor( CO4CTR, { || MQuadro(3) } )
               CO2CTR := CO4CTR
            ENDIF
         ENDDO

         CLEAR GETS
         ScreenRest()

      ELSEIF OPCCOR > 3

         CO1CTR := "9/15"
         IF OPCCOR = 4
            CO2CTR := "0/15"
            CO3CTR := "15/0"
            CO4CTR := "0/15"
            CO5CTR := "15/0"
            CO6CTR := "0/15"
            CO7CTR := "0/7"
         ELSE
            CO2CTR := "4/15"
            CO3CTR := "1/7"
            CO4CTR := "4/15"
            CO5CTR := "15/1"
            CO6CTR := "11/1"
            CO7CTR := "1/7"
         ENDIF
         FUNCTR := 137
         EXIT

      ENDIF

   ENDDO

   SetColor( cColor )
   ScreenRest()

RETURN( .T. )



FUNCTION Config_Cor( NOM_COR, NPROCED )

   LOCAL aState := SaveState( NIL, {} )

   LOCAL nCount

   PRIV LAST_OPC_COR := Val( Subs( NOM_COR, 1, AT( "/", NOM_COR ) -1 ) ) +1
   PRIV LAST_OPC_FUN := Val( Subs( NOM_COR,    AT( "/", NOM_COR ) +1 ) ) +1
   PRIV COR_BOR      := Subs( NOM_COR, 1, AT( "/", NOM_COR ) -1 )
   PRIV COR_FUN      := Subs( NOM_COR,    AT( "/", NOM_COR ) +1 )
   PRIV COR_TEL      := NOM_COR
   PRIV VPROCED      := NPROCED
   PRIV OPCCOR       := 1
   PRIV aBarCor      := {}
   PRIV aNomCor      := {}

   aAdd( aBarCor,  "0" )
   aAdd( aBarCor,  "1" )
   aAdd( aBarCor,  "2" )
   aAdd( aBarCor,  "3" )
   aAdd( aBarCor,  "4" )
   aAdd( aBarCor,  "5" )
   aAdd( aBarCor,  "6" )
   aAdd( aBarCor,  "7" )
   aAdd( aBarCor,  "8" )
   aAdd( aBarCor,  "9" )
   aAdd( aBarCor, "10" )
   aAdd( aBarCor, "11" )
   aAdd( aBarCor, "12" )
   aAdd( aBarCor, "13" )
   aAdd( aBarCor, "14" )
   aAdd( aBarCor, "15" )

   aAdd( aNomCor, "preto"            )
   aAdd( aNomCor, "azul"             )
   aAdd( aNomCor, "verde"            )
   aAdd( aNomCor, "ciano"            )
   aAdd( aNomCor, "vermelho"         )
   aAdd( aNomCor, "magenta"          )
   aAdd( aNomCor, "marron"           )
   aAdd( aNomCor, "branco"           )
   aAdd( aNomCor, "cinza"            )
   aAdd( aNomCor, "azul intenso"     )
   aAdd( aNomCor, "verde intenso"    )
   aAdd( aNomCor, "ciano intenso"    )
   aAdd( aNomCor, "vermelho intenso" )
   aAdd( aNomCor, "magenta intenso"  )
   aAdd( aNomCor, "amarelo"          )
   aAdd( aNomCor, "branco intenso"   )

   SetColor( "0/7" )

   @ 01,00,23,79 BOX "⁄ƒø≥Ÿƒ¿≥ "
   @ 03,00 TO 23,29
   @ 03,00 SAY "√" + Repl( "ƒ", 78 ) + "¥"
   @ 03,29 SAY "¬"
   @ 23,29 SAY "¡"
   @ 05,03 TO 22,13   // BARRA 1
   @ 05,16 TO 22,26   // BARRA 2
   @ 05,34 TO 07,53   // QUADRO 1
   @ 05,54 TO 07,73   // QUADRO 2
   @ 02,01 SAY PadC( "ConfiguraáÑo de Cores", 78 ) COLOR "9/7"
   @ 04,04 SAY "Conte£do"                          COLOR "15/7"
   @ 04,17 SAY "Fundo"                             COLOR "15/7"
   @ 04,35 SAY "Conte£do"                          COLOR "15/7"
   @ 04,55 SAY "Fundo"                             COLOR "15/7"
   @ 06,55 SAY PadC( aNomCor[ LAST_OPC_FUN ], 18 )
   @ 06,12,21,12 BOX "         " COLOR "15/0"
   @ 06,25,21,25 BOX "         " COLOR "15/0"

   FOR nCount := 0 TO 15

      @ 06 + nCount,04 SAY "€€€€€€€" COLOR NumToStr( nCount ) + "/0"
      @ 06 + nCount,17 SAY "€€€€€€€" COLOR NumToStr( nCount ) + "/0"

   NEXT

   Status( "ESC˙Retorna" ) ; SetColor( "0/0,15/0,,,0/0" )

   DO WHILE .T.

      KEYB Chr( K_SPACE )

      PRIV V_DEFIN := {}

      FOR nCount := 1 TO 16
         aAdd( V_DEFIN, Chr(17) )
      NEXT
      aChoice( 06, If( OPCCOR = 1, 12, 25 ), 21, If( OPCCOR = 1, 12, 25 ), V_DEFIN, .T., "M_FUNC", If( OPCCOR = 1, LAST_OPC_COR, LAST_OPC_FUN ) )
      IF ( ESC .OR. ENTER )
         EXIT
      ENDIF

      OPCCOR := If( OPCCOR = 1, 2, 1 )

   ENDDO

   RestState( aState, .F., .F., .T., .T. )

RETURN( COR_TEL )



FUNCTION M_Func( nMode, nPointer )

   LOCAL nReturn := 2

   IF ESC .OR. mxIn( LastKey(), { K_LEFT, K_RIGHT } )
      nReturn := 0
   ELSEIF ENTER
      nReturn := 1
   ELSEIF nMode = 1
      KEYB Chr( K_CTRL_PGDN )
   ELSEIF nMode = 2
      KEYB Chr( K_CTRL_PGUP )
   ENDIF
   IF OPCCOR = 1
      COR_BOR := aBarCor[ LAST_OPC_COR := nPointer ]
   ELSE
      COR_FUN := aBarCor[ LAST_OPC_FUN := nPointer ]
   ENDIF
   IF ! ESC .AND. ! ENTER .AND. ! mxIn( LastKey(), { K_LEFT, K_RIGHT } )
      COR_TEL := COR_BOR + "/" + COR_FUN
      @ 06, If( OPCCOR = 1, 35, 55 ) SAY PadC( aNomCor[ nPointer ], 18 ) COLOR "0/7"
   ENDIF
   EVal( VPROCED )
   SetColor("0/0,15/0,,,0/0")

RETURN( nReturn )



STATIC FUNCTION MQuadro( nTela )

   DO CASE
      CASE nTela = 1

           @ 12,42 SAY "        AAAAAAAA        " COLOR "15/1"
           @ 13,42,18,65 BOX "         "          COLOR COR_TEL
           @ 14,44 SAY "Aaaaaaa Ø"                COLOR COR_TEL
           @ 16,44 SAY "Bbbbbbb :"                COLOR COR_TEL
           @ 17,44 SAY "Ccccccc :"                COLOR COR_TEL
           @ 14,54 SAY "XXXXXXXXX"                COLOR CO3CTR
           @ 16,54 SAY "YYYYYYYYY"                COLOR CO4CTR
           @ 17,54 SAY "WWWWWWWWW"                COLOR CO4CTR

      CASE nTela = 2

           @ 12,42 SAY "        AAAAAAAA        " COLOR "15/1"
           @ 13,42,18,65 BOX "         "          COLOR CO1CTR
           @ 14,44 SAY "Aaaaaaa Ø"                COLOR CO1CTR
           @ 16,44 SAY "Bbbbbbb :"                COLOR CO1CTR
           @ 17,44 SAY "Ccccccc :"                COLOR CO1CTR
           @ 14,54 SAY "XXXXXXXXX"                COLOR COR_TEL
           @ 16,54 SAY "YYYYYYYYY"                COLOR CO4CTR
           @ 17,54 SAY "WWWWWWWWW"                COLOR CO4CTR

      CASE nTela = 3

           @ 12,42 SAY "        AAAAAAAA        " COLOR "15/1"
           @ 13,42,18,65 BOX "         "          COLOR CO1CTR
           @ 14,44 SAY "Aaaaaaa Ø"                COLOR CO1CTR
           @ 16,44 SAY "Bbbbbbb :"                COLOR CO1CTR
           @ 17,44 SAY "Ccccccc :"                COLOR CO1CTR
           @ 14,54 SAY "XXXXXXXXX"                COLOR CO3CTR
           @ 16,54 SAY "YYYYYYYYY"                COLOR COR_TEL
           @ 17,54 SAY "WWWWWWWWW"                COLOR COR_TEL

      CASE nTela = 4

           Limpa( 13,42,19,65, "SB", " AAAAAA ", COR_TEL )
           @ 14,43 SAY "˙˙Aaa˙˙≥˙˙Bbbb˙˙≥˙Ccc˙" COLOR CO6CTR
           @ 15,43 SAY "ÏÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÿÏÕÕÕÕ" COLOR COR_TEL
           @ 14,42 SAY "≥"                      COLOR COR_TEL
           @ 14,65 SAY "≥"                      COLOR COR_TEL
           @ 15,42 SAY "∆"                      COLOR COR_TEL
           @ 15,65 SAY "µ"                      COLOR COR_TEL
           @ 16,43 SAY "XXXXXXX≥Xxxxxxxx≥XXXXX" COLOR CO7CTR
           @ 17,43 SAY "WWWWWWW≥Wwwwwwww≥WWWWW" COLOR COR_TEL
           @ 18,43 SAY "YYYYYYY≥Yyyyyyyy≥YYYYY" COLOR COR_TEL

      CASE nTela = 5

           Limpa( 13,42,19,65, "SB", " AAAAAA ", CO5CTR )
           @ 14,43 SAY "˙˙Aaa˙˙≥˙˙Bbbb˙˙≥˙Ccc˙" COLOR COR_TEL
           @ 15,43 SAY "ÏÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÿÏÕÕÕÕ" COLOR CO5CTR
           @ 14,42 SAY "≥"                      COLOR CO5CTR
           @ 14,65 SAY "≥"                      COLOR CO5CTR
           @ 15,42 SAY "∆"                      COLOR CO5CTR
           @ 15,65 SAY "µ"                      COLOR CO5CTR
           @ 16,43 SAY "XXXXXXX≥Xxxxxxxx≥XXXXX" COLOR CO7CTR
           @ 17,43 SAY "WWWWWWW≥Wwwwwwww≥WWWWW" COLOR CO5CTR
           @ 18,43 SAY "YYYYYYY≥Yyyyyyyy≥YYYYY" COLOR CO5CTR

      CASE nTela = 6

           Limpa( 13,42,19,65, "SB", " AAAAAA ", CO5CTR )
           @ 14,43 SAY "˙˙Aaa˙˙≥˙˙Bbbb˙˙≥˙Ccc˙" COLOR CO6CTR
           @ 15,43 SAY "ÏÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÿÏÕÕÕÕ" COLOR CO5CTR
           @ 14,42 SAY "≥"                      COLOR CO5CTR
           @ 14,65 SAY "≥"                      COLOR CO5CTR
           @ 15,42 SAY "∆"                      COLOR CO5CTR
           @ 15,65 SAY "µ"                      COLOR CO5CTR
           @ 16,43 SAY "XXXXXXX≥Xxxxxxxx≥XXXXX" COLOR COR_TEL
           @ 17,43 SAY "WWWWWWW≥Wwwwwwww≥WWWWW" COLOR CO5CTR
           @ 18,43 SAY "YYYYYYY≥Yyyyyyyy≥YYYYY" COLOR CO5CTR

   ENDCASE

RETURN( NIL )



FUNCTION V_Cores_Config( cVar )

   LOCAL cColor := "Configurado  "

   LOCAL lIgual, nTab, nCor

   LOCAL aTabCor := { ;        // Mono    Color
                      { "CO1CTR", "9/15", "9/15" },;
                      { "CO2CTR", "0/15", "4/15" },;
                      { "CO3CTR", "15/0", "1/7"  },;
                      { "CO4CTR", "0/15", "4/15" },;
                      { "CO5CTR", "15/0", "15/1" },;
                      { "CO6CTR", "0/15", "11/1" },;
                      { "CO7CTR", "0/7" , "1/7"  },;
                      { "FUNCTR", 137   , 137    } ;
                    }

   cVar := If( cVar = NIL, "", "CFI" )

   FOR nTab := 2 TO 3

      lIgual := .T.

      FOR nCor := 1 TO Len( aTabCor )
         IF &( cVar + aTabCor[ nCor, 1 ] ) <> aTabCor[ nCor, nTab ]
            lIgual := .F.
         ENDIF
      NEXT

      IF lIgual
         cColor := If( nTab = 2, "Monocrom†tico", "Normal       " )
      ENDIF

   NEXT

RETURN( cColor )



FUNCTION ExibCores( nCorAtual, cCorFundo )

   LOCAL GetList   := {}
   LOCAL aState    := SaveState( NIL, {} )
   LOCAL nCorDigit := nCorAtual
   LOCAL nCor      := 0

   LOCAL nCorFun, nCorChr, cCor

   Muda_COR( 01, 00, MaxRow() - 1, 79, cCorFundo )
   SetColor( "0/7" )
   Limpa(02, 06, 21, 72, "S")
   @ 19,06 SAY "√" + Repl("ƒ", 65) + "¥"
   @ 02,35 SAY Chr(17) + " CORES " + Chr(16)

   FOR nCorFun := 0 TO 15
      SetPos( nCorFun + 3, 7 )
      FOR nCorChr := 0 TO 15
         cCor := NumToStr( nCorChr ) + "/" + NumToStr( nCorFun )
         @ nCorFun + 3,col() SAY Str( nCor ++, 4 ) + If( nCorChr = 15, " ", "" ) COLOR cCor
      NEXT
   NEXT

   SetColor( "0/7,0/7,,,0/7" )

   @ 20,08 SAY "N£mero da cor de fundo Ø" GET nCorDigit Pict "[ 999 ]" Valid nCorDigit>=0 .AND. nCorDigit<=255
   READ

   RestState( aState, .F., .F., .T., .T. )

RETURN( If( LastKey() = K_ESC, nCorAtual, nCorDigit ) )



FUNCTION mxWait( cMsg, nDefFrq, nColor, nLin, nCol, nLen, lMsgAguarde )
   
   LOCAL cChr, cDevice, cColor1, cColor2

   vDef( @nDefFrq    , 20  )
   vDef( @lMsgAguarde, .T. )

   IF lMsgAguarde .AND. ! "AGUARDE" $ Upper( cMsg )
      cMsg := AllTrim( cMsg )
      cMsg := "Aguarde, " + Lower( Left( cMsg, 1 ) ) + Subs( cMsg, 2 )
   ENDIF

   IF ! "..." $ Upper( cMsg )
      cMsg += "..."
   ENDIF

   #ifdef MINIGUI_MODE

      IF IsDef( "CS_MINIGUI" ) .AND. CS_MINIGUI
         RETURN( csStatus( CharRemove( cMsg ) ) )
      ENDIF

   #endif

   cChr := " "

   IF nPosGira > ( nDefFrq * 3 )
      nPosGira := 0
   ENDIF

   DO CASE
      CASE nPosGira = 0           ; cChr := "\"
      CASE nPosGira = nDefFrq     ; cChr := "|"
      CASE nPosGira = nDefFrq * 2 ; cChr := "/"
      CASE nPosGira = nDefFrq * 3 ; cChr := "ƒ"
      OTHERWISE                   ; cChr := cDispGira
   ENDCASE

   IF ( Left( cChr, 1 ) + cMsg ) <> cDispGira

      cChr := Left( cChr, 1 )

      IF nPosGira = 0
         SetCursor( 0 )
      ENDIF

      vDef( @nColor, 1 )
      vDef( @nLin  , MaxRow() )
      vDef( @nCol  , 00 )
      vDef( @nLen  , 80 )

      cDevice := Set( _SET_DEVICE, "SCREEN" )

      DO CASE
         CASE nColor = 1 ; cColor1 := "0/7"     ; cColor2 := "15/7"
         CASE nColor = 2 ; cColor1 := "0/15"    ; cColor2 := "9/15"
         CASE nColor = 3 ; cColor1 := cInfoMSca ; cColor2 := cInfoMSca
      ENDCASE

      @ nLin,nCol    SAY " ("                   COLOR cColor1
      @ nLin,nCol +2 SAY cChr                   COLOR cColor2
      @ nLin,nCol +3 SAY ") "                   COLOR cColor1
      @ nLin,nCol +5 SAY PadR( cMsg, nLen - 5 ) COLOR cColor1

      Set( _SET_DEVICE, cDevice )

      cDispGira := cChr + cMsg

   ENDIF

   nPosGira := If( nPosGira = ( nDefFrq * 3 ), 0, nPosGira + 1 )

RETURN( .T. )



FUNCTION Disp_Word( nRow, nCol, cString, nAjusta, cColor, lNegrito )

   #define DISP_CHR Subs( cString, nChr, 1 )

   LOCAL cSaveCor := SetColor( cColor )

   LOCAL aChrUpper[ 26, 4 ]
   LOCAL aChrLower[ 26, 4 ]
   LOCAL aNum     [ 10, 4 ]
   LOCAL aSimbols [ 6, 4 ]
   LOCAL aDisplay [ 4 ]

   LOCAL nLinStr, nChr

   vDef( @lNegrito, .F. )

   cString := CharRemove( cString )

   aChrUpper[ 1, 1 ] := "…ÕÕª"
   aChrUpper[ 1, 2 ] := "∫  ∫"
   aChrUpper[ 1, 3 ] := "ÃÕÕπ"
   aChrUpper[ 1, 4 ] := "º  »"

   aChrUpper[ 2, 1 ] := "ÀÕª "
   aChrUpper[ 2, 2 ] := "ÃÕ ª"
   aChrUpper[ 2, 3 ] := "∫  ∫"
   aChrUpper[ 2, 4 ] := " ÕÕº"

   aChrUpper[ 3, 1 ] := "…ÕÕª"
   aChrUpper[ 3, 2 ] := "∫   "
   aChrUpper[ 3, 3 ] := "∫   "
   aChrUpper[ 3, 4 ] := "»ÕÕº"

   aChrUpper[ 4, 1 ] := "ÀÕÕª"
   aChrUpper[ 4, 2 ] := "∫  ∫"
   aChrUpper[ 4, 3 ] := "∫  ∫"
   aChrUpper[ 4, 4 ] := " ÕÕº"

   aChrUpper[ 5, 1 ] := "…ÕÕª"
   aChrUpper[ 5, 2 ] := "ÃÕ  "
   aChrUpper[ 5, 3 ] := "∫   "
   aChrUpper[ 5, 4 ] := "»ÕÕº"

   aChrUpper[ 6, 1 ] := "…ÕÕª"
   aChrUpper[ 6, 2 ] := "∫   "
   aChrUpper[ 6, 3 ] := "ÃÕ  "
   aChrUpper[ 6, 4 ] := "º   "

   aChrUpper[ 7, 1 ] := "…ÕÕª"
   aChrUpper[ 7, 2 ] := "∫   "
   aChrUpper[ 7, 3 ] := "∫ Õª"
   aChrUpper[ 7, 4 ] := "»ÕÕº"

   aChrUpper[ 8, 1 ] := "ª  …"
   aChrUpper[ 8, 2 ] := "∫  ∫"
   aChrUpper[ 8, 3 ] := "ÃÕÕπ"
   aChrUpper[ 8, 4 ] := "º  »"

   aChrUpper[ 9, 1 ] := "À"
   aChrUpper[ 9, 2 ] := "∫"
   aChrUpper[ 9, 3 ] := "∫"
   aChrUpper[ 9, 4 ] := " "

   aChrUpper[ 10, 1 ] := "  ÕÀ"
   aChrUpper[ 10, 2 ] := "   ∫"
   aChrUpper[ 10, 3 ] := "   ∫"
   aChrUpper[ 10, 4 ] := "»ÕÕº"

   aChrUpper[ 11, 1 ] := "ª … "
   aChrUpper[ 11, 2 ] := "ÃÕ ª"
   aChrUpper[ 11, 3 ] := "∫  ∫"
   aChrUpper[ 11, 4 ] := "º  »"

   aChrUpper[ 12, 1 ] := "ª   "
   aChrUpper[ 12, 2 ] := "∫   "
   aChrUpper[ 12, 3 ] := "∫   "
   aChrUpper[ 12, 4 ] := "»ÕÕº"

   aChrUpper[ 13, 1 ] := "ÀÕÀÕª"
   aChrUpper[ 13, 2 ] := "∫ ∫ ∫"
   aChrUpper[ 13, 3 ] := "∫ ∫ ∫"
   aChrUpper[ 13, 4 ] := "º   »"

   aChrUpper[ 14, 1 ] := "ÀÕÕª"
   aChrUpper[ 14, 2 ] := "∫  ∫"
   aChrUpper[ 14, 3 ] := "∫  ∫"
   aChrUpper[ 14, 4 ] := "º  »"

   aChrUpper[ 15, 1 ] := "…ÕÕª"
   aChrUpper[ 15, 2 ] := "∫  ∫"
   aChrUpper[ 15, 3 ] := "∫  ∫"
   aChrUpper[ 15, 4 ] := "»ÕÕº"

   aChrUpper[ 16, 1 ] := "…ÕÕª"
   aChrUpper[ 16, 2 ] := "∫  ∫"
   aChrUpper[ 16, 3 ] := "ÃÕÕº"
   aChrUpper[ 16, 4 ] := "º   "

   aChrUpper[ 17, 1 ] := "…ÕÕª "
   aChrUpper[ 17, 2 ] := "∫  ∫ "
   aChrUpper[ 17, 3 ] := "∫  Œª"
   aChrUpper[ 17, 4 ] := "»ÕÕº»"

   aChrUpper[ 18, 1 ] := "…ÕÕª"
   aChrUpper[ 18, 2 ] := "∫  ∫"
   aChrUpper[ 18, 3 ] := "ÃÕÀº"
   aChrUpper[ 18, 4 ] := "º »Õ"

   aChrUpper[ 19, 1 ] := "…ÕÕ "
   aChrUpper[ 19, 2 ] := "»ÕÕª"
   aChrUpper[ 19, 3 ] := "   ∫"
   aChrUpper[ 19, 4 ] := "»ÕÕº"

   aChrUpper[ 20, 1 ] := "…ÕÀÕª"
   aChrUpper[ 20, 2 ] := "  ∫  "
   aChrUpper[ 20, 3 ] := "  ∫  "
   aChrUpper[ 20, 4 ] := "     "

   aChrUpper[ 21, 1 ] := "ª  …"
   aChrUpper[ 21, 2 ] := "∫  ∫"
   aChrUpper[ 21, 3 ] := "∫  ∫"
   aChrUpper[ 21, 4 ] := "»ÕÕº"

   aChrUpper[ 22, 1 ] := "ª   …"
   aChrUpper[ 22, 2 ] := "∫   ∫"
   aChrUpper[ 22, 3 ] := "»ª …º"
   aChrUpper[ 22, 4 ] := " »Õº "

   aChrUpper[ 23, 1 ] := "ª   …"
   aChrUpper[ 23, 2 ] := "∫ ∫ ∫"
   aChrUpper[ 23, 3 ] := "∫ ∫ ∫"
   aChrUpper[ 23, 4 ] := "»Õ Õº"

   aChrUpper[ 24, 1 ] := "ª  …"
   aChrUpper[ 24, 2 ] := "»ª…º"
   aChrUpper[ 24, 3 ] := "…  ª"
   aChrUpper[ 24, 4 ] := "º  »"

   aChrUpper[ 25, 1 ] := "ª …"
   aChrUpper[ 25, 2 ] := "»Àº"
   aChrUpper[ 25, 3 ] := " ∫ "
   aChrUpper[ 25, 4 ] := "   "

   aChrUpper[ 26, 1 ] := "…ÕÕÕª"
   aChrUpper[ 26, 2 ] := "  …Õº"
   aChrUpper[ 26, 3 ] := "…Õº  "
   aChrUpper[ 26, 4 ] := "»ÕÕÕº"

   aChrLower[ 1, 1 ] := "   "
   aChrLower[ 1, 2 ] := "…Õª"
   aChrLower[ 1, 3 ] := "…Õπ"
   aChrLower[ 1, 4 ] := "»Õ "

   aChrLower[ 2, 1 ] := "   "
   aChrLower[ 2, 2 ] := "ÀÕª"
   aChrLower[ 2, 3 ] := "ÃÕπ"
   aChrLower[ 2, 4 ] := " Õº"

   aChrLower[ 3, 1 ] := "   "
   aChrLower[ 3, 2 ] := "…Õª"
   aChrLower[ 3, 3 ] := "∫  "
   aChrLower[ 3, 4 ] := "»Õº"

   aChrLower[ 4, 1 ] := "   "
   aChrLower[ 4, 2 ] := "ÀÕª"
   aChrLower[ 4, 3 ] := "∫ ∫"
   aChrLower[ 4, 4 ] := " Õº"

   aChrLower[ 5, 1 ] := "   "
   aChrLower[ 5, 2 ] := "…Õª"
   aChrLower[ 5, 3 ] := "ÃÕº"
   aChrLower[ 5, 4 ] := "»Õº"

   aChrLower[ 6, 1 ] := " …Õ"
   aChrLower[ 6, 2 ] := " ÃÕ"
   aChrLower[ 6, 3 ] := " ∫ "
   aChrLower[ 6, 4 ] := "Õº "

   aChrLower[ 7, 1 ] := "   "
   aChrLower[ 7, 2 ] := "…Õª"
   aChrLower[ 7, 3 ] := "∫Õª"
   aChrLower[ 7, 4 ] := "»Õº"

   aChrLower[ 8, 1 ] := "ª  "
   aChrLower[ 8, 2 ] := "ÃÕª"
   aChrLower[ 8, 3 ] := "∫ ∫"
   aChrLower[ 8, 4 ] := "º »"

   aChrLower[ 9, 1 ] := "˛"
   aChrLower[ 9, 2 ] := "ª"
   aChrLower[ 9, 3 ] := "∫"
   aChrLower[ 9, 4 ] := "»"

   aChrLower[ 10, 1 ] := "  ˛"
   aChrLower[ 10, 2 ] := "  ª"
   aChrLower[ 10, 3 ] := "  ∫"
   aChrLower[ 10, 4 ] := "»Õº"

   aChrLower[ 11, 1 ] := "ª   "
   aChrLower[ 11, 2 ] := "∫ … "
   aChrLower[ 11, 3 ] := "ÃÕ ª"
   aChrLower[ 11, 4 ] := "º  »"

   aChrLower[ 12, 1 ] := "ª "
   aChrLower[ 12, 2 ] := "∫ "
   aChrLower[ 12, 3 ] := "∫ "
   aChrLower[ 12, 4 ] := "»Õ"

   aChrLower[ 13, 1 ] := "     "
   aChrLower[ 13, 2 ] := "ÀÕÀÕª"
   aChrLower[ 13, 3 ] := "∫ ∫ ∫"
   aChrLower[ 13, 4 ] := "º   »"

   aChrLower[ 14, 1 ] := "   "
   aChrLower[ 14, 2 ] := "ÀÕª"
   aChrLower[ 14, 3 ] := "∫ ∫"
   aChrLower[ 14, 4 ] := "º »"

   aChrLower[ 15, 1 ] := "   "
   aChrLower[ 15, 2 ] := "…Õª"
   aChrLower[ 15, 3 ] := "∫ ∫"
   aChrLower[ 15, 4 ] := "»Õº"

   aChrLower[ 16, 1 ] := "   "
   aChrLower[ 16, 2 ] := "…Õª"
   aChrLower[ 16, 3 ] := "ÃÕº"
   aChrLower[ 16, 4 ] := "º  "

   aChrLower[ 17, 1 ] := "    "
   aChrLower[ 17, 2 ] := "…ÕÕª"
   aChrLower[ 17, 3 ] := "∫  ∫"
   aChrLower[ 17, 4 ] := "»ÕÀº"

   aChrLower[ 18, 1 ] := "   "
   aChrLower[ 18, 2 ] := "ÀÕª"
   aChrLower[ 18, 3 ] := "∫  "
   aChrLower[ 18, 4 ] := "º  "

   aChrLower[ 19, 1 ] := "   "
   aChrLower[ 19, 2 ] := "…Õª"
   aChrLower[ 19, 3 ] := "»Õª"
   aChrLower[ 19, 4 ] := "»Õº"

   aChrLower[ 20, 1 ] := " ª "
   aChrLower[ 20, 2 ] := "ÕŒÕ"
   aChrLower[ 20, 3 ] := " ∫ "
   aChrLower[ 20, 4 ] := " »Õ"

   aChrLower[ 21, 1 ] := "    "
   aChrLower[ 21, 2 ] := "ª  …"
   aChrLower[ 21, 3 ] := "∫  ∫"
   aChrLower[ 21, 4 ] := "»ÕÕº"

   aChrLower[ 22, 1 ] := "    "
   aChrLower[ 22, 2 ] := "ª  …"
   aChrLower[ 22, 3 ] := "∫ …º"
   aChrLower[ 22, 4 ] := "»Õº "

   aChrLower[ 23, 1 ] := "     "
   aChrLower[ 23, 2 ] := "ª   …"
   aChrLower[ 23, 3 ] := "∫ ∫ ∫"
   aChrLower[ 23, 4 ] := "»Õ Õº"

   aChrLower[ 24, 1 ] := "    "
   aChrLower[ 24, 2 ] := "Õª…Õ"
   aChrLower[ 24, 3 ] := "…  ª"
   aChrLower[ 24, 4 ] := "º  »"

   aChrLower[ 25, 1 ] := "   "
   aChrLower[ 25, 2 ] := "ª …"
   aChrLower[ 25, 3 ] := "»Õπ"
   aChrLower[ 25, 4 ] := "  »"

   aChrLower[ 26, 1 ] := "    "
   aChrLower[ 26, 2 ] := " ÕÕª"
   aChrLower[ 26, 3 ] := "…ÕÕº"
   aChrLower[ 26, 4 ] := " ÕÕº"

   aNum[ 01, 1 ] := If( ! lNegrito, "…ÕÕª", " €ﬂﬂ€" )
   aNum[ 01, 2 ] := If( ! lNegrito, "∫  ∫", " €  €" )
   aNum[ 01, 3 ] := If( ! lNegrito, "∫  ∫", " €  €" )
   aNum[ 01, 4 ] := If( ! lNegrito, "»ÕÕº", " €‹‹€" )

   aNum[ 02, 1 ] := If( ! lNegrito,  "Õª ", "  ﬂ€ " )
   aNum[ 02, 2 ] := If( ! lNegrito,  " ∫ ", "   € " )
   aNum[ 02, 3 ] := If( ! lNegrito,  " ∫ ", "   € " )
   aNum[ 02, 4 ] := If( ! lNegrito,  "Õ Õ", "  €€€" )

   aNum[ 03, 1 ] := If( ! lNegrito, " ÕÕª", "  ﬂﬂ€" )
   aNum[ 03, 2 ] := If( ! lNegrito, "…ÕÕº", " ‹‹‹€" )
   aNum[ 03, 3 ] := If( ! lNegrito, "∫   ", " €   " )
   aNum[ 03, 4 ] := If( ! lNegrito, "»ÕÕº", " €‹‹€" )

   aNum[ 04, 1 ] := If( ! lNegrito, "…ÕÕª", " €ﬂﬂ€" )
   aNum[ 04, 2 ] := If( ! lNegrito, "  Õπ", "   ‹€" )
   aNum[ 04, 3 ] := If( ! lNegrito, "   ∫", "    €" )
   aNum[ 04, 4 ] := If( ! lNegrito, "»ÕÕº", " €‹‹€" )

   aNum[ 05, 1 ] := If( ! lNegrito, "ª  …", " €  €" )
   aNum[ 05, 2 ] := If( ! lNegrito, "∫  ∫", " €‹‹€" )
   aNum[ 05, 3 ] := If( ! lNegrito, "»ÕÕπ", "    €" )
   aNum[ 05, 4 ] := If( ! lNegrito, "   »", "    €" )

   aNum[ 06, 1 ] := If( ! lNegrito, "…ÕÕ ", " €ﬂﬂ " )
   aNum[ 06, 2 ] := If( ! lNegrito, "»ÕÕª", " €‹‹‹" )
   aNum[ 06, 3 ] := If( ! lNegrito, "   ∫", "    €" )
   aNum[ 06, 4 ] := If( ! lNegrito, "»ÕÕº", " €‹‹€" )

   aNum[ 07, 1 ] := If( ! lNegrito, "…ÕÕ ", " €ﬂﬂ " )
   aNum[ 07, 2 ] := If( ! lNegrito, "ÃÕÕª", " €‹‹‹" )
   aNum[ 07, 3 ] := If( ! lNegrito, "∫  ∫", " €  €" )
   aNum[ 07, 4 ] := If( ! lNegrito, "»ÕÕº", " €‹‹€" )

   aNum[ 08, 1 ] := If( ! lNegrito, "…ÕÕª", " €ﬂﬂ€" )
   aNum[ 08, 2 ] := If( ! lNegrito, "   ∫", "    €" )
   aNum[ 08, 3 ] := If( ! lNegrito, "   ∫", "    €" )
   aNum[ 08, 4 ] := If( ! lNegrito, "   »", "    €" )

   aNum[ 09, 1 ] := If( ! lNegrito, "…ÕÕª", " €ﬂﬂ€" )
   aNum[ 09, 2 ] := If( ! lNegrito, "ÃÕÕπ", " €‹‹€" )
   aNum[ 09, 3 ] := If( ! lNegrito, "∫  ∫", " €  €" )
   aNum[ 09, 4 ] := If( ! lNegrito, "»ÕÕº", " €‹‹€" )

   aNum[ 10, 1 ] := If( ! lNegrito, "…ÕÕª", " €ﬂﬂ€" )
   aNum[ 10, 2 ] := If( ! lNegrito, "»ÕÕπ", " €‹‹€" )
   aNum[ 10, 3 ] := If( ! lNegrito, "   ∫", "    €" )
   aNum[ 10, 4 ] := If( ! lNegrito, "»ÕÕº", " €‹‹€" )

   aSimbols[ 1, 1 ] := " "
   aSimbols[ 1, 2 ] := "Õ"
   aSimbols[ 1, 3 ] := " "
   aSimbols[ 1, 4 ] := " "

   aSimbols[ 2, 1 ] := If( ! lNegrito, " ", "  " )
   aSimbols[ 2, 2 ] := If( ! lNegrito, " ", "  " )
   aSimbols[ 2, 3 ] := If( ! lNegrito, " ", "  " )
   aSimbols[ 2, 4 ] := If( ! lNegrito, "˛", " ‹" )

   aSimbols[ 3, 1 ] := If( ! lNegrito, " ","   " )
   aSimbols[ 3, 2 ] := If( ! lNegrito, " ","   " )
   aSimbols[ 3, 3 ] := If( ! lNegrito, " ","   " )
   aSimbols[ 3, 4 ] := If( ! lNegrito, "ﬁ"," ﬂ›" )

   aSimbols[ 4, 1 ] := " "
   aSimbols[ 4, 2 ] := "˛"
   aSimbols[ 4, 3 ] := "˛"
   aSimbols[ 4, 4 ] := " "

   aSimbols[ 5, 1 ] := "…ÕÕª"
   aSimbols[ 5, 2 ] := "   ∫"
   aSimbols[ 5, 3 ] := " …Õº"
   aSimbols[ 5, 4 ] := " ˛  "

   aSimbols[ 6, 1 ] := "∫"
   aSimbols[ 6, 2 ] := "∫"
   aSimbols[ 6, 3 ] := "∫"
   aSimbols[ 6, 4 ] := "˛"

   FOR nLinStr := 1 TO 4

      aDisplay[ nLinStr ] := ""

      SetPos( nRow-1+nLinStr, nCol )

      FOR nChr := 1 TO Len( cString )

         IF Empty( DISP_CHR )

            IF nAjusta = NIL
               ?? "   "
            ELSE
               aDisplay[ nLinStr ] += "   "
            ENDIF

         ELSEIF DISP_CHR = "-"

            IF nAjusta = NIL
               ?? aSimbols[ 1, nLinStr ]
            ELSE
               aDisplay[ nLinStr ] += aSimbols[ 1, nLinStr ]
            ENDIF

         ELSEIF DISP_CHR = "."

            IF nAjusta = NIL
               ?? aSimbols[ 2, nLinStr ]
            ELSE
               aDisplay[ nLinStr ] +=  aSimbols[ 2, nLinStr ]
            ENDIF

         ELSEIF DISP_CHR = ","

            IF nAjusta = NIL
               ?? aSimbols[ 3, nLinStr ]
            ELSE
               aDisplay[ nLinStr ] += aSimbols[ 3, nLinStr ]
            ENDIF

         ELSEIF DISP_CHR = ":"

            IF nAjusta = NIL
               ?? aSimbols[ 4, nLinStr ]
            ELSE
               aDisplay[ nLinStr ] += aSimbols[ 4, nLinStr ]
            ENDIF

         ELSEIF DISP_CHR = "?"

            IF nAjusta = NIL
               ?? aSimbols[ 5, nLinStr ]
            ELSE
               aDisplay[ nLinStr ] += aSimbols[ 5, nLinStr ]
            ENDIF

         ELSEIF DISP_CHR = "!"

            IF nAjusta = NIL
               ?? aSimbols[ 6, nLinStr ]
            ELSE
               aDisplay[ nLinStr ] += aSimbols[ 6, nLinStr ]
            ENDIF

         ELSEIF DISP_CHR $ '~`@#$%^&*()_+={}[]";/<>|\'

            IF nAjusta = NIL
               ?? " "
            ELSE
               aDisplay[ nLinStr ] += " "
            ENDIF

         ELSEIF DISP_CHR $ "0123456789"

            IF nAjusta = NIL
               ?? aNum[ Asc( DISP_CHR ) - 47, nLinStr ]
            ELSE
               aDisplay[ nLinStr ] += aNum[ Asc( DISP_CHR ) - 47, nLinStr ]
            ENDIF

         ELSEIF Upper( DISP_CHR ) = DISP_CHR

            IF nAjusta=NIL
               ?? aChrUpper[ Asc( DISP_CHR ) - 64, nLinStr ]
            ELSE
               aDisplay[ nLinStr ] += aChrUpper[ Asc( DISP_CHR ) - 64, nLinStr ]
            ENDIF

         ELSEIF nAjusta = NIL
            ?? aChrLower[ Asc( Upper( DISP_CHR ) ) - 64, nLinStr ]
         ELSE
            aDisplay[ nLinStr ] += aChrLower[ Asc( Upper( DISP_CHR ) ) - 64, nLinStr ]
         ENDIF
      NEXT
      IF nAjusta <> NIL
         @ nRow + nLinStr - 1,00 SAY If( nAjusta = 0, PadR( aDisplay[ nLinStr ], 80 ),;
                                     If( nAjusta = 1, PadC( aDisplay[ nLinStr ], 80 ),;
                                                      PadL( aDisplay[ nLinStr ], 79 ) ) )
      ENDIF
   NEXT

   SetColor( cSaveCor )

RETURN(NIL)



/*----------------------------------------------------------------------------
 Funcao que efetua a inversao dos atributos de cores
 Ex:
      Cor = "15/0"
      ? InverseColor(Cor), Cor     // Retorna 0/15 15/0
      ? InverseColor(@Cor), Cor    // Retorna 0/15 0/15/
----------------------------------------------------------------------------*/

FUNCTION InverseColor( cColor )

   vDef( @cColor, SetColor() )

   cColor := AllTrim( Subs( cColor, At( "/", cColor ) +1 ) ) + "/" + ;
             AllTrim( Left( cColor, At( "/", cColor ) -1 ) )

RETURN( cColor )



/*----------------------------------------------------------------------------
 Seleciona um par de cores de uma string de cores

 Parametros

 cColor : String de cores
 nSlCl  : Cor e ser extraida
          1 = Impressao em video (todas as exibicoes)
          2 = Selecao ativa      (para GETS e PROMPTS)
          3 = Selecao inativa    (para GETS e PROMTPS)

 Retorno : String com as cores.

 Exemplo (os retornos serao letras, mas o exemplo Ç em numeros de cores)

  ? SetColor( "15/0,0/7,,,12/0" )
  ? SlColor( SetColor(), 1 )   // "15/0" - cor para impressoes
  ? SlColor( SetColor(), 2 )   // "0/7"  - cor para gets e prompts ativos
  ? SlColor( SetColor(), 3 )   // "12/0" - cor para gets e prompts inativos
----------------------------------------------------------------------------*/

FUNCTION SlColor( cColor, nSlCl )

   LOCAL cReturn

   vDef( @cColor, SetColor() )

   DO CASE
      CASE nSlCl = 1
           cReturn := Subs( cColor, 1, At( ",", cColor ) - 1 )
      CASE nSlCl = 2
           cColor := Subs( cColor, At( ",", cColor ) + 1 )
           cReturn := Subs( cColor, 1, At( ",", cColor ) - 1 )
      OTHERWISE
           cReturn := Subs( cColor, Rat( ",", cColor ) + 1 )
   ENDCASE

RETURN( cReturn )



/*----------------------------------------------------------------------------
 Seleciona uma unidade de cor de um par de cores

 Parametros

 cColor : String de cores
 nSl    : Cor e ser extraida ( 1 - cor do caracter, 2 - cor de fundo )

 Retorno : Caracter com o numero da cor.
----------------------------------------------------------------------------*/

FUNCTION SlValColor( cColor, nSl )

   LOCAL cReturn

   IF nSl = 1
      cReturn := Subs( cColor, 1, At( "/", cColor ) - 1 )
   ELSE
      cReturn := Subs( cColor, Rat( "/", cColor ) + 1 )
   ENDIF

RETURN( cReturn )



/*----------------------------------------------------------------------------
 Converte uma string de cores em letras para seu formato em numeros.

 Parametros

 cCor : String com a cor para conversao.

 Retorno : String convertida.
----------------------------------------------------------------------------*/

FUNCTION ConvStrColor( cColor )

   LOCAL nCor1 := Val( NColor( SlValColor( cColor, 1 ) ) )
   LOCAL nCor2 := Val( NColor( SlValColor( cColor, 2 ) ) )

RETURN( ( nCor2 * 16 ) + nCor1 )



/*----------------------------------------------------------------------------
 Converte a letra da cor para o seu numero correspondente.

 Parametros

 cCor : Letra da cor.

 Retorno : Numero da cor.
----------------------------------------------------------------------------*/

FUNCTION NColor( cColor )

   LOCAL nCor
   LOCAL aColor := {  ;
                      { "N"  ,  "0" },;
                      { "B"  ,  "1" },;
                      { "G"  ,  "2" },;
                      { "BG" ,  "3" },;
                      { "R"  ,  "4" },;
                      { "BR" ,  "5" },;
                      { "GR" ,  "6" },;
                      { "W"  ,  "7" },;
                      { "N+" ,  "8" },;
                      { "N*" ,  "8" },;
                      { "B+" ,  "9" },;
                      { "B*" ,  "9" },;
                      { "G+" , "10" },;
                      { "G*" , "10" },;
                      { "BG+", "11" },;
                      { "BG*", "11" },;
                      { "R+" , "12" },;
                      { "R*" , "12" },;
                      { "BR+", "13" },;
                      { "BR*", "13" },;
                      { "GR+", "14" },;
                      { "GR*", "14" },;
                      { "W+" , "15" },;
                      { "W*" , "15" } ;
                    }
   IF ( nCor := aScan( aColor, { |c| c[1] = cColor } ) ) > 0
      RETURN( aColor[ nCor, 2 ] )
   ENDIF

RETURN( cColor )



FUNCTION Cria_Cor( cCorAtual )

   // Cria sequencia de numero de cores

   LOCAL cCor := NumToStr( If( Val( cCorAtual ) < 15, Val( cCorAtual ) +1, 0 ) )

RETURN( cCor )



FUNCTION ScreenSave()

   // Salvar tela na pilha

   aAdd( aScreen, { SaveScreen(), SavePos() } )

RETURN( .T. )



FUNCTION ScreenRest( lRest )

   // Retirar e restaurar tela da pilha

   vDef( @lRest, .T. )

   IF lRest
      ScreenDraw()
   ENDIF

   IF Len( aScreen ) > 0
      aDel( aScreen, Len( aScreen ) )
      aSize( aScreen, Len( aScreen ) -1 )
   ENDIF

RETURN( .T. )



FUNCTION ScreenDraw()

   // Restaurar tela da pilha

   IF Len( aScreen ) > 0
      RestScreen( ,,,, aScreen[ Len( aScreen ), 1 ] )
      RestPos( aScreen[ Len( aScreen ), 2 ] )
   ENDIF

RETURN( .T. )


/*----------------------------------------------------------------------------
 Converte uma string de cores para uma matriz.

 Parametros

 cColor : String com as cores que irao gerar a matriz.

 Retorno : Matriz com as cores separadas.
----------------------------------------------------------------------------*/

FUNCTION ColorTable( cColor )

   LOCAL aColor := {}
   LOCAL cColorAdd

   DO WHILE At( ",", cColor ) > 0

      cColorAdd := Left( cColor, At( ",", cColor ) )

      IF Right( cColorAdd, 1 ) = ","
         cColorAdd := Left( cColorAdd, Len( cColorAdd ) -1 )
      ENDIF

      aAdd( aColor, cColorAdd )

      cColor := Subs( cColor, At( ",", cColor ) + 1 )

   ENDDO

   aAdd( aColor, cColor )

RETURN( aColor )



FUNCTION ColorPush( cColor )

   // Salva a cor atual na pilha e seleciona uma nova.

   aAdd( aCores, SetColor( cColor ) )

RETURN( NIL )



FUNCTION ColorPop()

   // Restaura a cor anterior e retira da pilha.

   ColorSet()

   IF Len( aCores ) > 0
      aDel( aCores, Len( aCores ) )
      aSize( aCores, Len( aCores ) - 1 )
   ENDIF

RETURN( NIL )



FUNCTION ColorSet()

   // Restaura a ultima cor da pilha.

   IF Len( aCores ) > 0
      SetColor( aCores[ Len( aCores ) ] )
   ENDIF

RETURN( NIL )



/*----------------------------------------------------------------------------
 Exibe uma barra de progressao informando o percentual de avanco de um
 processo. A finalidade e a mesma da funcao Progress(), porem utilizando um
 metodo mais inteligente e bem organizado de controle de progressao.
 Esta divida em tres funcoes:

   prgsStart()   -> inicia o processo parametrizando o ambiente.
   prgsNext()    -> avanda o progressivo.
   prgsUpdate()  -> atualiza o progressivo em video.
   prgsRestore() -> restaura a tela anterior.

 Parametros:

 cTitle    : Titulo da barra de progressao.
 nDefTotal : Definicao do total de itens que devem ser contados.
             O default e o total de registros do arquivo.
 nType     : Se 1, grafico na barra de status.
             Se 2, grafico no meio da tela, com moldura.
----------------------------------------------------------------------------*/

FUNCTION prgsStart( uTitle, nDefTotal, nType, cColor )

   vDef( @cColor, "15/9" )

   IF nDefTotal = NIL
      nDefTotal := mxRecCount()  // Nao usar vDef().
   ENDIF

   vDef( @nType, 1 )

   IF ! lPrgsIsDef
      IF ValType( uTitle ) = "B"
         uPrgsTitle := uTitle
      ELSEIF ValType( uTitle ) = "A"
         uPrgsTitle := { AllTrim( uTitle[1] ), AllTrim( uTitle[2] ) }
      ELSE
         uPrgsTitle := AllTrim( uTitle )
      ENDIF
      nPrgsType := nType
   ENDIF

   nPrgsTotal := nDefTotal
   nPrgsPerce := -1
   nPrgsCount := 0

   prgsScreen( cColor )

RETURN( NIL )



PROCEDURE prgsDefTitle( uTitle, nType )

   IF uTitle = NIL
      lPrgsIsDef := .F.
      uPrgsTitle := NIL
      nPrgsType  := 1
   ELSE
      lPrgsIsDef := .T.
      uPrgsTitle := uTitle
      nPrgsType  := nType
   ENDIF

RETURN( NIL )



FUNCTION prgsNext( nPointer, cAutoStart, cColor )

   LOCAL nDefPercent, cDevice, nCursor

   vDef( @cAutoStart, "" )
   vDef( @cColor, "15/9" )

   IF ! Empty( cAutoStart ) .AND. nPointer = 1
      prgsStart( cAutoStart )
   ENDIF

   nDefPercent := Round( ( nPrgsCount := If( nPointer = NIL, nPrgsCount + 1, nPointer ) ) / nPrgsTotal * 100, 2 )

   IF nPrgsType = 2

      cDevice := Set( _SET_DEVICE, "SCREEN" )
      nCursor := SetCursor(0)

      IF ValType( uPrgsTitle ) = "B"
         @ 14,22 SAY "  " + PadR( Eval( uPrgsTitle ), 34 ) COLOR cColor
      ENDIF

      @ 16,22 SAY PadR( "  [" + LTrim( Tran( nPrgsCount, "@E 99,999,999,999" ) ) + "/" + LTrim( Tran( nPrgsTotal, "@E 99,999,999,999" ) ) + "]", 36 ) COLOR cColor

      Set( _SET_DEVICE, cDevice )
      SetCursor( nCursor )

   ENDIF

   IF nPrgsPerce <> nDefPercent

      prgsUpdate( nDefPercent, cColor )

      nPrgsPerce := nDefPercent

   ENDIF

RETURN( .T. )



STATIC FUNCTION prgsUpdate( nPercent, cColor )

   LOCAL cDevice := Set( _SET_DEVICE, "SCREEN" )
   LOCAL nCursor := SetCursor(0)

   DO CASE
      CASE nPrgsType = 1

           @ MaxRow(), nPrgsColumn SAY Tran( nPercent, "999.99% " )          COLOR "0/7"
           @ MaxRow(), Col()       SAY Repl( "˛",      Int( nPercent / 4 ) ) COLOR "15/7"
           @ MaxRow(), Col()       SAY Repl( "˛", 25 - Int( nPercent / 4 ) ) COLOR "1/7"

      CASE nPrgsType = 2

           @ 15,35 SAY Tran( nPercent, "999.99%" )             COLOR cColor
           @ 19,22 SAY Repl( "€", Int( 36 * nPercent / 100 ) ) COLOR "7/0"
           @ 20,22 SAY Repl( "€", Int( 36 * nPercent / 100 ) ) COLOR "7/0"

   ENDCASE

   SetCursor( nCursor )
   Set( _SET_DEVICE, cDevice )

RETURN( NIL )



STATIC FUNCTION prgsScreen( cColor )

   LOCAL cDevice := Set( _SET_DEVICE, "SCREEN" )
   LOCAL nCursor := SetCursor(0)
   LOCAL nLinIni := 10

   DO CASE
      CASE nPrgsType = 1

           IF ValType( uPrgsTitle ) = "A"
              uPrgsTitle := uPrgsTitle[1]
           ENDIF

           IF ValType( uPrgsTitle ) = "C"
              @ MaxRow(), 00 SAY  " " + uPrgsTitle + "... " COLOR "0/7"
           ENDIF

           nPrgsColumn := Col()

           @ MaxRow(), nPrgsColumn SAY "  0.00% "          COLOR "0/7"
           @ MaxRow(), Col()       SAY Repl( "˛", 25 )     COLOR "1/7"
           @ MaxRow(), Col()       SAY Space( 80 - Col() ) COLOR "0/7"

      CASE nPrgsType = 2

           IF ValType( uPrgsTitle ) <> "A"
              nLinIni ++
           ENDIF
 
           @ ++ nLinIni,20 SAY "€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€" COLOR "8/15"

           IF ValType( uPrgsTitle ) = "A"
              @ ++ nLinIni,20 SAY "€                                      €" COLOR "8/15"
           ENDIF

           @ ++ nLinIni,20 SAY "€                                      €" COLOR "8/15"
           @ ++ nLinIni,20 SAY "€                                      €" COLOR "8/15"
           @ ++ nLinIni,20 SAY "€                                      €" COLOR "8/15"
           @ ++ nLinIni,20 SAY "€                                      €" COLOR "8/15"
           @ ++ nLinIni,20 SAY "€                                      €" COLOR "8/15"
           @ ++ nLinIni,20 SAY "€ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ€" COLOR "8/15"
           @ ++ nLinIni,20 SAY "€                                      €" COLOR "8/15"
           @ ++ nLinIni,20 SAY "€                                      €" COLOR "8/15"
           @ ++ nLinIni,20 SAY "€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€" COLOR "8/15"

           @ 19,22 SAY "≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤" COLOR "7/0"
           @ 20,22 SAY "≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤" COLOR "7/0"

           IF ValType( uPrgsTitle ) = "A"
              @ 12,22 SAY Space(36)                        COLOR cColor
              @ 13,22 SAY "  " + PadR( uPrgsTitle[1], 34 ) COLOR cColor
              @ 14,22 SAY "  " + PadR( uPrgsTitle[2], 34 ) COLOR cColor
           ELSEIF ValType( uPrgsTitle ) = "C"
              @ 13,22 SAY Space(36)                     COLOR cColor
              @ 14,22 SAY "  " + PadR( uPrgsTitle, 34 ) COLOR cColor
           ENDIF

           @ 15,22 SAY "  Conclu°do:   0.00%                " COLOR cColor

           @ 16,22 SAY PadR( "  [0/" + LTrim( Tran( nPrgsTotal, "@E 999,999,999" ) ) + "]", 36 ) COLOR cColor

           @ 17,22 SAY Space(36) COLOR cColor

           Status( "" )

   ENDCASE

   SetCursor( nCursor )
   Set( _SET_DEVICE, cDevice )

RETURN( NIL )



FUNCTION CursorOff()

   aAdd( aSetCursor, SetCursor(0) )

RETURN( NIL )



FUNCTION CursorOn()

   IF Len( aSetCursor ) > 0
      SetCursor( aSetCursor[ Len( aSetCursor ) ] )
      aDel( aSetCursor, Len( aSetCursor ) )
      aSize( aSetCursor, Len( aSetCursor ) -1 )
   ENDIF

RETURN( NIL )



FUNCTION vSay( cString, nRow, nCol, nLen, cColor1, cColor2 )

   LOCAL cColor    := cColor1
   LOCAL nCountRow := 0

   LOCAL nCount

   FOR nCount := 1 TO Len( cString )

      IF Subs( cString, nCount, 1 ) = "^"
         IF cColor = cColor1
            cColor := cColor2
         ELSE
            cColor := cColor1
         ENDIF
         LOOP
      ENDIF

      @ nRow + ( nCountRow ++ ), nCol ;
        SAY   PadC( Subs( cString, nCount, 1 ), nLen ) ;
        COLOR cColor

   NEXT

RETURN( NIL )



FUNCTION DisplayOn()

   aAdd( aDisplaySet, { Set( _SET_DEVICE, "SCREEN" ), Set( _SET_CONSOLE, .T. ) } )

RETURN( NIL )



FUNCTION DisplayRestore()

   IF Len( aDisplaySet ) > 0
      Set( _SET_DEVICE , aDisplaySet[ Len( aDisplaySet ), 1 ] )
      Set( _SET_CONSOLE, aDisplaySet[ Len( aDisplaySet ), 2 ] )
      IF Len( aDisplaySet ) > 0
         aDel( aDisplaySet, Len( aDisplaySet ) )
         aSize( aDisplaySet, Len( aDisplaySet ) -1 )
      ENDIF
   ENDIF

RETURN( NIL )



FUNCTION SavePos()

RETURN( { Row(), Col() } )



FUNCTION RestPos( aPos )

   // Restaura a posicao salva por SavePos().

   SetPos( aPos[1], aPos[2] )

RETURN( NIL )



PROCEDURE TelaParametros( nPos, aTela, cTitulo, nConfig, lDestino, lValores, lRelatorio, lLoja, nTop )

   #define REL_TPOS_ESQ 1
   #define REL_TPOS_CEN 2
   #define REL_TPOS_DIR 3

   #define REL_PAR_DES 1
   #define REL_PAR_CAM 2
   #define REL_PAR_TRC 3

   LOCAL nDiv     := 0
   LOCAL nTamDesc := 0
   LOCAL nTamGet  := 0
   LOCAL nTamDiv  := 0
   LOCAL nTamGet1 := 0
   LOCAL lTraco   := .F.

   LOCAL nCount, nTam, nTamTotal, cParDesc, nDefLen, cColor1, cColor2, nRow, aAux

   LOCAL cColor3, cColor4, cGetColors, nTamAux, cTitAux, cTitCampo, nLenDes, cTipPar

   vDef( @nConfig   ,  1  )
   vDef( @nTop      ,  1  )
   vDef( @lDestino  , .F. )
   vDef( @lValores  , .F. )
   vDef( @lRelatorio, .F. )
   vDef( @lLoja     , .F. )
   
   nRow := nTop

   FOR nCount := 1 TO Len( aTela )

      IF ValType( aTela[ nCount, 1 ] ) = "C"

         cTipPar := Upper( AllTrim( aTela[ nCount, 1 ] ) )
         aAux    := {}

         DO CASE
            CASE cTipPar = "DAT"  ; aAux := { "Per°odo"               , { 10, "a"  } }
            CASE cTipPar = "DAT2" ; aAux := { "Per°odo ^(màs/ano)^"   , { 07, "a"  } }
            CASE cTipPar = "PRO"  ; aAux := { "Produtos"              , { 09, "ao" } }
            CASE cTipPar = "GRP"  ; aAux := { "Grupos dos produtos"   , { 05, "ao" } }
            CASE cTipPar = "EMB"  ; aAux := { "Embalagens"            , { 05, "a"  } }
            CASE cTipPar = "LOJ"  ; aAux := { "Lojas"                 , { 03, "a"  } }
            CASE cTipPar = "CLI"  ; aAux := { "Clientes"              , { 09, "ao" } }
            CASE cTipPar = "REP"  ; aAux := { "Representantes"        , { 05, "ao" } }
            CASE cTipPar = "FOR"  ; aAux := { "Fornecedores"          , { 05, "ao" } }
            CASE cTipPar = "DES"  ; aAux := { "Despesas"              , { 05, "a"  } }
            CASE cTipPar = "TRA"  ; aAux := { "Transportadoras"       , { 05, "a"  } }
            CASE cTipPar = "RAM"  ; aAux := { "Ramos de atividade"    , { 05, "ao" } }
            CASE cTipPar = "REG"  ; aAux := { "Regiîes"               , { 05, "a"  } }
            CASE cTipPar = "POR"  ; aAux := { "Portadores"            , { 05, "ao" } }
            CASE cTipPar = "MAQ"  ; aAux := { "M†quinas"              , { 05, "a"  } }
            CASE cTipPar = "CEP"  ; aAux := { "CEPs"                  , { 09, "ao" } }
            CASE cTipPar = "FAB"  ; aAux := { "Fabricantes"           , { 05, "ao" } }
            CASE cTipPar = "CPG"  ; aAux := { "Condiáîes de pagamento", { 03, "a"  } }
            CASE cTipPar = "LPR"  ; aAux := { "Lista de preáos"       , { 03, "a"  } }
         ENDCASE

         IF Len( aAux ) > 0
            IF Len( aTela[ nCount ] ) = 1
               aTela[ nCount ] := aClone( aAux )
            ELSE
               aTela[ nCount, 1 ] := aAux[1]
               IF Len( aTela[ nCount ] ) >= 2
                  aTela[ nCount, 2 ] := aAux[2]
               ENDIF
            ENDIF
         ENDIF
         
      ENDIF

   NEXT

   IF lLoja
      cTitCampo := "Lojas"
      IF aScan( aTela, { |x| x[ REL_PAR_DES ] = cTitCampo } ) = 0
         aTela := aInsert( aTela, { { cTitCampo, { 3, "a" } } }, 1 )
      ENDIF
   ENDIF

   IF lRelatorio
      cTitCampo := "Relat¢rio ^(Anal°tico/SintÇtico)^"
      IF aScan( aTela, { |x| x[ REL_PAR_DES ] = cTitCampo } ) = 0
         aAdd( aTela, { cTitCampo, 9 } )
      ENDIF
   ENDIF

   IF lValores
      cTitCampo := "Valores ^(Hist¢ricos/Indexados)^"
      IF aScan( aTela, { |x| x[ REL_PAR_DES ] = cTitCampo } ) = 0
         aAdd( aTela, { cTitCampo, 10 } )
      ENDIF
   ENDIF

   IF lDestino
      nLenDes   := 10
      cTitCampo := "Destino ^(V°deo/Impressora"
      IF IsDef( "DEFIMP" )
         nLenDes   := 27
         cTitCampo += "/Outros"
      ENDIF
      cTitCampo += ")^"
      IF aScan( aTela, { |x| x[ REL_PAR_DES ] = cTitCampo } ) = 0
         aAdd( aTela, { cTitCampo, nLenDes } )
      ENDIF
   ENDIF

   IF nConfig = 1
      cColor1    := "7/15"              // Cor dos contornos
      cColor2    := "1/15"              // Cor das descricoes dos parametros
      cColor3    := "15/4"              // Cor do titulo
      cColor4    := "9/15"              // Cor 2 das descricoes dos parametros
      cGetColors := "4/15,15/1,,,4/15"
   ELSE
      cColor1    := "9/15"              // Cor dos contornos
      cColor2    := "9/15"              // Cor das descricoes dos parametros
      cColor3    := "15/1"              // Cor do titulo
      cColor4    := "9/15"              // Cor 2 das descricoes dos parametros
      cGetColors := "1/15,15/1,,,1/15"
   ENDIF

   FOR nCount := 1 TO Len( aTela )

      IF ValType( aTela[ nCount, REL_PAR_DES ] ) = "A"

         nTamDesc := aTela[ nCount, REL_PAR_DES, 2 ]
         aTela[ nCount, REL_PAR_DES ] := aTela[ nCount, REL_PAR_DES, 1 ]

      ENDIF

      aTela[ nCount, REL_PAR_DES ] := RTrim( aTela[ nCount, REL_PAR_DES ] )

      cParDesc := StrTran( RTrim( aTela[ nCount, REL_PAR_DES ] ), "^", "" )

      IF Len( cParDesc ) > nTamDesc
         nTamDesc := Len( cParDesc )
      ENDIF

      IF ValType( aTela[ nCount, REL_PAR_CAM ] ) = "C"

         nTam := Len( aTela[ nCount, REL_PAR_CAM ] ) + 2

      ELSEIF ValType( aTela[ nCount, REL_PAR_CAM ] ) = "A"

         IF aTela[ nCount, REL_PAR_CAM, 1 ] = 0

            nTam := Len( aTela[ nCount, REL_PAR_CAM, 2 ] ) + 2

         ELSE

            IF Len( aTela[ nCount, REL_PAR_CAM, 2 ] ) > nTamDiv
               nTamDiv := Len( aTela[ nCount, REL_PAR_CAM, 2 ] )
            ENDIF

            IF aTela[ nCount, REL_PAR_CAM, 1 ] > nTamGet1
               nTamGet1 := aTela[ nCount, REL_PAR_CAM, 1 ]
            ENDIF

            nTam := ( nTamGet1 * 2 ) + 2 + nTamDiv

         ENDIF

      ELSE

         nTam := aTela[ nCount, REL_PAR_CAM ]

      ENDIF

      IF nTam > nTamGet
         nTamGet := nTam
      ENDIF

   NEXT

   nTamTotal := nTamDesc + 3 + nTamGet

   DO CASE
      CASE nPos = REL_TPOS_ESQ ; nCol := 1
      CASE nPos = REL_TPOS_CEN ; nCol := Int( ( 80 - ( nTamTotal + 2 ) ) / 2 )
      CASE nPos = REL_TPOS_DIR ; nCol := 78 - ( nTamTotal + 2 )
   ENDCASE

   BackGround()

   SetPos( nRow, nCol )

   IF nConfig = 1
      @ Row() +1, nCol SAY PadC( cTitulo, nTamTotal + 2 )                                     COLOR cColor3
      @ Row() +1, nCol SAY "⁄" + Repl( "ƒ", nTamDesc + 2 ) + "¬" + Repl( "ƒ", nTamGet ) + "ø" COLOR cColor1
   ELSE
      @ Row() +1, nCol SAY "⁄" + Repl( "ƒ", nTamTotal )                                 + "ø" COLOR cColor1

      @ Row() +1, nCol  SAY "≥"                        COLOR cColor1
      @ Row()   , Col() SAY PadC( cTitulo, nTamTotal ) COLOR cColor3
      @ Row()   , Col() SAY "≥"                        COLOR cColor1

      @ Row() +1, nCol SAY "√" + Repl( "ƒ", nTamDesc + 2 ) + "¬" + Repl( "ƒ", nTamGet ) + "¥" COLOR cColor1
   ENDIF

   SetPos( Row() +1, nCol )

   FOR nCount := 1 TO Len( aTela )

      cTitAux := aTela[ nCount, REL_PAR_DES ]

      IF At( "^", cTitAux ) > 0
         cTitAux := Left( cTitAux, At( "^", cTitAux ) -1 )
      ENDIF

      IF ( ( ValType( aTela[ nCount, REL_PAR_DES ] ) <> "C" ) .OR. ( ! Empty( cTitAux ) .AND. ValType( aTela[ nCount, REL_PAR_DES ] ) = "C" ) ) .AND. lTraco .AND. ! ( Len( aTela[ nCount ] ) > 2 .AND. ! aTela[ nCount, REL_PAR_TRC ] )
         @ Row(), Col()   SAY "√" + Repl( "ƒ", nTamDesc + 2 ) + "≈" + Repl( "ƒ", nTamGet ) + "¥" COLOR cColor1
         SetPos( Row() + 1, nCol )
         lTraco := .F.
      ENDIF

      nDefLen := nTamDesc

      IF At( "^", aTela[ nCount, REL_PAR_DES ] ) > 0
         nDefLen += 2
      ENDIF

      @ Row(), Col() SAY "≥ " COLOR cColor1

      cParDesc := aTela[ nCount, REL_PAR_DES ]

      Say( Row(), Col(), PadR( cParDesc, nDefLen ), cColor4, cColor2 )

      @ Row(), Col() SAY " ≥" COLOR cColor1

      IF ValType( aTela[ nCount, REL_PAR_CAM ] ) = "C"

         @ Row(), Col() SAY PadR( " " + aTela[ nCount, REL_PAR_CAM ], nTamGet ) COLOR cColor2

         lTraco := .T.

      ELSEIF ValType( aTela[ nCount, REL_PAR_CAM ] ) = "A"

         IF aTela[ nCount, REL_PAR_CAM, 1 ] = 0
            @ Row(), Col() SAY PadR( " " + aTela[ nCount, REL_PAR_CAM, 2 ], nTamGet ) COLOR cColor2
         ELSE
            nTamAux := nTamGet1 + 1 + nTamDiv + nTamGet1 + 1
            IF nTamAux < nTamGet
               @ Row(), Col() SAY Space( nTamGet - nTamAux ) COLOR cColor1
            ENDIF
            @ Row(), Col() SAY Space( nTamGet1 + 1 )                            COLOR cColor1
            @ Row(), Col() SAY PadL( aTela[ nCount, REL_PAR_CAM, 2 ], nTamDiv ) COLOR cColor2
            @ Row(), Col() SAY Space( nTamGet1 + 1 )                            COLOR cColor1
         ENDIF

      ELSE
         @ Row(), Col() SAY Space( nTamGet ) COLOR cColor1
      ENDIF

      @ Row(), Col() SAY "≥" COLOR cColor1

      SetPos( Row() + 1, nCol )

      IF ( nCount <> Len( aTela ) ) .AND. ( ValType( aTela[ nCount, REL_PAR_CAM ] ) <> "C" ) .AND. ! ( Len( aTela[ nCount ] ) > 2 .AND. ! aTela[ nCount, REL_PAR_TRC ] )
         @ Row(), Col()   SAY "√" + Repl( "ƒ", nTamDesc + 2 ) + "≈" + Repl( "ƒ", nTamGet ) + "¥" COLOR cColor1
         SetPos( Row() + 1, nCol )
      ENDIF

   NEXT

   @ Row(), Col() SAY "¿" + Repl( "ƒ", nTamDesc + 2 ) + "¡" + Repl( "ƒ", nTamGet ) + "Ÿ" COLOR cColor1

   Shadow( nRow + 1, nCol, Row(), Col() -1 )

   SetColor( cGetColors )

   DefCursor()

   SetPos( nTop + 1, 00 )

RETURN



FUNCTION defPosicao( nLenRow, nLenCol, nRowMax, nColMax )
   
   LOCAL nColI, nColF, nLinI, nLinF

   vDef( @nRowMax, 21 )
   vDef( @nColMax, 57 )

   nLenCol += 3

   IF Row() + nLenRow +2 > nRowMax
      nLinI := ( nLinF := Row() -1 ) - ( nLenRow +1 )
   ELSE
      nLinF := ( nLinI := Row() +1 ) +   nLenRow +1
   ENDIF

   IF nLinI <= 0
      nLinF := ( nLinI := 2 ) + nLenRow +1
   ENDIF

   nColI := Max( nColMax - nLenCol, 1 )
   nColF := nColI + nLenCol

RETURN( { nLinI, nColI, nLinF, nColF } )



FUNCTION mxDispBegin()

   DispBegin()
   lDispBegin := .T.

RETURN( NIL )



FUNCTION mxDispEnd()

   DispEnd()
   lDispBegin := .F.

RETURN( NIL )



FUNCTION scrDefRest( cTela, lSetPos )

   vDef( @lSetPos, .F. )

   IF cTela = NIL
      cTela := SaveScreen()
   ELSE
      RestScreen( ,,,, cTela )
   ENDIF

   IF lSetPos
      DefCursor()
      SetPos( 02, 00 )
   ENDIF

RETURN( NIL )



PROCEDURE csWait( cMsg, nDefFrq, lMsgAguarde, lStatus )

   vDef( @lStatus, .F. )
   
   IF isCsw()
      IF lStatus
         olMsgWait( cMsg, 0, lMsgAguarde )
      ELSE
         olMsgWait( cMsg, nDefFrq, lMsgAguarde )
      ENDIF
   ELSEIF lStatus
      Status( cMsg, NIL, 1 )
   ELSE
      mxWait( cMsg, nDefFrq, NIL, NIL, NIL, NIL, lMsgAguarde )
   ENDIF

RETURN( NIL )



PROCEDURE olMsgWait( cMsg, nTempo, lMsgAguarde )

   #ifdef MINIGUI_MODE

      IF IsDef( "CS_MINIGUI" ) .AND. CS_MINIGUI
         IF cMsg <> "" .AND. ( nTempo = NIL .OR. nTempo <> 0 )
            cMsg := "Aguarde, " + cMsg + "..."
         ENDIF
         RETURN( csStatus( CharRemove( cMsg ) ) )
      ENDIF

   #endif

   IF cMsg = ""
      @ MaxRow() -7, 04 SAY Space(75) COLOR cInfoMSca
   ELSEIF nTempo <> NIL .AND. nTempo = 0
      Say( MaxRow() -7, 04, PadR( " " + cMsg, 75 ), If( IsDef( "cInfoMSca" ), cInfoMSca, NIL ) )
   ELSE
      mxWait( cMsg, nTempo, 03, MaxRow() -7, 04, 75, lMsgAguarde )
   ENDIF

RETURN( NIL )



PROCEDURE rSay( nLin, nRow, cSay )

  @ nLin, nRow - ( Len( cSay ) -1 ) SAY cSay

RETURN( NIL )



FUNCTION SaveScrLastRow()

   cScrLastRow := SaveScreen( MaxRow(), 0, MaxRow(), MaxCol() )
   
RETURN( cScrLastRow )



FUNCTION RestScrLastRow()

   IF cScrLastRow <> NIL
      RestScreen( MaxRow(), 0, MaxRow(), MaxCol(), cScrLastRow )
   ENDIF

RETURN( NIL )



PROCEDURE msgConcluido( lOk, cMsgAux, cTempoIni, cTempoFim )

   LOCAL cMsg := "Processo "

   IF lOk
      cMsg += "conclu°do ^com sucesso^ !"
   ELSE
      cMsg += "^nÑo conclu°do^ !"
   ENDIF

   IF cMsgAux <> NIL
      cMsg += ";;" + cMsgAux
   ENDIF

   IF cTempoIni <> NIL .AND. cTempoFim <> NIL
      cMsg += ";;Tempo de processamento: " + ElapTime( cTempoIni, cTempoFim )
   ENDIF

   MsgDlg( cMsg )

RETURN