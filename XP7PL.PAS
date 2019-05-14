{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  Primaryfile:     X P . P A S                                           ³
 ³                                                                         ³
 ³                                                                         ³
 ³ Routinen fuer den Empfang von 7Plusfiles                                ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


Procedure Open_Close_7Plus (* Kanal : Byte; Zeile : Str80 *);
Const   Cnt    = 'CNT';
Var     i,i1   : Byte;
        Result : Word;
        Sstr   : String[8];
        Nstr   : String[12];
        Vstr   : String[80];
        Suf    : String[3];
        Flag   : Boolean;
        f      : Text;
Begin
  with K[Kanal]^ do
  begin
    if SplSave then
    begin
      Vstr := FName_aus_FVar(SplFile);
      SplSave := false;
      Spl_COR_ERR := false;
      FiResult := CloseBin(SplFile);
      Umlaut := Spl_UmlMerk;

      Vstr := copy(Vstr,1,pos(Pkt,Vstr)) + Cnt;
      Assign(f,Vstr);
      if RewriteTxt(f) = 0 then
      begin
        Writeln(f,Spl_gCount);
        FiResult := CloseTxt(f);
      end;
    end else
    begin
      if MldOk = 11 then   (* 7PL .. P0X *)
      begin
        Spl_Time := Uhrzeit;
        Spl_tCount := 0;
        Spl_tLaenge := str_int('$' + ParmStr(7,B1,Zeile));
        Spl_tLaenge := (Spl_tLaenge div 64) +  2;

        i1 := str_int(ParmStr(4,B1,Zeile));
        Spl_gLaenge := str_int(ParmStr(6,B1,Zeile));
        Spl_gLaenge := (Spl_gLaenge div 62) +  2 * i1;
        if Spl_gLaenge mod 62 > 0 then inc(Spl_gLaenge);
        Spl_gLaenge := Spl_gLaenge * 69;
        Spl_tLaenge := Spl_tLaenge * 69;
        Nstr := copy(Zeile,20,8);
        i := pos(Pkt,Nstr);
        if i > 0 then Nstr := copy(Nstr,1,i-1);
        KillEndBlanks(Nstr);
        if Nstr = '' then
        begin
          Nstr := Call;
          Strip(Nstr);
        end;
        if i1 = 1 then Suf := '7PL'
                  else Suf := 'P' + Hex(str_int(ParmStr(2,B1,Zeile)),2);
        Nstr := Nstr + Pkt + Suf;
      end;

      if MldOk = 14 then   (* COR und ERR-File *)
      begin
        Spl_COR_ERR := true;
        Nstr := ParmStr(2,B1,Zeile);
        i := 0;
        While Exists(Konfig.SplVerz + copy(Nstr,1,pos(Pkt,Nstr)-1) + BS + Nstr) do
        begin
          inc(i);
          delete(Nstr,length(Nstr)-1,2);
          Nstr := Nstr + SFillStr(2,'0',Hex(i,2));
        end;
      end;

      if MldOk = 41 then   (* INF-File *)
      begin
        Spl_COR_ERR := true;
        Nstr := ParmStr(2,B1,Zeile);
        i := 0;
        While Exists(Konfig.SplVerz + copy(Nstr,1,pos(Pkt,Nstr)-1) + BS + Nstr) do
        begin
          inc(i);
          delete(Nstr,length(Nstr)-1,2);
          Nstr := Nstr + SFillStr(2,'0',Hex(i,2));
        end;
      end;

      Vstr := copy(Nstr,1,pos(Pkt,Nstr)-1);

      if MkSub(Konfig.SplVerz + Vstr) then
      begin
        if not Exists(Konfig.SplVerz + Vstr + BS  + Nstr) then
        begin
          Vstr := Konfig.SplVerz + Vstr + BS  + Nstr;
          Assign(SplFile,Vstr);
          Result := RewriteBin(SplFile,T);
        end else
        begin
          i := 0;
          Repeat
            inc(i);
            Sstr := Call;
            Strip(Sstr);
            Sstr := int_str(i) + Sstr;
            Flag := not Exists(Konfig.SplVerz + Vstr + BS  + Sstr + BS  + Nstr);
          Until Flag or (i > 250);
          if Flag then
          begin
            if MkSub(Konfig.SplVerz + Vstr + BS  + Sstr) then
            begin
              Vstr := konfig.SplVerz + Vstr + BS  + Sstr + BS  + Nstr;
              Assign(SplFile,Vstr);
              Result := RewriteBin(SplFile,T);
            end else Result := 1;
          end else Result := 1;
        end;

        if Result = 0 then
        begin
          SplSave := true;
          Spl_UmlMerk := Umlaut;
          Umlaut := 0;

          Vstr := copy(Vstr,1,pos(Pkt,Vstr)) + Cnt;
          Assign(f,Vstr);
          if ResetTxt(f) = 0 then
          begin
            Readln(f,Spl_gCount);
            FiResult := CloseTxt(f);
          end else Spl_gCount := 0;
        end else
        begin
          Triller;
          MldOk := 0;
        end;
      end else
      begin
        Triller;
        MldOk := 0;
      end;
    end;
    SetzeFlags(Kanal);
  end;
End;


Procedure Close_7Plus (* Kanal : Byte *);
Begin
  with K[Kanal]^ do
  begin
    if SplSave then
    begin
      SplSave := false;
      Spl_COR_ERR := false;
      FiResult := CloseBin(SplFile);
      Umlaut := Spl_UmlMerk;
    end;
  end;
End;


Procedure Write_SplFile (* Kanal : Byte; Zeile : String *);
Type    FPtr   = Array [1..500] of Char;

Var     i      : Byte;
        Result : Word;
        Count  : Word;
        ch     : Char;
        Feld   : ^FPtr;

Begin
  with K[Kanal]^ do
  begin
    GetMem(Feld,SizeOf(Feld^));
    FillChar(Feld^,SizeOf(Feld^),0);
    Count := 0;
    for i := 1 to length(Zeile) do
    Begin
      ch := Zeile[i];
      case ch of

      { #32..#41,
       #43..#126,
       #128..#144,
       #146,
       #148..#252 :  (ALT! bis 1.71)}
       #32..#126,
       #128..#254:

            begin
              inc(Count);
              Feld^[Count] := ch;
              if not Spl_COR_ERR then
              begin
                inc(Spl_gCount);
                inc(Spl_tCount);
              end;
            end;

       M1 : begin
              inc(Count);
              Feld^[Count] := #13;
              inc(Count);
              Feld^[Count] := #10;
            end;
      end;
    End;
    BlockWrite(SplFile,Feld^,Count,Result);
    FreeMem(Feld,SizeOf(Feld^));

    if not Spl_COR_ERR then
      FileInfo(Kanal,2,Spl_gLaenge,Spl_gCount,Spl_tLaenge,Spl_tCount);
  end;
End;

