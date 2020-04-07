/*

 MaxData.prg
 Descricao: Biblioteca de funcoes de data.
 Desenvolvido por MAX SCALLA Informatica Ltda.

 EMERSON DA SILVA CREMA
 31/03/14 * Implementado o parametro lAcentuado em StrMes().
 22/10/07 * Desenvolvimento de mxVerData().
 03/04/07 * Implementado parametro lUpper em StrMes() e em SelSemana().
 08/09/06 * Desenvolvimento de SDate().
 08/08/06 * Desenvolvimento de StoD(). Faz o processo inverso de DtoS().
 07/08/06 * Desenvolvimento de AddYear().

*/

#include "std.ch"
#include "inkey.ch"

FUNCTION FD( cDate, cFormat4, cYear )

   LOCAL cReturn := Left( cDate, 2 ) + "." + Subs( cDate, 3, 2 ) + "."

   IF cFormat4 = "S"
      cReturn += Right( cDate, 4 )
   ELSE
      cReturn += cYear + Right( cDate, 2 )
   ENDIF

RETURN( cReturn )
                                                  


FUNCTION DefDate( dDateDef, cFormat4, cYear )

   LOCAL lReturn := .T.
   LOCAL dDateRet

   IF ( dDateDef <> NIL ) .AND. Empty( dDateDef )

      dDateRet := Calendario( cFormat4 = "S" )

      IF cFormat4 = "2"
         SET CENT OFF
      ELSE
         SET CENT ON
      ENDIF

      IF ESC
         dDateDef := Space( If( cFormat4 = "S", 8, 6 ) )
         lReturn  := .F.
      ELSE
         dDateDef := Subs( DtoC( dDateRet ), 1, 2 ) + ;
                     Subs( DtoC( dDateRet ), 4, 2 ) + ;
                     Subs( DtoC( dDateRet ), 7    )

         IF cFormat4 = "N"
            cYear := Left( Str( Year( dDateRet ), 4 ), 2 )
         ENDIF
      ENDIF

   ENDIF

RETURN( lReturn )



FUNCTION V_Data( dData )

   LOCAL dReturn := If( Dow( dData ) = 1, dData +1,;
                    If( Dow( dData ) = 7, dData +2,;
                                          dData ) )

RETURN( dReturn )



FUNCTION YearTwo( dDate )

   LOCAL cReturn := Left( DtoC( dDate ), 6 ) + Right( DtoC( dDate ), 2 )

RETURN( cReturn )



FUNCTION VerifyDate( cData )

   LOCAL lReturn

   IF ! Empty( Left( cData, 2 ) )
      cData := StrZero( Val( Left( cData, 2 ) ), 2 ) + StrZero( Val( Right( cData, 2 ) ), 2 )
   ENDIF

   DO CASE
      CASE Val( Left( cData, 2 ) ) = 0 .AND. Val( Right( cData, 2 ) ) = 0
           lReturn := .F.
      CASE Right( cData, 2 ) $ "02*04*06*09*11"
           lReturn := If( Right( cData, 2 ) $ "02", Val( Left( cData, 2 ) ) < 30, Val( Left( cData, 2 ) ) < 31 ) .AND. Val( Left( cData, 2 ) ) > 0
      OTHERWISE
           lReturn := Val( Right( cData, 2 ) ) < 13 .AND. Val( Right( cData, 2 ) ) > 0 .AND. Val( Left( cData, 2 ) ) < 32 .AND. Val( Left( cData, 2 ) ) > 0
   ENDCASE

RETURN( lReturn )



FUNCTION VerDat( DATINI )

   DATFIM := ( DATINI + 31 ) - Day( DATINI + 31 )

RETURN( .T. )




FUNCTION mxVerData( DATINI, DATFIM )

   &DATFIM := ( &DATINI + 31 ) - Day( &DATINI + 31 )

RETURN( .T. )



FUNCTION StrMes( uData, lUpper, lAcentuado )

   LOCAL cReturn := ""
   LOCAL nMes    := If( ValType( uData ) = "N", uData, Month( uData ) )

   vDef( @lUpper    , .T. )
   vDef( @lAcentuado, .F. )

   DO CASE
      CASE nMes = 1  ; cReturn := "Janeiro"
      CASE nMes = 2  ; cReturn := "Fevereiro"
      CASE nMes = 3  ; cReturn := If( lAcentuado, "Mar‡o", "Marco" )
      CASE nMes = 4  ; cReturn := "Abril"
      CASE nMes = 5  ; cReturn := "Maio"
      CASE nMes = 6  ; cReturn := "Junho"
      CASE nMes = 7  ; cReturn := "Julho"
      CASE nMes = 8  ; cReturn := "Agosto"
      CASE nMes = 9  ; cReturn := "Setembro"
      CASE nMes = 10 ; cReturn := "Outubro"
      CASE nMes = 11 ; cReturn := "Novembro"
      CASE nMes = 12 ; cReturn := "Dezembro"
   ENDCASE

   IF lUpper
      cReturn := Upper( cReturn )
   ENDIF

RETURN( cReturn )



FUNCTION SelMes( uData )

   LOCAL cReturn := StrMes( uData, .F. )

RETURN( cReturn )



FUNCTION SelSemana( dData, lUpper )

   LOCAL nDia    := Dow( dData )
   LOCAL cReturn := ""

   vDef( @lUpper, .F. )

   DO CASE
      CASE nDia = 1 ; cReturn := "Domingo"
      CASE nDia = 2 ; cReturn := "Segunda"
      CASE nDia = 3 ; cReturn := "Terca  "
      CASE nDia = 4 ; cReturn := "Quarta "
      CASE nDia = 5 ; cReturn := "Quinta "
      CASE nDia = 6 ; cReturn := "Sexta  "
      CASE nDia = 7 ; cReturn := "Sabado "
   ENDCASE

   IF lUpper
      cReturn := Upper( cReturn )
   ENDIF

