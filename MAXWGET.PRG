/*

 MaxWGet.prg
 WinGet Library: Funcoes p/ entrada de dados.

 DENIS MAZZUCATTO RODRIGUES
 18/09/13 * Implementada possibilidade da linha e coluna de aList serem nulos.
 27/08/13 * Desenvolvimento da opcao WG_PASTA.
 09/08/10 * Inicio do desenvolvimento.
 
*/

#include "minigui.ch"
#include "tsbrowse.ch"
#include "inkey.ch"
#include "i_keybd.ch"
#include "shell32.ch"
#include "maxwin.ch"

STATIC _nRow := 0
STATIC _nBox := 0
STATIC _aBox := {}
STATIC _aGet := {}
STATIC _aDic := {}

STATIC lValidando     := .F.
STATIC lValidaEntrada := .F.
STATIC cGetNoValid    := ""

STATIC aEstados

PROCEDURE mxWGBox( ;         // Define os frames
                   cTitle,;  // Titulo do box
                   aCols,;   // Array com as posicoes das colunas dos edit's, onde o 1º elemento corresponde a 2ª coluna utilizada em mxWGGet (e assim por diante)
                   aPos ;    // Array com as posicoes do box
                 )

   /*
   Elementos de aPos:
   1º = nivel do box (p/ calculo da linha e altura)
   2º = coluna (left)
   3º = largura (width)
   */

   LOCAL nPos
  
   IF mxWFObj():cModel = "RPT"
      vDef( @cTitle, "Parâmetros para impressão" )
   ENDIF
  
   _nBox ++

   IF _nBox = 1
      _aBox := {}
      _aGet := {}
   ENDIF

   IF aPos = NIL
      IF _nBox = 1
         aPos := { 1, NIL, NIL }
      ELSE
         aPos := { _aBox[ _nBox -1, WG_aPos, 1 ] +1, NIL, NIL }
      ENDIF
   ENDIF

   IF aPos[ 1 ] = 1
      _nRow := 0
   ELSE
      nPos := 0
      DO WHILE _aBox[ ++ nPos, WG_aPos, 1 ] <> ( aPos[ 1 ] -1 )
      ENDDO
      aEval( _aGet[ nPos ], { |a| _nRow := Max( _nRow, a[ WG_nRow ] ) } )
   ENDIF

   aAdd( _aBox, { _nBox, cTitle, aCols, aPos } )
   aAdd( _aGet, {} )

RETURN( NIL )



PROCEDURE mxWGGet( ;           // Define as digitacoes
                   nRow,;      // Posicao da linha dentro do box
                   nCol,;      // Posicao da coluna (Qdo # 1 sera utilizado o valor do array definido em mxWGBox / Qdo for um numero negativo sera utilizado como left)
                   cLabel,;    // Titulo do label
                   cGet,;      // Nome do edit (P/ carregar automaticamente os valores do DIC utilizar os 6 ultimos caracteres do nome do campo)
                   cType,;     // Tipo do edit (Vide definicoes em MAXWIN.CH)
                   uWidth,;    // Tamanho do edit (Tambem usado p/ definir o numero de linhas do MEMO)
                   uMask,;     // Mascara do edit (Se NIL sera gerado automaticamente de acordo com o tipo/tamanho) (Também usado p/ definir as opcoes do CHECKBOX/COMBO)
                   uMessage,;  // Tooltip (Tambem usado como mensagem da linha de status)
                   aList,;     // Define abertura da lista de ajuda
                   cState ;    // Define o estado inicial do edit (Vide definicoes em MAXWIN.CH)
                 )

   /*
   Elementos de uWidth qdo passado como array:
   1º = largura (width)
   2º = tamanho máximo de caracteres (maxlen)

   Elementos de aList:
   1º = Nome do alias
   2º = Posicao da linha dentro do box p/ exibir a descricao do campo
   3º = Posicao da coluna p/ exibir a descricao do campo
   4º = Tamanho maximo de caracteres da descricao do campo
   5º = Nome do campo referente ao alias da lista de ajuda a ser exibido
   */

   #define DIC_GET  1
   #define DIC_TIP  2
   #define DIC_TAM  3
   #define DIC_DEC  4
   #define DIC_TXT  5
   #define DIC_MSG  6

   LOCAL nMaxRow := 0
   LOCAL nPos, nDec, nAux, nDic, aResult

   IF ValType( cState ) = "L" 
      IF ! cState
         RETURN( NIL )   
      ENDIF
      cState := NIL
   ENDIF

   IF aList <> NIL
      aSize( aList, 5 )
   ENDIF

   IF cGet <> NIL .AND. cType = NIL .AND. sqlActive()

      nDic := aScan( _aDic, { |x| x[ DIC_GET ] = cGet } )

      IF nDic = 0
         aResult := {}
         IF sqlExecute( "SELECT SUBSTRING(" + sisFlgModule() + "NOMDIC,4,6), " + ;
                                "TRIM(" + sisFlgModule() + "TIPDIC), " + ;
                                sisFlgModule() + "TAMDIC, " + ;
                                sisFlgModule() + "DECDIC, " + ;
                                "TRIM(" + sisFlgModule() + "NOLDIC), " + ;
                                "TRIM(" + sisFlgModule() + "DESDIC) " + ;
                        "FROM MXDIC" + sisFlgModule() + " " + ;
                        "WHERE " + sisFlgModule() + "STADIC='2' AND SUBSTRING(" + sisFlgModule() + "NOMDIC,4,6)=" + QuotedStr( cGet ), @aResult, .F. ) .AND. Len( aResult ) > 0

            _aDic := aInsert( _aDic, aResult )
         ENDIF
         nDic := aScan( _aDic, { |x| x[ DIC_GET ] = cGet } )
      ENDIF

      IF nDic > 0

         //vDef( @cLabel  , _aDic[ nDic, DIC_TXT ] )
         //vDef( @uMessage, _aDic[ nDic, DIC_MSG ] )

         cType  := _aDic[ nDic, DIC_TIP ]
         uWidth := _aDic[ nDic, DIC_TAM ]
         nDec   := _aDic[ nDic, DIC_DEC ]

         IF uMask = NIL

            IF cType = "N"
               IF nDec = 0
                  uMask := Repl( "9", uWidth )
               ELSE
                  uMask := ""
                  FOR nAux := uWidth - nDec -1 TO 1 STEP -1
                     IF uMask <> "" .AND. Mod( nAux, 3 ) = 0
                        uMask += ","
                     ENDIF
                     uMask += "9"
                  NEXT
                  uMask := "@E " + uMask + "." + Repl( "9", nDec )
               ENDIF
            ENDIF

         ENDIF

         DO CASE
            CASE cType = "C" ; cType := WG_TEXT
            CASE cType = "D" ; cType := WG_DATE
            CASE cType = "N" ; cType := WG_NUMERIC
         ENDCASE

      ENDIF

   ENDIF

   nPos := aAddNIL( _aGet[ _nBox ], 10 )

   _aGet[ _nBox, nPos, WG_nRow     ] := nRow + _nRow
   _aGet[ _nBox, nPos, WG_nCol     ] := nCol
   _aGet[ _nBox, nPos, WG_cLabel   ] := cLabel
   _aGet[ _nBox, nPos, WG_cGet     ] := cGet
   _aGet[ _nBox, nPos, WG_cType    ] := cType
   _aGet[ _nBox, nPos, WG_uWidth   ] := uWidth
   _aGet[ _nBox, nPos, WG_uMask    ] := uMask
   _aGet[ _nBox, nPos, WG_uMessage ] := uMessage
   _aGet[ _nBox, nPos, WG_cState   ] := cState
   _aGet[ _nBox, nPos, WG_aList    ] := aList

   IF aList <> NIL .AND. Len( aList ) > 1

      mxWGGet( vDef( @aList[ WG_LIST_ROW ], nRow ),;
               aList[ WG_LIST_COL ],;
               NIL,;
               cGet + "_" + aList[ WG_LIST_ALIAS ],;
               WG_LIST_TEXT,;
               aList[ WG_LIST_WIDTH ],;
               NIL,;
               cLabel )

   ENDIF
   
   SetPos( nRow, nCol )

