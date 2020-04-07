/*

 MaxDb.prg
 Descricao: Biblioteca de funcoes p/ uso em banco de dados.
 Desenvolvido por MAX SCALLA Informatica Ltda.
 
 EMERSON DA SILVA CREMA
 25/03/20 * Movido sqlDefNotNull() p/ MAXSQL.PRG.
 03/05/19 * Reformulado sqlDefNotNull() para que seja mais rapido.
 13/06/18 * Desenvolvido e implementado sqlDefNotNull().
 03/05/18 * Desenvolvido mxAddOrLock().
 16/06/16 * Implementado definicao "TR_NOLOCK" p/ nao executar os processos
            de geracao de registros de bloqueio de transacoes.
 15/04/16 * Alterado a abertura da transacao em mxTran() p/ q nao solicite o
            F10 quando ocorrer erro de transacao, isto apenas qdo existir a
            a variavel TR_ERROR_NOLOCK.
 13/04/16 * Implementado definicoes TRANS_*.
          * Implementado controle de referencias de transacoes
            (nome, id e conexao) p/ q sejam usadas na finalizacao da transacao.
            (Alteracoes em mxTran() e mxTranEnd()).
 
 DENIS MAZZUCATTO RODRIGUES
 07/12/15 * Implementacao de bReplace em mxAppendFrom().
 
 EMERSON DA SILVA CREMA
 27/09/13 * Padronizados logs na pasta LOGS\.
 26/08/13 * Implementado o parametro aFSelect em xDbStruct().
 04/12/12 * Removido olNewSend().

 DENIS MAZZUCATTO RODRIGUES
 28/09/12 * Desenvolvimento de mxTranAddMsg().
 10/07/12 * Implementanda verificacao do RDD em mxLockReplace().
 06/06/12 * Alteracao em mxTran() p/ padronizar o tamanho dos arquivos em
            aLocks, pois incluia duas vezes o mesmo alias causando assim
            travamento na transacao.
 10/08/11 * Alterado de 20 p/ 100 o numero de skips p/ dar o refresh.
 11/03/11 * Implementada consistencia em mxReplace() em relacao a gravacao de
            datas com o valor 00.00.0000
 09/12/10 * Implementacao de mxDbRefresh() em mxTran().
 29/11/10 * Implementada condicao de chave unica p/ R_KEYCTR em mxDbCreate().
 25/11/10 * Implementacao dos controles p/ R_KEYCTR.
 18/11/10 * Implementacao de mxDbRefresh() em mxSkip(), mxTop() e mxBottom().
 11/11/10 * Implementacao de aSkpLckTable.
 16/07/10 * Implementacao de aDelDuplicate() em mxTran().
 02/10/09 * Substituicao de IsExt() por IsUseExt().

 EMERSON DA SILVA CREMA
 09/09/09 * Implementado parametro lReplace em mxReplace().
 08/05/09 * Desenvolvimento de dbFControl() e dbKeySequence().
 07/05/09 * Desenvolvimento de dbKeyControl().
 12/01/09 * Desenvolvimento de mxFMove().
 25/02/08 * Implementada possibilidade de nao usar transacao em
            mxLockReplace().
 11/02/08 * Alteracao em mxTran() p/ nao incluir automaticamente COD qdo CSW.
 23/05/07 * Remocao de mxOrdem().
 18/04/07 * Removida chamada de cnxBegin().
 01/03/07 * Desenvolvimento de updOpenFiles(), getOpenFiles(), delOpenFiles(),
            sortOpenFiles() e mxCloseArea().

 DENIS MAZZUCATTO RODRIGUES
 15/12/06 * Modificacao em mxTran() p/ q o COD sempre fique na ultima posicao
            de aLocks.

 EMERSON DA SILVA CREMA
 07/08/06 * Desenvolvimento de mxLockDelete().
 21/07/06 * Desenvolvimento de IsBtr() e mxOrdList().
 06/04/06 * Desenvolvimento de mxAddLogReplace().
          * Implementado esquema de LOG em mxReplace() p/ alteracoes de campos
            definidos por mxAddLogReplace().
 04/04/06 * Correcao em mxTran() pois ha casos de transacoes q abrem arquivos
            onde a funcao de abertura tb utiliza uma transacao q acabava
            fechando os arquivos abertos pela transacao anterior.
          * Desenvolvimento de trOpenAdd().
          * Implementado parametro cTran em mxTranEnd().
 08/02/06 * Alteracao em mxUnlock(), pois qdo utilizava-se Windows XP estava
            efetuando um DbCommit() em uma area sem uso.
 02/02/06 * Implementado parametro lNoTrans em mxTran().
          * Implementado lNoConfTrans em mxConfTrans() e mxTran().
 27/01/06 * Removidas as implementacoes de btrRefresh().
          * Removido um N_XSkip(0) de mxDelete()
 19/01/06 * Desenvolvimento de btrRefresh().
 16/12/05 * Desenvolvimento de mxLockReplace().
          * Desenvolvimento e implementacao BtrLogTrans().
 27/09/05 * Desenvolvimento de IsTrans().
 27/04/05 * Desenvolvimento de mxGetFReplace().
 10/02/05 * Criadas consistencias em mxOrder() e mxUnlock() p/ reposicionar o
            registro.
 07/12/04 * Implementado TraceSet() e TraceLog().
 01/10/04 * Remodelada mxReplace().
 06/09/04 * Alteracao em aKeyFormat() p/ contemplar UpperCase().
 02/09/04 * Desenvolvimento de mxReplace().
 29/08/04 * Desenvolvimento de mxTranEnd() e implementada em mxTran().
 09/06/04 * Mudada inicializacao da variavel nOpenMode em mxOpen().
 11/11/03 * Desenvolvimento e implementacao de mxRqbCreate().

*/

#include "std.ch"
#include "inkey.ch"
#include "sqlrdd.ch"
#include "maxonl.ch"
#include "b:\desenvolvimento\sistemas\cs\loja\fontes\maxsetcf.ch"

// Definicoes para aOpenFiles
#define TOPEN_ALIAS     1
#define TOPEN_NOPEN     2
#define TOPEN_CONN      3
#define TOPEN_FSHORNAME 4
#define TOPEN_AREA      5
#define TOPEN_FFULLNAME 6
#define TOPEN_SHARED    7

// Definicoes para aTransFiles
#define TRANS_NAME  1
#define TRANS_CONN  2
#define TRANS_ID    3
#define TRANS_ALIAS 4

STATIC bTrOpen        := NIL
STATIC lLogTrans      := .F.
STATIC lNoConfTrans   := .F.
STATIC lKeyControl    := .F.
STATIC lAbortOpError  := .T.

STATIC aSkpLckTable   := {}  // Alias q deve ser dado o REFRESH antes do SKIP
STATIC nSkpRefresh    := 0

STATIC lConfTrans     := .F.
STATIC lTransMode     := .F.
STATIC lChr0Clear     := .F.
STATIC cActTransation := ""
STATIC aTransFiles    := {}
STATIC aTrOpen        := {}
STATIC aMsgTrans      := {}
STATIC aNoTrans       := {}
STATIC aLogReplace    := {}
STATIC aOpenFiles     := {}
STATIC cKeyForceAlias := NIL

STATIC cFieldReplace, cKeyFile, cKeyAlias


FUNCTION sqlLogTrans( lLog )

   LOCAL lReturn := lLogTrans

   IF lLog <> NIL
      lLogTrans := lLog
   ENDIF

RETURN( lReturn )



FUNCTION mxTransMode( lActive )

   LOCAL lReturn := lTransMode

   IF lActive <> NIL
      lTransMode := lActive
   ENDIF

RETURN( lReturn )



PROCEDURE mxSkip( nSkip )

   LOCAL nRecno

   vDef( @nSkip, 1 )

   mxConfTrans()

   TraceLog( "avancando registro " + mxLogRecord() )

   IF RddName() = "SQLRDD" .AND. ( ! Deleted() )
      IF EmptyDb()
         mxBottom()
      ELSEIF ( ++ nSkpRefresh >= 100 ) .AND. aScan( aSkpLckTable, Alias() ) = 0
         mxDbRefresh()
         nSkpRefresh := 0
      ELSE
         nRecno := mxRecno()
         DbSkip( 0 )
         mxGoTo( nRecNo )
      ENDIF
   ENDIF

   nRecno := mxRecno()
   DbSkip( nSkip )
   IF nSkip <> 0 .AND. nRecno = mxRecno() .AND. ! Bof() .AND. ! Eof()
      mxSkip( nSkip )
   ENDIF

   TraceLog( "registro avancado " + mxLogRecord() )

