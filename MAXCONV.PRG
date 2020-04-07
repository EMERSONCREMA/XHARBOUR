/*

 MaxConv.prg
 Descricao: Biblioteca de funcoes de conversao de valores.
 Desenvolvido por MAX SCALLA Informatica Ltda.
 
 EMERSON DA SILVA CREMA
 08/04/19 * Desenvolvido CtoN( cVal ).
 07/12/15 * Desenvolvido UtoN().

 DENIS MAZZUCATTO RODRIGUES
 08/08/12 * Verificado tipo de dado do parametro em NumToStr().

 EMERSON DA SILVA CREMA
 03/09/08 * Implementada utilizacao do parametro nMax em CtoA(), pois antes so
            existia o parametro.
 07/08/06 * Remocao de Codfic(), dCodfic() e Fill_out().
 23/06/06 * Desenvolvimento de ZLClear().
 16/03/06 * Desenvolvimento de DigOnly().
 18/01/06 * Desenvolvimento de Positiva().
 08/11/05 * Desenvolvimento de DefDec().
 05/08/05 * Implementacao de InverseString() em Inverse_String() apenas p/
            compatibilidade.

 DENIS MAZZUCATTO RODRIGUES
 12/05/05 * Desenvolvimento de ClearVar().

 EMERSON DA SILVA CREMA
 08/12/04 * Desenvolvimento de DecToHex().
 01/10/04 * Desenvolvimento de ValStr().
 26/08/04 * Desenvolvimento de SeqToChr().

*/

#include "std.ch"

PROCEDURE SwitchVal( uVal1, uVal2 )

   LOCAL uAux

   IF uVal1 <> uVal2
      uAux  := uVal1
      uVal1 := uVal2
      uVal2 := uAux
   ENDIF

RETURN( NIL )



FUNCTION Negativa( nVal )

  IF nVal > 0
     nVal *= -1
  ENDIF

RETURN( ValStr( nVal ) )



FUNCTION Positiva( nVal )

  IF nVal < 0
     nVal *= -1
  ENDIF

RETURN( ValStr( nVal ) )



FUNCTION NumToStr( nNum, cMask )

   LOCAL cNum

   IF ValType( nNum ) = "C"
      cNum := nNum
   ELSEIF cMask = NIL
      cNum := Str( nNum )
   ELSE
      cNum := Tran( nNum, cMask )
   ENDIF

   cNum := LTrim( cNum )

RETURN( cNum )



FUNCTION UtoC( uVar )

   LOCAL cVar := ""

   DO CASE
      CASE ValType( uVar ) = "C" ; cVar := uVar
      CASE ValType( uVar ) = "D" ; cVar := DtoC( uVar )
      CASE ValType( uVar ) = "N" ; cVar := NumToStr( uVar )
      CASE ValType( uVar ) = "L" ; cVar := If( uVar, ".T.", ".F." )
   ENDCASE

RETURN( cVar )



FUNCTION UtoN( uVar )

   LOCAL nVar := 0

   DO CASE
      CASE ValType( uVar ) = "C" ; nVar := Val( uVar )
      CASE ValType( uVar ) = "D" ; nVar := Val( DtoS( uVar ) )
      CASE ValType( uVar ) = "N" ; nVar := uVar
      CASE ValType( uVar ) = "L" ; nVar := If( uVar, 1, 0 )
   ENDCASE

RETURN( nVar )


/*

  CtoN(): Converte um valor caracter para numerico,
          formatando o conteudo inicial.

*/

FUNCTION CtoN( cVal )

   RETURN( Val( StrTran( AllTrim( cVal ), ",", "." ) ) )



FUNCTION ClearVar( uVar )

   LOCAL uReturn := uVar

   DO CASE
      CASE ValType( uVar ) = "C" ; uReturn := Space( Len( uVar ) )
      CASE ValType( uVar ) = "D" ; uReturn := CtoD( "" )
      CASE ValType( uVar ) = "N" ; uReturn := Val( Str( 0, Len( Str( uVar ) ) ) )
   ENDCASE

RETURN( uReturn )



FUNCTION Base35( cConv, lRestore )

   LOCAL cString := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
   LOCAL cReturn := ""

   LOCAL nCount, nCodigo, nDigit, cCode

   vDef( @lRestore, .F. )

   IF lRestore

      FOR nCount := 1 TO Len( cConv ) STEP 2

         cCode := Subs( cConv, nCount, 2 )

         nCodigo := At( Right( cCode, 1 ), cString ) -1
         nCodigo += ( ( At( Left( cCode, 1 ), cString ) -1 ) * Len( cString ) )

         cReturn += StrZero( nCodigo, 3 )

      NEXT

   ELSE

      FOR nCount := 1 TO Len( cConv ) STEP 3

         nCodigo := Val( Subs( cConv, nCount, 3 ) )

         nDigit := nCodigo % Len( cString ) +1

         nCodigo := Int( nCodigo / Len( cString ) ) +1

         cReturn += Subs( cString, nCodigo, 1 ) + Subs( cString, nDigit, 1 )

      NEXT

   ENDIF

RETURN( cReturn )



FUNCTION DecToHex( nDec )

   LOCAL cHexTable := "0123456789ABCDEF"

   LOCAL nDig1 := Int( nDec / 16 ) +1
   LOCAL nDig2 :=    ( nDec % 16 ) +1

   LOCAL cHex  := Subs( cHexTable, nDig1, 1 ) + Subs( cHexTable, nDig2, 1 )

RETURN( cHex )



FUNCTION TrimPict( nVal, cPict )

   LOCAL cReturn := LTrim( Tran( nVal, "@E " + cPict ) )

RETURN( cReturn )



FUNCTION LTTime( cTime )

   DO WHILE Left( cTime, 2 ) = "00" .AND. Len( cTime ) > 2
      cTime := Subs( cTime, 4 )
   ENDDO

RETURN( cTime )



FUNCTION SeqToChr( nSeq )

   LOCAL cReturn := If( nSeq < 10, NumToStr( nSeq ), Chr( 55 + nSeq ) )

RETURN( cReturn )



FUNCTION ChrToSeq( cChr )

   LOCAL nReturn := If( IsDigit( cChr ), Val( cChr ), Asc( cChr ) - 55 )

RETURN( nReturn )



FUNCTION ValStr( nNum )

   LOCAL nReturn := Val( Str( nNum ) )

RETURN( nReturn )



FUNCTION DefDec( nVal, nDec )

   nVal := Val( LTrim( Str( nVal, 19, nDec ) ) )

RETURN( nVal )



FUNCTION mxCtoA( cVar, cSep, nMax )

   LOCAL aReturn := {}

   vDef( @cSep, ";"  )
   vDef( @nMax, 1024 )

   DO WHILE ! Empty( cVar )

      IF At( cSep, cVar ) = 0
         aAdd( aReturn, cVar )
         EXIT
      ENDIF

      aAdd( aReturn, Left( cVar, At( cSep, cVar ) -1 ) )
      cVar := Subs( cVar, At( cSep, cVar ) +1 )

      IF Len( aReturn ) = nMax
         EXIT
      ENDIF

   ENDDO

RETURN( aReturn )



FUNCTION NoEmpty( cInfo, cMask, cChr )

   LOCAL cReturn := ""

   vDef( @cChr, "" )

   IF ! Empty( cInfo )
      cReturn := cChr + If( cMask = NIL, cInfo, Tran( cInfo, cMask ) )
   ENDIF

RETURN( cReturn )



FUNCTION blockToVal( uBlock )

   IF ValType( uBlock ) = "B"
      uBlock := Eval( uBlock )
   ENDIF

RETURN( uBlock )