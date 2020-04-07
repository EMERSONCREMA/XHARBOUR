/*------------------------------------------------------------------------------
 Funcoes para FTP

 EMERSON DA SILVA CREMA
 31/07/13 * Inicio do desenvolvimento
------------------------------------------------------------------------------*/

#include "minigui.ch"
#include "FileIO.ch"
#include "Directry.ch"
#include "sqlrdd.ch"
#include "inkey.ch"
#include "hbclass.ch"

FUNCTION ftpCD( oFtp, cPath )

   LOCAL lReturn := .F.
   LOCAL lError  := .T.
   LOCAL cPSave  := cPath
   LOCAL cCD

   BEGIN SEQUENCE

      IF ! ftpCDAux( oFtp, "/" )
         MsgBox( 'Não foi possível acessar a pasta "/"', "Alerta" )
         BREAK
      ENDIF

      DO WHILE ! Empty( cPath )
         IF At( "/", cPath ) = 0 .OR. cPath = "/"
            cCD := cPath
            cPath := ""
         ELSE
            cCD   := Left( cPath, At( "/", cPath ) -1 )
            cPath := Subs( cPath, At( "/", cPath ) +1 )
         ENDIF
         IF ! ftpCDAux( oFtp, cCD )
            MsgBox( 'Não foi possível acessar a pasta "' + cPSave + '"', "Alerta" )
            BREAK
         ENDIF
      ENDDO

      lReturn := .T.

   ENDSEQUENCE

RETURN( lReturn )



STATIC FUNCTION ftpCDAux( oFtp, cFolder, lMsg )

   LOCAL cMsg    := ""
   LOCAL lReturn := .F.

   vDef( @lMsg, .F. )

   FOR nRetry := 1 TO 10

      oFtp:Reset()

      TRY
         IF oFtp:cwd( cFolder ) .AND. Left( AllTrim( oFtp:cReply ), 3 ) = "250"
            lReturn := .T.
         ENDIF
      CATCH oErr
         cMsg := oErr:Description
      END

      IF lReturn
         cMsg := ""
         EXIT
      ENDIF

      ThreadSleep( 500 )

   NEXT

   IF ! lReturn .AND. lMsg
      MsgBox( "Não foi possível acessar a pasta " + cFolder + " " + cMsg, "Alerta" )
   ENDIF

RETURN( lReturn )