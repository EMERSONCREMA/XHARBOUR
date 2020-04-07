/*

 MaxValid.prg
 Descricao: Biblioteca de funcoes de validacao.
 Desenvolvido por MAX SCALLA Informatica Ltda.
 
 EMERSON DA SILVA CREMA
 14/12/18 * Desenvolvido:
            - GTIN_PrefixoValido()
            - GTIN_Valido()
            - GTIN_CalcularDV()
 22/08/16 * Alterado o parametro 1 de mxContido() p/ q utilize matrizes.
 26/08/13 * Desenvolvida funcao mxTimeValid().

 DENIS MAZZUCATTO RODRIGUES
 30/08/12 * Desenvolvimento de FilesCheck().
 09/12/09 * Implementacao de CardCheck().

 EMERSON DA SILVA CREMA
 19/12/06 * Implementado parametro cMsg em mxContido().
 07/10/05 * Mudada forma de verificacao em IsEqual().
 01/09/05 * Desenvolvimento de IsEqual().

 DENIS MAZZUCATTO RODRIGUES
 20/05/05 * Desenvolvimento de mxContido() e mxVldCnpj().

 EMERSON DA SILVA CREMA
 04/02/05 * Alteracao em vNumero(), pois qdo o parametro cNumero era vazio,
            retornava .T.
 01/10/04 * Implementacao de ValStr() em mxMax().

*/

#include "std.ch"
#include "inkey.ch"

#define GTIN_PrefixIni 1
#define GTIN_PrefixFim 2
#define GTIN_indEsp    3
#define GTIN_PaisNome  4


FUNCTION VNumero( cNumero )

   LOCAL nNumero

   cNumero := AllTrim( cNumero )

   IF Empty( cNumero )
      RETURN( .F. )
   ENDIF

   FOR nNumero := 1 TO Len( cNumero )
      IF ! Subs( cNumero, nNumero, 1 ) $ "0123456789."
         RETURN( .F. )
      ENDIF
   NEXT

RETURN( .T. )



FUNCTION mxEmpty( ;        // Verifica se um campo esta vazio, e informa q deve ser digitado.
                  uInfo,;  // Valor
                  cMsg ;   // Mensagem adicional
                )

   LOCAL lReturn := .F.

   BEGIN SEQUENCE

      IF ! Empty( uInfo )
         BREAK
      ENDIF

      vDef( @cMsg, "" )
      
      #ifdef MINIGUI_MODE
         IF IsDef( "CS_MINIGUI" ) .AND. CS_MINIGUI
            cMsg := "O preenchimento deste campo é obrigatório." + NoEmpty( cMsg, NIL, ";;" )
            MsgDlg( cMsg, NIL, "ALERT" )
            lReturn := .T.
            BREAK
         ENDIF
      #endif

      cMsg := "O preenchimento deste campo;‚ obrigat¢rio !" + NoEmpty( cMsg, NIL, ";;" )
      MsgDlg( cMsg )
      lReturn := .T.

   ENDSEQUENCE

RETURN( lReturn )



FUNCTION mxConfNum( nNum, lEmpty, cMsg )

   // Verifica se um numero e valido.

   vDef( @lEmpty, .F. )

   IF lEmpty
      IF nNum < 0
         vDef( @cMsg, "Este campo n„o pode ser menor; que 0 (zero) !" )
         MsgDlg( cMsg )
         RETURN(.F.)
      ENDIF
   ELSEIF nNum <= 0
      vDef( @cMsg, "Este campo deve ser maior; que 0 (zero) !" )
      MsgDlg( cMsg )
      RETURN(.F.)
   ENDIF

RETURN(.T.)



FUNCTION mxMin( nValue, nMin, cMsg )

   // Retorna .F. se for uma valor menor do que o informado.

   LOCAL lReturn := .T.

   IF ValType( nMin ) = "D"
      IF nValue < nMin
         vDef( @cMsg, "A data n„o pode ser menor que;" + DtoC( nMin ) + " !" )
         lReturn := .F.
      ENDIF
   ELSEIF ValType( nMin ) = "C"
      IF nValue < nMin
         vDef( @cMsg, "O valor n„o pode ser menor que;" + nMin + " !" )
         lReturn := .F.
      ENDIF
   ELSEIF ValStr( nValue ) < ValStr( nMin )
      vDef( @cMsg, "O valor n„o pode ser menor que ^" + ZRClear( NumToStr( nMin ) ) + "^ !" )
      lReturn := .F.
   ENDIF

   IF ! lReturn
      MsgDlg( cMsg )
   ENDIF

