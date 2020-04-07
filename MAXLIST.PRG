/*

 MaxList.prg
 Descricao: Biblioteca de funcoes de listas.
 Desenvolvido por MAX SCALLA Informatica Ltda.
 
 EMERSON DA SILVA CREMA
 15/01/19 * Implementado o parametro lNaoDefinido em UF() e ListUF().
 18/10/17 * Implementado em mxDbList() o parametro cFuncStat.
 23/09/13 * Trocado o nome da funcao dbList() p/ mxDbList().
 03/02/12 * Implementado em ListFiles() o parametro lShortFName.

 DENIS MAZZUCATTO RODRIGUES
 12/08/11 * Desenvolvimento de tbNPosCol().
 10/08/11 * Alterada utilizacao de mxDbRefresh() em GetKey().

 EMERSON DA SILVA CREMA
 16/09/10 * Implementado em aUF EX.
 21/06/10 * Correcao na definicao de aExcept em ListFiles().

 DENIS MAZZUCATTO RODRIGUES
 23/04/10 * Desenvolvimento de codPais().
 21/12/09 * Alteracao em mxDbBrowse() p/ exibir as informacoes do parametro
            cShow em varias linhas.

 EMERSON DA SILVA CREMA
 01/12/09 * Correcao de "Argument error" em aList().
 09/04/09 * Implementado em lsSelectAll() a possibilidade de selecionar
            arquivos de banco de dados no lugar de matrizes.

 DENIS MAZZUCATTO RODRIGUES
 02/04/09 * Implementacao de aUF.
          * Implementado retorno de aUF em UF().
          * Melhorias em UF() e ListUF().
 20/03/09 * Implementado PE (Pernambuco) na lista de ListUF().
 04/03/09 * Renomeada TBrowse() p/ mxDbBrowse().
 28/04/08 * Implementado parametro cFileGet em ListFiles().

 EMERSON DA SILVA CREMA
 07/12/07 * Implementado K_ALT_O em TBrowse().
 09/01/07 * Movida funcao MakeDbEdit() p/ as versoes 2.12c e 3.07.
 01/08/06 * Desenvolvimento de brPointer().
          * Implementacao de Pointer() em TBrowse().

 DENIS MAZZUCATTO RODRIGUES
 31/07/06 * Implementada possibilidade de selecionar varios tipos de arquivos
            em ListFiles() por passar uma matriz no parametro cFile.

 EMERSON DA SILVA CREMA
 16/03/06 * Desenvolvimento de ljSelectAll().
 17/01/06 * Desenvolvimento de tbrBottom() e implementado controle em
            TBrowse() p/ posicionar a lista em seu final.
 11/07/05 * Implementado o retorno 6 em TBrowse().
 06/07/05 * Alteracao em TBrowse() p/ qdo tiver alteracoes na barra de titulos
            das colunas, tb refaca o contorno a tela de forma proporcional.
 05/07/05 * Desenvolvimento de tbrDefTitulo().
          * Implementada consistencia p/ nao colocar linha de divisao no
            rodade da tela de TBrowse().
 07/12/04 * Removida atualizacao de tela a cada 5 segs, em TBrowse(), pois qdo
            uma informacao era alterada em outro terminal, isto causava um
            desposicionamento na lista. Esta alteracao reflete apenas em
            arquivos BTRIEVE.
 06/12/04 * Desenvolvimento de tbrBarra().

*/

#include "std.ch"
#include "inkey.ch"
#include "tbrowse.ch"

STATIC cTimeAlert := ""
STATIC aTbrBottom := {}

STATIC aPais := {}

STATIC aUF := { ;
                { 12, "AC", "Acre               " },;
                { 27, "AL", "Alagoas            " },;
                { 13, "AM", "Amazonas           " },;
                { 16, "AP", "Amap               " },;
                { 29, "BA", "Bahia              " },;
                { 23, "CE", "Cear               " },;
                { 53, "DF", "Distrito Federal   " },;
                { 32, "ES", "Esp¡rito Santo     " },;
                { 52, "GO", "Goi s              " },;
                { 21, "MA", "Maranh„o           " },;
                { 31, "MG", "Minas Gerais       " },;
                { 50, "MS", "Mato Grosso do Sul " },;
                { 51, "MT", "Mato Grosso        " },;
                { 15, "PA", "Par                " },;
                { 25, "PB", "Para¡ba            " },;
                { 26, "PE", "Pernambuco         " },;
                { 22, "PI", "Piau¡              " },;
                { 41, "PR", "Paran              " },;
                { 33, "RJ", "Rio de Janeiro     " },;
                { 24, "RN", "Rio Grande do Norte" },;
                { 11, "RO", "Rond“nia           " },;
                { 14, "RR", "Roraina            " },;
                { 43, "RS", "Rio Grande do Sul  " },;
                { 42, "SC", "Santa Catarina     " },;
                { 28, "SE", "Sergipe            " },;
                { 35, "SP", "S„o Paulo          " },;
                { 17, "TO", "Tocantins          " },;
                { 99, "EX", "Exterior           " } ;
              }

/*----------------------------------------------------------------------------
 Funcao p/ edicao de matrizes.

 Parametros

 aArrayUse   : Matriz que sera editada.
 nRow1       : Linha inicial.
 nCol1       : Coluna inicial.
 nRow2       : Linha final.
 nCol2       : Coluna final.
 aCols       : Numero das colunas que serao exibidas.
 aMask       : mascaras p/ as colunas.
 bFunction   : funcao definida pelo usuario.
 aSeparators : Separadores das colunas, rodape e cabecalho.
 nBar        :
 nSkip       :
 nStart      :
 lFreeze     : Se .T., a coluna 1 torna-se fixa
 cColColor   :

 Obs: A funcao "aList()" envia  3  parametros p/  a funcao definida  pelo
      usuario. O  primeiro  parametro  e a matriz  em edicao, o  segundo  a
      variavel  de controle  do browse  (oBrowse) e  a terceira o  ponteiro
      da  matriz. Todos  estes parametros podem  ser manipulados livremente
      dentro da funcao. A funcao definida pelo usuario pode ter 3 retornos.
      Os retornos sao: 0 encerra a edicao, 1 continua editando e 2 atualiza
      a exibicao da matriz.

 Exemplo de funcao do usuario:

  FUNCTION Udf( aArray, oBrowse, nPointer )

     LOCAL nRow := Row()
     LOCAL nCol := Col()
     @ MaxRow(), 0 SAY aArray[ nPointer, 2 ]
     SetPos( nRow, nCol )
     DO CASE
        CASE LastKey() = K_ESC
             RETURN(0)
        CASE LastKey() = K_ENTER
             aArray[ nPointer, 3 ] := If( aArray[ nPointer, 3 ] = 0, nPointer, 0 )
             oBrowse:RefreshCurrent()
        OTHERWISE
             RETURN(1)
     ENDCASE

  RETURN(2)

 A funcao do usuario deve ser passada como parametro da seguinte forma:

 aArray :=  aList( aArray,;  // Matriz p/ edicao
                   1     ,;  // Linha inicial
                   1     ,;  // Coluna inicial
                   10    ,;  // Linha final
                   78    ,;  // Coluna final
                   {}    ,;  // Numero das colunas a serem exibidas (todas)
                   { NIL, NIL, "@E 9,999.99" },;     // Mascaras das colunas
                   { |a, b, p| Udf( @a, @b, @p ) } )  // Funcao do usuario
                                            ³
                                            ÀÄÄ> permite que os dados
                                                 sejam atualizados.

 Retorno : Matriz atualizada.
----------------------------------------------------------------------------*/

