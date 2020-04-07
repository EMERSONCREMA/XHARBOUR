/*

 MaxSist.prg
 Descricao: Biblioteca de funcoes de uso geral no sistema.
 Desenvolvido por MAX SCALLA Informatica Ltda.

 EMERSON DA SILVA CREMA.
 04/06/19 * Ajstada a referencia de "meuip.com.br" em GetIP().
 18/06/18 * Ajuste em GetIP() p/ definicao do IP local e de Internet.
            - Local, agora eh utilizado o ultimo item da matriz retornada.
            - Internet, mudado o link http://meuip.datahouse.com.br/ p/
              http://www.meuip.com.br/.
 14/09/17 * Implementado em Senha() o parametro lSenhaADM.
 26/06/17 * Desenvolvido mxEnviaErro().
 27/10/16 * Removido de mxErrorMail() o envio de email p/ logs@maxscalla.com.br.
 10/10/16 * Implementado o parametro lSN em retSelecao().
 28/08/16 * Removido TimeToSec(), pois existe Secs() no xHarbour.
 09/06/16 * Implementado o parametro cFtpAccount em mxDownLoad().
          * Remvido de mxDownLoad() a utilizacao de csWebVarControl().
          * Removido:
            - csWebVarControl()
            - csWebDBConnect()
 27/05/16 * Implementado caracteres especiais em CHAR_POS e CHAR_TABLE.
 25/04/14 * Trocado em GoDos() o comando COMMAND.COM por CMD.EXE.
 17/02/14 * Alterado mxErrorLog() p/ q gere um LOG para cada dia.
          * Implementado em mxErrorMail() a informacao do "BD Ativo".
 09/10/13 * Removido pager de Fim().
 27/09/13 * Padronizados logs na pasta LOGS\.
 18/09/13 * Corrigida mxDownLoad() p/ q utilize as informacoes de conexao q
            estao em nosso banco da locaweb.
 
 DENIS MAZZUCATTO RODRIGUES
 05/09/13 * Desenvolvimento de sisLenAlias().
 
 EMERSON DA SILVA CREMA
 23/07/13 * Mudado os dados do email padrao em mxErrorMail().
 10/07/13 * Desenvolvimento de csWebVarControl().
          * Movida csWebDBConnect() de MAXLIBCS.PRG.
          * Alteracao em mxDownLoad() p/ identificar a conta de FTP em nosso
            banco de dados do servidor LOCAWEB.
 04/06/13 * Desenvolvimento de mxGetSysVersion().
          * Implementada possibilidade de tentar novamente enviar o email com a
            conta da maxscalla em mxErrorMail().
 13/05/13 * Desenvolvimento de mxDownLoad().
 03/05/13 * Importado mxErrorMail() e MAXLIB03.PRG.
          * Implementado parametro lErrorSys em mxErrorMail().
 05/04/13 * Implementacao de VEREXE em T_Fim().

 DENIS MAZZUCATTO RODRIGUES
 10/10/12 * Implementada tag <(TIME)> em mxDefErrLogTitle().
 13/08/12 * Alteracao em Senha() p/ liberar acesso p/ mais de uma senha.
 18/06/12 * Desenvolvimento de mxProcName().
 25/05/12 * Remocao de DefWinXP() - implementada diretamente em IsWinXP().
 10/08/11 * Removida mxDbRefresh() de SaveState().

 EMERSON DA SILVA CREMA
 01/09/10 * Remocao de csConf_SO().

 DENIS MAZZUCATTO RODRIGUES
 02/06/10 * Movida xAltd() p/ MAXLIBCF.PRG
 27/05/10 * Remocao de xpVideoMode().

 EMERSON DA SILVA CREMA
 30/11/09 * Implementada em GetNoEmpty() a possibilidade de conferencia de
            varias informacoes alternativas de uma so vez usando o segundo
            parametro.

 DENIS MAZZUCATTO RODRIGUES
 17/09/09 * Renomeada In() p/ mxIn().

 EMERSON DA SILVA CREMA
 26/03/09 * Implementado Chr(32) em CHAR_POS e CHAR_TABLE.
 12/03/09 * Desenvolvimento de mxDefErrLogTitle().

 DENIS MAZZUCATTO RODRIGUES
 27/02/09 * Desenvolvimento de varSave() e varRest().

 EMERSON DA SILVA CREMA
 22/01/09 * Alteracoes em csConf_SO():
            - substituicao de FILES= qdo ja existir.
            - verificacao do arquivo .TMP antes de substituir.
 16/01/09 * Desenvolvimento de xAltd().
 05/01/09 * Implementado em csConf_SO() definicao da posicao da configuracao.
 05/12/08 * Implementado letras minusculas em mxEncrypt() e mxDecrypt().
 23/10/08 * Desenvolvimento de getWinDir().
 20/10/08 * Desenvolvimento de mxLen().
 15/08/08 * Trocado em csConf_SO() SO_Windows() por IsWindows().
          * Remocao de SO_Windows().
 13/08/08 * Implementacao em csConf_SO() para q verifique se a maquina esta
            com Windows.
 06/08/08 * Movida cswConf_SO() de CSW.PRG da 3.11 com o nome de csConf_SO().
 15/04/08 * Remocao de vEmpty() pois faz a mesma coisa de GetNoEmpty().
 14/02/08 * Desenvolvimento de IsValue().
 22/01/08 * Desenvolvimento de varClear().
 30/08/07 * Desenvolvimento de mxCrypt() e mxDecrypt().
 09/01/07 * Movida MensErro() direto para a versao 2.12c.
 13/12/06 * Desenvolvimento de DateTime().
 26/09/06 * Desenvolvimento de foundStr().
 17/08/06 * Desenvolvimento de snhKeyMaster().
          * Implementada esquema de personalizacao de calculo de senha
            temporaria master.
 06/07/06 * Implementado parametro lRestScr em mRun().
 27/03/06 * Desenvolvimento de mxTimeStart() e mxElapTime().
 13/03/06 * Desenvolvimento de xpVideoMode().
 12/01/06 * Implementado backspace na digitacao da senha em Senha().
 02/01/06 * Desenvolvimento de mxErrorLog().
 21/11/05 * Desenvolvimento de SumTimes(), TimeToSec() e SecToTime().
 16/11/05 * Desenvolvimento de retSelecao().
 28/10/05 * Desenvolvimento de fEval().
 25/08/05 * Desenvolvimento de auxDefVars().
 26/01/05 * Desenvolvimento de IsWindows().
 20/01/05 * Removida auxSetVars() de LOJAUX.PRG.
 14/01/05 * Implementacao de defSysDate(), defVerDate() e sysDateConf().
 10/11/04 * Desenvolvimento de DefWinXP() e IsWinXP().
 30/07/04 * Desenvolvimento de TiraEspacos().
 20/07/04 * Desenvolvimento de SO_Windows() e IsWinNT().
 19/07/04 * Desenvolvimento de mxGetEnv().
 11/06/04 * Reestruturacao em Senha().
          * Desenvolvimento de senDefStatus().

*/

#include "std.ch"
#include "inkey.ch"
#include "fileIO.ch"
#include "Directry.ch"
#include "msg.ch"

EXTERNAL DESCEND, CRYPT

REQUEST HB_AnsiToOem
REQUEST HB_OemToAnsi
REQUEST HB_UTF8ToStr

#define FTP_FOLDER( cFolder ) If( Empty( cFtpRoot ), "", cFtpRoot + "/" ) + cFolder

#define SYS_COLOR  1
#define SYS_CURSOR 2
#define SYS_DIR    3
#define SYS_POS    4
#define SYS_SCREEN 5
#define SYS_ALIAS  6

#define CHAR_POS     "0123456789ABCDEFGHIJKLMNOPQRSTUVXWYZabcdefghijklmnopqrstuvxwyz |.@-]+_=/[&\%*()!?{};,$#<>:"

