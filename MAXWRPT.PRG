/*

 MaxWRpt.prg
 WinReport Class: Funcoes p/ geracao de relatorios.

 DENIS MAZZUCATTO RODRIGUES
 23/11/10 * Inicio do desenvolvimento.

*/

#include "minigui.ch"
#include "i_rptgen.ch"
#include "hbclass.ch"
#include "winprint.ch"
#include "Fileio.ch"
#include "maxwin.ch"

#define COL_cTitle     1
#define COL_cImp       2
#define COL_uMasc      3
#define COL_uMascTotal 4
#define COL_nCol       5
#define COL_nWidth     6
#define COL_cAlign     7

#define CPL_nAddRow 1
#define CPL_uCol    2
#define CPL_cImp    3

#define FNT_SUMMARY "Courier New"
#define FNT_DEFAULT "Arial"

Memvar Drv

// Class: mxWReport - Definicoes p/ relatorio.

CLASS mxWReport

   DATA cTitle         // Titulo do relatorio.
   DATA aTitleCpl      // Matriz com dados complementares do titulo - alimentada por AddCplTitle().
   DATA aSummary       // Matriz com dados exibidos no final - alimentada por AddSummary().
   DATA aColumn        // Matriz com as colunas - alimentada por AddColumn().
   DATA aParam         // Parametrizacões do relatorio.
   DATA lTotal         // Define a totalizacao geral.

   DATA nCols          // Número de colunas (80/100/132).
   DATA nColScale      // Escala do tamanho das colunas.
   DATA nColSpace      // Espaco entre colunas.
   DATA lColSpace      // Define se ira distribuir os espacos restantes entre as colunas.

   DATA cGroupExpr     // Expressao p/ formacao dos grupos.
   DATA cGroupHeader   // Titulo do grupo.
   DATA cGroupAlign    // Alinhamento do titulo do grupo.
   DATA bGroupAfter    // Codigo a ser executado antes da exibicao do grupo.
   DATA lGroupTotal    // Define a totalizacao do grupo.
   DATA lGroupSummary  // Define a exibicao do sumario p/ o grupo.

   DATA bFilter        // Condicao p/ filtro dos registros.
   DATA bEnd           // Condicao p/ finalizacao do relatorio.
   
	DATA cFontName      // Nome da fonte padrao.
	DATA nFontSize      // Tamanho da fonte padrao.
   
	METHOD Create()
	METHOD New( cTitle )
	METHOD AddCplTitle( nAddRow, uCol, cImp, lAdd )
   METHOD AddSummary( nAddRow, uCol, cImp, lAdd )
   METHOD AddColumn( cTitle, cImp, uMasc, nTotal, lAdd, uMascTotal )	   
	METHOD Execute( cFilePdf )
   
ENDCLASS



METHOD Create() CLASS mxWReport

	PUBLIC _HMG_RPTDATA := Array( 170 )
	PUBLIC drv          := "H"

	::cFontName := "Helvetica"

RETURN( Self )



METHOD New( cTitle, nCols, aParam ) CLASS mxWReport
   
	vDef( @cTitle, "" )
	vDef( @nCols , 80 )
	vDef( @aParam, {} )

   _HMG_RPTDATA[169] := {}
	
	::cTitle    := CapFirst( StrTran( StrTran( cTitle, "Relatório de ", "" ), "Relatório ", "" ) ) 
	::aTitleCpl := {}
	::aColumn   := {}
	::aSummary  := {}
	::aParam    := aParam
   ::lTotal    := .T.

	::cGroupExpr    := "" 
   ::cGroupHeader  := "''"
   ::cGroupAlign   := "LEFT"
   ::bGroupAfter   := { || .T. }
   ::lGroupTotal   := .T.
   ::lGroupSummary := .F.
   
   ::nCols     := nCols
   ::lColSpace := .T.
   ::nColSpace := 2

   IF nCols = 80
      ::nFontSize := 9
      ::nColScale := 2.395
   ELSEIF nCols = 100
      ::nFontSize := 8
      ::nColScale := 1.896
   ELSE
      ::nFontSize := 7
      ::nColScale := 1.420
   ENDIF

	::bFilter := NIL
	::bEnd    := { || Eof() }

RETURN( NIL )



METHOD AddCplTitle( nAddRow, uCol, cImp, lAdd ) CLASS mxWReport

   vDef( @lAdd, .T. )
   
	aAddC( ::aTitleCpl, { nAddRow, uCol, cImp }, lAdd )   

RETURN( NIL )



METHOD AddSummary( nAddRow, uCol, cImp, lAdd ) CLASS mxWReport

   vDef( @lAdd, .T. )
   
	aAddC( ::aSummary, { nAddRow, uCol, cImp }, lAdd )   

RETURN( NIL )



METHOD AddColumn( cTitle, cImp, uMasc, nTotal, lAdd, uMascTotal ) CLASS mxWReport

   LOCAL cAlign := "LEFT"
   
   vDef( @lAdd      , .T. )
   vDef( @uMascTotal, uMasc )

	IF ValType( uMasc ) = "C"
	   IF uMasc = "CENTER"
	      cAlign := "CENTER"
	      uMasc  := NIL
      ELSEIF uMasc = "LEFT"
         cAlign := "LEFT"
         uMasc  := NIL
      ELSEIF uMasc = "RIGHT"
         cAlign := "RIGHT"
         uMasc  := NIL
      ELSEIF uMasc <> MASK_FONE      
         cAlign := "RIGHT"
      ENDIF
   ENDIF

   IF uMasc = NIL
      uMasc := Len( cTitle )
   ENDIF

   aAddC( ::aColumn, { cTitle,;                               // COL_cTitle
                       cImp  ,;                               // COL_cImp
                       uMasc ,;                               // COL_uMasc
                       If( nTotal = NIL, NIL, uMascTotal ),;  // COL_uMascTotal
                       0,;                                    // COL_nCol
                       0,;                                    // COL_nWidth
                       cAlign ;                               // COL_cAlign
                     }, lAdd )
   
	IF nTotal <> NIL
	   IF ValType( nTotal ) = "C"
         aAddC( _HMG_RPTDATA[169], { Len( ::aColumn ), nTotal + "1", nTotal + "2" }, lAdd )
      ELSE
         aAddC( _HMG_RPTDATA[169], { Len( ::aColumn ), nTotal, nTotal }, lAdd )
      ENDIF 
	ENDIF   

RETURN( NIL )



METHOD Execute( cFilePdf ) CLASS mxWReport
   
   LOCAL lExec
   
   IF cFilePdf = NIL
      FileDelete( GetTempFolder() + "\TEMP*.PDF" )
      cFilePdf := GetTempFolder() + "\TEMP" + DefArqTmp( GetTempFolder(), ".PDF" ) + ".PDF"
   ELSE
      cFilePdf := ModExt( cFilePdf, "pdf" )
      FileDelete( cFilePdf )
   ENDIF
   
   csStatus( "Aguarde, gerando relatório" )
   
   mxWRptDefine()
	
   lExec := ExecuteReport( "csReport", .T., .F., cFilePdf )

   csStatus( "" )   

   IF lExec
      EXECUTE FILE cFilePdf
   ELSE
      csMsgDlg( "Nenhuma informação foi apurada para;a emissão do relatório !" )
   ENDIF

RETURN( NIL )



