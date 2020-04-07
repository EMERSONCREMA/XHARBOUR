/*

 MaxWFrm.prg
 WinForm Library: Funcoes p/ exibicao de formularios.

 DENIS MAZZUCATTO RODRIGUES
 03/12/15 * Desenvolvimento e implementacao de mxWFNextPage().
 24/09/13 * Implementado parametro aPage em CreateForm().
 04/10/10 * Desenvolvimento de mxWFChangePage() e mxWFBtArrow().
 27/09/10 * Desenvolvimento de mxWFAction(), mxWFInfo() e mxPressMouse().
 21/09/10 * Inicio do desenvolvimento.

*/

#include "minigui.ch"
#include "message.ch"
#include "tsbrowse.ch"
#include "inkey.ch"
#include "hbclass.ch"
#include "maxwin.ch"

#define WM_USER              0x400
#define TTM_SETMAXTIPWIDTH   ( WM_USER +24 )
#define TTM_SETDELAYTIME     ( WM_USER +3  )
#define TTDT_AUTOPOP         2

STATIC _lPauseMove    := .F.
STATIC _lFormFullMode := .T.

STATIC aWFormOpen   := {}  // Matriz com informacoes dos formularios abertos
STATIC cWFormActive := ""  // Nome do formulario ativo

// Class: mxWForm - Controle de formularios

CLASS mxWForm

   DATA cName             // Nome do formulario
   DATA cPanelTBar        // Nome do painel da ToolBar
   DATA cModel            // Modelo do formulario
   DATA lUsePageAux       // Define se ira utilizar uma pagina auxiliar
   DATA lUseImage         // Define se ira utilizar imagem lateral na ficha de cadastro
   DATA nImageWidth       // Largura da imagem lateral na ficha de cadastro

   DATA cIcon             // Nome do arquivo de icone
   DATA cTitleTop         // Titulo do formulario
   DATA cTitle            // Titulo referente ao modulo acessado
   DATA nWidth            // Largura do formulario
   DATA nHeight           // Altura do formulario

   DATA aRow              // Array com as linhas  (utilizado na movimentacao do formulario)
   DATA aCol              // Array com as colunas (utilizado na movimentacao do formulario)
   DATA lMaximized        // Identifica se o formulario principal esta maximizado
   DATA cAlias            // Nome do alias principal utilizado no browse
   DATA aFunction         // Array com o nome das funcoes de controle
   DATA aGets             // Array com o nome dos edit's do formulario
   DATA lVldGets          // Define se irá efetuar as validacoes dos edit's
   DATA aSaveState        // Salva o estado dos arquivos abertos ao perder o foco
   DATA uCargo            // Propriedade de livre atribuicao
                          
	DATA Rpt_nRowGet       // Linha inicial das digitacoes nos formularios de relatorio

	DATA Page_nRow         // Linha inicial da pagina (TabPage)
	DATA Page_nWidth       // Largura da pagina
	DATA Page_nHeight      // Altura da pagina
   
   DATA PageAux_nRowGet   // Linha inicial das digitacoes dentro da pagina auxiliar
	DATA PageAux_nRow      // Linha inicial da pagina auxiliar (TabPage)
	DATA PageAux_nWidth    // Largura da pagina auxiliar
	DATA PageAux_nHeight   // Altura da pagina auxiliar
	
	DATA PageTitle_cLista  // Titulo da aba da lista
   DATA PageTitle_cFicha  // Titulo da aba da ficha de cadastro
   DATA PageTitle_cMapa   // Titulo da aba do mapa
   
	DATA BtOk_nCol         // Coluna do botao de confirmacao na ficha de cadastro
	DATA BtNo_nCol         // Coluna do botao cancela na ficha de cadastro
   
	DATA bInit             // Codigo ao iniciar
	DATA bGotFocus         // Codigo ao receber o foco
	DATA bLostFocus        // Codigo ao perder o foco
	DATA bRelease          // Codigo ao fechar
	DATA bMinimize         // Codigo ao minimizar
	DATA bOnKeyESC         // Codigo ao ser pressionado ESC

	METHOD New( cForm, nWidth, nHeight, cTitle, aFunction, lExclusive )
	METHOD CreateForm( uFunction, aBrwCols, cBrwOrder, aPage )
	METHOD Activate()
	METHOD GetFunc( cFunc )

	METHOD OnInit()
	METHOD OnGotFocus()
	METHOD OnLostFocus()
	METHOD OnRelease()
	METHOD OnMove()
	METHOD OnMinimize()

ENDCLASS



METHOD New( ;             // Define informacoes sobre o novo formulario a ser criado
            cForm,;       // Nome do formulario
            nWidth,;      // Largura
            nHeight,;     // Altura
            cTitle,;      // Titulo do formulario
            aFunction,;   // Array com nome das funcoes de controle
            lExclusive ;  // Abertura exclusiva
          ) CLASS mxWForm

   /*
   Elementos de aFunction:
   1º = Funcao p/ controle das teclas pressionadas no browse
   2º = Funcao p/ exibicoes durante a navegacao no browse
   3º = Funcao p/ controle da pesquisa de registros no browse
   4º = Funcao p/ controle de validacoes das digitações
   5º = Funcao p/ controle dos botoes "Confirmar" e "Cancelar" da "Ficha de cadastro"
   6º = Funcao p/ controle da mudanca de pagina
   */

   LOCAL aResult := {}

	vDef( @cTitle    , ""  )
   vDef( @aFunction , {}  )
   vDef( @lExclusive, .F. )

   aSize( aFunction, 6 )

   _HMG_BRWLangError[10] := MSG_TITLE

   IF cForm <> "frMain"
	   csStatus( 'Carregando "' + Lower( cTitle ) + '"', "frMain" )
	ENDIF
	
   oWConfig:Load()  // Carrega as configuracoes de cores

   aAdd( aWFormOpen, { cForm, lExclusive } )
   
   cWFormActive := cForm

   ::cName       := cForm
	::cModel      := "CAD"
	::lUseImage   := .F.
	::lUsePageAux := .F.
	
   ::nWidth      := nWidth
   ::nHeight     := nHeight
   ::cTitle      := cTitle
   ::aFunction   := aFunction
   ::cAlias      := Alias()
   ::lVldGets    := .T.
   ::aGets       := {}
   ::uCargo      := NIL

   ::cPanelTBar := "pnToolBar" + Subs( ::cName, 3 )

   ::Page_nRow    := 58
   ::Page_nWidth  := ::nWidth -4
   ::Page_nHeight := ::nHeight -107

	::PageAux_nRowGet := 31
	::PageAux_nRow    := 82
	::PageAux_nWidth  := ::nWidth - If( ::lUseImage, ::nImageWidth, 8 )
	::PageAux_nHeight := ::nHeight -133

	::BtOk_nCol := ::Page_nWidth -220
	::BtNo_nCol := ::Page_nWidth -115

	::cIcon       := imgFile( "icone.ico" )
	::cTitleTop   := oWConfig:Form_TitleTop
	::nImageWidth := 250

	::PageTitle_cLista := "Lista de pesquisa"
	::PageTitle_cFicha := "Ficha de cadastro"
	::PageTitle_cMapa  := "Mapa de localização"

	::Rpt_nRowGet := 70

RETURN( Self )



