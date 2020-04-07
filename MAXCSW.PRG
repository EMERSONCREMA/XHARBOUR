/*-----------------------------------------------------------------------------
 MaxCsw.prg
 Descricao: Biblioteca de funcoes p/ recepcao de arquivos on-line pelo CSW.
 Desenvolvido por MAX SCALLA Informatica Ltda.
 Valido apenas p/ o Control Shop.

 EMERSON DA SILVA CREMA
 06/11/19 * Implementado abertura de "MXCODCFI" em rcvUpdNOE(), pois sem
            isto nao atualizava a sequencia para "CFICODACP".
 04/06/19 * Correcao no posicionamento da abertura das tabelas em rcvUpdNOE().
 30/04/19 * Implementado em TAB_ComImagens as tabelas "PMD", "BIO", e "IPM".
 29/03/19 * Reformulado rcvUpdNOE().
          * Implementado baixa de estoque apenas na loja, quando eh recebida
            uma nota de entrada que foi inserida pelo MASTER, permitindo assim
            q esta baixa seja retornada para o MASTER.
 19/03/19 * Incluido em rcvDelValid() o nome da transacao EXC_BORDUP.

 18/02/19 * Correcao em rcvReplFields() p/ q sempre consiga atualizar os campos
            CFIMINLIS e CFIMAXLIS.
 08/02/19 * Implementado consistencia para as transacoes GRAVA_DEV, CANC_PED
            e GRAVA_NOTA_DEV p/ q removam-se os itens antes de inseri-los
            novamente.
 20/12/18 * Desenvolvido e implementado rcvConfSeek() para q nao seja mais
            necessario ficar testando o nome das transacoes.
 03/12/18 * Implementado transacao GRAVA_NOTA_DEV p/ exclusao previa de itens
            em MXITECFI.
 11/10/18 * Alteracao em rcvProcess() p/ q permita itens com codigos iguais na
            gravacao de MXITFCFI.
 28/08/18 * Implementado alteracao para q permita que o processamento do
            "Envie" de uma transferencia altere a solicitacao.
 25/07/18 * Implementado TAB_ComImagens.
          * Implementado tratamento para tabelas com imagens, utilizando
            comandos SQL para gravacao.
 07/06/18 * Desenvolvido e implementado rcvUpdLIS().
 14/05/18 * Incluido em rcvDelValid() as transacoes GRAVA_CNAB e GRAVA_BORDUP.
 26/01/18 * Alteracao em rcvProcess() p/ nao efetuar pesquisa em MXLOGCFI,
            deve-se incluir sempre.
 18/01/18 * Desenvolvido e implementado rcvDelValid().
          * Em rcvDelValid() implementado consistencia para pedido de entrega.
 24/11/17 * Implementado mecanismo para eliminacao de todos os registros de
            MXESTCFI referentes a exclusao do regsitro correspondente em
            MXTESCFI.
 20/10/17 * Implementado consistencias p/ as transacoes "GRAVA_DEV" e "CANC_PED",
            pois estava duplicando os itens das vendas.
 03/10/17 * Ajuste em rcvDelRelation() p/ MXIFCCFI.
 03/08/17 * Alteracao em rcvProcess() p/ q permita gravar mais de 1 produto igual
            no MXITECFI, MXIFCCFI e MXIPECFI.
 27/06/17 * Implementado em rcvVldUpd() verificacao da transsacao "EXC_BORCHQ".
 26/06/17 * Removido sqlMsgError() e implementado recurso do proprio sqlExecute().
 15/05/17 * Alterado rcvUpdTRF() p/ nao gravar mais CFITESITF ao gerar o
            registro da loja de destino.
 14/02/17 * Correcao na atualizacao de CFIMINLIS e CFIMAXLIS em rcvReplFields().
 23/01/17 * Ajuste em rcvReplFields() p/ reenviar todos os campos de MXESTCFI
            e fazer a soma correta dos estoques em MXLISCFI->CFIESTLIS.
 04/11/16 * Implementado rotina exclusiva para entrada de produtos referentes
            a devolucoes de tintas produzidas.
 29/09/16 * Implementado exclusao de MXESTCFI quando excluido MXTESCFI.
 19/08/16 * Correcao em olSQLFormat() quando no SQL tem constantes no lugar
            de nomes de campos.
 18/08/16 * Implementado consistencias p/ trabalhar com ONL_OP_SELECT.
          * Desenvolvido rcvSqlResult().
 20/06/16 * Implementado abertura de MXKITCFI em rcvUpdNOE().
 05/05/16 * Implementado TESITF := 0.
 04/05/16 * Implementado o parametro DEBPRV em cliDebitos().
 08/10/15 * Removido rcvUpdPED().
 07/10/15 * Desenvolvido rcvUpdPED().
 06/08/15 * Desenvolvido rcvNomeTrans().
 13/04/15 * Incluido atualizacao do status "EParc" em rcvPetAtuOper().
 11/03/15 * Implementado a variavel cTransOpen.
 29/08/14 * Removida a funcao FileLog().
 11/08/14 * Desenvolvido e implementado:
            - cswIncAtualizacao().
            - cswLerAtualizacoes().
            - cswDelAtualizacao().
            - cswProcessaAtualizacao().
 02/07/14 * Correcao na definicao de uFlags p/ cEvent = "DC", pois nao estava
            contemplando o novo tamanho do codigo de clientes.
 24/06/14 * Correcao na definicao de uKey p/ cOper = ONL_OP_FCO em
            rcvProcess(), pois nao estava em acordo com o novo tamanho de
            CFICODCLI (9 digitos).
 09/06/14 * Na definicao do conteudo dos campos em rcvProcess(), esta sendo
            trocado o Chr(19) por Chr(13)+Chr(10).
 29/05/14 * Removidas atualizacoes de MXOBSCFI.
 28/05/14 * Importada a funcao FileLog() de MAXLIB02.PRG.
 26/05/14 * Implementado novo esquema d recodificacao de produtos utilizando
            csCtrAtuCodigo().
          * Removida procedure cswRestStatus().
 14/05/14 * Removida a procedure rcvUpdRelation(), pois nao era utilizada.
          * Correcao na definicao de procura de registro em MXFCXCFI qdo
            CFISFCCTR = "S".
 13/05/14 * Correcao nas definicoes das posicoes dos campos da chave de
            procura do PCL em rcvDelPcl().
 17/03/14 * Remocao das definicoes de lojas atraves de letras, utilizando
            o numero real das mesmas.
 28/02/14 * Desenvolvido e implementado rcvReplFields().
 21/02/14 * Implementado aAddST() em rcvUpdTRFPET().
 19/02/14 * Correcao na validacao p/ transferencia em rcvVldUpd(), pois qdo
            cancelava-se a entrega na loja, nao atualizava o status da
            operacao no MASTER.
 18/02/14 * Implementado OpenDB( "TRF" ) em rcvUpdTRFPET().
 06/02/14 * Implementado esquema p/ ignorar o processamento da transacao
            INC_FRM qdo o campo CFIVCOCOR ja estiver atualizado de acordo
            com a informacao que esta sendo recebida. Isto evitara os casos
            de duplicidades de itens no MXFRMCFI que eram causadas quando
            2 sistemas na mesma rede online utilizavam o mesmo banco de
            dados CS_TINTAS.
 05/02/14 * Mudado o nome de rcvTRF_PET() p/ rcvUpdTRFPET().
 15/01/14 * Adaptacoes p/ utilizacao de 7 digitos p/ CFICODPED.
 08/12/13 * Desenvolvido rcvTRF_PET().
 25/11/13 * Alteracao em rcvProcura() p/ impedir q na procura de CFIOBSIFC
            ocorra um erro no SQL ao conter apenas "\" (barra invertida).
 22/11/13 * Implementado SeekItem().
          * Desenvolvido rcvPetAtuOper().
          * Implementados ajustes p/ utilizacao de pedido de entrega de
            transferencias.
 15/10/13 * Impplementado cliBloqueioProcessa() no lugar de cliBloqueio().
          * Desenvolvido cswCliDefBloqueio().
 27/09/13 * Padronizados logs na pasta LOGS\.
 24/06/13 * Implementado cswUpdControl().
 20/06/13 * Correcao na utilizacao de rcvDelRelation(), pois nao estava sendo
            processado quando C_ALIAS = "FCO", portando duplicava o MXIFCCFI.
 12/06/13 * Implementado novo parametro em estGrvTotal().
          * Implementado sqlSeek() em rcvProcura() p/ MXLISCFI.
 31/05/13 * Implementado atualizacao do valor da duplicata em rcvPETDupls().

 DENIS MAZZUCATTO RODRIGUES
 06/05/13 * Corrigido erro de funcao inexistente "QutedStr" ao processar a
            transacao EXC_KIT.

 EMERSON DA SILVA CREMA
 03/05/13 * Alteracoes p/ unificacao da tabela de CEPs.
 25/04/13 * Implementado sqlSeek() em praticamente todas as rotinas.
 08/04/13 * Implementado novo esquema de consulta p/ ONL_OP_CONSULT via SQL.
          * Desenvolvimento de cswRetItens().

 DENIS MAZZUCATTO RODRIGUES
 05/03/13 * Implementacao de sqlGetRecords() em rcvUpdTRF().
          * Desenvolvimento e implementacao de rcvUpdRecords().
          * Implementacao de sqlGetRecords() em rcvPETDupls().

 EMERSON DA SILVA CREMA
 04/03/13 * Implementado comandos SQL em rcvUpdPET().

 DENIS MAZZUCATTO RODRIGUES
 29/01/13 * Implementadas consistencias em rcvAddOpen() ref RCV_BLK_CLI.

 EMERSON DA SILVA CREMA
 20/12/12 * Impedida execucao de rcvDelRelation() p/ transacao UPDNFE, pois
            causava replicacao de itens em MXITNCFI.

 DENIS MAZZUCATTO RODRIGUES
 23/11/12 * Correcao em rcvRepass() q gerava os registros de forma errada.
            Criava sempre um registro p/ loja 3 com o nome do arquivo C e o
            texto como O.

 EMERSON DA SILVA CREMA
 07/11/12 * Correcao na definicao cCpl em rcvPETDupls() qdo em 1 parcela,
            pois acabava nao definindo o complemento correto, consequentemente
            nao achando a duplicata.
          * Nao eh mais utilizado memoread e memoline, agora utiliza direto a
            leitura em uma variavel.
 18/10/12 * Desenvolvimento de olSQLFormat(), rcvDelPcl(), rcvSqlTable(),
            rcvUpdIFC() e rcvDelete().

 DENIS MAZZUCATTO RODRIGUES
 22/06/12 * Remocao de rcvBlkCLI() - implementada programacao direta.
 13/06/12 * Implementada procura especifica p/ IFC em rcvProcura().
 04/06/12 * Implementada consistencia p/ nao gravar alguns registros no CFG.
 24/05/12 * Implementada consistencia p/ verificar o tamanho de cAlias na
            definicao de C_ALIAS.
 23/05/12 * Passado parametro nas chamadas de olRename() p/ apagar o arquivo p/
            as operacoes ONL_OP_NFP, ONL_OP_FCO e ONL_OP_CONSULT.
 22/05/12 * Alteracao p/ nao executar rcvAddOpen() qdo ONL_OP_SENDIP.
 18/10/11 * Remocao de olCheckItens() (a programacao ja estava ignorada).
 11/10/11 * Implementado o schema na string do sql em rcvDelRelation().
 10/10/11 * Implementada verificacao do database p/ arquivos do tintometrico.

 EMERSON DA SILVA CREMA
 06/07/11 * Implementado SQL p/ delecao de registros em rcvDelRelation() e
            rcvUpdTRF().

 DENIS MAZZUCATTO RODRIGUES
 28/06/11 * Implementadas consistencias p/ transacao OL_BOLETO_PET.
          * Inclusa consistencia p/ gravar a data maior em ULCCLI/UDCCLI.
 24/06/11 * Correcoes na gravacao dos arquivos de CEP.

 EMERSON DA SILVA CREMA
 25/05/10 * Corrigida definicao dos campos validos p/ transacao ALT_DADOS_LIS.

 DENIS MAZZUCATTO RODRIGUES
 19/03/10 * Corrigida uma falha em rcvUpdTRF() q ficava em loop ao apagar as
            formulas do tintometrico.

 EMERSON DA SILVA CREMA
 17/02/10 * Implementado status SepaP p/ pedidos de entrega.

 DENIS MAZZUCATTO RODRIGUES
 17/02/10 * Alteracao em FUNCTION rcvUpdTRF() p/ nao zerar o codigo do
            representante q gerou a transferencia.
 23/12/09 * Corrigidas comparacoes com CFIBACCTR, pois nao utilizavam o Left().

 EMERSON DA SILVA CREMA
 22/10/09 * Implementadas condicoes p/ exclusao de campos p/ gravacao. Secao
            q comeca com NS-> e termina em <-NS.

 DENIS MAZZUCATTO RODRIGUES
 25/09/09 * Implementada gravacao de CFISTOPED.
 23/09/09 * Remocao de AddTransCod() de rcvUpdTRF().

 EMERSON DA SILVA CREMA
 18/09/09 * Alteracoes p/ BELA TINTAS p/ q permita modificacao do status da
            entrega p/ Digit qdo ainda estiver com status Separ/Impre.

 DENIS MAZZUCATTO RODRIGUES
 28/08/09 * Implementada consistencia p/ nao alterar o nome da transacao
            CANCELA_ROT p/ RCV_UPDPET em rcvUpdPET() pois nao estava alterando
            o status da entrega de Entre p/ Separ.
 27/08/09 * Implementadas consistencias em rcvVldUpd() referente a transacao
            RCV_UPDPET p/ PED.

 EMERSON DA SILVA CREMA
 27/07/09 * Implementadas adaptacoes p/ gravacao de CFIDSOLIS e CFISOFLIS.
 10/06/09 * Implementada gravacao da da loja em CFIAUXMDP em rcvPETDupls().
 08/06/09 * Correcao em rcvPETDupls() ref relacionamento das duplicatas qdo
            emitida NF pelo deposito.
 05/06/09 * Correcao da exclusao de KITs.

 DENIS MAZZUCATTO RODRIGUES
 05/06/09 * Permitida alteracao dos campos de estoque p/ transacao MMM_REA.

 EMERSON DA SILVA CREMA
 19/05/09 * Implementado gravacao de MTC em rcvUpdPET().
 07/04/09 * Atualizacao dos codigos dos arquivos relacionados as duplicatas.

 DENIS MAZZUCATTO RODRIGUES
 13/02/09 * Implementacao de SeekIPE() em rcvProcura().
          * Alterado controle feito pela transacao EXCLUI_ROT p/ CANCELA_ROT.
          * Inclusa verificacao em rcvDelRelation() p/ nao apagar os itens
            caso seja uma operacao p/ alterar apenas alguns campos do arquivo.
 05/02/09 * Implementacao de ONL_OP_GETDIRECT.
 04/02/09 * Remocao de NConnect() usada p/ gravar estoque da loja 9 do Bazar.

 EMERSON DA SILVA CREMA
 04/02/09 * Alteracao em rcvProcess() p/ nao executar rcvDelRelation() qdo for
            a transacao INC_PCOM.
 19/01/09 * Alteracao em rcvUpdPET() p/ nao utilizar o numero da conexao p/ a
            loja de reenvio qdo a transacao for CNX_REENVIA.

 DENIS MAZZUCATTO RODRIGUES
 29/12/08 * Nao estava atualizando o estoque minimo ao processar a transacao
            CEM_PROCESSA.

 EMERSON DA SILVA CREMA
 15/12/08 * Implementado parametro lDisp = .F. em todas funcoes mxRecLock(),
            mxAppend() e mxDelete().
 27/11/08 * Implementada consulta de campos como codeblock p/ ONL_OP_CONSULT.
 24/09/08 * Implementada gravacao do CEP.
 14/08/08 * Inclusa aberturada de MXMDPCFI p/ processar cliDebitos().
 06/08/08 * Inclusa transacao INC_PRO na consistencia q permite a gravacao de
            campos do cadastro de produtos.
          * Correcao do processo anterior, pois ainda nao efetuava as
            gravacoes da forma correta.
 05/08/08 * Trocadas as constantes RCV_OP_??? por ONL_OP_???. Incluso header
          * maxonl.ch.

 DENIS MAZZUCATTO RODRIGUES
 15/07/08 * Corrigido nome da variavel bExecute q recebia o retorno de
            rcvOpenAGE() (estava escrito bExeceute), causando erro BASE/1004.
 14/07/08 * Corrigida alteracao efetuada em 11/04/08 pois estava permitindo q
            pedidos ja entregues retornassem p/ roteiro.
 03/07/08 * Implementacao cnxEnvNFP() e RCV_OP_NFP.

 EMERSON DA SILVA CREMA
 03/07/08 * Mudado o nome do programa de MAXOLRCV.PRG p/ MAXCSW.PRG
          * Movidas rcvMaqDir(), rcvOpenAGE(), rcvDefBack(), rcvKey(),
            rcvFileRsp(), olSolicCod(), cswActFile() e isCsw() p/ MAXONL.PRG

 RODRIGO GENEROZO
 11/04/08 * Mudanca na hierarquia de aStatus em rcvVldUpd() p/ o PET, mudando
            ENTRE-4 p/ ENTRE-3 e colocado a condicao ENTREGA_ROT p/ o SEPAR.
 20/03/08 * Correcao em rcvUpdTRF() p/ nao gravar em duplicidade transferencia
            de produtos tintometricos.

 EMERSON DA SILVA CREMA
 25/02/08 * Correcao de alias does not exist MXITFCFI em rcvGetInfo().

 DENIS MAZZUCATTO RODRIGUES
 18/02/08 * Implementada busca do codigo de conferencia de transferencia em
            rcvGetInfo().

 EMERSON DA SILVA CREMA
 11/02/08 * Substituicao de sndFSequence() por sndSequence().
 20/12/07 * Adicionado abertura de MXCLECFI p/ consulta de credito de cliente.

 DENIS MAZZUCATTO RODRIGUES
 15/10/07 * Implementada condicao em rcvUpdRelation() p/ verificar o fim de
            arquivo, pois em alguns casos ficava travado em loop.

 EMERSON DA SILVA CREMA
 05/10/07 * Movida olMsgWait() p/ MAXTELA.PRG.
 20/09/07 * Implementada abertura de CLI e LOJ qdo o alias for AGE.
 17/09/07 * Correcao do recebimento de clientes qdo enviado pelo master e
            configurado p/ nao integrar clientes pois estava sempre reenviando
            p/ todas as lojas.

 DENIS MAZZUCATTO RODRIGUES
 30/08/07 * Implementada consistencia p/ nao gravar os campos contidos em
            sndNoSend().
 28/06/07 * Ao analisar os arquivos MXLOG*.TRF/NOE/PET, se existir mais de um
            arquivo solicitando a alteracao de uma mesma operacao, excluir os
            arquivos e deixar apenas 1.
          * As funcoes rcvDelRelation() e rcvUpdRelation() atualizavam os
            registros da venda e do recebimento varias vezes. Implementada
            consistencia aScan( aRecvSend ).
          * Implementada atualizacao dos recebimentos em rcvUpdRelation().
 05/06/07 * Implementada gravacao de CFISEQPET.
 23/05/07 * Implementacao de GrvLoe() em rcvPETDupls() p/ evitar duplicidade
            nas duplicatas.
 24/04/07 * A alteracao efetuada em 10/10/06 ocasionou duplicidade nos
            registros de MXFCVCFI e com isso no Loja ao processar uma
            transferencia acaba dando baixa do mesmo produto varias vezes.
 13/04/07 * Correcao em rcvVldUpd() q nao permitia a atualizacao de entregas
            com status Rotei p/ EParc.
 02/04/07 * Implementada validacao p/ COM e ITC em rcvVldUpd().
 29/03/07 * Implementada consistencia em rcvVldUpd() p/ nao alterar o status
            do pedido de entrega p/ Digit qdo ja estiver gravado Impre.

 EMERSON DA SILVA CREMA
 29/03/07 * Implementada rotina p/ gerar MXCLICFI.LOG a fim de localizar o
            problema da Festa Chopp.

 DENIS MAZZUCATTO RODRIGUES
 28/03/07 * Desenvolvimento de cswActFile() p/ utilizacao em ERRORSYS.PRG

 EMERSON DA SILVA CREMA
 26/03/07 * Implementado parametro aRcvPrior em rcvGetFiles().

 DENIS MAZZUCATTO RODRIGUES
 07/03/07 * Desenvolvimento e implementacao de rcvPETDupls().

 EMERSON DA SILVA CREMA
 27/02/07 * Implementada consulta de debitos do cliente de forma online.
            Utiliza cliDebitos().
 15/02/07 * Qdo nao existia registros em MXSNHCFI ou MXGCOCFI, nao estava
            dando mxAppend(), mas sim tentando bloquear, e travava o sistema.
          * Nao fazia a mesma consistencia de MXSNHCFI p/ o MXGCOCFI.

 DENIS MAZZUCATTO RODRIGUES
 03/01/07 * Implementado parametro nAdd em olSolicCod().
 28/12/06 * Definido o envio das entregas como prioridade em rcvUpdPET().

 EMERSON DA SILVA CREMA
 12/12/06 * Desenvolvimento de isCsw() e olMsgWait().

 DENIS MAZZUCATTO RODRIGUES
 06/12/06 * Implementada verificacao da variavel RELEASE em rcvVldUpd() como
            condicao p/ validar o processamento da transferencia. Na 3.10 nao
            deve ter a condicao, apenas na 3.101 ou superior, por isso foi
            feita essa verificacao, pois RELEASE nao existe na 3.10.
 01/11/06 * Desenvolvimento e implementacao de rcvDefBack().

 EMERSON DA SILVA CREMA
 10/10/06 * Implementada gravacao de MXFCVCFI e MXCOVCFI em rcvUpdTRF().

 DENIS MAZZUCATTO RODRIGUES
 19/09/06 * Implementacao de olCheckItens() e olReenvia().
 14/08/06 * Implementado processo p/ q o loja possa atualizar as variaveis da
            configuracao do sistema alteradas pelo Master.
 07/07/06 * Correcao em rcvUpdRelation() q nao atualizava os status dos
            pedidos qdo realizado o fechamento de contas.

 EMERSON DA SILVA CREMA
 22/06/06 * Desenvolvimento de rcvUpdRelation().
          * Implementacoes p/ gravacao correta de fechamentos de contas.

 DENIS MAZZUCATTO RODRIGUES
 02/06/06 * Implementada validacao p/ PED em rcvVldUpd().

 EMERSON DA SILVA CREMA
 22/05/06 * Removida consistencia q abria os arquivos PED e RCP relacionados
            do IFC, apenas se fosse exclusao.

 DENIS MAZZUCATTO RODRIGUES
 19/05/06 * Implementada validacao pela sequencia dos status da entrega em
            rcvVldUpd().
 18/05/06 * Correcao em rcvVldUpd() p/ nao permitir q haja vendas, entregas e
            transferencias sem itens.

 EMERSON DA SILVA CREMA
 17/05/06 * Trocado parametro cPath por aRcvFiles em rcvGetFiles().
            Agora a matriz aRcvFiles e atualizada qdo necessario, e nao e
            remontada por completo todas as vezes q processa a funcao.

 DENIS MAZZUCATTO RODRIGUES
 28/04/06 * Desenvolvimento de rcvProcura().
          * Implementacao de SeekITE().
          * Remocao de rcvAchaPro() - implementada em rcvProcura().

 EMERSON DA SILVA CREMA
 27/04/06 * Correcao em cnxSeek() pois estava utilizando parametrizacoes
            erradas a partir da matriz aRecvRelation.

 DENIS MAZZUCATTO RODRIGUES
 11/04/06 * Implementado recebimento das configuracoes do sistema.

 EMERSON DA SILVA CREMA
 27/03/06 * Implementacao de OpenAGE() p/ definir a agenda correta p/ q as
            informacoes sejam gravadas.

 DENIS MAZZUCATTO RODRIGUES
 17/03/06 * Alteracao na consulta de estoque p/ mostrar o estoque zerado da
            loja 9 (Televendas). Apenas p/ a rede Bazar.
 10/03/06 * Desenvolvimento e implementacao de rcvUpdNOE().
 06/03/06 * Implementada consulta ao SCPC.

 EMERSON DA SILVA CREMA
 20/02/06 * Implementada gravacao de CFILJFPED e CFILJFRCP.
 16/02/06 * Implementada gravacao do status em PED e RCP na exclusao de itens
            do fech de contas. Esta operacao efetua a redistribuicao das
            informacoes das quais se originam os movimentos.
 15/02/06 * Implementada gravacao de fechamentos de contas online.
 10/02/06 * Implementacao de RCV_OP_FCO.
          * Desenvolvimento de rcvAddExec().
 02/02/06 * Implementado parametro lNoTrans em mxTran().
 01/02/06 * Implementacao em rcvProcess() p/ nao abrir transacao qdo for
            operacao RCV_OP_GETINFO e o alias nao for COD.
 31/01/06 * Implementada consulta online (RCV_OP_CONSULT).
 23/01/06 * Adicionado o campo CFILOCLIS p/ q nao seja processado na loja qdo
            houver alteracao no Master.

 DENIS MAZZUCATTO RODRIGUES
 27/12/05 * No processo de leitura do arquivo texto, inclusa consistencia p/
            nao gravar a matriz finalizando os campos caso ainda nao tenha
            sido iniciada.
 21/09/05 * Desenvolvimento de rcvBlkCli().
          * Implementacao de cliDefBloqueio() e cliBloqueio().
 08/07/05 * Desenvolvimento e implementacao de rcvAchaPro().

 EMERSON DA SILVA CREMA
 25/05/05 * Implementacao de sndCnxDir() em rcvRepass().

 DENIS MAZZUCATTO RODRIGUES
 29/04/05 * Adaptacoes p/ envio das formulas personalizadas.
 07/10/04 * Conclusao do desenvolvimento.

 EMERSON DA SILVA CREMA
 27/05/04 * Inicio do desenvolvimento.
-----------------------------------------------------------------------------*/