RETURN( NIL )



PROCEDURE mxWGDefine( ;           // Cria os controles pre-definidos em mxWGBox/mxWGGet
                      lButtons,;  // Se TRUE cria os botoes CONFIRMAR/CANCELAR
                      uPos ;      // Linha inicial do primeiro label
                    )

   /*
   Elementos de uPos qdo passado como array:
   1º = Linha inicial do primeiro label
   2º = Largura do box
   */

   LOCAL aColsGet := {}

   LOCAL nRowFrame1, nRowFrame2, nRows, nRowBegin, nBoxWidth
   LOCAL nRow, nCol, nColAnt, nGet, nDef, nPos, nWidth, nMaxLen, nComboWidth
	LOCAL cLabel, cLink, cType, cName, cGet, cToolTip, cMessage, cState
   LOCAL uMask, uMessage, aList, aGets, lKeyF11, bKeyF11, cSavePath

   PRIV cList

   IF ValType( uPos ) = "A"
	   nRowBegin := uPos[1]
	   nBoxWidth := uPos[2]
	ELSE
	   nRowBegin := uPos
	ENDIF
	
   IF lButtons = NIL .AND. nRowBegin = NIL .AND. mxWFObj():lUsePageAux
      lButtons  := .F.
      nRowBegin := mxWFObj():PageAux_nRowGet
   ENDIF

   vDef( @lButtons , .T. )
	vDef( @nRowBegin, 54  )
	vDef( @nBoxWidth, mxWFObj():nWidth - If( mxWFObj():lUseImage, mxWFObj():nImageWidth, 16 ) )

	IF aEstados = NIL
      aEstados := { "  " }
      aEval( UF(), { |x| aAdd( aEstados, x[2] ) } )
	ENDIF

   FOR nDef := 1 TO 2

      // nDef = 1 - Exibicao dos titulos (label)
      // nDef = 2 - Definicao das digitacoes (textbox/combobox/checkbox/radiogroup)

      FOR _nBox := 1 TO Len( _aBox )

        nRowFrame1 := 0
        nRowFrame2 := 0

        IF mxWFObj():cModel = "RPT"
           nComboWidth := 0
           FOR nGet := 1 TO Len( _aGet[ _nBox ] )
              IF _aGet[ _nBox, nGet, WG_cType ] = WG_COMBO
                 aEval( _aGet[ _nBox, nGet, WG_uMask ], { |a| nComboWidth := Max( nComboWidth, Len( a ) ) } )
				  ENDIF   
		     NEXT
		  ENDIF   
		  
		  nColAnt := 0
		  
        FOR nGet := 1 TO Len( _aGet[ _nBox ] )

           nRow   := _aGet[ _nBox, nGet, WG_nRow   ]
           nCol   := _aGet[ _nBox, nGet, WG_nCol   ]
           cGet   := _aGet[ _nBox, nGet, WG_cGet   ]
           cLabel := _aGet[ _nBox, nGet, WG_cLabel ]
           cType  := _aGet[ _nBox, nGet, WG_cType  ]
           uMask  := _aGet[ _nBox, nGet, WG_uMask  ]
           cState := _aGet[ _nBox, nGet, WG_cState ]

           IF If( nDef = 1, cLabel, cGet ) = NIL
              LOOP
           ENDIF
           
           IF ValType( cLabel ) = "A"
              cLink  := cLabel[2]
              cLabel := cLabel[1]
           ELSE
              cLink := NIL
           ENDIF
           
           IF mxIn( cType, { WG_CHECK_V, WG_RADIO_V } )
              nRows := Len( uMask )
           ELSEIF mxIn( cType, { WG_MEMO, WG_MEMOEX } )
			     nRows := _aGet[ _nBox, nGet, WG_uWidth, 2 ]
			  ENDIF
           
			  IF nDef = 2

              IF ValType( _aGet[ _nBox, nGet, WG_uWidth ] ) = "A"
                 nWidth  := _aGet[ _nBox, nGet, WG_uWidth, 1 ]
                 nMaxLen := _aGet[ _nBox, nGet, WG_uWidth, 2 ]
              ELSE
                 nWidth  := _aGet[ _nBox, nGet, WG_uWidth ]
                 IF ValType( uMask ) = "C"
                    nWidth := Max( nWidth, Len( StrTran( StrTran( uMask, "@E ", "" ), "@R ", "" ) ) )
                 ENDIF
                 nMaxLen := nWidth
              ENDIF

              uMessage := _aGet[ _nBox, nGet, WG_uMessage ]
              aList    := _aGet[ _nBox, nGet, WG_aList    ]              

				  IF mxIn( cType, { WG_MEMO, WG_MEMOEX } )
                 nWidth := Int( nWidth / nRows )
				  ELSEIF cType = WG_NUMERIC
                 IF uMask = NIL
                    uMask := Repl( "9", nMaxLen )
                 ENDIF
              ELSEIF cType = WG_DATE
                 nWidth := 10
              ELSEIF cType = WG_UF
                 cType := WG_COMBO
                 uMask := aEstados
              ELSEIF cType = WG_FONE
                 uMask  := MASK_FONE
                 nWidth := 13
              ELSEIF cType = WG_CEP
                 uMask  := MASK_CEP
                 nWidth := 9
              ELSEIF cType = WG_CNPJ
                 uMask  := MASK_CNPJ
                 nWidth := 18
              ELSEIF cType = WG_CPF
                 uMask  := MASK_CPF
                 nWidth := 14
              ENDIF

              vDef( @uMask   , ""     )
              vDef( @nWidth  , 0      )
              vDef( @nMaxLen , nWidth )
              vDef( @uMessage, cLabel )
              
              IF nWidth < 0
                 nWidth := Abs( nWidth )
              ELSE
                 IF cType = WG_COMBO
                    IF mxWFObj():cModel = "RPT"
                       nWidth := nComboWidth
						  ELSE
						     nWidth := 0
                       aEval( uMask, { |a| nWidth := Max( nWidth, Len( a ) ) } )
                       nWidth += 2
                    ENDIF
                 ENDIF
                 nWidth *= 7.2
                 IF nWidth > 0
                    nWidth += 20
                    IF aList <> NIL
                       nWidth += 20
                    ENDIF
                 ENDIF
              ENDIF

           ENDIF

           nPos := _aBox[ _nBox, WG_aPos, 1 ]
           
			       // Linha inicial            // Entre linhas GET    // Espaço entre os box's
			  nRow := nRowBegin + ( ( nRow -1 ) * 25 ) + ( ( nPos -1 ) * 36 )

           IF nCol = NIL
              nCol := nColAnt
           ELSEIF _aBox[ _nBox, WG_aCols ] <> NIL .AND. nCol > 1
              nCol := _aBox[ _nBox, WG_aCols, nCol -1 ]
           ELSEIF nCol <= 0
              nCol := Abs( nCol )
           ELSE
              nCol := 19
           ENDIF

           IF _aBox[ _nBox, WG_aPos, 2 ] <> NIL
              nCol += _aBox[ _nBox, WG_aPos, 2 ] -10
           ENDIF

           nPos := aScan( aColsGet, { |x| x[1] = nCol } )

           IF nDef = 1

              nRow -= 2

              IF cGet = NIL
                 cName := "lb" + StrZero( _aBox[ _nBox, WG_nBox ], 3 ) + StrZero( nRow, 4 ) + StrZero( nCol, 4 )
              ELSE
                 cName := "lb" + cGet
              ENDIF

              IF cLink = NIL

                 DEFINE LABEL &cName
                    ROW       nRow
   					  COL       nCol
   					  VALUE     cLabel
                    AUTOSIZE  .T.
                    BACKCOLOR oWConfig:Color_Page
                    FONTNAME  oWConfig:FontName_GetLabel
                    FONTSIZE  oWConfig:FontSize_GetLabel
                    FONTBOLD  cGet = NIL .AND. uMask <> NIL
                 END LABEL

              ELSE
              
                 DEFINE HYPERLINK &cName
                    ROW        nRow
   					  COL        nCol
   					  VALUE      cLabel
                    ADDRESS    cLink
                    TOOLTIP    cLink
                    AUTOSIZE   .T.
                    HANDCURSOR .T.
                    BACKCOLOR  oWConfig:Color_Page
                    FONTNAME   oWConfig:FontName_GetLabel
                    FONTSIZE   oWConfig:FontSize_GetLabel
                    FONTBOLD   cGet = NIL .AND. uMask <> NIL
                 END HYPERLINK

              ENDIF

              mxWGDefState( cName, cState )
				  
				  SetProperty( mxWFObj():cName, cName, "Height", 20 )
				  SetProperty( mxWFObj():cName, cName, "FontColor", oWConfig:Color_GetLabel )
				
              IF nPos = 0
                 aAdd( aColsGet, { nCol, 0 } )
                 nPos := Len( aColsGet )
              ENDIF

              aColsGet[ nPos, 2 ] := Max( aColsGet[ nPos, 2 ], nCol + 8 + GetProperty( mxWFObj():cName, cName, "Width" ) )

              IF nRowFrame1 = 0
                 nRowFrame1 := nRow -23
              ENDIF

				  IF mxIn( cType, { WG_CHECK_V, WG_RADIO_V, WG_MEMO, WG_MEMOEX } )
                 nRow += ( 25 * ( nRows -1 ) )
              ENDIF              

              nRowFrame2 := Max( nRowFrame2, nRow +28 )

           ELSE

              IF nPos > 0
                 nCol := aColsGet[ nPos, 2 ]
              ENDIF

              nRow -= 5

              cName := cGet

              IF ! mxIn( cType, { WG_CHECK_H, WG_CHECK_V } )

                 IF ValType( uMessage ) = "A"
                    cToolTip := uMessage[1]
                    cMessage := uMessage[2]
                 ELSE
                    cToolTip := uMessage
                    cMessage := uMessage
                 ENDIF
                 
					  IF cToolTip <> NIL
					     cToolTip := StrTran( StrTran( cToolTip, " ou tecle F11 para ajuda", "" ), ";", _NL )
					  ENDIF   
					  
					  IF cMessage <> NIL
					     cMessage := StrTran( StrTran( cMessage, ";", " " ), _NL, " " )
					  ENDIF

              ENDIF

              IF cType = WG_COMBO

                 DEFINE COMBOBOX &cName
                    ROW            nRow
                    COL            nCol
                    WIDTH          nWidth
                    ITEMS          uMask
                    VALUE          1
                    TOOLTIP        cToolTip
                    FONTNAME       oWConfig:FontName_Get
                    FONTSIZE       oWConfig:FontSize_Get
                    FONTCOLOR      oWConfig:Color_GetFont
						  BACKCOLOR      oWConfig:Color_GetBack
                    ON LISTDISPLAY mxWGGotFocus()
						  ON GOTFOCUS    mxWGGotFocus()
                    ON CHANGE      mxWGValid()
                 END COMBOBOX

                 mxWGDefCargo( cName, NIL, { .F., cMessage, .F. } )
					  mxWGDefState( cName, cState )

           	     IF mxWFObj():cModel <> "RPT"
	                 
						  cName := "ed" + cName + "_Show"
	               
	                 DEFINE GETBOX &cName
	                    ROW         nRow
	                    COL         nCol
	                    WIDTH       nWidth
	                    HEIGHT      20
	                    VALUE       ""
	                    TOOLTIP     cToolTip
                       FONTNAME    oWConfig:FontName_Get
                       FONTSIZE    oWConfig:FontSize_Get
	                    FONTCOLOR   oWConfig:Color_GetDisabled
	                    BACKCOLOR   oWConfig:Color_GetBack
	                    INVISIBLE   .T.
	                    NOTABSTOP   .T.
	                    ON GOTFOCUS mxWGGotFocus()
	                 END GETBOX
	                 
                    mxWGDefCargo( cName, NIL, { .T., cMessage, .F. } )
						  
                 ENDIF
                  
				  ELSEIF cType = WG_MEMO

                 DEFINE EDITBOX &cName
                    ROW          nRow
                    COL          nCol
                    WIDTH        nWidth
                    HEIGHT       _aGet[ _nBox, nGet, WG_uWidth, 2 ] * 23
                    MAXLENGTH    _aGet[ _nBox, nGet, WG_uWidth, 1 ]
                    TOOLTIP      cToolTip
                    FONTNAME     oWConfig:FontName_Get
                    FONTSIZE     oWConfig:FontSize_Get
                    FONTCOLOR    oWConfig:Color_GetFont
						  BACKCOLOR    oWConfig:Color_GetBack
                    NOHSCROLLBAR .T.
                    NOVSCROLLBAR .T.
                    ON GOTFOCUS  mxWGGotFocus()
                    ON LOSTFOCUS mxWGValid()
                 END EDITBOX

                 mxWGDefCargo( cName, NIL, { .F., cMessage, .F. } )
					  mxWGDefState( cName, cState )

              ELSEIF cType = WG_MEMOEX
                 
                 cName += "00"
                 
                 FOR nPos := 1 TO nRows
                    
						  cName := Left( cName, Len( cName ) -2 ) + StrZero( nPos, 2 )
						  
	                 DEFINE GETBOX &cName
	                    ROW          nRow
	                    COL          nCol
	                    WIDTH        nWidth
	                    HEIGHT       22
	                    VALUE        Space( Int( _aGet[ _nBox, nGet, WG_uWidth, 1 ] / nRows ) )
	                    PICTURE      uMask
	                    TOOLTIP      cToolTip
                       FONTNAME     oWConfig:FontName_Get
                       FONTSIZE     oWConfig:FontSize_Get
	                    FONTCOLOR    oWConfig:Color_GetFont
							  BACKCOLOR    oWConfig:Color_GetBack
	                    ON GOTFOCUS  mxWGGotFocus()                                        
	                    ON LOSTFOCUS mxWGValid()	                    
	                    
	                    IF ValType( cMessage ) = "C"
	                       MESSAGE cMessage + " (Linha " + NumToStr( nPos ) + ")"
	                    ENDIF
	
	                 END GETBOX	                 
	                 
	                 mxWGDefCargo( cName, NIL, { .F., If( ValType( cMessage ) = "C", NIL, cMessage ), .F. } )
						  mxWGDefState( cName, cState )
						  
						  nRow += 22
					  
					  NEXT
				  
				  ELSEIF mxIn( cType, { WG_CHECK_H, WG_CHECK_V } )

                 FOR nPos := 1 TO Len( uMask )

                    IF ValType( uMessage ) = "A"
                       cToolTip := uMessage[ nPos ]
                       cMessage := uMessage[ nPos ]
                    ELSE
                       cToolTip := uMessage
                       cMessage := uMessage
                    ENDIF

   					  IF cToolTip <> NIL
   					     cToolTip := StrTran( cToolTip, ";", _NL )
   					  ENDIF

   					  IF cMessage <> NIL
   					     cMessage := StrTran( StrTran( cMessage, ";", " " ), _NL, " " )
   					  ENDIF

                    IF nMaxLen = 0
                       nWidth := mxWGDefWidth( uMask[ nPos ], mxWFObj():cName ) +100
                    ENDIF

                    IF Len( uMask ) > 1
                       cName := cName + "_" + StrZero( nPos, 2 )
                    ENDIF

                    DEFINE CHECKBOX &cName
                       ROW          nRow
                       COL          nCol
                       WIDTH        nWidth
                       HEIGHT       23
                       CAPTION      uMask[ nPos ]
                       VALUE        .F.
                       TOOLTIP      cToolTip
                       FONTNAME     oWConfig:FontName_Get
                       FONTSIZE     oWConfig:FontSize_Get
                       BACKCOLOR    oWConfig:Color_Page
                       ON GOTFOCUS  mxWGGotFocus()
                       ON CHANGE    mxWGValid()
                    END CHECKBOX

                    mxWGDefCargo( cName, NIL, { .F., cMessage, .F. } )
                    mxWGDefState( cName, cState )
						  
						  IF cType = WG_CHECK_V
                       nRow += 25
                    ELSE
                       nCol += GetProperty( mxWFObj():cName, cName, "Width" ) +6
                    ENDIF

                 NEXT

              ELSEIF mxIn( cType, { WG_RADIO_H, WG_RADIO_V } )

                 IF nWidth = 0
                    nWidth := 0
                    FOR nPos := 1 TO Len( uMask )
                       nWidth := Max( nWidth, mxWGDefWidth( uMask[ nPos ], mxWFObj():cName ) )
                    NEXT
                    nWidth += 30
                 ENDIF

                 DEFINE RADIOGROUP &cName
                    ROW        nRow
                    COL        nCol
                    WIDTH      nWidth
                    OPTIONS    uMask
                    VALUE      1
                    TOOLTIP    cToolTip
                    HORIZONTAL ( cType = WG_RADIO_H )
                    BACKCOLOR  oWConfig:Color_Page
                    ON CHANGE  ( mxWGMsgHelp(), mxWGValid() )
                    IF nMaxLen > 0
                       SPACING nMaxLen
                    ENDIF
                 END RADIOGROUP

                 IF cType = WG_RADIO_H
                    // Alternativa p/ definir o valor de Height
                    _HMG_aControlHeight[ &( "_" + mxWFObj():cName + "_" + cName ) ] := 23
                 ENDIF
                 
                 mxWGDefCargo( cName, NIL, { .F., cMessage, .F. } )
					  mxWGDefState( cName, cState )

              ELSEIF cType = WG_LIST_TEXT

                 cName := "lb" + cName

                 DEFINE LABEL &cName
					     ROW           nRow +2
						  COL           nCol
                    VALUE         ""
                    FONTCOLOR     oWConfig:Color_GetDisabled
                    FONTBOLD      .T.
                    FONTUNDERLINE .T.
                    AUTOSIZE      .T.
                    TOOLTIP       uMessage
                 END LABEL
                 
					  mxWGDefState( cName, cState )

              ELSEIF cType = WG_PASTA

                 DEFINE BTNTEXTBOX &cName
                    ROW          nRow
                    COL          nCol
                    WIDTH        nWidth
                    HEIGHT       20
                    VALUE        Space( nMaxLen )
                    TOOLTIP      cToolTip
                    FONTNAME     oWConfig:FontName_Get
                    FONTSIZE     oWConfig:FontSize_Get
                    FONTCOLOR    oWConfig:Color_GetFont
						  BACKCOLOR    oWConfig:Color_GetBack
                    ON GOTFOCUS  ( mxWGMsgHelp(), mxWGGotFocus() )
                    ON LOSTFOCUS mxWGValid()
                    ACTION       ( cSavePath  := CurPath(), This.Value := GetFolder( This.ToolTip, This.Value ), DiskChange( Left( cSavePath, 1 ) ), DirChange( cSavePath ) )

                 END BTNTEXTBOX

                 mxWGDefCargo( cName, NIL, { .F., cMessage, .F. } )
                 mxWGDefState( cName, cState )

              /*
              ELSEIF cType = WG_DATE

                 DEFINE DATEPICKER &cName
                    ROW          nRow
                    COL          nCol
                    WIDTH        nWidth
                    HEIGHT       20
                    VALUE        CtoD( "" )
                    TOOLTIP      cToolTip
                    FONTNAME     oWConfig:FontName_Get
                    FONTSIZE     oWConfig:FontSize_Get
                    FONTCOLOR    oWConfig:Color_GetFont
						  BACKCOLOR    oWConfig:Color_GetBack
                    ON GOTFOCUS  mxWGGotFocus()
   				     ON LOSTFOCUS mxWGValid()

                 END DATEPICKER

                 mxWGDefCargo( cName, NIL, { .F., cMessage, .F. } )
					  mxWGDefState( cName, cState )
              */
              
              ELSE

                 IF aList <> NIL
                    cList := ""
                    aEval( aList, { |x| cList += UtoC( x ) + "|" } )
                    cList := "'" + cList + "'"
                    lKeyF11 := .T.
                    IF ValType( cMessage ) = "C"
                       cMessage += " ou tecle F11 para ajuda"
                    ENDIF
                 ENDIF

                 DEFINE GETBOX &cName
                    ROW         nRow
                    COL         nCol
                    WIDTH       nWidth
                    HEIGHT      20
                    PICTURE     uMask
                    TOOLTIP     cToolTip
                    FONTNAME    oWConfig:FontName_Get
                    FONTSIZE    oWConfig:FontSize_Get
                    FONTCOLOR   oWConfig:Color_GetFont
						  BACKCOLOR   oWConfig:Color_GetBack
                    ON GOTFOCUS mxWGGotFocus()

            		  IF aList = NIL
						     ON LOSTFOCUS mxWGValid()
						  ELSE
                       ON LOSTFOCUS mxWGValid( &cList )
							  ACTION       mxWGList( &cList )
                    ENDIF

                    IF ValType( cMessage ) = "C"
                       MESSAGE cMessage
                    ENDIF

                    IF cType = WG_NUMERIC
                       VALUE 0
                    ELSEIF cType = WG_DATE
                       ON CHANGE mxWGSetToolTip()
                       VALUE CtoD( "" )
                    ELSE
                       VALUE Space( nMaxLen )
                    ENDIF

                 END GETBOX
                 
                 mxWGDefCargo( cName, NIL, { .F., If( ValType( cMessage ) = "C", NIL, cMessage ), .F. } )
                 mxWGDefState( cName, cState )
                 
              ENDIF

              nColAnt := nCol + nWidth + If( aList = NIL, 10, 5 )

           ENDIF

        NEXT

        IF nDef = 1

           nPos := 0

           DO WHILE .T.
              cName := "fm" + StrZero( _aBox[ _nBox, WG_nBox ], 2 ) + StrZero( ++ nPos, 2 )
              IF ! _IsControlDefined( cName, mxWFObj():cName )
                 EXIT
              ENDIF
           ENDDO

           cLabel := _aBox[ _nBox, WG_cTitle  ]
           nCol   := _aBox[ _nBox, WG_aPos, 2 ]
           nWidth := _aBox[ _nBox, WG_aPos, 3 ]

           vDef( @nCol  , If( mxWFObj():lUsePageAux, 9, 10 ) )
           vDef( @nWidth, nBoxWidth - nCol - If( mxWFObj():lUsePageAux, 1, 0 ) )

           DEFINE FRAME &cName
              ROW       nRowFrame1
              COL       nCol
              WIDTH     nWidth
              HEIGHT    ( nRowFrame2 - nRowFrame1 )
              BACKCOLOR oWConfig:Color_Page
              CAPTION   cLabel
              OPAQUE    .T.
              FONTNAME  oWConfig:FontName_Frame
				  FONTSIZE  oWConfig:FontSize_Frame
              FONTBOLD  .T.
           END FRAME

        ENDIF

      NEXT

   NEXT

   vDef( @lKeyF11, .F. )

   IF lKeyF11
      ON KEY F11 OF ( mxWFObj():cName ) ACTION ( bKeyF11 := GetProperty( ThisWindow.Name, ThisWindow.FocusedControl, "Action" ), If( ValType( bKeyF11 ) = "B", Eval( bKeyF11 ), NIL ) )
   ENDIF

   _nBox := 0
   
   IF lButtons
	   mxWFButtons()
	ENDIF

   aGets := aClone( mxWFObj():aGets )
   aEval( _aGet, { |x| aEval( x, { |a| aAddC( aGets, a[ WG_cGet ], a[ WG_cGet ] <> NIL ) } ) } )
   mxWFObj():aGets := aClone( aGets )

