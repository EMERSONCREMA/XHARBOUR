/*

 MaxGraf.prg
 Descricao: Biblioteca de funcoes de grafico.
 Desenvolvido por MAX SCALLA Informatica Ltda.

*/

#include "std.ch"
#include "inkey.ch"

#define IsLegenda ( aLegenda <> NIL .AND. cTipoLegenda = "L" )


FUNCTION mxGrafico( ;
                    cTitulo     ,;
                    aDados      ,;
                    nDimensao   ,;
                    aLegenda    ,;
                    cTipoLegenda,;
                    bFuncKey    ,;
                    bFuncStatus ,;
                    nRow        ,;
                    lAbort      ,;
                    nWait       ,;
                    aColor      ,;
                    lTotal2      ;
                  )

   LOCAL aState := {}
   LOCAL nTotal := 0
   LOCAL nFator := 1
   LOCAL nElIni := 1
   LOCAL nElAnt := 1
   LOCAL lModif := .T.
   LOCAL cOrdem := "C"
   LOCAL lInit  := ( MaxRow() = 24 )

   LOCAL nEscala, nPercent, nPos, nLeg, nLin, nCol
   LOCAL nAux, cColor, cImpLeg, nColLeg, nMaxRow, nTotal1, nTotal2

   IF Len( aDados ) = 0
      MsgDlg( "NÑo existe dados suficientes para;a exibiáÑo do gr†fico !" )
      RETURN( .F. )
   ENDIF

   vDef( @nRow   , 50  )
   vDef( @nWait  ,  0  )
   vDef( @lAbort , .F. )
   vDef( @lTotal2, .F. )

   SaveState( @aState )

   IF lInit
      grfInit( nRow )
   ENDIF

   SetColor( "15/0,0/7,9/0,,15/1" )

   nMaxRow := MaxRow()

   IF cTitulo <> NIL
      @ 01,00 SAY PadC( "GRAFICO " + Upper( cTitulo ), 80 )
   ENDIF

   DO WHILE .T.

      IF lModif

         nEscala := grfEscala( aDados, nDimensao, @nFator )
         nTotal  := aTotal( aDados, nDimensao )

         IF lTotal2

            nTotal1 := 0
            nTotal2 := 0

            FOR nPos := 1 TO Len( aDados )
                IF Mod( nPos, 2 ) = 0
                   nTotal2 += aDados[ nPos, nDimensao ]
                ELSE
                   nTotal1 += aDados[ nPos, nDimensao ]
                ENDIF
            NEXT

         ENDIF

      ENDIF

      IF lModif .OR. nElIni <> nElAnt

         grfGrade( nEscala, nFator )

         IF Len( aDados ) > 12
            @ 28,00 SAY PadC( "( Utilize " + Chr(27) + " ou " + Chr(26) + " para movimentar o gr†fico )", 80 )

            @ 28,07 SAY If( nElIni > 1                 , "<-", "  " )
            @ 28,76 SAY If( Len( aDados ) > nElIni + 11, "->", "  " )
         ENDIF

         IF IsLegenda
            @ 30,02 SAY "LEGENDA :"
         ENDIF

         nAux := 0

         FOR nPos := 0 TO If( Len( aDados ) > 12, 11, Len( aDados ) - 1 )

             IF aColor = NIL
                cColor := StrZero( nPos + nElIni - ( Int( (nPos + nElIni - 1) / 12 ) * 12 ), 2 ) + "/0"
             ELSE
                IF nAux = Len( aColor )
                   nAux := 0
                ENDIF
                nAux++
                cColor := aColor[ nAux ]
             ENDIF

             IF ! lTotal2
                nPercent := nTotal
             ELSEIF Mod( nPos, 2 ) = 0
                nPercent := nTotal1
             ELSE
                nPercent := nTotal2
             ENDIF

             nPercent := aDados[ nPos + nElIni, nDimensao ] / nPercent * 100

             grfBarra( nPos, aDados[ nPos + nElIni, nDimensao ], nFator, nEscala, cColor, nPercent )

             IF aLegenda <> NIL

                IF cTipoLegenda = "L"

                   IF nPos < 6
                      nLin := 33 + (nPos * If( nMaxRow = 49, 2, 1 ) )
                      nCol := 02
                   ELSE
                      nLin := 33 + (nPos - 6) * If( nMaxRow = 49, 2, 1 )
                      nCol := 41
                   ENDIF

                   @ nLin, nCol     SAY "€€"      COLOR cColor
                   @ nLin, nCol + 3 SAY Space(35) COLOR "15/0"

                   nColLeg := 0

                   FOR nLeg := 1 TO Len( aLegenda[ 1 ] )

                       cImpLeg := Tran( aDados[ nPos + nElIni, aLegenda[ 1, nLeg ] ], aLegenda[ 2, nLeg ] )

                       @ nLin, nCol + 3 + nColLeg SAY cImpLeg COLOR "15/0"

                       nColLeg += Len( cImpLeg ) + 1

                   NEXT

                ELSE

                   cImpLeg := Tran( aDados[ nPos + nElIni, aLegenda[ 1, 1 ] ], aLegenda[ 2, 1 ] )

                   @ 27, 07 + (nPos * 6) SAY PadR( cImpLeg, 5 ) COLOR "14/0"

                ENDIF

             ENDIF

         NEXT

      ENDIF

      IF lModif .AND. bFuncStatus <> NIL
         Eval( bFuncStatus, nDimensao, nTotal )
      ENDIF

      IF lAbort
         EXIT
      ENDIF

      ClearKeybBuffer()

      mxInkey( nWait )

      nElAnt := nElIni
      lModif := .F.

      IF ESC
         IF MsgDlg( "Deseja realmente abandonar;este gr†fico ?", { "NÑo", "Sim" } ) = 2
            EXIT
         ENDIF
      ELSEIF bFuncKey <> NIL
         lModif := Eval( bFuncKey, @aDados, @nDimensao, @aLegenda, @nElIni )
      ENDIF

      IF lModif
         LOOP
      ENDIF

      IF LastKey() = K_RIGHT .AND. Len( aDados ) > nElIni + 11
         nElIni++
      ELSEIF LastKey() = K_LEFT  .AND. nElIni > 1
         nElIni--
      ELSEIF LastKey() = K_F4

          IF cOrdem = "C"
             aSort( aDados, NIL, NIL, { |a,b| a[ nDimensao ] > b[ nDimensao ] } )
             cOrdem := "D"
          ELSEIF cOrdem = "D"
             aSort( aDados, NIL, NIL, { |a,b| a[ nDimensao ] < b[ nDimensao ] } )
             cOrdem := If( IsLegenda, "L", "C" )
          ELSE
             aSort( aDados, NIL, NIL, { |a,b| a[ aLegenda[ 1, 1 ] ] < b[ aLegenda[ 1, 1 ] ] } )
             cOrdem := "C"
          ENDIF

          lModif := .T.

      ENDIF

   ENDDO

   IF lInit
      SetColor( "15/0,0/7" )
      CLS
      SetMode( 25, 80 )
   ENDIF

   RestState( aState, .F., .F., lInit, .T. )

