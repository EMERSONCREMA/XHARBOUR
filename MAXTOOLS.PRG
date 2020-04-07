/*

 MaxTools.prg
 Descricao: Biblioteca de funcoes de ferramentas do sistema.
 Desenvolvido por MAX SCALLA Informatica Ltda.

 EMERSON DA SILVA CREMA
 10/10/16 * Implementado ThreadSleep() em Pop_Key().
 22/03/06 * Otimizada Calculadora() p/ diminuir a programacao.
          * Removidas variavels nCalcRow1 e 2, e nCalcCol1 e 2 p/ utilizar a
            matriz aCalcPos.
          * Correcao em Calendario(): variable does not exist H_HOME.
          * Desenvolvimento de calendTela().

 DENIS MAZZUCATTO RODRIGUES
 13/05/05 * Desenvolvimento de mxFormat().

*/

#include "std.ch"
#include "inkey.ch"

#define CALC_DIG_ADD   "+"
#define CALC_DIG_SUB   "-"
#define CALC_DIG_MUL   "*"
#define CALC_DIG_DIV   "/"
#define CALC_DIG_PER   "%"
#define CALC_DIG_EQ    "=" + Chr( K_ENTER )
#define CALC_DIG_CE    "Ee "
#define CALC_DIG_CLEAR "Cc"
#define CALC_DIG_POINT ".,"
#define CALC_DIG_BS    Chr(8)

STATIC aCalcPos  := { 2, 2, 16, 26 }
STATIC nTotTrack := 0
STATIC cProcTime := ""


FUNCTION Calendario( dUpdate )

   LOCAL aState    := SaveState( NIL, {} )
   LOCAL aSaveKeys := KeyReset( { K_SH_TAB, K_LEFT, K_RIGHT } )
   LOCAL lMode2000 := __SetCentury( .T. )
   LOCAL nRowPos   := 2
   LOCAL nColPos   := 2
   LOCAL dDate     := Date()

   LOCAL dDateIndex, nRow, nCol, lEnd, cYear, nPosX, nPosY, dDateRef, nDayRef

   calendTela( nRowPos, nColPos )

   MStatus({ { " ESC", "15/7" }, {"/", "0/7"}, {"Ù", "15/7" }, { "úRetorna ³ Use (", "0/7" }, { Chr(24)+Chr(25), "15/7" }, { "/", "0/7" }, { Chr(26)+Chr(27), "15/7" }, { ") ou digite a data a pesquisar no calend rio", "0/7" } }, 1)

   DO WHILE .T.

      SetColor( "15/1" )

      @ nRowPos +1,nColPos +1 SAY SelSemana( dDateRef := dDate ) + " ¯ " + Str( day( dDateRef ), 2, 0 ) + " " + PadR( CapFirst( StrMes( dDateRef ) ), 9 ) + " " + Str( year( dDateRef ), 4, 0 )

      dDateIndex := CtoD( "01" + Subs( DtoC( dDate ), 3 ) )
      nRow       := nRowPos +3
      nCol       := nColPos +1
      lEnd       := .F.
      cYear      := Subs( DtoC( dDate ), 4 )

      FOR nPosX := 1 TO 6

         FOR nPosY := 1 TO 7

            IF Dow( dDateIndex ) == nPosY .AND. ! lEnd

               nDayRef := day( dDateIndex )

               SetColor( If( day( dDateRef ) == nDayRef, "15/4", "15/1" ) )

               @ nRow + nPosX *2, nCol + nPosY *4 -3 SAY nDayRef PICT "99"
               dDateIndex ++
               IF ! cYear == Subs( DtoC( dDateIndex ), 4 )
                  lEnd := .T.
               ENDIF
            ELSE
               @ nRow + nPosX *2, nCol + nPosY *4 -3 SAY "  " COLOR "15/1"
            ENDIF

         NEXT

      NEXT

      SetCursor(0)

      DO CASE
         CASE mxInKey() == K_ESC
              EXIT
         CASE LastKey() == K_ENTER
              IF ValType( dUpdate ) == "O"
                 dUpdate:VarPut( dDate )
                 dUpdate:Buffer := DtoC( dDate )
                 dUpdate:BadDate := .F.
                 dUpdate:UpdateBuffer()
                 dUpdate:Assign()
              ELSE
                 dUpdate := dDate
              ENDIF
              EXIT
         CASE LastKey() == K_LEFT  .AND. ! ( Year( dDate ) == 0100 .AND. Month( dDate ) == 01 ) ; dDate := AddMonth( dDate, -01 )
         CASE LastKey() == K_RIGHT .AND. ! ( Year( dDate ) == 2999 .AND. Month( dDate ) == 12 ) ; dDate := AddMonth( dDate,  01 )
         CASE LastKey() == K_DOWN  .AND. Year( dDate ) > 0100                                   ; dDate := AddMonth( dDate, -12 )
         CASE LastKey() == K_UP    .AND. Year( dDate ) < 2999                                   ; dDate := AddMonth( dDate,  12 )
         CASE LastKey() == 45                                                                   ; dDate := mod_data( dDate,  01 )
         CASE LastKey() == 43                                                                   ; dDate := mod_data( dDate,  02 )
         CASE LastKey() >= 48 .AND. LastKey() <= 57                                             ; dDate := mod_data( dDate )
         CASE LastKey() == K_CTRL_HOME .OR. LastKey() == K_HOME                                 ; dDate := CtoD( "01/01/0100" )
         CASE LastKey() == K_CTRL_END  .OR. LastKey() == K_END                                  ; dDate := CtoD( "31/12/2999" )
         OTHERWISE
              mxTone( 900, 0 )
      ENDCASE

   ENDDO

   __SetCentury( lMode2000 )

   RestState( aState, .F., .F., .T., .T. )
   KeyRestore( aSaveKeys )
   ClearKeybBuffer()

RETURN( dDate )



STATIC FUNCTION calendTela( nRowPos, nColPos )

   SetColor( "7/1" )

   Limpa( nRowPos, nColPos, nRowPos +19, nColPos +28, "S" )

   @ nRowPos +02,nColPos    SAY "ÆÍÍÍÑÍÍÍÑÍÍÍÑÍÍÍÑÍÍÍÑÍÍÍÑÍÍÍµ"
   @ nRowPos +03,nColPos    SAY "³   ³   ³   ³   ³   ³   ³   ³"

   SetColor( "11/1" )

   @ nRowPos +03,nColPos +01 SAY "Dom"
   @ nRowPos +03,nColPos +05 SAY "Seg"
   @ nRowPos +03,nColPos +09 SAY "Ter"
   @ nRowPos +03,nColPos +13 SAY "Qua"
   @ nRowPos +03,nColPos +17 SAY "Qui"
   @ nRowPos +03,nColPos +21 SAY "Sex"
   @ nRowPos +03,nColPos +25 SAY "Sab"

   SetColor( "7/1" )

   @ nRowPos +04,nColPos     SAY "ÆÍÍÍØÍÍÍØÍÍÍØÍÍÍØÍÍÍØÍÍÍØÍÍÍµ"
   @ nRowPos +05,nColPos     SAY "³   ³   ³   ³   ³   ³   ³   ³"
   @ nRowPos +06,nColPos     SAY "ÃÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄ´"
   @ nRowPos +07,nColPos     SAY "³   ³   ³   ³   ³   ³   ³   ³"
   @ nRowPos +08,nColPos     SAY "ÃÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄ´"
   @ nRowPos +09,nColPos     SAY "³   ³   ³   ³   ³   ³   ³   ³"
   @ nRowPos +10,nColPos     SAY "ÃÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄ´"
   @ nRowPos +11,nColPos     SAY "³   ³   ³   ³   ³   ³   ³   ³"
   @ nRowPos +12,nColPos     SAY "ÃÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄ´"
   @ nRowPos +13,nColPos     SAY "³   ³   ³   ³   ³   ³   ³   ³"
   @ nRowPos +14,nColPos     SAY "ÃÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄÅÄÄÄ´"
   @ nRowPos +15,nColPos     SAY "³   ³   ³   ³   ³   ³   ³   ³"
   @ nRowPos +16,nColPos     SAY "ÆÍÍÍÏÍÍÍÏÍÍÍÏÍÑÍÏÍÍÍÏÍÍÍÏÍÍÍµ"
   @ nRowPos +17,nColPos +14 SAY "³"
   @ nRowPos +18,nColPos +14 SAY "³"
   @ nRowPos +19,nColPos +14 SAY "Á"

   SetColor( "11/1" )

   @ nRowPos +17,nColPos +03 SAY "(" + Chr(24) + ") + ano"
   @ nRowPos +17,nColPos +17 SAY "(" + Chr(26) + ") + mˆs"
   @ nRowPos +18,nColPos +03 SAY "(" + Chr(25) + ") - ano"
   @ nRowPos +18,nColPos +17 SAY "(" + Chr(27) + ") - mˆs"

RETURN( NIL )