RETURN( NIL )



PROCEDURE mxWGGotFocus  // Verifica se o componente pode ser editado

   LOCAL cGet := This.Name
   LOCAL lReadOnly
   
   mxWGSetToolTip( cGet )

   IF ! mxWFObj():lVldGets

      /*
      lReadOnly := GetProperty( ThisWindow.Name, cGet, "Cargo" )[1]

   	IF lReadOnly
   	   _SetNextFocus()
   	ENDIF
   	*/

   ELSEIF ! lValidando

      lValidaEntrada := .T.

      IF mxWGValid()
         lReadOnly := GetProperty( ThisWindow.Name, cGet, "Cargo" )[1]
      ELSE
         lReadOnly := .T.
      ENDIF

      lValidaEntrada := .F.

   	IF lReadOnly
   	   cGetNoValid += "|" + cGet
   	   _SetNextFocus()
   	ELSE
         mxWGMsgHelp()
      ENDIF

   ENDIF
   
RETURN( NIL )



PROCEDURE mxWGSetToolTip( ;           // Define a mensagem de ajuda do ToolTip
                          cGet,;      // Nome do objeto
                          cForm,;     // Formulario
                          cToolTip ;  // Mensagem de ajuda
                        )

   LOCAL uValue

   IF cGet = NIL  // *** Nao trocar por vDef ***
      cGet := This.Name
   ENDIF
   
   IF cForm = NIL  // *** Nao trocar por vDef ***
      cForm := ThisWindow.Name
   ENDIF

   uValue := mxGetValue( cGet, cForm )

   IF ValType( uValue ) = "D"   // Especifico p/ o tipo "data"

      cToolTip := GetProperty( cForm, cGet, "ToolTip" )
      
      IF Right( cToolTip, 1 ) = "]" .AND. At( "[", cToolTip ) > 0
         cToolTip := Trim( Left( cToolTip, RAt( "[", cToolTip ) -1 - Len( _NL ) ) )
      ENDIF

      IF ! Empty( uValue )
         cToolTip += _NL + "[" + StrTran( StrTran( CharRemove( CDoW( uValue ) ), "erca", "erça" ), "abado", "ábado" ) + "]"
      ENDIF

   ENDIF
   
   IF cToolTip <> NIL
      SetProperty( cForm, cGet, "ToolTip", cToolTip )
   ENDIF