METHOD GetFunc( ;        // Retorna o nome das funcoes de controle do formulario
                cFunc ;  // Tipo da funcao
              ) CLASS mxWForm

	LOCAL cReturn

	BEGIN SEQUENCE

  	   IF Empty( cWFormActive )
  	      BREAK
      ENDIF

		cReturn := ::aFunction

	   IF cReturn = NIL
	      BREAK
      ENDIF

		DO CASE
			CASE cFunc = "BrwKeys" ; cReturn := cReturn[1]  // Funcao p/ controle das teclas pressionadas no browse
			CASE cFunc = "BrwStat" ; cReturn := cReturn[2]  // Funcao p/ exibicoes durante a navegacao no browse
			CASE cFunc = "BrwSeek" ; cReturn := cReturn[3]  // Funcao p/ controle de pesquisa de registros no browse
			CASE cFunc = "GetVld"  ; cReturn := cReturn[4]  // Funcao p/ controle de validacoes das digitacoes
			CASE cFunc = "BtConf"  ; cReturn := cReturn[5]  // Funcao p/ controle dos botoes "Confirmar" e "Cancelar" da "Ficha de cadastro"
			CASE cFunc = "TabPage" ; cReturn := cReturn[6]  // Funcao p/ controle da mudanca de pagina
		ENDCASE

	ENDSEQUENCE

RETURN( cReturn )



METHOD CreateForm( ;            // Cria o formulario
                   uFunction,;  // Funcao com as definicoes de tela e digitacoes
                   aBrwCols,;   // Array com as colunas do browse
                   cBrwOrder,;  // Nome da variavel p/ controle da ordenacao dos registros no browse
                   aPage ;      // Array com as paginas internas da ficha de cadastro
                 ) CLASS mxWForm
                 
   LOCAL nPage, cTitle, cToolTip

   IF aBrwCols <> NIL .AND. ValType( aBrwCols ) = "L"  // Cria formulario do tipo MODAL

      DEFINE WINDOW &( ::cName ) ;
         AT           0, 0 ;
         WIDTH        ::nWidth ;
         HEIGHT       ::nHeight ;
         TITLE        ::cTitleTop ;
         MODAL ;
         NOSIZE ;
         NOSYSMENU ;
         NOSHOW ;
         BACKCOLOR    oWConfig:Color_Form ;
   		ON INIT      ::OnInit() ;
         ON RELEASE   ::OnRelease() ;
         ON GOTFOCUS  ::OnGotFocus() ;
         ON LOSTFOCUS ::OnLostFocus() ;
         ON MOVE      ::OnMove()

         IF ValType( uFunction ) = "C"
            &uFunction( 1 )
            &uFunction( 0 )
         ELSE
            Eval( uFunction, 1 )
            Eval( uFunction, 0 )
         ENDIF

      END WINDOW

   ELSEIF aPage = NIL

      DEFINE WINDOW &( ::cName ) ;
         AT           0, 0 ;
         WIDTH        ::nWidth ;
         HEIGHT       ::nHeight ;
         TITLE        ::cTitleTop ;
         ICON         ::cIcon ;
         CHILD ;
         NOMAXIMIZE ;
         NOSHOW ;
         NOSIZE ;
         BACKCOLOR    oWConfig:Color_Form ;
   	   ON INIT      ::OnInit() ;
         ON RELEASE   ::OnRelease() ;
         ON GOTFOCUS  ::OnGotFocus() ;
         ON LOSTFOCUS ::OnLostFocus() ;
         ON MOVE      ::OnMove() ;
         ON MINIMIZE  ::OnMinimize()

         IF aBrwCols <> NIL
         
            DEFINE TAB oTabPage ;
               AT        ::Page_nRow, 0 ;
               WIDTH     ::Page_nWidth ;
               HEIGHT    ::Page_nHeight ;
               VALUE     WF_PG_LISTA ;
               FONT      oWConfig:FontName_Page ;
   				SIZE      oWConfig:FontSize_Page ;
   				BACKCOLOR oWConfig:Color_Tab ;
               FLAT ;
               NOTABSTOP ;
               ON CHANGE mxWFChangePage()

               PAGE ::PageTitle_cLista

                  mxWBrowse( aBrwCols, cBrwOrder )

               END PAGE

               PAGE ::PageTitle_cFicha

                  IF ValType( uFunction ) = "C"
                     &uFunction( 1 )
                  ELSE
                     Eval( uFunction, 1 )
                  ENDIF

               END PAGE

               IF ValType( uFunction ) = "C"
                  &uFunction( WF_PG_CUSTOM )
               ELSE
                  Eval( uFunction, WF_PG_CUSTOM )
               ENDIF

            END TAB

         ENDIF
         
         IF ValType( uFunction ) = "C"
            &uFunction( 0 )
         ELSE
            Eval( uFunction, 0 )
         ENDIF

      END WINDOW

   ELSE

      ::lUsePageAux := .T.

      DEFINE WINDOW &( ::cName ) ;
         AT           0, 0 ;
         WIDTH        ::nWidth ;
         HEIGHT       ::nHeight ;
         TITLE        ::cTitleTop ;
         ICON         ::cIcon ;
         CHILD ;
         NOMAXIMIZE ;
         NOSHOW ;
         NOSIZE ;
         BACKCOLOR    oWConfig:Color_Form ;
   	   ON INIT      ::OnInit() ;
         ON RELEASE   ::OnRelease() ;
         ON GOTFOCUS  ::OnGotFocus() ;
         ON LOSTFOCUS ::OnLostFocus() ;
         ON MOVE      ::OnMove() ;
         ON MINIMIZE  ::OnMinimize()

			DEFINE TAB oTabPage2 ;
            AT     ::PageAux_nRow, 1 ;
            WIDTH  ::PageAux_nWidth ;
            HEIGHT ::PageAux_nHeight ;
            VALUE  1 ;
            FONT   oWConfig:FontName_Page ;
				SIZE   oWConfig:FontSize_Page ;
				BOTTOM ;
				BUTTONS
				
            FOR nPage := 1 TO Len( aPage )
            
               cTitle := aPage[ nPage ]
               
               IF At( ";", cTitle ) = 0
                  cToolTip := NIL
               ELSE
                  cToolTip := Subs( cTitle, At( ";", cTitle ) +1 )
                  cTitle   := Left( cTitle, At( ";", cTitle ) -1 )
               ENDIF

               PAGE cTitle TOOLTIP cToolTip

                  IF ValType( uFunction ) = "C"
                     &uFunction( nPage )
                  ELSE
                     Eval( uFunction, nPage )
                  ENDIF

               END PAGE

            NEXT

         END TAB

			SetProperty( ::cName, "oTabPage2", "Visible"  , .F. )
			SetProperty( ::cName, "oTabPage2", "BackColor", oWConfig:Color_Page )

         DEFINE TAB oTabPage ;
            AT        ::Page_nRow, 0 ;
            WIDTH     ::Page_nWidth ;
            HEIGHT    ::Page_nHeight ;
            VALUE     WF_PG_LISTA ;
            FONT      oWConfig:FontName_Page ;
				SIZE      oWConfig:FontSize_Page ;
				BACKCOLOR oWConfig:Color_Tab ;
            FLAT ;
            NOTABSTOP ;
            ON CHANGE mxWFChangePage()

            PAGE ::PageTitle_cLista

               IF aBrwCols <> NIL
                  mxWBrowse( aBrwCols, cBrwOrder )
               ELSEIF ValType( uFunction ) = "C"
                  &uFunction( -1 )
               ELSE
                  Eval( uFunction, -1 )
               ENDIF

            END PAGE

            PAGE ::PageTitle_cFicha

               mxWFButtons()

            END PAGE

         END TAB

         IF ValType( uFunction ) = "C"
            &uFunction( 0 )
         ELSE
            Eval( uFunction, 0 )
         ENDIF

      END WINDOW

   ENDIF

   IF cBrwOrder <> NIL
      ( ::cAlias )->( mxTop( &cBrwOrder ) )
   ENDIF
   
   mxDoMethod( ::cName, "Center" )
   mxDoMethod( ::cName, "Show" )

RETURN( NIL )