#define CHAR_TABLE { ;
                     "AXYESZFRV7P9Q8CWN4OU5T6B2J3K0DHL1GMIaxyeszfrvpqcwnoutbjkdhlgmi <>:)!@/\%*(?{}[=-;+]_&,$#|.",;   // 1
                     "CRTX0M89BU2NVS3WDZ4OPY17QAG5FE6JLHIKcrtxmbunvswdzopyqagfejlhik !@=<>:/[)\(+&?]{}%*;-_,$|#.",;   // 2
                     "B9P8EYVNZCQX3D5O4JMUWA0SK6F2H7RLIT1Gbpeyvnzcqxdojmuwaskfhrlitg !.]|\=<>:(?{&}+%*;-[#_@/,$)",;   // 3
                     "OK9MJBA4LX7HTZ3NWD8G5SYVC0FI2EP6R1UQokmjbalxhtznwdgsyvcfiepruq !|)\?([}{<>:%*;-_]+=@/,$&#.",;   // 4
                     "M5QZEFRYNWSXA4VJ16UO09C2P7IDKT8G3LBHmqzefrynwsxavjuocpidktglbh $#.+!&\?=(}{<>:%*;[-|])_@/,",;   // 5
                     "NCZO2BYLW9MDU1FVPRXI0JE5Q87S4K6HAGT3nczobylwmdufvprxijeqskhagt @/,$+#.!\?(]}={<>:%*[&;-|)_",;   // 6
                     "N0XYBKOW7D4PJ5CLZEFV6IH9QSA8R2UGMT13nxybkowdpjclzefvihqsarugmt |)_&@/[,$#.+]!\?(}<>:={%*;-",;   // 7
                     "20KX1LV3W8D7EFG6MSPJQTN5UAC4HYOBZI9Rkxlvwdefgmspjqtnuachyobzir %*;-|]=)_@/,$#.[&+!\?<>:(}{",;   // 8
                     "5B68CDYM9NOWEZPAQI4S3JRX0UFGTKV1L2H7bcdymnowezpaqisjrxufgtkvlh :(}{%*;-&=|)_@/,$#.+][!\?<>",;   // 9
                     "ENM78RLQ4O6F5JSZA2KYDG3B9PTWXHUC1VI0enmrlqofjszakydgbptwxhucvi #<>:.=!\?(+}[{%*;-|)]_@&/,$",;   // 10
                     "HB8OT6C95GJISZ7R1UF4MD3NQV2YELWX0PAKhbotcgjiszrufmdnqvyelwxpak ,$#.<>:!\?(}]{%*;-|)_=+@/&[",;   // 11
                     "JHIFP4G10A3WEMS2CTDQ5LU6BKNV9YR8X7ZOjhifpgawemsctdqlubknvyrxzo .!\?[@/<>:=,&$+#](}{%*;-|)_" ;   // 12
                   }

#define FERROR_LOG "LOGS\MXERROR_" + DtoS( Date() ) + ".LOG"

STATIC aCSModule     := {}
STATIC lVerDate      := .F.
STATIC nSenStatus    := 0
STATIC nKeySnhMaster := 977
STATIC cSenhaAdm     := "MXADMIN"
STATIC cFlgModule    := "CFI"
STATIC nLenAlias     := 8
STATIC cErrLogTitle  := ""

STATIC dSystemDate, cTimeStart, cWinDir, cFtpAccount, nFtpSize


FUNCTION DefCursor()

   LOCAL nCurAnt := SetCursor( If( ReadInsert(), 3, 2 ) )

RETURN( If( nCurAnt = 0, 0, SetCursor() ) )



FUNCTION MDefault( cVar, uCfg )

   PUBLIC &cVar := If( IsDef( cVar ), &cVar, uCfg )

RETURN( NIL )



FUNCTION vDef( uDef, uValue )

   IF uDef = NIL
      uDef := uValue
   ENDIF

RETURN( uDef )



FUNCTION varSave( aVars )

   LOCAL aSave := {}

   aEval( aVars, { |x| If( isDef( x ), aAdd( aSave, { x, &( x ) } ), NIL ) } )

RETURN( aSave )



FUNCTION varRest( aVars )

   aEval( aVars, { |x| &( x[ 1 ] ) := x[ 2 ] } )

RETURN( NIL )



FUNCTION Senha( ;
                uSenha   ,;
                cUsuario ,;
                lSenhaTmp,;
                nCorFundo,;
                bExecute ,;
                cSenhaBig,;
                cDigSenha,;
                lSenhaADM ;
              )

   LOCAL lReturn    := .T.
   LOCAL lMostraDig := .T.
   LOCAL aState     := SaveState( NIL, {} )
   LOCAL cSenhaAlt  := If( IsDef( "BigBoss" ) .AND. cSenhaBig = NIL, Trim( BigBoss ), "!@#$%^&*(" )
   LOCAL nKeyDigit  := 0
   LOCAL nLen       := Len( If( cUsuario = NIL, "MASTER", cUsuario ) ) +38
   LOCAL nPos       := ( ( 80 - nLen ) / 2 )

   LOCAL aSenhas, nValHora, nValData, cSenhaTmp, lSom

   vDef( @uSenha   , ""       )
   vDef( @cUsuario , "MASTER" )
   vDef( @lSenhaTmp, .T.      )
   vDef( @nCorFundo, 63       )
   vDef( @lSenhaADM, .F.      )

   cDigSenha := ""

   IF lSenhaTmp

      // Calculo da senha temporaria

      nValHora  := Val( Subs(       Time()  , 7, 2 ) + Subs(       Time()  , 4, 2 ) )
      nValData  := Val( Subs( DtoC( Date() ), 1, 2 ) + Subs( DtoC( Date() ), 4, 2 ) )
      nValHora  := Max( nValHora, 100 )
      cSenhaTmp := NumToStr( Int( nValHora * nValData / nKeySnhMaster ) )

   ENDIF
   
   IF ValType( uSenha ) = "A"
      aSenhas := {}
      aEval( uSenha, { |s| aAdd( aSenhas, Upper( AllTrim( s ) ) ) } )
   ELSE
      aSenhas := { Upper( AllTrim( uSenha ) ) }
   ENDIF
   
   aAddC( aSenhas, SenhaADM() )
   aAddC( aSenhas, Upper( cSenhaAlt ) )
   aAddC( aSenhas, cSenhaTmp, lSenhaTmp )
   
   SetCursor(0)
   SetColor( "0/7" )

   Muda_Cor( 01, 00, MaxRow() -1, 79, nCorFundo )
   mxTone( 499, 1 )
   mxTone( 520, 3 )

   IF bExecute <> NIL
      EVal( bExecute )
   ENDIF

   IF nSenStatus = 0

      MStatus( { { "ESC", "15/7" }, { "úAbandona", "0/7" } }, 2 )

      Limpa( If( lSenhaTmp, 16, 18 ), nPos -4, 20, nPos + nLen +3, "S" )

   ELSE

      mStatus( { { "", "0/7" }, { " ESC ", "15/09" }, { " Retorna ", "0/7" } }, 2 )
      
      @ If( lSenhaTmp, 16, 18 ), nPos -4, 20, nPos + nLen +3 BOX "ÛßÛÛÛÜÛÛ " COLOR "15/7"

      Shadow( If( lSenhaTmp, 16, 18 ), nPos -4, 20, nPos + nLen +3 )

   ENDIF

   IF lSenhaTmp
      IF nSenStatus = 0
         @ 17, nPos -3 SAY PadC( "úúú N£mero de controle (" + Str( nValHora, 4 ) + ") úúú", nLen +6 )
      ELSE
         @ 17, nPos -3 SAY PadC( "N£mero de controle [ " + NumToStr( nValHora ) + " ]", nLen +6 ) COLOR "4/7"
      ENDIF
   ENDIF

   DO WHILE nKeyDigit <> K_ESC

      IF lMostraDig

         @ 19, nPos -3         SAY PadC( "Digite a senha de acesso " + cUsuario + " " + Chr(26) + " __________", nLen +6 )
         @ 19, nPos + nLen -10 SAY "Û" COLOR "15/7"

         lMostraDig := .F.

      ENDIF

      IF ( ( nKeyDigit := mxInKey() ) > 32 .AND. nKeyDigit < 127 ) .OR. nKeyDigit = K_BS

         lSom := .T.

         IF nKeyDigit <> K_BS
            cDigSenha += Chr( nKeyDigit )
         ELSEIF Len( cDigSenha ) > 0
            cDigSenha := Left( cDigSenha, Len( cDigSenha ) -1 )
         ELSE
            lSom := .F.
         ENDIF

         @ 19, nPos -3                            SAY PadC( "Digite a senha de acesso " + cUsuario + " " + Chr(26) + " " + PadR( Repl( "#", Len( cDigSenha ) ), 10, "_" ), nLen + 6 )
         @ 19, nPos + nLen -10 + Len( cDigSenha ) SAY "Û" COLOR "15/7"

         IF lSom
            mxTone( 100, 0.01 )
         ENDIF

      ENDIF

      IF mxIn( nKeyDigit, { K_ENTER, K_F2 } ) .OR. ( Len( cDigSenha ) = 10 )

         IF mxIn( Upper( cDigSenha ), aSenhas ) .OR. ( nKeyDigit = K_F2 .AND. lSenhaADM )

            @ 19, nPos - 3 SAY PadC( "Acesso permitido !", nLen + 6 ) COLOR "9/7"
            ClearKeybBuffer()
            mxTone( 1500, 12 )
            mxInKey( 0.5 )
            EXIT

         ELSE

            @ 19, nPos - 3 SAY PadC( "Acesso negado !", nLen + 6 ) COLOR "12/7"
            ClearKeybBuffer()
            mxTone( 80, 12 )
            mxInKey( 0.5 )
            lMostraDig := .T.
            cDigSenha  := ""

         ENDIF

      ENDIF

   ENDDO

   IF nKeyDigit = K_ESC
      lReturn := .F.
   ENDIF

   RestState( aState, .F., .F., .T., .T. )

   ClearKeybBuffer()

