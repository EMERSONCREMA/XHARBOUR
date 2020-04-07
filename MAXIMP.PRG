/*

 MaxImp.prg
 Descricao: Biblioteca de funcoes de impressao.
 Desenvolvido por MAX SCALLA Informatica Ltda.

 EMERSON DA SILVA CREMA
 19/06/17 * Desenvolvido mxWinPrintRaw().
 22/06/16 * Implementado o parametro lPrint em Print_Video().
 13/06/16 * Desenvolvido e implementado impMsgFomulario().
 06/06/16 * Implementado csDefineImpressora().
 03/06/16 * Implementado parametro cDefault em
            - mxDefPorta()
            - OkPrn()
            - mxImp().

 DENIS MAZZUCATTO RODRIGUES
 04/03/16 * Implementacao de PrintFileRaw() - Spool RAW Format.
 
 EMERSON DA SILVA CREMA
 24/11/15 * Permitida definicao de l2Linhas em impTotaliza() como parametro.
 
 DENIS MAZZUCATTO RODRIGUES
 10/01/13 * Implementado parametro e retorno em impDefNoSep().
 15/06/12 * Implementado TRY em mxImp().
 18/01/10 * Implementado parametro lAdd em impAddCplTitulo().

 EMERSON DA SILVA CREMA
 07/07/09 * Implementado em impTotaliza() a possibilidade de quebra da
            totalizacao em 2 linhas.

 DENIS MAZZUCATTO RODRIGUES
 22/01/08 * Implementacao da totalizacao de registros do relatorio.
 29/11/06 * Desenvolvimento e implementacao de impDefNoSep().
 24/11/06 * Implementado parametro nLinesPage em Init_Printer().
          * Desenvolvimento e implementacao de impLinesPage().

 EMERSON DA SILVA CREMA
 21/11/06 * Correcao na definicao de colunas em impTotaliza().
          * Removidas as clausulas PARAMETERS.
 14/09/06 * Removidos todos os negritos qdo lUseMaxImp = .T..
          * Desenvolvimento de UseMaxImp().
 12/09/06 * Desenvolvimento de mxDefPorta() e mxValidPort().
 04/09/06 * Alteracao em OkPrn() e mxEndPrint() p/ tratar LPTWIN?.
 29/08/06 * Desenvolvimento de impProxPagina().
 01/06/06 * Implementado parametro lAdd em impAddColumn().
 01/06/06 * Implementado impReset() em mxEndPrint().

 DENIS MAZZUCATTO RODRIGUES
 28/12/05 * Implementada opcao de escolher as colunas q serao totalizadas por
            impTotaliza().

 EMERSON DA SILVA CREMA
 15/09/05 * Removido o InKey(0.01) de Buffer() e colocado InKey().

 DENIS MAZZUCATTO RODRIGUES
 11/11/04 * Alteracao em impAddCplTitulo() p/ imprimir o complemento apenas na
            pagina selecionada.
 25/10/04 * Desenvolvimento de impTotaliza().

 EMERSON DA SILVA CREMA
 23/07/04 * Incluso O numero da versao do sistema no cabecalho dos relatorios.

 DENIS MAZZUCATTO RODRIGUES
 01/11/03 * Desenvolvimento de impAddTitulo(), impAddCplTitulo(), impTitulo(),
            impAddColumn(), impCabecalho(), impColumn() e de suas funcoes
            auxiliares.

*/

#include "std.ch"
#include "inkey.ch"

#define POS_LINE If( DESTIN <> "V"               ,  2,  1  )
#define CHR_CSEP If( DESTIN <> "V" .OR. lImpNoSep, "", "³" )

#define IMP_VEZES  If( lImpVidImp .AND. lImpActVez .AND. ! UseMaxImp(), 2, 1 )

#define IMP_TXTCAB If( ValType( aImpColumn[ nAux, IMP_CABECALHO ] ) = "A", aImpColumn[ nAux, IMP_CABECALHO, 1 ], aImpColumn[ nAux, IMP_CABECALHO ] )

#define IMP_ADDROW    1
#define IMP_PCOL      2
#define IMP_CABECALHO 3
#define IMP_DADOS     4
#define IMP_MASC      5
#define IMP_TOTAL     6
#define IMP_MASCTOTAL 7

STATIC aCaminho := { "", "" }

STATIC bImpTitulo := { || NIL }
STATIC aImpCplTit := {}
STATIC aImpColumn := {}
STATIC aImpSavPar := {}
STATIC aImpCtrLin := { 0, 0 }
STATIC nImpColuna := 132
STATIC nImpLinFim := 62
STATIC lImpVidImp := .F.
STATIC lImpActVez := .T.
STATIC lImpSpool  := .F.
STATIC lImpNoSep  := .F.
STATIC lUseMaxImp := .F.
STATIC nTotalReg  := 0
STATIC nImp       := 0
STATIC cArqImp    := ""
STATIC cPortaRaw  := NIL


FUNCTION OkPrn( cPorta, cCols, cDefault )

   // Verfica se a impressora esta ONLINE

   LOCAL cSavScr := SaveScreen( 24,00,24,79 )
   LOCAL lReturn := .T.

   vDef( @cCols, "80" )

   IF ValType( cCols ) = "N"
      cCols := NumToStr( cCols )
   ENDIF

   MDefault( "CFIVIPCTR", "S" )

   lReturn := mxImp( @cPorta, cCols, NIL, NIL, @cDefault )

   RestScreen( 24,00,24,79, cSavScr )

RETURN( lReturn )



