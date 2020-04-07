/*

 MaxLBar.prg
 Descricao: Biblioteca de funcoes p/ impressao de codigo de barras.
 Desenvolvido por MAX SCALLA Informatica Ltda.

 DENIS MAZZUCATTO RODRIGUES
 11/12/09 * Inicio do desenvolvimento.
            Programacao inserida pela decompilacao da biblioteca LIBBAR.OBJ
*/

#include "inkey.ch"
#include "common.ch"

********************************
PROCEDURE TWINIC

   PUBLIC twean13, twean8, twupca, twupce, twc25, twc39, twc128
   PUBLIC twepson, twlaser, twdeskj
   PUBLIC twcode, twprinter, twlbarf, twlbarg, twaltura, twround
   PUBLIC twnulo, twmaxround, twsource, twmaxalt

   twean13    := 1
   twean8     := 2
   twupca     := 3
   twupce     := 4
   twc25      := 5
   twc39      := 6
   twc128     := 7
   twepson    := 1
   twlaser    := 2
   twdeskj    := 3
   twlbarf    := 1
   twlbarg    := 3
   twaltura   := 8
   twround    := 12
   twmaxalt   := 3000
   twmaxround := 100
   twsource   := ""
   twnulo     := Chr(0)
   twcode     := twean13
   twprinter  := twepson

RETURN( NIL )


********************************
PROCEDURE TWDEFCODE( twcodetype )

   IF twcodetype == twean13 .OR. ;
      twcodetype == twean8  .OR. ;
      twcodetype == twupca  .OR. ;
      twcodetype == twupce  .OR. ;
      twcodetype == twc25   .OR. ;
      twcodetype == twc39   .OR. ;
      twcodetype == twc128

      twcode := twcodetype

   ENDIF

RETURN( NIL )


********************************
PROCEDURE TWDEFPRINT( twprinttyp )

   IF twprinttyp == twepson .OR. ;
      twprinttyp == twlaser .OR. ;
      twprinttyp == twdeskj

      twprinter := twprinttyp

   ENDIF

RETURN( NIL )


********************************
PROCEDURE TWDEFLBARS( twfina, twgrossa )

   IF (twfina < 1)
      twfina := 1
   ENDIF
   IF (twgrossa >= twfina)
      twlbarg := twgrossa
      twlbarf := twfina
   ENDIF

RETURN( NIL )


********************************
PROCEDURE TWDEFALT( twalt )

   twaltura := twalt
   IF twaltura > twmaxalt
      twaltura := twmaxalt
   ENDIF

RETURN( NIL )


********************************
PROCEDURE TWDEFROUND( twroundval )

   twround := twroundval
   IF twround > twmaxround
      twround := twmaxround
   ENDIF

RETURN( NIL )


********************************
PROCEDURE TWDEFSALTO( twsalto )

   DevOut( "A" + Chr( twsalto ) )

RETURN( NIL )


********************************
PROCEDURE TWDJAVANCO( tw_avanco )

   DevOut( "*b" + AllTrim( Str( tw_avanco ) ) + "Y" )

RETURN( NIL )


********************************
PROCEDURE TWDJRETORN( tw_retorno )

   DevOut( "*b" + AllTrim( Str( tw_retorno * -1 ) ) + "Y" )

RETURN( NIL )


********************************
FUNCTION STRBIN_2_D( numbin )

   PRIV dig[8]
   result := 0
   FOR a := 1 TO 8
      dig[a] := Val( Subs( numbin, a, 1 ) ) * 2 ^ (8 - a)
      result := Int( result + dig[a] )
   NEXT

RETURN( result )


********************************
FUNCTION TWHPALTURA( twalt )

RETURN( "*c" + LTrim( Tran( twalt, "9999" ) ) + "B" )


********************************
FUNCTION TWHPAVANCO( twavanco )

RETURN( "*p+" + LTrim( Tran( twavanco, "9999" ) ) + "X" )


********************************
PROCEDURE TWAJUSTA

   IF twprinter == twlaser
      DevOut( "&f0S*p-30Y" )
   ENDIF

RETURN( NIL )


********************************
PROCEDURE TWRECUP

   IF twprinter == twlaser
      DevOut( "&f1S" )
   ENDIF

RETURN( NIL )


********************************
FUNCTION TWHPRETANG( twavanco )

RETURN( "*c" + LTrim( Tran( twavanco, "9999" ) ) + "a0P" + twhpavanco( twavanco ) )


********************************
FUNCTION TWCALCDIG( twsrc )

   twk := 0
   FOR twi := Len( twsrc ) TO 1 Step -1
      twj := Val( Subs( twsrc, twi, 1 ) )
      IF (mod(Len(twsrc) - twi, 2) == 0)
         twj := twj * 3
      ENDIF
      twk := twk + twj
   NEXT
   twk := mod(10 - mod(twk, 10), 10)

RETURN( Chr(twk + 48) )


********************************
FUNCTION TWVALIDNUM( twsrc, twsrclen )

   IF (twsrclen == 0)
      twsrclen := Len(twsrc)
   ENDIF
   twflag := .T.
   While (Len(twsrc) < twsrclen)
      twsrc := "0" + twsrc
   End
   FOR twi := 1 TO twsrclen
      twflag := twflag .AND. ( At(Subs(twsrc, twi, 1), "0123456789") > 0 )
   NEXT
   IF (twflag)
      twsource := twsrc
   ENDIF

RETURN( twflag )


********************************
FUNCTION TWTAMCHAR( twsrc )

RETURN( Int(twtamr(twsrc) / twround) )


********************************
FUNCTION TWORD39( twchar )

RETURN( At(Upper(twchar), "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%*") )


********************************
FUNCTION TWVALIDC39( twsrc )

   IF (Subs(twsrc, 1, 1) == "*")
      twsrc := Subs(twsrc, 2, Len(twsrc))
   ENDIF
   IF (Subs(twsrc, Len(twsrc), 1) == "*")
      twsrc := Subs(twsrc, 1, Len(twsrc) - 1)
   ENDIF
   twflag := .T.
   FOR twi := 1 TO Len(twsrc)
      twflag := twflag .AND. ( At(Upper(Subs(twsrc, twi, 1)), "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ- $/+%.") > 0 )
   NEXT
   IF (twflag)
      twsource := "*" + twsrc + "*"
   ENDIF

RETURN( twflag )


********************************
FUNCTION TWVALIDC12( twsrc )

   twflag := .T.

   FOR twi := 1 TO Len(twsrc)
      twflag := twflag .AND. ( At(Subs(twsrc, twi, 1), '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz `~!@#$%^&*_+|\=-{}[]()<>:,.?/";') > 0 )
   NEXT
   IF (twflag)
      twsource := twsrc
   ENDIF

RETURN( twflag )


********************************
FUNCTION TWVALID( twsrc )

   twflag := .F.
   twi := twcode
   DO CASE
   CASE twi == twean13
      twflag := twvalidnum(twsrc, 12)
      IF (twflag)
         twsource := twsource + twcalcdig(twsource)
      ENDIF
   CASE twcode == twean8
      twflag := twvalidnum(twsrc, 7)
      IF (twflag)
         twsource := twsource + twcalcdig(twsource)
      ENDIF
   CASE twcode == twupca
      twflag := twvalidnum(twsrc, 12)
      IF (twflag)
         twsource:= twsource + twcalcdig(twsource)
      ENDIF
   CASE twcode == twupce
      twflag := twvalidnum(twsrc, 7)
      IF (twflag)
         twsource := twsource + twcalcdig(twsource)
      ENDIF
   CASE twcode == twc25
      twflag := twvalidnum(twsrc, 0)
      IF (twflag .AND. mod(Len(twsrc), 2) == 1)
         twsource := "0" + twsource
      ENDIF
   CASE twcode == twc39
      twflag := twvalidc39(twsrc)
   CASE twcode == twc128
      twflag := twvalidc12(twsrc)
   ENDCASE