RETURN( NIL )



FUNCTION mxOrder( nOrder )

   LOCAL nIndexComp := IndexOrd()
   LOCAL nRecNo     := mxRecNo()

   BEGIN SEQUENCE

      IF nOrder = nIndexComp
         BREAK
      ENDIF

      IF RddName() = "SQLRDD" .AND. Len( mxGetIndexs() ) < nOrder
         BREAK
      ENDIF

      mxConfTrans()

      IF RddName() = "SQLRDD"
         IF ! Eof()
            mxDbCommit()
         ENDIF
         IF Eof()  // Nao pode alterar a ordem com o ponteiro posicionado no final do arquivo.
            DbGoTop()
         ENDIF
      ENDIF

      DbSetOrder( nOrder )

      mxGoTo( nRecNo )

   ENDSEQUENCE

RETURN( nIndexComp )



PROCEDURE mxTop( nOrder )

   IF nOrder = NIL
      mxConfTrans()
   ELSE
      mxOrder( nOrder )
   ENDIF

   IF RddName() = "SQLRDD"
      IF aScan( aSkpLckTable, Alias() ) = 0
         mxDbRefresh()
      ENDIF
   ELSEIF Upper( Left( Alias(), 4 ) ) = "TEMP"
      DbCommit()
      DbUnlock()
   ENDIF

   DbGoTop()

RETURN( NIL )



PROCEDURE mxBottom( nOrder )

   IF nOrder = NIL
      mxConfTrans()
   ELSE
      mxOrder( nOrder )
   ENDIF

   IF RddName() = "SQLRDD" .AND. aScan( aSkpLckTable, Alias() ) = 0
      mxDbRefresh()
   ENDIF

   DbGoBottom()

RETURN( NIL )



FUNCTION mxGoTo( nRecNo )

   LOCAL nOldRec := mxRecNo()

   mxConfTrans()

   TraceLog( "posicionando registro " + mxLogRecord() )

   IF ( ! EmptyDb() ) .AND. mxRecNo() <> nRecNo
      DbGoTo( nRecNo )
   ENDIF

   TraceLog( "registro posicionado " + mxLogRecord() )

RETURN( nOldRec )



FUNCTION mxDelete( nTempo, lDisp, lSkip )

   LOCAL cKey

   vDef( @lSkip, .T. )

   BEGIN SEQUENCE

      IF Deleted()
         mxSkip()
         BREAK
      ENDIF

      mxRLock( .F., nTempo, lDisp )

      IF sndIsStart()
         sndDelete()
      ENDIF

      IF TraceSet()
         cKey := ""
         IF IsDef( IndexKey() )
            cKey := " -> " + IndexKey() + "/" + UtoC( &( IndexKey() ) )
         ENDIF
         TraceLog( "excluindo registro " + mxLogRecord() + cKey )
      ENDIF

      csModuleResp()

      DbDelete()

      TraceLog( "registro excluido" )

      mxUnlock(.F.)

      IF lSkip .AND. Deleted()
         mxSkip()
      ENDIF

   ENDSEQUENCE

RETURN( NIL )



FUNCTION mxRecLock( nTempo, lDisp )

   mxRLock( .F., nTempo, lDisp )

   TraceLog( "registro travado " + mxLogRecord() )

   IF sndIsStart()
      sndUpdate( NIL, "U" )
   ENDIF

   csModuleResp()

RETURN( .T. )



FUNCTION mxAppend( nTempo, lDisp )

   mxRLock( .T., nTempo, lDisp )

   TraceLog( "registro incluido " + mxLogRecord() )

   IF sndIsStart()
      sndUpdate( NIL, "I" )
   ENDIF

   csModuleResp()

RETURN( .T. )



FUNCTION mxAddOrLock( lLock, nTempo, lDisp )

   IF lLock
      mxRecLock( nTempo, lDisp )
   ELSE
      mxAppend( nTempo, lDisp )
   ENDIF

RETURN(.T.)



FUNCTION mxRLock( lAppe, nTempo, lDisp )

   #define MSG_ALIAS "[" + Subs( Alias(), 3, 3 ) + If( Eof(), "/EOF", If( Bof(), "/BOF", "" ) ) + "] "

   LOCAL lMsg     := .T.
   //LOCAL lFuncKey := ( dbKeyControl() .AND. RddName() = "SQLRDD" .AND. IsDef( "R_KEYCTR" ) .AND. ! IsProcedure( "DBKEYSEQUENCE" ) )

   LOCAL nKeyCtr, nCount, cLog

   vDef( @nTempo,  0  )
   vDef( @lAppe , .F. )
   vDef( @lDisp , .F. )

   IF ( ! lAppe ) .AND. ( ! isCsw() )
      mxDbRefresh()
   ENDIF

   IF RddName() = "SQLRDD" .AND. mxTransMode() .AND. mxVTrans() .AND. Empty( GetActTrans() )

      cLog := DtoC( Date() ) + " " + Alias() + " -> ???" + _NL

      FOR nCount := 1 TO 3
         IF ! Empty( ProcName( nCount ) )
            cLog += ProcName( nCount ) + "(" + NumToStr( ProcLine( nCount ) ) + ")" + _NL
         ENDIF
      NEXT

      cLog += _NL

      mxFAddLine( "LOGS\TRANS.LOG", cLog )

      ScreenSave()
      MsgDlg( "O arquivo " + Alias() + " n„o foi inclu¡do numa transa‡„o !", "00:15" )
      ScreenRest()

      lMsg := .F.

   ENDIF

   IF lAppe
      TraceLog( "incluindo registro" )
   ELSE
      TraceLog( "travando registro " + mxLogRecord(2) )
   ENDIF

   DO WHILE lAppe

      /*
      IF lFuncKey
         nKeyCtr := dbKeySequence()
      ENDIF
      */

      APPEND BLANK

      IF RddName() = "SQLRDD"  // Utilizado p/ fixar o Recno.
         TRY
            dbCommit()
         CATCH oErr
            IF IsDef( "DESENV" )
               MsgDlg( oErr:Description )
            ENDIF
         END
      ENDIF

      IF ! NetErr()
         /*
         IF lFuncKey
            aAdd( aKeyControl, { mxRecNo(), Alias() } )
            mxReplace( "R_KEYCTR", nKeyCtr )
         ENDIF
         */
         EXIT
      ELSEIF nTempo > 30
         Mensagem( MSG_ALIAS + "Verifique as outras esta‡”es, h  problemas na gera‡„o do registro !", 1 )
         IF InKey() = K_ALT_Q
            QUIT
         ENDIF
         nTempo := 0
      ENDIF

      nTempo ++

   ENDDO

   DO WHILE .T.

      IF RLock()

         IF lDisp
            Status( MS013 )
         ENDIF

         IF RddName() = "SQLRDD" .AND. aScan( aSkpLckTable, Alias() ) = 0
            aAdd( aSkpLckTable, Alias() )
         ENDIF

         mxConfTrans()

         IF IsDef( "BKP_UPD" ) .AND. Empty( BKP_UPD )
            mxReplace( "BKP_UPD", If( lAppe, "I", "U" ) )
         ENDIF

         RETURN( .T. )

      ELSEIF nTempo > 30

         Mensagem( MSG_ALIAS + "Verifique as outras esta‡”es, h  problemas no bloqueio do registro !", 1 )

         IF InKey() = K_ALT_Q
            QUIT
         ENDIF

         nTempo := 0

      ENDIF

      nTempo ++

   ENDDO

   mxConfTrans()

RETURN( .T. )



