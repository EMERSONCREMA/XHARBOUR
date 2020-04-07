/*

 MaxWBrw.prg
 WinBrowse Library: Funcoes p/ exibicao de listas.

 DENIS MAZZUCATTO RODRIGUES
 03/12/15 * Corrigido refresh da lista ao utilizar CTRL+PGUP e CTRL+PGDN.
 02/12/15 * Desenvolvimento e implementacao de brAddTitleClick e brTitleClick.
          * Definida uma cor diferente p/ o titulo das colunas q permitem
            ordenacao.
 01/09/10 * Inicio do desenvolvimento.

*/

#include "inkey.ch"
#include "minigui.ch"
#include "tsbrowse.ch"
#include "maxwin.ch"

STATIC cBrwName, _aImg

PROCEDURE mxWBrowse( ;
                     aCols,;      // Array com as definicoes das colunas
                     cOrder,;     // Nome da variavel q controla a ordenacao
                     uPos,;       // Coordenadas da posicao onde o browse sera exibido
                     cName,;      // Nome do objeto a ser criado
                     cAlias,;     // Nome do arquivo q contem os dados
                     cFuncKey,;   // Funcao p/ controle das teclas pressionadas no browse
                     uFuncStat ;  // Funcao p/ exibicao de status
                   )
   /*
   Elementos de aCols:
   1º = ordem do indice
   2º = nome do campo ou funcao q ira tratar as informacoes do campo
   3º = titulo da coluna
   */

   LOCAL bFuncKey, bFuncStat, bColumn, bColor, bParam1, bParam2
	LOCAL nWidth, nWidthPage, nSize, nAlign, nTop, nLeft, nHeight
   LOCAL nCols, nDef, nLen, nAux, uConf, lHScroll, aTitleClick
	
   PRIV cForm := mxWFObj():cName

   IF cName = NIL
      cBrwName  := BRW_MAIN
      cAlias    := mxWFObj():cAlias
      cFuncKey  := mxWFObj():GetFunc( "BrwKeys" )
	   uFuncStat := mxWFObj():GetFunc( "BrwStat" )
   ELSE
      cBrwName := "oBrw" + cName
   ENDIF

   IF ValType( uPos ) = "A"
      aSize( uPos, 4 )
	   nTop       := uPos[1]
	   nLeft      := uPos[2]
	   nHeight    := uPos[3]
      nWidthPage := uPos[4]
	ELSE
	   nTop := uPos
	ENDIF   
	   
 	vDef( @nTop      , 21 )
	vDef( @nLeft     ,  0 )
	vDef( @nHeight   , mxWFObj():Page_nHeight -22 )
	vDef( @nWidthPage, mxWFObj():Page_nWidth )
	
   lHScroll := .F.

   nWidth := Negativa( nLeft )
	
	brLoadImages()

   TRY
      bParam1 := HB_ExecFromArray( "WB_Param", { "BmpCell", _aImg } )
   CATCH
      bParam1 := NIL
   END
	
   TRY
      bParam2 := HB_ExecFromArray( "WB_Param", { "RecGrid" } )
   CATCH
      bParam2 := NIL
   END
   
   vDef( @bParam2, { || oWConfig:Color_BrwRecGrid } )

	IF ValType( uFuncStat ) = "B"
	   bFuncStat := uFuncStat
	ELSE
		IF uFuncStat = NIL
		   uFuncStat := ".T."
		ELSE  
		   uFuncStat += "()"
		ENDIF
      uFuncStat := "{ || " + uFuncStat + "}"
      bFuncStat := &uFuncStat
   ENDIF
   
	IF bParam1 <> NIL
	   aAdd( aCols, { NIL, "''", "" } )
	ENDIF   
	
	nLen := Len( aCols )

   aTitleClick := {}

   FOR nCols := 1 TO nLen
      brAddTitleClick( @aTitleClick, nCols, aCols, cOrder )
   NEXT

   IF _IsControlDefined( cBrwName, cForm )
      _ReleaseControl( cBrwName, cForm )
   ENDIF

   DEFINE TBROWSE &cBrwName ;
		AT            nTop, nLeft ;
      PARENT        &cForm ;
		ALIAS         cAlias ;
      WIDTH         0 ;
      HEIGHT        nHeight ;
      FONT          oWConfig:FontName_Brw ;
      SIZE          oWConfig:FontSize_Brw ;
      ON GOTFOCUS   cBrwName := GetNoEmpty( _GetFocusedControl( mxWFObj():cName ), cBrwName ) ;
      ON CHANGE     Eval( bFuncStat ) ;
      ON HEADCLICK  aTitleClick ;
      ON DBLCLICK   brKeyPress( K_ENTER, NIL, NIL, "NK" )
      
		mxBrwObj( cBrwName ):SetColor( { 1, 3, 5, 6, 13, 15 }, ;
                                     { ;
               							   bParam2                                           ,;  // Texto registro inativo
               							   oWConfig:Color_BrwTitle                           ,;  // Texto do titulo
               							   oWConfig:Color_BrwRecBar                          ,;  // Texto registro ativo
               							   { oWConfig:Color_BrwBar1, oWConfig:Color_BrwBar2 },;  // Barra do cursor ativo
                                       CLR_BLACK                                         ,;
                 							   oWConfig:Color_BrwGrid                             ;  // Linhas da grade
                                     } )

		mxBrwObj( cBrwName ):SetColor( { 2, 4, 14 }, ;
                                     { ;
                  						   oWConfig:Color_BrwGridBack                                    ,;  // Cor de fundo dos registros inativos
                                       { oWConfig:Color_BrwTitleBack1, oWConfig:Color_BrwTitleBack2 },;  // Cor de fundo do titulo
                                       NIL                                                            ;
                 							 } )

      FOR nDef := 1 TO 2

			FOR nCols := 1 TO nLen

				bColumn := aCols[ nCols, 2 ]
            nAlign  := NIL

            IF ValType( bColumn ) = "C"
            
               IF "PadC(" $ bColumn
                  nAlign  := DT_CENTER
                  bColumn := AllTrim( Left( Subs( bColumn, 6 ), Len( bColumn ) -6 ) )
               ELSEIF "Tran(" $ bColumn
                  nAlign := DT_RIGHT
               ENDIF
               
               uConf := "{ || " + cAlias + "->(" + bColumn + ") }"

               IF ValType( Eval( &uConf ) ) = "D"
                  bColumn := "{ || " + cAlias + "->( YearTwo( " + bColumn + " ) ) }"
                  nAlign  := DT_CENTER
               ELSE
                  bColumn := uConf
               ENDIF

					bColumn := &bColumn

            ENDIF

            IF bParam1 <> NIL .AND. nCols = nLen
               nAlign := { || nMakeLong( DT_CENTER, DT_CENTER, DT_CENTER ) }
				ENDIF

            uConf := Eval( bColumn )

            IF ValType( uConf ) = "N"

               nSize  := Len( Str( uConf ) )
               nAlign := DT_RIGHT

            ELSEIF ValType( uConf ) = "D"

               nSize  := Len( DtoC( uConf ) )
               nAlign := DT_CENTER

            ELSE

               nSize := Len( uConf )

               vDef( @nAlign, DT_LEFT )

            ENDIF

            nSize := Max( Max( nSize, Len( brColTitle( aCols[ nCols ], .T. ) ) ), 2 )

				IF bParam1 <> NIL .AND. nCols = nLen
				   nSize := 38
				ELSE
				   nSize *= 8.5
				ENDIF

				IF nDef = 1
               nWidth += nSize
            ELSE
               nAux := ( nWidthPage - nWidth -5 )
               IF nAux <= 0
                  lHScroll := .T.
               ELSEIF bParam1 = NIL
                  nSize += Int( nAux / nLen )
                  IF nCols = nLen
                     nSize += 4
                  ENDIF
               ELSEIF nCols < nLen
                  nSize += Int( nAux / ( nLen -1 ) )
                  IF nCols = nLen -1
                     nSize += Mod( nAux, nLen -1 )
                  ENDIF
	            ENDIF

	      	   IF aCols[ nCols, 1 ] = NIL
	               bColor := NIL
			      ELSE
						bColor := "{ || If( " + cAlias + "->( IndexOrd() ) = " + UtoC( aCols[ nCols, 1 ] ) + ", " + NumToStr( oWConfig:Color_BrwGridOrder ) + ", " + NumToStr( oWConfig:Color_BrwGridBack ) + " ) }"
			         bColor := &bColor
			      ENDIF

               ADD COLUMN TO TBROWSE &cBrwName ;
						DATA   bColumn ;
                  TITLE  "" ;
                  SIZE   nSize ;
                  ALIGN  nAlign, DT_CENTER, DT_CENTER ;
                  COLORS NIL, bColor

	      	   IF aCols[ nCols, 1 ] <> NIL
                   mxBrwObj( cBrwName ):SetColor( { 3 }, { oWConfig:Color_BrwTitleOrder }, nCols )
			      ENDIF

            ENDIF

         NEXT

		NEXT

   	brColTitle( aCols )

   	IF bParam1 <> NIL
   	   mxBrwObj( cBrwName ):aColumns[ nLen ]:uBmpCell := bParam1
   	ENDIF

      mxBrwObj( cBrwName ):nHeightHead := 23
      mxBrwObj( cBrwName ):nHeightCell := 19
   	mxBrwObj( cBrwName ):lNoMoveCols := .T.
      mxBrwObj( cBrwName ):lNoHScroll  := ( ! lHScroll )
      mxBrwObj( cBrwName ):lNoResetPos := .T.

      IF lHScroll
         mxBrwObj( cBrwName ):nFreeze := 1
      ENDIF

      IF cFuncKey <> NIL
         mxBrwObj( cBrwName ):bKeyDown := { |k| brKeyPress( k, aCols, cOrder, "FX" ) }  // Controla as teclas de funcao (F?)
         mxBrwObj( cBrwName ):bKeyChar := { |k| brKeyPress( k, aCols, cOrder, "NK" ) }  // Controla as demais teclas
      ENDIF

      ON KEY CONTROL+PRIOR ACTION brKeyPress( K_CTRL_PGUP, NIL, NIL, "CP" )
      ON KEY CONTROL+NEXT  ACTION brKeyPress( K_CTRL_PGDN, NIL, NIL, "CP" )

   END TBROWSE

	SetProperty( mxWFObj():cName, cBrwName, "Width", nWidthPage -2 - nLeft )