RETURN( twflag )


********************************
FUNCTION TWTAMR( twsrc )

   twi := twtam(twsrc)
   IF (twprinter == twdeskj)
      IF (mod(twi, 8) == 0)
         twi := Int(twi / 8)
      ELSE
         twi := Int(twi / 8) + 1
      ENDIF
   ELSE
      While ! (mod(twi, twround) == 0)
         twi += 1
      End
   ENDIF

RETURN( twi )


********************************
FUNCTION TWTAM( twsrc )

   twtamanho := 0

   IF twvalid( twsrc )
      DO CASE
         CASE twcode == twean13 ; twtamanho := twlbarf * 95
         CASE twcode == twean8  ; twtamanho := twlbarf * 67
         CASE twcode == twupca  ; twtamanho := twlbarf * 95
         CASE twcode == twupce  ; twtamanho := twlbarf * 51
         CASE twcode == twc25   ; twtamanho := 6 * twlbarf + twlbarg + Len( twsrc ) * ( 3 * twlbarf + 2 * twlbarg )
         CASE twcode == twc39   ; twtamanho := ( 7 * twlbarf + 3 * twlbarg ) * Len( twsrc ) - 1
         CASE twcode == twc128  ; twtamanho := ( twbufsize * 11 + 13 ) * twlbarf
         OTHERWISE              ; twtamanho := 0
      ENDCASE
   ENDIF

RETURN( twtamanho )


********************************
PROCEDURE TWIMPEAN13

   PRIV twalt[8], twtab7a12[10]
   PRIV twcodigo1[10], twcodigo2[10], twcodigo3[10]

   twalt[1] := "ÿ"
   twalt[2] := "€"
   twalt[3] := "À"
   twalt[4] := "à"
   twalt[5] := "ð"
   twalt[6] := "ø"
   twalt[7] := "ü"
   twalt[8] := "þ"

   twcodigo1[01] := "0001101"
   twcodigo1[02] := "0011001"
   twcodigo1[03] := "0010011"
   twcodigo1[04] := "0111101"
   twcodigo1[05] := "0100011"
   twcodigo1[06] := "0110001"
   twcodigo1[07] := "0101111"
   twcodigo1[08] := "0111011"
   twcodigo1[09] := "0110111"
   twcodigo1[10] := "0001011"

   twcodigo2[01] := "0100111"
   twcodigo2[02] := "0110011"
   twcodigo2[03] := "0011011"
   twcodigo2[04] := "0100001"
   twcodigo2[05] := "0011101"
   twcodigo2[06] := "0111001"
   twcodigo2[07] := "0000101"
   twcodigo2[08] := "0010001"
   twcodigo2[09] := "0001001"
   twcodigo2[10] := "0010111"

   twcodigo3[01] := "1110010"
   twcodigo3[02] := "1100110"
   twcodigo3[03] := "1101100"
   twcodigo3[04] := "1000010"
   twcodigo3[05] := "1011100"
   twcodigo3[06] := "1001110"
   twcodigo3[07] := "1010000"
   twcodigo3[08] := "1000100"
   twcodigo3[09] := "1001000"
   twcodigo3[10] := "1110100"

   twtab7a12[01] := "111111"
   twtab7a12[02] := "221211"
   twtab7a12[03] := "212211"
   twtab7a12[04] := "122211"
   twtab7a12[05] := "221121"
   twtab7a12[06] := "211221"
   twtab7a12[07] := "112221"
   twtab7a12[08] := "212121"
   twtab7a12[09] := "122121"
   twtab7a12[10] := "121221"

   IF (twprinter == twepson)
      twsize := twtamr(twsource)
      twchar := twalt[mod(twaltura, 8) + 1]
      DevOut("L" + Chr(mod(twsize, 256)) + Chr(Int(twsize / 256)))
      DevOut(Repl(twchar, twlbarf) + Repl(twnulo, twlbarf) + Repl(twchar, twlbarf))
      twl := Val(Subs(twsource, 1, 1)) + 1
      FOR twi := 2 TO 13
         twj := Val(Subs(twsource, twi, 1)) + 1
         FOR twk := 1 TO 7
            IF (twi <= 7)
               twm := "TWCODIGO" + Subs(twtab7a12[twl], 8 - twi, 1)
            ELSE
               twm := "TWCODIGO3"
            ENDIF
            IF (Subs(&twm[twj], twk, 1) == "1")
               DevOut(Repl(twchar, twlbarf))
            ELSE
               DevOut(Repl(twnulo, twlbarf))
            ENDIF
         NEXT
         IF (twi == 7)
            DevOut(Repl(twnulo, twlbarf))
            DevOut(Repl(twchar, twlbarf))
            DevOut(Repl(twnulo, twlbarf))
            DevOut(Repl(twchar, twlbarf))
            DevOut(Repl(twnulo, twlbarf))
         ENDIF
      NEXT
      DevOut(Repl(twchar, twlbarf) + Repl(twnulo, twlbarf) + Repl(twchar, twlbarf))
      DevOut(Repl(twnulo, twsize - twtam(twsource)))
   ELSEIF (twprinter == twlaser)
      DevOut(twhpaltura(twaltura))
      DevOut(twhpretang(twlbarf) + twhpavanco(twlbarf) + twhpretang(twlbarf))
      twl := Val(Subs(twsource, 1, 1)) + 1
      FOR twi := 2 TO 13
         twj := Val(Subs(twsource, twi, 1)) + 1
         FOR twk := 1 TO 7
            IF (twi <= 7)
               twm := "TWCODIGO" + Subs(twtab7a12[twl], 8 - twi, 1)
            ELSE
               twm := "TWCODIGO3"
            ENDIF
            IF (Subs(&twm[twj], twk, 1) == "1")
               DevOut(twhpretang(twlbarf))
            ELSE
               DevOut(twhpavanco(twlbarf))
            ENDIF
         NEXT
         IF (twi == 7)
            DevOut(twhpavanco(twlbarf))
            DevOut(twhpretang(twlbarf))
            DevOut(twhpavanco(twlbarf))
            DevOut(twhpretang(twlbarf))
            DevOut(twhpavanco(twlbarf))
         ENDIF
      NEXT
      DevOut(twhpretang(twlbarf) + twhpavanco(twlbarf) + twhpretang(twlbarf))
   ELSEIF (twprinter == twdeskj)
      twbarra := ""
      twstrsiz := ""
      twsize := twtamr(twsource)
      twstrsiz := LTrim(Trim(Str(twsize)))
      twprow := Row()
      DevOut("*p" + LTrim(Trim(Str(-33))) + "Y")
      DevOut("*t300R")
      twbarra := "101"
      twl := Val(Subs(twsource, 1, 1)) + 1
      FOR twi := 2 TO 13
         twj := Val(Subs(twsource, twi, 1)) + 1
         FOR twk := 1 TO 7
            IF (twi <= 7)
               twm := "TWCODIGO" + Subs(twtab7a12[twl], 8 - twi, 1)
            ELSE
               twm := "TWCODIGO3"
            ENDIF
            IF (Subs(&twm[twj], twk, 1) == "1")
               twbarra := twbarra + "1"
            ELSE
               twbarra := twbarra + "0"
            ENDIF
         NEXT
         IF (twi == 7)
            twbarra := twbarra + "01010"
         ENDIF
      NEXT
      twbarra := twbarra + "101"
      saux1 := ""
      saux := ""
      FOR twj := 1 TO Len(twbarra)
         saux := saux + Repl(Subs(twbarra, twj, 1), twlbarf)
         While (Len(saux) >= 8)
            saux1 := saux1 + Chr(strbin_2_d(Subs(saux, 1, 8)))
            saux := Subs(saux, 9, Len(saux) - 8)
         End
      NEXT
      IF (Len(saux) > 0)
         saux := saux + Repl("0", 8 - Len(saux))
         saux1 := saux1 + Chr(strbin_2_d(saux))
      ENDIF
      FOR twcount := 1 TO twaltura
         DevOut("*r1A")
         DevOut("*b" + twstrsiz + "W")
         DevOut(saux1)
      NEXT
      DevOut("*rbC")
      IF (twaltura > 33)
         DevOut("*p" + LTrim(Trim(Str((twaltura - 33) * -1))) + "Y")
      ENDIF
      IF (twaltura < 33)
         DevOut("*p" + LTrim(Trim(Str((33 - twaltura) * -1))) + "Y")
      ENDIF
   ENDIF

