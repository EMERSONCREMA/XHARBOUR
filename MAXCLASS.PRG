/*

 MaxClass.prg
 Descricao: Classe para exibicao de dados em forma de lista.
 Desenvolvido por MAX SCALLA Informatica Ltda.

 EMERSON DA SILVA CREMA
 21/08/13 * Correcao da pesquisa qdo se usava numero, dava "abound error".
 
 DENIS MAZZUCATTO RODRIGUES
 29/12/11 * Corrigido calculo de nWidth.
 26/11/09 * Correcoes p/ implementacao do xHarbour.

 EMERSON DA SILVA CREMA
 09/08/06 * Implementada a propriedade Status.
 14/12/05 * Implementada propriedade MaxMark.
 27/10/04 * Corrigido retorno do evento Show(), pois qdo abandonava-se (ESC),
            estava retornando uma matriz vazia.
 16/04/04 * Inicio do desenvolvimento.

*/

#include "std.ch"
#include "inkey.ch"
#include "hbclass.ch"

/*---------------------------------------------------------------------------
 Nome da classe : listSelect

 Exibe um checklist baseado em uma matriz.

 Propriedades :

 ListSel     : Matriz para selecao
 Title       : Titulo da lista
 MarkOn      : Simbolo para o item marcado
 MarkOff     : Simbolo para o item desmarcado
 lsRow       : Linha Inicial
 lsCol       : Coluna Inicial
 nItens      : Numero de itens da lista
 ColorAtiv   : Cor do item ativo
 ColorInat   : Cor do item inativo
 ColorSele   : Cor do item selecionado
 ColorBorder : Cor da borda da janela
 ColorTitle  : Cor do titulo da janela
 KeySave     : Tecla para confirmacao
 Execute     : Bloco ou matriz de blocos de codigo a serem executados
 Mask        : Mascaras de exibicao das colunas
 Columns     : Numero das colunas da matriz q serao exibidas
 DefSearch   : Se .T., permite a localizacao do item na lista
 NoBorder    : Se .T., nao havera borda e titulo
 NoStatus    : Se .T., nao havera linha de status (ultima linha)
 Status      : Define a mensagem da linha de status
 RestScr     : Se .T., restaura a tela anterior
 MaxMark     : Numero maximo de itens que podem ser selecionados

 Eventos

 New  : Inicia o objeto
 Show : Executa o objeto

 Retorno : Matriz com os itens selecionados.
----------------------------------------------------------------------------*/

CLASS listSelect

   VAR ListSel
   VAR Title
   VAR MarkOn
   VAR MarkOff
   VAR lsRow
   VAR lsCol
   VAR nItens
   VAR ColorAtiv
   VAR ColorInat
   VAR ColorSele
   VAR ColorBorder
   VAR ColorTitle
   VAR KeySave
   VAR Execute
   VAR KeyBlock
   VAR Mask
   VAR Columns
   VAR DefSearch
   VAR NoBorder
   VAR NoStatus
   VAR Status
   VAR RestScr
   VAR IsSelect
   VAR ColSelect
   VAR MarkYN
   VAR Update
   VAR MaxMark

   METHOD New
   METHOD AddColumn
   METHOD Show

ENDCLASS



METHOD New( aDefList )

   ::ListSel     := aDefList
   ::Title       := "Sele‡„o"
   ::MarkOn      := "û"
   ::MarkOff     := " "
   ::lsRow       := NIL
   ::lsCol       := NIL
   ::nItens      := NIL
   ::ColorAtiv   := "15/1"
   ::ColorInat   := "8/15"
   ::ColorSele   := "12/15"
   ::ColorBorder := "9/15"
   ::ColorTitle  := "15/4"
   ::KeySave     := K_ENTER
   ::Execute     := NIL
   ::KeyBlock    := NIL
   ::Mask        := NIL
   ::Columns     := NIL
   ::DefSearch   := .F.
   ::NoBorder    := .F.
   ::NoStatus    := .F.
   ::Status      := "Selecione as op‡”es desejadas"
   ::RestScr     := .F.
   ::IsSelect    := .F.
   ::ColSelect   := NIL
   ::MarkYN      := .F.
   ::Update      := .T.
   ::MaxMark     := NIL

RETURN Self



METHOD AddColumn( uColumn )

   IF ::Columns = NIL
      ::Columns := {}
   ENDIF

   aAdd( ::Columns, uColumn )

RETURN Self