RETURN( lReturn )



FUNCTION mxMax( nValue, uMax, cMsg, lVerEmpty )

   // Retorna .F. se for uma valor maior do que o informado.

   LOCAL lReturn := .T.

   vDef( @lVerEmpty, .F. )

   IF ValType( uMax ) = "D"
      IF nValue > uMax
         vDef( @cMsg, "A data n„o pode ser maior que;" + DtoC( uMax ) + " !" )
         lReturn := .F.
      ENDIF
   ELSEIF ValType( uMax ) = "C"
      IF nValue > uMax
         vDef( @cMsg, "O valor n„o pode ser maior que;" + uMax + " !" )
         lReturn := .F.
      ENDIF
   ELSEIF ValStr( nValue ) > ValStr( uMax )
      vDef( @cMsg, "O valor n„o pode ser maior que ^" + ZRClear( NumToStr( uMax ) ) + "^ !" )
      lReturn := .F.
   ENDIF

   IF ! lReturn
      MsgDlg( cMsg )
   ELSEIF lVerEmpty
      lReturn := ! mxEmpty( nValue )
   ENDIF

RETURN( lReturn )



FUNCTION mxIntervalo( uValue, uMin, uMax, uMsg )

   LOCAL cMin, cMax, cMsg, bValid

   vDef( @uMsg, .T. )

   IF uMax = NIL
      bValid := { || uValue < uMin }
   ELSE
      bValid := { || uValue < uMin .OR. uValue > uMax }
   ENDIF

   IF Eval( bValid )

      IF ValType( uMsg ) = "C" .OR. uMsg

         DO CASE
            CASE ValType( uMsg ) = "C"
                 cMsg := uMsg
            CASE ValType( uValue ) = "C"
                 cMin := AllTrim( uMin )
                 IF uMax = NIL
                    cMsg := "Vocˆ n„o pode informar um valor;menor que " + cMin + " !"
                 ELSE
                    cMax := AllTrim( uMax )
                    cMsg := "O campo informado deve ser;maior ou igual a " + cMin + ";e menor ou igual a " + cMax + " !"
                 ENDIF
            CASE ValType( uValue ) = "N"
                 IF uMax = NIL
                    cMin := ZRClear( NumToStr( uMin ) )
                    cMsg := "Vocˆ n„o pode informar um valor menor que ^" + cMin + "^ !"
                 ELSE
                    cMin := ZRClear( NumToStr( Min( uMin, uMax ) ) )
                    cMax := ZRClear( NumToStr( Max( uMin, uMax ) ) )
                    cMsg := "O valor informado deve ser;maior ou igual a ^" + cMin + "^ e menor ou igual a ^" + cMax + "^ !"
                 ENDIF
            CASE ValType( uValue ) = "D"
                 IF uMax = NIL
                    cMin := DtoC( uMin )
                    cMsg := "Vocˆ n„o pode informar uma data;menor que " + cMin + " !"
                 ELSE
                    cMin := DtoC( Min( uMin, uMax ) )
                    cMax := DtoC( Max( uMin, uMax ) )
                    cMsg := "O data informada deve ser;maior ou igual a " + cMin + ";e menor ou igual a " + cMax + " !"
                 ENDIF
            OTHERWISE
                 cMsg := "O campo informado est  fora;do intervalo permitido !"
         ENDCASE

         MsgDlg( cMsg )

      ENDIF

      RETURN( .F. )

   ENDIF

RETURN( .T. )



FUNCTION mxVldSN( cVar )

   IF ! Upper( cVar ) $ "SN"
      MsgDlg( 'Informe "S" para Sim e "N" para N„o !' )
      RETURN( .F. )
   ENDIF

RETURN( .T. )



