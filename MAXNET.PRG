/*

 MaxNet.prg
 Descricao: Biblioteca de funcoes de acesso a banco de dados.
 Desenvolvido por MAX SCALLA Informatica Ltda.
 
 EMERSON DA SILVA CREMA
 08/07/19 * Implementado em AddCodigo() o parametro lConfTab.
          * Implementado em codGrvSequence() o parametro nRecLock.
 04/07/19 * Implementado em AddCodigo() o parametro bAjustaCod.
 29/03/19 * Implementado tratamento de codigo quando online para CFICODNOE.
          * Implementado CS_MODO_ONLINE.
 04/06/18 * Removida a verificação do tamanho do arquivo na função mxFLock().
 01/08/17 * Implementado em AddCodigo() msg de "Aguarde" p/ busca de sequencia
            de codigo.
 27/06/17 * Implementado os parametros aRecords e aDefReplace em SetVars().
          * Implementado o parametro aRecords em SaveVars().
 18/02/16 * Personalizacao em codLimite() p/ GAMACOR/ARICANDUVA p/ q
            em CFICODPET use a apenas a primeira posicao como codigo da
            loja quando for loja 2.

 DENIS MAZZUCATTO RODRIGUES
 15/12/15 * Alterada fmtKeySeek() p/ formatar o campo caracter com o tamanho
            exato do campo a ser pesquisado.
            
 EMERSON DA SILVA CREMA
 11/11/15 * Implementacao de lReset em SetVars().
 11/09/15 * Corrigida definicao da sequencia de codigo em AddCodigo() p/ os
            campos CFICODCHQ, CFICODCCD, CFICODPAG, CFICODRCP, CFICODRET e
            CFICODBLC.
 02/03/15 * Implementado parametro aRepl_Personalizado em Repl_Field().
 16/06/14 * Alteracao em lckOper() p/ considerar codigo com 14 digitos.
 12/05/14 * Removido CFICODCLI da constante COD_USELOJ.
 05/05/14 * Transformada a constante COD_MULTLJ() em funcao.
 30/04/14 * Desenvolvimento de mxUpdStr().
 24/04/14 * Desenvolvimento de codMultLojas().
          * Implementado adaptacoes em AddCodigo() p/ codificacao de
            CFICODCLI com numero de loja.
 08/04/14 * Movido Acha() de MAXNETX.PRG
          * Desenvolvimento de mxFieldLog().
 06/03/14 * Implementado CFICODBLC em COD_MULTLJ.
 24/02/14 * Implementado parametro uConn em mxRecCount().
 17/02/14 * Implementado parametro lconfVar em SaveVars().
 27/09/13 * Padronizados logs na pasta LOGS\.

 DENIS MAZZUCATTO RODRIGUES
 05/09/13 * Desenvolvimento de fmtAlias().
 20/08/13 * Implementado parametro lRestore em mxLocate().
 15/03/13 * Desenvolvimento e implementacao de COD_MULTLJ p/ gerar o codigo
            baseado no numero da loja q gerou o movimento.
 11/01/13 * Melhorias em EmptyDb().
 28/08/12 * Implementacao de mxDbRefresh() p/ o MXCODCFI em AddCodigo(),
            codGrvSequence(), codUpdate() e codSequencia().
 
 EMERSON DA SILVA CREMA
 26/04/12 * Correcao em fmtKeySeek() q nao convertia numeros p/ caracter com
            casas decimais, formatava neste caso como inteiro.
 22/02/12 * Desenvolvimento de mxSetDbRefresh().

 DENIS MAZZUCATTO RODRIGUES
 10/08/11 * Remocao de FieldValue().
          * Removida SR_Exec() de mxDbRefresh().
          * Removida mxDbRefresh() de AddCodigo(), codGrvSequence() e
            codUpdate().

 EMERSON DA SILVA CREMA
 02/06/11 * Desenvolvimento de mxFUnLockAll().
          * Mudado nome do arquivo de bloqueio em AddCodigo() p/ q seja
            MX???CTR.LCK.

 DENIS MAZZUCATTO RODRIGUES
 04/04/11 * Correcao em mxRecCount() qdo utilizado em schemas # de public.
 25/11/10 * Implementacao dos controles p/ R_KEYCTR.
 18/11/10 * Desenvolvimento de mxRecCount().
 17/03/10 * Modificada forma de bloqueio do arquivo em mxFLock() p/ resolver o
            problema do XP q consegue apagar o arquivo mesmo estando em uso.
 11/03/10 * Desenvolvimento de lckOper().
 19/01/10 * Corrigida comparacao com lSeqOnLine em GetSeqCodigo(), pois mesmo
            q a variavel nao exista a funcao buscava o codigo.

 EMERSON DA SILVA CREMA
 01/12/09 * Implementado parametro de tempo (cTime) em mxFLock().
 25/08/09 * Alteracao em mxFLock() p/ q repita os processos mal sucedidos
            durante 1 minuto (antes era 30s).
 05/08/09 * Corrigida gravacao de KEYCTR em SaveVars().
 09/04/09 * Desenvolvimento de sepAliasField().

 DENIS MAZZUCATTO RODRIGUES
 19/01/09 * Implementada verificacao do numero da loja 999 em GetSeqCodigo().

 EMERSON DA SILVA CREMA
 24/11/08 * Implementacao de lConfSeq em AddCodigo().
 10/06/08 * Correcao de "variable does not exist cCampoCOD" em codLimite().
          * Desenvolvimento e implementacao de codLimite().
 12/05/08 * Desenvolvimento de mxLogRecord().
 14/02/08 * Implementada consistencia em GetSeqCodigo() p/ nao buscar codigos
            qdo a loja estiver offline.

 DENIS MAZZUCATTO RODRIGUES
 14/02/08 * Implementada definicao COD_USELOJ.
          * Implementada mensagem p/ qdo o limite de codigos estiver esgotado.

 EMERSON DA SILVA CREMA
 04/10/07 * Movida ConfRec() de MAXAMOCF.PRG (Control Shop).
 23/05/07 * Remocao de mxSeekDef() e implementado o 4o. parametro em mxSeek().
 25/01/07 * Desenvolvimento de FieldValue().

 DENIS MAZZUCATTO RODRIGUES
 04/01/07 * Remocao de NewCod(), fldFormat() e IsEmptyDb().
 03/01/07 * Implementado parametro nAdd em codSequencia().

 EMERSON DA SILVA CREMA
 16/11/06 * Implementados parametros cDefCampo e aExcCampo em Repl_Field().

 DENIS MAZZUCATTO RODRIGUES
 30/10/06 * Desenvolvimento de defFileClose().

 EMERSON DA SILVA CREMA
 26/09/06 * Implementacao de foundStr().
          * Implementado campo CFICODEML.
 04/09/06 * Implementado parametro lMaster em cnxSeek().
 29/05/06 * Alteracao em cnxSeek() p/ qdo nao achar o registro e ainda nao for
            final de arquivo, posicionar entao no final.
 11/05/06 * Implementado parametro lVerLoja em defCodigos().
 19/04/06 * Mudada a variavel cIndKey de cnxSeek() p/ parametro.
          * Implementado LOG de erro em cnxSeek() qdo o tamanho da chave nao
            for igual ao tamanho do parametro de procura.
 10/04/06 * Desenvolvimento de fldFormat().
 27/01/06 * Removidas implementacoes de btrRefresh().
 20/01/06 * Implementacao de btrRefresh().

 DENIS MAZZUCATTO RODRIGUES
 15/08/05 * Desenvolvimento e implementacao de codGrvSequence().

 EMERSON DA SILVA CREMA
 15/04/05 * Alteracao em SeleArea() p/ consistir se o ALIAS esta aberto.
 07/12/04 * Desenvolvimento de TraceSet() e TraceLog().
          * Colocado mxReplace() em Repl_Field() e demais funcoes q faziam a
            gravacao de forma direta.

 DENIS MAZZUCATTO RODRIGUES
 19/11/04 * Desenvolvimento de mxDbStruct().

 EMERSON DA SILVA CREMA
 18/11/04 * Colocado .F. como default p/ lAppend em Repl_Field().
 06/10/04 * Implementacao de defReplace().
 13/08/04 * Desenvolvimento de codUpdate().

 DENIS MAZZUCATTO RODRIGUES
 12/08/04 * Alteracoes nas funcoes de codigo p/ buscar a ordem e o limite do
            codigo nos campos de MXCODCFI.

 EMERSON DA SILVA CREMA
 05/08/04 * Incluso parametro de mensagem em mxFLock().
 30/03/04 * Alteracao em SaveVars() p/ criar a sequencia baseando-se apenas
            pelo MXCODCFI.
*/

#include "std.ch"
#include "inkey.ch"
#include "common.ch"
#include "fileIO.ch"
#include "dataEdit.ch"

#define POS_CODCMP 1
#define POS_CODREC 2

#define COD_DIRECT "CFICODCNX|CFICODCFG|CFICODEML|CFIODPCOD"
#define COD_USELOJ "CFICODPET|CFICODTRF|CFICODNFP" // Codigos concatenados com o numero da loja

