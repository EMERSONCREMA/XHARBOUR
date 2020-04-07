/*

 MaxArq.prg
 Descricao: Biblioteca de funcoes de tratamento de matrizes.
 Desenvolvido por MAX SCALLA Informatica Ltda.
 
 EMERSON DA SILVA CREMA
 27/05/19 * Ajuste em strToArray() p/ suportar cDl maior que 2 caracteres.
 12/08/15 * Desenvolvido aMax().
 07/05/15 * Desenvolvido aSeqToChr().

 DENIS MAZZUCATTO RODRIGUES
 14/08/12 * Desenvolvimento de aOneDimensional().
 
 EMERSON DA SILVA CREMA
 26/04/12 * Desenvolvimento de aSay().
 19/04/12 * Desenvolvimento de strToArray().

 DENIS MAZZUCATTO RODRIGUES
 16/07/10 * Desenvolvimento de aDelDuplicate().
 30/07/08 * Implementado parametro lCond em aAppend().

 EMERSON DA SILVA CREMA
 19/10/07 * Desenvolvimento de aDelCond().
 06/03/07 * Desenvolvimento de aMoveTop().
          * Removido parametro nSubClear de aClear().
 22/11/06 * Desenvolvimento de aReplace().
 07/11/06 * Desenvolvimento de aLenMax().

 DENIS MAZZUCATTO RODRIGUES
 18/07/06 * Desenvolvimento de aGroup().

*/

#include "std.ch"

/*----------------------------------------------------------------------------
 Verifica se duas matrizes sao iguais.

 Parametros

 aArray1 : 1¦ matriz para comparacao
 aArray2 : 2¦ matriz para comparacao

 Retorno : .T. caso ambas sejam iguais.
----------------------------------------------------------------------------*/

FUNCTION aComp( aArray1, aArray2 )

   LOCAL lReturn := ( Len( aArray1 ) = Len( aArray2 ) )
   LOCAL nCount  := 0

   DO WHILE lReturn .AND. ( ++ nCount ) <= Len( aArray1 )
      lReturn := If( ValType( aArray1[ nCount ] ) = "A", aComp( aArray1[ nCount ], aArray2[ nCount ] ), aArray1[ nCount ] = aArray2[ nCount ] )
   ENDDO

RETURN( lReturn )



/*----------------------------------------------------------------------------
 Deleta o ultimo elemento de uma matriz.

 Parametros

 aArray  : Matriz para delecao do item.

 Retorno : Matriz com o item excluido.
----------------------------------------------------------------------------*/

FUNCTION aDelLast( aArray )

RETURN( aDelPos( aArray, Len( aArray ) ) )



FUNCTION aDelPos( aArray, nPos )

   IF Len( aArray ) > 0
      aArray := aDel( aArray, nPos )
      aArray := aSize( aArray, Len( aArray ) -1 )
   ENDIF

RETURN( aArray )



FUNCTION aDelCond( aArray, bCond )

   LOCAL nPos := aScan( aArray, bCond )

   IF nPos > 0
      aArray := aDelPos( aArray, nPos )
   ENDIF

RETURN( aArray )



/*----------------------------------------------------------------------------
 Soma uma coluna de uma matriz.

 Parametros

 aArray  : Matriz a ser calculada.
 nColumn : Numero da coluna da matriz a ser calculada.

 Retorno : Total do calculo.
----------------------------------------------------------------------------*/

FUNCTION aTotal( aArray, nColumn )

   LOCAL nTotal := 0
   
   IF nColumn = NIL
      aEval( aArray, { |a| nTotal += a } )
   ELSE
      aEval( aArray, { |a| nTotal += a[ nColumn ] } )
   ENDIF

RETURN( nTotal )



/*----------------------------------------------------------------------------
 Retorna o valor maximo de uma matriz.

 Parametros

 aArray  : Matriz a ser analisada.
 nColumn : Numero da coluna da matriz a ser analisada.

 Retorno : Valor maximo.
----------------------------------------------------------------------------*/

FUNCTION aMax( aArray, nColumn )

   LOCAL nMax := 0

   IF nColumn = NIL
      aEval( aArray, { |a| nMax := Max( nMax, a ) } )
   ELSE
      aEval( aArray, { |a| nMax := Max( nMax, a[ nColumn ] ) } )
   ENDIF

RETURN( nMax )




/*----------------------------------------------------------------------------
 Limpa o conteudo de uma matriz ou apenas um elemento.

 Parametros

 aUseArray : Matriz utilizada.
 nPointer  : Ponteiro da matriz.
 nSubClear : Nivel limite para limpeza das matrizes.

 Retorno : Matriz atualizada.

 Exemplo

    ? aClear( { ;
                { Date()  , 2, "A" },;
                { Date()-1, 0, "B" },;
                { Date()+1, 1, "A" } ;
              }, 2 )

    // O retorno sera : { ;
                          { Date()  , 2, "A" },;
                          {   .  .  , 0, " " },;  // O primeiro elemento da
                          { Date()+1, 1, "A" } ;  // matriz utilizada e uma
                        }                         // data vazia
----------------------------------------------------------------------------*/

