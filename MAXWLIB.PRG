/*

 MaxWLib.prg
 Funcoes para uso geral no modo visual.
 
 DENIS MAZZUCATTO RODRIGUES
 25/11/13 * Desenvolvimento de mxDoMethod().
 24/09/13 * Desenvolvimento de mxSetProcedure().
 18/09/13 * Implementacao de SetThemes().
 15/08/13 * Desenvolvimento de ProgressTask().
 08/08/13 * Implementado parametro lPassWord em InputBox2().
 01/09/10 * Inicio do desenvolvimento.

*/

#include "inkey.ch"
#include "fileio.ch"
#include "minigui.ch"
#include "message.ch"
#include "maxwin.ch"

#define TITLE_WAIT  "Aguarde, processando..."

STATIC aPictures  := {}
STATIC aImageInfo := {}

STATIC nPrgsTotal := 0
STATIC nPrgsCount := 0

STATIC cFormGif, cImageGif, cTimerGif, cLabelGif, nTotalFrames, nCurrentFrame, nWaitTaskClick

PROCEDURE SetWVars( aNoSet, lReadOnly )

   LOCAL cForm := mxWFObj():cName

   LOCAL nVarCount, cVar, cLabel

   IF ! Used()
      RETURN( NIL )
   ENDIF

   vDef( @aNoSet   , {}  )
   vDef( @lReadOnly, .F. )

   FOR nVarCount := 1 TO FCount()

      cVar := Right( Field( nVarCount ), 6 )

      IF aScan( aNoSet, cVar ) > 0
         LOOP
      ENDIF

      IF ! _IsControlDefined( cVar, cForm )
         LOOP
      ENDIF

      IF GetControlType( cVar, cForm ) = "COMBO"
		   mxSetComboValue( cForm, cVar, FieldGet( nVarCount ) )
		ELSEIF GetControlType( cVar, cForm ) = "RADIOGROUP"
		   mxSetRadioValue( cForm, cVar, FieldGet( nVarCount ) )
      ELSEIF GetControlType( cVar, cForm ) = "CHECKBOX"
         mxSetCheckValue( cForm, cVar, FieldGet( nVarCount ) )
      ELSE
         IF Type( Field( nVarCount ) ) = "N" .AND. FieldGet( nVarCount ) = 0  // P.O.G.
            SetProperty( cForm, cVar, "Value", 1 )
         ENDIF
         SetProperty( cForm, cVar, "Value", FieldGet( nVarCount ) )
      ENDIF

      cLabel := "ed" + cVar + "_Show"

		IF _IsControlDefined( cLabel, cForm )
         IF lReadOnly
			   SetProperty( cForm, cLabel, "Value", GetProperty( cForm, cVar, "DisplayValue" ) )
            SetProperty( cForm, cVar  , "Visible", .F. )
            SetProperty( cForm, cLabel, "Width"  , GetProperty( cForm, cVar, "Width" ) )
            SetProperty( cForm, cLabel, "Visible", .T. )
         ELSE
            SetProperty( cForm, cLabel, "Width"  , 0   )
            SetProperty( cForm, cLabel, "Visible", .F. )
            SetProperty( cForm, cVar  , "Visible", .T. )
         ENDIF
		ENDIF
		
      mxWGDefCargo( cVar, 3, lReadOnly )
      mxWGDefState( cVar, If( lReadOnly, WG_READONLY, WG_NORMAL ) )
      mxWGSetToolTip( cVar, cForm )

   NEXT

RETURN( NIL )



PROCEDURE ResetWVars( aNoReset )

   IF ! Used()
      RETURN( NIL )
   ENDIF

   GetBookMark()            // Salva o numero do registro

   mxBottom()               // Posiciona no ultimo registro
   mxSkip()                 // Avanca p/ EOF() p/ utilizar os valores vazios

   SetWVars( aNoReset )      // Atribui os valores dos campos as varivaveis

   GoToBookMark()           // Retorna a posicao de origem

RETURN( NIL )



PROCEDURE SaveWVars( lAppend, aNoSave, nMode )

   LOCAL cForm := mxWFObj():cName

   LOCAL nVarCount, nItem, cVar, uRepl

   IF ! Used()
      RETURN( NIL )
   ENDIF

   vDef( @lAppend, .F. )
   vDef( @aNoSave, {}  )
   vDef( @nMode  , 1   )

   IF ! lAppend
      GetBookMark()
      IF nMode = 1
         mxRecLock()
      ENDIF
   ELSEIF nMode = 1  // Adiciona um registro.
      mxAppend()
   ELSE
      dbAppend()
   ENDIF

   // Grava os valores nos campos

   FOR nVarCount := 1 TO FCount()

      cVar := Right( Field( nVarCount ), 6 )

      IF aScan( aNoSave, cVar ) > 0
         LOOP
      ENDIF

      IF IsDef( cVar )
         uRepl := &cVar
      ELSE
			IF ! _IsControlDefined( cVar, cForm )
	         LOOP
	      ENDIF
	      IF GetControlType( cVar, cForm ) = "COMBO"
	         nItem := GetProperty( cForm, cVar, "Value" )
	         IF nItem = 0
	            uRepl := ""
	         ELSE
	            uRepl := mxGetComboItems( cForm, cVar )[ nItem ]
	         ENDIF
	      ELSEIF GetControlType( cVar, cForm ) = "RADIOGROUP"
            nItem := GetProperty( cForm, cVar, "Value" )
            uRepl := GetProperty( cForm, cVar, "Caption", nItem )
         ELSEIF GetControlType( cVar, cForm ) = "CHECKBOX"
            uRepl := GetProperty( cForm, cVar, "Value" )
            DO CASE
               CASE FieldType( nVarCount ) = "C" ; uRepl := If( uRepl, "S", "N" )
               CASE FieldType( nVarCount ) = "N" ; uRepl := If( uRepl, 1, 0 )
            ENDCASE
         ELSE
	         uRepl := GetProperty( cForm, cVar, "Value" )
	      ENDIF
      ENDIF

      mxReplace( Alias() + "->" + Field( nVarCount ), uRepl )

   NEXT

   // Atualiza os buffers e desbloqueia

   IF nMode = 1
      mxUnlock(.F.)
   ENDIF

   IF ! lAppend
      GoToBookMark()
   ENDIF

RETURN( NIL )



PROCEDURE csStatus( ;        // Exibe uma mensagem de status
                    cMsg,;
                    cForm,;
                    nItem ;
                  )
   
   vDef( @cForm, mxWFObj():cName )
   vDef( @nItem, 1 )
   
   IF _IsControlDefined( "StatusBar", cForm )
      
      SetProperty( cForm, "StatusBar", "Item", nItem, cMsg )
      
   ELSEIF cForm <> "frMain"
   
      csStatus( cMsg, "frMain" )
      
   ENDIF  

   IF "..." $ cMsg
      _ProcessMess()
   ENDIF
   