#define CS_MODO_ONLINE ( IsDef( "CFICNXCTR" ) .AND. CFICNXCTR $ "MS" )

STATIC lBDTrace    := .F.
STATIC aCtrCodigos := {}
STATIC cDataSource := ""
STATIC cMxRdd      := "DBFCDX"
STATIC aRecOrd     := {}
STATIC aNetLock    := {}
STATIC aLckOper    := {}
STATIC lDbRefresh  := .T.


FUNCTION mxRecno()

   LOCAL nRecno := Recno()

RETURN( nRecno )



FUNCTION mxRecCount( cAlias, uConn )

   LOCAL nReturn := RecCount()
   LOCAL aSql    := {}

   LOCAL nConnSave, nOpen, cTela

   IF RddName() = "SQLRDD"

      vDef( @cAlias, Alias() )

      nOpen := aScan( getOpenFiles(), { |x| x[1] = cAlias } )

      IF nOpen > 0
         cAlias := sqlGetConn( "SCHEMA", getOpenFileS()[ nOpen, 3 ] ) + "." + getOpenFileS()[ nOpen, 4 ]
      ELSE
         nConnSave := sqlSetConn( sqlGetInfo( cAlias, "NAME" ) )
         cAlias := sqlGetInfo( cAlias, "SCHEMA" ) + "." + sqlGetInfo( cAlias, "FILE" )
      ENDIF
      
      cTela := SaveScreen( MaxRow(), 00, MaxRow(), MaxCol() )

      Status( "Contando registros de " + cAlias + "...", NIL, 1 )

      IF sqlExecute( "SELECT COUNT( DISTINCT SR_RECNO ) AS RECCOUNT FROM " + cAlias, @aSql, .F., uConn )
         nReturn := aSql[ 1, 1 ]
      ENDIF

      IF nConnSave <> NIL
         sqlSetConn( nConnSave )
      ENDIF
      
      RestScreen( MaxRow(), 00, MaxRow(), MaxCol(), cTela )

   ENDIF

RETURN( nReturn )



FUNCTION mxClose( uClose )

   LOCAL nCount, cClose, aClose

   IF uClose = NIL
      aClose := { Alias() }
   ELSEIF ValType( uClose ) = "A"
      aClose := uClose
   ELSE
      aClose := { uClose }
   ENDIF

   FOR nCount := 1 TO Len( aClose )

      cClose := aClose[ nCount ]

      IF Select( cClose ) > 0
         ( cClose )->( mxCloseArea() )
      ENDIF

   NEXT

RETURN( NIL )



FUNCTION mxCloseAll( aExcept )

   LOCAL nAlias

   IF aExcept = NIL
      mxCloseArea( .T. )
   ELSE
      IF ValType( aExcept ) = "C"
         aExcept := { aExcept }
      ENDIF
      FOR nAlias := 1 TO 255
         DbSelectArea( NumToStr( nAlias ) )
         IF Used() .AND. aScan( aExcept, Upper( Alias() ) ) = 0
            mxCloseArea()
         ENDIF
      NEXT
   ENDIF

RETURN( .T. )



FUNCTION mxGetIndexs()

   LOCAL aIndexs := {}
   LOCAL nIndex  := 0

   DO WHILE ! Empty( IndexKey( ++ nIndex ) )

      aAdd( aIndexs, StrTran( IndexKey( nIndex ), " ", "" ) )

   ENDDO

RETURN( aIndexs )



FUNCTION mxDbStruct( cFile, aField )

   LOCAL aStru := ( cFile )->( xDbStruct() )

   LOCAL nCount, nPos

   vDef( @aField, {} )

   FOR nCount := 1 TO Len( aField )

      nPos := aScan( aStru, { |x| x[1] = aField[ nCount, 1 ] } )

      IF nPos = 0
         aAppend( aStru, { aField[ nCount ] } )
      ELSE
         aStru[ nPos ] := aField[ nCount ]
      ENDIF

   NEXT

RETURN( aStru )



FUNCTION mxLocate( bLocate, lRestore )

   LOCAL lReturn
   LOCAL nRecno := mxRecno()
   
   vDef( @lRestore, .F. )
   
   mxDbRefresh()

   LOCATE ALL FOR Eval( bLocate )
   
   lReturn := Found()
   
   IF lRestore
      mxGoTo( nRecno )
   ENDIF

RETURN( lReturn )



FUNCTION mxSeek( nOrder, uSeek, lSoftSeek, aParams )

   LOCAL lReturn := .F.
   LOCAL nProc   := 1

   LOCAL lRetOrder, nOrdReturn, oErr, cLog

   IF ! EmptyDb()

      TraceLog( "iniciando SEEK " + mxLogRecord( If( ProcName(1) = "CNXSEEK", 2, 1 ) ) )

      lRetOrder := ( aParams <> NIL ) .AND. mxIn( SK_RETORDER, aParams )

      IF lRetOrder
         nOrdReturn := IndexOrd()
      ENDIF

      IF ( nOrder <> NIL ) .AND. ( IndexOrd() <> nOrder )
         mxOrder( nOrder )
      ELSE
         mxConfTrans()
      ENDIF

      uSeek := fmtKeySeek( uSeek, nOrder )

      cLog := Chr(13) + Chr(10) + ProcName(1) + "/" + NumToStr( ProcLine(1) ) + ;
              Chr(13) + Chr(10) + ProcName(2) + "/" + NumToStr( ProcLine(2) ) + ;
              Chr(13) + Chr(10) + ProcName(3) + "/" + NumToStr( ProcLine(3) ) + ;
              Chr(13) + Chr(10) + ProcName(4) + "/" + NumToStr( ProcLine(4) )

      mxDbRefresh()

      TRY
         lReturn := DbSeek( uSeek, lSoftSeek )
      CATCH oErr
         lReturn := .F.
         mxErrorLog( oErr:Description, "mxSeek(): " + Alias() + " / " + NumToStr( nOrder ) + " / " + UtoC( uSeek ) + cLog )
      END

      IF lRetOrder
         mxOrder( nOrdReturn )
      ENDIF

      TraceLog( "SEEK efetuado " + mxLogRecord() )

   ENDIF

RETURN( lReturn )



/*----------------------------------------------------------------------------
 Posiciona no primeiro registro cuja chave de indice satisfaca a expressao
 definida por uKey.
 Funcao utilizada apenas pelo sistema Control Shop na versao mult-lojas.

 Parametros

 nOrd    : Numero da ordem que a procura sera realizada.
 uKey    : Expressao a ser localizada.
 nLoj    : Numero da loja. Complemento de uKey. Utilizado quando a chave de
           indice nao possui controle do numero da loja.
           Se NIL, executa a funcao mxSeek().
 lSoft   : Se .F. posiciona o ponteiro no registro logico seguinte ao registro
           que deveria ter sido encontrado.
 cMsg    : Se # NIL e o registro nao foi encontrado, exibe mensagem.
 cIndKey : Chave opcional, se NIL, utiliza do indice informado.

 Retorno : .T. se registro encontrado, caso contrario .F.
----------------------------------------------------------------------------*/

FUNCTION cnxSeek( nOrd, uKey, nLoj, lSoft, cMsg, cIndKey, lMaster )

   LOCAL lReturn := .F.
   LOCAL cAlias  := Alias()

   LOCAL cCmpLoj, cLog, nCount

   BEGIN SEQUENCE

      vDef( @nOrd   , IndexOrd() )
      vDef( @lMaster, .F. )

      IF ! "CONTROL SHOP" $ Upper( SISTEMA )
         lReturn := mxSeek( nOrd, uKey, lSoft )
         BREAK
      ENDIF

      IF cIndKey = NIL
         cIndKey := mxIndexKey( nOrd )
      ENDIF

      cIndKey := Upper( StrTran( cIndKey, " ", "" ) )

      IF ( nLoj <> NIL ) .AND. ( CFICNXCTR = "M" .OR. ( CFIMLJCTR = "S" .AND. ! lMaster ) ) .AND. At( "NLJ", cIndKey ) = 0

         DO CASE
            CASE Left( cAlias, 4 ) = "TEMP" ; cCmpLoj := "CFINLJ" + Right( FieldName(1), 3 )
            OTHE                            ; cCmpLoj := "CFINLJ" + Subs( cAlias, 3, 3 )
         ENDCASE

         IF FieldPos( cCmpLoj ) = 0

            lReturn := mxSeek( nOrd, uKey, lSoft )

         ELSE

            uKey := fmtKeySeek( uKey, nOrd, @cIndKey )

            IF ValType( uKey ) = "C" .AND. ( Len( &cIndKey ) <> Len( uKey ) )

               cLog := "Parametro incorreto em cnxSeek() !;;" + ;
                       "procura : [^ " + uKey + " ^];" + ;
                       "chave : [^ " + cIndKey + " ^];"

               FOR nCount := 1 TO 3
                  IF ! Empty( ProcName( nCount ) )
                     cLog += ";" + ProcName( nCount ) + "(^" + NumToStr( ProcLine( nCount ) ) + "^)"
                  ENDIF
               NEXT

               IF IsProcedure( "CSW" )
                  cLog += ";Processando arquivo : " + cswActFile()
               ELSE
                  MsgDlg( cLog )
               ENDIF

               mxErrorLOG( StrTran( StrTran( cLog, ";", _NL ), "^", "" ) )

            ENDIF

            mxSeek( nOrd, uKey )

            DO WHILE &cIndKey == uKey .AND. ! Eof()

               IF &cCmpLoj = nLoj
                  lReturn := .T.
                  EXIT
               ENDIF
               mxSkip()

            ENDDO

            IF ! lReturn
               mxBottom()
               mxSkip()
            ENDIF

         ENDIF

      ELSE

         lReturn := mxSeek( nOrd, uKey, lSoft )

      ENDIF

      IF ! lReturn .AND. ( cMsg <> NIL )
         Mensagem( cMsg, 0 )
      ENDIF

   ENDSEQUENCE