STATIC PROCEDURE mxWRptDefine()
	
	LOCAL nCount, nLen, nRow, nCol, nHeight, nWidth, nItem, nFont
   LOCAL cAlign, cType, cFont, cVar, uVar

   PRIV cExpr
	
   DEFINE REPORT csReport

		// Report Layout.
	
		BEGIN LAYOUT 
			PAPERSIZE	PRINTER_PAPER_A4
			ORIENTATION	PRINTER_ORIENT_PORTRAIT 
		END LAYOUT

	   // Header Band.

		BEGIN HEADER
		   
         nHeight := 15
 
         IF aScan( oWReport:aColumn, { |x| At( ";", x[ COL_cTitle ] ) > 0 } ) > 0
            nHeight += 3.5
         ENDIF
	
	      IF Len( oWReport:aTitleCpl ) > 0
            nRow := If( oWReport:aTitleCpl[ 1, CPL_nAddRow ] = 0, 1, 0 )
            aEval( oWReport:aTitleCpl, { |x| nRow += x[ CPL_nAddRow ] } )
            nHeight += ( nRow * 5 ) +3
         ENDIF       
         
         BANDHEIGHT nHeight
	
			mxWRptLine( 16 )
	
			BEGIN TEXT
				EXPRESSION oWReport:cTitle
				ROW		  05
				COL		  10	
				FONTNAME	  oWReport:cFontName
				FONTSIZE	  10
			END TEXT		
			
			BEGIN TEXT
				EXPRESSION "Solução SPED Contribuições · v" + AllTrim( VERSAO )
				ROW		  05	
				COL		  145
				WIDTH		  50	
				FONTNAME	  oWReport:cFontName
				FONTSIZE	  10
				ALIGNMENT  Right
			END TEXT			

			BEGIN TEXT
				EXPRESSION empCNPJ( .T. )
            ROW		  09
				COL		  10
				FONTNAME	  oWReport:cFontName
				FONTSIZE	  8
				ALIGNMENT  Left
			END TEXT
			
			BEGIN TEXT
				EXPRESSION "Página: " + NumToStr( _PageNo )
				ROW		  09
				COL		  151
				WIDTH		  50	
				FONTNAME	  oWReport:cFontName
				FONTSIZE	  8
				ALIGNMENT  Right
			END TEXT			

			nRow := 15
			
			IF ! Empty( oWReport:aTitleCpl )
			   
            mxWRptCpl( oWReport:aTitleCpl, @nRow, 7 )
				
            nRow += 5
            
            mxWRptLine( nRow +2 )
            
            IF oWReport:nCols = 80
               nRow += 0.5
            ENDIF

			ENDIF
	
		   nCol := 10
			nLen := 0
			
         IF oWReport:lColSpace
            aEval( oWReport:aColumn, { |x| nLen += GetNoEmpty( At( ";", x[ COL_cTitle ] ), Len( x[ COL_cTitle ] ) ) } )
   			nLen := oWReport:nCols - nLen
   			nLen -= Len( oWReport:aColumn )
   			nLen := Int( nLen / Len( oWReport:aColumn ) )
   		ENDIF	
        
         FOR nCount := 1 TO Len( oWReport:aColumn )
				
            nItem := 1           
            
            DO WHILE nItem < 3
            
               cExpr := UtoC( oWReport:aColumn[ nCount, COL_cTitle ] )
               
               IF nItem = 1
                  IF At( ";", cExpr ) > 0
                     cExpr := Left( cExpr, At( ";", cExpr ) -1 )
                     nItem := 2
                  ELSE
                     nItem := 3
                  ENDIF
               ELSE
                  cExpr := Subs( cExpr, At( ";", cExpr ) +1 )
                  nItem := 4
               ENDIF
            
               cExpr := '"' + cExpr + '"'
               nWidth := Len( cExpr ) -2 + nLen 
               nWidth *= oWReport:nColScale
               nWidth := Round( nWidth, 0 )
   
               oWReport:aColumn[ nCount, COL_nCol   ] := nCol
   				oWReport:aColumn[ nCount, COL_nWidth ] := nWidth
               
               BEGIN TEXT
   					EXPRESSION &cExpr
   					ROW		  nRow + If( nItem = 4, 3, 0 )
   					COL		  nCol
   					WIDTH      nWidth
   					FONTNAME	  oWReport:cFontName
   					FONTSIZE	  oWReport:nFontSize
   					DO CASE
   					   CASE oWReport:aColumn[ nCount, COL_cAlign ] = "CENTER" ; ALIGNMENT Center
   					   CASE oWReport:aColumn[ nCount, COL_cAlign ] = "LEFT"   ; ALIGNMENT Left
   					   CASE oWReport:aColumn[ nCount, COL_cAlign ] = "RIGHT"  ; ALIGNMENT Right
   					ENDCASE   
   				END TEXT
				
            ENDDO
            
				nCol += nWidth + oWReport:nColSpace
			
   		NEXT
			
      END HEADER

		// Detail Band.

		BEGIN DETAIL

         DO CASE
            CASE oWReport:nCols =  80 ; nHeight := 5   ; nRow := 4
            CASE oWReport:nCols = 100 ; nHeight := 4.5 ; nRow := 3
            CASE oWReport:nCols = 132 ; nHeight := 4   ; nRow := 2
         ENDCASE   
			
         BANDHEIGHT nHeight					
         
         FOR nCount := 1 TO Len( oWReport:aColumn )
				
				nCol   := oWReport:aColumn[ nCount, COL_nCol   ]
				nWidth := oWReport:aColumn[ nCount, COL_nWidth ]
            uMasc  := oWReport:aColumn[ nCount, COL_uMasc  ]
            cExpr  := oWReport:aColumn[ nCount, COL_cImp   ]

				IF ValType( uMasc ) = "C"
               cExpr := "Tran( " + cExpr + ", '" + uMasc + "' )"
            ELSE
               cExpr := "Left( " + cExpr + ", " + NumToStr( uMasc ) + " )"
				ENDIF

				BEGIN TEXT
					EXPRESSION &cExpr
					ROW		  nRow
					COL		  nCol
					WIDTH		  nWidth
					HEIGHT     nHeight
					FONTNAME	  oWReport:cFontName
					FONTSIZE	  oWReport:nFontSize
					DO CASE
					   CASE oWReport:aColumn[ nCount, COL_cAlign ] = "CENTER" ; ALIGNMENT Center
					   CASE oWReport:aColumn[ nCount, COL_cAlign ] = "LEFT"   ; ALIGNMENT Left
					   CASE oWReport:aColumn[ nCount, COL_cAlign ] = "RIGHT"  ; ALIGNMENT Right
					ENDCASE
				END TEXT

			NEXT

		END DETAIL

		// Footer Band.

		BEGIN FOOTER

         BANDHEIGHT 18

			mxWRptLine( 2.5 )
			
			IF Len( oWReport:aParam ) > 0
			   
            cExpr := "("
   
            FOR nCount := 1 TO Len( oWReport:aParam )
      
               cVar  := oWReport:aParam[ nCount ]
               cType := GetControlType( cVar, mxWFObj():cName )
               
               IF cType = "COMBO"
      	         nItem := GetProperty( mxWFObj():cName, cVar, "Value" )
      	         IF nItem = 0
      	            uVar := ""
      	         ELSE
      	            uVar := Left( mxGetComboItems( mxWFObj():cName, cVar )[ nItem ], 1 )
      	         ENDIF      	         
      	      ELSEIF cType = "RADIOGROUP"
                  nItem := GetProperty( mxWFObj():cName, cVar, "Value" )
                  uVar  := GetProperty( mxWFObj():cName, cVar, "Caption", nItem )
      			ELSE
      	         uVar := GetProperty( mxWFObj():cName, cVar, "Value" )
      	      ENDIF
      	      
               cType := ValType( uVar )

               DO CASE
                  CASE cType = "U" ; cExpr += "NIL"
                  CASE cType = "N" ; cExpr += NumToStr( uVar )
                  CASE cType = "D" ; cExpr += AllTrim( ClearMasc( DtoC( uVar ), "./" ) )
                  CASE cType = "L" ; cExpr += If( uVar, "S", "N" )
                  OTHE             ; cExpr += AllTrim( uVar )
               ENDCASE               
                  
               cExpr += "-"
      
            NEXT
      
            cExpr := "'" + Left( cExpr, Len( cExpr ) -1 ) + ")'"
   
   			BEGIN TEXT
   				EXPRESSION &cExpr
   				ROW		  01
   				COL		  10	
   				FONTNAME	  oWReport:cFontName
   				FONTSIZE	  8
   				ALIGNMENT  Left 
   			END TEXT
			
         ENDIF

			BEGIN TEXT
				EXPRESSION "Max Scalla Informática Ltda."
				ROW		  01
				COL		  10
				WIDTH		  190
				FONTNAME	  oWReport:cFontName
				FONTSIZE	  8
				ALIGNMENT  Left
			END TEXT
			
			BEGIN TEXT
				EXPRESSION "Emitido em: " + DtoC( Date() )
				ROW		  01
				COL		  10
				WIDTH		  190	
				FONTNAME	  oWReport:cFontName
				FONTSIZE	  8
				ALIGNMENT  Right
			END TEXT

		END FOOTER	
		
      IF Empty( oWReport:cGroupExpr )
		   
         oWReport:lGroupTotal := .F.
         
		ELSE   
            
			// Group Band.
			
         cExpr := oWReport:cGroupHeader
			
         nHeight := 4 + ( 3.5 * ( NumToken( cExpr, ";" ) -1 ) )
         
         DO CASE
            CASE oWReport:nCols =  80 ; nRow := 6 ; nHeight += 4
            CASE oWReport:nCols = 100 ; nRow := 4 ; nHeight += 2
            OTHERWISE                 ; nRow := 2
         ENDCASE

         cFont := FNT_SUMMARY
         nFont := oWReport:nFontSize + 1.5

         cExpr += ";"        
         
         BEGIN GROUP		
	
				GROUPEXPRESSION &( oWReport:cGroupExpr )
	
				BEGIN GROUPHEADER
	
               BANDHEIGHT nHeight 
               
               DO WHILE Len( cExpr ) > 0               
   	
   					cVar := Left( cExpr, At( ";", cExpr ) -1 )
   					
                  cExpr := Subs( cExpr, Len( cVar ) +2 )
                  
                  BEGIN TEXT
   						EXPRESSION &cVar
   						ROW		  nRow 
   						COL		  10
   						WIDTH      190
   						FONTNAME	  cFont
   						FONTSIZE	  nFont
      					DO CASE
      					   CASE oWReport:cGroupAlign = "CENTER" ; ALIGNMENT Center
      					   CASE oWReport:cGroupAlign = "LEFT"   ; ALIGNMENT Left
      					   CASE oWReport:cGroupAlign = "RIGHT"  ; ALIGNMENT Right
      					ENDCASE   						
   					END TEXT
   					
                  nRow += 3.5
				   
               ENDDO
	
				END GROUPHEADER
	
				// Totalizacao do grupo.
				
            IF oWReport:lGroupTotal .OR. oWReport:lGroupSummary
				
               nHeight := 0
               
               IF oWReport:lGroupSummary
				      aEval( oWReport:aSummary, { |x| nHeight += x[ CPL_nAddRow ] } )
				      nHeight ++
                  nHeight *= 4
                  IF oWReport:lGroupTotal
                     nHeight += 6
                  ENDIF
               ENDIF

	            nHeight := Max( nHeight, 6 )
               
               // Group Footer Band.               
					
		         DO CASE
                  CASE oWReport:nCols =  80 ; nRow := 5 ; nRowLine := 7
                  CASE oWReport:nCols = 100 ; nRow := 3 ; nRowLine := 6
                  CASE oWReport:nCols = 132 ; nRow := 3 ; nRowLine := 4.5
               ENDCASE                

      			BEGIN GROUPFOOTER
		
						BANDHEIGHT nHeight
                  
                  IF oWReport:lGroupTotal
				         mxWRptTotal( .T., nRow )
				         mxWRptLine( nRowLine )
				         nRow += 3
                  ENDIF
                  
                  IF oWReport:lGroupSummary
                     mxWRptCpl( oWReport:aSummary, nRow, oWReport:nFontSize +1, FNT_SUMMARY )
                  ENDIF
		
					END GROUPFOOTER
				
				ENDIF					
		      
			END GROUP		
	   
		ENDIF
		
		// Summary Band.

      IF oWReport:lTotal .OR. ( Len( oWReport:aSummary ) > 0 .AND. ! oWReport:lGroupSummary )
		
		   // Totalizacao geral.
		
         DO CASE
            CASE oWReport:nCols =  80 ; nRow := 5 ; nRowLine := 6
            CASE oWReport:nCols = 100 ; nRow := 3 ; nRowLine := 6
            CASE oWReport:nCols = 132 ; nRow := 3 ; nRowLine := 4.5
         ENDCASE                
      
         BEGIN SUMMARY

   			BANDHEIGHT 6

            IF oWReport:lTotal
               
               IF ! oWReport:lGroupTotal
                  mxWRptLine( nRowLine )
               ENDIF
     
   				mxWRptTotal( .F., nRow )
   				
               nRow += 3
   				
   			ENDIF	
   			
   	      IF ! oWReport:lGroupSummary
      		   mxWRptCpl( oWReport:aSummary, nRow, oWReport:nFontSize +1, FNT_SUMMARY )
     		   ENDIF
            
   		END SUMMARY
   	
      ENDIF	

		_HMG_RPTDATA[164] := oWReport:bFilter      // xSkipProcedure
		_HMG_RPTDATA[165] := oWReport:bEnd         // xEOF
		_HMG_RPTDATA[170] := oWReport:bGroupAfter  // xGroupAfter
      
	END REPORT

