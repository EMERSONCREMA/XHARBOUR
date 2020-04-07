/*

 MaxIni.prg
 Descricao: Biblioteca de funcoes para geracao de arquivos de inicializacao.
 Desenvolvido por MAX SCALLA Informatica Ltda.
 
 EMERSON DA SILVA CREMA
 10/07/19 * Desenvolvido IniDestroy() e IniClose().
          * Correcao na definicao de lWrite em IniWrite(), pois estava
            gerando o arquivo .INI mesmo com o parametro = .T..
 16/11/18 * Desenvolvido HB_IniSetVar() e HB_IniWrite().

 DENIS MAZZUCATTO RODRIGUES
 03/10/11 * Alteracoes em IniAddSection() e IniAddLine() p/ verificar se a
            sessao/chave ja existem.

 EMERSON DA SILVA CREMA
 08/11/06 * Desenvolvimento de IniCreate(), IniSetSection() e IniSetLine().
 03/02/06 * Implementado parametro lWrite em IniStart(). Isto reflete em todas
            outras funcoes.
 22/10/04 * Implementacao de IniLoad() e IniGetVar().

*/

#include "std.ch"

STATIC cIniFile        := ""
STATIC cTmpFile        := ""
STATIC aIniStructure   := {}
STATIC nCurrentSection := 0
STATIC lIniWrite       := .F.
STATIC nIniFile        := -1
STATIC hIniFile


FUNCTION IniStart( cDefIniFile, lWrite )

   vDef( @lWrite, .F. )

   lIniWrite       := lWrite
   aIniStructure   := {}
   nCurrentSection := 0
   cTmpFile        := ""
   cIniFile        := cDefIniFile

   IF lWrite
      IniCreate()
   ENDIF

RETURN( NIL )



FUNCTION IniAddSection( cSection, lOverWrite )

   LOCAL cWriteSection := "[" + cSection + "]"
   LOCAL nWriteSection := aScan( aIniStructure, { |x| x[1] = cWriteSection } )

   vDef( @lOverWrite, .F. )

   IF nWriteSection > 0
      nCurrentSection := nWriteSection
      IF lOverWrite
         aIniStructure[ nWriteSection ] := { cWriteSection, {} }
      ENDIF
   ELSEIF lIniWrite
      IF nCurrentSection > 0
         FWrite( nIniFile, _NL )
      ENDIF
      FWrite( nIniFile, cWriteSection + _NL )
      nCurrentSection ++
   ELSE
      aAdd( aIniStructure, { cWriteSection, {} } )
      nCurrentSection := Len( aIniStructure )
   ENDIF

RETURN( NIL )



FUNCTION IniSetSection( cSection )

   LOCAL cWriteSection := "[" + cSection + "]"

   nCurrentSection := aScan( aIniStructure, { |x| x[1] = cWriteSection } )

   IF nCurrentSection = 0
      aAdd( aIniStructure, { cWriteSection, {} } )
      nCurrentSection := Len( aIniStructure )
   ENDIF

RETURN( NIL )



FUNCTION IniAddLine( cVar, cInfo )

   LOCAL aSection

   IF lIniWrite

      FWrite( nIniFile, cVar + "=" + AllTrim( UtoC( cInfo ) ) + _NL )

   ELSE

      aSection := aIniStructure[ nCurrentSection, 2 ]

      IF aScan( aSection, { |x| x[1] = cVar } ) = 0

         aAdd( aSection, { cVar, UtoC( cInfo ) } )

         aIniStructure[ nCurrentSection, 2 ] := aSection

      ENDIF

   ENDIF

RETURN( NIL )



FUNCTION IniSetLine( cVar, cInfo )

   LOCAL aSection := aIniStructure[ nCurrentSection, 2 ]
   LOCAL nSection := aScan( aSection, { |x| x[1] = cVar } )

   IF nSection = 0
      aAdd( aSection, { cVar, NIL } )
      nSection := Len( aSection )
   ENDIF

   aSection[ nSection, 2 ] := UtoC( cInfo )

   aIniStructure[ nCurrentSection, 2 ] := aSection

RETURN( NIL )