METHOD Show()

   // Declaracao de variaveis

   LOCAL aReturn    := {}
   LOCAL aSaveKeys  := KeyReset( { K_ALT_T } )
   LOCAL cScreen    := SaveScreen()
   LOCAL nSetCursor := SetCursor(0)
   LOCAL nColSelect := 0
   LOCAL cColor     := ""
   LOCAL cSearch    := ""
   LOCAL lExit      := .F.
   LOCAL lSave      := .F.
   LOCAL lAll       := .F.
   LOCAL aMark      := { "[" + ::MarkOn + "]", "[" + ::MarkOff + "]" }
   LOCAL aLastSel   := {}
   LOCAL aDefCols   := {}
   LOCAL aColor     := {}

   LOCAL oBrowse, oCol, lExecute, lDigit, cDigSave, cCol, uDefCol
   LOCAL nRow, nRowEnd, nCol, nColEnd, nColMask, nWidth, nCount
   LOCAL nSignal, nDef, nSel, nKey, nSearch, nMark, nColor

   PRIV nPointer := 1
   PRIV aList    := aClone( ::ListSel )

   // Definicao da coluna de selecao

   IF ::ColSelect <> NIL
      nColSelect := ::ColSelect
   ELSEIF ValType( aList[ 1, Len( aList[1] ) ] ) = "L"
      nColSelect := Len( aList[1] )
   ELSE
      FOR nCount := 1 TO Len( aList[1] )
         IF ValType( aList[ 1, nCount ] ) = "L"
            nColSelect := nCount
            EXIT
         ENDIF
      NEXT
   ENDIF

   // Definicao das colunas a serem exibidas

   IF ::Columns = NIL

      aEval( aList[1], { |a,n| aAdd( aDefCols, { n, n } ) } )

   ELSE

      FOR nCount := 1 TO Len( ::Columns )

         uDefCol := ::Columns[ nCount ]
         nCol    := If( ValType( uDefCol ) = "N", uDefCol, uDefCol[1] )

         aAdd( aDefCols, { nCol, nCount } )

      NEXT

   ENDIF

   // Definicao da largura da lista

   nWidth := 0

   FOR nCount := 1 TO Len( aList[1] )

      IF ValType( aList[ 1, nCount ] ) $ "LMA"
         LOOP
      ENDIF

      IF ::Columns = NIL .OR. ( lsLocColumn( ::Columns, nCount ) <> 0 )

         nColMask := aScan( aDefCols, { |x| x[1] = nCount } )
         nColMask := aDefCols[ nColMask, 2 ]

         DO CASE
            CASE ( ::Mask <> NIL ) .AND. ( ::Mask[ nColMask ] <> NIL )
                 nWidth += Len( Tran( aList[ 1, nCount ], ::Mask[ nColMask ] ) )
            CASE ValType( aList[ 1, nCount ] ) = "C"
                 nWidth += Len( aList[ 1, nCount ] )
            CASE ValType( aList[ 1, nCount ] ) = "N"
                 nWidth += LenNum( aList[ 1, nCount ] )
            OTHERWISE
                 nWidth += Len( DtoC( aList[ 1, nCount ] ) )
         ENDCASE

         nWidth++

      ENDIF

   NEXT

   nWidth += Len( aMark[1] ) -1

   // Definicao da linha inicial

   IF ::lsRow = NIL
      IF Len( ::ListSel ) > 21
         ::lsRow := 2
      ELSE
         ::lsRow := Int( ( MaxRow() - Len( ::ListSel ) ) / 2 )
      ENDIF
   ENDIF

   // Definicao da coluna inicial

   IF ::lsCol = NIL
      ::lsCol := Int( ( 79 - nWidth ) / 2 )
   ENDIF

   // Definicao do numero de itens

   IF ::nItens = NIL
      ::nItens := MaxRow() - ::lsRow - 2
      IF ::nItens > Len( ::ListSel )
         ::nItens := Len( ::ListSel )
      ENDIF
   ENDIF

   // Definicao da linha e coluna final

   nRowEnd := ::lsRow + ::nItens - 1
   nColEnd := ::lsCol + nWidth

   // Definicao da borda e titulo

   IF ! ::NoBorder
      @ ::lsRow -2, ::lsCol -1 SAY PadC( ::Title, nWidth + 3 ) COLOR ::ColorTitle
      @ ::lsRow -1, ::lsCol -1 TO nRowEnd +1, nColEnd +1       COLOR ::ColorBorder
      Shadow( ::lsRow -2, ::lsCol -1, nRowEnd +1, nColEnd +1 )
      IF ! ::NoStatus
         Status( ::Status )
      ENDIF
   ENDIF

   // Criacao do objeto TBrowse

   oBrowse := TBrowseNew( ::lsRow, ::lsCol, nRowEnd, nColEnd )

   oBrowse:SkipBlock     := { |nRequest| TbrSkip( aList, nRequest, @nPointer ) }
   oBrowse:GoBottomBlock := { || nPointer := Len( aList ) }
   oBrowse:GotopBlock    := { || nPointer := 1 }

   oBrowse:ColSep  := " "

   aAdd( aColor, ::ColorInat )
   aAdd( aColor, ::ColorAtiv )
   aAdd( aColor, ::ColorSele )

   FOR nCount := 1 TO Len( aDefCols )

      nCol := aDefCols[ nCount, 1 ]

      IF nCol = nColSelect

         oCol := TbColumnNew( NIL, { || RetSignal( @aList, nPointer, nColSelect, aMark ) } )
         oCol:ColorBlock := { || lsDefColor( aList[ nPointer, nColSelect ] ) }

      ELSE

         IF ( ::Mask <> NIL ) .AND. ( ::Mask[ nCount ] <> NIL )
            cCol := "{ || Tran( aList[ nPointer, " + LTrim( Str( nCol, 2 ) ) + " ], '" + ::Mask[ nCount ] + "' ) }"
         ELSE
            cCol := "{ || aList[ nPointer, " + LTrim( Str( nCol, 2 ) ) + " ] }"
         ENDIF

         oCol := TbColumnNew( NIL, &cCol )

      ENDIF

      IF ::Columns <> NIL

         uDefCol := ::Columns[ aDefCols[ nCount, 2 ] ]

         IF ValType( uDefCol ) = "A" .AND. Len( uDefCol ) > 2 .AND. ( uDefCol[3] <> NIL )

            nColor := aScan( aColor, { |c| c = uDefCol[3] } )

            IF nColor = 0
               aAdd( aColor, uDefCol[3] )
               nColor := Len( aColor )
            ENDIF

            oCol:ColorBlock := { || { nColor, 2 } }

         ENDIF

      ENDIF

      oBrowse:AddColumn( oCol )

   NEXT

   aEval( aColor, { |x| cColor += "," + x } )

   oBrowse:ColorSpec := Subs( cColor, 2 )

   aEval( aList, { |a| aAdd( aLastSel, a[ nColSelect ] ) } )

   DO WHILE ! lExit

      oBrowse:RefreshCurrent()

      ForceStable( oBrowse )

      oBrowse:ColorRect( { oBrowse:RowPos, 1, oBrowse:RowPos, oBrowse:ColCount }, { 2, 2 } )

      nKey := mxInKey( 0 )

      IF ( ::KeyBlock = NIL .OR. ::Execute = NIL )
         lExecute := .F.
      ELSEIF ValType( ::KeyBlock ) = "N"
         lExecute := ( nKey = ::KeyBlock )
      ELSE
         lExecute := ( aScan( ::KeyBlock, { |k| k = nKey } ) > 0 )
      ENDIF

      lDigit := .F.

      // Procura de itens na lista

      DO WHILE ( nKey > 47 .AND. nKey < 58          ) .OR. ;
               ( nKey > 64 .AND. nKey < 91          ) .OR. ;
               ( nKey > 96 .AND. nKey <123          ) .OR. ;
               ( nKey =  8 .AND. Len( cSearch ) > 0 )

         lDigit := .T.

         IF Len( cSearch ) = 0 .AND. ::DefSearch

            cDigSave := SaveScreen( Row()-1, nColEnd + 3, Row()+1, nColEnd + 4 + Len( aList[ 1, 1 ] ) )
            nRow     := Row()
            nCol     := Col()

            @ nRow-1, nColEnd + 3 CLEAR TO nRow+1, nColEnd + 4 + Len( aList[1,1] )
            @ nRow-1, nColEnd + 3       TO nRow+1, nColEnd + 4 + Len( aList[1,1] )

            SetPos( nRow, nCol )

         ENDIF

         IF nKey = 8 .AND. Len( cSearch ) > 0
            cSearch := Left( cSearch, Len( cSearch ) - 1 )
         ELSE
            cSearch += Chr( nKey )
         ENDIF

         IF Len( aList ) = 0
            nSearch := 0
         ELSE
            nSearch := aScan( aList, { |l| If( ValType( l[1] ) = "N", l[1] = Val( cSearch ), Left( l[1], Len( cSearch ) ) = cSearch ) } )
         ENDIF

         IF nSearch = 0
            EXIT
         ENDIF

         nPointer := nSearch

         ForceStable( oBrowse, .T. )

         oBrowse:ColorRect( { oBrowse:RowPos, 1, oBrowse:RowPos, oBrowse:ColCount }, { 2, 2 } )

         IF ::DefSearch
            DispDigit( nColEnd + 4, PadR( cSearch, Len( aList[1,1] ) ) )
         ENDIF

         nKey := mxInKey( 0 )

      ENDDO

      IF ::DefSearch .AND. lDigit
         RestScreen( Row()-1, nColEnd + 3, Row()+1, nColEnd + 4 + Len( aList[1,1] ), cDigSave )
      ENDIF
      cSearch := ""

      DO CASE
         CASE lExecute

              Eval( ::Execute, nPointer, aList[ nPointer, nColSelect ], aList[ nPointer ] )

         CASE IF( ValType( ::KeySave ) = "N", nKey = ::KeySave, aScan( ::KeySave, { |k| k = nKey } ) > 0 )

              lExit      := .T.
              ::IsSelect := .T.

         CASE nKey = K_ESC

              // Abandona, sem confirmar a operacao.

              lExit      := .T.
              ::IsSelect := .F.

         CASE ::Update .AND. ( nKey = K_SPACE .OR. ( ( ValType( aList[ nPointer, nColSelect ] ) <> "A" ) .AND. ::MarkYN .AND. Upper( Chr( nKey ) ) $ "SN" ) .OR. ( ValType( aList[ nPointer, nColSelect ] ) = "A" .AND. ( aScan( aList[ nPointer, nColSelect, 2 ], Upper( Chr( nKey ) ) ) > 0 ) ) )

              DO CASE
                 CASE ValType( aList[ nPointer, nColSelect ] ) = "A"

                      IF nKey = K_SPACE
                         nSignal := aScan( aList[ nPointer, nColSelect, 2 ], aList[ nPointer, nColSelect, 1 ] )
                         IF nSignal = Len( aList[ nPointer, nColSelect, 2 ] )
                            nSignal := 1
                         ELSE
                            nSignal ++
                         ENDIF
                      ELSE
                         nSignal := aScan( aList[ nPointer, nColSelect, 2 ], Upper( Chr( nKey ) ) )
                      ENDIF

                      aList[ nPointer, nColSelect, 1 ] := aList[ nPointer, nColSelect, 2, nSignal ]

                 CASE Upper( Chr( LastKey() ) ) = "S"
                      aList[ nPointer, nColSelect ] := .T.
                 CASE Upper( Chr( LastKey() ) ) = "N"
                      aList[ nPointer, nColSelect ] := .F.
                 OTHERWISE
                      aList[ nPointer, nColSelect ] := ( ! aList[ nPointer, nColSelect ] )
              ENDCASE

              aLastSel[ nPointer ] := aList[ nPointer, nColSelect ]

              oBrowse:RefreshCurrent()

              IF ::Execute <> NIL
                 Eval( ::Execute, nPointer, aList[ nPointer, nColSelect ], aList[ nPointer ] )
              ENDIF

              oBrowse:Down()

         CASE BrwKey( oBrowse, nKey )

              // Nada a executar.

         CASE nKey = K_ALT_T .AND. ::Update

              // Esta operacao marca/desmarca todos os itens.

              lAll := .F.

              FOR nCount := 1 TO Len( aList )

                 IF ValType( aList[ nCount, nColSelect ] ) = "L"
                    IF ! aList[ nCount, nColSelect ]
                       lAll := .T.
                       EXIT
                    ENDIF
                 ELSEIF aList[ nCount, nColSelect, 1 ] = aList[ nCount, nColSelect, 3 ]
                    lAll := .T.
                    EXIT
                 ENDIF

              NEXT

              FOR nCount := 1 TO Len( aList )

                 IF ValType( aList[ nCount, nColSelect ] ) = "L"
                    aList[ nCount, nColSelect ] := lAll
                 ELSEIF ! lAll
                    aList[ nCount, nColSelect, 1 ] := aList[ nCount, nColSelect, 3 ]
                 ELSE
                    FOR nDef := 1 TO Len( aList[ nCount, nColSelect, 2 ] )
                       IF aList[ nCount, nColSelect, 2, nDef ] <> [ nCount, nColSelect, 3 ]
                          aList[ nCount, nColSelect, 1 ] := aList[ nCount, nColSelect, 2, nDef ]
                          EXIT
                       ENDIF
                    NEXT
                 ENDIF

              NEXT

              oBrowse:RefreshAll()

              lAll := ( !lAll )

      ENDCASE

      IF lExit .AND. ::IsSelect .AND. ::MaxMark <> NIL

         nMark := 0

         IF ValType( aList[ 1, nColSelect ] ) = "L"
            aEval( aList, { |a| If( a[ nColSelect ], nMark++, .T. ) } )
         ENDIF

         IF nMark > ::MaxMark

            nMark -= ::MaxMark

            MsgDlg( ;
                    "O n£mero m ximo de itens que podem;"                  + ;
                    "ser selecionados ‚ " + NumToStr( ::MaxMark ) + " !;;" + ;
                    "Desmarque " + NumToStr( nMark ) + " ite" + If( nMark = 1, "m", "ns" ) + " para prosseguir." ;
                  )

            lExit := .F.

         ENDIF

      ENDIF

   ENDDO

   SetCursor( nSetCursor )

   IF ::IsSelect
      aReturn := aList
   ELSE
      aReturn := ::ListSel
   ENDIF
   
   IF ::RestScr
      RestScreen( ,,,, cScreen )
   ENDIF

   KeyRestore( aSaveKeys )

