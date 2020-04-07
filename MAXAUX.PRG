/*

 MaxArq.prg
 Descricao: Biblioteca de funcoes de auxiliares.
 Desenvolvido por MAX SCALLA Informatica Ltda.

 EMERSON DA SILVA CREMA
 09/01/19 * Inicio do desenvolvimento.

*/

#include "std.ch"
#include "inkey.ch"


//*** Funcoes para tratamento de numeros de enderecos ***

FUNCTION getNumEnd( cNum, cEnd, cDefNum, cCpl )

   #define _NRO Chr(167)

   LOCAL nAux, cAux, nChr, cNumAux, cCplAux

   IF cDefNum <> NIL .AND. ! Empty( cDefNum )

      cNum := cDefNum

   ELSE

      cNum := ""

      IF ! getNumEnd_aux( ",", @cEnd, @cNum, @cCpl )
         IF ! getNumEnd_aux( " N.", @cEnd, @cNum, @cCpl )
            getNumEnd_aux( " N" + _NRO, @cEnd, @cNum, @cCpl )
         ENDIF
      ENDIF

      IF Empty( cNum )

         IF IsDigit( Right( Trim( cEnd ), 1 ) )

            cEnd := Trim( cEnd )
            FOR nAux := Len( cEnd ) TO 1 STEP -1
               cAux := Subs( cEnd, nAux, 1 )
               IF ! IsDigit( cAux ) .AND. ! cAux $ "/.\"
                  EXIT
               ENDIF
               cNum := cAux + cNum
            NEXT
            IF Val( cNum ) = 0
               cNum := ""
            ELSE
               cEnd := Left( cEnd, Len( cEnd ) - Len( cNum ) )
            ENDIF

         ENDIF

         IF Empty( cNum )
            IF foundStr( Right( Trim( cEnd ), 3 ), "S/N|S\N" )
               cNum := "S/N"
               cEnd := Left( cEnd, Len( Trim( cEnd ) ) - 3 )
            ELSEIF foundStr( Right( Trim( cEnd ), 4 ), "S/N" + _NRO + "|S\N" + _NRO )
               cNum := "S/N"
               cEnd := Left( cEnd, Len( Trim( cEnd ) ) - 4 )
            ENDIF
         ENDIF

      ENDIF

      IF ! Empty( cNum )
         cEnd := Trim( cEnd )
         IF Right( cEnd, 3 ) $ " N.| N" + _NRO
            cEnd := Left( cEnd, Len( cEnd ) -3 )
         ENDIF
      ENDIF

      cNum := AllTrim( cNum )

      IF Left( cNum, 1 ) = "."
         cNum := Subs( cNum, 2 )
      ENDIF

   ENDIF

RETURN( cNum )



STATIC FUNCTION getNumEnd_aux( cDiv, cEnd, cNum, cCpl )

   LOCAL lReturn := .F.

   LOCAL nAux, nChr, cNumAux, cCplAux

   IF ! Empty( cNum )

      lReturn := .T.

   ELSE

      nAux := At( cDiv, cEnd )

      IF nAux <> 0

         cNumAux := AllTrim( Subs( cEnd, nAux + Len( cDiv ) ) )
         cCplAux := ""

         FOR nChr := 1 TO Len( cNumAux )
            cAux := Subs( cNumAux, nChr, 1 )
            IF ( ( cAux $ "0123456789." ) .OR. ( IsDigit( Left( cNum, 1 ) ) .AND. cAux $ "ABCDEFGHIJKLMNOPQRSTUVXWYZ-" ) ) .AND. Len( cCplAux ) = 0
               cNum += cAux
            ELSE
               cCplAux += cAux
            ENDIF
         NEXT

         IF ! Empty( cNum )
            cEnd := Left( cEnd, nAux - 1 )
            IF ! Empty( cCplAux )
               IF cCpl = NIL
                  cEnd := Trim( cEnd ) + " - " + cCplAux
               ELSE
                  cCpl := AllTrim( Trim( cCpl ) + " " + cCplAux )
                  IF Left( cCpl, 1 ) = "-"
                     cCpl := AllTrim( Subs( cCpl, 2 ) )
                  ENDIF
               ENDIF
            ENDIF
            lReturn := .T.
         ENDIF

      ENDIF

   ENDIF

RETURN( lReturn )

//*** Fim das funcoes para tratamento de numeros de enderecos ***