RETURN( NIL )



STATIC PROCEDURE mxWGMsgHelp  // Exibe mensagem de ajuda no status

   LOCAL cMessage

   IF _IsControlDefined( "StatusBar", ThisWindow.Name )

      cMessage := This.Cargo[2]

      IF ValType( cMessage ) = "B"
         cMessage := Eval( cMessage )
      ENDIF

      IF ! Empty( cMessage )
         SetProperty( ThisWindow.Name, "StatusBar", "Item", 1, cMessage )
      ENDIF

   ENDIF

RETURN( NIL )



FUNCTION mxWGValid( ;        // Validacoes ao perder o foco
                    cList,;  // Parametro aList de mxWGGet no formato string
                    cGet ;   // Nome do edit
                  )

   LOCAL lReturn
   LOCAL nCount :=  0
   LOCAL cForm  := ThisWindow.Name

   LOCAL cGetSave, cAlias, cDescr, cAux, lReadOnly, uValue, bKeyAct
   
	PRIV cFuncVld

   vDef( @cGet, This.Name )

   BEGIN SEQUENCE

      IF ( ! mxWFObj():lVldGets ) .OR. lValidando
         BREAK
      ENDIF

      IF ! lValidaEntrada .AND. At( cGet, cGetNoValid ) > 0
         cGetNoValid := StrTran( cGetNoValid, "|" + cGet, "" )
         BREAK
      ENDIF

      cFuncVld := mxWFObj():GetFunc( "GetVld" )

		IF cFuncVld = NIL
         BREAK
      ELSEIF Empty( cGet )
         BREAK
      ENDIF
		
      lReadOnly := GetProperty( ThisWindow.Name, cGet, "Cargo" )[1]
      
	   IF lReadOnly
	      BREAK
      ENDIF      

      lReturn := .T.
      
      lValidando := .T.

      uValue := GetProperty( ThisWindow.Name, cGet, "Value" )

      IF cList <> NIL

         IF Empty( uValue )
            bKeyAct := GetProperty( ThisWindow.Name, cGet, "Action" )
            IF ValType( bKeyAct ) = "B"
               _SetFocus( cGet, ThisWindow.Name )
               Eval( bKeyAct )
            ENDIF
         ENDIF

         DO WHILE ! Empty( cList )
		
		      cAux  := Left( cList, At( "|", cList ) -1 )
		      cList := Subs( cList, At( "|", cList ) +1 )
		
		      nCount ++
		
		      DO CASE
		         CASE nCount = WG_LIST_ALIAS ; cAlias := cAux
		         CASE nCount = WG_LIST_DESCR ; cDescr := cAux
		      ENDCASE
		
		   ENDDO
		   
		   IF Empty( cDescr )
		      cDescr := NIL
		   ENDIF

			lReturn := mxWGValidCod( uValue, cAlias, 1, If( cDescr = NIL, NIL, cGet + "|" + cDescr + cAlias ) )

		ENDIF
		
      IF lReturn
	
         lReturn := ( &cFuncVld( cGet, uValue, lValidaEntrada ) )

         IF lReturn
            lValidando := .F.
	         BREAK
	      ENDIF
	      
		ENDIF

      vDef( @cForm, mxWFObj():cName )
      _SetFocus( cGet, cForm )

      lValidando := .F.

   ENDSEQUENCE
   
   IF lReturn <> NIL .AND. ! lValidaEntrada
      mxWGDefCargo( cGet, 3, lReturn )
   ENDIF

   vDef( @lReturn, .T. )
   
