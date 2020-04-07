/*

 MaxGet.prg
 Descricao: Biblioteca de funcoes de GETs.
 Desenvolvido por MAX SCALLA Informatica Ltda.

 EMERSON DA SILVA CREMA
 03/09/13 * Implementado o parametro l2Linhas em MSele().
 12/11/09 * Movidas definicoes de MAXSTD.CH:
            #translate :radioGsb  => :cargo\[1\]
            #translate :radioGets => :cargo\[2\]
            #define RADIO_NUM_IVARS  6
            #define RADIO_BUTTON     Chr(4)
 26/06/07 * Desenvolvimento de mxGetArq().
 24/08/06 * Implementado parametro nCol em mSele().
 14/06/05 * Desenvolvimento de getDefMsg().
 10/11/03 * Incluso parametro bValid em SelectCheck().

*/

#include "std.ch"
#include "inkey.ch"
#include "getExit.ch"

/*--- Definicoes para utilizacao de funcoes do tipo RADIO ---*

#translate :radioGsb  => :cargo\[1\]
#translate :radioGets => :cargo\[2\]

#define RADIO_NUM_IVARS  6
#define RADIO_BUTTON     Chr(4)

*--- Funcoes de Caixas de Selecao ---*/

*--- Funcao RADIOGETS ---*

FUNCTION RadioGets( bVar, cVar, aChoices, aGetList, NoEnter )

   LOCAL nRow      := Row()
   LOCAL nCol      := Col()
   LOCAL nGets     := Len( aChoices )
   LOCAL nStartGet := Len( aGetList ) + 1

   LOCA nGet, oGet

   FOR nGet := 1 TO nGets

       DevPos(nRow, nCol)
       DevOut("( ) ")

       oGet := GetNew()
       Aadd( aGetList, oGet )

       oGet:col   := nCol + 4
       oGet:row   := nRow++
       oGet:name  := cVar
       oGet:block := t( aChoices[ nGet ] )
       oGet:cargo := Array( RADIO_NUM_IVARS )

       oGet:radioGsb  := bVar
       oGet:radioGets := Array( nGets )

       aEval( oGet:radioGets, { |x, n| oGet:radioGets[ n ] := nStartGet + n - 1 } )

       oGet:reader := { |o| RadioReader( o, aGetList, NoEnter ) }
       oGet:display()

   NEXT

RETURN( oGet )



FUNCTION t(c)

RETURN( {|x| c } )



PROCEDURE RadioReader( oGet, aGetList, NoEnter )

   IF ( GetPreValidate( oGet ) )
      oGet:SetFocus()

      DO WHILE ( oGet:exitState = GE_NOEXIT )
         IF ( oGet:typeOut )
            oGet:exitState := GE_ENTER
         ENDIF

         DO WHILE ( oGet:exitState = GE_NOEXIT )
            RadioApplyKey( oGet, mxInkey(), aGetList, NoEnter )
         ENDDO

         IF ( ! GetPostValidate( oGet ) )
            oGet:exitState := GE_NOEXIT
         ENDIF
      ENDDO

      oGet:KillFocus()

   ENDIF

RETURN