RETURN( NIL )



FUNCTION brColTitle( ;         // Monta o titulo das colunas
                     aCols,;   // Array com as definicoes das colunas
                     lTitle ;  // Se TRUE retorna o titulo da coluna
                   )
   
   LOCAL nCol, cTitle, bColor

   vDef( @lTitle, .F. )

   IF lTitle
   
      cTitle := aCols[ 3 ]

      IF ValType( cTitle ) = "B"
         cTitle := Eval( cTitle )
      ENDIF

   ELSE

      FOR nCol := 1 TO Len( aCols )

         cTitle := aCols[ nCol, 3 ]

         IF ValType( cTitle ) = "B"
            cTitle := Eval( cTitle )
         ENDIF

         mxBrwObj( cBrwName ):aColumns[ nCol ]:cHeading := cTitle

      NEXT

      mxBrwObj( cBrwName ):Refresh(.T.)

   ENDIF

RETURN( cTitle )



STATIC PROCEDURE brAddTitleClick( aTitleClick, nCols, aCols, cOrder )

   aAdd( aTitleClick, { || brTitleClick( nCols, aCols, cOrder ) } )

RETURN( NIL )



PROCEDURE brTitleClick( ;         // Muda a ordem da lista ao clicar no titulo da coluna
                        nCol,;    // Numero da coluna
                        aCols,;   // Array com as definicoes das colunas
                        cOrder ;  // Nome da variavel q controla a ordenacao
                      )

   IF cOrder <> NIL .AND. aCols[ nCol, 1 ] <> NIL

      SeleArea( mxBrwObj( cBrwName ):cAlias )

      &cOrder := If( ValType( aCols[ nCol, 1 ] ) = "C", &( aCols[ nCol, 1 ] ), aCols[ nCol, 1 ] )

	   mxOrder( &cOrder )
      mxBrwObj( cBrwName ):Refresh(.T.)

   ENDIF