FUNCTION mxImp( cPortaImp, cNumColImp, lConVerImp, lConPgs, cDefault )

   LOCAL aImp   := {}
   LOCAL SavTel := SaveScreen( 24,00,24,79 )

   PRIV cDefPorta

   vDef( @lConVerImp, .T. )
   vDef( @lConPgs   , .T. )

   cPortaRaw  := NIL
   lImpSpool  := .F.
   lConVerImp := ( lConVerImp .AND. CFIVIPCTR = "S" )

   mxDefPorta( @cPortaImp, @cDefault )

   IF IsDef( "CFIUCSCTR" ) .AND. foundStr( CFIUCSCTR, "S|R" ) .AND. "\\" $ cPortaImp

      IF CFIUCSCTR = "R"  // RAW Format

         impMsgFomulario( cNumColImp )

         lImpSpool := .T.
         cArqImp   := "TEMP" + DefArqTmp( NIL, ".PRN" )
         cPortaRaw := cPortaImp
         cDefPorta := cArqImp + ".PRN"

         SET PRINTER TO &cDefPorta

      ELSE  // PageScript

         DO WHILE .T.

            Status( "Aguarde, verificando se o programa Page Script est  ativo..." )

            IF ! lConPgs .OR. mxPsAct()

               cArqImp   := "TEMP" + DefArqTmp( NIL, ".PRN" )
               cDefPorta := cArqImp + ".PRN"

               SET PRINTER TO &cDefPorta

               aImp := mxPsGetPrint()
               nImp := aScan( aImp, Upper( AllTrim( cPortaImp ) ) )

               IF nImp = 0

                  IF MsgDlg( "Dispositivo n„o encontrado!;;Tentar novamente?", SimNao ) = 2
                     RestScreen( 24,00,24,79, SAVTEL )
                     SET PRIN TO
                     RETURN( .F. )
                  ENDIF

               ELSE

                  impMsgFomulario( cNumColImp )
                  lImpSpool := .T.
                  EXIT

               ENDIF

            ELSEIF MsgDlg( "O programa PageScript n„o est  ativo!;;Tentar novamente?", SimNao ) = 2

               RestScreen( 24,00,24,79, SAVTEL )
               SET PRIN TO
               RETURN( .F. )

            ENDIF

         ENDDO

      ENDIF

   ELSE

      impMsgFomulario( cNumColImp )

      IF mxValidPort( cPortaImp )
         TRY
            SET PRIN TO &cPortaImp
         CATCH
            SET PRIN TO
            MsgDlg( "Impressora despreparada!;;" + ;
                    "Verifique o dispositivo: ^"  + AllTrim( cPortaImp ) + "^" )
            RETURN( .F. )
         END
      ENDIF

      IF lConVerImp

         DO WHILE .T.

            IF "\\" $ cPortaImp

               Status( "Aguarde, verificando impressora na rede...", NIL, 1 )

               IF FCreate( AllTrim( cPortaImp ) + "\TEMP.PRN" ) > 0
                  EXIT
               ENDIF

               cMsg := "Impressora da rede despreparada!;;" + ;
                       "Verifique o caminho especificado:;" + ;
                       "^" + AllTrim( cPortaImp ) + "^"

            ELSEIF "LPTWIN" $ cPortaImp .OR. ( Upper( Left( cPortaImp, 3 ) ) <> "LPT" ) .OR. PrintReady( Val( Subs( cPortaImp, 4, 1 ) ) )

               EXIT

            ELSE

               cMsg := "Impressora despreparada!;;" + ;
                       "Verifique o dispositivo: ^"  + AllTrim( cPortaImp ) + "^"

               Status( "Aguarde, verificando impressora...", NIL, 1 )

            ENDIF

            IF MsgDlg( cMsg + ";;Tentar novamente?", { "Sim", "N„o" } ) = 2
               RestScreen( 24,00,24,79, SAVTEL )
               SET PRIN TO
               RETURN( .F. )
            ENDIF

            IF ! "\\" $ cPortaImp
               Inkey(1)
            ENDIF

         ENDDO

      ENDIF

   ENDIF

RETURN( .T. )



STATIC PROCEDURE impMsgFomulario( cNumColImp )

   IF cNumColImp <> NIL
      Mensagem( "Posicione o formul rio " + If( cNumColImp = "00", "para impress„o ", "de " + cNumColImp + " colunas " ) + "e tecle algo! ù ", 3, .T. )
   ENDIF

RETURN



FUNCTION mxDefPorta( cPorta, cDefault )

   LOCAL aPrinters, nOpc

   IF cPorta = NIL .OR. Empty( cPorta )
      cPorta := "LPT1"
   ENDIF

   IF "DECIDIR NA HORA" $ Upper( cPorta )

      aPrinters := GetPrinters(.T.)

      aAdd( aPrinters, { "LPT1"       , "" } )
      aAdd( aPrinters, { "LPT2"       , "" } )
      aAdd( aPrinters, { "LPT3"       , "" } )
      aAdd( aPrinters, { "Arquivo.PRN", "" } )

      IF cDefault = NIL
         nOpc := 0
      ELSE
         nOpc := aScan( aPrinters, { |p| AllTrim( Upper( p[1] ) ) == Upper( AllTrim( cDefault ) ) } )
      ENDIF

      IF nOpc = 0
         nOpc := Len( aPrinters )
      ENDIF

      IF Len( aPrinters ) < 19
         aEval( aPrinters, { |x,n| aPrinters[ n, 1 ] := SeqToChr( n ) + "ú" + x[1] } )
      ENDIF

      nOpc := aSelect( aPrinters, "Dispositivos de impress„o", NIL, nOpc, Len( aPrinters ) < 19, 1, CFIFUNCTR )

      IF nOpc > 0
         IF "\\" $ aPrinters[ nOpc, 2 ]
            cPorta := aPrinters[ nOpc, 2 ]
         ELSE
            cPorta := StrTran( aPrinters[ nOpc, 1 ], SeqToChr( nOpc ) + "ú", "" )
         ENDIF
         cDefault := cPorta
      ENDIF

      ClearKeybBuffer()

   ENDIF

   IF "\\" $ cPorta .AND. ! confPWin( cPorta )
      cPorta := "LPT1"
   ENDIF

   cPorta := AllTrim( cPorta )

   IF "LPTWIN" $ cPorta

      SetMaxImp(.T.)

      IF Empty( cArqImp ) .OR. ( ! ".TMP" $ cArqImp )

         cPorta := ConfPath( cPorta )

         IF ! IsDirExist( cPorta )
            mxMd( cPorta )
         ENDIF

         cArqImp := cPorta + "TEMP" + DefArqTmp( NIL, ".PRN" ) + ".TMP"

      ENDIF

      cPorta := cArqImp

   ENDIF