FUNCTION mxContido( uStr1, cStr2, cMsg )

   LOCAL lReturn, nCount

   FOR nCount := 1 TO Len( uStr1 )

      IF ValType( uStr1 ) = "C"
         lReturn := ( At( Subs( uStr1, nCount, 1 ), cStr2 ) > 0 )
      ELSE
         lReturn := foundStr( uStr1[ nCount ], cStr2 )
      ENDIF

      IF lReturn
         EXIT
      ENDIF

   NEXT

   IF ( cMsg <> NIL ) .AND. ! lReturn
      MsgDlg( cMsg )
   ENDIF

RETURN( lReturn )



FUNCTION mxCompara( uVar, uVal )

   LOCAL lReturn := .F.

   IF uVar <> NIL

      IF ValType( uVal ) = "B"
         lReturn := Eval( uVal )
      ELSE
         lReturn := ( uVar == uVal )
      ENDIF

   ENDIF

RETURN( lReturn )



FUNCTION mxVldCnpj( cDoc, cCheck )

   LOCAL lReturn := .F.
   LOCAL cCnpj   := AllTrim( Clear_CPF( cDoc ) )
   LOCAL nLen    := Len( cDoc )
   LOCAL lMask   := mxContido( "./-", cDoc )

   LOCAL nCount, nRest, nDig1, nDig2, DF4, DF5, DF6

   vDef( @cCheck, "S" )

   BEGIN SEQUENCE
                            // Pais = Chile.
      IF cCheck <> "S" .OR. IsValue( "CFICPACTR", 1589 )
         lReturn := .T.
         BREAK
      ENDIF

      IF Empty( cCnpj )
         lReturn := .T.
         BREAK
      ENDIF

      IF IsCnpj( cCnpj )

         // Verificacao do CNPJ - ( Cadastro Nacional de Pessoas Juridicas )

         IF Empty( Left( cDoc, 3 ) )
            lReturn := .T.
            BREAK
         ELSEIF Len( AllTrim( cCnpj ) ) <> 14
            BREAK
         ENDIF

         lReturn := ( Subs( cCnpj, 13, 1 ) = Mod11( Left( cCnpj, 12 ) ) )

         IF lReturn
            lReturn := ( Right( cCnpj, 1 ) = Mod11( Left( cCnpj, 13 ) ) )
         ENDIF

         IF ! lReturn
            cDoc := Left( cCnpj, 12 )
            cDoc += Mod11( cDoc )
            cDoc += Mod11( cDoc )
            IF lMask
               cDoc := Tran( cDoc, "@R 99.999.999/9999-99" )
            ENDIF
            cDoc := PadR( cDoc, nLen )
         ENDIF

         BREAK

      ENDIF

      IF Len( cCnpj ) < 11
         BREAK
      ENDIF

      // Verificacao do CPF - ( Cadastro de Pessoas Fisicas )

      FOR nCount := 1 TO 9
         D    := "0" + Str( nCount, 1 )
         D2&D := Val( Subs( cCnpj, nCount, 1 ) )
      NEXT

      DF4 := 10 * D201 + ;
              9 * D202 + ;
              8 * D203 + ;
              7 * D204 + ;
              6 * D205 + ;
              5 * D206 + ;
              4 * D207 + ;
              3 * D208 + ;
              2 * D209

      DF5 := DF4 / 11
      DF6 := Int( DF5 ) * 11

      nRest := DF4 - DF6
      nDig1 := If( mxIn( nRest, { 0, 1 } ), 0, 11 - nRest )

      FOR nCount := 1 TO 9
         D    := "0" + Str( nCount, 1 )
         D2&D := Val( Subs( cCnpj, nCount, 1 ) )
      NEXT

      DF4 := 11 * D201 + ;
             10 * D202 + ;
              9 * D203 + ;
              8 * D204 + ;
              7 * D205 + ;
              6 * D206 + ;
              5 * D207 + ;
              4 * D208 + ;
              3 * D209 + ;
              2 * nDig1

      DF5 := DF4 / 11
      DF6 := Int( DF5 ) * 11

      nRest := DF4 - DF6
      nDig2 := If( mxIn( nRest, { 0, 1 } ), 0, 11 - nRest )

      lReturn := ( Subs( cCnpj, 10, 2 ) = Str( nDig1, 1 ) + Str( nDig2, 1 ) )

      IF ! lReturn
         cDoc := Left( cCnpj, 9 ) + Str( nDig1, 1 ) + Str( nDig2, 1 ) + Subs( cCnpj, 12 )
         IF lMask
            cDoc := Tran( cDoc, "@R 999.999.999-99" )
         ENDIF
         cDoc := PadR( cDoc, nLen )
      ENDIF

   ENDSEQUENCE