RETURN( aReturn )



STATIC FUNCTION lsLocColumn( aCol, nCol )

   LOCAL nPos := 0
   LOCAL nCount

   FOR nCount := 1 TO Len( aCol )

      IF ValType( aCol[ nCount ] ) = "N"
         IF aCol[ nCount ] = nCol
            nPos := nCount
            EXIT
         ENDIF
      ELSEIF aCol[ nCount, 1 ] = nCol
         nPos := nCount
         EXIT
      ENDIF

   NEXT

RETURN( nPos )



STATIC FUNCTION lsDefColor( uCondition )

   LOCAL aColor

   IF ValType( uCondition ) = "A"
      aColor := If( uCondition[1] = uCondition[3], { 1, 2 }, { 3, 3 } )
   ELSE
      aColor := If( uCondition, { 3, 3 }, { 1, 2 } )
   ENDIF

RETURN( aColor )



STATIC FUNCTION RetSignal( aList, nPosition, nColSelect, aMark )

   LOCAL cSignal, nSignal, aSignal

   IF ValType( aList[ nPosition, nColSelect ] ) = "L"
      cSignal := If( aList[ nPosition, nColSelect ], aMark[1], aMark[2] )
   ELSE
      cSignal := "[" + aList[ nPosition, nColSelect, 1 ] + "]"
   ENDIF