FUNCTION IniWrite( lMemory )

   LOCAL cWrite := ""
   
   LOCAL nCount, aSection, cSection, nInfo, cMove

   vDef( @lMemory, .F. )

   IF ! lIniWrite

      IF ! lMemory
         IniCreate()
      ENDIF

      FOR nCount := 1 TO Len( aIniStructure )

         IF nCount <> 1
            IF lMemory
               cWrite += _NL
            ELSE
               FWrite( nIniFile, _NL )
            ENDIF
         ENDIF

         cSection := aIniStructure[ nCount, 1 ]
         aSection := aIniStructure[ nCount, 2 ]

         IF lMemory
            cWrite += cSection + _NL
         ELSE
            FWrite( nIniFile, cSection + _NL )
         ENDIF

         FOR nInfo := 1 TO Len( aSection )

            IF lMemory
               cWrite += aSection[ nInfo, 1 ] + "=" + AllTrim( aSection[ nInfo, 2 ] ) + _NL
            ELSE
               FWrite( nIniFile, aSection[ nInfo, 1 ] + "=" + AllTrim( aSection[ nInfo, 2 ] ) + _NL )
            ENDIF

         NEXT

      NEXT

   ENDIF

   IF ! lMemory

      FClose( nIniFile )

      IF IsDifDrv( cTmpFile, cIniFile )
         cMove := ConfPath( GetPath( cIniFile ) ) + DelPath( cTmpFile )
         mxFCopy( cTmpFile, cMove )
         mxFMove( cMove, cIniFile )
         mxFDel( cTmpFile )
      ELSE
         mxFMove( cTmpFile, cIniFile )
      ENDIF
      
   ENDIF

   lIniWrite := .F.

RETURN( cWrite )



FUNCTION IniClose()

   LOCAL lReturn := .T.

   TRY
      fClose( nIniFile )
   CATCH
      lReturn := .F.
   END

RETURN( lReturn )



FUNCTION IniDestroy()

   LOCAL lReturn := IniClose()

   TRY
      IF lReturn
         lReturn := mxFDel( cTmpFile )
      ENDIF
   CATCH
      lReturn := .F.
   END

RETURN( lReturn )



FUNCTION IniLoad( cIniFile )

   LOCAL lReturn := .F.

   LOCAL nIniFile, cInfo, cSection, cVar

   IF File( cIniFile )

      nIniFile := mxFOpen( cIniFile )

      IniStart( cIniFile )

      DO WHILE LineRead( nIniFile, @cInfo )

         IF Left( cInfo, 1 ) = "["
            cSection := ClearMasc( cInfo, "[]" )
            IniAddSection( cSection )
         ELSE
            cVar := Left( cInfo, At( "=", cInfo ) -1 )
            IF ! Empty( cVar )
               IniAddLine( cVar, Subs( cInfo, At( "=", cInfo ) +1 ) )
            ENDIF
         ENDIF

      ENDDO

      FClose( nIniFile )

      lReturn := .T.

   ELSE

      IniStart( cIniFile, .F. )
   
   ENDIF

RETURN( lReturn )



FUNCTION IniGetVar( cSection, cVar, cEmpty )

   LOCAL cReturn := ""
   LOCAL nSection := aScan( aIniStructure, { |s| s[1] = "[" + cSection + "]" } )

   LOCAL aSection, nVar

   IF nSection <> 0
      aSection := aIniStructure[ nSection, 2 ]
      nVar := aScan( aSection, { |v| v[1] = cVar } )
      IF nVar <> 0
         cReturn := aSection[ nVar, 2 ]
      ENDIF
   ENDIF

   IF Empty( cReturn ) .AND. cEmpty <> NIL
      cReturn := cEmpty
   ENDIF

RETURN( cReturn )



FUNCTION IniGetSection( cSection )

   LOCAL aSection := {}
   LOCAL nSection := aScan( aIniStructure, { |s| s[1] = "[" + cSection + "]" } )

   IF nSection <> 0
      aSection := aIniStructure[ nSection, 2 ]
   ENDIF

RETURN( aSection )



STATIC FUNCTION IniCreate()

   cTmpFile := "TEMP" + DefArqTmp( NIL, ".INI" ) + ".INI"
   nIniFile := mxFCreate( cTmpFile )

RETURN( NIL )



FUNCTION HB_IniLoad( cFile )

   LOCAL lReturn := .F.

   IF File( cFile )

      hIniFile := HB_ReadIni( cFile )
      cIniFile := cFile

      lReturn := .T.

   ENDIF

RETURN( lReturn )



FUNCTION HB_IniGetVar( cSection, cVar, cEmpty )

   LOCAL cReturn := ""

   vDef( @cEmpty, "" )

   IF ! Empty( cIniFile )

      TRY
         cReturn := hIniFile[ cSection ][ cVar ]
      CATCH
         cReturn := ""
      END

   ENDIF

   cReturn := GetNoEmpty( cReturn, cEmpty )

RETURN( cReturn )



FUNCTION HB_IniSetVar( cSection, cVar, cValue )

   LOCAL lReturn := .F.

   IF ! Empty( cIniFile )

      TRY
         hIniFile[ cSection ][ cVar ] := cValue
         lReturn := .T.
      CATCH
      END

   ENDIF

RETURN( lReturn )



FUNCTION HB_IniWrite()

   LOCAL lReturn := .F.

   IF ! Empty( cIniFile )

      TRY
         lReturn := HB_WriteIni( cIniFile, hIniFile, "", "" )
      CATCH
      END

   ENDIF

RETURN( lReturn )