RETURN( lReturn )



FUNCTION senDefStatus( nStatus )

   nSenStatus := nStatus

RETURN( NIL )



FUNCTION SenhaADM( cSenha )

   LOCAL cReturn := cSenhaADM

   IF cSenha <> NIL
      cSenhaADM := cSenha
   ENDIF

RETURN( cReturn )



FUNCTION snhKeyMaster( nKey )

   LOCAL nReturn := nKeySnhMaster

   IF nKey <> NIL
      nKeySnhMaster := nKey
   ENDIF

RETURN( nReturn )



FUNCTION T_Fim()

   LOCAL cVersao := ""
   
   SetColor( "7/0" )
   CLS

   DispBox( 02, 04, 22, 77, "°°°°°°°°°", "00/8" )
   DispBox( 01, 03, 21, 76, "ÜÜÜÛßßßÛÛ", "15/0" )
   DispBox( 02, 04, 20, 75, "ÛÛÛÛÛÛÛÛÛ", "07/0" )

   Say( 21, 03, "Û" + Repl( "Ü", 72 ) + "Û", NIL, "15/7" )

   SetColor( "11/7" )

   Say( 08, 06, Repl( "Ä", 68 ) )
   Say( 10, 06, Repl( "Ä", 68 ) )
   Say( 18, 06, Repl( "Ä", 68 ) )

   IF IsDef( "VERSAO" )
      cVersao += "- VERSAO " + Trim( UtoC( VERSAO ) )
   ENDIF
   
   IF IsDef( "VEREXE" )
      cVersao += "." + UtoC( VEREXE )
   ELSEIF IsDef( "RELEASE" ) .AND. RELEASE > 0
      cVersao += "." + UtoC( RELEASE )
   ENDIF

   IF IsDef( "SISTEMA" ) .AND. "CONTROL SHOP" $ Upper( SISTEMA )
      Say( 03, 05, PadC( "^CONTROL SHOP ù Sistema Comercial e Financeiro ^" + cVersao, 72 ),"11/8","15/8" )
   ELSE
      Say( 03, 05, PadC( "^&SISTEMA ^" + cVersao, 72 )                                     ,"11/8","15/8" )
   ENDIF

   Say( 05, 05, PadC( "Desenvolvido por :"                                     , 70 ), NIL, "0/7" )
   Say( 07, 05, PadC( "MAX SCALLA INFORMATICA LTDA."                           , 70 ), NIL, "1/7" )

   Say( 19, 05, PadC( "Max Scalla Inform tica Ltda.  -  FoneFax (11) 4479.6605", 70 ), NIL, "0/7" )
   Say( 20, 05, PadC( "BIP ú Central 4003.8200  C¢digo 4029688"                , 70 ), NIL, "0/7" )

RETURN( NIL )



FUNCTION Fim( uPergunta )

   IF uPergunta = NIL .AND. ConfMsg( "Confirma final de opera‡„o", SimNao ) = 2
      ClearKeybBuffer()
      RETURN( .F. )
   ENDIF

   mxDispBegin()

   IF IsDef( "MAXSCALLA" ) .AND. Empty( MAXSCALLA )
      SetColor( "7/0" )
      CLS
   ELSE
      T_Fim()

      SetColor( "0/7" )

      Say( 09, 05, PadC( "Acesse nosso site: ^www.maxscalla.com.br^", 72 ), "4/7" )
      Say( 11, 05, PadC( "Suporte t‚cnico deste sistema:"           , 70 ) )
      Say( 13, 05, PadC( "FoneFax ^(11) 4479.6605^"                 , 72 ), "4/7" )

      Say( 19, 05, PadC( "Aten‡„o Sr. usu rio, n„o se esque‡a de fazer as c¢pias de seguran‡a.", 70 ), NIL, "0/7" )
      Say( 20, 05, PadC( "Elas protegem e evitam eventuais perdas de dados."                   , 70 ), NIL, "0/7" )
   ENDIF

   mxDispEnd()

   TRY
      DbCloseAll()
   CATCH
      // Nada a executar.
   END

   mxTone( 449, 5 )
   SetColor( "7/0" )
   SetPos( MaxRow() -1, 00 )
   SetCursor( 1 )
   QUIT

RETURN( .T. )



FUNCTION GoDos()

   LOCAL cScreen := SaveScreen( 00, 00, MaxRow(), 79 )
   LOCAL cColor  := SetColor()
   LOCAL nCursor := SetCursor(1)

   SetColor( "7/0" )
   CLS
   @ 00,00 SAY 'Digite "EXIT" para retornar ao sistema ' + SISTEMA + "." COLOR "15/0"

   //! COMMAND.COM
   
   ! CMD.EXE

   RestScreen( 00, 00, MaxRow(), 79, cScreen )
   SetCursor( nCursor )
   SetColor( cColor )

RETURN( NIL )