RETURN( cPorta )



FUNCTION Print_Video( cTitulo, cRodape, lPrint )

   vDef( @lPrint, .T. )

   IF Len( aImpColumn ) > 0 .AND. lPrint
      End_Form()
      IF ! UseMaxImp()
         Eject()
      ENDIF
   ENDIF

   IF DESTIN = "V"

      vDef( @cRodape, "Exibi‡„o em v¡deo    " + SISTEMA + "    Vers„o " + VERSAO + If( Len( SISTEMA ) < 19, "    F2úProc " + Chr(25) + "    F3úProc " + Chr(24), "" ) )

      SET DEVI TO SCRE
      SET PRIN TO

      DisplayFile( cArqVid, cRodape, cTitulo )

      IF GerArq
         FErase( cArqVid )
      ENDIF
      FErase( cArqImp )

      impReset()

   ELSE

      mxEndPrint()
      
      IF ! lPrint
         MsgDlg( MS050 )
      ENDIF

   ENDIF

   Status( "" )

RETURN( NIL )



FUNCTION Init_Printer( nPagina, nBeginLine, nLinesPage )

   vDef( @nBeginLine, 56 )

   MDefault( "DESTIN", "I" )

   Mensagem( MS012, 1 )

   IF nLinesPage <> NIL
      nImpLinFim := nLinesPage
   ENDIF

   impSetPrc( nBeginLine, 00 )

   nPagina    := 1
   lImpVidImp := ( lImpVidImp .AND. DESTIN <> "I" )

   SET DEVI TO PRIN

RETURN( NIL )



FUNCTION Buffer()

   LOCAL cDevice := Set( _SET_DEVICE, "SCREEN" )
   LOCAL lReturn := .T.

   IF Inkey() = K_ESC
      lReturn := ( ConfMsg( "Continua", { "Sim", "N„o" } ) = 1 )
   ENDIF

   Set( _SET_DEVICE, cDevice )

RETURN( lReturn )



FUNCTION Titulo( cTitulo, nPag, nCol, cCompl, uHora, cDeskJet, uTipo, lPag )

   LOCAL cEmit := "EMITIDO EM: " + DtoC( Date() )

   LOCAL cVersao, nLenVer, nLenNom, cCliente

   IF uHora <> NIL
      cEmit += " AS " + Left( Time(), 5) + "h"
   ENDIF

   vDef( @nPag, 1   )
   vDef( @nCol, 132 )
   vDef( @lPag, .T. )

   MDefault( "DESTIN", "I" )

   nImpLinFim := impLinesPage( cDeskJet )
   nImpColuna := nCol

   IF DESTIN = "V"
      impSetPrc( 000, 000 )
   ELSE
      aImpCtrLin[ POS_LINE ] := 0

      @ 000,000  SAY ""
   ENDIF

   cVersao  := AllTrim( SISTEMA + " v" + AllTrim( VERSAO ) )
   nLenVer  := Len( cVersao )
   nLenNom  := ( nCol -2 ) - nLenVer
   cCliente := CLIENTE
   IF IsValue( "CFIHOMCTR", "S" )
      cCliente := "EMPRESA MODO TREINAMENTO"
   ENDIF

   impSay( 000, 000           , cTitulo                  , NIL, ChrComp( 1, cDeskJet ) + ChrComp(                   3  , cDeskJet ) )
   impSay( 001, 000           , NIL                      , NIL, ChrComp( 4, cDeskJet ) + ChrComp( If( nCol > 80, 0, 1 ), cDeskJet ) )
   impSay( 001, 000           , Left( cCliente, nLenNom ), NIL, NIL                                                                 )
   impSay( 000, nCol - nLenVer, cVersao                  , NIL, NIL                                                                 )
   impSay( 001, 000           , cEmit                    , NIL, NIL                                                                 )

   IF cCompl <> NIL

      IF uHora = NIL
         impSay( 000, 024, PadC( AllTrim( cCompl ), nCol -39 ) )
      ELSE
         impSay( 000, 034, PadC( AllTrim( cCompl ), nCol -49 ) )
      ENDIF

   ENDIF

   DO CASE
      CASE DESTIN = "V" ; impSay( 000, nCol -14, "EXIBICAO VIDEO" )
      CASE uTipo <> NIL ; impSay( 000, nCol -12, "FOLHA: "  + StrZero(    nPag, 5 ) )
      CASE lPag         ; impSay( 000, nCol -13, "PAGINA: " + StrZero(    nPag, 5 ) )
      OTHERWISE         ; impSay( 000, nCol -13, "PAGINA: " + StrZero( ++ nPag, 5 ) )
   ENDCASE

   IF Len( aImpColumn ) = 0 .OR. Len( aImpCplTit ) > 0

      impSay( 001, 000, Repl( "Ä", nCol ) )

   ENDIF

RETURN( .T. )



/*----------------------------------------------------------------------------
 Funcao para compactacao e descompactacao das impressoras
 0 - Compacta
 1 - Descompacta
 2 - Expande
 3 - Negrito
 4 - Retira Negrito
 5 - Retira Expandido
----------------------------------------------------------------------------*/

