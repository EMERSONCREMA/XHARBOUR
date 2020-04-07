/*

 MaxNetX.prg
 Descricao: Biblioteca de funcoes de acesso a banco de dados CDX.
 Desenvolvido por MAX SCALLA Informatica Ltda.
 
 EMERSON DA SILVA CREMA
 11/03/20 * Desenvolvido mxDBFSeek().
 08/04/14 * Movido Acha() para MAXNET.PRG
 06/09/13 * Implementacao em Close_aCdx() p/verificar se cTmp <> NIL.
 
 DENIS MAZZUCATTO RODRIGUES
 18/07/13 * Correcao em Open_aCdx() pois qdo selecionado p/ criar o temp via
            SQL nao tem como ser em memoria.

 EMERSON DA SILVA CREMA
 07/05/13 * Correcao em Open_aCdx() qdo usava SQL com temp em memoria, pois
            fechava a tabela antes de indexar.
 22/04/13 * Correcao em Open_aCdx(), pois nao criava temporario em memoria qdo
            selecionado p/ executar SQL.

 DENIS MAZZUCATTO RODRIGUES
 29/06/12 * Implementada gravacao dos arq temporarios na pasta Windows Temp.

 EMERSON DA SILVA CREMA
 23/05/07 * Remocao de Sele_Ordem() e mSeek().
 09/01/07 * Remocao de ConfStrutura(), UseIndexs(), Open_Area(), Close_Area()
            e IndexDbf().
          * Movida as funcoes direto p/ versao 2.12c: ConfStuCdx(), OpenDbf(),
            bReco(), NAppe(), mUnlock(), Top(), Bottom() e Ordem().
 16/05/06 * Desenvolvimento de mxTmpCreate() e mxTmpClose().
          * Implementado esquema p/ delecao de arquivos temporarios pendentes.
            P/ isso criada matriz aTmpCreate e implementada em mxTmpCreate().
          * Implementada mxTmpClose() em Close_aCDX() e Close_Area().
          * Removidos dos 3 ultimos parametros de Close_Area().
          * Trocada a programacao de Open_aCdx() e Open_Area() pela a
            implementacao de mxTmpCreate() nas mesmas.
          * Desenvolvimento de tmpDel() e tmpClear().
          * Renomeada VerifyStuCdx() p/ VerifyStu() e implementado parametro
            lCdx.
          * Removida VerifyStruc() e trocada por VerifyStu().
*/

#include "std.ch"
#include "inkey.ch"
#include "common.ch"
#include "dataEdit.ch"

STATIC aTmpCreate := {}
STATIC lTmpMemory := .F.


FUNCTION Open_aCdx( cArquivo, uCreate, Cdx1, Cdx2, Cdx3, Cdx4, Cdx5, Cdx6, Cdx7 )

   // Seleciona uma area vazia entre 100 e 250 p/ abertura de DBF

   LOCAL cFile := cArquivo
   LOCAL cReturn

   IF ! TempInMemory()
      IF cFile <> NIL .AND. ! IsUsePath( cFile ) .AND. Upper( Left( cFile, 4 ) ) = "TEMP"
         cFile := mxDirTemp() + cFile
      ENDIF
   ENDIF

   IF sqlActive() .AND. ValType( uCreate ) = "C" .AND. Upper( Left( uCreate, 7 ) ) = "SELECT "

      IF cArquivo = NIL
         cArquivo := DefArqTmp( mxDirTemp() )
         cFile    := mxDirTemp() + "TEMP" + cArquivo + ".DBF"
         TempInMemory( .F. )
      ENDIF

      //sqlExecute( uCreate, cFile, .F., NIL, NIL, NIL, NIL, .T. )
      sqlExecute( uCreate, cFile, .F. )

      IF ! TempInMemory()
         mxClose( GetNameFile( cFile ) )
      ENDIF

      uCreate := NIL

   ENDIF

   cReturn := mxTmpCreate( cFile, uCreate, Cdx1, Cdx2, Cdx3, Cdx4, Cdx5, Cdx6, Cdx7, .F. )

   TempInMemory( .F. )

RETURN( cReturn )



