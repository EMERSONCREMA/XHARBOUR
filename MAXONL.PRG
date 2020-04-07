/*

 MaxOnl.prg
 Descricao: Biblioteca de funcoes p/ operacoes online.
 Desenvolvido por MAX SCALLA Informatica Ltda.
 Valido apenas p/ o Control Shop.
 
 EMERSON DA SILVA CREMA
 07/10/19 * Implementado em olSqlInsert() a gravacao de CFISISCNX.
 15/05/19 * Correcao em sndGetInfo(), pois estava executando indevidamente
            o Upper() para comandos SQL.
 02/02/18 * Removida a funcao olFCreate().
 18/08/16 * Implementado consistencias p/ trabalhar com ONL_OP_SELECT.
 11/08/16 * Desenvolvido:
            - olDefTabAliasMov()
            - sndCnxNoSendMov()
            - sndDelCnxNoSendMov()
          * Implementado as definicoes ONL_TabAliasMov eONL_aCnxNoSendMov.
          * Alterado sndIsProcess() p/ consistir se as tabelas de movimentos
            serao ou nao enviadas.
 09/06/15 * Redefinicao do SELECT de cliLoja().
 14/08/14 * Alterado sndNoFSend() p/ q permita parametrizar uma matriz inteira
            em substituicao a parametrizacao dos campos de controle.
 09/06/14 * Na definicao do conteudo do campo caracter em sndField(), esta sendo
            trocado Chr(13)+Chr(10) por Chr(19), para q seja possivel enviar
            campos do tipo "Text". Serao retornados os caracteres pelo CSW.
 29/05/14 * Removidas atualizacoes de MXOBSCFI.
          * Removido olFileScpc().
 23/04/14 * Reformulado cliLoja() c/ novo padrao de 9 digitos.
 17/03/14 * Desenvolvimento de olRcvIsRepass(), olGetOrigem() e olIsNewFile().
 16/01/14 * Removido de sndPost() a utilizacao de CFIOB2DUP.
 11/11/13 * Transferido cliLoja() de MAXCLI01.PRG.
 16/08/13 * Desenvolvimento de sndIsUpdConnections().
 08/04/13 * Desenvolvimento e implementacao de olSqlInsert().

 DENIS MAZZUCATTO RODRIGUES
 14/03/13 * Removido parametro lLocal de sndFOnly().
 07/03/13 * Implementada gravacao em MXOUT via instrucao SQL em olRename() e
            removida transacao OL_NEWSEND.
 05/02/13 * Implementada condicao p/ CEM_PROCESSA em sndPost().
 18/01/13 * Corrigidos parametros de olRename() em olFileScpc() q gerava varios
            registros em MXOUT p/ a loja 3 sem informacao alguma.
 16/01/13 * Remocao de ONL_lRecvBack e rcvDefBack().

 EMERSON DA SILVA CREMA.
 04/12/12 * Remocao de olNewSend().

 DENIS MAZZUCATTO RODRIGUES
 17/01/12 * Alteracao em olFCreate() p/ criar o arquivo .TMP na pasta CONEXAO.
 29/11/11 * Ajustes em olRename() referente a abertura de transacao p/ o novo
            processo do online.

 EMERSON DA SILVA CREMA
 15/09/11 * Inclusos comandos SQL em sndSequence().

 DENIS MAZZUCATTO RODRIGUES
 01/08/11 * Implementada consistencia em sndEnd() p/ checar o tamanho do arq.
 28/06/11 * Implementacao de ONL_aOnlyProcess.

 EMERSON DA SILVA CREMA
 24/03/10 * Correcao em sndGetInfo(), pois causava erro em sndFLoja() por
            nao ter um ALIAS definido p/ a mesma.
 19/02/10 * Implementadas as definicoes KEY_*.*.
          * Implementado parametro uDefKey em sndGetInfo() e sndGetKey().
 22/10/09 * Removida condicao p/ ONL_aInfoFNoSend.

 DENIS MAZZUCATTO RODRIGUES
 18/09/09 * Implementada consistencia p/ o CODCCC em olSolicCod().

 EMERSON DA SILVA CREMA
 28/07/09 * Desenvolvimento e implementacao de sndSeleConnection().
 27/07/09 * Implementadas adaptacoes p/ gravacao de CFIDSOLIS e CFISOFLIS.
 10/06/09 * Desenvolvimento e implementacao de sndForceConnection().
 07/04/09 * Desenvolvimento de sndSaveKey().
 31/03/09 * Alteracao em sndField() p/ qdo forem campos numericos remover os
            espacos a esquerda e os zeros a direita e p/ campos data colocado
            o ano com 2 digitos.
 30/03/09 * Implementado em sndFLoja() verificacao da existencia de CFISTADUP.

 DENIS MAZZUCATTO RODRIGUES
 05/02/09 * Remocao de sndGetDir() e sndCnxDir().
          * Implementacao de ONL_OP_GETDIRECT.

 EMERSON DA SILVA CREMA
 23/12/08 * Desenvolvimento de onlConf() e onlConfGrv().
 05/08/08 * Trocadas as constantes SND_OP_??? por ONL_OP_???. Incluido header
            maxonl.ch.

 DENIS MAZZUCATTO RODRIGUES
 05/08/08 * Verificada existencia de CFICDADUP em sndGetKey().

 EMERSON DA SILVA CREMA
 03/07/08 * Mudado o nome do programa de MAXOLSND.PRG p/ MAXONL.PRG.
          * Movidas as funcoes isCsw(), cswActFile(), olSolicCod(), rcvKey(),
            rcvMaqDir(), rcvOpenAGE(), rcvDefBack(), rcvFileRsp() de MAXOLRCV.
 14/02/08 * Desenvolvimento de cnxOnLine().
 11/02/08 * Desenvolvimento de sndSequence().
          * Remocao de sndFSequence().
 17/01/08 * Desenvolvimento de sndDir().
 12/12/07 * Desenvolvimento de sndDelNoFSend().

 DENIS MAZZUCATTO RODRIGUES
 07/11/07 * Implementada consistencia em olRename() p/ ver se o tamanho do
            arquivo de origem e igual ao de destino.

 EMERSON DA SILVA CREMA
 05/01/07 * Implementado parametro cCond em sndNoFSend() e consistencia em
            sndPost() p/ utilizar a condicao fornecida por sndNoFSend().

 DENIS MAZZUCATTO RODRIGUES
 03/01/07 * Implementado parametro cCompl em sndGetInfo() e sndGetKey().
 28/12/06 * Implementado parametro lPrior em sndRename().
 25/10/06 * Desenvolvimento de olChrLoja().

 EMERSON DA SILVA CREMA
 07/06/06 * Implementado parametro aDefConnections em sndConnections().
 10/05/06 * Correcao em sndPost(), pois nao usava apontador p/ mxRecno().
 02/05/06 * Desenvolvimento de sndNoFSend().

 DENIS MAZZUCATTO RODRIGUES
 11/04/06 * Implementacao do MXCFGCFI em sndGetKey().
          * Implementacao em sndIsStart() p/ alterar o valor de lSendProcess.
 06/03/06 * Desenvolvimento de olFileScpc().

 EMERSON DA SILVA CREMA
 08/02/06 * Desenvolvimento de sndDelNoSend() e sndNoSend().
 31/01/06 * Desenvolvimento de sndGetDir() e olRename().
 23/01/06 * Incluso campo localizacao no estoque (LOC) p/ envio c/ o MXESTCFI.

 DENIS MAZZUCATTO RODRIGUES
 03/08/05 * Modificacoes no processo de envio das informacoes de estoque do
            Master p/ as lojas. O controle agora e feito apenas em sndEnd().

 EMERSON DA SILVA CREMA
 03/08/05 * Correcao em sndEnd() q nao gerava um arquivo so com todas as
            operacoes da transcao p/ a loja correspondente.

 DENIS MAZZUCATTO RODRIGUES
 01/08/05 * Desenvolvimento e implementacao de sndConfSequence().

 EMERSON DA SILVA CREMA
 19/05/05 * Desenvolvimento de sndCnxDir().
 18/05/05 * Correcao em sndEnd() p/ nao considerar a matriz aFOnly qdo for uma
            operacao de inclusao.

 DENIS MAZZUCATTO RODRIGUES
 29/04/05 * Adaptacoes p/ envio das formulas personalizadas.
 07/10/04 * Conclusao do desenvolvimento.

 EMERSON DA SILVA CREMA
 27/05/04 * Inicio do desenvolvimento.

*/

