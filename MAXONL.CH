/*----------------------------------------------------------------------------
 MAXONL.CH
 Definicoes para operacoes online.
 
 EMERSON DA SILVA CREMA
 18/08/16 * Implementado ONL_OP_SELECT.
 11/08/14 * Implementado CSW_ATU_???.
 16/08/13 * Implementado ONL_CONN_???.

 DENIS MAZZUCATTO RODRIGUES
 29/11/11 * Implementacao de NCONN_CNX.

 EMERSON DA SILVA CREMA
 05/08/08 * Inicio do desenvolvimento.
----------------------------------------------------------------------------*/

#define ONL_OP_INSERT    "I"
#define ONL_OP_UPDATE    "U"
#define ONL_OP_DELETE    "D"
#define ONL_OP_GETINFO   "G"
#define ONL_OP_GETDIRECT "B"
#define ONL_OP_CONSULT   "C"
#define ONL_OP_REENVIA   "R"
#define ONL_OP_FCO       "F"
#define ONL_OP_NFP       "N"
#define ONL_OP_BOLETO    "O"
#define ONL_OP_SENDIP    "S"
#define ONL_OP_SELECT    "Q"

#define NCONN_CNX  sqlGetConn( "CONN", "CS_CONEXAO" )

#define ONL_CONN_NUM 1
#define ONL_CONN_IPI 2
#define ONL_CONN_IPE 3
#define ONL_CONN_HOR 4

#define CSW_ATU_REC 1
#define CSW_ATU_DAT 2
#define CSW_ATU_SEQ 3
#define CSW_ATU_ARQ 4
#define CSW_ATU_REL 5
#define CSW_ATU_OPE 6
#define CSW_ATU_REF 7
#define CSW_ATU_AUX 8