FUNCTION Extenso( nValor, nLen )

   LOCAL cValor, nLenNum, cExtenso, cValUnid, nSubVal

   LOCAL cTabCem := "           CENTO       DUZENTOS    TREZENTOS   QUATROCENTOS" + ;
                    "QUINHENTOS  SEISCENTOS  SETECENTOS  OITOCENTOS  NOVECENTOS  "

   LOCAL cTabDez := "                   VINTE     TRINTA    QUARENTA  CINQUENTA " + ;
                    "SESSENTA  SETENTA   OITENTA   NOVENTA    "

   LOCAL cTabOnz := "DEZ     ONZE     DOZE     TREZE    QUATORZE QUINZE   DEZESSEIS" + ;
                    "DEZESSETEDEZOITO  DEZENOVE "

   LOCAL cTabUni := "     UM    DOIS  TRES  QUATROCINCO SEIS  SETE  OITO  NOVE  "

   PUBLIC EXLIN1 := " "
   PUBLIC EXLIN2 := " "

   cValor   := StrZero( nValor, 15, 2 )
   cValor   := Left( cValor, 12 ) + "0" + Subs( cValor, 14, 2 )
   nLenNum  := 1
   cExtenso := " "

   DO WHILE nLenNum < 16

      cValUnid := Subs( cValor, nLenNum, 3 )

      IF ( nLenNum = 4 )                      .AND. ;
         ( Subs( cValor, 1, 3 ) <> "000"    ) .AND. ;
         ( Subs( cValor, 4, 3 ) <> "000"    ) .AND. ;
         ( Subs( cValor, 7, 6 ) =  "000000" )
         cExtenso += " E "
      ENDIF

      IF ( nLenNum = 7 )                       .AND. ;
         ( Subs( cValor,  1, 6 ) <> "000000" ) .AND. ;
         ( Subs( cValor, 10, 3 ) =  "000"    ) .AND. ;
         ( Subs( cValor,  7, 3 ) <> "000"    )
         cExtenso += " E "
      ENDIF

      IF ( nLenNum = 10 )                         .AND. ;
         ( Subs( cValor, 10, 3 ) <> "000"       ) .AND. ;
         ( Subs( cValor,  1, 9 ) <> "000000000" )
         cExtenso += " E "
      ENDIF

      IF cValUnid = "100"
         cExtenso += " CEM "
      ENDIF

      IF ! foundStr( cValUnid, "000|100" )
         nSubVal := Val( Left( cValUnid, 1 ) )
         IF nSubVal <> 0
            cExtenso += Trim( Subs( cTabCem, nSubVal * 12, 12 ) )
         ENDIF
         IF Subs( cValUnid, 2, 1 ) <> "0"
            IF Left( cValUnid, 1 ) <> "0"
               cExtenso += " E "
            ENDIF
            IF Subs( cValUnid, 2, 1 ) <> "1"
               nSubVal := Val( Subs( cValUnid, 2, 1 ) )
               cExtenso  += Trim( Subs( cTabDez, nSubVal * 10, 10 ) )
            ELSE
               nSubVal := Val( Subs( cValUnid, 3, 1 ) )
               IF nSubVal = 0
                  cExtenso += " DEZ "
               ELSE
                  cExtenso += Trim( Subs( cTabOnz, nSubVal * 9, 9 ) )
               ENDIF
            ENDIF
         ENDIF

         IF ( Subs( cValUnid, 3, 1 ) <> "0" ) .AND. ;
            ( Subs( cValUnid, 2, 1 ) <> "1" )

            IF ( Subs( cValUnid, 1, 2 ) <> "00" ) .AND. ;
               ( Subs( cValUnid, 2, 1 ) <> "1" )
               cExtenso += " E "
            ENDIF

            nSubVal  := Val( Subs( cValUnid, 3, 1 ) )
            cExtenso += Trim( Subs( cTabUni, nSubVal * 6, 6 ) )

         ENDIF

      ENDIF

      DO CASE
         CASE nLenNum = 1
              IF ! foundStr( cValUnid, "000|001" )
                 cExtenso += " BILHOES "
              ELSEIF cValUnid = "001"
                 cExtenso += " BILHAO "
              ENDIF
         CASE nLenNum = 4
              IF ! foundStr( cValUnid, "000|001" )
                 cExtenso += " MILHOES "
              ELSEIF cValUnid = "001"
                 cExtenso += " MILHAO "
              ENDIF
         CASE nLenNum = 7
              IF cValUnid <> "000"
                 cExtenso += " MIL "
              ENDIF
         CASE nLenNum = 10
              IF Left( cValor, 3 ) <> "000" .AND. Subs( cValor, 4, 7 ) = "0000000"
                 IF Right( cValor, 2 ) = "00"
                    cExtenso += " DE REAIS"
                 ELSE
                    cExtenso += " DE REAIS E "
                 ENDIF
              ELSEIF cValUnid = "001"
                IF Right( cValor, 2 ) = "00"
                   cExtenso += " REAL"
                ELSE
                   cExtenso += " REAL E "
                ENDIF
             ELSEIF Left( cValor, 9 ) <> "000000000"
                IF Right( cValor, 2 ) = "00"
                   cExtenso += " REAIS"
                ELSE
                   cExtenso += " REAIS E "
                ENDIF
             ELSEIF ! foundStr( cValUnid, "000|001" )
                IF Right( cValor, 2 ) = "00"
                   cExtenso += " REAIS"
                ELSE
                   cExtenso += " REAIS E "
                ENDIF
             ELSEIF cValUnid = "001"
                IF Right( cValor, 2 ) = "00"
                   cExtenso += " REAL"
                ELSE
                   cExtenso += " REAL E "
                ENDIF
             ENDIF
      ENDCASE

      nLenNum += 3

   ENDDO

   IF Subs( cValor, 13, 3 ) = "001"
      cExtenso += " CENTAVO "
   ELSEIF Subs( cValor, 13, 3 ) <> "000"
      cExtenso += " CENTAVOS "
   ENDIF

   cExtenso := AllTrim( cExtenso )

   DO WHILE At( "  ", cExtenso ) > 0
      cExtenso := StrTran( cExtenso, "  ", " " )
   ENDDO

   EXLIN1 := AllTrim( Left( cExtenso, nLen - 1 ) )

   IF Len( cExtenso ) > nLen .AND. ! Empty( Right( EXLIN1, 1 ) ) .AND. ! Empty( Left( Subs( cExtenso, Len( EXLIN1 ) + 1 ), 1 ) )
      EXLIN1 := AllTrim( Left( EXLIN1, Rat( " ", EXLIN1 ) ) )
   ENDIF

   EXLIN2 := AllTrim( Subs( cExtenso, Len( EXLIN1 ) + 1, nLen ) )

   EXLIN1 := "*" + EXLIN1 + Repl( "*", nLen - Len( EXLIN1 ) -1 )
   EXLIN2 += Repl( "*", nLen - Len( EXLIN2 ) )

RETURN( .T. )



FUNCTION Repl_Cod( uCod, uCodUse )

   IF ! ESC .AND. uCod <> NIL
      uCod := uCodUse
   ENDIF

RETURN( NIL )



FUNCTION SaveState( aState, aSelect, aNoSelect )

   LOCAL cAliasOld, nOrderOld, nRecnoOld, nAlias, cAlias

   IF Used()
      cAliasOld := Alias()
      nOrderOld := IndexOrd()
      nRecnoOld := mxRecNo()
   ENDIF

   vDef( @aState, {} )

   IF aSelect = NIL

      FOR nAlias := 1 TO 255

         Select( nAlias )

         IF Used()

            IF aNoSelect <> NIL
               IF Left( Alias(), 2 ) = "MX" .AND. aScan( aNoSelect, { |a| a = Subs( Alias(), 3, 3 ) } ) > 0
                  LOOP
               ENDIF
            ENDIF

            aAdd( aState, { ;
                            ( nAlias )->( Alias() ),;
                            ( nAlias )->( IndexOrd() ),;
                            ( nAlias )->( mxRecNo() ) ;
                          } )

         ENDIF

      NEXT

      IF cAliasOld <> NIL
         Select( cAliasOld )
      ENDIF

   ELSE

      FOR nAlias := 1 TO Len( aSelect )

         IF Len( aSelect[ nAlias ] ) = 3
            cAlias := "MX" + aSelect[ nAlias ] + sisFlgModule()
         ELSE
            cAlias := Trim( aSelect[ nAlias ] )
         ENDIF

         IF Select( cAlias ) > 0

            aAdd( aState, { ;
                            cAlias,;
                            ( cAlias )->( IndexOrd() ),;
                            ( cAlias )->( mxRecNo() ) ;
                          } )
         ENDIF

      NEXT

   ENDIF

   aAdd( aState, { ;
                   cAliasOld       ,;
                   nOrderOld       ,;
                   nRecNoOld       ,;
                   SetColor()      ,;
                   SetCursor()     ,;
                   SaveScreen()    ,;
                   { Row(), Col() } ;
                 } )

RETURN( aClone( aState ) )



FUNCTION RestState( aState, lSaveAlias, lSaveRecord, lDisp, lSaveScr )

   #define RS_ALIAS  1
   #define RS_ORDER  2
   #define RS_RECNO  3
   #define RS_COLOR  4
   #define RS_CURSOR 5
   #define RS_SCREEN 6
   #define RS_POS    7

   LOCAL nLast, nAlias, cAlias

   IF aState = NIL
      RETURN( NIL )
   ENDIF

   nLast := Len( aState )

   vDef( @lSaveAlias , .T. )
   vDef( @lSaveRecord, .F. )
   vDef( @lDisp      , .T. )
   vDef( @lSaveScr   , .T. )

   FOR nAlias := 1 TO Len( aState )

      cAlias := aState[ nAlias, RS_ALIAS ]

      IF cAlias <> NIL .AND. Select( cAlias ) > 0 .AND. ( lSaveAlias .OR. nAlias < nLast )

         ( cAlias )->( mxOrder( aState[ nAlias, RS_ORDER ] ) )

         IF lSaveRecord
            ( cAlias )->( mxGoTo( aState[ nAlias, RS_RECNO ] ) )
         ENDIF

         IF nAlias = nLast
            SeleArea( cAlias )
         ENDIF

     ENDIF

   NEXT

   IF lDisp
      IF lSaveScr
         RestScreen( ,,,, aState[ nLast, RS_SCREEN ] )
      ENDIF
      SetColor( aState[ nLast, RS_COLOR ] )
      SetCursor( aState[ nLast, RS_CURSOR ] )
      SetPos( aState[ nLast, RS_POS, 1 ], aState[ nLast, RS_POS, 2 ] )
   ENDIF

RETURN( NIL )



