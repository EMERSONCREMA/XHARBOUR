/*

   MaxSpool.prg
   Descricao: Biblioteca de funcoes de impressao em spool.
   Desenvolvido por MAX SCALLA Informatica Ltda.

   ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³ TIPOS DE FONTES   ³ ESTILO DA FONTE         ³ CORES                   ³
   ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
   ³ "System"          ³  0 = Normal             ³  -1 = Preto             ³
   ³ "Courier New"     ³  1 = Negrito            ³  -2 = Azul escuro       ³
   ³ "Arial"           ³  2 = Italico            ³  -3 = Verde escuro      ³
   ³ "Times New Roman" ³  4 = Subscrito          ³  -4 = Ciano escuro      ³
   ³ "WingDings"       ³  8 = Riscado            ³  -5 = Vermelho escuro   ³
   ³                   ³ 12 = Negrito em Italico ³  -6 = Magenta escuro    ³
   ³                   ³                         ³  -7 = Marrom            ³
   ³                   ³                         ³  -8 = Cinza claro       ³
   ³                   ³                         ³  -9 = Cinza escuro      ³
   ³                   ³                         ³ -10 = Azul claro        ³
   ³                   ³                         ³ -11 = Verde florescente ³
   ³                   ³                         ³ -12 = Ciano florescente ³
   ³                   ³                         ³ -13 = Vermelho claro    ³
   ³                   ³                         ³ -14 = Magenta claro     ³
   ³                   ³                         ³ -15 = Amarelo           ³
   ³                   ³                         ³ -16 = Branco            ³
   ³                   ³                         ³ 255 = Sem cor           ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

*/

#include "std.ch"

STATIC aPgsSpo[36]
STATIC aCfgPgs[04]

STATIC lActPgs := .F.

/*----------------------------------------------------------------------------
 Efetua a verificacao se o programa PageScript esta ativo atraves do caminho
 definido por cPath ou do default que se encontra no arquivo de configuracao
 do PageScript que se encontra no raiz da maquina.

 Parametros

 cPath : Caminho onde se encontra o programa instalado.

 Retorno : Verdadeiro se estiver ativo, caso contrario, falso.
-----------------------------------------------------------------------------*/

FUNCTION mxPsAct( cPath )

   LOCAL lReturn := .F.

   IF ! lActPgs

      aPgsSpo[01] := NIL
      aPgsSpo[02] := NIL
      aPgsSpo[03] := -1
      aPgsSpo[04] := ""
      aPgsSpo[05] := "C:\"
      aPgsSpo[06] := "C:\"
      aPgsSpo[07] := "."
      aPgsSpo[08] := {}
      aPgsSpo[10] := .F.
      aPgsSpo[11] := .F.
      aPgsSpo[12] := .T.
      aPgsSpo[13] := .F.
      aPgsSpo[14] := 0
      aPgsSpo[15] := -255
      aPgsSpo[34] := 1
      aPgsSpo[35] := { 0, "" }
      aPgsSpo[36] := "Undefined"

      mxPsReset()

      aPgsSpo[06] := GetEnv( "TMP" )

      IF Empty( aPgsSpo[06] )

         aPgsSpo[06] := GetEnv( "TEMP" )

      ENDIF

      IF Empty( aPgsSpo[06] )

         aPgsSpo[06] := "\" + CurDir( "C" )

      ENDIF

      aPgsSpo[06] := ConfPath( aPgsSpo[06] )

      IF aPgsSpo[03] > -1

         FClose( aPgsSpo[03] )

      ENDIF

      IF ValType( cPath ) == "C"

         aPgsSpo[05] := ConfPath( cPath )

      ELSE

         mxIniNew( "C:\PSPath.ini" )

         aPgsSpo[05] := ConfPath( mxGetOpe( "Path", "Spool", "" ) )

         mxIniFree()

      ENDIF

      IF Len( mxPsQuery( 13, NIL, .T., 5 ) ) > 0
         lReturn := .T.
      ENDIF

      mxPsSetPri()

      aPgsSpo[11] := .F.
      lActPgs     := .T.

   ELSEIF Len( mxPsQuery( 13, NIL, .T., 5 ) ) > 0

      lReturn := .T.

   ENDIF