RETURN( lReturn )



FUNCTION fmtAlias( cAlias, nLen )

   IF Len( cAlias ) = 3 .AND. sisLenAlias() <> 3
      cAlias := "MX" + cAlias + sisFlgModule()
   ENDIF
   
   IF nLen <> NIL .AND. nLen = 3 .AND. Len( cAlias ) <> 3 .AND. Left( cAlias, 2 ) = "MX"
      cAlias := Subs( cAlias, 3, 3 )
   ENDIF

RETURN( cAlias )



STATIC FUNCTION fmtKeySeek( uSeek, nOrder, cIndKey )

   LOCAL aSeek, cIndex, cKey, cStr, uAux, nCount, nDec, nLen

   IF ValType( uSeek ) = "A"

      aSeek := aClone( uSeek )
      uSeek := NIL

      cIndex := mxIndexKey( nOrder ) + "+"

      cIndKey := ""

      FOR nCount := 1 TO Len( aSeek )

         cKey := Left( cIndex, At( "+", cIndex ) -1 )

         cIndex := Subs( cIndex, At( "+", cIndex ) +1 )

         cIndKey += If( Empty( cIndKey ), "", "+" ) + cKey

         uAux := aSeek[ nCount ]

         IF uAux = NIL
            LOOP
         ENDIF

         IF "DTOS" $ cKey

            IF ValType( uAux ) = "D"
               uAux := DtoS( uAux )
            ENDIF

         ELSEIF "STR" $ cKey

            IF ValType( uAux ) = "N"

               cStr := Subs( cKey, At( ",", cKey ) +1 )
               cStr := Left( cStr, At( ")", cStr ) -1 )
               
               nDec := At( ",", cStr )
               
               IF nDec = 0
                  nLen := Val( cStr )
               ELSE
                  nLen := Val( Left( cStr, nDec -1 ) )
                  nDec := Val( Subs( cStr, nDec +1 ) )
               ENDIF

               uAux := Str( uAux, nLen, nDec )

            ENDIF

         ELSE

            IF Alias() = "MXPEDCFI" .AND. nOrder = 6 .AND. cKey = "CFISTAPED"

               uAux := CapFirst( StrTran( Upper( uAux ), "ORC", "OR‡" ) )

               DO CASE
                  CASE uAux = "Prazp" ; uAux := "PrazP"
                  CASE uAux = "Devop" ; uAux := "DevoP"
                  CASE uAux = "Devpz" ; uAux := "DevPz"
               ENDCASE

            ELSEIF Type( cKey ) = "C"
            
               DO CASE
                  CASE ValType( uAux ) = "N" ; uAux := Str( uAux, Len( &cKey ) )
                  CASE ValType( uAux ) = "C" ; uAux := Left( PadR( uAux, Len( &cKey ) ), Len( &cKey ) )
               ENDCASE
               
            ENDIF

         ENDIF

         IF "UPPER" $ cKey
            uAux := Upper( uAux )
         ENDIF

         IF "MXDESCEND" $ cKey
            uAux := mxDescend( uAux )
         ENDIF

         IF uSeek = NIL
            uSeek := uAux
         ELSE
            uSeek += uAux
         ENDIF

      NEXT

   ENDIF

RETURN( uSeek )



PROCEDURE mxDbRefresh

   LOCAL nRecno, cUpdField

   BEGIN SEQUENCE

      IF ! mxSetDbRefresh()
         BREAK
      ENDIF
      
      IF RddName() <> "SQLRDD"
         BREAK
      ENDIF

      IF isCsw() .AND. foundStr( Subs( Alias(), 3, 3 ), "ACP|CHC|COV|DPC|FCV|ITE|LLP|LLS|MCC|MDC|PGC" )
         BREAK
      ENDIF

      nRecno := mxRecno()
      dbGoTop()
      SR_dbRefresh()
      mxGoTo( nRecno )
      IF IndexOrd() > 0
         cUpdField := &( IndexKey() )
      ENDIF

   ENDSEQUENCE

RETURN



FUNCTION mxSetDbRefresh( lSet )

   LOCAL lReturn := lDbRefresh

   IF lSet <> NIL
      lDbRefresh := lSet
   ENDIF

RETURN( lReturn )



FUNCTION mxRdd( cDef )

   LOCAL cReturn := cMxRdd

   IF cDef <> NIL
      cMxRdd := cDef
   ENDIF

RETURN( cReturn )



