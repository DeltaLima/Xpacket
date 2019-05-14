{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P P A S S . P A S                                                    ³
 ³                                                                         ³
 ³ Enth„lt notwendige Routinen zum Einloggen als SYSOP in den              ³
 ³ verschiedenen Systemen.                                                 ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


Procedure Sysop_Einloggen (* Kanal : Byte; Zeile : Str80 *);
Var    i,i1 : Byte;
       Flag : Boolean;
       Hstr : String[80];
       Astr : String[5];
       KC   : Sondertaste;
       VC   : char;
       SysArt_B : Byte;   {//db1ras}

Begin
  with K[Kanal]^ do
  begin
    if SysopParm then
    begin
      SysopParm := false;
      InfoOut(Kanal,0,1,InfoZeile(3));
    end else
    begin
      Flag := false;
      Zeile := RestStr(UpCaseStr(Zeile));
      KillEndBlanks(Zeile);
      Astr := Zeile;
{DigiCom Parm 19}
      For SysArt_B:=1 To maxSCon Do   {//db1ras}
       If ((Astr=SNam[SysArt_B]) Or ((Astr='') And (SysArt=SysArt_B)))
          And (SysArt_B in [1,2,3,5..11,13,14,15,17,18]) Then Begin
        Astr := SNam[SysArt_B];
        Flag := true;
        if SysArt_B<>18 then begin
         if SysArt_B=8 then
          begin
           for i:=7 to 15 do G^.FStr[i]:='';
           for i:=7 to 15 do G^.FStx[i]:=22;
           G^.Fstr[7] := InfoZeile(412);
           G^.Fstr[10] := InfoZeile(413);
           G^.Fstr[12] := InfoZeile(414);
           Fenster(15);
           _ReadKey(KC,VC);
           clrFenster;
          end;
         if (Upcase(VC)='M') and (SysArt_B=8) then
           SysopStr := ParmStr(18,B1,InfoZeile(217))
          else
           begin
            Case SysArt_B of
             1..18:SysopStr := ParmStr(SysArt_B,B1,InfoZeile(217));
             19   :SysopStr := ParmStr(17,B1,InfoZeile(217));
             20   :SysopStr := ParmStr(SysArt_B-1,B1,InfoZeile(217));
            end;
           end;

         if (xpnodec) or (SysArt_B=19) then delete(SysOpStr,1,2);
        end else SysOpStr := 'PRIV';
      end else if SCon[0] then
      begin
        for i := 1 to maxUser do
          if (not Flag and (Astr = UNam[i]))
             Or ((Astr = '') And (System = UNam[i])) Then Begin   {//db1ras}
            Astr := UNam[i];   {//db1ras}
            Flag := true;
            UserArt := i;
            SysopStr := ParmStr(UserArt,B1,InfoZeile(218));
          end;
      end;
      if not Flag then InfoOut(Kanal,1,1,InfoZeile(171));

      if Flag then
      begin
        Flag := false;
        KillEndBlanks(Astr);
        SysopArt := LRK + Astr + RRK;
        Assign(G^.TFile,Sys1Pfad + PwDatei);
        FiResult := ResetTxt(G^.TFile);
        While not Eof(G^.TFile) and not Flag do
        begin
          Readln(G^.TFile,Hstr);
          if Found_Pw_Call(Hstr,Call,Alias,SysopArt) then
          begin
            Flag := true;
            PassRetry := Byte(str_int(GetPwParm(1,Hstr)));
          end;
        end;
        FiResult := CloseTxt(G^.TFile);
        if not Flag then
           InfoOut(Kanal,1,1,InfoZeile(17) + B1 + SysopArt + B1 + Call);
      end;

      if Flag then
      begin
        Randomize;
        PassRight := 1;
        inc(PassRetry);
        if PassRetry > 1 then
        begin
          PassRight := Random(PassRetry+1);
          if PassRight = 0 then PassRight := 1;
        end;

        case SysArt_B of
          1 : begin   (* DBOX *)
                if not DBoxScaned then Scan_PW_Array(Kanal);
                SysopStr := SysopStr + B1 + DieBoxPW;
              end;

         else SysopParm := true;
        end;
        if not User_autopw then
        begin
         InfoOut(Kanal,0,1,SysopStr);
         S_PAC(Kanal,NU,true,SysopStr + M1);
        end else User_autopw:=false;
      end;
    end;
  end;
End;


Procedure Password_Auswert (* Kanal : Byte; Zeile : String *);
Begin

  with K[Kanal]^ do if SysArt in [0,2,3,5..11,13,14,15,17,18] then
  begin
    case SysArt of
      0 : case UserArt of
            1 : TheNet_SYS_Auswert(Kanal,Zeile);  (* TOP  *)
            2 : RMNC_Auswert(Kanal,Zeile);        (* SP   *)
            3 : TheNet_SYS_Auswert(Kanal,Zeile);  (* XP   *)
          end;
      5 : EZBOX_Auswert(Kanal,Zeile);      (* EBOX *)
      7 : RMNC_Auswert(Kanal,Zeile);       (* RMNC *)
      2,                                   (* BBOX *)
      3,                                   (* FBOX - FBB *)
      6,                                   (* BDXL *)
      8,                                   (* TNN  *)
      9,                                   (* NETR *)
     10,                                   (* BN   *)
     11,                                   (* DXC  *)
     13,                                   (* FALC *)
     15,                                   (* BPQ  *)
     14 : TheNet_SYS_Auswert(Kanal,Zeile); (* TNC3 *)
     17,                                   (* XP   *)
     18,                                   (* XN   *)
     19,                                   (* XPN  *)
     20 : TheNet_SYS_Auswert(Kanal,Zeile); (* DIGIC*)
    end;
  end;
  SetzeFlags(Kanal);
End;


Procedure DieBox_PW_Scan (* Kanal : Byte; Zeile : String; *);
var   Flag : Boolean;
Begin
  with K[Kanal]^ do
  begin
    Flag := false;
    if length(Zeile) > 14 then
    Repeat
      if (Zeile[3] = Pkt ) then
         if (Zeile[6] = Pkt ) then
            if (Zeile[9] = B1) then
               if (Zeile[12] = DP) then Flag := true;
      if not Flag then delete(Zeile,1,1);
    Until Flag or (length(Zeile) < 14);
    if Flag then DieBoxPW := copy(Zeile,1,2) +
                             copy(Zeile,10,2) +
                             copy(Zeile,13,2);
  end;
End;


Procedure Scan_PW_Array (* Kanal : Byte *);
var   Pw   : ^PWArrayPtr;
      Hstr : String[80];
      flag : Boolean;
      i    : Byte;
      Std,
      Min,
      Tag  : Byte;

Begin
  GetMem(Pw,SizeOf(Pw^));
  FillChar(Pw^,SizeOf(Pw^),0);
  with K[Kanal]^ do
  begin
    DBoxScaned := false;
    Assign(G^.TFile,Sys1Pfad + PwDatei);
    FiResult := ResetTxt(G^.TFile);
    Repeat
      Readln(G^.TFile,Hstr);
      flag := Found_Pw_Call(Hstr,Call,Alias,LRK + SNam[1] + RRK);
    Until flag or Eof(G^.TFile);
    if flag then
    begin
      for i := 0 to 59 do Readln(G^.TFile,Pw^[i]);
      Tag := str_int(copy(DieBoxPW,1,2));
      Std := str_int(copy(DieBoxPW,3,2));
      Min := str_int(copy(DieBoxPW,5,2));
      i := Min + Tag;
      if i > 59 then i := i - 60;
      DieBoxPW := copy(Pw^[i],Std+1,4);
      DBoxScaned := true;
    end;
    FiResult := CloseTxt(G^.TFile);
  end;
  FreeMem(Pw,SizeOf(Pw^));
End;


Procedure BayBox_US_Scan (* Kanal : Byte; Zeile : String *);
Begin
  with K[Kanal]^ do
  begin
    PassRetry := 1;
    PassRight := 1;
    SysopArt := BBUS;
    TheNet_SYS_Auswert(Kanal,Zeile);
  end;
End;

Function  PseudoPriv (* Laenge : Byte; Pstr : Str20; Dstr : Str80) : Str80 *);
Var   i     : Byte;
      w     : Word;
      Feld  : Array [1..6] of Byte;
      Hstr  : String[80];
      Flag  : Boolean;
Begin
  Randomize;
  w := 0;

  Hstr := CutStr(Dstr);
  delete(Hstr,1,1);
  delete(Hstr,length(Hstr),1);
  Flag := Hstr = SNam[2];

  Dstr := ParmStr(2,B1,Dstr);
  delete(Dstr,1,1);
  delete(Dstr,length(Dstr),1);

  for i := 1 to 6 do Feld[i] := 0;
  for i := 1 to 3 do
  begin
    Hstr := ParmStr(2+i,Km,Dstr);
    if (length(Hstr) = 4) and (Hstr[4] >= Hstr[1]) then
    begin
      Feld[2*i-1] := ord(Hstr[1]);
      Feld[2*i] := ord(Hstr[4]);
      w := w + Feld[2*i-1] + Feld[2*i];
    end;
  end;

  Hstr := '';
  if w = 0 then
  begin
    Feld[1] := 48;
    Feld[2] := 122;
  end;

  Repeat
    i := Random(254);
    if Flag and (i in [35,44,59]) then i := 0;
    if (i > 0) and
       (i in [Feld[1]..Feld[2],Feld[3]..Feld[4],Feld[5]..Feld[6]]) then
      Hstr := Hstr + Chr(i);
  Until length(Hstr) >= Laenge;

  if Pstr > '' then
  begin
    i := Random(Byte(Laenge-length(Pstr)));
    if i = 0 then i := 1;
    delete(Hstr,i,length(Pstr));
    insert(Pstr,Hstr,i);
  end;
  PseudoPriv := Hstr;
End;


Function  GetPwParm (* Nr : Byte; Zeile : Str80) : Str20 *);
Var  i,i1 : Byte;
Begin
  Zeile := ParmStr(2,B1,Zeile);
  i := pos(LRK,Zeile);
  i1 := pos(RRK,Zeile);
  if (i = 1) and (i1 > 2) then
  begin
    delete(Zeile,1,1);
    delete(Zeile,length(Zeile),1);
    GetPwParm := ParmStr(Nr,Km,Zeile);
  end else GetPwParm := '';
End;

Function  Found_Pw_Call (* Zeile : Str80; Cstr : Str9; Alstr:Str9; AStr : Str6) : Boolean *);
Var   i    : Byte;
      Flag : Boolean;
Begin
  KillEndBlanks(AStr);
  Flag := pos(AStr,Zeile) = 1;

  if Flag then
  Repeat
    Zeile := RestStr(Zeile);
    Flag := Cstr = CutStr(Zeile);
    if (not flag) and (length(alstr)>0) then Flag:=AlStr=CutStr(Zeile);
  Until Flag or (length(Zeile) = 0);

  Found_Pw_Call := Flag;
End;


Function  Check_Parm (* Zeile : String) : String *);
Var  i,i1 : Byte;
     Bstr : String;
Begin
  i := pos('> ',Zeile);
  if i > 0 then delete(Zeile,1,i-1);

  Bstr := '';
  i := 0;
  i1 := length(Zeile);
  While i < i1 do
  begin
    inc(i);
    if Zeile[i] in ['0'..'9',B1] then Bstr := Bstr + Zeile[i]
                                  else Bstr := Bstr + B1;
  end;
  KillStartBlanks(Bstr);
  KillEndBlanks(Bstr);
  Check_Parm := Bstr;
End;


Procedure RMNC_Auswert (* Kanal : Byte; Zeile : Str80 *);
var    i,iz    : Integer;
       PrivStr : String[80];
       Bstr    : String[20];
       Found   : Boolean;

Begin
  with K[Kanal]^ do
  begin
    While pos(B1,Zeile) > 0 do Zeile := RestStr(Zeile);
    While pos(M1,Zeile) > 0 do Zeile[pos(M1,Zeile)] := B1;
    While pos(^J,Zeile) > 0 do Zeile[pos(^J,Zeile)] := B1;
    While pos(RSK,Zeile) > 0 do Zeile[pos(RSK,Zeile)] := B1;

    KillStartBlanks(Zeile);
    KillEndBlanks(Zeile);

    if str_int(Zeile) > 0 then
    begin
      if PassRetry <> PassRight then
      begin
        Repeat
          iz := Random(255);
        Until iz in [21..255];
        InfoOut(Kanal,0,1,ParmStr(2,B1,InfoZeile(241)) + B2 + Zeile + PfStr + int_str(iz));
        S_PAC(Kanal,NU,true,int_str(iz) + M1);
      end else
      begin
        PrivStr := Zeile;
        Bstr := '';
        for i := 1 to length(PrivStr) do if PrivStr[i] in ['0'..'9'] then
         Bstr := Bstr + PrivStr[i];
        While length(Bstr) < 5 do Bstr := '0' + Bstr;

        Assign(G^.TFile,Sys1Pfad + PwDatei);
        FiResult := ResetTxt(G^.TFile);
        Found := false;
        Repeat
          Readln(G^.TFile,PrivStr);
          if Found_Pw_Call(PrivStr,Call,Alias,SysopArt) then Found := true;
        Until Found or Eof(G^.TFile);

        if Found then
        begin
          iz := 0;
          Readln(G^.TFile,PrivStr);
          for i := 1 to length(Bstr) do
            iz := iz + (str_int(Bstr[i]) * str_int(PrivStr[i]));
          InfoOut(Kanal,0,1,ParmStr(1,B1,InfoZeile(241)) + B2 + Zeile + PfStr + int_str(iz));
          S_PAC(Kanal,NU,true,int_str(iz) + M1);
        end else
        begin
          SysopParm := false;
          InfoOut(Kanal,1,1,InfoZeile(171));
        end;
        FiResult := CloseTxt(G^.TFile);
      end;

      if PassRetry > 1 then S_PAC(Kanal,NU,true,SysopStr + M1);
      dec(PassRetry);
      if PassRetry < 1 then SysopParm := false;
    end;
  end;
End;


Procedure TheNet_SYS_Auswert (* (Kanal : Byte; Zeile : String) *);
var  i,i1,r,
     AnzParam : Byte;
     PsConst,
     PwConst  : Byte;
     Dstr,
     Rstr,
     Pstr,
     Hstr     : String;
     Found    : Boolean;

Begin
  with K[Kanal]^ do
  begin

  {** FBB-Erg„nzung: Call bis einschlieálich '>  ' absensen **}
    if (SysArt=3) then
      begin
       if Pos('>  ', Zeile)>0 then Delete(Zeile,1,Pos('>  ',Zeile)+2);
       i:=Pos('[',Zeile);
       if i>0 then
        begin
         i1:=Pos(']',Zeile);
         if (i1>i+10) and (i1<i+14) and (i1>i) then delete(zeile, i, i1-i+1);
        end;
      end;
    if (SysArt=8) or ((SysArt=0) and (UserArt=1)) then
      begin
       if Pos('}  ', Zeile)>0 then Delete(Zeile,1,Pos('}  ',Zeile)+2);
      end;
    if Zeile[length(Zeile)]=#13 then PwMerk:='';
    Zeile:=PwMerk+Zeile;
    Zeile := Check_Parm(Zeile);
    Pstr := ParmStr(1,B1,Zeile);
    AnzParam := ParmAnz;
    Pstr := '';

    Assign(G^.TFile,Sys1Pfad + PwDatei);
    FiResult := ResetTxt(G^.TFile);
    Repeat
      Readln(G^.TFile,Hstr);
      Found := Found_Pw_Call(Hstr,Call,Alias,SysopArt);
    Until Found or Eof(G^.TFile);

    if Found then
    begin
      Dstr := Hstr;
      if SysArt = 11 then PwConst := 4
                     else PwConst := 5;
      if AnzParam = PwConst then
      begin
       PWMerk:='';
        PsConst := Byte(str_int(GetPwParm(2,Dstr)));
        if PassRetry <> PassRight then
        begin
          Pstr := PseudoPriv(PsConst,'',Dstr);
          InfoOut(Kanal,0,1,ParmStr(2,B1,InfoZeile(241)) + B2 +
                            Zeile + PfStr + copy(Pstr,1,PwConst));
          S_PAC(Kanal,NU,true,Pstr + M1);
        end else
        begin
          Pstr := '';
          Readln(G^.TFile,Hstr);
          for i := 1 to PwConst do
          begin
            i1 := Byte(str_int(ParmStr(i,B1,Zeile)));
            Pstr := Pstr + copy(Hstr,i1,1);
          end;
          Rstr := Pstr;
          if PsConst > PwConst then Pstr := PseudoPriv(PsConst,Pstr,Dstr);
          InfoOut(Kanal,0,1,
            ParmStr(1,B1,InfoZeile(241)) + B2 + Zeile + PfStr + Rstr);
          S_PAC(Kanal,NU,true,Pstr + M1);
          MailPWWait:=false;
          MailPrompt:='';
        end;

        if PassRetry > 1 then S_PAC(Kanal,NU,true,SysopStr + M1);
        dec(PassRetry);
        if PassRetry < 1 then SysopParm := false;
      end else {AnzParm = PwConst}
       begin
        if Zeile[length(zeile)]<>#13 then PWMerk:=Zeile else PWMerk:='';
       end;
    end else
    begin
      SysopParm := false;
      if First_Frame then InfoOut(Kanal,1,1,InfoZeile(171));
    end;

    FiResult := CloseTxt(G^.TFile);
  end;
End;


Procedure EZBOX_Auswert (* Kanal : Byte; Zeile : Str80 *);
var  b,i,i1 : Byte;
     Pstr   : String[4];
     Rstr   : String[20];
     Hstr   : String[80];
     Found  : Boolean;
Begin
  with K[Kanal]^ do
  begin
    if (copy(Zeile,1,1) = LRK) and (copy(Zeile,length(Zeile),1) = RSK) then
    begin
      delete(Zeile,1,1);
      delete(Zeile,length(Zeile),1);
      KillEndBlanks(Zeile);
      delete(Zeile,length(Zeile),1);
      While pos('.',Zeile) > 0 do Zeile[pos('.',Zeile)] := B1;
      Rstr := Zeile;

      Assign(G^.TFile,Sys1Pfad + PwDatei);
      FiResult := ResetTxt(G^.TFile);
      Repeat
        Readln(G^.TFile,Hstr);
        Found := Found_Pw_Call(Hstr,Call,Alias,SysopArt);
      Until Found or Eof(G^.TFile);

      if Found then
      begin
        Pstr := '';
        Readln(G^.TFile,Hstr);
        b := Ord(Hstr[Byte(str_int(CutStr(Zeile)))]);
        Zeile := RestStr(Zeile);
        for i := 1 to 4 do
        begin
          i1 := Byte(b + Byte(str_int(CutStr(Zeile))));
          i1 := i1 mod 80;
          if i1 = 0 then i1 := 80;
          Pstr := Pstr + Hstr[i1];
          Zeile := RestStr(Zeile);
        end;
        InfoOut(Kanal,0,1,ParmStr(1,B1,InfoZeile(241)) + B2 + Rstr + PfStr + Pstr);
        S_PAC(Kanal,NU,true,Pstr + M1);
      end else InfoOut(Kanal,1,1,InfoZeile(171));
      SysopParm := false;
      FiResult := CloseTxt(G^.TFile);
    end;
  end;
End;