FUNCTION ChrComp( TCHR, DESTIN )
                            //                       Descompactado       Negrito             Tira negrito        Expande
   mDefault( "CFICIMCTR", PadR( "                                                                            " , 120 ) )
   mDefault( "CFICIJCTR", PadR( "(s16.67H           (s10H              (s3B               (s-3B"                 , 120 ) )
   mDefault( "CFICILCTR",                                                                                                 "" )

   ARQCFG := If( DESTIN = NIL .OR. DESTIN $ "I|M|1", CFICIMCTR, If( DESTIN = "J", CFICIJCTR, CFICILCTR ) )

   DO CASE
      CASE TCHR = 1 ; RETURN( AllTrim( Subs( ARQCFG, 021, 20 ) ) )
      CASE TCHR = 2 ; RETURN( AllTrim( Subs( ARQCFG, 081, 20 ) ) )
      CASE TCHR = 3 ; RETURN( AllTrim( Subs( ARQCFG, 041, 20 ) ) )
      CASE TCHR = 4 ; RETURN( AllTrim( Subs( ARQCFG, 061, 20 ) ) )
      CASE TCHR = 5 ; RETURN( AllTrim( Subs( ARQCFG, 101, 20 ) ) )
   ENDCASE

RETURN( AllTrim( Left( ARQCFG, 20 ) ) )



FUNCTION Negrito( nLin, nCol, uTxt, nVez )

   LOCAL nL := nLin
   LOCAL nC := nCol
   LOCAL nI

   IF UseMaxImp()
      nVez := 1 
   ELSE
      vDef( @nVez, 2 )
   ENDIF 

   FOR nI := 1 TO nVez
      @ nL,nC SAY uTxt
   NEXT

RETURN( NIL )



FUNCTION mxValidPort( cPorta )

   LOCAL lReturn

   cPorta := AllTrim( cPorta )

   IF At( ".", cPorta ) = 0 .AND. ( ! "\\" $ cPorta )
      cPorta += ".PRN"
   ENDIF

   cPorta := Upper( cPorta )

   lReturn := ( Upper( AllTrim( Set( 24 ) ) ) <> cPorta )

RETURN( lReturn )



PROCEDURE mxEndPrint()

   SET DEVI TO SCRE
   SET PRIN TO

   IF lImpSpool .AND. IsDef( "CFIUCSCTR" ) .AND. foundStr( CFIUCSCTR, "S|R" )
   
      IF CFIUCSCTR = "R"  // RAW Format
      
         IF File( cArqImp + ".PRN" )
            PrintFileRaw( cPortaRaw, cArqImp + ".PRN", cArqImp + ".PRN" )
            FErase( cArqImp + ".PRN" )
         ELSE
            MsgDlg( "N„o foi poss¡vel gerar o arquivo;de impress„o em spool!" )
         ENDIF

      ELSEIF ! mxPsImpArq( cArqImp + ".PRN", .T., nImp, cArqImp )

         MsgDlg( "N„o foi poss¡vel gerar o arquivo;de impress„o em spool!" )
         
      ENDIF

   ELSEIF ! Empty( aCaminho[1] )

      FileCopy( AllTrim( aCaminho[1] ), AllTrim( aCaminho[2] ) )
      FErase( aCaminho[1] )

   ELSEIF ! Empty( cArqImp ) .AND. "LPTWIN" $ cArqImp

      mxFMove( cArqImp, ModExt( cArqImp, "PRN" ) )

      cArqImp := ""

   ENDIF

   impReset()

   SetMaxImp(.F.)

RETURN