RETURN( NIL )


********************************
PROCEDURE TWIMPCOD( twsrc )

   IF twvalid(twsrc)

      twajusta()

      DO CASE
         CASE twcode == twean13 ; twimpean13()
         CASE twcode == twean8  ; twimpean8()
         CASE twcode == twupca  ; twimpupca()
         CASE twcode == twupce  ; twimpupce()
         CASE twcode == twc25   ; twimpc25()
         CASE twcode == twc39   ; twimpc39()
         CASE twcode == twc128  ; twimpc128()
      ENDCASE

      twrecup()

   ENDIF

RETURN( NIL )


********************************
PROCEDURE TWIMPEAN8

   PRIV twalt[8], twcodigo1[10], twcodigo3[10]

   twalt[1] := "ÿ"
   twalt[2] := "€"
   twalt[3] := "À"
   twalt[4] := "à"
   twalt[5] := "ð"
   twalt[6] := "ø"
   twalt[7] := "ü"
   twalt[8] := "þ"

   twcodigo1[01] := "0001101"
   twcodigo1[02] := "0011001"
   twcodigo1[03] := "0010011"
   twcodigo1[04] := "0111101"
   twcodigo1[05] := "0100011"
   twcodigo1[06] := "0110001"
   twcodigo1[07] := "0101111"
   twcodigo1[08] := "0111011"
   twcodigo1[09] := "0110111"
   twcodigo1[10] := "0001011"

   twcodigo3[01] := "1110010"
   twcodigo3[02] := "1100110"
   twcodigo3[03] := "1101100"
   twcodigo3[04] := "1000010"
   twcodigo3[05] := "1011100"
   twcodigo3[06] := "1001110"
   twcodigo3[07] := "1010000"
   twcodigo3[08] := "1000100"
   twcodigo3[09] := "1001000"
   twcodigo3[10] := "1110100"

   IF (twprinter == twepson)
      twsize := twtamr(twsource)
      twchar := twalt[mod(twaltura, 8) + 1]
      DevOut("L" + Chr(mod(twsize, 256)) + Chr(Int(twsize / 256)))
      DevOut(Repl(twchar, twlbarf) + Repl(twnulo, twlbarf) + Repl(twchar, twlbarf))
      twl := Val(Subs(twsource, 1, 1)) + 1
      FOR twi := 1 TO 8
         twj := Val(Subs(twsource, twi, 1)) + 1
         FOR twk := 1 TO 7
            IF (twi <= 4)
               twm := "TWCODIGO1"
            ELSE
               twm := "TWCODIGO3"
            ENDIF
            IF (Subs(&twm[twj], twk, 1) == "1")
               DevOut(Repl(twchar, twlbarf))
            ELSE
               DevOut(Repl(twnulo, twlbarf))
            ENDIF
         NEXT
         IF (twi == 4)
            DevOut(Repl(twnulo, twlbarf))
            DevOut(Repl(twchar, twlbarf))
            DevOut(Repl(twnulo, twlbarf))
            DevOut(Repl(twchar, twlbarf))
            DevOut(Repl(twnulo, twlbarf))
         ENDIF
      NEXT
      DevOut(Repl(twchar, twlbarf) + Repl(twnulo, twlbarf) + Repl(twchar, twlbarf))
      DevOut(Repl(twnulo, twsize - twtam(twsource)))
   ELSEIF (twprinter == twlaser)
      DevOut(twhpaltura(twaltura))
      DevOut(twhpretang(twlbarf) + twhpavanco(twlbarf) + twhpretang(twlbarf))
      twl := Val(Subs(twsource, 1, 1)) + 1
      FOR twi := 1 TO 8
         twj := Val(Subs(twsource, twi, 1)) + 1
         FOR twk := 1 TO 7
            IF (twi <= 4)
               twm := "TWCODIGO1"
            ELSE
               twm := "TWCODIGO3"
            ENDIF
            IF (Subs(&twm[twj], twk, 1) == "1")
               DevOut(twhpretang(twlbarf))
            ELSE
               DevOut(twhpavanco(twlbarf))
            ENDIF
         NEXT
         IF (twi == 4)
            DevOut(twhpavanco(twlbarf))
            DevOut(twhpretang(twlbarf))
            DevOut(twhpavanco(twlbarf))
            DevOut(twhpretang(twlbarf))
            DevOut(twhpavanco(twlbarf))
         ENDIF
      NEXT
      DevOut(twhpretang(twlbarf) + twhpavanco(twlbarf) + twhpretang(twlbarf))
   ELSEIF (twprinter == twdeskj)
      twbarra := "101"
      twstrsiz := ""
      size := twtamr(twsource)
      twstrsiz := LTrim(Trim(Str(size)))
      DevOut("*p" + LTrim(Trim(Str(-33))) + "Y")
      DevOut("*t300R")
      twbarra := "101"
      twl := Val(Subs(twsource, 1, 1)) + 1
      FOR twi := 1 TO 8
         twj := Val(Subs(twsource, twi, 1)) + 1
         FOR twk := 1 TO 7
            IF (twi <= 4)
               twm := "TWCODIGO1"
            ELSE
               twm := "TWCODIGO3"
            ENDIF
            IF (Subs(&twm[twj], twk, 1) == "1")
               twbarra := twbarra + "1"
            ELSE
               twbarra := twbarra + "0"
            ENDIF
         NEXT
         IF (twi == 4)
            twbarra := twbarra + "01010"
         ENDIF
      NEXT
      twbarra := twbarra + "101"
      saux := ""
      saux1 := ""
      FOR twj := 1 TO Len(twbarra)
         saux := saux + Repl(Subs(twbarra, twj, 1), twlbarf)
         While (Len(saux) >= 8)
            saux1 := saux1 + Chr(strbin_2_d(Subs(saux, 1, 8)))
            saux := Subs(saux, 9, Len(saux) - 8)
         End
      NEXT
      IF (Len(saux) > 0)
         saux := saux + Repl("0", 8 - Len(saux))
         saux1 := saux1 + Chr(strbin_2_d(saux))
      ENDIF
      FOR twcount := 1 TO twaltura
         DevOut("*r1A")
         DevOut("*b" + twstrsiz + "W")
         DevOut(saux1)
      NEXT
      DevOut("*rbC")
      IF (twaltura > 33)
         DevOut("*p" + LTrim(Trim(Str((twaltura - 33) * -1))) + "Y")
      ENDIF
      IF (twaltura < 33)
         DevOut("*p" + LTrim(Trim(Str((33 - twaltura) * -1))) + "Y")
      ENDIF
   ENDIF

RETURN( NIL )