RETURN( lReturn )



STATIC FUNCTION mxWGDefWidth( ;         // Retorna o tamanho em pixel de uma string
                              cValue,;  // String
                              cForm ;   // Formulario
                            )

   LOCAL nWidth := 0
   LOCAL nPos

   @ 00,00 LABEL lbWGSetWidth VALUE "" AUTOSIZE INVISIBLE

   FOR nPos := 1 TO Len( cValue )

      SetProperty( cForm, "lbWGSetWidth", "Value", Subs( cValue, nPos, 1 ) )

      nWidth += GetProperty( cForm, "lbWGSetWidth", "Width" )

   NEXT

   RELEASE CONTROL lbWGSetWidth OF &cForm

RETURN( nWidth )



PROCEDURE mxWGDefCargo( ;         // Atribui valores a propriedade "Cargo" de um objeto
                        cName,;   // Nome do objeto
                        nPos,;    // Posicao do array q tera o valor alterado
                        uValue,;  // Valor
                        cForm ;   // Formulario
                      )

   LOCAL uCargo
   
   vDef( @cForm, mxWFObj():cName )
   vDef( @nPos , 0 )
   
   IF cName <> NIL .AND. ! Empty( cName ) .AND. _IsControlDefined( cName, cForm )
      IF nPos = 0
         SetProperty( cForm, cName, "Cargo", uValue )
      ELSE
         uCargo := GetProperty( cForm, cName, "Cargo" )
      	IF ValType( uCargo ) = "A" .AND. Len( uCargo ) >= nPos
            uCargo[ nPos ] := uValue
            SetProperty( cForm, cName, "Cargo", uCargo )
         ENDIF
      ENDIF
   ENDIF