RETURN( NIL )



PROCEDURE UpdCadastro( nEvent, aUpd )

   csStatus( "Aguarde, gravando dados em " + Alias() + "..." )

	DO CASE
      CASE nEvent = K_INCLUIR
           SaveWVars( .T. )
           mxBrwRefresh()
      CASE nEvent = K_ALTERAR
           SaveWVars( .F. )
      CASE nEvent = K_EXCLUIR
           mxDelete( NIL, .F. )
           IF Eof()
              mxBrwRefresh( NIL, BRW_REFRESH_BOTTOM )
           ELSEIF ! Empty( dbFilter() )
              mxBrwRefresh( NIL, BRW_REFRESH_RECNO )
           ENDIF
   ENDCASE

   csStatus( "" )

RETURN( NIL )



FUNCTION wConfEvent( nEvent, cMsg )

   LOCAL nReturn

   IF cMsg = NIL
      DO CASE
         CASE nEvent = K_INCLUIR   ; cMsg := "Confirma inclusão do registro"
         CASE nEvent = K_ALTERAR   ; cMsg := "Confirma alteração dos dados"
         CASE nEvent = K_EXCLUIR   ; cMsg := "Confirma exclusão do registro"
         CASE nEvent = K_PROCESSAR ; cMsg := "Confirma alteração dos dados"
      ENDCASE
   ENDIF

   IF cMsg = NIL
      nReturn := 1
   ELSE
      nReturn := MsgOptions( cMsg + "?", MSG_TITLE, { "&Sim", "&Não", "&Cancelar" }, 3, NIL, "msg_help" )
      DO CASE
         CASE nReturn = 2 ; nReturn :=  0
         CASE nReturn = 3 ; nReturn := -1
      ENDCASE
   ENDIF

RETURN( nReturn )



FUNCTION MsgOptions( cText, cTitle, aOptions, nDefaultOption, nSeconds, cIcon )

   #define ICON_SPACE   ( 16 + 32 + 16 )
   
   LOCAL cOption   := ""
   LOCAL nCount    := 0
   LOCAL nWidth    := 0
   LOCAL nBtnWidth := 0
   LOCAL nBtnPosX  := 10

   LOCAL nBtnPosY, nTextRows

   vDef( @cText         , "Selecione uma opção" )
   vDef( @cTitle        , Upper( _HMG_BRWLangError[10]) + "!" )
   vDef( @nDefaultOption, 1 )
   vDef( @nSeconds      , 0 )

   DEFINE FONT _Font_Options FONTNAME "Segoe UI" SIZE 9

   // Calcula a largura maxima do botao p/ igualar todos

   FOR nCount := 1 TO Len( aOptions )
      aOptions[ nCount ] := Alltrim( aOptions[ nCount ] )
      nBtnWidth := Max( GetTextWidth( NIL, aOptions[ nCount ], GetFontHandle( "_Font_Options" ) ), nBtnWidth )
   NEXT

   nBtnWidth := Max( nBtnWidth, 78 ) +10

   cText := _NL + cText

   nTextRows := MLCount( cText ) +1

   nBtnPosY := 12 + ( 15 * nTextRows )

   // Calcula a largura maxima do texto p/ definir o tamanho do formulario

   FOR nCount := 1 TO nTextRows
      nWidth := Max( GetTextWidth( NIL, Trim( MemoLine( cText, NIL, nCount, NIL, NIL, .T. ) ), GetFontHandle( "_Font_Options" ) ) +10, nWidth )
   NEXT

   IF cIcon <> NIL .AND. File( imgFile( cIcon ) )
      nWidth += ICON_SPACE
      cIcon  := imgFile( cIcon )
   ELSE
      cIcon := NIL
   ENDIF

   nWidth := Max( nWidth, ( Len( aOptions ) * ( nBtnWidth +10 ) ) ) +15

   nBtnPosX := Len( aOptions ) * ( nBtnWidth +10 )
   nBtnPosX := ( nWidth - nBtnPosX )
   nBtnPosX /= 2
   nBtnPosX := Int( nBtnPosX + 2.5 )

   DEFINE WINDOW _Options ;
      AT         0,0 ;
      WIDTH      nWidth ;
      HEIGHT     76 + ( 15 * nTextRows ) ;
      TITLE      cTitle ;
      ICON       imgFile( "icone.ico" ) ;
      MODAL ;
      NOSIZE ;
      ON RELEASE If( IsControlDefined( Timer_1, _Options ), _Options.Timer_1.Release, NIL )

      ON KEY ESCAPE ACTION _Options.Release

      IF cIcon = NIL
      
         @ 00, 00 ;
           LABEL     _Label ;
           VALUE     cText ;
           WIDTH     nWidth -6 ;
           HEIGHT    15 * nTextRows ;
           FONT      "_Font_Options" ;
           BACKCOLOR { 255, 255, 255 } ;
           CENTERALIGN

      ELSE

         @ 00, 00 ;
           LABEL     _LabelBack;
           VALUE     "" ;
           WIDTH     nWidth -6 ;
           HEIGHT    15 * nTextRows ;
           BACKCOLOR { 255, 255, 255 }

         @ 00, ICON_SPACE ;
           LABEL     _Label ;
           VALUE     cText ;
           WIDTH     nWidth -6 - ICON_SPACE ;
           HEIGHT    15 * nTextRows ;
           FONT      "_Font_Options" ;
           BACKCOLOR { 255, 255, 255 }

         @ Int( ( ( 15 * nTextRows ) -32 ) / 2 ), 16 ;
           IMAGE   _Image ;
           PICTURE cIcon ;
           WIDTH   32 ;
           HEIGHT  32
         
      ENDIF

      FOR nCount := 1 TO Len( aOptions )

         cOption := "_Btn_" + NumToStr( nCount )

         @ nBtnPosY, nBtnPosX ;
            BUTTON  &cOption ;
            CAPTION aOptions[ nCount ] ;
            WIDTH   nBtnWidth ;
            HEIGHT  25 ;
            FONT    "_Font_Options" ;
            ACTION  ( cOption := GetProperty( "_Options", This.Name, "Caption" ), _Options.Release )

         nBtnPosX += nBtnWidth +10

      NEXT

      mxDoMethod( "_Options", "_Btn_" + NumToStr( nDefaultOption ), "SetFocus" )

      IF nSeconds > 0

         DEFINE TIMER Timer_1 ;
            INTERVAL nSeconds * 1000 ;
            ACTION   ( cOption := aOptions[ nDefaultOption ], _Options.Release )

      ENDIF

   END WINDOW

   mxDoMethod( "_Options", "Center" )
   mxDoMethod( "_Options", "Activate" )

   RELEASE FONT _Font_Options