METHOD Activate() CLASS mxWForm  // Acoes tomadas ao ativar o formulario

   IF _IsControlDefined( BRW_MAIN, ::cName )
      _SetFocus( BRW_MAIN, ::cName )
   ENDIF

   mxDoMethod( ::cName, "Center" )
   mxDoMethod( ::cName, "SetFocus" )
   mxDoMethod( ::cName, "Activate" )

   hb_gcAll()  // Libera memoria

RETURN( NIL )



METHOD OnInit() CLASS mxWForm  // Acoes tomadas ao inicializar o formulario

   IF ::cName <> "frMain"
	   csStatus( "", "frMain" )
	ENDIF

   ::lMaximized := .F. //( ::cName = "frMain" )
   ::aRow       := { GetProperty( ::cName, "Row" ), GetProperty( ::cName, "Row" ) + GetProperty( ::cName, "Height" ) }
   ::aCol       := { GetProperty( ::cName, "Col" ), GetProperty( ::cName, "Col" ) + GetProperty( ::cName, "Width"  ) }

   IF ::cModel = "RPT"
      ShowReport( Application.Handle, GetFormHandle( ::cName ) )
   ENDIF

   SendMessage( GetFormToolTipHandle( ::cName ), TTM_SETMAXTIPWIDTH, 0, 340 ) //370
   SendMessage( GetFormToolTipHandle( ::cName ), TTM_SETDELAYTIME, TTDT_AUTOPOP, 20000 )
      
   IF ::bInit <> NIL
      Eval( ::bInit )
   ENDIF

   hb_gcAll()  // Libera memoria

RETURN( NIL )   



METHOD OnGotFocus() CLASS mxWForm  // Acoes tomadas ao receber o foco
	
   LOCAL nCount, nSize

   csStatus( "Restaurando formulário", "frMain" )

   cWFormActive := ::cName

   IF ::cName <> "frMain"
      SetProperty( ::cName, "Title", ::cTitleTop )
   ENDIF

   IF ::aSaveState <> NIL

      FOR nCount := 1 TO Len( ::aSaveState ) -1

         nSize := Len( ::aSaveState[ nCount ] )

         IF dbIsOpen( ::aSaveState[ nCount, 1 ] )
            ( ::aSaveState[ nCount, 1 ] )->( mxDbSetFilter( ::aSaveState[ nCount, nSize ] ) )
         ENDIF

      NEXT

      IF _IsControlDefined( "oTabPage", ::cName ) .AND. GetProperty( ::cName, "oTabPage", "Value" ) = WF_PG_LISTA
         mxBrwObj( BRW_MAIN ):Refresh(.T.)
      ENDIF

      RestState( ::aSaveState, .T., .T., .F., .F. )

      ::aSaveState := NIL

   ENDIF

	csStatus( "", "frMain" )
	csStatus( "" )

   IF _IsWindowDefined( "HBPREVIEW" ) .AND. IsWindowVisible( GetFormHandle( "HBPREVIEW" ) )
      ShowReport( GetFormHandle( "HBPREVIEW" ), 0 )
   ENDIF

   IF ::bGotFocus <> NIL
      Eval( ::bGotFocus )
   ENDIF

RETURN( NIL )



METHOD OnLostFocus() CLASS mxWForm  // Acoes tomadas ao perder o foco

   LOCAL nCount, nSize

   IF ::cName <> "frMain"

      SetProperty( ::cName, "Title", ::cTitleTop + " - [" + Trim( ::cTitle ) + "]" )

      IF oWConfig:Form_Exclusive

         ::aSaveState := NIL

      ELSE
      
         ::aSaveState := SaveState()

         FOR nCount := 1 TO Len( ::aSaveState ) -1

            nSize := Len( ::aSaveState[ nCount ] ) +1

            aSize( ::aSaveState[ nCount ], nSize )

            ::aSaveState[ nCount, nSize ] := ( ::aSaveState[ nCount, 1 ] )->( dbFilter() )

         NEXT

      ENDIF

   ENDIF

   IF ::bLostFocus <> NIL
      Eval( ::bLostFocus )
   ENDIF

RETURN( NIL )



METHOD OnRelease() CLASS mxWForm  // Acoes tomadas ao fechar o formulario
	
   LOCAL nPos := aScan( aWFormOpen, { |x| x[1] = ::cName } )

   IF ::bRelease <> NIL
      Eval( ::bRelease )
   ENDIF

   IF nPos > 0
      IF aWFormOpen[ nPos, 2 ]  // Modo exclusivo
         mxCloseAll()
      ENDIF
      aDelPos( aWFormOpen, nPos )
   ENDIF

	cWFormActive := "frMain"

   IF Len( aWFormOpen ) = 1
      mxCloseAll()
   ENDIF

   hb_gcAll()  // Libera memoria

RETURN( NIL )



METHOD OnMove() CLASS mxWForm  // Acoes tomadas ao mover o formulario
	
   LOCAL nForm, nRow, nCol, nSize, lUpd, lResize

   LOCAL nRowBeginM, nColBeginM, nRowEndM, nColEndM
   LOCAL nRowBeginC, nColBeginC, nRowEndC, nColEndC

	IF _lPauseMove
      RETURN( NIL )
   ENDIF
    
   IF ! _IsWindowDefined( "frMain" )
      RETURN( NIL )
   ENDIF

   lMain := ( ::cName = "frMain" )
   lExit := .F.

   nRow  := oWFMain:aRow[1]
   nCol  := oWFMain:aCol[1]
   nSize := oWFMain:nWidth

	::nHeight := GetProperty( ::cName, "Height" )
   ::nWidth  := GetProperty( ::cName, "Width"  )

   ::aRow := { GetProperty( ::cName, "Row" ), GetProperty( ::cName, "Row" ) + GetProperty( ::cName, "Height" ) }
   ::aCol := { GetProperty( ::cName, "Col" ), GetProperty( ::cName, "Col" ) + GetProperty( ::cName, "Width"  ) }

   nRow -= oWFMain:aRow[1]
   nCol -= oWFMain:aCol[1]

   lResize := ( oWFMain:nWidth <> nSize )
   
   IF lMain
		IF lResize
         IF nSize < 1024 .OR. oWFMain:nWidth < 1024  // Minimizado
            RETURN( NIL )
         ENDIF
         oWFMain:lMaximized := ( oWFMain:nWidth > nSize )
      ENDIF
      _lPauseMove := .T.
   ENDIF

   FOR nForm := 1 TO Len( aWFormOpen )

      cForm := aWFormOpen[ nForm, 1 ]

      IF cForm = "frMain"
         LOOP
      ENDIF

      // Coordenadas da janela filha (Child)

      nRowBeginC := mxWFObj( cForm ):aRow[1]
      nColBeginC := mxWFObj( cForm ):aCol[1]
      nRowEndC   := mxWFObj( cForm ):aRow[2]
      nColEndC   := mxWFObj( cForm ):aCol[2]

      IF lMain .AND. ( ! lResize )

         nRowBeginC -= nRow
         nColBeginC -= nCol

         SetProperty( cForm, "Row", nRowBeginC )
         SetProperty( cForm, "Col", nColBeginC )

      	mxWFObj( cForm ):nHeight := GetProperty( cForm, "Height" )
         mxWFObj( cForm ):nWidth  := GetProperty( cForm, "Width"  )

		   mxWFObj( cForm ):aRow := { GetProperty( cForm, "Row" ), GetProperty( cForm, "Row" ) + GetProperty( cForm, "Height" ) }
		   mxWFObj( cForm ):aCol := { GetProperty( cForm, "Col" ), GetProperty( cForm, "Col" ) + GetProperty( cForm, "Width"  ) }

      ELSE

         // Coordenadas da janela principal (Main)

         nRowBeginM := oWFMain:aRow[1]
         nColBeginM := oWFMain:aCol[1]
         nRowEndM   := oWFMain:aRow[2]
         nColEndM   := oWFMain:aCol[2]

         lUpd := .F.

         IF nRowBeginC <  nRowBeginM
            nRowBeginC := nRowBeginM
            lUpd       := .T.
         ENDIF

			IF ! oWFMain:lMaximized

				IF nRowEndC > nRowEndM
               nRowBeginC := nRowEndM - mxWFObj( cForm ):nHeight
               lUpd       := .T.
            ENDIF

            IF nColBeginC <  nColBeginM
               nColBeginC := nColBeginM
               lUpd       := .T.
            ELSEIF nColEndC > nColEndM
               nColBeginC :=  nColEndM - mxWFObj( cForm ):nWidth
               lUpd       := .T.
            ENDIF

         ENDIF

         IF lUpd

      		SetProperty( cForm, "Row", nRowBeginC )
            SetProperty( cForm, "Col", nColBeginC )

            mxWFObj( cForm ):nHeight := GetProperty( cForm, "Height" )
            mxWFObj( cForm ):nWidth  := GetProperty( cForm, "Width"  )

      	   mxWFObj( cForm ):aRow := { GetProperty( cForm, "Row" ), GetProperty( cForm, "Row" ) + GetProperty( cForm, "Height" ) }
	   	   mxWFObj( cForm ):aCol := { GetProperty( cForm, "Col" ), GetProperty( cForm, "Col" ) + GetProperty( cForm, "Width"  ) }

            lExit := .T.
            
         ENDIF

      ENDIF

   NEXT

	IF lMain
      _lPauseMove := .F.
   ELSEIF lExit
      mxPressMouse( WM_MOUSE_LEFT, WM_MOUSE_UP )
   ENDIF