FUNCTION aClear( aUseArray, nPointer )

   LOCAL aArray, nCount

   IF nPointer = NIL
      aArray := aUseArray
   ELSE
      aArray := aUseArray[ nPointer ]
   ENDIF

   FOR nCount := 1 TO Len( aArray )

      DO CASE
         CASE ValType( aArray[ nCount ] ) = "C"
              aArray[ nCount ] := Space( Len( aArray[ nCount ] ) )
         CASE ValType( aArray[ nCount ] ) = "N"
              aArray[ nCount ] := 0
         CASE ValType( aArray[ nCount ] ) = "D"
              aArray[ nCount ] := CtoD( "" )
         CASE Valtype( aArray[ nCount ] ) = "L"
              aArray[ nCount ] := .F.
         CASE Valtype( aArray[ nCount ] ) = "A"
              aArray[ nCount ] := aClear( aArray[ nCount ] )
      ENDCASE

   NEXT

   IF nPointer <> NIL
      aUseArray[ nPointer ] := aArray
   ENDIF

RETURN( aArray )



/*----------------------------------------------------------------------------
 Move o conteudo de um elemento da matriz para outra posicao.

 Parametros

 aArray : Matriz utilizada.
 nOrig  : Posicao atual do elemento.
 nMove  : Nova posicao.

 Retorno : Matriz atualizada.

 Exemplo

    ? aMove( { 1, 2, 3 }, 2, 1 )
    // O retorno sera: { 2, 1, 3 }
----------------------------------------------------------------------------*/

FUNCTION aMove( aArray, nOrig, nMove )

   LOCAL aMove1 := aArray[ nOrig ]
   LOCAL aMove2 := aArray[ nMove ]

   aArray[ nMove ] := aMove1
   aArray[ nOrig ] := aMove2

RETURN( aClone( aArray ) )



/*----------------------------------------------------------------------------
 Adiciona todos elementos de uma matriz no final de uma outra.

 Parametros

 aArray1 : Matriz que recebera os elementos.
 aArray2 : Matriz que contem os elementos que serao adicionados.

 Retorno : Matriz atualizada.

 Exemplo

 ? aAppend( { 1, 2, 3 }, { 4, 5 } )  // O retorno sera: { 1, 2, 3, 4, 5 }
----------------------------------------------------------------------------*/

FUNCTION aAppend( aArray1, aArray2, lCond )

   LOCAL aReturn := aArray1

   vDef( @lCond, .T. )

   IF lCond
      IF ValType( aArray2 ) = "A"
         aEval( aArray2, { |a| aAdd( aReturn, a ) } )
      ELSE
         aAdd( aReturn, aArray2 )
      ENDIF
   ENDIF

RETURN( aReturn )



/*----------------------------------------------------------------------------
 Adiciona um elemento a matriz mediante condicao.

 Parametros

 aArray1 : Matriz que recebera os elementos.
 uAdd    : Informacao a ser adicionada a matriz.
 lCond   : Condicao para adicao, se = NIL, assume .T.

 Retorno : Matriz atualizada.

 Exemplo

    ? aAddC( { 1, 2, 3 }, 5, Date() = CTOD( "14.01.2009" ) )
    // O retorno sera: { 1, 2, 3, 5 } se for a data acima.
----------------------------------------------------------------------------*/

FUNCTION aAddC( aArray1, uAdd, lCond, lEmpty )

   LOCAL aReturn := aArray1

   vDef( @lCond , .T. )
   vDef( @lEmpty, .T. )

   IF lCond .AND. ( lEmpty .OR. ( uAdd <> NIL .AND. ! Empty( uAdd ) ) )
      aAdd( aReturn, uAdd )
   ENDIF

RETURN( aReturn )



FUNCTION aInsert( aArray1, aArray2, nPos )

   LOCAL aReturn := {}
   LOCAL nArr
   
   vDef( @nPos, 1 )

   FOR nArr := 1 TO nPos -1
      aAdd( aReturn, aArray1[ nArr ] )
   NEXT

   IF ValType( aArray2 ) = "A"
      aReturn := aAppend( aReturn, aArray2 )
   ELSE
      aAdd( aReturn, aArray2 )
   ENDIF

   FOR nArr := nPos TO Len( aArray1 )
      aAdd( aReturn, aArray1[ nArr ] )
   NEXT

RETURN( aReturn )



