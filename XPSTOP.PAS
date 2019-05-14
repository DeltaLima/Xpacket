{ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ                                                                         ณ
 ณ                             X - P a c k e t                             ณ
 ณ                                                                         ณ
 ณ                                                                         ณ
 ณ  X P S T O P . P A S                                                    ณ
 ณ                                                                         ณ
 ณ Routinen fr die Auwertung der STOP-Kompression und Codierung.          ณ
 ณ                                                                         ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู}


Function STOPCompress (Kanal : Byte; Zeile : String; Code : Byte) : String;
Var   Hstr : String;
      t    : Word;
      s    : Word;
      i    : Byte;
      a    : Integer;
      b,c  : Byte;
      ch   : Char;
      long : Boolean;
Begin
  if Zeile > '' then
  begin
    Zeile := PackIt(Zeile);
    FillChar(Hstr,SizeOf(Hstr),0);
    a := 7;
    b := 1;
    long := false;

    i := 0;
    While (i < length(Zeile)) and not long do
    begin
      inc(i);
      t := HTable[ord(Zeile[i])].Tab;
      s := $8000;
      C := 0;

      While (C < HTable[ord(Zeile[i])].Len) and not long do
      begin
        inc(C);
        if t and s = s then Hstr[b] := Chr(ord(Hstr[b]) + 1 shl a);
        s := s shr 1;
        dec(a);
        if a < 0 then
        begin
          a := 7;
          inc(b);
          if b > 254 then long := true;
        end;
      end;
      Hstr[0] := chr(b);
    end;

    Hstr := CodeIt(Kanal, Hstr, Code);

    if (length(Hstr) > length(Zeile)) or long then
    begin
      Hstr := CodeIt(Kanal, Zeile, Code);
      Hstr := Chr(length(Hstr)) + Hstr;
      ch := #255;
    end else ch := Chr(length(Hstr));

    STOPCompress := ch + Hstr;
  end else STOPCompress := '';
End;

Function STOPDeCompress (Kanal : Byte; Zeile2 : String; Code : Byte) : String;
Var   Zeile,
      Hstr  : String;
      b,i,l : Byte;
      a     : Integer;
      t,t2  : Word;
      Bit   : LongInt;
      ch    : Char;

