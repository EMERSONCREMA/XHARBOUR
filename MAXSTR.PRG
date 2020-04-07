/*

 MaxStr.prg
 Descricao: Funcoes p/ tratamento de strings.

 EMERSON DA SILVA CREMA
 28/03/19 * Implementado em strJoin() a possibilidade de passar no primeiro
            parametro uma array de informacoes de dados de tipos diferentes
            para q sejam unidos.
 27/07/18 * Desenvolvido foneFormata().
 05/10/17 * Alterado foundStr() p/ q seja possivel utilizar matrizes nos
            parametros de valor para procura e campo a ser procurado.
 25/06/14 * Desenvolvido strJoin().
 29/07/13 * Implementado o parametro lTrim em QuotedStr().
 06/03/13 * Implementado o parametro aAux e lSubst em CharRemove().

 DENIS MAZZUCATTO RODRIGUES
 27/12/12 * Desenvolvimento de QuotedStr().
          * Remocao de Invert_String().
 
 EMERSON DA SILVA CREMA
 28/08/12 * Desenvolvimento de foneAjusta().

 DENIS MAZZUCATTO RODRIGUES
 11/03/11 * Alterado conceito de mxDescend().
 02/07/10 * Desenvolvimento de mxDescend().

 EMERSON DA SILVA CREMA
 01/07/10 * Implementado em strNumOnly() o parametro lChrToSpace.
 08/04/09 * Correcao em ZRClear(), pois estava removendo zeros de numeros
            inteiros.
 18/02/08 * Desenvolvimento de strNumOnly().
 05/11/07 * Inclusao de strIns() em foundStr().
          * Invertidos os parametros uStr e cStr de foundStr().
          * Remocao de strIns().
 19/10/07 * Desenvolvimento de strIns().
 31/07/07 * Desenvolvimento de strReplace().
 26/03/07 * Desenvolvimento de ZRClear().
 28/12/05 * Desenvolvimento de ChrCount().
          * Inicio do desenvolvimento.

*/

#include "std.ch"

FUNCTION Plural( cString, nNumero )

   LOCAL cPlural := " "

   IF Abs( nNumero ) <> 1

      IF cString = Upper( cString )
         cPlural := "S"
      ELSE
         cPlural := "s"
      ENDIF

      IF Upper( Right( cString, 1 ) ) = "M"
         cString := Left( cString, Len( cString ) -1 ) + If( cPlural = "S", "N", "s" )
      ENDIF

   ENDIF

RETURN( cString + cPlural )



FUNCTION TiraEspacos( cCampo )

   DO WHILE At( Space(2), cCampo ) > 0

      cCampo := StrTran( cCampo, Space(2), Space(1) )

   ENDDO

RETURN( cCampo )



FUNCTION foundStr( uStrValue, uStrSearch, lUpper )

   LOCAL lFound := .F.
   LOCAL nCount, aStrValue, nValue, cValue

   vDef( @lUpper   , .F. )
   vDef( @uStrValue, ""  )
   
   IF ValType( uStrValue ) = "C"
      aStrValue := { uStrValue }
   ELSE
      aStrValue := uStrValue
   ENDIF
   
   FOR nValue := 1 TO Len( aStrValue )
   
      cValue := aStrValue[ nValue ]

      IF ValType( uStrSearch ) = "C"

         IF Left( uStrSearch, 1 ) <> "|"
            uStrSearch := "|" + uStrSearch
         ENDIF

         IF Right( uStrSearch, 1 ) <> "|"
            uStrSearch += "|"
         ENDIF

         IF Empty( cValue )

            cValue := "|" + cValue + "|"

         ELSE

            IF Left( cValue, 1 ) <> "|"
               cValue := "|" + cValue
            ENDIF

            IF Right( cValue, 1 ) <> "|"
               cValue += "|"
            ENDIF

         ENDIF

         IF lUpper
            uStrSearch := Upper( uStrSearch )
            cValue     := Upper( cValue )
         ENDIF

         lFound := cValue $ uStrSearch

      ELSE

         FOR nCount := 1 TO Len( uStrSearch )
            IF lUpper
               lFound := Upper( cValue ) $ Upper( uStrSearch[ nCount ] )
            ELSE
               lFound := cValue $ uStrSearch[ nCount ]
            ENDIF
            IF lFound
               EXIT
            ENDIF
         NEXT

      ENDIF
      
   NEXT

