/*

 MaxDig.prg
 Descricao: Biblioteca de funcoes de calculo de digitos.
 Desenvolvido por MAX SCALLA Informatica Ltda.

 EMERSON DA SILVA CREMA
 21/12/18 * Removida funcao CB_Digito() pois foi desenvolvido
            MAXVALID.PRG->GTIN_CalcularDV().
 11/12/17 * Implementado o parametro cRet10 em Mod11().
 27/07/16 * Desenvolvido CB_Digito().
 15/09/09 * Implementada nova consistencia p/ Tocantins (TO) em Conf_IE().
 01/09/09 * Reformulada a mensagem em Conf_IE().
 19/08/09 * Correcao do digito verificador em Conf_IE() p/ DF.

 DENIS MAZZUCATTO RODRIGUES
 02/06/09 * Implementacao de Mod11() em Conf_IE() p/ PR e TO.
 22/05/09 * Corrigida validacao da IE do MT e SP (apenas qdo iniciada com "P")
            em Conf_IE().
 21/05/09 * Corrigido calculo da IE do AC em Conf_IE().

 EMERSON DA SILVA CREMA
 11/05/09 * Implementado em Clear_CPF() o parametro lTrimLeft.
 23/07/07 * Implementado parametro cDig0 em Mod11().
 29/09/05 * Implementado parametro lMsg em CGCPF().
 12/08/05 * Implementado parametro nTip em CGCPF().

*/

#include "std.ch"

FUNCTION CGCPF( cCGCPF, nTip, lMsg )

   // Efetua a validacao do CNPJ p/ pessoas Juridicas e do CPF p/ Fisicas

   LOCAL lReturn := .F.
   LOCAL CGCPF   := AllTrim( Clear_CPF( cCGCPF ) )
   LOCAL nCount

   PRIV D, D2, DF4, DF5, DF6, VLREST, PRIDIG, SEGDIG

   vDef( @nTip, 0 )
   vDef( @lMsg, .F. )

   BEGIN SEQUENCE
   
      IF IsValue( "CFICPACTR", 1589 )  // Pais = Chile.
         lReturn := .T.
         BREAK 
      ENDIF

      IF nTip = 2 .AND. Len( CGCPF ) > 11
         BREAK
      ELSEIF nTip = 1 .AND. Len( CGCPF ) < 14
         BREAK
      ENDIF

      IF Empty( CGCPF )
         lReturn := .T.
         BREAK
      ELSEIF Len( CGCPF ) > 11
         IF Empty( Left( cCGCPF, 3 ) )
            lReturn := .T.
         ELSEIF Len( AllTrim( CGCPF ) ) <> 14
            BREAK
         ELSEIF Subs( CGCPF, 13, 1 ) <> Mod11( Left( CGCPF, 12 ) )
            BREAK
         ENDIF
         lReturn := Right( CGCPF, 1 ) = Mod11( Left( CGCPF, 13 ) )
         BREAK
      ELSEIF Len( CGCPF ) < 11
         BREAK
      ENDIF

      FOR nCount := 1 TO 9
         D    := "0" + Str( nCount, 1 )
         D2&D := Val( Subs( CGCPF, nCount, 1 ) )
      NEXT

      DF4 := 10*D201+9*D202+8*D203+7*D204+6*D205+5*D206+4*D207+3*D208+2*D209
      DF5 := DF4/11
      DF6 := Int( DF5 ) * 11

      VLREST := DF4-DF6
      PRIDIG := If( VLREST = 0 .OR. VLREST = 1, 0, 11 - VLREST )

      FOR nCount := 1 TO 9
         D    := "0" + Str( nCount, 1 )
         D2&D := Val( Subs( CGCPF, nCount, 1 ) )
      NEXT

      DF4 := 11*D201+10*D202+9*D203+8*D204+7*D205+6*D206+5*D207+4*D208+3*D209+2*PRIDIG
      DF5 := DF4/11
      DF6 := INT(DF5)*11

      VLREST := DF4-DF6
      PRIDIG := Str( PRIDIG, 1 )
      SEGDIG := Str( If( VLREST = 0 .OR. VLREST = 1, 0, 11 - VLREST ), 1 )

      lReturn := ( PRIDIG = Subs( CGCPF, 10, 1 ) .AND. SEGDIG = Subs( CGCPF, 11, 1 ) )

   ENDSEQUENCE

   IF ! lReturn .AND. lMsg
      MsgDlg( "O CNPJ/CPF informado n„o ‚ v lido !" )
   ENDIF