RETURN( Ascan( aOptions, Alltrim( cOption ) ) )



PROCEDURE WaitTask( cMsg )

   LOCAL aInfoGif

   nWaitTaskClick := 0
   
   IF cMsg <> NIL
   
      cMsg := PadR( cMsg, 50 )

      mxDoMethod( mxWFObj():cName, "Hide" )

      IF _IsWindowDefined( "frWaitTask" )

         SetProperty( "frWaitTask", "Title", TITLE_WAIT )
         SetProperty( "frWaitTask", cLabelGif, "Value", cMsg )

      ELSE

         PUBLIC oWFWaitTask := mxWForm():New( "frWaitTask", 0, 0, TITLE_WAIT )

         DEFINE WINDOW frWaitTask ;
            AT         0, 0 ;
            WIDTH      0 ;
            HEIGHT     0 ;
            TITLE      oWFWaitTask:cTitle ;
            NOSIZE ;
            NOMAXIMIZE ;
            NOSYSMENU ;
            NOSHOW ;
            CHILD ;
            ON RELEASE    oWFWaitTask:OnRelease() ;
            ON MOVE       oWFWaitTask:OnMove() ;
            ON MOUSECLICK { || nWaitTaskClick ++, SetProperty( "frWaitTask", "Title", TITLE_WAIT + " (" + NumToStr( nWaitTaskClick ) + ")" ) } ;
            BACKCOLOR     { 246, 246, 246 }

            DEFINE STATUSBAR FONT oWConfig:FontName_StatusBar SIZE oWConfig:FontSize_StatusBar
               STATUSITEM "" DEFAULT
            END STATUSBAR

            aInfoGif := AnimatedGif( "frWaitTask", "aguarde", 1, 1, cMsg )

         END WINDOW

         SetProperty( "frWaitTask", "Width" , aInfoGif[2] +6 )
         SetProperty( "frWaitTask", "Height", aInfoGif[3] +46 )

         mxWSetStyle( GetFormHandle( "frWaitTask" ) )

      ENDIF

      csStatus( "", "frWaitTask" )
      csStatus( "", "frMain" )

      mxDoMethod( "frWaitTask", "Center" )

   ENDIF

   mxDoMethod( "frWaitTask", "Show" )

RETURN( NIL )



PROCEDURE WaitTaskHide( cMsg )

   nWaitTaskClick := 0
   
   SetProperty( "frWaitTask", "Title", TITLE_WAIT )
   mxDoMethod( "frWaitTask", "Hide" )

RETURN( NIL )



FUNCTION WaitTaskAbort( nCount )

RETURN( nWaitTaskClick >= nCount )



PROCEDURE StatusTask( cMsg )

   csStatus( cMsg, "frWaitTask" )

   _ProcessMess()

RETURN( NIL )



FUNCTION ProgressTask( nDefTotal )

   IF nDefTotal = NIL
      RETURN( Tran( ( ++ nPrgsCount ) / nPrgsTotal * 100, "@E 999.99%" ) )
   ENDIF
   
   nPrgsTotal := nDefTotal
   nPrgsCount := 0

RETURN( NIL )



FUNCTION imgFile( cFile )

   IF ! IsUseExt( cFile )
      cFile += ".bmp"
   ENDIF

   cFile := ConfPath( oWConfig:Form_ImagePath ) + "img_" + cFile

RETURN( cFile )



FUNCTION mxGetObject( cName, cForm )

   vDef( @cForm, mxWFObj():cName )

RETURN( GetObjectByHandle( GetControlHandle( cName, cForm ) ) )



FUNCTION mxGetComboItems( ;        // Retorna uma matriz com os itens do combobox
                          cForm,;  // Formulario
                          cName ;  // Combobox
                        )

   LOCAL aReturn := {}

   LOCAL nItem, nItemCount

   IF cName = NIL
      cName := Subs( cForm, At( ".", cForm ) +1 )
      cForm := Left( cForm, At( ".", cForm ) -1 )
   ENDIF

   nItemCount := GetProperty( cForm, cName, "ItemCount" )

   FOR nItem := 1 TO nItemCount
      aAdd( aReturn, GetProperty( cForm, cName, "Item", nItem ) )
   NEXT

RETURN( aReturn )



PROCEDURE mxSetComboValue( ;         // Atribui um valor ao combobox
                           cForm,;   // Formulario
                           cName,;   // Combobox
                           uValue ;  // Valor
                         )

	LOCAL nItem

   IF _IsControlDefined( cName, cForm )

   	IF ValType( uValue ) = "N"
   	   nItem := Min( uValue, GetProperty( cForm, cName, "ItemCount" ) )
   	ELSE
   	   nItem := aScan( mxGetComboItems( cForm, cName ), { |x| Left( x, Len( uValue ) ) = uValue } )
   	ENDIF

   	SetProperty( cForm, cName, "Value", nItem )
      SetProperty( cForm, cName, "Item" , nItem )

   ENDIF

RETURN( NIL )



FUNCTION mxGetComboValue( ;        // Retorna o texto do item selecionado no combobox
                          cForm,;  // Formulario
                          cName ;  // Combobox
                        )

   LOCAL nItem := GetProperty( cForm, cName, "Value" )

   IF nItem <= 0
      RETURN( varClear( mxGetComboItems( cForm, cName )[ 1 ] ) )
	ENDIF

RETURN( mxGetComboItems( cForm, cName )[ nItem ] )



FUNCTION mxGetRadioItems( ;        // Retorna uma matriz com os itens do radiogroup
                          cForm,;  // Formulario
                          cName ;  // Radiogroup
                        )

   LOCAL aReturn := {}
   LOCAL nIndex

   IF cName = NIL
      cName := Subs( cForm, At( ".", cForm ) +1 )
      cForm := Left( cForm, At( ".", cForm ) -1 )
   ENDIF

	nIndex := GetControlIndex( cName, cForm )

   IF nIndex > 0
	   aReturn := _HMG_aControlCaption[ nIndex ]
	ENDIF

RETURN( aReturn )



PROCEDURE mxSetRadioValue( ;         // Atribui um valor ao radiogroup
                           cForm,;   // Formulario
                           cName,;   // Radiogroup
                           uValue ;  // Valor
                         )

	LOCAL nValue, aItems

	IF _IsControlDefined( cName, cForm )

      IF ValType( uValue ) = "N"
   	   nValue := uValue
   	ELSE
   	   aItems := mxGetRadioItems( cForm, cName )
   		nValue := aScan( aItems, { |x| Left( x, Len( uValue ) ) = uValue } )
   	ENDIF

   	SetProperty( cForm, cName, "Value", Max( nValue, 1 ) )

   ENDIF