/*
  Composicao do arquivo:

  Nos parametros P e K, os campos sao separados por  (Chr 19)

  T=   Nome da transacao q foi utilizada.

  P=   Parametros da operacao.
       - Operation (vide maxonl.ch)
       - Alias
       - Fields (A=All, O=Only)

  K=   Chave primaria.
       - Order
       - Key

  W=   Condicao WHILE

  F=   Condicao FOR
  
  Q=   Condicao WHERE (Query)

  C=   Codigo da conexao.

  D=   Diretorio do arquivo para gravacao.

  U=   Define a alteracao de um campo chave.

  ->   Inicio da gravacao dos campos.

  ???= Nome parcial do campo. A proxima informacao e o conteudo do campo.

  <-   Fim da gravacao dos campos.

*/

#include "std.ch"
#include "maxonl.ch"
#include "sqlrdd.ch"

STATIC aOnl := { ;
                 .F.,; // 1
                 .F.,; // 2
                 .F.,; // 3
                 .F.,; // 4
                 .F.,; // 5
                 .F.,; // 6
                 "" ,; // 7
                 "" ,; // 8
                 "" ,; // 9
                 0  ,; // 10
                 {} ,; // 11
                 {} ,; // 12
                 {} ,; // 13
                 {} ,; // 15
                 {} ,; // 16
                 {} ,; // 17
                 {} ,; // 18
                 {} ,; // 19
                 {} ,; // 20
                 {} ,; // 21
                 NIL,; // 22
                 NIL,; // 22
                 .F.,; // 23
                 "" ,; // 24
                 "" ,; // 25
                 NIL,; // 26
                 NIL,; // 27
                 0  ,; // 28
                 0  ,; // 29
                 {} ,; // 30
                 {} ,; // 31
                 .F.,; // 32
                 0  ,; // 33
                 {} ,; // 34
                 {}  ; // 35
               }

#define ONL_lSendProcess    aOnl[01]
#define ONL_lSendActive     aOnl[02]
#define ONL_lMaster         aOnl[03]
#define ONL_lGetInfo        aOnl[04]
#define ONL_lGetDirect      aOnl[05]
#define ONL_lOnlConf        aOnl[06]
#define ONL_cSndTrans       aOnl[07]
#define ONL_cSendFolder     aOnl[08]
#define ONL_cSaveSequence   aOnl[09]
#define ONL_nConnection     aOnl[10]
#define ONL_aConnections    aOnl[11]
#define ONL_aNoProcess      aOnl[12]
#define ONL_aNoSend         aOnl[13]
#define ONL_aNoFSend        aOnl[14]
#define ONL_aSendProcess    aOnl[15]
#define ONL_aSendConnect    aOnl[16]
#define ONL_aSendKey        aOnl[17]
#define ONL_aSendDir        aOnl[18]
#define ONL_aFOnly          aOnl[19]
#define ONL_aUpdKey         aOnl[20]
#define ONL_uDelKey         aOnl[21]
#define ONL_uSaveKey        aOnl[22]
#define ONL_lCsw            aOnl[23]
#define ONL_cActFile        aOnl[24]
#define ONL_cRecvFolder     aOnl[25]
#define ONL_bRcvMaqDir      aOnl[26]
#define ONL_bOpenAGE        aOnl[27]
#define ONL_nForceConnect   aOnl[28]
#define ONL_nSeleConnect    aOnl[29]
#define ONL_aInfoFNoSend    aOnl[30]
#define ONL_aOnlyProcess    aOnl[31]
#define ONL_lUpdConnections aOnl[32]
#define ONL_ReplicationMode aOnl[33]
#define ONL_TabAliasMov     aOnl[34]
#define ONL_aCnxNoSendMov   aOnl[35]

#define SND_ALIAS   1
#define SND_RECNO   2
#define SND_OPER    3
#define SND_KEY     4
#define SND_CONNECT 5
#define SND_FIELDS  6
#define SND_UPDKEY  7
#define SND_FLAG    8

#define SND_NOSEND { "CLI","CLE" }

#define KEY_ALIAS 1
#define KEY_ORDER 2
#define KEY_FIELD 3

STATIC _lSendProcess := .T.
STATIC _aSendProcess := {}
STATIC _aFOnly       := {}
STATIC _cSndTrans    := ""


FUNCTION sndActive( lActive, aOnlyProcess )

   LOCAL lReturn := ONL_lSendActive

   IF lActive <> NIL
      ONL_lSendActive := lActive
      IF ! lActive
         ONL_aOnlyProcess := {}
      ELSEIF aOnlyProcess <> NIL
         ONL_aOnlyProcess := aClone( aOnlyProcess )
      ENDIF
   ENDIF

RETURN( lReturn )



FUNCTION sndStart( cTrans )

   LOCAL cAlias := Alias()

   vDef( @cTrans, "" )

   IF ONL_lSendProcess

      MsgDlg( "Processamento on-line j  iniciado em outro momento !;;"  + ;
              "Transa‡„o anterior : ^" + ONL_cSndTrans + "^;" + ;
              "Transa‡„o atual    : ^" + cTrans    + "^" )

   ENDIF
   
   ONL_aSendProcess := {}
   ONL_lSendProcess := .T.
   ONL_aFOnly       := {}
   ONL_cSndTrans    := cTrans

   IF onlConf() .AND. ! dbIsOpen( "MXONLCFI" )
      mxOpen( 0, "MXONLCFI", NIL, mxRdd(), .T., .F., .F. )
      SeleArea( cAlias )
   ENDIF

RETURN( NIL )



