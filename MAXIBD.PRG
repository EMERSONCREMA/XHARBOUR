/*

 MaxImpBD.prg
 Descricao: Biblioteca de funcoes p/ importacao de bancos de dados.
 Desenvolvido por MAX SCALLA Informatica Ltda.

 EMERSON DA SILVA CREMA
 25/01/19 * Inicio do desenvolvimento.

*/

#include "std.ch"
#include "inkey.ch"
#include "sqlrdd.ch"
#include "maxonl.ch"
#include "b:\desenvolvimento\sistemas\cs\loja\fontes\maxsetcf.ch"


FUNCTION c_date( cDate )

   IF AllTrim( cDate ) = "NULL"
      cDate := ""
   ELSE
      cDate := Subs( cDate, 9, 2 ) + "-" + Subs( cDate, 6, 2 ) + "-" + Left( cDate, 4 )
   ENDIF

RETURN( CtoD( cDate ) )



FUNCTION c_val( cInfo )

   cInfo := AllTrim( cInfo )
   cInfo := If( Upper( cInfo ) == "NULL", "0", cInfo )
   cInfo := StrTran( cInfo, ",", "." )

RETURN( Val( cInfo ) )



FUNCTION c_str( cInfo )

   cInfo := AllTrim( cInfo )
   cInfo := If( Upper( cInfo ) == "NULL", "", cInfo )

RETURN( TiraEspacos( CharRemove( cInfo ) ) )