FUNCTION Mod_Data( d_ant, nStatus )

   LOCAL GetList := {}
   LOCAL aState  := SaveState( NIL, {} )
   LOCAL d_digit := d_ant
   LOCAL d_ndia  := 0

   SetColor( "1/15,15/1,,,1/15" )

   BackGround( 01, 00, MaxRow() -1, 79, If( IsDef( "CFIFUNCTR" ), CFIFUNCTR, 60 ) )

   Limpa( 04, 03, 06, 52, "S" )
   DefCursor()

   IF nStatus == NIL
      RepeatKey()
      @ 05,05 ;
        SAY   "Entre com a data e ser pesquisada ¯" ;
        GET   d_digit ;
        PICT  "99.99.9999" ;
        VALID ! empty( d_digit ) .AND. ;
              d_digit <= CtoD("31/12/2999") .AND. ;
              d_digit >= CtoD("01/01/0100") ;
        WHEN  MensHelp( "Digite a data a ser localizada" )
      READ
   ELSE
      @ 05,05 ;
        SAY   "N£mero de dias a ser pesquisado ¯" ;
        GET   d_ndia ;
        PICT  "999999999999" ;
        VALID d_ndia > 0                                                                           WHEN MensHelp("Digite o n£mero de dias a ser localizado")
      READ
      IF nStatus == 1
         d_digit -= d_ndia
      ELSE
         d_digit += d_ndia
      ENDIF
   ENDIF

   RestState( aState, .F., .F., .T., .T. )
   ClearKeybBuffer()

RETURN( If( LastKey() == K_ESC , d_ant, d_digit ) )



FUNCTION Calculad()

   LOCAL aState    := SaveState( NIL, {} )
   LOCAL aSaveKeys := KeyReset( { LastKey(), K_LEFT, K_RIGHT } )
   LOCAL INI_CALC  := .T.
   LOCAL cScrMove  := SaveScreen( 1, 0, MaxRow() -1, 79 )

   LOCAL nCalcKey, T_CAL1, nMove

   SetColor( "0/7" ) ; SetCursor(0)

   POP_CALC( @T_CAL1 )

   MStatus( { { " ESC", "15/7" }, { "úRetorna ³ Use (", "0/7" }, { Chr(24)+Chr(25), "15/7" }, { "/", "0/7" }, { Chr(26)+Chr(27), "15/7" }, { ") ou CTRL+(", "0/7" }, { Chr(26)+Chr(27), "15/7" }, { ") para movimentar a calculadora", "0/7" } }, 1)

   DO WHILE .T.

      IF INI_CALC

         RestScreen( aCalcPos[1], aCalcPos[2], aCalcPos[3], aCalcPos[4], T_CAL1 )

         NUM_CALC := 0
         DEC_CALC := 0
         PRI_CALC := 0
         LIC_CALC := 0
         DET_CALC := 0

         SOM_CALC := 0
         SUB_CALC := 0
         MUL_CALC := 0
         DIV_CALC := 0
         CDG_CALC := 0

         CTD_CALC := .F.
         INI_CALC := .F.
         DG1_CALC := .T.

         SIN_CALC := "C"

      ENDIF

      POP_IMPR( NUM_CALC,DEC_CALC,CTD_CALC,"C" )

      DO WHILE .T.

         IF ! ( nCalcKey := mxInKey() ) == 0

            POP_KEY( nCalcKey )

            DO CASE
               CASE Chr( nCalcKey ) $ CALC_DIG_CLEAR

                    IF Len( SIN_CALC ) > 0
                       INI_CALC := .T.
                       EXIT
                    ENDIF

               CASE Chr( nCalcKey ) $ CALC_DIG_CE

                    NUM_CALC := 0
                    CDG_CALC := 0
                    DG1_CALC := .T.
                    POP_IMPR( NUM_CALC, DEC_CALC, CTD_CALC, "E" )

               CASE Chr( nCalcKey ) == CALC_DIG_BS

                    NUM_CALC := Str( NUM_CALC, 25, DEC_CALC )
                    NUM_CALC := Val( Left( NUM_CALC, Len( NUM_CALC ) -1 ) )
                    DEC_CALC := If( DEC_CALC == 0,  0 , DEC_CALC -1 )
                    CTD_CALC := If( DEC_CALC == 0, .F., CTD_CALC    )
                    CDG_CALC := If( CDG_CALC == 0,  0 , CDG_CALC -1 )
                    POP_IMPR( NUM_CALC, DEC_CALC, CTD_CALC, SIN_CALC )

               CASE ( nCalcKey == K_CTRL_LEFT  .AND. ( aCalcPos[2] -5 >= 00 .AND. aCalcPos[4] -5 >= 24 ) ) .OR. ;
                    ( nCalcKey == K_CTRL_RIGHT .AND. ( aCalcPos[2] +5 <= 53 .AND. aCalcPos[4] +5 <= 77 ) )

                    nMove := If( nCalcKey == K_CTRL_LEFT, -5, 5 )

                    RestScreen( 01, 00, MaxRow()-1, 79, cScrMove )
                    aCalcPos[2] += nMove
                    aCalcPos[4] += nMove
                    POP_CALC( @T_CAL1 )
                    DEC_CALC := POP_DECIM( NUM_CALC )
                    POP_IMPR( NUM_CALC, DEC_CALC, CTD_CALC, SIN_CALC )
                    DEC_CALC := 0

               CASE ( nCalcKey == K_LEFT  .AND. ( aCalcPos[2] -1 >= 00 .AND. aCalcPos[4] -1 >= 24 ) ) .OR. ;
                    ( nCalcKey == K_RIGHT .AND. ( aCalcPos[2] +1 <= 53 .AND. aCalcPos[4] +1 <= 77 ) )

                    nMove := If( nCalcKey == K_LEFT, -1, 1 )

                    RestScreen( 01, 00, MaxRow()-1, 79, cScrMove )
                    aCalcPos[2] += nMove
                    aCalcPos[4] += nMove
                    POP_CALC( @T_CAL1 )
                    DEC_CALC := POP_DECIM( NUM_CALC )
                    POP_IMPR( NUM_CALC, DEC_CALC, CTD_CALC, SIN_CALC )
                    DEC_CALC := 0

               CASE ( nCalcKey == K_DOWN .AND. ( aCalcPos[3] +1 <= MaxRow() -2 ) ) .OR. ;
                    ( nCalcKey == K_UP   .AND. ( aCalcPos[1] -1 >= 1 .AND. aCalcPos[3]-1 >= 15 ) )

                    nMove := If( nCalcKey == K_UP, -1, 1 )

                    RestScreen( 01, 00, MaxRow()-1, 79, cScrMove )
                    aCalcPos[1] += nMove
                    aCalcPos[3] += nMove
                    POP_CALC( @T_CAL1 )
                    DEC_CALC := POP_DECIM( NUM_CALC )
                    POP_IMPR( NUM_CALC, DEC_CALC, CTD_CALC, SIN_CALC )
                    DEC_CALC := 0

               CASE nCalcKey == K_ESC

                    INI_CALC := .F.
                    EXIT

               CASE nCalcKey > 47 .AND. nCalcKey < 58

                    NUM_CALC := If( DG1_CALC, 0, NUM_CALC )
                    DG1_CALC := .F.
                    CDG_CALC := If( CDG_CALC == 16, 16, CDG_CALC+1 )
                    IF CDG_CALC < 16
                       NUM_CALC := Str( NUM_CALC, 25, DEC_CALC )
                       DEC_CALC := If( CTD_CALC, DEC_CALC+1, DEC_CALC )
                       NUM_CALC := Val( NUM_CALC + If( DEC_CALC == 1, "." + Chr( nCalcKey ), Chr( nCalcKey ) ) )
                       POP_IMPR( NUM_CALC, DEC_CALC, CTD_CALC, SIN_CALC )
                    ENDIF

               CASE Chr( nCalcKey ) == CALC_DIG_ADD

                    PRI_CALC := If( SIN_CALC == CALC_DIG_ADD .OR. Len( SIN_CALC ) == 0, PRI_CALC, POP_CONC( PRI_CALC, NUM_CALC, SIN_CALC, nCalcKey ) )
                    PRI_CALC := If( PRI_CALC == 0, NUM_CALC, PRI_CALC )
                    SOM_CALC := If( SOM_CALC == 0, PRI_CALC, NUM_CALC + SOM_CALC )
                    SIN_CALC := CALC_DIG_ADD
                    SUB_CALC := 0
                    MUL_CALC := 0
                    DIV_CALC := 0
                    PRI_CALC := SOM_CALC
                    DG1_CALC := .T.
                    DEC_CALC := POP_DECIM( PRI_CALC )
                    POP_IMPR( PRI_CALC, DEC_CALC, CTD_CALC, SIN_CALC )
                    CTD_CALC := .F.
                    CDG_CALC := 0
                    DEC_CALC := 0

               CASE Chr( nCalcKey ) == CALC_DIG_SUB

                    PRI_CALC := If( SIN_CALC == CALC_DIG_SUB .OR. Len( SIN_CALC ) == 0, PRI_CALC, POP_CONC( PRI_CALC, NUM_CALC, SIN_CALC, nCalcKey ) )
                    PRI_CALC := If( PRI_CALC == 0, NUM_CALC, PRI_CALC )
                    SUB_CALC := If( SUB_CALC == 0, PRI_CALC, SUB_CALC - NUM_CALC )
                    SIN_CALC := CALC_DIG_SUB
                    SOM_CALC := 0
                    MUL_CALC := 0
                    DIV_CALC := 0
                    DG1_CALC :=.T.
                    PRI_CALC := SUB_CALC
                    DEC_CALC := POP_DECIM( PRI_CALC )
                    POP_IMPR( PRI_CALC, DEC_CALC, CTD_CALC, SIN_CALC )
                    CTD_CALC := .F.
                    CDG_CALC := 0
                    DEC_CALC := 0

               CASE Chr( nCalcKey ) == CALC_DIG_MUL

                    PRI_CALC := If( SIN_CALC == CALC_DIG_MUL .OR. Len( SIN_CALC ) == 0, PRI_CALC, POP_CONC( PRI_CALC, NUM_CALC, SIN_CALC, nCalcKey ) )
                    PRI_CALC := If( PRI_CALC == 0, NUM_CALC, PRI_CALC )
                    MUL_CALC := If( MUL_CALC == 0, PRI_CALC, NUM_CALC * MUL_CALC )
                    SIN_CALC := CALC_DIG_MUL
                    DG1_CALC := .T.
                    SOM_CALC := 0
                    SUB_CALC := 0
                    DIV_CALC := 0
                    PRI_CALC := MUL_CALC
                    DEC_CALC := POP_DECIM( PRI_CALC )
                    POP_IMPR( PRI_CALC, DEC_CALC, CTD_CALC, SIN_CALC )
                    CTD_CALC := .F.
                    CDG_CALC := 0
                    DEC_CALC := 0

               CASE Chr( nCalcKey ) == CALC_DIG_DIV

                    PRI_CALC := If( SIN_CALC == CALC_DIG_DIV .OR. Len( SIN_CALC ) == 0, PRI_CALC, POP_CONC( PRI_CALC, NUM_CALC, SIN_CALC, nCalcKey ) )
                    PRI_CALC := If( PRI_CALC == 0, NUM_CALC, PRI_CALC )
                    DIV_CALC := If( DIV_CALC == 0, PRI_CALC, DIV_CALC / NUM_CALC )
                    SIN_CALC := CALC_DIG_DIV
                    DG1_CALC := .T.
                    SOM_CALC := 0
                    SUB_CALC := 0
                    MUL_CALC := 0
                    PRI_CALC := DIV_CALC
                    DEC_CALC := POP_DECIM( PRI_CALC )
                    POP_IMPR( PRI_CALC, DEC_CALC, CTD_CALC, SIN_CALC )
                    CTD_CALC := .F.
                    CDG_CALC := 0
                    DEC_CALC := 0

               CASE Chr( nCalcKey ) == CALC_DIG_PER

                    IF SIN_CALC == CALC_DIG_DIV
                       NUM_CALC := PRI_CALC / NUM_CALC / 100
                       SIN_CALC := "="
                       PRI_CALC := 0
                    ELSEIF SIN_CALC == CALC_DIG_MUL
                       NUM_CALC := PRI_CALC * NUM_CALC / 100
                       SIN_CALC := "="
                       PRI_CALC := 0
                    ELSE
                       NUM_CALC := PRI_CALC * NUM_CALC / 100
                    ENDIF
                    DEC_CALC := POP_DECIM( NUM_CALC )
                    POP_IMPR( NUM_CALC, DEC_CALC, CTD_CALC, SIN_CALC )
                    SOM_CALC := 0
                    SUB_CALC := 0
                    MUL_CALC := 0
                    DIV_CALC := 0
                    CDG_CALC := 0
                    DEC_CALC := 0
                    DG1_CALC := .T.
                    CTD_CALC := .F.

               CASE Chr( nCalcKey ) $ CALC_DIG_EQ

                    IF Len( SIN_CALC ) > 0
                       PRI_CALC := POP_CONC( PRI_CALC, NUM_CALC, SIN_CALC, nCalcKey )
                    ENDIF
                    DG1_CALC := .T.
                    SIN_CALC := "="
                    DEC_CALC := POP_DECIM( PRI_CALC )
                    POP_IMPR( PRI_CALC, DEC_CALC, CTD_CALC, SIN_CALC )
                    NUM_CALC := PRI_CALC
                    PRI_CALC := 0
                    SOM_CALC := 0
                    SUB_CALC := 0
                    MUL_CALC := 0
                    DIV_CALC := 0
                    CDG_CALC := 0
                    DEC_CALC := 0
                    CTD_CALC :=.F.

               CASE Chr( nCalcKey ) $ CALC_DIG_POINT

                    NUM_CALC := If( DG1_CALC, 0, NUM_CALC )
                    DG1_CALC := .F.
                    CTD_CALC := .T.

               OTHERWISE
                    mxTone( 900, 0 )
                    ClearKeybBuffer()
            ENDCASE

         ENDIF

      ENDDO

      IF ! INI_CALC
         EXIT
      ENDIF

   ENDDO

   RestState( aState, .F., .F., .T., .T. )
   KeyRestore( aSaveKeys )
   ClearKeybBuffer()