FUNCTION aList( ;
                aArrayUse  ,;
                nRow1      ,;
                nCol1      ,;
                nRow2      ,;
                nCol2      ,;
                aCols      ,;
                aMask      ,;
                bFunction  ,;
                aSeparators,;
                nBar       ,;
                bSkip      ,;
                nStart     ,;
                lFreeze    ,;
                cColColor  ,;
                nColPos    ,;
                aTitle      ;
              )

   LOCAL lInit := .T.
   LOCAL lExit := .F.
   LOCAL nKey  := 0

   LOCAL oBrowse, oCol, nCol, cCol, nRowSav, nColSav
   LOCAL nReturn, lUp, tRowSave, nSavCursor, cColTitle

   IF Len( aArrayUse ) = 0
      RETURN( {} )
   ENDIF

   vDef( @nBar       ,  1  )
   vDef( @lFreeze    , .F. )
   vDef( @aSeparators, {}  )
   vDef( @aMask      , {}  )
   vDef( @aCols      , {}  )
   vDef( @nColPos    ,  1  )

   PRIV nPointer := 1
   PRIV aArray   := aClone( aArrayUse )

   nSavCursor := SetCursor(0)

   oBrowse := TBrowseNew( nRow1, nCol1, nRow2, nCol2 )

   IF cColColor <> NIL
      oBrowse:ColorSpec += cColColor
   ENDIF

   oBrowse:SkipBlock     := { |nRequest| TbrSkip( aArray, nRequest, @nPointer ) }
   oBrowse:GoBottomBlock := { || nPointer := Len( aArray ) }
   oBrowse:GoTopBlock    := { || nPointer := 1 }
    
   IF Len( aSeparators ) < 1
      aAdd( aSeparators, "³" )
   ENDIF
   IF Len( aSeparators ) < 2
      aAdd( aSeparators, "" )
   ENDIF
   IF Len( aSeparators ) < 3
      aAdd( aSeparators, "" )
   ENDIF

   oBrowse:ColSep  := aSeparators[1]
   oBrowse:FootSep := aSeparators[2]
   oBrowse:HeadSep := aSeparators[3]

   IF Len( aCols ) = 0
      nCol := 1
      aEval( aArray[1], { || aAdd( aCols, nCol++ ) } )
   ENDIF

   FOR nCol := 1 TO Len( aCols )

      IF ! ( nCol <= Len( aMask ) .AND. aMask[ nCol ] <> NIL )
         cCol := "aArray[ nPointer, " + LTrim( Str( aCols[ nCol ] ) ) + "]"
      ELSEIF aMask[ nCol ] = Repl( "X", Len( aMask[ nCol ] ) )
         cCol := "PadR( aArray[ nPointer, " + LTrim( Str( aCols[ nCol ] ) ) + "], " + NumToStr( Len( aMask[ nCol ] ) ) + " )"
      ELSE
         cCol := "Tran( aArray[ nPointer, " + LTrim( Str( aCols[ nCol ] ) ) + "], '" + aMask[ nCol ] + "' )"
      ENDIF
      
      cColTitle := NIL

      IF aTitle <> NIL .AND. nCol <= Len( aTitle )
         cColTitle := aTitle[ nCol ]
      ENDIF

      oCol := TbColumnNew( cColTitle, { || &cCol } )

      IF cColColor <> NIL
         oCol:ColorBlock := { || { 6, 7 } }
      ENDIF

      oBrowse:AddColumn( oCol )

   NEXT

   IF lFreeze
      oBrowse:freeze := 1
   ENDIF

   oBrowse:ColPos := nColPos

   ClearKeybBuffer()

   nReturn := 1

   DO WHILE ! lExit

      mxDispBegin()

      oBrowse:RefreshCurrent()

      DO WHILE ! oBrowse:Stabilize()
      ENDDO

      IF bSkip <> NIL

         IF lInit .OR. mxIn( nKey, { K_DOWN, K_PGDN, K_CTRL_PGDN } )

            lUp := .F.

            DO WHILE Eval( bSkip, aArray[ nPointer ] )
               IF nPointer = Len( aArray )
                  lUp := .T.
               ENDIF
               IF lUp
                  oBrowse:Up()
               ELSE
                  oBrowse:Down()
               ENDIF
               DO WHILE ! oBrowse:Stabilize()
               ENDDO
            ENDDO

         ELSEIF mxIn( nKey, { K_UP, K_PGUP, K_CTRL_PGUP } )

            lUp := .T.

            DO WHILE Eval( bSkip, aArray[ nPointer ] )
               IF nPointer = 1
                  lUp := .F.
               ENDIF
               IF lUp
                  oBrowse:Up()
               ELSE
                  oBrowse:Down()
               ENDIF
               DO WHILE ! oBrowse:Stabilize()
               ENDDO
            ENDDO

         ENDIF
      ENDIF

      IF lInit .AND. nStart <> NIL .AND. nPointer <> nStart .AND. nStart <= Len( aArray ) .AND. nStart <> 0
         DO WHILE nPointer <> nStart
            IF nStart > nPointer
               oBrowse:Down()
            ELSE
               oBrowse:Up()
            ENDIF
            DO WHILE ! oBrowse:Stabilize()
            ENDDO
         ENDDO
      ENDIF

      nRowSav := Row()
      nColSav := Col()

      tRowSave := SaveScreen( nRowSav, nCol1, nRowSav, nCol2 )

      DO WHILE ! oBrowse:Stabilize()
      ENDDO

      IF nBar <> 0
         IF nBar = 1
            oBrowse:ColorRect( { oBrowse:RowPos, 1, oBrowse:RowPos, oBrowse:ColCount }, { 2, 1 } )
         ELSE
            BackGround( nRowSav, nCol1, nRowSav, nCol2, ConvStrColor( SlColor( SetColor(), 2 ) ) )
         ENDIF
      ENDIF

      mxDispEnd()

      IF ! lInit
         nKey := mxInKey()
      ENDIF

      lInit := .F.

      IF bFunction <> NIL
         nReturn := Eval( bFunction, @aArray, @oBrowse, @nPointer )
      ENDIF

      IF ! mxIn( nReturn, { 0, 3 } )

         mxDispBegin()

         RestScreen( nRowSav, nCol1, nRowSav, nCol2, tRowSave )

         SetPos( nRowSav, nColSav )

         mxDispEnd()

      ENDIF

      DO CASE
         CASE mxIn( nReturn, { 0,3 } )
              lExit := .T.
         CASE nReturn = 1
              DO CASE
                 CASE BrwKey( @oBrowse, nKey )
                      // Nada a executar.
                 CASE nKey = K_ESC
                      IF bFunction = NIL
                         lExit := .T.
                      ENDIF
              ENDCASE
              IF bFunction <> NIL
                 ForceStable( oBrowse:RefreshCurrent() )
                 Eval( bFunction, @aArray, @oBrowse, @nPointer )
              ENDIF
         CASE nReturn = 2
              oBrowse:RefreshAll()
      ENDCASE

   ENDDO

   SetCursor( nSavCursor )

RETURN( aArray )



/*----------------------------------------------------------------------------
 Funcao padrao p/ efetuar skip em tbrowse com matriz.

 Parametros.

 aSkip    : Matriz p/ skip
 nRequest : Quantidade de itens solicitado pelo TBROWSE.
 nPointer : Variavel de pointeiro da matriz. ( Deve utilizar @ ).

 Retorno : Numero de itens de serao avancados ou retrocedidos.
----------------------------------------------------------------------------*/

FUNCTION TbrSkip( aSkip, nRequest, nPointer )

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



FUNCTION BrwKey( oBrowse, nKey, aNoKeys )

   // Funcao p/ tratamento de comandos basicos em TBrowse.

   LOCAL lReturn := .T.

   vDef( @aNoKeys, {} )

   DO CASE
      CASE mxIn( nKey, aNoKeys ) ; lReturn := .F.
      CASE nKey = K_CTRL_END     ; oBrowse:panEnd()
      CASE nKey = K_CTRL_HOME    ; oBrowse:panHome()
      CASE nKey = K_CTRL_LEFT    ; oBrowse:panLeft()
      CASE nKey = K_CTRL_RIGHT   ; oBrowse:panRight()
      CASE nKey = K_CTRL_PGDN    ; oBrowse:goBottom()
      CASE nKey = K_CTRL_PGUP    ; oBrowse:goTop()
      CASE nKey = K_UP           ; oBrowse:up()
      CASE nKey = K_DOWN         ; oBrowse:down()
      CASE nKey = K_END          ; oBrowse:end()
      CASE nKey = K_HOME         ; oBrowse:home()
      CASE nKey = K_LEFT         ; oBrowse:left()
      CASE nKey = K_RIGHT        ; oBrowse:right()
      CASE nKey = K_PGDN         ; oBrowse:pageDown()
      CASE nKey = K_PGUP         ; oBrowse:pageUp()
      OTHERWISE                  ; lReturn := .F.
   ENDCASE

RETURN( lReturn )



FUNCTION BrLIni( nIte )
RETURN( MaxRow() - 2 - nIte )



FUNCTION BrLFim( nIte )
RETURN( If( nIte = NIL, MaxRow() -3, nIte ) )



FUNCTION ListFiles( cFiles     ,;
                    cPath      ,;
                    cExcept    ,;
                    cTitle     ,;
                    cOrder     ,;
                    aFiles     ,;
                    cFileGet   ,;
                    lShortFName )

   LOCAL aListFiles := {}
   LOCAL cScreen    := SaveScreen()
   LOCAL cColor     := SetColor( "8/15,15/1,,,8/15" )
   LOCAL lExcept    := ( cExcept <> NIL )
   LOCAL cReturn    := ""
   LOCAL nLen       := 0

   LOCAL aExecpt, nFile, nOrder, nRowEnd, aAux, nColLeft, nColRight

   vDef( @cPath      , ""         )
   vDef( @cExcept    , ""         )
   vDef( @cOrder     , "N"        )
   vDef( @cTitle     , "Arquivos" )
   vDef( @lShortFName, .T.        )

   IF ValType( cFiles ) = "C"
      aFiles := Directory( cPath + cFiles )
   ELSE
      aFiles := {}
      FOR nFile := 1 TO Len( cFiles )
         aAux := Directory( cPath + cFiles[ nFile ] )
         aEval( aAux, { |f| aAdd( aFiles, f ) } )
      NEXT
   ENDIF

   IF lExcept
      aExcept := Directory( cPath + cExcept )
      aAux    := {}
      FOR nFile := 1 TO Len( aFiles )
         IF aScan( aExcept, { |e| e[1] = aFiles[ nFile, 1 ] } ) = 0
            aAdd( aAux, aFiles[ nFile ] )
         ENDIF
      NEXT
      aFiles := aClone( aAux )
   ENDIF

   IF Len( aFiles ) > 0

      DO CASE
         CASE cOrder = "N" ; nOrder := 1
         CASE cOrder = "S" ; nOrder := 2
         CASE cOrder = "D" ; nOrder := 3
      ENDCASE

      aSort( aFiles,,, { |x,y| x[ nOrder ] < y[ nOrder ] } )

      aEval( aFiles, { |f| nLen := Min( 38, Max( Len( f[1] ), nLen ) ) } )

      IF lShortFName 
         aEval( aFiles, { |f| aAdd( aListFiles, " " + PadR( GetNameFile( GetShortFileName( cPath + f[1] ) ), nLen ) + " gerado em " + DtoC( f[3] ) + " as " + f[4] + "h" ) } )
      ELSE
         aEval( aFiles, { |f| aAdd( aListFiles, " " + PadR( f[1], nLen ) + " gerado em " + fDate( f[3], "DD.MM.AA" ) + " as " + f[4] + "h" ) } )
      ENDIF
      
      nColLeft  := Int( ( MaxCol() - Len( aListFiles[1] ) ) / 2 )
      nColRight := nColLeft + Len( aListFiles[1] )

      Muda_Cor( 01, 00, MaxRow()-1, 79, CFIFUNCTR )

      nRowEnd := If( Len( aListFiles ) >= 10, MaxRow() -6, 8 + Len( aListFiles ) )

      Limpa( 07, nColLeft -1, nRowEnd, nColRight + 1, "s", NIL, "9/15" )
      @ 06,nColLeft -1 SAY PadC( cTitle, Len( aListFiles[1] ) + 3 ) COLOR "15/4"
      Shadow( 06, nColLeft -1, nRowEnd, nColRight +1 )
      
      @ nRowEnd, nColRight - 6 SAY "[" + StrZero( Len( aListFiles ), 5 ) + "]" COLOR "15/4"
      
      Status( "ESCúRetorna" )

      nFile := aChoice( 08, nColLeft, MaxRow() -7, nColRight, aListFiles, NIL, "M_List" )

      RestScreen( ,,,, cScreen )
      SetColor( cColor )

      IF nFile <> 0
         IF lShortFName 
            cReturn := GetNameFile( GetShortFileName( cPath + aFiles[ nFile, 1 ] ) )
         ELSE
            cReturn := aFiles[ nFile, 1 ] 
         ENDIF
      ENDIF

   ENDIF

   IF cFileGet <> NIL
      cFileGet := PadR( cReturn, Len( cFileGet ) )
      RETURN( ! Empty( cReturn ) )
   ENDIF