FUNCTION mxUnLock( uMode )

   LOCAL nCount

   IF uMode = NIL

      TraceLog( "efetuando COMMIT de todos os registros" )

      // Desbloqueia todos os registros em todas as areas

      FOR nCount := 1 TO 255

         IF ( nCount )->( Used() )
            ( nCount )->( mxDbCommit() )
            ( nCount )->( DbUnlock() )
         ENDIF

      NEXT

      TraceLog( "COMMIT efetuado" )

   ELSE

      TraceLog( "efetuando COMMIT de registro pendente " + mxLogRecord() )

      mxDbCommit()  // Atualiza buffer da area atual
      TraceLog( "COMMIT efetuado" )

      IF dbKeyControl() .AND. RddName() = "SQLRDD" .AND. IsDef( "R_KEYCTR" ) .AND. Alias() <> "MXKEYCFI"
         IF Empty( R_KEYCTR )
            mxReplace( "R_KEYCTR", dbKeySequence() )
         ELSE
            dbKeyBkp()
         ENDIF
      ENDIF

      IF sndIsStart()
         sndPost()
      ENDIF

      DbUnlock()  // Desbloqueia todos registros da area atual

   ENDIF

RETURN( .T. )



PROCEDURE mxDbCommit()

   LOCAL nRecno := mxRecno()
   LOCAL nSkpUnlock

   DbCommit()

   mxGoTo( nRecno )

   IF ( nSkpUnlock := aScan( aSkpLckTable, Alias() ) ) > 0
      aSkpLckTable := aDel( aSkpLckTable, nSkpUnlock )
      aSkpLckTable := aSize( aSkpLckTable, Len( aSkpLckTable ) -1 )
   ENDIF

RETURN( NIL )



FUNCTION mxDefTrOpen( bOpen )

   bTrOpen := bOpen

RETURN( NIL )