PROCEDURE Close_aCdx( cTmp )

   IF cTmp <> NIL
      mxTmpClose( cTmp )
   ENDIF

RETURN



STATIC FUNCTION mxTmpCreate( cArquivo, uCreate, Idx1, Idx2, Idx3, Idx4, Idx5, Idx6, Idx7, lNtx )

   LOCAL cFileDbf := cArquivo
   LOCAL cFileIdx, cAliasArea, cTempArea, nIdx, nArea, aIdx, nTry

   vDef( @lNtx, .F. )

   IF ! IsUseExt( cArquivo )
      cFileDbf := ModExt( cArquivo, "DBF" )
   ENDIF

   cFileDbf := Upper( cFileDbf )
   cFileIdx := Upper( ModExt( cArquivo, If( lNtx, "NTX", "CDX" ) ) )

   mxFDel( cFileIdx )

   cAliasArea := DelExt( GetNameFile( cFileDbf ) )
   
   IF uCreate <> NIL
      IF ValType( uCreate ) = "C"
         SeleArea( uCreate )
         uCreate := xDbStruct()
      ENDIF
      IF TempInMemory()
         Hb_DbCreateTemp( cAliasArea, uCreate, If( lNtx, "DBFNTX", "DBFCDX" ) )
      ELSE
         FOR nTry := 1 TO 3
            TRY
               DbCreate( cFileDbf, uCreate, If( lNtx, "DBFNTX", "DBFCDX" ) )
            CATCH
            END
            IF File( cFileDbf )
               EXIT
            ENDIF
         NEXT
      ENDIF
   ENDIF

   IF TempInMemory()
   
      aAdd( aTmpCreate, { cAliasArea, Time() } )

      cTempArea := NumToStr( Select() )

      IF Idx1 <> NIL
         IF ValType( Idx1 ) = "A"
            aIdx := aClone( Idx1 )
         ELSE
            aIdx := {}
            FOR nIdx := 3 TO PCount() -1
               aAddC( aIdx, PValue( nIdx ), PValue( nIdx ) <> NIL )
            NEXT
         ENDIF
         mxTmpIndex( cAliasArea, aIdx, lNtx )
      ENDIF

      RETURN( cTempArea )
      
   ENDIF
   
   aAddC( aTmpCreate, { cFileDbf, Time() }, File( cFileDbf ) )

   DO WHILE .T.

      FOR nRetry := 1 TO 3

         DbUseArea( .T., If( lNtx, "DBFNTX", "DBFCDX" ), cFileDbf, cAliasArea, .F., .F. )
         
         nArea := Select( cAliasArea )

         IF nArea = 0
            LOOP
         ENDIF

         Select( cAliasArea )

         IF Alias() <> cAliasArea
            LOOP
         ENDIF

         cTempArea := Ltrim( Str( nArea, 3 ) )

         IF Idx1 <> NIL

            IF ValType( Idx1 ) = "A"
               aIdx := aClone( Idx1 )
            ELSE
               aIdx := {}
               FOR nIdx := 3 TO PCount() -1
                  aAddC( aIdx, PValue( nIdx ), PValue( nIdx ) <> NIL )
               NEXT
            ENDIF

            mxTmpIndex( cFileIdx, aIdx, lNtx )

         ENDIF

         RETURN( cTempArea )

      NEXT
      
      MsgDlg( "Nao existem areas disponiveis no sistema;para geracao de arquivos temporarios !" )

      Mensagem( "Aguarde um momento, selecionando  rea de trabalho...", 1 )

      IF mxIn( mxInKey( 0.01 ), { 81, 113 } )
         Fim( 0 )
      ENDIF

      FOR nArea := 1 TO Len( aTmpCreate )
         IF aTmpCreate[ nArea, 1 ] <> cFileDbf .AND. Elaptime( aTmpCreate[ nArea, 2 ], Time() ) > "00:30:00"
            mxTmpClose( aTmpCreate[ nArea, 1 ] )
            nArea := 1
         ENDIF
      NEXT

   ENDDO

RETURN( NIL )