RETURN( cReturn )



FUNCTION M_List()

   IF LastKey() = K_ENTER
      RETURN( 1 )
   ELSEIF LastKey() = K_ESC
      RETURN( 0 )
   ENDIF

RETURN( 2 )



FUNCTION mxDbBrowse( ;
                     aCols      ,;
                     aTitulo    ,;
                     cTitulo    ,;
                     cFuncKey   ,;
                     cFuncStat  ,;
                     nCorFundo  ,;
                     nItens     ,;
                     lSavScreen ,;
                     lModeAbort ,;
                     cCorBrowse ,;
                     cCorTitulo ,;
                     cCorBarra  ,;
                     nBeginKey  ,;
                     nBottom    ,;
                     nLeft      ,;
                     lDispEnd   ,;
                     bParameters,;
                     bColorRect ,;
                     nOrder     ,;
                     cShow       ;
                  )

   LOCAL GetList     := {}
   LOCAL cSavScreen  := SaveScreen()
   LOCAL cSavColor   := SetColor( If( cCorBrowse = NIL, "15/0,0/7", cCorBrowse + "," + cCorBarra ) )
   LOCAL cSavCorBrow := SetColor()
   LOCAL nSavCursor  := SetCursor(0)
   LOCAL nAfterDig   := 0
   LOCAL nReturn     := 0
   LOCAL nTbKey      := 0
   LOCAL nKey        := 0
   LOCAL aTit        := {}
   LOCAL aIndex      := {}
   LOCAL aSeque      := {}
   LOCAL aSelOrder   := {}
   LOCAL lStart      := .T.
   LOCAL lMore       := .F.
   LOCAL lLoop       := .F.
   LOCAL lUpdList    := .F.
   LOCAL lF4         := .F.
   LOCAL lLeft       := ( nLeft <> NIL )

   LOCAL nSizeTitulo, nTop, nRight, nDefOrder, nCount, nShowLin
   LOCAL nSavRecno, nSavRow, nSavCol, cSavTel, cDefTitulo, cShowAux
   LOCAL cTitPrint, lUpdTitulo, lClear, lPressKey, oBrowse, cCol

   // Esta consistencia define se esta sendo rodado o Control Shop na versao
   // 3.08 ou superior. Reconfigura os DISPBEGIN() e DISPEND().

   LOCAL lSisCS308 := IsDef( "SISTEMA" ) .AND. ( "CONTROL SHOP" $ Upper( SISTEMA ) ) .AND. ;
                      IsDef( "VERSAO"  ) .AND. ( Val( VERSAO ) >= 3.08 )

   PRIV CprAll := ""
      
   vDef( @cCorTitulo, "0/7" )

   IF nBeginKey = NIL
      nBeginKey := 0
      IF Eof()
         mxBottom()
      ENDIF
   ELSEIF nBeginKey <> K_CTRL_PGDN
      KEYB Chr( nBeginKey )
   ENDIF

   vDef( @bColorRect, { || { 5, 2 } } )

   FOR nCount := 1 TO Len( aCols )

      IF ValType( aCols[ nCount ] ) = "A"

         aSize( aCols[ nCount ], 4 )

         IF aCols[ nCount, 1 ] <> NIL
            aAdd( aIndex, aCols[ nCount ] )
            aAdd( aSeque, nCount )
            lF4 := .T.
         ENDIF

         cCol := aCols[ nCount, 2 ]

         IF ValType( cCol ) = "C" .AND. FieldPos( cCol ) > 0

            DO CASE
               CASE Type( cCol ) = "C" ; aCols[ nCount, 2 ] := "PadR( " + cCol + ", " + NumToStr( FieldSize( FieldPos( cCol ) ) ) + ")"
               CASE Type( cCol ) = "N" ; aCols[ nCount, 2 ] := "Str( "  + cCol + ", " + NumToStr( FieldSize( FieldPos( cCol ) ) ) + ")"
            ENDCASE

         ENDIF

      ENDIF

   NEXT

   DefTitulo( @aCols, @aTit )

   DO WHILE .T.

      mxDispBegin()
      
      IF lUpdList

         DefTitulo( @aCols, @aTit )

      ELSEIF lF4

         DO WHILE ( nDefOrder := tbGetOrder( aIndex ) ) <> If( nOrder = NIL, nDefOrder, nOrder ) .OR. nDefOrder = NIL
            tbDefOrder( @aCols, @aIndex, @aSeque, @aTit )
         ENDDO
         mxOrder( nOrder := nDefOrder )

         DefTitulo( @aCols, @aTit )

         IF Len( aSelOrder ) = 0

            aSelOrder := {}

            FOR nCount := 1 TO Len( aCols )

               IF ValType( aCols[ nCount ] ) = "A" .AND. aCols[ nCount, 1 ] <> NIL
                  aAdd( aSelOrder, { nCount,;
                                     aCols[ nCount, 1 ],;
                                     SeqToChr( Len( aSelOrder ) + 1 ) + " -> " + blockToVal( aCols[ nCount, 3 ] ) } )
               ENDIF

            NEXT

         ENDIF

      ENDIF

      lUpdList   := .F.
      lUpdTitulo := .F.

      IF Len( aTit ) <> 0

         aTitulo := { "", "" }

         FOR nCount := 1 TO Len( aTit )

             IF nCount = 1
                aTitulo[1] += "Æ"
             ENDIF

             aTitulo[1] += aTit[ nCount, 1 ]
             aTitulo[2] += aTit[ nCount, 2 ]

             IF nCount = Len( aTit )
                aTitulo[1] += "µ"
             ELSE
                aTitulo[1] += "Ø"
                aTitulo[2] += "³"
             ENDIF

         NEXT

         IF cDefTitulo <> NIL .AND. cDefTitulo <> aTitulo[ 2 ]
            lStart     := .T.
            lUpdTitulo := .T.
         ENDIF

         cDefTitulo := aTitulo[2]

      ENDIF

      IF lStart .OR. lUpdTitulo

         nSizeTitulo := Len( aTitulo[1] ) + If( Len( aTitulo ) = 1, 2, 0 )

         vDef( @nBottom, MaxRow() -2 )
         vDef( @nLeft  , Int( ( 80  - nSizeTitulo ) / 2 ) )

         IF ( ! lUpdTitulo ) .AND. cShow <> NIL
            nBottom -= ( NumToken( cShow, "|" ) + 1 )
         ENDIF

         nTop   := nBottom + 2 - ( 3 + Len( aTitulo ) ) - nItens
         nRight := nLeft + nSizeTitulo - 1
         lStart := .F.

         IF cShow <> NIL .AND. nTop <= 0
            nItens := 16 - NumToken( cShow, "|" )
            nTop   := 2
         ENDIF

      ENDIF

      IF ! lMore .OR. lUpdTitulo

         IF lUpdTitulo
            @ nTop, nLeft TO nBottom, nRight
            h_Print( nTop + 3, nBottom - 1, nRight, Chr(24), "±", Chr(25) )
            Say( nTop, nLeft + 1, PadC( cTitulo, nRight - nLeft -1, "Ä" ) )
         ELSE
            Muda_Cor( 01, 00, MaxRow() - 1, 79, nCorFundo )
            Limpa( nTop, nLeft, nBottom, nRight, "SB", cTitulo )
         ENDIF

         IF nBottom < 22 .AND. nTop > 1 .AND. cTitulo <> NIL .AND. ! Empty( cTitulo ) .AND. ! lLeft
            @ nBottom, nLeft, 22, nRight BOX "ÃÄ´³ÙÄÀ³ "
         ENDIF

      ENDIF

      SetColor( cSavCorBrow )

      IF Len( aTitulo ) = 1
         @ nBottom -1 - nItens, nLeft +1 SAY aTitulo[1] COLOR cCorTitulo
         @ nTop, nLeft TO nBottom, nRight
      ELSE
         @ nBottom -1 - nItens, nLeft SAY aTitulo[1]

         SetPos( nBottom -2 - nItens, nLeft +1 )

         cTitPrint := aTitulo[2]

         DO WHILE Len( cTitPrint ) > 0
            IF At( "³", cTitPrint ) = 0
               @ Row(),Col() SAY cTitPrint COLOR cCorTitulo
               cTitPrint := ""
            ELSE
               @ Row(),Col() SAY Left( cTitPrint, At( "³", cTitPrint ) -1 ) COLOR cCorTitulo
               @ Row(),Col() SAY "³"
               cTitPrint := Subs( cTitPrint, At( "³", cTitPrint ) +1 )
            ENDIF
         ENDDO

      ENDIF

      oBrowse := StockBrowseNew( nTop +1 + Len( aTitulo ), nLeft +1, nBottom -1, nRight -1, aCols )

      oBrowse:headSep   := ""
      oBrowse:colSep    := "³"
      oBrowse:cargo     := { .T., cTitulo }

      IF bParameters <> NIL
         Eval( bParameters, @oBrowse )
      ENDIF

      IF nBeginKey = K_CTRL_PGDN .OR. aScan( aTbrBottom, { |x| x[1] = Alias() } ) > 0
         oBrowse:goBottom()
      ENDIF

      mxDbRefresh()
      ForceStable( oBrowse, .T., .F. )

      mxDispEnd()

      IF ! lSisCS308 .AND. ! lMore .AND. lDispEnd <> NIL .AND. lDispEnd
         mxDispEnd()
      ENDIF

      IF lLoop
         mxGoTo( nSavRecno )
         lLoop := .F.
      ENDIF

      lMore := .T.

      DO WHILE lMore

         IF ! mxIn( nReturn, { 5, 6 } )
         
            IF ! lSisCS308
               mxDispBegin()
            ENDIF

            IF Eof()
               mxTop()
            ENDIF

            oBrowse:colPos := oBrowse:colCount

            ForceStable( oBrowse:refreshCurrent() )

            IF Len( aTitulo ) = 2
               Pointer( nTop + 3, nBottom - 1, nRight, brPointer( oBrowse ) )
            ENDIF

            IF cShow <> NIL

               nShowLin := nBottom + NumToken( cShow, "|" )
               cShowAux := "|" + cShow

               DO WHILE At( "|", cShowAux ) > 0
                  @ nShowLin --, oBrowse:nLeft +1 SAY PadR( &( AfterAtNum( "|", cShowAux ) ), nRight - nLeft -3 )
                  cShowAux := BeforAtNum( "|", cShowAux )
               ENDDO

            ENDIF

            oBrowse:colorRect( { oBrowse:rowPos, oBrowse:freeze + 1, oBrowse:rowPos,oBrowse:colCount }, Eval( bColorRect ) )

            IF cFuncStat <> NIL

               nSavRow := Row()
               nSavCol := Col()

               IF ! Empty( CprAll )
                  cSavTel := SaveScreen( nBottom, nLeft, nBottom, nRight )
               ENDIF

               IF ValType( cFuncStat ) = "B"
                  Eval( cFuncStat, @oBrowse, @nOrder )
               ELSE
                  IF At( "(", cFuncStat ) = 0
                     cFuncStat += "()"
                  ENDIF
                  Eval( { || &( cFuncStat ) } )
               ENDIF

               IF ! Empty( CprAll )
                  RestScreen( nBottom, nLeft, nBottom, nRight, cSavTel )
               ENDIF

               SetPos( nSavRow, nSavCol )

            ENDIF

            IF ! lSisCS308
               mxDispEnd()
            ENDIF

         ENDIF

         IF cTitulo <> NIL .AND. ! Empty( cTitulo ) .AND. cTitulo <> oBrowse:cargo[ 2 ]

            cTitulo := oBrowse:cargo[ 2 ]

            Say( nTop, nLeft + 1, PadC( cTitulo, nRight - nLeft -1, "Ä" ) )

         ENDIF

         IF nReturn <> 6

            IF nBeginKey = 0
               nTbKey    := GetKey( oBrowse, nLeft +1, nRight -1, cCorBarra )
            ELSE
               nTbKey    := nBeginKey
               nBeginKey := 0
            ENDIF

         ENDIF

         nReturn :=  0
         lClear  := .T.

         IF ElapTime( cTimeAlert, Time() ) >= "00:00:10"
            IF File( "MACS.SET" )
               MsgDlg( "Abandone o sistema agora mesmo!;;Sistema em manuten‡„o." )
               cTimeAlert := Time()
            ENDIF
         ENDIF

         IF oBrowse:cargo[1]

            lPressKey := .T.

            DO CASE
               CASE BrwKey( @oBrowse, nTbKey, { K_RIGHT, K_LEFT } )

                    // Nada a executar.

               CASE nTbKey = K_ALT_O .AND. lF4

                    nOrder := aSelect( aSelOrder, "Sele‡„o de ordem", NIL, NIL, NIL, 3 )

                    IF nOrder <> 0

                       nOrder := blockToVal( aSelOrder[ nOrder, 2 ] )

                       DO WHILE ( nDefOrder := tbGetOrder( aIndex ) ) <> nOrder
                          tbDefOrder( @aCols, @aIndex, @aSeque, @aTit )
                       ENDDO

                       nSavRecno := mxRecno()
                       lLoop := .T.
                       lMore := .T.

                       EXIT

                    ENDIF

               CASE nTbKey = K_F4 .AND. lF4

                    tbDefOrder( @aCols, @aIndex, @aSeque, @aTit )

                    nOrder := tbGetOrder( aIndex )

                    nSavRecno := mxRecno()
                    lLoop := .T.
                    lMore := .T.

                    EXIT

               OTHERWISE
                    lPressKey := .F.
            ENDCASE

         ELSE

            lPressKey := .F.

         ENDIF

         IF lPressKey

            ClearKeybBuffer()

         ELSEIF nTbKey <> 0

            mxDbRefresh()
            DefCursor()

            IF ValType( cFuncKey ) = "B"
               nReturn := Eval( cFuncKey, @oBrowse, @nOrder, @lUpdList )
            ELSE
               nReturn := Eval( { || &( cFuncKey + "()" ) } )
            ENDIF

            nKey := LastKey()

            IF nReturn = 0

               lMore := lLoop := ( ! mxIn( nKey, { K_ENTER, K_ESC } ) )

               IF lMore .AND. nKey = K_F4 .AND. lF4
                  tbDefOrder( @aCols, @aIndex, @aSeque, @aTit )
                  nOrder := tbGetOrder( aIndex )
               ENDIF

            ELSEIF mxIn( nReturn, { 3, 4 } )

               IF Eof()
                  oBrowse:GoBottom()
               ENDIF
               oBrowse:refreshAll()

            ELSEIF mxIn( nReturn, { 5, 6 } )

               IF nReturn = 5
                  oBrowse:goTop()
               ENDIF

               RepeatKey()

            ENDIF

            SetCursor(0)

         ENDIF

         lClear := .F.

         IF nReturn = 3

            @ nBottom, nLeft + 1 SAY "[" + PadR( CprAll, nRight - nLeft - 3 ) + "]" COLOR cCorTitulo

         ELSEIF ! Empty( CprAll ) .AND. ( nReturn <> 5 .OR. lClear )

            IF ++ nAfterDig = 15 .OR. CprAll = "." .OR. lClear

               @ nBottom, nLeft + 1 SAY Repl( "Ä", nRight - nLeft - 1 )

               CprAll    := ""
               lMore     := .T.
               nAfterDig := 0

            ENDIF

         ENDIF

         IF nReturn <> 6
            nTbKey := 0
         ENDIF

         IF lLoop
            lLoop     := lModeAbort .AND. lMore
            nSavRecno := mxRecno()
            EXIT
         ENDIF

      ENDDO

      IF ! lLoop
         EXIT
      ENDIF

   ENDDO

   IF lSavScreen
      RestScreen( NIL, NIL, NIL, NIL, cSavScreen )
   ENDIF

   SetCursor( nSavCursor )

   RELEASE MStat  // Variavel usada emn Stat().