FUNCTION CfgSet()

   #include "simpleio.ch"

   REQUEST HB_CODEPAGE_PLISO
   /*
   REQUEST HB_CODEPAGE_PT850
   REQUEST HB_CODEPAGE_BG866
   REQUEST HB_CODEPAGE_BGISO
   REQUEST HB_CODEPAGE_BGMIK
   REQUEST HB_CODEPAGE_BGWIN
   REQUEST HB_CODEPAGE_CS852
   REQUEST HB_CODEPAGE_CSISO
   REQUEST HB_CODEPAGE_CSWIN
   REQUEST HB_CODEPAGE_DE850
   REQUEST HB_CODEPAGE_DEISO
   REQUEST HB_CODEPAGE_DEWIN
   REQUEST HB_CODEPAGE_EL737
   REQUEST HB_CODEPAGE_ELWIN
   REQUEST HB_CODEPAGE_EN
   REQUEST HB_CODEPAGE_ES850
   REQUEST HB_CODEPAGE_ES850C
   REQUEST HB_CODEPAGE_ESISO
   REQUEST HB_CODEPAGE_ESMWIN
   REQUEST HB_CODEPAGE_ESWIN
   REQUEST HB_CODEPAGE_FR850
   REQUEST HB_CODEPAGE_FRISO
   REQUEST HB_CODEPAGE_FRWIN
   REQUEST HB_CODEPAGE_HR852
   REQUEST HB_CODEPAGE_HRWIN
   REQUEST HB_CODEPAGE_HU852
   REQUEST HB_CODEPAGE_HUISO
   REQUEST HB_CODEPAGE_HUWIN
   REQUEST HB_CODEPAGE_IT437
   REQUEST HB_CODEPAGE_IT850
   REQUEST HB_CODEPAGE_ITISB
   REQUEST HB_CODEPAGE_ITISO
   REQUEST HB_CODEPAGE_ITWIN
   REQUEST HB_CODEPAGE_LTWIN
   REQUEST HB_CODEPAGE_PL852
   REQUEST HB_CODEPAGE_PLISO
   REQUEST HB_CODEPAGE_PLMAZ
   REQUEST HB_CODEPAGE_PLWIN
   REQUEST HB_CODEPAGE_PT850
   REQUEST HB_CODEPAGE_PTISO
   REQUEST HB_CODEPAGE_RO852
   REQUEST HB_CODEPAGE_ROISO
   REQUEST HB_CODEPAGE_ROWIN
   REQUEST HB_CODEPAGE_SKISO
   REQUEST HB_CODEPAGE_SKWIN
   REQUEST HB_CODEPAGE_SL852
   REQUEST HB_CODEPAGE_SLISO
   REQUEST HB_CODEPAGE_SLWIN
   REQUEST HB_CODEPAGE_SRWIN
   REQUEST HB_CODEPAGE_SV850
   REQUEST HB_CODEPAGE_SVISO
   REQUEST HB_CODEPAGE_SVWIN
   REQUEST HB_CODEPAGE_TR857
   REQUEST HB_CODEPAGE_TRWIN
   REQUEST HB_CODEPAGE_UA1125
   REQUEST HB_CODEPAGE_UA1251
   REQUEST HB_CODEPAGE_UA866
   REQUEST HB_CODEPAGE_UAKOI8
   */

   SET SCOR OFF
   SET EXCL OFF
   SET EXAC ON
   SET DELE ON
   SET WRAP ON
   SET CENT ON
   SET ESCA ON
   SET EPOC TO 1950
   SET MESS TO 24
   SET DECI TO 12
   SET DATE GERM

   SetBlink(.F.)
   SetCancel(.F.)
   mSetCursor(.F.)

   //SR_SetMultiLang(.T.)
   //SR_SetBaseLang( LANG_PT_BR )
   //SR_SetSecondLang( LANG_PT_BR )

   HB_SETCODEPAGE( "PLISO" )
   
RETURN( NIL )


/*----------------------------------------------------------------------------
 Verifica se a rotina atual e proveniente de outra rotina passado como
 parametro.

 Parametros

 hProcedure : Rotina a ser verificada
 nRun       : Numero chamadas da rotina (utilizado p/ evitar recursividade).

 Retorno : .T. se estiver na rotina.
----------------------------------------------------------------------------*/

FUNCTION IsProcedure( hProcedure, nRun )

   LOCAL lReturn := .F.
   LOCAL nCount  := nCountRun := 0

   LOCAL cProcName, lVer

   vDef( @nRun, 1 )

   DO WHILE ! Empty( cProcName := Upper( Left( Trim( ProcName( nCount++ ) ), 10 ) ) )

      IF ValType( hProcedure ) = "A"
         lVer := ( aScan( hProcedure, { |p| cProcName = Trim( Left( Upper(p), 10 ) ) } ) > 0 )
      ELSE
         lVer := ( cProcName = Trim( Left( Upper( hProcedure ), 10 ) ) )
      ENDIF

      IF lVer .AND. ( ++ nCountRun = nRun )
         lReturn := .T.
         EXIT
      ENDIF

   ENDDO

RETURN( lReturn )



FUNCTION mxIn( hVerify, aVerify )

   LOCAL lReturn := aScan( aVerify, { |x| x = hVerify } ) > 0

RETURN( lReturn )



FUNCTION DefArqTmp( cPath, cExt )

   LOCAL cArq

   vDef( @cPath, ""     )
   vDef( @cExt , ".DBF" )

   DO WHILE .T.
      cArq := Num_TempFile()
      IF TempInMemory()
         IF Select( "TEMP" + cArq ) = 0
            EXIT
         ENDIF
      ELSEIF ! File( cPath + "TEMP" + cArq + cExt )
         EXIT
      ENDIF
   ENDDO

RETURN( cArq )



FUNCTION IsDef( cVar )

   LOCAL lReturn := ( Left( Type( cVar ), 1 ) <> "U" )

RETURN( lReturn )



FUNCTION AjusCond( cVar, cCond, cOper )

   vDef( @cOper, " .AND. " )

   IF Len( cVar ) > 0
      cVar += cOper
   ENDIF

   cVar += cCond

RETURN( cVar )



FUNCTION MRun

   PARAMETERS cCommand, lRestScr

   LOCAL aState := {}

   vDef( @lRestScr, .T. )

   SaveState( @aState )
   SetCursor( 0 )
   SetPos( 0, 0 )

   ! &cCommand

   RestState( aState, .F., .F., lRestScr, lRestScr )

   mSetPos( MaxRow(), 79 )

RETURN( .T. )


/*----------------------------------------------------------------------------
 Efetua uma pausa com tempo estipulado.

 Parametros

 cDelay : Tempo que deve ser aguardado. ( Ex: "1:00" - um minuto )
----------------------------------------------------------------------------*/

FUNCTION mxDelay( cDelay, lExit )

   LOCAL cInit   := Time()
   LOCAL nCursor := SetCursor( 0 )
   LOCAL cElapsed

   vDef( @lExit, .F. )

   DO WHILE .T.

      cElapsed := ElapTime( cInit, Time() )
      cElapsed := Right( cElapsed, Len( cDelay ) )

      IF cElapsed >= cDelay
         EXIT
      ENDIF

      IF lExit .AND. mxInKey( 0.01 ) = K_ESC
         EXIT
      ENDIF
      
   ENDDO

   SetCursor( nCursor )

RETURN( NIL )



/*----------------------------------------------------------------------------
 Verifica a quantidade de segundos passados de um tempo inicial.
 Usada em conjunto com timeStart().

 Parametros

 cWait : Tempo que deve ser aguardado. ( Ex: "1:00" - um minuto )
----------------------------------------------------------------------------*/

FUNCTION timeElapsed( cWait )

   LOCAL cElapsed := ElapTime( cTimeStart, Time() )

   cElapsed := Right( cElapsed, Len( cWait ) )

RETURN( cElapsed >= cWait )



FUNCTION timeStart()

   cTimeStart := Time()

RETURN( NIL )



FUNCTION KeyReset( aKeys )

   LOCAL aKeyReset := {}

   aEval( aKeys, { |k| aAdd( aKeyReset, { k, SetKey( k, NIL ) } ) } )

RETURN( aKeyReset )



FUNCTION KeyRestore( aKeys )

   aEval( aKeys, { |k| SetKey( k[1], k[2] ) } )

RETURN( NIL )



FUNCTION mxGetEnv( cEnv )

   LOCAL cStrVar := Upper( EnvParam() )
   LOCAL cReturn := ""

   LOCAL cVar, nCount

   BEGIN SEQUENCE

      DO WHILE ! Empty( cStrVar )

         cVar    := Left( cStrVar, At( _NL, cStrVar ) -1 )
         cStrVar := Subs( cStrVar, At( _NL, cStrVar ) +2 )

         FOR nCount := 1 TO 2

            IF Left( cVar, At( "=", cVar ) ) = If( nCount = 1, cEnv, Upper( cEnv ) ) + "="
               cReturn := Subs( cVar, At( "=", cVar ) + 1 )
               BREAK
            ENDIF

         NEXT

      ENDDO

   ENDSEQUENCE

RETURN( cReturn )



FUNCTION IsWinXP()

   LOCAL lReturn := ( mxGetEnv( "OS" ) = "WINDOWS_NT" )

RETURN( lReturn )



FUNCTION IsWinNT()

   LOCAL lReturn := mxIn( Upper( mxGetEnv( "OS" ) ), { "WINDOWS NT", "WINDOWS_NT" } )

RETURN( lReturn )



FUNCTION WinOSInfo()

   LOCAL cReturn := ""
   
   DO CASE
      CASE Os_IsWin7()    ; cReturn := "Win7"
      CASE Os_IsWinNT()   ; cReturn := "WinNT"
      CASE Os_IsWinXP()   ; cReturn := "WinXP"
      CASE Os_IsWin95()   ; cReturn := "Win95"
      CASE Os_IsWin98()   ; cReturn := "Win98"
      CASE Os_IsWinME()   ; cReturn := "WinME"
      CASE Os_IsWin2003() ; cReturn := "Win2003"
   ENDCASE