RETURN( NIL )



METHOD OnMinimize() CLASS mxWForm  // Acoes tomadas ao minimizar o formulario

	//_HideWindow( ::cName )

   IF ::bMinimize <> NIL
      Eval( ::bMinimize )
   ENDIF

RETURN( NIL )

// EndClass: mxWForm



PROCEDURE mxWFDefScreen( ;           // Define e monta opcoes de tela
                         aToolBar,;  // Array com as opções da barra de tarefas
                         lStatus,;   // Se TRUE define a barra de status
                         lEsc ;      // Se TRUE permite utilizar o ESC p/ fechar paginas/formulario
                       )
                       
	#define ATB_NKEY  1
	#define ATB_CKEY  2
	#define ATB_COPC  3
	#define ATB_CMSG  4
	#define ATB_LCND  5
	#define ATB_CBTN  6

   #define Empty_CKEY( cKey )  ( Empty( cKey ) .OR. Left( cKey, 1 ) = "|" )

	LOCAL cName, cNameItem, cCol, aAux, lBtOpc, lBtImp
	LOCAL nCount, nMenu, nSepar, nCol, nBtAux

   PRIV cFuncKey := mxWFObj():GetFunc( "BrwKeys" )  // Funcao q ira controlar as acoes dos botoes
	PRIV cAction

	vDef( @lStatus, .T. )
   vDef( @lEsc   , .T. )

   nCol := If( mxWFObj():cModel = "RPT", 1, 2 )
   
   DEFINE GETBOX edSetFocus  // Alternativa utilizada p/ posicionar o cursor
      ROW         -1
      COL         -1
      WIDTH       0
      HEIGHT      0
      VALUE       ""
      INVISIBLE   .F.
      NOTABSTOP   .T.
   END GETBOX

   DEFINE LABEL lbTitleBack  // Texto com titulo do modulo acessado
      ROW         00
      COL         00
      VALUE       ""
		WIDTH       mxWFObj():nWidth
		HEIGHT      26
      TRANSPARENT .F.
		BACKCOLOR   oWConfig:Color_PageBack
   END LABEL

   IF _IsControlDefined( "oTabPage", mxWFObj():cName )
      nCount := Int( mxWFObj():nWidth / 2 ) +20
   ELSE
      nCount := mxWFObj():nWidth
   ENDIF

   DEFINE LABEL lbTitle  // Texto com titulo do modulo acessado
      ROW         01
      COL         00
      VALUE       "  " + mxWFObj():cTitle
		TOOLTIP     mxWFObj():cTitle
		WIDTH       nCount
		HEIGHT      25
      TRANSPARENT .F.
		BACKCOLOR   oWConfig:Color_PageBack
		FONTCOLOR   oWConfig:Color_PageTitle
		FONTNAME    oWConfig:FontName_Label
		FONTSIZE    12
   END LABEL

   IF mxWFObj():cModel = "RPT"

      // Nada a fazer.

   ELSEIF _IsControlDefined( "oTabPage", mxWFObj():cName )

		DEFINE LABEL lbTitleOper // Texto com titulo da operacao executada
	      ROW         01
	      COL         Int( mxWFObj():nWidth / 2 ) +18
	      VALUE       "| " + mxWFObj():PageTitle_cLista + " |  "
			TOOLTIP     mxWFObj():cTitle
			WIDTH       Int( mxWFObj():nWidth / 2 ) -25
			HEIGHT      25
	      TRANSPARENT .F.
	      CLIENTEDGE  .F.
	      RIGHTALIGN  .T.
	      BACKCOLOR   oWConfig:Color_PageBack
	      FONTCOLOR   oWConfig:Color_PageOper
			FONTNAME    oWConfig:FontName_Label
			FONTSIZE    12
	   END LABEL

   ELSEIF _IsControlDefined( "oBtOk", mxWFObj():cName )
   
      SetProperty( mxWFObj():cName, "oBtOk", "Row", mxWFObj():nHeight -88 )
      SetProperty( mxWFObj():cName, "oBtNo", "Row", mxWFObj():nHeight -88 )
      
   ENDIF

	IF mxWFObj():cModel = "RPT"

	    mxWFImage()

	ELSEIF aToolBar <> NIL  // Monta a barra superior de botoes

		cName := mxWFObj():cPanelTBar

		DEFINE WINDOW &cName ;
	      AT         26, -1 ;
	      WIDTH      mxWFObj():nWidth ;
			HEIGHT     30 ;
	      BACKCOLOR  oWConfig:Color_Form ;
	      WINDOWTYPE PANEL

			IF ValType( aToolBar[ 1, ATB_NKEY ] ) = "C"

	         cCol := aToolBar[ 1, ATB_NKEY ] + "|"
	         aAux := aClone( aToolBar )

				aToolBar := {}

	         DO WHILE Len( cCol ) > 0

	            cKey := Left( cCol, At( "|", cCol ) -1 )
	            cCol := Subs( cCol, At( "|", cCol ) +1 )

	            nCount := aScan( aAux, { |a| a[ ATB_CKEY ] = cKey }, 2 )

	            DO CASE
	               CASE nCount > 0
	                    aAdd( aToolBar, aAux[ nCount ] )
	                    aDelPos( aAux, nCount )
	               CASE cKey = "+"   ; aAdd( aToolBar, { K_INCLUIR  , "+"  , "Inclui"    , "Inclui nov" + aAux[ 1, 2 ]                   , Len( aAux[1] ) = 2 .OR. aAux[ 1, 3 ], "bt_inclui"   } )
				      CASE cKey = "*"   ; aAdd( aToolBar, { K_ALTERAR  , "*"  , "Altera"    , "Altera dados d" + aAux[ 1, 2 ]               , Len( aAux[1] ) = 2 .OR. aAux[ 1, 3 ], "bt_altera"   } )
	               CASE cKey = "-"   ; aAdd( aToolBar, { K_EXCLUIR  , "-"  , "Exclui"    , "Exclui "  + LTrim( Subs( aAux[ 1, 2 ], 3 ) ) , Len( aAux[1] ) = 2 .OR. aAux[ 1, 3 ], "bt_exclui"   } )
	               CASE cKey = "C"   ; aAdd( aToolBar, { K_EXCLUIR  , "-"  , "Cancela"   , "Cancela " + LTrim( Subs( aAux[ 1, 2 ], 3 ) ) , Len( aAux[1] ) = 2 .OR. aAux[ 1, 3 ], "bt_exclui"   } )
	               CASE cKey = "SPC" ; aAdd( aToolBar, { K_CONSULTAR, "SPC", "Consulta"  , "Consulta dados d" + aAux[ 1, 2 ]             , .T.                                 , "bt_consulta" } )
	               CASE cKey = "F4"  ; aAdd( aToolBar, { K_F4       , "F4" , "Muda ordem", "Muda a disposição dos dados na lista"        , .T.                                 , "bt_ordem"    } )
	               CASE cKey = "F10" ; aAdd( aToolBar, { K_F10      , "F10", "Impressões", "Permite acessar menu com opções de impressão", .T.                                 , "bt_imprime"  } )
	            ENDCASE

	         ENDDO

	         aDelPos( aAux, 1 )
				aAppend( aToolBar, aAux )

	      ENDIF

         nCount := 1

         DO WHILE nCount <= Len( aToolBar )

            aSize( aToolBar[ nCount ], ATB_CBTN )
            
            IF aToolBar[ nCount, ATB_LCND ] = NIL
               aToolBar[ nCount, ATB_LCND ] := .T.
            ENDIF

            IF aToolBar[ nCount, ATB_LCND ]
               nCount ++
            ELSE
               aDelPos( aToolBar, nCount )
            ENDIF

         ENDDO

         nSepar := aScan( aToolBar, { |a| Empty_CKEY( a[ ATB_CKEY ] ) } )

			lBtOpc := ( aScan( aToolBar, { |a| Empty_CKEY( a[ ATB_CKEY ] ) } ) > 0 )
			lBtImp := ( aScan( aToolBar, { |a| a[ ATB_CKEY ] = "IMP"  } ) > 0 )

			nBtAux := If( lBtOpc, 1, 0 ) + If( lBtImp, 1, 0 )

			aEval( aToolBar, { |a| If( ( Len( a ) < ATB_LCND .OR. a[ ATB_LCND ] ) .AND. ! Empty_CKEY( a[ ATB_CKEY ] ) .AND. ! foundStr( a[ ATB_CKEY ], "_|IMP|IMP_" ), nBtAux ++, NIL ) } )

			nCol := ( 4 + nBtAux ) * 26 + 12 + If( lBtOpc, 17, 0 ) + If( lBtImp, 17, 0 ) - nBtAux

         IF mxWFObj():GetFunc( "BrwSeek" ) <> NIL

            DEFINE LABEL lbSearch  // Texto da pesquisa na barra superior
	            ROW       8
	            COL       nCol
	            VALUE     "Pesquisar"
	      		AUTOSIZE  .T.
               FONTNAME  oWConfig:FontName_GetLabel
               FONTSIZE  oWConfig:FontSize_GetLabel
	      		FONTCOLOR oWConfig:Color_GetLabel
	      		BACKCOLOR oWConfig:Color_Form
	         END LABEL

	   		DEFINE GETBOX edSearch  // Digitacao da informacao a ser pesquisada no browse
	            ROW          6
	            COL          nCol +64
	            WIDTH        180
	            HEIGHT       20
	            VALUE        Space(200)
	            TOOLTIP      "Informação a ser pesquisada"
	            MESSAGE      "Informação a ser pesquisada"
	            NOTABSTOP    .T.
               FONTNAME     oWConfig:FontName_Get
               FONTSIZE     oWConfig:FontSize_Get
               FONTCOLOR    oWConfig:Color_GetFont
	   			BACKCOLOR    oWConfig:Color_GetBack
               ON GOTFOCUS  _PushKey( VK_HOME )
               ON LOSTFOCUS SetProperty( mxWFObj():cPanelTBar, "edSearch", "Value", Space(200) )
					ON CHANGE    mxBrwSearch()
	         END GETBOX

			ENDIF

         DEFINE TOOLBAREX oToolBar BUTTONSIZE 25, 25 FLAT TOOLBARSIZE Int( nCol / 3 )

				BUTTON oBtTop  TOOLTIP "Início do cadastro" PICTURE imgFile( "bt_primeiro" ) ACTION mxWFBtArrow()
				BUTTON oBtPrev TOOLTIP "Registro anterior"  PICTURE imgFile( "bt_anterior" ) ACTION mxWFBtArrow()
			   BUTTON oBtNext TOOLTIP "Próximo registro"   PICTURE imgFile( "bt_proximo"  ) ACTION mxWFBtArrow()
			   BUTTON oBtEnd  TOOLTIP "Final do cadastro"  PICTURE imgFile( "bt_ultimo"   ) ACTION mxWFBtArrow() SEPARATOR

			   nBtAux := 0

				FOR nCount := 1 TO Len( aToolBar )

					IF aToolBar[ nCount, ATB_CBTN ] = NIL
					   IF Upper( aToolBar[ nCount, ATB_COPC ] ) = "IMPRIME"
					      aToolBar[ nCount, ATB_CBTN ] := "bt_imprime"
					   ELSE
					      aToolBar[ nCount, ATB_CBTN ] := ""
					   ENDIF
					ENDIF

				   cName := "oBt" + StrZero( ++ nBtAux, 2 ) + "_TB"

					lBtOpc := Empty_CKEY( aToolBar[ nCount, ATB_CKEY ] )
					lBtImp := ( aToolBar[ nCount, ATB_CKEY ] = "IMP" )

               IF lBtOpc .OR. lBtImp

				      IF lBtOpc
							BUTTON &cName TOOLTIP "Opções diversas"     PICTURE imgFile( "bt_opcoes" )  WHOLEDROPDOWN SEPARATOR
						ELSE
							BUTTON &cName TOOLTIP "Opções de impressão" PICTURE imgFile( "bt_imprime" ) WHOLEDROPDOWN SEPARATOR
						ENDIF

                  DEFINE DROPDOWN MENU BUTTON &cName

							DO WHILE ( nCount <= Len( aToolBar ) ) .AND. If( lBtOpc, Empty_CKEY( aToolBar[ nCount, ATB_CKEY ] ), aToolBar[ nCount, ATB_CKEY ] = "IMP" )
							
                        IF ( ! Empty( aToolBar[ nCount, ATB_CMSG ] ) ) .AND. ;
                           ( ! Empty( aToolBar[ nCount, ATB_CKEY ] ) ) .AND. ;
                           ( ! lBtImp )

                           aToolBar[ nCount, ATB_CMSG ] := "[ " + StrTran( aToolBar[ nCount, ATB_CKEY ], "|", "" ) + " ]  " + aToolBar[ nCount, ATB_CMSG ]

                        ENDIF

                        cNameItem := cName + "_" + StrZero( nCount, 3 )
                        
                        cAction := cFuncKey + "(" + NumToStr( aToolBar[ nCount, ATB_NKEY ] ) + ")"

								MENUITEM aToolBar[ nCount, ATB_COPC ] ACTION &cAction MESSAGE aToolBar[ nCount, ATB_CMSG ] NAME &cNameItem

                        IF Right( aToolBar[ nCount, ATB_CKEY ], 1 ) = "_"
								   SEPARATOR
					         ENDIF

								nCount ++

							ENDDO

						END MENU

						nCount --

					ELSE

                  IF ( ! Empty( aToolBar[ nCount, ATB_CMSG ] ) ) .AND. ;
                     ( ! Empty( aToolBar[ nCount, ATB_CKEY ] ) )

                     aToolBar[ nCount, ATB_CMSG ] := "[ " + StrTran( aToolBar[ nCount, ATB_CKEY ], "|", "" ) + " ]  " + aToolBar[ nCount, ATB_CMSG ]

                  ENDIF

                  IF aToolBar[ nCount, ATB_NKEY ] = K_F4
	 			         cAction := "_PushKey(" + NumToStr( VK_F4 ) + ")"
						ELSE
						   cAction := cFuncKey + "(" + NumToStr( aToolBar[ nCount, ATB_NKEY ] ) + ")"
						ENDIF

						IF mxIn( nCount, { nSepar -1, Len( aToolBar ) } )
	  					   BUTTON &cName TOOLTIP aToolBar[ nCount, ATB_CMSG ] PICTURE imgFile( aToolBar[ nCount, ATB_CBTN ] ) ACTION ( _SetFocus( BRW_MAIN, mxWFObj():cName ), &cAction ) SEPARATOR
	  					ELSE
							BUTTON &cName TOOLTIP aToolBar[ nCount, ATB_CMSG ] PICTURE imgFile( aToolBar[ nCount, ATB_CBTN ] ) ACTION ( _SetFocus( BRW_MAIN, mxWFObj():cName ), &cAction )
						ENDIF

					ENDIF

				NEXT

			END TOOLBAR
			
         IF lStatus

      		DEFINE STATUSBAR
      		END STATUSBAR

            DEFINE TIMER tmrToolBar ;
               OF       &cName ;
      		   INTERVAL 200 ;
      		   ACTION   mxWFStatusToolBar()

            SetProperty( mxWFObj():cPanelTBar, "StatusBar", "Visible", .F. )
            
         ENDIF

      END WINDOW

	ENDIF

	IF lStatus  // Monta a barra de status

      DEFINE STATUSBAR FONT oWConfig:FontName_StatusBar SIZE oWConfig:FontSize_StatusBar
         STATUSITEM "" DEFAULT
      END STATUSBAR

   ENDIF

	IF lEsc  // Permite utilizar o ESC p/ fechar as paginas e/ou o formulario
	   ON KEY ESCAPE ACTION mxWFOnKeyESC()
	ENDIF
	
	ON KEY SHIFT+PRIOR ACTION mxWFBtArrow( "Prev" )
	ON KEY SHIFT+NEXT  ACTION mxWFBtArrow( "Next" )
	ON KEY CONTROL+TAB ACTION mxWFNextPage()