RETURN( NIL )



STATIC PROCEDURE mxWRptLine( nRow, nFromCol, nToCol )

   // Exibe uma linha.
   
   vDef( @nFromCol,   9 )
   vDef( @nToCol  , 201 )

	BEGIN LINE
		FROMROW	nRow
		FROMCOL	nFromCol
		TOROW		nRow
		TOCOL		nToCol
		PENWIDTH	0.1
	END LINE
	
RETURN( NIL )



STATIC PROCEDURE mxWRptTotal( lGroup, nRow )
   
   // Monta a totalizacao do grupo/geral.
   
   LOCAL nCol, nWidth, nCount, nPos
   
   PRIV cExpr := "'TOTAL " + If( lGroup, "", "GERAL " ) + ":'"

   BEGIN TEXT
		EXPRESSION &cExpr
      ROW		  nRow
		COL		  10	
		FONTNAME	  oWReport:cFontName
		FONTSIZE	  oWReport:nFontSize
	END TEXT

   FOR nCount := 1 TO Len( oWReport:aColumn )
   
      IF oWReport:aColumn[ nCount, COL_uMascTotal ] <> NIL
         
   		nCol   := oWReport:aColumn[ nCount, COL_nCol   ]
   		nWidth := oWReport:aColumn[ nCount, COL_nWidth ]
         
         nPos := aScan( _HMG_RPTDATA[169], { |x| x[1] = nCount } )
   
         cExpr := "_HMG_RPTDATA[ 169, " + NumToStr( nPos ) + ", " + If( lGroup, "2", "3" ) + " ]"
         
   		IF Type( cExpr ) = "C"
   		   cExpr := &cExpr
		   ENDIF
   		
         cExpr := "Tran( " + cExpr + ", '" + oWReport:aColumn[ nCount, COL_uMascTotal ] + "' )"
   		
   		BEGIN TEXT
   			EXPRESSION &cExpr
   			ROW		  nRow
   			COL		  nCol
   			WIDTH		  nWidth
   			FONTNAME	  oWReport:cFontName
   			FONTSIZE	  oWReport:nFontSize
   			ALIGNMENT  Right
   		END TEXT
   	
   	ENDIF					
   
   NEXT					

RETURN( NIL )



STATIC PROCEDURE mxWRptCpl( aCpl, nRow, nFontSize, cFontName )
   
   LOCAL nCount, nCol, cAlign

   PRIV cExpr
   
   vDef( @cFontName, oWReport:cFontName )
   
   FOR nCount := 1 TO Len( aCpl )
      
      cExpr := UtoC( aCpl[ nCount, CPL_cImp ] )
      
      IF Left( cExpr, 4 ) = "{ ||"
         cExpr := Subs( cExpr, 6 )
         cExpr := AllTrim( Left( cExpr, Len( cExpr ) -1 ) )
      ELSEIF Left( cExpr, 1 ) <> '"'
         cExpr := '"' + cExpr + '"'
      ENDIF
   	
      IF ValType(  aCpl[ nCount, CPL_uCol ] ) = "C"
         cAlign := aCpl[ nCount, CPL_uCol ]
         nCol   := 10
      ELSE
         cAlign := "LEFT"
         nCol   := aCpl[ nCount, CPL_uCol ]
      ENDIF   
      
      nRow += ( 3.5 * aCpl[ nCount, CPL_nAddRow ] )
   
   	BEGIN TEXT
   		EXPRESSION &cExpr
   		ROW		  nRow
   		COL		  nCol
   		WIDTH		  190
   		FONTNAME	  cFontName
   		FONTSIZE	  nFontSize
   		DO CASE
   		   CASE cAlign = "CENTER" ; ALIGNMENT Center
   		   CASE cAlign = "LEFT"   ; ALIGNMENT Left
   		   CASE cAlign = "RIGHT"  ; ALIGNMENT Right
   		ENDCASE   
   	END TEXT
   
   NEXT
   
RETURN( NIL )



PROCEDURE ImpPosAlias( cAlias, bFunc )

   SeleArea( cAlias )
   
   IF bFunc = NIL
      mxTop(1)
   ELSEIF ValType( bFunc ) = "N"
      mxTop( bFunc )   
   ELSE
      Eval( bFunc )
   ENDIF

RETURN( NIL )

********************************************************************************

Procedure _DefineReport( cName )

   _HMG_RPTDATA[118] := 0
   _HMG_RPTDATA[119] := 0

   _HMG_RPTDATA[120] := 0

   _HMG_RPTDATA[121] := {}
   _HMG_RPTDATA[122] := {}

   _HMG_RPTDATA[123] := 0
   _HMG_RPTDATA[124] := 0

   _HMG_RPTDATA[155] := 0
   _HMG_RPTDATA[156] := 0

   _HMG_RPTDATA[157] := {}
   _HMG_RPTDATA[158] := {}
   _HMG_RPTDATA[159] := {}
   _HMG_RPTDATA[160] := {}
   _HMG_RPTDATA[126] := {}
   _HMG_RPTDATA[127] := 0
   _HMG_RPTDATA[161] := 'MAIN'

   _HMG_RPTDATA[164] := Nil
   _HMG_RPTDATA[165] := Nil

   _HMG_RPTDATA[166] := Nil
   _HMG_RPTDATA[167] := {}

   If cName <> '_TEMPLATE_'
      _HMG_RPTDATA[162] := cName
   Else
      cName := _HMG_RPTDATA[162]
   EndIf

   Public &cName := {}

Return


Procedure _EndReport

	Local aMiscData := {}
	Local cReportName

   aadd( aMiscData, _HMG_RPTDATA[120] )  // nGroupCount
   aadd( aMiscData, _HMG_RPTDATA[152] )  // nHeadeHeight
   aadd( aMiscData, _HMG_RPTDATA[153] )  // nDetailHeight
   aadd( aMiscData, _HMG_RPTDATA[154] )  // nFooterHeight
   aadd( aMiscData, _HMG_RPTDATA[127] )  // nSummaryHeight
   aadd( aMiscData, _HMG_RPTDATA[124] )  // nGroupHeaderHeight
   aadd( aMiscData, _HMG_RPTDATA[123] )  // nGroupFooterHeight
   aadd( aMiscData, _HMG_RPTDATA[125] )  // xGroupExpression
   aadd( aMiscData, _HMG_RPTDATA[164] )  // xSkipProcedure
   aadd( aMiscData, _HMG_RPTDATA[165] )  // xEOF
   aadd( aMiscData, _HMG_RPTDATA[170] )  // xGroupAfter

   cReportName := _HMG_RPTDATA[162]

   &cReportName := { _HMG_RPTDATA[159],;
	                  _HMG_RPTDATA[160],;
							_HMG_RPTDATA[158],;
							_HMG_RPTDATA[157],;
							_HMG_RPTDATA[126],;
							_HMG_RPTDATA[121],;
							_HMG_RPTDATA[122],;
							aMiscData }

Return

* Layout **********************************************************************