RETURN( NIL )



PROCEDURE mxWGDefState( ;            // Define o estado de um objeto (invisivel/desabilitado/apenas leitura/normal)
                        uName,;      // Nome do objeto
                        cState,;     // Definicao do estado (Vide definicoes em MAXWIN.CH)
                        cForm,;      // Formulario
                        lSetState ;  // Condicao p/ definicao do estado
                      )
	
   LOCAL uCargo, cName, nCount
   
   vDef( @cForm, mxWFObj():cName )
   vDef( @lSetState, .T. )
   
   IF lSetState

      IF ValType( uName ) = "C"
         uName := { uName }
      ENDIF

   	FOR nCount := 1 TO Len( uName )

   		cName := uName[ nCount ]

         IF ! _IsControlDefined( cName, cForm )
            LOOP
         ENDIF

         IF cState = WG_INVISIBLE
   		   SetProperty( cForm, cName, "Visible", .F. )
   		ELSEIF cState = WG_DISABLED
   		   SetProperty( cForm, cName, "Enabled", .F. )
   		ELSEIF mxIn( cState, { WG_READONLY, WG_NORMAL } )
   		   uCargo := GetProperty( cForm, cName, "Cargo" )
   			IF ValType( uCargo ) = "A"
   	         uCargo[1] := ( cState = WG_READONLY )
   	         SetProperty( cForm, cName, "Cargo", uCargo )
   	      ENDIF
   			IF GetProperty( cForm, cName, "ReadOnly" ) <> NIL
   	         IF foundStr( GetControlType( cName, cForm ), "COMBO|RADIOGROUP" )
   	            SetProperty( cForm, cName, "Enabled", cState <> WG_READONLY )
               ELSE
                  SetProperty( cForm, cName, "ReadOnly", cState = WG_READONLY )
   	         ENDIF
   	      ELSEIF cState = WG_READONLY
   				IF uCargo = NIL .OR. GetControlType( cName, cForm ) = "CHECKBOX"
   	            SetProperty( cForm, cName, "Enabled", .F. )
               ENDIF
   			ENDIF
   			IF cState = WG_NORMAL
   			   SetProperty( cForm, cName, "Enabled", .T. )
   				SetProperty( cForm, cName, "Visible", .T. )
   			ENDIF
   			IF ! foundStr( GetControlType( cName, cForm ), "LABEL|CHECKBOX|COMBO|RADIOGROUP" )
   				SetProperty( cForm, cName, "FontColor", If( cState = WG_NORMAL, oWConfig:Color_GetFont, oWConfig:Color_GetDisabled ) )
   			ENDIF
   		ENDIF

   	NEXT

   ENDIF

RETURN( NIL )



PROCEDURE mxWGActivate( ;            // Ativa/desativa a digitacao
                        uActivate,;  // Tecla pressionada / TRUE ativa a digitacao / FALSE desativa a digitacao (os edit's ficarao como readonly)
                        uSetFocus ;  // Sequencia dos edit's q receberao o foco inicial
                      )

   LOCAL aGets := aClone( mxWFObj():aGets )
   LOCAL lActivate, nCount

   IF ValType( uActivate ) = "L"
      lActivate := uActivate
   ELSE
      lActivate := ( ! mxIn( uActivate, { K_CONSULTAR, K_EXCLUIR } ) )
   ENDIF

   _ProcessMess()

   aEval( aGets, { |x| mxWGDefCargo( x, 3, !lActivate ) } )

   mxWFObj():lVldGets := .T.

   _SetFocus( "edSetFocus", mxWFObj():cName )

   IF lActivate

      IF uSetFocus = NIL
         uSetFocus := {}
         aEval( aGets, { |x| If( Len( x ) = 6, aAdd( uSetFocus, x ), NIL ) } )
      ELSEIF ValType( uSetFocus ) = "C"
         uSetFocus := { uSetFocus }
      ENDIF

      FOR nCount := 1 TO Len( uSetFocus )
         IF ! GetProperty( mxWFObj():cName, uSetFocus[ nCount ], "Cargo" )[1] .AND. GetProperty( mxWFObj():cName, uSetFocus[ nCount ], "Enabled" )
            _SetFocus( uSetFocus[ nCount ], mxWFObj():cName )
            EXIT
         ENDIF
      NEXT

   ELSEIF ValType( uActivate ) = "N"

      DO CASE
         CASE uActivate = K_CONSULTAR ; _SetFocus( "oBtOk", mxWFObj():cName )
         CASE uActivate = K_EXCLUIR   ; _SetFocus( "oBtNo", mxWFObj():cName )
      ENDCASE

   ENDIF

   mxWFObj():lVldGets := lActivate

   lValidando     := .F.
   lValidaEntrada := .F.
   cGetNoValid    := ""

RETURN( NIL )



PROCEDURE mxWGChangePage( ;          // Muda de pagina apos a digitacao do primeiro/ultimo get
                          lReturn,;
                          aGets ;
                        )

   /* PROGRAMACAO NAO FINALIZADA

   LOCAL nPos     := aScan( aGets, _cGet )
	LOCAL cPageAux := "oTabPage" + NumToStr( GetProperty( mxWFObj():cName, "oTabPage", "Value" ) )
	LOCAL lShift
	
	IF lReturn .AND. nPos > 0
	   
		lShift := CheckBit( GetKeyState( VK_SHIFT ), 32768 )
		
		IF Mod( nPos, 2 ) > 0
			IF mxLastKey() = 38 .OR. ( lShift .AND. mxLastKey() = 9 )  // Up/Shift+Tab
		      SetProperty( mxWFObj():cName, cPageAux, "Value", GetProperty( mxWFObj():cName, cPageAux, "Value" ) -1 )
		      _cGet := aGets[ nPos -1 ]
		      _SetFocus( _cGet, mxWFObj():cName )
			ENDIF
		ELSEIF ( ! lShift ) .AND. mxIn( mxLastKey(), { 9, 13, 40 } ) // Tab/Enter/Down
		   IF nPos = Len( aGets )
		      _SetFocus( "oBtOk", mxWFObj():cName )
		   ELSE
		      SetProperty( mxWFObj():cName, cPageAux, "Value", GetProperty( mxWFObj():cName, cPageAux, "Value" ) +1 )
	  		   _cGet := aGets[ nPos +1 ]
	         _SetFocus( _cGet, mxWFObj():cName )
			ENDIF   
		ENDIF		

	ENDIF
	*/
	