RETURN( NIL )



PROCEDURE mxSetCheckValue( ;         // Atribui um valor ao checkbox
                           cForm,;   // Formulario
                           cName,;   // Checkbox
                           uValue ;  // Valor
                         )

   LOCAL lValue

	IF _IsControlDefined( cName, cForm )

      DO CASE
         CASE ValType( uValue ) = "C" ; lValue := ( Left( Upper( uValue ), 1 ) = "S" )  // N = .F. / S = .T.
         CASE ValType( uValue ) = "N" ; lValue := ( uValue = 1 )                        // 0 = .F. / 1 = .T.
         OTHERWISE                    ; lValue := uValue
   	ENDCASE

   	SetProperty( cForm, cName, "Value", lValue )

   ENDIF

RETURN( NIL )



PROCEDURE mxSetValue( ;         // Atribui um valor à propriedade value de um objeto
                      cVar,;    // Nome do objeto
                      uValue ;  // Valor
                    )

   LOCAL cType, cValue

   IF _IsControlDefined( cVar, mxWFObj():cName )

      cType := GetControlType( cVar, mxWFObj():cName )

      DO CASE
         CASE cType = "COMBO"
              mxSetComboValue( mxWFObj():cName, cVar, uValue )
         CASE cType = "RADIOGROUP"
              mxSetRadioValue( mxWFObj():cName, cVar, uValue )
         CASE cType = "CHECKBOX"
              mxSetCheckValue( mxWFObj():cName, cVar, uValue )
         OTHERWISE
              IF GetProperty( mxWFObj():cName, cVar, "Value" ) <> uValue
                 SetProperty( mxWFObj():cName, cVar, "Value", uValue )
              ENDIF
              IF ValType( uValue ) = "N" .AND. Empty( uValue )
                 cValue := NumToStr( uValue )
                 cValue := StrTran( cValue, ",", "V" )
                 cValue := StrTran( cValue, ".", "," )
                 cValue := StrTran( cValue, "V", "." )
                 SetProperty( mxWFObj():cName, cVar, "DisplayValue", cValue )
              ENDIF
      ENDCASE

      mxWGSetToolTip( cVar, mxWFObj():cName )

   ENDIF

RETURN( NIL )



FUNCTION mxGetValue( ;        // Retorna o valor de um objeto
                     cVar,;   // Nome do objeto
                     cForm ;  // Formulario
                   )

   LOCAL uValue

   vDef( @cForm, mxWFObj():cName )

   IF _IsControlDefined( cVar, cForm )
      uValue := GetProperty( cForm, cVar, "Value" )
   ENDIF

RETURN( uValue )



PROCEDURE mxSetProcedure( ;         // Altera a procedure executada em determinado evento de um objeto
                          cEvent,;  // Evento
                          cName,;   // Nome do objeto
                          uFunc ;   // Funcao
                        )

   LOCAL mVar := "_" + mxWFObj():cName + "_" + cName
   LOCAL k    := &mVar

   IF ValType( uFunc ) = "C"
      uFunc := "{ || " + uFunc + "() }"
      uFunc := &uFunc
   ENDIF
   
   cEvent := Upper( cEvent )
   
   DO CASE
      CASE cEvent = "ONCHANGE" ; _HMG_aControlChangeProcedure[ k ] := uFunc
   ENDCASE

RETURN( NIL )



PROCEDURE mxDoMethod( cForm, cControl, cMethod )

   IF _IsWindowDefined( cForm )
      IF cMethod = NIL
         cMethod := cControl
         DoMethod( cForm, cMethod )
      ELSE
         DoMethod( cForm, cControl, cMethod )
      ENDIF
   ENDIF
   
RETURN( NIL )



PROCEDURE mxDoEvent( cForm, cControl, cEvent )

   LOCAL mVar, k

   IF _IsWindowDefined( cForm )

       mVar := "_" + mxWFObj():cName + "_" + cControl
       k    := &mVar

      cEvent := Upper( cEvent )

      DO CASE
         CASE cEvent = "ONCHANGE" ; _DoControlEventProcedure( _HMG_aControlChangeProcedure[ k ], k )
      ENDCASE

   ENDIF

RETURN( NIL )



FUNCTION wVar( ;         // Retorna ou atribui um valor a um objeto
               cVar, ;   // Nome do objeto
               uValue,;  // Valor
               cDescr ;  // Atribui a descrição de um campo relacionado ao edit
             )

   LOCAL uReturn, cType

   IF uValue = NIL

      cType := GetControlType( cVar, mxWFObj():cName )

      IF cType = "COMBO"
         uReturn := mxGetComboValue( mxWFObj():cName, cVar )
         IF Left( cVar, 3 ) <> "EST"  // Estado (UF)
            uReturn := Left( uReturn, 1 )
         ENDIF
      ELSE
         uReturn := mxGetValue( cVar )
      ENDIF

   ELSE

      mxSetValue( cVar, uValue )

      IF cDescr <> NIL
         mxWGDescricao( cVar, cDescr )
      ENDIF

   ENDIF

RETURN( uReturn )



FUNCTION mxLabel( ;             // Cria um objeto do tipo label
                  cName,;       // Nome do objeto (opcional)
                  nRow,;        // Linha
                  nCol,;        // Coluna
                  cValue,;      // Texto
                  aFont,;       // Configuracoes da fonte
                  aBackColor ;  // Configuracoes da cor de fundo
                )

   LOCAL cForm := mxWFObj():cName
   
   vDef( @aFont, {} )

   aSize( aFont, 4 )
   IF aFont[1] = NIL  // Nome da fonte
      aFont[1] := oWConfig:FontName_GetLabel
   ENDIF
   IF aFont[2] = NIL  // Tamanho da fonte
      aFont[2] := oWConfig:FontSize_GetLabel
   ENDIF
   IF aFont[3] = NIL  // Cor da fonte
      aFont[3] := oWConfig:Color_GetLabel
   ENDIF
   IF aFont[4] = NIL  // Negrito
      aFont[4] := .F.
   ENDIF

   IF cName = NIL
      DO WHILE .T.
         cName := "lbTmp" + StrZero( HB_RandomInt( 0, 999 ), 3 )
		   IF ! _IsControlDefined( cName, mxWFObj():cName )
		      EXIT
		   ENDIF
		ENDDO
	ENDIF

   DEFINE LABEL &cName
      PARENT    &cForm
      ROW       nRow
	   COL       nCol
   	VALUE     cValue
      AUTOSIZE  .T.
      FONTNAME  aFont[1]
      FONTSIZE  aFont[2]
		FONTCOLOR aFont[3]
      FONTBOLD  aFont[4]
		IF aBackColor = NIL
		   TRANSPARENT .T.
		ELSE
		   BACKCOLOR aBackColor
		ENDIF
   END LABEL

