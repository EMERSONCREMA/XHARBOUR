/*

 MaxWin.ch
 Definições diversas para a biblioteca visual.

 DENIS MAZZUCATTO RODRIGUES
 09/08/10 * Inicio do desenvolvimento.

*/

// Definições p/ WinGet

#define WG_TEXT       "A"
#define WG_MEMO       "B"
#define WG_MEMOEX     "C"
#define WG_NUMERIC    "D"
#define WG_DATE       "E"
#define WG_COMBO      "F"
#define WG_CHECK_H    "G"
#define WG_CHECK_V    "H"
#define WG_RADIO_H    "I"
#define WG_RADIO_V    "J"
#define WG_UF         "K"
#define WG_CNPJ       "L"
#define WG_CPF        "M"
#define WG_FONE       "N"
#define WG_CEP        "O"
#define WG_PASTA      "P"
#define WG_LIST_TEXT  "Q"

// Definições utilizadas em mxWGDefState()

#define WG_NORMAL     NIL
#define WG_INVISIBLE  "A"
#define WG_READONLY   "B"
#define WG_DISABLED   "C"

// Definições internas da classe

#define WG_nRow       1
#define WG_nCol       2
#define WG_cLabel     3
#define WG_cGet       4
#define WG_cType      5
#define WG_uWidth     6
#define WG_uMask      7
#define WG_uMessage   8
#define WG_cState     9
#define WG_aList     10

#define WG_nBox    1
#define WG_cTitle  2
#define WG_aCols   3
#define WG_aPos    4

#define WG_LIST_ALIAS  1
#define WG_LIST_DESCR  2
#define WG_LIST_ROW    3
#define WG_LIST_COL    4
#define WG_LIST_WIDTH  5

// Definições p/ WinMouse

#define WM_MOUSE_LEFT   .T.
#define WM_MOUSE_RIGHT  .F.
#define WM_MOUSE_DOWN   .T.
#define WM_MOUSE_UP     .F.

// Definições p/ WinForm

#define WF_PG_LISTA     1
#define WF_PG_FICHA     2
#define WF_PG_MAPA      3
#define WF_PG_CUSTOM  -99

#define WF_HEIGHT_GG  685
#define WF_HEIGHT_G   629
#define WF_HEIGHT_M   533
#define WF_HEIGHT_P   439

// Definições de máscaras

#define MASK_CPF   "@R 999.999.999-99"
#define MASK_CNPJ  "@R 99.999.999/9999-99"
#define MASK_FONE  "@R (99)X999-9999"
#define MASK_CEP   "@R 99999-999"

// Definições diversas

#define BT_VERDE     1
#define BT_VERMELHO  2
#define BT_AZUL      3
#define BT_AMARELO   4

#define RPT_NOPARAM   ( ! File( "RPTPARAM.SET" ) )

#define BRW_MAIN  "oBrw" + Subs( mxWFObj():cName, 3 )

#define BRW_REFRESH_TOP     1
#define BRW_REFRESH_BOTTOM  2
#define BRW_REFRESH_RECNO   3

#define MSG_TITLE  "Informação importante"

#define _NL  HB_OsNewLine()