RETURN( cReturn )



FUNCTION getWinDir()

   IF cWinDir = NIL
      IF IsWinNT()
         cWinDir := mxGetEnv( "SYSTEMROOT" )
      ELSE
         cWinDir := mxGetEnv( "WINBOOTDIR" )
      ENDIF
      IF Empty( cWinDir )
         cWinDir := "C:\WINDOWS"
      ENDIF
   ENDIF

RETURN( cWinDir )



FUNCTION GetIP( lInternet )

   LOCAL cReturn  := ""

   LOCAL oHttp, cHtml, cEstacao, aHosts, nPos

   vDef( @lInternet, .F. )

   IF lInternet

      oHttp := TIpClientHttp():new( "http://www.meuip.com.br/" )

      IF oHttp:open()

         cHtml := oHttp:readAll()
         oHttp:close()

         IF ValType( cHtml ) = "C"
            cHtml   := HB_AnsiToOEM( HB_UTF8ToStr( cHtml ) )
            nPos    := At( 'Meu ip ‚', cHtml   )
            IF nPos <> 0
               cReturn := Subs( cHtml  , nPos + 9 )
               cReturn := Left( cReturn, At( '</'      , cReturn ) - 1 )
            ENDIF
         ENDIF

      ENDIF

   ELSE

      cEstacao := NetName( .F. )

      InetInit()

      aHosts := InetGetHosts( cEstacao )

      IF aHosts = NIL
         aHosts := InetGetAlias( cEstacao )
      ENDIF
      IF Empty( aHosts )
         aHosts := InetGetAlias( cEstacao )
      ENDIF

      InetCleanup()

      IF Len( aHosts ) > 0
         cReturn := aHosts[ Len( aHosts ) ]
      ENDIF

   ENDIF

RETURN( AllTrim( cReturn ) )



FUNCTION defSysDate( dDate )

   LOCAL dReturn := dSystemDate

   IF dDate <> NIL
      dSystemDate := dDate
   ENDIF

RETURN( dReturn )



FUNCTION defVerDate( lDef )

   LOCAL lReturn := lVerDate

   IF lDef <> NIL
      lVerDate := lDef
   ENDIF

RETURN( lReturn )



FUNCTION sysDateConf()

   IF defVerDate() .AND. Date() < defSysDate()
      defVerDate(.F.)
      MsgDlg( "A data do computador foi alterada !;" + ;
              "O sistema ser  finalizado." )
      Fim(0)
   ENDIF

RETURN( NIL )



PROCEDURE auxSetVars

   LOCAL hFile := mxFOpen( "VARS.SET" )

   LOCAL cLinha, cType, cInfo, cVars

   DO WHILE LineRead( hFile, @cLinha )

      IF Left( cLinha, 2 ) = "//"
         LOOP
      ENDIF

      cType := Left( cLinha, 1 )
      cVars := Subs( cLinha, 3, At( ":=", cLinha ) - 4 )
      cInfo := Subs( cLinha, At( ":=", cLinha ) + 3 )

      DO CASE
         CASE cType = "L" ; uInfo := If( cInfo = ".T.", .T., .F. )
         CASE cType = "N" ; uInfo := Val( cInfo )
         CASE cType = "D" ; uInfo := CtoD( cInfo )
         OTHE             ; uInfo := cInfo
      ENDCASE

      PUBLIC &cVars := uInfo

   ENDDO

   FClose( hFile )

RETURN( NIL )



FUNCTION auxDefVars( cVar, uDefault )

   LOCAL uVar := uDefault

   IF IsDef( cVar )
      uVar := &cVar
   ENDIF

RETURN( uVar )



FUNCTION IsWindows()

   LOCAL lWindows := .F.

   IF ! Empty( mxGetEnv( "winbootdir" ) ) .OR. ;
      ! Empty( mxGetEnv( "windir"     ) ) .OR. ;
      IsWinNT()
      lWindows := .T.
   ENDIF

RETURN( lWindows )



FUNCTION fEval( bEval, nLoop )

   LOCAL nCount

   FOR nCount := 1 TO nLoop
      Eval( bEval, nCount )
   NEXT

RETURN( .T. )



FUNCTION retSelecao( cSelecao, aSelecao, nPosIni, cVazio, lSN )

   LOCAL cReturn := ""
   LOCAL nPos    := 0
   LOCAL nCount, nMax

   vDef( @nPosIni, 1 )
   vDef( @cVazio , "Nenhum" )
   vDef( @lSN    , .T. )
   
   IF nPosIni = 1
      nMax := Len( aSelecao )
   ELSE
      nMax := Len( cSelecao )
   ENDIF
   
   IF lSN

      FOR nCount := nPosIni TO nMax

         nPos ++

         IF Subs( cSelecao, nCount, 1 ) = "S"

            IF ! Empty( cReturn )
               cReturn += "/"
            ENDIF

            cReturn += aSelecao[ nPos ]

         ENDIF

      NEXT
      
   ELSE
   
      FOR nCount := 1 TO Len( cSelecao )

         nPos := aScan( aSelecao, { |x| Left( x, 1 ) = Subs( cSelecao, nCount, 1 ) } )

         IF nPos > 0

            IF ! Empty( cReturn )
               cReturn += "/"
            ENDIF

            cReturn += aSelecao[ nPos ]

         ENDIF

      NEXT

   ENDIF

   IF Empty( cReturn )
      cReturn := cVazio
   ENDIF

RETURN( cReturn )



FUNCTION SecToTime( nSeconds )

   // Converte um total de segundos para um string de tempo.

   LOCAL cHours, nHours, nMinutes, nCalc

   nHours   := ( nSeconds - ( nSeconds % 3600 ) ) / 3600
   nSeconds := nSeconds % 3600
   nMinutes := ( nSeconds - ( nSeconds % 60 ) ) / 60
   nSeconds := nSeconds % 60

   cHours := LTrim( Str( Int( nHours ) ) ) + ":" + StrZero( nMinutes, 2 ) + ":" + StrZero( nSeconds, 2 )

RETURN( cHours )



FUNCTION DateTime( dData, cHora )

   LOCAL nDateTime := Val( Dtos( dData ) ) + Secs( cHora ) / Secs( "24:00" )

RETURN( nDateTime )



FUNCTION mxErrorLog( cError, cAddInfo )

   LOCAL nLog := 0
   LOCAL cLog := ""
   LOCAL cFile, cSubject

   cLog += cError
   cLog += _NL

   IF cAddInfo <> NIL
      cLog += _NL
      cLog += cAddInfo + _NL
   ENDIF

   IF ! Empty( mxDefErrLogTitle() )
      cLog += mxDefErrLogTitle() + _NL
   ENDIF

   IF Hb_FSize( FERROR_LOG ) > 10000000  // 10mb
      DO WHILE .T.
         cFile := ModExt( FERROR_LOG, "." + StrZero( nLog ++, 3 ) )
         IF nLog > 1000
            nLog := 0
            mxFDel( ModExt( FERROR_LOG, ".???" ), FERROR_LOG )
         ELSEIF ! File( cFile )
            fRename( FERROR_LOG, cFile )
            EXIT
         ENDIF
      ENDDO
   ENDIF

   mxFAddLine( FERROR_LOG, cLog )

RETURN( cLog )




FUNCTION mxEnviaErro( cError )

   LOCAL lEnvia := .T.

   TRY
      cReadError := MemoRead( FERROR_LOG )
      IF cError $ cReadError
         lEnvia := .F.
      ENDIF
   CATCH
      lEnvia := .T.
   END
   
RETURN( lEnvia )




FUNCTION mxEncrypt( cEnc )

   LOCAL cReturn   := ""
   LOCAL nChrTable := 0

   LOCAL nChr, nCount

   FOR nCount := 1 TO Len( cEnc )
      nChr    := At( Subs( cEnc, nCount, 1 ), CHAR_POS )
      cReturn += Subs( CHAR_TABLE[ ++ nChrTable ], nChr, 1 )
      IF nChrTable = Len( CHAR_TABLE )
         nChrTable := 0
      ENDIF
   NEXT

RETURN( cReturn )



FUNCTION mxDecrypt( cDec )

   LOCAL cReturn   := ""
   LOCAL nChrTable := 0
   LOCAL nCount

   FOR nCount := 1 TO Len( cDec )
      nChr    := At( Subs( cDec, nCount, 1 ), CHAR_TABLE[ ++ nChrTable ] )
      cReturn += Subs( CHAR_POS, nChr, 1 )
      IF nChrTable = Len( CHAR_TABLE )
         nChrTable := 0
      ENDIF
   NEXT

