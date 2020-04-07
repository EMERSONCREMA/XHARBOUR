/*

 MaxFunBD.prg
 Descricao: Biblioteca de funcoes de banco de dados.
 Desenvolvido por MAX SCALLA Informatica Ltda.

 EMERSON DA SILVA CREMA
 20/10/05 * Implementacao de DefCod().
 05/08/05 * Correcoes em XmlToDbf(), pois ficava em loop.
          * Corrigido tb a duplicidade de campos.
 18/07/05 * Implementacao de mxOpen() em fanInicio().
 20/06/05 * Desenvolvimento de XmlToDbf().
          * Alteracao em fanInicio() p/ gerar o CDX e fanFim() p/ apaga-lo.

 DENIS MAZZUCATTO RODRIGUES
 17/06/05 * Desenvolvimento de AbreviaNome().

 EMERSON DA SILVA CREMA
 14/06/05 * Desenvolvimento de fanInicio(), fanFim() e fanAjusta().
          * Inicio do desenvolvimento.

*/

#include "std.ch"

STATIC nFanControle := 0
STATIC cFanControle := ""

FUNCTION fanInicio()

   LOCAL lReturn

   mxClose( "FAN" )
   mxFDel( "FAN.CDX" )

   DbCreate( "FAN.DBF", { { "FAN", "C", 15, 0 } }, "DBFCDX" )

   mxOpen( 0, "FAN.DBF", NIL, "DBFCDX", .F. )
   INDEX ON FAN TO FAN

   lReturn := ( Select( "FAN" ) > 0 )

   nFanControle := 0
   cFanControle := ""

RETURN( lReturn )



FUNCTION fanFim()

   mxClose( "FAN" )

   mxFDel( { "FAN.DBF", "FAN.CDX" } )

RETURN( NIL )



FUNCTION fanAjusta( cDefFan )

   LOCAL cControle

   nFanControle := 0

   DO WHILE .T.

      cFanControle := AllTrim( cDefFan )

      IF nFanControle <> 0

         cControle    := NumToStr( nFanControle )
         cFanControle := AllTrim( cFanControle )

         IF Len( cFanControle ) + Len( cControle ) >= 15
            cFanControle := Left( cFanControle, 14 - Len( cControle ) )
         ENDIF

         cFanControle += " " + cControle

         cFanControle := PadR( cFanControle, 15 )

      ENDIF

      cFanControle := PadR( Upper( CharRemove( cFanControle ) ), 15 )

      IF ! FAN->( DbSeek( cFanControle ) )
         EXIT
      ENDIF

      nFanControle ++

   ENDDO

   FAN->( DbAppend() )
   FAN->FAN := cFanControle

RETURN( cFanControle )



FUNCTION fanDescricao()

RETURN( cFanControle )



