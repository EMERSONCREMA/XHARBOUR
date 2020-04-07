/*

 MaxWCfg.prg
 WinConfig Class: Configuracoes gerais do sistema.

 DENIS MAZZUCATTO RODRIGUES
 02/12/15 * Implementacao de Color_BrwTitleOrder.
 25/09/13 * Implementacao de Form_Exclusive.
 05/09/13 * Implementacao de Form_TitleTop e Form_ImagePath.
 06/08/13 * Implementacao de FontName_StatusBar e FontSize_StatusBar.
 03/11/10 * Inicio do desenvolvimento.

*/

#include "minigui.ch"
#include "hbclass.ch"

// Class: mxWConfig - Configuracoes gerais (cores/fontes).

CLASS mxWConfig

	// Configuracao de cores

	DATA Color_FormBack       // Fundo do formulario principal
	DATA Color_Form           // Fundo dos formularios (sem efeito)
   DATA Color_Page           // Fundo das paginas (sem efeito)
   DATA Color_PageTitle      // Label com o titulo do formulario
   DATA Color_PageOper       // Label da operacao q esta sendo executada
   DATA Color_PageBack       // Fundo do label com o titulo do formulario
   DATA Color_GetLabel       // Label das telas de digitacao
   DATA Color_GetBack        // Fundo do edit
   DATA Color_GetFont        // Fonte do edit
   DATA Color_GetDisabled    // Fonte do edit desabilitado
   DATA Color_Frame          // Fundo do frame (sem efeito)
   DATA Color_Tab            // Fundo do tabpage (sem efeito)

	DATA Color_BrwTitle       // Fonte da barra de titulo das colunas
	DATA Color_BrwTitleOrder  // Fonte da barra de titulo das colunas q permite indexacao
	DATA Color_BrwTitleBack1  // Fundo da barra de titulo das colunas (degrade inicial)
	DATA Color_BrwTitleBack2  // Fundo da barra de titulo das colunas (degrade final)
	DATA Color_BrwGrid        // Linhas do grid
	DATA Color_BrwGridBack    // Fundo do grid
	DATA Color_BrwGridOrder   // Fundo da coluna indexada ativa
	DATA Color_BrwBar1        // Fundo da barra do registro corrente (degrade inicial)
	DATA Color_BrwBar2        // Fundo da barra do registro corrente (degrade final)
	DATA Color_BrwRecGrid     // Fonte dos registros no grid
	DATA Color_BrwRecBar	     // Fonte do registro corrente na barra

	// Configuracao de fontes

	DATA FontName_Page
	DATA FontName_Button
	DATA FontName_GetLabel
	DATA FontName_Get
	DATA FontName_Frame
	DATA FontName_Label
	DATA FontName_Brw
	DATA FontName_StatusBar

	DATA FontSize_Page
	DATA FontSize_Button
	DATA FontSize_GetLabel
	DATA FontSize_Get
	DATA FontSize_Frame
	DATA FontSize_Brw
	DATA FontSize_StatusBar
	
	// Configuracoes gerais
	
	DATA Form_TitleTop
   DATA Form_ImagePath
   DATA Form_Exclusive

	METHOD Create()
	METHOD Load()

ENDCLASS



METHOD Create() CLASS mxWConfig

   // Configuracao de cores

	::Color_FormBack    := { 255, 255, 255 }
	::Color_Form        := { 255, 255, 255 }
   ::Color_Page        := { 255, 255, 255 }
   ::Color_PageTitle   := { 255, 255, 255 }
   ::Color_PageOper    := { 255, 255, 255 }
   ::Color_PageBack    := {  84, 107, 151 }
   ::Color_GetLabel    := {  24,  56, 105 }
   ::Color_GetBack     := { 243, 243, 243 }
   ::Color_GetFont     := {   0,   0,   0 }
   ::Color_GetDisabled := { 117,   0,   0 }
   ::Color_Frame       := { 255, 128,   0 }
   ::Color_Tab         := NIL
	
	::Color_BrwTitle      := RGB(   0,   0,   0 )
	::Color_BrwTitleOrder := RGB(   0,   0, 255 )
	::Color_BrwTitleBack1 := RGB( 177, 211, 255 )
	::Color_BrwTitleBack2 := RGB( 224, 237, 255 )
	::Color_BrwGrid       := RGB( 224, 224, 224 )
	::Color_BrwGridBack   := RGB( 255, 255, 255 )
	::Color_BrwGridOrder  := RGB( 228, 238, 248 )
	::Color_BrwBar1       := RGB( 251, 229, 146 )
	::Color_BrwBar2       := RGB( 239, 152,  25 )
	::Color_BrwRecGrid    := RGB(   6,  41,  85 )
	::Color_BrwRecBar     := RGB(   0,   0,   0 )
   
	// Configuracao de fontes

	::FontName_Page      := "Nina"
	::FontName_Button    := "Nina"
	::FontName_GetLabel  := "Nina"
	::FontName_Get       := "Consolas"
	::FontName_Frame     := "Segoe UI"
	::FontName_Label     := "Segoe UI"
	::FontName_Brw       := "Consolas"
	::FontName_StatusBar := "Nina"
	
	::FontSize_Page      := 10
	::FontSize_Button    := 9
	::FontSize_GetLabel  := 9
	::FontSize_Get       := 9
	::FontSize_Frame     := 8.5
	::FontSize_Brw       := 9
	::FontSize_StatusBar := 9

   // Configuracoes gerais
   
   ::Form_TitleTop  := SISTEMA
   ::Form_ImagePath := "imagens"
   ::Form_Exclusive := .F.