RETURN( nTbKey )



FUNCTION tbrDefTitulo( oBrowse, cTitulo )

   oBrowse:cargo[ 2 ] := cTitulo

RETURN( NIL )



STATIC FUNCTION tbGetOrder( aIndex )

   LOCAL nDefOrder := blockToVal( aIndex[ 1, 1 ] )

RETURN( nDefOrder )



STATIC FUNCTION tbDefOrder( aCols, aIndex, aSeque, aTit )

   LOCAL aLast := aIndex[1]

   aDel( aIndex, 1 )
   aSize( aIndex, Len( aIndex ) -1 )

   aAdd( aIndex, aLast )

   aEval( aIndex, { |i,n| aCols[ aSeque[ n ] ] := i } )

   DefTitulo( @aCols, @aTit )

RETURN( NIL )



STATIC FUNCTION DefTitulo( aCols, aTit )

   LOCAL nCount, cCol, uTit, nLen, uConf, cSimbol

   aTit := {}

   FOR nCount := 1 TO Len( aCols )

      IF ValType( aCols[ nCount ] ) = "A"

         cCol := aCols[ nCount, 2 ]
         uTit := blockToVal( aCols[ nCount, 3 ] )
         nLen := 0

         IF ValType( cCol ) = "B"
            uConf := Eval( cCol )
            DO CASE
               CASE ValType( uConf ) = "N" ; nLen := Len( Str( uConf ) )
               CASE ValType( uConf ) = "D" ; nLen := Len( DtoC( uConf ) )
               OTHE                        ; nLen := Len( uConf )
            ENDCASE
         ELSEIF Type( cCol ) = "N"
            nLen := Len( Str( &cCol ) )
         ELSEIF Type( cCol ) = "D"
            nLen := Len( DtoC( &cCol ) )
         ELSE
            nLen := Len( &cCol )
         ENDIF

         aCols[ nCount, 4 ] := ( nLen > 0 )

         IF nLen > 0
            cSimbol := "Í"
            IF aCols[ nCount, 1 ] <> NIL .AND. ( ValType( aCols[ nCount, 1 ] ) = "N" .OR. ValType( Eval( aCols[ nCount, 1 ] ) ) = "N" )
               cSimbol := "ì"
            ENDIF
            aAdd( aTit, { cSimbol + Repl( "Í", nLen -1 ), PadC( uTit, nLen, " " ) } )
         ENDIF

      ENDIF

   NEXT