RETURN( lReturn )



/*----------------------------------------------------------------------------
 Efetua a consistencia das impressoras instaladas na maquina para impressao,
 que tem como base um arquivo que se encontra no diretorio de instalacao do
 PageScipt. ( <Diretorio>\SPOOL\PRINTERS.PSI )

 Retorno : Retorna uma matriz unidimensional com as impressoras instaladas.
-----------------------------------------------------------------------------*/

FUNCTION mxPsGetPrint()

   LOCAL aGetImp := {}
   LOCAL nGetImp := Len( aPgsSpo[08] )
   LOCAL nImp

   FOR nImp := 1 TO nGetImp
      aAdd( aGetImp, Upper( aPgsSpo[ 08, nImp, 1 ] ) )
   NEXT

RETURN( aClone( aGetImp ) )



/*-----------------------------------------------------------------------------
 Inicializa o driver de impressao do PageScript e cria um arquivo de spool
 para impressao, iniciando modo de impressao em spool.

 Parametros

 nImp    : Numero da impressora em que sera direcionado a impressao em spool.
 cNomArq : Nome do arquivo que sera gerado na fila de espera de impressao
           do windows para a impressao em spool.
 nTipImp : Tipo da da disposicao da impressao na folha.
           - 0 = Retrato  -> Impressao na folha em modo horizontal.
           - 1 = Paisagem -> Impressao na folha em modo vertical.
 nCopia  : Especifica o numero de copias a serem impressas.

 Retorno : Retorna o codigo de status da ultima operacao do DOS com arquivos.
----------------------------------------------------------------------------*/

FUNCTION mxPsBegDoc( nImp, cNomArq, nTipImp, nCopia )

   aPgsSpo[04] := mxPsNewArq( ".PGS" )

   IF lActPgs .AND. ( aPgsSpo[03] := FCreate( aPgsSpo[06] + aPgsSpo[04], 0 ) ) >= 0

      nImp    := If( nImp    == NIL                      , 0          , Int( nImp    ) )
      nCopia  := If( nCopia  == NIL                      , aPgsSpo[23], Int( nCopia  ) )
      nTipImp := If( nTipImp == NIL                      , aPgsSpo[25], Int( nTipImp ) )
      cNomArq := If( Empty( cNomArq ) .OR. cNomArq == NIL, "Untitled" , cNomArq        )

      aPgsSpo[09] := .T.

      IF nImp < 0 .OR. nImp > Len( aPgsSpo[08] )
         nImp := 0
      ENDIF

      aPgsSpo[14] := nImp

      FWrite( aPgsSpo[3], Chr(0) + "s" + Chr(2) + "4.0.4"                       + Chr(1) + ;
                          Chr(0) + "f" + Chr(2) + DtoC( Date() ) + " " + Time() + Chr(1) + ;
                          Chr(0) + "q" + Chr(2) + cNomArq                       + Chr(1) + ;
                          Chr(0) + "n" + Chr(2) + LTrim( Str( nImp        ) )   + Chr(1) + ;
                          Chr(0) + "{" + Chr(2) + LTrim( Str( aPgsSpo[24] ) )   + Chr(1) + ;
                          Chr(0) + "l" + Chr(2) + LTrim( Str( nTipImp     ) )   + Chr(1) + ;
                          Chr(0) + "v" + Chr(2) + LTrim( Str( nCopia      ) )   + Chr(1) + ;
                          Chr(0) + "x" + Chr(2) + LTrim( Str( aPgsSpo[22] ) )   + Chr(1) + ;
                          Chr(0) + "w" + Chr(2) + LTrim( Str( aPgsSpo[21] ) )            + ;
                                         Chr(2) + LTrim( Str( aPgsSpo[20] ) )   + Chr(1) + ;
                          Chr(0) + "p" + Chr(2) + LTrim( Str( aPgsSpo[16] ) )            + ;
                                         Chr(2) + LTrim( Str( aPgsSpo[17] ) )   + Chr(1) + ;
                          Chr(0) + "y" + Chr(2) + aPgsSpo[7]                    + Chr(1) + ;
                          Chr(0) + "z" + Chr(2) + If( aPgsSpo[12], "1", "0")    + Chr(1) + ;
                          Chr(0) + "d" + Chr(1) + ("") )

      IF ValType( aPgsSpo[1] ) == "B" .AND. ! aPgsSpo[10]
         Eval( aPgsSpo[1] )
      ENDIF

   ENDIF