PROCEDURE RadioApplyKey( oGet, nKey, aGetList, NoEnter )

   LOCAL cKey, bKeyBlock, nSaveRow, nSaveCol

   IF ( bKeyBlock := SetKey( nKey ) ) <> NIL
      GetDoSetKey( bKeyBlock, oGet )
      RETURN
   ENDIF

   DO CASE
      CASE ( nKey = K_UP        ) ; oGet:exitState := GE_UP
      CASE ( nKey = K_SH_TAB    ) ; oGet:exitState := GE_UP
      CASE ( nKey = K_DOWN      ) ; oGet:exitState := GE_DOWN
      CASE ( nKey = K_TAB       ) ; oGet:exitState := GE_DOWN
      CASE ( nKey = K_PGUP      ) ; oGet:exitState := GE_WRITE
      CASE ( nKey = K_PGDN      ) ; oGet:exitState := GE_WRITE
      CASE ( nKey = K_CTRL_HOME ) ; oGet:exitState := GE_TOP
      CASE ( nKey = K_CTRL_W    ) ; oGet:exitState := GE_WRITE
      CASE ( nKey = K_INS       ) ; Set( _SET_INSERT, ! Set( _SET_INSERT ) )
      CASE ( nKey = K_ENTER .AND. ( NoEnter <> NIL ) )
           oGet:exitState := GE_ENTER
      CASE ( nKey = K_SPACE  ) .OR. ( nKey = K_ENTER )
           IF Eval( oGet:radioGsb ) <> Eval( oGet:block )
              Eval( oGet:radioGsb, Eval( oGet:block ) )
           ENDIF
           oGet:changed := .T.
           DrawRadios( aGetlist, oGet )
           IF ( nKey = K_ENTER )
              oGet:exitState := GE_WRITE
           ENDIF
      CASE ( nKey = K_ESC )
           IF ( Set( _SET_ESCAPE ) )
              oGet:undo()
              oGet:exitState := GE_ESCAPE
           ENDIF
   ENDCASE

RETURN



PROCEDURE DrawRadios( aGetList, oGet )

   LOCAL nRadios  := Len( oGet:radioGets )
   LOCAL nSaveRow := Row()
   LOCAL nSaveCol := Col()

   LOCAL nGet, oGet1

   FOR nGet := 1 TO nRadios
      oGet1 := aGetList[ oGet:radioGets[ nGet ] ]
      DevPos( oGet1:row, oGet1:col - 3 )
      DevOut( If( Eval( oGet1:radioGsb ) = Eval( oGet1:block ), RADIO_BUTTON, " " ) )
   NEXT

   DevPos( nSaveRow, nSaveCol )

RETURN



FUNCTION MSele( cVar, cMsg, aOpc, nLeft, cColor, nCol, l2Linhas )

   LOCAL GetList := {}
   LOCAL aState  := SaveState( NIL, {} )
   LOCAL nCheck  := 1
   LOCAL nLen    := 0
   LOCAL cRad    := ""
   LOCAL cDef    := " " + cVar + " "

   LOCAL nLinI, nColI, nLinF, nColF, nLin, nPos, aPos

   vDef( @cColor, "1/7,15/1,,,7/1" )
   vDef( @nCol, 1 )
   vDef( @l2Linhas, .F. )

   SetCursor(0)
   SetColor( cColor )

   aEval( aOpc, { |x| nLen := Max( nLen, Len( x[ nCol ] ) ) } )

   FOR nPos := 1 TO Len( aOpc )

      cRad += '" ' + PadR( aOpc[ nPos, nCol ], nLen ) + ' ",'

      IF cVar $ Left( aOpc[ nPos, nCol ], 1 )
         cDef := " " + PadR( aOpc[ nPos, nCol ], nLen ) + " "
      ENDIF

   NEXT

   nLen += 2

   cRad := "{" + Left( cRad, Len( cRad ) -1 ) + "}"

   IF l2Linhas
      aPos := defPosicao( Len( aOpc ), Max( Len( cMsg ), nLen + 5 ) )
   ELSE
      aPos := defPosicao( Len( aOpc ), Len( cMsg ) + nLen + 5 )
   ENDIF

   nLinI := aPos[ 1 ]
   nColI := aPos[ 2 ]
   nLinF := aPos[ 3 ]
   nColF := aPos[ 4 ]
   
   IF l2Linhas
      nLinF += 2
      nLin := nLinI + 1
   ELSE
      nLin := nLinI + Int( Len( aOpc ) / 2 ) + mxRest( Len( aOpc ), 2 )
   ENDIF

   MStatus( { { "Para configurar tecle ", "0/7" }, { "Ù", "15/7" }, { " no item selecionado", "0/7" } }, 2 )

   Limpa( nLinI, nColI, nLinF, nColF, "s" )

   @ nLin,nColI + 2 SAY cMsg

   @ nLinI + If( l2Linhas, 3, 1 ), nColI + If( l2Linhas, 2, Len( cMsg ) + 3 ) ;
     GET   cDef ;
     RADIO &cRad

   READ

   cVar := AllTrim( cDef )

   IF nLeft <> NIL
      cVar := Left( cVar, nLeft )
   ENDIF

   RestState( aState, .F., .F., .T., .T. )