PROCEDURE mxTmpIndex( cFileIdx, aIdx, lNtx )

   LOCAL nIdx, cTagIndex, cKeyIndex, cTela

   vDef( @lNtx, .F. )

   cFileIdx := Upper( ModExt( cFileIdx, If( lNtx, "NTX", "CDX" ) ) )
   
   FOR nIdx := 1 TO Len( aIdx )

      IF ValType( aIdx[ nIdx ] ) = "A"
         cTagIndex := aIdx[ nIdx, 1 ]
         cKeyIndex := aIdx[ nIdx, 2 ]
      ELSE
         cTagIndex := NumToStr( nIdx )
         cKeyIndex := aIdx[ nIdx ]
      ENDIF

      IF cKeyIndex <> NIL
         IF cTela = NIL
            cTela := SaveScreen( MaxRow(), 00, MaxRow(), MaxCol() )
         ENDIF
         Status( "Gerando " + DelExt( cFileIdx ) + "_" + cTagIndex + "...", NIL, 1 )
         IF TempInMemory()
            IF lNtx
               INDEX ON &cKeyIndex TO &cFileIdx MEMORY ADDITIVE
            ELSE
               INDEX ON &cKeyIndex TAG &cTagIndex TO &cFileIdx MEMORY ADDITIVE
            ENDIF
         ELSEIF lNtx
            INDEX ON &cKeyIndex TO &cFileIdx
         ELSE
            INDEX ON &cKeyIndex TAG &cTagIndex TO &cFileIdx
         ENDIF
      ENDIF

   NEXT

   IF ! TempInMemory()
      SET INDEX TO &cFileIdx
   ENDIF
   
   IF cTela <> NIL
      RestScreen( MaxRow(), 00, MaxRow(), MaxCol(), cTela )
   ENDIF

RETURN



STATIC PROCEDURE mxTmpClose( cTmp )

   LOCAL nTmp := aScan( aTmpCreate, { |x| Upper( DelExt( GetNameFile( x[1] ) ) ) = Upper( GetNameFile( DelExt( cTmp ) ) ) } )

   IF nTmp > 0
      tmpDel( aTmpCreate[ nTmp, 1 ] )
      aDel( aTmpCreate, nTmp )
      aSize( aTmpCreate, Len( aTmpCreate ) -1 )
   ELSE
      tmpDel( cTmp )
   ENDIF

RETURN



PROCEDURE tmpClear

   aEval( aTmpCreate, { |tmp| tmpDel( tmp[1] ) } )

RETURN



STATIC PROCEDURE tmpDel( cTmp )

   TRY

      mxClose( DelExt( GetNameFile( cTmp ) ) )

      mxFDel( ModExt( cTmp, "DBF" ) )
      mxFDel( ModExt( cTmp, "DBT" ) )
      mxFDel( ModExt( cTmp, "FPT" ) )
      mxFDel( ModExt( cTmp, "CDX" ) )
      mxFDel( ModExt( cTmp, "NTX" ) )
      
   CATCH
   
   END

RETURN



FUNCTION TempInMemory( lMemory )

   LOCAL lReturn := lTmpMemory
   
   IF lMemory <> NIL
      lTmpMemory := lMemory
   ENDIF
   
RETURN( lReturn )



FUNCTION bFile( TEMPO, SAIDA )

   // Tenta bloquear um arquivo compartilhado em uso.

   LOCAL nTempo := If( TEMPO = NIL, 0, TEMPO )

   DO WHILE .T.
      IF FLock()
         IF SAIDA = NIL
            Mensagem( MS000, 1 )
         ENDIF
         RETURN( .T. )
      ELSE
         IF nTempo ++ > 30
            Mensagem( "Verifique as outras esta‡”es, h  problemas no bloqueio do arquivo !", 1 )
         ENDIF
         IF mxInKey( 0.01 ) = 286
            RETURN( .F. )
         ENDIF
      ENDIF
   ENDDO

RETURN( .F. )



FUNCTION mxDBFSeek( nOrder, uSeek )

   IF nOrder <> NIL .AND. IndexOrd() <> nOrder
      DbSetOrder( nOrder )
   ENDIF

   DbSeek( uSeek )

RETURN( !Eof() )