RETURN( .T. )



STATIC FUNCTION Pop_Impr( VALI_CALC, DECI_CALC, CTLD_CALC, SINL_CALC )

   VALI_CALC := AllTrim( Str( VALI_CALC, 25, DECI_CALC ) )

   IF Left( VALI_CALC, 1 ) == "*"
      VALI_CALC := "             Erro"
   ENDIF

   @ aCalcPos[1] +02, aCalcPos[2] +03                    SAY Space(19)
   @ aCalcPos[1] +02, aCalcPos[2] +21 - Len( VALI_CALC ) SAY VALI_CALC
   @ aCalcPos[1] +13, aCalcPos[2] +20                    SAY SINL_CALC COLOUR "0/3"
   SetColor( "0/7" )

RETURN( .T. )



STATIC FUNCTION Pop_Conc( PRIC_CALC, NUMC_CALC, SINC_CALC, NOSC_CALC )

   NOSC_CALC := Chr( NOSC_CALC )

   DO CASE
      CASE SINC_CALC == CALC_DIG_ADD ; PRIC_CALC := PRIC_CALC + NUMC_CALC
      CASE SINC_CALC == CALC_DIG_SUB ; PRIC_CALC := PRIC_CALC - NUMC_CALC
      CASE SINC_CALC == CALC_DIG_MUL ; PRIC_CALC := PRIC_CALC * NUMC_CALC
      CASE SINC_CALC == CALC_DIG_DIV ; PRIC_CALC := PRIC_CALC / NUMC_CALC
      CASE SINC_CALC $  CALC_DIG_EQ  ; PRIC_CALC := PRIC_CALC
   ENDCASE

RETURN( PRIC_CALC )



STATIC FUNCTION Pop_Decim( VALA_CALC )

   LOCAL DECD_CALC := 6

   VALA_CALC := Str( VALA_CALC, 25, 6 )

   DO WHILE Right( VALA_CALC, 1 ) == "0"
      VALA_CALC := Left( VALA_CALC, Len( VALA_CALC ) -1 )
      DECD_CALC--
   ENDDO

RETURN( DECD_CALC )