RETURN( NIL )



FUNCTION brKeyPress( ;         // Captura as teclas pressionadas na lista
                     nKey,;    // Codigo da tecla pressionada
                     aCols,;   // Array com as definicoes das colunas
                     cOrder,;  // Nome da variavel q controla a ordenacao
                     cKey ;    // CP = Controla as teclas CTRL+PAGE? / FX = Controla as teclas de funcao (F?) / NK = Controla as demais teclas
                   )
                   
   LOCAL nCol, nOrder

   BEGIN SEQUENCE
   
      IF cKey = "CP"

         IF mxIn( nKey, { K_CTRL_PGUP, K_CTRL_PGDN } ) .AND. _GetFocusedControl( mxWFObj():cName ) = cBrwName
         
            DO CASE
               CASE nKey = K_CTRL_PGUP ; mxBrwObj( cBrwName ):GoTop()
               CASE nKey = K_CTRL_PGDN ; mxBrwObj( cBrwName ):GoBottom()
            ENDCASE

            mxBrwReturn( mxWFObj():cName )
      
         ENDIF

         BREAK

      ENDIF

      PRIV cFuncKey := mxWFObj():GetFunc( "BrwKeys" )

      SeleArea( mxBrwObj( cBrwName ):cAlias )

	   IF cKey = "NK" .AND. ;
	      ( ( nKey > 64 .AND. nKey <  91 ) .OR. ;
		     ( nKey > 96 .AND. nKey < 123 ) .OR. ;
		     ( nKey > 47 .AND. nKey <  58 ) )

		   IF mxWFObj():GetFunc( "BrwSeek" ) <> NIL
    		   _SetFocus( "edSearch", mxWFObj():cPanelTBar )
			   SetProperty( mxWFObj():cPanelTBar, "edSearch", "Value", Chr( nKey ) + Space(199) )
			   _PushKey( VK_END )
			   mxBrwSearch()
			   IF cOrder <> NIL
               &cOrder := IndexOrd()
            ENDIF
		   ENDIF
		   BREAK
		  
      ENDIF

	   IF cKey = "FX"
         IF nKey = 122  // F11
            nKey := -40
         ELSEIF nKey = 123  // F12
		      nKey := -41
		   ELSEIF mxIntervalo( nKey, 113, 121, .F. )
		      nKey := Negativa( nKey -112 )  // F2 - F10
		   ENDIF
         IF ! mxIntervalo( nKey, -9, -2, .F. ) .AND. ! mxIn( nKey, { -40, -41 } )
            BREAK
         ENDIF
      ENDIF

      IF cOrder <> NIL .AND. nKey = K_F4

         nOrder := &cOrder

		   nCol := aScan( aCols, { |x| x[1] <> NIL .AND. nOrder = If( ValType( x[1] ) = "C", &( x[1] ), x[1] ) } )
		  
		   DO WHILE .T.
		      nCol ++
		      IF nCol > Len( aCols )
		         nCol := 1
            ENDIF
		      IF aCols[ nCol, 1 ] <> NIL
		         &cOrder := If( ValType( aCols[ nCol, 1 ] ) = "C", &( aCols[ nCol, 1 ] ), aCols[ nCol, 1 ] )
		         EXIT
		      ENDIF
         ENDDO

         nOrder := &cOrder
		  
		   mxOrder( nOrder )
	      mxBrwObj( cBrwName ):Refresh(.T.)

	   ELSE

         &cFuncKey( nKey )

	   ENDIF

   ENDSEQUENCE