********************************
PROCEDURE TWIMPUPCA

   PRIV twalt[8], twcodigo1[10], twcodigo3[10]

   twalt[1] := "ÿ"
   twalt[2] := "€"
   twalt[3] := "À"
   twalt[4] := "à"
   twalt[5] := "ð"
   twalt[6] := "ø"
   twalt[7] := "ü"
   twalt[8] := "þ"

   twcodigo1[01] := "0001101"
   twcodigo1[02] := "0011001"
   twcodigo1[03] := "0010011"
   twcodigo1[04] := "0111101"
   twcodigo1[05] := "0100011"
   twcodigo1[06] := "0110001"
   twcodigo1[07] := "0101111"
   twcodigo1[08] := "0111011"
   twcodigo1[09] := "0110111"
   twcodigo1[10] := "0001011"

   twcodigo3[01] := "1110010"
   twcodigo3[02] := "1100110"
   twcodigo3[03] := "1101100"
   twcodigo3[04] := "1000010"
   twcodigo3[05] := "1011100"
   twcodigo3[06] := "1001110"
   twcodigo3[07] := "1010000"
   twcodigo3[08] := "1000100"
   twcodigo3[09] := "1001000"
   twcodigo3[10] := "1110100"

   IF (twprinter == twepson)
      twsize := twtamr(twsource)
      twchar := twalt[mod(twaltura, 8) + 1]
      DevOut("L" + Chr(mod(twsize, 256)) + Chr(Int(twsize / 256)))
      DevOut(Repl(twchar, twlbarf) + Repl(twnulo, twlbarf) + Repl(twchar, twlbarf))
      twl := Val(Subs(twsource, 1, 1)) + 1
      FOR twi := 2 TO 13
         twj := Val(Subs(twsource, twi, 1)) + 1
         FOR twk := 1 TO 7
            IF (twi <= 7)
               twm := "TWCODIGO1"
            ELSE
               twm := "TWCODIGO3"
            ENDIF
            IF (Subs(&twm[twj], twk, 1) == "1")
               DevOut(Repl(twchar, twlbarf))
            ELSE
               DevOut(Repl(twnulo, twlbarf))
            ENDIF
         NEXT
         IF (twi == 7)
            DevOut(Repl(twnulo, twlbarf))
            DevOut(Repl(twchar, twlbarf))
            DevOut(Repl(twnulo, twlbarf))
            DevOut(Repl(twchar, twlbarf))
            DevOut(Repl(twnulo, twlbarf))
         ENDIF
      NEXT
      DevOut(Repl(twchar, twlbarf) + Repl(twnulo, twlbarf) + Repl(twchar, twlbarf))
      DevOut(Repl(twnulo, twsize - twtam(twsource)))
   ELSEIF (twprinter == twlaser)
      DevOut(twhpaltura(twaltura))
      DevOut(twhpretang(twlbarf) + twhpavanco(twlbarf) + twhpretang(twlbarf))
      twl := Val(Subs(twsource, 1, 1)) + 1
      FOR twi := 2 TO 13
         twj := Val(Subs(twsource, twi, 1)) + 1
         FOR twk := 1 TO 7
            IF (twi <= 7)
               twm := "TWCODIGO1"
            ELSE
               twm := "TWCODIGO3"
            ENDIF
            IF (Subs(&twm[twj], twk, 1) == "1")
               DevOut(twhpretang(twlbarf))
            ELSE
               DevOut(twhpavanco(twlbarf))
            ENDIF
         NEXT
         IF (twi == 7)
            DevOut(twhpavanco(twlbarf))
            DevOut(twhpretang(twlbarf))
            DevOut(twhpavanco(twlbarf))
            DevOut(twhpretang(twlbarf))
            DevOut(twhpavanco(twlbarf))
         ENDIF
      NEXT
      DevOut(twhpretang(twlbarf) + twhpavanco(twlbarf) + twhpretang(twlbarf))
   ELSEIF (twprinter == twdeskj)
      twbarra := ""
      twstrsiz := ""
      twaltdot := Int(Round(300 / 72 * twaltura, 0))
      twsize := twtamr(twsource)
      twstrsiz := LTrim(Trim(Str(twsize)))
      DevOut("*p" + LTrim(Trim(Str(-33))) + "Y")
      DevOut("*t300R")
      twbarra := "101"
      twl := Val(Subs(twsource, 1, 1)) + 1
      FOR twi := 2 TO 13
         twj := Val(Subs(twsource, twi, 1)) + 1
         FOR twk := 1 TO 7
            IF (twi <= 7)
               twm := "TWCODIGO1"
            ELSE
               twm := "TWCODIGO3"
            ENDIF
            IF (Subs(&twm[twj], twk, 1) == "1")
               twbarra := twbarra + "1"
            ELSE
               twbarra := twbarra + "0"
            ENDIF
         NEXT
         IF (twi == 7)
            twbarra := twbarra + "01010"
         ENDIF
      NEXT
      twbarra := twbarra + "101"
      saux := ""
      saux1 := ""
      FOR twj := 1 TO Len(twbarra)
         saux := saux + Repl(Subs(twbarra, twj, 1), twlbarf)
         While (Len(saux) >= 8)
            saux1 := saux1 + Chr(strbin_2_d(Subs(saux, 1, 8)))
            saux := Subs(saux, 9, Len(saux) - 8)
         End
      NEXT
      IF (Len(saux) > 0)
         saux := saux + Repl("0", 8 - Len(saux))
         saux1 := saux1 + Chr(strbin_2_d(saux))
      ENDIF
      FOR twcount := 1 TO twaltura
         DevOut("*r1A")
         DevOut("*b" + twstrsiz + "W")
         DevOut(saux1)
      NEXT
      DevOut("*rbC")
      IF (twaltura > 33)
         DevOut("*p" + LTrim(Trim(Str((twaltura - 33) * -1))) + "Y")
      ENDIF
      IF (twaltura < 33)
         DevOut("*p" + LTrim(Trim(Str((33 - twaltura) * -1))) + "Y")
      ENDIF
   ENDIF

RETURN( NIL )