STATIC FUNCTION confPWin( cPort )

   LOCAL cNetName := NetName()
   LOCAL lReturn

   lReturn := Empty( cNetName ) .OR. ! ( ( "\\" + AllTrim( Upper( cNetName ) ) + "\" ) $ AllTrim( Upper( cPort ) ) )

RETURN( lReturn )



PROCEDURE SetMaxImp( lMaxImp )

   lUseMaxImp := lMaxImp

RETURN



FUNCTION UseMaxImp()

   LOCAL lReturn := lUseMaxImp

RETURN( lReturn )



FUNCTION Next_Form( nCols, lImpTitulo )

   vDef( @nCols     , nImpColuna )
   vDef( @lImpTitulo, .F.        )

   IF DESTIN <> "V" .AND. impPRow() > nImpLinFim -11

      @ If( nImpLinFim = pRow() .AND. pCol() > 0, nImpLinFim + 1, nImpLinFim ), 000  SAY PadC( "* * * CONTINUA * * *", nCols )

      IF lImpTitulo
         impTitulo()
      ENDIF

   ENDIF

RETURN( NIL )



FUNCTION End_Form( nCols )

   IF DESTIN <> "V" .OR. lImpVidImp

      impSetPrint( lImpVidImp )

      vDef( @nCols, nImpColuna )

      IF DESTIN <> "V" .AND. impPRow() <= nImpLinFim
         @ nImpLinFim,000  SAY PadC( "* * * FIM * * *", nCols )
      ENDIF

      impSetPrint( lImpVidImp )

   ENDIF

RETURN( NIL )



FUNCTION impLinesPage( cPrinter )

   LOCAL nReturn := 62

   IF IsDef( "CFIMLICTR" )

      DO CASE
         CASE foundStr( cPrinter, "1|M" ) ; nReturn := Val( Subs( CFIMLICTR,  2, 3 ) )  // Matricial
         CASE cPrinter = "J"              ; nReturn := Val( Subs( CFIMLICTR,  6, 3 ) )  // Jato de tinta
         CASE cPrinter = "L"              ; nReturn := Val( Subs( CFIMLICTR, 10, 3 ) )  // Laser
      ENDCASE

   ENDIF

RETURN( nReturn )



FUNCTION impAddTitulo( bTitulo )

   bImpTitulo := bTitulo

RETURN( NIL )



FUNCTION impAddCplTitulo( nAddRow, uCol, cImp, nPage, lAdd )

   vDef( @nPage,  0  )
   vDef( @lAdd , .T. )

   aAddC( aImpCplTit, { nAddRow, uCol, cImp, nPage }, lAdd )

RETURN( NIL )



FUNCTION impAddColumn( cCabecalho, uImp, uMasc, nTotal, lAdd, uMascTotal )

   LOCAL nLen    := Len( aImpColumn )
   LOCAL nAddRow := 0
   LOCAL nCol    := 0
   LOCAL nAux

   vDef( @lAdd, .T. )

   IF lAdd

      FOR nAux := 1 TO nLen
         nCol += Len( IMP_TXTCAB ) + 1
      NEXT

      IF nLen = 0
         nAddRow := 1
      ENDIF

      aAdd( aImpColumn, { nAddRow, nCol, cCabecalho, uImp, uMasc, { nTotal, nTotal }, uMascTotal } )

   ENDIF

RETURN( NIL )



FUNCTION impTitulo( cPLine )

   LOCAL nSavPage   := NUMPAG
   LOCAL lSavActVez := lImpActVez

   LOCAL cImp, nImp, nAux

   PRIV cLine := cPLine

   impSaveParam( "impTitulo", { "cLine" } )

   FOR nImp := 1 TO IMP_VEZES

      lImpActVez := .F.

      impSetPrint( nImp = 2 )

      IF nImp = 2

         impRestParam( "impTitulo" )

         NUMPAG := nSavPage

      ENDIF

      IF DESTIN <> "V" .AND. NUMPAG = 1
         impSetPrc( 000, 000 )
      ENDIF

      // Impressao do titulo

      Eval( bImpTitulo )

      // Impressao do complemento do titulo

      IF DESTIN = "V"
         vDef( @cLine, impLine( "Ä", If( lImpNoSep, "Ä", "Â" ) ) )
      ELSE
         vDef( @cLine, Repl( "-", nImpColuna ) )

         cLine := StrTran( cLine, "Ä", "-" )
         cLine := StrTran( cLine, "Í", "=" )
      ENDIF

      FOR nAux := 1 TO Len( aImpCplTit )

         IF GetNoEmpty( aImpCplTit[ nAux, 4 ], NUMPAG ) <> NUMPAG
            LOOP
         ENDIF

         cImp := blockToVal( aImpCplTit[ nAux, 3 ] )

         IF DESTIN <> "V"
            cImp := StrTran( cImp, Repl( "Ä", nImpColuna ), Repl( "-", nImpColuna ) )
            cImp := StrTran( cImp, Repl( "Í", nImpColuna ), Repl( "=", nImpColuna ) )
         ENDIF

         @ impPRow( aImpCplTit[ nAux, IMP_ADDROW ] ), blockToVal( aImpCplTit[ nAux, IMP_PCOL ] )  SAY cImp

      NEXT

      @ impPRow( 1 ), 000  SAY cLine

      IF DESTIN <> "V" .OR. NUMPAG = 1
         NUMPAG ++
      ENDIF

      lImpActVez := lSavActVez

   NEXT

   cPLine := cLine

   impSetPrint( lImpActVez )

RETURN( NIL )



FUNCTION impCabecalho( nPNeg )

   LOCAL lArray := .F.

   LOCAL nImp, cImp, nAux, nVez

   PRIV nNeg := nPNeg

   impSaveParam( "impCabecalho", { "nNeg" } )

   FOR nImp := 1 TO IMP_VEZES

      impSetPrint( nImp = 2 )

      IF nImp = 2
         impRestParam( "impCabecalho" )
      ENDIF

      vDef( @nNeg, 1 )

      IF DESTIN = "V"
         nNeg := 1
      ENDIF

      FOR nAux := 1 TO Len( aImpColumn )

         cImp := IMP_TXTCAB

         IF ValType( aImpColumn[ nAux, IMP_CABECALHO ] ) = "A"
            lArray := .T.
         ENDIF

         IF aImpColumn[ nAux, IMP_PCOL ] = 0
            @ impPRow( aImpColumn[ nAux, IMP_ADDROW ] ), aImpColumn[ nAux, IMP_PCOL ]     SAY ""
         ELSE
            @ impPRow( aImpColumn[ nAux, IMP_ADDROW ] ), aImpColumn[ nAux, IMP_PCOL ] -1  SAY CHR_CSEP
         ENDIF

         FOR nVez := 1 TO nNeg
            IF nVez = 1 .OR. ! UseMaxImp()
               @ impPRow(), aImpColumn[ nAux, IMP_PCOL ]  SAY cImp
            ENDIF
         NEXT

      NEXT

      IF lArray

         FOR nAux := 1 TO Len( aImpColumn )

            cImp := ""

            IF ValType( aImpColumn[ nAux, IMP_CABECALHO ] ) = "A"
               cImp := aImpColumn[ nAux, IMP_CABECALHO, 2 ]
            ENDIF

            IF aImpColumn[ nAux, IMP_PCOL ] = 0
               @ impPRow( aImpColumn[ nAux, IMP_ADDROW ] ), aImpColumn[ nAux, IMP_PCOL ]     SAY ""
            ELSE
               @ impPRow( aImpColumn[ nAux, IMP_ADDROW ] ), aImpColumn[ nAux, IMP_PCOL ] -1  SAY CHR_CSEP
            ENDIF

            FOR nVez := 1 TO nNeg
               IF nVez = 1 .OR. ! UseMaxImp()
                  @ impPRow(), aImpColumn[ nAux, IMP_PCOL ]  SAY cImp
               ENDIF
            NEXT

         NEXT

      ENDIF

      IF DESTIN = "V"
         @ impPRow( 1 ), 000  SAY impLine( "Ä", If( lImpNoSep, "Ä", "Å" ) )
      ELSE
         @ impPRow( 1 ), 000  SAY Repl( "-", nImpColuna )
      ENDIF

   NEXT

   nPNeg := nNeg

   impSetPrint( lImpActVez )

RETURN( NIL )



FUNCTION impColumn()

   LOCAL nVez     := IMP_VEZES
   LOCAL nSavPage := NUMPAG

   LOCAL nAux, nImp, nSpace, nTotal, uMasc, cImp, nLin

   lImpActVez := .F.

   nTotalReg ++

   FOR nImp := 1 TO nVez

      impSetPrint( nImp = 2 )

      IF nImp = 2
         NUMPAG := nSavPage
      ENDIF

      BEGIN SEQUENCE

         IF NUMPAG > 1

            nLin := impPRow()

            IF DESTIN = "V" .OR. nLin < ( nImpLinFim -6 )
               BREAK
            ENDIF

            Next_Form()

         ENDIF

         impTitulo()     // Impressao do titulo
         impCabecalho()  // Impressao do cabecalho

      ENDSEQUENCE

      // Impressao dos dados das colunas

      FOR nAux := 1 TO Len( aImpColumn )

         IF aImpColumn[ nAux, IMP_PCOL ] = 0
            @ impPRow( aImpColumn[ nAux, IMP_ADDROW ] ), aImpColumn[ nAux, IMP_PCOL ]     SAY ""
         ELSE
            @ impPRow( aImpColumn[ nAux, IMP_ADDROW ] ), aImpColumn[ nAux, IMP_PCOL ] -1  SAY CHR_CSEP
         ENDIF

         cImp   := aImpColumn[ nAux, IMP_DADOS ]
         uMasc  := aImpColumn[ nAux, IMP_MASC  ]

         IF ValType( cImp ) = "C"
            cImp := &cImp
         ENDIF

         cImp := blockToVal( cImp )

         nSpace := Len( IMP_TXTCAB )

         IF ValType( aImpColumn[ nAux, IMP_TOTAL, 1 ] ) = "N"

            IF ValType( cImp ) = "C"
               nTotal := Val( StrTran( ClearMasc( cImp, "." ), ",", "." ) )
            ELSEIF ValType( cImp ) = "N"
               nTotal := cImp
            ELSE
               nTotal := 0
            ENDIF

            aImpColumn[ nAux, IMP_TOTAL, 1 ] += nTotal
            aImpColumn[ nAux, IMP_TOTAL, 2 ] += nTotal

         ENDIF

         DO CASE
            CASE uMasc = NIL
                 IF ValType( cImp ) = "C"
                    cImp := Left( cImp, nSpace )
                 ENDIF
            CASE ValType( uMasc ) = "N" ; cImp := PadR( cImp, uMasc )
            CASE ValType( uMasc ) = "C" ; cImp := PadL( AllTrim( Tran( cImp, uMasc ) ), nSpace )
            CASE ValType( uMasc ) = "B" ; cImp := PadL( AllTrim( Tran( cImp, Eval( uMasc ) ) ), nSpace )
         ENDCASE
         
         @ impPRow(), aImpColumn[ nAux, IMP_PCOL ]  SAY cImp

      NEXT

   NEXT

   lImpActVez := .T.

   IF nImp > 1
      impSetPrint( .T. )
   ENDIF

RETURN( NIL )



FUNCTION colLenMask( uMasc )

   LOCAL cMasc := uMasc
   
   IF ValType( uMasc ) = "B"
      cMasc := Eval( uMasc )
   ENDIF

   IF Left( cMasc, 3 ) = "@E "
      cMasc := Subs( cMasc, 4 )
   ENDIF

RETURN( Len( cMasc ) )



FUNCTION impTotaliza( cPMsg, nPCol, cPTipo, aPColExcept, lPTotalReg, l2Linhas )

   LOCAL cReturn  := ""
   LOCAL cReturn1 := ""
   LOCAL nTotGer  := 0
   LOCAL nColTot  := 0
   LOCAL nLinha   := 2
   LOCAL nLen     := Len( aImpColumn )
   LOCAL nImp, nAux, nTotal, nOpcTotal, uMasc, nSpace, nAjusta
   
   vDef( @lPTotalReg, .F. )
   vDef( @l2Linhas  , ( aScan( aImpColumn, { |x| x[ IMP_MASCTOTAL ] <> NIL } ) > 0 ) )

   PRIV cMsg       := cPMsg
   PRIV nCol       := nPCol
   PRIV cTipo      := cPTipo
   PRIV aColExcept := aPColExcept
   PRIV lTotalReg  := lPTotalReg

   impSaveParam( "impTotaliza", { "cMsg", "nCol", "cTipo", "aColExcept", "lTotalReg" } )

   FOR nImp := 1 TO IMP_VEZES

      impSetPrint( nImp = 2 )

      IF nImp = 2
         impRestParam( "impTotaliza" )
      ENDIF

      vDef( @cTipo, "TOT" )

      nOpcTotal := If( cTipo = "SUB", 1, 2 )

      FOR nAux := 1 TO nLen

         nTotal  := blockToVal( aImpColumn[ nAux, IMP_TOTAL, nOpcTotal ] )
         uMasc   := aImpColumn[ nAux, IMP_MASC ]
         nSpace  := Len( IMP_TXTCAB )
         nAjusta := 0

         IF aImpColumn[ nAux, IMP_MASCTOTAL ] <> NIL .AND. nTotal <> NIL
            uMasc := aImpColumn[ nAux, IMP_MASCTOTAL ]
            IF Len( aImpColumn[ nAux, IMP_MASCTOTAL ] ) > colLenMask( aImpColumn[ nAux, IMP_MASC ] )
               nAjusta := Len( aImpColumn[ nAux, IMP_MASCTOTAL ] ) - colLenMask( aImpColumn[ nAux, IMP_MASC ] )
            ENDIF
         ENDIF

         IF nTotal = NIL
            cReturn  += Space( nSpace + 1 )
            cReturn1 += Space( nSpace + 1 )
         ELSE
            IF ValType( nTotal ) = "N"
               aImpColumn[ nAux, IMP_TOTAL, 1 ] := 0
            ENDIF
            IF aColExcept <> NIL .AND. aScan( aColExcept, ++nColTot ) > 0
               cReturn  += Space( nSpace +1 )
               cReturn1 += Space( nSpace +1 )
            ELSE
               nTotGer += nTotal
               IF aImpColumn[ nAux, IMP_MASCTOTAL ] <> NIL .AND. nAjusta > 0
                  nSpace += nAjusta
               ENDIF
               IF ! l2Linhas .OR. nLinha = 2
                  cReturn  := Left( cReturn , Len( cReturn  ) - nAjusta )
                  cReturn  += PadL( AllTrim( Tran( nTotal, If( ValType( uMasc ) = "B", Eval( uMasc ), uMasc ) ) ), nSpace ) + " "
                  cReturn1 += Space( nSpace - nAjusta ) + " "
                  nLinha := 1
               ELSE
                  cReturn1 := Left( cReturn1, Len( cReturn1 ) - nAjusta )
                  cReturn  += Space( nSpace - nAjusta ) + " "
                  cReturn1 += PadL( AllTrim( Tran( nTotal, If( ValType( uMasc ) = "B", Eval( uMasc ), uMasc ) ) ), nSpace ) + " "
                  nLinha := 2
               ENDIF
            ENDIF
         ENDIF

      NEXT

      IF cMsg <> NIL
         vDef( @nCol, 1 )
         cReturn := Stuff( cReturn , nCol, Len( cMsg ), cMsg )
         IF l2Linhas
            cReturn1 := Stuff( cReturn1, nCol, Len( cMsg ), Space( Len( cMsg ) ) )
         ENDIF
      ENDIF

      @ impPRow( 1 ),000  SAY Trim( cReturn )

      IF l2Linhas
         @ impPRow( 1 ),000  SAY Trim( cReturn1 )
      ENDIF

      IF lTotalReg .AND. nTotalReg > 0
         @ impPRow( 2 ), 000  SAY "TOTAL DE REGISTROS : " + NumToStr( nTotalReg )
         nTotalReg := 0
      ENDIF

   NEXT

   cPMsg       := cMsg
   nPCol       := nCol
   cPTipo      := cTipo
   aPColExcept := aColExcept
   lPTotalReg  := lTotalReg

   impSetPrint( lImpActVez )

RETURN( nTotGer )



FUNCTION impFecha( cPChr, lTotalReg )

   LOCAL nImp, cChr1, cChr2

   PRIV cChr := cPChr

   vDef( @lTotalReg, .F. )

   impSaveParam( "impFecha", { "cChr" } )

   FOR nImp := 1 TO IMP_VEZES

      impSetPrint( nImp = 2 )

      IF nImp = 2
         impRestParam( "impFecha" )
      ENDIF

      vDef( @cChr, "Ä" )

      IF cChr = "Ä"
         cChr1 := If( DESTIN = "V", "Ä", "-" )
         cChr2 := If( DESTIN = "V", If( lImpNoSep, "Ä", "Á" ), "-" )
      ELSE
         cChr1 := If( DESTIN = "V", "Í", "=" )
         cChr2 := If( DESTIN = "V", If( lImpNoSep, "Í", "Ï" ), "=" )
      ENDIF

      IF NUMPAG > 1
         @ impPRow( 1 ), 000  SAY impLine( cChr1, cChr2 )
         IF lTotalReg .AND. nTotalReg > 0
            @ impPRow( 1 ), 000  SAY "TOTAL DE REGISTROS : " + NumToStr( nTotalReg )
            nTotalReg := 0
         ENDIF
      ENDIF

   NEXT

   cPChr := cChr

   impSetPrint( lImpActVez )

RETURN( NIL )



FUNCTION impSay( nPAddRow, nPCol, uPImp, uPMasc, uPChr, nPNeg )

   LOCAL nImp, nVez, nPRow

   PRIV nAddRow := nPAddRow
   PRIV nCol    := nPCol
   PRIV uImp    := uPImp
   PRIV uMasc   := uPMasc
   PRIV uChr    := uPChr
   PRIV nNeg    := nPNeg

   impSaveParam( "impSay", { "nAddRow", "nCol", "uImp", "uMasc", "uChr", "nNeg" } )

   FOR nImp := 1 TO IMP_VEZES

      impSetPrint( nImp = 2 )

      IF nImp = 2
         impRestParam( "impSay" )
      ENDIF

      vDef( @nNeg, 1  )
      vDef( @uImp, "" )
      vDef( @uChr, "" )

      uImp := blockToVal( uImp )

      IF uMasc <> NIL

         DO CASE
            CASE ValType( uMasc ) = "B" ; uImp := Tran( uImp, Eval( uMasc ) )
            CASE ValType( uMasc ) = "C" ; uImp := Tran( uImp, uMasc )
            CASE ValType( uMasc ) = "N" ; uImp := PadR( uImp, uMasc )
         ENDCASE

      ENDIF

      IF DESTIN = "V"
         nNeg := 1
         uChr := ""
      ELSEIF ValType( uImp ) = "C"
         uImp := StrTran( uImp, Repl( "Ä", nImpColuna ), Repl( "-", nImpColuna ) )
         uImp := StrTran( uImp, Repl( "Í", nImpColuna ), Repl( "=", nImpColuna ) )
         IF nImpColuna = 132
            uImp := StrTran( uImp, Repl( "Ä", 80 ), Repl( "-", 80 ) )
            uImp := StrTran( uImp, Repl( "Í", 80 ), Repl( "=", 80 ) )
         ENDIF
      ENDIF

      nPRow := impPRow() + nAddRow

      @ nPRow, nCol  SAY uChr

      FOR nVez := 1 TO nNeg
         IF nVez = 1 .OR. ! UseMaxImp()
            @ nPRow, nCol  SAY uImp
         ENDIF
      NEXT

      impPRow( nAddRow )

   NEXT

   nPAddRow := nAddRow
   nPCol    := nCol
   uPImp    := uImp
   uPMasc   := uMasc
   uPChr    := uChr
   nPNeg    := nNeg

   impSetPrint( lImpActVez )

RETURN( NIL )



FUNCTION impLine( cChr1, cChr2, lTotal )

   LOCAL cReturn := ""
   LOCAL nLen    := Len( aImpColumn )
   LOCAL nPos    := aImpColumn[ 1, IMP_PCOL ]

   LOCAL nAux, nCol, cChr

   vDef( @cChr2 , cChr1 )
   vDef( @lTotal, .F. )

   IF lTotal .AND. DESTIN = "V"
      RETURN( "" )
   ENDIF

   IF DESTIN <> "V"
      cChr1 := StrTran( cChr1, "Ä", "-" )
      cChr1 := StrTran( cChr1, "Í", "=" )
   ENDIF

   IF DESTIN = "V" .OR. lTotal

      FOR nAux := 1 TO nLen

         IF lTotal .AND. aImpColumn[ nAux, IMP_TOTAL, 1 ] = NIL
            cChr := " "
         ELSE
            cChr := cChr1
         ENDIF

         cReturn += Repl( cChr, Len( IMP_TXTCAB ) )

         IF nAux < nLen
            cReturn += cChr2
         ELSEIF Len( cReturn ) < nImpColuna
            cReturn += Repl( cChr, nImpColuna - Len( cReturn ) )
         ENDIF

      NEXT

   ELSE

      cReturn := Repl( cChr1, nImpColuna )

   ENDIF

RETURN( cReturn )



FUNCTION impReset()

   bImpTitulo := { || NIL }
   aImpCplTit := {}
   aImpColumn := {}
   aImpSavPar := {}
   aImpCtrLin := { 0, 0 }
   nImpColuna := 132
   nImpLinFim := 62
   lImpVidImp := .F.
   lImpActVez := .T.
   lImpNoSep  := .F.
   nTotalReg  := 0

RETURN( NIL )



FUNCTION impDuplaGrv()

   LOCAL lReturn := ( lImpVidImp .AND. Len( aImpColumn ) > 0 )

RETURN( lReturn )



STATIC FUNCTION impPRow( nAddRow )

   vDef( @nAddRow, 0 )

   MDefault( "DESTIN", "I" )

   IF impDuplaGrv()
      impSetPrc( aImpCtrLin[ POS_LINE ] += nAddRow, pCol() )
   ENDIF

RETURN( pRow() + nAddRow )



STATIC FUNCTION impSetPrc( nRow, nCol )

   MDefault( "DESTIN", "I" )

   SetPrc( nRow, nCol )

   aImpCtrLin[ POS_LINE ] := nRow

RETURN( NIL )



STATIC FUNCTION impSetPrint( lMuda )

   IF impDuplaGrv()

      IF lMuda
         DESTIN := If( DESTIN = "V", "I", "V" )
      ENDIF

      IF DESTIN = "V"
         SET PRIN TO &cArqVid  // ADDITIVE
      ELSE
         SET PRIN TO &cArqImp  // ADDITIVE
      ENDIF

   ENDIF

RETURN( NIL )



STATIC FUNCTION impSaveParam( cFunc, aParam )

   LOCAL nArr, nPos, cVar
   
   IF impDuplaGrv()

      FOR nArr := 1 TO Len( aParam )

         cVar := aParam[ nArr ]
         nPos := aScan( aImpSavPar, { |x| x[1] + x[2] = cFunc + cVar } )

         IF nPos = 0
            aAdd( aImpSavPar, { cFunc, cVar, &cVar } )
         ELSE
            aImpSavPar[ nPos, 3 ] := &cVar
         ENDIF

      NEXT

   ENDIF

RETURN( NIL )



STATIC FUNCTION impRestParam( cFunc )

   LOCAL nArr, cVar
   
   IF impDuplaGrv()

      FOR nArr := 1 TO Len( aImpSavPar )

         IF aImpSavPar[ nArr, 1 ] = cFunc
            cVar  := aImpSavPar[ nArr, 2 ]
            &cVar := aImpSavPar[ nArr, 3 ]
         ENDIF

      NEXT

   ENDIF

RETURN( NIL )



FUNCTION impProxPagina( NUMPAG, nCol )

   vDef( @nCol, 132 )

   IF NUMPAG = 1
      SetPrc( 0,0 )
   ELSE
      @ pRow() +1, 000 SAY Repl( "-", nCol )
   ENDIF

RETURN( NIL )



FUNCTION impDefNoSep( lDef )

   LOCAL lReturn := lImpNoSep

   IF lDef <> NIL
      lImpNoSep := lDef
   ENDIF

RETURN( lReturn )



FUNCTION mxWinPrintRaw( cPrinter, cFileName, cDocumentName )

  LOCAL nPrn:= -1, cMess:= "WinPrintRaw(): "

  IF ! Empty( cFilename )
     nPrn := PrintFileRaw( cPrinter, cFileName, cDocumentName )
     IF nPrn < 0
        DO CASE
           CASE nPrn = -1 ; MsgDlg( cMess + "Incorrect parameters passed to function")
           CASE nPrn = -2 ; MsgDlg( cMess + "WINAPI OpenPrinter() call failed")
           CASE nPrn = -3 ; MsgDlg( cMess + "WINAPI StartDocPrinter() call failed")
           CASE nPrn = -4 ; MsgDlg( cMess + "WINAPI StartPagePrinter() call failed")
           CASE nPrn = -5 ; MsgDlg( cMess + "WINAPI malloc() of memory failed")
           CASE nPrn = -6 ; MsgDlg( cMess + "WINAPI CreateFile() call failed - File " + cFileName + " no found??" )
        ENDCASE
     ENDIF
  ENDIF

RETURN( nPrn )