RETURN( lReturn )



FUNCTION IsCnpj( cDoc )
   
   LOCAL lReturn := ! IsValue( "CFICPACTR", 1589 ) .AND. ( Len( AllTrim( Clear_CPF( cDoc ) ) ) > 11 )

RETURN( lReturn )



FUNCTION IsEqual( uVar1, uVar2 )

   // Valido apenas p/ o tipo numerico.

   LOCAL lReturn := Left( Str( uVar1, 19, 4 ), 18 ) == Left( Str( uVar2, 19, 4 ), 18 )

RETURN( lReturn )



FUNCTION IsMsg( lValid, cMsg )

   IF lValid
      MsgDlg( cMsg )
   ENDIF

RETURN( lValid )



FUNCTION CardCheck( cNumCar )

   LOCAL nReturn := -1  // Numero invalido
   LOCAL nDig    := 0

   LOCAL nCount, nAux, cNumAux

   BEGIN SEQUENCE

      IF ValType( cNumCar ) <> "C"
         BREAK
      ELSEIF Left( cNumCar, 1 ) = "0"
         BREAK
      ENDIF

      cNumCar := AllTrim( cNumCar )

      IF Len( cNumCar ) < 16
         cNumAux := Repl( "0", 16 - Len( cNumCar ) ) + cNumCar
      ELSE
         cNumAux := cNumCar
      ENDIF

      FOR nCount := 1 TO 15 STEP 2

         nAux := Val( Subs( cNumAux, nCount, 1 ) ) * 2

         IF nAux > 9
            nDig += ( 1 + nAux % 10 )
         ELSE
            nDig += nAux
         ENDIF

      NEXT

      FOR nCount := 2 TO 16 STEP 2
         nDig += Val( Subs( cNumAux, nCount, 1 ) )
      NEXT

      IF nDig = 0 .OR. ( nDig % 10 <> 0 )
         BREAK
      ENDIF

      cNumAux := Left( cNumCar, 2 )

      IF foundStr( cNumAux, "34|37" )

         nReturn := 1  // American Express

      ELSEIF cNumAux = "36"

         nReturn := 6  // Diners Club

      ELSEIF cNumAux = "38"

         IF Subs( cNumCar, 3, 1 ) = "9"
            nReturn := 5  // Carte Blanche
         ELSE
            nReturn := 6  // Diners Club
         ENDIF

      ELSEIF foundStr( cNumAux, "31|33|35" )

         cNumAux := Left( cNumCar, 6 )

         IF ( cNumAux >= "311200" .AND. cNumAux <= "312099" ) .OR. ;
            ( cNumAux >= "315800" .AND. cNumAux <= "315999" ) .OR. ;
            ( cNumAux >= "333700" .AND. cNumAux <= "334999" ) .OR. ;
            ( cNumAux >= "352800" .AND. cNumAux <= "358999" )

            nReturn := 7  // JCB

         ENDIF

      ELSEIF cNumAux = "30"

         nReturn := 6  // Diners Club
         cNumAux := Left( cNumCar, 6 )

         IF ( cNumAux >= "308800" .AND. cNumAux <= "309499" ) .OR. ;
            ( cNumAux >= "309600" .AND. cNumAux <= "310299" )

            nReturn := 7  // JCB

         ENDIF

      ELSEIF Left( cNumAux, 1 ) = "4"

         nReturn := 2  // Visa

      ELSEIF cNumAux >= "51" .AND. cNumAux <= "55"

         nReturn := 3  // MasterCard

      ELSEIF cNumAux = "60" .AND. Subs( cNumCar, 3, 2 ) = "11"

         nReturn := 4  // Discover

      ELSEIF Left( cNumAux, 1 ) = "9"

         nReturn := 5  // Carte Blanche

      ELSE

         nReturn := 0  // Cartao desconhecido

      ENDIF

   ENDSEQUENCE

RETURN( nReturn )