FUNCTION aGroup( aDefArray, nColumn, bFor )

  LOCAL aReturn := {}
  LOCAL aArray  := aClone( aDefArray )

  LOCAL nCount, nPos

  vDef( @bFor, { || .T. } )

  FOR nCount := 1 TO Len( aArray )

     IF ! Eval( bFor, aArray[ nCount ] )
        LOOP
     ENDIF

     nPos := aScan( aReturn, { |x| x[ nColumn ] = aArray[ nCount, nColumn ] } )

     IF nPos = 0
        aAdd( aReturn, aArray[ nCount ] )
     ELSE
        aEval( aArray[ nCount ], { |x,y| If( ValType( x ) = "N" .AND. ( y <> nColumn ), aReturn[ nPos, y ] += x, NIL ) } )
     ENDIF

  NEXT

  aSort( aReturn, NIL, NIL, { |x,y| x[ nColumn ] < y[ nColumn ] } )

RETURN( aClone( aReturn ) )



FUNCTION aLenMax( aArray, nCol )

   LOCAL nMax := 0

   LOCAL nCount, cStr

   vDef( @nCol, 1 )

   FOR nCount := 1 TO Len( aArray )

      IF ValType( aArray[ nCount ] ) = "A"
         cStr := aArray[ nCount, nCol ]
      ELSE
         cStr := aArray[ nCount ]
      ENDIF

      // Para compatibilizacao com funcoes de menus.

      cStr := StrTran( cStr, "&", "" )

      IF Len( cStr ) > nMax
         nMax := Len( cStr )
      ENDIF

   NEXT

RETURN( nMax )



FUNCTION aReplace( aArray, uReplace, nCol )

   LOCAL nCount

   FOR nCount := 1 TO Len( aArray )
      IF nCol = NIL
         aArray[ nCount ] := uReplace
      ELSE
         aArray[ nCount, nCol ] := uReplace
      ENDIF
   NEXT

RETURN( aArray )



FUNCTION aOneDimensional( aArray, nCol )

   LOCAL aReturn := {}
   
   vDef( @nCol, 1 )
   
   aEval( aArray, { |a| aAdd( aReturn, a[ nCol ] ) } )

RETURN( aClone( aReturn ) )



FUNCTION aMoveTop( aArray )

   LOCAL aAux := aClone( aArray )
   LOCAL nAux := 0

   LOCAL nCount, uVar

   aClear( @aAux )

   FOR nCount := 1 TO Len( aArray )
      uVar := aArray[ nCount ]
      IF ValType( uVar ) = "A"
         uVar := uVar[ 1 ]
      ENDIF
      IF ! Empty( uVar )
         aAux[ ++ nAux ] := aArray[ nCount ]
      ENDIF
   NEXT

   aArray := aAux

RETURN( aAux )



FUNCTION aAddNIL( aArray, nLen )

   LOCAL nPos

   aAdd( aArray, {} )
   nPos := Len( aArray )
   aSize( aArray[ nPos ], nLen )

RETURN( nPos )



PROCEDURE aDelDuplicate( aArray )

   LOCAL aSave := aClone( aArray )

   aArray := {}

   aEval( aSave, { |a| aAddC( aArray, a, aScan( aArray, a ) = 0 ) } )

RETURN( NIL )



FUNCTION strToArray( cStr, cDl, lDelInit )

   LOCAL aReturn := {}
   LOCAL nAux, cAux

   vDef( @cDl     , "|" )
   vDef( @lDelInit, .T. )

   IF lDelInit
      IF Left( cStr, Len( cDl ) ) = cDl
         cStr := Subs( cStr, Len( cDl ) + 1 )
      ENDIF
      IF Right( cStr, Len( cDl ) ) = cDl
         cStr := Left( cStr, Len( cStr ) - Len( cDl ) )
      ENDIF
   ENDIF
   
   DO WHILE .T.
   
      nAux := At( cDl, cStr )
      IF nAux = 0
         aAdd( aReturn, cStr )
         EXIT
      ENDIF

      cAux := Left( cStr, nAux - 1 )

      IF cAux = cDl
         cAux := ""
      ENDIF

      aAdd( aReturn, cAux )
      cStr := Subs( cStr, nAux + Len( cDl ) )

   ENDDO
   
RETURN( aClone( aReturn ) )



FUNCTION aSay( aLines, nCol, uInfo, uFmt, uDefault )

   LOCAL cSay

   IF uInfo = NIL

      IF nCol = 0
         aLines := {}
      ENDIF

      aAdd( aLines, "" )

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

      aLines[ Len( aLines ) ] := PadR( aLines[ Len( aLines ) ], nCol -1 ) + cSay

   ENDIF

RETURN( NIL )



FUNCTION aSeqToChr( aTab, nCol )

   LOCAL nCount

   FOR nCount := 1 TO Len( aTab )
      IF nCol = NIL
         aTab[ nCount ] := SeqToChr( nCount ) + aTab[ nCount ]
      ELSE
         aTab[ nCount, nCol ] := SeqToChr( nCount ) + aTab[ nCount, nCol ]
      ENDIF
   NEXT

RETURN( aClone( aTab ) )