FUNCTION sndEnd()

   LOCAL nFOnly, nCount, nConnect, cSendFile, cSequence, cFFlag
   LOCAL aFields, nField, cCodConnect, cConnect
   LOCAL nPosUpd, nPosDir, cUpdKey, cUpdOld, cUpdNew, nDefConnect
   
   ONL_aSendConnect := {}
   ONL_lGetInfo     := .F.
   ONL_lGetDirect   := .F.
   
   FOR nCount := 1 TO Len( ONL_aSendProcess )

      IF ONL_aSendProcess[ nCount, SND_CONNECT, 1 ] >= 999
         LOOP
      ENDIF

      nFOnly := aScan( ONL_aFOnly, { |f| f[1] = ONL_aSendProcess[ nCount, SND_ALIAS ] } )

      IF nFOnly <> 0 .AND. Empty( ONL_aFOnly[ nFOnly, 2 ] )
         LOOP
      ENDIF

      IF ONL_aSendProcess[ nCount, SND_FLAG ] = NIL
         cFFlag := If( nFOnly = 0, "A", "O" )
      ELSE
         cFFlag := ONL_aSendProcess[ nCount, SND_FLAG ]
      ENDIF

      DO CASE
         CASE ONL_aSendProcess[ nCount, SND_OPER ] = ONL_OP_GETINFO   ; ONL_lGetInfo   := .T.
         CASE ONL_aSendProcess[ nCount, SND_OPER ] = ONL_OP_GETDIRECT ; ONL_lGetDirect := .T.
      ENDCASE

      // Verifica as conexoes q nao devem ser integradas

      nDefConnect := ONL_aSendProcess[ nCount, SND_CONNECT, 1 ]

      BEGIN SEQUENCE

         IF nDefConnect <> 0
            BREAK
         ENDIF

         IF ! mxIn( ONL_aSendProcess[ nCount, SND_ALIAS ], SND_NOSEND )
            BREAK
         ENDIF

         IF sndMaster()

            IF ONL_aSendProcess[ nCount, SND_CONNECT, 2 ] <> NIL .AND. ;
               ONL_aSendProcess[ nCount, SND_CONNECT, 2 ] > 0
               BREAK
            ENDIF

            nConnect := sndFLoja( ONL_aSendProcess[ nCount ] )

         ELSE

            nConnect := sndDefConnection()

         ENDIF

         IF ! mxIn( nConnect, sndNoSend() )
            BREAK
         ENDIF

         nDefConnect := nConnect

         ONL_aSendProcess[ nCount, SND_CONNECT, 1 ] := nDefConnect

      ENDSEQUENCE

      nConnect := aScan( ONL_aSendConnect, { |c| c[1] = nDefConnect } )

      // Definicao da conexao q gerou o arquivo e a loja do registro

      IF ONL_lGetDirect .OR. ONL_aSendProcess[ nCount, SND_CONNECT, 1 ] = 0
         cCodConnect := CHR_SEP + StrZero( sndDefConnection(), 3 )
      ELSE
         cCodConnect := CHR_SEP + StrZero( ONL_aSendProcess[ nCount, SND_CONNECT, 1 ], 3 )
      ENDIF

      IF ONL_aSendProcess[ nCount, SND_CONNECT, 2 ] = NIL
         cCodConnect += CHR_SEP + "000"
      ELSE
         cCodConnect += CHR_SEP + StrZero( ONL_aSendProcess[ nCount, SND_CONNECT, 2 ], 3 )
      ENDIF

      cCodConnect += CHR_SEP

      IF nConnect = 0

         cSequence := sndSequence()

         sndConfSequence( cSequence )

         IF ONL_aSendProcess[ nCount, SND_CONNECT, 1 ] = 0
            cConnect := "000"
         ELSE
            cConnect := olChrLoja( ONL_aSendProcess[ nCount, SND_CONNECT, 1 ] )
         ENDIF

         IF sndMaster() .OR. ONL_lGetDirect
            cSendFile := "M"
         ELSE
            cSendFile := "L"
         ENDIF

         cSendFile := cConnect + cSendFile + cSequence + ".TMP"

         aAdd( ONL_aSendConnect, { ONL_aSendProcess[ nCount, SND_CONNECT, 1 ], cSendFile, "" } )

         nConnect := Len( ONL_aSendConnect )

         // Nome da transacao.

         IF ! Empty( ONL_cSndTrans )
            ONL_aSendConnect[ nConnect, 3 ] += "T=" + ONL_cSndTrans + _NL
         ENDIF

      ELSE

         cSendFile := ONL_aSendConnect[ nConnect, 2 ]
         
      ENDIF

      // Parametros da operacao.

      ONL_aSendConnect[ nConnect, 3 ] += "P=" + CHR_SEP + ONL_aSendProcess[ nCount, SND_OPER ] + CHR_SEP

      IF ONL_aSendProcess[ nCount, SND_OPER ] <> ONL_OP_SELECT
         ONL_aSendConnect[ nConnect, 3 ] += ONL_aSendProcess[ nCount, SND_ALIAS ] + CHR_SEP + cFFlag + CHR_SEP
      ENDIF
      
      ONL_aSendConnect[ nConnect, 3 ] += _NL
      
      IF ONL_aSendProcess[ nCount, SND_OPER ] <> ONL_OP_SELECT

         // Diretorio do arquivo.

         nPosDir := aScan( ONL_aSendDir, { |x| x[1] = ONL_aSendProcess[ nCount, SND_ALIAS ] } )

         IF nPosDir <> 0
            ONL_aSendConnect[ nConnect, 3 ] += "D=" + CHR_SEP + blockToVal( ONL_aSendDir[ nPosDir, 2 ] ) + CHR_SEP + _NL
         ENDIF

         // Chave de localizacao do registro.

         ONL_aSendConnect[ nConnect, 3 ] += "K=" + ONL_aSendProcess[ nCount, SND_KEY ] + _NL
         
      ENDIF

      // Qdo e uma informacao q deve ser redistribuida, informa-se a
      // conexao q gerou a operacao.

      ONL_aSendConnect[ nConnect, 3 ] += "C=" + cCodConnect + _NL

      IF ONL_aSendProcess[ nCount, SND_OPER ] <> ONL_OP_SELECT

         // Informa-se o campo, q qdo alterado deve-se alterar todos os
         // relacionamentos dentro do sistema.

         IF ONL_aSendProcess[ nCount, SND_UPDKEY ] <> NIL

            cUpdOld := ONL_aSendProcess[ nCount, SND_UPDKEY, 2 ]

            IF ONL_aSendProcess[ nCount, SND_OPER ] = ONL_OP_DELETE
               cUpdNew := ONL_aSendProcess[ nCount, SND_UPDKEY, 3 ]
            ELSE
               cUpdKey := ONL_aSendProcess[ nCount, SND_UPDKEY, 1 ]

               IF Right( cUpdKey, 3 ) = ONL_aSendProcess[ nCount, SND_ALIAS ]
                  cUpdKey := Subs( cUpdKey, 4, 3 )
               ELSE
                  cUpdKey := Subs( cUpdKey, 4, 5 )
               ENDIF

               nPosUpd := aScan( ONL_aSendProcess[ nCount, SND_FIELDS ], { |a| Left( a, At( "=", a ) -1 ) = cUpdKey } )

               IF nPosUpd = 0
                  cUpdNew := cUpdOld
               ELSE
                  cUpdNew := ONL_aSendProcess[ nCount, SND_FIELDS, nPosUpd ]
                  cUpdNew := Subs( cUpdNew, At( "=", cUpdNew ) +1 )
               ENDIF
            ENDIF

            IF cUpdOld <> cUpdNew
               ONL_aSendConnect[ nConnect, 3 ] += "U=" + CHR_SEP + ONL_aSendProcess[ nCount, SND_UPDKEY, 1 ] + CHR_SEP + cUpdOld + CHR_SEP + cUpdNew + CHR_SEP + _NL
            ENDIF

         ENDIF
         
      ENDIF

      // Flag de inicio da gravacao dos campos.

      ONL_aSendConnect[ nConnect, 3 ] += "->" + _NL

      aFields := ONL_aSendProcess[ nCount, SND_FIELDS ]
      
      FOR nField := 1 TO Len( aFields )

         IF ! ONL_lGetInfo .AND. ONL_aSendProcess[ nCount, SND_OPER ] <> ONL_OP_INSERT .AND. nFOnly <> 0 .AND. aScan( ONL_aFOnly[ nFOnly, 2 ], { |f| f = Left( aFields[ nField ], At( "=", aFields[ nField ] ) -1 ) } ) = 0
            LOOP
         ENDIF

         // Campo a ser enviado.

         ONL_aSendConnect[ nConnect, 3 ] += aFields[ nField ] + _NL

      NEXT

      // Flag de fim da gravacao dos campos.

      ONL_aSendConnect[ nConnect, 3 ] += "<-" + _NL
      
   NEXT

   IF Len( ONL_aInfoFNoSend ) > 0
   
      // Campos de nao devem ser gravados

      ONL_aSendConnect[ nConnect, 3 ] += "NS->" + _NL

      FOR nField := 1 TO Len( ONL_aInfoFNoSend )
         ONL_aSendConnect[ nConnect, 3 ] += ONL_aInfoFNoSend[ nField, 1 ] + _NL
      NEXT

      ONL_aSendConnect[ nConnect, 3 ] += "<-NS" + _NL

   ENDIF

   ONL_lSendProcess := .F.
   ONL_aSendProcess := {}
   ONL_aFOnly       := {}
   ONL_cSndTrans    := ""