FUNCTION ConfDate( cDate, lEmpty )

   LOCAL lReturn := .F.
   LOCAL cConf

   vDef( @lEmpty, .F. )

   BEGIN SEQUENCE

      IF Empty( Left( cDate, 2 ) )
         cDate   := "  .    "
         lReturn := lEmpty
         BREAK
      ENDIF

      IF Empty( Right( cDate, 4 ) )
         cDate := Left( cDate, 3 ) + "." + FDate( Date(), "AAAA" )
      ENDIF

      cDate := StrZero( Val( Left( cDate, 2 ) ), 2 ) + "." + Right( cDate, 4 )

      cConf := "01." + cDate

      IF Empty( CtoD( cConf ) )
         BREAK
      ENDIF

      cDate := FDate( CtoD( cConf ), "MM.AAAA" )

      lReturn := .T.

   ENDSEQUENCE

RETURN( lReturn )



FUNCTION FilesCheck( aFiles, lMsg )

   LOCAL cNotFound := ""

   vDef( @lMsg, .T. )

   IF ValType( aFiles ) = "C"
      aFiles := { aFiles }
   ENDIF
   
   aEval( aFiles, { |x| If( File( x ), NIL, cNotFound += ";" + x ) } )
   
   IF lMsg .AND. ! Empty( cNotFound )
      MsgDlg( "^Arquivo(s) n„o encontrado(s)^;" + cNotFound )
   ENDIF

RETURN( Empty( cNotFound ) )



FUNCTION mxTimeValid( cTime, lEmpty, lMsg )

   vDef( @lEmpty, .F. )
   vDef( @lMsg  , .T. )
   
   IF lEmpty .AND. Empty( StrTran( cTime, ":", "" ) )
      RETURN(.T.)
   ENDIF
   
   IF ! TimeValid( cTime )
      IF lMsg
         MsgDlg( "A hora informada n„o ‚ v lido !" )
      ENDIF
      RETURN(.F.)
   ENDIF
   
RETURN(.T.)



/**************** Validacao GTIN ****************/

/*

   * GTIN-8          ( 8 digitos )
   * GTIN-12         ( 12 digitos )
   * GTIN-13         ( 13 digitos )
   * GTIN-14         ( 14 digitos )
   * GSIN            ( 17 digitos )
   * SSCC            ( 18 digitos )

   Como calcular um digito de verificacao manualmente

   Formato da chave de ID   Posicoes dos digitos

   GTIN-8  ................                                                   N1   N2   N3   N4   N5   N6   N7   N8
   GTIN-12 ................                               N1   N2   N3   N4   N5   N6   N7   N8   N9   N10  N11  N12
   GTIN-13 ................                          N1   N2   N3   N4   N5   N6   N7   N8   N9   N10  N11  N12  N13
   GTIN-14 ................                     N1   N2   N3   N4   N5   N6   N7   N8   N9   N10  N11  N12  N13  N14
   GSIN    ................      N1   N2   N3   N4   N5   N6   N7   N8   N9   N10  N11  N12  N13  N14  N15  N16  N17
   SSCC    ................ N1   N2   N3   N4   N5   N6   N7   N8   N9   N10  N11  N12  N13  N14  N15  N16  N17  N18

   Etapa 1 : multiplique o valor de cada posicao por

      Posicao:  1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17
               x3   x1   x3   x1   x3   x1   x3   x1   x3   x1   x3   x1   x3   x1   x3   x1   x3

   Etapa 2 : adicionar resultados juntos para criar uma soma

   Etapa 3 : subtraia a soma do multiplo de dez ou mais proximo do digito igual ou superior


   A tabela a seguir fornece um exemplo para ilustrar
   como um digito de verificacaão GTIN-13 e calculado (6291041500213):


   Posicoes (Numero sem digito de verificacao)

               N1    N2     N3     N4     N5     N6     N7     N8     N9     N10    N11    N12  N13

               6     2      9      1      0      4      1      5      0      0      2      1

   Etapa 1 : multiplicar

               x1    x3     x1     x3     x1     x3     x1     x3     x1     x3     x1     x3

               = 6   = 6    = 9    = 3    = 0    = 12   = 1    = 15   = 0    = 0    = 2    = 3

   Etapa 2 : criar soma

               6 + 6  + 9 + 3 + 0 + 12 + 1 + 15 + 0 + 0 + 2 + 3   =   57

   Etapa 3 : Subtraia a soma do multiplo mais proximo igual ou superior de dez

               60- 57 = 3 (Digito de Verificacao)

               Digito de Verificacao = 3

   Numero com digito de verificacao:

               6291041500213

*/