RETURN( FError() )



/*----------------------------------------------------------------------------
 Desiguina o tipo da unidade de impressao em modo texto, milimetrica, em
 centimetros, polegadas ou em pixels.

 Parametros

 nUnidade : Tipo da unidade de impressao.
            - 0 = Impressao em formato texto ( Linha, Coluna ).
            - 1 = Impressao em milimetros.
            - 2 = Impressao em centimetros.
            - 3 = Impressao em polegadas.
            - 4 = Impressao em pixels.

 Retorno : A unidade de impressao anterior.
----------------------------------------------------------------------------*/

FUNCTION mxPsSetUnit( nUnidade )

   LOCAL nOldUni := aPgsSpo[34]

   aPgsSpo[34] := If( nUnidade == NIL, aPgsSpo[34], Int( nUnidade ) )

   IF lActPgs .AND. aPgsSpo[9]

      FWrite( aPgsSpo[3], Chr(0) + "r" + Chr(2) + LTrim( Str( Int( aPgsSpo[34] ) ) ) + Chr(1) + ("") )

   ENDIF

RETURN( nOldUni )



/*----------------------------------------------------------------------------
 Define a quantidade de linhas e colunas para impressao, ela so pode ser
 utilizada qdo a impressao for definida como texto pela funcao mxPsSetUnit().

 Parametros

 nLin : Numero de linhas para impressao.
 nCol : Numero de colunas para impressao.

 Retorno : A configuracao de linhas e colunas ateriores.
----------------------------------------------------------------------------*/

FUNCTION mxPsRowCol( nLin, nCol )

   LOCAL nOldLin := aPgsSpo[16]
   LOCAL nOldCol := aPgsSpo[17]

   aPgsSpo[16] := If( nLin == NIL, aPgsSpo[16], Int( nLin ) )
   aPgsSpo[17] := If( nCol == NIL, aPgsSpo[17], Int( nCol ) )

   IF lActPgs .AND. aPgsSpo[9]

      FWrite( aPgsSpo[3], Chr(0) + "p" + Chr(2) + LTrim( Str( aPgsSpo[16] ) ) + ;
                                         Chr(2) + LTrim( Str( aPgsSpo[17] ) ) + Chr(1) + ("") )

   ENDIF

RETURN( { nOldLin, nOldCol } )



/*----------------------------------------------------------------------------
 Permite configurar a fonte, estilo, tamanho, cor, cor de fundo para o
 formulario de impressao.

 Parametros

 cFont   : A fonte que sera usada na impressao indicadas na tabela acima.
 nStyle  : Estilo da fonte para impressao indicada na tabela acima.
 nPoint  : Tamanho da fonte em quantidade de pontos.
 nFColor : Numero da cor indicada na tabela acima para a fonte.
 nBColor : Numero da cor indicada na tabela acima para o plano de fundo.

 Retorno : Retorna fonte, estilo, tamanho, cor, cor de fundo anteriores.
----------------------------------------------------------------------------*/