RETURN( cVar )



FUNCTION MaxSele( aVar, cMsg, cColor1, cColor2, cColor3, cColor4, cColor5, nType )

   LOCAL GetList := {}
   LOCAL aState  := SaveState( NIL, {} )

   LOCAL lReturn := .T.
   LOCAL nLen    := Len( aVar[ 1, 2 ] )

   LOCAL aOpc[ Len( aVar ) ]

   LOCAL nLinI, nColI, nLinF, nColF, nLin, nPos, aPos
   
   vDef( @cColor1,  "1/7" )
   vDef( @cColor2,  "7/1" )
   vDef( @cColor3,  "1/7" )
   vDef( @cColor4,  "1/7" )
   vDef( @cColor5, "15/1" )
   vDef( @nType  ,     1  )

   aPos := defPosicao( Len( aVar ), Len( cMsg ) + nLen +5 )

   nLinI := aPos[ 1 ]
   nColI := aPos[ 2 ]
   nLinF := aPos[ 3 ]
   nColF := aPos[ 4 ]

   nLin := nLinI + Int( Len( aVar ) /2 ) + mxRest( Len( aVar ), 2 )

   Limpa( nLinI, nColI, nLinF, nColF, "s", NIL, cColor1 )

   @ nLin,nColI +2 SAY cMsg COLOR cColor1

   FOR nPos := 1 TO Len( aVar )
       aOpc[ nPos ] := aVar[ nPos, 1 ]
       aVar[ nPos ] := { nLinI + nPos, nColI + Len( cMsg ) +3, aVar[ nPos, 2 ], aVar[ nPos, 1 ] }
   NEXT

   lReturn := SelectCheck( @aVar, cColor5, cColor2, cColor3, cColor4, 2 )

   FOR nPos := 1 TO Len( aVar )
      IF nType = 2
         aVar[ nPos, 1 ] := If( lReturn, aVar[ nPos, 4 ], aOpc[ nPos ] )
         aVar[ nPos, 2 ] := aVar[ nPos, 3 ]
         aSize( aVar[ nPos ], 2 )
      ELSE
         aVar[ nPos ] := If( lReturn, aVar[ nPos, 4 ], aOpc[ nPos ] )
      ENDIF
   NEXT

   RestState( aState, .F., .F., .T., .T. )

RETURN( lReturn )