FUNCTION GTIN_PrefixoValido( cGTIN, cMsgErro )

   #define ARRAY_PREFIX_GTIN { ;
                               { 000, 019, 0, "GS1 US"                                               },;
                               { 020, 029, 1, "Numeros de circulacao restrita dentro da regiao"      },;
                               { 030, 039, 0, "GS1 US"                                               },;
                               { 040, 049, 1, "GS1 Numeros de circulacao restrita dentro da empresa" },;
                               { 050, 059, 1, "GS1 US reserved for future use"                       },;
                               { 060, 139, 0, "GS1 US"                                               },;
                               { 200, 299, 1, "GS1 Numeros de circulacao restrita dentro da regiao"  },;
                               { 300, 379, 0, "GS1 France"                                           },;
                               { 380, 380, 0, "GS1 Bulgaria"                                         },;
                               { 383, 383, 0, "GS1 Slovenija"                                        },;
                               { 385, 385, 0, "GS1 Croatia"                                          },;
                               { 387, 387, 0, "GS1 BIH (Bosnia-Herzegovina)"                         },;
                               { 389, 389, 0, "GS1 Montenegro"                                       },;
                               { 400, 440, 0, "GS1 Germany"                                          },;
                               { 450, 459, 0, "GS1 Japan"                                            },;
                               { 490, 499, 0, "GS1 Japan"                                            },;
                               { 460, 469, 0, "GS1 Russia"                                           },;
                               { 470, 470, 0, "GS1 Kyrgyzstan"                                       },;
                               { 471, 471, 0, "GS1 Taiwan"                                           },;
                               { 474, 474, 0, "GS1 Estonia"                                          },;
                               { 475, 475, 0, "GS1 Latvia"                                           },;
                               { 476, 476, 0, "GS1 Azerbaijan"                                       },;
                               { 477, 477, 0, "GS1 Lithuania"                                        },;
                               { 478, 478, 0, "GS1 Uzbekistan"                                       },;
                               { 479, 479, 0, "GS1 Sri Lanka"                                        },;
                               { 480, 480, 0, "GS1 Philippines"                                      },;
                               { 481, 481, 0, "GS1 Belarus"                                          },;
                               { 482, 482, 0, "GS1 Ukraine"                                          },;
                               { 483, 483, 0, "GS1 Turkmenistan"                                     },;
                               { 484, 484, 0, "GS1 Moldova"                                          },;
                               { 485, 485, 0, "GS1 Armenia"                                          },;
                               { 486, 486, 0, "GS1 Georgia"                                          },;
                               { 487, 487, 0, "GS1 Kazakstan"                                        },;
                               { 488, 488, 0, "GS1 Tajikistan"                                       },;
                               { 489, 489, 0, "GS1 Hong Kong"                                        },;
                               { 500, 509, 0, "GS1 UK"                                               },;
                               { 520, 521, 0, "GS1 Association Greece"                               },;
                               { 528, 528, 0, "GS1 Lebanon"                                          },;
                               { 529, 529, 0, "GS1 Cyprus"                                           },;
                               { 530, 530, 0, "GS1 Albania"                                          },;
                               { 531, 531, 0, "GS1 Macedonia"                                        },;
                               { 535, 535, 0, "GS1 Malta"                                            },;
                               { 539, 539, 0, "GS1 Ireland"                                          },;
                               { 540, 549, 0, "GS1 Belgium & Luxembourg"                             },;
                               { 560, 560, 0, "GS1 Portugal"                                         },;
                               { 569, 569, 0, "GS1 Iceland"                                          },;
                               { 570, 579, 0, "GS1 Denmark"                                          },;
                               { 590, 590, 0, "GS1 Poland"                                           },;
                               { 594, 594, 0, "GS1 Romania"                                          },;
                               { 599, 599, 0, "GS1 Hungary"                                          },;
                               { 600, 601, 0, "GS1 South Africa"                                     },;
                               { 603, 603, 0, "GS1 Ghana"                                            },;
                               { 604, 604, 0, "GS1 Senegal"                                          },;
                               { 608, 608, 0, "GS1 Bahrain"                                          },;
                               { 609, 609, 0, "GS1 Mauritius"                                        },;
                               { 611, 611, 0, "GS1 Morocco"                                          },;
                               { 613, 613, 0, "GS1 Algeria"                                          },;
                               { 615, 615, 0, "GS1 Nigeria"                                          },;
                               { 616, 616, 0, "GS1 Kenya"                                            },;
                               { 618, 618, 0, "GS1 Ivory Coast"                                      },;
                               { 619, 619, 0, "GS1 Tunisia"                                          },;
                               { 620, 620, 0, "GS1 Tanzania"                                         },;
                               { 621, 621, 0, "GS1 Syria"                                            },;
                               { 622, 622, 0, "GS1 Egypt"                                            },;
                               { 623, 623, 0, "GS1 Brunei"                                           },;
                               { 624, 624, 0, "GS1 Libya"                                            },;
                               { 625, 625, 0, "GS1 Jordan"                                           },;
                               { 626, 626, 0, "GS1 Iran"                                             },;
                               { 627, 627, 0, "GS1 Kuwait"                                           },;
                               { 628, 628, 0, "GS1 Saudi Arabia"                                     },;
                               { 629, 629, 0, "GS1 Emirates"                                         },;
                               { 640, 649, 0, "GS1 Finland"                                          },;
                               { 690, 699, 0, "GS1 China"                                            },;
                               { 700, 709, 0, "GS1 Norway"                                           },;
                               { 729, 729, 0, "GS1 Israel"                                           },;
                               { 730, 739, 0, "GS1 Sweden"                                           },;
                               { 740, 740, 0, "GS1 Guatemala"                                        },;
                               { 741, 741, 0, "GS1 El Salvador"                                      },;
                               { 742, 742, 0, "GS1 Honduras"                                         },;
                               { 743, 743, 0, "GS1 Nicaragua"                                        },;
                               { 744, 744, 0, "GS1 Costa Rica"                                       },;
                               { 745, 745, 0, "GS1 Panama"                                           },;
                               { 746, 746, 0, "GS1 Republica Dominicana"                             },;
                               { 750, 750, 0, "GS1 Mexico"                                           },;
                               { 754, 755, 0, "GS1 Canada"                                           },;
                               { 759, 759, 0, "GS1 Venezuela"                                        },;
                               { 760, 769, 0, "GS1 Schweiz; Suisse; Svizzera"                        },;
                               { 770, 771, 0, "GS1 Colombia"                                         },;
                               { 773, 773, 0, "GS1 Uruguay"                                          },;
                               { 775, 775, 0, "GS1 Peru"                                             },;
                               { 777, 777, 0, "GS1 Bolivia"                                          },;
                               { 778, 779, 0, "GS1 Argentina"                                        },;
                               { 780, 780, 0, "GS1 Chile"                                            },;
                               { 784, 784, 0, "GS1 Paraguay"                                         },;
                               { 786, 786, 0, "GS1 Ecuador"                                          },;
                               { 789, 790, 0, "GS1 Brasil"                                           },;
                               { 800, 839, 0, "GS1 Italy"                                            },;
                               { 840, 849, 0, "GS1 Spain"                                            },;
                               { 850, 850, 0, "GS1 Cuba"                                             },;
                               { 858, 858, 0, "GS1 Slovakia"                                         },;
                               { 859, 859, 0, "GS1 Czech"                                            },;
                               { 860, 860, 0, "GS1 Serbia"                                           },;
                               { 865, 865, 0, "GS1 Mongolia"                                         },;
                               { 867, 867, 0, "GS1 North Korea"                                      },;
                               { 868, 869, 0, "GS1 Turkey"                                           },;
                               { 870, 879, 0, "GS1 Netherlands"                                      },;
                               { 880, 880, 0, "GS1 South Korea"                                      },;
                               { 884, 884, 0, "GS1 Cambodia"                                         },;
                               { 885, 885, 0, "GS1 Thailand"                                         },;
                               { 888, 888, 0, "GS1 Singapore"                                        },;
                               { 890, 890, 0, "GS1 India"                                            },;
                               { 893, 893, 0, "GS1 Vietnam"                                          },;
                               { 896, 896, 0, "GS1 Pakistan"                                         },;
                               { 899, 899, 0, "GS1 Indonesia"                                        },;
                               { 900, 919, 0, "GS1 Austria"                                          },;
                               { 930, 939, 0, "GS1 Australia"                                        },;
                               { 940, 949, 0, "GS1 New Zealand"                                      },;
                               { 950, 950, 1, "GS1 Global Office"                                    },;
                               { 951, 951, 1, "Numeracao para EPC Tag Data Standard"                 },;
                               { 955, 955, 0, "GS1 Malaysia"                                         },;
                               { 958, 958, 0, "GS1 Macau"                                            },;
                               { 960, 969, 1, "Global Office (GTIN-8s)"                              },;
                               { 977, 977, 1, "Serial publications (ISSN)"                           },;
                               { 978, 979, 1, "Bookland (ISBN)"                                      },;
                               { 980, 980, 1, "Refund receipts"                                      },;
                               { 981, 984, 1, "GS1 Coupon identification for common currency areas"  },;
                               { 990, 999, 1, "GS1 Coupon identification"                            } ;
                             }

   LOCAL nCount, nPrefixo, cPrefixo

   cMsgErro := ""
   
   cGTIN := AllTrim( cGTIN )

   IF GTIN_Valido( cGTIN, @cMsgErro )

      cPrefixo := Left( cGTIN, 3 )
      nPrefixo := Val( cPrefixo )

      IF aScan( ARRAY_PREFIX_GTIN, { |x| ( nPrefixo >= x[ GTIN_PrefixIni ] ) .AND. ( nPrefixo <= x[ GTIN_PrefixFim ] ) } ) = 0
         cMsgErro := "Prefixo " +  cPrefixo + " do GTIN " + cGTIN + " informado inv lido"
      ENDIF

   ENDIF
   