RETURN( cSendFile )



FUNCTION sndRename( lPrior )

   LOCAL cFolder := sndFolder()

   LOCAL nCount, nConnect, nRename
   LOCAL cSendRename, cSendFile, aRename

   vDef( @lPrior, .F. )

   IF ONL_lGetInfo .OR. ONL_lGetDirect
      lPrior := .T.
   ENDIF

   IF lPrior
      cFolder += "PRIOR\"
   ENDIF

   FOR nCount := 1 TO Len( ONL_aSendConnect )

      cSendFile := ONL_aSendConnect[ nCount, 2 ]

      aRename := {}

      IF sndMaster() .AND. Left( GetNameFile( cSendFile ), 3 ) = "000"

         cSendRename := DelPath( ModExt( cSendFile, "SND" ) )

         FOR nConnect := 1 TO Len( ONL_aConnections )
            IF mxIn( sndSeleConnection(), { 0, 999, ONL_aConnections[ nConnect, 1 ] } )
               aAdd( aRename, { cFolder + olChrLoja( ONL_aConnections[ nConnect, 1 ] ) + Subs( cSendRename, 4 ), ONL_aSendConnect[ nCount, 3 ] } )
            ENDIF
         NEXT

      ELSE

         cSendRename := cFolder + DelPath( ModExt( cSendFile, If( ONL_lGetDirect, "DIR", "SND" ) ) )

         aAdd( aRename, { cSendRename, ONL_aSendConnect[ nCount, 3 ] } )

      ENDIF

      FOR nRename := 1 TO Len( aRename )
         olRename( cSendFile, aRename[ nRename ] )
      NEXT

   NEXT

   ONL_lGetInfo := .F.
   sndSeleConnection( 0 )

RETURN( NIL )



FUNCTION sndSave()

   _aSendProcess := ONL_aSendProcess
   _lSendProcess := ONL_lSendProcess
   _aFOnly       := ONL_aFOnly
   _cSndTrans    := ONL_cSndTrans

   ONL_lSendProcess  := .F.

RETURN( NIL )



FUNCTION sndRest()

   ONL_aSendProcess  := _aSendProcess
   ONL_lSendProcess  := _lSendProcess
   ONL_aFOnly        := _aFOnly
   ONL_cSndTrans     := _cSndTrans

   _aSendProcess := {}
   _lSendProcess := .T.
   _aFOnly       := {}
   _cSndTrans    := ""

RETURN( NIL )



FUNCTION sndIsStart( lSend )

   LOCAL lReturn := ONL_lSendProcess

   IF lSend <> NIL
      ONL_lSendProcess := lSend
   ENDIF

RETURN( lReturn )



FUNCTION sndNameTrans()

RETURN( ONL_cSndTrans )



FUNCTION sndUpdate( cAlias, cOper )

   LOCAL nSend

   vDef( @cOper , ONL_OP_UPDATE )
   vDef( @cAlias, Alias()       )

   BEGIN SEQUENCE

      IF ( Left( cAlias, 2 ) <> "MX" ) .OR. ;
         ( ! sndActive()             ) .OR. ;
         ( ! sndIsProcess( cAlias )  )
         BREAK
      ENDIF

      cAlias := Subs( cAlias, 3, 3 )
      nSend  := sndDefProcess( cAlias, cOper )

   ENDSEQUENCE

RETURN( NIL )



FUNCTION sndDelete( cAlias, nConnect )

   LOCAL nSend, cField, nFLoja

   vDef( @cAlias  , Alias() )
   vDef( @nConnect, 0       )

   BEGIN SEQUENCE

      IF Left( cAlias, 2 ) <> "MX"
         BREAK
      ELSEIF ! sndActive()
         BREAK
      ELSEIF ! sndIsProcess( cAlias )
         BREAK
      ENDIF

      cAlias := Subs( cAlias, 3, 3 )

      nFLoja := sndFLoja()

      IF nConnect = 0 .AND. nFLoja <> NIL
         IF sndMaster()
            nConnect := nFLoja
         ELSE
            nConnect := sndDefConnection()
         ENDIF
      ENDIF
      
      nSend := sndDefProcess( cAlias, ONL_OP_DELETE )

      ONL_aSendProcess[ nSend, SND_KEY ]     := sndGetKey( cAlias )
      ONL_aSendProcess[ nSend, SND_CONNECT ] := { nConnect, nFLoja }

   ENDSEQUENCE

RETURN( NIL )



STATIC FUNCTION sndFLoja( aField )

   LOCAL nReturn, nPos, cField, cLoja

   BEGIN SEQUENCE

      IF aField = NIL

         cField := Stuff( Field( 1 ), 4, 3, "NLJ" )

         IF sndForceConnection() <> 0

            nReturn := sndForceConnection()

         ELSEIF FieldPos( cField ) > 0

            IF cField = "CFINLJDUP" .AND. Select( "MXDUPCFI" ) > 0 .AND. IsDef( "MXDUPCFI->CFISTADUP" ) .AND. MXDUPCFI->CFISTADUP = "Cance"
               cField := "CFINLADUP"
            ENDIF

            nReturn := FieldGet( FieldPos( cField ) )

            IF ValType( nReturn ) = "C"
               nReturn := Val( nReturn )
            ENDIF

         ELSEIF ! sndMaster() .AND. Right( cField, 3 ) = "LIS"

            nReturn := sndDefConnection()

         ENDIF

         BREAK

      ENDIF

      nReturn := 0

      nPos := aScan( aField[ SND_FIELDS ], { |f| Left( f, 3 ) = "NLJ" } )

      IF foundStr( aField[ SND_ALIAS ], "CLI" )

         nPos := aScan( aField[ SND_FIELDS ], { |f| Left( f, 3 ) = "COD" } )

         IF nPos > 0
            cLoja   := "cliLoja( " + Subs( aField[ SND_FIELDS, nPos ], 5 ) + " )"
            nReturn := &cLoja
         ENDIF

      ELSEIF nPos > 0

         nReturn := Val( Subs( aField[ SND_FIELDS, nPos ], 5 ) )

      ENDIF

   ENDSEQUENCE

RETURN( nReturn )