RETURN( lReturn )



FUNCTION Clear_CPF( cCpf, nLen, lTrimLeft )

   LOCAL cReturn := ""
   LOCAL nAux

   vDef( @nLen     , 19  )
   vDef( @lTrimLeft, .F. )

   FOR nAux := 1 TO Len( cCpf )

      IF IsDigit( Subs( cCpf, nAux, 1 ) )
         cReturn += Subs( cCpf, nAux, 1 )
      ENDIF

   NEXT

   cReturn := AllTrim( cReturn )

   IF nLen > 0
      IF lTrimLeft
         cReturn := PadR( cReturn, nLen )
      ELSE
         cReturn := PadL( cReturn, nLen )
      ENDIF
   ENDIF

RETURN( cReturn )



FUNCTION Mod11( cNumero, cRet1, cRet0, cBase, cRet10 )

   LOCAL cDig, nSoma, nCount, cMult, nResto

   vDef( @cBase, "98765432" )

   cNumero := AllTrim( cNumero )
   cMult   := Repl( cBase, 10 )

   FOR nCount := 1 TO Len( cNumero )
      IF ! Subs( cNumero, nCount, 1 ) $ "0123456789"
         RETURN( " " )
      ENDIF
   NEXT

   cMult := Right( cMult, Len( cNumero ) )
   nSoma := 0

   FOR nCount := 1 TO Len( cNumero )
       nSoma += Val( Subs( cNumero, nCount, 1 ) ) * Val( Subs( cMult, nCount, 1 ) )
   NEXT

   nResto := Mod( nSoma, 11 )

   IF nResto = 0
      cDig := If( cRet0 = NIL, "0", cRet0 )
   ELSEIF cRet1 <> NIL .AND. nResto = 1
      cDig := cRet1
   ELSE
      cDig := If( nResto = 10 .AND. cRet10 <> NIL, cRet10, Right( Str( 11 - nResto, 2 ), 1 ) )
   ENDIF

RETURN( cDig )



FUNCTION Mod10( cValor )

   LOCAL nTotal := 0
   LOCAL nValor := 0
   LOCAL nFator := 2

   LOCAL nDv, nCount, nX

   FOR nCount := Len( cValor ) TO 1 step - 1
      nValor := Val( Subs( cValor, nCount, 1 ) ) * nFator
      IF nValor > 9
         nValor := AllTrim( Str( nValor ) )
         FOR nX := 1 TO Len( nValor )
            nTotal += Val( Subs( nValor, nX, 1 ) )
         NEXT
      ELSE
         nTotal += nValor
      ENDIF
      nFator := If( nFator = 2, 1, 2 )
   NEXT

   nDv := nTotal % 10
   nDv := If( nDv = 0, 0, 10 - nDv )

RETURN( Str( nDv, 1 ) )


/*----------------------------------------------------------------------------
 Validacao de Inscricao Estadual

 Parametros

 cEstado  : Unidade federal ( Alfanumerico, tamanho = 2 )
 cInscEst : Inscricao Estadual ( Alfanumerico, tamanho = variavel )
 lMsg     : Se .T., exibe mensagem de alerta qdo a inscricao estiver errada.
 cInscOk  : Retorna a Inscricao Estadual correta
 cMasc    : Retorna a mascara da Inscricao Estadual
----------------------------------------------------------------------------*/