STATIC FUNCTION Pop_Calc( T_CAL1 )

   mxDispBegin()

   SetColor( "0/3" )

   Muda_Cor( aCalcPos[1] +1, aCalcPos[2] +2, aCalcPos[3] +1, aCalcPos[4] +2, 8 )

   @ aCalcPos[1], aCalcPos[2], aCalcPos[3], aCalcPos[4] BOX "ÉÍ»º¼ÍÈº "

   @ aCalcPos[1]    , aCalcPos[2] +06 SAY   "úCalculadoraú"

   SetColor( "0/7" )
   @ aCalcPos[1] +01, aCalcPos[2] +02 SAY   "ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»"
   @ aCalcPos[1] +02, aCalcPos[2] +02 SAY   "º                   º"
   @ aCalcPos[1] +03, aCalcPos[2] +02 SAY   "ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼"

   SetColor( "0/3" )
   @ aCalcPos[1] +05, aCalcPos[2] +01 SAY  " ( ) ( ) ( ) ( ) (   ) "
   @ aCalcPos[1] +07, aCalcPos[2] +01 SAY  " ( ) ( ) ( ) ( )  (C ) "
   @ aCalcPos[1] +09, aCalcPos[2] +01 SAY  " ( ) ( ) ( ) ( ) (   ) "
   @ aCalcPos[1] +11, aCalcPos[2] +01 SAY  " ( ) ( ) ( ) ( ) (   ) "
   @ aCalcPos[1] +12, aCalcPos[2]     SAY "ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶"
   @ aCalcPos[1] +13, aCalcPos[2] +09 SAY "Opera‡„o (   )"

   SetColor( "9/3" )
   @ aCalcPos[1] +05, aCalcPos[2] +03 SAY "7"
   @ aCalcPos[1] +05, aCalcPos[2] +07 SAY "8"
   @ aCalcPos[1] +05, aCalcPos[2] +11 SAY "9"
   @ aCalcPos[1] +05, aCalcPos[2] +15 SAY "+"
   @ aCalcPos[1] +05, aCalcPos[2] +20 SAY Chr(27)
   @ aCalcPos[1] +07, aCalcPos[2] +03 SAY "4"
   @ aCalcPos[1] +07, aCalcPos[2] +07 SAY "5"
   @ aCalcPos[1] +07, aCalcPos[2] +11 SAY "6"
   @ aCalcPos[1] +07, aCalcPos[2] +15 SAY "-"
   @ aCalcPos[1] +07, aCalcPos[2] +21 SAY "E"
   @ aCalcPos[1] +09, aCalcPos[2] +03 SAY "1"
   @ aCalcPos[1] +09, aCalcPos[2] +07 SAY "2"
   @ aCalcPos[1] +09, aCalcPos[2] +11 SAY "3"
   @ aCalcPos[1] +09, aCalcPos[2] +15 SAY "*"
   @ aCalcPos[1] +09, aCalcPos[2] +20 SAY "C"
   @ aCalcPos[1] +11, aCalcPos[2] +03 SAY "0"
   @ aCalcPos[1] +11, aCalcPos[2] +07 SAY "."
   @ aCalcPos[1] +11, aCalcPos[2] +11 SAY "%"
   @ aCalcPos[1] +11, aCalcPos[2] +15 SAY "/"
   @ aCalcPos[1] +11, aCalcPos[2] +20 SAY "="

   SetColor( "0/7" )

   T_CAL1 := SaveScreen( aCalcPos[1], aCalcPos[2], aCalcPos[3], aCalcPos[4] )

   mxDispEnd()

RETURN( .T. )



STATIC FUNCTION Pop_Key( nCalcKey )

   LOCAL cKey      := Chr( nCalcKey )
   LOCAL cButton   := "( )"
   LOCAL cDisp     := cKey
   LOCAL nColAjust := 0

   LOCAL nRow, nCol

   IF cKey $ "0123456789+-*/.%=CcEe " + Chr( K_ENTER ) + Chr( K_BS )

      DO CASE
         CASE cKey $ "0"            ; nRow := 11 ; nCol := 02
         CASE cKey $ "1"            ; nRow := 09 ; nCol := 02
         CASE cKey $ "2"            ; nRow := 09 ; nCol := 06
         CASE cKey $ "3"            ; nRow := 09 ; nCol := 10
         CASE cKey $ "4"            ; nRow := 07 ; nCol := 02
         CASE cKey $ "5"            ; nRow := 07 ; nCol := 06
         CASE cKey $ "6"            ; nRow := 07 ; nCol := 10
         CASE cKey $ "7"            ; nRow := 05 ; nCol := 02
         CASE cKey $ "8"            ; nRow := 05 ; nCol := 06
         CASE cKey $ "9"            ; nRow := 05 ; nCol := 10
         CASE cKey $ CALC_DIG_POINT ; nRow := 11 ; nCol := 06
         CASE cKey $ CALC_DIG_PER   ; nRow := 11 ; nCol := 10
         CASE cKey $ CALC_DIG_DIV   ; nRow := 11 ; nCol := 14
         CASE cKey $ CALC_DIG_CE    ; nRow := 07 ; nCol := 19 ; cButton := "(C )"  ; cDisp := "E"
         CASE cKey $ CALC_DIG_EQ    ; nRow := 11 ; nCol := 18 ; cButton := "(   )" ; cDisp := "="
         CASE cKey $ CALC_DIG_MUL   ; nRow := 09 ; nCol := 14
         CASE cKey $ CALC_DIG_CLEAR ; nRow := 09 ; nCol := 18 ; cButton := "(   )" ; cDisp := "C"
         CASE cKey $ CALC_DIG_SUB   ; nRow := 07 ; nCol := 14
         CASE cKey $ CALC_DIG_ADD   ; nRow := 05 ; nCol := 14
         CASE cKey $ CALC_DIG_BS    ; nRow := 05 ; nCol := 18 ; cButton := "(   )" ; cDisp := Chr( 27 )
      ENDCASE

      IF Len( cButton ) > 3
         nColAjust := 1
      ENDIF

      @ aCalcPos[1] + nRow, aCalcPos[2] + nCol                SAY cButton COLOR "15/3"
      @ aCalcPos[1] + nRow, aCalcPos[2] + nCol +1 + nColAjust SAY cDisp   COLOR "15/3"

      ThreadSleep( 50 )

      @ aCalcPos[1] + nRow, aCalcPos[2] + nCol                SAY cButton COLOR "0/3"
      @ aCalcPos[1] + nRow, aCalcPos[2] + nCol +1 + nColAjust SAY cDisp   COLOR "9/3"

   ENDIF

RETURN( .T. )



PROCEDURE ProcessTime( lStart, cProcName )

   IF lStart
      cProcTime := Time()
   ELSE
      vDef( @cProcName, "" )
      MsgDlg( "Tempo total do processamento :;;^" + ElapTime( cProcTime, Time() ) + "^" + If( Empty( cProcName ), "", ";(" + cProcName + ")" ) )
   ENDIF

RETURN( NIL )