********************************
PROCEDURE TWIMPUPCE

   PRIV twalt[8], twcodigo1[10], twcodigo2[10], twtab2a7[10]

   twalt[1] := "ÿ"
   twalt[2] := "€"
   twalt[3] := "À"
   twalt[4] := "à"
   twalt[5] := "ð"
   twalt[6] := "ø"
   twalt[7] := "ü"
   twalt[8] := "þ"

   twcodigo1[01] := "0001101"
   twcodigo1[02] := "0011001"
   twcodigo1[03] := "0010011"
   twcodigo1[04] := "0111101"
   twcodigo1[05] := "0100011"
   twcodigo1[06] := "0110001"
   twcodigo1[07] := "0101111"
   twcodigo1[08] := "0111011"
   twcodigo1[09] := "0110111"
   twcodigo1[10] := "0001011"

   twcodigo2[01] := "0100111"
   twcodigo2[02] := "0110011"
   twcodigo2[03] := "0011011"
   twcodigo2[04] := "0100001"
   twcodigo2[05] := "0011101"
   twcodigo2[06] := "0111001"
   twcodigo2[07] := "0000101"
   twcodigo2[08] := "0010001"
   twcodigo2[09] := "0001001"
   twcodigo2[10] := "0010111"

   twtab2a7[01] := "222111"
   twtab2a7[02] := "221211"
   twtab2a7[03] := "221121"
   twtab2a7[04] := "221112"
   twtab2a7[05] := "212211"
   twtab2a7[06] := "211221"
   twtab2a7[07] := "211122"
   twtab2a7[08] := "212121"
   twtab2a7[09] := "212112"
   twtab2a7[10] := "211212"

   IF (twprinter == twepson)
      twsize := twtamr(twsource)
      twchar := twalt[mod(twaltura, 8) + 1]
      DevOut("L" + Chr(mod(twsize, 256)) + Chr(Int(twsize / 256)))
      DevOut(Repl(twchar, twlbarf) + Repl(twnulo, twlbarf) + Repl(twchar, twlbarf))
      twl := Val(Subs(twsource, 8, 1)) + 1
      FOR twi := 2 TO 7
         twj := Val(Subs(twsource, twi, 1)) + 1
         FOR twk := 1 TO 7
            twm := "TWCODIGO" + Subs(twtab2a7[twl], twi - 1, 1)
            IF (Subs(&twm[twj], twk, 1) == "1")
               DevOut(Repl(twchar, twlbarf))
            ELSE
               DevOut(Repl(twnulo, twlbarf))
            ENDIF
         NEXT
      NEXT
      DevOut(Repl(twnulo, twlbarf) + Repl(twchar, twlbarf))
      DevOut(Repl(twnulo, twlbarf) + Repl(twchar, twlbarf))
      DevOut(Repl(twnulo, twlbarf) + Repl(twchar, twlbarf))
      DevOut(Repl(twnulo, twsize - twtam(twsource)))
   ELSEIF (twprinter == twlaser)
      DevOut(twhpaltura(twaltura))
      DevOut(twhpretang(twlbarf) + twhpavanco(twlbarf) + twhpretang(twlbarf))
      twl := Val(Subs(twsource, 8, 1)) + 1
      FOR twi := 2 TO 7
         twj := Val(Subs(twsource, twi, 1)) + 1
         FOR twk := 1 TO 7
            twm := "TWCODIGO" + Subs(twtab2a7[twl], twi - 1, 1)
            IF (Subs(&twm[twj], twk, 1) == "1")
               DevOut(twhpretang(twlbarf))
            ELSE
               DevOut(twhpavanco(twlbarf))
            ENDIF
         NEXT
      NEXT
      DevOut(twhpavanco(twlbarf) + twhpretang(twlbarf))
      DevOut(twhpavanco(twlbarf) + twhpretang(twlbarf))
      DevOut(twhpavanco(twlbarf) + twhpretang(twlbarf))
   ELSEIF (twprinter == twdeskj)
      twbarra := ""
      twsrtsiz := ""
      twsize := twtamr(twsource)
      twstrsiz := LTrim(Trim(Str(twsize)))
      DevOut("*p" + LTrim(Trim(Str(-33))) + "Y")
      DevOut("*t300R")
      twbarra := "101"
      twl := Val(Subs(twsource, 8, 1)) + 1
      FOR twi := 2 TO 7
         twj := Val(Subs(twsource, twi, 1)) + 1
         FOR twk := 1 TO 7
            twm := "TWCODIGO" + Subs(twtab2a7[twl], twi - 1, 1)
            IF (Subs(&twm[twj], twk, 1) == "1")
               twbarra := twbarra + "1"
            ELSE
               twbarra := twbarra + "0"
            ENDIF
         NEXT
      NEXT
      twbarra := twbarra + "010101"
      saux := ""
      saux1 := ""
      FOR twj := 1 TO Len(twbarra)
         saux := saux + Repl(Subs(twbarra, twj, 1), twlbarf)
         While (Len(saux) >= 8)
            saux1 := saux1 + Chr(strbin_2_d(Subs(saux, 1, 8)))
            saux := Subs(saux, 9, Len(saux) - 8)
         End
      NEXT
      IF (Len(saux) > 0)
         saux := saux + Repl("0", 8 - Len(saux))
         saux1 := saux1 + Chr(strbin_2_d(saux))
      ENDIF
      FOR twcount := 1 TO twaltura
         DevOut("*r1A")
         DevOut("*b" + twstrsiz + "W")
         DevOut(saux1)
      NEXT
      DevOut("*rbC")
      IF (twaltura > 33)
         DevOut("*p" + LTrim(Trim(Str((twaltura - 33) * -1))) + "Y")
      ENDIF
      IF (twaltura < 33)
         DevOut("*p" + LTrim(Trim(Str((33 - twaltura) * -1))) + "Y")
      ENDIF
   ENDIF

RETURN( NIL )


********************************
PROCEDURE TWIMPC25

   PRIV twalt[8], twcodigo[10]

   twalt[1] := "ÿ"
   twalt[2] := "€"
   twalt[3] := "À"
   twalt[4] := "à"
   twalt[5] := "ð"
   twalt[6] := "ø"
   twalt[7] := "ü"
   twalt[8] := "þ"

   twcodigo[01] := "00110"
   twcodigo[02] := "10001"
   twcodigo[03] := "01001"
   twcodigo[04] := "11000"
   twcodigo[05] := "00101"
   twcodigo[06] := "10100"
   twcodigo[07] := "01100"
   twcodigo[08] := "00011"
   twcodigo[09] := "10010"
   twcodigo[10] := "01010"

   IF (twprinter == twepson)
      twsize := twtamr(twsource)
      twchar := twalt[mod(twaltura, 8) + 1]
      DevOut("L" + Chr(mod(twsize, 256)) + Chr(Int(twsize / 256)))
      DevOut(Repl(twchar, twlbarf) + Repl(twnulo, twlbarf) + Repl(twchar, twlbarf) + Repl(twnulo, twlbarf))
      FOR twi := 1 TO Len(twsource) / 2
         twk := Val(Subs(twsource, twi * 2 - 1, 1)) + 1
         twl := Val(Subs(twsource, twi * 2, 1)) + 1
         FOR twj := 1 TO 5
            IF (Subs(twcodigo[twk], twj, 1) == "1")
               twm := twlbarg
            ELSE
               twm := twlbarf
            ENDIF
            IF (Subs(twcodigo[twl], twj, 1) == "1")
               twn := twlbarg
            ELSE
               twn := twlbarf
            ENDIF
            DevOut(Repl(twchar, twm) + Repl(twnulo, twn))
         NEXT
      NEXT
      DevOut(Repl(twchar, twlbarg) + Repl(twnulo, twlbarf) + Repl(twchar, twlbarf))
      DevOut(Repl(twnulo, twsize - twtam(twsource)))
   ELSEIF (twprinter == twlaser)
      DevOut(twhpaltura(twaltura))
      DevOut(twhpretang(twlbarf) + twhpavanco(twlbarf) + twhpretang(twlbarf) + twhpavanco(twlbarf))
      FOR twi := 1 TO Int(Len(twsource) / 2)
         twk := Val(Subs(twsource, twi * 2 - 1, 1)) + 1
         twl := Val(Subs(twsource, twi * 2, 1)) + 1
         FOR twj := 1 TO 5
            IF (Subs(twcodigo[twk], twj, 1) == "1")
               twm := twlbarg
            ELSE
               twm := twlbarf
            ENDIF
            IF (Subs(twcodigo[twl], twj, 1) == "1")
               twn := twlbarg
            ELSE
               twn := twlbarf
            ENDIF
            DevOut(twhpretang(twm) + twhpavanco(twn))
         NEXT
      NEXT
      DevOut(twhpretang(twlbarg) + twhpavanco(twlbarf) + twhpretang(twlbarf))
   ELSEIF (twprinter == twdeskj)
      twbarra := ""
      twstrsiz := ""
      twsize := twtamr(twsource)
      twstrsiz := LTrim(Trim(Str(twsize)))
      DevOut("*p" + LTrim(Trim(Str(-33))) + "Y")
      DevOut("*t300R")
      twbarra := "2020"
      FOR twi := 1 TO Len(twsource) / 2
         twk := Val(Subs(twsource, twi * 2 - 1, 1)) + 1
         twl := Val(Subs(twsource, twi * 2, 1)) + 1
         FOR twj := 1 TO 5
            IF (Subs(twcodigo[twk], twj, 1) == "1")
               twbarra := twbarra + "3"
            ELSE
               twbarra := twbarra + "2"
            ENDIF
            IF (Subs(twcodigo[twl], twj, 1) == "1")
               twbarra := twbarra + "1"
            ELSE
               twbarra := twbarra + "0"
            ENDIF
         NEXT
      NEXT
      twbarra := twbarra + "302"
      saux := ""
      saux1 := ""
      FOR twj := 1 TO Len(twbarra)
         twbaraux := Subs(twbarra, twj, 1)
         DO CASE
         CASE twbaraux == "0"
            saux := saux + Repl("0", twlbarf)
         CASE twbaraux == "1"
            saux := saux + Repl("0", twlbarg)
         CASE twbaraux == "2"
            saux := saux + Repl("1", twlbarf)
         CASE twbaraux == "3"
            saux := saux + Repl("1", twlbarg)
         ENDCASE
         While (Len(saux) >= 8)
            saux1 := saux1 + Chr(strbin_2_d(Subs(saux, 1, 8)))
            saux := Subs(saux, 9, Len(saux) - 8)
         End
      NEXT
      IF (Len(saux) > 0)
         saux := saux + Repl("0", 8 - Len(saux))
         saux1 := saux1 + Chr(strbin_2_d(saux))
      ENDIF
      FOR twcount := 1 TO twaltura
         DevOut("*r1A")
         DevOut("*b" + twstrsiz + "W")
      NEXT
      DevOut("*rbC")
      IF (twaltura > 33)
         DevOut("*p" + LTrim(Trim(Str((twaltura - 33) * -1))) + "Y")
      ENDIF
      IF (twaltura < 33)
         DevOut("*p" + LTrim(Trim(Str((33 - twaltura) * -1))) + "Y")
      ENDIF
   ENDIF