RETURN( cName )



PROCEDURE mxCheckBox( ;           // Cria um objeto do tipo label
                      cName,;     // Nome do objeto
                      nRow,;      // Linha
                      nCol,;      // Coluna
                      lValue,;    // Valor
                      cCaption,;  // Texto
                      cToolTip ;  // Mensagem
                    )

   DEFINE CHECKBOX &cName
      ROW          nRow
      COL          nCol
      WIDTH        Len( cCaption ) * 7
      HEIGHT       23
      CAPTION      cCaption
      VALUE        lValue
      TOOLTIP      cToolTip
      TRANSPARENT  .T.
      ON CHANGE    mxWGValid()
   END CHECKBOX
   
   mxWGDefCargo( cName, NIL, { .F., "", .F. } )

RETURN( NIL )



FUNCTION InputBox2( ;                 // Exibe um inputbox avancado
                    cInputPrompt,;    // Texto do label
                    cDialogCaption,;  // Titulo da janela
                    uDefault,;        // Valor default da digitacao
                    lPassWord ;       // Ativa digitacao de senha
                  )

   LOCAL uReturn := ""
   LOCAL lDate   := ( ValType( uDefault ) = "D" )
   LOCAL nLines
   
	vDef( @cInputPrompt  , ""  )
   vDef( @cDialogCaption, ""  )
   vDef( @uDefault      , ""  )
   vDef( @lPassWord     , .T. )

   cInputPrompt := StrTran( cInputPrompt, ";", Chr(13) + Chr(10) )
   
   nLines := NumAt( Chr(13) + Chr(10), cInputPrompt ) * 17
   
   IF _IsWindowDefined( "_InputBox" )
      mxDoMethod( "_InputBox", "Release" )
   ENDIF

	DEFINE WINDOW _InputBox ;
		AT     0, 0 ;
		WIDTH  350 ;
		HEIGHT 124 + nLines ;
		TITLE  cDialogCaption ;
		MODAL	;
		NOSIZE

		ON KEY ESCAPE ACTION ( _HMG_DialogCancelled := .T., mxDoMethod( "_InputBox", "Release" ) )

      DEFINE LABEL _Label
         ROW       10
         COL       14
         WIDTH     341
         HEIGHT    21 + nLines
 		   VALUE     cInputPrompt
	      FONTNAME  oWConfig:FontName_Button
	      FONTSIZE  oWConfig:FontSize_Button
      END LABEL
      
      IF lDate
      
         DEFINE DATEPICKER _TextBox
            ROW         34 + nLines
            COL         14
   		   HEIGHT      21
   		   WIDTH       314
            VALUE       uDefault
   	      FONTNAME    oWConfig:FontName_Button
   	      FONTSIZE    oWConfig:FontSize_Button
   		   ON ENTER    ( _HMG_DialogCancelled := .F., uReturn := _InputBox._TextBox.Value, mxDoMethod( "_InputBox", "Release" ) )
         END DATEPICKER

      ELSE
      
         DEFINE TEXTBOX _TextBox
            ROW         34 + nLines
            COL         14
   		   HEIGHT      21
   		   WIDTH       314
            VALUE       uDefault
            UPPERCASE   .T.
            PASSWORD    lPassWord
   	      FONTNAME    oWConfig:FontName_Button
   	      FONTSIZE    oWConfig:FontSize_Button
   		   ON ENTER    ( _HMG_DialogCancelled := .F., uReturn := _InputBox._TextBox.Value, mxDoMethod( "_InputBox", "Release" ) )
         END TEXTBOX

      ENDIF

      DEFINE BUTTON _Ok
         ROW        64 + nLines
         COL        138
		   WIDTH      92
		   HEIGHT     24
		   CAPTION    "OK"
	      FONTNAME   oWConfig:FontName_Button
	      FONTSIZE   oWConfig:FontSize_Button
		   ACTION    ( _HMG_DialogCancelled := .F., uReturn := _InputBox._TextBox.Value, mxDoMethod( "_InputBox", "Release" ) )
      END BUTTON

      DEFINE BUTTON _Cancel
         ROW        64 + nLines
         COL        236
		   WIDTH      92
		   HEIGHT     24
         CAPTION    "Cancela"
	      FONTNAME   oWConfig:FontName_Button
	      FONTSIZE   oWConfig:FontSize_Button
		   ACTION     ( _HMG_DialogCancelled := .T., mxDoMethod( "_InputBox", "Release" ) )
		END BUTTON

	END WINDOW

	_SetFocus( "_TextBox", "_InputBox" )

   mxDoMethod( "_InputBox", "Center" )
   mxDoMethod( "_InputBox", "Activate" )

RETURN( uReturn )