RETURN( .T. )



STATIC FUNCTION grfEscala( aDados, nDimensao, nFator )

   LOCAL nEscala := 0
   LOCAL nPos

   FOR nPos := 1 TO Len( aDados )
       IF nEscala <  aDados[ nPos, nDimensao ]
          nEscala := aDados[ nPos, nDimensao ]
       ENDIF
   NEXT

   IF nEscala > 99999
      nFator  := 1000
      nEscala := Round( ( nEscala / nFator ) / 10, 1 )
   ELSE
      nFator  := 1
      nEscala := Round( nEscala, 0 )
      nEscala := ( nEscala + If( Right( Str( nEscala ), 1 ) = "0", 0, 10 - Val( Right( Str( nEscala ), 1 ) ) ) ) / 10
   ENDIF

RETURN( nEscala )



STATIC FUNCTION grfGrade( nEscala, nFator )

   LOCAL nDec := If( nFator > 1, 1, 0 )
   LOCAL nI

   @ 04,00 CLEAR TO 27,79

   IF nDec > 0
      @ 04,02 SAY "Mil" COLOR "14/0"
   ENDIF

   FOR nI := 0 TO 10
       @ 26 - (nI * 2), 01    SAY Str( nEscala * nI, 5, nDec )       COLOR "14/0"
       @ Row()        , Col() SAY "√"
       @ 26 - (nI * 2), 07    SAY Repl( If( nI = 0, "ƒ", "˙" ), 71 ) COLOR "7/0"
       @ 25 - (nI * 2), 06    SAY "≥"
   NEXT

RETURN( NIL )



STATIC FUNCTION grfBarra( nPos, nValor, nFator, nEscala, cColor, nPercent )

   LOCAL nBase := ( (nValor / nFator) / (nEscala * 10) ) * 100
   LOCAL nDec  := If( nFator > 1, 1, 0 )
   LOCAL nI

   FOR nI := 0 TO Round( nBase / 5, 0 )

       DO CASE
          CASE nI = 0
               @ 26     , 07 + (nPos * 6) SAY "ﬂﬂﬂﬂﬂ" COLOR cColor
          CASE nI = 1
               @ 26     , 07 + (nPos * 6) SAY "ﬂﬂﬂﬂﬂ" COLOR cColor
               @ 25     , 07 + (nPos * 6) SAY "€€€€€" COLOR cColor
          CASE nI = 20 .OR. nI = Round( nBase / 5, 0 )
               @ 26 - nI, 07 + (nPos * 6) SAY "‹‹‹‹‹" COLOR cColor
          CASE nI < 21
               @ 26 - nI, 07 + (nPos * 6) SAY "€€€€€" COLOR cColor
          CASE nI > 20
               EXIT
       ENDCASE

   NEXT

   @ 26 - nI, 07 + (nPos * 6) SAY Str( nValor / nFator, 5, nDec ) COLOR "15/0"

   IF nPercent <> NIL
      @ 25 - nI, 07 + (nPos * 6) SAY nPercent PICT If( nPercent = 100, " 999%", "99.9%" ) COLOR "14/0"
   ENDIF

RETURN( NIL )



FUNCTION grfInit( nRow )

   vDef( @nRow, 50 )

   SetColor( "15/0,0/7,,,15/0" )
   CLS
   SetMode( nRow, 80 )
   SetCursor(0)
   SetColor( "15/0,0/7,9/0,,15/1" )

RETURN( NIL )