FUNCTION mxPsSetFont( cFont, nStyle, nPoint, nFColor, nBColor )

   LOCAL cOldFnt := aPgsSpo[27]
   LOCAL nOldSty := aPgsSpo[28]
   LOCAL nOldPon := aPgsSpo[18]
   LOCAL nOldFCl := aPgsSpo[32]
   LOCAL nOldBCl := aPgsSpo[33]

   aPgsSpo[27] := If( cFont   == NIL, aPgsSpo[27], cFont          )
   aPgsSpo[28] := If( nStyle  == NIL, aPgsSpo[28], Int( nStyle  ) )
   aPgsSpo[18] := If( nPoint  == NIL, aPgsSpo[18], nPoint         )
   aPgsSpo[32] := If( nFColor == NIL, aPgsSpo[32], Int( nFColor ) )
   aPgsSpo[33] := If( nBColor == NIL, aPgsSpo[33], Int( nBColor ) )

RETURN( { cOldFnt, nOldSty, nOldPon, nOldFCl, nOldBCl } )



/*----------------------------------------------------------------------------
 Adiciona os dados a serem impressos no arquivo de spool.

 Parametros

 nLin    : Numero da linha onde sera impressa a informacao.
 nCol    : Numero da coluna onde sera impressa a informacao.
 uStr    : Conteudo que sera impresso.
 cMasc   : Mascara que sera utilizada na informacao a ser impressa.
 nJusStr : Tipo de alinhamento do texto.
           - 0 = O texto sera justificado para a esquerda.
           - 1 = O texto sera justificado para a direita.
           - 2 = O texto sera alinhado no centro.
           - 3 = O texto sera alinhado no centro por decimais.
 cFonte  : A fonte que sera usada na impressao indicadas na tabela acima.
 nEstilo : Estilo da fonte para impressao indicada na tabela acima.
 nTamFnt : Tamanho da fonte em quantidade de pontos.
 nFColor : Numero da cor indicada na tabela acima para a fonte.
 nBColor : Numero da cor indicada na tabela acima para o plano de fundo.
 nAngulo : Indica o angulo da rotacao do texto em graus.
           - 0 = Sem rotacao.
----------------------------------------------------------------------------*/

FUNCTION mxPSTextOut( nLin, nCol, uStr, cMasc, nJusStr, cFonte, nEstilo, nTamFnt, nFColor, nBColor, nAngulo )

   LOCAL cTipStr

   IF lActPgs .AND. aPgsSpo[9]

      cTipStr := ValType( uStr )
      cMasc   := If( cMasc   == NIL, ""         , cMasc          )
      nJusStr := If( nJusStr == NIL, aPgsSpo[26], Int( nJusStr ) )
      cFonte  := If( cFonte  == NIL, aPgsSpo[27], cFonte         )
      nEstilo := If( nEstilo == NIL, aPgsSpo[28], Int( nEstilo ) )
      nTamFnt := If( nTamFnt == NIL, aPgsSpo[18], nTamFnt        )
      nFColor := If( nFColor == NIL, aPgsSpo[32], Int( nFColor ) )
      nBColor := If( nBColor == NIL, aPgsSpo[33], Int( nBColor ) )
      nAngulo := If( nAngulo == NIL, 0          , Int( nAngulo ) )

      IF Empty( cMasc )

         IF cTipStr == "N"
            cMasc := "@N"
         ELSEIF cTipStr == "D"
            cMasc := "@D"
         ELSEIF cTipStr == "L"
            cMasc := "@Y"
         ELSE
            cMasc := "@X"
         ENDIF

      ENDIF

      uStr := Tran( uStr, cMasc )

      IF nAngulo < 0 .OR. nAngulo > 360

         nAngulo := 0

      ENDIF

      FWrite( aPgsSpo[3], Chr(0) + "o" + Chr(2) + LTrim( Str( nLin        ) ) + ;
                                         Chr(2) + LTrim( Str( nCol        ) ) + ;
                                         Chr(2) + LTrim( Str( Len( uStr ) ) ) + ;
                                         Chr(2) + uStr                        + ;
                                         Chr(2) + LTrim( Str( nJusStr     ) ) + ;
                                         Chr(2) + cFonte                      + ;
                                         Chr(2) + LTrim( Str( nEstilo     ) ) + ;
                                         Chr(2) + LTrim( Str( nTamFnt     ) ) + ;
                                         Chr(2) + LTrim( Str( nFColor     ) ) + ;
                                         Chr(2) + LTrim( Str( nBColor     ) ) + ;
                                         Chr(2) + LTrim( Str( nAngulo     ) ) + ;
                                         Chr(1) + ("") )

   ENDIF