RETURN( cSignal )



STATIC FUNCTION DispDigit( nColDisp, cDisplay )

   LOCAL aPos := { Row(), Col() }

   @ aPos[1], nColDisp SAY cDisplay

   SetPos( aPos[1], aPos[2] )

RETURN( NIL )



STATIC FUNCTION ForceStable( oBrow, lRefresh )

   IF lRefresh = NIL
      lRefresh := .F.
   ENDIF
   mxDispBegin()
   IF lRefresh
      oBrow:RefreshAll()
   ENDIF
   DO WHILE !oBrow:Stabilize()
   ENDDO
   mxDispend()

RETURN( NIL )



STATIC FUNCTION TbrSkip( aSkip, nRequest, nPointer )

   LOCAL nPos := 0

   IF nRequest >= 0
      nPos := Len( aSkip ) - nPointer
   ELSE
      nPos := nPointer - 1
   ENDIF

   IF Abs( nRequest ) < nPos
      nPos := nRequest
   ELSEIF nRequest >= 0
      nPos := Len( aSkip ) - nPointer
   ELSE
      nPos := 1 - nPointer
   ENDIF

   nPointer += nPos

RETURN( nPos )



STATIC FUNCTION BrwKey( oBrowse, nKey )

   LOCAL lReturn := .T.

   DO CASE
      CASE nKey = K_CTRL_END   ; oBrowse:panEnd()
      CASE nKey = K_CTRL_HOME  ; oBrowse:panHome()
      CASE nKey = K_CTRL_LEFT  ; oBrowse:panLeft()
      CASE nKey = K_CTRL_PGDN  ; oBrowse:goBottom()
      CASE nKey = K_CTRL_PGUP  ; oBrowse:goTop()
      CASE nKey = K_CTRL_RIGHT ; oBrowse:panRight()
      CASE nKey = K_DOWN       ; oBrowse:down()
      CASE nKey = K_END        ; oBrowse:end()
      CASE nKey = K_HOME       ; oBrowse:home()
      CASE nKey = K_LEFT       ; oBrowse:left()
      CASE nKey = K_PGDN       ; oBrowse:pageDown()
      CASE nKey = K_PGUP       ; oBrowse:pageUp()
      CASE nKey = K_RIGHT      ; oBrowse:right()
      CASE nKey = K_UP         ; oBrowse:up()
      OTHERWISE                ; lReturn := .F.
   ENDCASE

RETURN( lReturn )