FUNCTION Conf_IE( cEstado, cInscEst, lMsg, cInscOk, cMasc )

   LOCAL lOk     := .F.
   LOCAL cBase   := ""
   LOCAL cBase2  := ""
   LOCAL cOrigem := ""

   LOCAL nCount, nCalc, nSoma, nResto, uDigito1, uDigito2
   LOCAL nProduto, nPeso, nDigito, nBase, aMult, cMsg

   IF ESC
      RETURN( .F. )
   ENDIF

   IF Empty( cInscEst ) .OR. Upper( AllTrim( cInscEst ) ) = "ISENTO"
      RETURN( .T. )
   ENDIF

   vDef( @lMsg, .T. )

   FOR nCount := 1 TO Len( AllTrim( cInscEst ) )
       IF Subs( cInscEst, nCount, 1 ) $ "0123456789P"
          cOrigem += Subs( cInscEst, nCount, 1 )
       ENDIF
   NEXT

   cMasc := "99999999999999"

   DO CASE
      CASE cEstado = "AC"

           cMasc := "99,999,999/999-99"
           cBase := PadR( cOrigem, 11, "0" )

           IF Left( cBase, 2 ) = "01"

              uDigito1 := Mod11( cBase )
              cBase += uDigito1
              uDigito2 := Mod11( cBase )
              cBase2 := cBase + uDigito2

              lOk := ( cBase2 = cOrigem )

           ENDIF

      CASE cEstado = "AL"

           cMasc := "999999999"
           cBase := PadR( cOrigem, 9, "0" )

           IF Left( cBase, 2 ) = "24"

              nSoma := 0
              FOR nCount := 1 TO 8
                 nCalc := Val( Subs( cBase, nCount, 1 ) )
                 nCalc := nCalc * ( 10 - nCount )
                 nSoma += nCalc
              NEXT

              nProduto := nSoma * 10
              nResto   := nProduto % 11
              uDigito1 := If( nResto = 10, "0", Str( nResto, 1, 0 ) )
              cBase2   := Left( cBase, 8 ) + uDigito1
              lOk      := ( cBase2 = cOrigem )

           ENDIF

      CASE cEstado = "AM"

           cMasc := "99,999,999-9"
           cBase := PadR( cOrigem, 9, "0" )

           nSoma := 0
           FOR nCount := 1 TO 8
              nCalc := Val( Subs( cBase, nCount, 1 ) )
              nCalc := nCalc * ( 10 - nCount )
              nSoma += nCalc
           NEXT

           IF nSoma < 11
              uDigito1 := Str( 11 - nSoma, 1, 0 )
           ELSE
              nResto   := nSoma % 11
              uDigito1 := If( nResto < 2, "0", Str( 11 - nResto, 1, 0 ) )
           ENDIF

           cBase2 := Left( cBase, 8 ) + uDigito1
           lOk    := ( cBase2 = cOrigem )

      CASE cEstado = "AP"

           cMasc := "999999999"
           cBase := PadR( cOrigem, 9, "0" )

           IF Left( cBase, 2 ) = "03"

              nBase := Val( Left( cBase, 8 ) )

              IF nBase >= 3000001 .AND. nBase <= 3017000
                 nPeso   := 5
                 nDigito := 0
              ELSEIF nBase >= 3017001 .AND. nBase <= 3019022
                 nPeso   := 9
                 nDigito := 1
              ELSEIF nBase >= 3019023
                 nPeso   := 0
                 nDigito := 0
              ENDIF

              nSoma := nPeso
              FOR nCount := 1 TO 8
                 nCalc := Val( Subs( cBase, nCount, 1 ) )
                 nCalc := nCalc * ( 10 - nCount )
                 nSoma += nCalc
              NEXT

              nResto   := nSoma % 11
              uDigito1 := 11 - nResto

              IF uDigito1 = 10
                 uDigito1 := 0
              ELSEIF uDigito1 = 11
                 uDigito1 := nDigito
              ENDIF

              uDigito1 := Str( uDigito1, 1, 0 )

              cBase2 := Left( cBase, 8 ) + uDigito1
              lOk    := ( cBase2 = cOrigem )
           ENDIF

      CASE cEstado = "BA"

           cMasc := "999999-99"
           cBase :=PadR( cOrigem, 8, "0" )

           IF Left( cBase, 1 ) $ "0123458"

              nSoma := 0
              FOR nCount := 1 TO 6
                 nCalc := Val( Subs( cBase, nCount, 1 ) )
                 nCalc := nCalc * ( 8 - nCount )
                 nSoma += nCalc
              NEXT

              nResto   := nSoma % 10
              uDigito2 := Str( If( nResto = 0, 0, 10 - nResto ), 1, 0 )
              cBase2   := Left( cBase, 6 ) + uDigito2

              nSoma := 0
              FOR nCount := 1 TO 7
                 nCalc := Val( Subs( cBase2, nCount, 1 ) )
                 nCalc := nCalc * ( 9 - nCount )
                 nSoma += nCalc
              NEXT

              nResto   := nSoma % 10
              uDigito1 := Str( If( nResto = 0, 0, 10 - nResto ), 1, 0 )

           ELSE

              nSoma := 0
              FOR nCount := 1 TO 6
                 nCalc := Val( Subs( cBase, nCount, 1 ) )
                 nCalc := nCalc * ( 8 - nCount )
                 nSoma += nCalc
              NEXT

              nResto   := nSoma % 11
              uDigito2 := Str( If( nResto < 2, 0, 11 - nResto ), 1, 0 )
              cBase2   := Left( cBase, 6 ) + uDigito2

              nSoma := 0
              FOR nCount := 1 TO 7
                 nCalc := Val( Subs( cBase2, nCount, 1 ) )
                 nCalc := nCalc * ( 9 - nCount )
                 nSoma += nCalc
              NEXT

              nResto   := nSoma % 11
              uDigito1 := Str( If( nResto < 2, 0, 11 - nResto ), 1, 0 )

           ENDIF

           cBase2 := Left( cBase, 6 ) + uDigito1 + uDigito2
           lOk    := ( cBase2 = cOrigem )

      CASE cEstado = "CE"

           cMasc := "99999999-9"
           cBase := PadR( cOrigem, 9, "0" )

           nSoma := 0
           FOR nCount := 1 TO 8
              nCalc := Val( Subs( cBase, nCount, 1 ) )
              nCalc := nCalc * ( 10 - nCount )
              nSoma += nCalc
           NEXT

           nResto   := nSoma % 11
           uDigito1 := 11 - nResto

           IF uDigito1 > 9
              uDigito1 := 0
           ENDIF

           cBase2 := Left( cBase, 8 ) + Str( uDigito1, 1, 0 )
           lOk    := ( cBase2 = cOrigem )

      CASE cEstado = "DF"

           cMasc   := "99.999999.999-99"
           cOrigem := PadL( cOrigem, 13, "0" )
           cBase2  := Left( cOrigem, 11 )

           aMult := { 5,4,3,2,9,8,7,6,5,4,3,2 }

           FOR nProduto := 1 TO 2

              nSoma := 0
              nPeso := Len( aMult )

              FOR nCount := Len( cBase2 ) TO 1 STEP -1
                 nCalc := Val( Subs( cBase2, nCount, 1 ) )
                 nCalc *= aMult[ nPeso ]
                 nSoma += nCalc
                 nPeso --
              NEXT

              nResto := nSoma % 11
              nResto := 11 - nResto

              IF nResto > 9
                 nResto := 0
              ENDIF

              cBase2 += Str( nResto, 1 )

           NEXT

           lOk := ( cBase2 = cOrigem )

      CASE cEstado = "ES"

           cMasc := "999999999"
           cBase := PadR( cOrigem, 9, "0" )

           nSoma := 0
           FOR nCount := 1 TO 8
              nCalc := Val( Subs( cBase, nCount, 1 ) )
              nCalc := nCalc * ( 10 - nCount )
              nSoma += nCalc
           NEXT

           nResto   := nSoma % 11
           uDigito1 := Str( If( nResto < 2, 0, 11 - nResto ), 1, 0 )
           cBase2   := Left( cBase, 8 ) + uDigito1
           lOk      := ( cBase2 = cOrigem )

      CASE cEstado = "GO"

           cMasc := "99,999,999-9"
           cBase := PadR( cOrigem, 9, "0" )

           IF Left( cBase, 2 ) $ "10,11,15"

              nSoma := 0
              FOR nCount := 1 TO 8
                 nCalc := Val( Subs( cBase, nCount, 1 ) )
                 nCalc := nCalc * ( 10 - nCount )
                 nSoma += nCalc
              NEXT

              nResto := nSoma % 11

              IF nResto = 0
                 uDigito1 := "0"
              ELSEIF nResto = 1
                 nBase    := Val( Left( cBase, 8 ) )
                 uDigito1 := If( nBase >= 10103105 .AND. nBase <= 10119997, "1", "0" )
              ELSE
                 uDigito1 := Str( 11 - nResto, 1, 0 )
              ENDIF

              cBase2 := Left( cBase, 8 ) + uDigito1
              lOk    := ( cBase2 = cOrigem )

           ENDIF

      CASE cEstado = "MA"

           cMasc := "999999999"
           cBase := PadR( cOrigem, 9, "0" )

           IF Left( cBase, 2 ) = "12"

              nSoma := 0
              FOR nCount := 1 TO 8
                 nCalc := Val( Subs( cBase, nCount, 1 ) )
                 nCalc := nCalc * ( 10 - nCount )
                 nSoma += nCalc
              NEXT

              nResto   := nSoma % 11
              uDigito1 := Str( If( nResto < 2, 0, 11 - nResto ), 1, 0 )
              cBase2   := Left( cBase, 8 ) + uDigito1
              lOk      := ( cBase2 = cOrigem )

           ENDIF

      CASE cEstado = "MT"

           cMasc := "9999999999-9"
           cBase := PadR( cOrigem, 10, "0" )
           aMult := { 3,2,9,8,7,6,5,4,3,2 }

           nSoma := 0
           FOR nCount := 1 TO 10
              nCalc := Val( Subs( cBase, nCount, 1 ) )
              nCalc := nCalc * aMult[ nCount ]
              nSoma += nCalc
           NEXT

           nResto   := nSoma % 11
           uDigito1 := If( nResto < 2, 0, 11 - nResto )
           cBase2   := Left( cBase, 10 ) + Str( uDigito1, 1, 0 )
           lOk      := ( cBase2 = cOrigem )

      CASE cEstado = "MS"

           cMasc := "999999999"
           cBase := PadR( cOrigem, 9, "0" )

           IF Left( cBase, 2 ) = "28"

              nSoma := 0
              FOR nCount := 1 TO 8
                 nCalc := Val( Subs( cBase, nCount, 1 ) )
                 nCalc := nCalc * ( 10 - nCount )
                 nSoma += nCalc
              NEXT

              nResto   := nSoma % 11
              uDigito1 := Str( If( nResto < 2, 0, 11 - nResto ), 1, 0 )
              cBase2   := Left( cBase, 8 ) + uDigito1
              lOk      := ( cBase2 = cOrigem )

           ENDIF

      CASE cEstado = "MG"

           cMasc  := "999,999,999/9999"
           cBase  := PadR( cOrigem, 13, "0" )
           cBase2 := Left( cBase, 3 ) + "0" + Subs( cBase, 4, 8 )
           nBase  := 2

           nSoma  := ""
           FOR nCount := 1 TO 12
              nCalc := Val( Subs( cBase2, nCount, 1 ) )
              nBase := If( nBase = 2, 1, 2 )
              nCalc := AllTrim( Str( nCalc * nBase, 2, 0 ) )
              nSoma += nCalc
           NEXT

           nBase := 0
           FOR nCount := 1 TO Len( nSoma )
              nBase += Val( Subs( nSoma, nCount, 1 ) )
           NEXT

           nSoma := nBase
           DO WHILE Right( Str( nBase, 3, 0 ), 1 ) <> "0"
              nBase ++
           ENDDO

           uDigito1 := Str( nBase - nSoma, 1, 0 )
           cBase2   := Left( cBase, 11 ) + uDigito1
           aMult    := { 3,2,11,10,9,8,7,6,5,4,3,2 }

           nSoma := 0
           FOR nCount := 1 TO 12
              nCalc := Val( Subs( cBase2, nCount, 1 ) )
              nCalc := nCalc * aMult[ nCount ]
              nSoma += nCalc
           NEXT

           nResto   := nSoma % 11
           uDigito2 := If( nResto < 2, 0, 11 - nResto )
           cBase2   += Str( uDigito2, 1, 0 )
           lOk      := ( cBase2 = cOrigem )

      CASE cEstado = "PA"

           cMasc := "99-999999-9"
           cBase := PadR( cOrigem, 9, "0" )

           IF Left( cBase, 2 ) = "15"

              nSoma := 0
              FOR nCount := 1 TO 8
                 nCalc := Val( Subs( cBase, nCount, 1 ) )
                 nCalc := nCalc * (10 - nCount )
                 nSoma += nCalc
              NEXT

              nResto   := nSoma % 11
              uDigito1 := Str( If( nResto < 2, 0, 11 - nResto ), 1, 0 )
              cBase2   := Left( cBase, 8 ) + uDigito1
              lOk      := ( cBase2 = cOrigem )

           ENDIF

      CASE cEstado = "PB"

           cMasc := "99,999,999-9"
           cBase := PadR( cOrigem, 9, "0" )

           nSoma := 0
           FOR nCount := 1 TO 8
              nCalc := Val( Subs( cBase, nCount, 1 ) )
              nCalc := nCalc * ( 10 - nCount )
              nSoma += nCalc
           NEXT

           nResto   := nSoma % 11
           uDigito1 := 11 - nResto

           IF uDigito1 > 9
              uDigito1 := 0
           ENDIF
           cBase2 := Left( cBase, 8 ) + Str( uDigito1, 1, 0 )
           lOk    := ( cBase2 = cOrigem )

      CASE cEstado = "PE"

           cMasc := "99,9,999,9999999-9"
           cBase := PadR( cOrigem, 14, "0" )
           aMult := { 5,4,3,2,1,9,8,7,6,5,4,3,2 }

           nSoma := 0
           FOR nCount := 1 TO 13
              nCalc := Val( Subs( cBase, nCount, 1 ) )
              nCalc := nCalc * aMult[ nCount ]
              nSoma += nCalc
           NEXT

           nResto   := nSoma % 11
           uDigito1 := 11 - nResto

           IF uDigito1 > 9
              uDigito1 -= 10
           ENDIF

           cBase2 := Left( cBase, 13 ) + Str( uDigito1, 1, 0 )
           lOk    := ( cBase2 = cOrigem )

      CASE cEstado = "PI"

           cMasc := "999999999"
           cBase := PadR( cOrigem, 9, "0" )

           nSoma := 0
           FOR nCount := 1 TO 8
              nCalc := Val( Subs( cBase, nCount, 1 ) )
              nCalc := nCalc *( 10 - nCount )
              nSoma += nCalc
           NEXT

           nResto   := nSoma % 11
           uDigito1 := Str( If( nResto < 2, 0, 11 - nResto ), 1, 0 )
           cBase2   := Left( cBase, 8 ) + uDigito1
           lOk      := ( cBase2 = cOrigem )

      CASE cEstado = "PR"

           cMasc := "999,99999-99"
           cBase := PadR( cOrigem, 8, "0" )

           uDigito1 := Mod11( cBase, NIL, NIL, "32765432" )
           cBase += uDigito1
           uDigito2 := Mod11( cBase, NIL, NIL, "432765432" )
           cBase2 := cBase + uDigito2

           lOk := ( cBase2 = cOrigem )

      CASE cEstado = "RJ"

           cMasc := "99,999,99-9"
           cBase := PadR( cOrigem, 8, "0" )
           aMult := { 2,7,6,5,4,3,2 }

           nSoma := 0
           FOR nCount := 1 TO 7
              nCalc := Val( Subs( cBase, nCount, 1 ) )
              nCalc := nCalc * aMult[ nCount ]
              nSoma += nCalc
           NEXT

           nResto   := nSoma % 11
           uDigito1 := Str( If( nResto < 2, 0, 11 - nResto ), 1, 0 )
           cBase2   := Left( cBase, 7 ) + uDigito1
           lOk      := ( cBase2 = cOrigem )

      CASE cEstado = "RN"

           cMasc := "99,999,999-9"
           cBase := PadR( cOrigem, 9, "0" )

           IF Left( cBase, 2 ) = "20"

              nSoma := 0
              FOR nCount := 1 TO 8
                 nCalc := Val( Subs( cBase, nCount, 1 ) )
                 nCalc := nCalc *( 10 - nCount )
                 nSoma += nCalc
              NEXT

              nProduto := nSoma * 10
              nResto   := nProduto % 11
              uDigito1 := Str( If( nResto > 9, 0, nResto ), 1, 0 )
              cBase2   := Left( cBase, 8 ) + uDigito1
              lOk      := ( cBase2 = cOrigem )

           ENDIF

      CASE cEstado = "RO"

           cMasc  := "999999999"
           cBase  := PadR( cOrigem, 9, "0" )
           cBase2 := Subs( cBase, 4, 5 )

           nSoma := 0
           FOR nCount := 1 TO 5
              nCalc := Val( Subs( cBase2, nCount, 1 ) )
              nCalc := nCalc * ( 7 - nCount )
              nSoma += nCalc
           NEXT

           nResto   := nSoma % 11
           uDigito1 := 11 - nResto

           IF uDigito1 > 9
              uDigito1 -= 10
           ENDIF

           cBase2 := Left( cBase, 8 ) + Str( uDigito1, 1, 0 )
           lOk    := ( cBase2 = cOrigem )

      CASE cEstado = "RR"

           cMasc := "99999999-9"
           cBase := PadR( cOrigem, 9, "0" )

           IF Left( cBase, 2 ) = "24"

              nSoma := 0
              FOR nCount := 1 TO 8
                 nCalc := Val( Subs( cBase, nCount, 1 ) )
                 nCalc := nCalc * nCount
                 nSoma += nCalc
              NEXT

              nResto   := nSoma % 9
              uDigito1 := Str( nResto, 1, 0 )
              cBase2   := Left( cBase, 8 ) + uDigito1
              lOk      := ( cBase2 = cOrigem )

           ENDIF

      CASE cEstado = "RS"

           cMasc := "999/999999-9"
           cBase := PadR( cOrigem, 10, "0" )
           nBase := Val( Left( cBase, 3 ) )

           IF nBase > 0 .AND. nBase < 468

              aMult := { 2,9,8,7,6,5,4,3,2 }

              nSoma := 0
              FOR nCount := 1 TO 9
                 nCalc := Val( Subs( cBase, nCount, 1 ) )
                 nCalc := nCalc * aMult[ nCount ]
                 nSoma += nCalc
              NEXT

              nResto   := nSoma % 11
              uDigito1 := 11 - nResto

              IF uDigito1 > 9
                 uDigito1 := 0
              ENDIF

              cBase2 := Left( cBase, 9 ) + Str( uDigito1, 1, 0 )
              lOk    := ( cBase2 = cOrigem )

           ENDIF

      CASE cEstado = "SC"

           cMasc := "999,999,999"
           cBase := PadR( cOrigem, 9, "0" )

           nSoma := 0
           FOR nCount := 1 TO 8
              nCalc := Val( Subs( cBase, nCount, 1 ) )
              nCalc := nCalc * ( 10 - nCount )
              nSoma += nCalc
           NEXT

           nResto   := nSoma % 11
           uDigito1 := If( nResto < 2, "0", Str( 11 - nResto, 1, 0 ) )
           cBase2   := Left( cBase, 8 ) + uDigito1
           lOk      := ( cBase2 = cOrigem )

      CASE cEstado = "SE"

           cMasc := "99999999-9"
           cBase := PadR( cOrigem, 9, "0" )

           nSoma := 0
           FOR nCount := 1 TO 8
              nCalc := Val( Subs( cBase, nCount, 1 ) )
              nCalc := nCalc * ( 10 - nCount )
              nSoma += nCalc
           NEXT

           nResto   := nSoma % 11
           uDigito1 := 11 - nResto

           IF uDigito1 > 9
              uDigito1 := 0
           ENDIF

           cBase2 := Left( cBase, 8 ) + Str( uDigito1, 1, 0 )
           lOk    := ( cBase2 = cOrigem )

      CASE cEstado = "SP"

           IF Left( cOrigem, 1 ) = "P"

              cMasc  := "P-99999999,9/999"
              cBase  := PadR( cOrigem, 13, "0" )
              cBase2 := Subs( cBase, 2, 8 )
              aMult  := { 1,3,4,5,6,7,8,10 }

              nSoma := 0
              FOR nCount := 1 TO 8
                 nCalc := Val( Subs( cBase2, nCount, 1 ) )
                 nCalc := nCalc * aMult[ nCount ]
                 nSoma += nCalc
              NEXT

              nResto   := nSoma % 11
              uDigito1 := Right( Str( nResto, 2, 0 ), 1 )
              cBase2   := Left( cBase, 9 ) + uDigito1 + Subs( cBase, 11, 3 )

           ELSE

              cMasc := "999,999,999,999"
              cBase := PadR( cOrigem, 12, "0" )
              aMult := { 1,3,4,5,6,7,8,10 }

              nSoma := 0
              FOR nCount := 1 TO 8
                 nCalc := Val( Subs( cBase, nCount, 1 ) )
                 nCalc := nCalc * aMult[ nCount ]
                 nSoma += nCalc
              NEXT

              nResto   := nSoma % 11
              uDigito1 := Right( Str( nResto, 2, 0 ), 1 )
              cBase2   := Left( cBase, 8 ) + uDigito1 + Subs( cBase, 10, 2 )
              aMult    := { 3,2,10,9,8,7,6,5,4,3,2 }

              nSoma := 0
              FOR nCount := 1 TO 11
                 nCalc := Val( Subs( cBase2, nCount, 1 ) )
                 nCalc := nCalc * aMult[ nCount ]
                 nSoma += nCalc
              NEXT

              nResto   := nSoma % 11
              uDigito2 := Right( Str( nResto, 2, 0 ), 1 )
              cBase2   += uDigito2

           ENDIF
           lOk := ( cBase2 = cOrigem )

      CASE cEstado = "TO"

           cMasc := "99,99,999999-9"

           IF Len( cOrigem ) <= 9

              cBase := Left( PadL( cOrigem, 9, "0" ), 8 )
              cBase += Mod11( cBase )

              lOk := ( cBase = cOrigem )

           ELSE

              cBase := PadL( cOrigem, 11, "0" )

              IF foundStr( Subs( cBase, 3, 2 ), "01|02|03|99" )

                 cBase2 := Left( cBase, 2 ) + Subs( cBase, 5, 6 )
                 cBase2 := Left( cBase, 10 ) + Mod11( cBase2 )

                 lOk := ( cBase2 = cOrigem )

              ENDIF

           ENDIF

      OTHERWISE

           IF lMsg
              MsgDlg( "Unidade federativa;inv lida !" )
           ENDIF

   ENDCASE

   IF ! lOk

      IF lMsg

         cMsg := "Inscri‡„o estadual inv lida !;;"

         IF Empty( cBase2 )
            cMsg   += "Os d¡gitos identificadores de;cidade e/ou estado n„o conferem."
         ELSE
            cBase2 := StrTran( Tran( cBase2, "@R " + cMasc ), " ", "0" )
            cBase2 := StrTran( cBase2, ",", "." )
            cMsg   += "O correto seria : " + cBase2
         ENDIF

         MsgDlg( cMsg )

      ELSE

         cInscOk := ""

         IF ! Empty( cBase2 )
            cInscOk := StrTran( Tran( cBase2, "@R " + cMasc ), " ", "0" )
            cInscOk := StrTran( cInscOk, ",", "." )
         ENDIF

      ENDIF

   ENDIF

RETURN( lOk )