RETURN( lFound )



FUNCTION Invert_String( cString )

   LOCAL cReturn := InverseString( cString )

RETURN( cReturn )



FUNCTION QuotedStr( cString, lTrim )

   vDef( @lTrim, .F. )
   
   IF lTrim
      cString := Trim( cString )
   ENDIF

RETURN( "'" + cString + "'" )



FUNCTION ClearMasc( cString, cChars )

   LOCAL cStrNew := ""
   LOCAL nCount, cChr

   FOR nCount := 1 TO Len( cString )

      cChr := Subs( cString, nCount, 1 )

      IF ! cChr $ If( cChars = NIL, "-()", cChars )
         cStrNew += cChr
      ENDIF

   NEXT

   IF Subs( cStrNew, 5, 1 ) <> " " .AND. cChars = NIL  // Utilizado p/ telefone
      cStrNew := Left( cStrNew, 4 ) + " " + Subs( cStrNew, 5 )
   ENDIF

RETURN( cStrNew )



FUNCTION CapFirst( cString )

   LOCAL cReturn := ""
   LOCAL cStrAux := ""
   LOCAL nSpace  := Len( cString )

   cString := Lower( Trim( cString ) ) + " "

   DO WHILE Len( cString ) > 0

      cStrAux := Left( cString, At( " ", cString ) )
      cString := Subs( cString, Len( cStrAux ) +1 )

      IF Len( Trim( cStrAux ) ) < 3 .OR. ( Len( Trim( cStrAux ) ) = 3 .AND. foundStr( Trim( cStrAux ), "das|dos" ) )
         cReturn += cStrAux
      ELSE
         cReturn += Upper( Left( cStrAux, 1 ) ) + Subs( cStrAux, 2 )
      ENDIF

   ENDDO

RETURN( PadR( cReturn, nSpace ) )



FUNCTION CharRemove( cString, nType, aAux, lSubst )

   LOCAL cReturn, cChr, aChr, nCount, nPos

   vDef( @nType, 2 )

   DO WHILE nType <= 2

      cReturn := ""

      IF nType = 1  // Acentuacao Windows

         aChr := { ;
                   "ç‡","õ”","ã„","ô“","ó¢","é‚","êˆ","á " ;
                 }
      ELSE

         aChr := { ;
                   "€C","u","‚e","ƒa","„a","…a","†a","‡c","ˆe","‰e","Še",;
                   "‹i","Œi","i","ŽA","A","E","‘_","’_","“o","”o","•o",;
                   "–u","—u","˜Y","™O","šU","›o","œL","0","žx","Ÿf"," a",;
                   "¡i","¢o","£u","¤n","¥N","¦a","§o","¨_","©R","ª_","«_",;
                   "¬_","­_","®<","¯>","°|","±|","²|","³|","´|","µA","¶A",;
                   "·A","¸C","¹|","º|","»|","¼|","½c","¾_","¿|","À|","Á|",;
                   "Â|","Ã|","Ä-","Å|","Æa","ÇA","È|","É|","Ê|","Ë|","Ì|",;
                   "Í|","Î|","Ïo","Ðo","ÑD","ÒE","ÓE","ÔE","Õ1","ÖI","×I",;
                   "ØI","Ù|","Ú|","Û|","Ü|","Ý|","ÞI","ß|","àO","áB","âO",;
                   "ãO","äo","åO","æu","çp","èp","éU","êU","ëU","ìy","íy",;
                   "î_","ï'","ð-","ñ_","ò=","ó_","ôT","õS","ö:","÷,","øo",;
                   "ù'","ú.","û1","ü3","ý2","þ|","úu","£u",Chr(255) +"_"  ;
                 }
      ENDIF

      IF aAux <> NIL
         IF lSubst <> NIL .AND. lSubst
            aChr := aAux
         ELSE
            FOR nCount := 1 TO Len( aAux )
               nPos := aScan( aChr, { |x| Left( x, 1 ) = Left( aAux[ nCount ], 1 ) } )
               IF nPos = 0
                  aAdd( aChr, aAux[ nCount ] )
               ELSE
                  aChr[ nPos ] := aAux[ nCount ]
               ENDIF
            NEXT
         ENDIF
      ENDIF

      FOR nCount := 1 TO Len( cString )

         cChr := Subs( cString, nCount, 1 )

         nPos := aScan( aChr, { |x| Left( x, 1 ) = cChr } )
         IF nPos > 0
            cReturn += Right( aChr[ nPos ], 1 )
         ELSE
            cReturn += cChr
         ENDIF

      NEXT

      cString := cReturn

      nType ++

   ENDDO