RETURN( NIL )



STATIC PROCEDURE mxWFStatusToolBar

   LOCAL cStatusForm, cStatusTool
   
   IF _IsWindowDefined( mxWFObj():cPanelTBar ) .AND. _IsControlDefined( "StatusBar", mxWFObj():cPanelTBar )

      cStatusForm := GetProperty( mxWFObj():cName     , "StatusBar", "Item", 1 )
      cStatusTool := GetProperty( mxWFObj():cPanelTBar, "StatusBar", "Item", 1 )

      IF cStatusForm = cStatusTool
         SetProperty( mxWFObj():cPanelTBar, "StatusBar", "Item", 1, "" )
      ELSEIF ! Empty( cStatusTool )
         SetProperty( mxWFObj():cName, "StatusBar", "Item", 1, cStatusTool )
      ENDIF

   ENDIF
   
RETURN( NIL )



STATIC PROCEDURE mxWFBtArrow( cBtName )  // Acoes dos botoes de setas de movimentacao - (inicio/anterior/proximo/fim)

	LOCAL nPage := GetProperty( mxWFObj():cName, "oTabPage", "Value" )

   PRIV cFuncKey := mxWFObj():GetFunc( "BrwKeys" )

   IF cBtName = NIL
      cBtName := Subs( This.Name, 4 )
   ENDIF

   DO CASE
	   CASE cBtName = "Top"  ; mxBrwObj():GoTop() ; mxBrwReturn( mxWFObj():cName )
	   CASE cBtName = "Prev" ; mxBrwObj():GoUp()
	   CASE cBtName = "Next" ; mxBrwObj():GoDown()
	   CASE cBtName = "End"  ; mxBrwObj():GoBottom() ; mxBrwReturn( mxWFObj():cName )
	ENDCASE

	IF nPage = WF_PG_FICHA
	
      IF cFuncKey = NIL
         SetWVars( NIL, .T. )
      ELSE
         &cFuncKey( K_CONSULTAR )
      ENDIF
      
   ELSEIF nPage = WF_PG_MAPA
   
		/*
      IF GetProperty( mxWFObj():cName, "oTabPage", "Caption", nPage ) = mxWFObj():PageTitle_cMapa
		   mxMapSetVars( mxWFObj():cName, mxWFObj():cAlias )
		ENDIF
		*/
		
	ENDIF