FUNCTION SendMail( cServer   ,;  // cServer    -> Necessario. Nome IP ou o dominio do servidor de email
                   nPort     ,;  // nPort      -> Opcional.   A porta usada pelo o meu servidor de email
                   uFrom     ,;  // uFrom      -> Necessario. Endereco de email do remetente
                   aTo       ,;  // aTo        -> Necessario. Sequencia de caracteres ou matriz de enderecos de email para enviar o email para
                   aCC       ,;  // aCC        -> Opcional.   Sequencia de caracteres ou matriz de email adresses para CC (Copia do email)
                   aBCC      ,;  // aBCC       -> Opcional.   Sequencia de caracteres ou matriz de email adresses de Cco (copia oculta do email)
                   cBody     ,;  // cBody      -> Opcional.   A mensagem do corpo do email como texto, ou o nome do arquivo da mensagem em HTML para enviar.
                   cSubject  ,;  // cSubject   -> Opcional.   Assunto do email
                   aFiles    ,;  // aFiles     -> Opcional.   Matriz/arquivos de anexos para enviar com o email
                   cUser     ,;  // cUser      -> Necessario. Nome de usuario para o servidor POP3
                   cPass     ,;  // cPass      -> Necessario. Senha para cUser
                   cPopServer,;  // cPopServer -> Necessario. Nome IP ou o dominio do servidor de email POP3
                   nPriority ,;  // nPriority  -> Opcional.   Email de prioridade: 1 = alta, 3 = Normal (padrao), 5 = baixa
                   lRead     ,;  // lRead      -> Opcional.   Se definido como. T., uma solicitacao de confirmacao eh enviada. A configuracao padrao eh .f.
                   lTrace    ,;  // lTrace     -> Opcional.   Se definido como. T., um arquivo de log eh criado (sendmail <nNr>.log). A configuracao padrao eh .f.
                   lPopAuth  ,;  // lPopAuth   -> Opcional.   Sinalizador para indicar que Autentication POP3 eh usado. A configuracao padrao eh. T.
                   lNoAuth   ,;  // lNoAuth    -> Opcional.   Servidores de email que nao precisam de autenticacao smtp
                   nTimeOut  ,;  // nTimeOut   -> Opcional.   Numero de milesimos de segundos a aguarda o envio - Padrao eh 2000(2 segundos)
                   lCheckNet )   // lCheckNet  -> Opcional.   Verifica se a internet esta disponivel antes de enviar o email

   LOCAL lReturn       := .T.
   LOCAL lConnect      := .T.
   LOCAL lConnectPlain := .F.
   LOCAL lAuthLogin    := .F.
   LOCAL lAuthPlain    := .F.
   LOCAL cTmp          := ""
   LOCAL cMimeText     := ""
   LOCAL cTo           := ""
   LOCAL cCC           := ""
   LOCAL cBCC          := ""
   LOCAL aData         := {}

   LOCAL oInMail, cBodyTemp, oUrl, oUrl1, oMail, oAttach, oPop
   LOCAL cAddress, cFile, cFname, cFext, cData, cFrom, cFromName
   LOCAL aThisFile, aHosts, nCount, nSize, nSent

   vDef( @cUser    , ""    )
   vDef( @cPass    , ""    )
   vDef( @nPort    , 25    )
   vDef( @aFiles   , {}    )
   vDef( @nPriority, 3     )
   vDef( @lRead    , .F.   )
   vDef( @lTrace   , .F.   )
   vDef( @lPopAuth , .T.   )
   vDef( @lNoAuth  , .F.   )
   vDef( @nTimeOut , 20000 )
   vDef( @lCheckNet, .F.   )
   
   IF lCheckNet

      InetInit()

      cAddress := "www.maxscalla.com.br"

      aHosts := InetGetHosts( cAddress )

      IF aHosts = NIL
         aHosts := InetGetAlias( cAddress )
      ENDIF

      IF Len( aHosts ) = 0
         aHosts := InetGetAlias( cAddress )
      ENDIF

      InetCleanup()

      IF Len( aHosts ) = 0
         RETURN( .F. )
      ENDIF

   ENDIF

   IF ValType( uFrom ) = "A"
      cFrom     := uFrom[1]
      cFromName := '"' + AllTrim( uFrom[2] ) + '" <' + uFrom[1] + '>'
   ELSE
      cFrom     := uFrom
      cFromName := uFrom
   ENDIF

   cUser := StrTran( cUser, "@", "&at;" )

   IF ! ( ( ".htm" IN Lower( cBody ) .OR. ".html" IN Lower( cBody ) ) .AND. File( cBody ) )

      IF Right(cBody,2) <> HB_OSNewLine()
         cBody += HB_OsNewLine()
      ENDIF

   ENDIF

   // cTo
   IF Valtype( aTo ) = "A"
      IF Len( aTo ) > 1
         FOR EACH cTo IN aTo
            IF HB_EnumIndex() <> 1
               cTmp += cTo + ","
            ENDIF
         NEXT
         cTmp := Left( cTmp, Len( cTmp ) -1 )
      ENDIF
      cTo := aTo[ 1 ]
      IF Len( cTmp ) > 0
         cTo += "," + cTmp
      ENDIF
   ELSE
      cTo := AllTrim( aTo )
   ENDIF

   // CC (Carbon Copy)
   IF Valtype( aCC ) = "A"
      IF Len( aCC ) > 0
         FOR EACH cTmp IN aCC
            cCC += cTmp + ","
         NEXT
         cCC := Left( cCC, Len( cCC ) -1 )
      ENDIF
   ELSE
      cCC := AllTrim( aCC )
   ENDIF

   // BCC (Blind Carbon Copy)
   IF Valtype( aBCC ) = "A"
      IF Len( aBCC ) > 0
         FOR EACH cTmp IN aBCC
            cBCC += cTmp + ","
         NEXT
         cBCC := Left( cBCC, Len( cBCC ) -1 )
      ENDIF
   ELSE
      cBCC := AllTrim( aBCC )
   ENDIF

   IF cPopServer <> NIL .AND. lPopAuth
      TRY
         oUrl1 := tUrl():New( "pop://" + cUser + ":" + cPass + "@" + cPopServer + "/" )
         oUrl1:cUserid := Strtran( cUser, "&at;", "@" )
         opop:= tIPClientpop():New( oUrl1, lTrace )
         IF oPop:Open()
            oPop:Close()
         //ELSE
         //   lReturn := .F.
         ENDIF
      CATCH
         lReturn := .F.
      END
   ENDIF

   IF ! lReturn
      RETURN( .F. )
   ENDIF

   TRY
      oUrl := tUrl():New( "smtp://" + cUser + "@" + cServer + "/" + cTo )
   CATCH
      lReturn := .F.
   END

   IF ! lReturn
      RETURN( .F. )
   ENDIF

   oUrl:nPort   := nPort
   oUrl:cUserid := StrTran( cUser, "&at;", "@" )

   oMail   := tipMail():new()
   oAttach := tipMail():new()
   oAttach:SetEncoder( "7-bit" )

   IF ( ".htm" IN Lower( cBody ) .OR. ".html" IN Lower( cBody ) ) .AND. File( cBody )
      cMimeText := "text/html ; charset=ISO-8859-1"
      oAttach:hHeaders[ "Content-Type" ] := cMimeText
      cBodyTemp := cBody
      cBody     := MemoRead( cBodyTemp ) + Chr( 13 ) + Chr( 10 )
   ELSE
      oMail:hHeaders[ "Content-Type" ] := "text/plain; charset=iso8851"
   ENDIF

   oAttach:SetBody( cBody )
   oMail:Attach( oAttach )
   oUrl:cFile := cTo + If( Empty( cCC ), "", "," + cCC ) + If( Empty( cBCC ), "", "," + cBCC )

   oMail:hHeaders[ "Date" ] := tip_Timestamp()
   oMail:hHeaders[ "From" ] := cFrom

   IF ! Empty( cCC )
      oMail:hHeaders[ "Cc" ] := cCC
   ENDIF
   IF ! Empty( cBCC )
      oMail:hHeaders[ "Bcc" ] := cBCC
   ENDIF

   oMail:setHeader( cSubject, cFromName, cTo )

   TRY
      oInmail := tIPClientsmtp():New( oUrl, lTrace)
   CATCH
      lReturn := .F.
   END

   IF ! lReturn
      RETURN( .F. )
   ENDIF

   oInmail:nConnTimeout := nTimeOut

   IF ! lNoAuth

      IF oInMail:Opensecure()

         DO WHILE .T.
            oInMail:GetOk()
            IF oInMail:cReply = NIL
               EXIT
            ELSEIF "LOGIN" IN oInMail:cReply
               lAuthLogin := .T.
            ELSEIF "PLAIN" IN oInMail:cReply
               lAuthPlain := .T.
            ENDIF
         ENDDO

         IF lAuthLogin
            IF ! oInMail:Auth( cUser, cPass )
               lConnect := .F.
            ELSE
               lConnectPlain := .T.
            ENDIF
         ENDIF

         IF lAuthPlain .AND. ! lConnect
            IF !oInMail:AuthPlain( cUser, cPass )
               lConnect := .F.
            ENDIF
         ELSEIF ! lConnectPlain
            oInmail:Getok()
            lConnect := .F.
         ENDIF

      ELSE

         lConnect := .F.

      ENDIF
   ELSE
      lConnect := .F.
   ENDIF

   IF ! lConnect

      IF !lNoAuth
         oInMail:Close()
      ENDIF

      TRY
         oInmail := tIPClientsmtp():New( oUrl, lTrace)
      CATCH
         lReturn := .F.
      END

      oInmail:nConnTimeout:=nTimeOut

      IF !oInMail:Open()
         lConnect := .F.
         oInmail:Close()
         RETURN( .F. )
      ENDIF

      DO WHILE .T.
         oInMail:GetOk()
         IF oInMail:cReply = NIL
            EXIT
         ENDIF
      ENDDO

   ENDIF

   oInMail:oUrl:cUserid := cFrom
   oMail:hHeaders[ "To" ]      := cTo
   oMail:hHeaders[ "Subject" ] := cSubject

   FOR EACH aThisFile IN AFiles

      IF Valtype( aThisFile ) = "C"
         cFile := aThisFile
         cData := Memoread( cFile ) + Chr( 13 ) + Chr( 10 )
      ELSEIF Valtype( aThisFile ) = "A" .AND. Len( aThisFile ) >= 2
         cFile := aThisFile[ 1 ]
         cData := aThisFile[ 2 ] + Chr( 13 ) + Chr( 10 )
      ELSE
         lReturn := .F.
         EXIT
      ENDIF

      oAttach := TipMail():New()

      HB_FNameSplit( cFile,, @cFname, @cFext )

      IF Lower( cFile ) LIKE ".+\.(vbd|asn|asz|asd|pqi|tsp|exe|sml|ofml)"    .OR. ;
         Lower( cFile ) LIKE ".+\.(pfr|frl|spl|gz||stk|ips|ptlk|hqx|mbd)"    .OR. ;
         Lower( cFile ) LIKE ".+\.(mfp|pot|pps|ppt|ppz|doc|n2p|bin|class)"   .OR. ;
         Lower( cFile ) LIKE ".+\.(lha|lzh|lzx|dbf|cdx|dbt|fpt|ntx|oda)"     .OR. ;
         Lower( cFile ) LIKE ".+\.(axs|zpa|pdf|ai|eps|ps|shw|qrt|rtc|rtf)"   .OR. ;
         Lower( cFile ) LIKE ".+\.(smp|dst|talk|tbk|vmd|vmf|wri|wid|rrf)"    .OR. ;
         Lower( cFile ) LIKE ".+\.(wis|ins|tmv|arj|asp|aabaam|aas|bcpio)"    .OR. ;
         Lower( cFile ) LIKE ".+\.(vcd|chat|cnc|coda|page|z|con|cpio|pqf)"   .OR. ;
         Lower( cFile ) LIKE ".+\.(csh|cu|csm|dcr|dir|dxr|swa|dvi|evy|ebk)"  .OR. ;
         Lower( cFile ) LIKE ".+\.(gtar|hdf|map|phtml|php3|ica|ipx|ips|js)"  .OR. ;
         Lower( cFile ) LIKE ".+\.(latex|bin|mif|mpl|mpire|adr|wlt|nc|cdf)"  .OR. ;
         Lower( cFile ) LIKE ".+\.(npx|nsc|pgp|css|sh||shar|swf|spr|sprite)" .OR. ;
         Lower( cFile ) LIKE ".+\.(sit|sca|sv4cpio|sv4crc|tar|tcl|tex)"      .OR. ;
         Lower( cFile ) LIKE ".+\.(texinfo|texi|tlk|t|tr|roff|man|mems)"     .OR. ;
         Lower( cFile ) LIKE ".+\.(alt|che|ustar|src|xls|xlt|zip|au|snd)"    .OR. ;
         Lower( cFile ) LIKE ".+\.(es|gsm|gsd|rmf|tsi|vox|wtx|aif|aiff)"     .OR. ;
         Lower( cFile ) LIKE ".+\.(aifc|cht|dus|mid|midi|mp3|mp2|m3u|ram)"   .OR. ;
         Lower( cFile ) LIKE ".+\.(ra|rpm|stream|rmf|vqf|vql|vqe|wav|wtx)"   .OR. ;
         Lower( cFile ) LIKE ".+\.(mol|pdb|dwf|ivr|cod|cpi|fif|gif|ief)"     .OR. ;
         Lower( cFile ) LIKE ".+\.(jpeg|jpg|jpe|rip|svh|tiff|tif|mcf|svf)"   .OR. ;
         Lower( cFile ) LIKE ".+\.(dwg|dxf|wi|ras|etf|fpx|fh5|fh4|fhc|dsf)"  .OR. ;
         Lower( cFile ) LIKE ".+\.(pnm|pbm|pgm|ppm|rgb|xbm|xpm|xwd|dig)"     .OR. ;
         Lower( cFile ) LIKE ".+\.(push|wan|waf||afl|mpeg|mpg|mpe|qt|mov)"   .OR. ;
         Lower( cFile ) LIKE ".+\.(viv|vivo|asf|asx|avi|movie|vgm|vgx)"      .OR. ;
         Lower( cFile ) LIKE ".+\.(xdr|vgp|vts|vtts|3dmf|3dm|qd3d|qd3)"      .OR. ;
         Lower( cFile ) LIKE ".+\.(svr|wrl|wrz|vrt)"                         .OR. ;
         Empty( cFExt )
         oAttach:SetEncoder( "base64" )
      ELSE
         oAttach:SetEncoder( "7-bit" )
      ENDIF

      cMimeText := HB_SetMimeType( cFile, cFname, cFext )
      // Some EMAIL readers use Content-Type to check for filename

      IF ( ".html" IN Lower( cFext ) ) .OR. ( ".htm" IN Lower( cFext ) )
         cMimeText += "; charset=ISO-8859-1"
      ENDIF

      oAttach:hHeaders[ "Content-Type" ] := cMimeText
      // But usually, original filename is set here
      oAttach:hHeaders[ "Content-Disposition" ] := "attachment; filename=" + cFname + cFext
      oAttach:SetBody( cData )
      oMail:Attach( oAttach )

   NEXT

   IF lRead
      oMail:hHeaders[ "Disposition-Notification-To" ] := cUser
   ENDIF

   IF nPriority <> 3
      oMail:hHeaders[ "X-Priority" ] := Str( nPriority, 1 )
   ENDIF

   oInmail:Write( oMail:ToString() )

   /*
   cData := oMail:ToString()
   nSize := Len( cData )
   FOR nCount := 1 TO Len( cData ) STEP 1024
      aAdd( aData, Subs( cData, nCount, 1024 ) )
   NEXT
   nSent := 0
   FOR nCount := 1 TO Len( aData )
      nSent += oInmail:Write( aData[ nCount ], Len( aData[ nCount ] ) )
   NEXT
   */
   
   lReturn := oInMail:Commit()
   oInMail:Close()