RETURN( cReturn )



FUNCTION varClear( uVar )

   DO CASE
      CASE ValType( uVar ) = "N" ; uVar := 0
      CASE ValType( uVar ) = "C" ; uVar := Space( Len( uVar ) )
      CASE ValType( uVar ) = "D" ; uVar := CtoD( "" )
   ENDCASE

RETURN( uVar )



FUNCTION IsValue( cVar, uValue )

   LOCAL lReturn := IsDef( cVar ) .AND. &cVar = uValue

RETURN( lReturn )



FUNCTION GetNoEmpty( uVar1, uVar2 )

   LOCAL uReturn := uVar1
   LOCAL nVar

   IF ValType( uVar2 ) = "A" .AND. ValType( uVar1 ) <> ValType( uVar2 )
      FOR nVar := 1 TO Len( uVar2 )
         IF ! Empty( uReturn )
            EXIT
         ENDIF
         uReturn := uVar2[ nVar ]
      NEXT
   ELSEIF uReturn = NIL .OR. Empty( uReturn )
      uReturn := uVar2
   ENDIF

RETURN( uReturn )



FUNCTION mxLen( uVar )

   LOCAL nLen := 0

   DO CASE
      CASE ValType( uVar ) = "D" ; nLen := Len( DtoC( uVar ) )
      CASE ValType( uVar ) = "N" ; nLen := Len( Str( uVar ) )
      OTHERWISE                  ; nLen := Len( uVar )
   ENDCASE

RETURN( nLen )



FUNCTION mxDefErrLogTitle( cDef )

   LOCAL cReturn := cErrLogTitle

   IF cDef <> NIL
      cErrLogTitle := cDef
   ENDIF
   
   cReturn := StrTran( cReturn, "<(TIME)>", Time() )

RETURN( cReturn )



PROCEDURE csModuleResp( aModule )

   LOCAL cFile, cAlias, cRecno, cEvent

   BEGIN SEQUENCE
 
      IF aModule <> NIL

         aCSModule := aClone( aModule )

         fErase( ModExt( aCSModule[1], ".RSP" ) )
         fErase( ModExt( aCSModule[1], ".TMR" ) )

         BREAK

      ENDIF
      
      IF Len( aCSModule ) = 0
         BREAK
      ENDIF

      IF Len( aCSModule ) < 5
         aSize( aCSModule, 5 )
      ENDIF
   
      cFile  := aCSModule[1]
      cAlias := aCSModule[2]
      nRecno := aCSModule[3]      
      cEvent := aCSModule[4]
      
      IF cEvent = "47"
         cEvent := "42"
      ENDIF

      IF cAlias <> Alias()
         BREAK
      ENDIF
      
      IF ! File( cFile )
         BREAK
      ENDIF
      
      IF cEvent = "43" .OR. nRecno = 0
         nRecno := mxRecno()
      ENDIF

      IF aCSModule[5] = nRecno
         BREAK
      ENDIF

      aCSModule[5] := nRecno
      
      IF Len( cAlias ) > 3
         cAlias := Subs( cAlias, 3, 3 )
      ENDIF

      mxFAddLine( ModExt( cFile, ".TMR" ), "0000000000|" + cAlias + "|" + StrZero( nRecno, 16 ) + "|" + cEvent + "|" )

   ENDSEQUENCE

RETURN( NIL )



PROCEDURE mxForNext( nBegin, nTo, bFunc )

   LOCAL nCount

   vDef( @nBegin, 1 )
   vDef( @nTo   , 1 )
   vDef( @bFunc , { || .T. } )

   FOR nCount := nBegin TO nTo
      Eval( bFunc, nCount )
   NEXT

RETURN( NIL )



FUNCTION sisFlgModule( cFlg )

   LOCAL cReturn := cFlgModule
   
   IF cFlg <> NIL
      cFlgModule := cFlg
   ENDIF
   
RETURN( cReturn )



FUNCTION sisLenAlias( nLen )

   LOCAL nReturn := nLenAlias

   IF nLen <> NIL
      nLenAlias := nLen
   ENDIF

RETURN( nReturn )



FUNCTION mxProcName( nStart )

   LOCAL cReturn := ""
   LOCAL nProc, cProc

   vDef( @nStart, 1 )

   nProc := nStart

   DO WHILE .T.

      nProc ++
      cProc := ProcName( nProc )

      IF Empty( cProc )
         EXIT
      ENDIF

      cReturn +=  Chr(13) + Chr(10) + cProc + "(" + NumToStr( ProcLine( nProc ) ) + ")"

   ENDDO

   cReturn := Subs( cReturn, 3 )

RETURN( cReturn )



