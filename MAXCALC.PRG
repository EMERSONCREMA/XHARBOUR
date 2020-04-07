/*

 MaxCalc.prg
 Descricao: Biblioteca de funcoes de calculos matematicos.
 Desenvolvido por MAX SCALLA Informatica Ltda.
 
 EMERSON DA SILVA CREMA
 09/01/19 * Desenvolvido mxCalcLucro().

 DENIS MAZZUCATTO RODRIGUES
 16/01/08 * Retirado os 0 nao significativos da parte decimal em mxDecimal().

 EMERSON DA SILVA CREMA
 04/09/07 * Implementado o parametro nDec em Percent().

 DENIS MAZZUCATTO RODRIGUES
 04/01/07 * Desenvolvimento de defPercent().
 08/11/05 * Desenvolvimento de mxDecimal().
 11/07/05 * Modificacao e correcao em MRound(). Incluso o parametro "S".
 13/12/04 * Correcao em Trunca() q estava arredondando o valor das casas
            decimais.

 EMERSON DA SILVA CREMA
 26/11/03 * Desenvolvimento de mxRest() - retorna o resto de uma divisao.
 01/11/02 * Desenvolvimento de dsvPadrao() - calculo de desvio padrao.

*/

#include "std.ch"

FUNCTION Percent( nVal, nPer, NO_ADD, nDec )

   LOCAL nReturn := If( NO_ADD = NIL, nVal, 0 ) + ( nVal * nPer / 100 )

   IF nDec <> NIL
      nReturn := Round( nReturn, nDec )
   ENDIF

RETURN( nReturn )



FUNCTION defPercent( nVal1, nVal2, nPos )

   LOCAL nReturn

   vDef( @nPos, 1 )

   // Complementativo.
   // Retorna o % p/ q nVal1 fique igual a nVal2.

   IF nPos = 1
      nReturn := ( nVal2 * 100 / nVal1 )
      nReturn -= 100
   ELSE
      nReturn := ( nVal1 / nVal2 )
      nReturn --
      nReturn *= -100
   ENDIF

RETURN( nReturn )



FUNCTION dsvPadrao( aDados )

   LOCAL nMedia := 0
   LOCAL nSoma  := 0
   LOCAL nTotal := 0

   LOCAL nCount, nDsv

   aEval( aDados, { |d| nTotal += d } )

   nMedia := nTotal / Len( aDados )

   FOR nCount := 1 TO Len( aDados )
      nVal  := aDados[ nCount ] - nMedia
      nVal  *= nVal
      nSoma += nVal
   NEXT

   nDsv := Sqrt( nSoma / ( Len( aDados ) -1 ) )

RETURN( nDsv )



FUNCTION Trunca( nValor, nDec )

   LOCAL cValor := LTrim( Tran( nValor, "999999999999999." + Repl( "9", nDec + 10 ) ) )

   LOCAL nReturn := Val( Left( cValor, At( ".", cValor ) ) + Subs( cValor, At( ".", cValor ) +1, nDec ) )

RETURN( nReturn )



FUNCTION MRound( nValor, nDec, cTipo )

   LOCAL nReturn := Round( nValor, nDec )
   LOCAL nCalc

   vDef( @cTipo, "M" )

   cTipo := Upper( cTipo )

   IF cTipo = "M" .AND. ( Right( Str( Trunca( nValor, nDec +1 ) ), 1 ) <> "6" )

      // Arredonda p/ cima apenas se a proxima casa decimal for > 6.
      // Exemplos:
      // MRound( 0.001, 2, "M" ) = 0.00
      // MRound( 0.005, 2, "M" ) = 0.00
      // MRound( 0.006, 2, "M" ) = 0.01
      // MRound( 0.009, 2, "M" ) = 0.01

      nCalc := Val( "0." + Repl( "0", nDec ) + "1" )

      nReturn := Round( nValor - nCalc, nDec )

   ELSEIF cTipo = "S" .AND. ( Right( Str( Trunca( nValor, nDec +1 ) ), 1 ) <> "0" )

      // Arredonda p/ cima sempre q a proxima casa decimal for > 0.
      // Exemplos:
      // MRound( 0.000, 2, "S" ) = 0.00
      // MRound( 0.001, 2, "S" ) = 0.01
      // MRound( 0.006, 2, "S" ) = 0.01
      // MRound( 0.009, 2, "S" ) = 0.01

      nCalc := Val( "0." + Repl( "0", nDec -1 ) + "1" )

      nReturn := Trunca( nValor, nDec ) + nCalc

   ENDIF

RETURN( nReturn )



FUNCTION mxRest( nNum, nDiv )

   LOCAL nCalc := nNum / nDiv
   LOCAL nRest := nNum - ( Int( nCalc ) * nDiv )

RETURN( nRest )



// Retorna a quantidade de casas decimais de determinado numero.

FUNCTION mxDecimal( nNum )

   LOCAL nDec, cDec

   IF ValType( nNum ) = "C"
      nNum := StrTran( nNum, ".", ""  )
      nNum := StrTran( nNum, ",", "." )
      nNum := Val( nNum )
   ENDIF

   nDec := nNum - Int( nNum )

   IF nDec > 0
      cDec := NumToStr( nDec )
      cDec := Subs( cDec, 3 )
      DO WHILE Right( cDec, 1 ) = "0"
         cDec := Left( cDec, Len( cDec ) -1 )
      ENDDO
      nDec := Len( cDec )
   ENDIF

RETURN( nDec )



FUNCTION mxCalcLucro( nPreco, nCusto, cLucro )

   LOCAL nLucro

   IF ValStr( nPreco ) == ValStr( nCusto )
      nLucro := 0
   ELSEIF cLucro = "V"
      //Calculo sobre preco de venda
      nLucro := ( 1 - ( nCusto / nPreco ) ) * 100
   ELSE
      //Calculo sobre preco de custo
      nLucro := ( nPreco - nCusto ) / nCusto * 100
   ENDIF

   nLucro := Round( nLucro, 4 )

RETURN( nLucro )