RETURN( NIL )



PROCEDURE mxWFImage  // Define/exibe a imagem de identificacao no formulario

   LOCAL cName, cImage, nRow, nWidth, nHeight
	
	BEGIN SEQUENCE
	
	   IF ! mxWFObj():lUseImage
	      BREAK
      ENDIF
	
		cName := Upper( Right( mxWFObj():cName, 3 ) )
		
		nWidth := mxWFObj():nImageWidth
		
      DO CASE
		   CASE mxWFObj():cModel = "RPT" ; nHeight := 201
         CASE cName = "MAP"            ; nHeight := 430
		   OTHERWISE                     ; nHeight := mxWFObj():Page_nHeight -24
		ENDCASE		
		
		cImage := imgFile( "scr_" + cName )
		
		IF ! File( cImage )
		   BREAK
      ENDIF
      
		nRow := If( mxWFObj():cModel = "RPT", 38, 23 )
      
		cName := "imForm" + cName
		
		DEFINE IMAGE &cName
		   ROW     nRow
		   COL     mxWFObj():nWidth - nWidth
		   PICTURE cImage
		   WIDTH   nWidth
		   HEIGHT  nHeight
		   STRETCH .F.
		END IMAGE
		
      nRow += nHeight
      
      IF mxWFObj():cModel = "RPT"
         nHeight := mxWFObj():nHeight - nHeight
      ELSE   
         nHeight := mxWFObj():Page_nHeight -24 - nHeight
      ENDIF   
		
      DEFINE IMAGE &( cName + "F" )
		   ROW     nRow
		   COL     mxWFObj():nWidth - nWidth
		   PICTURE imgFile( "fundo" )
		   WIDTH   nWidth
		   HEIGHT  nHeight
		   STRETCH .T.
		END IMAGE		
		
	END SEQUENCE

RETURN( NIL )



PROCEDURE mxWFButtons( ;       // Define os botoes de confirmacao
                       nRow ;  // Linha
                     )

   IF mxWFObj():cModel = "RPT"

      DEFINE BUTTONEX oBtOk
	      ROW      mxWFObj():nHeight -88
  		   COL      mxWFObj():nWidth -228
         WIDTH    104
	      HEIGHT   30
	      CAPTION  "Confirmar"
	      TOOLTIP  "Gera relatório"
	      FONTNAME oWConfig:FontName_Button
	      FONTSIZE oWConfig:FontSize_Button
	      PICTURE  imgFile( "bt_ok" )
	      ACTION   mxWFBtConf( .T. )
	   END BUTTONEX
	   
	   DEFINE BUTTONEX oBtNo
	      ROW      mxWFObj():nHeight -88
  		   COL      mxWFObj():nWidth -118
         WIDTH    104
	      HEIGHT   30
	      CAPTION  "Cancelar"
	      TOOLTIP  "Cancela operação"
	      FONTNAME oWConfig:FontName_Button
	      FONTSIZE oWConfig:FontSize_Button
	      PICTURE  imgFile( "bt_no" )
	      ACTION   mxDoMethod( mxWFObj():cName, "Release" )
	   END BUTTONEX

	ELSE

      vDef( @nRow, mxWFObj():Page_nHeight -38 )

		DEFINE BUTTONEX oBtOk
	      ROW      nRow
	      COL      mxWFObj():BtOk_nCol
	      WIDTH    100
	   	HEIGHT   27
	      CAPTION  "Confirmar"
	      TOOLTIP  "Confirma operação"
	      FONTNAME oWConfig:FontName_Button
	      FONTSIZE oWConfig:FontSize_Button
	      PICTURE  imgFile( "bt_ok" )
	     	ACTION   mxWFBtConf( .T. )
	   END BUTTONEX
	
	   DEFINE BUTTONEX oBtNo
	      ROW      nRow
	      COL      mxWFObj():BtNo_nCol
	      WIDTH    100
	      HEIGHT   27
	      CAPTION  "Cancelar"
	      TOOLTIP  "Cancela operação"
	      FONTNAME oWConfig:FontName_Button
	      FONTSIZE oWConfig:FontSize_Button
	      PICTURE  imgFile( "bt_no" )
	      ACTION   mxWFBtConf( .F. )
	   END BUTTONEX

	ENDIF