RETURN( NIL )



FUNCTION StockBrowseNew( nTop, nLeft, nBottom, nRight, aCols )

   LOCAL oBrowse, oColumn

   oBrowse := TBrowseDB( nTop, nLeft, nBottom, nRight )

   BrwDefCols( @oBrowse, aCols )

RETURN( oBrowse )



STATIC FUNCTION BrwDefCols( oBrowse, aCols )

   LOCAL nCount, oColumn

   PRIV cCols

   DO WHILE oBrowse:colCount <> 0
      oBrowse:delColumn(1)
   ENDDO

   FOR nCount := 1 TO Len( aCols )

      IF ValType( aCols[ nCount ] ) = "A"
         IF ! aCols[ nCount, 4 ]
            LOOP
         ENDIF
         cCols := aCols[ nCount, 2 ]
      ELSE
         cCols := aCols[ nCount ]
      ENDIF

      IF ValType( cCols ) <> "B"
         cCols := { || &cCols }
      ENDIF

      oColumn := TBColumnNew( NIL, cCols )

      oBrowse:addColumn( oColumn )

   NEXT

RETURN( oBrowse )



FUNCTION GetKey( oBrowse, nLeft, nRight, cCorBarra )

   LOCAL nKey, bKey

   DO WHILE .T.

      nKey := mxInKey( 60 )

      IF mxIn( nKey, { 0, K_CTRL_PGUP, K_CTRL_PGDN } )
         mxDbRefresh()
      ENDIF

      IF nKey <> 0

         bKey := SetKey( nKey )

         IF bKey = NIL .OR. nKey = K_INS

            DO CASE
               CASE mxIn( nKey, { K_UP, K_PGUP, K_CTRL_PGUP } )
                    IF oBrowse:hitTop
                       LOOP
                    ENDIF
               CASE mxIn( nKey, { K_DOWN, K_PGDN, K_CTRL_PGDN } )
                    IF oBrowse:hitBottom
                       LOOP
                    ENDIF
            ENDCASE

            EXIT
         ENDIF

         Eval( bKey )

      ENDIF

      IF oBrowse <> NIL .AND. Empty( dbFilter() )
         mxDispBegin()
         oBrowse:RefreshAll()
         mxDispEnd()
         EXIT
      ENDIF

   ENDDO

RETURN( nKey )



PROCEDURE ForceStable( oBrow, lRefresh, lDisp )

   LOCAL cUpdField

   IF IndexOrd() > 0
      cUpdField := &( IndexKey() )
   ENDIF

   vDef( @lRefresh, .F. )
   vDef( @lDisp   , .T. )

   IF lDisp
      mxDispBegin()
   ENDIF

   IF lRefresh
      oBrow:RefreshAll()
   ENDIF

   DO WHILE !oBrow:Stabilize()
   ENDDO

   IF lDisp
      mxDispEnd()
   ENDIF

RETURN



FUNCTION tbNPosCol( oBrw, aCols, cCol )

   LOCAL nCol := 0
   LOCAL nReturn, nCount

   FOR nCount := 1 TO Len( aCols )
      IF aCols[ nCount, 4 ]
         nCol ++
      ENDIF
      IF If( ValType( aCols[ nCount, 3 ] ) = "B", Eval( aCols[ nCount, 3 ] ), aCols[ nCount, 3 ] ) = cCol
         EXIT
      ENDIF
   NEXT

   IF nCol <= 0 .OR. nCol -1 > Len( oBrw:aColumnsSep )
      nReturn := 0
   ELSEIF nCol = 1
      nReturn := oBrw:nLeft
   ELSE
      nReturn := oBrw:aColumnsSep[ nCol -1 ] +1
   ENDIF

RETURN( nReturn )


/*---------------------------------------------------------------------------
 DbList( 1                            ,;  // Linha inicial
         1                            ,;  // Coluna inicial
         10                           ,;  // Linha final
         78                           ,;  // Coluna final
         {}                           ,;  // Campos a serem exibidos (todas)
         { NIL, NIL, "@E 9,999.99" }  ,;  // Mascaras das colunas
         { |b| Udf( @b ) }            ,;  // Funcao do usuario
         { Coluna, Rodape, Cabecalho },;  // Separadores, a = Colunas
         { Bloco codigo de definicao de cores } )

 Retorno : Matriz atualizada.
----------------------------------------------------------------------------*/

FUNCTION mxDbList(  ;
                    nRow1      ,;
                    nCol1      ,;
                    nRow2      ,;
                    nCol2      ,;
                    aCols      ,;
                    aMask      ,;
                    bFunction  ,;
                    aSeparators,;
                    bHighLight ,;
                    lBar       ,;
                    cFuncStat   ;
                 )

   LOCAL lInit     := .T.
   LOCAL lExit     := .F.
   LOCAL nReturn   := 1
   LOCAL nKey      := 0
   LOCAL cStrColor := SlColor( SetColor(), 1 )
   LOCAL aColor    := ColorTable( SetColor() )

   LOCAL oBrowse, oCol, nCol, bCol, nRowPos, nColPos, nCount
   LOCAL cClHigh1, cClHigh2, aColBlock, cCol, aNoKeys, nSavRow, nSavCol

   vDef( @lBar, .T. )
   
   IF lBar
      ColorPush( cStrColor + "," + cStrColor + ",,," + cStrColor )
      aNoKeys := { K_RIGHT, K_LEFT }
   ENDIF

   oBrowse := TBrowseDB( nRow1, nCol1, nRow2, nCol2 )

   cClHigh1 := "4/"  + SlValColor( aColor[1], 2 )
   cClHigh2 := "12/" + SlValColor( aColor[2], 2 )

   aAdd( aColor, cClHigh1 )
   aAdd( aColor, cClHigh2 )

   oBrowse:ColorSpec := oBrowse:ColorSpec + "," + cClHigh1 + "," + cClHigh2

   IF lBar
      ColorPop()
   ENDIF

   IF aSeparators = NIL
      aSeparators := {}
   ENDIF

   IF Len( aSeparators ) < 1
      aAdd( aSeparators, "³" )
   ENDIF
   IF Len( aSeparators ) < 2
      aAdd( aSeparators, "" )
   ENDIF
   IF Len( aSeparators ) < 3
      aAdd( aSeparators, "ÂÄ" )
   ENDIF

   oBrowse:ColSep  := aSeparators[1]
   oBrowse:FootSep := aSeparators[2]
   oBrowse:HeadSep := aSeparators[3]

   IF aMask = NIL
      aMask := {}
   ENDIF

   IF aCols = NIL
      aCols := {}
      FOR nCount := 1 TO FCount()
         aAdd( aCols, Field( nCount ) )
      NEXT
   ENDIF

   FOR nCol := 1 TO Len( aCols )

      bCol := aCols[ nCol ]
      
      cCol := NIL
      
      IF ValType( bCol ) = "A"
         cCol := bCol[ 2 ]
         bCol := bCol[ 1 ]
      ENDIF

      IF ValType( bCol ) <> "B"

         IF nCol <= Len( aMask ) .AND. aMask[ nCol ] <> NIL
            bCol := "Tran( " + bCol + ", '" + aMask[ nCol ] + "' )"
         ENDIF

         bCol := "{ || " + bCol + " }"
         bCol := &bCol

      ENDIF

      oCol := TbColumnNew( cCol, bCol )

      IF bHighLight <> NIL
         IF nCol = 1
            oCol:ColorBlock := { || aColBlock := If( Eval( bHighLight ), { 6, 6 }, { 1, 2 } ) }
         ELSE
            oCol:ColorBlock := { || aColBlock }
         ENDIF
      ENDIF

      oBrowse:AddColumn( oCol )

   NEXT

   ClearKeybBuffer()

   DO WHILE ( ! lExit )
   
      IF cFuncStat <> NIL

         nSavRow := Row()
         nSavCol := Col()

         IF ValType( cFuncStat ) = "B"
            Eval( cFuncStat, @oBrowse )
         ELSE
            IF At( "(", cFuncStat ) = 0
               cFuncStat += "()"
            ENDIF
            Eval( { || &( cFuncStat ) } )
         ENDIF

         SetPos( nSavRow, nSavCol )

      ENDIF

      mxDispBegin()

      ForceStable( oBrowse:RefreshCurrent() )

      nRowPos := Row()
      nColPos := Col()

      ForceStable( oBrowse )

      IF lBar

         IF bHighLight = NIL .OR. ! Eval( bHighLight )
            BackGround( nRowPos, nCol1, nRowPos, nCol2, ConvStrColor( aColor[2] ) )
         ELSE
            BackGround( nRowPos, nCol1, nRowPos, nCol2, ConvStrColor( aColor[7] ) )
         ENDIF

      ENDIF

      mxDispEnd()
      SetCursor(0)

      IF ! lInit
         nKey := mxInKey()
      ENDIF

      IF BrwKey( @oBrowse, nKey, aNoKeys )
         ForceStable( oBrowse:RefreshCurrent() )
      ENDIF

      lInit := .F.

      IF bFunction <> NIL
         nReturn := Eval( bFunction, @oBrowse )
      ENDIF

      IF nReturn <> 0
         SetPos( nRowPos, nColPos )
      ENDIF

      DO CASE
         CASE nReturn = 0
              lExit := .T.
         CASE nReturn = 1
              DO CASE
                 // CASE BrwKey( @oBrowse, nKey )
                      // Nada a executar.
                 CASE nKey = K_ESC
                      IF bFunction = NIL
                         lExit := .T.
                      ENDIF
              ENDCASE

              IF bFunction <> NIL
                 ForceStable( oBrowse:RefreshCurrent(), .F. )
                 Eval( bFunction, @oBrowse )
              ENDIF

         CASE nReturn = 2
              oBrowse:RefreshAll()
      ENDCASE

   ENDDO