RETURN( cReturn )



FUNCTION InverseString( cString )

   LOCAL cReturn := ""
   LOCAL nCount

   FOR nCount := Len( cString ) TO 1 STEP -1
      cReturn += Subs( cString, nCount, 1 )
   NEXT

RETURN( cReturn )



FUNCTION Ini_String( cStr )

   LOCAL cReturn := ""

   LOCAL nCount, cStrAux

   cStr := " " + cStr

   FOR nCount := 1 TO Len( cStr )

      cStrAux := Subs( cStr, nCount +1, 1 )

      IF Subs( cStr, nCount, 1 ) $ " ./" .AND. ( IsAlpha( cStrAux ) .OR. IsDigit( cStrAux ) )
         cReturn += cStrAux
      ENDIF

   NEXT

RETURN( cReturn )



/*----------------------------------------------------------------------------
 Alinha e justifica o texto de uma string ou campo memo.

 Parametros

 cText : String ou campo memo.
 nLin  : Linha inicial para impressao do texto formatado.
 nCol  : Coluna inicial para impressao do texto formatado.
 nLen  : Tamanho da linha desejada para formatacao.
----------------------------------------------------------------------------*/

FUNCTION mxJustifica( cText, nLin, nCol, nLen )

  LOCAL cTxtImp := AllTrim( cText )
  LOCAL cLinTxt := ""
  LOCAL nOcorr  := 1
  LOCAL nNumLin

  vDef( @nLin, 000 )
  vDef( @nCol, 000 )
  vDef( @nLen, 080 )

  FOR nNumLin := 1 TO MlCount( cTxtImp )

     cLinTxt := AllTrim( MemoLine( cText, nLen, nNumLin, NIL, .T. ) )

     IF nNumLin < MlCount( cTxtImp )

        DO WHILE Len( AllTrim( cLinTxt ) ) < nLen

           nOcorr  := nLen - Len( AllTrim( cLinTxt ) )
           cLinTxt := StrTran( cLinTxt, " ", "  ", NIL, nOcorr )

        ENDDO

     ENDIF

     @ nLin, nCol SAY cLinTxt

     nLin += 2

  NEXT

  SetPos( nLin, nCol )

RETURN( .T. )



// Remove os zeros a esquerda da string.

FUNCTION ZLClear( cString )

   cString := AllTrim( cString )

   DO WHILE ( Left( cString, 1 ) = "0" ) .AND. ( Len( cString ) > 1 ) .AND. ( ! Subs( cString, 2, 1 ) $ ",." )
      cString := Subs( cString, 2 )
   ENDDO

RETURN( cString )



// Remove os zeros a direita da string.

FUNCTION ZRClear( cString )

   cString := AllTrim( cString )

   IF "." $ cString

      DO WHILE Right( cString, 1 ) = "0" .AND. Len( cString ) > 1
         cString := Left( cString, Len( cString ) -1 )
      ENDDO

      IF Right( cString, 1 ) $ ".,"
         cString := Left( cString, Len( cString ) -1 )
      ENDIF

   ENDIF

RETURN( cString )



FUNCTION ChrCount( cString, cChr, lUpper )

   LOCAL nReturn := 0
   LOCAL nCount

   vDef( @lUpper, .T. )

   IF lUpper
      cString := Upper( cString )
      cChr    := Upper( cChr )
   ENDIF

   FOR nCount := 1 TO Len( cString )
      IF Subs( cString, nCount, 1 ) = cChr
         nReturn ++
      ENDIF
   NEXT

RETURN( nReturn )