RETURN( NIL )



STATIC PROCEDURE brLoadImages  // Carrega as imagens q serao utilizadas na coluna de identificacao do registro
   
	IF _aImg = NIL
	
	   _aImg := {}
		aSize( _aImg, 4 )

	   _aImg[ BT_VERDE    ] := LoadImage( imgFile( "brw_verde" ) )
	   _aImg[ BT_VERMELHO ] := LoadImage( imgFile( "brw_vermelho" ) )
	   _aImg[ BT_AZUL     ] := LoadImage( imgFile( "brw_azul" ) )
	   _aImg[ BT_AMARELO  ] := LoadImage( imgFile( "brw_amarelo" ) )

	ENDIF

RETURN( NIL )



PROCEDURE mxBrwSearch( ;        // Efetua a pesquisa na lista
                       bSeek ;  // Funcao alternativa p/ efetuar a procura
                     )

   LOCAL cSeek, nRecno

   PRIV cFuncPesq
   
   IF bSeek = NIL
      cSeek := Trim( GetProperty( mxWFObj():cPanelTBar, "edSearch", "Value" ) )
      IF Empty( cSeek )
         RETURN( NIL )
      ENDIF
      cFuncPesq := mxWFObj():GetFunc( "BrwSeek" )
		&cFuncPesq( cSeek )
   ELSE
      Eval( bSeek )
   ENDIF

	IF Eof()
	   mxBrwObj( cBrwName ):GoBottom()
	ELSE
      mxBrwObj( cBrwName ):Seek( cSeek )
		nRecno := mxRecno()
		mxBrwObj( cBrwName ):GoUp()
		IF ! mxBrwObj( cBrwName ):lHitTop
		   mxBrwObj( cBrwName ):GoDown()
		ENDIF
		mxGoTo( nRecno )
	ENDIF	

   mxBrwObj( cBrwName ):Refresh(.T.)
	mxBrwObj( cBrwName ):UpStable()
	mxBrwObj( cBrwName ):DrawSelect()
	