RETURN( NIL )



STATIC PROCEDURE mxWGCalendar  // Exibe calendario p/ ajuda/selecao

   /* PROGRAMACAO NAO FINALIZADA

   LOCAL cForm  := ThisWindow.Name
   LOCAL cName  := ThisWindow.FocusedControl
   LOCAL nRow   := ThisWindow.Row + GetProperty( cForm, cName, "Row" ) 
   LOCAL nCol   := ThisWindow.Col + GetProperty( cForm, cName, "Col" ) +3
   LOCAL dValue := GetProperty( cForm, cName, "Value" )
   
   IF mxWFObj():cModel = "RPT"
      nRow += 52
   ELSEIF nRow +175 > mxWFObj():nHeight
      nRow -= 76
   ELSEIF _IsControlDefined( "oTabPage2", cForm )
      nRow += 145
   ELSE   
      nRow += 122
   ENDIF   

   DEFINE WINDOW frCalendar ;
      AT     nRow, nCol ;
      WIDTH  192 ;
		HEIGHT 175 ;
      CHILD ;
      NOSIZE ;
      NOCAPTION ;
      NOSYSMENU ;
      ON LOSTFOCUS mxDoMethod( "frCalendar", "Release" )

      DEFINE MONTHCALENDAR WG_CALENDAR
         ROW       00
         COL       00
         VALUE     GetNoEmpty( dValue, Date() )
         ON CHANGE SetProperty( cForm, cName, "Value", frCalendar.WG_CALENDAR.Value ) 
      END MONTHCALENDAR
            
      ON KEY ESCAPE        ACTION ( SetProperty( cForm, cName, "Value", dValue ), mxDoMethod( "frCalendar", "Release" ) )
      ON KEY RETURN        ACTION frCalendar.Release
      ON KEY LEFT          ACTION frCalendar.WG_CALENDAR.Value := frCalendar.WG_CALENDAR.Value -1
      ON KEY RIGHT         ACTION frCalendar.WG_CALENDAR.Value := frCalendar.WG_CALENDAR.Value +1
      ON KEY UP            ACTION frCalendar.WG_CALENDAR.Value := frCalendar.WG_CALENDAR.Value -7
      ON KEY DOWN          ACTION frCalendar.WG_CALENDAR.Value := frCalendar.WG_CALENDAR.Value +7
      ON KEY SPACE         ACTION frCalendar.WG_CALENDAR.Value := Date()
      ON KEY CONTROL+LEFT  ACTION frCalendar.WG_CALENDAR.Value := frCalendar.WG_CALENDAR.Value -30
      ON KEY CONTROL+RIGHT ACTION frCalendar.WG_CALENDAR.Value := frCalendar.WG_CALENDAR.Value +30

   END WINDOW

   frCalendar.Activate
   */

RETURN( NIL )



PROCEDURE mxWGDescricao( ;         // Atribui a descricao de um campo relacionado ao edit
                         cCampo,;  // Nome do edit
                         cDescr ;  // Nome do campo q contem a descricao
                       )
	
   LOCAL cAlias := Right( cDescr, 3 )
   LOCAL cLabel := "lb" + cCampo + "_" + cAlias
   LOCAL uCampo := GetProperty( mxWFObj():cName, cCampo, "Value" )
   
   fmtAlias( @cAlias )

   IF ( cAlias )->( mxSeek( 1, uCampo ) )
      mxSetValue( cLabel, Trim( ( cAlias )->( &( sisFlgModule() + cDescr ) ) ) )
   ELSE
      mxSetValue( cLabel, "" )
   ENDIF

RETURN( NIL )	