FUNCTION sndGetInfo( cAlias, aFGet, nConnect, nFLoja, cCompl, uDefKey )

   LOCAL nSend

   // *** Nao mudar a posicao das linhas abaixo ***
   
   vDef( @cAlias, Alias() )

   IF Empty( Alias() )
      Select( cAlias )
   ENDIF

   // ***

   vDef( @nConnect, 0          )
   vDef( @nFLoja  , sndFLoja() )

   cAlias := Subs( cAlias, 3, 3 )
   
   IF cCompl <> NIL .AND. cCompl = "ONL_OP_GETDIRECT"
      cCompl := NIL
      nSend  := sndDefProcess( cAlias, ONL_OP_GETDIRECT )
   ELSEIF cCompl <> NIL .AND. cCompl = "ONL_OP_SELECT"
      cCompl := NIL
      nSend  := sndDefProcess( cAlias, ONL_OP_SELECT )
   ELSE
      nSend  := sndDefProcess( cAlias, ONL_OP_GETINFO )
   ENDIF

   ONL_aSendProcess[ nSend, SND_KEY     ] := sndGetKey( cAlias, cCompl, uDefKey )
   ONL_aSendProcess[ nSend, SND_CONNECT ] := { nConnect, nFLoja }

   aEval( aFGet, { |f| aAdd( ONL_aSendProcess[ nSend, SND_FIELDS ], If( foundStr( Upper( AllTrim( Left( f, 6 ) ) ), "SELECT|UPDATE|DELETE" ), f, Upper( f ) ) + "?" ) } )

RETURN( NIL )



FUNCTION sndPost( cAlias, nConnect )

   LOCAL nSend, nCount, cField, nFLoja, cDefAlias, nNoFSend

   vDef( @cAlias  , Alias() )
   vDef( @nConnect, 0       )

   BEGIN SEQUENCE

      IF Left( cAlias, 2 ) <> "MX"
         BREAK
      ELSEIF ! sndActive()
         BREAK
      ELSEIF ! sndIsProcess( cAlias )
         BREAK
      ENDIF

      cDefAlias := cAlias

      cAlias := Subs( cAlias, 3, 3 )
      nSend  := aScan( ONL_aSendProcess, { |s| s[ SND_ALIAS ] = cAlias                       .AND. ;
                                               s[ SND_RECNO ] = ( cDefAlias )->( mxRecno() ) .AND. ;
                                         mxIn( s[ SND_OPER  ], { ONL_OP_INSERT, ONL_OP_UPDATE } ) } )

      IF nSend = 0
         BREAK
      ENDIF
      
      IF cAlias = "EST"

         // No caso de alteracao no arquivo MXESTCFI as unicas informacoes
         // q devem ser enviadas p/ as lojas e o estoque minimo e maximo,
         // venda sem estoque, localizacao, data e qtde de saldo oficial.

         IF ONL_cSndTrans = "CEM_PROCESSA"
            sndFOnly( "EST", { "MIN","MAX" } )
         ENDIF

         ONL_aSendProcess[ nSend, SND_KEY ] := sndGetKey( "EST" )
         
      ELSEIF ONL_uSaveKey <> NIL

         ONL_aSendProcess[ nSend, SND_KEY ] := ONL_uSaveKey
         
      ELSE
      
         ONL_aSendProcess[ nSend, SND_KEY ] := sndGetKey( cAlias )
         
      ENDIF

      ONL_aSendProcess[ nSend, SND_FIELDS ] := {}

      nFLoja := sndFLoja()

      IF nConnect = 0 .AND. nFLoja <> NIL
         nConnect := If( sndMaster(), nFLoja, sndDefConnection() )
      ENDIF
      
      FOR nCount := 1 TO fCount()

         nNoFSend := aScan( ONL_aNoFSend, { |x| x[1] = Field( nCount ) } )

         IF nNoFSend <> 0
            IF ONL_aNoFSend[ nNoFSend, 2 ] = NIL .OR. &( ONL_aNoFSend[ nNoFSend, 2 ] )
               LOOP
            ENDIF
         ENDIF
                     
         IF Empty( FieldGet( nCount ) )
            IF aScan( ONL_aFOnly, { |f| f[1] = cAlias } ) = 0
               LOOP
            ENDIF
         ENDIF

         IF Right( Field( nCount ), 3 ) = cAlias
            cField := Subs( Field( nCount ), 4, 3 )
         ELSE
            cField := Subs( Field( nCount ), 4 )
         ENDIF

         aAdd( ONL_aSendProcess[ nSend, SND_FIELDS ], Upper( cField ) + "=" + sndField( nCount ) )

      NEXT

      ONL_aSendProcess[ nSend, SND_CONNECT ] := { nConnect, nFLoja }

   ENDSEQUENCE

RETURN( NIL )



FUNCTION sndField( uField )

   LOCAL cField

   IF ValType( uField ) = "N"
      cField := FieldGet( uField )
   ELSE
      cField := uField
   ENDIF

   DO CASE
      CASE ValType( cField ) = "N" ; cField := ZRClear( LTrim( Str( cField ) ) )
      CASE ValType( cField ) = "D" ; cField := YearTwo( cField )
      CASE ValType( cField ) = "L" ; cField := If( cField, "S", "N" )
      OTHERWISE                    ; cField := StrTran( cField, _NL, Chr(19) )
   ENDCASE

RETURN( cField )



FUNCTION sndAddKey( aKey )

   aAdd( ONL_aSendKey, aKey )

RETURN( NIL )



FUNCTION sndAddUpdKey( aUpd )

   aAdd( ONL_aUpdKey, aUpd )

RETURN( NIL )



FUNCTION sndAddDelKey( uDel )

   ONL_uDelKey := uDel

RETURN( NIL )



FUNCTION sndAddDir( cAlias, bDir )

   aAdd( ONL_aSendDir, { cAlias, bDir } )

RETURN( NIL )



FUNCTION sndDir()

RETURN( ONL_aSendDir )



FUNCTION sndGetKey( cAlias, cCompl, uDefKey )

   LOCAL nKey, cKey, uFields, cDefAlias
   
   vDef( @cAlias, Alias() )
   vDef( @cCompl, ""      )

   IF Len( cAlias ) > 3
      cDefAlias := cAlias
      cAlias    := Subs( cAlias, 3, 3 )
   ELSE
      cDefAlias := "MX" + cAlias + "CFI"
   ENDIF

   IF ! Empty( cCompl )
      cCompl := "[" + cCompl + "]"
   ENDIF
   
   nKey := aScan( ONL_aSendKey, { |k| k[ KEY_ALIAS ] = cAlias } )

   IF nKey = 0 .AND. ! Empty( ( cDefAlias )->( mxIndexKey( 1 ) ) )
      sndAddKey( { cAlias, 1 } )
      nKey := Len( ONL_aSendKey )
   ENDIF

   IF nKey <> 0

      uFields := "MX" + cAlias + "CFI->( " + ( cDefAlias )->( mxIndexKey( ONL_aSendKey[ nKey, KEY_ORDER ] ) ) + " )"

      IF "U" $ Type( uFields )

         nKey := 0

      ELSE

         IF uDefKey <> NIL

            uFields := uDefKey

         ELSEIF cAlias = "DUP" .AND. IsDef( "MXDUPCFI->CFICDADUP" ) .AND. IsDef( "MXDUPCFI->CFISTADUP" ) .AND. MXDUPCFI->CFISTADUP = "Cance"

            uFields := Str( MXDUPCFI->CFICDADUP, 8 ) + MXDUPCFI->CFICPADUP + Str( MXDUPCFI->CFINLADUP, 3 )

         ELSE

            DO CASE
               CASE Type( uFields ) = "N" ; uFields := Str( &uFields )
               CASE Type( uFields ) = "D" ; uFields := DtoC( &uFields )
               OTHE                       ; uFields := &uFields
            ENDCASE

         ENDIF

         cKey := CHR_SEP + StrZero( ONL_aSendKey[ nKey, KEY_ORDER ], 2 ) + CHR_SEP + uFields + CHR_SEP

         IF Len( ONL_aSendKey[ nKey ] ) > KEY_ORDER
            cKey += ONL_aSendKey[ nKey, KEY_FIELD ] + CHR_SEP
         ENDIF

      ENDIF

   ENDIF

   IF nKey = 0

      cKey := CHR_SEP + "00" + CHR_SEP

      IF cAlias = "COD"
         cKey += MXCODCFI->CFICMPCOD + cCompl + CHR_SEP + "CFICMPCOD"
      ELSEIF cAlias = "CFG"
         cKey += MXCFGCFI->CFICMPCFG + CHR_SEP + "CFICMPCFG"
      ELSE
         cKey += CHR_SEP
      ENDIF

      cKey += CHR_SEP

   ENDIF