Procedure _BeginLayout

   _HMG_RPTDATA[161] := 'LAYOUT'

Return


Procedure _EndLayout

   aadd( _HMG_RPTDATA[159], _HMG_RPTDATA[155] )
   aadd( _HMG_RPTDATA[159], _HMG_RPTDATA[156] )
   aadd( _HMG_RPTDATA[159], _HMG_RPTDATA[118] )
   aadd( _HMG_RPTDATA[159], _HMG_RPTDATA[119] )

Return

* Header **********************************************************************

Procedure _BeginHeader

   _HMG_RPTDATA[161] := 'HEADER'
   _HMG_RPTDATA[160] := {}

Return


Procedure _EndHeader
Return


* Detail **********************************************************************

Procedure _BeginDetail

   _HMG_RPTDATA[161] := 'DETAIL'
   _HMG_RPTDATA[158] := {}

Return


Procedure _EndDetail
Return

* Footer **********************************************************************

Procedure _BeginFooter

   _HMG_RPTDATA[161] := 'FOOTER'
   _HMG_RPTDATA[157] := {}

Return


Procedure _EndFooter
Return

* Summary **********************************************************************

Procedure _BeginSummary

   _HMG_RPTDATA[161] := 'SUMMARY'

Return


Procedure _EndSummary
Return


* Text **********************************************************************

Procedure _BeginText

   _HMG_RPTDATA[116] := ''                         // Text
   _HMG_ActiveControlRow           := 0            // Row
   _HMG_ActiveControlCol           := 0            // Col
   _HMG_ActiveControlWidth         := 0            // Width
   _HMG_ActiveControlHeight        := 0            // Height
   _HMG_ActiveControlFont          := FNT_DEFAULT  // FontName
   _HMG_ActiveControlSize          := 9            // FontSize
   _HMG_ActiveControlFontBold      := .F.          // FontBold
   _HMG_ActiveControlFontItalic    := .F.          // FontItalic
   _HMG_ActiveControlFontUnderLine := .F.          // FontUnderLine
   _HMG_ActiveControlFontStrikeOut := .F.          // FontStrikeout
   _HMG_ActiveControlFontColor     := { 0, 0, 0 }  // FontColor
   _HMG_ActiveControlRightAlign    := .F.          // Alignment
   _HMG_ActiveControlCenterAlign   := .F.          // Alignment

Return


Procedure _EndText

   Local aText

   aText := { 'TEXT'                         ,;
			     _HMG_RPTDATA[116]              ,;
			     _HMG_ActiveControlRow          ,;
			     _HMG_ActiveControlCol          ,;
			     _HMG_ActiveControlWidth        ,;
			     _HMG_ActiveControlHeight       ,;
			     _HMG_ActiveControlFont         ,;
			     _HMG_ActiveControlSize         ,;
			     _HMG_ActiveControlFontBold     ,;
			     _HMG_ActiveControlFontItalic   ,;
			     _HMG_ActiveControlFontUnderLine,;
			     _HMG_ActiveControlFontStrikeOut,;
			     _HMG_ActiveControlFontColor    ,;
			     _HMG_ActiveControlRightAlign   ,;
			     _HMG_ActiveControlCenterAlign }

   DO CASE
      CASE _HMG_RPTDATA[161] == 'HEADER'      ; aadd( _HMG_RPTDATA[160], aText )
      CASE _HMG_RPTDATA[161] == 'DETAIL'      ; aadd( _HMG_RPTDATA[158], aText )
      CASE _HMG_RPTDATA[161] == 'FOOTER'      ; aadd( _HMG_RPTDATA[157], aText )
      CASE _HMG_RPTDATA[161] == 'SUMMARY'     ; aadd( _HMG_RPTDATA[126], aText )
      CASE _HMG_RPTDATA[161] == 'GROUPHEADER' ; aadd( _HMG_RPTDATA[121], aText )
      CASE _HMG_RPTDATA[161] == 'GROUPFOOTER' ; aadd( _HMG_RPTDATA[122], aText )
   ENDCASE

Return

* Band Height *****************************************************************

Procedure _BandHeight( nValue )

	DO CASE
	   CASE _HMG_RPTDATA[161] == 'HEADER'      ; _HMG_RPTDATA[152] := nValue
	   CASE _HMG_RPTDATA[161] == 'DETAIL'      ; _HMG_RPTDATA[153] := nValue
	   CASE _HMG_RPTDATA[161] == 'FOOTER'      ; _HMG_RPTDATA[154] := nValue
	   CASE _HMG_RPTDATA[161] == 'SUMMARY'     ; _HMG_RPTDATA[127] := nValue
	   CASE _HMG_RPTDATA[161] == 'GROUPHEADER' ; _HMG_RPTDATA[124] := nValue
	   CASE _HMG_RPTDATA[161] == 'GROUPFOOTER' ; _HMG_RPTDATA[123] := nValue
   ENDCASE

Return

* Execute *********************************************************************