Begin
  Zeile := Zeile2;
  ch := Zeile[1];
  delete(Zeile,1,1);
  if ch = #255 then delete(Zeile,1,1);

  Zeile := DeCodeIt(Kanal, Zeile, Code);

  if (ch < #255) and (Zeile[0] > #0) then
  begin
    Hstr := '';
    l := 0;
    Bit := 0;

    for i := 1 to length(Zeile) do
    begin
      Bit := (Bit shl 8) or ord(Zeile[i]);
      l := Byte(l + 8);

      a := 0;

      Repeat
        b := HTable[a].Len;
        if l >= b then
        begin
          t := HTable[a].Tab;
          t2 := Word(Bit shr (l-b)) shl (16-b);

          if t = t2 then
          begin
            Hstr := Hstr + chr(a);
            l := l - b;
            a := -1;
          end;
        end;
        inc(a);
      Until (a > 257) or (l < 3);
    end;
  end else Hstr := Zeile;

  Hstr := UnPackIt(Hstr);

  if Kanal = 0 then
  begin
    t := K[0]^.StopCode;
    K[0]^.StopCode := G^.DetCode;
    if STOPCompress(0, Hstr, Code) <> Zeile2 then
    begin
                    Hstr := Zeile2;
    end;
    K[0]^.StopCode := t;
  end;

  STOPDeCompress := Hstr;
End;



Function  PMak (Nr : Byte) : String;
Begin
       if Nr = 53 then PMak := ' ษออออออหออออออหออหอออออออออออออออออหออออออออหอออออออออหอออออออออออออออ List อป' + M1
  else if Nr = 54 then PMak := ' บMsg.-#บPFRAKSบKBบ   An   @  BBS   บ  Von   บDat./Zeitบ        Titel         บ' + M1
  else if Nr = 55 then PMak := ' ฬออออออฮออออออฮออฮอออออออออออออออออฮออออออออฮอออออออออฮออออออออออออออออออออออน' + M1
  else if Nr = 56 then PMak := ' ศออออออสออออออสออสอออออออออออออออออสออออออออสอออออออออสออออออออออออออออออออออผ' + M1
  else if Nr = 57 then PMak := ' ษออออออหออออออหอออออหอออออออออออออออออหออออออออหอออออออออหอออออออออหออ Read อป' + M1
  else if Nr = 58 then PMak := ' บMsg.-#บPFRAKSบ Byteบ   An   @  BBS   บ  Von   บDat./ZeitบGeschrbn.บ  Lifet. บ' + M1
  else if Nr = 59 then PMak := ' ฬออออออฮออออออฮอออออฮอออออออออออออออออฮออออออออฮอออออออออฮอออออออออฮอออออออออน' + M1
  else if Nr = 60 then PMak := ' ศออออออสออออออสอออออสอออออออออออออออออสออออออออสอออออออออสอออออออออสอออออออออผ' + M1
  else if Nr = 61 then PMak := ' ษออออออหออออออหอออออหอออออออออออออออออหออออออออหอออออออออหอออหออออออออ Send อป' + M1
  else if Nr = 62 then PMak := ' บMsg.-#บPFRAKSบ Byteบ   An   @  BBS   บ  Von   บDat./ZeitบLt.บ  Bulletin-ID  บ' + M1
  else if Nr = 63 then PMak := ' ฬออออออฮออออออฮอออออฮอออออออออออออออออฮออออออออฮอออออออออฮอออฮอออออออออออออออน' + M1
  else if Nr = 64 then PMak := ' ฬออออออสออออออสอออออสอออออออออออออออออสออออออออสอออออออออสอออสอออออออออออออออน' + M1
  else if Nr = 65 then PMak := ' ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ' + M1

  else PMak := '';
End;


Function  PackIt (Zeile : String) : String;
Var i, j,
    az    : Integer;
    PM,
    Hstr  : String;
Begin
  Hstr := '';
  i := 1;
  while i <= length(Zeile) - 3 do
  begin
    az := 0;
    for j := 53 to maxPMak do
    begin
      PM := PMak(j);
      if Copy(Zeile,i,length(PM)) = PM then
      begin
        az := 1;
        Hstr := Hstr + chr(255) + chr(255) + chr(j-1);
        i := i + length(PM);
        j := maxPMak;
      end;
    end;
    if az = 0 then
    begin
      if Zeile[i] = Zeile[i+1] then
      begin
        if (Zeile[i] = Zeile[i+2]) and (Zeile[i] = Zeile[i+3]) then
        begin
          az := 4;
          while (i + az <= length(Zeile)) and (Zeile[i] = Zeile[i+az]) do
            az := az + 1;
          Hstr := Hstr + chr(255) + chr(az) + Zeile[i];
          i := i + az - 1;
        end;
      end;
      if az = 0 then
      begin
        Hstr := Hstr + Zeile[i];
        if Zeile[i] = chr(255) then Hstr := Hstr + chr(0);
      end;
      i := i + 1;
    end;
  end;
  while i <= length(Zeile) do
  begin
    Hstr := Hstr + Zeile[i];
    if Zeile[i] = chr(255) then Hstr := Hstr + chr(0);
    i := i + 1;
  end;
  PackIt := Hstr;
End;

Function  UnPackIt (Zeile : String) : String;
Var i,
    az    : Integer;
    Hstr  : String;
Begin
  Hstr := '';
  i := 1;
  while i <= length(Zeile) do
  begin
    if Zeile[i] = chr(255) then
    begin
      i := i + 1;
      if Zeile[i] = chr(0) then Hstr := Hstr + chr(255)
      else if Zeile[i] = chr(255) then
      begin
        i := i + 1;
        Hstr := Hstr + PMak(ord(Zeile[i])+1);
      end else
      begin
        az := ord(Zeile[i]);
        i := i + 1;
        while az > 0 do
        begin
          Hstr := Hstr + Zeile[i];
          az := az - 1;
        end;
      end;
    end else Hstr := Hstr + Zeile[i];
    i := i + 1;
  end;
  UnPackIt := Hstr;
End;

Function DetectStopCode {(LastBt, Cd1, Cd2 : Byte) : Boolean};
begin
 DetectStopCode := LastBt = (cd1 xor cd2 xor 55);
end;

Function  CodeIt (Kanal : Byte; Zeile : String; Code : Byte) : String;
Var c1,c2 : Byte;
    i     : Integer;
    flag  : Boolean;
    Hstr  : String;
Begin
  if (K[Kanal]^.StopCode > 0) and (Zeile > '') then
  begin
    c1 := Byte(K[Kanal]^.StopCode shr 8);
    c2 := Byte(K[Kanal]^.StopCode and 255);
    Hstr := Chr(c1) + Chr(c2);
		 Hstr := Hstr + Chr(c1 xor c2 xor 55);
    flag := true;               {======================
				 wr sch”n, wenns richtig wre, ist es
				 aber nicht :-) Das ist die angebliche
				 Berechnung des Check-Bytes}

    for i := length(Zeile) downto 1 do
    begin
      if flag then begin Hstr := Chr(Ord(Zeile[i]) xor c1) + Hstr; flag := false; end
      else begin Hstr := Chr(Ord(Zeile[i]) xor c2) + Hstr; flag := true; end;
    end;
    CodeIt := Hstr;
  end else CodeIt := Zeile;