RETURN( NIL )



FUNCTION mxPsEndDoc()

   // Efetua a impressao finalizando o processo de impressao e eliminando o
   // arquivo de spool.

   IF lActPgs .AND. aPgsSpo[9]

      IF ValType( aPgsSpo[1] ) == "B" .AND. aPgsSpo[10]

         Eval( aPgsSpo[1] )

      ENDIF

      FWrite( aPgsSpo[3], Chr(0) + "h" + Chr(1) + ("") )
      FClose( aPgsSpo[3] )
      __CopyFile( aPgsSpo[6] + aPgsSpo[4], aPgsSpo[5] + aPgsSpo[4] )
      mxFDel( aPgsSpo[6] + aPgsSpo[4] )
      mxPsQuery( 17, { { "PrintJobFile", aPgsSpo[4] } }, .F. )
      mxPsReset()
      mxPsSetPri()

   ENDIF     

RETURN( NIL )



/*----------------------------------------------------------------------------
 Efetua a impressao de um arquivo, em spool utilizando corretamente os
 caracteres especificos de impressao.

 Parametros

 cFileName : Nome do arquivo que contem as informacoes a serem impressas.
 lDelete   : Se .T. ele deleta o arquivo apos o termino do processo de
             impressao senao ele mantem o arquivo no diretorio.
 nPrinter  : Numero da impressora que e obtida pela funcao mxPsGetPrint() em
             que sera direcionado a impressao em spool.
 cTitulo   : Nome do arquivo na fila de impressao do Windows.

 Retorno : Retorna .T. se conseguiu gerar com sucesso o arquivo de impressao
           .F. quando o arquivo na conseguiu ser gerado
----------------------------------------------------------------------------*/

FUNCTION mxPsImpArq( cFileName, lDelete, nPrinter, cTitulo )

   LOCAL lGerArq := File( cFileName )
   LOCAL cArqImp

   vDef( @lDelete , .T.        )
   vDef( @nPrinter, 0          )
   vDef( @cTitulo , "Untitled" )

   IF lGerArq .AND. lActPgs

      cArqImp := mxPsNewArq( ".PGS" )
      __CopyFile( cFileName, aPgsSpo[5] + cArqImp )
      mxPsQuery( 19, { { "PrintJobFile", cArqImp }, { "Printer", LTrim( Str( nPrinter ) ) }, { "JobTitle", cTitulo } }, .F. )

   ENDIF

   IF lDelete
      mxFDel( cFileName )
   ENDIF

RETURN( lGerArq .AND. lActPgs )



STATIC FUNCTION mxIniNew( cArq )

   IF cArq == NIL

      aCfgPgs[04] := .F.

   ELSE

      IF At( ".", cArq ) == 0
         cArq := cArq + ".ini"
      ENDIF

      aCfgPgs[2] := {}
      aCfgPgs[3] := .F.
      aCfgPgs[4] := .T.
      aCfgPgs[1] := Upper( cArq )

      mxIniLoad()

   ENDIF

RETURN( NIL )



STATIC FUNCTION mxGetOpe( cStrIni, cStrLin, cStrRet )

   LOCAL nPosStr

   IF cStrRet == NIL
      cStrRet := ""
   ENDIF

   nPosStr := aScan( aCfgPgs[2], { |x| Upper( x[1] ) == "[" + Upper( ALlTrim( cStrIni ) ) + "]" .AND. ;
                                       Upper( x[2] ) ==       Upper( AllTrim( cStrLin ) )             ;
                                 } )