PROCEDURE SetThemes( nType )

   LOCAL aColors := GetMenuColors()

	vDef( @nType, 0 )

   SET MENUSTYLE EXTENDED

	SWITCH nType
	CASE 0  // Default
		aColors[ MNUCLR_MENUBARBACKGROUND1 ]  := GetSysColor( 15 )
		aColors[ MNUCLR_MENUBARBACKGROUND2 ]  := GetSysColor( 15 )
		aColors[ MNUCLR_MENUBARTEXT ]         := RGB(   0,   0,   0 )
		aColors[ MNUCLR_MENUBARSELECTEDTEXT ] := RGB(   0,   0,   0 )
		aColors[ MNUCLR_MENUBARGRAYEDTEXT ]   := RGB( 192, 192, 192 )
		aColors[ MNUCLR_MENUBARSELECTEDITEM1 ]:= RGB( 255, 252, 248 )
		aColors[ MNUCLR_MENUBARSELECTEDITEM2 ]:= RGB( 136, 133, 116 )

		aColors[ MNUCLR_MENUITEMTEXT ]        := RGB(   0,   0,   0 )
		aColors[ MNUCLR_MENUITEMSELECTEDTEXT ]:= RGB(   0,   0,   0 )
		aColors[ MNUCLR_MENUITEMGRAYEDTEXT ]  := RGB( 192, 192, 192 )

		aColors[ MNUCLR_MENUITEMBACKGROUND1 ] := RGB( 255, 255, 255 )
		aColors[ MNUCLR_MENUITEMBACKGROUND2 ] := RGB( 255, 255, 255 )

		aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND1 ] := RGB( 182, 189, 210 )
		aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND2 ] := RGB( 182, 189, 210 )
		aColors[ MNUCLR_MENUITEMGRAYEDBACKGROUND1 ]   := RGB( 255, 255, 255 )
		aColors[ MNUCLR_MENUITEMGRAYEDBACKGROUND2 ]   := RGB( 255, 255, 255 )

		aColors[ MNUCLR_IMAGEBACKGROUND1 ] := RGB( 246, 245, 244 )
		aColors[ MNUCLR_IMAGEBACKGROUND2 ] := RGB( 207, 210, 200 )

		aColors[ MNUCLR_SEPARATOR1 ] := RGB( 168, 169, 163 )
		aColors[ MNUCLR_SEPARATOR2 ] := RGB( 255, 255, 255 )

		aColors[ MNUCLR_SELECTEDITEMBORDER1 ] := RGB(  10, 36, 106 )
		aColors[ MNUCLR_SELECTEDITEMBORDER2 ] := RGB(  10, 36, 106 )
		aColors[ MNUCLR_SELECTEDITEMBORDER3 ] := RGB(  10, 36, 106 )
		aColors[ MNUCLR_SELECTEDITEMBORDER4 ] := RGB(  10, 36, 106 )

		SET MENUCURSOR FULL

		SET MENUSEPARATOR SINGLE RIGHTALIGN

		SET MENUITEM BORDER 3DSTYLE

		EXIT

	CASE 1  // Classic
		aColors[ MNUCLR_MENUBARBACKGROUND1 ]  := GetSysColor( 15 )
		aColors[ MNUCLR_MENUBARBACKGROUND2 ]  := GetSysColor( 15 )
		aColors[ MNUCLR_MENUBARTEXT ]         := GetSysColor(  7 )
		aColors[ MNUCLR_MENUBARSELECTEDTEXT ] := GetSysColor( 14 )
		aColors[ MNUCLR_MENUBARGRAYEDTEXT ]   := GetSysColor( 17 )
		aColors[ MNUCLR_MENUBARSELECTEDITEM1 ]:= GetSysColor( 13 )
		aColors[ MNUCLR_MENUBARSELECTEDITEM2 ]:= GetSysColor( 13 )

		aColors[ MNUCLR_MENUITEMTEXT ]        := GetSysColor(  7 )
		aColors[ MNUCLR_MENUITEMSELECTEDTEXT ]:= GetSysColor( 14 )
		aColors[ MNUCLR_MENUITEMGRAYEDTEXT ]  := GetSysColor( 17 )

		aColors[ MNUCLR_MENUITEMBACKGROUND1 ] := If( _HMG_IsXP, GetSysColor( 4 ), RGB( 255, 255, 255 ) )
		aColors[ MNUCLR_MENUITEMBACKGROUND2 ] := If( _HMG_IsXP, GetSysColor( 4 ), RGB( 255, 255, 255 ) )

		aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND1 ] := GetSysColor( 13 )
		aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND2 ] := GetSysColor( 13 )
		aColors[ MNUCLR_MENUITEMGRAYEDBACKGROUND1 ]   := If( _HMG_IsXP, GetSysColor( 4 ), RGB( 255, 255, 255 ) )
		aColors[ MNUCLR_MENUITEMGRAYEDBACKGROUND2 ]   := If( _HMG_IsXP, GetSysColor( 4 ), RGB( 255, 255, 255 ) )

		aColors[ MNUCLR_IMAGEBACKGROUND1 ] := GetSysColor( 15 )
		aColors[ MNUCLR_IMAGEBACKGROUND2 ] := GetSysColor( 15 )

		aColors[ MNUCLR_SEPARATOR1 ] := GetSysColor( 17 )
		aColors[ MNUCLR_SEPARATOR2 ] := GetSysColor( 14 )

		aColors[ MNUCLR_SELECTEDITEMBORDER1 ] := GetSysColor( 13 )
		aColors[ MNUCLR_SELECTEDITEMBORDER2 ] := GetSysColor( 13 )
		aColors[ MNUCLR_SELECTEDITEMBORDER3 ] := GetSysColor( 17 )
		aColors[ MNUCLR_SELECTEDITEMBORDER4 ] := GetSysColor( 14 )

		SET MENUCURSOR FULL

		SET MENUSEPARATOR DOUBLE RIGHTALIGN

		SET MENUITEM BORDER FLAT

		EXIT

	CASE 2  // Office 2000
		aColors[ MNUCLR_MENUBARBACKGROUND1 ]  := GetSysColor( 15 )
		aColors[ MNUCLR_MENUBARBACKGROUND2 ]  := GetSysColor( 15 )
		aColors[ MNUCLR_MENUBARTEXT ]         := RGB(   0,   0,   0 )
		aColors[ MNUCLR_MENUBARSELECTEDTEXT ] := RGB(   0,   0,   0 )
		aColors[ MNUCLR_MENUBARGRAYEDTEXT ]   := RGB( 128, 128, 128 )
		aColors[ MNUCLR_MENUBARSELECTEDITEM1 ]:= GetSysColor(15)
		aColors[ MNUCLR_MENUBARSELECTEDITEM2 ]:= GetSysColor(15)

		aColors[ MNUCLR_MENUITEMTEXT ]        := RGB(   0,   0,   0 )
		aColors[ MNUCLR_MENUITEMSELECTEDTEXT ]:= RGB( 255, 255, 255 )
		aColors[ MNUCLR_MENUITEMGRAYEDTEXT ]  := RGB( 128, 128, 128 )

		aColors[ MNUCLR_MENUITEMBACKGROUND1 ] := RGB( 212, 208, 200 )
		aColors[ MNUCLR_MENUITEMBACKGROUND2 ] := RGB( 212, 208, 200 )

		aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND1 ] := RGB(  10,  36, 106 )
		aColors[ MNUCLR_MENUITEMSELECTEDBACKGROUND2 ] := RGB(  10,  36, 106 )
		aColors[ MNUCLR_MENUITEMGRAYEDBACKGROUND1 ]   := RGB( 212, 208, 200 )
		aColors[ MNUCLR_MENUITEMGRAYEDBACKGROUND2 ]   := RGB( 212, 208, 200 )

		aColors[ MNUCLR_IMAGEBACKGROUND1 ] := RGB( 212, 208, 200 )
		aColors[ MNUCLR_IMAGEBACKGROUND2 ] := RGB( 212, 208, 200 )

		aColors[ MNUCLR_SEPARATOR1 ] := RGB( 128, 128, 128 )
		aColors[ MNUCLR_SEPARATOR2 ] := RGB( 255, 255, 255 )

		aColors[ MNUCLR_SELECTEDITEMBORDER1 ] := RGB(  10,  36, 106 )
		aColors[ MNUCLR_SELECTEDITEMBORDER2 ] := RGB( 128, 128, 128 )
		aColors[ MNUCLR_SELECTEDITEMBORDER3 ] := RGB(  10,  36, 106 )
		aColors[ MNUCLR_SELECTEDITEMBORDER4 ] := RGB( 255, 255, 255 )

		SET MENUCURSOR SHORT
		SET MENUSEPARATOR DOUBLE LEFTALIGN
		SET MENUITEM BORDER 3D

	END

	SetMenuColors( aColors )