#include "std.ch"
#include "inkey.ch"
#include "dataEdit.ch"
#include "maxonl.ch"
#include "b:\desenvolvimento\sistemas\cs\loja\fontes\maxmaqcf.ch"

STATIC cRecvDrvBkp   := ""
STATIC cRecvTrans    := ""
STATIC cRecvFiles    := ""
STATIC aRecvRelation := {}
STATIC aRecvNoUpd    := {}
STATIC aRecvExec     := {}
STATIC aRecvSend     := {}
STATIC aGetInfo      := {}
STATIC bFuncMsg      := NIL

#define CSW_SQLLOG "LOGS\CSWSQL.LOG"

#define USA_SEEK_ITE ( IsDef( "RELEASE" ) .AND. RELEASE < 31 )

#define RCV_ALIAS   1
#define RCV_OPER    2
#define RCV_ORDER   3
#define RCV_KEY     4
#define RCV_FIELDS  5
#define RCV_FKEY    6
#define RCV_FCLEAR  7
#define RCV_FLOJA   8
#define RCV_SORT    9

#define RCV_SEND_TAB  1
#define RCV_SEND_REC  2
#define RCV_SEND_NLJ  3

#define RCV_FILE_REC  1
#define RCV_FILE_TXT  2
#define RCV_FILE_PRI  3
#define RCV_FILE_ARQ  4

#define RCV_USE_LOE  { "CHQ","DUP" }
#define RCV_BLK_CLI  { "CHQ","DUP","FCO" }

#define RL_ALIAS_HEADER  1
#define RL_ALIAS_CHILD   2
#define RL_KEY_HEADER    3
#define RL_KEY_CHILD     4
#define RL_ORD_CHILD     5
#define RL_DEL_CHILD     6
#define RL_SQL           7

#define CMPIFC_PED  1
#define CMPIFC_NLJ  2
#define CMPIFC_LJF  3
#define CMPIFC_STA  4
#define CMPIFC_FLG  5

#define CNX_EXCLUI  "C"

#define TAB_ComImagens "IMA|IMM|IMS|IPD|PMD|BIO|IPM"

#define C_ALIAS  Upper( If( Len( cAlias ) = 3, cAlias, Subs( cAlias, 3, 3 ) ) )

#define CONF_NOSEND   ( ! sndMaster() .AND. ! Empty( sndNoSend() ) )

#define RCV_TRF_AUTO  ( CFIURECTR <> "N" .AND. CFIGETCTR = "S" )

#define vldField( cField )  rcvVldField( cAlias + "->" + cField, aFields )


STATIC cRcvTrans := ""