RETURN( cReturn )



/*----------------------------------------------------------------------------
 Converte uma data para caracter no formato definido.

 Parametros

 dDate   : Data para conversao.
 cFormat : Formato desejado.
           DD   - Dia
           MM   - Mes
           AA   - Ano com dois digitos.
           AAAA - Ano com quatro digitos.

 Retorno : String no formato selecionado.

 Exemplo :

 Data -> 01.03.2000
 FDate( data, "AAAAMMDD" ) -> "20000301"
                               ³   ³ À> dia
                               ³   ÀÄÄ> mes
                               ÀÄÄÄÄÄÄ> ano ( 4 digitos )

 FDate( data, "DDMMAA", "/" ) -> "01/03/00"
                                  ³  ³  À> ano ( 2 digitos )
                                  ³  ÀÄÄÄ> mes
                                  ÀÄÄÄÄÄÄ> dia
----------------------------------------------------------------------------*/

FUNCTION FDate( dDate, cFormat, cSeparator, lEmpty )

   #DEFINE DefSep( cDate, cStr, cSep )  cDate := If( !Empty( cSep ), StrTran( cDate, cStr, cStr + " " ), cDate )

   LOCAL lCentury := ( Len( DtoC( dDate ) ) = 10 )
   LOCAL cDay     := ""
   LOCAL cMonth   := ""
   LOCAL cYear    := ""
   LOCAL cDate    := ""
   LOCAL cConf    := ""

   LOCAL lSetConsole, lSetCentury, nDay, nMonth, nYear, nCount
   LOCAL cYear4, cYear2, cChr

   vDef( @cSeparator, ""  )
   vDef( @lEmpty    , .F. )

   cFormat := Upper( AllTrim( cFormat ) )

   cDate := cFormat

   IF ! lCentury
      lSetConsole := Set( _SET_CONSOLE, .F. )
      lSetCentury := __SetCentury(.T.)
   ENDIF

   cYear4 := StrZero( Year( dDate ), 4 )

   IF ! lCentury
      __SetCentury( lSetConsole )
      Set( _SET_CONSOLE, lSetConsole )
   ENDIF

   cYear2 := Right( cYear4, 2 )

   nDay   := At( "DD", cFormat )
   nMonth := At( "MM", cFormat )
   nYear  := At( "AA", cFormat )

   IF nDay <> 0
      cDay  := StrZero( Day( dDate ), 2 )
      cConf += cDay
      cDate := DefSep( cDate, "DD", cSeparator )
      cDate := StrTran( cDate, "DD", cDay )
   ENDIF

   IF nMonth <> 0
      cMonth := StrZero( Month( dDate ), 2 )
      cConf  += cMonth
      cDate  := DefSep( cDate, "MM", cSeparator )
      cDate  := StrTran( cDate, "MM", cMonth )
   ENDIF

   IF nYear <> 0
      cYear := cYear2
      IF At( "AAAA", cFormat ) = 0
         cDate := DefSep( cDate, "AA", cSeparator )
         cDate := StrTran( cDate, "AA", cYear )
      ELSE
         cYear := cYear4
         cDate := DefSep( cDate, "AAAA", cSeparator )
         cDate := StrTran( cDate, "AAAA", cYear )
      ENDIF
      cConf += cYear
   ENDIF

   cDate := RTrim( cDate )
   IF ! Empty( cSeparator )
      cDate := StrTran( cDate, " ", cSeparator )
   ENDIF

   IF lEmpty
      IF Len( cConf ) > 0 .AND. cConf = Repl( "0", Len( cConf ) )
         cDate := StrTran( cDate, "0", " " )
      ENDIF
   ENDIF

RETURN( cDate )



FUNCTION AddYear( dDate, nYears )

   IF Year( dDate ) + nYears <= 2999
      dDate := AddMonth( dDate, nYears * 12 )
   ELSE
      dDate := CtoD( fDate( dDate, "DD/MM/" ) + "2999" )
   ENDIF

RETURN( dDate )


/*
FUNCTION AddMonth( dData, nMeses )

   LOCAL nDia      := Day( dData )
   LOCAL nMes      := Month( dData )
   LOCAL nAno      := Val( Subs( DtoC( dData ), 7, 4 ) )
   LOCAL dNovaData := CtoD("")

   LOCAL nCountDia

   IF nMeses > 0
      FOR nCountDia := 1 TO nMeses
         IF ++ nMes > 12
            nMes := 1
            nAno++
         ENDIF
      NEXT
   ELSE
      nMeses =- nMeses
      FOR nCountDia := 1 TO nMeses
         IF -- nMes < 1
            nMes := 12
            nAno--
         ENDIF
      NEXT
   ENDIF
   FOR nCountDia := nDia TO 1 STEP -1
      dNovaData := CtoD( StrZero( nCountDia, 2 ) + "/" + StrZero( nMes, 2 ) + "/" + StrZero( nAno, 4 ) )
      IF ! empty( dNovaData )
         EXIT
      ENDIF
   NEXT

RETURN( If( Empty( dNovaData ), CtoD( StrZero( nDia, 2 ) + "/" + StrZero( nMes, 2 ) + "/2999" ), dNovaData ) )
*/



FUNCTION StoD( cDate )

   cDate := CtoD( Right( cDate, 2 ) + "." + Subs( cDate, 5, 2 ) + "." + Left( cDate, 4 ) )

RETURN( cDate )