RETURN( NIL )



// Funcoes p/ exibicao de imagens .GIF animado

#ifndef __XHARBOUR__
   #xtranslate At(<a>,<b>,[<x,...>]) => hb_At(<a>,<b>,<x>)
#endif
#define Alert( c ) MsgExclamation( c, "LoadGif", NIL, .F. )



FUNCTION LoadGif( GIF, aGifInfo, aFrames, aImgInfo, cPath )

   LOCAL cGifHeader, cGifEnd := Chr(0) + Chr(33) + Chr(249)
   LOCAL i, j, nImgCount, nFileHandle
   LOCAL cStream, cFile, cPicBuf, imgHeader
   LOCAL bLoadGif := TRUE

	aGifInfo := Array( 3 )
	aFrames  := {}
	aImgInfo := {}

   vDef( @cPath, GetTempFolder() )
   
   cPath := ConfPath( cPath )

	IF ! File( GIF )
		Alert( "File " + GIF + " is not found!" )
		RETURN FALSE
	ENDIF

	IF ! ReadFromStream( GIF, @cStream )
		Alert( "Error when reading file " + GIF )
		RETURN FALSE
   ENDIF

	nImgCount := 0
	i := 1
	j := At( cGifEnd, cStream, i ) + 1

	cGifHeader := Left( cStream, j )

	IF Left( cGifHeader, 3 ) <> "GIF"
		Alert( "This file is not a GIF file!" )
		RETURN FALSE
	ENDIF

	aGifInfo[ 1 ] := Substr( cGifHeader, 4, 3 )          // GifVersion
	aGifInfo[ 2 ] := Bin2W( Substr( cGifHeader, 7, 2 ) ) // LogicalScreenWidth
	aGifInfo[ 3 ] := Bin2W( Substr( cGifHeader, 9, 2 ) ) // LogicalScreenHeight

	i := j + 2

	/* Split GIF Files at separate pictures and load them into ImageList */

	DO WHILE .T.

		nImgCount ++
		j := At( cGifEnd, cStream, i ) + 3

      IF j > Len( cGifEnd )

         cFile := cPath + cFileNoExt( GIF) + "_frame_" + StrZero( nImgCount, 4 ) + ".gif"

         IF File( ModExt( cFile, ".bmp" ) )

            cFile := ModExt( cFile, ".bmp" )
            imgHeader := Left( Substr ( cStream, i - 1, j - i ), 16 )

         ELSE

            nFileHandle := FCreate( cFile, FC_NORMAL )

            IF FError() <> 0
   				Alert( "Error while creatingg a temp file:" + Str( Ferror() ) )
   				RETURN FALSE
   			ENDIF

   	      cPicBuf := cGifHeader + Substr( cStream, i - 1, j - i )
   	      imgHeader := Left( Substr ( cStream, i - 1, j - i ), 16 )

   			IF FWrite( nFileHandle, cPicBuf ) <> Len( cPicBuf )
   				Alert( "Error while writing a file:" + Str( FError() ) )
   				RETURN FALSE
   			ENDIF

            IF ! FClose( nFileHandle )
   				Alert( "Error while closing a file:" + Str( FError() ) )
   				RETURN FALSE
   			ENDIF

         ENDIF

	      aSize( aFrames, nImgCount )
         aFrames[ nImgCount ]  := cFile

       	aSize( aImgInfo, nImgCount )
	      aImgInfo[ nImgCount ] := imgHeader

		ENDIF

		DO EVENTS

      IF j == 3
		   EXIT
	   ELSE
		   i := j
	   ENDIF

   ENDDO

   IF i < Len( cStream )

      cFile := cPath + cFileNoExt( GIF) + "_frame_" + StrZero( nImgCount, 4 ) + ".gif"

      IF File( ModExt( cFile, ".bmp" ) )

         cFile := ModExt( cFile, ".bmp" )
         imgHeader := Left( Substr( cStream, i - 1, Len( cStream ) - i ), 16 )

      ELSE

   	   nFileHandle := FCreate( cFile, FC_NORMAL )

         IF FError() <> 0
   			Alert( "Error while creatingg a temp file:" + Str( Ferror() ) )
      		RETURN FALSE
   	   ENDIF

         cPicBuf := cGifHeader + Substr( cStream, i - 1, Len( cStream ) - i )
         imgHeader := Left( Substr( cStream, i - 1, Len( cStream ) - i ), 16 )

   	   IF FWrite( nFileHandle, cPicBuf ) <> Len( cPicBuf )
   			Alert( "Error while writing a file:" + Str( FError() ) )
      		RETURN FALSE
   		ENDIF

         IF ! FClose( nFileHandle )
   		   Alert( "Error while closing a file:" + Str( FError() ) )
   		   RETURN FALSE
   	   ENDIF

      ENDIF

    	aSize( aFrames, nImgCount )
      aFrames[ nImgCount ]  := cFile

	   aSize( aImgInfo, nImgCount )
      aImgInfo[ nImgCount ] := imgHeader

   ENDIF

RETURN( bLoadGif )



FUNCTION ReadFromStream( cFile, cStream )

   LOCAL nFileHandle := FOpen( cFile )
   LOCAL nFileSize

	IF FError() <> 0
      RETURN FALSE
	ENDIF

	nFileSize := FSeek( nFileHandle, 0, FS_END )
	cStream   := Space( nFileSize )
	FSeek( nFileHandle, 0, FS_SET )
	FRead( nFileHandle, @cStream, nFileSize )
	FClose( nFileHandle )

RETURN ( FError( ) == 0 .AND. ! Empty( cStream ) )



FUNCTION GetFrameDelay( cImageInfo, nDelay )

   vDef( @nDelay, 10 )

RETURN( Bin2W( Subs( cImageInfo, 4, 2 ) ) * nDelay )