Function ExecuteReport( cReportName, lPreview, lSelect, cOutputFileName )

	Local lReturn := .F.
	Local nCount
	Local nRow

   Local cPdfPaperSize   := ''
	Local cPdfOrientation := ''
	Local cPrinter

	Local aPaper[18][2]
	Local aLayout
	Local aHeader
	Local aDetail
	Local aFooter
	Local aSummary
	Local aTemp
	Local aGroupHeader
	Local aGroupFooter
	Local aMiscData

	Local nPaperWidth
	Local nPaperHeight
	Local nOrientation
	Local nPaperSize
	Local nHeadeHeight
	Local nDetailHeight
	Local nFooterHeight
	Local nBandSpace
	Local nCurrentOffset
	Local nPreviousRecNo
	Local nSummaryHeight
	Local nGroupHeaderHeight
	Local nGroupFooterHeight
	Local nGroupCount
	Local nOutfile

	Local xGroupExpression
	Local xPreviousGroupExpression
	Local xTemp
	Local xSkipProcedure
	Local xEOF
	Local xGroupAfter

	Local lGroupStarted
	Local lSuccess
	Local lTempEof

   IF _HMG_RPTDATA[120] > 1
      MsgMiniGUIError('Only One Group Level Allowed')
   ENDIF

   _HMG_RPTDATA[149] := ''
   _HMG_RPTDATA[150] := .F.
   _HMG_RPTDATA[163] := .F.
   _HMG_RPTDATA[166] := .F.

   If ValType( cOutputFileName ) == 'C'

      DO CASE
         CASE Upper( Right( AllTrim( cOutputFileName ), 4 ) ) == '.PDF'  ; _HMG_RPTDATA[150] := .T.
         CASE Upper( Right( AllTrim( cOutputFileName ), 5 ) ) == '.HTML' ; _HMG_RPTDATA[163] := .T.
         CASE Upper( Right( AllTrim( cOutputFileName ), 4 ) ) == '.RTF'  ; _HMG_RPTDATA[166] := .T.
      ENDCASE

   EndIf

   IF _HMG_RPTDATA[163]
      _HMG_RPTDATA[149] += '<html>' + chr(13) + chr(10)
      _HMG_RPTDATA[149] += '<style>' + chr(13) + chr(10)
      _HMG_RPTDATA[149] += 'div {position:absolute}' + chr(13) + chr(10)
      _HMG_RPTDATA[149] += '.line { }' + chr(13) + chr(10)
      _HMG_RPTDATA[149] += '</style>' + chr(13) + chr(10)
      _HMG_RPTDATA[149] += '<body>' + chr(13) + chr(10)
   ENDIF

   IF _HMG_RPTDATA[150]
      PdfInit()
      pdfOpen( cOutputFileName, 200, .t. )
   ENDIF

   If ValType( xSkipProcedure ) = 'U'

      * If not workarea open, cancel report execution

      If Select() == 0
         Return( .F. )
      EndIf

      nPreviousRecNo := RecNo()

   EndIf

   ***********************************************************************
   * Determine Print Parameters
   ***********************************************************************

   aTemp := __MVGET( cReportName )

   aLayout      := aTemp[1]
   aHeader      := aTemp[2]
   aDetail      := aTemp[3]
   aFooter      := aTemp[4]
   aSummary     := aTemp[5]
   aGroupHeader := aTemp[6]
   aGroupFooter := aTemp[7]
   aMiscData    := aTemp[8]

   nGroupCount        := aMiscData[1]
   nHeadeHeight       := aMiscData[2]
   nDetailHeight      := aMiscData[3]
   nFooterHeight      := aMiscData[4]
   nSummaryHeight     := aMiscData[5]
   nGroupHeaderHeight := aMiscData[6]
   nGroupFooterHeight := aMiscData[7]
   xTemp              := aMiscData[8]
   xSkipProcedure     := aMiscData[9]
   xEOF               := aMiscData[10]
   xGroupAfter        := aMiscData[11]

   nOrientation := aLayout[1]
   nPaperSize   := aLayout[2]
   nPaperWidth  := aLayout[3]
   nPaperHeight := aLayout[4]

   If ValType( lPreview ) <> 'L'
      lPreview := .F.
   EndIf

   If ValType( lSelect ) <> 'L'
      lSelect := .F.
   EndIf

	IF _HMG_RPTDATA[150] == .F. .AND. _HMG_RPTDATA[163] == .F.

      If lSelect
         cPrinter := GetPrinter()
      Else
         cPrinter := GetDefaultPrinter()
      EndIf

      If Empty(cPrinter)
         Return( .F. )
      EndIf

   ENDIF

   ***********************************************************************
   * Select Printer
   ***********************************************************************

   IF _HMG_RPTDATA[150] == .F. .AND. _HMG_RPTDATA[163] == .F. .AND. _HMG_RPTDATA[166] == .F.

      init printsys

      SET UNITS MM
      SET PREVIEW SCALE 2.5

      IF lPreview

         If nPaperSize == PRINTER_PAPER_USER

            if drv = "H"
               SELECT PRINTER
               SET PAGE ORIENTATION nOrientation
            Else
               SELECT PRINTER cPrinter     ;
                  TO          lSuccess     ;
                  ORIENTATION nOrientation ;
                  PAPERSIZE   nPaperSize   ;
                  PAPERWIDTH  nPaperWidth  ;
                  PAPERLENGTH nPaperHeight ;
                  PREVIEW
             Endif
         Else

            if drv = "H"
               SELECT PRINTER cPrinter PREVIEW
            Else
               SELECT PRINTER cPrinter     ;
                  TO          lSuccess     ;
                  ORIENTATION nOrientation ;
                  PAPERSIZE   nPaperSize   ;
                  PREVIEW
            Endif

         EndIf

      ELSE

         If nPaperSize == PRINTER_PAPER_USER

				if drv = "H"
            Else
               SELECT PRINTER cPrinter     ;
                  TO          lSuccess     ;
                  ORIENTATION nOrientation ;
                  PAPERSIZE   nPaperSize   ;
                  PAPERWIDTH  nPaperWidth  ;
                  PAPERLENGTH nPaperHeight
            Endif

         Else

            if drv = "H"
            Else
               SELECT PRINTER cPrinter     ;
                  TO          lSuccess     ;
                  ORIENTATION nOrientation ;
                  PAPERSIZE   nPaperSize
            Endif

         EndIf
      ENDIF

		if drv = "H"
         define font "f0" name "courier new" size 12
         define pen "P0" style PS_SOLID width 10
         SET PAGE ORIENTATION nOrientation PAPERSIZE nPapersize FONT "f0"
      Endif

   ENDIF

   ***********************************************************************
   * Determine Paper Dimensions in mm.
   ***********************************************************************

   If npaperSize >= 1 .and. nPaperSize <= 18

      aPaper[ PRINTER_PAPER_LETTER      ] := { 215.9 , 279.4 }
      aPaper[ PRINTER_PAPER_LETTERSMALL ] := { 215.9 , 279.4 }
      aPaper[ PRINTER_PAPER_TABLOID     ] := { 279.4 , 431.8 }
      aPaper[ PRINTER_PAPER_LEDGER      ] := { 431.8 , 279.4 }
      aPaper[ PRINTER_PAPER_LEGAL       ] := { 215.9 , 355.6 }
      aPaper[ PRINTER_PAPER_STATEMENT   ] := { 139.7 , 215.9 }
      aPaper[ PRINTER_PAPER_EXECUTIVE   ] := { 184.15, 266.7 }
      aPaper[ PRINTER_PAPER_A3          ] := { 297   , 420   }
      aPaper[ PRINTER_PAPER_A4          ] := { 210   , 297   }
      aPaper[ PRINTER_PAPER_A4SMALL     ] := { 210   , 297   }
      aPaper[ PRINTER_PAPER_A5          ] := { 148   , 210   }
      aPaper[ PRINTER_PAPER_B4          ] := { 250   , 354   }
      aPaper[ PRINTER_PAPER_B5          ] := { 182   , 257   }
      aPaper[ PRINTER_PAPER_FOLIO       ] := { 215.9 , 330.2 }
      aPaper[ PRINTER_PAPER_QUARTO      ] := { 215   , 275   }
      aPaper[ PRINTER_PAPER_10X14       ] := { 254   , 355.6 }
      aPaper[ PRINTER_PAPER_11X17       ] := { 279.4 , 431.8 }
      aPaper[ PRINTER_PAPER_NOTE        ] := { 215.9 , 279.4 }

      DO CASE
         CASE nOrientation == PRINTER_ORIENT_PORTRAIT  ; nPaperHeight := aPaper[ nPaperSize ][2]
         CASE nOrientation == PRINTER_ORIENT_LANDSCAPE ; nPaperHeight := aPaper[ nPaperSize ][1]
         OTHERWISE
            MsgMiniGUIError('Report: Orientation Not Supported')
      ENDCASE

   Else

      MsgMiniGUIError('Report: Paper Size Not Supported')

   EndIf


   IF _HMG_RPTDATA[150]

      * PDF Paper Size

      DO CASE
         CASE nPaperSize == PRINTER_PAPER_LETTER      ; cPdfPaperSize := "LETTER"
         CASE nPaperSize == PRINTER_PAPER_LEGAL       ; cPdfPaperSize := "LEGAL"
         CASE nPaperSize == PRINTER_PAPER_A4          ; cPdfPaperSize := "A4"
         CASE nPaperSize == PRINTER_PAPER_TABLOID     ; cPdfPaperSize := "LEDGER"
         CASE nPaperSize == PRINTER_PAPER_EXECUTIVE   ; cPdfPaperSize := "EXECUTIVE"
         CASE nPaperSize == PRINTER_PAPER_A3          ; cPdfPaperSize := "A3"
         CASE nPaperSize == PRINTER_PAPER_ENV_10      ; cPdfPaperSize := "COM10"
         CASE nPaperSize == PRINTER_PAPER_B4          ; cPdfPaperSize := "JIS B4"
         CASE nPaperSize == PRINTER_PAPER_B5          ; cPdfPaperSize := "B5"
         CASE nPaperSize == PRINTER_PAPER_P32K        ; cPdfPaperSize := "JPOST"
         CASE nPaperSize == PRINTER_PAPER_ENV_C5      ; cPdfPaperSize := "C5"
         CASE nPaperSize == PRINTER_PAPER_ENV_DL      ; cPdfPaperSize := "DL"
         CASE nPaperSize == PRINTER_PAPER_ENV_B5      ; cPdfPaperSize := "B5"
         CASE nPaperSize == PRINTER_PAPER_ENV_MONARCH ; cPdfPaperSize := "MONARCH"
         OTHERWISE
            MsgMiniGUIError("Report: PDF Paper Size Not Supported")
      ENDCASE

      * PDF Orientation

      DO CASE
         CASE nOrientation == PRINTER_ORIENT_PORTRAIT  ; cPdfOrientation := 'P'
         CASE nOrientation == PRINTER_ORIENT_LANDSCAPE ; cPdfOrientation := 'L'
         OTHERWISE
            MsgMiniGUIError('Report: Orientation Not Supported')
      ENDCASE

   ENDIF

   ***********************************************************************
   * Calculate Bands
   ***********************************************************************

   nBandSpace := nPaperHeight - nHeadeHeight - nFooterHeight

   ***********************************************************************
   * Print Document
   ***********************************************************************

   If nGroupCount > 0
      xGroupExpression := &(xTemp)
   EndIf

   _HMG_RPTDATA[117] := 1

   IF _HMG_RPTDATA[150] == .F. .AND. _HMG_RPTDATA[163] == .F. .AND. _HMG_RPTDATA[166] == .F.

      if drv = "H"
         START DOC
      Else
         START PRINTDOC
      Endif

   ENDIF

   xPreviousGroupExpression := ''
   lGroupStarted := .f.

   If ValType( xSkipProcedure ) == 'U'
      Go Top
      lTempEof := Eof()
   Else
      lTempEof := Eval(xEof)
   EndIf

   Do While .Not. lTempEof

      IF _HMG_RPTDATA[163] == .F.

         IF _HMG_RPTDATA[150]

            pdfNewPage( cPdfPaperSize, cPdfOrientation, 6 )

         ELSEif _HMG_RPTDATA[166] == .F.

            if drv = "H"
               START PAGE
            Else
               START PRINTPAGE
            Endif

         ENDIF

         nCurrentOffset := 0

         lReturn := .T.
         _ProcessBand( aHeader, 0, "HEADER" )

         nCurrentOffset := nHeadeHeight

         do while .t.

            If nGroupCount > 0

               If ( valtype(xPreviousGroupExpression) != valtype(xGroupExpression) ) .or. ( xPreviousGroupExpression <> xGroupExpression )

                  Eval( xGroupAfter )

                  If lGroupStarted
                     _ProcessBand( aGroupFooter, nCurrentOffset, "GROUPFOOTER" )
                     nCurrentOffset += nGroupFooterHeight
                  EndIf

                  If nCurrentOffset + nGroupHeaderHeight + nDetailHeight >= nPaperHeight - nFooterHeight -1
                     lGroupStarted := .F.
                     Exit
                  EndIf

                  _ProcessBand( aGroupHeader, nCurrentOffset, "GROUPHEADER" )
                  nCurrentOffset += nGroupHeaderHeight

                  xPreviousGroupExpression := xGroupExpression

                  lGroupStarted := .T.

               EndIf

            EndIf

            If ValType( xSkipProcedure ) == 'U' .OR. Eval( xSkipProcedure, aDetail, @nCurrentOffset, nPaperHeight - nFooterHeight - nDetailHeight -1 )

               _ProcessBand( aDetail, nCurrentOffset, "DETAIL" )

               nCurrentOffset += nDetailHeight

            ENDIF

            Skip

            If ValType( xSkipProcedure ) == 'U'
               lTempEof := Eof()
            Else
               lTempEof := Eval(xEof)
            EndIf

            If lTempEof

               * If group footer defined, print it.

               If nGroupFooterHeight > 0

                  * If group footer don't fit in the current page, print page footer,
                  * start a new page and print header first

                  If nCurrentOffset + nGroupFooterHeight > nPaperHeight - nFooterHeight

                     nCurrentOffset := nPaperHeight - nFooterHeight
                     _ProcessBand( aFooter, nCurrentOffset, "FOOTER" )

                     IF _HMG_RPTDATA[150] == .F.
                        if drv = "H"
                           END PAGE
                           START PAGE
                        Else
                           END PRINTPAGE
                           START PRINTPAGE
                        Endif
                     ELSE
                        pdfNewPage( cPdfPaperSize, cPdfOrientation, 6 )
                     ENDIF

                     _HMG_RPTDATA[117]++

                     nCurrentOffset := 0
                     _ProcessBand( aHeader, 0, "HEADER" )
                     nCurrentOffset := nHeadeHeight

                  EndIf

                  _ProcessBand( aGroupFooter, nCurrentOffset, "GROUPFOOTER" )
                  nCurrentOffset += nGroupFooterHeight

               EndIf

               * If Summary defined, print it.

               If Len( aSummary ) > 0

                  * If summary don't fit in the current page, print footer,
                  * start a new page and print header first

                  nRow := nCurrentOffset

                  For nCount := 1 to Len( aSummary )

                     If nCurrentOffset +4 +3 >= nPaperHeight - nFooterHeight

                        nCurrentOffset := nPaperHeight - nFooterHeight
                        _ProcessBand( aFooter, nCurrentOffset, "FOOTER" )

                        IF _HMG_RPTDATA[150] == .F.
                           if drv = "H"
                              END PAGE
                              START PAGE
                           Else
                              END PRINTPAGE
                              START PRINTPAGE
                           Endif
                        ELSE
                           pdfNewPage( cPdfPaperSize, cPdfOrientation, 6 )
                        ENDIF

                        _HMG_RPTDATA[117]++

                        nCurrentOffset := 0
                        _ProcessBand( aHeader, 0, "HEADER" )
                        nCurrentOffset := nHeadeHeight

                        nRow := 0
                        aEval( aSummary, { |x| x[3] := ( nRow += 3 ) }, nCount )
                        nRow := nCurrentOffset

                     EndIf

                     _ProcessBand( { aSummary[ nCount ] }, nRow, "SUMMARY" )

                     IF aSummary[ nCount, 1 ] = "TEXT" .AND. Trim( Upper( aSummary[ nCount, 7 ] ) ) = "COURIER"  // FNT_SUMMARY
                        nCurrentOffset += 4
                        nRow += 0.3
                    ENDIF

                  Next

               EndIf

               Exit

            EndIf

            If nGroupCount > 0
               xGroupExpression := &(xTemp)
            EndIf

            If nCurrentOffset + nDetailHeight >= nPaperHeight - nFooterHeight -1
               Exit
            EndIf

         EndDo

         nCurrentOffset := nPaperHeight - nFooterHeight

         _ProcessBand( aFooter, nCurrentOffset, "FOOTER" )

         IF _HMG_RPTDATA[150] == .F. .AND. _HMG_RPTDATA[166] == .F.

            if drv = "H"
               END PAGE
            Else
               END PRINTPAGE
            Endif

         ENDIF

         _HMG_RPTDATA[117]++

      ELSE

         nCurrentOffset := 0

         _ProcessBand( aHeader, 0, "HEADER" )

         nCurrentOffset := nHeadeHeight

         do while .t.

            If nGroupCount > 0

               If xPreviousGroupExpression <> xGroupExpression

                  If lGroupStarted
                     _ProcessBand( aGroupFooter, nCurrentOffset, "GROUPFOOTER" )
                     nCurrentOffset += nGroupFooterHeight
                  EndIf

                  _ProcessBand( aGroupHeader, nCurrentOffset, "GROUPHEADER" )

                  nCurrentOffset += nGroupHeaderHeight

                  xPreviousGroupExpression := xGroupExpression

                  lGroupStarted := .T.

               EndIf

            EndIf

            _ProcessBand( aDetail, nCurrentOffset, "DETAIL" )

            nCurrentOffset += nDetailHeight

				If ValType( xSkipProcedure ) == 'U'
               Skip
               lTempEof := Eof()
            Else
               Eval(xSkipProcedure)
               lTempEof := Eval(xEof)
            EndIf

            If lTempEof

               * If group footer defined, print it.

               If nGroupFooterHeight > 0

                  _ProcessBand( aGroupFooter, nCurrentOffset, "GROUPFOOTER" )
                  nCurrentOffset += nGroupFooterHeight

               EndIf

               * If Summary defined, print it.

               If Len( aSummary ) > 0
                  _ProcessBand( aSummary, nCurrentOffset, "SUMMARY" )
                  nCurrentOffset += nSummaryHeight
               EndIf

               Exit

            EndIf

            If nGroupCount > 0
               xGroupExpression := &(xTemp)
            EndIf

         EndDo

         _ProcessBand( aFooter, nCurrentOffset, "FOOTER" )

      ENDIF

   EndDo

   IF _HMG_RPTDATA[150] == .F. .AND. _HMG_RPTDATA[163] == .F. .AND. _HMG_RPTDATA[166] == .F.

	   if drv = "H"
	      END DOC
	      RELEASE PRINTSYS
	   Else
	      END PRINTDOC
	   Endif

   ELSEIF _HMG_RPTDATA[150]

      pdfClose()

   ELSEIF _HMG_RPTDATA[163]

      _HMG_RPTDATA[149] += '</body>' + chr(13) + chr(10)
      _HMG_RPTDATA[149] += '</html>' + chr(13) + chr(10)

      nOutfile := FCREATE( cOutputFileName, FC_NORMAL)

      fWrite( nOutfile, _HMG_RPTDATA[149], Len(_HMG_RPTDATA[149]) )

      fClose( nOutfile )

   ENDIF

   If ValType( xSkipProcedure ) == 'U'
      Go nPreviousRecNo
   EndIf