RETURN( IF( nPosStr == 0, cStrRet, aCfgPgs[ 2, nPosStr, 3 ] ) )



STATIC FUNCTION mxIniFree()

   aCfgPgs[02] := {}
   aCfgPgs[03] := .T.

RETURN( NIL )



STATIC FUNCTION mxIniLoad()

   LOCAL nAbeArq := FOpen( aCfgPgs[1], 0 )
   LOCAL cStrArq, nPosImp

   IF FError() == 0

      nPosImp := FSeek( nAbeArq, 0, 2 )

      FSeek( nAbeArq, 0, 0 )

      cStrArq := FReadStr( nAbeArq, nPosImp )

      FClose( nAbeArq )

      mxIniSet( cStrArq )

   ELSE

      aCfgPgs[3] := .T.

   ENDIF     

RETURN( NIL )



STATIC FUNCTION mxIniSet( cStrArq )

   LOCAL nLinArq, nLin, cStrIni, cStrLin

   aCfgPgs[2] := {}

   nLinArq := MlCount( cStrArq, 254, NIL, .F. )

   FOR nLin := 1 TO nLinArq

      cStrLin := AllTrim( MemoLine( cStrArq, 254, 1, NIL, .F. ) )
      cStrArq := Subs( cStrArq, MlPos( cStrArq, 254, 2, NIL, .F. ) )

      IF ! Empty( cStrLin )

         IF Left( cStrLin, 1 ) == "["

            cStrIni := cStrLin

         ELSE

            aAdd( aCfgPgs[2], { cStrIni                                           ,;
                                AllTrim( Left( cStrLin, At( "=", cStrLin ) - 1 ) ),;
                                AllTrim( Subs( cStrLin, At( "=", cStrLin ) + 1 ) ) ;
                              } )

         ENDIF

      ENDIF

   NEXT      

RETURN( NIL )



STATIC FUNCTION mxPsNewArq( cExt )

   LOCAL cFile

   DO WHILE File( cFile := "TEMP" + Num_TempFile() + cExt )
   ENDDO

RETURN( cFile )



STATIC FUNCTION mxPsSetPri()

   LOCAL nImp, nQtdImp, nImpDef

   mxIniNew( aPgsSpo[05] + "PRINTERS.PSI" )

   nImpDef := Val( mxGetOpe( "Return", "Default", LTrim( Str( aPgsSpo[15] ) ) ) )
   nQtdImp := Val( mxGetOpe( "Return", "NumData", "0" ) )

   IF ! nImpDef == aPgsSpo[15]

      aPgsSpo[15] := nImpDef
      aPgsSpo[11] := .T.

   ENDIF

   aPgsSpo[08] := {}

   FOR nImp := 1 TO nQtdImp

      aAdd( aPgsSpo[08], {      mxGetOpe( "P" + LTrim( Str( nImp ) ), "Printer"     , ""    ),;
                           Val( mxGetOpe( "P" + LTrim( Str( nImp ) ), "pPaperWidth" , "0" ) ),;
                           Val( mxGetOpe( "P" + LTrim( Str( nImp ) ), "pPaperHeight", "0" ) ),;
                           Val( mxGetOpe( "P" + LTrim( Str( nImp ) ), "pPageWidth"  , "0" ) ),;
                           Val( mxGetOpe( "P" + LTrim( Str( nImp ) ), "pPageHeight" , "0" ) ),;
                           Val( mxGetOpe( "P" + LTrim( Str( nImp ) ), "pOffsetY"    , "0" ) ),;
                           Val( mxGetOpe( "P" + LTrim( Str( nImp ) ), "pOffsetX"    , "0" ) ),;
                           Val( mxGetOpe( "P" + LTrim( Str( nImp ) ), "pPixelsX"    , "0" ) ),;
                           Val( mxGetOpe( "P" + LTrim( Str( nImp ) ), "pPixelsY"    , "0" ) ),;
                           Val( mxGetOpe( "P" + LTrim( Str( nImp ) ), "lPaperWidth" , "0" ) ),;
                           Val( mxGetOpe( "P" + LTrim( Str( nImp ) ), "lPaperHeight", "0" ) ),;
                           Val( mxGetOpe( "P" + LTrim( Str( nImp ) ), "lPageWidth"  , "0" ) ),;
                           Val( mxGetOpe( "P" + LTrim( Str( nImp ) ), "lPageHeight" , "0" ) ),;
                           Val( mxGetOpe( "P" + LTrim( Str( nImp ) ), "lOffsetY"    , "0" ) ),;
                           Val( mxGetOpe( "P" + LTrim( Str( nImp ) ), "lOffsetX"    , "0" ) ),;
                           Val( mxGetOpe( "P" + LTrim( Str( nImp ) ), "lPixelsX"    , "0" ) ),;
                           Val( mxGetOpe( "P" + LTrim( Str( nImp ) ), "lPixelsY"    , "0" ) ),;
                           Val( mxGetOpe( "P" + LTrim( Str( nImp ) ), "Bits"        , "0" ) ),;
                           Val( mxGetOpe( "P" + LTrim( Str( nImp ) ), "PaperSize"   , "0" ) ),;
                           Val( mxGetOpe( "P" + LTrim( Str( nImp ) ), "Bin"         , "0" ) ) ;
                         } )

   NEXT

   mxIniFree()