RETURN( cKey )



FUNCTION sndNoProcess( aAlias )

   IF ValType( aAlias ) = "C"
      aAlias := { aAlias }
   ENDIF

   aEval( aAlias, { |x| aAdd( ONL_aNoProcess, "MX" + x ) } )

RETURN( NIL )



FUNCTION sndNoSend( nConnection )

   // Controle de envio de clientes (ICCLOJ = S/N)

   IF nConnection = NIL
      RETURN( aClone( ONL_aNoSend ) )
   ENDIF

   IF aScan( ONL_aNoSend, nConnection ) = 0
      aAdd( ONL_aNoSend, nConnection )
   ENDIF

RETURN( NIL )



FUNCTION sndDelNoSend( nConnection )

   // Controle de envio de clientes (ICCLOJ = S/N)

   LOCAL nPos := aScan( ONL_aNoSend, nConnection )

   IF nPos > 0
      aDelPos( ONL_aNoSend, nPos )
   ENDIF

RETURN( NIL )



FUNCTION sndCnxNoSendMov( nConnection )

   // Controle de envio de movimentos (IMVLOJ = S/N)

   IF nConnection = NIL
      RETURN( aClone( ONL_aCnxNoSendMov ) )
   ENDIF

   IF aScan( ONL_aCnxNoSendMov, nConnection ) = 0
      aAdd( ONL_aCnxNoSendMov, nConnection )
   ENDIF

RETURN( NIL )



FUNCTION sndDelCnxNoSendMov( nConnection )

   // Controle de envio de movimentos (IMVLOJ = S/N)

   LOCAL nPos := aScan( ONL_aCnxNoSendMov, nConnection )

   IF nPos > 0
      aDelPos( ONL_aCnxNoSendMov, nPos )
   ENDIF

RETURN( NIL )



FUNCTION sndNoFSend( uField, cCond )

   // Controle de envio de campos

   IF uField = NIL
      RETURN( aClone( ONL_aNoFSend ) )
   ENDIF

   IF ValType( uField ) = "A"
      ONL_aNoFSend := uField
   ELSEIF aScan( ONL_aNoFSend, { |x| x[1] = uField } ) = 0
      aAdd( ONL_aNoFSend, { uField, cCond } )
   ENDIF

RETURN( NIL )



FUNCTION sndDelNoFSend( cField )

   // Controle de envio de campos

   LOCAL nPos := aScan( ONL_aNoFSend, { |x| x[1] = cField } )

   IF nPos > 0
      aDelPos( ONL_aNoFSend, nPos )
   ENDIF

RETURN( NIL )



FUNCTION sndIsProcess( cAlias )

   LOCAL lReturn := .T.
   
   IF Len( cAlias ) = 3
      cAlias := "MX" + cAlias
   ENDIF

   IF ! sndMaster() .AND. aScan( sndCnxNoSendMov(), { |c| c = sndDefConnection() } ) <> 0
      lReturn := ( aScan( olGetTabAliasMov(), { |p| Left( p, 5 ) = Left( cAlias, 5 ) } ) = 0 )
   ENDIF
   
   IF lReturn

      lReturn := ( aScan( ONL_aNoProcess, { |p| p = Left( cAlias, 5 ) } ) = 0 )

      IF lReturn .AND. ! Empty( ONL_aOnlyProcess )
         lReturn := ( aScan( ONL_aOnlyProcess, { |p| p = Subs( cAlias, 3, 3 ) } ) > 0 )
      ENDIF
      
   ENDIF

RETURN( lReturn )



FUNCTION sndFolder( cFolder )

   LOCAL cReturn := ONL_cSendFolder

   IF cFolder <> NIL
      ONL_cSendFolder := ConfPath( cFolder )
   ENDIF

RETURN( cReturn )



FUNCTION sndConfSequence( cSequence )

   IF ONL_cSaveSequence = cSequence

      MsgDlg( "Problemas na sequˆncia do arquivo !;;Comunique a Max Scalla imediatamente.", "00:15" )

   ENDIF

   ONL_cSaveSequence := cSequence

RETURN( NIL )



FUNCTION sndMaster( lDef )

   LOCAL lReturn := ONL_lMaster

   IF lDef <> NIL
      ONL_lMaster := lDef
   ENDIF

RETURN( lReturn )



PROCEDURE sndAddConnection( nConnection, cIpInt, cIpExt )

   LOCAL nPos := aScan( ONL_aConnections, { |x| x[ ONL_CONN_NUM ] = nConnection } )
   
   vDef( @cIpInt, "" )
   vDef( @cIpExt, "" )

   IF nPos = 0
      aAdd( ONL_aConnections, { nConnection, cIpInt, cIpExt, Time() } )
   ELSE
      ONL_aConnections[ nPos, ONL_CONN_IPI ] := cIpInt
      ONL_aConnections[ nPos, ONL_CONN_IPE ] := cIpExt
      ONL_aConnections[ nPos, ONL_CONN_HOR ] := Time()
   ENDIF
   
   sndIsUpdConnections( .T. )

RETURN



FUNCTION sndConnections( aDefConnections )

   LOCAL aReturn := ONL_aConnections

   IF aDefConnections <> NIL
      ONL_aConnections := aDefConnections
   ENDIF

RETURN( aReturn )



FUNCTION sndIsUpdConnections( lUpd )

   LOCAL lReturn := ONL_lUpdConnections
   
   IF lUpd <> NIL
      ONL_lUpdConnections := lUpd
   ENDIF

RETURN( lReturn )



FUNCTION sndDefConnection( nDef )

   LOCAL nReturn := ONL_nConnection

   IF nDef <> NIL
      ONL_nConnection := nDef
   ENDIF

RETURN( nReturn )



FUNCTION sndFOnly( cAlias, aFields )

   LOCAL nPos := aScan( ONL_aFOnly, { |f| f[1] = cAlias } )
   LOCAL nField
   
   IF nPos = 0
      aAdd( ONL_aFOnly, { cAlias, aClone( aFields ) } )
   ELSEIF Empty( aFields )
      aDelPos( ONL_aFOnly, nPos )
   ELSE
      FOR nField := 1 TO Len( aFields )
         IF aScan( ONL_aFOnly[ nPos, 2 ], aFields[ nField ] ) = 0
            aAdd( ONL_aFOnly[ nPos, 2 ], aFields[ nField ] )
         ENDIF
      NEXT
   ENDIF

RETURN( NIL )