RETURN( NIL )


********************************
PROCEDURE TWIMPC39

   PRIV twalt[8], twcodigo[44]

   twalt[1] := "ÿ"
   twalt[2] := "€"
   twalt[3] := "À"
   twalt[4] := "à"
   twalt[5] := "ð"
   twalt[6] := "ø"
   twalt[7] := "ü"
   twalt[8] := "þ"

   twcodigo[01] := "000110100"
   twcodigo[02] := "100100001"
   twcodigo[03] := "001100001"
   twcodigo[04] := "101100000"
   twcodigo[05] := "000110001"
   twcodigo[06] := "100110000"
   twcodigo[07] := "001110000"
   twcodigo[08] := "000100101"
   twcodigo[09] := "100100100"
   twcodigo[10] := "001100100"
   twcodigo[11] := "100001001"
   twcodigo[12] := "001001001"
   twcodigo[13] := "101001000"
   twcodigo[14] := "000011001"
   twcodigo[15] := "100011000"
   twcodigo[16] := "001011000"
   twcodigo[17] := "000001101"
   twcodigo[18] := "100001100"
   twcodigo[19] := "001001100"
   twcodigo[20] := "000011100"
   twcodigo[21] := "100000011"
   twcodigo[22] := "001000011"
   twcodigo[23] := "101000010"
   twcodigo[24] := "000010011"
   twcodigo[25] := "100010010"
   twcodigo[26] := "001010010"
   twcodigo[27] := "000000111"
   twcodigo[28] := "100000110"
   twcodigo[29] := "001000110"
   twcodigo[30] := "000010110"
   twcodigo[31] := "110000001"
   twcodigo[32] := "011000001"
   twcodigo[33] := "111000000"
   twcodigo[34] := "010010001"
   twcodigo[35] := "110010000"
   twcodigo[36] := "011010000"
   twcodigo[37] := "010000101"
   twcodigo[38] := "110000100"
   twcodigo[39] := "011000100"
   twcodigo[40] := "010101000"
   twcodigo[41] := "010100010"
   twcodigo[42] := "010001010"
   twcodigo[43] := "000101010"
   twcodigo[44] := "010010100"

   IF (twprinter == twepson)
      twsize := twtamr(twsource)
      twchar := twalt[mod(twaltura, 8) + 1]
      DevOut("L" + Chr(mod(twsize, 256)) + Chr(Int(twsize / 256)))
      FOR twi := 1 TO Len(twsource)
         twj := tword39(Subs(twsource, twi, 1))
         FOR twk := 1 TO 9
            IF (Subs(twcodigo[twj], twk, 1) == "1")
               twm := twlbarg
            ELSE
               twm := twlbarf
            ENDIF
            IF (mod(twk, 2) == 1)
               DevOut(Repl(twchar, twm))
            ELSE
               DevOut(Repl(twnulo, twm))
            ENDIF
         NEXT
         DevOut(Repl(twnulo, twlbarf))
      NEXT
      DevOut(Repl(twnulo, twsize - twtam(twsource)))
   ELSEIF (twprinter == twlaser)
      DevOut(twhpaltura(twaltura))
      FOR twi := 1 TO Len(twsource)
         twj := tword39(Subs(twsource, twi, 1))
         FOR twk := 1 TO 9
            IF (Subs(twcodigo[twj], twk, 1) == "1")
               twm := twlbarg
            ELSE
               twm := twlbarf
            ENDIF
            IF (mod(twk, 2) == 1)
               DevOut(twhpretang(twm))
            ELSE
               DevOut(twhpavanco(twm))
            ENDIF
         NEXT
         DevOut(twhpavanco(twlbarf))
      NEXT
   ELSEIF (twprinter == twdeskj)
      twstrsiz := ""
      twsize := twtamr(twsource)
      twstrsiz := LTrim(Trim(Str(twsize)))
      DevOut("*p" + LTrim(Trim(Str(-33))) + "Y")
      DevOut("*t300R")
      twbarra := ""
      FOR twi := 1 TO Len(twsource)
         twj := tword39(Subs(twsource, twi, 1))
         FOR twk := 1 TO 9
            IF (Subs(twcodigo[twj], twk, 1) == "1")
               twm := twlbarg
            ELSE
               twm := twlbarf
            ENDIF
            IF (mod(twk, 2) == 1)
               IF (twm == twlbarg)
                  twbarra := twbarra + "3"
               ELSE
                  twbarra := twbarra + "2"
               ENDIF
            ELSEIF (twm == twlbarg)
               twbarra := twbarra + "1"
            ELSE
               twbarra := twbarra + "0"
            ENDIF
         NEXT
         twbarra := twbarra + "0"
      NEXT
      saux := ""
      saux1 := ""
      FOR twj := 1 TO Len(twbarra)
         twbaraux := Subs(twbarra, twj, 1)
         DO CASE
         CASE twbaraux == "0"
            saux := saux + Repl("0", twlbarf)
         CASE twbaraux == "1"
            saux := saux + Repl("0", twlbarg)
         CASE twbaraux == "2"
            saux := saux + Repl("1", twlbarf)
         CASE twbaraux == "3"
            saux := saux + Repl("1", twlbarg)
         ENDCASE
         While (Len(saux) >= 8)
            saux1 := saux1 + Chr(strbin_2_d(Subs(saux, 1, 8)))
            saux := Subs(saux, 9, Len(saux) - 8)
         End
      NEXT
      IF (Len(saux) > 0)
         saux := saux + Repl("0", 8 - Len(saux))
         saux1 := saux1 + Chr(strbin_2_d(saux))
      ENDIF
      FOR twcount := 1 TO twaltura
         DevOut("*r1A")
         DevOut("*b" + twstrsiz + "W")
         DevOut(saux1)
      NEXT
      DevOut("*rbC")
      IF (twaltura > 33)
         DevOut("*p" + LTrim(Trim(Str((twaltura - 33) * -1))) + "Y")
      ENDIF
      IF (twaltura < 33)
         DevOut("*p" + LTrim(Trim(Str((33 - twaltura) * -1))) + "Y")
      ENDIF
   ENDIF

RETURN( NIL )


