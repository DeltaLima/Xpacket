{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P S T R . P A S                                                      ³
 ³                                                                         ³
 ³ Library - Unit mit oft ben”tigten Routinen fr die Stringverarbeitung   ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}

Function  str_int (* Zeile : Str10 : LongInt *);
Var i    : Integer;
    Zahl : LongInt;
Begin
  Val(Zeile,Zahl,i);
  if (i > 0) then Zahl := 0;
  Str_Int := Zahl;
End;


Function  int_str (* i : LongInt) : Str10 *);
Var   Hstr  : String[10];
Begin
  str(i,Hstr);
  int_str := Hstr;
End;


Function ConstStr (* VC : Char ; L : Byte) : Str80; *);
Const  ML = 80;
Var    Bstr : String[80];
Begin
  if L > ML then L := ML;
  Bstr := '';
  FillChar(Bstr[1],L,VC);
  Bstr[0] := Chr(L);
  ConstStr := Bstr;
End;


Function RetStr (* Zeile : String) : String *) ;
Var   i : Byte;
Begin
 i := pos(M1,Zeile);
 if i = 0 then i := Length(Zeile)
          else Dec(i);
 Zeile[0] := Chr(i);
 RetStr := Zeile;
End;


Function CutStr (* Zeile : String) : String *) ;
Var   i : Byte;
Begin
 i := pos(B1,Zeile);
 if i = 0 then i := Length(Zeile)
          else Dec(i);
 Zeile[0] := Chr(i);
 CutStr := Zeile;
End;


Function  RestStr (* (Zeile : String) : String *);
Var       i,i1 : Byte;
Begin
  i := pos(B1,Zeile);
  if i > 0 then
  begin
    i1 := length(Zeile) - i;
    Zeile[0] := Chr(i1);
    move(Zeile[i+1],Zeile[1],i1);
    While (Zeile[0] > #0) and (Zeile[1] = ' ') do delete(Zeile,1,1);
  end else Zeile := '';
  RestStr := Zeile;
End;


Function UpCaseStr (* (Zeile : String) : String *) ;
Var  i   : Byte;
Begin
  for i := 1 to Ord(Zeile[0]) do
   if Zeile[i] in ['a'..'z'] then dec(Zeile[i],$20);
  UpCaseStr := Zeile;
End;


Procedure KillEndBlanks (* var Zeile : String *);
Begin
  While (Zeile[0] > #0) and (Zeile[Ord(Zeile[0])] = B1) do dec(Zeile[0]);
End;


Procedure KillStartBlanks (* Var Zeile : String *);
Begin
  While (Zeile[0] > #0) and (Zeile[1] = B1) do
  begin
    dec(Zeile[0]);
    move(Zeile[2],Zeile[1],Ord(Zeile[0]));
  end;
End;


Function ParmStr (* (Nr : Byte; VC : char; Zeile : String) : String *);
Var      i,i1,
         i2,i3 : Byte;
         Hstr  : String;
Begin
  if Zeile > '' then
  begin
    i2 := 0;
    i3 := 254;
    While (ord(Zeile[0]) > 0) and (Zeile[1] = VC) do
    begin
      delete(Zeile,1,1);
      inc(i2);
    end;

    Hstr := '';
    i1 := 1;
    for i := 1 to Ord(Zeile[0]) do
    begin
      if Nr = i1 then if Zeile[i] <> VC then
      begin
        Hstr := Hstr + Zeile[i];
        i3 := i;
      end;
      if (Zeile[i] = VC) and (Zeile[i-1] <> VC) then inc(i1);
    end;
    While (Hstr[0] > #0) and (Hstr[Ord(Hstr[0])] = B1) do Hstr[0] := Chr(Ord(Hstr[0])-1);
    While (Hstr[0] > #0) and (Hstr[1] = B1) do delete(Hstr,1,1);
    ParmAnz := i1;
    ParmPos := Byte(i3 + i2 - length(Hstr) + 1);
    ParmStr := Hstr;
  end else
  begin
    ParmAnz := 0;
    ParmPos := 0;
    ParmStr := '';
  end;
End;

Function  SFillStr (* Anz : Byte; VC : Char; Zeile : String) : String *);
Var  i,i1 : Byte;
Begin
  i := length(Zeile);
  if i < Anz then
  begin
    i1 := Anz - i;
    move(Zeile[1],Zeile[i1+1],i);
    FillChar(Zeile[1],i1,VC);
    Zeile[0] := Chr(Anz);
  end;
  SFillStr := Zeile;
End;


Function  EFillStr (* Anz : Byte; VC : Char; Zeile : String) : String *);
Var  i : Byte;
Begin
  i := length(Zeile);
  if i < Anz then
  begin
    FillChar(Zeile[i+1],Anz-i,VC);
    Zeile[0] := Chr(Anz);
  end;
  EFillStr := Zeile;
End;

Function  CEFillStr (* Anz : Byte; VC : Char; Zeile : String) : String *);
Var  i : Byte;
Begin
  i := length(Zeile);
  if i < Anz then
  begin
    FillChar(Zeile[i+1],Anz-i,VC);
    Zeile[0] := Chr(Anz);
  end;
  cEFillStr:=copy(Zeile,1,Anz);
End;



Function  ZFillStr (* Anz : Byte; VC : Char; Zeile : String) : String *);
Begin
  While length(Zeile) < Anz do Zeile := VC + Zeile + VC;
  if length(Zeile) > Anz then Zeile := copy(Zeile,1,Anz);
  ZFillStr := Zeile;
End;


Function  Hex (* Dezimal : LongInt; Stellenzahl : Byte) : Str8 *);
Const HexChars  : Array [0..15] of Char = ('0','1','2','3','4','5','6','7',
                                           '8','9','A','B','C','D','E','F');