RETURN( NIL )



PROCEDURE mxWFBtConf( ;        // Acoes tomadas ao clicar nos botoes de confirmacao
                      lConf ;  // TRUE = Botao "Confirmar" / FALSE = Botao "Cancelar"
                    )
                    
   PRIV cFuncConf := mxWFObj():GetFunc( "BtConf" )

   IF mxWFObj():cModel = "RPT" .AND. lConf
      csStatus( "Aguarde, selecionando dados..." )
   ENDIF   
   
   IF cFuncConf = NIL .OR. ;
      Type( cFuncConf + "()" ) = "U" .OR. ; // Funcao inexistente
      vDef( &cFuncConf( lConf ), .T. )

      IF _IsControlDefined( "oTabPage", mxWFObj():cName )
         mxSetValue( "oTabPage", WF_PG_LISTA )
      ELSE
         mxDoMethod( mxWFObj():cName, "Release" )
      ENDIF

   ENDIF

RETURN( NIL )



PROCEDURE mxWFCadastro( ;         // Inicia a exibicao/edicao do cadastro (Muda p/ a pagina "Ficha de cadastro")
                        nEvent,;  // Tecla pressionada
                        cTitle,;  // Titulo a ser exibido (Se NIL ira exibir o titulo padrao da tecla)
                        aDescr ;  // Campos q terao as descricoes exibidas
                      )

   LOCAL nCount

   IF cTitle = NIL .OR. Left( cTitle, 1 ) = "|"

      IF cTitle = NIL
         cTitle := StrTran( mxWFObj():cTitle, "Cadastro de ", "" )
      ELSE
         cTitle := Subs( cTitle, 2 )
      ENDIF

   	DO CASE
         CASE nEvent = K_INCLUIR   ; cTitle := "Inclusão de "  + Lower( cTitle )
         CASE nEvent = K_ALTERAR   ; cTitle := "Alteração de " + Lower( cTitle )
         CASE nEvent = K_EXCLUIR   ; cTitle := "Exclusão de "  + Lower( cTitle )
         CASE nEvent = K_CONSULTAR ; cTitle := "Consulta de "  + Lower( cTitle )
         OTHERWISE                 ; cTitle := mxWFObj():cTitle
      ENDCASE

   ENDIF

   SetProperty( mxWFObj():cName, "oBtNo", "Visible", .F. )
   
   IF nEvent = K_CONSULTAR
      SetProperty( mxWFObj():cName, "oBtOk", "Col"    , mxWFObj():BtNo_nCol )
   ELSE
      SetProperty( mxWFObj():cName, "oBtOk", "Col"    , mxWFObj():BtOk_nCol )
      SetProperty( mxWFObj():cName, "oBtNo", "Visible", .T. )
   ENDIF

   mxWFObj():lVldGets := .F.
   
   SeleArea( mxWFObj():cAlias )

   IF nEvent = K_INCLUIR
      ResetWVars()
	ELSE
      SetWVars( NIL, mxIn( nEvent, { K_CONSULTAR, K_EXCLUIR } ) )
   ENDIF
   
	IF aDescr <> NIL
	   aEval( aDescr, { |x| mxWGDescricao( x[1], x[2] ) } )
	ENDIF

   IF _IsControlDefined( "oTabPage", mxWFObj():cName )
      mxSetValue( "lbTitleOper", "| " + cTitle + " |  " )
      mxSetValue( "oTabPage"   , WF_PG_FICHA )
   ENDIF

	IF mxIn( nEvent, { K_CONSULTAR, K_EXCLUIR } )
      _SetFocus( If( nEvent = K_CONSULTAR, "oBtOk", "oBtNo" ), mxWFObj():cName )
   ENDIF

   _ProcessMess()

RETURN( NIL )



PROCEDURE mxWFChangePage  // Acoes tomadas na mudanca de pagina

   LOCAL cPage  := This.Name
	LOCAL nPage  := GetProperty( mxWFObj():cName, cPage, "Value" )
	LOCAL nCount := 0

	LOCAL cName, cPageAux, oBrw, lEnabled

	PRIV cFuncKey  := mxWFObj():GetFunc( "BrwKeys" )
	PRIV uFuncStat := mxWFObj():GetFunc( "BrwStat" )
	PRIV cFuncPage := mxWFObj():GetFunc( "TabPage" )

   IF cPage = "oTabPage"

      mxWFObj():lVldGets := .F.

      // Ativa/desativa botoes da barra superior

      lEnabled := ( nPage = WF_PG_LISTA .OR. nEvent = NIL .OR. mxIn( nEvent, { K_CONSULTAR, K_EXCLUIR } ) )

      SetProperty( mxWFObj():cPanelTBar, "oBtTop" , "Enabled", lEnabled )
      SetProperty( mxWFObj():cPanelTBar, "oBtPrev", "Enabled", lEnabled )
      SetProperty( mxWFObj():cPanelTBar, "oBtNext", "Enabled", lEnabled )
      SetProperty( mxWFObj():cPanelTBar, "oBtEnd" , "Enabled", lEnabled )
      
      lEnabled := ( nPage = WF_PG_LISTA )

      DO WHILE .T.
	      cName := "oBt" + StrZero( ++ nCount, 2 ) + "_TB"
		   IF ! _IsControlDefined( cName, mxWFObj():cPanelTBar )
		      EXIT
	      ENDIF
			SetProperty( mxWFObj():cPanelTBar, cName, "Enabled", lEnabled )
		ENDDO

      IF _IsControlDefined( "edSearch", mxWFObj():cPanelTBar )
		   SetProperty( mxWFObj():cPanelTBar, "lbSearch", "Enabled", lEnabled )
			SetProperty( mxWFObj():cPanelTBar, "edSearch", "Enabled", lEnabled )
		ENDIF

	   FOR nCount := 2 TO 3

			cPageAux := cPage + NumToStr( nCount )

         IF _IsControlDefined( cPageAux, mxWFObj():cName )
		      SetProperty( mxWFObj():cName, cPageAux, "Value"  , 1 )
				SetProperty( mxWFObj():cName, cPageAux, "Visible", nPage = WF_PG_FICHA )
		   ENDIF

		NEXT

		SeleArea( mxWFObj():cAlias )

      IF cFuncPage <> NIL
         &cFuncPage( nPage )
      ENDIF

      IF nPage = WF_PG_LISTA
      
         IF _IsControlDefined( BRW_MAIN, mxWFObj():cName )
			   mxBrwObj():UpStable()
			   mxBrwObj():Refresh(.F.)
			   _SetFocus( BRW_MAIN, mxWFObj():cName )
         ENDIF
         
         IF uFuncStat <> NIL
            IF ValType( uFuncStat ) = "C"
               uFuncStat := "{ || " + uFuncStat + "() }"
               uFuncStat := &uFuncStat
            ENDIF
       	   Eval( uFuncStat )
          ENDIF

			nEvent := NIL
			
	   ELSEIF nPage = WF_PG_FICHA

         IF cFuncKey <> NIL
         
            IF ( nEvent = NIL .OR. nEvent = K_CONSULTAR ) .AND. EmptyDb()
               SetProperty( mxWFObj():cName, cPage, "Value", WF_PG_LISTA )
            ELSEIF nEvent = NIL
	            &cFuncKey( K_CONSULTAR )
	         ENDIF
	         
	      ENDIF

      /*
      ELSEIF nPage = WF_PG_MAPA

         IF GetProperty( mxWFObj():cName, "oTabPage", "Caption", nPage ) = mxWFObj():PageTitle_cMapa
			   mxMapSetVars( mxWFObj():cName, mxWFObj():cAlias )
			ENDIF

         nEvent := NIL
		*/

   	ENDIF
		
		IF nPage <> WF_PG_FICHA .AND. _IsControlDefined( "oTabPage", mxWFObj():cName )
		   mxSetValue( "lbTitleOper", "| " + GetProperty( mxWFObj():cName, "oTabPage", "Caption", nPage ) + " |  " )
		ENDIF
   
	ENDIF
	