FUNCTION sndDefProcess( cAlias, cOper )

   LOCAL nSend, nUpdKey
   
   IF mxIn( cOper, { ONL_OP_INSERT, ONL_OP_UPDATE } )

      nSend := aScan( ONL_aSendProcess, { |s| s[ SND_ALIAS ] = cAlias    .AND. ;
                                              s[ SND_RECNO ] = mxRecno() .AND. ;
                                        mxIn( s[ SND_OPER  ], { ONL_OP_INSERT, ONL_OP_UPDATE } ) } )

   ELSE

      nSend := aScan( ONL_aSendProcess, { |s| s[ SND_ALIAS ] = cAlias    .AND. ;
                                              s[ SND_RECNO ] = mxRecno() .AND. ;
                                              s[ SND_OPER  ] = cOper } )

   ENDIF

   IF nSend = 0

      aAdd( ONL_aSendProcess, { cAlias, mxRecno(), cOper, "", { 999 }, {}, NIL, NIL } )
      nSend := Len( ONL_aSendProcess )

   ELSEIF cOper = ONL_OP_UPDATE .AND. ONL_aSendProcess[ nSend, SND_OPER ] = ONL_OP_INSERT

      cOper := ONL_OP_INSERT

   ENDIF

   IF mxIn( cOper, { ONL_OP_UPDATE, ONL_OP_DELETE } )

      nUpdKey := aScan( ONL_aUpdKey, { |u| u[1] = cAlias } )

      IF nUpdKey <> 0

         IF cOper <> ONL_OP_DELETE

            ONL_aSendProcess[ nSend, SND_UPDKEY ] := { ONL_aUpdKey[ nUpdKey, 2 ], sndField( FieldPos( ONL_aUpdKey[ nUpdKey, 2 ] ) ) }

         ELSEIF ONL_uDelKey <> NIL

            ONL_aSendProcess[ nSend, SND_UPDKEY ] := { ONL_aUpdKey[ nUpdKey, 2 ], sndField( FieldPos( ONL_aUpdKey[ nUpdKey, 2 ] ) ), ONL_uDelKey }
            ONL_uDelKey := NIL

         ENDIF

      ENDIF

   ENDIF

   ONL_aSendProcess[ nSend, SND_OPER ] := cOper

RETURN( nSend )



