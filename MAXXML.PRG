


FUNCTION xmlGetTag( cXML, cParTagI, cParTagE, cFormat )

   LOCAL uReturn := ""

   LOCAL cXMLAux, cTag_I, cTag_E, nPos

   IF cParTagE = NIL
      cParTagE := cParTagI
   ENDIF

   cXMLAux := Upper( cXML )

   cTag_I := "<"  + Upper( cParTagI ) + ">"
   cTag_E := "</" + Upper( cParTagE ) + ">"

   nPos := At( cTag_I, cXMLAux )

   IF nPos > 0

      nPos += Len( cTag_I )

      uReturn := Subs( cXML, nPos )

      cXMLAux := Upper( uReturn )

      nPos := At( cTag_E, cXMLAux )

      IF nPos > 0
         nPos --
         uReturn := Left( uReturn, nPos )
      ENDIF

   ENDIF

   DO CASE
      CASE cFormat == "N"                          ; uReturn := Val( uReturn )
      CASE cFormat == "N,"                         ; uReturn := StrTran( uReturn, ".", "," )
      CASE cFormat == "D"                          ; uReturn := DtoC( uReturn )
      CASE cFormat == "SD"                         ; uReturn := StoD( uReturn )
      CASE cFormat <> NIL .AND. ! Empty( uReturn ) ; uReturn := Tran( uReturn, cFormat )
   ENDCASE

RETURN( uReturn )