PROCEDURE mxErrorMail( cError, lErrorSys )

   LOCAL cTela       := SaveScreen( MaxRow(), 00, MaxRow(), MaxCol() )
   LOCAL lMaxAccount := .F.

   LOCAL cServer, nPort, cFrom, cUser, cPass, cPopServer
   LOCAL cSubject, cIpNet, cProcess, lSend, nTry

   vDef( @lErrorSys, .T. )

   BEGIN SEQUENCE

      IF IsDef( "NO_SEND_MAIL_ERROR" )
         BREAK
      ELSEIF IsDef( "DESENV" )
         BREAK
      ELSEIF "ERROR TERM/2014" $ Upper( cError )
         BREAK
      ELSEIF "PGRES_FATAL_ERROR" $ Upper( cError ) .AND. ;
             ( "NO CONNECTION TO THE SERVER" $ Upper( cError ) .OR. ;
               "SERVER CLOSED THE CONNECTION UNEXPECTEDLY" $ Upper( cError ) .OR. ;
               "COULD NOT RECEIVE DATA FROM SERVER" $ Upper( cError ) )
         BREAK
      ENDIF
      
      cIpNet := GetIP( .T. )

      IF IsDef( "IP_MAXSCALLA" ) .AND. cIpNet = IP_MAXSCALLA
         BREAK
      ENDIF

      cSubject := "[Log de erro]"

      IF IsDef( "CLIENTE" )
         cSubject += " " + AllTrim( CLIENTE )
         IF IsDef( "SERIE" )
            cSubject += " #" + SERIE + "#"
         ENDIF
      ENDIF

      TRY
         cProcess := TiraEspacos( GetRegistry( HKEY_LOCAL_MACHINE, "HARDWARE\DESCRIPTION\System\CentralProcessor\0", "ProcessorNameString" ) )
      CATCH
         cProcess := "(Indeterminado)"
      END

      IF lErrorSys
         cError += _NL + mxDefErrLogTitle()                                                    + ;
                   _NL
      ENDIF

      cError += _NL + "Aplicativo: "  + ExeName()                                           + ;
                _NL + "Computador: "  + NetName()                                           + ;
                _NL + "Processador: " + cProcess                                            + ;
                _NL + "Memoria: "     + NumToStr( Round( Memory( 103 ) / 1024, 0 ) ) + "MB" + ;
                _NL + "IP local: "    + GetIP()                                             + ;
                _NL + "IP internet: " + cIpNet                                              + ;
                _NL + "BD ativo: "    + sqlGetConn( "NAME" )

      cError += _NL + _NL + "Databases:"
      aEval( sqlGetConn(), { |x| cError += _NL + Lower( x[5] ) + "=\\" + x[1] + "\" + Lower( x[3] ) + "\" + Lower( x[4] ) } )
      
      FOR nTry := 1 TO 2

         IF lMaxAccount .OR. ! IsDef( "CFICSSCTR" ) .OR. Empty( CFICSSCTR ) .OR. Empty( CFICPWCTR )
            cServer     := "mail.maxscalla.com.br"
            nPort       := 587
            cFrom       := "Max Scalla"
            cUser       := "web@maxscalla.com.br"
            cPass       := "maxmax2013"
            cPopServer  := "mail.maxscalla.com.br"
            lMaxAccount := .T.
         ELSE
            cServer     := Trim( CFICSSCTR )
            nPort       := CFIPSSCTR
            cFrom       := CapFirst( CFIFANCTR )
            cUser       := Trim( CFICNCCTR )
            cPass       := Trim( CFICPWCTR )
            cPopServer  := Trim( CFICP3CTR )
         ENDIF
         
         Status( "Enviando log de erro..." )

         TRY

            lSend := SendMail( ;
                              cServer                               ,;  // cServer    -> Necessario. Nome IP ou o dominio do servidor de email
                              nPort                                 ,;  // nPort      -> Opcional.   A porta usada pelo o meu servidor de email
                              { cUser, cFrom }                      ,;  // cFrom      -> Necessario. Endereco de email do remetente
                              { "desenvolvimento@maxscalla.com.br" },;  // aTo        -> Necessario. Sequencia de caracteres ou matriz de enderecos de email para enviar o email para
                              {}                                    ,;  // aCC        -> Opcional.   Sequencia de caracteres ou matriz de email adresses para CC (Copia do email)
                              {}                                    ,;  // aBCC       -> Opcional.   Sequencia de caracteres ou matriz de email adresses de Cco (copia oculta do email)
                              cError                                ,;  // cBody      -> Opcional.   A mensagem do corpo do email como texto, ou o nome do arquivo da mensagem em HTML para enviar.
                              cSubject                              ,;  // cSubject   -> Opcional.   Assunto do email
                              {}                                    ,;  // aFiles     -> Opcional.   Matriz/arquivos de anexos para enviar com o email
                              cUser                                 ,;  // cUser      -> Necessario. Nome de usuario para o servidor POP3
                              cPass                                 ,;  // cPass      -> Necessario. Senha para cUser
                              cPopServer                            ,;  // cPopServer -> Necessario. Nome IP ou o dominio do servidor de email POP3
                              3                                     ,;  // nPriority  -> Opcional.   Email de prioridade: 1 = alta, 3 = Normal (padrao), 5 = baixa
                              .F.                                   ,;  // lRead      -> Opcional.   Se definido como. T., uma solicitacao de confirmacao eh enviada. A configuracao padrao eh .f.
                              .F.                                   ,;  // lTrace     -> Opcional.   Se definido como. T., um arquivo de log eh criado (sendmail <nNr>.log). A configuracao padrao eh .f.
                              .T.                                   ,;  // lPopAuth   -> Opcional.   Sinalizador para indicar que Autentication POP3 eh usado. A configuracao padrao eh. T.
                              .F.                                   ,;  // lnoauth    -> Opcional.   Servidores de email que nao precisam de autenticacao smtp
                              2000                                  ,;  // nTimeOut   -> Opcional.   Numero de milesimos de segundos a aguarda o envio - Padrao eh 2000(2 segundos)
                              .T.                                    ;  // lCheckNet  -> Opcional.   Verifica se a internet esta disponivel antes de enviar o email
                            )

         CATCH

            lSend := .F.

         END
         
         IF nTry = 2 .OR. lSend .OR. lMaxAccount
            EXIT
         ENDIF
         
         lMaxAccount := .T.
         
      NEXT

   ENDSEQUENCE

   //Status( "Enviando log de erro..." )
   
   RestScreen( cTela, MaxRow(), 00, MaxRow(), MaxCol() )

RETURN( NIL )



FUNCTION mxGetSysVersion()

   LOCAL cVersion := ""
   
   IF IsDef( "SISTEMA" )
      cVersion += Trim( SISTEMA )
   ENDIF

   IF IsDef( "VERSAO" )
      cVersion += " - v"+ Trim( VERSAO )
   ENDIF

   IF IsDef( "RELEASE" )
      cVersion += "." + NumToStr( RELEASE )
   ENDIF

   IF IsDef( "VEREXE" )
      cVersion += "." + UtoC( VEREXE )
   ENDIF

RETURN( cVersion )



FUNCTION mxDownLoad( aFolder, aDown, cDest, cFtpAccount )

   // Parametros
   // cFtpAccount: Exemplo: "ftp://maxscall:senha@ftp.maxscalla.com.br"

   LOCAL cTela   := SaveScreen()
   LOCAL cColor  := SetColor()
   LOCAL lReturn := .F.
   LOCAL lClose  := .F.
   LOCAL aResult := {}

   LOCAL oFtp, oUrl, aFtpInfo, nCount, cFLocal, cErro, nRow, nRowDisp
   LOCAL aFtpFiles, aSize, nSize, nRetry, oErr, lOk, cFtpRoot, cURL

   PRIV lDownStart := .T.
   PRIV cDown

   BEGIN SEQUENCE

      Limpa( 02,16,10,62, "s", NIL, "15/2" )

      IF At( ";", cFtpAccount ) = 0
         cURL     := cFtpAccount
         cFtpRoot := ""
      ELSE
         aFtpInfo := strToArray( Trim( cFtpAccount ), ";", .F. )
         cURL     := "ftp://" + aFtpInfo[ 2 ] + ":" + aFtpInfo[ 3 ] + "@" + aFtpInfo[ 1 ]
         cFtpRoot := aFtpInfo[6]
      ENDIF

      TRY
         oUrl := tUrl():New( cURL )
         oFtp := TIpClientFtp():new( oUrl, NIL, .T. )
         oFtp:nDefaultPort := Val( aFtpInfo[4] )
         oFtp:nConnTimeout := 30000
         oFtp:bUsePasv     := aFtpInfo[5] = "S"
         oFtp:exGauge      := ( @FtpProgress() )
      CATCH oErr
         MsgDlg( oErr:Description )
         BREAK
      END

      @ 03, 18 SAY "Conectando no servidor..." COLOR "15/2"

      lOk := .F.

      TRY
         lOk := oFtp:open()
      CATCH oErr
         lOk := .F.
         cErro := oErr:Description
      END

      IF ! lOk
         cErro := "Problemas ao conectar no servidor !;;" + If( cErro = NIL, "", cErro )
         IF ! Empty( oFtp:lastErrorMessage() )
            cErro += ";" + oFtp:lastErrorMessage()
         ENDIF
         MsgDlg( cErro )
         BREAK
      ENDIF

      lClose := .T.

      @ 04, 18 SAY "Acessando caminho para download..." COLOR "15/2"
      
      oFtp:cwd( "/" )
      ThreadSleep( 100 )

      IF ! Empty( cFtpRoot )
         ThreadSleep( 100 )
         oFtp:cwd( cFtpRoot )
      ENDIF

      FOR nCount := 1 TO Len( aFolder )
         ThreadSleep( 100 )
         oFtp:cwd( aFolder[ nCount ] )
      NEXT

      ThreadSleep( 100 )

      aFtpFiles := oFtp:ListFiles( "" )

      ThreadSleep( 100 )

      nRow := 0

      FOR nCount := 1 TO Len( aDown )

         nRow ++
         IF nRow > 5
            SetColor( "15/2" )
            Scroll( 03, 17, 09, 61, 1 )
            nRowDisp := 09
         ELSE
            nRowDisp := 04 + nRow
         ENDIF

         @ nRowDisp, 18 SAY "Baixando " + aDown[ nCount ] + "..." COLOR "15/2"

         FOR nRetry := 1 TO 5

            cFLocal := cDest + aDown[ nCount ]

            IF File( cFLocal )
               mxFDel( cFLocal )
            ENDIF

            lDownStart := .T.
            cDown      := aDown[ nCount ]
            
            nSize    := aScan( aFtpFiles, { |x| x[ F_NAME ] = cDown } )
            nFtpSize := 0
            
            IF nSize > 0
               nFtpSize := aFtpFiles[ nSize, F_SIZE ]
            ENDIF

            IF oFtp:downloadFile( StrTran( cFLocal, "\", "/" ), cDown )

               aSize := Directory( cFLocal )

               IF Len( aSize ) = 0
                  MsgDlg( cFLocal + " n„o encontrado !" )
                  BREAK
               ENDIF

               IF nSize = 0
                  MsgDlg( "ftp:" + cDown + " n„o encontrado !" )
                  BREAK
               ENDIF

               IF aFtpFiles[ nSize, F_SIZE ] <> aSize[ 1, F_SIZE ]
                  IF nRetry = 5
                     mxFDel( cFLocal )
                     MsgDlg( "O tamanho do arquivo baixado n„o ‚ v lido !;;" + ;
                             "Esperado : " + Str( aFtpFiles[ nSize, F_SIZE ], 10 ) + ";" + ;
                             "Avalidado: " + Str(     aSize[ 1    , F_SIZE ], 10 ) )
                     lReturn := .F.
                     BREAK
                  ENDIF
                  ThreadSleep( 100 )
               ENDIF

               EXIT

            ENDIF

         NEXT

         IF ! lReturn
            MsgDlg( oFtp:lastErrorMessage() )
         ENDIF

      NEXT

      lReturn := .T.

   ENDSEQUENCE

   IF lClose
      oFtp:close()
   ENDIF

   RestScreen( ,,,, cTela )
   SetColor( cColor )

RETURN( lReturn )



FUNCTION FtpProgress( nSent, nTotal, oFtp )

   IF lDownStart
      prgsStart( "Baixando " + cDown, nFtpSize, 2 )
      lDownStart := .F.
   ENDIF

   prgsNext( nSent )

RETURN( .T. )