FUNCTION SelectCheck( ;
                      aCheck   ,;
                      cAtiv    ,;
                      cInat    ,;
                      cRAtiv   ,;
                      cRInat   ,;
                      nMode    ,;
                      MoldCheck,;
                      RunFunct ,;
                      bValid   ,;
                      lSkip    ,;
                      nCheck    ;
                    )
                    
   #define SLC_LIN 1
   #define SLC_COL 2
   #define SLC_DES 3
   #define SLC_CHK 4

   LOCAL nCursor := SetCursor(0)
   LOCAL nKey    := 0

   LOCAL uSelect, cCheckOk, cCheckNo, nCount, nNewPos

   vDef( @nCheck, 1      )
   vDef( @cAtiv , "15/0" )
   vDef( @cInat , "0/7"  )
   vDef( @cRAtiv, "0/7"  )
   vDef( @cRInat, "0/7"  )

   vDef( @nMode, 1 )

   vDef( @lSkip, .F. )

   nNewPos := nCheck

   IF nMode = 1
      cCheckOk := "(" + Chr(4) + ") "
      cCheckNo := "( ) "
   ELSE
      cCheckOk := "[û] "
      cCheckNo := "[ ] "
   ENDIF

   FOR nCount := 1 TO Len( aCheck )

       @ aCheck[ nCount, SLC_LIN ], aCheck[ nCount, SLC_COL ] SAY If( aCheck[ nCount, SLC_CHK ], cCheckOk, cCheckNo) COLOR If( nCount = nCheck, cRAtiv, cRInat )

       @ aCheck[ nCount, SLC_LIN ], aCheck[ nCount, SLC_COL ] + 4 SAY aCheck[ nCount, SLC_DES ]                      COLOR If( nCount = nCheck, cAtiv, cInat )

       IF aCheck[ nCount, SLC_CHK ] .AND. nMode = 1
          uSelect := nCount
       ENDIF

       IF MoldCheck <> NIL
          SayMold( aCheck[ nCount, SLC_LIN ], aCheck[ nCount, SLC_COL ], aCheck[ nCount, SLC_DES ] + Space(4), MoldCheck )
       ENDIF

   NEXT

   MStatus( { { "Use ", "0/7" }, { "ESC/Ù", "15/7" }, { " para retornar, ","0/7" }, { Chr(24) + Chr(25) + Chr(26) + Chr(27), "15/7" }, { " para movimentar-se e ", "0/7" }, { "SPC", "15/7" }, { " para sele‡„o do item", "0/7" } }, 2 )

   DO WHILE ! mxIn( nKey, { K_PGDN, K_PGUP, K_ENTER, K_ESC } )

      IF RunFunct <> NIL
         EVal( RunFunct, nCheck )
      ENDIF

      nKey := mxInkey()

      IF mxIn( nKey, { K_UP, K_LEFT } )

         IF nCheck = 1
            nNewPos := Len( aCheck )
         ELSE
            nNewPos--
         ENDIF

      ELSEIF mxIn( nKey, { K_DOWN, K_RIGHT } )

         IF nCheck = Len( aCheck )
            nNewPos := 1
         ELSE
            nNewPos++
         ENDIF

      ELSEIF mxIn( nKey, { K_HOME, K_CTRL_HOME, K_CTRL_PGUP } )

         nNewPos := 1

      ELSEIF mxIn( nKey, { K_END, K_CTRL_END, K_CTRL_PGDN } )

         nNewPos := Len( aCheck )

      ELSEIF nKey = K_SPACE

         IF nMode = 1

            uSelect := nCheck

            FOR nSelect := 1 TO Len( aCheck )

                IF aCheck[ nSelect, SLC_CHK ] := ( nSelect = nCheck )
                   @ aCheck[ nSelect, SLC_LIN ], aCheck[ nSelect, SLC_COL ] + 1 SAY Chr(4)                    COLOR If( nSelect = nCheck, cRAtiv, cRInat )
                ELSE
                   @ aCheck[ nSelect, SLC_LIN ], aCheck[ nSelect, SLC_COL ] + 1 SAY " "                       COLOR If( nSelect = nCheck, cRAtiv, cRInat )
                   @ aCheck[ nCheck , SLC_LIN ], aCheck[ nCheck , SLC_COL ] + 4 SAY aCheck[ nCheck, SLC_DES ] COLOR cInat
                ENDIF

            NEXT

         ELSEIF bValid = NIL .OR. Eval( bValid, aCheck, nCheck )

            aCheck[ nCheck, SLC_CHK ] := ( ! aCheck[ nCheck, SLC_CHK ] )

            @ aCheck[ nCheck, SLC_LIN ], aCheck[ nCheck, SLC_COL ] ;
              SAY   If( aCheck[ nCheck, SLC_CHK ], cCheckOk, cCheckNo ) ;
              COLOR cRAtiv

            IF lSkip

               IF nCheck = Len( aCheck )
                  nNewPos := 1
               ELSE
                  nNewPos++
               ENDIF

            ENDIF

         ENDIF

      ENDIF

      IF mxIn( nKey, { K_PGDN, K_PGUP, K_ENTER, K_ESC } )
         cRAtiv := cRInat
         cAtiv  := cInat
      ENDIF

      IF ( nCheck <> 0 )  // .AND. ( nNewPos <> nCheck )

         @ aCheck[ nCheck, SLC_LIN ], aCheck[ nCheck, SLC_COL ]     SAY If( aCheck[ nCheck, SLC_CHK ], cCheckOk, cCheckNo ) COLOR cRInat
         @ aCheck[ nCheck, SLC_LIN ], aCheck[ nCheck, SLC_COL ] + 4 SAY     aCheck[ nCheck, SLC_DES ]                       COLOR cInat

         nCheck := nNewPos

         @ aCheck[ nNewPos, SLC_LIN ], aCheck[ nNewPos, SLC_COL ]     SAY If( aCheck[ nNewPos, SLC_CHK ], cCheckOk, cCheckNo ) COLOR cRAtiv
         @ aCheck[ nNewPos, SLC_LIN ], aCheck[ nNewPos, SLC_COL ] + 4 SAY     aCheck[ nNewPos, SLC_DES ]                       COLOR cAtiv

      ENDIF

      IF nKey = K_ESC

         nCheck := 0

      ELSEIF mxIn( nKey, { K_ENTER, K_PGDN, K_PGUP } )

         SetPos( 24, 00 )

      ENDIF

   ENDDO
   IF nMode <> 1
      uSelect := !ESC
   ENDIF
   SetCursor( nCursor )