FUNCTION mxWGList( ;            // Exibe lista p/ ajuda/selecao
                   cList,;      // Parametro cList de mxWGValid
                   lListOnly ;  // Apenas abre a lista sem ter um get vinculado
                 )
                  
   LOCAL aState := SaveState()
   LOCAL cTitle := "Localizar "
   LOCAL cForm  := ThisWindow.Name
   LOCAL cName  := ThisWindow.FocusedControl
   LOCAL nCount := 0

   LOCAL cAlias, cDescr, cAux, lReadOnly

   PRIV WGLCAMPO := {}
   PRIV ORDWGL   := 0
   
	PRIV oWFList, uCodigo

   vDef( @lListOnly, .F. )
   
   BEGIN SEQUENCE

      IF ! lListOnly
      
         IF Empty( cName )
            BREAK
         ENDIF

         lReadOnly := GetProperty( cForm, cName, "Cargo" )[1]

      	IF lReadOnly
      	   _SetNextFocus()
         ENDIF

      ENDIF
      
      DO WHILE ! Empty( cList )

         cAux  := Left( cList, At( "|", cList ) -1 )
         cList := Subs( cList, At( "|", cList ) +1 )

         nCount ++

         DO CASE
            CASE nCount = WG_LIST_ALIAS ; cAlias := cAux
            CASE nCount = WG_LIST_DESCR ; cDescr := cAux
         ENDCASE

      ENDDO
      
      IF Empty( cDescr )
         cDescr := NIL
      ENDIF

      IF cDescr <> NIL
         cDescr := fmtAlias( cAlias ) + "->" + sisFlgModule() + cDescr + cAlias
      ENDIF

      TRY
         HB_ExecFromArray( "WG_ListParam", { cAlias, @cTitle, @WGLCAMPO, @ORDWGL } )
      CATCH
         WGLCAMPO := NIL
      END
      
      IF WGLCAMPO = NIL
         BREAK
      ENDIF

      ( fmtAlias( cAlias ) )->( mxOrder( ORDWGL ) )

      IF ( fmtAlias( cAlias ) )->( Eof() )
         ( fmtAlias( cAlias ) )->( mxTop() )
      ENDIF

      oWFList := mxWForm():New( "frList", 800, 498, cTitle, { "K_WGList" } )

      DEFINE WINDOW frList ;
      	AT           0, 0 ;
       	WIDTH        oWFList:nWidth ;
         HEIGHT       oWFList:nHeight ;
         TITLE        oWFList:cTitleTop ;
         MODAL ;
         NOSIZE ;
         NOSYSMENU ;
         ON INIT      oWFList:OnInit() ;
         ON GOTFOCUS  oWFList:OnGotFocus() ;
         ON LOSTFOCUS oWFList:OnLostFocus() ;
         ON RELEASE   oWFList:OnRelease() ;
         ON MOVE      oWFList:OnMove() ;
         BACKCOLOR    oWConfig:Color_Form

         DEFINE LABEL lbList
            ROW         07
            COL         50
            VALUE       oWFList:cTitle
      		TOOLTIP     oWFList:cTitle
      		WIDTH       oWFList:Page_nWidth
      		FONTSIZE    15
            TRANSPARENT .T.
      		CENTERALIGN .F.
      		FONTBOLD    .F.
      		FONTCOLOR   { 255, 255, 255 }
      	END LABEL

      	DEFINE IMAGE imList1
   	   	ROW     00
   			COL     00
         	WIDTH   46
      	   HEIGHT  40
         	PICTURE imgFile( "barrap_icone" )
      		STRETCH .T.
    		END IMAGE

   		DEFINE IMAGE imList2
   	   	ROW     00
   			COL     46
         	WIDTH   oWFList:Page_nWidth
      	   HEIGHT  40
         	PICTURE imgFile( "barrap_titulo" )
      		STRETCH .T.
    		END IMAGE

   		DEFINE LABEL lbSearch
   			COL         08
   			ROW         53
   			VALUE       "Texto para pesquisa :"
   			TRANSPARENT .T.
   		END LABEL

   	 	DEFINE GETBOX edSearch
            COL         135
            ROW         49
            HEIGHT      23
            WIDTH       oWFList:Page_nWidth -260
            VALUE       Space(200)
            FONTNAME    oWConfig:FontName_Get
            FONTSIZE    oWConfig:FontSize_Get
            FONTCOLOR   oWConfig:Color_GetFont
            BACKCOLOR   oWConfig:Color_GetBack
            ON GOTFOCUS _PushKey( VK_HOME )
   		END GETBOX

   		DEFINE BUTTONEX oBtPesq
         	ROW      49
         	COL      oWFList:Page_nWidth -115
         	WIDTH    100
      		HEIGHT   23
         	CAPTION  "Pesquisar"
         	TOOLTIP  "Pesquisar"
            FONTNAME oWConfig:FontName_Button
            FONTSIZE oWConfig:FontSize_Button
        		ACTION   K_WGList()
      	END BUTTONEX

    		DEFINE BUTTONEX oBtOk
         	ROW      oWFList:nHeight -61
         	COL      oWFList:BtOk_nCol
         	WIDTH    100
      		HEIGHT   27
         	CAPTION  "Confirmar"
         	TOOLTIP  "Confirma operação"
     	      FONTNAME oWConfig:FontName_Button
            FONTSIZE oWConfig:FontSize_Button
            PICTURE  imgFile( "bt_ok" )
        		ACTION   K_WGList( K_ENTER )
      	END BUTTONEX

      	DEFINE BUTTONEX oBtNo
         	ROW      oWFList:nHeight -61
         	COL      oWFList:BtNo_nCol
         	WIDTH    100
         	HEIGHT   27
         	CAPTION  "Cancelar"
         	TOOLTIP  "Cancela operação"
            FONTNAME oWConfig:FontName_Button
            FONTSIZE oWConfig:FontSize_Button
            PICTURE  imgFile( "bt_no" )
         	ACTION   mxDoMethod( "frList", "Release" )
      	END BUTTONEX

         mxWBrowse( WGLCAMPO, "ORDWGL", { 80, NIL, oWFList:Page_nHeight -44 } )

      END WINDOW

      ON KEY ALT+F4 OF frList ACTION mxDoMethod( "frList", "Release" )
      ON KEY ESCAPE OF frList ACTION mxDoMethod( "frList", "Release" )

      SetProperty( oWFList:cName, "BackColor", oWConfig:Color_Form )

   	mxWSetStyle( GetFormHandle( oWFList:cName ) )

      mxBrwRefresh( BRW_MAIN )

      mxDoMethod( "frList", "Center" )
      mxDoMethod( "frList", "Show" )
      _SetFocus( BRW_MAIN, "frList" )
      mxDoMethod( "frList", "Activate" )
      
      IF lListOnly

         _RestoreWindow( cForm )
         
      ELSE

         IF uCodigo <> NIL
         	SetProperty( cForm, cName, "Value", uCodigo )
         ENDIF

         IF cDescr <> NIL
            SetProperty( cForm, "lb" + cName + "_" + cAlias, "Value", Trim( &cDescr ) )
         ENDIF

         _RestoreWindow( cForm )
      	_SetFocus( cName, cForm )

         IF uCodigo <> NIL
      	   _SetNextFocus()
         ENDIF

      ENDIF

   ENDSEQUENCE

   RestState( aState, .T., .T., .F., .F. )

RETURN( uCodigo )



PROCEDURE K_WGList( ;         // Controla as teclas pressionadas no browse da lista de ajuda
                    nEvent ;  // Codigo da tecla pressionada no browse da lista de ajuda
                  )

   TRY
      uCodigo := HB_ExecFromArray( "WG_ListControl", { fmtAlias( Alias(), 3 ), nEvent, ORDWGL, frList.edSearch.Value } )
   CATCH
      uCodigo := NIL
   END

   IF nEvent = NIL
      _SetFocus( BRW_MAIN, "frList" )
   ELSEIF uCodigo <> NIL
      mxDoMethod( "frList", "Release" )
   ENDIF

RETURN( NIL )



FUNCTION mxWGValidCod( ;           // Verifica se o codigo digitado existe na lista de ajuda
                       uCod,;      // Valor do codigo
                       cAlias,;    // Nome do alias da lista de ajuda
                       nOrder,;    // Ordem de pesquisa
                       cDesc,;     // Informacoes sobre a descricao do campo a ser exibido
                       lRestPos ;  // Se TRUE retorna a posicao original do alias
                     )

   LOCAL lReturn := .F.

	LOCAL nRec, cLabel, cCampo

   vDef( @lRestPos, .F. )

   fmtAlias( @cAlias )

   IF lRestPos
	   nRec := ( cAlias )->( mxRecNo() )
	ENDIF

   IF Empty( uCod )
      lReturn := .T.
   ELSE
      lReturn := ( cAlias )->( mxSeek( nOrder, { uCod } ) )
   ENDIF

   IF cDesc <> NIL
	   cCampo := cAlias + "->" + sisFlgModule() + Subs( cDesc, At( "|", cDesc ) +1 )
	   cLabel := "lb" + Left( cDesc, At( "|", cDesc ) -1 ) + "_" + fmtAlias( cAlias, 3 )
      mxSetValue( cLabel, If( lReturn .AND. ! Empty( uCod ), Trim( &cCampo ), "" ) )
	ENDIF

	IF ! lReturn
	   MsgInfo( "Código não incluso !", MSG_TITLE )
	ENDIF

	IF lRestPos
      ( cAlias )->( mxGoTo( nRec ) )
   ENDIF

RETURN( lReturn )



FUNCTION mxWGCheckValid( ;           // Executa as validacoes ainda nao realizadas dos edit's
                         aGets,;     // Array com o nome dos edit's
                         cCplName ;  // Complemento do nome dos edit's (caso seja passado o nome com apenas com 3 caracters)
                       )

   LOCAL lReturn  := .T.
   LOCAL cFocused := GetProperty( mxWFObj():cName, "FocusedControl" )

   LOCAL nCount, cName, lValid

   vDef( @aGets, mxWFObj():aGets )
   
   FOR nCount := 1 TO Len( aGets )
   
      cName := aGets[ nCount ]
      IF cCplName <> NIL .AND. Len( cName ) = 3
         cName += cCplName
      ENDIF

      IF ! _IsControlDefined( cName, mxWFObj():cName )
         LOOP
      ENDIF
      
      lValid := GetProperty( mxWFObj():cName, cName, "Cargo" )[3]

      IF ! lValid
         IF ! mxWGValid( NIL, cName )
            lReturn := .F.
            EXIT
         ENDIF
      ENDIF

   NEXT

   IF lReturn
      _SetFocus( cFocused, mxWFObj():cName )
   ENDIF

RETURN( lReturn )



FUNCTION mxWGTxtLabel( ;        // Retorna o texto do label de um edit
                       cName ;  // Nome do edit
                     )

   LOCAL cReturn := ""
   
   cName := "lb" + cName
   
   IF _IsControlDefined( cName, mxWFObj():cName )
      cReturn := AllTrim( GetProperty( mxWFObj():cName, cName, "Value" ) )
   ENDIF

RETURN( cReturn )