End;

Function  DeCodeIt (Kanal : Byte; Zeile : String; Code : Byte) : String;
Var c1,c2 : Byte;
    i     : Integer;
    flag  : Boolean;
    Hstr  : String;
    InOrdung:boolean;
Begin
  i := length(Zeile);
  if i > 3 then
  begin
    c1 := Byte(Zeile[i-2]);
    c2 := Byte(Zeile[i-1]);
    InOrdung:=false;
    if ((((Word(c1) shl 8) + Word(c2)) = K[Kanal]^.StopCode)          ) and
       (DetectStopCode (Byte(Zeile[i]), c1,c2)                        ) {and
  !weg lassen!     (not k[kanal]^.mo.MonActive)                                   }  then InOrdung:=true;

    {nachfolgender Teil fr den Spion-Autodetect!}
{$IFDEF code}
    if (DetectStopCode (Byte(Zeile[i]), c1,c2)                        ) and
       (k[kanal]^.mo.MonActive)                                         then InOrdung:=true;
{$ENDIF}


  if InOrdung then
    begin
      G^.DetCode := ((Word(c1) shl 8) + Word(c2));
      Hstr := '';
      flag := (length(Zeile) mod 2) = 0;
      for i := 1 to length(Zeile) - 3 do
      begin
        if flag then begin Hstr := Hstr + Chr(Ord(Zeile[i]) xor c1); flag := false; end
        else begin Hstr := Hstr + Chr(Ord(Zeile[i]) xor c2); flag := true; end;
      end;
      Zeile := Hstr;
    end else G^.DetCode := 0;
  end else G^.DetCode := 0;
  DeCodeIt := Zeile;
End;

Function  CodeStr (Kanal : Byte; Zeile : String) : String;
Var i : Integer;
Begin
  for i := 1 to length(Zeile) do
  begin
    Zeile[i] := Chr(CodeTab[Ord(Zeile[i])]);
  end;
  CodeStr := Zeile;
End;

Function  DeCode (Kanal : Byte; Zeile : String) : String;
Var i : Integer;
Begin
  for i := 1 to length(Zeile) do
  begin
    Zeile[i] := Chr(DeCodeTab[Ord(Zeile[i])]);
  end;
  DeCode := Zeile;
End;

Function  GetCode (Call : Str9) : Word;
Begin
  {ReadUser(Call);
  GetCode := U^.Komp;}

  GetCode:=200;  {Hier sollte eigentlich der Code bergeben werden,
                  der dem User zugeordnet ist. Bei Tests mit anderen
                  Codes umstellen!!!}
End;








Function  F2C(Call : Str9) : Str9; Begin F2C := Call; End;