RETURN( Empty( cMsgErro ) )



FUNCTION GTIN_Valido( cGTIN, cMsgErro, lExibeDigitoCorreto )

   LOCAL lReturn := .F.

   LOCAL cDigOriginal, cDigCalculado, cCodigo

   vDef( @lExibeDigitoCorreto, .T. )

   cMsgErro := ""

   cGTIN := AllTrim( cGTIN )

   BEGIN SEQUENCE

      IF ! IsDigit( cGTIN )
         cMsgErro := "C¢digo GTIN inv lido, o c¢digo GTIN deve conter somente numeros."
         BREAK
      ENDIF

      IF ! mxIn( Len( cGTIN ), { 8, 12, 13, 14, 17, 18 } )
         cMsgErro := "C¢digo GTIN inv lido, o c¢digo GTIN deve ter 8, 12, 13 ou 14 caracteres."
         BREAK
      ENDIF

      cCodigo       := Left( cGTIN, Len( cGTIN ) - 1 )
      cDigOriginal  := Right( cGTIN, 1 )
      cDigCalculado := GTIN_CalcularDV( cCodigo )

      IF cDigOriginal <> cDigCalculado

         cMsgErro := "Digito do c¢digo GTIN " + cGTIN + " inv lido."

         IF lExibeDigitoCorreto
            cMsgErro += " (O correto ‚ : " + cDigCalculado + ")"
         ENDIF

         BREAK

      ENDIF

      lReturn := .T.

   ENDSEQUENCE

RETURN( lReturn )



FUNCTION GTIN_CalcularDV( cGTIN )

   LOCAL cReturn := ""
   // aMult Considerando o maior GTIN valido, de 18 posicoes, menos digito (SSCC)
   LOCAL aMult   := { 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3 }
   LOCAL nDV     := 0
   
   LOCAL nDig, nCount

   cGTIN := PadL( AllTrim( cGTIN ), Len( aMult ), "0" )

   FOR nCount := 1 TO Len( cGTIN )

      nDig := Val( Subs( cGTIN, nCount, 1 ) )
      nDV  += ( nDig * aMult[ nCount ] )

   NEXT

   nDV := ( Ceiling( nDV / 10 ) * 10 ) - nDV

   cReturn := NumToStr( nDV )

RETURN( cReturn )