RETURN( Self )



METHOD Load() CLASS mxWConfig

   /*
   LOCAL hIni
	
	IF File( "MXCFGCFI.INI" )
	   
		hIni := HB_ReadIni( "MXCFGCFI.INI" )
	
		::Color_FormBack      := LoadColor( hIni, "FormBack"     , ::Color_FormBack           )
		::Color_Form          := LoadColor( hIni, "Form"         , ::Color_Form               )
	   ::Color_Page          := LoadColor( hIni, "Page"         , ::Color_Page               )
	   ::Color_PageTitle     := LoadColor( hIni, "PageTitle"    , ::Color_PageTitle          ) 	   
	   ::Color_PageOper      := LoadColor( hIni, "PageOper"     , ::Color_PageOper           )	    
	   ::Color_GetLabel      := LoadColor( hIni, "GetLabel"     , ::Color_GetLabel           )
	   ::Color_GetBack       := LoadColor( hIni, "GetBack"      , ::Color_GetBack            )
	   ::Color_GetFont       := LoadColor( hIni, "GetFont"      , ::Color_GetFont            )
	   ::Color_GetDisabled   := LoadColor( hIni, "GetDisabled"  , ::Color_GetDisabled        )
	   ::Color_Frame         := LoadColor( hIni, "Frame"        , ::Color_Frame              )
	   ::Color_Tab           := LoadColor( hIni, "Tab"          , ::Color_Tab                )
		::Color_BrwTitle      := LoadColor( hIni, "BrwTitle"     , ::Color_BrwTitle     , .T. )
		::Color_BrwTitleOrder := LoadColor( hIni, "BrwTitleOrder", ::Color_BrwTitleOrder, .T. )
		::Color_BrwTitleBack1 := LoadColor( hIni, "BrwTitleBack1", ::Color_BrwTitleBack1, .T. )
		::Color_BrwTitleBack2 := LoadColor( hIni, "BrwTitleBack2", ::Color_BrwTitleBack2, .T. )
		::Color_BrwGrid       := LoadColor( hIni, "BrwGrid"      , ::Color_BrwGrid      , .T. )
		::Color_BrwGridBack   := LoadColor( hIni, "BrwGridBack"  , ::Color_BrwGridBack  , .T. )
		::Color_BrwGridOrder  := LoadColor( hIni, "BrwGridOrder" , ::Color_BrwGridOrder , .T. )
		::Color_BrwBar1       := LoadColor( hIni, "BrwBar1"      , ::Color_BrwBar1      , .T. )
		::Color_BrwBar2       := LoadColor( hIni, "BrwBar2"      , ::Color_BrwBar2      , .T. )
		::Color_BrwRecGrid    := LoadColor( hIni, "BrwRecGrid"   , ::Color_BrwRecGrid   , .T. )
		::Color_BrwRecBar     := LoadColor( hIni, "BrwRecBar"    , ::Color_BrwRecBar    , .T. )

	ENDIF
	*/
	
RETURN( NIL )



STATIC FUNCTION LoadColor( hIni, cKey, uColor, lRGB )

   LOCAL uReturn := uColor
	LOCAL aColor
   
	vDef( @lRGB, .F. )
	
	TRY
	   aColor := hIni[ "Colors" ][ cKey ]
	CATCH
	   aColor := NIL
	END
	   
   IF aColor <> NIL
      aColor := &aColor
      IF Len( aColor ) > 0
			IF lRGB
	         uReturn := RGB( aColor[1], aColor[2], aColor[3] )
	      ELSE
	         uReturn := aColor
			ENDIF
	   ENDIF
	ENDIF
   
RETURN( uReturn )

// EndClass: mxWConfig