Return( lReturn )

*.............................................................................*
Procedure _ProcessBand( aBand , nOffset, cBandType )
*.............................................................................*

	Local i, nPos, nValue, cValue

	For i := 1 To Len( aBand )

      _ProcessMess()

      cValue := _PrintObject( aBand[i], nOffset )

      IF cBandType = "DETAIL"
         nPos := aScan( _HMG_RPTDATA[169], { |x| x[1] = i } )
         IF nPos > 0
            nValue := Val( StrTran( ClearMasc( cValue, "." ), ",", "." ) )
			   IF ValType( _HMG_RPTDATA[ 169, nPos, 3 ] ) = "N"
               _HMG_RPTDATA[ 169, nPos, 2 ] += nValue
				   _HMG_RPTDATA[ 169, nPos, 3 ] += nValue
			   ENDIF
         ENDIF
		ENDIF

   Next i

	IF cBandType = "GROUPFOOTER"
		FOR i := 1 TO Len( _HMG_RPTDATA[169] )
         _HMG_RPTDATA[ 169, i, 2 ] := 0
      NEXT
   ENDIF

Return

*.............................................................................*
Procedure _PrintObject( aObject, nOffset )
*.............................................................................*

	DO CASE
	   CASE aObject[1] == 'TEXT'      ; _PrintText( aObject, nOffset )
	   CASE aObject[1] == 'IMAGE'     ; _PrintImage( aObject, nOffset )
	   CASE aObject[1] == 'LINE'      ; _PrintLine( aObject, nOffset )
	   CASE aObject[1] == 'RECTANGLE' ; _PrintRectangle( aObject, nOffset )
   ENDCASE

Return