RETURN( NIL )



FUNCTION PointerTbr( oBrowse, cCor )

   Pointer( oBrowse:nTop, oBrowse:nBottom, oBrowse:nRight + 1, brPointer( oBrowse ), cCor )

RETURN( NIL )



FUNCTION tbrBarra( oBrowse, nColorBar, nColorCel, nColorBrw )

   LOCAL aPos := SavePos()

   DO CASE
      CASE nColorBar = nColorCel

           oBrowse:ColorRect( { oBrowse:RowPos  ,;
                                1               ,;
                                oBrowse:RowPos  ,;
                                oBrowse:ColCount }, { nColorBar, nColorBrw } )

      CASE oBrowse:ColPos = 1

           oBrowse:ColorRect( { oBrowse:RowPos  ,;
                                1               ,;
                                oBrowse:RowPos  ,;
                                1                }, { nColorCel, nColorBrw } )

           oBrowse:ColorRect( { oBrowse:RowPos  ,;
                                2               ,;
                                oBrowse:RowPos  ,;
                                oBrowse:ColCount }, { nColorBar, nColorBrw } )

      CASE oBrowse:ColPos = oBrowse:ColCount

           oBrowse:ColorRect( { oBrowse:RowPos     ,;
                                1                  ,;
                                oBrowse:RowPos     ,;
                                oBrowse:ColCount -1 }, { nColorBar, nColorBrw } )

           oBrowse:ColorRect( { oBrowse:RowPos  ,;
                                oBrowse:ColCount,;
                                oBrowse:RowPos  ,;
                                oBrowse:ColCount }, { nColorCel, nColorBrw } )

      OTHERWISE

           oBrowse:ColorRect( { oBrowse:RowPos   ,;
                                1                ,;
                                oBrowse:RowPos   ,;
                                oBrowse:ColPos -1 }, { nColorBar, nColorBrw } )

           oBrowse:ColorRect( { oBrowse:RowPos   ,;
                                oBrowse:ColPos +1,;
                                oBrowse:RowPos   ,;
                                oBrowse:ColCount  }, { nColorBar, nColorBrw } )

           oBrowse:ColorRect( { oBrowse:RowPos,;
                                oBrowse:ColPos,;
                                oBrowse:RowPos,;
                                oBrowse:ColPos }, { nColorCel, nColorBrw } )
   ENDCASE

   RestPos( aPos )

RETURN( NIL )



FUNCTION tbrBottom( cAlias, lActive )

   LOCAL nAlias

   IF Len( cAlias ) = 3
      cAlias := "MX" + cAlias + sisFlgModule()
   ENDIF

   nAlias := aScan( aTbrBottom, { |x| x[1] = cAlias } )

   IF lActive
      IF nAlias = 0
         aAdd( aTbrBottom, { cAlias, 0 } )
         nAlias := Len( aTbrBottom )
      ENDIF
      aTbrBottom[ nAlias, 2 ] ++
   ELSEIF nAlias <> 0
      IF aTbrBottom[ nAlias, 2 ] = 1
         aDel( aTbrBottom, Len( aTbrBottom ) )
         aSize( aTbrBottom, Len( aTbrBottom ) - 1 )
      ELSE
         aTbrBottom[ nAlias, 2 ] --
      ENDIF
   ENDIF

RETURN( NIL )



FUNCTION lsSelectAll( uSelect, uCol, cSel, cUnSel )

   LOCAL lMark, cAlias

   PRIV cField

   vDef( @cSel  , "[X]" )
   vDef( @cUnSel, "[ ]" )

   IF ValType( uSelect ) = "A"

      aReplace( @uSelect, If( aScan( uSelect, { |x| x[ uCol ] = cUnSel } ) = 0, cUnSel, cSel ), uCol )

   ELSE

      cAlias := uSelect
      cField := uCol

      ( cAlias )->( GetBookMark() )

      lMark  := ( cAlias )->( mxLocate( { || &cField = " " } ) )

      ( cAlias )->( mxTop() )

      DO WHILE ! ( cAlias )->( Eof() )

         mxWait( If( lMark, "", "des" ) + "marcando registros" )

         ( cAlias )->&cField := If( lMark, cSel, cUnSel )
         ( cAlias )->( mxSkip() )

      ENDDO

      ( cAlias )->( GoToBookMark() )

   ENDIF

RETURN( uSelect )



FUNCTION brPointer( oBrowse )

   LOCAL nPointer := 0

   DO CASE
      CASE oBrowse:hitTop    ; nPointer := 1
      CASE oBrowse:hitBottom ; nPointer := 2
   ENDCASE

RETURN( nPointer )



FUNCTION Barra( nRow1, nCol1, nRow2, nCol2, lTop, lBott, nMode, nCor )

   vDef( @nCor, 112 )

   IF lTop <> NIL .AND. lBott <> NIL .AND. nMode <> NIL
      Pointer( lTop, lBott, nCol2+1, nMode )
   ENDIF

   Muda_Cor( nRow1, nCol1, nRow2, nCol2, nCor )
   SetCursor( 0 )
   SET CONS OFF
   WAIT

   IF mxIn( LastKey(), { 3, 4, 5, 6, 8, 18, 19, 22, 23, 24, 26, 29, 30, 31 } )
      RepeatKey()
   ENDIF

   @ nRow1,nCol1 SAY ""
   SET CONS ON
   DefCursor()

RETURN( .T. )



FUNCTION UF( cUF, lTodos, lNaoDefinido )

   IF cUF = NIL
      RETURN( aUF )
   ENDIF

   cUF := Upper( cUF )

   IF aScan( aUF, { |x| cUF = x[2] } ) = 0
      cUF := ListUF( cUF, lTodos, lNaoDefinido )
   ENDIF

RETURN( .T. )



STATIC FUNCTION ListUF( cUF, lTodos, lNaoDefinido )

   LOCAL cSavCor := SetColor( "0/7,15/0,,,0/7" )
   LOCAL nSavRow := Row()
   LOCAL nSavCol := Col()
   LOCAL aListUF := {}

   LOCAL nLinIni, nLinFim, nColIni, nPosIni, nOpc

   vDef( @lTodos      , .F. )
   vDef( @lNaoDefinido, .F. )

   aAddC( aListUF, "    - Todos              ", lTodos )
   aAddC( aListUF, "    - Nao definido       ", lNaoDefinido )

   aEval( aUF, { |x| aAdd( aListUF, " " + x[2] + " - " + x[3] ) } )

   MStatus( { { "ESC", "15/7"}, { "úRetorna  ³  ","0/7" }, { "Ù", "15/7" }, { "úSeleciona   ", "0/7" } }, 2 )

   IF nSavCol - Len( cUF ) +27 > 79
      nColIni := nSavCol - Len( cUF ) -26
   ELSE
      nColIni := nSavCol - Len( cUF ) +1
   ENDIF

   IF nSavRow +8 > 22
      nLinIni := nSavRow -7
      nLinFim := nSavRow -2
   ELSE
      nLinIni := nSavRow +2
      nLinFim := nSavRow +7
   ENDIF

   IF ( lTodos .OR. lNaoDefinido ) .AND. Empty( cUF )
      nPosIni := 0
   ELSE
      nPosIni := aScan( aListUF, { |x| Subs( x, 2, 2 ) = GetNoEmpty( CFIESTCTR, "SP" ) } )
   ENDIF

   ScreenSave()

   Limpa( nLinIni -1, nColIni -1, nLinFim +1, nColIni +27, "s", NIL, "0/7" )

   nOpc := aChoice( nLinIni, nColIni, nLinFim, nColIni +26, aListUF, .T., "M_List", GetNoEmpty( nPosIni, 1 ) )

   ScreenRest()
   SetColor( cSavCor )
   ClearKeybBuffer()

   IF nOpc <> 0
      RETURN( Subs( aListUF[ nOpc ], 2, 2 ) )
   ENDIF

RETURN( cUF )