RETURN( NIL )



STATIC FUNCTION mxPsQuery( nOpe, aFimImp, lCab, nCtrl )

   LOCAL aImp    := {}
   LOCAL nCtrArq := If( ValType( nCtrl ) == "N", nCtrl, 5 )
   LOCAL cNomArq := mxPsNewArq( ""     )
   LOCAL cNomExt := mxPsNewArq( ".PSP" )

   LOCAL nOpeDat, nLin, nCtrGer

   mxIniNew( aPgsSpo[5] + cNomArq + ".PST" )

   mxSetOpe( "Query", "Version" , "4.0.4"                 )
   mxSetOpe( "Query", "Query"   , LTrim( Str( nOpe ) )    )
   mxSetOpe( "Query", "FileName", If( lCab, cNomExt, "" ) )

   IF ValType( aFimImp ) == "A"

      FOR nLin := 1 TO Len( aFimImp )

         mxSetOpe( "Query", aFimImp[ nLin, 1 ], aFimImp[ nLin, 2 ] )

      NEXT

   ENDIF

   mxSaveFile()
   mxIniFree()

   FRename( aPgsSpo[5] + cNomArq + ".PST", aPgsSpo[5] + cNomArq + ".PSQ" )

   IF lCab

      Inkey( 0.10 )

      IF ! File( aPgsSpo[5] + cNomExt )

         nCtrGer := 0

         DO WHILE nCtrArq > 0

            Inkey( 0.10 )

            nCtrArq -= 0.10
            nCtrGer += 0.10

            IF nCtrGer > 1

               nCtrGer := 0

               IF File( aPgsSpo[5] + cNomExt )
                  EXIT
               ENDIF

            ENDIF

         ENDDO

      ENDIF

      IF File( aPgsSpo[5] + cNomExt )

         mxIniNew( aPgsSpo[5] + cNomExt )

         nOpeDat     := Val( mxGetOpe( "Return", "NumData", "0" ) )
         aPgsSpo[15] := Val( mxGetOpe( "Return", "Default", LTrim( Str( aPgsSpo[15] ) ) ) )
         aPgsSpo[36] := mxGetOpe( "Return", "Version", "Undefined" )

         FOR nLin := 1 TO nOpeDat

            aAdd( aImp, mxGetOpe( "Data", "D" + LTrim( Str( nLin ) ), "" ) )

         NEXT

         mxIniFree()

         mxFDel( aPgsSpo[5] + cNomExt )

      ELSE

         mxFDel( aPgsSpo[5] + cNomArq + ".PSQ" )
         mxFDel( aPgsSpo[5] + cNomExt )

      ENDIF

   ENDIF