Var    Stelle : Byte;
Begin
  if (Stellenzahl > 8) then Stellenzahl := 8;
  Hex := '        ';
  Hex[0] := Chr(Stellenzahl);
  for Stelle := Stellenzahl downto 1 do
  begin
    Hex[Stelle] := HexChars[Dezimal and $0F];
    Dezimal := Dezimal shr 4;
  end;
End;


Function  Adr_absolut(Zeiger : Pointer) : LongInt;
Begin
  if Zeiger = NIL then Adr_absolut := 0
         else Adr_absolut := (LongInt(Seg(Zeiger^)) shl 4) + Ofs(Zeiger^);
End;


Function Pointer_Str (* Zeiger : Pointer) : Str9 *);
Begin
  if Zeiger = NIL then Pointer_Str := 'NIL      '
         else Pointer_Str := Hex(Seg(Zeiger^),4) + DP + Hex(Ofs(Zeiger^),4);
End;


Function FormByte (* Zeile : str11) : str11  *);
var  Bstr : String[11];
     i,i1 : Byte;
Begin
  Bstr := '';
  i1 := length(Zeile);
  for i := 1 to i1 do
  begin
    Bstr := Zeile[i1+1-i] + Bstr;
    if (i > 1) and (i < i1) and (i mod 3 = 0) then Bstr := Pkt  + Bstr;
  end;
  FormByte := Bstr;
End;


Function  Bin (* Dezimal : LongInt ; Stellenzahl : Byte) : Str32 *);
Var    Stelle : Byte;
Begin
  if Stellenzahl > 32 then Stellenzahl := 32;
  Bin[0] := Chr(Stellenzahl);
  for Stelle := Stellenzahl downto 1 do
  begin
    if (Dezimal and $01) > 0 then Bin[Stelle] := '1'
                             else Bin[Stelle] := '0';
    Dezimal := Dezimal shr 1;
  end;
End;


Procedure Strip (* var Call: str9 *);
Var p : Byte;
Begin
  p := pos('-',Call);
  if p > 0 then Call := Copy(Call,1,p-1);
End;