RETURN( NIL )



PROCEDURE mxBrwRefresh( ;           // Atualiza o browse
                        cBrwName,;  // Nome do browse
                        uType ;     // Tipo do refresh
                      )

   LOCAL nLen   := 0
   LOCAL nRecno := ( mxBrwObj( cBrwName ):cAlias )->( Recno() )
   
   vDef( @cBrwName, BRW_MAIN )
   vDef( @uType   , BRW_REFRESH_TOP )

   csStatus( "" )

   IF Empty( ( mxBrwObj( cBrwName ):cAlias )->( dbFilter() ) )
      nLen := ( mxBrwObj( cBrwName ):cAlias )->( LastRec() )
   ELSE
      ( mxBrwObj( cBrwName ):cAlias )->( dbEval( { || nLen ++ } ) )
   ENDIF
      
   mxBrwObj( cBrwName ):nLen := nLen
   
   DO CASE
      CASE uType = BRW_REFRESH_TOP

           mxBrwObj( cBrwName ):GoBottom()
           mxBrwObj( cBrwName ):UpStable()
           mxBrwObj( cBrwName ):Refresh(.T.)
           mxBrwObj( cBrwName ):GoTop()
           mxBrwObj( cBrwName ):Display()

           ( mxWFObj():cAlias )->( mxTop() )

      CASE uType = BRW_REFRESH_BOTTOM

           mxBrwObj( cBrwName ):GoTop()
           mxBrwObj( cBrwName ):UpStable()
           mxBrwObj( cBrwName ):Refresh(.T.)
           mxBrwObj( cBrwName ):GoBottom()
           mxBrwObj( cBrwName ):Display()

           ( mxWFObj():cAlias )->( mxBottom() )

      CASE uType = BRW_REFRESH_RECNO

           mxBrwRefresh( cBrwName, BRW_REFRESH_BOTTOM )

           ( mxWFObj():cAlias )->( mxGoTo( nRecno ) )

   ENDCASE

   _SetFocus( cBrwName, mxWFObj():cName )

RETURN( NIL )



FUNCTION mxBrwReturn( ;
                      cForm,;
                      nReturn,;
                      nOrd ;
                    )

   vDef( @nReturn, 2 )

   IF _IsControlDefined( "oTabPage", cForm ) .AND. GetProperty( cForm, "oTabPage", "Value" ) = 1

      mxWFActive( cForm )

      SeleArea( mxWFObj():cAlias )

      IF nOrd <> NIL
         mxOrder( nOrd )
      ENDIF

      mxBrwObj():Refresh( nReturn = 0 )

      _SetFocus( "oBrw" + Subs( cForm, 3 ), cForm )

   ENDIF

RETURN( nReturn )