********************************
PROCEDURE TWIMPC128

   PRIV twalt[8], twbuffer[52], twcodigo[106]

   codeset := 0
   a := 1
   b := 2
   c := 3

   twalt[1] := "ÿ"
   twalt[2] := "€"
   twalt[3] := "À"
   twalt[4] := "à"
   twalt[5] := "ð"
   twalt[6] := "ø"
   twalt[7] := "ü"
   twalt[8] := "þ"

   twcodigo[01] := "11011001100"
   twcodigo[02] := "11001101100"
   twcodigo[03] := "11001100110"
   twcodigo[04] := "10010011000"
   twcodigo[05] := "10010001100"
   twcodigo[06] := "10001001100"
   twcodigo[07] := "10011001000"
   twcodigo[08] := "10011000100"
   twcodigo[09] := "10001100100"
   twcodigo[10] := "11001001000"
   twcodigo[11] := "11001000100"
   twcodigo[12] := "11000100100"
   twcodigo[13] := "10110011100"
   twcodigo[14] := "10011011100"
   twcodigo[15] := "10011001110"
   twcodigo[16] := "10111001100"
   twcodigo[17] := "10011101100"
   twcodigo[18] := "10011100110"
   twcodigo[19] := "11001110010"
   twcodigo[20] := "11001011100"
   twcodigo[21] := "11001001110"
   twcodigo[22] := "11011100100"
   twcodigo[23] := "11001110100"
   twcodigo[24] := "11101101110"
   twcodigo[25] := "11101001100"
   twcodigo[26] := "11100101100"
   twcodigo[27] := "11100100110"
   twcodigo[28] := "11101100100"
   twcodigo[29] := "11100110100"
   twcodigo[30] := "11100110010"
   twcodigo[31] := "11011011000"
   twcodigo[32] := "11011000110"
   twcodigo[33] := "11000110110"
   twcodigo[34] := "10100011000"
   twcodigo[35] := "10001011000"
   twcodigo[36] := "10001000110"
   twcodigo[37] := "10110001000"
   twcodigo[38] := "10001101000"
   twcodigo[39] := "10001100010"
   twcodigo[40] := "11010001000"
   twcodigo[41] := "11000101000"
   twcodigo[42] := "11000100010"
   twcodigo[43] := "10110111000"
   twcodigo[44] := "10110001110"
   twcodigo[45] := "10001101110"
   twcodigo[46] := "10111011000"
   twcodigo[47] := "10111000110"
   twcodigo[48] := "10001110110"
   twcodigo[49] := "11101110110"
   twcodigo[50] := "11010001110"
   twcodigo[51] := "11000101110"
   twcodigo[52] := "11011101000"
   twcodigo[53] := "11011100010"
   twcodigo[54] := "11011101110"
   twcodigo[55] := "11101011000"
   twcodigo[56] := "11101000110"
   twcodigo[57] := "11100010110"
   twcodigo[58] := "11101101000"
   twcodigo[59] := "11101100010"
   twcodigo[60] := "11100011010"
   twcodigo[61] := "11101111010"
   twcodigo[62] := "11001000010"
   twcodigo[63] := "11110001010"
   twcodigo[64] := "10100110000"
   twcodigo[65] := "10100001100"
   twcodigo[66] := "10010110000"
   twcodigo[67] := "10010000110"
   twcodigo[68] := "10000101100"
   twcodigo[69] := "10000100110"
   twcodigo[70] := "10110010000"
   twcodigo[71] := "10110000100"
   twcodigo[72] := "10011010000"
   twcodigo[73] := "10011000010"
   twcodigo[74] := "10000110100"
   twcodigo[75] := "10000110010"
   twcodigo[76] := "11000010010"
   twcodigo[77] := "11001010000"
   twcodigo[78] := "11110111010"
   twcodigo[79] := "11000010100"
   twcodigo[80] := "10001111010"
   twcodigo[81] := "10100111100"
   twcodigo[82] := "10010111100"
   twcodigo[83] := "10010011110"
   twcodigo[84] := "10111100100"
   twcodigo[85] := "10011110100"
   twcodigo[86] := "10011110010"
   twcodigo[87] := "11110100100"
   twcodigo[88] := "11110010100"
   twcodigo[89] := "11110010010"
   twcodigo[90] := "11011011110"
   twcodigo[91] := "11011110110"
   twcodigo[92] := "11110110110"
   twcodigo[93] := "10101111000"
   twcodigo[94] := "10100011110"
   twcodigo[95] := "10001011110"
   twcodigo[96] := "10111101000"
   twcodigo[97] := "10111100010"
   twcodigo[98] := "11110101000"
   twcodigo[99] := "11110100010"
   twcodigo[100] := "10111011110"
   twcodigo[101] := "10111101110"
   twcodigo[102] := "11101011110"
   twcodigo[103] := "11110101110"
   twcodigo[104] := "11010000100"
   twcodigo[105] := "11010010000"
   twcodigo[106] := "11010011100"
   twwrkbuf := ""
   twwrkbuf := twsource
   IF (Subs(twwrkbuf, 1, 1) == ">")
      IF (Len(twwrkbuf) > 1 .AND. (Subs(twwrkbuf, 2, 1) == "9" .OR. Subs(twwrkbuf, 2, 1) == ":" .OR. Subs(twwrkbuf, 2, 1) == ";"))
      ELSE
         twwrkbuf := ">:" + twwrkbuf
      ENDIF
   ELSE
      twwrkbuf := ">:" + twwrkbuf
   ENDIF
   twbufsize := 0
   While (Len(twwrkbuf) > 0)
      IF (Subs(twwrkbuf, 1, 1) == ">")
         IF (Len(twwrkbuf) > 1)
            twsub := Subs(twwrkbuf, 2, 1)
            DO CASE
            CASE twsub == "<"
               IF ( ! codeset == c )
                  twbufsize ++
                  twbuffer[twbufsize] := 62
               ENDIF
               twwrkbuf := Subs(twwrkbuf, -(Len(twwrkbuf) - 2), Len(twwrkbuf) - 2)
            CASE twsub == "0"
               IF (codeset == c)
                  twwrkbuf := Subs(twwrkbuf, -(Len(twwrkbuf) - 1), Len(twwrkbuf) - 1)
               ELSE
                  twbufsize ++
                  twbuffer[twbufsize] := 30
                  twwrkbuf := Subs(twwrkbuf, -(Len(twwrkbuf) - 2), Len(twwrkbuf) - 2)
               ENDIF
            CASE twsub == "="
               IF ( ! codeset == c )
                  twbufsize ++
                  twbuffer[twbufsize] := 94
               ENDIF
               twwrkbuf := Subs(twwrkbuf, -(Len(twwrkbuf) - 2), Len(twwrkbuf) - 2)
            CASE twsub == "1" .OR. twsub == "2" .OR. twsub == "3"
               IF (codeset == c)
                  twwrkbuf := Subs(twwrkbuf, -(Len(twwrkbuf) - 1), Len(twwrkbuf) - 1)
               ELSE
                  twbufsize ++
                  twbuffer[twbufsize] := Asc(Subs(twwrkbuf, 2, 1)) + 46
                  twwrkbuf := Subs(twwrkbuf, -(Len(twwrkbuf) - 2), Len(twwrkbuf) - 2)
               ENDIF
            CASE twsub == "4"
               IF (codeset == c)
                  twwrkbuf := Subs(twwrkbuf, -(Len(twwrkbuf) - 1), Len(twwrkbuf) - 1)
                  twbufsize ++
                  twbuffer[twbufsize] := 98
                  twwrkbuf := Subs(twwrkbuf, -(Len(twwrkbuf) - 2), Len(twwrkbuf) - 2)
                  IF (codeset == a)
                     codeset := b
                  ELSE
                     codeset := a
                  ENDIF
               ENDIF
            CASE twsub == "5"
               IF (codeset == c)
                  twwrkbuf := Subs(twwrkbuf, -(Len(twwrkbuf) - 1), Len(twwrkbuf) - 1)
               ELSE
                  twbufsize ++
                  twbuffer[twbufsize] := 99
                  twwrkbuf := Subs(twwrkbuf, -(Len(twwrkbuf) - 2), Len(twwrkbuf) - 2)
                  codeset := c
               ENDIF
            CASE twsub == "6"
               twbufsize ++
               twbuffer[twbufsize] := 100
               twwrkbuf := Subs(twwrkbuf, -(Len(twwrkbuf) - 2), Len(twwrkbuf) - 2)
               codeset := b
            CASE twsub == "7"
               twbufsize ++
               twbuffer[twbufsize] := 101
               twwrkbuf := Subs(twwrkbuf, -(Len(twwrkbuf) - 2), Len(twwrkbuf) - 2)
               codeset := a
            CASE twsub == "8"
               twbufsize ++
               twbuffer[twbufsize] := 102
               twwrkbuf := Subs(twwrkbuf, -(Len(twwrkbuf) - 2), Len(twwrkbuf) - 2)
            CASE twsub == "9"
               twbufsize ++
               twbuffer[twbufsize] := 103
               twwrkbuf := Subs(twwrkbuf, -(Len(twwrkbuf) - 2), Len(twwrkbuf) - 2)
               codeset := a
            CASE twsub == ":"
               twbufsize ++
               twbuffer[twbufsize] := 104
               twwrkbuf := Subs(twwrkbuf, -(Len(twwrkbuf) - 2), Len(twwrkbuf) - 2)
               codeset := b
            CASE twsub == ";"
               twbufsize ++
               twbuffer[twbufsize] := 105
               twwrkbuf := Subs(twwrkbuf, -(Len(twwrkbuf) - 2), Len(twwrkbuf) - 2)
               codeset := c
            OTHERWISE
               IF ( ! codeset == c )
                  twbufsize ++
                  twbuffer[twbufsize] := 62
               ENDIF
               twwrkbuf := Subs(twwrkbuf, -(Len(twwrkbuf) - 1), Len(twwrkbuf) - 1)
            ENDCASE
         ELSE
            IF ( ! codeset == c )
               twbufsize ++
               twbuffer[twbufsize] := 62
            ENDIF
            twwrkbuf := Subs(twwrkbuf, -(Len(twwrkbuf) - 1), Len(twwrkbuf) - 1)
         ENDIF
      ELSEIF (codeset == a .OR. codeset == b)
         IF (Asc(Subs(twwrkbuf, 1, 1)) >= 32 .AND. Asc(Subs(twwrkbuf, 1, 1)) <= 127)
            twbufsize ++
            twbuffer[twbufsize] := Asc(Subs(twwrkbuf, 1, 1)) - 32
         ENDIF
         twwrkbuf := Subs(twwrkbuf, -(Len(twwrkbuf) - 1), Len(twwrkbuf) - 1)
      ELSEIF (codeset == c)
         IF (Len(twwrkbuf) > 1 .AND. Subs(twwrkbuf, 1, 1) >= "0" .AND. Subs(twwrkbuf, 1, 1) <= "9")
            IF (Subs(twwrkbuf, 2, 1) >= "0" .AND. Subs(twwrkbuf, 2, 1) <= "9")
               twbufsize ++
               twbuffer[twbufsize] := (Asc(Subs(twwrkbuf, 1, 1)) - 48) * 10 + Asc(Subs(twwrkbuf, 2, 1)) - 48
            ENDIF
            twwrkbuf := Subs(twwrkbuf, -(Len(twwrkbuf) - 2), Len(twwrkbuf) - 2)
         ELSE
            twwrkbuf := Subs(twwrkbuf, -(Len(twwrkbuf) - 1), Len(twwrkbuf) - 1)
         ENDIF
      ENDIF
   End
   IF (twprinter == twepson)
      twbarra := ""
      twwrkl := twbuffer[1]
      FOR twj := 2 TO twbufsize
         twwrkl := twwrkl + (twj - 1) * twbuffer[twj]
      NEXT
      twbufsize ++
      twbuffer[twbufsize] := Int(mod(twwrkl, 103))
      twsize := twtamr(twsource)
      twchar := twalt[mod(twaltura, 8) + 1]
      FOR twi := 1 TO twbufsize
         twbarra := twbarra + twcodigo[twbuffer[twi] + 1]
      NEXT
      twbarra := twbarra + "1100011101011"
      DevOut("L" + Chr(mod(Len(twbarra) * twlbarf, 256)) + Chr(Int(Len(twbarra) * twlbarf / 256)))
      FOR twa := 1 TO Len(twbarra)
         IF (Subs(twbarra, twa, 1) == "0")
            DevOut(Repl(twnulo, twlbarf))
         ELSE
            DevOut(Repl(twchar, twlbarf))
         ENDIF
      NEXT
   ELSEIF (twprinter == twlaser)
      twbarra := ""
      twwrkl := twbuffer[1]
      FOR twj := 2 TO twbufsize
         twwrkl := twwrkl + (twj - 1) * twbuffer[twj]
      NEXT
      twbufsize ++
      twbuffer[twbufsize] := Int(mod(twwrkl, 103))
      FOR twi := 1 TO twbufsize
         twbarra := twbarra + twcodigo[twbuffer[twi] + 1]
      NEXT
      twbarra := twbarra + "1100011101011"
      DevOut(twhpaltura(twaltura))
      FOR twa := 1 TO Len(twbarra)
         IF (Subs(twbarra, twa, 1) == "0")
            DevOut(twhpavanco(twlbarf))
         ELSE
            DevOut(twhpretang(twlbarf))
         ENDIF
      NEXT
   ELSEIF (twprinter == twdeskj)

      twwrkl := twbuffer[1]
      FOR twj := 2 TO twbufsize
         twwrkl := twwrkl + (twj - 1) * twbuffer[twj]
      NEXT

      twbufsize ++
      twbuffer[twbufsize] := Int(mod(twwrkl, 103))
      twbarra  := ""
      twstrsiz := ""
      twsize   := twtamr(twsource)
      twstrsiz := LTrim(Trim(Str(twsize)))
      DevOut("*p" + LTrim(Trim(Str(-33))) + "Y")
      DevOut("*t300R")

      twbarra := ""
      FOR twi := 1 TO twbufsize
         twbarra += twcodigo[twbuffer[twi] + 1]
      NEXT

      twbarra += "1100011101011"
      conta   := 0
      saux    := ""
      saux1   := ""

      FOR twj := 1 TO Len(twbarra)
         saux := saux + Repl(Subs(twbarra, twj, 1), twlbarf)
         While (Len(saux) >= 8)
            saux1 := saux1 + Chr(strbin_2_d(Subs(saux, 1, 8)))
            saux := Subs(saux, 9, Len(saux) - 8)
         End
      NEXT
      IF (Len(saux) > 0)
         saux := saux + Repl("0", 8 - Len(saux))
         saux1 := saux1 + Chr(strbin_2_d(saux))
      ENDIF
      FOR twcount := 1 TO twaltura
         DevOut("*r1A")
         DevOut("*b" + twstrsiz + "W")
         DevOut(saux1)
      NEXT
      DevOut("*rbC")
      IF (twaltura > 33)
         DevOut("*p" + LTrim(Trim(Str((twaltura - 33) * -1))) + "Y")
      ENDIF
      IF (twaltura < 33)
         DevOut("*p" + LTrim(Trim(Str((33 - twaltura) * -1))) + "Y")
      ENDIF
   ENDIF

RETURN( NIL )