RETURN( uSelect )



/*----------------------------------------------------------------------------
 Atualiza os valores de uma matriz GetList

 Parametros

 GetList : Matriz GetList
 cName   : Variavel que nao sera atualizado o Valid
----------------------------------------------------------------------------*/

FUNCTION GetUpdate( GetList, cName )

   LOCAL nGet

   FOR nGet := 1 TO Len( GetList )

      GetList[ nGet ]:UpdateBuffer()

      DO CASE
         CASE GetList[ nGet ]:Control:Classname() = "LISTBOX"
              GetList[ nGet ]:Control:Select( GetList[ nGet ] :VarGet() )
         CASE GetList[ nGet ]:Control:Classname() = "PUSHBUTTON"
              GetList[ nGet ]:Control:Display()
         OTHERWISE
              GetList[ nGet ]:Display()
      ENDCASE

      IF ( cName                     <> NIL ) .AND. ;
         ( GetList[ nGet ]:PostBlock <> NIL ) .AND. ;
         ( ! GetList[ nGet ]:Name    $ cName  )
         EVal( GetList[ nGet ]:PostBlock, GetList[ nGet ] )
      ENDIF
   NEXT

RETURN( .T. )



FUNCTION DefPict( aGet, cVar, cPict )

   LOCAL nPos := aScan( aGet, { |g| g:name = Upper( cVar ) } )

   IF nPos > 0
      aGet[ nPos ]:picture := cPict
      aGet[ nPos ]:display()
   ENDIF

RETURN( .T. )



FUNCTION getDefMsg( aGet, cVar, cMsg )

   LOCAL nPos := aScan( aGet, { |g| g:name = Upper( cVar ) } )

   IF nPos > 0
      aGet[ nPos ]:message := cMsg
      aGet[ nPos ]:display()
   ENDIF

RETURN( .T. )



FUNCTION mxGetArq( cNomArq, cTitulo )

   LOCAL GetList := {}
   LOCAL lReturn := .F.

   vDef( @cTitulo, "Informe o nome do arquivo" )

   DO WHILE .T.

      mxGetBox( cTitulo, @cNomArq, "@S30" )

      IF LastKey() = K_ESC
         EXIT
      ENDIF

      IF File( cNomArq ) .AND. ConfMsg( "Nome de arquivo j  existente, substituir", { "N„o", "Sim" } ) = 1
         LOOP
      ENDIF

      lReturn := .T.
      EXIT

   ENDDO

RETURN( lReturn )