*-----------------------------------------------------------------------------*
Function _PrintText( aObject, nOffset )
*-----------------------------------------------------------------------------*

	Local cValue         := aObject[ 2]
	Local nRow           := aObject[ 3]
	Local nCol           := aObject[ 4]
	Local nWidth         := aObject[ 5]
	Local nHeight        := aObject[ 6]
	Local cFontname      := aObject[ 7]
	Local nFontSize      := aObject[ 8]
	Local lFontBold      := aObject[ 9]
	Local lFontItalic    := aObject[10]
	Local lFontUnderLine := aObject[11]
	Local lFOntStrikeout := aObject[12]
	Local aFontColor     := aObject[13]
	Local lAlignment_1   := aObject[14]
	Local lAlignment_2   := aObject[15]
	Local cAlignment     := ''
	Local nFontStyle     := 0
	Local nTextRowFix    := 5
	Local HBPcOffset     := 0
	Local cHtmlAlignment

   cValue := &cValue

   IF _HMG_RPTDATA[150] == .F. .AND. _HMG_RPTDATA[163] == .F.

      If lAlignment_1 == .F. .and.  lAlignment_2

         cAlignment   := 'CENTER'
         hbprn:settextalign(TA_CENTER)

      ElseIf lAlignment_1 .and.  lAlignment_2 == .F.

         cAlignment   := 'RIGHT'
         hbprn:settextalign(TA_RIGHT)

      ElseIf   lAlignment_1 == .F. .and.  lAlignment_2 == .F.

         cAlignment   := ''
         hbprn:settextalign(TA_LEFT)

      EndIf

      if drv = "H"

         hbprn:modifyfont( "F0", cFontName, nFontSize, Nil, 0,;
			                  lFontBold     , !lFontBold,;
                           lFontitalic   , !lFontitalic,;
									lFontUnderline, !lFontUnderline,;
                           lFontStrikeout, !lFontStrikeout)

         hbPrn:SetTextColor( { aFontColor[1], aFontColor[2], aFontColor[3] } )

         IF ! ISCHARACTER( cValue )
            cValue := alltrim( HB_ValToStr( cValue ) )
         ENDIF
         if cAlignment  = 'RIGHT'
            HBPcOffset := nWidth
         Elseif cAlignment  = 'CENTER'
            HBPcOffset := nWidth / 2
         Endif

         @nRow + nOffset + 3, nCol + HBPcOffset SAY cValue FONT "F0" TO PRINT

      Else

      _HMG_PRINTER_H_MULTILINE_PRINT ( _HMG_PRINTER_HDC, nRow  + nOffset, nCol, nRow + nHeight  + nOffset, nCol + nWidth, cFontName, nFontSize, aFontColor[1], aFontColor[2], aFontColor[3], cValue, lFontBold, lFontItalic, lFontUnderline, lFontStrikeout, .T., .T., .T., cAlignment )

      Endif

   ELSEIF _HMG_RPTDATA[163]

      DO CASE
         CASE ValType(cValue) == "N" ; cValue := AllTrim(Str(cValue))
         CASE ValType(cValue) == "D" ; cValue := dtoc(cValue)
         CASE ValType(cValue) == "L" ; cValue := if( cValue, _HMG_RPTDATA[371][24], _HMG_RPTDATA[371][25] )
      ENDCASE

      DO CASE
         CASE lAlignment_1 == .F. .and. lAlignment_2 == .T. ; cHtmlAlignment := 'center'
         CASE lAlignment_1 == .T. .and. lAlignment_2 == .F. ; cHtmlAlignment := 'right'
         CASE lAlignment_1 == .F. .and. lAlignment_2 == .F. ; cHtmlAlignment := 'left'
      ENDCASE

      _HMG_RPTDATA[149] += '<div style=position:absolute;left:' + alltrim(str(nCol)) +  'mm;top:' +  alltrim(str(nRow+nOffset)) + 'mm;width:' +  alltrim(str(nWidth)) + 'mm;font-size:' + alltrim(str(nFontSize)) + 'pt;font-family:"' +  cFontname + '";text-align:' + cHtmlAlignment + ';font-weight:' + if(lFontBold,'bold','normal') + ';font-style:' + if(lFontItalic,'italic','normal') + ';text-decoration:' + if(lFontUnderLine,'underline','none') + ';color:rgb(' + alltrim(str(aFontColor[1])) + ',' + alltrim(str(aFontColor[2])) + ',' +  alltrim(str(aFontColor[3])) + ');>' + cValue + '</div>' + chr(13) + chr(10)

   ELSEIF _HMG_RPTDATA[150]

      DO CASE
         CASE ValType(cValue) == "N" ; cValue := AllTrim(Str(cValue))
         CASE ValType(cValue) == "D" ; cValue := dtoc(cValue)
         CASE ValType(cValue) == "L" ; cValue := if( cValue, _HMG_RPTDATA[371][24], _HMG_RPTDATA[371][25] )
      ENDCASE

		DO CASE
		   CASE lFontBold == .f. .and. lFontItalic == .f. ; nFontStyle := 0
		   CASE lFontBold == .t. .and. lFontItalic == .f. ; nFontStyle := 1
		   CASE lFontBold == .f. .and. lFontItalic == .t. ; nFontStyle := 2
		   CASE lFontBold == .t. .and. lFontItalic == .t. ; nFontStyle := 3
      ENDCASE

      pdfSetFont( cFontname, nFontStyle, nFontSize )

      If lAlignment_1 == .F. .and.  lAlignment_2  // Center

         If lFontUnderLine
            pdfAtSay ( cValue + chr(254), nRow + nOffset + nTextRowFix, nCol + ( nWidth - ( pdfTextWidth( cValue ) * 25.4 ) ) / 2, 'M' )
         Else
            pdfAtSay ( chr(253) + chr(aFontColor[1]) + chr(aFontColor[2]) + chr(aFontColor[3]) + cValue, nRow + nOffset + nTextRowFix, nCol + ( nWidth - ( pdfTextWidth( cValue ) * 25.4 ) ) / 2, 'M' )
         EndIf

      ElseIf lAlignment_1 .and.  lAlignment_2 == .F. // Right

         If lFontUnderLine
            pdfAtSay ( cValue + chr(254), nRow + nOffset + nTextRowFix, nCol + nWidth - pdfTextWidth( cValue ) * 25.4, 'M' )
         Else
            pdfAtSay ( chr(253) + chr(aFontColor[1]) + chr(aFontColor[2]) + chr(aFontColor[3]) + cValue, nRow + nOffset + nTextRowFix, nCol + nWidth - pdfTextWidth( cValue ) * 25.4, 'M' )
         EndIf

      ElseIf lAlignment_1 == .F. .and.  lAlignment_2 == .F. // Left

         If lFontUnderLine
            pdfAtSay ( cValue + chr(254), nRow + nOffset + nTextRowFix, nCol, 'M' )
         Else
            pdfAtSay ( chr(253) + chr(aFontColor[1]) + chr(aFontColor[2]) + chr(aFontColor[3]) + cValue, nRow + nOffset + nTextRowFix, nCol, 'M' )
         EndIf

      EndIf

   ENDIF

Return( cValue )

*-----------------------------------------------------------------------------*
Procedure _PrintImage( aObject, nOffset )
*-----------------------------------------------------------------------------*
	Local cValue   := aObject[2]
	Local nRow     := aObject[3]
	Local nCol     := aObject[4]
	Local nWidth   := aObject[5]
	Local nHeight  := aObject[6]
	Local lStretch := aObject[7]

   IF _HMG_RPTDATA[150] == .F. .AND. _HMG_RPTDATA[163] == .F.

      if drv = "H"
         hbprn:picture(nRow + nOffset,nCol, nHeight, nWidth, cValue, Nil, Nil )
      Else
         _HMG_PRINTER_H_IMAGE ( _HMG_PRINTER_HDC, cValue, nRow + nOffset, nCol, nHeight, nWidth, .T. )
      Endif

   ELSEIF _HMG_RPTDATA[150]

      IF UPPER( RIGHT( cValue, 4 ) ) == '.JPG'
         pdfImage( cValue, nRow + nOffset, nCol, "M", nHeight, nWidth )
      ELSE
         MsgMiniGuiError("Report: Only JPG images allowed" )
      ENDIF

   ELSEIF _HMG_RPTDATA[163]

      _HMG_RPTDATA[149] += '<div style=position:absolute;left:' + alltrim(str(nCol)) + 'mm;top:' + alltrim(str(nRow+nOffset))  + 'mm;> <img src="' + cValue + '" ' + 'width=' + alltrim(str(nWidth*3.85)) + 'mm height=' + alltrim(str(nHeight*3.85)) + 'mm/> </div>' + chr(13) + chr(10)

   ENDIF

Return

*-----------------------------------------------------------------------------*
Procedure _PrintLine( aObject, nOffset )
*-----------------------------------------------------------------------------*
	Local nFromRow  := aObject[2]
	Local nFromCol  := aObject[3]
	Local nToRow    := aObject[4]
	Local nToCol    := aObject[5]
	Local nPenWidth := aObject[6]
	Local aPenColor := aObject[7]

   IF _HMG_RPTDATA[150] == .F. .AND. _HMG_RPTDATA[163] == .F.
      if drv = "H"
         Hbprn:modifypen("P0", Nil, nPenWidth * 25.4, { aPenColor[1], aPenColor[2], aPenColor[3] } )
         hbprn:line( nFromRow + nOffset, nFromCol, nToRow  + nOffset, nToCol, "P0" )
      Else
      _HMG_PRINTER_H_LINE ( _HMG_PRINTER_HDC, nFromRow + nOffset, nFromCol, nToRow  + nOffset, nToCol, nPenWidth, aPenColor[1], aPenColor[2], aPenColor[3], .T., .T. )
      Endif

   ELSEIF _HMG_RPTDATA[150]

      If nFromRow <> nToRow .and. nFromCol <> nToCol
         MsgMiniGUIError('Report: Only horizontal and vertical lines are supported with PDF output')
      EndIf

      pdfBox( nFromRow + nOffset, nFromCol, nToRow + nOffset + nPenWidth, nToCol, 0, 1, "M", CHR(253) + CHR(aPenColor[1]) + CHR(aPenColor[2]) + CHR(aPenColor[3]) )

   ELSEIF _HMG_RPTDATA[163]

      _HMG_RPTDATA[149] += '<div style="left:' + alltrim(str(nFromCol)) + 'mm;top:' +  alltrim(str(nFromRow+nOffset)) +  'mm;width:' +  alltrim(str(nToCol-nFromCol)) +  'mm;height:0mm;BORDER-STYLE:SOLID;BORDER-COLOR:' + 'rgb(' + alltrim(str(aPenColor[1])) + ',' + alltrim(str(aPenColor[2])) + ',' +  alltrim(str(aPenColor[3])) + ')' + ';BORDER-WIDTH:' + alltrim(str(nPenWidth)) + 'mm;BACKGROUND-COLOR:#FFFFFF;"><span class="line"></span></DIV>' + chr(13) + chr(10)

   ENDIF