FUNCTION AnimatedGif( cForm, cFile, nRow, nCol, cText )

   LOCAL aPictInfo := {}

   LOCAL cAux, nPnWidth, nPnHeight, nPnRow1, nPnRow2, nPnCol1, nPnCol2

   vDef( @cForm, mxWFObj():cName )
   
   cFormGif := cForm
   
   cFile := imgFile( DelExt( cFile ) + ".gif" )

   DO WHILE .T.
      cAux := "Tmp" + StrZero( HB_RandomInt( 0, 999 ), 3 )
	   IF ! _IsControlDefined( "img" + cAux, cFormGif )
	      EXIT
	   ENDIF
	ENDDO

   IF File( cFile )

      cImageGif := "img" + cAux
      cTimerGif := "tmr" + cAux

      LoadGif( cFile, @aPictInfo, @aPictures, @aImageInfo, oWConfig:Form_ImagePath )

      nTotalFrames  := Len( aPictures )
	   nCurrentFrame := 1

      DEFINE IMAGE &cImageGif
         PARENT  &cFormGif
         ROW     nRow
         COL     nCol
         PICTURE NIL
         WIDTH   aPictInfo[2]
         HEIGHT  aPictInfo[3]
         STRETCH .T.
      END IMAGE

   ELSE
   
      aPictInfo := { "", 0, 0 }

      nTotalFrames := 0

   ENDIF
   
   nPnWidth  := 0
   nPnHeight := 0

   IF cText <> NIL

      cLabelGif := "lb" + cAux

      mxLabel( cLabelGif, nRow + Int( aPictInfo[3] / 2 ), nCol + aPictInfo[2] +10, cText, { oWConfig:FontName_Frame, 12, NIL, .T. } )

      SetProperty( cFormGif, cLabelGif, "Row", GetProperty( cFormGif, cLabelGif, "Row" ) - Int( GetProperty( cFormGif, cLabelGif, "Height" ) / 2 ) )

      nPnHeight := 5
      nPnWidth  := GetProperty( cFormGif, cLabelGif, "Width" ) +20

   ENDIF

   IF cImageGif <> NIL

      nPnRow1 := GetProperty( cFormGif, cImageGif, "Row" ) -2
      nPnRow2 := GetProperty( cFormGif, cImageGif, "Row" ) + aPictInfo[3]

      nPnCol1 := GetProperty( cFormGif, cImageGif, "Col" ) -2
      nPnCol2 := GetProperty( cFormGif, cImageGif, "Col" ) + aPictInfo[2] + nPnWidth

      nPnHeight := nPnRow2 - nPnRow1 +5
      nPnWidth  := nPnCol2 - nPnCol1

   ENDIF
   
   IF nTotalFrames > 1

      DEFINE TIMER &cTimerGif ;
         OF       &cFormGif ;
         INTERVAL GetFrameDelay( aImageInfo[ nCurrentFrame ] ) ;
         ACTION   PlayGif()

      SetProperty( cFormGif, cImageGif, "Picture", aPictures[ nCurrentFrame ] )
      SetProperty( cFormGif, cTimerGif, "Enabled", .T. )

   ENDIF

RETURN( { cAux, nPnWidth, nPnHeight } )



PROCEDURE PlayGif

	IF nCurrentFrame < nTotalFrames
		nCurrentFrame ++
	ELSE
		nCurrentFrame := 1
	ENDIF

   SetProperty( cFormGif, cImageGif, "Picture", aPictures[ nCurrentFrame ] )
   SetProperty( cFormGif, cTimerGif, "Value"  , GetFrameDelay( aImageInfo[ nCurrentFrame ] ) )

   mxDoMethod( cFormGif, cImageGif, "Refresh" )

RETURN( NIL )



FUNCTION GridSetOrder( _nGridCol, _cTypeCol, _cGridName )

   #define cSeparador  Chr(19)

   LOCAL nColGrid   := 0
   LOCAL nRowGrid   := 0
   LOCAL aDataGrid  := {}
   LOCAL aGridIndex := {}
   LOCAL aContOrd   := {}
   LOCAL cContOrd

   LOCAL nRow, nCol, nPosCont, nValue

   vDef( @_nGridCol, 1   )
   vDef( @_cTypeCol, "C" )

   IF _cGridName = NIL
      _cGridName := This.Name
   ENDIF

   nValue := GetProperty( mxWFActive(), _cGridName, "Value" )
   
   aDataGrid := aClone( GetProperty( mxWFActive(), _cGridName, "Item", _nGridCol ) )
   nColGrid  := Len( aDataGrid )
   nRowGrid  := GetProperty( mxWFActive(), _cGridName, "ItemCount" )
   aContOrd  := Array( nColGrid )

   FOR nRow := 1 TO nRowGrid

      cContOrd := GetProperty( mxWFActive(), _cGridName, "Item", nRow )[ _nGridCol ]

      IF _cTypeCol = "D"
         cContOrd := DtoS( CtoD( cContOrd ) )
      ELSEIF _cTypeCol = "N"
         cContOrd := PadL( Trim( cContOrd ), 30 )
      ELSEIF _cTypeCol = "C"
         cContOrd := Upper( cContOrd )
      ENDIF

      cContOrd += cSeparador

      FOR nCol := 1 TO nColGrid
         cContOrd += GetProperty( mxWFActive(), _cGridName, "Item", nRow )[ nCol ] + cSeparador
      NEXT

      aAdd( aGridIndex, cContOrd )

   NEXT

   aGridIndex := aSort( aGridIndex )

   FOR nRow := 1 TO nRowGrid

      cContOrd := aGridIndex[ nRow ]
      nPosCont :=1

      FOR nCol := 1 TO nColGrid

         nPosCont ++
         aContOrd[ nCol ] := cStrToken( cContOrd, nPosCont, cSeparador )

      NEXT

      SetProperty( mxWFActive(), _cGridName, "Item", nRow, aContOrd )

   NEXT

   SetProperty( mxWFActive(), _cGridName, "Value", Max( nValue, 1 ) )

   mxDoMethod( mxWFActive(), _cGridName, "Refresh"  )
   mxDoEvent(  mxWFActive(), _cGridName, "OnChange" )

RETURN( .T. )



STATIC FUNCTION cStrToken( _cCadena, _nPosDato, _cSeparador )

   LOCAL nBytes     := Len( _cCadena )
   LOCAL nSeparador := 0
   LOCAL cDato      := ""
   LOCAL cByte      := ""
   LOCAL nByte

   vDef( @_nPosDato  , 1 )
   vDef( @_cSeparador, Chr(19) )

   FOR nByte := 1 TO nBytes

      cByte  := Subs( _cCadena, nByte, 1 )

      IF cByte = _cSeparador

         nSeparador ++

         IF nSeparador = _nPosDato
            RETURN( cDato )
         ENDIF

         cByte := ""
         cDato := ""

      ENDIF

      cDato += cByte

   NEXT

   If nSeparador < ( _nPosDato - 1 )
      cDato := ""
   ENDIF

RETURN( cDato )