RETURN( NIL )


STATIC PROCEDURE mxWFNextPage

   LOCAL nPageAtu1, nPageAtu2, nPageMax1, nPageMax2
   
   IF _IsControlDefined( "oTabPage", mxWFObj():cName )
      nPageAtu1 := GetProperty( mxWFObj():cName, "oTabPage", "Value" )
      nPageMax1 := GetProperty( mxWFObj():cName, "oTabPage", "ItemCount" )
   ENDIF

   IF _IsControlDefined( "oTabPage2", mxWFObj():cName )
      nPageAtu2 := GetProperty( mxWFObj():cName, "oTabPage2", "Value" )
      nPageMax2 := GetProperty( mxWFObj():cName, "oTabPage2", "ItemCount" )
   ENDIF

   IF nPageAtu1 <> NIL

      IF nPageAtu1 = WF_PG_LISTA

         mxSetValue( "oTabPage", WF_PG_FICHA )

      ELSEIF nPageAtu1 = WF_PG_FICHA .AND. nPageAtu2 <> NIL
      
         mxSetValue( "oTabPage2", If( nPageAtu2 +1 > nPageMax2, 1, nPageAtu2 +1 ) )

      ELSE

         mxSetValue( "oTabPage", If( nPageAtu1 +1 > nPageMax1, 1, nPageAtu1 +1 ) )

      ENDIF

   ELSEIF nPageAtu2 <> NIL

      mxSetValue( "oTabPage2", If( nPageAtu2 +1 > nPageMax2, 1, nPageAtu2 +1 ) )

   ENDIF

RETURN( NIL )



PROCEDURE mxWFOnKeyESC  // Acoes tomadas ao pressionar a tecla ESC

   IF mxWFObj():bOnKeyESC = NIL .OR. Eval( mxWFObj():bOnKeyESC, ThisWindow.FocusedControl )

      IF mxWFObj():cModel = "RPT"
   	   mxDoMethod( mxWFObj():cName, "Release" )
      ELSEIF ! _IsControlDefined( BRW_MAIN, mxWFObj():cName )
         mxDoMethod( mxWFObj():cName, "Release" )
         _PushKey( 13 )
         Inkey( 0.5 )
      ELSEIF _IsControlDefined( "oTabPage", mxWFObj():cName )
         IF GetProperty( mxWFObj():cName, "oTabPage", "Value" ) = WF_PG_LISTA
            IF ThisWindow.FocusedControl = BRW_MAIN
               mxDoMethod( mxWFObj():cName, "Release" )
            ELSE
               _SetFocus( BRW_MAIN, mxWFObj():cName )
      		ENDIF
         ELSE
            mxWFObj():lVldGets := .F.
            mxSetValue( "oTabPage", WF_PG_LISTA )
      	ENDIF
      ENDIF

   ENDIF
	
RETURN( NIL )



FUNCTION mxWFObj( ;        // Retorna o objeto do formulario
                  cForm ;  // Formulario
                )
   
   vDef( @cForm, cWFormActive )

RETURN( &( "oWF" + Subs( cForm, 3 ) ) )



FUNCTION mxBrwObj( ;        // Retorna o objeto browse do formulario ativo
                   cName ;  // Nome do browse
                 )

   vDef( @cName, "oBrw" + Subs( cWFormActive, 3 ) )

RETURN( mxGetObject( cName, cWFormActive ) )



FUNCTION mxWFActive( ;        // Define/retorna o formulário ativo
                     cForm ;  // Formulario
                   )

   LOCAL cReturn := cWFormActive
   
   IF cForm <> NIL
   
      cWFormActive := cForm

      mxDoMethod( cForm, "Restore" )
      mxDoMethod( cForm, "Show" )
      mxDoMethod( cForm, "SetFocus" )
      
   ENDIF
   
RETURN( cReturn )



FUNCTION mxWFConfClose( cMsg )

   LOCAL lReturn := .F.
   
   vDef( @cMsg, "Confirma encerramento da aplicação?" )
   
   IF Len( aWFormOpen ) = 1 .OR. Len( aWFormOpen ) = 2 .AND. aScan( aWFormOpen, { |x| x[1] = "frWaitTask" } ) > 0
      lReturn := MsgYesNo( cMsg, "Confirmação", .F. )
   ENDIF

RETURN( lReturn )



PROCEDURE mxBtFechar

   IF _IsControlDefined( "oBtOk", mxWFObj():cName )

      csStatus( "" )
      SetProperty( mxWFObj():cName, "oBtOk", "Visible", .F. )
      SetProperty( mxWFObj():cName, "oBtNo", "Enabled", .T. )
      SetProperty( mxWFObj():cName, "oBtNo", "Caption", "Fechar" )
      SetProperty( mxWFObj():cName, "oBtNo", "ToolTip", NIL )

   ENDIF

RETURN( NIL )



FUNCTION isFormOpen( ;           // Verifica se o formulario esta aberto
                     cForm,;     // Formulario
                     lRestore ;  // Se TRUE restaura o formulario p/ primeiro plano
                   )

   LOCAL lReturn := ( aScan( aWFormOpen, { |x| x[1] = cForm } ) > 0 )
   
   vDef( @lRestore, .T. )
   
   hb_gcAll()  // Libera memoria
   
   IF lReturn
      IF lRestore
         mxDoMethod( cForm, "Restore" )
         mxDoMethod( cForm, "Show" )
         mxDoMethod( cForm, "SetFocus" )
      ENDIF
   ELSEIF aScan( aWFormOpen, { |x| x[2] } ) > 0
      MsgStop( "Atenção, um módulo está aberto em modo exclusivo!", MSG_TITLE )
      lReturn := .T.
   ELSEIF oWConfig:Form_Exclusive
      lReturn := ( ! FormExclusiveMode( .F. ) )
   ENDIF

RETURN( lReturn )



FUNCTION FormExclusiveMode( ;       // Verifica se o formulario pode ser aberto em modo exclusivo
                            lMsg ;  // Se TRUE exibe a mensagem de advertencia
                          )

   LOCAL lReturn := .T.

   IF Len( aWFormOpen ) = 2 .AND. aScan( aWFormOpen, { |x| x[1] = "frWaitTask" } ) > 0
   
      // Nada a fazer.

   ELSEIF Len( aWFormOpen ) > 1

      vDef( @lMsg, .F. )

      IF lMsg

         MsgStop( "Atenção, este processo requer acesso exclusivo!" + _NL + _NL + ;
                  "Feche os demais módulos antes de prosseguir.", MSG_TITLE )

      ENDIF

      lReturn := .F.
      
   ENDIF

RETURN( lReturn )



FUNCTION FormFullMode( lFullMode )

   LOCAL lReturn := _lFormFullMode

   IF lFullMode <> NIL
      _lFormFullMode := lFullMode
   ENDIF

RETURN( lReturn )