FUNCTION codPais( uPais, nLen, cNome )

   LOCAL cSavCor
   LOCAL nSavRow   := Row()
   LOCAL nSavCol   := Col()
   LOCAL aListPais := {}

   LOCAL nLinIni, nLinFim, nColIni, nOpc, cAux

   vDef( @nLen, 36 )

   IF Len( aPais ) = 0

      aAdd( aPais, { "0132", "AFEGANISTAO                         " } )
      aAdd( aPais, { "0175", "ALBANIA, REPUBLICA DA               " } )
      aAdd( aPais, { "0230", "ALEMANHA                            " } )
      aAdd( aPais, { "0310", "BURKINA FASO                        " } )
      aAdd( aPais, { "0370", "ANDORRA                             " } )
      aAdd( aPais, { "0400", "ANGOLA                              " } )
      aAdd( aPais, { "0418", "ANGUILLA                            " } )
      aAdd( aPais, { "0434", "ANTIGUA E BARBUDA                   " } )
      aAdd( aPais, { "0477", "ANTILHAS HOLANDESAS                 " } )
      aAdd( aPais, { "0531", "ARABIA SAUDITA                      " } )
      aAdd( aPais, { "0590", "ARGELIA                             " } )
      aAdd( aPais, { "0639", "ARGENTINA                           " } )
      aAdd( aPais, { "0647", "ARMENIA, REPUBLICA DA               " } )
      aAdd( aPais, { "0655", "ARUBA                               " } )
      aAdd( aPais, { "0698", "AUSTRALIA                           " } )
      aAdd( aPais, { "0728", "AUSTRIA                             " } )
      aAdd( aPais, { "0736", "AZERBAIJAO, REPUBLICA DO            " } )
      aAdd( aPais, { "0779", "BAHAMAS, ILHAS                      " } )
      aAdd( aPais, { "0809", "BAHREIN, ILHAS                      " } )
      aAdd( aPais, { "0817", "BANGLADESH                          " } )
      aAdd( aPais, { "0833", "BARBADOS                            " } )
      aAdd( aPais, { "0850", "BELARUS, REPUBLICA DA               " } )
      aAdd( aPais, { "0876", "BELGICA                             " } )
      aAdd( aPais, { "0884", "BELIZE                              " } )
      aAdd( aPais, { "0906", "BERMUDAS                            " } )
      aAdd( aPais, { "0930", "MIANMAR (BIRMANIA)                  " } )
      aAdd( aPais, { "0973", "BOLIVIA, ESTADO PLURINACIONAL DA    " } )
      aAdd( aPais, { "0981", "BOSNIA-HERZEGOVINA, REPUBLICA DA    " } )
      aAdd( aPais, { "1015", "BOTSUANA                            " } )
      aAdd( aPais, { "1082", "BRUNEI                              " } )
      aAdd( aPais, { "1112", "BULGARIA, REPUBLICA DA              " } )
      aAdd( aPais, { "1155", "BURUNDI                             " } )
      aAdd( aPais, { "1198", "BUTAO                               " } )
      aAdd( aPais, { "1279", "CABO VERDE, REPUBLICA DE            " } )
      aAdd( aPais, { "1376", "CAYMAN, ILHAS                       " } )
      aAdd( aPais, { "1414", "CAMBOJA                             " } )
      aAdd( aPais, { "1457", "CAMAROES                            " } )
      aAdd( aPais, { "1490", "CANADA                              " } )
      aAdd( aPais, { "1504", "GUERNSEY, ILHA DO CANAL             " } )
      aAdd( aPais, { "1508", "JERSEY, ILHA DO CANAL               " } )
      aAdd( aPais, { "1511", "CANARIAS, ILHAS                     " } )
      aAdd( aPais, { "1538", "CAZAQUISTAO, REPUBLICA DO           " } )
      aAdd( aPais, { "1546", "CATAR                               " } )
      aAdd( aPais, { "1589", "CHILE                               " } )
      aAdd( aPais, { "1600", "CHINA, REPUBLICA POPULAR            " } )
      aAdd( aPais, { "1619", "FORMOSA (TAIWAN)                    " } )
      aAdd( aPais, { "1635", "CHIPRE                              " } )
      aAdd( aPais, { "1651", "COCOS (KEELING), ILHAS              " } )
      aAdd( aPais, { "1694", "COLOMBIA                            " } )
      aAdd( aPais, { "1732", "COMORES, ILHAS                      " } )
      aAdd( aPais, { "1775", "CONGO                               " } )
      aAdd( aPais, { "1830", "COOK, ILHAS                         " } )
      aAdd( aPais, { "1872", "COREIA DO NORTE, REP.POP.DEMOCRATICA" } )
      aAdd( aPais, { "1902", "COREIA DO SUL, REPUBLICA DA         " } )
      aAdd( aPais, { "1937", "COSTA DO MARFIM                     " } )
      aAdd( aPais, { "1953", "CROACIA, REPUBLICA DA               " } )
      aAdd( aPais, { "1961", "COSTA RICA                          " } )
      aAdd( aPais, { "1988", "COVEITE                             " } )
      aAdd( aPais, { "1996", "CUBA                                " } )
      aAdd( aPais, { "2291", "BENIN                               " } )
      aAdd( aPais, { "2321", "DINAMARCA                           " } )
      aAdd( aPais, { "2356", "DOMINICA, ILHA                      " } )
      aAdd( aPais, { "2399", "EQUADOR                             " } )
      aAdd( aPais, { "2402", "EGITO                               " } )
      aAdd( aPais, { "2437", "ERITREIA                            " } )
      aAdd( aPais, { "2445", "EMIRADOS ARABES UNIDOS              " } )
      aAdd( aPais, { "2453", "ESPANHA                             " } )
      aAdd( aPais, { "2461", "ESLOVENIA, REPUBLICA DA             " } )
      aAdd( aPais, { "2470", "ESLOVACA, REPUBLICA                 " } )
      aAdd( aPais, { "2496", "ESTADOS UNIDOS                      " } )
      aAdd( aPais, { "2518", "ESTONIA, REPUBLICA DA               " } )
      aAdd( aPais, { "2534", "ETIOPIA                             " } )
      aAdd( aPais, { "2550", "FALKLAND (ILHAS MALVINAS)           " } )
      aAdd( aPais, { "2593", "FEROE, ILHAS                        " } )
      aAdd( aPais, { "2674", "FILIPINAS                           " } )
      aAdd( aPais, { "2712", "FINLANDIA                           " } )
      aAdd( aPais, { "2755", "FRANCA                              " } )
      aAdd( aPais, { "2810", "GABAO                               " } )
      aAdd( aPais, { "2852", "GAMBIA                              " } )
      aAdd( aPais, { "2895", "GANA                                " } )
      aAdd( aPais, { "2917", "GEORGIA, REPUBLICA DA               " } )
      aAdd( aPais, { "2933", "GIBRALTAR                           " } )
      aAdd( aPais, { "2976", "GRANADA                             " } )
      aAdd( aPais, { "3018", "GRECIA                              " } )
      aAdd( aPais, { "3050", "GROENLANDIA                         " } )
      aAdd( aPais, { "3093", "GUADALUPE                           " } )
      aAdd( aPais, { "3131", "GUAM                                " } )
      aAdd( aPais, { "3174", "GUATEMALA                           " } )
      aAdd( aPais, { "3255", "GUIANA FRANCESA                     " } )
      aAdd( aPais, { "3298", "GUINE                               " } )
      aAdd( aPais, { "3310", "GUINE-EQUATORIAL                    " } )
      aAdd( aPais, { "3344", "GUINE-BISSAU                        " } )
      aAdd( aPais, { "3379", "GUIANA                              " } )
      aAdd( aPais, { "3417", "HAITI                               " } )
      aAdd( aPais, { "3450", "HONDURAS                            " } )
      aAdd( aPais, { "3514", "HONG KONG                           " } )
      aAdd( aPais, { "3557", "HUNGRIA, REPUBLICA DA               " } )
      aAdd( aPais, { "3573", "IEMEN                               " } )
      aAdd( aPais, { "3595", "MAN, ILHA DE                        " } )
      aAdd( aPais, { "3611", "INDIA                               " } )
      aAdd( aPais, { "3654", "INDONESIA                           " } )
      aAdd( aPais, { "3697", "IRAQUE                              " } )
      aAdd( aPais, { "3727", "IRA, REPUBLICA ISLAMICA DO          " } )
      aAdd( aPais, { "3751", "IRLANDA                             " } )
      aAdd( aPais, { "3794", "ISLANDIA                            " } )
      aAdd( aPais, { "3832", "ISRAEL                              " } )
      aAdd( aPais, { "3867", "ITALIA                              " } )
      aAdd( aPais, { "3913", "JAMAICA                             " } )
      aAdd( aPais, { "3964", "JOHNSTON, ILHAS                     " } )
      aAdd( aPais, { "3999", "JAPAO                               " } )
      aAdd( aPais, { "4030", "JORDANIA                            " } )
      aAdd( aPais, { "4111", "KIRIBATI                            " } )
      aAdd( aPais, { "4200", "LAOS, REP.POP.DEMOCR.DO             " } )
      aAdd( aPais, { "4235", "LEBUAN,ILHAS                        " } )
      aAdd( aPais, { "4260", "LESOTO                              " } )
      aAdd( aPais, { "4278", "LETONIA, REPUBLICA DA               " } )
      aAdd( aPais, { "4316", "LIBANO                              " } )
      aAdd( aPais, { "4340", "LIBERIA                             " } )
      aAdd( aPais, { "4383", "LIBIA                               " } )
      aAdd( aPais, { "4405", "LIECHTENSTEIN                       " } )
      aAdd( aPais, { "4421", "LITUANIA, REPUBLICA DA              " } )
      aAdd( aPais, { "4456", "LUXEMBURGO                          " } )
      aAdd( aPais, { "4472", "MACAU                               " } )
      aAdd( aPais, { "4499", "MACEDONIA, ANT.REP.IUGOSLAVA        " } )
      aAdd( aPais, { "4502", "MADAGASCAR                          " } )
      aAdd( aPais, { "4525", "MADEIRA, ILHA DA                    " } )
      aAdd( aPais, { "4553", "MALASIA                             " } )
      aAdd( aPais, { "4588", "MALAVI                              " } )
      aAdd( aPais, { "4618", "MALDIVAS                            " } )
      aAdd( aPais, { "4642", "MALI                                " } )
      aAdd( aPais, { "4677", "MALTA                               " } )
      aAdd( aPais, { "4723", "MARIANAS DO NORTE                   " } )
      aAdd( aPais, { "4740", "MARROCOS                            " } )
      aAdd( aPais, { "4766", "MARSHALL, ILHAS                     " } )
      aAdd( aPais, { "4774", "MARTINICA                           " } )
      aAdd( aPais, { "4855", "MAURICIO                            " } )
      aAdd( aPais, { "4880", "MAURITANIA                          " } )
      aAdd( aPais, { "4885", "MAYOTTE (ILHAS FRANCESAS)           " } )
      aAdd( aPais, { "4901", "MIDWAY, ILHAS                       " } )
      aAdd( aPais, { "4936", "MEXICO                              " } )
      aAdd( aPais, { "4944", "MOLDAVIA, REPUBLICA DA              " } )
      aAdd( aPais, { "4952", "MONACO                              " } )
      aAdd( aPais, { "4979", "MONGOLIA                            " } )
      aAdd( aPais, { "4985", "MONTENEGRO                          " } )
      aAdd( aPais, { "4995", "MICRONESIA                          " } )
      aAdd( aPais, { "5010", "MONTSERRAT, ILHAS                   " } )
      aAdd( aPais, { "5053", "MOCAMBIQUE                          " } )
      aAdd( aPais, { "5070", "NAMIBIA                             " } )
      aAdd( aPais, { "5088", "NAURU                               " } )
      aAdd( aPais, { "5118", "CHRISTMAS (NAVIDAD), ILHA           " } )
      aAdd( aPais, { "5177", "NEPAL                               " } )
      aAdd( aPais, { "5215", "NICARAGUA                           " } )
      aAdd( aPais, { "5258", "NIGER                               " } )
      aAdd( aPais, { "5282", "NIGERIA                             " } )
      aAdd( aPais, { "5312", "NIUE, ILHA                          " } )
      aAdd( aPais, { "5355", "NORFOLK, ILHA                       " } )
      aAdd( aPais, { "5380", "NORUEGA                             " } )
      aAdd( aPais, { "5428", "NOVA CALEDONIA                      " } )
      aAdd( aPais, { "5452", "PAPUA NOVA GUINE                    " } )
      aAdd( aPais, { "5487", "NOVA ZELANDIA                       " } )
      aAdd( aPais, { "5517", "VANUATU                             " } )
      aAdd( aPais, { "5568", "OMA                                 " } )
      aAdd( aPais, { "5665", "PACIFICO, ILHAS DO                  " } )
      aAdd( aPais, { "5738", "PAISES BAIXOS (HOLANDA)             " } )
      aAdd( aPais, { "5754", "PALAU                               " } )
      aAdd( aPais, { "5762", "PAQUISTAO                           " } )
      aAdd( aPais, { "5800", "PANAMA                              " } )
      aAdd( aPais, { "5860", "PARAGUAI                            " } )
      aAdd( aPais, { "5894", "PERU                                " } )
      aAdd( aPais, { "5932", "PITCAIRN,ILHA                       " } )
      aAdd( aPais, { "5991", "POLINESIA FRANCESA                  " } )
      aAdd( aPais, { "6033", "POLONIA, REPUBLICA DA               " } )
      aAdd( aPais, { "6076", "PORTUGAL                            " } )
      aAdd( aPais, { "6114", "PORTO RICO                          " } )
      aAdd( aPais, { "6238", "QUENIA                              " } )
      aAdd( aPais, { "6254", "QUIRGUIZ, REPUBLICA                 " } )
      aAdd( aPais, { "6289", "REINO UNIDO                         " } )
      aAdd( aPais, { "6408", "REPUBLICA CENTRO-AFRICANA           " } )
      aAdd( aPais, { "6475", "REPUBLICA DOMINICANA                " } )
      aAdd( aPais, { "6602", "REUNIAO, ILHA                       " } )
      aAdd( aPais, { "6653", "ZIMBABUE                            " } )
      aAdd( aPais, { "6700", "ROMENIA                             " } )
      aAdd( aPais, { "6750", "RUANDA                              " } )
      aAdd( aPais, { "6769", "RUSSIA, FEDERACAO DA                " } )
      aAdd( aPais, { "6777", "SALOMAO, ILHAS                      " } )
      aAdd( aPais, { "6858", "SAARA OCIDENTAL                     " } )
      aAdd( aPais, { "6874", "EL SALVADOR                         " } )
      aAdd( aPais, { "6904", "SAMOA                               " } )
      aAdd( aPais, { "6912", "SAMOA AMERICANA                     " } )
      aAdd( aPais, { "6955", "SAO CRISTOVAO E NEVES,ILHAS         " } )
      aAdd( aPais, { "6971", "SAN MARINO                          " } )
      aAdd( aPais, { "7005", "SAO PEDRO E MIQUELON                " } )
      aAdd( aPais, { "7056", "SAO VICENTE E GRANADINAS            " } )
      aAdd( aPais, { "7102", "SANTA HELENA                        " } )
      aAdd( aPais, { "7153", "SANTA LUCIA                         " } )
      aAdd( aPais, { "7200", "SAO TOME E PRINCIPE, ILHAS          " } )
      aAdd( aPais, { "7285", "SENEGAL                             " } )
      aAdd( aPais, { "7315", "SEYCHELLES                          " } )
      aAdd( aPais, { "7358", "SERRA LEOA                          " } )
      aAdd( aPais, { "7370", "SERVIA                              " } )
      aAdd( aPais, { "7412", "CINGAPURA                           " } )
      aAdd( aPais, { "7447", "SIRIA, REPUBLICA ARABE DA           " } )
      aAdd( aPais, { "7480", "SOMALIA                             " } )
      aAdd( aPais, { "7501", "SRI LANKA                           " } )
      aAdd( aPais, { "7544", "SUAZILANDIA                         " } )
      aAdd( aPais, { "7560", "AFRICA DO SUL                       " } )
      aAdd( aPais, { "7595", "SUDAO                               " } )
      aAdd( aPais, { "7641", "SUECIA                              " } )
      aAdd( aPais, { "7676", "SUICA                               " } )
      aAdd( aPais, { "7706", "SURINAME                            " } )
      aAdd( aPais, { "7722", "TADJIQUISTAO, REPUBLICA DO          " } )
      aAdd( aPais, { "7765", "TAILANDIA                           " } )
      aAdd( aPais, { "7803", "TANZANIA, REP.UNIDA DA              " } )
      aAdd( aPais, { "7820", "TERRITORIO BRIT.OC.INDICO           " } )
      aAdd( aPais, { "7838", "DJIBUTI                             " } )
      aAdd( aPais, { "7889", "CHADE                               " } )
      aAdd( aPais, { "7919", "TCHECA, REPUBLICA                   " } )
      aAdd( aPais, { "7951", "TIMOR LESTE                         " } )
      aAdd( aPais, { "8001", "TOGO                                " } )
      aAdd( aPais, { "8052", "TOQUELAU, ILHAS                     " } )
      aAdd( aPais, { "8109", "TONGA                               " } )
      aAdd( aPais, { "8150", "TRINIDAD E TOBAGO                   " } )
      aAdd( aPais, { "8206", "TUNISIA                             " } )
      aAdd( aPais, { "8230", "TURCAS E CAICOS,ILHAS               " } )
      aAdd( aPais, { "8249", "TURCOMENISTAO, REPUBLICA DO         " } )
      aAdd( aPais, { "8273", "TURQUIA                             " } )
      aAdd( aPais, { "8281", "TUVALU                              " } )
      aAdd( aPais, { "8311", "UCRANIA                             " } )
      aAdd( aPais, { "8338", "UGANDA                              " } )
      aAdd( aPais, { "8451", "URUGUAI                             " } )
      aAdd( aPais, { "8478", "UZBEQUISTAO, REPUBLICA DO           " } )
      aAdd( aPais, { "8486", "VATICANO, EST.DA CIDADE DO          " } )
      aAdd( aPais, { "8508", "VENEZUELA                           " } )
      aAdd( aPais, { "8583", "VIETNA                              " } )
      aAdd( aPais, { "8630", "VIRGENS (BRITANICAS), ILHAS         " } )
      aAdd( aPais, { "8664", "VIRGENS (EUA), ILHAS                " } )
      aAdd( aPais, { "8702", "FIJI                                " } )
      aAdd( aPais, { "8737", "WAKE, ILHA                          " } )
      aAdd( aPais, { "8885", "CONGO, REPUBLICA DEMOCRATICA DO     " } )
      aAdd( aPais, { "8907", "ZAMBIA                              " } )

   ENDIF

   aSort( aPais, NIL, NIL, { |x,y| x[2] < y[2] } )

   IF uPais = NIL
      RETURN( aPais )
   ENDIF

   nOpc := aScan( aPais, { |x| uPais = x[1] } )

   IF nOpc = 0 .AND. cNome = NIL

      cSavCor := SetColor( "0/7,15/0,,,0/7" )

      aEval( aPais, { |x| aAdd( aListPais, " " + x[1] + " - " + x[2] ) } )

      MStatus( { { "ESC", "15/7"}, { "úRetorna  ³  ","0/7" }, { "Ù", "15/7" }, { "úSeleciona   ", "0/7" } }, 2 )

      IF nSavCol - Len( uPais ) +47 > 79
         nColIni := 33
      ELSE
         nColIni := nSavCol - Len( uPais ) +1
      ENDIF

      IF nSavRow +8 > 22
         nLinIni := nSavRow -7
         nLinFim := nSavRow -2
      ELSE
         nLinIni := nSavRow +2
         nLinFim := nSavRow +7
      ENDIF

      ScreenSave()

      Limpa( nLinIni -1, nColIni -1, nLinFim +1, nColIni +45, "s", NIL, "0/7" )

      nOpc := aChoice( nLinIni, nColIni, nLinFim, nColIni +44, aListPais, .T., "M_List" )

      ScreenRest()
      SetColor( cSavCor )
      ClearKeybBuffer()

   ENDIF

   IF nOpc <> 0

      cAux := aPais[ nOpc, 2 ]

      DO WHILE At( ",", cAux ) > 0

         cAux := AllTrim( Subs( cAux, At( ",", cAux ) +1, Len( cAux ) ) ) + " " + ;
                 AllTrim( Left( cAux, At( ",", cAux ) -1 ) )

      ENDDO

      uPais := aPais[ nOpc, 1 ]

      IF cNome = NIL
         @ nSavRow, nSavCol +3 SAY PadR( cAux, nLen )
      ELSE
         cNome := PadR( cAux, nLen )
      ENDIF

   ENDIF

RETURN( .T. )