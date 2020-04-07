/*

 MaxSql.prg
 Descricao: Biblioteca de funcoes p/ uso do banco de dados PostgreSQL.
 Desenvolvido por MAX SCALLA Informatica Ltda.
 
 EMERSON DA SILVA CREMA
 25/03/20 * Movido sqlDefNotNull() de MAXDB.PRG.
 28/02/20 * Desenvolvido sqlDB_Parameters().
          * Desenvolvido sqlIndexExist().
          * Implementado maxsql.ch.
 07/11/19 * Desenvolvido e implementado sqlPostgre_v9().
 16/05/19 * Correcao do parametro lUseTrim em sqlCompFormat() quando usado
            em recursividade, pois estava no lugar de lRecursive.
 06/05/19 * Implementado em sqlExistItem() as constantes SQL_ITEM_*.*.
          * Implementado em sqlExistItem() a verificacao de
            chaves primarias.
 09/04/19 * Desenvolvido e implementado sqlDefaultRDD().
 04/04/19 * Adaptacoes em sqlDropFunction() e sqlExistItem() p/ q
            trabalhem com Postgre 11.
 03/04/19 * Desenvolvido sqlPGSVersion().
 15/03/19 * Desenvolvido sqlRddTabRegister().
 13/12/18 * Implementado em dbConverte() as constantes TMP_ALIAS_ORI e
            TMP_ALIAS_DES.
 30/11/18 * Reformulado dbConverte() para q execute insercao de registros
            atraves de comados SQL agrupando 100 regisros por gravacao.
          * Desenvolvido dbConv_SqlInsert().
 25/07/18 * Implementado em sqlFReplace() o parametro lFormatChars.
 10/07/18 * Desenvolvido sqlFieldType() e sqlField_Parameters().
 18/06/18 * Desenvolvido sqlVacuum().
 08/06/18 * Desenvolvido sqlFieldExist().
 17/05/18 * Implementado em sqlGetRecords() o parametro nLimit.
 01/12/17 * Implementado em sqlAddConn() o parametro cPCode_Default.
 26/06/17 * Removido sqlMsgError() e implementado recurso do proprio sqlExecute().
 26/06/17 * Implementado mxEnviaErro().
 29/05/17 * Desenvolvido sqlDbTime() e sqlDbDate()
 21/03/17 * Implementado o parametro cNoGet em sqlGetFields().
 31/10/16 * Implementacoes em sqlSrRecnoRecovery():
            - Verificacao da existencia da sequencia antes de exclui-la.
            - Implementado "CASCADE" no "DROP" de SR_RECNO.
 19/10/16 * Desenvolvido as funcoes:
            - sqlDropFunction()
            - sqlDropType()
            - sqlExistItem()
 26/09/16 * Implementado a pesquisa de porta para o parametro cInfo = "PORT"
            em sqlGetInfo().
 20/09/16 * Desenvolvido sqlSrRecnoRecovery().
 13/04/16 * Implementado o parametro cInternalID em sqlClearLocks().
 25/01/16 * Desenvolvido sqlAddLog()
            (Funcao basicamente p/ q seja chamda no debuger).
 09/06/15 * Desenvolvido sqlDelDuplicate().
 25/02/15 * Desenvolvido sqlUserExist() e sqlCreateUser().
 21/01/15 * Removido sqlDbChangePass() de sqlAddConn().
 22/08/14 * Desenvolvido sqlDbChangePass().
          * Implementado em sqlAddConn() atualizacao automatica da
            nova senha d banco de dados.
          * Implementado as constantes BD_SENHA_ANT1 e BD_SENHA_ANT2.
 06/05/14 * Desenvolvido sqlGetFieldValue().
 09/04/14 * Desenvolvido sqlSelectOffSet().
          * Alteracoes em sqlDelete():
            - Implementado sndIsProcess().
            - Removido o parametro nOrder.
            - Implementado o parametro uConn.
            - Permitido a digitacao direta de cWhere no formato texto.
 12/03/14 * Desenvolvido as funcoes:
            - sqlUpdIndexKey()
            - sqlClearFunc().
 27/02/14 * Alterada a funcao SR_Exec() p/ q ao executar sqlExecute()
            nao exiba mensagem nem envie mail de log qdo houver erro
            no COMMIT (parametro da funcao sqlExecute()).
 20/02/14 * Implementado parametro lSendErrorMail em sqlExecute().
 17/02/14 * Implementado em sqlExecute():
            - mxErrorMail().
            - Parametro lShowError.
 03/12/13 * Removido de dbConverte() o processamento da funcao Crypt().
 13/09/13 * Desenvolvido sqlGetPageCode().
          * Desenvolvido sqlConnPostgres().
          * Implementado sqlGetPageCode() em sqlAddConn().
 26/07/13 * Implementado o parametro cColor em sqlCopyFromTable().
 08/07/13 * Desenvolvida funcao sqlGetFields().
 05/06/13 * Adicionado um TRY CATCH em sqlExecute() p/ sqlSetConn().
 22/05/13 * Implementado "ORDER BY SR_RECNO" em sqlCopyFromTable().
 14/05/13 * Implementado em dbConverte().
            - Set( _SET_DELETED, .F. )
            - Correcao na definicao de cError pelo total de regitros.
 13/05/13 * Implementado em sqlCopyFromTable() a possibilidade de
            utilizar tabela DBF como origem dos dados.
          * Desenvolvido sqlAuxCopyFromTable().
 10/05/13 * Implementado o parametro nLen em sqlFReplace().
 03/05/13 * Implementado o parametro lEmail em sqlMsgError().
 02/05/13 * Desenvolvido sqlCopyFromTable().
 26/04/13 * Implementado o parametro nProcedure em sqlMsgError().
 25/04/13 * Implementado sqlMsgError() nas funcoes que utilizam
            sqlExecute().
 
 DENIS MAZZUCATTO RODRIGUES
 18/04/13 * Desenvolvimento de sqlSeek().
 
 EMERSON DA SILVA CREMA
 01/04/13 * Desenvolvimento de sqlStrWhere().
 25/03/13 * Desenvolvimento de sqlSum() e sqlMax().
 22/03/13 * Reformulada sqlDelete() p/ q utilize apenas comandos SQL na
            localizacao dos registros.
 18/03/13 * Implementado parametro lUseTrim em sqlCompFormat().
 13/03/13 * Implementado parametro uConn em sqlRecCount().
 11/03/13 * Implementado parametro cOrder em sqlGetRecords().
 05/03/13 * Desenvolvimento de sqlGetRecords().

 DENIS MAZZUCATTO RODRIGUES
 27/12/12 * Implementado retorno p/ sqlSchemaAux().

 EMERSON DA SILVA CREMA
 28/09/12 * Implementado em sqlAddConn() parametro lMsgError.
 28/08/12 * Implementado em sqlAddConn() a possibilidade de usar os mesmos
            parametros em conexoes de nomes diferentes.
 07/08/12 * Implementado em sqlCompFormat() a possibilidade de usar o parametro
            cComp como matriz p/ gerar string p/ o parametro "IN" do SQL.
 12/07/12 * Renomeada csBasicConn() p/ sqlBasicConn().
          * Implementacoes em sqlBasicConn() p/ q se adapte em qq sistema.
 04/07/12 * Desenvolvimento de sqlRecCount().

 DENIS MAZZUCATTO RODRIGUES
 03/07/12 * Substituicao das chamadas de mxFDel() por "DROP IF EXISTS" em
            sqlRenameTable().
 19/06/12 * Alteracao em sqlRenameTable() p/ verificar a existencia do indice
            "sr" antes de renomea-lo.
 24/05/12 * Implementado novamente SR_Exec().
 23/05/12 * Implementado comando "SET log_min_messages=ERROR" em sqlAddConn().
 22/05/12 * Remocao de SR_Exec().

 EMERSON DA SILVA CREMA
 19/05/12 * Implementado em sqlAddConn() a possibilidade de utilizar varios
            nomes de referencia (cName) p/ a mesma configuracao.
 18/05/12 * Desenvolvimento de sqlDefPort() e sqlDefUser().
 17/05/12 * Desenvolvimento de sqlDefWrite().
 15/05/12 * Desenvolvimento de sqlGetTableStr().
 14/05/12 * Desenvolvimento de sqlMsgError().
 04/05/12 * Desenvolvimento de sqlFieldsStart(), sqlFReplace(), sqlExeWrite()
            e sqlGetWriteCommand().

 DENIS MAZZUCATTO RODRIGUES
 20/01/12 * Implementado nivel de senha em sqlDefPass().
 09/12/11 * Implementado parametro cPass em sqlAddConn().
 01/12/11 * Implementada gravacao no MXERROR.LOG qdo ocorrer erro em
            sqlExecute().
 15/07/11 * Desenvolvimento e implementacao de sqlLastError().

 EMERSON DA SILVA CREMA
 06/07/11 * Desenvolvimento de sqlCompFormat().
 30/05/11 * Desenvolvimento de sqlDelete().
 05/05/11 * Colocada consistencia em dbConverte() p/ q verifique a existencia
            do arquivo de origem antes de iniciar a conversao e exibir
            mensagem de arquivo ausente qdo nao existir, sem passar pelo
            processo final de verificacao do total de registros.

 DENIS MAZZUCATTO RODRIGUES
 28/03/11 * Implementado retorno p/ sqlAddConn().
 03/12/10 * Implementada conferencia de registros em dbConverte().
 03/05/10 * Inicio do desenvolvimento.

 Funcoes ja adaptadas p/ arquivos SQL:

 * mxFCopy()    - Copia arquivos.
 * mxFMove()    - Renomeia/move arquivos.
 * mxFDel()     - Apaga arquivos.
 * mxMd()       - Cria database e schema.
 * dbFile()     - Verifica existencia de arquivos.
 * IsDirExist() - Verifica existencia de database ou schema.

*/

#include "set.ch"
#include "std.ch"
#include "sqlrdd.ch"
#include "maxsql.ch"

#define SQL_IP     1
#define SQL_CONN   2
#define SQL_DTB    3
#define SQL_SCHEMA 4
#define SQL_NAME   5

//#define BD_SENHA      "qadmcsmsq@425S"
#define BD_SENHA      "maxr2w2e8f4"
//#define BD_SENHA_ANT1 "maxr2w2e8f4"
//#define BD_SENHA_ANT2 "M@Xr2w2e8f4"

// Definicoes para sqlCopyFromTable().

#define SQLC_CONN  1
#define SQLC_TAB   2
#define SQLC_WHERE 3

// Utilizadas p/ conexao com o banco de dados.

STATIC aConfPageCode := {}
STATIC aSqlConn      := {}
STATIC nSqlConn      := 0
STATIC lSqlRdd       := .F.
STATIC cDbType       := "DBF"
STATIC cTimeChk      := ""
STATIC cLastErr      := ""
STATIC cLastCmd      := ""
STATIC nDefPort      := 1987
STATIC cDefUser      := "postgres"
STATIC cDefPass      := BD_SENHA
STATIC aPGSVersion   := {}

// Utilizadas p/ as instrucoes SQL.

STATIC cSqlFrom    := ""
STATIC cSqlFromAs  := ""
STATIC aSqlFields  := {}
STATIC aSqlJoin    := {}
STATIC aSqlCase    := {}
STATIC cSqlCase    := ""
STATIC cSqlWhere   := NIL
STATIC cSqlGroup   := NIL
STATIC cSqlOrder   := NIL
STATIC cSqlFields  := ""
STATIC cSqlValues  := ""
STATIC cSqlOper    := ""
STATIC cSqlWrite   := ""
STATIC nSqlCommit  := 0
STATIC cDbPageCode := ""


FUNCTION sqlActive( lActive )

   // Define se ira utilizar banco de dados SQL.

   LOCAL lReturn := lSqlRdd

   IF lActive <> NIL
      lSqlRdd := lActive
   ENDIF

RETURN( lReturn )



FUNCTION dbActive( cType )

   // Define o tipo do banco de dados SQL utilizado.

   LOCAL cReturn := cDbType

   IF cType <> NIL
      cDbType := cType
   ENDIF

RETURN( cReturn )