FUNCTION strReplace( cStr, aStr, uRpl )

   LOCAL nCount

   FOR nCount := 1 TO Len( aStr )
      IF uRpl = NIL
         cStr := StrTran( cStr, aStr[ nCount, 1 ], aStr[ nCount, 2 ] )
      ELSEIF ValType( uRpl ) = "C"
         cStr := StrTran( cStr, aStr[ nCount ], uRpl )
      ELSE
         cStr := StrTran( cStr, aStr[ nCount ], uRpl[ nCount ] )
      ENDIF
   NEXT

RETURN( cStr )



FUNCTION strNumOnly( cStr, lChrToSpace )

   LOCAL cReturn := ""

   LOCAL nCount, cChr

   vDef( @lChrToSpace, .F. )

   FOR nCount := 1 TO Len( cStr )
      cChr := Subs( cStr, nCount, 1 )
      IF cChr $ "0123456789"
         cReturn += cChr
      ELSEIF lChrToSpace
         cReturn += " "
      ENDIF
   NEXT

RETURN( cReturn )



FUNCTION mxDescend( cStr )

   #define DESC_ASC "|4890|4989|5088|5187|5286|5385|5484|5583|5682" + ;
                    "|5781|6580|6679|6778|6877|6976|7075|7174|7273" + ;
                    "|7372|7471|7570|7669|7768|7867|7966|8065|8157" + ;
                    "|8256|8355|8454|8553|8652|8751|8850|8949|9048"

   LOCAL cReturn := ""

   LOCAL nAux, nCount, nPos

   FOR nCount := 1 TO Len( cStr )

      nAux := Asc( Subs( cStr, nCount, 1 ) )

      nPos := At( "|" + StrZero( nAux, 2 ), DESC_ASC )

      IF nPos = 0
         cReturn += Chr( nAux )
      ELSE
         cReturn += Chr( Val( Subs( DESC_ASC, nPos +3, 2 ) ) )
      ENDIF

    NEXT

RETURN( cReturn )



FUNCTION foneAjusta( cFone, nLen )

   IF nLen = NIL
      IF Len( cFone ) = 12
         nLen := 8
      ELSEIF Len( cFone ) = 13
         nLen := 9
      ELSE
         nLen := 8
      ENDIF
   ENDIF

   cFone := PadL( AllTrim( Left( cFone, 4 ) ), 4 ) + PadL( AllTrim( Right( cFone, nLen ) ), nLen )
   
RETURN( cFone )



FUNCTION strJoin( uStr, cJoin, cSep )

   LOCAL cStr := ""
   LOCAL nStr

   vDef( @cSep, " - " )

   IF ValType( uStr ) = "A"
   
      FOR nStr := 1 TO Len( uStr )
         IF nStr > 1
            cStr += cSep
         ENDIF
         cStr += UtoC( uStr[ nStr ] )
      NEXT
   
   ELSE

      IF ! Empty( cSep ) .AND. ! Empty( uStr ) .AND. ! Empty( cJoin )
         uStr += cSep
      ENDIF

      IF ! Empty( cJoin )
         uStr += cJoin
      ENDIF
      
      cStr := uStr
      
   ENDIF

RETURN( cStr )



FUNCTION foneFormata( cFone )

   LOCAL nTamOri := Len( cFone )
   LOCAL cFonOri := cFone
   LOCAL nTam

   IF ! Empty( cFone )

      IF StrTran( cFone, " ", "" ) = strNumOnly( cFone )

         cFone := strNumOnly( cFone )

         IF Len( cFone ) > 9 .AND. Left( cFone, 1 ) = "0"
            cFone := ZLClear( cFone )
         ENDIF

         DO CASE
            CASE Len( cFone ) = 8  ; cFone := Left( cFone, 4 ) + "-" + Right( cFone, 4 )
            CASE Len( cFone ) = 9  ; cFone := Left( cFone, 5 ) + "-" + Right( cFone, 4 )
            CASE Len( cFone ) = 10 ; cFone := "(" + Left( cFone, 2 ) + ")" + Subs( cFone, 3, 4 ) + "-" + Right( cFone, 4 )
            CASE Len( cFone ) = 11 ; cFone := "(" + Left( cFone, 2 ) + ")" + Subs( cFone, 3, 5 ) + "-" + Right( cFone, 4 )
            OTHERWISE
                 cFone := cFonOri
         ENDCASE

         cFone := PadR( cFone, nTamOri )

      ENDIF

   ENDIF

RETURN( cFone )