FUNCTION mxTran( cTran, aLocks, lMsg, lNoTrans, lNoCod )

   #define TR_ONLINE  ( CFICNXCTR <> "N" .AND. lON .AND. sndActive() )

   LOCAL lSuporte := IsProcedure( "SUPORTE" )
   LOCAL lON      := ( aLocks <> NIL )

   LOCAL nCount, nPos, aSql
   LOCAL cAlias, cOpen, cOldAlias, cScreen, cTimeLock, cSql, cWhere, cInternalID

   vDef( @lMsg    , .T. )
   vDef( @lNoTrans, .F. )
   vDef( @lNoCod  , .F. )

   MDefault( "CFICNXCTR", "N" )

   IF TR_ONLINE
      sndStart( cTran )
   ENDIF

   IF lON
      IF lNoTrans .OR. ! sqlActive()
         cActTransation := cTran
      ENDIF
      aMsgTrans := {}
   ENDIF

   IF lNoTrans
      lNoConfTrans := .T.
   ENDIF

   IF mxTransMode()

      IF lON

         cInternalID := SR_GetInternalID()

         IF ! lNoTrans

            IF ! lSuporte
               FOR nCount := 1 TO Len( aLocks )
                  cAlias := aLocks[ nCount ]
                  IF Len( cAlias ) = 8 .AND. Left( cAlias, 2 ) = "MX" .AND. Right( cAlias, 3 ) = "CFI"
                     aLocks[ nCount ] := Subs( cAlias, 3, 3 )
                  ENDIF
               NEXT
            ENDIF
            
            cScreen := SaveScreen( 24,00,24,79 )

            cOldAlias := Alias()

            aAddC( aLocks, "KEY", dbKeyControl() )
            aAddC( aLocks, "ONL", TR_ONLINE .AND. onlConf())
            
            aDelDuplicate( @aLocks )

            aSort( aLocks )

            IF ! isCSW()

               nPos := aScan( aLocks, "COD" )

               IF ( nPos > 0 .OR. CFICNXCTR <> "N" ) .AND. ( nPos <> Len( aLocks ) ) .AND. ! lNoCod
                  IF nPos > 0
                     aDelPos( aLocks, nPos )
                  ENDIF
                  aAdd( aLocks, "COD" )
               ENDIF

            ENDIF

            IF TR_ONLINE
               IF ! dbIsOpen( "MXOUT" )
                  mxOpen( 0, "CS_CONEXAO\MXOUT", "MXOUT", mxRdd(), .T. )
               ENDIF
               aLocks := aInsert( aLocks, "MXOUT", 1 )
            ENDIF
            
            FOR nCount := 1 TO Len( aLocks )

                cAlias := aLocks[ nCount ]

                IF Len( cAlias ) = 3 .AND. ! lSuporte
                   cOpen := "MX" + cAlias + sisFlgModule()
                ELSE
                   cOpen := cAlias
                ENDIF

                IF Select( cOpen ) = 0

                   IF bTrOpen = NIL
                      Eval( &( "{ || ABRA" + cAlias + "() }" ) )
                   ELSE
                      Eval( bTrOpen, cAlias )
                   ENDIF

                   trOpenAdd( cTran, cOpen )

                ENDIF

            NEXT

            IF ! Empty( cOldAlias ) .AND. Select( cOldAlias ) > 0
               Select( cOldAlias )
            ENDIF

            TraceLog( Repl( "-", 80 )              + Chr(13) + Chr(10) + ;
                      "abrindo transacao " + cTran + Chr(13) + Chr(10) + ;
                      Repl( "-", 80 ) )

            IF sqlLogTrans()
               mxFAddLine( "LOGS\OPTRANS.LOG", "OPEN - " + DtoC( Date() ) + " - " + Time() + " - " + cTran )
            ENDIF

            cTimeLock := Time()

            aAdd( aTransFiles, { cTran, sqlGetConn( "NAME" ), cInternalID, {} } )

            FOR nCount := 1 TO Len( aLocks )

               cAlias := aLocks[ nCount ]

               IF Len( cAlias ) = 3 .AND. ! lSuporte
                  cAlias := "MX" + cAlias + sisFlgModule()
               ENDIF

               IF lMsg
                  csWait( "[" + cAlias + "] Abrindo transa‡„o " + cTran + "...", NIL, NIL, .T. )
               ENDIF

               IF ! IsDef( "TR_NOLOCK" )

                  TraceLog( "incluindo na transacao " + cAlias )

                  nPos := aScan( aOpenFiles, { |x| x[ TOPEN_ALIAS ] = Upper( cAlias ) } )

                  cOpen := StrTran( aOpenFiles[ nPos, TOPEN_CONN ] + "\" + Upper( cAlias ), "\", "." )

                  DO WHILE .T.
                     aSql := {}
                     cWhere := "SUBSTR(lock_,1," + NumToStr( Len( cOpen ) +9 ) + ") = 'MXTRAN_$_" + cOpen + "'"
                     sqlExecute( "SELECT DISTINCT lock_ FROM public.sr_mgmntlocks WHERE " + cWhere, @aSql, NIL, NIL, NIL, .F., .F. )
                     IF Len( aSql ) = 0
                        cSql := "INSERT INTO public.sr_mgmntlocks ( lock_, wsid_, spid_ ) VALUES ( 'MXTRAN_$_"
                        cSql += cOpen
                        cSql += " (" + cTran + ")"
                        TRY
                           cSql += If( lSuporte, "", "  " + &( "csSet( " + NumToStr( CSSET_ARQNET ) + " )" ) )
                        CATCH
                        END
                        cSql += "', '"
                        cSql += cInternalID
                        cSql += "', (select pg_backend_pid()) )"
                        sqlExecute( cSql, NIL, NIL, NIL, NIL, .F., .F. )
                        EXIT
                     ENDIF
                     IF Empty( cTimeLock )
                        sqlExecute( "DELETE FROM public.sr_mgmntlocks WHERE " + cWhere, NIL, .F., NIL, NIL, .F., .F. )
                     ELSEIF ElapTime( cTimeLock, Time() ) >= "00:03:00"
                        IF IsDef( "TR_ERROR_NOLOCK" )
                           cTimeLock := ""
                        ELSEIF isCsw()
                           @ MaxRow() -7, 68  SAY "<Tecle F10>" COLOR cInfoMSca
                        ELSE
                           @ MaxRow(), 68  SAY "<Tecle F10>" COLOR "0/7"
                        ENDIF
                        IF mxInkey( 0.01 ) = K_F10 .AND. &( "SenhaMax()" )
                           cTimeLock := ""
                        ENDIF
                     ELSEIF isCsw()
                        @ MaxRow() -7, 71  SAY ElapTime( cTimeLock, Time() ) COLOR cInfoMSca
                     ELSE
                        @ MaxRow(), 71  SAY ElapTime( cTimeLock, Time() ) COLOR "0/7"
                     ENDIF
                  ENDDO

                  TraceLog( "arquivo incluido" )

               ENDIF

               aAdd( aTransFiles[ Len( aTransFiles ), TRANS_ALIAS ], cAlias )

               ( cAlias )->( mxDbRefresh() )

            NEXT

            IF TR_ONLINE
               SR_BeginTransaction( NCONN_CNX )
            ENDIF

            SR_BeginTransaction()

            TraceLog( "transacao aberta" )

            cActTransation := cTran

            IF lMsg .AND. isCsw()
               csWait( "Transa‡„o " + cTran + " aberta com sucesso.", NIL, NIL, .T. )
            ENDIF

            RestScreen( 24,00,24,79, cScreen )

         ENDIF

      ELSE

         IF CFICNXCTR <> "N" .AND. ( ! lON ) .AND. sndActive()
            sndEnd()
            sndRename()
         ENDIF

         IF ! lNoTrans
            mxTranEnd( .T., cTran )
         ENDIF

         lNoConfTrans := .F.

      ENDIF

   ENDIF

   IF ! lON
      IF lNoTrans .OR. ! sqlActive()
         cActTransation := ""
      ENDIF
      IF Len( aMsgTrans ) > 0
         mxMsgTran( ";[Transa‡„o ^" + cTran + "^]" )
         MsgDlg( formatMsg( aMsgTrans, .T. ), "ACEF2" )
      ENDIF
   ENDIF

RETURN( .T. )



PROCEDURE mxMsgTran( cMsg )

   IF cMsg <> NIL
      aAdd( aMsgTrans, cMsg )
   ENDIF
   
RETURN( NIL )



STATIC FUNCTION trOpenAdd( cTran, cAlias )

   LOCAL nTrOpen

   IF Select( cAlias ) > 0

      nTrOpen := aScan( aTrOpen, { |t| t[1] = cTran } )

      IF nTrOpen = 0
         aAdd( aTrOpen, { cTran, {} } )
         nTrOpen := Len( aTrOpen )
      ENDIF

      aAdd( aTrOpen[ nTrOpen ], cAlias )

   ENDIF

RETURN( NIL )



FUNCTION mxTranEnd( lOk, cTran )

   LOCAL nTrOpen, nTrans

   vDef( @cTran, cActTransation )
   
   nTrOpen := aScan( aTrOpen    , { |t| t[1] = cTran } )
   nTrans  := aScan( aTransFiles, { |x| x[ TRANS_NAME ] = cTran } )
   
   IF nTrans <> 0

      vDef( @lOk, .T. )
      
      IF sqlGetConn( "NAME" ) <> aTransFiles[ nTrans, TRANS_CONN ]
         sqlSetConn( aTransFiles[ nTrans, TRANS_CONN ] )
      ENDIF

      IF sqlLogTrans()
         mxFAddLine( "LOGS\OPTRANS.LOG", "END - " + DtoC( Date() ) + " - " + Time() + " - " + cActTransation )
      ENDIF

      TraceLog( Repl( "-", 80 )               + Chr(13) + Chr(10) + ;
                "fechando transacao " + cTran + Chr(13) + Chr(10) + ;
                Repl( "-", 80 ) )

      IF lOk
         SR_Exec( { || SR_EndTransaction() } )
      ELSE
         SR_Exec( { || SR_RollBackTransaction() } )
      ENDIF

      IF sndActive() .AND. ( ! IsDef( "CFICNXCTR" ) .OR. CFICNXCTR <> "N" )
         IF lOk
            SR_Exec( { || SR_EndTransaction( NCONN_CNX ) } )
         ELSE
            SR_Exec( { || SR_RollBackTransaction( NCONN_CNX ) } )
         ENDIF
      ENDIF

      IF ! IsDef( "TR_NOLOCK" )
         sqlClearLocks( "TRAN", aTransFiles[ nTrans, TRANS_ID ] )
      ENDIF

      TraceLog( "transacao fechada" )
      
   ENDIF

   IF nTrOpen <> 0
      aEval( aTrOpen[ nTrOpen ], { |cAlias| mxClose( cAlias ) } )
      aTrOpen := aDel( aTrOpen, nTrOpen )
      aTrOpen := aSize( aTrOpen, Len( aTrOpen ) -1 )
   ENDIF

   aNoTrans       := {}
   aTransFiles    := {}
   cActTransation := ""

RETURN( NIL )



FUNCTION GetActTrans()

   LOCAL cReturn := cActTransation

RETURN( cReturn )



FUNCTION mxOpen( ;
                 nArea    ,;
                 cOpen    ,;
                 cAlias   ,;
                 cRdd     ,;
                 lShared  ,;
                 lReadOnly,;
                 lDisplay ,;
                 lRetry   ,;
                 cWait    ,;
                 lQuit     ;
               )

   LOCAL lReturn := .F.
   LOCAL nRetry  := 0
   LOCAL nCursor := SetCursor(0)

   LOCAL lError, lAM, cDisp, nOpenMode, nSelect, nKey, nConnSave
   
   mSetCursor(.F.)

   vDef( @cRdd     , mxRdd()       )
   vDef( @cAlias   , cOpen         )
   vDef( @lReadOnly, .F.           )
   vDef( @lDisplay , .T.           )
   vDef( @lShared  , .T.           )
   vDef( @lRetry   , .T.           )
   vDef( @lQuit    , lAbortOpError )

   cAlias := DelExt( DelExt( DelPath( cAlias ) ) )

   BEGIN SEQUENCE

      Select( nArea )

      nSelect := Select()

      IF ! IsUseExt( cOpen )
         cOpen += ".DBF"
      ENDIF

      cDisp := cOpen

      IF cRdd = "SQLRDD"
         IF GetExt( cDisp ) = ".DBF"
            cDisp := DelExt( cDisp )
         ENDIF
         lAM := ( "CS_AM" $ sqlGetInfo( cDisp, "NAME" ) )
      ELSE
         lAM := ( "CSAM\" $ cDisp )
      ENDIF

      IF lAM
         cDisp := Chr(30) + " MX" + Subs( DelPath( cDisp ), 3, 3 ) + sisFlgModule() + GetExt( cDisp )
      ENDIF

      TraceLog( "abrindo " + cOpen + " " +   + Chr(13) + Chr(10) + ;
                ProcName(1) + "/" + NumToStr( ProcLine(1) ) + Chr(13) + Chr(10) + ;
                ProcName(2) + "/" + NumToStr( ProcLine(2) ) + Chr(13) + Chr(10) + ;
                ProcName(3) + "/" + NumToStr( ProcLine(3) ) + Chr(13) + Chr(10) + ;
                ProcName(4) + "/" + NumToStr( ProcLine(4) ) )

      IF ! dbFile( cOpen, cRdd )
         TraceLog( "arquivo " + cOpen + " nao encontrado" )
         MsgDlg( "O arquivo " + cDisp + ";n„o existe !", cWait )
         IF lQuit
            Inkey( 5 )
            Fim( 0 )
         ENDIF
         BREAK
      ENDIF

      IF nArea = 0 .AND. Select( cAlias ) > 0
         lReturn := .T.
         BREAK
      ENDIF

      IF cRdd = "SQLRDD"

         IF "\" $ cOpen

            // Mantem a conexao atual caso nao tenha "\" no nome do arquivo

            nConnSave := sqlSetConn( NIL                          ,;
                                     sqlGetInfo( cOpen, "DTB"    ),;
                                     sqlGetInfo( cOpen, "SCHEMA" ) )

         ENDIF

         cOpen := sqlGetInfo( cOpen, "FILE" )

      ENDIF

      IF lDisplay
         csWait( "Abrindo arquivo " + cDisp + "...", NIL, NIL, .T. )
      ENDIF

      DO WHILE .T.

         DbUseArea( .F., cRdd, cOpen, cAlias, lShared, lReadOnly )

         Memory( -1 )

         IF cRdd = "SQLRDD"
            lError := ( Select( cAlias ) = 0 )
         ELSE
            lError := xNetErr( cRdd )
         ENDIF

         IF ! lError
            EXIT
         ENDIF

         nKey := mxInKey( 1 )

         IF ( ++ nRetry ) = 3
            IF ! lRetry
               BREAK
            ENDIF
            csWait( "(Sess„o Open) - Problemas na abertura do arquivo " + cDisp + "...", NIL, NIL, .T. )
            nRetry := 0
         ENDIF

         IF mxIn( nKey, { 81, 113 } )
            IF lQuit
               Fim( 0 )
            ENDIF
            BREAK
         ENDIF

      ENDDO

      updOpenFiles( cAlias, cOpen, lShared )

      lReturn := .T.

   ENDSEQUENCE

   IF lReturn
      TraceLog( "ok" + Chr(13) + Chr(10) )
   ENDIF

   SetCursor( nCursor )

   Memory( -1 )

   IF nConnSave <> NIL
      sqlSetConn( nConnSave )
   ENDIF

RETURN( lReturn )



FUNCTION getOpenFiles()

RETURN( aOpenFiles )



FUNCTION updOpenFiles( cAlias, cOpen, lShared )

   LOCAL nOpen := aScan( aOpenFiles, { |x| x[ TOPEN_ALIAS ] = cAlias } )

   vDef( @cOpen, cAlias )

   IF nOpen = 0
      aAdd( aOpenFiles, { cAlias, 1, "", "", Select( cAlias ), cOpen, lShared } )
      nOpen := Len( aOpenFiles )
   ELSE
      aOpenFiles[ nOpen, TOPEN_NOPEN ] ++
   ENDIF

   IF ( cAlias )->( RddName() ) = "SQLRDD"
      aOpenFiles[ nOpen, TOPEN_CONN      ] := sqlGetConn( "NAME" )
      aOpenFiles[ nOpen, TOPEN_FSHORNAME ] := GetNameFile( cOpen )
   ENDIF

   aOpenFiles[ nOpen, TOPEN_AREA      ] := Select( cAlias )
   aOpenFiles[ nOpen, TOPEN_FFULLNAME ] := cOpen

RETURN( aOpenFiles )



FUNCTION sortOpenFiles()

   aSort( aOpenFiles,,, { |x,y| x[ TOPEN_NOPEN ] < y[ TOPEN_NOPEN ] } )

RETURN( aOpenFiles )



FUNCTION delOpenFiles( uAlias )

   LOCAL nClose, cOpen, nConnSave

   IF ValType( uAlias ) = "N"
      nClose := uAlias
   ELSE
      nClose := aScan( aOpenFiles, { |x| x[ TOPEN_ALIAS ] = uAlias } )
   ENDIF

   IF nClose <> 0

      cOpen := aOpenFiles[ nClose, TOPEN_FSHORNAME ]

      IF ! Empty( cOpen )

         IF GetExt( cOpen ) = ".DBF"
            cOpen := DelExt( cOpen )
         ELSE
            cOpen := StrTran( cOpen, ".", "_" )
         ENDIF

         IF cOpen <> aOpenFiles[ nClose, TOPEN_ALIAS ] .OR. ( "\" $ aOpenFiles[ nClose, TOPEN_CONN ] )

            nConnSave := sqlSetConn( aOpenFiles[ nClose, TOPEN_CONN ] )

            sqlExecute( "DELETE FROM " + Lower( sqlGetConn( "SCHEMA" ) ) + ".sr_mgmntlocks WHERE STRPOS(lock_, '" + cOpen + "') > 0 AND wsid_ = '" + SR_GetInternalID() + "'", NIL, NIL, NIL, NIL, .F., .F. )

            sqlSetConn( nConnSave )

         ENDIF

      ENDIF

      aDel( aOpenFiles, nClose )
      aSize( aOpenFiles, Len( aOpenFiles ) -1 )

   ENDIF

RETURN( NIL )



FUNCTION mxCloseArea( lAll )

   vDef( @lAll, .F. )

   IF lAll
      DbCloseAll()
      aOpenFiles := {}
   ELSE
      delOpenFiles( Alias() )
      DbCloseArea()
   ENDIF

RETURN( NIL )



FUNCTION mxDbCreate( cFile, aStruct, aIndex, cRdd, lIndex, lReconnect )

   LOCAL lReturn := .F.
   LOCAL aFDef   := {}

   LOCAL nConnSave, nCount, cKey, cIndex
   
   vDef( @lReconnect, .T. )

   IF cRdd = NIL
      cRdd := DbSetDriver()
   ENDIF

   IF aIndex = NIL
      aIndex := {}
   ENDIF

   vDef( @lIndex, .T. )

   BEGIN SEQUENCE

      IF ! IsUseExt( cFile )
         cFile += ".DBF"
      ENDIF

      mxFDel( cFile, NIL, NIL, cRdd )

      IF cRdd = "SQLRDD"

         nConnSave := sqlSetConn( NIL                          ,;
                                  sqlGetInfo( cFile, "DTB"    ),;
                                  sqlGetInfo( cFile, "SCHEMA" ) )

         cFile := GetNameFile( cFile )

         IF GetExt( cFile ) = ".DBF"
            cFile := DelExt( cFile )
         ELSE
            cFile := StrTran( cFile, ".", "_" )
         ENDIF

      ENDIF

      DbCreate( cFile, aStruct, cRdd )

      IF cRdd = "SQLRDD"

         IF ! mxOpen( 0, cFile, "EEORIEOE", cRdd, .F., .F., .F., .T., NIL, .F. )
            BREAK
         ENDIF

         Select( "EEORIEOE" )

         FOR nCount := 1 TO Len( aStruct )

            IF foundStr( aStruct[ nCount, 2 ], "C|N" )
               EEORIEOE->( SR_AddRuleNotNull( aStruct[ nCount, 1 ] ) )
            ENDIF

            IF aStruct[ nCount, 2 ] = "C"
               IF aStruct[ nCount, 3 ] > 10 .AND. aScan( aIndex, { |x| aStruct[ nCount, 1 ] $ x[2] } ) > 0
                  aAdd( aFDef, "ALTER TABLE " + sqlGetInfo( cFile, "SCHEMA" ) + "." + sqlGetInfo( cFile, "FILE" ) + " ALTER COLUMN " + aStruct[ nCount, 1 ] + " TYPE character( " + NumToStr( aStruct[ nCount, 3 ] ) + ")" )
               ENDIF
               aAdd( aFDef, "ALTER TABLE " + sqlGetInfo( cFile, "SCHEMA" ) + "." + sqlGetInfo( cFile, "FILE" ) + " ALTER COLUMN " + aStruct[ nCount, 1 ] + " SET DEFAULT ''" )
            ELSEIF aStruct[ nCount, 2 ] = "M"
               aEval( sqlDefNotNull( cFile, aStruct[ nCount, 1 ], .F. ), { |x| aAdd( aFDef, x ) } )
            ENDIF

         NEXT

         IF Len( aFDef ) > 0
            sqlExecute( aFDef )
         ENDIF

         IF dbKeyControl()
            nCount := EEORIEOE->( FieldPos( "R_KEYCTR" ) )
         ELSE
            nCount := 0
         ENDIF

         mxClose( "EEORIEOE" )

         /*
         IF nCount > 0
            sqlExecute( "ALTER TABLE " + sqlGetConn( "SCHEMA" ) + "." + cFile + " ADD CONSTRAINT " + Lower( sqlGetInfo( cFile, "FILE" ) ) + "_r_keyctr UNIQUE (r_keyctr)" )
         ENDIF
         */

         IF lReconnect
            sqlReconnect()
         ENDIF

      ENDIF

      cIndex := ""

      IF Right( cRdd, 6 ) = "DBFCDX"
         cIndex := DelExt( cFile ) + ".CDX"
      ENDIF

      IF ! Empty( cIndex )
         mxFDel( cIndex, NIL, NIL, cRdd )
      ENDIF

      ThreadSleep( 300 )
      
      IF ! dbFile( cFile, cRdd )
         MsgDlg( "N„o foi poss¡vel criar o arquivo !;" + cFile )
         BREAK
      ENDIF

      IF lIndex .AND. Len( aIndex ) > 0

         IF ! mxOpen( 0, cFile, "EEORIEOE", cRdd, .F., .F., .F., .T., NIL, .F. )
            BREAK
         ENDIF

         Select( "EEORIEOE" )

         FOR nCount := 1 TO Len( aIndex )

            cIndex := aIndex[ nCount, 1 ]
            cKey   := aIndex[ nCount, 2 ]

            EEORIEOE->( sqlDefSyntheticIndex( cKey ) )

            IF IsDigit( cIndex )

               // Modificacao p/ compatibilizar com dicIndex().

               cFile := DelExt( GetNameFile( cFile ) )

               cIndex := NumToStr( Val( cIndex ) )
               cIndex := Left( cFile, Len( cFile ) - Len( cIndex ) ) + cIndex

            ENDIF

            INDEX ON &cKey TAG &cIndex

         NEXT

         mxClose( "EEORIEOE" )

      ENDIF

      lReturn := .T.

   ENDSEQUENCE

   mxClose( "EEORIEOE" )

   IF nConnSave <> NIL
      sqlSetConn( nConnSave )
   ENDIF

RETURN( lReturn )



FUNCTION xNetErr( cRdd )

   // Verifica se houve erro em algum processo executado em uma
   // base de dados

RETURN( NetErr() )



FUNCTION xDbStruct( aFSelect )

   LOCAL aStructure := DbStruct()
   LOCAL aReturn    := {}
   LOCAL nCount, nPos

   IF RddName() = "SQLRDD"
      aEval( aStructure, { |a| aSize( a, 4 ) } )
   ENDIF

   IF aFSelect = NIL
      aReturn := aStructure
   ELSE
      FOR nCount := 1 TO Len( aFSelect )
         nPos := aScan( aStructure, { |x| x[ DBS_NAME ] = aFSelect[ nCount ] } )
         IF nPos > 0
            aAdd( aReturn, aStructure[ nPos ] )
         ENDIF
      NEXT
   ENDIF

RETURN( aReturn )



/*----------------------------------------------------------------------------
 Monta uma matriz com uma chave de indices desmenbrada.
 Traz em cada vetor o flag "d" para nao DESCEND e "D" para DESCEND.

 Parametros

 cKey : Chave para formatacao.

 Retorno : Matriz com o nome dos campos e flags correspondentes.

 Exemplo

 aKey := aKeyFormat( "CAMPO1 + CAMPO2 + DESCEND( CAMPO3 )" )
 // Resultado.
 aKey[ 1 ] // CAMPO1, "d"
 aKey[ 2 ] // CAMPO2, "d"
 aKey[ 3 ] // CAMPO3, "D"
----------------------------------------------------------------------------*/

FUNCTION aKeyFormat( cKey, cType )

   LOCAL cParcial  := ""
   LOCAL nFunction := 0
   LOCAL aKey      := {}

   LOCAL nCount1, nCount2, cStr, cDesFlag, cUpeFlag

   FOR nCount1 := 1 TO Len( cKey )

      cStr := Subs( cKey, nCount1, 1 )

      IF cStr = "("
         nFunction ++
         cParcial += cStr
      ELSEIF cStr = ")"
         nFunction --
         cParcial += cStr
      ELSEIF cStr = "+" .AND. nFunction = 0
         aAdd( aKey, { Upper( cParcial ), "d", "u" } )
         cParcial := ""
      ELSE
         cParcial += cStr
      ENDIF

   NEXT

   aAddC( aKey, { Upper( cParcial ), "d", "u" }, ! Empty( cParcial ) )

   FOR nCount1 := 1 TO Len( aKey )

      cKey     := aKey[ nCount1, 1 ]
      cDesFlag := "d"
      cUpeFlag := "u"
      cParcial := ""

      FOR nCount2 := 1 TO Len( cKey )

         cStr := Subs( cKey, nCount2, 1 )

         IF cStr = "("
            IF Upper( AllTrim( cParcial ) ) = "DESCEND"
               cDesFlag := "D"
            ELSEIF Upper( AllTrim( cParcial ) ) = "UPPER"
               cUpeFlag := "U"
            ENDIF
            cParcial := ""
         ELSEIF cStr = ")"
            EXIT
         ELSE
            cParcial += cStr
         ENDIF

      NEXT

      IF At( ",", cParcial ) > 0
         cParcial := Left( cParcial, At( ",", cParcial ) -1 )
      ENDIF

      IF cType <> NIL
         IF Left( cType, 1 ) <> " "
            cDesFlag := Left( cType, 1 )
         ENDIF
         IF Subs( cType, 6, 1 ) <> " "
            cUpeFlag := Subs( cType, 6, 1 )
         ENDIF
         cType := Subs( cType, At( ";", cType ) + 1 )
      ENDIF

      aKey[ nCount1, 1 ] := StrTran( Upper( cParcial ), " ", "" )
      aKey[ nCount1, 2 ] := cDesFlag
      aKey[ nCount1, 3 ] := cUpeFlag

   NEXT

RETURN( aKey )


/*----------------------------------------------------------------------------
 Efetua o mesmo processo de append from mas com tratamento para campo
 auto-incremento.

 Parametros

 cFile       : Nome completo do arquivo para append.
 bFor        : Condicao FOR.
 bWhile      : Condicao WHILE.
 cRdd        : Driver de "cFile".
 nModeAppend : Se 1, processo de append normal, caso contrario, processo
               manual.
 cFromAlias  : Nome do alias de origem para o APPEND.

 Retorno : .T. se a operacao for bem sucedida.
----------------------------------------------------------------------------*/

FUNCTION mxAppendFrom( cFile, cFromAlias, bFor, bWhile, cRdd, nModeAppend, bReplace )

   LOCAL nPos     := 0
   LOCAL lClose   := .F.
   LOCAL lReturn  := .F.
   LOCAL cAlias   := Alias()
   LOCAL aStruct1 := xDbStruct()
   LOCAL aStruct2 := aClone( aStruct1 )

   LOCAL nCount, aReplace, cField, cReplace

   vDef( @bWhile     , { || .T. } )
   vDef( @bFor       , { || .T. } )
   vDef( @nModeAppend, 1          )
   vDef( @cRdd       , mxRdd()    )
   vDef( @cFromAlias , "WEWOWOEW" )

   BEGIN SEQUENCE

      IF Select( cFromAlias ) > 0
         nModeAppend := 2
      ENDIF

      IF nModeAppend = 1
         APPEND FROM ( cFile ) WHILE Eval( bWhile ) FOR Eval( bFor ) VIA cRdd
      ELSE
         IF Select( cFromAlias ) = 0
            IF ! mxOpen( 0, cFile, cFromAlias, cRdd, .F., .F., .F. )
               BREAK
            ENDIF
            lClose := .T.
         ENDIF

         aStruct2 := ( cFromAlias )->( xDbStruct() )

         FOR nCount := 1 TO Len( aStruct1 )
            aStruct1[ nCount ] := cAlias + "->" + aStruct1[ nCount, 1 ]
         NEXT

         FOR nCount := 1 TO Len( aStruct2 )
            aStruct2[ nCount ] := cFromAlias  + "->" + aStruct2[ nCount, 1 ]
         NEXT

         aReplace := {}

         FOR nCount := 1 TO Len( aStruct1 )

            nPos := aScan( aStruct2, { |x| Right( x, 7 ) = Right( aStruct1[ nCount ], 7 ) } )

            IF nPos > 0
               aAdd( aReplace, { aStruct1[ nCount ], aStruct2[ nPos ] } )
            ENDIF

         NEXT

         ( cFromAlias )->( mxTop() )
         ( cFromAlias )->( prgsStart( "Copiando " + cFile ) )

         DO WHILE ( cFromAlias )->( !Eof() ) .AND. ( cFromAlias )->( Eval( bWhile ) )

            prgsNext()

            IF ! ( cFromAlias )->( Eval( bFor ) )
               ( cFromAlias )->( mxSkip() )
               LOOP
            ENDIF

            ( cAlias )->( mxAppend() )

            aEval( aReplace, { |f| &( f[1] ) := &( f[2] ) } )
            
            IF bReplace <> NIL
               ( cAlias )->( Eval( bReplace ) )
            ENDIF

            ( cAlias )->( mxUnlock(.F.) )

            ( cFromAlias )->( mxSkip() )

         ENDDO

         IF lClose
            mxClose( cFromAlias )
         ENDIF

      ENDIF

      lReturn := .T.

   ENDSEQUENCE

   IF Select( cAlias ) > 0
      Select( cAlias )
   ENDIF

RETURN( lReturn )



PROCEDURE mxPack()

   PACK

RETURN( NIL )



PROCEDURE mxZap( cTable )

   //IF sqlActive() .AND. RddName() = "SQLRDD"
   //   vDef( @cTable, sqlGetInfo( Alias(), "SCHEMA" ) + "." + Alias() )
   //   sqlExecute( "DELETE FROM " + cTable )
   //ELSE
      ZAP
   //ENDIF

RETURN( NIL )



FUNCTION mxConfTrans()

   LOCAL cLog, nTrans

   IF Used() .AND. RddName() = "SQLRDD" .AND. ! lNoConfTrans .AND. mxTransMode() .AND. ! Empty( GetActTrans() ) .AND. aScan( aNoTrans, Alias() ) = 0
   
      nTrans := aScan( aTransFiles, { |x| x[ TRANS_NAME ] = GetActTrans() } )

      IF nTrans <> 0 .AND. aScan( aTransFiles[ nTrans, TRANS_ALIAS ], Alias() ) = 0

         aAdd( aNoTrans, Alias() )

         cLog := DtoC( Date() ) + " " + Alias() + " -> " + GetActTrans() + _NL

         FOR nCount := 1 TO 5
            IF ! Empty( ProcName( nCount ) )
               cLog += ProcName( nCount ) + "(" + NumToStr( ProcLine( nCount ) ) + ")" + _NL
            ENDIF
         NEXT

         cLog += _NL

         mxFAddLine( "LOGS\TRANS.LOG", cLog )
         ScreenSave()
         MsgDlg( "O arquivo " + Alias() + " n„o foi inclu¡do;na transa‡„o " + GetActTrans() + " !;;" + ProcName( 2 ) + " -> " + StrZero( ProcLine( 2 ), 4 ), "00:15" )
         ScreenRest()

      ENDIF

   ENDIF

RETURN( NIL )



FUNCTION mxDelIndexs()

   IF RddName() = "SQLRDD"
      SR_Exec( { || SR_DropIndex( Alias() ) } )
   ELSE
      DO WHILE ! Empty( IndexKey( 1 ) )
         OrdDestroy( OrdName( 1 ) )
      ENDDO
   ENDIF

RETURN( NIL )



FUNCTION mxDBFName( cName, cRdd )

   vDef( @cRdd, If( sqlActive(), "SQLRDD", "DBFCDX" ) )

   IF cRdd = "SQLRDD"
      IF GetExt( cName ) = ".DBF"
         cName := DelExt( cName )
      ENDIF
   ELSEIF At( ".", cName ) = 0
      cName += ".DBF"
   ENDIF

RETURN( cName )



FUNCTION mxVTrans( lConf )

   LOCAL lOldSet := lConfTrans

   IF lConf <> NIL
      lConfTrans := lConf
   ENDIF

RETURN( lOldSet )



FUNCTION mxReplace( cField, uReplace, lReplace )

   LOCAL nPosAlias := At( "->", cField )

   LOCAL cAlias, uFieldSave, cLogField

   vDef( @lReplace, .T. )

   IF lReplace

      IF nPosAlias = 0

         cAlias := Alias()

         IF Len( cField ) = 3 .AND. Left( cAlias, 2 ) = "MX"
            cField := sisFlgModule() + cField + Subs( cAlias, 3, 3 )
         ENDIF
         cField := cAlias + "->" + cField

      ELSE

         cAlias := Left( cField, nPosAlias -1 )

      ENDIF

      cFieldReplace := cField

      uFieldSave := &cField
      
      IF ValType( uReplace ) = "C"
         IF lChr0Clear
            uReplace := StrTran( uReplace, Chr(0), Space(1) )
         ENDIF
      ELSEIF ValType( uReplace ) = "D"
         IF DtoC( uReplace ) = DtoC( CtoD( "" ) +1 )
            uReplace := CtoD( "" )
         ENDIF
      ENDIF

      &cField := uReplace

      TraceLog( "gravado campo " + cField + " = " + UtoC( uFieldSave ) + " -> " + UtoC( uReplace ) )

      IF Len( aLogReplace ) > 0 .AND. ! Empty( uFieldSave ) .AND. uFieldSave <> uReplace
         cLogField := AllTrim( Upper( Subs( cField, At( "->", cField ) + 2 ) ) )
         IF aScan( aLogReplace, { |x| x = cLogField } ) > 0
            mxFAddLine( "LOGS\MXREPLAC.LOG", PadR( cField, 21 ) + Str( mxRecNo(), 19 ) + " " + PadR( GetActTrans(), 20 ) + PadR( UtoC( &( IndexKey(1) ) ), 60 ) + UtoC( uFieldSave ) + " -> " + UtoC( uReplace ) )
         ENDIF
      ENDIF

   ENDIF

   cFieldReplace := NIL

RETURN( NIL )



FUNCTION mxLockReplace( cTran, cField, uReplace, lMsg, lReplace )

   vDef( @lMsg    , .F. )
   vDef( @lReplace, .T. )

   IF lReplace

      GetBookMark()
      IF cTran <> NIL .AND. RddName() = "SQLRDD"
         mxTran( cTran, { Alias() }, lMsg )
      ENDIF
      mxRecLock( NIL, .F. )
      mxReplace( cField, uReplace )
      mxUnlock(.F.)
      IF cTran <> NIL .AND. RddName() = "SQLRDD"
         mxTran( cTran )
      ENDIF
      GoToBookMark()

   ENDIF

RETURN( NIL )



FUNCTION mxLockDelete( cTran, lMsg )

   vDef( @lMsg, .F. )

   mxTran( cTran, { Alias() }, lMsg )
   mxDelete( NIL, .F. )
   mxTran( cTran )

RETURN( NIL )



FUNCTION mxGetFReplace()

RETURN( cFieldReplace )



FUNCTION IsTrans( cAlias )

   LOCAL lReturn := .F.
   LOCAL nTrans
   
   IF Len( cAlias ) = 3
      cAlias := "MX" + cAlias + sisFlgModule()
   ENDIF
   
   FOR nTrans := 1 TO Len( aTransFiles )
      IF aScan( aTransFiles[ nTrans, TRANS_NAME ], cAlias ) > 0
         lReturn := .T.
         EXIT
      ENDIF
   NEXT

RETURN( lReturn )



FUNCTION DefAbortOpError( lAbort )

   LOCAL lOldAbort := lAbortOpError

   IF lAbort <> NIL
      lAbortOpError := lAbort
   ENDIF

RETURN( lOldAbort )



FUNCTION mxAddLogReplace( cField )

   IF cField <> NIL
      aAdd( aLogReplace, AllTrim( Upper( cField ) ) )
   ENDIF

RETURN( aLogReplace )



FUNCTION mxOrdList( lDicSql )

   LOCAL aOrder := {}
   LOCAL nOrder := 0

   vDef( @lDicSql, .F. )

   IF lDicSql

      sqlExecute( "SELECT CFIDESDIC FROM MXDICCFI WHERE CFIALIDIC='" + Upper( Alias() ) + "' AND CFISTADIC='3' ORDER BY CFINOMDIC", @aOrder, .F. )
      
      FOR nOrder := 1 TO Len( aOrder )
         aOrder[ nOrder ] := aOrder[ nOrder, 1 ]
         IF At( ";", aOrder[ nOrder ] ) > 0
            aOrder[ nOrder ] := Subs( aOrder[ nOrder ], At( ";", aOrder[ nOrder ] ) +1 )
         ENDIF
      NEXT

   ELSE

      DO WHILE ! Empty( IndexKey( ++ nOrder ) )
         aAdd( aOrder, TiraEspacos( IndexKey( nOrder ) ) )
      ENDDO

   ENDIF
   
RETURN( aOrder )



FUNCTION dbKeyControl( lControl )

   LOCAL lReturn := lKeyControl

   IF lControl <> NIL
      lKeyControl := ( lControl .AND. sqlActive() )
   ENDIF

RETURN( lReturn )



PROCEDURE dbKeyCreate( lIndex )

   #define KEY_STR  { { "C_FILE"  , "C",  8, 0 },;
                      { "N_KEYCTR", "N", 15, 0 },;
                      { "BKP_UPD" , "C",  1, 0 } }

   #define KEY_IDX  { { "001", "C_FILE" } }

   vDef( @lIndex, .F. )

   IF dbKeyControl()

      cKeyFile  := "MXKEYCFI"
      cKeyAlias := "MXKEYCFI"

      IF ! dbFile( cKeyFile )
         mxDbCreate( cKeyFile, KEY_STR, KEY_IDX, "SQLRDD" )
      ELSEIF lIndex
         mxOpen( 0, cKeyFile, cKeyAlias, "SQLRDD", .T., NIL, .F. )
         IF Empty( ( cKeyAlias )->( IndexKey(1) ) )
            INDEX ON C_FILE TAG MXKEYCF1
         ENDIF
         mxClose( cKeyAlias )
      ENDIF

   ENDIF

RETURN( NIL )



FUNCTION dbKeySequence( nSequence, cAlias )

   LOCAL cAliasSave := Alias()
   LOCAL aResult    := {}

   LOCAL nConnSave, nPos, cKeyLocate

   IF dbKeyControl()

      IF nSequence = NIL
         cAlias := cAliasSave
      ELSE
         cAlias := DelExt( GetNameFile( cAlias ) )
      ENDIF

      IF cKeyForceAlias = NIL
         cKeyLocate := cAlias
      ELSE
         cKeyLocate := cKeyForceAlias
      ENDIF

      //mxClose( cKeyAlias )

      IF Select( cKeyAlias ) = 0

         nConnSave := sqlSetConn( NIL      ,;
                                  "CS_LOJA",;
                                  "PUBLIC"  )

         mxOpen( 0, cKeyFile, cKeyAlias, "SQLRDD", .T., NIL, .F. )

         sqlSetConn( nConnSave )

      ENDIF

      nPos := aScan( getOpenFiles(), { |x| x[1] = cAlias } )

      IF nPos > 0
         nConnSave := sqlSetConn( getOpenFiles()[ nPos, 3  ] )
      ENDIF

      IF nSequence = NIL

         nSequence := 0

         IF  Left( cKeyLocate, 2 ) = "MX" .AND. Right( cKeyLocate, 3 ) = sisFlgModule()

            FOR nPos := 1 TO 5
               IF ! ( cKeyAlias )->( mxSeek( 1, { cKeyLocate } ) )
                  nSequence := 0
                  IF sqlExecute( "SELECT MAX( R_KEYCTR ) FROM " + cKeyLocate, @aResult, .F. )
                     nSequence := aResult[ 1, 1 ]
                  ENDIF
                  ( cKeyAlias )->( mxAppend( NIL, .F. ) )
                  ( cKeyAlias )->( mxReplace( "C_FILE"  , cKeyLocate ) )
                  ( cKeyAlias )->( mxReplace( "N_KEYCTR", nSequence ) )
                  ( cKeyAlias )->( mxUnlock(.F.) )
               ENDIF
               ( cKeyAlias )->( DbSkip(0) )
               IF ( cKeyAlias )->C_FILE = cKeyLocate
                  nSequence := dbKeyDefCtr( ( cKeyAlias )->N_KEYCTR )
                  ( cKeyAlias )->( mxRecLock( NIL, .F. ) )
                  ( cKeyAlias )->( mxReplace( "N_KEYCTR", nSequence ) )
                  ( cKeyAlias )->( mxReplace( "BKP_UPD" , "S" ) )
                  ( cKeyAlias )->( mxUnlock(.F.) )
                  EXIT
               ENDIF
            NEXT

            IF nSequence = 0
               mxTranEnd(.F.)
               MsgDlg( "N„o foi poss¡vel definir a sequˆncia;do arquivo de controle !" )
               Fim(0)
            ENDIF

         ENDIF

      ELSE

         IF ! ( cKeyAlias )->( mxSeek( 1, { cKeyLocate } ) )
            ( cKeyAlias )->( mxAppend( NIL, .F. ) )
            ( cKeyAlias )->( mxReplace( "C_FILE", cKeyLocate ) )
            ( cKeyAlias )->( mxUnlock(.F.) )
         ENDIF
         ( cKeyAlias )->( DbSkip(0) )
         IF ( cKeyAlias )->C_FILE = cKeyLocate .AND. nSequence > ( cKeyAlias )->N_KEYCTR
            ( cKeyAlias )->( mxRecLock( NIL, .F. ) )
            ( cKeyAlias )->( mxReplace( "N_KEYCTR", nSequence ) )
            ( cKeyAlias )->( mxReplace( "BKP_UPD" , "S" ) )
            ( cKeyAlias )->( mxUnlock(.F.) )
         ENDIF

      ENDIF

   ENDIF

   IF nConnSave <> NIL
      sqlSetConn( nConnSave )
   ENDIF

   IF dbIsOpen( cAliasSave )
      Select( cAliasSave )
   ENDIF

RETURN( nSequence )



FUNCTION dbKeyBkp( cAlias )

   LOCAL cKeyLocate

   vDef( @cAlias, Alias() )

   IF cKeyForceAlias = NIL
      cKeyLocate := cAlias
   ELSE
      cKeyLocate := cKeyForceAlias
   ENDIF

   IF ( cKeyAlias )->( mxSeek( 1, { cKeyLocate } ) )
      ( cKeyAlias )->( mxRecLock( NIL, .F. ) )
      ( cKeyAlias )->( mxReplace( "BKP_UPD" , "S" ) )
      ( cKeyAlias )->( mxUnlock(.F.) )
   ENDIF

RETURN( NIL )



FUNCTION dbKeyDefCtr( nSequence )

   LOCAL nReturn := nSequence

   IF CFICNXCTR = "N"
      nReturn ++
   ELSE
      nReturn := Left( Str( nReturn, 15 ), 12 )
      nReturn := Str( Val( nReturn ) +1 )
      nReturn := Val( nReturn + StrZero( CFINLJCTR, 3 ) )
   ENDIF

RETURN( nReturn )



FUNCTION mxChr0Clear( lClear )

   // Qdo habilitado, elimina dos CHR(0) trocando por CHR(32) em mxReplace().

   LOCAL lReturn := lChr0Clear

   IF lClear <> NIL
      lChr0Clear := lClear
   ENDIF

RETURN( lReturn )


/*
FUNCTION defKeyCtr( cTabela )

   LOCAL aResult := {}
   LOCAL lReturn := .F.
   LOCAL nCodigo := 0

   vDef( @cTabela, Alias() )

   BEGIN SEQUENCE

      IF ! dbKeyControl()
         lReturn := .T.
         BREAK
      ENDIF

      IF Select( "MXKEYCFI" ) = 0
         BREAK
      ENDIF
      IF ! sqlExecute( "SELECT CFICODKEY FROM MXKEYCFI WHERE CFITABKEY = '" + cTabela + "'", @aResult, .F. )
         BREAK
      ENDIF
      IF Len( aResult ) = 0
         MXKEYCFI->( mxAppend( NIL, .F. ) )
         MXKEYCFI->( mxReplace( "TAB", cTabela ) )
      ELSE
         MXKEYCFI->( mxRecLock( NIL, .F. ) )
         nCodigo := MXKEYCFI->CFICODKEY
      ENDIF
      nCodigo ++
      MXKEYCFI->( mxReplace( "COD", nCodigo ) )
      MXKEYCFI->( mxUnlock(.F.) )

      IF ! CNX_OFFLINE
         nCodigo := Val( Str( CFINLJCTR, 3 ) + StrZero( nCodigo, 12 ) )
      ENDIF

      lReturn := .T.

   ENDSEQUENCE

RETURN( nCodigo )
*/



FUNCTION keyForceAlias( cAlias )

   cKeyForceAlias := cAlias

RETURN( cKeyForceAlias )



FUNCTION mxDbSetFilter( cFilter )

   LOCAL cReturn := dbFilter()
   
   IF cFilter = NIL .OR. Empty( cFilter )
      SET FILTER TO
   ELSE
      SET FILTER TO &cFilter
   ENDIF
   
RETURN( cReturn )