FUNCTION Abrevia( cString, nLen )

   LOCAL cReturn := Upper( AllTrim( cString ) )

   vDef( @nLen, 0 )

   // Acentos

   cReturn := Upper( CharRemove( cReturn ) )

   IF Len( cReturn ) > nLen

      // Cores

      cReturn := StrTran( cReturn, "AMARELO"  , "AM"   )
      cReturn := StrTran( cReturn, "AMARELA"  , "AM"   )
      cReturn := StrTran( cReturn, "AMARELLO" , "AM"   )
      cReturn := StrTran( cReturn, "AMARILLO" , "AM"   )
      cReturn := StrTran( cReturn, "AZUL"     , "AZ"   )
      cReturn := StrTran( cReturn, "BEGE"     , "BG"   )
      cReturn := StrTran( cReturn, "BEIGE"    , "BG"   )
      cReturn := StrTran( cReturn, "BRANCO"   , "BCO"  )
      cReturn := StrTran( cReturn, "BRANCA"   , "BCA"  )
      cReturn := StrTran( cReturn, "BRONZE"   , "BZE"  )
      cReturn := StrTran( cReturn, "CINZA"    , "CZ"   )
      cReturn := StrTran( cReturn, "DOURADO"  , "DOUR" )
      cReturn := StrTran( cReturn, "GELO"     , "GL"   )
      cReturn := StrTran( cReturn, "GRAFITE"  , "GRAF" )
      cReturn := StrTran( cReturn, "LARANJA"  , "LJ"   )
      cReturn := StrTran( cReturn, "MARROM"   , "MR"   )
      cReturn := StrTran( cReturn, "MARRON"   , "MR"   )
      cReturn := StrTran( cReturn, "PESSEGO"  , "PESS" )
      cReturn := StrTran( cReturn, "PRETO"    , "PTO"  )
      cReturn := StrTran( cReturn, "PRETA"    , "PTA"  )
      cReturn := StrTran( cReturn, "ROXO"     , "RX"   )
      cReturn := StrTran( cReturn, "TURQUESA" , "TURQ" )
      cReturn := StrTran( cReturn, "VERDE"    , "VD"   )
      cReturn := StrTran( cReturn, "VERMELHO" , "VM"   )
      cReturn := StrTran( cReturn, "VERMELHA" , "VM"   )
      cReturn := StrTran( cReturn, "VERM "    , "VM"   )

      // Lista de produtos

      cReturn := StrTran( cReturn, " L "             , "L "     )
      cReturn := StrTran( cReturn, " LT "            , "L "     )
      cReturn := StrTran( cReturn, "ABRACADEIRA"     , "ABRAC"  )
      cReturn := StrTran( cReturn, "ACABAMENTO"      , "ACAB"   )
      cReturn := StrTran( cReturn, "ACESSORIOS"      , "ACESS"  )
      cReturn := StrTran( cReturn, "ACETINADO"       , "ACET"   )
      cReturn := StrTran( cReturn, "ACRILICO"        , "ACR"    )
      cReturn := StrTran( cReturn, "ACRILICA"        , "ACR"    )
      cReturn := StrTran( cReturn, "ADAPTADOR"       , "ADAPT"  )
      cReturn := StrTran( cReturn, "ALICATE"         , "ALIC"   )
      cReturn := StrTran( cReturn, "ALUMINIO"        , "ALUM"   )
      cReturn := StrTran( cReturn, "ANTIGO"          , "ANT "   )
      cReturn := StrTran( cReturn, "ARTICULAVEL"     , "ARTIC"  )
      cReturn := StrTran( cReturn, "BASE POLIESTER"  , "BP"     )
      cReturn := StrTran( cReturn, "BASE POLI."      , "BP"     )
      cReturn := StrTran( cReturn, "BASE POLIURETANO", "BPU"    )
      cReturn := StrTran( cReturn, "BISNAGA"         , "BISN"   )
      cReturn := StrTran( cReturn, "BORRACHA"        , "BORR"   )
      cReturn := StrTran( cReturn, "BRILHANTE"       , "BRILH"  )
      cReturn := StrTran( cReturn, "CAIXA"           , "CX"     )
      cReturn := StrTran( cReturn, "CATALIZADOR"     , "CAT"    )
      cReturn := StrTran( cReturn, "CENTAURO"        , "CENT"   )
      cReturn := StrTran( cReturn, "CERAMICA"        , "CERAM"  )
      cReturn := StrTran( cReturn, "CHUVEIRO"        , "CHUV"   )
      cReturn := StrTran( cReturn, "COMPLEMENTO"     , "COMPL"  )
      cReturn := StrTran( cReturn, "COMPLEMENTARES"  , "COMPL"  )
      cReturn := StrTran( cReturn, "CONCENTRADO"     , "CONC"   )
      cReturn := StrTran( cReturn, "CONCRETO"        , "CONCR"  )
      cReturn := StrTran( cReturn, "CONEXAO"         , "CNX"    )
      cReturn := StrTran( cReturn, "CONEXOES"        , "CNX"    )
      cReturn := StrTran( cReturn, "COZINHA"         , "COZ"    )
      cReturn := StrTran( cReturn, "DEMARCACAO"      , "DEMARC" )
      cReturn := StrTran( cReturn, "DESEMPENADEIRA"  , "DESEMP" )
      cReturn := StrTran( cReturn, "DOBRADICA"       , "DOBR "  )
      cReturn := StrTran( cReturn, "EQUIPAMENTO"     , "EQUIP"  )
      cReturn := StrTran( cReturn, "EQUIPAMENTOS"    , "EQUIP"  )
      cReturn := StrTran( cReturn, "ESCURO"          , "ESC"    )
      cReturn := StrTran( cReturn, "ESMALTE"         , "ESM"    )
      cReturn := StrTran( cReturn, "ESPATULA"        , "ESPAT"  )
      cReturn := StrTran( cReturn, "ETIQUETA"        , "ETIQ"   )
      cReturn := StrTran( cReturn, "EXTERNA"         , "EXT"    )
      cReturn := StrTran( cReturn, "FIXACAO"         , "FIX"    )
      cReturn := StrTran( cReturn, "FECHADURA"       , "FECHAD" )
      cReturn := StrTran( cReturn, "FERRO"           , "FER"    )
      cReturn := StrTran( cReturn, "FLEXIVEL"        , "FLEX"   )
      cReturn := StrTran( cReturn, "FOLHA"           , "FL"     )
      cReturn := StrTran( cReturn, "FOSCO"           , "FCO"    )
      cReturn := StrTran( cReturn, "GAVETA"          , "GAV"    )
      cReturn := StrTran( cReturn, "IMPORTADO"       , "IMP"    )
      cReturn := StrTran( cReturn, "IMPORTADA"       , "IMP"    )
      cReturn := StrTran( cReturn, "IMPORT"          , "IMP"    )
      cReturn := StrTran( cReturn, "INTERNA"         , "INT"    )
      cReturn := StrTran( cReturn, "KILO "           , "KG "    )
      cReturn := StrTran( cReturn, "LAMPADA"         , "LAMP"   )
      cReturn := StrTran( cReturn, "LAVATORIO"       , "LAV"    )
      cReturn := StrTran( cReturn, "LIGACAO"         , "LIG"    )
      cReturn := StrTran( cReturn, "LITRO "          , "LT "    )
      cReturn := StrTran( cReturn, "LUMINOSO"        , "LUMIN"  )
      cReturn := StrTran( cReturn, "MADEIRA"         , "MAD"    )
      cReturn := StrTran( cReturn, "MANGUEIRA"       , "MANG"   )
      cReturn := StrTran( cReturn, "MARITIMO"        , "MAR."   )
      cReturn := StrTran( cReturn, "MEDIO"           , "MED"    )
      cReturn := StrTran( cReturn, "METALICO"        , "MET"    )
      cReturn := StrTran( cReturn, "METALICA"        , "MET"    )
      cReturn := StrTran( cReturn, "METAL."          , "MET"    )
      cReturn := StrTran( cReturn, "METRO "          , "MT "    )
      cReturn := StrTran( cReturn, "METROS "         , "MT "    )
      cReturn := StrTran( cReturn, "PARAFUSO"        , "PARAF"  )
      cReturn := StrTran( cReturn, "PARALELO"        , "PARAL"  )
      cReturn := StrTran( cReturn, "PECA "           , "PC "    )
      cReturn := StrTran( cReturn, "PECAS "          , "PC "    )
      cReturn := StrTran( cReturn, "PEROLIZADO"      , "PEROL"  )
      cReturn := StrTran( cReturn, "PEROLIZADA"      , "PEROL"  )
      cReturn := StrTran( cReturn, "PINTURA"         , "PINT"   )
      cReturn := StrTran( cReturn, "PLASTICA"        , "PLAST"  )
      cReturn := StrTran( cReturn, "PLASTICO"        , "PLAST"  )
      cReturn := StrTran( cReturn, "POLIESTER"       , "POLIE"  )
      cReturn := StrTran( cReturn, "POLIURETANO"     , "PU"     )
      cReturn := StrTran( cReturn, "PRATELEIRA"      , "PRAT"   )
      cReturn := StrTran( cReturn, "PROTETORA"       , "PROT"   )
      cReturn := StrTran( cReturn, "PROTETOR"        , "PROT"   )
      cReturn := StrTran( cReturn, "QUADRADA"        , "QUAD"   )
      cReturn := StrTran( cReturn, "QUADRADO"        , "QUAD"   )
      cReturn := StrTran( cReturn, "RAPIDO"          , "RAP"    )
      cReturn := StrTran( cReturn, "REDONDA"         , "RED"    )
      cReturn := StrTran( cReturn, "REDONDO"         , "RED"    )
      cReturn := StrTran( cReturn, "REFRIGERADOR"    , "REFRIG" )
      cReturn := StrTran( cReturn, "REMOVEDOR"       , "REMOV"  )
      cReturn := StrTran( cReturn, "RENAISSANCE"     , "RENA"   )
      cReturn := StrTran( cReturn, "RESISTENCIA"     , "RESIST" )
      cReturn := StrTran( cReturn, "ROLO "           , "RL "    )
      cReturn := StrTran( cReturn, "SEGURANCA"       , "SEG"    )
      cReturn := StrTran( cReturn, "SEGURO"          , "SEG"    )
      cReturn := StrTran( cReturn, "SEMI BRILHO"     , "SB"     )
      cReturn := StrTran( cReturn, "SINTETICO"       , "SINT"   )
      cReturn := StrTran( cReturn, "TELEFONE"        , "TEL"    )
      cReturn := StrTran( cReturn, "TEXTURADO"       , "TEXT"   )
      cReturn := StrTran( cReturn, "TEXTURATTO"      , "TEXT"   )
      cReturn := StrTran( cReturn, "TRANSPARENTE"    , "TRANSP" )
      cReturn := StrTran( cReturn, "UNIDADE"         , "UNID"   )
      cReturn := StrTran( cReturn, "UNIVERSAL"       , "UNIV"   )
      cReturn := StrTran( cReturn, "VALVULA"         , "VALV"   )
      cReturn := StrTran( cReturn, "VELOCIDADE"      , "VELOC"  )
      cReturn := StrTran( cReturn, "VERNIZES"        , "VERN"   )
      cReturn := StrTran( cReturn, "VERNIZ"          , "VERN"   )

      // Cadastro de enderecos

      cReturn := StrTran( cReturn, "SAO BERNARDO DO CAMPO", "SBC"   )
      cReturn := StrTran( cReturn, "SAO BERNARDO"         , "SBC"   )
      cReturn := StrTran( cReturn, "SAO CAETANO DO SUL"   , "SC"    )
      cReturn := StrTran( cReturn, "SAO CAETANO"          , "SC"    )
      cReturn := StrTran( cReturn, "SAO PAULO"            , "SP"    )
      cReturn := StrTran( cReturn, "RIO DE JANEIRO"       , "RJ"    )

      cReturn := StrTran( cReturn, " N "                  , " "     )
      cReturn := StrTran( cReturn, " N. "                 , " "     )
      cReturn := StrTran( cReturn, "ALAMEDA"              , "AL "   )
      cReturn := StrTran( cReturn, "AL."                  , "AL "   )
      cReturn := StrTran( cReturn, "AL,"                  , "AL "   )
      cReturn := StrTran( cReturn, "AL:"                  , "AL "   )
      cReturn := StrTran( cReturn, "ANDAR"                , "AND "  )
      cReturn := StrTran( cReturn, "APTO "                , "AP "   )
      cReturn := StrTran( cReturn, "APTO."                , "AP "   )
      cReturn := StrTran( cReturn, "APT "                 , "AP "   )
      cReturn := StrTran( cReturn, "APT."                 , "AP "   )
      cReturn := StrTran( cReturn, "AVENIDA"              , "AV "   )
      cReturn := StrTran( cReturn, "AV."                  , "AV "   )
      cReturn := StrTran( cReturn, "AV,"                  , "AV "   )
      cReturn := StrTran( cReturn, "AV:"                  , "AV "   )
      cReturn := StrTran( cReturn, "BLOCO"                , "BL "   )
      cReturn := StrTran( cReturn, "CHACARA"              , "CHAC " )
      cReturn := StrTran( cReturn, "CONJUNTO"             , "CJ "   )
      cReturn := StrTran( cReturn, "CONJ"                 , "CJ "   )
      cReturn := StrTran( cReturn, "ESTRADA"              , "ESTR " )
      cReturn := StrTran( cReturn, "JARDIM"               , "JD "   )
      cReturn := StrTran( cReturn, "LARGO"                , "LRG "  )
      cReturn := StrTran( cReturn, "PARQUE"               , "PQ "   )
      cReturn := StrTran( cReturn, "PQ."                  , "PQ "   )
      cReturn := StrTran( cReturn, "PQ,"                  , "PQ "   )
      cReturn := StrTran( cReturn, "PQ:"                  , "PQ "   )
      cReturn := StrTran( cReturn, "PRACA"                , "PC "   )
      cReturn := StrTran( cReturn, "RODOVIA"              , "ROD "  )
      cReturn := StrTran( cReturn, "RUA"                  , "R "    )
      cReturn := StrTran( cReturn, "R."                   , "R "    )
      cReturn := StrTran( cReturn, "R,"                   , "R "    )
      cReturn := StrTran( cReturn, "R:"                   , "R "    )
      cReturn := StrTran( cReturn, "SALA"                 , "SL "   )
      cReturn := StrTran( cReturn, "SANTO "               , "STO "  )
      cReturn := StrTran( cReturn, "SAO "                 , "S "    )
      cReturn := StrTran( cReturn, "TRAVESSA"             , "TRAV " )
      cReturn := StrTran( cReturn, "VILA"                 , "VL "   )
      cReturn := StrTran( cReturn, "VL."                  , "VL "   )
      cReturn := StrTran( cReturn, "VL,"                  , "VL "   )
      cReturn := StrTran( cReturn, "VL:"                  , "VL "   )

      // Numeros

      cReturn := StrTran( cReturn, "TREZE"         , "13" )
      cReturn := StrTran( cReturn, "VINTE E QUATRO", "24" )
      cReturn := StrTran( cReturn, "VINTE E SEIS"  , "26" )

      // Outros

      cReturn := StrTran( cReturn, " COM "             , " C/"          )
      cReturn := StrTran( cReturn, " DE "              , " "            )
      cReturn := StrTran( cReturn, " DONA "            , " D "          )
      cReturn := StrTran( cReturn, " PARA "            , " P/"          )
      cReturn := StrTran( cReturn, " SEM "             , " S/"          )
      cReturn := StrTran( cReturn, " SENHOR "          , " SR "         )
      cReturn := StrTran( cReturn, "BRIGADEIRO"        , "BRIG"         )
      cReturn := StrTran( cReturn, "C/ "               , "C/"           )
      cReturn := StrTran( cReturn, "CAPITAO"           , "CAP"          )
      cReturn := StrTran( cReturn, "CIMENTADOS E PISOS", "CIMENT/PISOS" )
      cReturn := StrTran( cReturn, "COMERCIO"          , "COM."         )
      cReturn := StrTran( cReturn, "COMERCIAL"         , "COML."        )
      cReturn := StrTran( cReturn, "CONSELHEIRO"       , "CONS"         )
      cReturn := StrTran( cReturn, "CONSTRUCAO"        , "CONSTR"       )
      cReturn := StrTran( cReturn, "CORONEL"           , "CEL"          )
      cReturn := StrTran( cReturn, "DOUTOR"            , "DR"           )
      cReturn := StrTran( cReturn, "ENGENHEIRO"        , "ENG"          )
      cReturn := StrTran( cReturn, "EXPORTACAO"        , "EXP"          )
      cReturn := StrTran( cReturn, "GENERAL"           , "GEN"          )
      cReturn := StrTran( cReturn, "GOVERNADOR"        , "GOV"          )
      cReturn := StrTran( cReturn, "GRANDE"            , "GDE"          )
      cReturn := StrTran( cReturn, "IMPORTACAO"        , "IMP"          )
      cReturn := StrTran( cReturn, "JUNIOR"            , "JR"           )
      cReturn := StrTran( cReturn, "MARECHAL"          , "MAL"          )
      cReturn := StrTran( cReturn, "MATERIAIS"         , "MATS."        )
      cReturn := StrTran( cReturn, "MATERIAL"          , "MAT."         )
      cReturn := StrTran( cReturn, "NUMERO"            , "NRO"          )
      cReturn := StrTran( cReturn, "P/ "               , "P/"           )
      cReturn := StrTran( cReturn, "PEQUENO"           , "PEQ"          )
      cReturn := StrTran( cReturn, "PEQUENA"           , "PEQ"          )
      cReturn := StrTran( cReturn, "PERFORMANCE"       , "PERF"         )
      cReturn := StrTran( cReturn, "PRESIDENTE"        , "PRES"         )
      cReturn := StrTran( cReturn, "PROFESSOR"         , "PROF"         )

   ENDIF
   
   cReturn := TiraEspacos( cReturn )