FUNCTION rcvProcess( aRcvFile, cPath, bFunc )

   #define RCV_FLAG Left( cInfo, 2 )

   #define RCV_CONS_ORDER 1
   #define RCV_CONS_SEEK  2
   #define RCV_CONS_WHILE 3
   #define RCV_CONS_FOR   4
   #define RCV_CONS_SQL   5

   LOCAL lReturn  := .F.
   LOCAL aFiles   := {}
   LOCAL aConsult := {}
   LOCAL aBlkCli  := {}
   LOCAL aProcess := {}
   LOCAL aRcvFco  := {}
   LOCAL aNoRcv   := {}
   LOCAL lFClear  := .F.
   LOCAL lFInic   := .F.
   LOCAL lFNInic  := .F.
   LOCAL lItens   := .F.
   LOCAL lNoTrans := .F.
   LOCAL lScpc    := .F.
   LOCAL lDir     := .F.
   LOCAL lOpenCFG := .F.
   LOCAL cOper    := ""
   LOCAL cRcvFile := cPath + aRcvFile[ RCV_FILE_ARQ ]

   LOCAL TOTDEB := 0
   LOCAL DEBPRA := 0
   LOCAL DEBPRV := 0
   LOCAL DEBDEV := 0
   LOCAL DEBDUP := 0
   LOCAL DEBDPT := 0
   LOCAL DEBATR := 0
   LOCAL DEBCHQ := 0
   LOCAL DEBCHD := 0
   LOCAL DEBCHT := 0
   LOCAL DEBRCP := 0
   LOCAL REPAGE := -1

   LOCAL cInfo, cAlias, cDir, cFile, cField, cFieldKey, cTrans, cTransOpen, cRead
   LOCAL cSort, cEvent, cWhile, cFor, cDefAlias, cSendFile, cRename, cAux
   LOCAL cAliasOLD, cMsgOLD, cSql, lAtualizaCod

   LOCAL nConnect, nFLoja, nNotUpdate, nCupUpdate, nFcoUpdate
   LOCAL nOrder, nCount, nAdd, nField, nOper
   LOCAL nCliLoj, nPos, nReadK, nProcess, nTotProcess, nItemProcess

   LOCAL lSeek, lNew, lRcvProduto
   LOCAL uKey, uFlags, bExecute
   LOCAL aKey, aAux, aFields, aDelPcl, aUpdPetDup, aResult

   cRecvTrans := ""

   aGetInfo := {}

   IF bFunc <> NIL
      bFuncMsg := bFunc
   ENDIF

   rcvNomeTrans( "" )

   rcvDispMsg( .T., .T., "Carregando " + AllTrim( fNameDir( cRcvFile, 40 ) ) + "..." )

   cswActFile( cRcvFile )

   cRead := aRcvFile[ RCV_FILE_TXT ]

   DO WHILE ! Empty( cRead )

      nRead := At( _NL, cRead )

      IF nRead = 0
         cInfo := cRead
         cRead := ""
      ELSE
         cInfo := Left( cRead, nRead - 1 )
         cRead := Subs( cRead, nRead + Len( _NL ) )
      ENDIF

      // Consistencia p/ evitar erro qdo tem linhas em branco no arquivo.

      IF Empty( cInfo )
         LOOP
      ENDIF

      IF Left( cInfo, 8 ) = "CSR20 03"  // Consulta ao SCPC

         nConnect := Val( Subs( cInfo, 18, 3 ) )
         cFile    := Subs( cInfo, 9, 12 )
         lScpc    := .T.

         EXIT

      ENDIF

      cField := ""

      // Nao mudar a posicao das condicoes

      DO CASE
         CASE RCV_FLAG = "T="

              // Nome da transacao q foi utilizada.

              cTrans     := AllTrim( Subs( cInfo, 3 ) )
              cRecvTrans := cTrans

              rcvNomeTrans( cTrans )

         CASE RCV_FLAG = "P="

              // Parametros da operacao.

              cOper   := Subs( cInfo, 4, 1 )
              cAlias  := Subs( cInfo, 6, 3 )
              lFClear := Subs( cInfo, 10, 1 ) = "A"

              IF cOper <> ONL_OP_SENDIP
                 rcvAddOpen( aFiles, cAlias )
              ENDIF

              IF cOper = ONL_OP_FCO
                 uFlags := Subs( cInfo, 10, 1 )
                 cEvent := Subs( cInfo, 12, 1 )
              ELSEIF cOper = ONL_OP_NFP
                 uFlags := Subs( cInfo, 5 )
              ENDIF

              IF "DC" $ cInfo
                 uFlags := { Val( Subs( cInfo, 13, 9 ) ), Val( Subs( cInfo, 23, 1 ) ) }
                 cEvent := "DC"
                 rcvAddOpen( aFiles, "PED" )
                 rcvAddOpen( aFiles, "PCL" )
                 rcvAddOpen( aFiles, "RCP" )
                 rcvAddOpen( aFiles, "DUP" )
                 rcvAddOpen( aFiles, "CHQ" )
              ENDIF

              rcvAddOpen( aFiles, "LOJ", cAlias = "CLI" )

              IF cAlias = "AGE"
                 rcvAddOpen( aFiles, "LOJ" )
                 rcvAddOpen( aFiles, "CLI" )
              ENDIF

         CASE RCV_FLAG = "D="

              // Diretorio p/ gravacao.

              cDir := rcvKey( cInfo )[2]

              IF cAlias <> NIL .AND. mxIn( C_ALIAS, MAQ_ALIAS )
                 IF "\CS_" $ cDir
                    cDir := "\" + sqlGetConn( "DTB", "CS_TINTAS" ) + Subs( cDir, At( "\", Subs( cDir, 2 ) ) +1 )
                 ENDIF
              ENDIF

              IF rcvMaqDir() <> NIL
                 bExecute := rcvMaqDir()
                 Eval( bExecute, cDir )
              ENDIF

              lDir := .T.

         CASE RCV_FLAG = "K="

              // Chave primaria.

              IF cOper = ONL_OP_FCO

                 uKey := { ;
                           Val(  Subs( cInfo, 04, 09 ) ),;
                           CtoD( Subs( cInfo, 14, 10 ) ) ;
                         }

              ELSE

                 aKey   := rcvKey( cInfo )
                 nOrder := Val( aKey[1] )
                 uKey   := aKey[2]

                 IF nOrder = 2 .AND. Len( aKey ) > 2 .AND. aKey[3] = "CFICODRET"  // Para compatibilidade.
                    cFieldKey := "STR(CFICODRET,13)+STR(CFINLJRET,3)"
                 ELSE
                    cFieldKey := If( Len( aKey ) > 2, aKey[3], "" )
                 ENDIF

                 IF cOper = ONL_OP_CONSULT
                    aAdd( aConsult, { NIL, NIL, NIL, NIL, .F. } )
                    aConsult[ Len( aConsult ), RCV_CONS_ORDER ] := nOrder
                    aConsult[ Len( aConsult ), RCV_CONS_SEEK  ] := uKey
                 ENDIF

              ENDIF

         CASE RCV_FLAG = "W="

              // Condicao WHILE.

              cWhile := StrTran( Subs( cInfo, 4 ), CHR_SEP, "" )
              aConsult[ Len( aConsult ), RCV_CONS_WHILE ] := cWhile

         CASE RCV_FLAG = "F="

              // Condicao FOR.

              cFor := StrTran( Subs( cInfo, 4 ), CHR_SEP, "" )
              aConsult[ Len( aConsult ), RCV_CONS_FOR ] := cFor

         CASE RCV_FLAG = "Q="

              aAdd( aConsult, { NIL, NIL, NIL, NIL, .T. } )

              cFor := StrTran( Subs( cInfo, 4 ), CHR_SEP, "" )
              aConsult[ Len( aConsult ), RCV_CONS_FOR ] := cFor

         CASE RCV_FLAG = "C="

              // Codigo da conexao.

              nConnect := Val( Subs( cInfo, 4, 3 ) )
              nFLoja   := Val( Subs( cInfo, 8, 3 ) )

         CASE RCV_FLAG = "I="

              IF cOper = ONL_OP_SENDIP

                 uFlags := AllTrim( Subs( cInfo, 3 ) )
                 uFlags := Subs( uFlags, 2 )
                 uFlags := Left( uFlags, Len( uFlags ) -1 )

              ELSE

                 aAdd( aRcvFco, { Subs( cInfo, 4, 5 ),;
                                  Val( Subs( cInfo, 10, 3 ) ),;
                                  Val( Subs( cInfo, 14, 7 ) ),;
                                  Val( Subs( cInfo, 22, 3 ) ) } )
              ENDIF

         CASE RCV_FLAG = "->"

              // Inicio da gravacao dos campos.

              aFields := {}
              lFInic  := .T.

         CASE RCV_FLAG = "<-"

              // Fim da gravacao dos campos.

              IF cOper = ONL_OP_DELETE
                 aFields := {}
              ENDIF

              IF ! lFInic
                 LOOP
              ENDIF

              lFInic := .F.

              aAdd( aProcess, { cAlias   ,;  // 1 -> RCV_ALIAS
                                cOper    ,;  // 2 -> RCV_OPER
                                nOrder   ,;  // 3 -> RCV_ORDER
                                uKey     ,;  // 4 -> RCV_KEY
                                aFields  ,;  // 5 -> RCV_FIELDS
                                cFieldKey,;  // 6 -> RCV_FKEY
                                lFClear  ,;  // 7 -> RCV_FCLEAR
                                nFLoja   ,;  // 8 -> RCV_FLOJA
                                NIL } )      // 9 -> RCV_SORT

         CASE Left( cInfo, 4 ) = "NS->"

              // Inicio dos campos q nao devem ser gravados.

              aNoRcv  := {}
              lFNInic := .T.

         CASE Left( cInfo, 4 ) = "<-NS"

              // Fim dos campos q nao devem ser gravados.

              lFNInic := .F.

         CASE lFNInic

              // Campos q nao devem ser gravados.

              aAdd( aNoRcv, cInfo )

         CASE ! lFInic

              LOOP

         OTHERWISE

              IF cOper = ONL_OP_SELECT

                 IF Right( cInfo, 1 ) = "?"
                    cInfo := Left( cInfo, Len( cInfo ) -1 )
                 ENDIF
                 aAdd( aGetInfo, cInfo )

              ELSE

                 // Campo enviado.

                 nPos := At( "=", cInfo )

                 IF nPos = 0
                    nPos := At( "?", cInfo )
                 ENDIF

                 cInfo := StrTran( cInfo, Chr(19), _NL )

                 IF cOper = ONL_OP_CONSULT

                    cField := cInfo

                    IF Len( cField ) > 3 .AND. ! "{||" $ cInfo
                       cDefAlias := Right( cField, 3 )
                       cField    := "MX" + cDefAlias + "CFI->CFI" + cField
                       rcvAddOpen( aFiles, cDefAlias )
                       IF ! lItens .AND. cDefAlias = "ITE"
                          lItens := .T.
                       ENDIF
                    ELSE
                       cField := "MX" + cAlias + "CFI->CFI" + Left( cField, 3 ) + cAlias
                    ENDIF

                 ELSE

                    cField := Left( cInfo, nPos -1 )

                    IF cAlias = "AGE" .AND. cField = "REP"
                       REPAGE := Val( Subs( cInfo, nPos + 1 ) )
                    ENDIF

                    cField := "MX" + cAlias + "CFI->CFI" + cField + If( Len( cField ) > 3, "", cAlias )

                 ENDIF

                 aAdd( aFields, { cField, Subs( cInfo, nPos + 1 ) } )

              ENDIF

      ENDCASE

      IF mxIn( cOper, { ONL_OP_GETINFO, ONL_OP_GETDIRECT } )
         aAdd( aGetInfo, GetNoEmpty( cField, cInfo ) )
      ENDIF

   ENDDO
   
   rcvDispMsg( .F., .F., "Processando " + AllTrim( fNameDir( cRcvFile, 40 ) ) + "...", 14 )

   IF cTrans <> NIL
      IF foundStr( cTrans, "UPDPRO_LIS|GRP_EXC|EMB_EXC|ATU_LISMKP|INC_AUD|ALT_AUD|EXC_AUD|PROC_AUD" )
         cswUpdControl( cTrans )
      ENDIF
      rcvDispMsg( .T., .T., "Transa‡„o [" + cTrans + "] " )
   ENDIF

   IF cOper = ONL_OP_CONSULT .AND. ( cEvent <> NIL ) .AND. cEvent = "DC"
      rcvAddOpen( aFiles, "CLE" )
      rcvAddOpen( aFiles, "MDP" )
   ENDIF

   rcvAddOpen( aFiles, "MDP", cOper = ONL_OP_CONSULT .AND. cAlias = "DUP" .AND. ( cEvent = NIL .OR. ( cEvent <> "DC" ) ) )

   DO CASE
      CASE lScpc

           mxFDel( "SCPC\" + cFile )
           mxFCopy( cRcvFile, "SCPC\" + cFile )

      CASE cOper = ONL_OP_NFP

           cnxEnvNFP( ;
                      Subs( uFlags, 2, 3 )          ,;
                      CtoD( Subs( uFlags,  6, 10 ) ),;
                      CtoD( Subs( uFlags, 17, 10 ) ) ;
                    )

           cRename   := rcvFileRsp( cRcvFile, nConnect, "SND" )
           cSendFile := ModExt( cRename, "TMP" )

           cInfo := "NFP=" + uFlags

           rcvDispMsg( .T., .T., "Enviando " + AllTrim( fNameDir( cRename, 50 ) ) + "..." )
           olRename( cSendFile, { cRename, cInfo }, .T. )

      CASE cOper = ONL_OP_FCO

           IF cEvent = "F"

              OpenDB( { "PED","RCP" } )

              sndActive( .T. )

              mxTran( "RCV_FCO", { "PED","RCP" } )

              FOR nCount := 1 TO Len( aRcvFco )

                 IF aRcvFco[ nCount, 2 ] = aRcvFco[ nCount, 4 ]
                    LOOP
                 ENDIF

                 IF foundStr( aRcvFco[ nCount, 1 ], "Prazo|DevPz" )

                    IF MXPEDCFI->( mxSeek( 11, { aRcvFco[ nCount, 3 ], aRcvFco[ nCount, 2 ] } ) )

                       cAux := If( aRcvFco[ nCount, 1 ] = "DevPz", "DevoP", "PrazP" )

                       MXPEDCFI->( mxRecLock( NIL, .F. ) )
                       MXPEDCFI->( mxReplace( "STO", MXPEDCFI->CFISTAPED, MXPEDCFI->CFISTAPED <> cAux ) )
                       MXPEDCFI->( mxReplace( "STA", cAux ) )
                       MXPEDCFI->( mxReplace( "LJF", nConnect ) )
                       MXPEDCFI->( mxUnlock(.F.) )

                    ENDIF

                 ELSEIF "Rece" $ aRcvFco[ nCount, 1 ]

                    IF MXRCPCFI->( mxSeek( 1, { aRcvFco[ nCount, 3 ], aRcvFco[ nCount, 2 ] } ) )

                       MXRCPCFI->( mxRecLock( NIL, .F. ) )
                       MXRCPCFI->( mxReplace( "STA", "Proce" ) )
                       MXRCPCFI->( mxReplace( "LJF", nConnect ) )
                       MXRCPCFI->( mxUnlock(.F.) )

                    ENDIF

                 ENDIF

              NEXT

              mxTran( "RCV_FCO" )

              sndActive( .F. )

           ELSE

              nOper := aScan( aRecvExec, { |x| x[1] = ONL_OP_FCO } )

              IF nOper > 0

                 cRename   := rcvFileRsp( cRcvFile, nConnect, "SND" )
                 cSendFile := GetNameFile( cRename )

                 cInfo := "P=" + CHR_SEP + "F" + CHR_SEP + cAlias + CHR_SEP + _NL
                 cInfo += "C=" + CHR_SEP + StrZero( nConnect, 3 ) + CHR_SEP + _NL

                 cInfo := Eval( aRecvExec[ nOper, 2 ], cInfo, uKey, uFlags, nConnect )

                 IF ! Empty( cInfo )

                    rcvDispMsg( .T., .T., "Enviando " + AllTrim( fNameDir( cRename, 50 ) ) + "..." )

                    olRename( cSendFile, { cRename, cInfo }, .T. )

                 ENDIF

              ENDIF

           ENDIF

      CASE cOper = ONL_OP_REENVIA

           cAlias := "MX" + cAlias + "CFI"

           OpenDB( { { C_ALIAS, nOrder } } )

           DO CASE
              CASE ( cAlias )->( Type( mxIndexKey( nOrder ) ) ) = "N"
                   uKey := Val( uKey )
              CASE ( cAlias )->( Type( mxIndexKey( nOrder ) ) ) = "D"
                   uKey := CtoD( uKey )
              CASE ! Empty( cFieldKey )
                   uKey := Left( uKey, Len( ( cAlias )->&( "(" + cFieldKey + ")" ) ) )
           ENDCASE

           lSeek := rcvProcura( cAlias, nOrder, uKey, nFLoja )

           IF lSeek
              olReenvia( C_ALIAS, cTrans )
           ENDIF

      CASE cOper = ONL_OP_CONSULT

           aEval( aFiles, { |a| OpenDB( { { a, 1 } } ) } )

           cRename   := rcvFileRsp( cRcvFile, nConnect, "SND" )
           cSendFile := ModExt( cRename, "TMP" )

           cInfo := ""

           IF ( cEvent <> NIL ) .AND. cEvent = "DC"

              IF MXCLICFI->( mxSeek( 1, { uFlags[1] } ) )

                 cliDebitos( ;
                             @TOTDEB  ,;  // Total geral dos debitos
                             @DEBPRA  ,;  // Vendas a prazo
                             @DEBPRV  ,;  // Vendas a prazo vencidas
                             @DEBDEV  ,;  // Devolucoes a prazo
                             @DEBDUP  ,;  // Duplicatas em aberto
                             @DEBDPT  ,;  // Duplicatas em desconto
                             @DEBATR  ,;  // Duplicatas em atraso
                             @DEBCHQ  ,;  // Cheques nao depositados
                             @DEBCHD  ,;  // Cheques devolvidos
                             @DEBCHT  ,;  // Cheques com terceiros
                             @DEBRCP  ,;  // Recebimentos parciais
                             uFlags[2] ;
                           )

              ENDIF

              cInfo += "TOTDEB=" + Str( TOTDEB, 12, 2 ) + _NL
              cInfo += "DEBPRA=" + Str( DEBPRA, 12, 2 ) + _NL
              cInfo += "DEBPRV=" + Str( DEBPRV, 12, 2 ) + _NL
              cInfo += "DEBDEV=" + Str( DEBDEV, 12, 2 ) + _NL
              cInfo += "DEBDUP=" + Str( DEBDUP, 12, 2 ) + _NL
              cInfo += "DEBDPT=" + Str( DEBDPT, 12, 2 ) + _NL
              cInfo += "DEBATR=" + Str( DEBATR, 12, 2 ) + _NL
              cInfo += "DEBCHQ=" + Str( DEBCHQ, 12, 2 ) + _NL
              cInfo += "DEBCHD=" + Str( DEBCHD, 12, 2 ) + _NL
              cInfo += "DEBCHT=" + Str( DEBCHT, 12, 2 ) + _NL
              cInfo += "DEBRCP=" + Str( DEBRCP, 12, 2 ) + _NL

           ELSE

              cInfo += "P=" + CHR_SEP + "C" + CHR_SEP + cAlias + CHR_SEP + _NL
              cInfo += "C=" + CHR_SEP + StrZero( nConnect, 3 ) + CHR_SEP + _NL

              cDefAlias := "MX" + cAlias + "CFI"

              FOR nCount := 1 TO Len( aConsult )

                 cInfo += "N=" + CHR_SEP + StrZero( nCount, 2 ) + CHR_SEP + _NL

                 IF aConsult[ nCount, RCV_CONS_SQL ]

                    sqlNew( cDefAlias )

                    FOR nField := 1 TO Len( aFields )
                       olMsgWait( "realizando consulta" + If( ValType( uKey ) $ "CN", " (" + UtoC( uKey ) + ")", "" ) )
                       sqlField( StrTran( aFields[ nField, 1 ], cDefAlias + "->", "" ) )
                    NEXT

                    sqlWhere( aConsult[ nCount, RCV_CONS_FOR ] )

                    aResult := {}

                    cSql := sqlSelect()

                    IF IsDef( "CSWLOG" )
                       mxFAddLine( CSW_SQLLOG, cSql )
                    ENDIF

                    IF sqlExecute( cSql, @aResult, .F., NIL, NIL, .T., .T. )
                       cswRetItens( @cInfo, cDefAlias, aFields, aResult, "realizando consulta" + If( ValType( uKey ) $ "CN", " (" + UtoC( uKey ) + ")", "" ) )
                    ENDIF

                 ELSE

                    nOrder := aConsult[ nCount, RCV_CONS_ORDER ]
                    uKey   := aConsult[ nCount, RCV_CONS_SEEK  ]
                    cWhile := aConsult[ nCount, RCV_CONS_WHILE ]
                    cFor   := aConsult[ nCount, RCV_CONS_FOR   ]

                    DO CASE
                       CASE ( cDefAlias )->( Type( mxIndexKey( nOrder ) ) ) = "N" ; uKey := Val( uKey )
                       CASE ( cDefAlias )->( Type( mxIndexKey( nOrder ) ) ) = "D" ; uKey := CtoD( uKey )
                    ENDCASE

                    IF ( cDefAlias )->( mxSeek( nOrder, uKey ) )

                       IF cFor = NIL .OR. Empty( cFor )
                          cFor := ".T."
                       ENDIF

                       IF At( "->", cWhile ) = 0
                          cWhile := cDefAlias + "->( " + cWhile + " )"
                       ENDIF

                       IF At( "->", cFor ) = 0
                          cFor := cDefAlias + "->( " + cFor + " )"
                       ENDIF

                       DO WHILE &cWhile .AND. ( cDefAlias )->( !Eof() )

                          IF ! &cFor
                             DbNext ( cDefAlias )
                          ENDIF

                          IF &( cDefAlias + "->CFINLJ" + cAlias ) = nConnect
                             DbNext ( cDefAlias )
                          ENDIF

                          DO CASE
                             CASE ! lItens

                                  olMsgWait( "realizando consulta" + If( ValType( uKey ) $ "CN", " (" + UtoC( uKey ) + ")", "" ) )

                                  cInfo += "->" + _NL

                                  FOR nField := 1 TO Len( aFields )
                                     IF ValType( aFields[ nField ] ) = "A" .AND. ValType( aFields[ nField, 2 ] ) = "C" .AND. Left( aFields[ nField, 2 ], 3 ) = "{||"
                                        cField := &( aFields[ nField, 2 ] )
                                        cField := Eval( cField )
                                     ELSE
                                        cField := &( aFields[ nField, 1 ] )
                                     ENDIF
                                     cInfo += Trim( UtoC( cField ) ) + _NL
                                  NEXT

                                  cInfo += "<-" + _NL

                             CASE cAlias = "PED"

                                  sqlNew( "MXITECFI" )

                                  FOR nField := 1 TO Len( aFields )
                                     olMsgWait( "realizando consulta" + If( ValType( uKey ) $ "CN", " (" + UtoC( uKey ) + ")", "" ) )
                                     IF "MXITECFI->" $ aFields[ nField, 1 ]
                                        sqlField( StrTran( aFields[ nField, 1 ], "MXITECFI->", "" ) )
                                     ENDIF
                                  NEXT

                                  sqlWhere( "CFIPEDITE = " + NumToStr( MXPEDCFI->CFICODPED ) + " AND CFINLJITE = " + NumToStr( MXPEDCFI->CFINLJPED ) )

                                  aResult := {}

                                  cSql := sqlSelect()

                                  IF IsDef( "CSWLOG" )
                                     mxFAddLine( CSW_SQLLOG, cSql )
                                  ENDIF

                                  IF sqlExecute( cSql, @aResult, .F., NIL, NIL, .T., .T. )
                                     cswRetItens( @cInfo, "MXITECFI", aFields, aResult, "realizando consulta" + If( ValType( uKey ) $ "CN", " (" + UtoC( uKey ) + ")", "" ) )
                                  ENDIF

                          ENDCASE

                          ( cDefAlias )->( mxSkip() )

                       ENDDO

                    ENDIF

                 ENDIF

              NEXT

           ENDIF

           rcvDispMsg( .T., .T., "Enviando " + AllTrim( fNameDir( cRename, 50 ) ) + "..." )

           olRename( cSendFile, { cRename, cInfo }, .T. )

      CASE cOper = ONL_OP_SENDIP

           IF sndMaster() .AND. ValType( uFlags ) = "C"

              sndAddConnection( ;
                                nConnect                            ,;
                                Left( uFlags, At( "", uFlags ) -1 ),;
                                Subs( uFlags, At( "", uFlags ) +1 ) ;
                              )
           ENDIF

           cTrans := ""

      CASE cOper = ONL_OP_SELECT

           IF sndMaster() .AND. Len( aGetInfo ) > 0

              aResult := {}

              IF sqlExecute( aGetInfo[ 1 ], @aResult, .F., "CS_LOJA" ) .AND. Len( aResult ) > 0

                 rcvSqlResult( cRcvFile, nConnect, aResult )

              ENDIF

           ENDIF

      OTHERWISE

           IF sndMaster()

              IF cOper = ONL_OP_GETINFO

                 // Envia as lojas do grupo on-line, identificando as conectadas.

                 cInfo := "C="

                 FOR nPos := 1 TO Len( sndConnections() )

                    cInfo += NumToStr( sndConnections()[ nPos, ONL_CONN_NUM ] )

                    IF At( StrZero( sndConnections()[ nPos, ONL_CONN_NUM ], 3 ), MemoRead( "CONEXAO\MXCNXCFI.TXT" ) ) > 0
                       cInfo += "#"
                    ENDIF

                    cInfo += CHR_SEP

                 NEXT

                 nPos := aScan( aGetInfo, { |x| Left( x, 2 ) = "C=" } )

                 IF nPos = 0
                    nPos := aScan( aGetInfo, { |x| Left( x, 2 ) = "K=" } )
                    aGetInfo := aInsert( aGetInfo, cInfo, nPos +1 )
                 ELSE
                    aGetInfo[ nPos ] := cInfo
                 ENDIF

                 // Utilizado p/ consulta de estoque qdo utiliza
                 // pedido de entrega.

                 IF CFIURECTR <> "N"
                    rcvAddOpen( aFiles, "IPE" )
                    rcvAddOpen( aFiles, "PET" )
                 ENDIF

                 IF CFIUCTCTR = "N"
                    rcvAddOpen( aFiles, "TRF" )
                    rcvAddOpen( aFiles, "ITF" )
                 ENDIF

              ENDIF

              // Utilizado p/ bloquear clientes c/ cheques devolvidos
              // ou duplicatas em atraso.

              IF Left( CFIBACCTR, 1 ) = "S"

                 lSeek := .F.

                 aEval( RCV_BLK_CLI, { |x| lSeek .OR. ( lSeek := ( aScan( aFiles, x ) > 0 ) ) } )

                 IF lSeek
                    rcvAddOpen( aFiles, "CLE" )
                    rcvAddOpen( aFiles, "CLI" )
                    aEval( RCV_BLK_CLI, { |x| rcvAddOpen( aFiles, x ) } )
                 ENDIF

              ENDIF

           ENDIF

           IF Len( aProcess ) > 0

              IF ! sndMaster() .AND. aScan( aFiles, "CFG" ) > 0
                 aArqNet := Directory( "MXNET*.TMP" )
                 aEval( aArqNet, { |f| fClose( fCreate( StrTran( f[1], "NET", "CFG" ) ) ) } )
              ENDIF

              FOR nCount := 1 TO Len( aProcess )

                 cSort := "0"

                 IF aScan( aRecvRelation, { |x| x[ RL_ALIAS_CHILD ] = aProcess[ nCount, RCV_ALIAS ] } ) > 0
                    cSort := "2"
                 ELSEIF aScan( aRecvRelation, { |x| x[ RL_ALIAS_HEADER ] = aProcess[ nCount, RCV_ALIAS ] } ) > 0
                    cSort := "1"
                 ENDIF

                 cSort += aProcess[ nCount, RCV_ALIAS ] + StrZero( nCount, 5 )

                 aProcess[ nCount, RCV_SORT ] := cSort

                 IF foundStr( aProcess[ nCount, RCV_ALIAS ], "FCO|IFC" )
                    rcvAddOpen( aFiles, "PED" )
                    rcvAddOpen( aFiles, "RCP" )
                    rcvAddOpen( aFiles, "IFC" )
                 ENDIF

                 IF aProcess[ nCount, RCV_ALIAS ] = "PET"
                    rcvAddOpen( aFiles, "DUP" )
                    rcvAddOpen( aFiles, "MDP" )
                    rcvAddOpen( aFiles, "PCL" )
                    rcvAddOpen( aFiles, "FER" )
                    rcvAddOpen( aFiles, "PED" )
                    rcvAddOpen( aFiles, "TRF" )
                 ENDIF

                 IF aProcess[ nCount, RCV_ALIAS ] = "EST"
                    rcvAddOpen( aFiles, "LIS" )
                    rcvAddOpen( aFiles, "TES" )
                 ENDIF

                 IF aProcess[ nCount, RCV_ALIAS ] = "TES"
                    rcvAddOpen( aFiles, "CSC" )
                 ENDIF

                 IF aProcess[ nCount, RCV_ALIAS ] = "NOE"
                    rcvAddOpen( aFiles, "NCM" )
                 ENDIF

                 aFields := aProcess[ nCount, RCV_FIELDS ]

                 rcvAddOpen( aFiles, "ITF", sndMaster() .AND. Len( aFields ) = 1 .AND. Right( aFields[ 1, 1 ], 12 ) = "TRF:COD_CONF" )

              NEXT
              
              rcvAddOpen( aFiles, "ATU" )

              vDef( @cTrans, "RECEIVER" )

              IF Right( cTrans, 10 ) = "RCV_UPDTRF" .AND. ! sndMaster() .AND. RCV_TRF_AUTO
                 rcvAddOpen( aFiles, "NOT" )
                 rcvAddOpen( aFiles, "ITN" )
                 rcvAddOpen( aFiles, "ITF" )
                 rcvAddOpen( aFiles, "COV" )
                 rcvAddOpen( aFiles, "FCV" )
                 rcvAddOpen( aFiles, "COD" )
                 rcvAddOpen( aFiles, "CPG" )
                 rcvAddOpen( aFiles, "PET" )
                 rcvAddOpen( aFiles, "IPE" )
                 rcvAddOpen( aFiles, "MPE" )
                 rcvAddOpen( aFiles, "LIS" )
                 rcvAddOpen( aFiles, "MTC" )
              ENDIF

              rcvAddOpen( aFiles, "LOJ" )

              aProcess := aSort( aProcess, NIL, NIL, { |x,y| x[ RCV_SORT ] < y[ RCV_SORT ] } )

              IF REPAGE >= 0 .AND. ( rcvOpenAGE() <> NIL )
                 bExecute := rcvOpenAGE()
                 Eval( bExecute, REPAGE )
              ENDIF

              FOR nCount := 1 TO Len( aFiles )
                 IF ! foundStr( aFiles[ nCount ], TAB_ComImagens )
                    OpenDB( { { aFiles[ nCount ], 1 } } )
                 ENDIF
              NEXT

              IF mxIn( cOper, { ONL_OP_GETINFO, ONL_OP_GETDIRECT } ) .AND. ( C_ALIAS <> "COD" )
                 lNoTrans := .T.
              ENDIF

              aRecvSend    := {}
              aRecvNoUpd   := {}
              aUpdPetDup   := {}
              nFcoUpdate   := 0
              nNotUpdate   := 0
              nCupUpdate   := 0
              lAtualizaCod := .F.

              IF cTrans = "OL_BOLETO_PET"
                 sndActive( .T., { "DUP","MDP" } )
                 sndForceConnection( nFLoja )
              ENDIF

              aAux    := {}
              aDelPcl := {}

              FOR nCount := 1 TO Len( aProcess )
                 IF aProcess[ nCount, RCV_ALIAS ] = "PCL" .AND. aProcess[ nCount, RCV_OPER ] = ONL_OP_DELETE .AND. aProcess[ nCount, RCV_ORDER ] = 1
                    aAdd( aDelPcl, aProcess[ nCount ] )
                 ELSE
                    aAdd( aAux, aProcess[ nCount ] )
                 ENDIF
              NEXT

              IF Len( aDelPcl ) > 0
                 aProcess := aClone( aAux )
              ENDIF

              cTransOpen := cTrans

              IF Left( cTransOpen, 4 ) <> "RCV_"
                 cTransOpen := "RCV_" + cTransOpen
              ENDIF

              mxTran( cTransOpen, aFiles, NIL, lNoTrans )

              olMsgWait( "", 0 )

              IF Len( aDelPcl ) > 0
                 rcvDelPcl( aDelPcl )
              ENDIF

              cAliasOLD := "MX???CFI"
              cMsgOLD   := "???%"

              nTotProcess  := 1
              nItemProcess := 0
              lRcvProduto  := ( sndMaster() .AND. aScan( aProcess, { |p| p[ RCV_ALIAS ] = "LIS" .AND. p[ RCV_OPER ] = ONL_OP_INSERT } ) > 0 )

              IF lRcvProduto
                 // Este procedimento serve para TINTAS produzidas na maquina DEVOLVIDAS.
                 // Neste caso os processos sao divididos em 2 etapas:
                 // 1) Primeiro processa-se a inclusao na lista de produtos dos novos itens referentes a tintas produzidas
                 // 2) Depois executa-se os processos restantes, inclusive de baixa de estoque.
                 nTotProcess := 2
              ENDIF

              FOR nProcess := 1 TO nTotProcess

                 FOR nCount := 1 TO Len( aProcess )

                    cAlias    := aProcess[ nCount, RCV_ALIAS  ]
                    cOper     := aProcess[ nCount, RCV_OPER   ]
                    nOrder    := aProcess[ nCount, RCV_ORDER  ]
                    uKey      := aProcess[ nCount, RCV_KEY    ]
                    aFields   := aProcess[ nCount, RCV_FIELDS ]
                    cFieldKey := aProcess[ nCount, RCV_FKEY   ]
                    lFClear   := aProcess[ nCount, RCV_FCLEAR ]
                    nFLoja    := aProcess[ nCount, RCV_FLOJA  ]

                    IF nTotProcess = 2
                       IF nProcess = 1 .AND. cAlias <> "LIS"
                          LOOP
                       ELSEIF nProcess = 2 .AND. cAlias = "LIS"
                          LOOP
                       ENDIF
                    ENDIF

                    cMsg := Tran( Int( ++ nItemProcess / Len( aProcess ) * 100 ), "999%" )

                    IF cMsgOLD <> cMsg
                       rcvDispMsg( .F., .F., cMsg )
                       cMsgOLD := cMsg
                    ENDIF

                    cAlias := "MX" + cAlias + "CFI"

                    IF C_ALIAS = "CPE"  // Na versao em xHarbour nao tem
                       LOOP             // mais o MXCPECFI
                    ENDIF

                    IF CFICNXCTR = "S"
                       IF MXLOJCFI->CFICODLOJ <> CFINLJCTR
                          MXLOJCFI->( mxSeek( 1, { CFINLJCTR } ) )
                       ENDIF
                       IF MXLOJCFI->( !Eof() ) .AND. MXLOJCFI->CFIIMVLOJ = "N" .AND. aScan( olGetTabAliasMov(), { |cMov| Subs( cMov, 3, 3 ) = C_ALIAS } ) <> 0
                          LOOP
                       ENDIF
                    ENDIF

                    IF C_ALIAS = "CSC"
                       lAtualizaCod := .T.
                    ENDIF

                    IF C_ALIAS = "COD"

                       // Solicitacao de codigo.

                       IF cOper <> ONL_OP_GETINFO
                          LOOP
                       ENDIF

                       nAdd := 1

                       IF At( "[", uKey ) > 0

                          nAdd := Subs( uKey, At( "[", uKey ) )
                          uKey := StrTran( uKey, nAdd, "" )

                          aProcess[ nCount, RCV_KEY ] := uKey

                          nAdd := Val( ClearMasc( nAdd, "[]" ) )
                          nAdd := GetNoEmpty( nAdd, 1 )

                       ENDIF

                       lSeek := .T.

                       codSequencia( uKey, NIL, NIL, .T., nAdd )

                    ELSEIF foundStr( C_ALIAS, "SNH|GCO" )

                       ( cAlias )->( mxTop() )

                       lSeek := .T.

                    ELSEIF C_ALIAS = "CFG"

                       IF foundStr( Subs( uKey, 4, 3 ), "NLJ|CNX|MLJ|SER|RAZ|NOM|NCG" )
                          LOOP
                       ENDIF

                       lSeek := MXCFGCFI->( mxSeek( 1, { UtoC( uKey ) } ) )

                    ELSEIF C_ALIAS = "ITB" .AND. cTrans = "GRAVA_CNAB"

                       lSeek := .F.

                    ELSEIF C_ALIAS = "LOG"

                       lSeek := .F.

                    ELSE

                       IF ( cTrans <> "CNX_REENVIA" ) .AND. Empty( uKey )
                          LOOP
                       ENDIF

                       DO CASE
                          CASE ( cAlias )->( Type( mxIndexKey( nOrder ) ) ) = "N"
                               uKey := Val( uKey )
                          CASE ( cAlias )->( Type( mxIndexKey( nOrder ) ) ) = "D"
                               uKey := CtoD( uKey )
                          CASE ! Empty( cFieldKey )
                               uKey := Left( uKey, Len( ( cAlias )->&( "(" + cFieldKey + ")" ) ) )
                       ENDCASE

                       IF CFICNXCTR = "S" .AND. C_ALIAS = "CLI" .AND. nOrder = 1
                          nCliLoj := cliLoja( uKey )
                          IF nCliLoj <> 0
                             IF MXLOJCFI->CFICODLOJ <> CFINLJCTR
                                MXLOJCFI->( mxSeek( 1, { CFINLJCTR } ) )
                             ENDIF
                             IF MXLOJCFI->( !Eof() ) .AND. MXLOJCFI->CFIICCLOJ = "N" .AND. ( nCliLoj <> CFINLJCTR )
                                LOOP
                             ENDIF
                          ENDIF
                       ENDIF

                       IF ! rcvConfSeek( C_ALIAS, aProcess ) .AND. ( ! foundSTr( cTrans, "GRAVA_DEV|CANC_PED|GRAVA_NOTA_DEV" ) )
                          lSeek := .F.
                       ELSEIF ( ( cTrans = "GRAVA_FCX" ) .OR. ( cTrans = "CNX_REENVIA" .AND. C_ALIAS = "FCX" ) ) .AND. CFISFCCTR = "S"
                          lSeek := MXFCXCFI->( mxSeek( 4, { nFLoja, Val( Subs( uKey, 9, 3 ) ), StoD( Left( uKey, 8 ) ) } ) )
                       ELSE
                          lSeek := rcvProcura( cAlias, nOrder, uKey, nFLoja, aFields )
                       ENDIF

                    ENDIF

                    IF cOper = ONL_OP_DELETE

                       IF lSeek .AND. rcvVldUpd( cAlias, cOper, lSeek, aFields, cTrans )

                          rcvDelRelation( aProcess, nCount, nFLoja, @lSeek )

                          IF C_ALIAS = "ITA"
                             lSeek := .T.
                          ENDIF

                          IF lSeek

                             IF mxIn( C_ALIAS, RCV_BLK_CLI )
                                cswCliDefBloqueio( C_ALIAS, @aBlkCli )
                             ENDIF
                             IF mxIn( C_ALIAS, RCV_USE_LOE )
                                GrvLoe( C_ALIAS )
                             ENDIF
                             IF C_ALIAS = "TPR"
                                UpdPrecos( "-", MXTPRCFI->CFICODTPR )
                             ELSEIF C_ALIAS = "TES"
                                csCtrAtuCodigo( "TES", "-", Str( MXTESCFI->CFICODTES, 3 ) + Str( MXTESCFI->CFINLJTES, 3 ), 2, Str( MXTESCFI->CFICODTES, 3 ), "" )
                                lAtualizaCod := .T.
                             ENDIF

                             rcvDelete( cAlias )

                          ENDIF

                       ENDIF

                    ELSEIF mxIn( cOper, { ONL_OP_GETINFO, ONL_OP_GETDIRECT } )

                       ( cAlias )->( rcvGetInfo( aFields ) )

                    ELSEIF ! rcvVldUpd( cAlias, cOper, lSeek, @aFields, cTrans )

                       IF C_ALIAS = "COR" .AND. cTrans = "INC_FRM"
                          EXIT
                       ENDIF

                    ELSE

                       IF rcvDelValid( cAlias, lSeek, cTrans )
                          rcvDelRelation( aProcess, nCount, nFLoja, @lSeek )
                       ENDIF

                       IF ! lSeek .AND. cTrans = "CNX_ENVEST"
                          cOper := ONL_OP_INSERT
                       ENDIF

                       lNew := .F.

                       IF lSeek

                          IF mxIn( C_ALIAS, RCV_BLK_CLI )
                             cswCliDefBloqueio( C_ALIAS, @aBlkCli )
                          ENDIF

                          IF C_ALIAS = "PET" .AND. vldField( "CFITIPPET" ) = "PED"

                             IF foundStr( cTrans, "GRVNOT_PET|EXC_NOT|RCV_UPDPET|ATU_DIGDUP" ) .AND. Empty( Subs( vldField( "CFIFLGPET" ), 3, 1 ) )  // Simples Remessa
                                aAdd( aUpdPetDup, { vldField( "CFICODPET" ),;
                                                    vldField( "CFINLJPET" ),;
                                                    vldField( "CFIDUPPET" ),;
                                                    vldField( "CFINFVPET" ),;
                                                    vldField( "CFICLIPET" ) ;
                                                  } )
                             ENDIF

                          ENDIF

                          IF foundStr( C_ALIAS, "SNH|GCO" ) .AND. ( cAlias )->( EmptyDb() )

                             lNew := .T.
                             ( cAlias )->( mxAppend( NIL, .F. ) )

                          ELSEIF foundStr( C_ALIAS, TAB_ComImagens )

                             sqlFieldsStart( "I" )

                             lSeek := .F.
                             lNew  := .T.

                          ELSE

                             ( cAlias )->( mxRecLock( NIL, .F. ) )

                             IF C_ALIAS = "FCO" .AND. cOper = ONL_OP_UPDATE
                                nNotUpdate := ( cAlias )->CFINOTFCO
                                nCupUpdate := ( cAlias )->CFINCFFCO
                             ENDIF

                          ENDIF

                       ELSEIF cOper = ONL_OP_UPDATE .AND. ! lFClear

                          LOOP

                       ELSE

                          lNew := .T.

                          IF foundStr( C_ALIAS, TAB_ComImagens )
                             sqlFieldsStart( "I" )
                          ELSE
                             ( cAlias )->( mxAppend( NIL, .F. ) )
                          ENDIF

                       ENDIF

                       IF cAlias <> cAliasOLD
                          olMsgWait( "Gravando dados em " + cAlias, 0 )
                          cAliasOLD := cAlias
                       ENDIF

                       rcvReplFields( cAlias, cTrans, aFields, aNoRcv, lFClear, lNew, cRcvFile, nConnect )

                       IF cOper = ONL_OP_INSERT .AND. mxIn( C_ALIAS, RCV_USE_LOE )
                          GrvLoe( C_ALIAS, "ExcLoe" )
                       ENDIF

                       IF C_ALIAS = "NOE" .AND. foundStr( MXNOECFI->CFISTANOE, "Proce|Cance" )

                          IF sndMaster() .AND. ( Left( CFIFCPCTR, 1 ) <> "N" )
                             cAux := "P"
                          ELSE
                             cAux := " "
                          ENDIF

                          cswIncAtualizacao( "NOE"                                                                                 ,;
                                             strJoin( { MXNOECFI->CFICODNOE, MXNOECFI->CFINLJNOE, MXNOECFI->CFISTANOE }, NIL, "|" ),;
                                             cAux                                                                                  ,;
                                             "1"                                                                                   ,;
                                             NIL                                                                                   ,;
                                             .T. )
                                             
                       ENDIF

                       IF sndMaster()

                          IF C_ALIAS = "TRF"

                             IF Right( cTrans, 10 ) <> "RCV_UPDTRF"

                                //IF ! lSeek .OR. ( Right( MXTRFCFI->CFISTATRF, 2 ) <> "OK" )
                                IF ! lSeek .OR. ( MXTRFCFI->CFISTATRF <> "SolOK" )

                                   cswIncAtualizacao( "TRF"                                                            ,;
                                                      strJoin( { MXTRFCFI->CFICODTRF, MXTRFCFI->CFINLJTRF }, NIL, "|" ),;
                                                      cOper                                                            ,;
                                                      "1" )

                                ENDIF

                             ENDIF

                          ELSEIF C_ALIAS = "PET"

                             IF MXPETCFI->CFIDEPPET <> 0

                                cswIncAtualizacao( "PET"                                                            ,;
                                                   strJoin( { MXPETCFI->CFICODPET, MXPETCFI->CFINLJPET }, NIL, "|" ),;
                                                   cOper                                                            ,;
                                                   "1"                                                              ,;
                                                   strJoin( { cTrans, nConnect }, NIL, "|" ) )

                             ENDIF

                          ELSEIF C_ALIAS = "FCO"

                             vDef( @nNotUpdate, 0 )
                             vDef( @nCupUpdate, 0 )

                             cswIncAtualizacao( "FCO"                                                            ,;
                                                strJoin( { MXFCOCFI->CFICODFCO, MXFCOCFI->CFINLJFCO }, NIL, "|" ),;
                                                " "                                                              ,;
                                                "1"                                                              ,;
                                                strJoin( { nNotUpdate, nCupUpdate }, NIL, "|" ) )

                          ENDIF

                       ELSEIF C_ALIAS = "TPR"

                          MXTPRCFI->( mxReplace( "ATV", If( confTprLoja( sndDefConnection() ), "S", "N" ) ) )

                          IF cOper = ONL_OP_INSERT
                             UpdPrecos( "-", MXTPRCFI->CFICODTPR )
                          ENDIF

                       ENDIF

                       IF C_ALIAS = "PET" .AND. Empty( MXPETCFI->CFISEQPET )
                          MXPETCFI->( mxReplace( "SEQ", petDefSequencia() ) )
                       ENDIF

                       IF foundStr( C_ALIAS, TAB_ComImagens )
                          sqlExeWrite( "CS_LOJA", cAlias, NIL, .T. )
                       ELSE
                          ( cAlias )->( mxUnlock(.F.) )
                       ENDIF

                       IF C_ALIAS = "TES" .AND. cOper = ONL_OP_INSERT

                          csCtrAtuCodigo( "TES", "+", Str( MXTESCFI->CFICODTES, 3 ) + Str( MXTESCFI->CFINLJTES, 3 ), 2, Str( MXTESCFI->CFICODTES, 3 ), "" )
                          lAtualizaCod := .T.

                       ELSEIF nProcess = 1 .AND. C_ALIAS = "LIS" .AND. lRcvProduto .AND. cOper = ONL_OP_INSERT

                          cswIncAtualizacao( "LIS"              ,;
                                             MXLISCFI->CFICODLIS,;
                                             cOper              ,;
                                             "1" )

                       ENDIF

                       IF nCount = Len( aProcess )
                          olMsgWait( "", 0 )
                       ENDIF

                    ENDIF

                    IF sndMaster() .AND. nFcoUpdate = 0 .AND. C_ALIAS = "FCO" .AND. ( cOper <> ONL_OP_DELETE )
                       nFcoUpdate := nCount
                    ENDIF

                 NEXT

              NEXT

              IF Right( cTrans, 10 ) = "RCV_UPDTRF" .AND. ! sndMaster() .AND. RCV_TRF_AUTO .AND. Left( MXTRFCFI->CFISTATRF, 1 ) = "E"

                 cswIncAtualizacao( "TR2"                                                            ,;
                                    strJoin( { MXTRFCFI->CFICODTRF, MXTRFCFI->CFINLJTRF }, NIL, "|" ),;
                                    "U"                                                              ,;
                                    "1" )

              ENDIF

              IF Len( aUpdPetDup ) > 0
                 FOR nCount := 1 TO Len( aUpdPetDup )
                    IF MXPETCFI->( mxSeek( 1, { aUpdPetDup[ nCount, 1 ] } ) )
                       rcvPETDupls( cTrans, aUpdPetDup[ nCount, 3 ], aUpdPetDup[ nCount, 4 ], aUpdPetDup[ nCount, 5 ] )
                    ENDIF
                 NEXT
              ENDIF

              IF ! Empty( GetActTrans() )
                 mxTran( cTransOpen, NIL, NIL, lNoTrans )
              ENDIF

              IF lAtualizaCod
                 SaveScrLastRow()
                 csCtrAtuCodigo( NIL, NIL, NIL, NIL, NIL, NIL, .T., .T., .T. )
                 RestScrLastRow()
              ENDIF

              IF cTrans = "OL_BOLETO_PET"
                 sndActive( .F. )
                 sndForceConnection( 0 )
              ENDIF

              IF rcvOpenAGE() <> NIL
                 bExecute := rcvOpenAGE()
                 Eval( bExecute, -1 )
              ENDIF

              // Atualiza informacoes q pertencem as lojas, pois foram
              // apenas atualizadas no MASTER.

              IF Len( aRecvSend ) > 0

                 sndActive( .T. )
                 sndStart( "RCV_SEND" )

                 FOR nCount := 1 TO Len( aRecvSend )

                    olMsgWait( "atualizando opera‡”es nas lojas", 1 )

                    ( aRecvSend[ nCount, RCV_SEND_TAB ] )->( mxGoTo( aRecvSend[ nCount, RCV_SEND_REC ] ) )
                    ( aRecvSend[ nCount, RCV_SEND_TAB ] )->( sndUpdate() )
                    ( aRecvSend[ nCount, RCV_SEND_TAB ] )->( sndPost( NIL, aRecvSend[ nCount, RCV_SEND_NLJ ] ) )

                 NEXT

                 sndEnd()
                 sndRename()
                 sndActive( .F. )

              ENDIF

           ENDIF

   ENDCASE

   rcvDispMsg( .F., .T., PadR( "ok", 7 ) )

   IF ! mxIn( cOper, { ONL_OP_CONSULT, ONL_OP_FCO, ONL_OP_NFP, ONL_OP_SELECT } )
      rcvWriInfo( cRcvFile, nConnect, cOper = ONL_OP_GETDIRECT )
   ENDIF

   rcvRepass( aRcvFile, nConnect )

   IF ! mxIn( cOper, { ONL_OP_CONSULT, ONL_OP_FCO, ONL_OP_NFP } )

      rcvUpdTRF()
      rcvUpdTRFPET()
      rcvUpdPET()
      rcvUpdNOE()
      rcvUpdFCO()
      rcvUpdLIS()

      IF sndMaster() .AND. Left( CFIBACCTR, 1 ) <> "N" .AND. aBlkCli <> NIL .AND. Len( aBlkCli ) > 0
         sndActive( .T. )
         cliBloqueioProcessa( aBlkCli )
         sndActive( .F. )
      ENDIF

   ENDIF

   IF rcvMaqDir() <> NIL
      bExecute := rcvMaqDir()
      Eval( bExecute, "" )
   ENDIF

   IF lDir
      aEval( sndDir(), { |x| mxClose( "MX" + x[1] + "CFI" ) } )
   ENDIF

   IF ( cTrans <> NIL ) .AND. Left( cTrans, 7 ) = "GRVCEP_"
      mxClose( "MXCEPCFI" )
   ENDIF

   mxClose( { "MXCODCFI","MXCFGCFI","DIC" } )

   olMsgWait( "", 0 )

   lReturn := .T.

RETURN( lReturn )



STATIC FUNCTION rcvConfSeek( cAlias, aProcess )

   LOCAL lReturn := .T.

   IF foundStr( cAlias, "ITE|IFC|IPE|ITS|ITC|ITF" )
      DO CASE
         CASE cAlias = "ITE" ; lReturn := ( aScan( aProcess, { |x| x[ RCV_ALIAS ] = "PED" } ) = 0 )
         CASE cAlias = "IFC" ; lReturn := ( aScan( aProcess, { |x| x[ RCV_ALIAS ] = "FCO" } ) = 0 )
         CASE cAlias = "IPE" ; lReturn := ( aScan( aProcess, { |x| x[ RCV_ALIAS ] = "PET" } ) = 0 )
         CASE cAlias = "ITS" ; lReturn := ( aScan( aProcess, { |x| x[ RCV_ALIAS ] = "NOE" } ) = 0 )
         CASE cAlias = "ITC" ; lReturn := ( aScan( aProcess, { |x| x[ RCV_ALIAS ] = "COM" } ) = 0 )
         CASE cAlias = "ITF" ; lReturn := ( aScan( aProcess, { |x| x[ RCV_ALIAS ] = "TRF" } ) = 0 )
      ENDCASE
   ENDIF

RETURN( lReturn )



STATIC PROCEDURE cswRetItens( cInfo, cDefAlias, aFields, aResult, cMsg )

   LOCAL nReplace, nPos, nField

   FOR nReplace := 1 TO Len( aResult )

      nPos := 0

      cInfo += "->" + _NL

      FOR nField := 1 TO Len( aFields )

         olMsgWait( cMsg )

         IF cDefAlias + "->" $ aFields[ nField, 1 ]
            cInfo += Trim( UtoC( aResult[ nReplace, ++ nPos ] ) ) + _NL
         ELSE
            cInfo += Trim( UtoC( &( aFields[ nField, 1 ] ) ) ) + _NL
         ENDIF

      NEXT

      cInfo += "<-" + _NL

   NEXT

RETURN



STATIC PROCEDURE rcvRepass( aRcvFile, nConnect )

   LOCAL cFile := aRcvFile[ RCV_FILE_ARQ ]
   LOCAL cInfo := aRcvFile[ RCV_FILE_TXT ]

   LOCAL nSend, cSequence, cSendFile, cRename

   IF sndMaster() .AND. olRcvIsRepass( cFile )

      FOR nSend := 1 TO Len( sndConnections() )

         IF nConnect <> sndConnections()[ nSend, ONL_CONN_NUM ]

            cSequence := sndSequence()

            IF ValType( cSequence ) = "N"
               cSequence := StrZero( cSequence, 6 )
            ENDIF

            sndConfSequence( cSequence )

            cRename   := sndFolder() + olChrLoja( sndConnections()[ nSend, ONL_CONN_NUM ] ) + "M" + cSequence + ".SND"
            cSendFile := ModExt( cRename, "TMP" )

            rcvDispMsg( .T., .T., "Enviando " + AllTrim( fNameDir( cRename, 50 ) ) + "..." )
            olRename( cFile, { cRename, cInfo }, .F. )
            rcvDispMsg( .F., .T., "ok" )

         ENDIF

      NEXT

   ENDIF

RETURN



STATIC PROCEDURE rcvAddOpen( aFiles, cAlias, lCond )

   LOCAL aAppend := {}
   LOCAL nCount

   vDef( @lCond, .T. )

   IF ! lCond .OR. cAlias = "CPE"
      RETURN( .F. )
   ENDIF

   IF Empty( cAlias )
      mxErrorLog( "CSW:rcvAddOpen - Empty Alias", "Arquivo: " + cswActFile() + _NL + "Transacao: " + cRecvTrans )
      RETURN( .F. )
   ENDIF

   aAdd( aAppend, cAlias )

   IF foundStr( cAlias, "LIS|TPR" )
      aAppend( aAppend, { "TPR","LIS","PRC","EST" } )
   ENDIF

   IF mxIn( cAlias, RCV_BLK_CLI )
      aAppend( aAppend, { "CLE","CLI" } )  // Devido a cliDefBloqueio().
   ENDIF

   aAddC( aAppend, "ITF", cAlias = "TRF" .AND. Select( "MXITFCFI" ) > 0 )     // Devido a rcvVldUpd().
   aAddC( aAppend, "IPE", cAlias = "PET" .AND. Select( "MXIPECFI" ) > 0 )     // Devido a rcvVldUpd().
   aAddC( aAppend, "LOJ", foundStr( cAlias, "CLI" ) .AND. CONF_NOSEND  )      // Devido a rcvVldUpd().
   aAddC( aAppend, "LIS", cAlias = "ITE" )                                    // Devido a rcvProcura().
   aAddC( aAppend, "LOE", mxIn( cAlias, RCV_USE_LOE ) )

   FOR nCount := 1 TO Len( aAppend )

      IF aScan( aFiles, { |f| f = aAppend[ nCount ] } ) = 0
         aAdd( aFiles, aAppend[ nCount ] )
      ENDIF

   NEXT

RETURN( NIL )



STATIC PROCEDURE rcvGetInfo( aFields )

   LOCAL lFStart := .T.
   LOCAL cAlias  := Alias()

   LOCAL cField, nField, nPos, nArr, nConnection
   LOCAL nQtde, cVend, nMin, nMax

   IF sndMaster() .AND. Len( aFields ) = 1 .AND. aFields[ 1, 1 ] = "MXLISCFI->CFIESTLIS"

      // Consulta de estoque.

      nArr := aScan( aGetInfo, "MXLISCFI->CFIESTLIS" )

      aGetInfo := aDelPos( aGetInfo, nArr )

      FOR nPos := Len( sndConnections() ) TO 1 STEP -1

         nConnection := sndConnections()[ nPos, ONL_CONN_NUM ]

         nQtde := 0
         cVend := "S"

         MXTESCFI->( mxSeek( 2, { nConnection } ) )

         DO WHILE MXTESCFI->CFINLJTES = nConnection .AND. MXTESCFI->( !Eof() )

            nQtde += EstCampo( "EST", nConnection, MXTESCFI->CFICODTES )

            IF GetNoEmpty( EstCampo( "VEN", nConnection, MXTESCFI->CFICODTES ), "N" ) = "N"
               cVend := "N"
            ENDIF

            MXTESCFI->( mxSkip() )

         ENDDO

         // Abatimento do estoque comprometido com os pedidos de entrega.

         nQtde -= petVerEst( .F., nConnection )

         aGetInfo := aInsert( aGetInfo, "EST" + StrZero( nConnection, 3 ) + "=" + ZRClear( LTrim( Str( nQtde ) ) ), nArr )
         aGetInfo := aInsert( aGetInfo, "VEN" + StrZero( nConnection, 3 ) + "=" + GetNoEmpty( cVend, "N" ), nArr )

      NEXT

   ELSEIF Len( aFields ) > 0 .AND. Right( aFields[ 1, 1 ], 3 ) = "EST"

      // Consulta de estoque minimo e maximo.

      aDelCond( aGetInfo, { |x| x = "MXESTCFI->CFIESTEST" } )
      aDelCond( aGetInfo, { |x| x = "MXESTCFI->CFIMINEST" } )
      aDelCond( aGetInfo, { |x| x = "MXESTCFI->CFIMAXEST" } )
      aDelCond( aGetInfo, { |x| x = "MXESTCFI->CFITESEST" } )
      aDelCond( aGetInfo, { |x| x = "MXESTCFI->CFICDREST" } )
      aDelCond( aGetInfo, { |x| x = "<-"                  } )

      FOR nPos := 1 TO Len( sndConnections() )

         nConnection := sndConnections()[ nPos, ONL_CONN_NUM ]

         MXTESCFI->( mxSeek( 2, { nConnection } ) )

         DO WHILE MXTESCFI->CFINLJTES = nConnection .AND. MXTESCFI->( !Eof() )

            // Abatimento do estoque comprometido com os pedidos de entrega.
            nQtde := EstCampo( "EST", nConnection, MXTESCFI->CFICODTES ) - petVerEst( .F., nConnection )

            aAdd( aGetInfo, "EST" + StrZero( nConnection, 3 ) + "=" + Str( nQtde ) )
            aAdd( aGetInfo, "MIN" + StrZero( nConnection, 3 ) + "=" + Str( EstCampo( "MIN", nConnection, MXTESCFI->CFICODTES ) ) )
            aAdd( aGetInfo, "MAX" + StrZero( nConnection, 3 ) + "=" + Str( EstCampo( "MAX", nConnection, MXTESCFI->CFICODTES ) ) )
            aAdd( aGetInfo, "TES" + StrZero( nConnection, 3 ) + "=" + Str( MXTESCFI->CFICODTES ) )
            aAdd( aGetInfo, "CDR" + StrZero( nConnection, 3 ) + "=" + MXTESCFI->CFICDRTES )

            MXTESCFI->( mxSkip() )

         ENDDO

      NEXT

      aAdd( aGetInfo, "<-" )

   ELSEIF sndMaster() .AND. Len( aFields ) = 1 .AND. Right( aFields[ 1, 1 ], 12 ) = "TRF:COD_CONF"

      // Consulta do codigo de conferencia da transferencia.

      aDelCond( aGetInfo, { |x| x = "MXTRFCFI->CFITRF:COD_CONF" } )

      aAdd( aGetInfo, "COD_CONF=" + NumToStr( MXITFCFI->( trfGeraCod( MXTRFCFI->CFICODTRF, MXTRFCFI->CFINLJTRF ) ) ) )

   ELSE

      FOR nField := 1 TO Len( aFields )

         cField := Right( aFields[ nField, 1 ], 9 )

         nPos := ( cAlias )->( FieldPos( cField ) )

         IF nPos > 0
            nArr := aScan( aGetInfo, cAlias + "->" + cField )
            IF nArr > 0
               aGetInfo[ nArr ] := Right( cField, 6 ) + "=" + ( cAlias )->( sndField( nPos ) )
            ENDIF
         ENDIF

      NEXT

   ENDIF

RETURN



STATIC PROCEDURE rcvWriInfo( cRcvFile, nConnect, lGetDirect )

   LOCAL cInfo := ""

   LOCAL cRename, cSendFile, nSendFile, nCount

   IF Len( aGetInfo ) > 0

      cRename   := rcvFileRsp( cRcvFile, nConnect, If( lGetDirect, "DIR", "SND" ) )
      cSendFile := ModExt( cRename, "TMP" )

      FOR nCount := 1 TO Len( aGetInfo )
         IF ValType( aGetInfo[ nCount ] ) = "A"
            aEval( aGetInfo[ nCount ], { |f| cInfo += f + _NL } )
         ELSE
            cInfo += aGetInfo[ nCount ] + _NL
         ENDIF
      NEXT

      rcvDispMsg( .T., .T., "Enviando " + AllTrim( fNameDir( cRename, 50 ) ) + "..." )
      olRename( cSendFile, { cRename, cInfo }, .F. )
      rcvDispMsg( .F., .T., "ok" )

   ENDIF

RETURN



STATIC PROCEDURE rcvSqlResult( cRcvFile, nConnect, aResult )

   LOCAL cInfo := "P" + CHR_SEP + ONL_OP_SELECT + CHR_SEP + _NL + "->" + _NL

   LOCAL cRename, cSendFile, nCount, nField

   cRename   := rcvFileRsp( cRcvFile, nConnect, "SND" )
   cSendFile := ModExt( cRename, "TMP" )

   FOR nCount := 1 TO Len( aResult )

      FOR nField := 1 TO Len( aResult[ nCount ] )

         cInfo += UtoC( aResult[ nCount, nField ] )

         IF nField < Len( aResult[ nCount ] )

            cInfo += "|"

         ENDIF

      NEXT

      cInfo += _NL

   NEXT

   cInfo += "<-"

   rcvDispMsg( .T., .T., "Enviando " + AllTrim( fNameDir( cRename, 50 ) ) + "..." )
   olRename( cSendFile, { cRename, cInfo }, .F. )
   rcvDispMsg( .F., .T., "ok" )

RETURN




FUNCTION rcvFiles()

   IF Empty( cRecvFiles )
      cRecvFiles := If( sndMaster(), "???L", olChrLoja() + "M" ) + "*.SND"
   ENDIF

RETURN( cRecvFiles )



STATIC FUNCTION rcvField( cField, uReplace, lClear, cTableSql, cFieldSql, cType )

   IF cFieldSql <> NIL
      cType := sqlFieldType( cTableSql, cFieldSql )
   ELSE
      cType := Type( cField )
   ENDIF

   IF lClear

      DO CASE
         CASE cType = "N"  ; uReplace := 0
         CASE cType = "D"  ; uReplace := CtoD( "" )
         CASE cType = "L"  ; uReplace := .F.
         CASE cField = NIL ; uReplace := ""
         OTHERWISE         ; uReplace := Space( Len( &cField ) )
      ENDCASE

   ELSE

      DO CASE
         CASE cType = "N" ; uReplace := Val( uReplace )
         CASE cType = "D" ; uReplace := CtoD( uReplace )
         CASE cType = "L" ; uReplace := ( uReplace = "S" )
      ENDCASE

   ENDIF

RETURN( uReplace )



PROCEDURE rcvAddRelation( aRelation )

   aAdd( aRecvRelation, aRelation )

RETURN



PROCEDURE rcvAddExec( cOper, bExec )

   aAdd( aRecvExec, { cOper, bExec } )

RETURN



PROCEDURE rcvGetFiles( aRcvFiles, aRcvPrior, aFiles )

   LOCAL nCount, cFileTmp

   aRcvFiles := {}
   aRcvPrior := {}

   aSort( aFiles,,, { |x,y| Str( x[3], 1 ) + x[4] < Str( y[3], 1 ) + y[4] } )

   FOR nCount := 1 TO Len( aFiles )

      olMsgWait( "selecionando arquivos...", 1 )

      cFileTmp := aFiles[ nCount, 4 ]

      IF GetExt( cFileTmp ) = ".DIR"
         cFileTmp := ModExt( cFileTmp, "SND" )
      ENDIF

      IF aFiles[ nCount, 3 ] = 0
         aAdd( aRcvPrior, aFiles[ nCount ] )
      ELSE
         aAdd( aRcvFiles, aFiles[ nCount ] )
      ENDIF

   NEXT

RETURN



STATIC PROCEDURE rcvDelRelation( aProcess, nCount, nConnect, lSeek )

   LOCAL aResult := {}
   LOCAL nPos    := 0
   LOCAL nAux    := 0

   LOCAL cAliasHead, cAliasItem, cSeek, cAux, cConn, cSqlTable, cWhere

   DO WHILE .T.

      nPos := aScan( aRecvRelation, { |x| x[ RL_ALIAS_HEADER ] = aProcess[ nCount, RCV_ALIAS ] }, nPos + 1 )

      IF nPos = 0
         nPos := aScan( aRecvRelation, { |x| x[ RL_ALIAS_CHILD ] = aProcess[ nCount, RCV_ALIAS ] } )
         IF nPos > 0
            lSeek := aRecvRelation[ nPos, RL_DEL_CHILD ]
         ENDIF
         EXIT
      ENDIF

      nAux := aScan( aProcess, { |x| x[ RCV_ALIAS ] = aRecvRelation[ nPos, RL_ALIAS_CHILD ] }, nCount )

      IF nAux > 0 .AND. aProcess[ nAux, RCV_OPER ] = ONL_OP_UPDATE .AND. ! aProcess[ nAux, RCV_FCLEAR ]
         LOOP
      ENDIF

      cAliasHead := "MX" + aRecvRelation[ nPos, RL_ALIAS_HEADER ] + "CFI"
      cAliasItem := "MX" + aRecvRelation[ nPos, RL_ALIAS_CHILD ]  + "CFI"

      cSeek := ( cAliasHead )->( &( aRecvRelation[ nPos, RL_KEY_HEADER ] ) )

      IF aRecvRelation[ nPos, RL_ALIAS_CHILD ] = "IFC"
         cSeek := Left( cSeek, 6 )
      ENDIF

      cAux  := Subs( cAliasItem, 3, 3 ) + cSeek

      IF aScan( aProcess, { |x| x[ RCV_ALIAS ] + Left( x[ RCV_KEY ], Len( cSeek ) ) = cAux }, nCount ) = 0
         LOOP
      ENDIF

      IF ! sndActive() .AND. Len( aRecvRelation[ nPos ] ) >= RL_SQL .AND. ! Empty( aRecvRelation[ nPos, RL_SQL ] )

         cSqlTable := rcvSqlTable( cAliasItem, @cConn )
         cWhere    := olSQLFormat( aRecvRelation[ nPos, RL_SQL ] )

         cAux := "DELETE FROM " + cSqlTable + " WHERE " + cWhere

         olMsgWait( "excluindo itens (" + aRecvRelation[ nPos, RL_ALIAS_CHILD ] + ")" )

         IF IsDef( "CSWLOG" )
            mxFAddLine( CSW_SQLLOG, cAux )
         ENDIF

         IF ! sqlExecute( cAux, NIL, .T., cConn, NIL, .T., .T. )
            Fim( 0 )
         ENDIF

         IF Select( cAliasItem ) > 0
            ( cAliasItem )->( mxDbRefresh() )
         ENDIF

      ELSE

         DO WHILE ( cAliasItem )->( cnxSeek( aRecvRelation[ nPos, RL_ORD_CHILD ], cSeek, nConnect, NIL, NIL, aRecvRelation[ nPos, RL_KEY_CHILD ] ) )

            olMsgWait( cAliasItem + cSeek )

            ( cAliasItem )->( mxDelete( NIL, .F. ) )

         ENDDO

      ENDIF

   ENDDO

RETURN



STATIC FUNCTION rcvVldUpd( cAlias, cOper, lSeek, aFields, cTrans )

   LOCAL lReturn := .T.

   LOCAL aStatus, nPosAtu, nPosNew, nCodCli, cLoja, nAux, nAux2

   IF cTrans = "CNX_REENVIA"
      RETURN( .T. )
   ENDIF

   DO CASE
      CASE C_ALIAS = "CHQ"

           IF cOper = ONL_OP_UPDATE

              IF ! foundStr( cTrans, "EXC_BORCHQ" )
                 IF lSeek
                    lReturn := ( Empty( MXCHQCFI->CFIDTDCHQ ) .OR. ! Empty( vldField( "CFIDTDCHQ" ) ) )
                 ELSE
                    lReturn := ( ! MXLOECFI->( mxSeek( 1, { CNX_EXCLUI, "CHQ", Str( vldField( "CFICODCHQ" ), 13 ) + Str( vldField( "CFINLJCHQ" ), 3 ) } ) ) )
                 ENDIF
              ENDIF

              IF ! lReturn
                 aAdd( aRecvNoUpd, "CHQ" + Str( vldField( "CFICODCHQ" ), 13 ) + Str( vldField( "CFINLJCHQ" ), 3 ) )
              ENDIF

           ENDIF

      CASE C_ALIAS = "MCH"

           IF cOper = ONL_OP_DELETE
              lReturn := ( aScan( aRecvNoUpd, "CHQ" + Str( MXMCHCFI->CFICHQMCH, 13 ) + Str( MXMCHCFI->CFINLJMCH, 3 ) ) = 0 )
           ELSE
              lReturn := ( aScan( aRecvNoUpd, "CHQ" + Str( vldField( "CFICHQMCH" ), 13 ) + Str( vldField( "CFINLJMCH" ), 3 ) ) = 0 )
           ENDIF

      CASE C_ALIAS = "DUP"

           IF cOper = ONL_OP_UPDATE

              IF ! lSeek
                 lReturn := ( ! MXLOECFI->( mxSeek( 1, { CNX_EXCLUI, "DUP", Str( vldField( "CFICODDUP" ), 7 ) + vldField( "CFICPLDUP" ) + Str( vldField( "CFINLJDUP" ), 3 ) } ) ) )
              ELSEIF ! foundStr( cTrans, "CNX_INCALT_DUP|OL_BXDUP2|MCX_CANCELA" )
                 lReturn := ( Empty( MXDUPCFI->CFIDTPDUP ) .OR. ! Empty( vldField( "CFIDTPDUP" ) ) )
              ENDIF

           ENDIF

      CASE C_ALIAS = "PED"

           IF ( cOper <> ONL_OP_DELETE ) .AND. lSeek

              lReturn := ( ( ( vldField( "CFISTAPED" ) <> "Or‡am" ) .OR. MXPEDCFI->CFISTAPED = "Or‡am" ) .AND. ( MXPEDCFI->CFISTAPED <> "Cance" ) )

              IF ! lReturn
                 aAdd( aRecvNoUpd, "PED" + Str( MXPEDCFI->CFICODPED, 7 ) + Str( MXPEDCFI->CFINLJPED, 3 ) )
              ENDIF

           ELSEIF cOper = ONL_OP_UPDATE .AND. ! lSeek .AND. cTrans = "RCV_UPDPET"

              lReturn := .F.

           ENDIF

      CASE C_ALIAS = "ITE"

           IF cOper = ONL_OP_DELETE
              lReturn := ( aScan( aRecvNoUpd, "PED" + Str( MXITECFI->CFIPEDITE, 7 ) + Str( MXITECFI->CFINLJITE, 3 ) ) = 0 )
           ELSE
              lReturn := ( aScan( aRecvNoUpd, "PED" + Str( vldField( "CFIPEDITE" ), 7 ) + Str( vldField( "CFINLJITE" ), 3 ) ) = 0 )
           ENDIF

      CASE C_ALIAS = "TRF"

           IF lSeek

              IF sndMaster()

                 // Colocada esta situacao em 19/02/2014, pois sem isto, nao cancelava no master,
                 // e no final, nao se permitia mais cancelar a solicitacao.

                 lReturn := .T.

              ELSE

                 lReturn := ( ( Right( MXTRFCFI->CFISTATRF, 2 ) <> "OK" ) .OR. Right( vldField( "CFISTATRF" ), 2 ) = "OK" .OR. Right( vldField( "CFISTATRF" ), 4 ) = "Canc" )

                 IF cTrans = "EXC_TRF" .AND. IsDef( "RELEASE" )
                    IF lReturn
                       lReturn := ( Right( MXTRFCFI->CFISTATRF, 2 ) <> "OK" )
                    ELSE
                       lReturn := ( MXTRFCFI->CFISTATRF = "EnvOK" .AND. vldField( "CFISTATRF" ) = "Envie" )
                    ENDIF
                 ENDIF

                 IF ! lReturn .AND. Select( "MXITFCFI" ) > 0
                    lReturn := ! MXITFCFI->( mxSeek( 1, { MXTRFCFI->CFICODTRF, MXTRFCFI->CFINLJTRF } ) )
                 ENDIF

                 IF ! lReturn
                    aAdd( aRecvNoUpd, "TRF" + Str( MXTRFCFI->CFICODTRF, 7 ) + Str( MXTRFCFI->CFINLJTRF, 3 ) )
                 ENDIF

              ENDIF

           ENDIF

      CASE C_ALIAS = "ITF"

           IF cOper = ONL_OP_DELETE
              lReturn := ( aScan( aRecvNoUpd, "TRF" + Str( MXITFCFI->CFICODITF, 7 ) + Str( MXITFCFI->CFINLJITF, 3 ) ) = 0 )
           ELSE
              lReturn := ( aScan( aRecvNoUpd, "TRF" + Str( vldField( "CFICODITF" ), 7 ) + Str( vldField( "CFINLJITF" ), 3 ) ) = 0 )
           ENDIF

      CASE C_ALIAS = "PET"

           IF lSeek

              IF ( cOper <> ONL_OP_DELETE ) .AND. ( cTrans <> "ALTQTD_PET" )

                 IF Upper( MXPETCFI->CFISTAPET ) = "IMPRE" .AND. Upper( vldField( "CFISTAPET" ) ) = "DIGIT" .AND. ! CliCS( "BELATINTAS" )
                    nPosAtu := aScan( aFields, { |f| f[1] = "MXPETCFI->CFISTAPET" } )
                    IF nPosAtu > 0
                       aFields[ nPosAtu, 2 ] := "Impre"
                    ENDIF
                 ENDIF

              ENDIF

              nAux := If( cTrans = "CANCELA_ROT", 4, If( foundStr( cTrans, "ENTREGA_ROT|RCV_UPDPET" ), 3, If( cTrans = "ALTQTD_PET", 1, 2 ) ) )

              aStatus := { ;
                           { "DIGIT", 1    },;
                           { "IMPRE", 1    },;
                           { "SEPAR", nAux },;
                           { "SEPAP", nAux },;
                           { "ROTEI", 3    },;
                           { "TRANS", 3    },;
                           { "ENTRE", 4    },;
                           { "SOLIC", 5    },;
                           { "CANCE", 6    } ;
                         }

              IF cTrans = "ATU_DIGDUP"
                 lReturn := .T.
              ELSEIF Upper( MXPETCFI->CFISTAPET ) = "EPARC" .AND. foundStr( Upper( vldField( "CFISTAPET" ) ), "DIGIT|IMPRE" )
                 lReturn := .F.
              ELSE
                 nPosAtu := aScan( aStatus, { |x| x[1] = Upper( MXPETCFI->CFISTAPET ) } )
                 nPosNew := aScan( aStatus, { |x| x[1] = Upper( vldField( "CFISTAPET" ) ) } )

                 IF nPosNew > 0 .AND. nPosAtu > 0
                    IF CliCS( "BELATINTAS" ) .AND. foundStr( MXPETCFI->CFISTAPET, "Digit|Impre|Separ|SepaP" ) .AND. foundStr( vldField( "CFISTAPET" ), "Digit|Impre|Separ|SepaP" )
                       lReturn := .T.
                    ELSE
                       lReturn := ( aStatus[ nPosNew, 2 ] >= aStatus[ nPosAtu, 2 ] )
                    ENDIF
                 ENDIF
              ENDIF

              IF ! lReturn .AND. Select( "MXIPECFI" ) > 0
                 lReturn := ( ! MXIPECFI->( mxSeek( 1, { MXPETCFI->CFICODPET, MXPETCFI->CFINLJPET } ) ) )
              ENDIF

              IF ! lReturn
                 aAdd( aRecvNoUpd, "PET" + Str( MXPETCFI->CFICODPET, 7 ) + Str( MXPETCFI->CFINLJPET, 3 ) )
              ENDIF

           ENDIF

      CASE C_ALIAS = "IPE"

           IF cOper = ONL_OP_DELETE
              lReturn := ( aScan( aRecvNoUpd, "PET" + Str( MXIPECFI->CFIPETIPE, 7 ) + Str( MXIPECFI->CFINLJIPE, 3 ) ) = 0 )
           ELSE
              lReturn := ( aScan( aRecvNoUpd, "PET" + Str( vldField( "CFIPETIPE" ), 7 ) + Str( vldField( "CFINLJIPE" ), 3 ) ) = 0 )
           ENDIF

      CASE C_ALIAS = "MPE"

           IF cOper = ONL_OP_DELETE
              lReturn := ( aScan( aRecvNoUpd, "PET" + Str( MXMPECFI->CFIPETMPE, 7 ) + Str( MXMPECFI->CFINLJMPE, 3 ) ) = 0 )
           ELSE
              lReturn := ( aScan( aRecvNoUpd, "PET" + Str( vldField( "CFIPETMPE" ), 7 ) + Str( vldField( "CFINLJMPE" ), 3 ) ) = 0 )
           ENDIF

      CASE C_ALIAS = "COM"

           IF cOper = ONL_OP_UPDATE .AND. lSeek .AND. ( cTrans <> "EXC_NOE" )

              IF foundStr( MXCOMCFI->CFISTACOM, "RParc|RTota" ) .AND. vldField( "CFISTACOM" ) = "Digit"
                 lReturn := .F.
                 aAdd( aRecvNoUpd, "COM" + Str( MXCOMCFI->CFICODCOM, 6 ) + Str( MXCOMCFI->CFINLJCOM, 3 ) )
              ENDIF

           ENDIF

      CASE C_ALIAS = "ITC"

           IF cOper = ONL_OP_UPDATE
              lReturn := ( aScan( aRecvNoUpd, "COM" + Str( vldField( "CFIPEDITC" ), 6 ) + Str( vldField( "CFINLJITC" ), 3 ) ) = 0 )
           ENDIF

      CASE C_ALIAS = "COR"

           IF ! sndMaster()
              nAux  := vldField( "CFIVCOCOR" )
              nAux2 := MXCORCFI->CFIVCOCOR
              IF mxIn( cOper, { ONL_OP_INSERT, ONL_OP_UPDATE } ) .AND. nAux <= nAux2
                 rcvDispMsg( .T., .T., "Formula ja atualizada." )
                 lReturn := .F.
              ENDIF
           ENDIF

   ENDCASE

   BEGIN SEQUENCE

      IF ! CONF_NOSEND .OR. ! lReturn
         BREAK
      ENDIF

      IF foundStr( C_ALIAS, "CLI" )

         IF C_ALIAS = "CLI"
            nCodCli := vldField( "CFICODCLI" )
         ENDIF

         IF mxIn( sndDefConnection(), sndNoSend() )

            cLoja   := "cliLoja( " + NumToStr( nCodCli ) + " )"
            lReturn := ( &cLoja = sndDefConnection() )

         ENDIF

      ENDIF

   ENDSEQUENCE

RETURN( lReturn )



STATIC FUNCTION rcvProcura( cAlias, nOrder, uKey, nFLoja, aFields )

   LOCAL lReturn := .F.
   LOCAL aResult := {}
   LOCAL cAux, cDefObs

   IF C_ALIAS = "LIS"

      cAux := GetNoEmpty( vldField( "CFICODLIS" ), uKey )

      lReturn := AchaPro( ;
                          cAux                   ,;
                          vldField( "CFIDESLIS" ),;
                          vldField( "CFIEMBLIS" ),;
                          .F.                    ,;
                          .F.                     ;
                        )

   ELSEIF C_ALIAS = "ITE"

      IF ! Empty( vldField( "CFIPROITE" ) )

         IF USA_SEEK_ITE
            lReturn := SeekITE( vldField( "CFIPEDITE" ), { vldField( "CFIPROITE" ),;
                                                           vldField( "CFIDESITE" ),;
                                                           vldField( "CFIEMBITE" ),;
                                                           vldField( "CFICORITE" ),;
                                                           vldField( "CFIOBSITE" ) }, vldField( "CFINLJITE" ) )
         ELSE
            lReturn := SeekItem( "ITE",;
                                 vldField( "CFIPEDITE" ),;
                                 vldField( "CFINLJITE" ),;
                                 { ;
                                   vldField( "CFIPROITE" ),;
                                   vldField( "CFIDESITE" ),;
                                   vldField( "CFIEMBITE" ),;
                                   vldField( "CFICORITE" ),;
                                   vldField( "CFIOBSITE" ) ;
                                 } )
         ENDIF

      ENDIF

   ELSEIF C_ALIAS = "IPE"

      IF ! Empty( vldField( "CFIPROIPE" ) )

         IF USA_SEEK_ITE
            lReturn := SeekIPE( vldField( "CFIPETIPE" ), { vldField( "CFIPROIPE" ),;
                                                           vldField( "CFIDESIPE" ),;
                                                           vldField( "CFIEMBIPE" ),;
                                                           vldField( "CFICORIPE" ),;
                                                           vldField( "CFIOBSIPE" ) }, vldField( "CFINLJIPE" ) )
         ELSE
            lReturn := SeekItem( "IPE",;
                                 vldField( "CFIPETIPE" ),;
                                 vldField( "CFINLJIPE" ),;
                                 { vldField( "CFIPROIPE" ),;
                                   vldField( "CFIDESIPE" ),;
                                   vldField( "CFIEMBIPE" ),;
                                   vldField( "CFICORIPE" ),;
                                   vldField( "CFIOBSIPE" ) ;
                                 } )
         ENDIF

      ENDIF

   ELSEIF C_ALIAS = "ITF"

      IF ! Empty( vldField( "CFIPROITF" ) )

         lReturn := MXITFCFI->( mxSeek( 1, { vldField( "CFICODITF" ),;
                                             nFLoja                 ,;
                                             vldField( "CFIPROITF" ),;
                                             vldField( "CFIDESITF" ),;
                                             vldField( "CFIEMBITF" ),;
                                             vldField( "CFICORITF" ) } ) )

      ENDIF

   ELSEIF C_ALIAS = "IFC" .AND. ! Empty( vldField( "CFIPROIFC" ) )

      sqlNew( "MXIFCCFI", "IFC" )

      sqlField( "IFC.SR_RECNO" )

      sqlWhere( "IFC.CFICODIFC", vldField( "CFICODIFC" ) )
      sqlWhere( "IFC.CFIPROIFC", QuotedStr( vldField( "CFIPROIFC" ), .T. ) )
      sqlWhere( "IFC.CFIDESIFC", QuotedStr( strReplace( Trim( vldField( "CFIDESIFC" ) ), { "'", "\" }, { "''", "\\" } ) ) )
      sqlWhere( "IFC.CFIEMBIFC", QuotedStr( vldField( "CFIEMBIFC" ), .T. ) )
      sqlWhere( "IFC.CFISTAIFC", QuotedStr( vldField( "CFISTAIFC" ), .T. ) )

      cDefObs := Trim( StrTran( vldField( "CFIOBSIFC" ), "'", "''" ) )
      IF cDefObs = "\"
         cDefObs += "\"
      ENDIF

      sqlWhere( "TRIM(IFC.CFIOBSIFC)", QuotedStr( cDefObs ) )
      sqlWhere( "IFC.CFIPEDIFC", vldField( "CFIPEDIFC" ) )
      sqlWhere( "IFC.CFINLJIFC", vldField( "CFINLJIFC" ) )

      cAux := sqlSelect() + " LIMIT 1"

      IF IsDef( "CSWLOG" )
         mxFAddLine( CSW_SQLLOG, cAux )
      ENDIF

      IF sqlExecute( cAux, @aResult, .F., NIL, NIL, .T., .T. ) .AND. Len( aResult ) > 0
         lReturn := .T.
         MXIFCCFI->( mxGoTo( aResult[ 1, 1 ] ) )
      ENDIF

   ELSEIF C_ALIAS = "PCL" .AND. nOrder = 1

      sqlNew( "MXPCLCFI", "PCL" )

      sqlField( "PCL.SR_RECNO" )

      sqlWhere( "PCL.CFITIPPCL", QuotedStr( vldField( "CFITIPPCL" ) ) )
      sqlWhere( "PCL.CFIDOCPCL", vldField( "CFIDOCPCL" ) )
      sqlWhere( "PCL.CFICDOPCL", QuotedStr( vldField( "CFICDOPCL" ) ) )
      sqlWhere( "PCL.CFINUMPCL", vldField( "CFINUMPCL" ) )
      sqlWhere( "PCL.CFINLJPCL", nFLoja )

      cAux := sqlSelect() + " LIMIT 1"

      IF IsDef( "CSWLOG" )
         mxFAddLine( CSW_SQLLOG, cAux )
      ENDIF

      IF sqlExecute( cAux, @aResult, .F., NIL, NIL, .T., .T. ) .AND. Len( aResult ) > 0
         lReturn := .T.
         MXPCLCFI->( mxGoTo( aResult[ 1, 1 ] ) )
      ENDIF

   ELSEIF C_ALIAS = "TRF" .AND. ! Empty( vldField( "CFICODTRF" ) )

      lReturn := MXTRFCFI->( mxSeek( 9, { uKey, nFLoja } ) )

      IF IsDef( "CSWLOG" )
         mxFAddLine( CSW_SQLLOG, sqlLastCmd() )
      ENDIF

   ELSEIF C_ALIAS = "CLI"

      lReturn := ( cAlias )->( mxSeek( nOrder, { uKey } ) )

   ELSE

      mxSetDbRefresh( .F. )
      lReturn := ( cAlias )->( cnxSeek( nOrder, uKey, nFLoja ) )
      mxSetDbRefresh( .T. )

   ENDIF

RETURN( lReturn )



FUNCTION rcvVldField( cFLocate, aFields )

   LOCAL uReturn
   LOCAL nPos := aScan( aFields, { |f| f[1] = cFLocate } )

   IF nPos > 0
      uReturn := rcvField( cFLocate, aFields[ nPos, 2 ], .F. )
   ELSE
      uReturn := rcvField( cFLocate, NIL, .T. )
   ENDIF

RETURN( uReturn )



STATIC PROCEDURE rcvUpdTRF()

   LOCAL aOpers, aBookTRF, aRecnoITF, aRecnoFCV, aRecnoFCV2, aTrans
   LOCAL nTrf, nLoja, nCount, nPos, cOper, cLog, nFcv, cSql, cWhere, aInfo

   BEGIN SEQUENCE

      IF ! sndMaster()
         BREAK
      ENDIF

      aOpers := cswLerAtualizacoes( "1", "TRF" )

      IF Len( aOpers ) = 0
         BREAK
      ENDIF

      aTrans := { "COV","FCV","TRF","ITF" }

      OpenDB( aTrans )

      DeclareVars MXCOVCFI
      DeclareVars MXFCVCFI
      DeclareVars MXTRFCFI
      DeclareVars MXITFCFI

      aAddC( aTrans, "COD", Select( "MXCODCFI" ) > 0 )

      FOR nCount := 1 TO Len( aOpers )

         olMsgWait( "verificando transferˆncias", 1 )

         // Define as variaveis de controle.

         aInfo := strToArray( AllTrim( aOpers[ nCount, CSW_ATU_REL ] ) )

         nTrf  := Val( aInfo[ 1 ] )
         nLoja := Val( aInfo[ 2 ] )
         cOper := aOpers[ nCount, CSW_ATU_OPE ]

         IF nTrf > 0 .AND. MXTRFCFI->( mxSeek( 9, { nTrf, nLoja } ) )

            NLJTRF := MXTRFCFI->CFINLJTRF
            LOJTRF := MXTRFCFI->CFILOJTRF

            SwitchVal( @NLJTRF, @LOJTRF )

            // Verifica se o outro registro da operacao ja foi processado
            // ou esta cancelado - neste caso nao e alterado

            aBookTRF := MXTRFCFI->( mxGetBM() )

            IF MXTRFCFI->( mxSeek( 9, { nTrf, NLJTRF } ) )

               IF Right( MXTRFCFI->CFISTATRF, 2 ) = "OK"   .OR. ;
                  Right( MXTRFCFI->CFISTATRF, 4 ) = "Canc"

                  cswProcessaAtualizacao( aOpers[ nCount, CSW_ATU_REC ] )
                  LOOP

               ENDIF

            ENDIF

            mxGoToBM( aBookTRF )

            aRecnoITF := sqlGetRecords( "ITF", "CFICODITF=" + NumToStr( nTrf ) + " AND CFINLJITF=" + NumToStr( nLoja ) )

            IF Len( aRecnoITF ) = 0
               LOOP
            ENDIF

            sndActive( .T. )

            mxTran( "RCV_UPDTRF", aTrans )

            MXTRFCFI->( mxRecLock( NIL, .F. ) )

            MXTRFCFI->( SetVars() )

            SwitchVal( @NLJTRF, @LOJTRF )

            IF Empty( MXTRFCFI->CFIOB3TRF )
               MXTRFCFI->( mxReplace( "OB3", "VIDE LOJA " + StrZero( NLJTRF, 3 ) + " TRANSFERENCIA " + StrZero( CODTRF, 7 ) ) )
            ENDIF

            MXTRFCFI->( mxUnlock(.F.) )

            IF Right( MXTRFCFI->CFISTATRF, 4 ) = "Canc"
               STATRF := If( MXTRFCFI->CFISTATRF = "SCanc", "ECanc", "SCanc" )
            ELSE
               STATRF := If( MXTRFCFI->CFISTATRF = "Solic", "Envie", "Solic" )
            ENDIF

            IF RCV_TRF_AUTO
               ROTTRF := If( Left( STATRF, 1 ) = "E", "A", " " )
            ENDIF

            OB3TRF := GetNoEmpty( OB3TRF, "VIDE LOJA " + StrZero( nLoja, 3 ) + " SOLICITACAO " + StrZero( nTrf, 7 ) )

            IF MXTRFCFI->( mxSeek( 9, { nTrf, NLJTRF } ) )
               cOper  := ONL_OP_UPDATE
               PETTRF := MXTRFCFI->CFIPETTRF
               ROTTRF := MXTRFCFI->CFIROTTRF
            ELSE
               cOper := ONL_OP_INSERT
            ENDIF

            IF cOper = ONL_OP_UPDATE

               sndActive( .F. )

               sqlDelete( "ITF", { ;
                                   { "COD", MXTRFCFI->CFICODTRF },;
                                   { "NLJ", NLJTRF              } ;
                                 } )

               sndActive( .T. )

            ENDIF

            MXTRFCFI->( SaveVars( cOper = ONL_OP_INSERT ) )

            FOR nPos := 1 TO Len( aRecnoITF )

               MXITFCFI->( mxGoTo( aRecnoITF[ nPos, 1 ] ) )
               MXITFCFI->( SetVars() )

               IF InvalidCod( "ZZ", MXITFCFI->CFIPROITF )

                  IF MXCOVCFI->( mxSeek( 1, { NLJTRF, "TRF", CODITF, Left( MXITFCFI->CFIPROITF, 5 ), MXITFCFI->CFICORITF } ) )
                     MXCOVCFI->( mxDelete( NIL, .F. ) )
                  ENDIF

                  aRecnoFCV := {}

                  IF MXCOVCFI->( mxSeek( 1, { NLJITF, "TRF", CODITF, Left( MXITFCFI->CFIPROITF, 5 ), MXITFCFI->CFICORITF } ) )

                     MXCOVCFI->( SetVars() )
                     NLJCOV := NLJTRF
                     MXCOVCFI->( SaveVars(.T.) )

                     // Procura pelo codigo anterior para replicar

                     cSql := "CFINLJFCV=" + NumToStr( NLJITF ) + " AND CFIDOCFCV=" + NumToStr( CODITF ) + " AND CFITDOFCV='TRF' AND CFICODFCV=" + QuotedStr( Trim( MXITFCFI->CFICORITF ) )

                     aRecnoFCV := sqlGetRecords( "FCV", cSql )

                     // Procura pelo novo codigo para apagar os itens anteriores afim de inclui-los novamente.

                     cWhere := "CFINLJFCV=" + NumToStr( NLJTRF ) + ;
                          " AND CFIDOCFCV=" + NumToStr( CODITF ) + ;
                          " AND CFITDOFCV=" + QuotedStr( "TRF" ) + ;
                          " AND CFICODFCV=" + QuotedStr( Trim( MXITFCFI->CFICORITF ) )

                     IF sndActive()

                        aRecnoFCV2 := sqlGetRecords( "FCV", cWhere )

                        FOR nFcv := 1 TO Len( aRecnoFCV2 )
                           MXFCVCFI->( mxGoTo( aRecnoFCV2[ nFcv, 1 ] ) )
                           MXFCVCFI->( mxDelete( NIL, .F. ) )
                        NEXT

                     ELSE

                        cSql := "DELETE FROM MXFCVCFI WHERE " + cWhere

                        IF IsDef( "CSWLOG" )
                           mxFAddLine( CSW_SQLLOG, cSql )
                        ENDIF

                        IF ! sqlExecute( cSql, NIL, .F., NIL, NIL, .T., .T. )
                           Fim(0)
                        ENDIF

                        MXFCVCFI->( mxDbRefresh() )

                     ENDIF

                  ENDIF

                  FOR nFcv := 1 TO Len( aRecnoFCV )

                     MXFCVCFI->( mxGoTo( aRecnoFCV[ nFcv, 1 ] ) )

                     MXFCVCFI->( SetVars() )
                     NLJFCV := NLJTRF
                     MXFCVCFI->( SaveVars(.T.) )

                  NEXT

               ENDIF

               CODITF := CODTRF
               NLJITF := NLJTRF

               MXITFCFI->( SaveVars( .T., NIL, { "TESITF" } ) )

            NEXT

            mxTran( "RCV_UPDTRF" )

            sndActive( .F. )

         ENDIF

         cswProcessaAtualizacao( aOpers[ nCount, CSW_ATU_REC ] )

      NEXT

   ENDSEQUENCE

RETURN



STATIC PROCEDURE rcvUpdNOE()

   LOCAL aOpen  := { "KIT","LAP","ICM","LIS","NOE","ITS","ACP","TES","EST","LLP","PCU","IPC","COD" }
   LOCAL aOpers := cswLerAtualizacoes( "1", "NOE" )
   LOCAL dData  := Date()
   LOCAL cHora  := Time()

   LOCAL nNoe, nLoja, nCount, cLog, aInfo, nRec, aRecITS

   IF Len( aOpers ) <> 0
   
      xAltd( "ESC" )

      OpenDB( aOpen )

      FOR nCount := 1 TO Len( aOpers )

         // Define as variaveis de controle.

         aInfo := strToArray( AllTrim( aOpers[ nCount, CSW_ATU_REL ] ) )

         nNoe  := Val( aInfo[ 1 ] )
         nLoja := Val( aInfo[ 2 ] )

         IF nNoe <> 0 .AND. MXNOECFI->( mxSeek( 1, { nNoe, nLoja } ) )
         
            // Atualizacao de precos no MASTER
            // Obs: Exceto proveniente de transferencnias.

            IF sndMaster() .AND. aOpers[ nCount, CSW_ATU_OPE ] = "P" .AND. MXNOECFI->CFIORINOE <> "TRF"

               olMsgWait( "verificando notas de entrada", 1 )

               sndActive( .T. )
               gprGrava()
               sndActive( .F. )

            ENDIF
            
            // Atualizacao do estoque na LOJA quando
            // processado ou cancelado no MASTER

            IF ! sndMaster() .AND. mxIn( "Proce", { MXNOECFI->CFISTANOE, MXNOECFI->CFISTONOE } )

               sndActive(.T.)

               aRecITS := csSqlItens( "ITS" )

               mxTran( "NE_PROCESSA_EST", aOpen )

               FOR nRec := 1 TO Len( aRecITS )

                  mxWait( "processando nota fiscal de entrada" )

                  MXITSCFI->( mxGoTo( aRecITS[ nRec, 1 ] ) )

                  BaixaEst( "ITS"                                        ,;
                            MXITSCFI->CFINLJITS                          ,;
                            MXITSCFI->CFITESITS                          ,;
                            MXITSCFI->CFIQTDITS                          ,;
                            If( MXNOECFI->CFISTANOE = "Cance", "-", "+" ),;
                            { "NE", "", MXNOECFI->CFIDESNOE }            ,;
                            NIL                                          ,;
                            NIL                                          ,;
                            NIL                                          ,;
                            NIL                                          ,;
                            dData                                        ,;
                            cHora                                         ;
                          )
                          
               NEXT

               mxTran( "NE_PROCESSA_EST" )

               sndActive(.F.)

            ENDIF

         ENDIF

         cswProcessaAtualizacao( aOpers[ nCount, CSW_ATU_REC ] )

      NEXT

   ENDIF

RETURN



STATIC PROCEDURE rcvUpdPET()

   LOCAL aOpen := {}

   LOCAL aOpers, nPet, nLoja, nConnect, nCount, nPos, nRec, aInfo
   LOCAL aRegIpe, cLog, cTrans, cTransOri

   mxSetDbRefresh(.F.)

   BEGIN SEQUENCE

      IF ! sndMaster()
         BREAK
      ENDIF

      aOpers := cswLerAtualizacoes( "1", "PET" )

      IF Len( aOpers ) = 0
         BREAK
      ENDIF

      rcvDispMsg( .T., .T., "Distribuindo entregas..." )

      aOpen := { "MPE","PED","PET","IPE","MTC" }

      IF CFIUSTCTR = "S"
         aAdd( aOpen, "COV" )
         aAdd( aOpen, "FCV" )
      ENDIF

      OpenDB( aOpen )

      MXPETCFI->( mxDbRefresh() )

      FOR nCount := 1 TO Len( aOpers )

         olMsgWait( "verificando entregas", 1 )

         aInfo := strToArray( AllTrim( aOpers[ nCount, CSW_ATU_REL ] ) )

         nPet  := Val( aInfo[ 1 ] )
         nLoja := Val( aInfo[ 2 ] )

         aInfo := strToArray( AllTrim( aOpers[ nCount, CSW_ATU_AUX ] ) )

         cTrans   := AllTrim( aInfo[ 1 ] )
         nConnect := Val( aInfo[ 2 ] )

         IF nPet > 0

            cTransOri := cTrans

            IF ! foundStr( cTrans, "CANCELA_ROT|CANC_PED|ALTQTD_PET|ATUSTAPET|CNX_REENVIA|ATU_DIGDUP" )
               cTrans := "RCV_UPDPET"
            ENDIF

            // Como o numero do pedido de entrega nunca ira se repetir, pois
            // ele e composto com o numero da loja, nao existe a necessidade
            // de utilizar cnxSeek() p/ efetuar a procura.

            IF MXPETCFI->( mxSeek( 1, { nPet } ) ) .AND. MXIPECFI->( mxSeek( 4, { nPet } ) )

               sndActive( .T. )
               sndStart( cTrans )

               NLJPET := If( MXPETCFI->CFIDEPPET = nConnect, MXPETCFI->CFINLJPET, MXPETCFI->CFIDEPPET )

               // Pedido de entrega

               MXPETCFI->( sndUpdate() )
               MXPETCFI->( sndPost( NIL, NLJPET ) )

               // Itens do pedido de entrega

               IF cTransOri = "MCX_RECPED"
                  sndFOnly( "IPE", { "PET","NLJ","PRO","DES","EMB","COR","OBS","DSC","PCU","PRC","PRL" } )
               ENDIF

               aRegIpe := rcvUpdRecords( "IPE", NLJPET, "CFIPETIPE = " + NumToStr( nPet ) + " AND CFINLJIPE = " + NumToStr( MXPETCFI->CFINLJPET ) )

               // Movimentacao no pedido de entrega

               rcvUpdRecords( "MPE", NLJPET, "CFIPETMPE = " + NumToStr( nPet ) + " AND CFINLJMPE = " + NumToStr( MXPETCFI->CFINLJPET ) )

               IF MXMTCCFI->( mxSeek( 1, { "PET", MXPETCFI->CFICODPET, MXPETCFI->CFINLJPET } ) )
                  MXMTCCFI->( sndUpdate() )
                  MXMTCCFI->( sndPost( NIL, NLJPET ) )
               ENDIF

               IF CFIUSTCTR = "S"

                  // Cores vendidas

                  rcvUpdRecords( "COV", NLJPET, "CFIDOCCOV = " + NumToStr( nPet ) + " AND CFINLJCOV = " + NumToStr( MXPETCFI->CFINLJPET ) + " AND CFITDOCOV = 'PET'" )

                  // Formulas das cores vendidas

                  rcvUpdRecords( "FCV", NLJPET, "CFIDOCFCV = " + NumToStr( nPet ) + " AND CFINLJFCV = " + NumToStr( MXPETCFI->CFINLJPET ) + " AND CFITDOFCV = 'PET'" )

               ENDIF

               /*
               IF sndMaster() .AND. C_ALIAS = "PET" .AND. ! Empty( MXPETCFI->CFIDEPPET ) .AND. MXPETCFI->CFINLJPET <> MXPETCFI->CFIDEPPET .AND. nConnect = MXPETCFI->CFIDEPPET .AND. ! Empty( MXPETCFI->CFITIPPET )
                  // Definir uma forma de atualizar a reseva ou transferencia de
                  // entregas feitas em outras unidade de negocio.
                  petAtuOperacao( MXPETCFI->CFISTAPET, Date(), NIL, .F., .T. )
               ENDIF
               */

               sndEnd()
               sndRename(.T.)

               rcvPetAtuOper( cTransOri, aRegIpe )

               sndActive( .F. )

            ENDIF

         ENDIF

         cswProcessaAtualizacao( aOpers[ nCount, CSW_ATU_REC ] )

      NEXT

      rcvDispMsg( .F., .T., PadR( "ok", 7 ) )

   ENDSEQUENCE

   mxSetDbRefresh(.T.)

RETURN



STATIC PROCEDURE rcvUpdTRFPET()

   LOCAL aOpers, nCount, cLog, nTrf, nLoja, cOper, aTrans, aRec, nRec

   PRIV aMqCorST := {}
   PRIV aMqFrmST := {}

   PRIV ROTTRF, TURPED, HPEPED, DPEPED, DPFPED, DEPPED, PRIPED

   BEGIN SEQUENCE

      aOpers := cswLerAtualizacoes( "1", "TR2" )

      IF Len( aOpers ) = 0
         BREAK
      ENDIF

      OpenDB( "TRF" )

      FOR nCount := 1 TO Len( aOpers )

         aInfo := strToArray( AllTrim( aOpers[ nCount, CSW_ATU_REL ] ) )

         nTrf  := Val( aInfo[ 1 ] )
         nLoja := Val( aInfo[ 2 ] )
         cOper := aOpers[ nCount, CSW_ATU_OPE ]

         IF nTrf > 0 .AND. MXTRFCFI->( mxSeek( 9, { nTrf, nLoja } ) )

            sndActive(.T.)

            IF Subs( MXTRFCFI->CFISTATRF, 2, 4 ) = "Canc"

               IF ( MXTRFCFI->CFIPETTRF <> 0 .AND. MXPETCFI->( mxSeek( 1, { MXTRFCFI->CFIPETTRF } ) ) ) .OR. ;
                  ( MXTRFCFI->CFICODTRF <> 0 .AND. MXPETCFI->( mxSeek( 5, { nTrf, nLoja, "TRF"  } ) ) )

                  aTrans := { "IPE","MPE","MTC","PET","TRF","ITF","LOJ" }

                  aAppend( aTrans, { "ACP","KIT","LIS","EMB","LLP" } )
                  aAppend( aTrans, { "COV","FCV" }, CFIUSTCTR = "S" )
                  aAppend( aTrans, { "NOT","ITN","NFI" }, "NF" $ MXPETCFI->CFITPNPET )

                  mxTran( "CSW_CANCELA_PET2", aTrans )
                  petCancela( "", "", "Cance", Date(), Time() )
                  mxTran( "CSW_CANCELA_PET2" )

               ENDIF

            ELSE

               TURPED := "Q"
               HPEPED := Space(5)
               PRIPED := Space(20)
               DPEPED := Date()
               DPFPED := Date()
               DEPPED := 0

               aTrans := { "PET","IPE","MPE","LIS","LOJ","ITF","TRF","CPG","COD" }

               aAppend( aTrans, { "COV","FCV","CBC","MAQ" }, CFIUSTCTR = "S" )

               mxTran( "CSW_GRAVA_PET2", aTrans )

               IF CFIUSTCTR = "S"

                  aRec := csSqlItens( "ITF", NIL, NIL, NIL, "CFICORITF <> ''" )

                  FOR nRec := 1 TO Len( aRec )

                     MXITFCFI->( mxGoTo( aRec[ nRec, 1 ] ) )

                     aAddST( @aMqCorST          ,;
                             @aMqFrmST          ,;
                             1                  ,;
                             MXITFCFI->CFIPROITF,;
                             MXITFCFI->CFICORITF,;
                             MXITFCFI->CFIEMBITF,;
                             MXITFCFI->CFINLJITF,;
                             MXITFCFI->CFICODITF,;
                             "TRF" )

                  NEXT

               ENDIF

               petGrava( NIL, "TRF" )

               mxTran( "CSW_GRAVA_PET2" )

            ENDIF

            sndActive(.F.)

         ENDIF

         cswProcessaAtualizacao( aOpers[ nCount, CSW_ATU_REC ] )

      NEXT

   ENDSEQUENCE

RETURN



STATIC PROCEDURE rcvUpdLIS()

   LOCAL aOpers, nCount, aInfo, cCodLis

   BEGIN SEQUENCE

      IF ! sndMaster()
         BREAK
      ENDIF

      aOpers := cswLerAtualizacoes( "1", "LIS" )

      IF Len( aOpers ) = 0
         BREAK
      ENDIF

      IF ! OpenDB( "LIS" )
         BREAK
      ENDIF

      FOR nCount := 1 TO Len( aOpers )

         olMsgWait( "replicando produto", 1 )

         // Define as variaveis de controle.

         aInfo := strToArray( AllTrim( aOpers[ nCount, CSW_ATU_REL ] ) )

         cCodLis  := aInfo[ 1 ]

         IF MXLISCFI->( mxSeek( 1, { cCodLis } ) )
            cnxReenvia( .F., .F. )
         ENDIF

         cswProcessaAtualizacao( aOpers[ nCount, CSW_ATU_REC ] )

      NEXT

   ENDSEQUENCE

RETURN



STATIC PROCEDURE rcvPETDupls( cTrans, cDupPet, nCodAux, nCli )

   #define MDP_OBSER     15
   #define FPG_DUPLICATA "5"

   LOCAL nParcela, nLoj, nLojAtu, nAux, cCpl, cDup, nVal1, nVal2, aVenctos
   LOCAL nCreMdp, cTipMdp, cObsMdp1, cObsMdp2, cSql, nRec, aRec, nValDup, dDtvDup

   BEGIN SEQUENCE

      IF IsDef( "MXDUPCFI->CFICREDUP" )

         // Na versao 3.12 nao sera mais alterado o codigo da duplicata.

         IF Empty( cDupPet ) .OR. MXPETCFI->CFIDEPPET = 0 .OR. ! foundStr( cTrans, "GRVNOT_PET|EXC_NOT|RCV_UPDPET|ATU_DIGDUP" )
            BREAK
         ENDIF

         IF cTrans = "RCV_UPDPET"
            cTrans := If( nCodAux = 0, "EXC_NOT", "GRVNOT_PET" )
         ENDIF

         nVal1 := Val( LTrim( Subs( cDupPet,  1, 12 ) ) )
         nVal2 := Val( LTrim( Subs( cDupPet, 13, 12 ) ) )

         aVenctos := {}

         IF CFIAVDCTR = "S" .AND. MXPETCFI->CFIRECPET = "D" .AND. ! Empty( MXPETCFI->CFIDNFPET )

            aVenctos := cpgDatas( NIL, "PET", NIL, NIL, NIL, MXPETCFI->CFIDNFPET )

         ENDIF

         FOR nParcela := 1 TO MXPETCFI->CFIPARPET

            cDup := PadR( Subs( cDupPet, 25 + ( ( nParcela -1 ) * 10 ), 10 ), 10 )
            cCpl := Right( cDup, 2 )
            cDup := Left( cDup, 8 )

            IF MXDUPCFI->( mxSeek( 1, { Val( cDup ), cCpl, MXPETCFI->CFINLJPET } ) )

               nValDup := If( nParcela = 1, nVal1, nVal2 )

               cObsMdp1 := ""
               cObsMdp2 := ""
               dDtvDup  := MXDUPCFI->CFIDTVDUP

               IF cTrans = "GRVNOT_PET"

                  cTipMdp  := "NOT"
                  nCreMdp  := nCodAux
                  cObsMdp1 := "Emitida NF " + NumToStr( nCodAux ) + " na loja " + NumToStr( MXPETCFI->CFIDEPPET ) + " (Entrega " + NumToStr( MXPETCFI->CFICODPET ) + ")"
                  cObsMdp2 := If( nValDup > MXDUPCFI->CFIVALDUP, "Acrescimo de impostos: R$ " + TrimPict( nValDup - MXDUPCFI->CFIVALDUP, "99,999,999.99" ), "" )
                  nLojAtu  := MXPETCFI->CFIDEPPET

                  IF MXDUPCFI->CFITIPDUP = cTipMdp .AND. MXDUPCFI->CFICREDUP = nCreMdp
                     LOOP
                  ENDIF

                  IF CFIAVDCTR = "S" .AND. nParcela <= Len( aVenctos )
                     dDtvDup := aVenctos[ nParcela ]
                  ENDIF

               ELSEIF cTrans = "EXC_NOT"

                  IF MXDUPCFI->CFITIPDUP <> "NOT" .OR. MXDUPCFI->CFICREDUP <> MXPETCFI->CFINFVPET
                     LOOP
                  ENDIF

                  cTipMdp  := "PED"
                  nCreMdp  := MXPETCFI->CFIPEDPET
                  cObsMdp1 := "Cancelada NF " + NumToStr( MXPETCFI->CFINFVPET ) + " na loja " + NumToStr( MXPETCFI->CFIDEPPET )
                  nLojAtu  := 0

               ENDIF

               MXDUPCFI->( mxRecLock( NIL, .F. ) )
               MXDUPCFI->( mxReplace( "TIP", cTipMdp ) )
               MXDUPCFI->( mxReplace( "CRE", nCreMdp ) )
               MXDUPCFI->( mxReplace( "LDO", nLojAtu ) )
               MXDUPCFI->( mxReplace( "VAL", nValDup ) )
               MXDUPCFI->( mxReplace( "DTV", dDtvDup ) )
               MXDUPCFI->( mxUnlock(.F.) )

               mdpInc( MDP_OBSER, 0, Date(), cObsMdp1, { MXDUPCFI->CFITIPDUP, MXDUPCFI->CFICREDUP } )
               mdpInc( MDP_OBSER, 0, Date(), cObsMdp2, { MXDUPCFI->CFITIPDUP, MXDUPCFI->CFICREDUP } )

               IF MXPCLCFI->( mxSeek( 3, { "5", MXDUPCFI->CFICODDUP, MXDUPCFI->CFICPLDUP, MXDUPCFI->CFINLJDUP, "PED" } ) )
                  MXPCLCFI->( mxRecLock( NIL, .F. ) )
                  MXPCLCFI->( mxReplace( "DTV", dDtvDup ) )
                  MXPCLCFI->( mxUnlock(.F.) )
               ENDIF

            ENDIF

         NEXT

      ENDIF

   ENDSEQUENCE

RETURN



STATIC PROCEDURE rcvUpdFCO()

   LOCAL aOpers, nCount, nFco, nLoja, cSqlTable, cConn, cLog

   BEGIN SEQUENCE

      IF ! sndMaster()
         BREAK
      ENDIF

      aOpers := cswLerAtualizacoes( "1", "FCO" )

      IF Len( aOpers ) = 0
         BREAK
      ENDIF

      cSqlTable := rcvSqlTable( "MXIFCCFI", @cConn )

      FOR nCount := 1 TO Len( aOpers )

         olMsgWait( "verificando fechamentos de contas", 1 )

         // Define as variaveis de controle.

         aInfo := strToArray( AllTrim( aOpers[ nCount, CSW_ATU_REL ] ) )

         nFco  := Val( aInfo[ 1 ] )
         nLoja := Val( aInfo[ 2 ] )

         aInfo := strToArray( AllTrim( aOpers[ nCount, CSW_ATU_AUX ] ) )

         nNot  := Val( aInfo[ 1 ] )
         nCup  := Val( aInfo[ 2 ] )

         IF nFco > 0

            sndActive(.T.)

            mxTran( "RCV_UPDFCO", { "PED","RCP","IFC","FCO" } )

            rcvUpdIFC( nNot, nCup, "IFC", "MXIFCCFI", "MXFCOCFI", cSqlTable, "CFICODIFC = " + sqlCompFormat( nFco ) + " AND CFINLJIFC = " + + sqlCompFormat( nLoja ), .F. )

            mxTran( "RCV_UPDFCO" )

            sndActive(.F.)

         ENDIF

         cswProcessaAtualizacao( aOpers[ nCount, CSW_ATU_REC ] )

      NEXT

   ENDSEQUENCE

RETURN



STATIC PROCEDURE rcvDispMsg( lSumRow, lSumCol, cMsg, nCol )

   IF bFuncMsg <> NIL
      Eval( bFuncMsg, lSumRow, lSumCol, cMsg, nCol )
   ENDIF

RETURN



STATIC FUNCTION olSQLFormat( cSql )

   LOCAL nSubst, cSubst, cConst, lString

   DO WHILE .T.

      nSubst := At( "{", cSql )

      IF nSubst = 0
         EXIT
      ENDIF

      cSubst := Subs( cSql, nSubst )
      cSubst := Left( cSubst, At( "}", cSubst ) )

      lString := At( "'", cSubst ) <> 0

      cConst := Subs( cSubst, 2 )
      cConst := Left( cConst, Len( cConst ) -1 )

      IF ! lString
         cConst := "MX" + Right( cConst, 3 ) + "CFI->" + cConst
      ENDIF

      cConst := &cConst

      cConst := sqlCompFormat( cConst )

      cSql := StrTran( cSql, cSubst, cConst )

   ENDDO

RETURN( cSql )



STATIC FUNCTION rcvDelPcl( aDelPcl )

   LOCAL lReturn := .T.
   LOCAL cSql    := ""
   LOCAL nCount, cSqlTable, cConn

   cSqlTable := rcvSqlTable( "MXPCLCFI", @cConn )

   FOR nCount := 1 TO Len( aDelPcl )

      olMsgWait( "eliminando parcelamentos", 2 )

      IF ! Empty( cSql )
         cSql += ";"
      ENDIF

      cSql += "DELETE FROM " + cSqlTable + ;
              " WHERE CFITIPPCL = " + QuotedStr(     Subs( aDelPcl[ nCount, RCV_KEY ], 01, 03 ) ) + ;
                " AND CFIDOCPCL = " + LTrim(         Subs( aDelPcl[ nCount, RCV_KEY ], 04, 14 ) ) + ;
                " AND CFICDOPCL = " + QuotedStr(     Subs( aDelPcl[ nCount, RCV_KEY ], 18, 02 ) ) + ;
                " AND CFINUMPCL = " + NumToStr( Val( Subs( aDelPcl[ nCount, RCV_KEY ], 20, 02 ) ) ) + ;
                " AND CFINLJPCL = " + sqlCompFormat( aDelPcl[ nCount, RCV_FLOJA ] )

   NEXT

   IF ! Empty( cSql )

      IF IsDef( "CSWLOG" )
         mxFAddLine( CSW_SQLLOG, cSql )
      ENDIF

      IF ! sqlExecute( cSql, NIL, .T., cConn )
         lReturn := .F.
         MsgDlg( "N„o foi poss¡vel executar o comando:;;" + cSql + ";;[" + cswActFile() + "]" )
      ENDIF
      MXPCLCFI->( mxDbRefresh() )
   ENDIF

RETURN( lReturn )



STATIC FUNCTION rcvSqlTable( cTable, cConn )

   LOCAL nAux := aScan( GetOpenFiles(), { |x| x[1] = cTable } )
   LOCAL cSqlTable

   cConn     := If( nAux = 0, "", GetOpenFiles()[ nAux, 3 ] )
   cSqlTable := sqlGetInfo( "\" + cConn + "\", "SCHEMA" ) + "." + cTable

RETURN( cSqlTable )



STATIC PROCEDURE rcvUpdIFC( nNotUpdate, nCupUpdate, cRel, cAliasItem, cAliasHead, cSqlTable, cWhere, lDel )

   LOCAL aResult := {}

   LOCAL nItens, cAux, lOk, nRec

   IF cRel = "IFC" .AND. ( cAliasItem )->( FieldPos( "CFILJFIFC" ) ) <> 0

      cAux := "SELECT CFIPEDIFC, CFINLJIFC, CFILJFIFC, CFISTAIFC, CFIFLGIFC FROM " + cSqlTable + " WHERE " + cWhere + " AND NOT CFILJFIFC IN ( 0, CFINLJIFC ) AND CFISTAIFC IN ( 'Prazo','DevPz','ReceD','ReceF','ReceI' ) GROUP BY CFIPEDIFC, CFINLJIFC, CFILJFIFC, CFISTAIFC, CFIFLGIFC"

      IF IsDef( "CSWLOG" )
         mxFAddLine( CSW_SQLLOG, cAux )
      ENDIF

      IF sqlExecute( cAux, @aResult, .F., NIL, NIL, .T., .T. ) .AND. Len( aResult ) > 0

         FOR nItens := 1 TO Len( aResult )

            IF foundStr( aResult[ nItens, CMPIFC_STA ], "Prazo|DevPz" )

               IF MXPEDCFI->( mxSeek( 11, { aResult[ nItens, CMPIFC_PED ], aResult[ nItens, CMPIFC_LJF ] } ) )

                  rcvAddSend( "PED", MXPEDCFI->CFINLJPED )

                  MXPEDCFI->( mxRecLock( NIL, .F. ) )

                  cAux := If( aResult[ nItens, CMPIFC_FLG ] = "C", MXPEDCFI->CFITPNPED, "" )

                  IF nCupUpdate <> 0
                     IF mxIn( MXPEDCFI->CFINCFPED, { 0, nCupUpdate } )
                        IF aResult[ nItens, CMPIFC_FLG ] = "C"
                           cAux := StrTran( cAux, "CF", "" )
                        ELSE
                           cAux += "CF"
                        ENDIF
                        MXPEDCFI->( mxReplace( "NCF", If( aResult[ nItens, CMPIFC_FLG ] = "C", 0, ( cAliasHead )->CFINCFFCO ) ) )
                        MXPEDCFI->( mxReplace( "ECF", If( aResult[ nItens, CMPIFC_FLG ] = "C", 0, ( cAliasHead )->CFIECFFCO ) ) )
                     ENDIF
                  ENDIF

                  IF nNotUpdate <> 0
                     IF mxIn( MXPEDCFI->CFINNFPED, { 0, nNotUpdate } )
                        IF aResult[ nItens, CMPIFC_FLG ] = "C"
                           cAux := StrTran( cAux, "NF", "" )
                        ELSE
                           cAux += "NF"
                        ENDIF
                        MXPEDCFI->( mxReplace( "NNF", If( aResult[ nItens, CMPIFC_FLG ] = "C", 0 , ( cAliasHead )->CFINOTFCO ) ) )
                        MXPEDCFI->( mxReplace( "NOP", If( aResult[ nItens, CMPIFC_FLG ] = "C", "", ( cAliasHead )->CFINOPFCO ) ) )
                        MXPEDCFI->( mxReplace( "NO2", If( aResult[ nItens, CMPIFC_FLG ] = "C", "", ( cAliasHead )->CFINO2FCO ) ) )
                     ENDIF
                  ENDIF

                  MXPEDCFI->( mxReplace( "TPN", AllTrim( cAux ), AllTrim( MXPEDCFI->CFITPNPED ) <> AllTrim( cAux ) ) )

                  IF aResult[ nItens, CMPIFC_FLG ] = "C"
                     cAux := aResult[ nItens, CMPIFC_STA ]
                  ELSE
                     cAux := If( aResult[ nItens, CMPIFC_STA ] = "DevPz", "DevoP", "PrazP" )
                  ENDIF

                  MXPEDCFI->( mxReplace( "STO", MXPEDCFI->CFISTAPED, MXPEDCFI->CFISTAPED <> cAux ) )
                  MXPEDCFI->( mxReplace( "STA", cAux ) )

                  IF aResult[ nItens, CMPIFC_FLG ] = "C"
                     MXPEDCFI->( mxReplace( "NCX", 0, MXPEDCFI->CFINCXPED = -1 ) )
                  ENDIF

                  MXPEDCFI->( mxUnlock(.F.) )

               ENDIF

            ELSEIF "Rece" $ aResult[ nItens, CMPIFC_STA ]

               IF MXRCPCFI->( mxSeek( 1, { aResult[ nItens, CMPIFC_PED ], aResult[ nItens, CMPIFC_LJF ] } ) )

                  IF aScan( aRecvSend, { |x| x[ RCV_SEND_TAB ] = "MXRCPCFI" .AND. x[ RCV_SEND_REC ] = MXRCPCFI->( mxRecNo() ) .AND. x[ RCV_SEND_NLJ ] = MXRCPCFI->CFINLJRCP } ) = 0
                     aAdd( aRecvSend, { "MXRCPCFI", MXRCPCFI->( mxRecNo() ), MXRCPCFI->CFINLJRCP } )
                  ENDIF

                  cAux := MXRCPCFI->CFISTARCP

                  DO CASE
                     CASE aResult[ nItens, CMPIFC_FLG ] <> "C"    ; cAux := "Proce"
                     CASE aResult[ nItens, CMPIFC_STA ] = "ReceD" ; cAux := "Digit"
                     CASE aResult[ nItens, CMPIFC_STA ] = "ReceF" ; cAux := "Cr‚dF"
                     CASE aResult[ nItens, CMPIFC_STA ] = "ReceI" ; cAux := "Impre"
                  ENDCASE

                  MXRCPCFI->( mxRecLock( NIL, .F. ) )
                  MXRCPCFI->( mxReplace( "STA", cAux ) )
                  MXRCPCFI->( mxUnlock(.F.) )

               ENDIF

            ENDIF

         NEXT

      ENDIF

   ENDIF

RETURN



STATIC FUNCTION rcvDelete( cTable )

   LOCAL lReturn := .T.
   LOCAL cSql, cSqlTable, cConn

   cSqlTable := rcvSqlTable( cTable, @cConn )
   cSql      := "DELETE FROM " + cSqlTable + " WHERE sr_recno = " + sqlCompFormat( ( cTable )->( mxRecno() ) )

   IF IsDef( "CSWLOG" )
      mxFAddLine( CSW_SQLLOG, cSql )
   ENDIF

   lReturn := sqlExecute( cSql, NIL, .T., cConn, NIL, .T., .T. )

   IF lReturn
      ( cTable )->( mxDbRefresh() )
   ENDIF

RETURN( lReturn )



STATIC FUNCTION rcvUpdRecords( cAlias, nLoja, cWhere )

   LOCAL aRec := sqlGetRecords( cAlias, cWhere )
   LOCAL nRec

   cAlias := "MX" + cAlias + "CFI"

   FOR nRec := 1 TO Len( aRec )

      ( cAlias )->( mxGoTo( aRec[ nRec, 1 ] ) )
      ( cAlias )->( sndUpdate() )
      ( cAlias )->( sndPost( NIL, nLoja ) )

   NEXT

RETURN( aClone( aRec ) )



STATIC PROCEDURE cswCliDefBloqueio( cAlias, aBlkCli )

   LOCAL cCpi := ""

   IF cAlias = "DUP"
      IF MXCLICFI->( mxSeek( 1, { MXDUPCFI->CFICCLDUP } ) )
         cCpi := MXCLICFI->CFICPICLI
      ENDIF
      IF aScan( aBlkCli, { |x| x[1] = MXDUPCFI->CFICCLDUP } ) = 0
         aAdd( aBlkCli, { MXDUPCFI->CFICCLDUP, cCpi } )
      ENDIF
      IF ! Empty( cCpi ) .AND. aScan( aBlkCli, { |x| x[1] = 1 .AND. x[2] = cCpi } ) = 0
         aAdd( aBlkCli, { 1, cCpi } )
      ENDIF
   ELSEIF cAlias = "CHQ"
      IF aScan( aBlkCli, { |x| x[1] = MXCHQCFI->CFICLICHQ .AND. x[2] = MXCHQCFI->CFICCICHQ } ) = 0
         aAdd( aBlkCli, { MXCHQCFI->CFICLICHQ, MXCHQCFI->CFICCICHQ } )
      ENDIF
      IF aScan( aBlkCli, { |x| x[1] = 1 .AND. x[2] = MXCHQCFI->CFICPICHQ } ) = 0
         aAdd( aBlkCli, { 1, MXCHQCFI->CFICPICHQ } )
      ENDIF
   ELSEIF cAlias = "FCO"
      IF MXCLICFI->( mxSeek( 1, { MXFCOCFI->CFICLIFCO } ) )
         cCpi := MXCLICFI->CFICPICLI
      ENDIF
      IF aScan( aBlkCli, { |x| x[1] = MXFCOCFI->CFICLIFCO } ) = 0
         aAdd( aBlkCli, { MXFCOCFI->CFICLIFCO, cCpi } )
      ENDIF
      IF ! Empty( cCpi ) .AND. aScan( aBlkCli, { |x| x[1] = 1 .AND. x[2] = cCpi } ) = 0
         aAdd( aBlkCli, { 1, cCpi } )
      ENDIF
   ENDIF

RETURN



STATIC PROCEDURE rcvPetAtuOper( cTransOri, aRegIpe )

   LOCAL cFlagHead  := GetNoEmpty( MXPETCFI->CFITIPPET, "PED" )
   LOCAL cFlagItem  := If( cFlagHead = "PED", "ITE", "ITF" )
   LOCAL cAliasHead := "MX" + cFlagHead + "CFI"
   LOCAL cAliasItem := "MX" + cFlagItem + "CFI"

   LOCAL nRec, lSeek

   IF ( cAliasHead )->( mxSeek( If( cFlagHead = "PED", 11, 9 ), { MXPETCFI->CFIPEDPET, MXPETCFI->CFINLJPET } ) )

      mxTran( "RCV_UPDPET", { cFlagHead, cFlagItem, "PET", "IPE" } )

      IF foundStr( MXPETCFI->CFISTAPET, "Cance|Entre|EParc|Separ|SepaP" )

         sndFOnly( cFlagHead, { "PET","ROT" } )

         ( cAliasHead )->( mxRecLock( NIL, .F. ) )

         DO CASE
            CASE MXPETCFI->CFISTAPET = "Cance"
                 ( cAliasHead )->( mxReplace( "PET", 0  ) )
                 ( cAliasHead )->( mxReplace( "ROT", "" ) )
            CASE MXPETCFI->CFISTAPET = "Entre"
                 ( cAliasHead )->( mxReplace( "ROT", "N" ) )
            CASE MXPETCFI->CFISTAPET = "EParc"
                 ( cAliasHead )->( mxReplace( "ROT", "P" ) )
            CASE foundStr( MXPETCFI->CFISTAPET, "Separ|SepaP" )
                 ( cAliasHead )->( mxReplace( "ROT", "A" ) )
         ENDCASE

         ( cAliasHead )->( mxUnlock(.F.) )

      ENDIF

      IF cTransOri = "ALTQTD_PET"

         FOR nRec := 1 TO Len( aRegIpe )

            olMsgWait( "atualizando itens da reserva" )

            MXIPECFI->( mxGoTo( aRegIpe[ nRec, 1 ] ) )

            IF USA_SEEK_ITE
               lSeek := SeekITE( MXPETCFI->CFIPEDPET, { MXIPECFI->CFIPROIPE,;
                                                        MXIPECFI->CFIDESIPE,;
                                                        MXIPECFI->CFIEMBIPE,;
                                                        MXIPECFI->CFICORIPE,;
                                                        MXIPECFI->CFIOBSIPE }, MXPETCFI->CFINLJPET )
            ELSE
               lSeek := SeekItem( cFlagItem,;
                                  MXPETCFI->CFIPEDPET,;
                                  MXPETCFI->CFINLJPET,;
                                  { MXIPECFI->CFIPROIPE,;
                                    MXIPECFI->CFIDESIPE,;
                                    MXIPECFI->CFIEMBIPE,;
                                    MXIPECFI->CFICORIPE,;
                                    MXIPECFI->CFIOBSIPE ;
                                  } )
            ENDIF

            IF lSeek

               sndFOnly( cFlagItem, { cFlagHead, "NLJ","PRO","DES","EMB","COR","OBS","QAE" } )

               ( cAliasItem )->( mxRecLock( NIL, .F. ) )
               ( cAliasItem )->( mxReplace( "QAE", MXIPECFI->CFIQTPIPE ) )
               ( cAliasItem )->( mxUnlock(.F.) )

            ENDIF

         NEXT

      ENDIF

      mxTran( "RCV_UPDPET" )

   ENDIF

RETURN



STATIC FUNCTION rcvReplFields( cAlias, cTrans, aFields, aNoRcv, lFClear, lNew, cRcvFile, nConnect )

   LOCAL aUpdEst := {}
   LOCAL lMinMax := .F.
   LOCAL cPro    := Space(9)

   LOCAL nField, cField, cFLocate, nNoFSend, lEstPro, nReplace, uReplace, cType

   IF foundStr( C_ALIAS, TAB_ComImagens )

      FOR nField := 1 TO Len( aFields )

         cFLocate := aFields[ nField, 1 ]
         cField   := aFields[ nField, 1 ]
         cField   := AllTrim( Upper( Subs( cField, At( "->", cField ) + 2 ) ) )

         uReplace := rcvField( cFLocate, Trim( aFields[ nField, 2 ] ), .F., cAlias, cField, @cType )

         IF foundStr( cType, "C|M|B" ) .AND. At( "\", uReplace ) <> 0 //.AND. At( "\\", uReplace ) = 0
            uReplace := StrTran( uReplace, "\", "\\" )
         ENDIF

         sqlFReplace( cField, uReplace, NIL, cType <> "B" )

      NEXT

   ELSE

      IF C_ALIAS = "EST"
         cPro := MXESTCFI->CFIPROEST
      ENDIF

      FOR nField := 1 TO ( cAlias )->( fCount() )

         cField := ( cAlias )->( Field( nField ) )

         // Ignora os campos q nao devem ser gravados.

         IF aScan( aNoRcv, { |x| x = cField } ) > 0
            LOOP
         ENDIF

         cFLocate := cAlias + "->" + cField

         IF sndMaster()
            IF C_ALIAS = "LIS" .AND. foundStr( Subs( cField, 4, 3 ), "VEN|EST|MIN|MAX|LOC|DSO|SOF" )
               LOOP
            ELSEIF C_ALIAS = "EST" .AND. foundStr( Subs( cField, 4, 3 ), "VEN|EST|MIN|MAX|LOC|DSO|SOF" )
               IF foundStr( Subs( cField, 4, 3 ), "EST|MIN|MAX" )
                  aAdd( aUpdEst, Subs( cField, 4, 3 ) )
               ENDIF
            ENDIF
         ELSEIF foundStr( C_ALIAS, "LIS|EST" ) .AND. foundStr( Subs( cField, 4, 3 ), "EST" )
            LOOP
         ENDIF

         IF foundStr( Subs( cField, 4, 3 ), "MIN|MAX" ) .AND. ! sndMaster()
            aAdd( aUpdEst, Subs( cField, 4, 3 ) )
            lMinMax := .T.
         ENDIF

         nNoFSend := aScan( sndNoFSend(), { |x| x[1] = cField } )
         lEstPro  := .F.

         IF nNoFSend > 0

            // Se for loja e estiver nas transacoes abaixo
            // permite alterar os campos MIN, MAX, VEN e LOC.
            // Para os demais arquivos verifica permissao.

            IF C_ALIAS <> "EST"
               IF sndNoFSend()[ nNoFSend, 2 ] = NIL .OR. ( cAlias )->( &( sndNoFSend()[ nNoFSend, 2 ] ) )
                  LOOP
               ENDIF
            ENDIF

         ENDIF

         nReplace := aScan( aFields, { |f| f[1] = cFLocate } )

         IF nReplace = 0

            IF ! lFClear
               LOOP
            ENDIF

            uReplace := rcvField( cFLocate, NIL, .T. )

         ELSE

            uReplace := rcvField( cFLocate, aFields[ nReplace, 2 ], .F. )

         ENDIF

         IF C_ALIAS <> "LIS"

            IF ! lNew .AND. C_ALIAS = "CLI"
               IF Subs( cField, 4, 3 ) = "COD" .AND. ( &cFLocate <> uReplace ) .AND. &cFLocate > 0
                  mxFAddLine( "LOGS\MXCLICFI.LOG", FDate( Date(), "DD.MM.AA" ) + " - " + Time() + " - CSW - Codigo repetido : " + NumToStr( &cFLocate ) + " -> " + NumToStr( uReplace ) + " - " + cTrans + " - " + cRcvFile )
               ENDIF
               IF foundStr( Subs( cField, 4, 3 ), "ULC|UDC" )
                  uReplace := Max( &cFLocate, uReplace )
               ENDIF
            ENDIF

         ELSEIF lFClear

            IF ! lEstPro .AND. foundStr( Subs( cField, 4, 3 ), "MIN|MAX|VEN|LOC|DSO|SOF" )
               LOOP
            ELSEIF aScan( aFields, { |f| f[1] = "MXLISCFI->CFICODLIS" } ) = 0
               LOOP
            ENDIF

         ENDIF

         &cFLocate := uReplace

      NEXT

      IF C_ALIAS = "EST" .AND. ( sndMaster() .OR. lMinMax ) .AND. ! Empty( cPro )
         estGrvTotal( aUpdEst, cPro, .F. )
      ENDIF

   ENDIF

RETURN( NIL )



STATIC PROCEDURE cswIncAtualizacao( cArq, cKey, cOpe, cRef, cAux, lConfere )

   LOCAL lInsert := .T.
   LOCAL cCampos, cValores

   vDef( @cRef    , " " )
   vDef( @cAux    , ""  )
   vDef( @lConfere, .F. )

   IF lConfere
      lInsert := ( sqlRecCount( "CFIARQATU = " + QuotedStr( cArq ) + " AND CFIRELATU = " + QuotedStr( cKey ), "MXATUCFI", "CS_LOJA" ) = 0 )
   ENDIF

   IF lInsert

      IF Empty( GetActTrans() )

         cCampos  := "CFIDATATU, " + ;
                     "CFISEQATU, " + ;
                     "CFIARQATU, " + ;
                     "CFIRELATU, " + ;
                     "CFIOPEATU, " + ;
                     "CFIREFATU, " + ;
                     "CFIAUXATU"

         cValores := "current_date, " + ;
                     "COALESCE( ( SELECT MAX(CFISEQATU) + 1 FROM MXATUCFI ), 0 ), " + ;
                     QuotedStr( cArq ) + ", " + ;
                     QuotedStr( cKey ) + ", " + ;
                     QuotedStr( cOpe ) + ", " + ;
                     QuotedStr( cRef ) + ", " + ;
                     QuotedStr( cAux )

         sqlExecute( "INSERT INTO MXATUCFI ( " + cCampos + " ) VALUES ( " + cValores + " )", NIL, .T., "CS_LOJA" )

      ELSE
      
         MXATUCFI->( mxAppend( NIL, .F. ) )
         MXATUCFI->( mxReplace( "CFIDATATU", sqlDbDate() ) )
         MXATUCFI->( mxReplace( "CFISEQATU", sqlMax( "CFISEQATU", "MXATUCFI", NIL, "CS_LOJA" ) + 1 ) )
         MXATUCFI->( mxReplace( "CFIARQATU", cArq ) )
         MXATUCFI->( mxReplace( "CFIRELATU", cKey ) )
         MXATUCFI->( mxReplace( "CFIOPEATU", cOpe ) )
         MXATUCFI->( mxReplace( "CFIREFATU", cRef ) )
         MXATUCFI->( mxReplace( "CFIAUXATU", cAux ) )
         MXATUCFI->( mxUnlock(.F.) )
         
      ENDIF

   ENDIF

RETURN



FUNCTION cswLerAtualizacoes( cRef, cArq, nLimit )

   LOCAL nTry

   /*
     Definiceos em MAXONL.CH

     CSW_ATU_REC 1
     CSW_ATU_DAT 2
     CSW_ATU_SEQ 3
     CSW_ATU_ARQ 4
     CSW_ATU_REL 5
     CSW_ATU_OPE 6
     CSW_ATU_REF 7
     CSW_ATU_AUX 8
   */

   LOCAL aAtualiza := {}
   LOCAL cWhere    := "CFIPRCATU = ' ' AND CFIREFATU = " + QuotedStr( cRef )
   LOCAL cCampos   := "SR_RECNO, "  + ;
                      "CFIDATATU, " + ;
                      "CFISEQATU, " + ;
                      "CFIARQATU, " + ;
                      "CFIRELATU, " + ;
                      "CFIOPEATU, " + ;
                      "CFIREFATU, " + ;
                      "CFIAUXATU"

   LOCAL cSql

   vDef( @cArq, "   " )

   IF ! Empty( cArq )
      cWhere += " AND CFIARQATU = " + QuotedStr( cArq )
   ENDIF

   cSql := "SELECT " + cCampos + " FROM MXATUCFI WHERE " + cWhere + " ORDER BY CFISEQATU" + If( nLimit = NIL, "", " LIMIT " + NumToStr( nLimit ) )

   FOR nTry := 1 TO 2

      IF sqlExecute( cSql, @aAtualiza, .F., "CS_LOJA", NIL, NIL, .F. )
         EXIT
      ELSEIF ( nTry = 1 ) .AND. ( "NO CONNECTION TO THE SERVER" $ Upper( sqlLastError() ) )
         sqlReconnect( sqlGetConn( "CONN", "CS_LOJA" ), .F. )
      ELSE
         aAtualiza := {}
      ENDIF

   NEXT

RETURN( aClone( aAtualiza ) )



FUNCTION cswDelAtualizacao( nRec )

RETURN( sqlExecute( "DELETE FROM MXATUCFI WHERE SR_RECNO = " + NumToStr( nRec ), NIL, .T., "CS_LOJA" ) )



FUNCTION cswProcessaAtualizacao( nRec, cPrc )

   vDef( @cPrc, "1" )

RETURN( sqlExecute( "UPDATE MXATUCFI SET CFIPRCATU = " + QuotedStr( cPrc ) + " WHERE SR_RECNO = " + NumToStr( nRec ), NIL, .T., "CS_LOJA" ) )



FUNCTION rcvNomeTrans( cTrans )

   LOCAL cReturn := cRcvTrans

   IF cTrans <> NIL
      cRcvTrans := cTrans
   ENDIF

RETURN( cReturn )



STATIC FUNCTION rcvDelValid( cAlias, lSeek, cTrans )

   LOCAL lReturn := .F.

   BEGIN SEQUENCE

      IF ! lSeek
         BREAK
      ENDIF

      IF foundStr( cTrans, "INC_PCOM|OL_BOLETO_PET|RCV_OL_BOLETO_PET|ATUNFE|GRAVA_DEV|GRAVA_CNAB|GRAVA_BORDUP|EXC_BORDUP" )
         BREAK
      ENDIF

      IF Subs( cAlias, 3, 3 ) <> "PET" .AND. cTrans = "CANC_PED"
         BREAK
      ENDIF

      lReturn := .T.

   ENDSEQUENCE

RETURN( lReturn )



STATIC PROCEDURE rcvAddSend( cDefAlias, nLoja )

   LOCAL cAlias := "MX" + cDefAlias + "CFI"

   IF aScan( aRecvSend, { |x| x[ RCV_SEND_TAB ] = cAlias .AND. x[ RCV_SEND_REC ] = ( cAlias )->( mxRecNo() ) .AND. If( nLoja <> NIL, x[ RCV_SEND_NLJ ] = nLja, .T. ) } ) = 0
      aAdd( aRecvSend, { cAlias, ( cAlias )->( mxRecNo() ), nLoja } )
   ENDIF

RETURN