SC_RandomString( Options )
{ Div := 0, Total := 0
If not RegExMatch( Options, "(M|m)(\d+)", _)
Return 1
If RegExMatch( Options, "(U|u)(\d?)", __)
Div++, U := 1
If RegExMatch( Options, "(L|l)(\d?)", ___)
Div++, L := 1
If RegExMatch( Options, "(D|d)(\d?)", ____)
Div++, D := 1
Max := _2, Un := __2, Ln := ___2, Dn := ____2, Un := Un > 0 ? Un : 1, Ln := Ln > 0 ? Ln : 1, Dn := Dn > 0 ? Dn : 1, Total := ( Un + LN + Dn ) , Un := U < 0 ? 0 : Un, Ln := L < 0 ? 0 : Ln, Dn := D < 0 ? 0 : Dn
If ( Un + LN + Dn ) > Max 
Return 2
SC_Loop:
Loop, %Total%
{ Random, Ran, 65, 90
Out .= Un > 0 ? ( Chr(Ran) , Un-- ) : "" 
If StrLen( Out ) = Max
Goto, End
Random, Ran, 97, 122
Out .= Ln > 0 ? ( Chr(Ran), Ln-- ) : ""
If StrLen( Out ) = Max
Goto, End
Random, Ran, 0,9
Out .= Dn > 0 ? ( Ran, Dn-- ) : ""
If StrLen( Out ) = Max
Goto, End
}
If StrLen( Out ) < Max
{ Un+= U > 0 ? 1 : 0,Ln+= L > 0 ? 1 : 0,Dn+= D > 0 ? 1 : 0
Goto, SC_Loop
}
End:
Loop, Parse, Out,
{ gOut .= A_LoopField ","
Sort, gOut, Random D`,
}
Loop, Parse, gOut, `,
{ If A_LoopField = %Last%
Return SC_RandomString( Options ) 
Last := A_LoopField
}
StringReplace, Out, gOut, `,,,All
Return Out
}