RETURN( lReturn )



STATIC FUNCTION HB_SetMimeType( cFile, cFname, cFext )

   cFile := Lower( cFile )

   IF     cFile LIKE ".+\.vbd"                         ; RETURN "application/activexdocument="     + cFname + cFext
   ELSEIF cFile LIKE ".+\.(asn|asz|asd)"               ; RETURN "application/astound="             + cFname + cFext
   ELSEIF cFile LIKE ".+\.pqi"                         ; RETURN "application/cprplayer="           + cFname + cFext
   ELSEIF cFile LIKE ".+\.tsp"                         ; RETURN "application/dsptype="             + cFname + cFext
   ELSEIF cFile LIKE ".+\.exe"                         ; RETURN "application/exe="                 + cFname + cFext
   ELSEIF cFile LIKE ".+\.(sml|ofml)"                  ; RETURN "application/fml="                 + cFname + cFext
   ELSEIF cFile LIKE ".+\.pfr"                         ; RETURN "application/font-tdpfr="          + cFname + cFext
   ELSEIF cFile LIKE ".+\.frl"                         ; RETURN "application/freeloader="          + cFname + cFext
   ELSEIF cFile LIKE ".+\.spl"                         ; RETURN "application/futuresplash ="       + cFname + cFext
   ELSEIF cFile LIKE ".+\.gz"                          ; RETURN "application/gzip ="               + cFname + cFext
   ELSEIF cFile LIKE ".+\.stk"                         ; RETURN "application/hstu ="               + cFname + cFext
   ELSEIF cFile LIKE ".+\.ips"                         ; RETURN "application/ips="                 + cFname + cFext
   ELSEIF cFile LIKE ".+\.ptlk"                        ; RETURN "application/listenup ="           + cFname + cFext
   ELSEIF cFile LIKE ".+\.hqx"                         ; RETURN "application/mac-binhex40 ="       + cFname + cFext
   ELSEIF cFile LIKE ".+\.mbd"                         ; RETURN "application/mbedlet="             + cFname + cFext
   ELSEIF cFile LIKE ".+\.mfp"                         ; RETURN "application/mirage="              + cFname + cFext
   ELSEIF cFile LIKE ".+\.(pot|pps|ppt|ppz)"           ; RETURN "application/mspowerpoint ="       + cFname + cFext
   ELSEIF cFile LIKE ".+\.doc"                         ; RETURN "application/msword="              + cFname + cFext
   ELSEIF cFile LIKE ".+\.n2p"                         ; RETURN "application/n2p="                 + cFname + cFext
   ELSEIF cFile LIKE ".+\.(bin|class|lha|lzh|lzx|dbf)" ; RETURN "application/octet-stream ="       + cFname + cFext
   ELSEIF cFile LIKE ".+\.oda"                         ; RETURN "application/oda="                 + cFname + cFext
   ELSEIF cFile LIKE ".+\.axs"                         ; RETURN "application/olescript="           + cFname + cFext
   ELSEIF cFile LIKE ".+\.zpa"                         ; RETURN "application/pcphoto="             + cFname + cFext
   ELSEIF cFile LIKE ".+\.pdf"                         ; RETURN "application/pdf="                 + cFname + cFext
   ELSEIF cFile LIKE ".+\.(ai|eps|ps)"                 ; RETURN "application/postscript="          + cFname + cFext
   ELSEIF cFile LIKE ".+\.shw"                         ; RETURN "application/presentations="       + cFname + cFext
   ELSEIF cFile LIKE ".+\.qrt"                         ; RETURN "application/quest="               + cFname + cFext
   ELSEIF cFile LIKE ".+\.rtc"                         ; RETURN "application/rtc="                 + cFname + cFext
   ELSEIF cFile LIKE ".+\.rtf"                         ; RETURN "application/rtf="                 + cFname + cFext
   ELSEIF cFile LIKE ".+\.smp"                         ; RETURN "application/studiom="             + cFname + cFext
   ELSEIF cFile LIKE ".+\.dst"                         ; RETURN "application/tajima="              + cFname + cFext
   ELSEIF cFile LIKE ".+\.talk"                        ; RETURN "application/talker="              + cFname + cFext
   ELSEIF cFile LIKE ".+\.tbk"                         ; RETURN "application/toolbook ="           + cFname + cFext
   ELSEIF cFile LIKE ".+\.vmd"                         ; RETURN "application/vocaltec-media-desc=" + cFname + cFext
   ELSEIF cFile LIKE ".+\.vmf"                         ; RETURN "application/vocaltec-media-file=" + cFname + cFext
   ELSEIF cFile LIKE ".+\.wri"                         ; RETURN "application/write="               + cFname + cFext
   ELSEIF cFile LIKE ".+\.wid"                         ; RETURN "application/x-DemoShield ="       + cFname + cFext
   ELSEIF cFile LIKE ".+\.rrf"                         ; RETURN "application/x-InstallFromTheWeb=" + cFname + cFext
   ELSEIF cFile LIKE ".+\.wis"                         ; RETURN "application/x-InstallShield="     + cFname + cFext
   ELSEIF cFile LIKE ".+\.ins"                         ; RETURN "application/x-NET-Install="       + cFname + cFext
   ELSEIF cFile LIKE ".+\.tmv"                         ; RETURN "application/x-Parable-Thing="     + cFname + cFext
   ELSEIF cFile LIKE ".+\.arj"                         ; RETURN "application/x-arj="               + cFname + cFext
   ELSEIF cFile LIKE ".+\.asp"                         ; RETURN "application/x-asap="              + cFname + cFext
   ELSEIF cFile LIKE ".+\.aab"                         ; RETURN "application/x-authorware-bin ="   + cFname + cFext
   ELSEIF cFile LIKE ".+\.(aam|aas)"                   ; RETURN "application/x-authorware-map ="   + cFname + cFext
   ELSEIF cFile LIKE ".+\.bcpio"                       ; RETURN "application/x-bcpio="             + cFname + cFext
   ELSEIF cFile LIKE ".+\.vcd"                         ; RETURN "application/x-cdlink ="           + cFname + cFext
   ELSEIF cFile LIKE ".+\.chat"                        ; RETURN "application/x-chat="              + cFname + cFext
   ELSEIF cFile LIKE ".+\.cnc"                         ; RETURN "application/x-cnc="               + cFname + cFext
   ELSEIF cFile LIKE ".+\.(coda|page)"                 ; RETURN "application/x-coda="              + cFname + cFext
   ELSEIF cFile LIKE ".+\.z"                           ; RETURN "application/x-compress="          + cFname + cFext
   ELSEIF cFile LIKE ".+\.con"                         ; RETURN "application/x-connector="         + cFname + cFext
   ELSEIF cFile LIKE ".+\.cpio"                        ; RETURN "application/x-cpio="              + cFname + cFext
   ELSEIF cFile LIKE ".+\.pqf"                         ; RETURN "application/x-cprplayer="         + cFname + cFext
   ELSEIF cFile LIKE ".+\.csh"                         ; RETURN "application/x-csh="               + cFname + cFext
   ELSEIF cFile LIKE ".+\.(cu|csm)"                    ; RETURN "application/x-cu-seeme="          + cFname + cFext
   ELSEIF cFile LIKE ".+\.(dcr|dir|dxr|swa)"           ; RETURN "application/x-director="          + cFname + cFext
   ELSEIF cFile LIKE ".+\.dvi"                         ; RETURN "application/x-dvi="               + cFname + cFext
   ELSEIF cFile LIKE ".+\.evy"                         ; RETURN "application/x-envoy="             + cFname + cFext
   ELSEIF cFile LIKE ".+\.ebk"                         ; RETURN "application/x-expandedbook="      + cFname + cFext
   ELSEIF cFile LIKE ".+\.gtar"                        ; RETURN "application/x-gtar="              + cFname + cFext
   ELSEIF cFile LIKE ".+\.hdf"                         ; RETURN "application/x-hdf="               + cFname + cFext
   ELSEIF cFile LIKE ".+\.map"                         ; RETURN "application/x-httpd-imap ="       + cFname + cFext
   ELSEIF cFile LIKE ".+\.phtml"                       ; RETURN "application/x-httpd-php="         + cFname + cFext
   ELSEIF cFile LIKE ".+\.php3"                        ; RETURN "application/x-httpd-php3 ="       + cFname + cFext
   ELSEIF cFile LIKE ".+\.ica"                         ; RETURN "application/x-ica="               + cFname + cFext
   ELSEIF cFile LIKE ".+\.ipx"                         ; RETURN "application/x-ipix="              + cFname + cFext
   ELSEIF cFile LIKE ".+\.ips"                         ; RETURN "application/x-ipscript="          + cFname + cFext
   ELSEIF cFile LIKE ".+\.js"                          ; RETURN "application/x-javascript ="       + cFname + cFext
   ELSEIF cFile LIKE ".+\.latex"                       ; RETURN "application/x-latex="             + cFname + cFext
   ELSEIF cFile LIKE ".+\.bin"                         ; RETURN "application/x-macbinary="         + cFname + cFext
   ELSEIF cFile LIKE ".+\.mif"                         ; RETURN "application/x-mif="               + cFname + cFext
   ELSEIF cFile LIKE ".+\.(mpl|mpire)"                 ; RETURN "application/x-mpire="             + cFname + cFext
   ELSEIF cFile LIKE ".+\.adr"                         ; RETURN "application/x-msaddr ="           + cFname + cFext
   ELSEIF cFile LIKE ".+\.wlt"                         ; RETURN "application/x-mswallet="          + cFname + cFext
   ELSEIF cFile LIKE ".+\.(nc|cdf)"                    ; RETURN "application/x-netcdf ="           + cFname + cFext
   ELSEIF cFile LIKE ".+\.npx"                         ; RETURN "application/x-netfpx ="           + cFname + cFext
   ELSEIF cFile LIKE ".+\.nsc"                         ; RETURN "application/x-nschat ="           + cFname + cFext
   ELSEIF cFile LIKE ".+\.pgp"                         ; RETURN "application/x-pgp-plugin ="       + cFname + cFext
   ELSEIF cFile LIKE ".+\.css"                         ; RETURN "application/x-pointplus="         + cFname + cFext
   ELSEIF cFile LIKE ".+\.sh"                          ; RETURN "application/x-sh ="               + cFname + cFext
   ELSEIF cFile LIKE ".+\.shar"                        ; RETURN "application/x-shar="              + cFname + cFext
   ELSEIF cFile LIKE ".+\.swf"                         ; RETURN "application/x-shockwave-flash="   + cFname + cFext
   ELSEIF cFile LIKE ".+\.spr"                         ; RETURN "application/x-sprite ="           + cFname + cFext
   ELSEIF cFile LIKE ".+\.sprite"                      ; RETURN "application/x-sprite ="           + cFname + cFext
   ELSEIF cFile LIKE ".+\.sit"                         ; RETURN "application/x-stuffit="           + cFname + cFext
   ELSEIF cFile LIKE ".+\.sca"                         ; RETURN "application/x-supercard="         + cFname + cFext
   ELSEIF cFile LIKE ".+\.sv4cpio"                     ; RETURN "application/x-sv4cpio="           + cFname + cFext
   ELSEIF cFile LIKE ".+\.sv4crc"                      ; RETURN "application/x-sv4crc ="           + cFname + cFext
   ELSEIF cFile LIKE ".+\.tar"                         ; RETURN "application/x-tar="               + cFname + cFext
   ELSEIF cFile LIKE ".+\.tcl"                         ; RETURN "application/x-tcl="               + cFname + cFext
   ELSEIF cFile LIKE ".+\.tex"                         ; RETURN "application/x-tex="               + cFname + cFext
   ELSEIF cFile LIKE ".+\.(texinfo|texi)"              ; RETURN "application/x-texinfo="           + cFname + cFext
   ELSEIF cFile LIKE ".+\.tlk"                         ; RETURN "application/x-tlk="               + cFname + cFext
   ELSEIF cFile LIKE ".+\.(t|tr|roff)"                 ; RETURN "application/x-troff="             + cFname + cFext
   ELSEIF cFile LIKE ".+\.man"                         ; RETURN "application/x-troff-man="         + cFname + cFext
   ELSEIF cFile LIKE ".+\.me"                          ; RETURN "application/x-troff-me="          + cFname + cFext
   ELSEIF cFile LIKE ".+\.ms"                          ; RETURN "application/x-troff-ms="          + cFname + cFext
   ELSEIF cFile LIKE ".+\.alt"                         ; RETURN "application/x-up-alert="          + cFname + cFext
   ELSEIF cFile LIKE ".+\.che"                         ; RETURN "application/x-up-cacheop ="       + cFname + cFext
   ELSEIF cFile LIKE ".+\.ustar"                       ; RETURN "application/x-ustar="             + cFname + cFext
   ELSEIF cFile LIKE ".+\.src"                         ; RETURN "application/x-wais-source="       + cFname + cFext
   ELSEIF cFile LIKE ".+\.xls"                         ; RETURN "application/xls="                 + cFname + cFext
   ELSEIF cFile LIKE ".+\.xlt"                         ; RETURN "application/xlt="                 + cFname + cFext
   ELSEIF cFile LIKE ".+\.zip"                         ; RETURN "application/zip="                 + cFname + cFext
   ELSEIF cFile LIKE ".+\.(au|snd)"                    ; RETURN "audio/basic="                     + cFname + cFext
   ELSEIF cFile LIKE ".+\.es"                          ; RETURN "audio/echospeech ="               + cFname + cFext
   ELSEIF cFile LIKE ".+\.(gsm|gsd)"                   ; RETURN "audio/gsm="                       + cFname + cFext
   ELSEIF cFile LIKE ".+\.rmf"                         ; RETURN "audio/rmf="                       + cFname + cFext
   ELSEIF cFile LIKE ".+\.tsi"                         ; RETURN "audio/tsplayer="                  + cFname + cFext
   ELSEIF cFile LIKE ".+\.vox"                         ; RETURN "audio/voxware="                   + cFname + cFext
   ELSEIF cFile LIKE ".+\.wtx"                         ; RETURN "audio/wtx="                       + cFname + cFext
   ELSEIF cFile LIKE ".+\.(aif|aiff|aifc)"             ; RETURN "audio/x-aiff ="                   + cFname + cFext
   ELSEIF cFile LIKE ".+\.(cht|dus)"                   ; RETURN "audio/x-dspeech="                 + cFname + cFext
   ELSEIF cFile LIKE ".+\.(mid|midi)"                  ; RETURN "audio/x-midi ="                   + cFname + cFext
   ELSEIF cFile LIKE ".+\.mp3"                         ; RETURN "audio/x-mpeg ="                   + cFname + cFext
   ELSEIF cFile LIKE ".+\.mp2"                         ; RETURN "audio/x-mpeg ="                   + cFname + cFext
   ELSEIF cFile LIKE ".+\.m3u"                         ; RETURN "audio/x-mpegurl="                 + cFname + cFext
   ELSEIF cFile LIKE ".+\.(ram|ra)"                    ; RETURN "audio/x-pn-realaudio ="           + cFname + cFext
   ELSEIF cFile LIKE ".+\.rpm"                         ; RETURN "audio/x-pn-realaudio-plugin="     + cFname + cFext
   ELSEIF cFile LIKE ".+\.stream"                      ; RETURN "audio/x-qt-stream="               + cFname + cFext
   ELSEIF cFile LIKE ".+\.rmf"                         ; RETURN "audio/x-rmf="                     + cFname + cFext
   ELSEIF cFile LIKE ".+\.(vqf|vql)"                   ; RETURN "audio/x-twinvq="                  + cFname + cFext
   ELSEIF cFile LIKE ".+\.vqe"                         ; RETURN "audio/x-twinvq-plugin="           + cFname + cFext
   ELSEIF cFile LIKE ".+\.wav"                         ; RETURN "audio/x-wav="                     + cFname + cFext
   ELSEIF cFile LIKE ".+\.wtx"                         ; RETURN "audio/x-wtx="                     + cFname + cFext
   ELSEIF cFile LIKE ".+\.mol"                         ; RETURN "chemical/x-mdl-molfile="          + cFname + cFext
   ELSEIF cFile LIKE ".+\.pdb"                         ; RETURN "chemical/x-pdb="                  + cFname + cFext
   ELSEIF cFile LIKE ".+\.dwf"                         ; RETURN "drawing/x-dwf="                   + cFname + cFext
   ELSEIF cFile LIKE ".+\.ivr"                         ; RETURN "i-world/i-vrml="                  + cFname + cFext
   ELSEIF cFile LIKE ".+\.cod"                         ; RETURN "image/cis-cod="                   + cFname + cFext
   ELSEIF cFile LIKE ".+\.cpi"                         ; RETURN "image/cpi="                       + cFname + cFext
   ELSEIF cFile LIKE ".+\.fif"                         ; RETURN "image/fif="                       + cFname + cFext
   ELSEIF cFile LIKE ".+\.gif"                         ; RETURN "image/gif="                       + cFname + cFext
   ELSEIF cFile LIKE ".+\.ief"                         ; RETURN "image/ief="                       + cFname + cFext
   ELSEIF cFile LIKE ".+\.(jpeg|jpg|jpe)"              ; RETURN "image/jpeg="                      + cFname + cFext
   ELSEIF cFile LIKE ".+\.rip"                         ; RETURN "image/rip="                       + cFname + cFext
   ELSEIF cFile LIKE ".+\.svh"                         ; RETURN "image/svh="                       + cFname + cFext
   ELSEIF cFile LIKE ".+\.(tiff|tif)"                  ; RETURN "image/tiff="                      + cFname + cFext
   ELSEIF cFile LIKE ".+\.mcf"                         ; RETURN "image/vasa="                      + cFname + cFext
   ELSEIF cFile LIKE ".+\.(svf|dwg|dxf)"               ; RETURN "image/vnd="                       + cFname + cFext
   ELSEIF cFile LIKE ".+\.wi"                          ; RETURN "image/wavelet="                   + cFname + cFext
   ELSEIF cFile LIKE ".+\.ras"                         ; RETURN "image/x-cmu-raster="              + cFname + cFext
   ELSEIF cFile LIKE ".+\.etf"                         ; RETURN "image/x-etf="                     + cFname + cFext
   ELSEIF cFile LIKE ".+\.fpx"                         ; RETURN "image/x-fpx="                     + cFname + cFext
   ELSEIF cFile LIKE ".+\.(fh5|fh4|fhc)"               ; RETURN "image/x-freehand ="               + cFname + cFext
   ELSEIF cFile LIKE ".+\.dsf"                         ; RETURN "image/x-mgx-dsf="                 + cFname + cFext
   ELSEIF cFile LIKE ".+\.pnm"                         ; RETURN "image/x-portable-anymap="         + cFname + cFext
   ELSEIF cFile LIKE ".+\.pbm"                         ; RETURN "image/x-portable-bitmap="         + cFname + cFext
   ELSEIF cFile LIKE ".+\.pgm"                         ; RETURN "image/x-portable-graymap ="       + cFname + cFext
   ELSEIF cFile LIKE ".+\.ppm"                         ; RETURN "image/x-portable-pixmap="         + cFname + cFext
   ELSEIF cFile LIKE ".+\.rgb"                         ; RETURN "image/x-rgb="                     + cFname + cFext
   ELSEIF cFile LIKE ".+\.xbm"                         ; RETURN "image/x-xbitmap="                 + cFname + cFext
   ELSEIF cFile LIKE ".+\.xpm"                         ; RETURN "image/x-xpixmap="                 + cFname + cFext
   ELSEIF cFile LIKE ".+\.xwd"                         ; RETURN "image/x-xwindowdump="             + cFname + cFext
   ELSEIF cFile LIKE ".+\.dig"                         ; RETURN "multipart/mixed="                 + cFname + cFext
   ELSEIF cFile LIKE ".+\.push"                        ; RETURN "multipart/x-mixed-replace="       + cFname + cFext
   ELSEIF cFile LIKE ".+\.(wan|waf)"                   ; RETURN "plugin/wanimate="                 + cFname + cFext
   ELSEIF cFile LIKE ".+\.ccs"                         ; RETURN "text/ccs ="                       + cFname + cFext
   ELSEIF cFile LIKE ".+\.(htm|html)"                  ; RETURN "text/html="                       + cFname + cFext
   ELSEIF cFile LIKE ".+\.pgr"                         ; RETURN "text/parsnegar-document="         + cFname + cFext
   ELSEIF cFile LIKE ".+\.txt"                         ; RETURN "text/plain="                      + cFname + cFext
   ELSEIF cFile LIKE ".+\.rtx"                         ; RETURN "text/richtext="                   + cFname + cFext
   ELSEIF cFile LIKE ".+\.tsv"                         ; RETURN "text/tab-separated-values="       + cFname + cFext
   ELSEIF cFile LIKE ".+\.hdml"                        ; RETURN "text/x-hdml="                     + cFname + cFext
   ELSEIF cFile LIKE ".+\.etx"                         ; RETURN "text/x-setext="                   + cFname + cFext
   ELSEIF cFile LIKE ".+\.(talk|spc)"                  ; RETURN "text/x-speech="                   + cFname + cFext
   ELSEIF cFile LIKE ".+\.afl"                         ; RETURN "video/animaflex="                 + cFname + cFext
   ELSEIF cFile LIKE ".+\.(mpeg|mpg|mpe)"              ; RETURN "video/mpeg="                      + cFname + cFext
   ELSEIF cFile LIKE ".+\.(qt|mov)"                    ; RETURN "video/quicktime="                 + cFname + cFext
   ELSEIF cFile LIKE ".+\.(viv|vivo)"                  ; RETURN "video/vnd.vivo="                  + cFname + cFext
   ELSEIF cFile LIKE ".+\.(asf|asx)"                   ; RETURN "video/x-ms-asf="                  + cFname + cFext
   ELSEIF cFile LIKE ".+\.avi"                         ; RETURN "video/x-msvideo="                 + cFname + cFext
   ELSEIF cFile LIKE ".+\.movie"                       ; RETURN "video/x-sgi-movie="               + cFname + cFext
   ELSEIF cFile LIKE ".+\.(vgm|vgx|xdr)"               ; RETURN "video/x-videogram="               + cFname + cFext
   ELSEIF cFile LIKE ".+\.vgp"                         ; RETURN "video/x-videogram-plugin ="       + cFname + cFext
   ELSEIF cFile LIKE ".+\.vts"                         ; RETURN "workbook/formulaone="             + cFname + cFext
   ELSEIF cFile LIKE ".+\.vtts"                        ; RETURN "workbook/formulaone="             + cFname + cFext
   ELSEIF cFile LIKE ".+\.(3dmf|3dm|qd3d|qd3)"         ; RETURN "x-world/x-3dmf="                  + cFname + cFext
   ELSEIF cFile LIKE ".+\.svr"                         ; RETURN "x-world/x-svr="                   + cFname + cFext
   ELSEIF cFile LIKE ".+\.(wrl|wrz)"                   ; RETURN "x-world/x-vrml="                  + cFname + cFext
   ELSEIF cFile LIKE ".+\.vrt"                         ; RETURN "x-world/x-vrt="                   + cFname + cFext
   ENDIF

RETURN( "text/plain;filename=" + cFname + cFext )