RETURN( cReturn )



FUNCTION AbreviaNome( cNome, nLen, nTotal )

   LOCAL nPos1 := AtNum( " ", cNome, 1 )
   LOCAL nPos2 := AtNum( " ", cNome, 2 )

   LOCAL cReturn := cNome

   IF nTotal = NIL
      cReturn := Abrevia( cReturn, nLen )
   ENDIF

   vDef( @nLen  , 0 )
   vDef( @nTotal, Len( Trim( cNome ) ) )

   IF ! mxIn( 0, { nPos1, nPos2 } ) .AND. nTotal > nLen
      
      cReturn := Left( cNome, nPos1 )
      cReturn += Subs( cNome, nPos1 +1, 1 )
      cReturn += AbreviaNome( Subs( cNome, nPos2 ), nLen, nTotal - ( nPos2 - nPos1 -2 ) )

   ENDIF

   IF nLen > 0
      cReturn := PadR( cReturn, nLen )
   ENDIF

RETURN( cReturn )



FUNCTION DefCod( cCod )

   IF Len( cCod ) = 1
   
      IF cCod = "Z"
         MsgDlg( "Limite para codigo de produto esgotado !" )
      ENDIF
   
      cCod := DefCodAux( cCod )

   ELSEIF Len( cCod ) = 2

      IF IsDigit( cCod )
         IF cCod = "99"
            cCod := "A0"
         ELSE
            cCod := StrZero( Val( cCod ) + 1, 2 )
         ENDIF
      ELSE
         IF Right( cCod, 1 ) = "Z"
            IF Left( cCod, 1 ) = "Z"
               MsgDlg( "Limite para codigo de produto esgotado !" )
            ENDIF
            cCod := DefCodAux( Left( cCod, 1 ) ) + "0"
         ELSE
            cCod := Left( cCod, 1 ) + DefCodAux( Right( cCod, 1 ) )
         ENDIF
      ENDIF

   ELSE

      IF IsDigit( cCod )
         IF cCod = "999"
            cCod := "A00"
         ELSE
            cCod := StrZero( Val( cCod ) + 1, 3 )
         ENDIF
      ELSEIF IsDigit( Right( cCod, 2 ) )
         IF Right( cCod, 2 ) = "99"
            IF Left( cCod, 1 ) = "Z"
               cCod := "AA0"
            ELSE
               cCod := DefCodAux( Left( cCod, 1 ) ) + "00"
            ENDIF
         ELSE
            cCod := Left( cCod, 1 ) + StrZero( Val( Right( cCod, 2 ) ) + 1, 2 )
         ENDIF
      ELSEIF Right( cCod, 1 ) = "Z"
         IF Subs( cCod, 2, 1 ) = "Z"
            IF cCod = "Z"
               MsgDlg( "Limite para codigo de produto esgotado !" )
            ENDIF
            cCod := DefCodAux( Left( cCod, 1 ) ) + "A0"
         ELSE
            cCod := Left( cCod, 1 ) + DefCodAux( Subs( cCod, 2, 1 ) ) + "0"
         ENDIF
      ELSE
         cCod := Left( cCod, 2 ) + DefCodAux( Right( cCod, 1 ) )
      ENDIF

   ENDIF

RETURN( cCod )



STATIC FUNCTION DefCodAux( cCod )

   IF cCod = "9"
      cCod := "A"
   ELSEIF IsDigit( cCod )
      cCod := Str( Val( cCod ) + 1, 1 )
   ELSE
      cCod := Chr( Asc( cCod ) +1 )
   ENDIF

RETURN( cCod )