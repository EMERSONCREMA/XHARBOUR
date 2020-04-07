  ''' <summary>
  ''' Gera os valores p/ atualização os campos de índice (INDKEY_???) da SQLRDD
  ''' </summary>
  ''' <remarks>Última atualização: 05/02/14 por Denis MR</remarks>
  Private Sub UpdIndexSQLRDD(ByRef aFields As List(Of String), ByRef aValues As List(Of String))
 
      Dim dsIndKey As New DataSet
 
      dsIndKey = ExecQuery("SELECT * FROM sr_mgmntindexes WHERE idxcol_ IS NOT NULL AND TRIM(UPPER(table_))=" + QuotedStr(Me.mxTable) + " ORDER BY idxcol_")
 
      aFields = New List(Of String)
      aValues = New List(Of String)
 
      aFields.Clear()
      aValues.Clear()
 
      If IsNotNothingData(dsIndKey) Then
 
          Dim cValue As String
          Dim cKey As String
          Dim aKey As String()
          Dim nRecno As Integer
 
          If Me.Operacao = dbEvent.K_INCLUIR Then
              nRecno = Me.mxRecnoNew()
          Else
              nRecno = Me.mxRecno()
          End If
 
          For nRow = 0 To dsIndKey.Tables(0).Rows.Count - 1
 
              aKey = dsIndKey.Tables(0).Rows(nRow).Item("idxkey_").ToString.Split("+")
 
              For nAux = 0 To aKey.Length - 1
 
                  cKey = aKey(nAux).ToUpper
 
                  If cKey.Length = 9 Then  '' Campo simples
 
                      cValue = Me.oRow.Item(cKey)
 
                  ElseIf cKey.Contains("DTOS(") Then  '' Campo do tipo data
 
                      cKey = cKey.Replace("DTOS(", "")
                      cKey = cKey.Replace(")", "")
 
                      cValue = Me.oRow.Item(cKey).ToString
                      cValue = Subs(cValue, 7, 4) + Subs(cValue, 4, 2) + Subs(cValue, 1, 2)
 
                      If cValue = "00010101" Then cValue = ""
 
                      cValue = PadL(cValue, 8)
 
                  ElseIf cKey.Contains("STR(") Then  '' Campo numérico
 
                      cKey = cKey.Replace("STR(", "")
                      cKey = cKey.Replace(")", "")
                      cKey += ",0,"
 
                      Dim aStr As String() = cKey.Split(",")
 
                      cKey = cKey.Substring(0, 9)
 
                      cValue = Str(Me.oRow.Item(cKey), Val(aStr(1)), Val(aStr(2))).ToString
 
                  ElseIf cKey.Contains("UPPER(") Then  '' String maiúscula
 
                      cKey = cKey.Replace("UPPER(", "")
                      cKey = cKey.Replace(")", "")
 
                      cValue = Me.oRow.Item(cKey).ToString.ToUpper
 
                  ElseIf cKey.Contains("MXDESCEND(") Then
 
                      cKey = cKey.Replace("MXDESCEND(", "")
                      cKey = cKey.Replace(")", "")
 
                      cValue = mxDescend(Me.oRow.Item(cKey).ToString)
 
                  Else
 
                      cKey = cKey.Substring(cKey.IndexOf("CFI"), 9)
 
                      cValue = Me.oRow.Item(cKey).ToString
 
                  End If
 
                  aKey(nAux) = cValue
 
              Next
 
              cValue = ""
              For nAux = 0 To aKey.Length - 1
                  cValue += aKey(nAux)
              Next
 
              cValue = cValue.Replace("00:00:00", "        ") + PadL(nRecno.ToString, 15)
 
              aFields.Add("INDKEY_" + dsIndKey.Tables(0).Rows(nRow).Item("idxcol_").ToString)
              aValues.Add(QuotedStr(cValue))
 
          Next
 
      End If
 
      dsIndKey.Dispose()
 
  End Sub
  
  
  


FUNCTION mxDescend( cStr )

   #define DESC_ASC "|4890|4989|5088|5187|5286|5385|5484|5583|5682" + ;
                    "|5781|6580|6679|6778|6877|6976|7075|7174|7273" + ;
                    "|7372|7471|7570|7669|7768|7867|7966|8065|8157" + ;
                    "|8256|8355|8454|8553|8652|8751|8850|8949|9048"

   LOCAL cReturn := ""

   LOCAL nAux, nCount, nPos

   FOR nCount := 1 TO Len( cStr )

      nAux := Asc( Subs( cStr, nCount, 1 ) )

      nPos := At( "|" + StrZero( nAux, 2 ), DESC_ASC )

      IF nPos = 0
         cReturn += Chr( nAux )
      ELSE
         cReturn += Chr( Val( Subs( DESC_ASC, nPos +3, 2 ) ) )
      ENDIF

    NEXT

RETURN( cReturn )