FUNCTION mxDataSource( cDef )

   LOCAL cReturn := cDataSource

   IF cDef <> NIL
      cDataSource := cDef
      IF Len( cDataSource ) > 0 .AND. ( Right( cDataSource, 1 ) <> "\" )
         cDataSource += "\"
      ENDIF
   ENDIF

RETURN( cReturn )



FUNCTION mxFLock( cLock, lRepeat, lForever, cMsg, lCheck, cTime )

   LOCAL lReturn     := .F.
   LOCAL lRetry      := .T.
   LOCAL nCountRetry := 100
   LOCAL nLock       := aScan( aNetLock, { |l| l[1] = cLock } )

   LOCAL lOk, nHandle, cCreate, cMsgErro, nCount, cRef, cErrorLog

   IF Len( cLock ) = 3
      cCreate := "MX" + cLock + "CFI"
   ELSE
      cCreate := cLock
   ENDIF

   IF ! IsUseExt( cLock )
      cCreate += ".LCK"
   ENDIF

   vDef( @lCheck, .T. )
   vDef( @cTime , "01:00" )

   IF nLock <> 0

      IF ! aNetLock[ nLock, 4 ]
         RETURN( .T. )
      ENDIF

      cMsgErro := "A opera‡„o de bloqueio do arquivo " + cCreate + " j  foi;"  + ;
                  "efetuada em outro momento, por‚m foi n„o finalizada !;;"    + ;
                  "A opera‡„o executada agora poder  ^resultar em^;"           + ;
                  "^travamentos^ nas demais esta‡”es, sendo necess ria uma;"   + ;
                  "interven‡„o t‚cnica para a corre‡„o do problema.;;"         + ;
                  "Para que os travamentos n„o ocorram o;"                     + ;
                  "sistema ser  finalizado neste momento.;;Referˆncia do erro :"

      cErrorLog := "mxFLock()" + Chr(13) + Chr(10)

      FOR nCount := 1 TO 3

         cRef := ProcName( nCount ) + "(" + NumToStr( ProcLine( nCount ) ) + ")"

         cMsgErro += ";^" + cRef + "^"

         cErrorLog += cRef

         IF nCount <> 3
            cErrorLog += Chr(13) + Chr(10)
         ENDIF

      NEXT

      mxErrorLog( cErrorLog )

      MsgDlg( cMsgErro )

      Fim( 0 )

   ENDIF

   vDef( @lRepeat , .T. )
   vDef( @lForever, .F. )
   vDef( @cMsg    , "Opera‡„o sendo efetuada por outro terminal;(" + cCreate + ")" )

   cRef := mxProcName( 1 )

   DO WHILE lRetry .OR. lForever

      BEGIN SEQUENCE

         lOk   := .F.
         nLock := 0

         timeStart()

         DO WHILE ! timeElapsed( cTime )

            //IF File( cCreate ) .AND. HB_FSize( cCreate ) > 0
            IF File( cCreate )
               FErase( cCreate )
            ENDIF

            IF ! File( cCreate )
               IF nLock = 0
                  nLock := 1
                  Inkey( 0.1 )
                  LOOP
               ENDIF
               lOk := .T.
               EXIT
            ENDIF

            Inkey( 0.01 )

         ENDDO

         IF ! lOk
            IF Empty( cMsg )
               lRetry := .F.
            ELSEIF lForever
               Mensagem( cMsg + " (1/2) !", 1 )
            ELSEIF ! lRepeat
               MsgDlg( cMsg + " (1/2) !" )
               lRetry := .F.
            ELSEIF MsgDlg( cMsg + " (1/2) !", { "Tentar novamente", "Abandonar" } ) = 2
               lRetry := .F.
            ENDIF
            BREAK
         ENDIF

         lOk := .F.

         timeStart()

         DO WHILE ! timeElapsed( cTime )

            IF File( cCreate )
               BREAK
            ENDIF

            nHandle := fCreate( cCreate, FC_NORMAL )

            IF nHandle >= 0
               fWrite( nHandle, cRef, Len( cRef ) )
               lOk := .T.
               InKey( 1 )
               EXIT
            ENDIF

            InKey( 0.01 )

         ENDDO

         IF ! lOk
            IF lForever
               Mensagem( cMsg + " (2/2) !", 1 )
            ELSEIF ! lRepeat
               MsgDlg( cMsg + " (2/2) !" )
               lRetry := .F.
            ELSEIF MsgDlg( cMsg + " (2/2) !", { "Tentar novamente", "Abandonar" } ) = 2
               lRetry := .F.
            ENDIF
            BREAK
         ENDIF

         lReturn := .T.

      ENDSEQUENCE

      IF lReturn

         // 1- Alias do arquivo.
         // 2- Handle do arquivo de bloqueio.
         // 3- Nome do arquivo de bloqueio.
         // 4- Define futuras verificacoes p/ o mesmo arquivo.

         aAdd( aNetLock, { cLock, nHandle, cCreate, lCheck } )
         EXIT

      ENDIF

   ENDDO

RETURN( lReturn )



FUNCTION mxFUnlock( cLock, lCheck )

   LOCAL lReturn := .F.
   LOCAL nLock   := aScan( aNetLock, { |l| l[1] = cLock } )

   BEGIN SEQUENCE

      IF nLock = 0
         BREAK
      ENDIF

      vDef( @lCheck, .T. )

      IF lCheck <> aNetLock[ nLock, 4 ]
         BREAK
      ENDIF

      IF ! Empty( aNetLock[ nLock, 1 ] )
         IF aNetLock[ nLock, 2 ] >= 0
            FClose( aNetLock[ nLock, 2 ] )
         ENDIF
         IF File( aNetLock[ nLock, 3 ] )
            FErase( aNetLock[ nLock, 3 ] )
         ENDIF
      ENDIF

      aDel( aNetLock, nLock )
      aSize( aNetLock, Len( aNetLock ) -1 )

      lReturn := .T.

   ENDSEQUENCE

RETURN( lReturn )



FUNCTION lckOper( cAlias, uLock, uCodigo )

   LOCAL lReturn := .T.
   LOCAL cFile   := ""
   LOCAL nPos

   BEGIN SEQUENCE

      IF uCodigo = NIL
         cFile := "MX" + cAlias + "CFI->CFICOD" + cAlias
         IF ! isDef( cFile )
            BREAK
         ENDIF
         IF cAlias = "DUP"
            cFile := StrZero( MXDUPCFI->CFICODDUP, 8 ) + PadR( Trim( MXDUPCFI->CFICPLDUP ), 2, "!" )
         ELSE
            cFile := StrZero( &cFile, 14 )
         ENDIF
      ELSE
         IF ValType( uCodigo ) = "N"
            cFile := StrZero( uCodigo, 14 )
         ELSEIF cAlias = "DUP"
            cFile := Left( uCodigo, 8 ) + PadR( Trim( Right( uCodigo, 2 ) ), 2, "!" )
         ELSE
            cFile := Left( uCodigo, 8 )
         ENDIF
      ENDIF

      cFile += "." + If( cAlias = "BOL", "LCK", cAlias )

      nPos := aScan( aLckOper, cFile )

      IF uLock = NIL  // Desbloqueio

         IF nPos > 0
            mxFUnlock( aLckOper[ nPos ] )
            aDelPos( aLckOper, nPos )
         ENDIF
         BREAK

      ENDIF

      // Bloqueio

      IF nPos > 0
         MsgDlg( "Esta opera‡„o j  est  sendo efetuada;por este terminal !" )
         lReturn := .F.
         BREAK
      ENDIF

      IF ValType( uLock ) = "L" .AND. ( ! uLock )
         BREAK
      ELSEIF ValType( uLock ) = "N" .AND. mxIn( uLock, { K_INCLUIR, K_CONSULTAR } )
         BREAK
      ENDIF

      Status( "Aguarde, bloqueando opera‡„o..." )

      IF ! mxFLock( cFile, .F., NIL, NIL, NIL, "00:15" )
         lReturn := .F.
         BREAK
      ENDIF

      aAdd( aLckOper, cFile )

   ENDSEQUENCE

RETURN( lReturn )



FUNCTION mxGetBM()

   LOCAL aBookMark := { mxRecNo(), IndexOrd(), Alias() }

RETURN( aBookMark )



FUNCTION mxGoToBM( aBookMark )

   LOCAL cAlias

   IF aBookMark <> NIL
      cAlias := aBookMark[ 3 ]
      ( cAlias )->( mxOrder( aBookMark[ 2 ] ) )
      ( cAlias )->( mxGoTo( aBookMark[ 1 ] ) )
   ENDIF

RETURN( aBookMark )



FUNCTION GetBookMark()

   LOCAL cAlias := Upper( Alias() )
   LOCAL nPos   := GetBookPos( cAlias, .T. )
   LOCAL aInfo  := aRecOrd[ nPos, 2 ]

   aAdd( aInfo, { mxRecNo(), IndexOrd() } )

   aRecOrd[ nPos, 2 ] := aInfo

RETURN( .T. )



FUNCTION GotoBookMark()

   LOCAL cAlias := Upper( Alias() )
   LOCAL nPos   := GetBookPos( cAlias )
   LOCAL aInfo

   IF nPos <> 0

      aInfo := aRecOrd[ nPos, 2 ]

      mxOrder( aInfo[ Len( aInfo ), 2 ] )
      mxGoto( aInfo[ Len( aInfo ), 1 ] )

      DelBookMark( nPos )

   ENDIF

RETURN( .T. )



FUNCTION DelBookMark( nPos )

   LOCAL cAlias := Upper( Alias() )
   LOCAL aInfo

   IF nPos = NIL
      nPos := GetBookPos( cAlias )
   ENDIF

   IF nPos <> 0

      aInfo := aRecOrd[ nPos, 2 ]

      aDel( aInfo, Len( aInfo ) )
      aSize( aInfo, Len( aInfo ) -1 )

      IF Len( aInfo ) = 0 .AND. Len( aRecOrd ) > 0
         aDel( aRecOrd, nPos )
         aSize( aRecOrd, Len( aRecOrd ) -1 )
      ELSE
         aRecOrd[ nPos, 2 ] := aInfo
      ENDIF

   ENDIF

RETURN( .T. )



STATIC FUNCTION GetBookPos( cAlias, lAppend )

   LOCAL nPos := 0

   vDef( @lAppend, .F. )

   IF Len( aRecOrd ) > 0 .AND. aRecOrd[ Len( aRecOrd ), 1 ] = cAlias

      nPos := Len( aRecOrd )

   ELSEIF Len( aRecOrd ) > 0 .AND. aRecOrd[ 1, 1 ] = cAlias

      nPos := 1

   ELSE

      nPos := aScan( aRecOrd , { |x| x[1] = cAlias } )

      IF nPos = 0 .AND. lAppend
         aAdd( aRecOrd, { cAlias, {} } )
         nPos := Len( aRecOrd )
      ENDIF

   ENDIF

RETURN( nPos )



FUNCTION mxLogRecord( nProc )

   LOCAL cReturn := ""

   IF TraceSet()
      cReturn := "(" + Alias() + "/" + NumToStr( mxRecno() ) + ")"
      IF nProc <> NIL
         cReturn += " -> proc: " + ProcName( nProc +1 ) + "/" + NumToStr( ProcLine( nProc +1 ) )
      ENDIF
   ENDIF

RETURN( cReturn )



FUNCTION TraceSet( lTrace )

   LOCAL lReturn := lBDTrace

   IF lTrace <> NIL
      lBDTrace := lTrace
   ENDIF

RETURN( lReturn )



FUNCTION TraceLog( cLog )

   IF TraceSet()
      mxFAddLine( "LOGS\MXTRACE.LOG", Time() + "  " + cLog )
   ENDIF

RETURN( NIL )



FUNCTION ConfRec( nRecord, cMsg, cErro )

   LOCAL lReturn := .F.

   BEGIN SEQUENCE

      IF ( nRecord <> NIL ) .AND. nRecord = mxRecNo()
         cErro := "Erro ao processar o arquivo de " + cMsg + " !;Reorganize-o antes de executar;novamente este m¢dulo."
         BREAK
      ENDIF

      nRecord := mxRecNo()
      lReturn := .T.

   ENDSEQUENCE

RETURN( lReturn )



FUNCTION Repl_Field( cAliasOri, cAliasDes, lAppend, lUnlock, cDefCampo, aExcCampo, aRepl_Personalizado )

   LOCAL cCampoOri, cCampoDes, nCount

   vDef( @lAppend, .F. )
   vDef( @lUnlock, .T. )

   IF lAppend
      ( cAliasDes )->( mxAppend( NIL, .F. ) )
   ELSE
      ( cAliasDes )->( mxRecLock( NIL, .F. ) )
   ENDIF

   FOR nCount := 1 TO ( cAliasDes )->( FCount() )

      cCampoDes := ( cAliasDes )->( FieldName( nCount ) )
      cCampoOri := cCampoDes

      IF cDefCampo <> NIL
         IF cDefCampo = "ORI"
            cCampoOri := Left( cCampoOri, 6 ) + Subs( cAliasOri, 3, 3 )
         ELSE
            cCampoDes := Left( cCampoDes, 6 ) + Subs( cAliasDes, 3, 3 )
         ENDIF
      ENDIF

      IF ( aExcCampo <> NIL ) .AND. mxIn( Subs( cCampoDes, 4, 3 ), aExcCampo )
         LOOP
      ENDIF

      IF cCampoDes = "R_KEYCTR"
         LOOP
      ENDIF

      IF ( cAliasDes )->( FieldPos( cCampoDes ) ) > 0 .AND. ;
         ( cAliasOri )->( FieldPos( cCampoOri ) ) > 0

         ( cAliasDes )->( mxReplace( cCampoDes, &( cAliasOri + "->" + cCampoOri ) ) )

      ENDIF

   NEXT
   
   IF aRepl_Personalizado <> NIL
      FOR nCount := 1 TO Len( aRepl_Personalizado )
         ( cAliasDes )->( mxReplace( aRepl_Personalizado[ nCount, 1 ], aRepl_Personalizado[ nCount, 2 ] ) )
      NEXT
   ENDIF

   IF lUnlock
      ( cAliasDes )->( mxUnlock(.F.) )
   ENDIF

RETURN( NIL )



FUNCTION dbFile( cFile, cRdd )

   LOCAL lReturn, nConnSave
   
   vDef( @cRdd, mxRdd() )

   IF Empty( cFile )

      lReturn := .F.

   ELSEIF cRdd = "SQLRDD"

      lReturn := .F.

      IF Len( GetPath( cFile ) ) > 1  // Outro database ou schema

         nConnSave := sqlSetConn( NIL                          ,;
                                  sqlGetInfo( cFile, "DTB"    ),;
                                  sqlGetInfo( cFile, "SCHEMA" ) )

      ENDIF

      IF ! sqlCheckConn( NIL, "Problema ao verificar a existˆncia de;^" + cFile + "^" )  // Verifica se a conexao ainda esta ativa
         lReturn := .F.
      ELSE
         cFile := GetNameFile( cFile )
         IF "?" $ cFile .OR. "*" $ cFile
            lReturn := ( Len( sqlDirectory( cFile ) ) > 0 )
         ELSEIF GetExt( cFile ) = ".CDX"
            lReturn := SR_Exec( { || SR_File( cFile ) } )
         ELSE
            IF GetExt( cFile ) = ".DBF"
               cFile := DelExt( cFile )
            ELSE
               cFile := StrTran( cFile, ".", "_" )
            ENDIF
            lReturn := SR_Exec( { || SR_ExistTable( cFile ) } )
         ENDIF
      ENDIF

      IF nConnSave <> NIL
         sqlSetConn( nConnSave )
      ENDIF

   ELSE

      lReturn := File( cFile )

   ENDIF

RETURN( lReturn )



FUNCTION dbIsOpen( cAlias )

   LOCAL nSelect := Select()
   LOCAL lReturn := ( Select( cAlias ) > 0 )

   IF nSelect > 0
      Select( nSelect )
   ENDIF

RETURN( lReturn )



FUNCTION EmptyDb()

   LOCAL lReturn := ( RecCount() = 0 )
   LOCAL nRecno  := mxRecno()

   IF ! lReturn .AND. RddName() <> "SQLRDD"
      dbGoTop()
      lReturn := ( ! mxLocate( { || ! Deleted() } ) )
      dbGoTo( nRecno )
   ENDIF

RETURN( lReturn )



FUNCTION SeleArea( cArea )

   IF cArea <> NIL .AND. Len( cArea ) > 0
      IF AllTrim( Str( Val( cArea ), 3 ) ) = AllTrim( cArea )
         SELE &cArea
      ELSEIF Select( cArea ) > 0
         Select( cArea )
      ENDIF
   ENDIF

RETURN( NIL )



FUNCTION defFileClose( aFiles )

   LOCAL aReturn := {}
   LOCAL cAlias

   IF ValType( aFiles ) = "C"
      aFiles := { aFiles }
   ENDIF

   aEval( aFiles, { |a| cAlias := "MX" + a + sisFlgModule(), If( Select( cAlias ) = 0, aAdd( aReturn, cAlias ), NIL ) } )

RETURN( aReturn )



FUNCTION defReplace( cAlias1, cAlias2 )

   LOCAL aReplace := {}
   LOCAL aFields1 := ( cAlias1 )->( xDbStruct() )
   LOCAL aFields2 := ( cAlias2 )->( xDbStruct() )

   LOCAL cField, cReplace, nCount, nField

   FOR nCount := 1 TO Len( aFields2 )

      nField := aScan( aFields1, { |f| f[1] = aFields2[ nCount, 1 ] } )

      IF nField > 0

         cField   := cAlias1 + "->" + aFields1[ nField, 1 ]
         cReplace := cAlias2 + "->" + aFields2[ nCount, 1 ]

         IF aFields2[ nCount, 2 ] <> aFields1[ nField, 2 ]

            DO CASE
               CASE aFields1[ nField, 2 ] = "C"
                    DO CASE
                       CASE aFields2[ nCount, 2 ] = "N" ; cReplace := "LTrim( Str( " + cReplace + " ) )"
                       CASE aFields2[ nCount, 2 ] = "D" ; cReplace := "DtoC( " + cReplace + " )"
                       CASE aFields2[ nCount, 2 ] = "L" ; cReplace := "If( " + cReplace + ", 'S', 'N' )"
                    ENDCASE
               CASE aFields1[ nField, 2 ] = "N"
                    DO CASE
                       CASE aFields2[ nCount, 2 ] = "C" ; cReplace := "Val( " + cReplace + " )"
                       CASE aFields2[ nCount, 2 ] = "D" ; cReplace := "Val( DtoS( " + cReplace + " ) )"
                       CASE aFields2[ nCount, 2 ] = "L" ; cReplace := "If( " + cReplace + ", 1, 0 )"
                       CASE aFields2[ nCount, 2 ] = "M" ; cReplace := "Val( " + cReplace + " )"
                    ENDCASE
               CASE aFields1[ nField, 2 ] = "D"
                    DO CASE
                       CASE aFields2[ nCount, 2 ] = "C" ; cReplace := "CtoD( " + cReplace + " )"
                       CASE aFields2[ nCount, 2 ] = "M" ; cReplace := "CtoD( " + cReplace + " )"
                    ENDCASE
               CASE aFields1[ nField, 2 ] = "L"
                    DO CASE
                       CASE aFields2[ nCount, 2 ] = "N" ; cReplace := "If( " + cReplace + " =  0 , .F., .T. )"
                       CASE aFields2[ nCount, 2 ] = "C" ; cReplace := "If( " + cReplace + " = 'S', .T., .F. )"
                       CASE aFields2[ nCount, 2 ] = "M" ; cReplace := "If( " + cReplace + " = 'S', .T., .F. )"
                    ENDCASE
               CASE aFields1[ nField, 2 ] = "M"
                    DO CASE
                       CASE aFields2[ nCount, 2 ] = "N" ; cReplace := "Str( " + cReplace + " )"
                       CASE aFields2[ nCount, 2 ] = "D" ; cReplace := "DtoC( " + cReplace + " )"
                       CASE aFields2[ nCount, 2 ] = "L" ; cReplace := "If( " + cReplace + ", 'S', 'N' )"
                       CASE aFields2[ nCount, 2 ] = "C" ; cReplace := "If( " + cReplace + ", 'S', 'N' )"
                    ENDCASE
            ENDCASE

         ENDIF

         aAdd( aReplace, { cField, cReplace } )

      ENDIF

   NEXT

RETURN( aReplace )



FUNCTION sepAliasField( cSep, cAlias, cField )

   cAlias := Subs( cSep, 1, At( "->", cSep ) - 1 )
   cField := Subs( cSep   , At( "->", cSep ) + 2 )

RETURN( NIL )



FUNCTION SetVars( aNoSet, lReset, aRecords, aDefReplace )

   LOCAL aFields := {}
   LOCAL nVarCount, cVar, nReplace, uReplace

   IF Used()

      vDef( @aNoSet, {}  )
      vDef( @lReset, .F. )

      mxDbRefresh()

      // Atribui os valores dos campos as variaveis.

      FOR nVarCount := 1 TO FCount()

         cVar := Right( Field( nVarCount ), 6 )

         IF aScan( aNoSet, cVar ) = 0
            DO CASE
               CASE ! lReset                               ; &cVar := FieldGet( nVarCount )
               CASE ValType( FieldGet( nVarCount ) ) = "N" ; &cVar := 0
               CASE ValType( FieldGet( nVarCount ) ) = "D" ; &cVar := CtoD( "" )
               CASE ValType( FieldGet( nVarCount ) ) = "L" ; &cVar := .F.
               OTHERWISE                                   ; &cVar := Space( Len( FieldGet( nVarCount ) ) )
            ENDCASE
         ENDIF
         
         IF aRecords <> NIL
         
            nReplace := 0
            IF aDefReplace <> NIL
               nReplace := aScan( aDefReplace, { |x| x[1] = cVar } )
            ENDIF
            
            IF nReplace = 0
               uReplace := &cVar
            ELSE
               uReplace := aDefReplace[ nReplace, 2 ]
            ENDIF
            
            aAdd( aFields, { cVar, uReplace } )
            
         ENDIF

      NEXT

      IF aRecords <> NIL
         aAdd( aRecords, aFields )
      ENDIF
      
   ENDIF

RETURN( aClone( aRecords ) )



FUNCTION ResetVars( aNoReset )

   IF Used()

      /*
      GetBookMark()            // Salva o numero do registro.

      mxBottom()               // Posiciona no ultimo registro.
      mxSkip()                 // Avanca para posicao de EOF() para utilizar
                               // os valores vazios.
      */

      SetVars( aNoReset, .T. )      // Atribui os valores vazios dos campos as varivaveis.

      //GoToBookMark()           // Retorna a posicao de origem.
      
   ENDIF

RETURN( NIL )



FUNCTION SaveVars( lAppend, aConfCod, aNoSave, lForceSeq, nMode, lConfVar, aRecords )

   LOCAL nCod, nVarCount, uVar, cVar, nTotRecords, nRecord, cField

   #define POS_CAMPO  1
   #define POS_ORDEM  2
   #define POS_LIMIT  3
   #define POS_LOJA   4

   vDef( @nMode, 1 )
   
   BEGIN SEQUENCE

      IF ! Used()
         BREAK
      ENDIF

      vDef( @lAppend  , .F. )
      vDef( @aNoSave  , {}  )
      vDef( @lForceSeq, .F. )
      vDef( @lConfVar , .F. )
      
      IF aRecords = NIL
         nTotRecords := 1
      ELSE
         nTotRecords := Len( aRecords )
      ENDIF
      
      FOR nRecord := 1 TO nTotRecords

         IF ! lAppend

            IF nRecord = 1
               GetBookMark()
            ENDIF

            IF nMode = 1
               mxRecLock()  // Bloqueia um registro.
            ENDIF

         ELSEIF aConfCod <> NIL

            aSize( aConfCod, POS_LOJA )

            uVar := Right( aConfCod[ POS_CAMPO ], 6 )
            nCod := &uVar

            AddCodigo( @nCod,;
                       aConfCod[ POS_CAMPO ],;
                       aConfCod[ POS_ORDEM ],;
                       aConfCod[ POS_LIMIT ],;
                       aConfCod[ POS_LOJA  ],;
                       lForceSeq ) // Este ultimo parametro forca a sequencia pelo MXCODCFI.

            &uVar := nCod

         ELSEIF nMode = 1  // Adiciona um registro.
            mxAppend()
         ELSE
            DbAppend()
         ENDIF

         // Grava as variveis nos campos.

         IF aRecords = NIL

            FOR nVarCount := 1 TO FCount()
               IF dbKeyControl() .AND. foundStr( Field( nVarCount ), "R_KEYCTR|BKP_UPD|BKP_CTR" )
                  LOOP
               ENDIF
               cVar := Right( Field( nVarCount ), 6 )
               IF aScan( aNoSave, cVar  ) = 0 .AND. ( ! lConfVar .OR. IsDef( cVar ) )
                  mxReplace( Alias() + "->" + Field( nVarCount ), &cVar )
               ENDIF
            NEXT

         ELSE
         
            FOR nVarCount := 1 TO Len( aRecords[ nRecord ] )
               cVar   := aRecords[ nRecord, nVarCount, 1 ]
               cField := "CFI" + cVar
               IF dbKeyControl() .AND. foundStr( cField, "R_KEYCTR|BKP_UPD|BKP_CTR" )
                  LOOP
               ENDIF
               IF aScan( aNoSave, cVar  ) = 0 .AND. ( ! lConfVar )
                  mxReplace( Alias() + "->" + cField, aRecords[ nRecord, nVarCount, 2 ] )
               ENDIF
            NEXT

         ENDIF

         // Atualiza os buffers e desbloqueia.

         IF nMode = 1
            mxUnlock(.F.)
         ENDIF

      NEXT

      IF ! lAppend .AND. nTotRecords > 0
         GoToBookMark()
      ENDIF
      
   ENDSEQUENCE
   
   IF aConfCod <> NIL
      vDef( @nCod, 0 )
   ENDIF

RETURN( nCod )



FUNCTION DelVars()

   LOCAL nCount, cVar

   FOR nCount := 1 TO FCount()
      cVar := Right( Field( nCount ), 6 )
      IF IsDef( cVar )
         RELEASE &cVar
      ENDIF
   NEXT

RETURN( NIL )



//--- Funcoes para definicao de codigos

FUNCTION DefTabCodigos( lGet )

   vDef( @lGet, .F. )

   BEGIN SEQUENCE
   
      IF lGet
         BREAK
      ENDIF

      aCtrCodigos := {}

      IF Select( "MXCODCFI" ) = 0
         BREAK
      ENDIF

      MXCODCFI->( mxTop() )

      DO WHILE MXCODCFI->( !Eof() )

         aAdd( aCtrCodigos, { ;
                              AllTrim( MXCODCFI->CFICMPCOD ),;
                              MXCODCFI->( mxRecNo() )        ;
                            } )

         MXCODCFI->( mxSkip() )

      ENDDO

   ENDSEQUENCE

RETURN( aCtrCodigos )



FUNCTION AddCodigo( uCodBas   ,;
                    cCampo    ,;
                    nOrdem    ,;
                    nLimite   ,;
                    nLoja     ,;
                    lForceSeq ,;
                    lConfSeq  ,;
                    bAjustaCod,;
                    lConfTab )

   LOCAL lFLock := .F.

   LOCAL cAlias, nCod, cCampoLoj, cCampoCOD, cLock, uCodLoc, bWhile, cTela

   vDef( @uCodBas  ,            0 )
   vDef( @nOrdem   ,            1 )
   vDef( @nLimite  , 999999999999 )
   vDef( @lForceSeq, .F.          )
   vDef( @lConfSeq , .F.          )
   vDef( @lConfTab , .F.          )

   DefCampoCod( @cAlias, @cCampo, @cCampoCOD )

   IF ( ! mxTransMode() ) .OR. Empty( GetActTrans() )

      IF Select( cAlias ) = 0
         lFLock := sqlActive()
      ELSE
         lFLock := ( cAlias )->( RddName() ) = "SQLRDD"
      ENDIF

   ENDIF

   cCampoLoj := Left( cCampoCOD, 3 ) + "NLJ" + Right( cCampoCOD, 3 )

   IF uCodBas = 0
      uCodBas := GetSeqCodigo( cCampo, nOrdem, nLimite, nLoja )
   ENDIF

   IF Len( aCtrCodigos ) > 0 .AND. Select( "MXCODCFI" ) > 0

      // Localiza o controle na matriz

      nCod := aScan( aCtrCodigos, { |c| c[ POS_CODCMP ] = cCampoCOD } )

      IF nCod > 0

         // Se encontrado, posiciona no registro informado pela matriz.

         MXCODCFI->( mxDbRefresh() )
         MXCODCFI->( mxGoTo( aCtrCodigos[ nCod, POS_CODREC ] ) )

         // Consiste se o registro e correto.

         IF MXCODCFI->( mxRecNo() ) = aCtrCodigos[ nCod, POS_CODREC ]

            // Bloqueia o registro para gerar a sequencia

            MXCODCFI->( mxRecLock( NIL, .F. ) )

            IF MXCODCFI->( FieldPos( "CFIORDCOD" ) ) > 0
               nOrdem := MXCODCFI->CFIORDCOD
            ENDIF

            codLimite( @nLimite, cCampoCOD )

            IF lForceSeq

               uCodBas := MXCODCFI->CFISEQCOD + 1

            ELSE
            
               IF Empty( uCodBas ) .OR. uCodBas > nLimite
                  uCodBas := codSequencia( cCampo, nOrdem, nLimite )
               ENDIF

               // Localiza a sequencia no arquivo - caso ja exista, incrementa.

               IF nOrdem <> 0
               
                  uCodLoc := codMultLojas( uCodBas, cCampo, nLoja, nLimite )
                  
                  IF foundStr( cCampoCOD, "CFICODCHQ|CFICODCCD|CFICODPAG|CFICODRCP|CFICODRET|CFICODBLC" )
                     bWhile := { || ( cAlias )->( mxSeek( nOrdem, { uCodLoc, nLoja } ) ) }
                  ELSE
                     bWhile := { || ( cAlias )->( cnxSeek( nOrdem, uCodLoc, nLoja ) ) }
                  ENDIF
                  
                  cTela := SaveScreen( MaxRow(), 00, MaxRow(), MaxCol() )

                  DO WHILE Eval( bWhile )
                  
                     IF uCodBas >= nLimite
                        uCodBas := nLimite
                        EXIT
                     ENDIF
                     
                     uCodLoc := codMultLojas( ++ uCodBas, cCampo, nLoja, nLimite )
                     
                     mxWait( "analisando sequencia valida (" + Subs( cAlias, 3, 3 ) + ")" )

                  ENDDO
                  
                  RestScreen( MaxRow(), 00, MaxRow(), MaxCol(), cTela )
                  
               ENDIF
            
            ENDIF

            // Grava a sequencia no arquivo de controle.

            IF lForceSeq .OR. uCodBas > MXCODCFI->CFISEQCOD .OR. MXCODCFI->CFISEQCOD = nLimite
               codGrvSequence( uCodBas )
            ELSE
               MXCODCFI->( mxUnlock(.F.) )
            ENDIF

            IF uCodBas <= nLimite
               uCodBas := codMultLojas( uCodBas, cCampo, nLoja, nLimite )
            ENDIF
            
            IF bAjustaCod <> NIL
               uCodBas := Eval( bAjustaCod, uCodBas )
            ENDIF

            // Confere se a gravacao esta na sequencia correta com o arquivo.

            IF lConfSeq .AND. ( cAlias )->( RddName() ) <> "DBFCDX"
               ( cAlias )->( mxBottom( nOrdem ) )
               IF ( cAlias )->( &cCampo ) >= uCodBas
                  IF lConfTab
                     uCodBas := ( cAlias )->( &cCampo ) + 1
                     codGrvSequence( uCodBas, aCtrCodigos[ nCod, POS_CODREC ] )
                  ELSE
                     IF ! Empty( GetActTrans() )
                        mxTranEnd( .F., GetActTrans() )
                     ENDIF
                     MsgDlg( "N„o foi poss¡vel gerar corretamente;" + ;
                             "a sequˆncia de c¢digo.;;"             + ;
                             "Comunique nosso suporte t‚cnico;"     + ;
                             "imediatamente !;;"                    + ;
                             "*** O sistema ser  finalizado ***;"   + ;
                             "[ " + MXCODCFI->CFICMPCOD + " ]" )
                     Fim( 0 )
                  ENDIF
               ENDIF
            ENDIF

            ( cAlias )->( mxAppend( NIL, .F. ) )  // Adiciona o novo registro.

            ( cAlias )->( mxReplace( cCampo, uCodBas ) )  // Grava a sequencia no arquivo desejado.

            // Caso seja mult-lojas, grava o numero da loja no arquivo.

            IF nLoja <> NIL .AND. ( cAlias )->( FieldPos( cCampoLoj ) ) > 0
               ( cAlias )->( mxReplace( cCampoLoj, nLoja ) )
            ENDIF

            ( cAlias )->( mxDbCommit() )

            RETURN( .T. )

         ENDIF

      ENDIF

   ENDIF

   // Metodos antigos serao utilizados caso nao haja o processo
   // de controle com MXCODCFI.

   IF lFLock
      cLock := Left( cAlias, Len( cAlias ) -3 ) + "COD"
      mxFLock( cLock, .T. )
   ELSEIF ( cAlias )->( RddName() ) <> "SQLRDD"
      ( cAlias )->( BFile( NIL, .F. ) )
   ENDIF

   IF COD_MULTLJ( cCampo )
      uCodBas := codMultLojas( uCodBas, cCampo, nLoja, nLimite )
      IF foundStr( Right( cCampo, 9 ), "CFICODCLI|CFICODMAD|CFICODNOE" )
         nLimite := Val( "999" + NumToStr( nLimite ) )
      ELSE
         nLimite := Val( "999999" + NumToStr( nLimite ) )
      ENDIF
   ENDIF

   IF nOrdem <> 0

      IF foundStr( cCampoCOD, "CFICODCHQ|CFICODCCD|CFICODPAG|CFICODRCP|CFICODRET|CFICODBLC" )
         bWhile := { || ( cAlias )->( mxSeek( nOrdem, { uCodBas, nLoja } ) ) }
      ELSE
         bWhile := { || ( cAlias )->( cnxSeek( nOrdem, uCodBas, nLoja ) ) }
      ENDIF

      DO WHILE Eval( bWhile )
         ( cAlias )->( mxBottom( nOrdem ) )
         uCodBas := &cCampo + 1
         IF uCodBas >= nLimite
            uCodBas := nLimite
            EXIT
         ENDIF
      ENDDO
      
   ENDIF

   ( cAlias )->( mxAppend( NIL, .F. ) )

   ( cAlias )->( mxReplace( cCampo, uCodBas ) )

   IF nLoja <> NIL .AND. ( cAlias )->( FieldPos( cCampoLoj ) ) > 0
      ( cAlias )->( mxReplace( cCampoLoj, nLoja ) )
   ENDIF

   IF lFLock
      mxFUnlock( cLock )
   ENDIF

RETURN( .T. )



FUNCTION codMultLojas( uCodBas, cCampo, nLoja, nLimite )

   IF COD_MULTLJ( cCampo )
      IF foundStr( Right( cCampo, 9 ), "CFICODCLI|CFICODMAD|CFICODNOE" )
         uCodBas := Val( StrZero( CFINLJCTR, 3 ) + StrZero( uCodBas, Len( NumToStr( nLimite ) ) ) )
      ELSE
         uCodBas := Val( StrZero( nLoja, 3 ) + StrZero( CFINLJCTR, 3 ) + StrZero( uCodBas, Len( NumToStr( nLimite ) ) ) )
      ENDIF
   ENDIF
   
RETURN( uCodBas )



FUNCTION codUpdate( cCampo, uCodBas )

   LOCAL lTrans := Empty( GetActTrans() )

   LOCAL cAlias, cCampoCOD

   DefCampoCod( @cAlias, @cCampo, @cCampoCOD )

   IF Len( aCtrCodigos ) > 0 .AND. Select( "MXCODCFI" ) > 0

      // Localiza o controle na matriz

      nCod := aScan( aCtrCodigos, { |c| c[ POS_CODCMP ] = cCampoCOD } )

      IF nCod > 0

         IF lTrans
            mxTran( "UPD_CODIGO", { "COD" }, .F. )
         ENDIF

         // Se encontrado, posiciona no registro informado pela matriz.

         MXCODCFI->( mxDbRefresh() )
         MXCODCFI->( mxGoTo( aCtrCodigos[ nCod, POS_CODREC ] ) )

         IF MXCODCFI->CFISEQCOD < uCodBas
            MXCODCFI->( mxRecLock( NIL, .F. ) )
            codGrvSequence( uCodBas )
         ENDIF

         IF lTrans
            mxTran( "UPD_CODIGO" )
         ENDIF

      ENDIF

   ENDIF

RETURN( NIL )



FUNCTION GetSeqCodigo( cCampo, nOrdem, nLimite, nLoja, lZeraSeq )

   LOCAL nReturn, cCodCampo
   
   vDef( @lZeraSeq, .F. )

   IF "->" $ cCampo
      cCampoCOD := Subs( cCampo, At( "->", cCampo ) + 2 )
   ELSE
      cCampoCOD := cCampo
   ENDIF

   IF nLoja <> NIL .AND. nLoja <> 999 .AND. CFICNXCTR = "M" .AND. ( ! COD_MULTLJ( cCampoCOD ) ) .AND. ( IsValue( "lSeqOnLine", .T. ) .OR. cnxOnLine( nLoja ) )
      nReturn := olSolicCod( cCampo, nOrdem, nLimite, nLoja )
   ELSE
      nReturn := codSequencia( cCampo, nOrdem, nLimite, NIL, NIL, lZeraSeq )
   ENDIF
   
RETURN( nReturn )



FUNCTION codSequencia( cCampo, nOrdem, nLimite, lGrava, nAdd, lZeraSeq )

   LOCAL lTrans := Empty( GetActTrans() )

   LOCAL cAlias, nCod, uCodBas, cCampoCOD

   vDef( @nOrdem  ,            1 )
   vDef( @nLimite , 999999999999 )
   vDef( @nAdd    ,            1 )
   vDef( @lGrava  , .F.          )
   vDef( @lZeraSeq, .F.          )

   DefCampoCod( @cAlias, @cCampo, @cCampoCOD )

   IF Len( aCtrCodigos ) > 0 .AND. Select( "MXCODCFI" ) > 0

      // Localiza o controle na matriz

      nCod := aScan( aCtrCodigos, { |c| c[ POS_CODCMP ] = cCampoCOD } )

      IF nCod > 0

         // Se encontrado, posiciona no registro informado pela matriz.

         MXCODCFI->( mxDbRefresh() )
         MXCODCFI->( mxGoTo( aCtrCodigos[ nCod, POS_CODREC ] ) )

         // Consiste se o registro e correto.

         IF MXCODCFI->( mxRecNo() ) = aCtrCodigos[ nCod, POS_CODREC ]

            IF lGrava
               IF lTrans
                  mxTran( "CODSEQUENCIA", { "COD" }, .F. )
               ENDIF
               MXCODCFI->( mxRecLock( NIL, .F. ) )
            ENDIF

            IF MXCODCFI->( FieldPos( "CFIORDCOD" ) ) > 0
               nOrdem := MXCODCFI->CFIORDCOD
            ENDIF

            codLimite( @nLimite, cCampoCOD )

            // Gera a sequencia

            uCodBas := MXCODCFI->CFISEQCOD + nAdd

            IF uCodBas > nLimite
               IF ! lZeraSeq .AND. ! foundStr( cCampoCOD, COD_DIRECT )
                  MsgDlg( "O limite de c¢digos para o campo;^" + ;
                          cCampoCOD + "^ est  esgotado.;" + ;
                          "[Atual: " + NumToStr( uCodBas ) + " / Limite: " + NumToStr( nLimite ) + "];;" + ;
                          "Comunique nosso suporte t‚cnico;"   + ;
                          "imediatamente !;;"                  + ;
                         "*** O sistema ser  finalizado ***" )
                  Fim( 0 )
               ENDIF
               uCodBas := 0
            ENDIF
            
            IF lGrava
               IF uCodBas > MXCODCFI->CFISEQCOD .OR. ( uCodBas = 0 .AND. foundStr( cCampoCOD, COD_DIRECT ) )
                  codGrvSequence( uCodBas )
               ELSE
                  MXCODCFI->( mxUnlock(.F.) )
               ENDIF
               IF lTrans
                  mxTran( "CODSEQUENCIA" )
               ENDIF
            ENDIF

         ENDIF

      ENDIF

   ENDIF

   IF ( uCodBas = NIL .OR. uCodBas = nLimite ) .AND. ! foundStr( cCampoCOD, COD_DIRECT )

      // Metodos antigos, serao utilizados caso nao haja o processo de
      // controle com MXCODCFI.

      ( cAlias )->( mxBottom( nOrdem ) )

      uCodBas := &cCampo + nAdd

      IF uCodBas >= nLimite
         uCodBas := nLimite
      ENDIF

   ENDIF

RETURN( uCodBas )



STATIC FUNCTION DefCampoCod( cAlias, cCampo, cCampoCOD )

   IF cAlias <> NIL
      cAlias := Upper( cAlias )
   ENDIF

   cCampo    := Upper( cCampo )
   cCampoCOD := cCampo

   IF At( "->", cCampo ) = 0
      cAlias    := Alias()
      cCampo    := cAlias + "->" + cCampo
   ELSE
      cAlias    := Subs( cCampoCOD, 1, At( "->", cCampoCOD ) - 1 )
      cCampoCOD := Subs( cCampoCOD   , At( "->", cCampoCOD ) + 2 )
   ENDIF

RETURN( NIL )



FUNCTION defCodigos( cCodigo, nOrder, nVar1, nVar2, lVerLoja )

   LOCAL cAlias := If( "->" $ cCodigo, Left( cCodigo, At( "->", cCodigo ) -1 ), Left( cCodigo, 8 ) )

   vDef( @lVerLoja, .T. )

   IF lVerLoja .OR. cCodigo <> "MXLOJCFI->CFICODLOJ"

      ( cAlias )->( mxBottom( nOrder ) )
      nVar2 := &cCodigo

      IF CS_MODO_ONLINE .AND. cCodigo = "MXLOJCFI->CFICODLOJ" .AND. nVar2 = 999
         ( cAlias )->( mxSkip( -1 ) )
         nVar2 := &cCodigo
      ENDIF

      ( cAlias )->( mxTop( nOrder ) )
      nVar1 := &cCodigo

   ENDIF

RETURN( NIL )



STATIC FUNCTION codGrvSequence( uCodBas, nRecLock )

   LOCAL lErro := .T.

   BEGIN SEQUENCE

      MXCODCFI->( mxDbRefresh() )
      
      IF nRecLock <> NIL
         MXCODCFI->( mxGoTo( nRecLock ) )
      ENDIF
      
      IF MXCODCFI->CFISEQCOD = uCodBas
         BREAK
      ENDIF

      IF nRecLock <> NIL
         MXCODCFI->( mxRecLock( NIL, .F. ) )
      ENDIF

      MXCODCFI->( mxReplace( "SEQ", uCodBas ) )
      MXCODCFI->( mxUnlock(.F.) )

      IF MXCODCFI->CFISEQCOD <> uCodBas
         BREAK
      ENDIF

      lErro := .F.

   ENDSEQUENCE

   IF lErro

      MsgDlg( "N„o foi poss¡vel buscar corretamente;" + ;
              "a sequˆncia de c¢digo.;;"              + ;
              "Comunique nosso suporte t‚cnico;"      + ;
              "imediatamente !;;"                     + ;
              "*** O sistema ser  finalizado ***;"    + ;
              "[ " + MXCODCFI->CFICMPCOD + " ]" )

      Fim( 0 )

   ENDIF

RETURN( NIL )



FUNCTION codLimite( nLimite, cCampoCOD )

   LOCAL cLimite

   IF MXCODCFI->( FieldPos( "CFILIMCOD" ) ) > 0
      nLimite := MXCODCFI->CFILIMCOD
      cLimite := NumToStr( nLimite )
      IF Len( cLimite ) = 1 .OR. cLimite <> Repl( "9", Len( cLimite ) )
         nLimite := Val( Repl( "9", nLimite ) )
      ENDIF
      IF CS_MODO_ONLINE .AND. foundStr( cCampoCOD, COD_USELOJ )
         IF cCampoCOD = "CFICODPET" .AND. ( IsValue( "CFIRPECTR", "GAMACOR" ) .OR. IsValue( "CFIRPECTR", "ARICANDUVA" ) ) .AND. IsValue( "CFINLJCTR", 2 )
            nLimite := Val( Subs( NumToStr( nLimite ), 2 ) )
         ELSE
            nLimite := Val( Subs( NumToStr( nLimite ), 3 ) )
         ENDIF
      ENDIF
   ENDIF

RETURN( nLimite )

//--- Fim das funcoes p/ definicao de codigos



FUNCTION mxFUnLockAll()

   LOCAL nCount := Len( aNetLock )

   DO WHILE nCount > 0 .AND. Len( aNetLock ) > 0
      IF Len( aNetLock ) > 0
         mxFUnlock( aNetLock[ Len( aNetLock ), 1 ] )
      ENDIF
      nCount --
   ENDDO

RETURN( NIL )



FUNCTION Acha( uChave, cAreaAtual, cAreaPesq, nStatus, cMens, uSaida, nOrdPes )

   LOCAL nOrdAnt  := ( cAreaPesq )->( IndexOrd() )
   LOCAL lReturn  := .T.
   LOCAL cDisplay := Set( _SET_DEVICE, "SCREEN" )

   SeleArea( cAreaPesq )

   IF ( cAreaPesq )->( EmptyDb() )

      IF nStatus = 1
         IF ( cMens <> MS000 ) .AND. uSaida = NIL
            Mensagem( cMens, 0 )
         ENDIF
         lReturn := .F.
      ENDIF

   ELSEIF ( cAreaPesq )->( mxSeek( nOrdPes, uChave ) )

      IF nStatus = 0
         IF ( cMens <> MS000 ) .AND. uSaida = NIL
            Mensagem( cMens, 0 )
         ENDIF
         lReturn := .F.
      ENDIF

   ELSEIF nStatus = 1

      IF ( cMens <> MS000 ) .AND. uSaida = NIL
         Mensagem( cMens, 0 )
      ENDIF
      lReturn := .F.

   ENDIF

   ( cAreaPesq )->( mxOrder( nOrdAnt ) )

   SeleArea( cAreaAtual )

   Set( _SET_DEVICE, cDisplay )

RETURN( lReturn )



FUNCTION mxFieldLog( cLog, lFName )

   LOCAL cLine := ""
   LOCAL nCount
   
   vDef( @lFName, .F. )
   
   FOR nCount := 1 TO fCount()
      IF ! Empty( cLine )
         cLine += "|"
      ENDIF
      IF lFName
         cLine += Field( nCount ) + ":"
      ENDIF
      cLine += UtoC( FieldGet( nCount ) )
   NEXT

RETURN( mxFAddLine( cLog, cLine ) )



FUNCTION mxUpdStr( aStr, aNewStr )

   LOCAL nField, nAux
   
   FOR nField := 1 TO Len( aNewStr )
   
      nAux := aScan( aStr, { |f| Upper( f[1] ) = Upper( aNewStr[ nField, 1 ] ) } )

      IF nAux = 0
         aAdd( aStr, aNewStr[ nField ] )
      ELSE
         aStr[ nAux, 1 ] := aNewStr[ nField, 1 ]
         aStr[ nAux, 2 ] := aNewStr[ nField, 2 ]
         aStr[ nAux, 3 ] := aNewStr[ nField, 3 ]
         aStr[ nAux, 4 ] := aNewStr[ nField, 4 ]
      ENDIF
   
   NEXT

RETURN( aClone( aStr ) )



FUNCTION COD_MULTLJ( cCampo )

   LOCAL lReturn := .F.

   IF CS_MODO_ONLINE .AND. foundStr( Right( cCampo, 9 ), "CFICODCLI|CFICODMAD|CFICODRET|CFICODRCP|CFICODNOE" )
      lReturn := .T.
   ENDIF

   IF ! lReturn
      // Codigo concatenados com o numero das loja geradora e da operacao
      lReturn := IsDef( "CFIMLJCTR" ) .AND. CFIMLJCTR = "S" .AND. foundStr( Right( cCampo, 9 ), "CFICODCCC|CFICODBLC|CFICODPAG|CFICODCHQ|CFICODCCD|CFICODPVP" )
   ENDIF
   
RETURN( lReturn )