FUNCTION olRename( cFile, aRename, lDel )

   LOCAL lReturn := .F.

   LOCAL lSndActive, nLoja, cTmpRename, cTrans, cSql, cTela

   vDef( @lDel, .F. )

   BEGIN SEQUENCE

      IF ! sndActive() .AND. ! isCsw()
         BREAK
      ENDIF
      
      cTela := SaveScreen( MaxRow(), 00, MaxRow(), MaxCol() )

      csWait( "Gravando dados em MXOUT...", NIL, .F., .T. )
      
      lSndActive := sndActive(.F.)
      
      nLoja := Left( DelPath( aRename[ 1 ] ), 3 )
      
      IF olIsNewFile( nLoja )
         nLoja := Val( nLoja )
      ELSE
         nLoja := If( nLoja = "0", 0, Asc( Left( nLoja, 1 ) ) -64 )
      ENDIF

      cTmpRename := aRename[ 2 ]

      cTrans := AllTrim( MemoLine( cTmpRename, 80, 1 ) )
      IF Left( cTrans, 2 ) = "T="
         cTrans := Subs( cTrans, 3 )
      ELSE
         cTrans := ""
      ENDIF
      
      cSql := olSqlInsert( "OUT",;
                           nLoja,;
                           Date(),;
                           Time(),;
                           cTrans,;
                           If( "\PRIOR\" $ aRename[ 1 ], 0, 1 ),;
                           0,;
                           NIL,;
                           "" ,;
                           GetNameFile( aRename[ 1 ] ),;
                           cTmpRename )

      cSql := StrTran( cSql, 'INTO "mxout"'       , 'INTO cs_conexao."mxout"' )
      cSql := StrTran( cSql, 'INTO public."mxout"', 'INTO cs_conexao."mxout"' )

      IF ! sqlExecute( cSql, NIL, .F., If( foundStr( sqlGetConn( "NAME" ), "CS_LOJA|CS_CONEXAO" ), NIL, "CS_CONEXAO" ) )
         BREAK
      ENDIF

      IF lDel
         mxFDel( cFile )
      ENDIF

      sndActive( lSndActive )

      lReturn := .T.

   ENDSEQUENCE
   
   IF cTela <> NIL
      RestScreen( MaxRow(), 00, MaxRow(), MaxCol(), cTela )
   ENDIF

RETURN( lReturn )



FUNCTION olChrLoja( nLoja )

   vDef( @nLoja, sndDefConnection() )

RETURN( StrZero( nLoja, 3 ) )



FUNCTION sndSequence()

   LOCAL cAlias     := Alias()
   LOCAL cSequence  := "000001"
   LOCAL lSndActive := sndActive(.F.)
   LOCAL lTransMode := mxTransMode(.F.)
   LOCAL aResult    := {}

   LOCAL cSql, nRetry, lOk

   FOR nRetry := 1 TO 5
   
      lOk := .F.

      TRY

         IF sqlExecute( "SELECT CFIARQCSW FROM MXCSWCFI FOR UPDATE", @aResult )
            IF Len( aResult ) = 0
               cSql := "INSERT INTO MXCSWCFI (CFIARQCSW, sr_recno) VALUES (<SEQ>,<SEQ>)"
            ELSE
               IF aResult[ 1, 1 ] = 0
                  cSequence := "700000"
               ELSEIF aResult[ 1, 1 ] < 999999
                  cSequence := StrZero( aResult[ 1, 1 ] + 1, 6 )
               ENDIF
               cSql := "UPDATE MXCSWCFI SET CFIARQCSW = <SEQ>"
            ENDIF
            cSql := StrTran( cSql, "<SEQ>", cSequence )
            lOk := sqlExecute( cSql )
         ENDIF

      CATCH

      END
      
      IF lOk
         IF dbIsOpen( "MXCSWCFI" )
            MXCSWCFI->( mxDbRefresh() )
         ENDIF
         EXIT
      ENDIF

   NEXT
   
   IF Select( cAlias ) > 0
      Select( cAlias )
   ENDIF

   sndActive( lSndActive )
   mxTransMode( lTransMode )

RETURN( cSequence )



FUNCTION cnxOnLine( nConnection )

   LOCAL lReturn := ( aScan( ONL_aConnections, { |x| x[1] = nConnection } ) > 0 )

RETURN( lReturn )



FUNCTION isCsw( lSet )

   LOCAL lReturn := ONL_lCsw

   IF lSet <> NIL
      ONL_lCsw := lSet
   ENDIF

RETURN( lReturn )



FUNCTION cswActFile( cFile )

   LOCAL cReturn := ONL_cActFile

   IF cFile <> NIL
      ONL_cActFile := GetNameFile( cFile )
   ENDIF

RETURN( cReturn )



FUNCTION rcvKey( cKey )

   LOCAL aKey := {}
   LOCAL cAddKey

   IF Len( cKey ) > 0 .AND. Right( cKey, 1 ) <> ""
      cKey += ""
   ENDIF

   DO WHILE Len( cKey ) > 0 .AND. cKey <> "K="

      cAddKey := Left( cKey, At( "", cKey ) -1 )

      IF cAddKey <> "K="
         aAdd( aKey, cAddKey )
      ENDIF

      cKey := Subs( cKey, At( "", cKey ) +1 )

   ENDDO

   IF Empty( aKey )
      aKey := aAppend( aKey, { " ", " " } )
   ENDIF

RETURN( aKey )



FUNCTION rcvFolder( cFolder )

   LOCAL cReturn := ONL_cRecvFolder

   IF cFolder <> NIL
      ONL_cRecvFolder := ConfPath( cFolder )
   ENDIF

RETURN( cReturn )



FUNCTION rcvMaqDir( bSet )

   LOCAL bReturn := ONL_bRcvMaqDir

   IF bSet <> NIL
      ONL_bRcvMaqDir := bSet
   ENDIF

RETURN( bReturn )
   


FUNCTION rcvOpenAGE( bSet )

   LOCAL bReturn := ONL_bOpenAGE

   IF bSet <> NIL
      ONL_bOpenAGE := bSet
   ENDIF

RETURN( bReturn )



FUNCTION olSolicCod( cCampo, nOrdem, nLimite, nLoja, nAdd )

   LOCAL cAlias := Left( cCampo, 8 )

   LOCAL uCodigo, aInfo

   vDef( @nOrdem ,            1 )
   vDef( @nLimite, 999999999999 )
   vDef( @nAdd   ,            1 )

   ScreenSave()

   MsgDlg( "Aguarde, buscando c¢digo sequencial;" + ;
           "de " + cCampo + If( CFICNXCTR = "M", " na loja " + StrZero( nLoja, 3 ), " no Master" ) + ".", "NP", "8" )

   DO WHILE .T.

      aInfo := olGetInfo( { { "COD", { "SEQ" }, Right( cCampo, 9 ), nAdd } }, NIL, nLoja )

      uCodigo := olSeekInfo( aInfo, "SEQCOD" )

      vDef( @uCodigo, "0" )

      uCodigo := Val( uCodigo )

      IF sndMaster() .AND. uCodigo <> 0 .AND. Right( cCampo, 6 ) = "CODCCC"

         ( cAlias )->( GetBookMark() )
         IF ( cAlias )->( cnxSeek( 1, uCodigo, nLoja ) )
            uCodigo := 0
         ENDIF
         ( cAlias )->( GoToBookMark() )

         IF uCodigo = 0
            LOOP
         ENDIF

      ENDIF

      EXIT

   ENDDO

   ScreenRest()

RETURN( uCodigo )



FUNCTION rcvFileRsp( cFile, nConnect, cOper )

   LOCAL cReturn := DelExt( DelPath( cFile ) )

   IF cOper = "DIR"
      cOper   := "RCV"
      cReturn := StrZero( nConnect, 3 ) + "M" + Subs( cReturn, 5 ) + ".RSP"
   ELSE
      cReturn := StrZero( nConnect, 3 ) + If( Subs( cReturn, 4, 1 ) = "M", "L", "M" ) + Subs( cReturn, 5 ) + ".RSP"
   ENDIF

   DO CASE
      CASE cOper = "RCV" ; cReturn := rcvFolder() + "PRIOR\" + cReturn
      CASE cOper = "SND" ; cReturn := sndFolder() + "PRIOR\" + cReturn
   ENDCASE

RETURN( cReturn )



FUNCTION onlConf( lConf )

   LOCAL lReturn := ONL_lOnlConf

   IF lConf <> NIL
      ONL_lOnlConf := lConf
   ENDIF

RETURN( lReturn )



FUNCTION sndSaveKey( cAlias, lReset )

   vDef( @lReset, .F. )

   ONL_uSaveKey := If( lReset, NIL, sndGetKey( cAlias ) )

RETURN( ONL_uSaveKey )



FUNCTION sndForceConnection( nForce )

   LOCAL nReturn := ONL_nForceConnect

   IF nForce <> NIL
      ONL_nForceConnect := nForce
   ENDIF

RETURN( nReturn )



FUNCTION sndSeleConnection( nSele )

   LOCAL nReturn := ONL_nSeleConnect

   IF nSele <> NIL
      ONL_nSeleConnect := nSele
   ENDIF

RETURN( nReturn )



FUNCTION olSqlInsert( cTab, P_NLJ, P_DAT, P_HOR, P_TRA, P_PRI, P_PRC, P_DPR, P_HPR, P_ARQ, P_TXT )

   LOCAL cSql      := "INSERT INTO MX" + cTab + " ( CFINLJCNX, CFIDATCNX, CFIHORCNX, CFITRACNX, CFIPRICNX, CFIPRCCNX, CFIDPRCNX, CFIHPRCNX, CFIARQCNX, CFITXTCNX, CFISISCNX ) " + ;
                                          "VALUES (        ??,         ?,        ??,        ??,        ??,        ??,         ?,        ??,        ??,         ?,         ? )"
   LOCAL apCodeSql := SR_SQLParse( cSql )

   cSql := SR_SQLCodeGen( apCodeSql,;
                          { ;
                            P_NLJ,;
                            P_DAT,;
                            P_HOR,;
                            P_TRA,;
                            P_PRI,;
                            P_PRC,;
                            P_DPR,;
                            P_HPR,;
                            P_ARQ,;
                            P_TXT,;
                            "T"   ;
                          },;
                          SYSTEMID_POSTGR )

RETURN( cSql )



FUNCTION cliLoja( nCod )

   LOCAL aResult := {}
   LOCAL nLoja, nInt, nMod
   
   vDef( @nCod, MXCLICFI->CFICODCLI )
   
   nLoja := Val( Left( StrZero( nCod, 9 ), 3 ) )
   
   IF nLoja = 0

      IF sqlExecute( "SELECT CFICODLOJ " + ;
                     "FROM MXLOJCFI " + ;
                     "WHERE " + ;
                        "( TRIM(CFIFCCLOJ) <> '' ) AND " + ;
                           "( " + NumToStr( nCod ) + " BETWEEN CAST( REPLACE( CASE WHEN LENGTH( SUBSTR( CFIFCCLOJ, 8, 7 ) ) = 0 THEN '0000000' ELSE SUBSTR( CFIFCCLOJ, 1, 7 ) END, ' ', '0' ) AS INTEGER ) AND " + ;
                                                              "CAST( REPLACE( CASE WHEN LENGTH( SUBSTR( CFIFCCLOJ, 8, 7 ) ) = 0 THEN '0000000' ELSE SUBSTR( CFIFCCLOJ, 8, 7 ) END, ' ', '0' ) AS INTEGER ) ) LIMIT 1", @aResult, .F., "CS_LOJA" )

         IF Len( aResult ) > 0
            nLoja := aResult[ 1, 1 ]
         ENDIF

      ENDIF

   ENDIF
   
   IF nLoja = 0

      nInt := Int( nCod / 10000 )
      nMod := Mod( nCod,  10000 )

      IF nMod <> 0
         nInt ++
      ENDIF

      nLoja := nInt

   ENDIF

RETURN( nLoja )



FUNCTION olGetOrigem( cFile )

   LOCAL cConnection := Left( DelPath( cFile ), 4 )

   IF olIsNewFile( cConnection )
      RETURN( Subs( cConnection, 4, 1 ) )
   ENDIF
   
RETURN( Subs( cConnection, 2, 1 ) )



FUNCTION olRcvIsRepass( cFile )

   LOCAL cConnection := Left( DelPath( cFile ), 3 )
   
   IF olIsNewFile( cConnection )
      RETURN( cConnection = "000" )
   ENDIF
   
RETURN( Left( cConnection, 1 ) = "0" )



FUNCTION olIsNewFile( cConnection )

RETURN( IsDigit( Left( cConnection, 3 ) ) )



PROCEDURE olDefTabAliasMov()

   LOCAL aResult := {}

   IF Len( ONL_TabAliasMov ) = 0

      IF sqlExecute( "SELECT CFIALIDIC FROM MXDICCFI WHERE CFISTADIC = '1' AND CFITIPDIC = 'M' ORDER BY CFIALIDIC", @aResult, .F., "CS_LOJA" )
         aEval( aResult, { |x| aAdd( ONL_TabAliasMov, x[1] ) } )
      ENDIF

   ENDIF

RETURN



FUNCTION olGetTabAliasMov()

   RETURN( ONL_TabAliasMov )