Return

*-----------------------------------------------------------------------------*
Procedure _PrintRectangle( aObject, nOffset )
*-----------------------------------------------------------------------------*
	Local nFromRow  := aObject[2]
	Local nFromCol  := aObject[3]
	Local nToRow    := aObject[4]
	Local nToCol    := aObject[5]
	Local nPenWidth := aObject[6]
	Local aPenColor := aObject[7]


   IF _HMG_RPTDATA[150] == .F. .AND. _HMG_RPTDATA[163] == .F.

      if drv = "H"
         Hbprn:modifypen( "P0", Nil, nPenWidth * 25.4, { aPenColor[1], aPenColor[2], aPenColor[3] } )
         hbprn:rectangle( nFromRow + nOffset, nFromCol, nToRow  + nOffset, nToCol, "p0", Nil )
      Else
      _HMG_PRINTER_H_RECTANGLE ( _HMG_PRINTER_HDC, nFromRow + nOffset, nFromCol, nToRow  + nOffset, nToCol, nPenWidth, aPenColor[1], aPenColor[2], aPenColor[3], .T., .T. )
      Endif

   ELSEIF _HMG_RPTDATA[150]

      pdfBox( nFromRow + nOffset, nFromCol, nFromRow + nOffset + nPenWidth, nToCol              , 0, 1, "M", CHR(253) + CHR(aPenColor[1]) + CHR(aPenColor[2]) + CHR(aPenColor[3]) )
      pdfBox( nToRow   + nOffset, nFromCol, nToRow   + nOffset + nPenWidth, nToCol              , 0, 1, "M", CHR(253) + CHR(aPenColor[1]) + CHR(aPenColor[2]) + CHR(aPenColor[3]) )
      pdfBox( nFromRow + nOffset, nFromCol, nToRow   + nOffset            , nFromCol + nPenWidth, 0, 1, "M", CHR(253) + CHR(aPenColor[1]) + CHR(aPenColor[2]) + CHR(aPenColor[3]) )
      pdfBox( nFromRow + nOffset, nToCol  , nToRow   + nOffset            , nToCol   + nPenWidth, 0, 1, "M", CHR(253) + CHR(aPenColor[1]) + CHR(aPenColor[2]) + CHR(aPenColor[3]) )

   ELSEIF _HMG_RPTDATA[163]

      _HMG_RPTDATA[149] += '<div style="left:' + alltrim(str(nFromCol)) + 'mm;top:' +  alltrim(str(nFromRow+nOffset)) +  'mm;width:' +  alltrim(str(nToCol-nFromCol)) +  'mm;height:' + alltrim(str(nToRow-nFromRow)) + 'mm;BORDER-STYLE:SOLID;BORDER-COLOR:' + 'rgb(' + alltrim(str(aPenColor[1])) + ',' + alltrim(str(aPenColor[2])) + ',' +  alltrim(str(aPenColor[3])) + ')' + ';BORDER-WIDTH:' + alltrim(str(nPenWidth)) + 'mm;BACKGROUND-COLOR:#FFFFFF;"><span class="line"></span></DIV>' + chr(13) + chr(10)

   ENDIF

Return

* Line **********************************************************************

Procedure _BeginLine

   _HMG_RPTDATA[110] := 0            // FromRow
   _HMG_RPTDATA[111] := 0            // FromCol
   _HMG_RPTDATA[112] := 0            // ToRow
   _HMG_RPTDATA[113] := 0            // ToCol
   _HMG_RPTDATA[114] := 1            // PenWidth
   _HMG_RPTDATA[115] := { 0, 0, 0 }  // PenColor

Return


Procedure _EndLine

   Local aLine

   aLine := { 'LINE'           ,;
			     _HMG_RPTDATA[110],;
			     _HMG_RPTDATA[111],;
			     _HMG_RPTDATA[112],;
			     _HMG_RPTDATA[113],;
			     _HMG_RPTDATA[114],;
			     _HMG_RPTDATA[115] }

   DO CASE
      CASE _HMG_RPTDATA[161] == 'HEADER'      ; aadd( _HMG_RPTDATA[160], aLine )
      CASE _HMG_RPTDATA[161] == 'DETAIL'      ; aadd( _HMG_RPTDATA[158], aLine )
      CASE _HMG_RPTDATA[161] == 'FOOTER'      ; aadd( _HMG_RPTDATA[157], aLine )
      CASE _HMG_RPTDATA[161] == 'SUMMARY'     ; aadd( _HMG_RPTDATA[126], aLine )
      CASE _HMG_RPTDATA[161] == 'GROUPHEADER' ; aadd( _HMG_RPTDATA[121], aLine )
      CASE _HMG_RPTDATA[161] == 'GROUPFOOTER' ; aadd( _HMG_RPTDATA[122], aLine )
   ENDCASE

Return

* Image **********************************************************************

Procedure _BeginImage

   _HMG_ActiveControlValue   := ''   // Value
   _HMG_ActiveControlRow     := 0    // Row
   _HMG_ActiveControlCol     := 0    // Col
   _HMG_ActiveControlWidth   := 0    // Width
   _HMG_ActiveControlHeight  := 0    // Height
   _HMG_ActiveControlStretch := .F.  // Stretch

Return


Procedure _EndImage

	Local aImage

   aImage := { 'IMAGE'                 ,;
			      _HMG_ActiveControlValue ,;
			      _HMG_ActiveControlRow   ,;
			      _HMG_ActiveControlCol   ,;
			      _HMG_ActiveControlWidth ,;
			      _HMG_ActiveControlHeight,;
			      _HMG_ActiveControlStretch }

   DO CASE
      CASE _HMG_RPTDATA[161] == 'HEADER'      ; aadd( _HMG_RPTDATA[160], aImage )
      CASE _HMG_RPTDATA[161] == 'DETAIL'      ; aadd( _HMG_RPTDATA[158], aImage )
      CASE _HMG_RPTDATA[161] == 'FOOTER'      ; aadd( _HMG_RPTDATA[157], aImage )
      CASE _HMG_RPTDATA[161] == 'SUMMARY'     ; aadd( _HMG_RPTDATA[126], aImage )
      CASE _HMG_RPTDATA[161] == 'GROUPHEADER' ; aadd( _HMG_RPTDATA[121], aImage )
      CASE _HMG_RPTDATA[161] == 'GROUPFOOTER' ; aadd( _HMG_RPTDATA[122], aImage )
   ENDCASE

Return

* Rectangle **********************************************************************

Procedure _BeginRectangle

   _HMG_RPTDATA[110] := 0            // FromRow
   _HMG_RPTDATA[111] := 0            // FromCol
   _HMG_RPTDATA[112] := 0            // ToRow
   _HMG_RPTDATA[113] := 0            // ToCol
   _HMG_RPTDATA[114] := 1            // PenWidth
   _HMG_RPTDATA[115] := { 0, 0, 0 }  // PenColor

Return


Procedure _EndRectangle

	Local aRectangle

   aRectangle := { 'RECTANGLE'      ,;
				       _HMG_RPTDATA[110],;
				       _HMG_RPTDATA[111],;
				       _HMG_RPTDATA[112],;
				       _HMG_RPTDATA[113],;
				       _HMG_RPTDATA[114],;
				       _HMG_RPTDATA[115] }

   DO CASE
      CASE _HMG_RPTDATA[161] == 'HEADER'      ; aadd( _HMG_RPTDATA[160], aRectangle )
      CASE _HMG_RPTDATA[161] == 'DETAIL'      ; aadd( _HMG_RPTDATA[158], aRectangle )
      CASE _HMG_RPTDATA[161] == 'FOOTER'      ; aadd( _HMG_RPTDATA[157], aRectangle )
      CASE _HMG_RPTDATA[161] == 'SUMMARY'     ; aadd( _HMG_RPTDATA[126], aRectangle )
      CASE _HMG_RPTDATA[161] == 'GROUPHEADER' ; aadd( _HMG_RPTDATA[121], aRectangle )
      CASE _HMG_RPTDATA[161] == 'GROUPFOOTER' ; aadd( _HMG_RPTDATA[122], aRectangle )
   ENDCASE

Return

*..............................................................................
Procedure _BeginGroup()
*..............................................................................

   _HMG_RPTDATA[161] := 'GROUP'
   _HMG_RPTDATA[120] ++

Return

*..............................................................................
Procedure _EndGroup()
*..............................................................................
Return

*..............................................................................
Procedure _BeginGroupHeader()
*..............................................................................
   _HMG_RPTDATA[161] := 'GROUPHEADER'
Return

*..............................................................................
Procedure _EndGroupHeader()
*..............................................................................
Return

*..............................................................................
Procedure _BeginGroupFooter()
*..............................................................................
   _HMG_RPTDATA[161] := 'GROUPFOOTER'
Return

*..............................................................................
Procedure _EndGroupFooter()
*..............................................................................
Return

*..............................................................................
Function _dbSum( cField )
*..............................................................................
	Local nVar := 0

   if type( cField ) == 'N'
      SUM &(cField) TO nVar
   EndIf

Return nVar

*..............................................................................
Procedure _BeginData()
*..............................................................................
Return

*..............................................................................
Procedure _EndData()
*..............................................................................
Return