RETURN( aImp )



STATIC FUNCTION mxSetOpe( cCabStr, cTipLin, cStrLin )

   LOCAL nPosStr := aScan( aCfgPgs[2], { |x| Upper( x[1] ) == "[" + Upper( AllTrim( cCabStr ) ) + "]" .AND. ;
                                             Upper( x[2] ) ==       Upper( AllTrim( cTipLin ) )            ;
                                       } )

   LOCAL nPos, aStrArq

   IF nPosStr == 0

      aStrArq := { "[" + AllTrim( cCabStr ) + "]", AllTrim( cTipLin ), AllTrim( cStrLin ) }

      nPosStr := aScan( aCfgPgs[2], { |x| Upper( x[1] ) == "[" + Upper( AllTrim( cCabStr ) ) + "]" } )

      IF nPosStr == 0

         aAdd( aCfgPgs[2], aStrArq )

      ELSE

         nPos := aScan( aCfgPgs[2], { |x| ! Upper( x[1] ) == "[" + Upper( AllTrim( cCabStr ) ) + "]" }, nPosStr )

         IF nPos == 0

            aAdd( aCfgPgs[2], aStrArq )

         ELSE

            aSize( aCfgPgs[2], Len( aCfgPgs[2] ) + 1 )
            aIns( aCfgPgs[2], nPos - 1 )
            aCfgPgs[ 2, nPos - 1 ] := aStrArq

         ENDIF

      ENDIF

   ELSE

      aCfgPgs[ 2, nPosStr, 3 ] := AllTrim( cStrLin )

   ENDIF

RETURN( NIL )



STATIC FUNCTION mxSaveFile()

   LOCAL cStrArq := mxGetStr()
   LOCAL nGerArq := FCreate( aCfgPgs[1] )

   IF FError() == 0

      FWrite( nGerArq, cStrArq )

      IF FError() == 0
         aCfgPgs[3] := .T.
      ENDIF

      FClose( nGerArq )

   ENDIF

RETURN( NIL )



STATIC FUNCTION mxGetStr()

   LOCAL nLenStr := Len( aCfgPgs[2] )
   LOCAL cStrArq := ""
   LOCAL cStrCab := ""
   LOCAL nCount

   FOR nCount := 1 TO nLenStr

      IF ! cStrCab == aCfgPgs[ 2, nCount, 1 ]

         IF ! Empty( cStrArq )
            cStrArq := cStrArq + If( aCfgPgs[4], Chr(13) + Chr(10), "" )
         ENDIF

         cStrArq := cStrArq + ( aCfgPgs[ 2, nCount, 1 ] + If( aCfgPgs[4], Chr(13) + Chr(10), "" ) )
         cStrCab := aCfgPgs[ 2, nCount, 1 ]

      ENDIF

      cStrArq := cStrArq + ( aCfgPgs[ 2, nCount, 2 ] + "=" + aCfgPgs[ 2, nCount, 3 ] + If( aCfgPgs[4], Chr(13) + Chr(10), "" ) )

   NEXT

RETURN( cStrArq )



STATIC FUNCTION mxPsReset()

   aPgsSpo[09] := .F.
   aPgsSpo[16] := 55
   aPgsSpo[17] := 80
   aPgsSpo[18] := 12
   aPgsSpo[19] := 1
   aPgsSpo[20] := 0
   aPgsSpo[21] := 0
   aPgsSpo[22] := 0
   aPgsSpo[23] := 1
   aPgsSpo[24] := 1
   aPgsSpo[25] := 0
   aPgsSpo[26] := 0
   aPgsSpo[27] := "Courier New"
   aPgsSpo[28] := 0
   aPgsSpo[29] := -16
   aPgsSpo[30] := -1
   aPgsSpo[31] := 0
   aPgsSpo[32] := -1
   aPgsSpo[33] := -255

RETURN( NIL )