FUNCTION sqlAddConn( cIP, cDtb, uSchema, cName, lAbort, nPort, cUser, cPass, lCreate, lMsgError, cPCode_Default )

   // Efetua a conexao ao banco de dados.
   // Cria o database e os schemas caso nao existam.

   #define MSG_CONN_DSN   StrTran( cDSN, ";pwd=" + cPass, "" )
   #define MSG_CONN_ERROR "N„o foi poss¡vel estabelecer a;conex„o com o banco de dados !;;" + MSG_CONN_DSN
   
   LOCAL lReturn  := .F.
   LOCAL lUpdPass := .F.

   LOCAL cDSN, nConn, nCount, nPos, aConnAux, nConnAux, aAux, cPageCode, nTry
   
   vDef( @cIP           , ""                )
   vDef( @cDtb          , ""                )
   vDef( @uSchema       , ""                )
   vDef( @cName         , cDtb              )
   vDef( @lAbort        , DefAbortOpError() )
   vDef( @nPort         , sqlDefPort()      )
   vDef( @cUser         , sqlDefUser()      )
   vDef( @cPass         , sqlDefPass()      )
   vDef( @lCreate       , .T.               )
   vDef( @lMsgError     , .T.               )
   vDef( @cPCode_Default, "WIN1252"         )
   
   sqlDbPageCode( Upper( cPCode_Default ) )

   BEGIN SEQUENCE
   
      IF Empty( cDtb )
         IF lAbort
            Fim( 0 )
         ENDIF
         BREAK
      ENDIF

      cIP   := AllTrim( GetNoEmpty( cIP, "localhost" ) )
      cUser := AllTrim( cUser )
      cDtb  := Lower( cDtb )
      cPass := AllTrim( cPass )

      cDSN := "pgs=" + AllTrim( cIP ) + ";"
      cDSN += "uid=" + cUser + ";"
      cDSN += "dtb=" + cDtb + ";"
      cDSN += "prt=" + NumToStr( nPort ) + ";"
      cDSN += "pwd=" + cPass

      IF ValType( uSchema ) = "C"

         IF Empty( uSchema )
            uSchema := "public"
         ELSE
            uSchema := Lower( uSchema )
            cDSN += ";owner=" + uSchema
         ENDIF

         nPos := aScan( aSqlConn, { |x| x[ SQL_IP ] = cIP .AND. x[ SQL_DTB ] = Upper( cDtb ) .AND. x[ SQL_SCHEMA ] = Upper( uSchema ) } )

         IF nPos > 0 .AND. cName <> aSqlConn[ nPos, SQL_NAME ]
            nPos := 0
         ENDIF

         IF nPos = 0  // Verifica se ja existe a conexao

            BEGIN SEQUENCE
            
               FOR nTry := 1 TO 3

                  TraceLog( "conectando " + MSG_CONN_DSN )

                  SR_SetToolsOwner( Upper( uSchema ) )

                  TRY
                     nConn := SR_AddConnection( CONNECT_POSTGRES, cDSN )
                  CATCH
                     nConn := -1
                  END

                  IF nConn > 0  // Conectado com sucesso
                  
                     /*
                     IF nTry > 1
                        sqlDefPass( BD_SENHA )
                        lUpdPass := .T.
                     ENDIF
                     */

                     IF ! IsDef( "DESENV" ) .AND. aScan( aConfPageCode, { |x| x[1] = cIp .AND. x[2] = cDtb } ) = 0

                        nConnAux := sqlConnPostgres( cDSN, cDtb, cIp )

                        IF nConnAux >= 0

                           cPageCode := sqlGetPageCode( cDtb )

                           IF ! cPageCode == cPCode_Default
                              MsgDlg( "Banco de dados \\" + cIp + "\" + cDtb + ";com defini‡„o de p gina de c¢digo inv lida !;;" + ;
                                      "P gina de c¢digo do banco : ^" + PadR( cPageCode     , Max( 7, Len( cPageCode ) ) ) + "^;" + ;
                                      "P gina do c¢digo v lida   : ^" + PadR( cPCode_Default, Max( 7, Len( cPageCode ) ) ) + "^" )
                              nConn := -1
                           ENDIF

                           SR_EndConnection( nConnAux )
                           sqlDelConn( nConnAux )

                        ENDIF

                        aAdd( aConfPageCode, { cIp, cDtb } )

                     ENDIF

                     BREAK

                  ENDIF
                  
                  /*
                  DO CASE
                     CASE nTry = 1 ; cDSN := StrTran( cDSN, ";pwd=" + cPass, ";pwd=" + BD_SENHA_ANT1 ) ; cPass := BD_SENHA_ANT1
                     CASE nTry = 2 ; cDSN := StrTran( cDSN, ";pwd=" + cPass, ";pwd=" + BD_SENHA_ANT2 ) ; cPass := BD_SENHA_ANT2
                  ENDCASE
                  */
                  
               NEXT

               IF ! lCreate  // Nao tenta criar o banco de dados
                  BREAK
               ENDIF
               
               //cDSN := StrTran( cDSN, ";pwd=" + cPass, ";pwd=" + BD_SENHA ) ; cPass := BD_SENHA

               // Erro na conexao
               // Pode ser q o database principal nao tenha sido criado

               IF uSchema <> "public"
                  BREAK
               ENDIF

               // Conecta temporariamente no banco padrao p/ tentar
               // criar o informado na funcao

               nConn := sqlConnPostgres( cDSN, cDtb, cIP )

               IF nConn < 0
                  BREAK
               ELSEIF mxMd( "\" + cDtb, "SQLRDD" )
                  SR_EndConnection( nConn )
                  sqlDelConn( nConn )
               ELSE
                  SR_EndConnection( nConn )
                  nConn := -1
                  BREAK
               ENDIF

               // Tenta novamente a conexao

               TRY
                  nConn := SR_AddConnection( CONNECT_POSTGRES, cDSN )
               CATCH
                  nConn := -1
               END

            ENDSEQUENCE

            IF nConn < 0
               TraceLog( "erro na conexao" )
               IF lAbort
                  IF lMsgError
                     MsgDlg( MSG_CONN_ERROR )
                  ENDIF
                  Fim( 0 )
               ELSEIF lMsgError
                  ScreenSave()
                  MsgDlg( MSG_CONN_ERROR, "02:30" )
                  ScreenRest()
               ENDIF
               BREAK
            ENDIF

            TraceLog( "conectado" )

            aAdd( aSqlConn, { cIP, nConn, Upper( cDtb ), Upper( uSchema ), Upper( cName ) } )

            sqlSetConn( nConn )
            sqlExecute( "SET log_min_messages=ERROR", NIL, .F., NIL, NIL, .F., .F. )

            IF ! foundStr( Upper( uSchema ), "CS_OLD|CS_TEMP" ) .AND. Upper( cName ) <> "CS_AM"
               dbKeyCreate()
            ENDIF

         ELSEIF aSqlConn[ nPos, SQL_NAME ] <> cName .AND. aSqlConn[ nPos, SQL_SCHEMA ] = uSchema

            aConnAux := aSqlConn[ nPos ]

            aAdd( aSqlConn, { aConnAux[ SQL_IP     ],;
                              aConnAux[ SQL_CONN   ],;
                              aConnAux[ SQL_DTB    ],;
                              aConnAux[ SQL_SCHEMA ],;
                              Upper( cName ) } )

            nConn := aConnAux[ SQL_CONN ]

            sqlSetConn( nConn )

         ENDIF

      ELSE

         // Conecta ao database principal (public)

         sqlAddConn( cIP, cDtb, NIL, cName )
         sqlSetConn( cName )
         nConn := sqlGetConn( "CONN" )

         // Efetua a conexao dos schemas

         FOR nCount := 1 TO Len( uSchema )

            IF mxMd( uSchema[ nCount ], "SQLRDD" )  // Verifica a existencia dos schemas
               IF ! sqlAddConn( cIP, cDtb, uSchema[ nCount ], cName + "\" + Upper( uSchema[ nCount ] ) )
                  BREAK
               ENDIF
            ELSEIF lMsgError
               MsgDlg( MSG_CONN_ERROR + ";owner=" + Lower( uSchema[ nCount ] ) + ";;Erro na cria‡„o do esquema." )
            ENDIF

         NEXT

         sqlSetConn( nConn )
         sqlExecute( "COMMIT", NIL, .F. )

      ENDIF

      IF nSqlCommit = 1
         SR_AutoCommit(.T.)
      ENDIF

      lReturn := .T.

   ENDSEQUENCE
   
   /*
   IF lReturn .AND. lUpdPass
      IF ! sqlDbChangePass( BD_SENHA, .F. )
         lReturn := .F.
      ENDIF
   ENDIF
   */

RETURN( lReturn )



FUNCTION sqlConnPostgres( cDSN, cDtb, cIP )

   LOCAL nConn

   TRY
      nConn := SR_AddConnection( CONNECT_POSTGRES, StrTran( cDSN, "dtb=" + cDtb, "dtb=postgres" ), NIL, NIL, NIL, NIL, NIL, .T. )
      aAdd( aSqlConn, { cIP, nConn, "POSTGRES", "PUBLIC", "POSTGRES" } )
      sqlSetConn( nConn )
   CATCH
      nConn := -1
   END
   
RETURN( nConn )



PROCEDURE sqlDisconnect()

   // Desconecta todas conexoes ao banco p/ poder finalizar o programa.

   IF sqlActive()
      IF ! Empty( GetActTrans() )
         SR_RollBackTransaction()
      ENDIF
      sqlClearLocks( "TRAN" )
      dbCloseAll()
      SR_End()
   ENDIF

RETURN( NIL )



PROCEDURE sqlReconnect( nConn, lAll )

   LOCAL nConnSave := sqlGetConn( "CONN" )
   LOCAL aConn, aSaveOpen, aSaveState, nCount

   vDef( @lAll, .T. )
   
   IF lAll

      vDef( @nConn, nConnSave )

      aConn      := sqlGetConn()
      aSaveOpen  := aClone( getOpenFiles() )
      aSaveState := {}

      aEval( aSaveOpen, { |x| aAdd( aSaveState, x[1] + " " ) } )
      aSaveState := SaveState( NIL, aSaveState )

      FOR nCount := 1 TO Len( aSaveOpen )

         IF ! Empty( aSaveOpen[ nCount, 3 ] )
            sqlSetConn( aSaveOpen[ nCount, 3 ] )
            mxClose( aSaveOpen[ nCount, 1 ] )
         ENDIF

      NEXT

      FOR nCount := Len( aConn ) TO 1 STEP -1

         IF aConn[ nCount, SQL_CONN ] >= nConn
            sqlDelConn( aConn[ nCount, SQL_CONN ] )
         ENDIF

      NEXT

      FOR nCount := 1 TO Len( aConn )

         IF aConn[ nCount, SQL_CONN ] >= nConn

            sqlAddConn( aConn[ nCount, SQL_IP     ],;
                        aConn[ nCount, SQL_DTB    ],;
                        aConn[ nCount, SQL_SCHEMA ],;
                        aConn[ nCount, SQL_NAME   ] )

         ENDIF

      NEXT

      FOR nCount := 1 TO Len( aSaveOpen )

         IF ! Empty( aSaveOpen[ nCount, 3 ] )

            sqlSetConn( aSaveOpen[ nCount, 3 ] )

            mxOpen( ;
                    aSaveOpen[ nCount, 5 ],;
                    aSaveOpen[ nCount, 6 ],;
                    aSaveOpen[ nCount, 1 ],;
                    NIL                   ,;
                    aSaveOpen[ nCount, 7 ],;
                    NIL                   ,;
                    .F.                    ;
                  )
         ENDIF

      NEXT

      sqlSetConn( nConnSave )

      RestState( aSaveState, .T., .T., .F., .F. )

   ELSE

      aConn := sqlGetConn( NIL, nConn )

      sqlDelConn( nConn )

      IF Len( aConn ) > 0
      
         sqlAddConn( aConn[ SQL_IP     ],;
                     aConn[ SQL_DTB    ],;
                     aConn[ SQL_SCHEMA ],;
                     aConn[ SQL_NAME   ] )

         IF nConnSave = nConn
            nConnSave := sqlGetConn( "CONN", aConn[ SQL_NAME ] )
         ENDIF

      ENDIF

      sqlSetConn( nConnSave )

   ENDIF
   
RETURN( NIL )



FUNCTION sqlSchemaAux( cOper, uConnSave )

   LOCAL lReturn := .F.
   LOCAL nConnLen, nCount, aSchema

   IF sqlActive()

      vDef( @uConnSave, sqlGetConn( "CONN" ) )

      nConnLen := Len( aSqlConn )
      cOper    := Upper( cOper )

      IF cOper = "ADD"

         FOR nCount := 1 TO nConnLen

            IF aSqlConn[ nCount, SQL_SCHEMA ] = "PUBLIC"

               Status( "Aguarde, conectando schema auxiliar para " + aSqlConn[ nCount, SQL_NAME ] + "..." )

               aSchema := {}

               IF aScan( aSqlConn, { |x| x[ SQL_NAME ] = aSqlConn[ nCount, SQL_NAME ] + "\CS_OLD" } ) = 0
                  aAdd( aSchema, "CS_OLD" )
               ENDIF

               IF aScan( aSqlConn, { |x| x[ SQL_NAME ] = aSqlConn[ nCount, SQL_NAME ] + "\CS_TEMP" } ) = 0
                  aAdd( aSchema, "CS_TEMP" )
               ENDIF

               IF Len( aSchema ) > 0

                  lReturn := .T.

                  sqlAddConn( aSqlConn[ nCount, SQL_IP   ],;
                              aSqlConn[ nCount, SQL_DTB  ],;
                              aSchema                     ,;
                              aSqlConn[ nCount, SQL_NAME ] )

               ENDIF

            ENDIF

         NEXT

      ELSEIF cOper = "DEL"

         DO WHILE ( nCount := aScan( aSqlConn, { |x| foundStr( x[ SQL_SCHEMA ], "CS_OLD|CS_TEMP" ) } ) ) > 0

            Status( "Aguarde, desconectando schema auxiliar " + aSqlConn[ nCount, SQL_NAME ] + "..." )

            sqlDelConn( aSqlConn[ nCount, SQL_CONN ] )

            lReturn := .T.

         ENDDO

      ENDIF

      sqlSetConn( uConnSave )

   ENDIF

RETURN( lReturn )



FUNCTION sqlGetConn( cInfo, uConn )

   // Retorna informacoes de uma conexao.

   LOCAL uReturn, nPos

   IF cInfo = NIL

      IF uConn = NIL
         uReturn := aClone( aSqlConn )
      ELSE
         IF ValType( uConn ) = "N"
            nPos := aScan( aSqlConn, { |x| x[ SQL_CONN ] = uConn } )
         ELSE
            nPos := aScan( aSqlConn, { |x| x[ SQL_NAME ] = uConn } )
         ENDIF
         IF nPos > 0
            uReturn := aClone( aSqlConn[ nPos ] )
         ELSE
            uReturn := {}
         ENDIF
      ENDIF
      
   ELSE

      vDef( @uConn, nSqlConn )

      IF ValType( uConn ) = "N"
         nPos := aScan( aSqlConn, { |x| x[ SQL_CONN ] = uConn } )
      ELSE
         nPos := aScan( aSqlConn, { |x| x[ SQL_NAME ] = uConn } )
      ENDIF

      IF nPos > 0

         DO CASE
            CASE cInfo = "NPOS"       ; uReturn := nPos
            CASE cInfo = "CONN"       ; uReturn := aSqlConn[ nPos, SQL_CONN ]
            CASE cInfo = "IP"         ; uReturn := aSqlConn[ nPos, SQL_IP ]
            CASE cInfo = "DTB"        ; uReturn := aSqlConn[ nPos, SQL_DTB ]
            CASE cInfo = "SCHEMA"     ; uReturn := aSqlConn[ nPos, SQL_SCHEMA ]
            CASE cInfo = "NAME"       ; uReturn := aSqlConn[ nPos, SQL_NAME ]
            CASE cInfo = "DTB+SCHEMA" ; uReturn := "\" + aSqlConn[ nPos, SQL_DTB ] + "\" + aSqlConn[ nPos, SQL_SCHEMA ] + "\"
         ENDCASE

      ELSEIF foundStr( cInfo, "NPOS|CONN" )
         uReturn := 0
      ELSE
         uReturn := ""
      ENDIF

   ENDIF

RETURN( uReturn )



FUNCTION sqlSetConn( uConn, cDtb, cSchema )

   // Ativa uma conexao.

   LOCAL nConnSave := sqlGetConn( "CONN" )

   nSqlConn := sqlDefConn( uConn, cDtb, cSchema )

   IF nSqlConn > 0
      SR_Exec( { || SR_SetActiveConnection( nSqlConn ) } )
      SR_Exec( { || SR_SetToolsOwner( sqlGetConn( "SCHEMA" ) ) } )
   ENDIF

RETURN( nConnSave )



PROCEDURE sqlDelConn( uConn, cDtb, cSchema )

   // Desconecta uma conexao.

   LOCAL nConn := sqlDefConn( uConn, cDtb, cSchema )

   IF nConn > 0

      TRY
         SR_EndConnection( nConn )
         SR_EndConnection( nConn )
      CATCH
         // Erro ao desconectar
      END

      aDelPos( aSqlConn, aScan( aSqlConn, { |x| x[ SQL_CONN ] = nConn } ) )

      IF Len( aSqlConn ) > 0 .AND. ( ! IsProcedure( "sqlReconnect" ) )

         IF nConn = nSqlConn
            sqlSetConn( aSqlConn[ 1, SQL_CONN ] )
         ELSE
            sqlSetConn( nSqlConn )
         ENDIF

      ENDIF

   ENDIF

RETURN( NIL )



STATIC FUNCTION sqlDefConn( uConn, cDtb, cSchema )

   // Retorna o numero de uma conexao de acordo com o nome/database/schema.

   LOCAL nConn, nPos

   IF uConn <> NIL

      IF ValType( uConn ) = "N"
         nPos := aScan( aSqlConn, { |x| x[ SQL_CONN ] = uConn } )
      ELSE
         nPos := aScan( aSqlConn, { |x| Upper( x[ SQL_NAME ] ) = Upper( uConn ) } )
      ENDIF

   ELSE

      IF cDtb <> NIL .AND. At( "\", cDtb ) > 0  // Outro database ou schema

         cDtb := GetPath( cDtb )

         IF Empty( cDtb )
            cDtb    := NIL
            cSchema := NIL
         ELSEIF Left( cDtb, 1 ) = "\"
            cDtb    := Subs( cDtb, 2 )
            cSchema := StrTran( Subs( cDtb, At( "\", cDtb ) +1 ), "\", "" )
            IF Empty( cSchema )
               cSchema := NIL
            ENDIF
            cDtb := Left( cDtb, At( "\", cDtb ) -1 )
            IF Empty( cDtb )
               cDtb := NIL
            ENDIF
         ELSE
            cSchema := Left( cDtb, At( "\", cDtb ) -1 )
            cDtb    := NIL
         ENDIF

      ENDIF

      IF cDtb = NIL
         nPos := aScan( aSqlConn, { |x| x[ SQL_CONN ] = sqlGetConn( "CONN" ) } )
         cDtb := aSqlConn[ nPos, SQL_DTB ]
      ENDIF

      vDef( @cSchema, "PUBLIC" )

      nPos := aScan( aSqlConn, { |x| x[ SQL_DTB ] = Upper( cDtb ) .AND. x[ SQL_SCHEMA ] = Upper( cSchema ) } )

   ENDIF

   IF nPos > 0
      nConn := aSqlConn[ nPos, SQL_CONN ]
   ELSE
      nConn := 0
   ENDIF

RETURN( nConn )



FUNCTION sqlGetInfo( ;        // Retorna informacoes (ip/database/schema/arquivo) com base numa string
                     cStr,;   // String
                     cInfo ;  // IP/DTB/SCHEMA/FILE/NAME/PORT
                   )

   LOCAL uReturn := ""
   LOCAL nPos

   IF Empty( cStr )
      RETURN( "" )
   ENDIF
   
   IF cInfo <> "PORT" .AND. At( ",", cInfo ) > 0
      cInfo := Left( cInfo, At( ",", cInfo ) -1 )
   ENDIF

   cStr  := Upper( cStr )
   cInfo := Upper( cInfo )

   IF cInfo <> "IP" .AND. Left( cStr, 2 ) = "\\"
      // Retira o IP da string
      cStr := Subs( cStr, 3 )
      cStr := Subs( cStr, At( "\", cStr + "\" ) )
   ENDIF

   IF cInfo = "IP"

      IF Left( cStr, 2 ) = "\\"
         uReturn := Subs( cStr, 3 )
         uReturn := Left( uReturn, At( "\", uReturn + "\" ) -1 )
      ENDIF

      uReturn := StrTran( uReturn, "\", "" )

      IF Empty( uReturn )
         nPos := aScan( aSqlConn, { |x| x[ SQL_CONN ] = sqlGetConn( "CONN" ) } )
         uReturn := aSqlConn[ nPos, SQL_IP ]
      ENDIF

   ELSEIF cInfo = "DTB"

      IF Left( cStr, 1 ) = "\"
         uReturn := Subs( cStr, 2 )
         uReturn := Left( uReturn, At( "\", uReturn + "\" ) -1 )
      ENDIF

      uReturn := StrTran( uReturn, "\", "" )
      
      IF At( "|", uReturn ) > 0
         uReturn := Left( uReturn, At( "|", uReturn ) -1 )
      ENDIF

      IF Empty( uReturn )
         nPos := aScan( aSqlConn, { |x| x[ SQL_CONN ] = sqlGetConn( "CONN" ) } )
         IF nPos > 0
            uReturn := aSqlConn[ nPos, SQL_DTB ]
         ENDIF
      ENDIF

   ELSEIF cInfo = "SCHEMA"

      uReturn := GetPath( cStr )

      IF Left( cStr, 1 ) = "\"
         uReturn := Subs( uReturn, 2 )
         uReturn := StrTran( Subs( uReturn, At( "\", uReturn + "\" ) +1 ), "\", "" )
         uReturn := GetNoEmpty( uReturn, "PUBLIC" )
      ELSE
         uReturn := Left( uReturn, At( "\", uReturn + "\" ) -1 )
         IF Empty( uReturn )
            nPos := aScan( aSqlConn, { |x| x[ SQL_CONN ] = sqlGetConn( "CONN" ) } )
            IF nPos > 0
               uReturn := aSqlConn[ nPos, SQL_SCHEMA ]
            ENDIF
         ENDIF
      ENDIF

   ELSEIF cInfo = "FILE"

      uReturn := GetNameFile( cStr )

      IF GetExt( uReturn ) = ".DBF"
         uReturn := DelExt( uReturn )
      ELSE
         uReturn := StrTran( uReturn, ".", "_" )
      ENDIF

   ELSEIF cInfo = "NAME"

      uReturn := sqlGetInfo( cStr, "DTB" )
      cStr    := sqlGetInfo( cStr, "SCHEMA" )

      nPos := aScan( aSqlConn, { |x| x[ SQL_DTB] = uReturn .AND. x[ SQL_SCHEMA ] = cStr } )

      IF nPos = 0
         uReturn := ""
      ELSE
         uReturn := aSqlConn[ nPos, SQL_NAME ]
      ENDIF

   ELSEIF cInfo = "PORT" .AND. At( ",", cInfo ) > 0
   
      uReturn := AllTrim( Subs( cInfo, At( ",", cInfo ) +1 ) )
      
   ENDIF

RETURN( If( cInfo = "PORT", GetNoEmpty( Val( uReturn ), 1987 ), AllTrim( uReturn ) ) )



FUNCTION sqlCheckConn( uConn, cMsg )

   // Verifica se a conexao ainda e valida.

   LOCAL lReturn := .F.

   vDef( @cMsg, "" )
   
   BEGIN SEQUENCE

      IF ! sqlActive() .OR. ( Left( cTimeChk, 5 ) = Left( Time(), 5 ) )
         lReturn := .T.
         BREAK
      ENDIF

      vDef( @uConn, nSqlConn )

      IF ValType( uConn ) = "C"
         uConn := sqlGetConn( "CONN", uConn )
      ENDIF

      IF uConn = 0
         BREAK
      ELSEIF ! SR_Exec( { || SR_CheckCnn( uConn ) } )
         BREAK
      ELSEIF ! sqlExecute( "SELECT * FROM sr_mgmnttables LIMIT 1", NIL, .F. )
         BREAK
      ENDIF

      cTimeChk := Time()

      lReturn := .T.

   ENDSEQUENCE

   IF ! lReturn

      MsgDlg( "A conex„o ^" + sqlGetConn( "NAME", uConn ) + "^ com o;" + ;
              "banco de dados n„o ‚ mais v lida !" + NoEmpty( cMsg, NIL, ";;" ) )

      IF DefAbortOpError()
         Fim( 0 )
      ENDIF

   ENDIF

RETURN( lReturn )



PROCEDURE sqlClearLocks( cType, cInternalID )

  // Limpa os controles de transacoes e arquivos abertos.

  LOCAL cSql

  IF cType = "ALL"
     cSql := "DELETE FROM public.sr_mgmntlocks"
  ELSEIF cType = "TRAN"
     IF cInternalID = NIL
        cInternalID := SR_GetInternalID()
     ENDIF
     cSql := "DELETE FROM public.sr_mgmntlocks WHERE SUBSTR(lock_,1,9) = 'MXTRAN_$_' AND wsid_ = '" + cInternalID + "'"
  ENDIF

  IF cSql <> NIL
     sqlExecute( cSql )
  ENDIF

RETURN( NIL )



FUNCTION sqlDirectory( cFiles )

   // Funcao Directory() p/ arquivos SQL.

   LOCAL aSql      := {}
   LOCAL cWhere    := ""
   LOCAL nConnSave := sqlSetConn( NIL                           ,;
                                  sqlGetInfo( cFiles, "DTB"    ),;
                                  sqlGetInfo( cFiles, "SCHEMA" ) )

   LOCAL oSql, nCount, nFExt, nSubs, cSubs, cNext, cAux, cSRFile

   cFiles := Upper( GetNameFile( cFiles ) )

   IF GetExt( cFiles ) = ".CDX"
      cSRFile := "sr_mgmntindexes"
   ELSE
      cSRFile := "sr_mgmnttables"
   ENDIF

   IF foundStr( GetExt( cFiles ), ".DBF|.CDX|.*" )
      cFiles := DelExt( cFiles )
   ENDIF

   IF cFiles <> "*"

      cFiles := StrTran( cFiles, ".", "_" )

      IF "?" $ cFiles .OR. "*" $ cFiles

         nFExt := 0
         nSubs := 0
         cSubs := ""
         cNext := ""

         FOR nCount := 1 TO Len( cFiles )

            cAux := Subs( cFiles, nCount, 1 )

            cSubs += cAux

            IF nCount < Len( cFiles )

               nSubs := GetNoEmpty( nSubs, nCount )

               cNext := Subs( cFiles, nCount +1, 1 )

               IF cAux + cNext = "??"
                  LOOP
               ELSEIF ( ! cAux $ "?*" ) .AND. ( ! cNext $ "?*_" )
                  LOOP
               ENDIF

            ENDIF

            IF "_" $ cSubs
               nFExt := 1
               IF Len( cSubs ) = 1
                  LOOP
               ENDIF
            ENDIF

            IF nFExt > 0
               IF nFExt = 1
                  cWhere += " AND POSITION('_' IN table_)>0"
                  cSubs := Subs( cSubs, 2 )
               ENDIF
               IF "?" $ cSubs
                  cWhere += " AND SUBSTRING(table_,POSITION('_' IN table_)+" + NumToStr( nFExt ) + "," + NumToStr( Len( cSubs ) ) + ")<>'" + Space( Len( cSubs ) ) + "'"
               ELSEIF ! "*" $ cSubs
                  cWhere += " AND UPPER(SUBSTRING(table_,POSITION('_' IN table_)+" + NumToStr( nFExt ) + "," + NumToStr( Len( cSubs ) ) + "))='" + cSubs + "'"
               ENDIF
               nFExt += Len( cSubs )
            ELSEIF "?" $ cSubs
               cWhere += " AND SUBSTR(table_," + NumToStr( nSubs ) + "," + NumToStr( Len( cSubs ) ) + ")<>'" + Space( Len( cSubs ) ) + "'"
            ELSEIF ! "*" $ cSubs
               cWhere += " AND UPPER(SUBSTR(table_," + NumToStr( nSubs ) + "," + NumToStr( Len( cSubs ) ) + "))='" + cSubs + "'"
            ENDIF

            cSubs := ""
            nSubs := 0

         NEXT

         cWhere := Subs( cWhere, 6 )

      ELSE
         cWhere := "UPPER(TRIM(SUBSTR(table_,1,12)))='" + cFiles + "'"
      ENDIF

      cWhere := " WHERE " + cWhere

   ENDIF

   nCount := aScan( aSqlConn, { |x| x[ SQL_CONN ] = sqlGetConn( "CONN" ) } )

   cAux := aSqlConn[ nCount, SQL_SCHEMA ]

   oSql := SR_GetConnection()

   oSql:exec( "SELECT DISTINCT table_ FROM " + If( cAux = "PUBLIC", "", cAux + "." ) + cSRFile + cWhere, .F., .T., @aSql )

   FOR nCount := 1 TO Len( aSql )

      cFiles := AllTrim( aSql[ nCount, 1 ] )

      IF mxIntervalo( Len( Subs( cFiles, Rat( "_", cFiles ) +1 ) ), 1, 3, .F. )
         cFiles := Left( cFiles, Rat( "_", cFiles ) -1 ) + "." + Subs( cFiles, Rat( "_", cFiles ) +1 )
      ENDIF

      aSql[ nCount, 1 ] := cFiles

   NEXT

   sqlSetConn( nConnSave )

RETURN( aSql )



FUNCTION sqlCopyTable( cOri, cDes, cRddDes )

   // Copia arquivos SQL.

   LOCAL lReturn := .F.
   LOCAL lTran   := mxVTrans(.F.)

   vDef( @cRddDes, "SQLRDD" )

   BEGIN SEQUENCE

      IF ! dbFile( cOri )
         BREAK
      ENDIF

      Status( "Aguarde, copiando " + cOri, NIL, 1 )

      IF Select( sqlGetInfo( cOri, "FILE" ) ) > 0
         BREAK
      ENDIF

      IF ! mxOpen( 0, cOri, "EOIIXORI", "SQLRDD", .F., .T., .F. )
         BREAK
      ENDIF

      mxFDel( cDes, NIL, NIL, cRddDes )

      IF ! mxDbCreate( cDes, mxDbStruct( "EOIIXORI" ), NIL, cRddDes )
         BREAK
      ENDIF

      mxOpen( 0, cDes, "EOIIXDES", cRddDes, .F., .F., .F. )

      IF ! EOIIXDES->( mxAppendFrom( cOri, "EOIIXORI", NIL, NIL, "SQLRDD" ) )
         BREAK
      ENDIF

      lReturn := ( EOIIXDES->( mxRecCount( cDes ) ) = EOIIXORI->( mxRecCount( cOri ) ) )

   ENDSEQUENCE

   mxClose( { "EOIIXORI", "EOIIXDES" } )

   IF ! lReturn
      mxFDel( cDes, NIL, NIL, cRddDes )
   ENDIF

   mxVTrans( lTran )

RETURN( lReturn )



FUNCTION sqlRenameTable( cOri, cDes )

   // Renomeia e move arquivos SQL.

   LOCAL lReturn := .F.
   LOCAL aSql    := {}
   LOCAL aIdx    := {}

   LOCAL nConnSave
   LOCAL cSchemaOri, cSchemaDes, cFileOri, cFileDes, cFileTmp

   IF ! dbFile( cOri )
      RETURN( .F. )
   ENDIF

   IF sqlGetInfo( cOri, "DTB" ) = sqlGetInfo( cDes, "DTB" )

      cSchemaOri := sqlGetInfo( cOri, "SCHEMA" )
      cSchemaDes := sqlGetInfo( cDes, "SCHEMA" )

      cFileOri := sqlGetInfo( cOri, "FILE" )
      cFileDes := sqlGetInfo( cDes, "FILE" )

      nConnSave := sqlSetConn( NIL                         ,;
                               sqlGetInfo( cOri, "DTB"    ),;
                               sqlGetInfo( cOri, "SCHEMA" ) )

      sqlExecute( "SELECT DISTINCT tag_ FROM " + cSchemaOri + ".sr_mgmntindexes WHERE UPPER(table_) = '" + Upper( cFileOri ) + "'", @aIdx, .F. )

      aSql := {}
      sqlExecute( "SELECT tablename FROM pg_indexes WHERE UPPER(schemaname)='" + Upper( cSchemaOri ) + "' AND UPPER(tablename)='" + Upper( cFileOri ) + "' AND UPPER(indexname)='" + Upper( cFileOri + "_sr" ) + "'", @aSql, .F. )
      IF Len( aSql ) > 0
         aAdd( aIdx, { "sr" } )  // Indice default p/ controle do recno
      ENDIF

      cFileTmp := "TEMP_" + cFileOri

      aSql := {}
      
      // Exclui os arquivos temporarios antes do processamento

      aAdd( aSql, "DROP TABLE IF EXISTS "    + cSchemaOri + "." + cFileTmp + " CASCADE" )
      aAdd( aSql, "DROP SEQUENCE IF EXISTS " + cSchemaOri + "." + cFileTmp + "_sq CASCADE" )
      aEval( aIdx, { |i| aAdd( aSql, "DROP INDEX IF EXISTS " + cSchemaOri + "." + cFileTmp + "_" + Trim( i[1] ) + " CASCADE" ) } )

      aAdd( aSql, "DROP TABLE IF EXISTS "    + cSchemaDes + "." + cFileTmp + " CASCADE" )
      aAdd( aSql, "DROP SEQUENCE IF EXISTS " + cSchemaDes + "." + cFileTmp + "_sq CASCADE" )
      aEval( aIdx, { |i| aAdd( aSql, "DROP INDEX IF EXISTS " + cSchemaDes + "." + cFileTmp + "_" + Trim( i[1] ) + " CASCADE" ) } )

      aAdd( aSql, "DROP TABLE IF EXISTS "    + cSchemaDes + "." + cFileDes + " CASCADE" )
      aAdd( aSql, "DROP SEQUENCE IF EXISTS " + cSchemaDes + "." + cFileDes + "_sq CASCADE" )
      aEval( aIdx, { |i| aAdd( aSql, "DROP INDEX IF EXISTS " + cSchemaDes + "." + cFileDes + "_" + Trim( i[1] ) + " CASCADE" ) } )

      // Renomeia a tabela original p/ um nome temporario

      aAdd( aSql, "ALTER TABLE "    + cSchemaOri + "." + cFileOri +    " RENAME TO " + cFileTmp         )
      aAdd( aSql, "ALTER SEQUENCE " + cSchemaOri + "." + cFileOri + "_sq RENAME TO " + cFileTmp + "_sq" )

      aEval( aIdx, { |i| aAdd( aSql, "ALTER TABLE " + cSchemaOri + "." + cFileOri + "_" + Trim( i[1] ) + " RENAME TO " + cFileTmp + "_" + Trim( i[1] ) ) } )

      aAdd( aSql, "UPDATE " + cSchemaOri + ".sr_mgmnttables  SET table_ = '" + cFileTmp + "' WHERE table_ = '" + cFileOri + "'" )
      aAdd( aSql, "UPDATE " + cSchemaOri + ".sr_mgmntindexes SET table_ = '" + cFileTmp + "' WHERE table_ = '" + cFileOri + "'" )

      // Altera o schema

      IF cSchemaOri <> cSchemaDes
         aAdd( aSql, "ALTER TABLE "    + cSchemaOri + "." + cFileTmp +    " SET SCHEMA " + cSchemaDes )
         aAdd( aSql, "ALTER SEQUENCE " + cSchemaOri + "." + cFileTmp + "_sq SET SCHEMA " + cSchemaDes )
      ENDIF

      // Renomeia o temporario p/ o novo nome (tabela/sequencia/indices)

      aAdd( aSql, "ALTER TABLE "    + cSchemaDes + "." + cFileTmp +    " RENAME TO " + cFileDes         )
      aAdd( aSql, "ALTER SEQUENCE " + cSchemaDes + "." + cFileTmp + "_sq RENAME TO " + cFileDes + "_sq" )

      aEval( aIdx, { |i| aAdd( aSql, "ALTER TABLE " + cSchemaDes + "." + cFileTmp + "_" + Trim( i[1] ) + " RENAME TO " + cFileDes + "_" + Trim( i[1] ) ) } )

      // Renomeia as sequencias

      IF cFileOri <> cFileDes
         aAdd( aSql, "ALTER TABLE " + cSchemaDes + "." + cFileDes + " DROP CONSTRAINT " + Lower( cFileOri ) + "_sr_recno_key" )
         aAdd( aSql, "ALTER TABLE " + cSchemaDes + "." + cFileDes + " ADD  CONSTRAINT " + Lower( cFileDes ) + "_sr_recno_key UNIQUE (sr_recno)" )
      ENDIF

      // Atualiza os arquivos de controle do SQLRDD

      IF cSchemaOri <> cSchemaDes
         aAdd( aSql, "DELETE FROM " + cSchemaDes + ".sr_mgmnttables  WHERE UPPER(table_) = '" + Upper( cFileTmp ) + "'" )
         aAdd( aSql, "DELETE FROM " + cSchemaDes + ".sr_mgmntindexes WHERE UPPER(table_) = '" + Upper( cFileTmp ) + "'" )

         aAdd( aSql, "INSERT INTO " + cSchemaDes + ".sr_mgmnttables  (SELECT * FROM " + cSchemaOri + ".sr_mgmnttables  WHERE UPPER(table_) = '" + Upper( cFileTmp ) + "')" )
         aAdd( aSql, "INSERT INTO " + cSchemaDes + ".sr_mgmntindexes (SELECT * FROM " + cSchemaOri + ".sr_mgmntindexes WHERE UPPER(table_) = '" + Upper( cFileTmp ) + "')" )
      ENDIF

      aAdd( aSql, "UPDATE " + cSchemaDes + ".sr_mgmnttables  SET table_ = '" + cFileDes + "' WHERE UPPER(table_) = '" + Upper( cFileTmp ) + "'" )
      aAdd( aSql, "UPDATE " + cSchemaDes + ".sr_mgmntindexes SET " + ;
                  "table_ = '"     + cFileDes + "', " + ;
                  "idxname_ = '"   + cFileDes + "', " + ;
                  "phis_name_ = '" + cFileDes + "' || '_' || tag_ WHERE UPPER(table_) = '" + Upper( cFileTmp ) + "'" )

      IF cSchemaOri <> cSchemaDes
         aAdd( aSql, "DELETE FROM " + cSchemaOri + ".sr_mgmnttables  WHERE UPPER(table_) = '" + Upper( cFileTmp ) + "'" )
         aAdd( aSql, "DELETE FROM " + cSchemaOri + ".sr_mgmntindexes WHERE UPPER(table_) = '" + Upper( cFileTmp ) + "'" )
      ENDIF

      lReturn := sqlExecute( aSql )

      sqlSetConn( nConnSave )

   ELSE

      IF sqlCopyTable( cOri, cDes )
         mxFDel( cOri, NIL, NIL, "SQLRDD" )
      ENDIF

   ENDIF

RETURN( lReturn )



PROCEDURE sqlDeleteIndex( cFile, cIndex )

   LOCAL aIdx      := {}
   LOCAL aSql      := {}
   LOCAL cSchema   := sqlGetInfo( cFile, "SCHEMA" )
   LOCAL nConnSave := sqlSetConn( NIL                          ,;
                                  sqlGetInfo( cFile, "DTB"    ),;
                                  sqlGetInfo( cFile, "SCHEMA" ) )

   cFile := sqlGetInfo( cFile, "FILE" )

   IF cIndex = NIL

      sqlExecute( "SELECT DISTINCT phis_name_ FROM " + cSchema + ".sr_mgmntindexes WHERE UPPER(table_) = '" + Upper( cFile ) + "'", @aIdx, .F. )

      aEval( aIdx, { |i| aAdd( aSql, "DROP INDEX IF EXISTS " + cSchema + "." + Trim( i[1] ) + " CASCADE" ) } )

      aAdd( aSql, "DELETE FROM " + cSchema + ".sr_mgmntindexes WHERE UPPER(table_) = '" + Upper( cFile ) + "'" )
   
   ELSE

      aAdd( aSql, "DROP INDEX IF EXISTS " + cSchema + "." + cFile + "_" + Trim( cIndex ) + " CASCADE" )

      aAdd( aSql, "DELETE FROM " + cSchema + ".sr_mgmntindexes WHERE UPPER(phis_name_) = '" + Upper( cFile + "_" + Trim( cIndex ) ) + "'" )

   ENDIF
   
   sqlExecute( aSql )

RETURN( NIL )



FUNCTION sqlExecute( uSql, aResult, lTran, uConn, lLog, lShowError, lSendErrorMail, lSet_W1252 )

   // Executa uma instrucao SQL direto no banco de dados.

   LOCAL lReturn := .F.

   LOCAL aSql, nSql, oSql, oErr, cResult, nConnSave, cError, cErrorMsg, cSql

   vDef( @lTran         , .T. )
   vDef( @lLog          , .T. )
   vDef( @lSendErrorMail, .T. )
   vDef( @lSet_W1252    , .F. )
   vDef( @lShowError    , IsDef( "SQL_SHOWERROR" ) )
   
   IF ValType( uSql ) = "C"
      aSql  := { uSql }
   ELSE
      aSql := aClone( uSql )
   ENDIF
   
   IF ValType( aResult ) = "C"
      cResult := aResult
      aResult := {}
   ENDIF

   BEGIN SEQUENCE

      IF uConn <> NIL
         TRY
            nConnSave := sqlSetConn( uConn )
         CATCH oErr
            IF lLog .AND. oErr <> NIL
               cError := oErr:Description
               TraceLog( cError )
            ENDIF
            BREAK
         END
      ENDIF

      IF SR_GetActiveConnection() = 0 .OR. SR_GetActiveConnection() <> sqlGetConn( "CONN" )
         lTran := .F.
         BREAK
      ENDIF

      oSql := SR_GetConnection()

      IF lTran
         oSql:execute( "BEGIN" )
      ENDIF
      
      FOR nSql := 1 TO Len( aSql )

         cSql := aSql[ nSql ]
         
         TraceLog( "executando " + cSql )

         sqlLastCmd( cSql )

         IF ( lSet_W1252 .OR. IsProcedure( "CSW" ) ) .AND. Left( Upper( cSql ), 7 ) = "SELECT "
            TRY
               oSql:exec( "SET CLIENT_ENCODING='WIN1252'", .F., .F., {}, "" )
            CATCH
            END
         ENDIF

         TRY
            IF oSql:exec( cSql, .F., aResult <> NIL, @aResult, cResult ) = SQL_ERROR
               IF lSet_W1252
                  osql:ListCatTables()
               ENDIF
               IF ( ! lSet_W1252 ) .OR. ( oSql:exec( cSql, .F., aResult <> NIL, @aResult, cResult ) = SQL_ERROR )
                  IF lLog
                     TraceLog( "erro " + sqlLastError( oSql:LastError ) )
                     cErrorMsg := sqlLastError() + mxProcName()
                     cError    := mxErrorLog( "Erro na instrucao SQL : " + cSql, cErrorMsg )
                  ENDIF
                  BREAK
               ENDIF
            ENDIF
         CATCH oErr
            IF lLog .AND. oErr <> NIL
               TraceLog( oErr:Description )
            ENDIF
            aResult := {}
            BREAK
         END

         TraceLog( "ok" )

      NEXT

      lReturn := .T.

   ENDSEQUENCE

   IF lTran
      TRY
         IF lReturn
            oSql:execute( "COMMIT", .F. )
         ELSE
            oSql:execute( "ROLLBACK", .F. )
         ENDIF
      CATCH
      END
   ENDIF

   IF cError <> NIL
      IF lSendErrorMail .AND. mxEnviaErro( cErrorMsg )
         mxErrorMail( cError, .F. )
      ENDIF
      IF lShowError
         MsgDlg( StrTran( cError, _NL, ";" ) )
      ENDIF
   ENDIF

   IF uConn <> NIL
      sqlSetConn( nConnSave )
   ENDIF

RETURN( lReturn )



FUNCTION sqlLastError( cError )

   IF cError <> NIL
      cLastErr := AllTrim( cError )
   ENDIF

RETURN( cLastErr )



FUNCTION sqlLastCmd( cCmd )

   IF cCmd <> NIL
      cLastCmd := AllTrim( cCmd )
   ENDIF

RETURN( cLastCmd )



PROCEDURE sqlDefSyntheticIndex( cKey, lForce )

   // Forca a criacao de indices sinteticos p/ campos do tipo data.

   #define F_SYNTHETIC { ;
                         "DTCCCD","DTDCHQ","DCACHQ","LIGCLI","LI1CLI",;
                         "LI2CLI","DTECOM","DTECUP","DTPDUP","DPADUP",;
                         "DTEITC","DTEITS","LIGAGE","DTPPAG","DGPPAG",;
                         "DTCPED","DTPTRF","DATLCF"                   ;
                       }

   LOCAL nField, aField

   IF RddName() = "SQLRDD"

      vDef( @lForce, .F. )

      IF lForce

         SR_SetSyntheticIndex( .T. )

      ELSE

         SR_SetSyntheticIndex( .F. )

         aField := aKeyFormat( cKey )

         FOR nField := 1 TO Len( aField )

            IF mxIn( Right( aField[ nField, 1 ], 6 ), F_SYNTHETIC )
               SR_SetSyntheticIndex( .T. )
               EXIT
            ENDIF

         NEXT

      ENDIF

   ENDIF

RETURN( NIL )



FUNCTION SR_Exec( bFunc )

   LOCAL uReturn  := Eval( bFunc )
   LOCAL cSaveSql := sqlLastCmd()

   IF Empty( GetActTrans() )
      IF nSqlCommit = 0
         sqlExecute( "COMMIT", NIL, .F., NIL, .F., .F., .F. )
      ENDIF
      sqlLastCmd( cSaveSql )
   ENDIF

RETURN( uReturn )



FUNCTION dbConverte( uOri, uDes, lZap, aPrgs, cError )

   // Converte arquivos DBF e Btrieve p/ o formato SQL e arquivos SQL p/ DBF.

   #define N_DB_REFRESH  100000
   #define TMP_ALIAS_ORI "EOIIWORI"
   #define TMP_ALIAS_DES "EOIIWDES"

   LOCAL lReturn := .T.
   LOCAL lSetDel := Set( _SET_DELETED, .F. )
   LOCAL lSnd    := sndActive(.F.)
   LOCAL lTrans  := mxTransMode(.F.)
   LOCAL cOdbc   := "ControlShop"
   LOCAL nRec    := 0

   LOCAL cOri, cDes, cRddOri, cRddDes, cFileOri, cFileDes, cSql, cPrgs, cField, lNew
   LOCAL oErr, oCn, oRs, nField, nField2, nLastRec, uRepl, aStr1, nTrans, cConn, aFReplace

   vDef( @lZap , .T. )
   vDef( @aPrgs, { "Convertendo", 2 } )

   cError := ""

   IF ValType( uOri ) = "A"
      cOri    := uOri[1]
      cRddOri := uOri[2]
      IF Len( uOri ) > 2
         cOdbc := uOri[3]
      ENDIF
   ELSE
      cOri    := uOri
      cRddOri := If( GetExt( cOri ) = ".DAT", "RQBRDD",;
                 If( GetExt( cOri ) = ".DBF", "DBFCDX", "SQLRDD" ) )
   ENDIF

   IF ValType( uDes ) = "A"
      cDes    := uDes[1]
      cRddDes := uDes[2]
   ELSE
      cDes    := uDes
      cRddDes := If( GetExt( cDes ) = ".DBF", "DBFCDX", "SQLRDD" )
   ENDIF

   cFileOri := DelExt( GetNameFile( cOri ) )
   cFileDes := DelExt( GetNameFile( cDes ) )

   IF cRddDes = "SQLRDD"
      cPrgs := "\" + sqlGetInfo( cDes, "DTB" ) + "\" + sqlGetInfo( cDes, "SCHEMA" )
   ELSE
      cPrgs := GetNoEmpty( GetPath( cDes ), CurPath() + "\" )
   ENDIF

   cPrgs := fNameDir( cPrgs, 33 )

   IF cRddOri = "RQBRDD"

      // Btrieve via ODBC.

      IF ! dbFile( cDes, cRddDes )
         dicDbCreate( cFileDes, NIL, NIL, NIL, cDes, cRddDes )
      ENDIF
      mxOpen( 0, cDes, TMP_ALIAS_DES, cRddDes, .F., .F. )
      IF lZap
         ( TMP_ALIAS_DES )->( mxZap() )
      ENDIF

      oCn := CreateObject( "ADODB.Connection" )
      oRs := CreateObject( "ADODB.Recordset" )

      oCn:Open( 'Provider=MSDASQL.1;Persist Security Info=False;Data Source=' + cOdbc + ';Extended Properties="DSN=' + cOdbc + '"' )

      // Busca a quantidade de registros

      Status( "Aguarde, contando registros de " + cFileOri + "...", NIL, 1 )

      cSql := "SELECT COUNT(1) AS LASTREC FROM " + cFileOri

      TRY
         oRs:Open( cSql, oCn, 2, 3 )
         oRs:MoveFirst()
         nLastRec := oRs:Fields[ "LASTREC" ]:Value()
         oRs:Close()
      CATCH oErr
         lReturn  := .F.
         nLastRec := 0
         cError   := oErr:Description
         mxErrorLog( cError, "dbConverte(): " + cRddOri + " / " + cFileOri )
      END

      IF nLastRec > 0

         IF cRddDes = "SQLRDD"
            ( TMP_ALIAS_DES )->( SR_QuickAppend(.T.) )
            ( TMP_ALIAS_DES )->( SR_MaxRowCache( nLastRec ) )
         ENDIF

         Status( "Abrindo arquivo " + cFileOri + "...", NIL, 1 )

         cSql := "SELECT * FROM " + cFileOri + " WHERE false"

         oRs:Open( cSql, oCn, 2, 3 )

         cSql := ""

         aStr1 := {}

         FOR nField := 0 TO oRs:Fields:Count -1

            cSql += ","

            IF oRs:Fields[ nField ]:Type = 131  // Numerico
               cSql += "(" + oRs:Fields[ nField ]:Name + "*1) AS "
            ENDIF

            cSql += oRs:Fields[ nField ]:Name

            aAdd( aStr1, { oRs:Fields[ nField ]:Name, oRs:Fields[ nField ]:Type } )

         NEXT

         cSql := "SELECT " + Subs( cSql, 2 ) + " FROM " + cFileOri

         oRs:Close()
         oRs:Open( cSql, oCn, 2, 3 )
         oRs:MoveFirst()

         prgsStart( { aPrgs[1] + " " + cFileOri, cPrgs }, nLastRec, aPrgs[2] )

         DO WHILE ! oRs:Eof()

            prgsNext()

            cSql := ""

            ( TMP_ALIAS_DES )->( dbAppend() )

            FOR nField := 1 TO Len( aStr1 )

               nField2 := ( TMP_ALIAS_DES )->( FieldPos( aStr1[ nField, 1 ] ) )

               IF nField2 = 0
                  LOOP
               ENDIF

               uRepl := oRs:Fields[ aStr1[ nField, 1 ] ]:Value()

               ( TMP_ALIAS_DES )->( dbConvRepl( nField2, uRepl ) )

               cSql += UtoC( uRepl ) + "|"

            NEXT

            IF cRddDes = "SQLRDD" .AND. ++ nRec = N_DB_REFRESH
               mxClose( TMP_ALIAS_DES )
               mxOpen( 0, cDes, TMP_ALIAS_DES, cRddDes, .F., .F. )
               Status( "" )
               nRec := 0
            ENDIF

            oRs:MoveNext()

         ENDDO

         oRs:Close()

      ENDIF

      oCn:Close()

   ELSEIF dbFile( cOri, cRddOri )

      // Arquivos DBF.

      mxOpen( 0, cOri, TMP_ALIAS_ORI, cRddOri, .T., .T. )

      aStr1 := ( TMP_ALIAS_ORI )->( xDbStruct() )

      IF ! dbFile( cDes, cRddDes )
         mxDbCreate( cDes, aStr1, NIL, cRddDes )
      ENDIF
      mxOpen( 0, cDes, TMP_ALIAS_DES, cRddDes, .F., .F. )
      
      cConn := sqlGetConn( "NAME" )

      IF lZap
         ( TMP_ALIAS_DES )->( mxZap() )
         ( TMP_ALIAS_DES )->( DbCommit() )
      ENDIF

      aFReplace := {}

      FOR nField := 1 TO Len( aStr1 )

         cField := ( TMP_ALIAS_ORI )->( FieldName( nField ) )

         IF ( TMP_ALIAS_DES )->( FieldPos( cField ) ) = 0
            LOOP
         ENDIF

         aAdd( aFReplace, { cField, nField } )

      NEXT

      nLastRec := ( TMP_ALIAS_ORI )->( mxRecCount( cOri ) )

      ( TMP_ALIAS_ORI )->( mxTop() )
      ( TMP_ALIAS_ORI )->( prgsStart( { aPrgs[1] + " " + cFileOri, cPrgs }, nLastRec, aPrgs[2] ) )
      
      IF cRddDes = "SQLRDD"

         nTrans := 0
         cSql   := ""

         DO WHILE ( TMP_ALIAS_ORI )->( !Eof() )

            prgsNext()

            IF ( TMP_ALIAS_ORI )->( Deleted() )
               ( TMP_ALIAS_ORI )->( DbSkip() )
               nLastRec --
               LOOP
            ENDIF
            
            cSql += dbConv_SqlInsert( aFReplace, cDes, TMP_ALIAS_ORI )

            IF ++ nTrans = 100
               cSql := "BEGIN;" + cSql + "COMMIT"
               IF ! sqlExecute( cSql, NIL, .F., cConn, NIL, .T. )
                  cError  += "Erro na gravacao do registro" + Chr(13) + Chr(10) + cSql
                  lReturn := .F.
                  EXIT
               ENDIF
               nTrans := 0
               cSql   := ""
            ENDIF

            ( TMP_ALIAS_ORI )->( DbSkip() )

         ENDDO

         IF ! Empty( cSql )
            cSql := "BEGIN;" + cSql + "COMMIT"
            IF ! sqlExecute( cSql, NIL, .F., cConn, NIL, .T. )
               cError  += "Erro na gravacao do registro" + Chr(13) + Chr(10) + cSql
               lReturn := .F.
            ENDIF
         ENDIF

      ELSE
      
         /*
         IF cRddDes = "SQLRDD"
            ( TMP_ALIAS_DES )->( SR_QuickAppend(.T.) )
            ( TMP_ALIAS_DES )->( SR_MaxRowCache( nLastRec ) )
         ENDIF
         */

         DO WHILE ( TMP_ALIAS_ORI )->( !Eof() )

            prgsNext()

            IF ( TMP_ALIAS_ORI )->( Deleted() )
               //( TMP_ALIAS_ORI )->( mxSkip() )
               ( TMP_ALIAS_ORI )->( DbSkip() )
               nLastRec --
               LOOP
            ENDIF

            cSql := ""

            ( TMP_ALIAS_DES )->( dbAppend() )

            FOR nField := 1 TO Len( aStr1 )

               nField2 := ( TMP_ALIAS_DES )->( FieldPos( ( TMP_ALIAS_ORI )->( FieldName( nField ) ) ) )

               IF nField2 = 0
                  LOOP
               ENDIF

               uRepl := ( TMP_ALIAS_ORI )->( FieldGet( nField ) )

               IF ! Empty( uRepl )

                  ( TMP_ALIAS_DES )->( dbConvRepl( nField2, uRepl ) )

                  cSql += UtoC( uRepl ) + "|"

               ENDIF

            NEXT

            TRY
               //( TMP_ALIAS_DES )->( mxDbCommit() )
               ( TMP_ALIAS_DES )->( DbCommit() )
            CATCH oErr
               // Erro na gravacao do registro
               cError   := "Erro na gravacao do registro" + Chr(13) + Chr(10) + oErr:Description + "(" + cSql + ")"
               lReturn := .F.
            END

            //( TMP_ALIAS_ORI )->( mxSkip() )

            IF cRddDes = "SQLRDD" .AND. ++ nRec = N_DB_REFRESH
               mxClose( TMP_ALIAS_DES )
               mxOpen( 0, cDes, TMP_ALIAS_DES, cRddDes, .F., .F. )
               Status( "" )
               nRec := 0
            ENDIF

            ( TMP_ALIAS_ORI )->( DbSkip() )

         ENDDO

      ENDIF

      mxClose( TMP_ALIAS_ORI )

      TRY
         //( TMP_ALIAS_DES )->( mxDbCommit() )
         ( TMP_ALIAS_DES )->( DbCommit() )
      CATCH
         // Erro na gravacao do registro
         cError  += "Erro na gravacao do registro" + Chr(13) + Chr(10) + cSql
         lReturn := .F.
      END

   ELSE

      cError  := "Arquivo de origem " + Trim( cOri ) + " nao encontrado"
      lReturn := .F.

   ENDIF

   IF lZap
      vDef( @nLastRec, 0 )
      lReturn := ( lReturn .AND. nLastRec = ( TMP_ALIAS_DES )->( mxRecCount( cDes ) ) )
      IF ! lReturn .AND. Empty( cError )
         cError := "Numero de registros nao confere: " + NumToStr( nLastRec ) + "|" + NumToStr( ( TMP_ALIAS_DES )->( mxRecCount( cDes ) ) )
      ENDIF
   ENDIF

   mxClose( TMP_ALIAS_DES )

   mxTransMode( lTrans )
   sndActive( lSnd )
   Set( _SET_DELETED, lSetDel )

RETURN( lReturn )



STATIC FUNCTION dbConv_SqlInsert( aFReplace, cTab, cAliasOri )

   LOCAL nField, uInfo, cField

   sqlFieldsStart( "I" )

   FOR nField := 1 TO Len( aFReplace )
   
      cField := aFReplace[ nField, 1 ]
      uInfo  := ( cAliasOri )->( FieldGet( aFReplace[ nField, 2 ] ) )
      
      IF ValType( uInfo ) = "C"
         uInfo := StrTran( uInfo, "\", "\\" )
         uInfo := StrTran( uInfo, "'", "''" )
      ENDIF

      sqlFReplace( cField, uInfo )

   NEXT

RETURN( sqlDefWrite( cTab ) + ";" )



STATIC PROCEDURE dbConvRepl( nField, uRepl )

   uRepl := dbConvFType( Type( FieldName( nField ) ), uRepl )

   FieldPut( nField, uRepl )

RETURN( NIL )



STATIC PROCEDURE dbConvFType( cType1, uRepl )

   LOCAL cType2 := ValType( uRepl )

   IF cType1 <> cType2

      DO CASE
         CASE cType1 = "C"
              DO CASE
                 CASE cType2 = "U" ; uRepl := ""
                 CASE cType2 = "N" ; uRepl := NumToStr( uRepl )
                 CASE cType2 = "D" ; uRepl := DtoC( uRepl )
                 CASE cType2 = "L" ; uRepl := If( uRepl, "S", "N" )
              ENDCASE
         CASE cType1 = "N"
              DO CASE
                 CASE cType2 = "U" ; uRepl := 0
                 CASE cType2 = "C" ; uRepl := Val( uRepl )
                 CASE cType2 = "D" ; uRepl := Val( DtoS( uRepl ) )
                 CASE cType2 = "L" ; uRepl := If( uRepl, 1, 0 )
              ENDCASE
         CASE cType1 = "D"
              DO CASE
                 CASE cType2 = "U" ; uRepl := CtoD( "" )
                 CASE cType2 = "C" ; uRepl := CtoD( uRepl )
              ENDCASE
         CASE cType1 = "L"
              DO CASE
                 CASE cType2 = "U" ; uRepl := .F.
                 CASE cType2 = "N" ; uRepl := If( uRepl <> 0 , .T., .F. )
                 CASE cType2 = "C" ; uRepl := If( uRepl = "S", .T., .F. )
              ENDCASE
      ENDCASE

   ENDIF

RETURN( uRepl )

// Funcoes p/ instrucoes SQL.


PROCEDURE sqlNew( cFrom, cFromAs )

  cSqlFrom   := cFrom
  cSqlFromAs := cFromAs
  aSqlFields := {}
  aSqlJoin   := {}
  aSqlCase   := {}
  cSqlCase   := ""
  cSqlWhere  := NIL
  cSqlGroup  := NIL
  cSqlOrder  := NIL

RETURN( NIL )



PROCEDURE sqlField( uField, cFieldAs, aExcept )

   LOCAL cField, nField

   vDef( @cFieldAs, "" )

   IF ValType( uField ) = "C"
      IF uField = "*" .AND. aExcept <> NIL
         uField := {}
         FOR nField := 1 TO fCount()
            IF aScan( aExcept, Field( nField ) ) = 0
               aAdd( uField, Field( nField ) )
            ENDIF
         NEXT
      ELSE
         uField := { uField }
      ENDIF
   ELSE
      cFieldAs := ""
   ENDIF

   FOR nField := 1 TO Len( uField )

      cField := uField[ nField ]

      IF Len( cField ) = 3 .AND. Left( cField, 1 ) <> "'"
         cField := sisFlgModule() + cField + Subs( cSqlFrom, 3, 3 )
      ENDIF

      IF cSqlFromAs <> NIL .AND. Left( cField, 3 ) = sisFlgModule()
         cField := cSqlFromAs + "." + cField
      ENDIF

      aAdd( aSqlFields, { cField, cFieldAs } )

   NEXT

RETURN



PROCEDURE sqlCase( cOper, uCase1, uCase2 )

   cOper := Upper( cOper )

   IF cOper = "BEGIN"

      cSqlCase := "CASE"
      aSqlCase := uCase1

   ELSEIF cOper = "WHEN"

      cSqlCase += " WHEN "
      cSqlCase += uCase1
      cSqlCase += " THEN "

      IF aSqlCase = NIL
         cSqlCase += uCase2
      ELSE
         cSqlCase += sqlCast( uCase2, aSqlCase[2], aSqlCase[3], aSqlCase[4] )
      ENDIF

   ELSEIF cOper = "ELSE"

      cSqlCase += " ELSE "

      IF aSqlCase = NIL
         cSqlCase += uCase2
      ELSE
         cSqlCase += sqlCast( uCase2, aSqlCase[2], aSqlCase[3], aSqlCase[4] )
      ENDIF

   ELSEIF cOper = "END"

      cSqlCase += " END"

      IF aSqlCase <> NIL
         cSqlCase += " AS " + aSqlCase[1]
      ENDIF

      sqlField( cSqlCase )

      cSqlCase := ""
      aSqlCase := {}

   ENDIF

RETURN( NIL )



PROCEDURE sqlJoin( cJoin, cCond )

   IF cCond <> NIL
      cJoin += " ON " + cCond
   ENDIF

   aAdd( aSqlJoin, cJoin )

RETURN( NIL )



FUNCTION sqlWhere( cWhere, uComp1, uComp2 )

   LOCAL cReturn := " " + cWhere
   LOCAL cAux

   IF uComp1 <> NIL

      vDef( @uComp2, uComp1 )

      IF ValType( uComp1 ) = "A"

         cReturn += " IN ("

         IF ValType( uComp1[1] ) = "N"
            aEval( uComp1, { |x| cReturn += NumToStr( x ) + "," } )
         ELSE
            aEval( uComp1, { |x| cReturn += "'" + x + "'," } )
         ENDIF

         cReturn := Left( cReturn, Len( cReturn ) -1 ) + ")"

      ELSE

         IF ValType( uComp1 ) = "D"
            uComp1 := sqlCompFormat( uComp1 )
            uComp2 := sqlCompFormat( GetNoEmpty( uComp2, uComp1 ) )
         ENDIF

         IF uComp1 = uComp2
            cReturn += "=" + UtoC( uComp1 )
         ELSE
            cReturn += " BETWEEN " + UtoC( uComp1 ) + " AND " + UtoC( uComp2 )
         ENDIF

      ENDIF

   ENDIF

   vDef( @cSqlWhere, "" )

   cAux := AllTrim( cReturn )

   IF ( ! Empty( cSqlWhere ) )                .AND. ;
      ( Upper( Left( cAux, 4 ) )  <> "AND " ) .AND. ;
      ( Upper( Right( cAux, 4 ) ) <> " AND" ) .AND. ;
      ( Upper( Left( cAux, 3 ) )  <> "OR "  ) .AND. ;
      ( Upper( Right( cAux, 3 ) ) <> " OR"  )

      cSqlWhere := AllTrim( cSqlWhere )

      IF ( Upper( Right( cSqlWhere, 4 ) ) = " AND" ) .OR. ;
         ( Upper( Right( cSqlWhere, 3 ) ) = " OR"  )

         cSqlWhere += " (" + AllTrim( cReturn ) + ")"

      ELSE

         cSqlWhere += " AND (" + AllTrim( cReturn ) + ")"

      ENDIF

   ELSE

      cSqlWhere += cReturn

   ENDIF

RETURN( cReturn )



PROCEDURE sqlGroup( cGroup )

   cSqlGroup := cGroup

RETURN( NIL )



PROCEDURE sqlOrder( cOrder )

   IF cSqlFromAs <> NIL .AND. Left( cOrder, 3 ) = sisFlgModule()
      cSqlOrder := cSqlFromAs + "." + cOrder
   ELSE
      cSqlOrder := cOrder
   ENDIF

RETURN( NIL )



FUNCTION sqlSelect()

   LOCAL cSql, nCount

   cSql := "SELECT "

   IF Len( aSqlFields ) = 0
      cSql += "*"
   ELSE
      FOR nCount := 1 TO Len( aSqlFields )
        cSql += aSqlFields[ nCount, 1 ]
        IF ! Empty( aSqlFields[ nCount, 2 ] )
           cSql += " AS " + aSqlFields[ nCount, 2 ]
        ENDIF
        cSql += ", "
      NEXT
      cSql := Left( cSql, Len( cSql ) -2 )
   ENDIF

   cSql += " FROM " + cSqlFrom

   IF cSqlFromAs <> NIL
      cSql += " " + cSqlFromAs
   ENDIF

   FOR nCount := 1 TO Len( aSqlJoin )
      cSql += " LEFT OUTER JOIN " + aSqlJoin[ nCount ]
   NEXT

   IF cSqlWhere <> NIL
      cSql += " WHERE " + cSqlWhere
   ENDIF

   IF cSqlGroup <> NIL
      cSql += " GROUP BY " + cSqlGroup
   ENDIF

   IF cSqlOrder <> NIL
      cSql += " ORDER BY " + cSqlOrder
   ENDIF

RETURN( cSql )



FUNCTION sqlCast( cField, cType, nLen, nDec )

   LOCAL cReturn

   vDef( @nLen, 1 )
   vDef( @nDec, 0 )

   cReturn := "cast( " + cField + " as "

   IF cType = "C"
      cReturn += "character varying(" + NumToStr( nLen ) + ")"
   ELSEIF cType = "N"
      cReturn += "numeric(" + NumToStr( nLen ) + "," + NumToStr( nDec ) + ")"
   ENDIF

   cReturn += " )"

RETURN( cReturn )



FUNCTION sqlDelete( cAlias, uWhere, uConn )

   #define D_FIELD 1   // Campo
   #define D_COMP  2   // Comparacao

   LOCAL cWhere := ""

   LOCAL nCount, cSql, cInfo, cComp, cField, lReturn, cExp, aRec, nRec

   IF Len( cAlias ) = 3
      cAlias := "MX" + cAlias + sisFlgModule()
   ENDIF

   cSql := "DELETE FROM " + cAlias + " WHERE "

   IF ValType( uWhere ) = "C"

      cWhere := uWhere

   ELSE

      FOR nCount := 1 TO Len( uWhere )

         cField := uWhere[ nCount, D_FIELD ]
         IF Len( cField ) = 3
            cField := sisFlgModule() + cField + Subs( cAlias, 3, 3 )
         ENDIF

         cInfo := uWhere[ nCount, D_COMP ]
         cComp := sqlCompFormat( cInfo, NIL, NIL, NIL, .F. )
         cExp  := cField + " = " + cComp

         cWhere += cExp

         IF nCount < Len( uWhere )
            cWhere += " AND "
         ENDIF

      NEXT

   ENDIF

   cSql += cWhere

   IF sndActive() .AND. sndIsProcess( cAlias )
      aRec := sqlGetRecords( cAlias, cWhere )
      FOR nRec := 1 TO Len( aRec )
         ( cAlias )->( mxGoTo( aRec[ nRec, 1 ] ) )
         ( cAlias )->( sndDelete() )
      NEXT
   ENDIF

   lReturn := sqlExecute( cSql, NIL, .F., uConn, NIL, .T. )

RETURN( lReturn )



FUNCTION sqlDelDuplicate( cAlias, aFields, uConn )

   LOCAL lReturn, nField

   LOCAL cSql := "DELETE FROM " + cAlias + " A " + ;
                 "WHERE ( SELECT B.SR_RECNO FROM " + cAlias + " B WHERE "

   FOR nField := 1 TO Len( aFields )
      cSql += "A." + aFields[ nField ] + "=B." + aFields[ nField ] + " AND "
   NEXT

   cSql += "A.SR_RECNO > B.SR_RECNO LIMIT 1 ) IS NOT NULL"

   lReturn := sqlExecute( cSql, NIL, .F., uConn )

RETURN( lReturn )



FUNCTION sqlCompFormat( cComp, lTrim, lDateNull, lRecursive, lUseTrim )

   LOCAL nCount, cResult

   IF lRecursive = NIL
      lTrim := .F.
   ENDIF

   vDef( @lDateNull, .F. )
   vDef( @lUseTrim , .T. )

   DO CASE
      CASE ValType( cComp ) = "A"
           cResult := "( "
           FOR nCount := 1 TO Len( cComp )
              cResult += sqlCompFormat( cComp[ nCount ], @lTrim, lDateNull, .T., lUseTrim )
              IF nCount < Len( cComp )
                 cResult += ","
              ENDIF
           NEXT
           cResult += " )"
      CASE ValType( cComp ) = "N" ; cResult := NumToStr( cComp )
      CASE ValType( cComp ) = "D" ; cResult := If( lDateNull .AND. Empty( cComp ), "null", "'" + fDate( cComp, "AAAA-MM-DD" ) + "'" )
      OTHERWISE
           IF lUseTrim
              cResult := "Trim( '" + StrTran( cComp, "'", "''" ) + "' )" ; lTrim := .T.
           ELSE
              cResult := "'" + StrTran( Trim( cComp ), "'", "''" ) + "'" ; lTrim := .F.
           ENDIF
   ENDCASE

RETURN( cResult )



FUNCTION sqlBasicConn( aConn, cIni, lLog )

   LOCAL lReturn := .F.

   LOCAL nConn, cConn, cConnDef, cIP, cDtb, aSchema, cAux

   // **** ATENCAO ***
   // Definir sempre o primeiro em aConn como a conexao principal.

   vDef( @aConn,{ "LOJA" } )
   vDef( @cIni , "MXCFGCFI.INI" )
   vDef( @lLog , .F. )

   IF ValType( aConn ) = "C"
      aConn := { aConn }
   ENDIF

   BEGIN SEQUENCE

      IF ! HB_IniLoad( cIni )
         MsgDlg( "Arquivo ^" + cIni + "^ n„o localizado !" )
         BREAK
      ENDIF

      // Definicoes do banco de dados

      dbActive( HB_IniGetVar( "LocalDados", "Tipo", "DBF" ) )

      sqlActive( dbActive() <> "DBF" )

      IF ! sqlActive()
         BREAK
      ENDIF

      mxRdd( "SQLRDD" )
      
      sqlDefaultRDD()

      dbKeyControl(.F.)

      FOR nConn := 1 TO Len( aConn )

         cConn := aConn[ nConn ]

         IF At( "\", cConn ) = 0
            cConnDef := cConn
         ELSE
            cConnDef := Left( cConn, At( "\", cConn ) -1 )
         ENDIF

         cIP  := sqlGetInfo( HB_IniGetVar( "LocalDados", cConnDef ), "IP"  )
         cDtb := sqlGetInfo( HB_IniGetVar( "LocalDados", cConnDef ), "DTB" )

         IF Empty( cDtb )

            IF cConn = aConn[ 1 ]

               MsgDlg( "Problemas na conex„o com o banco de dados !;;" + ;
                       "^[LocalDados][" + cConn + "]^ n„o configurado.;;" + ;
                       "Verifique o arquivo ^" + cIni + "^" )
               Fim( 0 )

            ENDIF

            LOOP

         ENDIF

         IF At( "|", cDtb ) > 0
            cDtb := Left( cDtb, At( "|", cDtb ) -1 )
         ENDIF

         aSchema := NIL

         IF At( "\", cConn ) > 0

            vDef( @aSchema, {} )

            cConn := Subs( cConn, At( "\", cConn ) +1 ) + "|"

            DO WHILE ! Empty( cConn )
               IF aConn[ 1 ] = "LOJA"
                  aAdd( aSchema, "CS_" + Left( cConn, At( "|", cConn ) -1 ) )
               ELSE
                  aAdd( aSchema, Left( cConn, At( "|", cConn ) -1 ) )
               ENDIF
               cConn := Subs( cConn, At( "|", cConn ) +1 )
            ENDDO

         ENDIF

         IF aConn[ 1 ] = "LOJA"
            cAux := "CS_" + cConnDef
         ELSE
            cAux := cConnDef
         ENDIF

         IF ! sqlAddConn( cIP, cDtb, aSchema, cAux )
            sqlDisconnect()
            BREAK
         ENDIF

      NEXT

      // Define o database principal como ativo
      IF aConn[ 1 ] = "LOJA"
         sqlSetConn( "CS_" + aConn[ 1 ] )
      ELSE
         sqlSetConn( aConn[ 1 ] )
      ENDIF

      IF lLog
         SR_StartLog()
      ENDIF

      lReturn := .T.

   ENDSEQUENCE

RETURN( lReturn )



FUNCTION sqlFieldsStart( cOper )

   cSqlFields := ""
   cSqlValues := ""
   cSqlWrite  := ""
   cSqlOper   := cOper

RETURN( NIL )



FUNCTION sqlFReplace( cField, uValue, nLen, lFormatChars )

   vDef( @lFormatChars, .T. )

   IF ( ValType( uValue ) = "C" ) .AND. lFormatChars
      uValue := StrTran( uValue, Chr(39) , Chr(34) )
      uValue := StrTran( uValue, Chr(144), "E"     )
      IF nLen <> NIL
         uValue := Left( uValue, nLen )
      ENDIF
   ENDIF

   IF cSqlOper = "U"
      IF ! Empty( cSqlWrite )
         cSqlWrite += ", "
      ENDIF
      cSqlWrite += cField + " = " + sqlCompFormat( uValue, NIL, .T., NIL, .F. )
   ELSE
      IF ! Empty( cSqlFields )
         cSqlFields += ", "
         cSqlValues += ", "
      ENDIF
      cSqlFields += cField
      cSqlValues += sqlCompFormat( uValue, NIL, .T., NIL, .F. )
      cSqlWrite  := "( " + cSqlFields + " ) VALUES ( " + cSqlValues + " )"
   ENDIF

RETURN( NIL )



FUNCTION sqlExeWrite( cBD, cTable, cWhere, lTrans )

   LOCAL lReturn := .T.

   vDef( @lTrans, .T. )
   
   IF ! Empty( If( cWhere = NIL, cSqlFields, cSqlWrite ) )

      sqlDefWrite( cTable, cWhere )

      lReturn := sqlExecute( sqlGetWriteCommand(), NIL, lTrans, cBD, NIL, .T. )
      
   ENDIF

RETURN( lReturn )



FUNCTION sqlDefWrite( cTable, cWhere )

   IF cSqlOper = "U"
      cSqlWrite := "UPDATE " + cTable + " SET " + cSqlWrite
      IF cWhere <> NIL .AND. ! Empty( cWhere )
         cSqlWrite += " WHERE " + cWhere
      ENDIF
   ELSE
      cSqlWrite := "INSERT INTO " + cTable + " " + cSqlWrite
   ENDIF

RETURN( cSqlWrite )



FUNCTION sqlGetWriteCommand()

RETURN( cSqlWrite )



FUNCTION sqlGetTableStr( aStr, cTable, cDB, lSqlMode )

   LOCAL lReturn := .F.
   LOCAL cTemp   := ""

   LOCAL cAlias, cSql, aAux, nCount, nLen, nDec, nPos

   vDef( @lSqlMode, .T. )

   aStr := {}

   BEGIN SEQUENCE

      IF lSqlMode

         DO WHILE .T.
            cTemp := "STR" + Num_TempFile() + ".DBF"
            IF ! File( cTemp )
               EXIT
            ENDIF
         ENDDO

         cAlias := StrTran( cTemp, ".DBF", "" )

         cSql := "SELECT * FROM " + cTable + " WHERE sr_recno < 0"

         IF ! sqlExecute( cSql, cTemp, .F., cDB, NIL, .T., .F. )
            BREAK
         ENDIF

         aAux := ( cAlias )->( xDbStruct() )

         mxClose( cAlias )
         mxFDel( cTemp )

         aEval( aAux, { |x| aAddC( aStr,  x, x[1] <> "SR_RECNO" ) } )

      ELSE

         cAlias := GetNoEmpty( sqlGetInfo( cTable, "SCHEMA" ), "PUBLIC" )
         cTable := sqlGetInfo( cTable, "FILE" )

         cSql := "SELECT "
         cSql += "  f.attname AS DBS_NAME, "
         cSql += "  pg_catalog.format_type(f.atttypid,f.atttypmod) AS DBS_TYPE "
         cSql += "FROM pg_attribute f "
         cSql += "JOIN pg_class c ON c.oid = f.attrelid "
         cSql += "JOIN pg_type t ON t.oid = f.atttypid "
         cSql += "LEFT JOIN pg_attrdef d ON d.adrelid = c.oid AND d.adnum = f.attnum "
         cSql += "LEFT JOIN pg_namespace n ON n.oid = c.relnamespace "
         cSql += "LEFT JOIN pg_constraint p ON p.conrelid = c.oid AND f.attnum = ANY (p.conkey) "
         cSql += "LEFT JOIN pg_class AS g ON p.confrelid = g.oid "
         cSql += "WHERE c.relkind = 'r'::char "
         cSql += "  AND n.nspname = " + QuotedStr( Lower( cAlias ) )  // SCHEMA
         cSql += "  AND c.relname = " + QuotedStr( Lower( cTable ) )
         cSql += "  AND f.attnum > 0 "
         cSql += "  AND f.attname <> 'sr_recno'"

         aAux := {}

         IF ! sqlExecute( cSql, aAux, .F., cDB, NIL, .T., .F. )
            BREAK
         ENDIF

         FOR nCount := 1 TO Len( aAux )

            nLen := 0
            nDec := 0

            IF Upper( Left( aAux[ nCount, 2 ], 1 ) ) = "D"
               nLen := 8
            ELSE
               nPos := At( "(", aAux[ nCount, 2 ] )
               IF nPos > 0
                  IF At( ",", aAux[ nCount, 2 ] ) > nPos
                     nLen := Val( Subs( aAux[ nCount, 2 ], nPos +1, At( ",", aAux[ nCount, 2 ] ) - nPos -1 ) )
                     nPos := At( ",", aAux[ nCount, 2 ] )
                     nDec := Val( Subs( aAux[ nCount, 2 ], nPos +1, At( ")", aAux[ nCount, 2 ] ) - nPos -1 ) )
                  ELSE
                     nLen := Val( Subs( aAux[ nCount, 2 ], nPos +1, At( ")", aAux[ nCount, 2 ] ) - nPos -1 ) )
                  ENDIF
               ENDIF
            ENDIF

            aAdd( aStr, { Upper( aAux[ nCount, 1 ] ),;
                          Upper( Left( aAux[ nCount, 2 ], 1 ) ),;
                          nLen,;
                          nDec,;
                          0 } )

         NEXT

      ENDIF

      IF Len( aStr ) = 0
         MsgDlg( "N„o foi poss¡vel definir a estrutura de " + cTable )
         BREAK
      ENDIF

      lReturn := .T.

   ENDSEQUENCE

RETURN( lReturn )



FUNCTION sqlGetIndexStr( aStr, cTable, cDB, lID_Index )

   LOCAL lReturn := .F.

   LOCAL cShema, cSql
   
   vDef( @lID_Index, .T. )

   aStr := {}

   BEGIN SEQUENCE

      cShema := GetNoEmpty( sqlGetInfo( cTable, "SCHEMA" ), "PUBLIC" )
      cTable := sqlGetInfo( cTable, "FILE" )

      cSql := "SELECT "
      cSql += "  index_name, "
      cSql += "  array_to_string( array_agg(column_name), ',' ) "
      cSql += "FROM "
      cSql += "  ( "
      cSql += "  SELECT "
      cSql += "    t.relname AS table_name, "
      cSql += "    i.relname AS index_name, "
      cSql += "    a.attname AS column_name, "
      cSql += "    unnest(ix.indkey) AS unn, "
      cSql += "    a.attnum "
      cSql += "  FROM "
      cSql += "    pg_class t, "
      cSql += "    pg_class i, "
      cSql += "    pg_index ix, "
      cSql += "    pg_attribute a, "
      cSql += "    pg_namespace n "
      cSql += "  WHERE "
      cSql += "    t.oid = ix.indrelid "
      cSql += "    AND n.oid = t.relnamespace "
      cSql += "    AND i.oid = ix.indexrelid "
      cSql += "    AND a.attrelid = t.oid "
      cSql += "    AND a.attnum = ANY(ix.indkey) "
      cSql += "    AND a.attname <> 'sr_recno' "
      cSql += "    AND t.relkind = 'r' "
      cSql += "    AND n.nspname = " + QuotedStr( Lower( cShema ) )
      cSql += "    AND t.relname = " + QuotedStr( Lower( cTable ) )
      cSql += "  ORDER BY "
      cSql += "    t.relname, "
      cSql += "    i.relname, "
      cSql += "    generate_subscripts(ix.indkey,1) "
      cSql += ") sb "
      cSql += "WHERE unn = attnum "
      
      IF ! lID_Index
         cSql += "    AND NOT index_name LIKE '%cfi_id%' "
      ENDIF
      
      cSql += "GROUP BY table_name, index_name"

      IF ! sqlExecute( cSql, aStr, .F., cDB, NIL, .T., .F. )
         BREAK
      ENDIF

      lReturn := .T.

   ENDSEQUENCE

RETURN( lReturn )



FUNCTION sqlDefPort( nPort )

   LOCAL nReturn := nDefPort

   IF nPort <> NIL
      nDefPort := nPort
   ENDIF

RETURN( nReturn )



FUNCTION sqlDefUser( cUser )

   LOCAL cReturn := cDefUser

   IF cUser <> NIL
      cDefUser := cUser
   ENDIF

RETURN( cReturn )



FUNCTION sqlDefPass( cPass )

   // Define/retorna a senha p/ conexao ao banco de dados.

   LOCAL cReturn := cDefPass

   IF cPass <> NIL
      cDefPass := cPass
   ENDIF

RETURN( cReturn )



FUNCTION sqlDbChangePass( cPass, lQuit )

   LOCAL lReturn := .F.
   LOCAL cMsg

   vDef( @lQuit, .T. )

   BEGIN SEQUENCE

      IF ! sqlExecute( "ALTER USER postgres WITH PASSWORD " + QuotedStr( cPass ) )
         cMsg := "Problemas na execu‡„o do comando;para altera‡„o da senha.;;" + sqlLastError()
         BREAK
      ENDIF

      sqlDefPass( cPass )

      lReturn := .T.

   ENDSEQUENCE

   IF cMsg <> NIL
      MsgDlg( cMsg + ";;O sistema ser  finalizado." )
      IF lQuit
         Fim( 0 )
      ENDIF
   ENDIF

RETURN( lReturn )



FUNCTION sqlDefCommit( nCommit )

   LOCAL nReturn := nSqlCommit

   IF nCommit <> NIL
      nSqlCommit := nCommit
   ENDIF

RETURN( nReturn )



FUNCTION sqlRecCount( cWhere, cFrom, uConn )

   LOCAL nRecCount := 0
   LOCAL aResult   := {}
   LOCAL cSql

   IF cFrom = NIL
      cFrom := Alias()
   ENDIF

   cSql := "SELECT COUNT(1) AS NRECCOUNT FROM " + cFrom

   IF cWhere <> NIL .AND. ! Empty( cWhere )
      cSql += " WHERE " + cWhere
   ENDIF

   IF sqlExecute( cSql, @aResult, .F., uConn, NIL, .T. ) .AND. Len( aResult ) > 0
      nRecCount := aResult[ 1, 1 ]
   ENDIF

RETURN( nRecCount )



FUNCTION sqlSum( cField, cFrom, cWhere, uConn )

   LOCAL nTotal  := 0
   LOCAL aResult := {}
   LOCAL cSql

   IF cFrom = NIL
      cFrom := Alias()
   ENDIF

   cSql := "SELECT SUM(" + cField + ") AS TOTAL FROM " + cFrom

   IF cWhere <> NIL .AND. ! Empty( cWhere )
      cSql += " WHERE " + cWhere
   ENDIF

   IF sqlExecute( cSql, @aResult, .F., uConn, NIL, .T. ) .AND. Len( aResult ) > 0
      nTotal := aResult[ 1, 1 ]
   ENDIF

RETURN( nTotal )



FUNCTION sqlMax( cField, cFrom, cWhere, uConn )

   LOCAL nMax    := 0
   LOCAL aResult := {}
   LOCAL cSql

   IF cFrom = NIL
      cFrom := Alias()
   ENDIF

   cSql := "SELECT MAX(" + cField + ") AS TOTAL FROM " + cFrom

   IF cWhere <> NIL .AND. ! Empty( cWhere )
      cSql += " WHERE " + cWhere
   ENDIF

   IF sqlExecute( cSql, @aResult, .F., uConn, NIL, .T. ) .AND. Len( aResult ) > 0
      nMax := aResult[ 1, 1 ]
   ENDIF

RETURN( nMax )



FUNCTION sqlSeek( cFrom, cWhere, uConn )

   LOCAL lReturn := .F.
   LOCAL aResult := {}

   IF At( "ORDER BY", cWhere ) = 0
      cWhere += " ORDER BY SR_RECNO"
   ENDIF

   IF sqlExecute( "SELECT SR_RECNO FROM " + cFrom + " WHERE " + cWhere + " LIMIT 1", @aResult, .F., uConn, NIL, .T. ) .AND. Len( aResult ) > 0
      IF dbIsOpen( cFrom )
         ( cFrom )->( mxGoTo( aResult[ 1, 1 ] ) )
      ENDIF
      lReturn := .T.
   ENDIF

RETURN( lReturn )



FUNCTION sqlGetRecords( cAlias, cWhere, cOrder, cConn, cFields, nLimit )

   LOCAL aRec := {}
   LOCAL nRec, cSql, cMsg

   cFields := "SR_RECNO" + If( cFields = NIL, "", ", " + cFields )

   IF Len( cAlias ) = 3
      cAlias := "MX" + cAlias + "CFI"
   ENDIF
   cSql := "SELECT " + cFields + " FROM " + cAlias

   IF cWhere <> NIL .AND. ! Empty( cWhere )
      cSql += " WHERE " + cWhere
   ENDIF

   IF cOrder <> NIL
      cSql += " ORDER BY " + cOrder
   ENDIF
   
   IF nLimit <> NIL
      cSql += " LIMIT " + NumToStr( nLimit )
   ENDIF

   IF ! sqlExecute( cSql, @aRec, .F., cConn, NIL, .T. )
      IF IsProcedure( "LOJA" )
         Fim(0)
      ENDIF
      aRec := {}
   ENDIF

RETURN( aClone( aRec ) )



FUNCTION sqlStrWhere( cWhere, cAddWhere )

   vDef( @cWhere, "" )

   IF cAddWhere <> NIL .AND. ! Empty( cAddWhere )

      IF ! Empty( cWhere )
         cWhere += " AND "
      ENDIF

      cWhere += "(" + cAddWhere + ")"

   ENDIF

RETURN( cWhere )



FUNCTION sqlCopyFromTable( aSource, aTarget, uFields, cTitle, lDelete, cColor )

   LOCAL lReturn    := .F.
   LOCAL nDefOffSet := 500
   LOCAL aPos       := {}

   LOCAL cSql, aResult, nOffSet, cExeSql, nRecCount
   LOCAL nField, cFields, cDir

   vDef( @lDelete, .F. )

   ScreenSave()

   BEGIN SEQUENCE

      IF lDelete

         cSql := "DELETE FROM " + aTarget[ SQLC_TAB ]

         IF Len( aTarget ) >= SQLC_WHERE
            cSql += " WHERE " + aTarget[ SQLC_WHERE ]
         ENDIF

         Status( "Eliminandos dados anteriores da tabela " + aTarget[ SQLC_TAB ] + "..." )

         IF ! sqlExecute( cSql, NIL, .F., aTarget[ SQLC_CONN ], NIL, .T., .F. )
            BREAK
         ENDIF

         Status( "" )

      ENDIF

      IF ValType( uFields ) = "C"
         cFields := uFields
      ELSE
         cFields := ""
         FOR nField := 1 TO Len( uFields )
            cFields += uFields[ nField ]
            IF nField < Len( uFields )
               cFields += ","
            ENDIF
         NEXT
      ENDIF

      IF IsUseExt( aSource[ SQLC_TAB ] )

         cDir := ""

         IF aSource[ SQLC_CONN ] <> NIL
            cDir := ConfPath( aSource[ SQLC_CONN ] )
         ENDIF

         IF ! mxOpen( 0, cDir + aSource[ SQLC_TAB ], "TABAUX", "DBFCDX", .F. )
            BREAK
         ENDIF

         FOR nField := 1 TO Len( uFields )
            aAdd( aPos, TABAUX->( FieldPos( uFields[ nField ] ) ) )
         NEXT

         TABAUX->( prgsStart( cTitle, NIL, 2, cColor ) )

         DO WHILE TABAUX->( !Eof() )

            aResult := {}
            nOffSet := 0

            DO WHILE TABAUX->( !Eof() )

               prgsNext( NIL, NIL, cColor )

               aAdd( aResult, {} )

               FOR nField := 1 TO Len( uFields )
                  aAdd( aResult[ Len( aResult ) ], TABAUX->( FieldGet( aPos[ nField ] ) ) )
               NEXT

               TABAUX->( dbSkip() )

               nOffSet ++

               IF TABAUX->( Eof() ) .OR. nOffSet = nDefOffSet
                  EXIT
               ENDIF

            ENDDO

            IF ! sqlAuxCopyFromTable( aTarget, aResult, cFields )
               BREAK
            ENDIF

         ENDDO

         mxClose( "TABAUX" )

      ELSE

         nRecCount := sqlRecCount( If( Len( aSource ) >= SQLC_WHERE, aSource[ SQLC_WHERE ], NIL ), aSource[ SQLC_TAB ], aSource[ SQLC_CONN ] )

         nOffSet := 0

         cSql := "SELECT " + cFields + " "
         cSql += "FROM " + aSource[ SQLC_TAB ] + " "

         IF Len( aSource ) >= SQLC_WHERE
            cSql += "WHERE " + aSource[ SQLC_WHERE ] + " "
         ENDIF

         cSql += "ORDER BY SR_RECNO LIMIT " + NumToStr( nDefOffSet )

         prgsStart( cTitle, nRecCount, 2, cColor )

         DO WHILE .T.

            aResult := {}
            cExeSql := cSql + " OFFSET " + NumToStr( nOffSet )

            IF ! sqlExecute( cExeSql, @aResult, .F., aSource[ SQLC_CONN ], NIL, .T., .F. )
               BREAK
            ENDIF

            IF Len( aResult ) = 0
               EXIT
            ENDIF

            IF ! sqlAuxCopyFromTable( aTarget, aResult, cFields )
               BREAK
            ENDIF

            nOffSet += Len( aResult )

            prgsNext( nOffSet, NIL, cColor )

         ENDDO

      ENDIF

      lReturn := .T.

   ENDSEQUENCE

   ScreenRest()

RETURN( lReturn )



STATIC FUNCTION sqlAuxCopyFromTable( aTarget, aResult, cFields )

   LOCAL lReturn := .F.
   LOCAL cSqlInsert, nCount, nField, uReplace

   BEGIN SEQUENCE

      cSqlInsert := "INSERT INTO " + aTarget[ SQLC_TAB ] + " (" + cFields + ") VALUES "

      FOR nCount := 1 TO Len( aResult )

         cSqlInsert += "("

         FOR nField := 1 TO Len( aResult[ nCount ] )

            uReplace := aResult[ nCount, nField ]

            IF ValType( uReplace ) = "C"
               uReplace := QuotedStr( strReplace( uReplace, { "'", "\" }, { "''", "\\" } ), .T. )
            ELSE
               uReplace := sqlCompFormat( uReplace, NIL, .T., NIL, .F. )
            ENDIF

            cSqlInsert += uReplace
            IF nField < Len( aResult[ nCount ] )
               cSqlInsert += ","
            ENDIF

         NEXT

         cSqlInsert += ")"

         IF nCount < Len( aResult )
            cSqlInsert += ","
         ENDIF

      NEXT

      IF ! sqlExecute( cSqlInsert, NIL, .F., aTarget[ SQLC_CONN ], NIL, .T., .F. )
         BREAK
      ENDIF

      lReturn := .T.

   ENDSEQUENCE

RETURN( lReturn )



FUNCTION sqlGetFields( cNoGet )

   LOCAL cFields := ""
   LOCAL nFCount := fCount()
   LOCAL nField

   FOR nField := 1 TO nFCount
      IF cNoGet <> NIL .AND. foundStr( Upper( Field( nField ) ), cNoGet )
         LOOP
      ENDIF
      cFields += Field( nField )
      IF nField < nFCount
         cFields += ","
      ENDIF
   NEXT

RETURN( cFields )



FUNCTION sqlGetPageCode( cDtb )

   LOCAL cReturn := "WIN1252"
   LOCAL aResult := {}
   LOCAL cSql    := "SELECT pg_encoding_to_char(encoding) FROM pg_database WHERE datname = " + QuotedStr( cDtb )

   IF sqlExecute( cSql, @aResult, .F., "postgres", NIL, .F., .F. ) .AND. Len( aResult ) > 0
      cReturn := Trim( aResult[ 1, 1 ] )
   ENDIF

RETURN( cReturn )




FUNCTION sqlUpdIndexKey( cTable, cField, cUpdate, uConn )

   LOCAL aIndexs       := {}
   LOCAL cFieldsUpdate := ""
   LOCAL cSql, nIndex, aKey, nKey, nAux, cPartialKey, lDescend

   IF uConn = NIL
      uConn := sqlGetConn( "CONN" )
   ENDIF

   cSql := "SELECT UPPER( IDXKEY_ ), IDXCOL_ FROM SR_MGMNTINDEXES WHERE TABLE_ = " + QuotedStr( cTable ) + " AND IDXCOL_ <> '' AND IDXKEY_ LIKE " + QuotedStr( "%" + cField + "%" ) + " ORDER BY IDXCOL_"

   IF sqlExecute( cSql, @aIndexs, .F., uConn )

      FOR nIndex := 1 TO Len( aIndexs )

         //TO_CHAR(current_date, 'YYYYMMDD' )      // DTOS
         //SUBSTR( TO_CHAR(1234, '9999' ), 2, 4 )  // STR
         //MXDESCED( 'ABC' )                       // DESCEND
         //UPPER( 'abc' )                          // UPPER

         // Primeiro separa-se os campos

         aKey := {}
         cKey := aIndexs[ nIndex, 1 ]

         DO WHILE Len( cKey ) > 0

            nAux := At( "+", cKey )
            IF nAux = 0
               aAdd( aKey, cKey )
               cKey := ""
            ELSE
               aAdd( aKey, Left( cKey, nAux -1 ) )
               cKey := Subs( cKey, nAux + 1 )
            ENDIF

         ENDDO

         cKey := ""

         FOR nKey := 1 TO Len( aKey )

            cPartialKey := aKey[ nKey ]

            lDescend := sqlClearFunc( @cPartialKey, "MXDESCEND" )

            DO CASE
               CASE sqlClearFunc( @cPartialKey, "DTOS" )       ; cPartialKey := "TO_CHAR( " + cPartialKey + ", 'YYYYMMDD' )"
               CASE sqlClearFunc( @cPartialKey, "UPPER" )      ; cPartialKey := "UPPER( " + cPartialKey + " )"
               CASE sqlClearFunc( @cPartialKey, "STR", @nAux ) ; cPartialKey := "SUBSTR( TO_CHAR( " + cPartialKey + ", " + QuotedStr( Repl( "9", nAux ) ) + " ), 2, " + NumToStr( nAux ) + " )"
            ENDCASE

            IF lDescend
               cPartialKey := "MXDESCEND( " + cPartialKey + " )"
            ENDIF

            IF ! Empty( cKey )
               cKey += "||"
            ENDIF

            cKey += StrTran( cPartialKey, cField, cUpdate )

         NEXT

         cKey += "||SUBSTR( TO_CHAR( SR_RECNO, '999999999999999' ), 2, 15 )"

         IF ! Empty( cFieldsUpdate )
            cFieldsUpdate += ", "
         ENDIF

         cFieldsUpdate += "INDKEY_" + aIndexs[ nIndex, 2 ] + " = " + cKey

      NEXT

   ENDIF

RETURN( cFieldsUpdate )



STATIC FUNCTION sqlClearFunc( cField, cFunc, nLen )

   LOCAL lClear := .F.

   cField := AllTrim( cField )
   IF Left( cField, Len( cFunc ) + 1 ) = cFunc + "("
      cField := Subs( cField, Len( cFunc ) + 2 )
      cField := Left( cField, Len( cField ) -1 )
      IF cFunc = "STR"
         nLen   := Val( AllTrim( Subs( cField, At( ",", cField ) + 1 ) ) )
         cField := Left( cField, At( ",", cField ) -1 )
      ENDIF
      lClear := .T.
   ENDIF

RETURN( lClear )



FUNCTION sqlSelectOffSet( bExecute, cProgress, cFrom, cWhere, uConn, SQL_OFFSET, cFields )

   LOCAL lReturn    := .F.
   LOCAL cTela      := SaveScreen()
   LOCAL nCursor    := SetCursor(0)
   LOCAL aResult    := {}
   LOCAL nOffSet    := 0
   LOCAL nTotal     := 0

   LOCAL cSql, nRecCount, cSqlAux, nRecord

   vDef( @SQL_OFFSET, 500 )

   BEGIN SEQUENCE

      // Define o total de registros

      cSql := "SELECT COUNT(1) AS RECORDCOUNT FROM " + cFrom

      IF ! Empty( cWhere )
         cSql += " WHERE " + cWhere
      ENDIF

      IF ! sqlExecute( cSql, @aResult, .F., uConn, NIL, .T., .F. )
         BREAK
      ENDIF

      IF Len( aResult ) = 0
         MsgDlg( "N„o foi poss¡vel definir o total de registros !" )
         BREAK
      ENDIF

      nRecCount := aResult[ 1, 1 ]

      IF nRecCount = 0
         lReturn := .T.
         BREAK
      ENDIF

      IF cFields = NIL
         cSql := "SELECT SR_RECNO FROM " + cFrom
      ELSE
         cSql := "SELECT " + cFields + " FROM " + cFrom
      ENDIF

      IF ! Empty( cWhere )
         cSql += " WHERE " + cWhere
      ENDIF

      cSql += " ORDER BY SR_RECNO LIMIT " + NumToStr( SQL_OFFSET )

      Status( "" )

      prgsStart( cProgress, nRecCount, 2 )

      DO WHILE .T.

         cSqlAux := cSql + " OFFSET " + NumToStr( nOffSet )
         aResult := {}

         IF ! sqlExecute( cSqlAux, @aResult, .F., uConn, NIL, .T., .F. )
            BREAK
         ENDIF

         IF Len( aResult ) = 0
            EXIT
         ENDIF

         FOR nRecord := 1 TO Len( aResult )

            prgsNext()

            IF cFields = NIL
               ( cFrom )->( mxGoTo( aResult[ nRecord, 1 ] ) )
               Eval( bExecute )
            ELSE
               Eval( bExecute, aResult[ nRecord ] )
            ENDIF


         NEXT

         nTotal += Len( aResult )

         IF nTotal >= nRecCount
            EXIT
         ENDIF

         nOffSet += SQL_OFFSET

      ENDDO

      lReturn := .T.

   ENDSEQUENCE

   RestScreen( ,,,, cTela )
   SetCursor( nCursor )

RETURN( lReturn )



FUNCTION sqlGetFieldValue( cField, uDefault, cFrom, cWhere, uConn )

   LOCAL lReturn := .F.
   LOCAL aResult := {}
   LOCAL uReturn := uDefault

   IF sqlExecute( "SELECT " + cField + " FROM " + cFrom + " WHERE " + cWhere + " LIMIT 1", @aResult, .F., uConn, NIL, .T. ) .AND. Len( aResult ) > 0
      uReturn := aResult[ 1, 1 ]
   ENDIF

RETURN( uReturn )



STATIC PROCEDURE sqlField_Parameters( cTable, cField, cDataBase, cSchema, cWhere )

   sqlDB_Parameters( @cDataBase, @cSchema )

   cWhere := "table_catalog = lower( " + QuotedStr( cDataBase ) + " ) and " + ;
             "table_schema  = lower( " + QuotedStr( cSchema   ) + " ) and " + ;
             "table_name    = lower( " + QuotedStr( cTable    ) + " ) and " + ;
             "column_name   = lower( " + QuotedStr( cField )    + " )"

RETURN



STATIC PROCEDURE sqlDB_Parameters( cDataBase, cSchema )

   IF cDataBase = NIL
      cDataBase := sqlGetConn( "DTB" )
   ENDIF

   IF cSchema = NIL
      cSchema := sqlGetConn( "SCHEMA" )
   ENDIF

RETURN



FUNCTION sqlFieldExist( cTable, cField, cDataBase, cSchema )

   LOCAL cWhere
   
   sqlField_Parameters( cTable, cField, @cDataBase, @cSchema, @cWhere )

RETURN( sqlRecCount( cWhere, "information_schema.columns" ) > 0 )



FUNCTION sqlFieldType( cTable, cField, cDataBase, cSchema )

   LOCAL aReturn := {}
   LOCAL cReturn := ""
   LOCAL cWhere, cSql
   
   sqlField_Parameters( cTable, cField, @cDataBase, @cSchema, @cWhere )

   cSql := "SELECT CAST( data_type AS  character(20) ) as data_type FROM information_schema.columns WHERE " + cWhere + " LIMIT 1"
             
   IF sqlExecute( cSql, @aReturn, .F. ) .AND. Len( aReturn ) <> 0
      cReturn := AllTrim( aReturn[ 1, 1 ] )
      DO CASE
         CASE cReturn = "bytea"             ; cReturn := "B"
         CASE cReturn = "text"              ; cReturn := "M"
         CASE cReturn = "character varying" ; cReturn := "C"
         CASE cReturn = "character"         ; cReturn := "C"
         CASE cReturn = "date"              ; cReturn := "D"
         CASE cReturn = "integer"           ; cReturn := "N"
         CASE cReturn = "numeric"           ; cReturn := "N"
      ENDCASE
   ENDIF

RETURN( cReturn )



FUNCTION sqlIndexExist( cTable, cIndex, cSchema )

   LOCAL cSql, cWhere

   sqlDB_Parameters( "", @cSchema )

   cWhere := "Lower( schemaname ) = " + QuotedStr( Lower( cSchema ) ) + " AND " + ;
             "Lower( tablename )  = " + QuotedStr( Lower( cTable  ) ) + " AND " + ;
             "Lower( indexname )  = " + QuotedStr( Lower( cIndex  ) )

RETURN( sqlRecCount( cWhere, "pg_indexes" ) > 0 )



FUNCTION sqlUserExist( cUser, cConn )

   LOCAL cSql    := "SELECT rolname FROM pg_roles where rolname = " + QuotedStr( cUser )
   LOCAL aSelect := {}

   IF ! sqlExecute( cSql, @aSelect, .F., cConn ) .OR. Len( aSelect ) = 0
      RETURN(.F.)
   ENDIF

RETURN(.T.)



FUNCTION sqlCreateUser( cUser, cPassword, lForcePassword, cConn )

   LOCAL lCreateUser := ( ! sqlUserExist( cUser, cConn ) )
   LOCAL cSql

   vDef( @lForcePassword, .F. )

   IF lCreateUser .OR. lForcePassword
      cSql := If( lCreateUser, "CREATE", "ALTER" ) + " USER " + cUser + " WITH PASSWORD " + QuotedStr( cPassword )
      IF ! sqlExecute( cSql, NIL, .F., cConn )
         RETURN(.F.)
      ENDIF
   ENDIF

RETURN(.T.)



FUNCTION sqlAddLog() // Funcao basicamente p/ q seja chamda no debuger.

RETURN( mxfaddline( "sqls.txt", sqllastcmd() ) )



FUNCTION sqlSrRecnoRecovery( cTable, uConn )

   LOCAL lReturn := .F.

   BEGIN SEQUENCE

      Status( "Removendo " + cTable + "_sq..." )

      IF sqlRecCount( "lower( sequence_schema ) = 'public' AND lower( sequence_name ) = '" + Lower( cTable ) + "_sq'", "information_schema.sequences", uConn ) > 0

         IF ! sqlExecute( "DROP SEQUENCE " + cTable + "_sq CASCADE;", NIL, .F., uConn )
            BREAK
         ENDIF

      ENDIF

      Status( "Removendo " + cTable + ".sr_recno..." )

      IF ! sqlExecute( "ALTER TABLE " + cTable + " DROP COLUMN IF EXISTS sr_recno CASCADE;", NIL, .F., uConn )
         BREAK
      ENDIF

      Status( "Criando " + cTable + "_sq..." )

      Status( "Incluindo coluna " + cTable + ".sr_recno..." )

      IF ! sqlExecute( "CREATE SEQUENCE " + cTable + "_sq " + ;
                         "INCREMENT 1 " + ;
                         "MINVALUE 1 " + ;
                         "MAXVALUE 9223372036854775807 " + ;
                         "START 1 " + ;
                         "CACHE 1; " + ;
                       "ALTER TABLE " + cTable + "_sq " + ;
                         "OWNER TO postgres;", NIL, .F., uConn )
         BREAK
      ENDIF

      IF ! sqlExecute( "ALTER TABLE " + cTable + " ADD COLUMN sr_recno numeric(15,0) NOT NULL DEFAULT nextval('" + cTable + "_sq'::regclass);", NIL, .F., uConn )
         BREAK
      ENDIF

      lReturn := .T.

   ENDSEQUENCE

RETURN( lReturn )



FUNCTION sqlDropFunction( cFuncName, cSqlReturn, uConn )

   LOCAL aFunc     := {}
   LOCAL aError    := {}
   LOCAL lPostgre9 := sqlPostgre_v9()
   
   LOCAL cSql, nFunc

   cSql := "SELECT DISTINCT 'DROP ' "

   IF lPostgre9
      cSql += "|| CASE WHEN p.proisagg THEN 'AGGREGATE ' ELSE 'FUNCTION ' END "
   ELSE
      cSql += "|| i.routine_type ||' '"
   ENDIF
   
   cSql += "|| quote_ident( n.nspname ) || '.' || quote_ident( p.proname ) || '(' " + ;
           "|| pg_catalog.pg_get_function_identity_arguments( p.oid ) || ') CASCADE;' AS stmt " + ;
           "FROM pg_catalog.pg_proc p " + ;
           "JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace "
             
   IF ! lPostgre9
      cSql += "JOIN  information_schema.routines i on i.routine_name = p.proname "
   ENDIF
   
   cSql += "WHERE n.nspname = 'public' " + ;
             "AND lower( p.proname ) IN ( " + QuotedStr( lower( cFuncName ) ) + " ) " + ;
             "AND pg_catalog.pg_function_is_visible( p.oid ) " + ;
           "ORDER BY 1 "

   lReturn := sqlExecute( cSql, @aFunc, .F., uConn )

   IF ! lReturn
      aAdd( aError, sqlLastError() )
   ELSE
      FOR nFunc := 1 TO Len( aFunc )
         IF cSqlReturn <> NIL
            cSqlReturn += aFunc[ nFunc, 1 ]
         ELSEIF ! sqlExecute( aFunc[ nFunc, 1 ], NIL, .F., uConn )
            aAdd( aError, sqlLastError() )
            lReturn := .F.
         ENDIF
      NEXT
   ENDIF

   IF ! lReturn
      MsgDlg( aError )
   ENDIF

RETURN( lReturn )



FUNCTION sqlDropType( cTypeName, cSqlReturn, uConn )

   LOCAL aType  := {}
   LOCAL aError := {}
   LOCAL cSql   := "SELECT typname FROM pg_catalog.pg_type WHERE lower( typname ) = " + QuotedStr( Lower( cTypeName ) )
   LOCAL nType

   lReturn := sqlExecute( cSql, @aType, .F., uConn )

   IF ! lReturn
      aAdd( aError, sqlLastError() )
   ELSEIF Len( aType ) > 0
      cSql := "DROP TYPE " + cTypeName + " CASCADE;"
      IF cSqlReturn <> NIL
         cSqlReturn += cSql
      ELSEIF ! sqlExecute( cSql, NIL, .F., uConn )
         aAdd( aError, sqlLastError() )
         lReturn := .F.
      ENDIF
   ENDIF

   IF ! lReturn
      MsgDlg( aError )
   ENDIF

RETURN( lReturn )



FUNCTION sqlExistItem( cType, cItem, cConn )

   #define _ASP '"'

   LOCAL lReturn   := .F.
   LOCAL aResult   := {}
   LOCAL cSql      := ""
   LOCAL lPostgre9 := sqlPostgre_v9()

   vDef( @cConn, "CS_LOJA" )

   IF cType = SQL_ITEM_TYPE

      cSql := "SELECT 1 FROM pg_type WHERE Lower( typname ) = " + QuotedStr( Lower( cItem ) ) + " LIMIT 1"

   ELSEIF cType = SQL_ITEM_FUNCTION

      cSql += "SELECT CASE WHEN p.proretset THEN 'setof ' ELSE '' END || "
      cSql += "   pg_catalog.format_type(p.prorettype, NULL) as " + _ASP + "Result data type" + _ASP + ", "
      cSql += "   n.nspname as " + _ASP + "Schema" + _ASP + ", "
      cSql += "   p.proname as " + _ASP + "Name" + _ASP + ", "
      cSql += "   pg_catalog.oidvectortypes(p.proargtypes) as " + _ASP + "Argument data types" + _ASP + ", "
      cSql += "   u.usename as " + _ASP + "Owner" + _ASP + ", "
      cSql += "   l.lanname as " + _ASP + "Language" + _ASP + ", "
      cSql += "   p.prosrc as " + _ASP + "Source code" + _ASP + ", "
      cSql += "   pg_catalog.obj_description(p.oid, 'pg_proc') as " + _ASP + "Description" + _ASP
      cSql += "FROM "
      cSql += "   pg_catalog.pg_proc p "
      cSql += "LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace "
      cSql += "LEFT JOIN pg_catalog.pg_language l ON l.oid = p.prolang "
      cSql += "LEFT JOIN pg_catalog.pg_user u ON u.usesysid = p.proowner "
      cSql += "WHERE "
      cSql += "   p.prorettype <> 'pg_catalog.cstring'::pg_catalog.regtype"
      cSql += "   AND p.proargtypes[0] <> 'pg_catalog.cstring'::pg_catalog.regtype"
      IF lPostgre9
         cSql += "   AND NOT p.proisagg"
      ENDIF
      cSql += "   AND pg_catalog.pg_function_is_visible(p.oid)"
      cSql += "   AND Lower( p.proname ) ~ '^" + Lower( cItem ) + "$' "
      cSql += "ORDER "
      cSql += "   BY 2, 3, 1, 4"

   ELSEIF mxIn( cType, { SQL_ITEM_VIEW, SQL_ITEM_ORDINARY_TABLE } )

      cSql += "SELECT "
      cSql += "   n.nspname AS table_schema, "
      cSql += "   pg_catalog.pg_get_userbyid(c.relowner) AS table_owner, "
      cSql += "   c.relname AS table_name "
      cSql += "FROM "
      cSql += "   pg_catalog.pg_class c "
      cSql += "LEFT JOIN "
      cSql += "   pg_catalog.pg_namespace n ON (n.oid = c.relnamespace) "
      cSql += "WHERE "
      cSql += "   c.relkind  = " + QuotedStr( Lower( cType ) ) + " and "
      cSql += "   Lower( c.relname ) = " + QuotedStr( Lower( cItem ) )
      
   ELSEIF cType = SQL_ITEM_PRIMARY_KEY
   
      cSql += "SELECT "
      cSql += "   DISTINCT UPPER( constraint_name ) AS constraint_name "
      cSql += "FROM "
      cSql += "   information_schema.key_column_usage "
      cSql += "WHERE "
      cSql += "   Lower( constraint_name ) = " + QuotedStr( Lower( cItem ) )

   ELSEIF cType = SQL_ITEM_TABLE

      cSql += "SELECT tablename FROM pg_catalog.pg_tables WHERE NOT schemaname IN ('pg_catalog','information_schema') AND Lower( tablename ) = " + Lower( cItem )

   ELSE

      MsgDlg( "Parametro cType -> sqlExistItem() informado incorretamente!" )

   ENDIF

   IF sqlExecute( cSql, @aResult, .F., cConn, NIL, .T., .F. )
      lReturn := Len( aResult ) > 0
   ENDIF

RETURN( lReturn )



FUNCTION sqlDbTime()

   LOCAL aResult := {}
   LOCAL cTime

   IF sqlExecute( "SELECT SUBSTRING( CAST( current_time AS VARCHAR ), 1, 8 )", @aResult, .F. ) .AND. Len( aResult ) > 0 .AND. ! Empty( aResult[ 1, 1 ] )
      cTime := aResult[ 1, 1 ]
   ELSE
      cTime := Time()
   ENDIF

RETURN( cTime )



FUNCTION sqlDbDate()

   LOCAL aResult := {}
   LOCAL dDate

   IF sqlExecute( "SELECT TO_CHAR( current_date, 'dd/mm/yyyy' )", @aResult, .F., NIL, NIL, .F., .F. ) .AND. Len( aResult ) > 0 .AND. ! Empty( aResult[ 1, 1 ] )
      dDate := CtoD( aResult[ 1, 1 ] )
   ELSE
      dDate := Date()
   ENDIF

RETURN( dDate )



FUNCTION sqlVacuum( cTab, cConn, lMsg )

   vDef( @lMsg, .T. )

   IF lMsg
      Status( "Executando VACUUM em " + cTab + "..." )
   ENDIF

RETURN( sqlExecute( "VACUUM FULL " + cTab, NIL, .F., cConn ) )



FUNCTION sqlDbPageCode( cPage )

   LOCAL cReturn := cDbPageCode
   
   IF cPage <> NIL
      cDbPageCode := cPage
   ENDIF
   
RETURN( cReturn )



FUNCTION sqlRddTabRegister( cTable, uConn )

   LOCAL lReturn := .T.

   IF sqlRecCount( "table_ = " + QuotedStr( cTable ), "public.sr_mgmnttables", uConn ) = 0
      lReturn := sqlExecute( "INSERT INTO public.sr_mgmnttables ( table_, signature_, created_, type_, reginfo_ ) VALUES ( " + QuotedStr( cTable ) + ", 'MGMNT 1.72', TO_CHAR( CURRENT_TIMESTAMP, 'YYYYMMDDhh:mm:ss' ), 'TABLE', '' )", NIL, .F., uConn )
   ENDIF

RETURN( lReturn )



FUNCTION sqlPGSVersion( cConn )

   LOCAL aVersion := {}
   LOCAL nVersion, cVersion, nConn

   IF cConn = NIL
      cConn := sqlGetConn( "NAME" )
   ENDIF
   
   nVersion := aScan( aPGSVersion, { |x| x[1] = cConn } )

   IF nVersion = 0
      nConn := sqlgetconn( "CONN", cConn )
      IF nConn <> 0
         cVersion := SR_GetConnectionInfo( nConn, 18 )
         cVersion := LTrim( Subs( cVersion, At( " ", cVersion ) ) )
         cVersion := AllTrim( Left( cVersion, At( " ", cVersion ) ) )
         IF Right( cVersion, 1 ) = ","
            cVersion := Left( cVersion, Len( cVersion ) -1 )
         ENDIF
         aAdd( aPGSVersion, { cConn, cVersion } )
         nVersion := Len( aPGSVersion )
      ENDIF
   ENDIF
   
   IF nVersion <> 0
      RETURN( aPGSVersion[ nVersion, 2 ] )
   ENDIF
   
RETURN( "" )



FUNCTION sqlPostgre_v9()

   RETURN( Left( sqlPGSVersion(), 2 ) = "9." )



PROCEDURE sqlDefaultRDD()

   SR_SetRDDTemp( "DBFNTX" )
   
   SR_SetSyntheticIndex(.F.)
   SR_SetSyntheticIndexMinimun(20)
   SR_SetExclusiveManagement(.T.)
   SR_UseDeleteds(.F.)

RETURN



FUNCTION sqlDefNotNull( cTable, cColumn, lExecute, lUpdate )

   #define NULL_MAX_ITENS 500

   LOCAL aFDef   := {}
   LOCAL aRec    := {}
   LOCAL nOffSet := 0

   LOCAL nTotal, cSql, cWhere, nRec

   vDef( @lExecute, .T. )
   vDef( @lUpdate , .F. )

   BEGIN SEQUENCE

      cTable := sqlGetInfo( cTable, "SCHEMA" ) + "." + sqlGetInfo( cTable, "FILE" )

      IF lUpdate

         cWhere := cColumn + " IS NULL"

         Status( "Analisando informa‡”es em " + cTable + "." + cColumn + "..." )

         IF ! sqlExecute( "SELECT SR_RECNO FROM " + cTable + " WHERE " + cWhere + " ORDER BY SR_RECNO", @aRec, .F. )
            BREAK
         ENDIF

         nTotal := Len( aRec )

         IF nTotal > 0

            cSql := ""

            FOR nRec := 1 TO Len( aRec )

               IF ( ++ nOffSet ) = 1
                  cSql := "UPDATE " + cTable + " SET " + cColumn + " = '' WHERE " + cWhere + " AND SR_RECNO IN ( "
               ELSE
                  cSql += ", "
               ENDIF

               cSql += NumToStr( aRec[ nRec, 1 ] )

               IF nOffSet = NULL_MAX_ITENS
                  cSql += " )"
                  mxWait( "definindo valores default para " + cColumn + " (faltam " + NumToStr( nTotal ) + ")", 1 )
                  IF ! sqlExecute( cSql, NIL, .F. )
                     BREAK
                  ENDIF
                  nTotal -= nOffSet
                  nOffSet := 0
               ENDIF

            NEXT

            IF nOffSet <> 0
               cSql += " )"
               IF ! sqlExecute( cSql, NIL, .F. )
                  BREAK
               ENDIF
            ENDIF

         ENDIF

      ENDIF

      aAdd( aFDef, "ALTER TABLE " + cTable + " ALTER COLUMN " + cColumn + " SET NOT NULL" )
      aAdd( aFDef, "ALTER TABLE " + cTable + " ALTER COLUMN " + cColumn + " SET DEFAULT ''" )

      IF lExecute
         sqlExecute( aFDef )
      ENDIF

   ENDSEQUENCE

RETURN( aClone( aFDef ) )