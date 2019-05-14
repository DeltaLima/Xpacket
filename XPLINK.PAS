{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P L I N K . P A S                                                    ³
 ³                                                                         ³
 ³ Routinen fr den automatischen Connectaufbau                            ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


Procedure Lnk_Sort (* Art : Byte *);
Var  x,i,j  : Integer;
     Change : Boolean;
     Hilf   : Lnk_Type;
     N      : Word;
     Flag   : Boolean;
     Hstr,
     Xstr   : String[14];

Begin
  N := Lnk_Anz;

  if N > 1 then
  begin
    x := 1;
    While x <= N do x := x * 3 + 1;
    x := x div 3;
    While x > 0 do
    begin
      i := x;
      While i <= N do
      begin
        j := i - x;
        Change := true;
        While (j > 0) and Change do
        begin
          case Art of
            1 : Flag := Lnk^[j].Ext;
            2 : Flag := CutStr(Lnk^[j].Entry) > CutStr(Lnk^[j+x].Entry);
            3 : Flag := RestStr(Lnk^[j].Entry) > RestStr(Lnk^[j+x].Entry);
            4 : Flag := length(RestStr(Lnk^[j].Entry)) >
                        length(RestStr(Lnk^[j+x].Entry));
            else Flag := false;
          end;

          if Flag then
          begin
            move(Lnk^[j+x],Hilf,SizeOf(Lnk_Type));
            move(Lnk^[j],Lnk^[j+x],SizeOf(Lnk_Type));
            move(Hilf,Lnk^[j],SizeOf(Lnk_Type));
            j := j - x;
          end else Change := false;
        end;
        i := i + 1;
      end;
      x := x div 3;
    end;
  end;
End;


Procedure Lnk_Init (* TNr : Byte; Freq : Str8 *);
Var    Hstr : String[80];
       VC   : Char;
       Flag,
       Extr : Boolean;
Begin
  Lnk_Anz := 0;
  FillChar(Lnk^,SizeOf(Lnk^),0);
  FiResult := ResetTxt(G^.LinkFile);

  Flag := false;
  While not Eof(G^.LinkFile) and not Flag do
  begin
    Readln(G^.LinkFile,Hstr);
    KillEndBlanks(Hstr);
    Flag := (TncI + int_str(TNr) + DP + Freq) = Hstr;
  end;

  if Flag then
  begin
    Flag := false;
    Repeat
      Readln(G^.LinkFile,Hstr);
      if Hstr[0] > #0 then VC := Hstr[1]
                      else VC := #0;

      if VC in [B1,'ù'] then
      begin
        Extr := copy(Hstr,1,1) = 'ù';
        delete(Hstr,1,1);
        if Hstr > '' then
        begin
          inc(Lnk_Anz);
          if Lnk_Anz >= (maxLnk-1) then Flag := true;
          Lnk^[Lnk_Anz].Entry := Hstr;
          Lnk^[Lnk_Anz].Ext := Extr;
        end;
      end else Flag := true;
    Until Eof(G^.LinkFile) or Flag;
  end;
  FiResult := CloseTxt(G^.LinkFile);
End;


Procedure ALT_C_Connect (* Kanal : Byte *);
Const  Bofs = 1;
Var    TNr,
       i,i1,i2,
       Bpos      : Byte;
       Dpos      : Integer;
       w         : Word;
       yM,
       Zmax,
       SSort     : Byte;
       KeyTime   : LongInt;
       OK,
       Flag,
       CurCON,
       AFlag,
       Fertig    : Boolean;
       Hstr      : String[80];
       Nstr,
       Astr,
       SuStr     : String[9];
       Qstr      : String[8];
       KC        : Sondertaste;
       VC        : Char;

  Procedure LnkPage(beg : Word);
  Var   i  : Byte;
        VC : Char;
  Begin
    Teil_Bild_Loesch(Bofs+1,maxZ-1,Attrib[2]);
    for i := 1 to Zmax do
    begin
      if Lnk^[beg-1+i].Ext then VC := 'ù'
                           else VC := B1;
      WriteRam(1,i+Bofs,Attrib[2],0,EFillStr(80,B1,VC + Lnk^[beg-1+i].Entry));
    end;
  End;

  Function GetLinkStr(Nr : Integer) : Str80;
  Var   VC : Char;
  Begin
    if Lnk^[Nr].Ext then VC := 'ù'
                    else VC := B1;
    GetLinkStr := EFillStr(80,B1,VC + Lnk^[Dpos].Entry);
  End;

  Function GetStr_Con(Kanal : Byte; Zeile : Str80) : Str80;
  Var   i : Byte;
  Begin
    with K[Kanal]^ do
    begin
      i := pos(RSK + Call + B1,Zeile + B1);
      if i > 0 then
      begin
        delete(Zeile,1,i-1);
        Zeile := RestStr(Zeile);
        While (pos(RSK,CutStr(Zeile)) = 0) and (length(Zeile) > 0) do
         Zeile := RestStr(Zeile);
      end;
      GetStr_Con := Zeile;
    end;
  End;

  Procedure WriteKopfzeilen;
  Begin
    WriteRam(1,1,Attrib[15],0,
     EFillStr(80,B1,B1+ TncI + int_str(TNr) + DP +
                     EFillStr(20,B1,Qstr) + InfoZeile(140)));
    WriteRam(1,maxZ,Attrib[15],0,EFillStr(80,B1,B1+InfoZeile(2)));
  End;

Begin
  with K[Kanal]^ do
  begin
    NowFenster := false;
    GetMem(Lnk,SizeOf(Lnk^));
    TNr := K[Kanal]^.TncNummer;
    Qstr := TNC[TNr]^.QRG_Akt;
    Lnk_Init(TNr,Qstr);
    GetMem(FreqList,SizeOf(FreqList^));

    yM := 1;
    Bpos := 1;
    Dpos := 1;
    SSort := 0;

    SuStr := '';
    Zmax := maxZ - (1 + Bofs);
    AFlag := false;
    Fertig := false;
    CurCON := true;

    WriteKopfzeilen;

    LnkPage(Dpos);
    WriteAttr(1,Bpos+Bofs,80,Attrib[4],0);
    KeyTime := TimerTick + 1;

    Repeat
      if CurCON then InitCursor(1,Bpos+Bofs)
                else InitCursor(1,1);

      if AFlag then VC := S_ch
               else VC := B1;

      WriteRam(69,1,Attrib[15],0,VC + B1 + EFillStr(10,B1,SuStr));

      Repeat
        if TimerTick > KeyTime then
        begin
          Hstr := GetConPfad(CutStr(Lnk^[Dpos].Entry));
          if connected then Hstr := GetStr_Con(Kanal,Hstr);
          WriteRam(12,Bofs+Bpos,Attrib[4],0,EFillStr(69,B1,Hstr));
        end;
      Until _KeyPressed;


      WriteRam(1,Bofs+Bpos,Attrib[4],0,GetLinkStr(Dpos));

      _ReadKey(KC,VC);

      KeyTime := TimerTick + 1;


      if KC <> _Andere then SuStr := '';

      case KC of
        _Esc
         : Fertig := true;

        _Del
         : begin
             Fertig := true;
             Auto_CON := false;
             ACZeile := '';
           end;

        _Dn
         : if Dpos < Lnk_Anz then
           begin
             inc(Dpos);
             if Bpos < Zmax then inc(Bpos) else
             begin
               WriteAttr(1,Bofs+yM,80,Attrib[2],0);
               Scroll(Up,0,1+Bofs,Zmax+Bofs);
               WriteRam(1,Bofs+Bpos,Attrib[4],0,GetLinkStr(Dpos));
             end;
           end else Alarm;

        _Up
         : if Dpos > 1 then
           begin
             dec(Dpos);
             if Bpos > 1 then dec(Bpos) else
             begin
               WriteAttr(1,Bofs+yM,80,Attrib[2],0);
               Scroll(Dn,0,1+Bofs,Zmax+Bofs);
               WriteRam(1,Bofs+Bpos,Attrib[4],0,GetLinkStr(Dpos));
             end;
           end else Alarm;

        _PgDn
         : if Dpos < Lnk_Anz then
           begin
             if Dpos + Zmax - Bpos >= Lnk_Anz then
             begin
               Dpos := Lnk_Anz;
               Bpos := Zmax;
               if Bpos > Lnk_Anz then Bpos := Lnk_Anz;
             end else
             begin
               Dpos := Dpos + Zmax - 1;
               if Dpos + Zmax - 1 > Lnk_Anz then Dpos := Lnk_Anz - Zmax + Bpos;
               LnkPage(Dpos - Bpos + 1);
             end;
           end else Alarm;

        _PgUp
         : if Dpos > 1 then
           begin
             if Dpos <= Bpos then
             begin
               Dpos := 1;
               Bpos := 1;
             end else
             begin
               Dpos := Dpos - Zmax + 1;
               if Dpos - Zmax + 1 < 1 then Dpos := Bpos;
               LnkPage(Dpos - Bpos + 1);
             end;
           end else Alarm;

        _CtrlPgUp
         : if Dpos > 1 then
           begin
             Dpos := 1;
             Bpos := 1;
             LnkPage(1);
           end else Alarm;

        _CtrlPgDn
         : if Dpos < Lnk_Anz then
           begin
             Dpos := Lnk_Anz;
             Bpos := Zmax;
             if Bpos > Lnk_Anz then Bpos := Lnk_Anz;
             LnkPage(Dpos - Bpos + 1);
           end else Alarm;

        _CtrlHome
         : begin
             Dpos := Dpos - Bpos + 1;
             Bpos := 1;
           end;

        _CtrlEnd
         : if Lnk_Anz < Zmax then
           begin
             Dpos := Lnk_Anz;
             Bpos := Lnk_Anz;
           end else
           begin
             Dpos := Dpos + Zmax - Bpos;
             Bpos := Zmax;
           end;

        _Right, _Left
         : begin
             FreqCount := 0;
             FillChar(FreqList^,SizeOf(FreqList^),0);
             FiResult := ResetTxt(G^.LinkFile);
             Repeat
               Readln(G^.LinkFile,Hstr);
               if (copy(Hstr,1,3) = TncI) and (copy(Hstr,5,1) = DP) then
               begin
                 inc(FreqCount);
                 FreqList^[FreqCount].TNr := str_int(copy(Hstr,4,1));
                 delete(Hstr,1,5);
                 Hstr := CutStr(Hstr);
                 FreqList^[FreqCount].QRG := Hstr;
               end;
             Until Eof(G^.LinkFile);
             FiResult := CloseTxt(G^.LinkFile);

             if FreqCount > 1 then
             begin
               FreqPos := 0;
               for i := 1 to FreqCount do
               begin
                 if (TNr = FreqList^[i].TNr) and (Qstr = FreqList^[i].QRG)
                  then FreqPos := i;
               end;
               if FreqPos = 0 then FreqPos := 1;
               if KC = _Right then
               begin
                 inc(FreqPos);
                 if FreqPos > FreqCount then FreqPos := 1;
               end else if KC = _Left then
               begin
                 dec(FreqPos);
                 if FreqPos < 1 then FreqPos := FreqCount;
               end;

               TNr := FreqList^[FreqPos].TNr;
               Qstr := FreqList^[FreqPos].QRG;
               Lnk_Init(TNr,Qstr);
               Lnk_Sort(SSort);
               yM := 1;
               Bpos := 1;
               Dpos := 1;
               WriteKopfzeilen;
               LnkPage(Dpos);
             end;
           end;

        _ShTab
         : CurCON := not CurCON;

        _Ret
         : if (Lnk_Anz > 0) and
            not (Test or SplSave or Auto_CON or Mo.MonActive or
                 FileSend {or Ignore} or   {//db1ras}
                 ((SysArt in [1..4]) And connected)) then {//db1ras}
           begin
             ACZeile := GetConPfad(CutStr(Lnk^[Dpos].Entry));
             if connected then ACZeile := GetStr_Con(Kanal,ACZeile);
             if length(ACZeile) > 0 then
             begin
               Auto_CON := true;
               Hstr := GetConStr(ACZeile);
               if not connected then Connect(Kanal,Hstr)
                                else S_PAC(Kanal,NU,true,Hstr + M1);
               Fertig := true;
             end else Alarm;
           end else Alarm;

        _AltA
         : if (Lnk_Anz > 0) then
           begin
             AFlag := true;
             Lnk^[Dpos].Ext := not Lnk^[Dpos].Ext;
             WriteRam(1,Bofs+Bpos,Attrib[4],0,GetLinkStr(Dpos));
           end else Alarm;

        _AltE
         : begin
             Cursor_ein;
             ExecDOS(Konfig.EditVerz + B1 + Sys1Pfad + LinkDatei);
             Cursor_aus;
             Lnk_Init(TNr,Qstr);
             Lnk_Sort(SSort);
             yM := 1;
             Bpos := 1;
             Dpos := 1;
             WriteKopfzeilen;
             LnkPage(Dpos);
           end;

        _AltH
         : XP_Help(G^.OHelp[27]);

        _AltL
         : if (Lnk_Anz > 0) then
           begin
             Hstr := GetConPfad(CutStr(Lnk^[Dpos].Entry));
             Hstr := copy(Hstr,1,68);
             GetString(Hstr,Attrib[4],68,12,Bofs+Bpos,KC,0,Ins);
             KillEndBlanks(Hstr);
             if KC = _Ret then
             begin
               AFlag := true;
               Lnk^[Dpos].Entry := EFillStr(10,B1,CutStr(Lnk^[Dpos].Entry)) + Hstr;
               LinkMod(Hstr);
               Lnk^[Dpos].Entry := EFillStr(10,B1,CutStr(Lnk^[Dpos].Entry)) + Hstr;
             end;
             WriteRam(1,Bofs+Bpos,Attrib[4],0,GetLinkStr(Dpos));
           end else Alarm;

        _AltN
         : if (Lnk_Anz > 0) then
           begin
             Nstr := CutStr(Lnk^[Dpos].Entry);
             Astr := Nstr;

             GetString(Nstr,Attrib[4],9,2,Bofs+Bpos,KC,0,Ins);
             While pos(B1,Nstr) > 0 do Nstr[pos(B1,Nstr)] := '-';
             KillEndBlanks(Nstr);
             if (KC = _Ret) and (Nstr > '') then
             begin
               AFlag := true;
               Lnk^[Dpos].Entry := EFillStr(10,B1,Nstr) +
                                   RestStr(Lnk^[Dpos].Entry);
               if (Astr > '') then for i := 1 to Lnk_Anz do
               begin
                 Repeat
                   i1 := pos(LSym+Astr,Lnk^[i].Entry);
                   if i1 > 0 then
                   begin
                     Repeat
                       delete(Lnk^[i].Entry,i1,1);
                     Until (i1 > length(Lnk^[i].Entry)) or
                           (Lnk^[i].Entry[i1] = B1);
                     Insert(LSym+Nstr,Lnk^[i].Entry,i1);
                   end;
                 Until i1 = 0;
               end;
             end;
             LnkPage(Dpos - Bpos + 1);
           end else Alarm;

        _AltS
         : if (Lnk_Anz > 0) then
           begin
             SaveLinks(Kanal,TNr,Qstr);
             AFlag := false;
           end else Alarm;

        _Alt1.._Alt4
         : if (Lnk_Anz > 0) then
           begin
             case KC of
              _Alt1 : SSort := 1;
              _Alt2 : SSort := 2;
              _Alt3 : SSort := 3;
              _Alt4 : SSort := 4;
             end;
             Lnk_Sort(SSort);
             LnkPage(Dpos - Bpos + 1);
           end else Alarm;

        _Andere
         : if (Lnk_Anz > 0) then
           begin
             SuStr := SuStr + UpCase(VC);
             w := 0;
             Flag := false;
             While (w < Lnk_Anz) and not Flag do
             begin
               inc(w);
               if pos(SuStr,Lnk^[w].Entry) = 1 then
               begin
                 Flag := true;
                 Dpos := w;
                 if (Dpos < Bpos) or (Lnk_Anz <= Zmax) then Bpos := Dpos;
                 if ((Lnk_Anz - Dpos + Bpos) < Zmax) and
                    (Lnk_Anz > Zmax) and
                    (Dpos > Bpos) then Bpos := Zmax - (Lnk_Anz - Dpos);
               end;
             end;

             if not Flag then
             begin
               Alarm;
               SuStr := '';
             end else LnkPage(Dpos - Bpos + 1);
           end else Alarm;

        else Alarm;
      end;

      WriteAttr(1,Bofs+yM,80,Attrib[2],0);
      WriteAttr(1,Bofs+Bpos,80,Attrib[4],0);
      yM := Bpos;
    Until Fertig;

    FreeMem(FreqList,SizeOf(FreqList^));
    FreeMem(Lnk,SizeOf(Lnk^));
    Neu_Bild;
  end;
End;


Function GetConPfad (* Rufz : Str9) : String *);
Const maxLoop = 30;

Var   Hstr  : String;
      Cstr  : String[9];
      i,i1,
      Loop  : Byte;
      FLoop : Boolean;

  Function GetLink(Call : Str9) : String;
  Var  i    : Byte;
       Flag : Boolean;
       hlpst:str12;
  Begin
    i := 0;
    Call:=UpcaseStr(Call);
    Repeat
      inc(i);
      hlpst:=upcasestr(CutStr(Lnk^[i].Entry));
      Flag := Call = hlpst;
    Until (i = Lnk_Anz) or Flag;
    if Flag then GetLink := RestStr(Lnk^[i].Entry)
            else GetLink := '';
  End;

Begin
  Hstr := GetLink(Rufz);
  if Hstr > '' then
  begin
    Loop := 0;
    FLoop := false;
    While not Floop and (pos(LSym,Hstr) > 0) do
    begin
      i := pos(LSym,Hstr);
      delete(Hstr,i,2);
      Cstr := '';
      Repeat
        Cstr := Cstr + Hstr[i];
        delete(Hstr,i,1);
      Until (i > length(Hstr)) or (Hstr[i] = B1);
      Insert(GetLink(Cstr),Hstr,i);

      inc(Loop);
      if Loop > maxLoop then FLoop := true;
    end;
    if FLoop then Hstr := '';
    GetConPfad := Hstr;
  end else GetConPfad := '';
End;


Function  GetConStr (* var Zeile : String) : Str80 *);
Var    Hstr : String[80];
Begin
  Hstr := '';
  Repeat
    Hstr := Hstr + CutStr(Zeile) + B1;
    While pos(RSK,Hstr) > 0 do Hstr[pos(RSK,Hstr)] := B1;
    Zeile := RestStr(Zeile);
  Until (pos(RSK,CutStr(Zeile)) > 0) or (Zeile = '');
  KillEndBlanks(Hstr);
  GetConStr := Hstr;
End;


Function  LinkExists (* Name : Str9; var Gate : Byte) : Boolean *);
var   Flag,
      Find : Boolean;
      Hstr : String[9];
      Freq : String[8];
      i,
      CrNr : Byte;
Begin
  Flag := false;
  Find := false;
  KillEndBlanks(Name);
  Freq := '';

  FiResult := ResetTxt(G^.LinkFile);
  Repeat
    Readln(G^.LinkFile,DZeile);
    i := pos(DP,DZeile);
    if i = 5 then
    begin
      CrNr := str_int(copy(DZeile,4,1));
      delete(DZeile,1,i);
      Freq := CutStr(DZeile);
      i := 0;
      Repeat
        inc(i);
        Flag := (Freq = TNC[i]^.QRG_Akt) and (i = CrNr);
      Until Flag or (i >= TNC_Anzahl);
    end else if Flag and (copy(DZeile,1,1) = 'ù') then
    begin
      delete(DZeile,1,1);
      Hstr := UpcaseStr(CutStr(DZeile));
      Find := (Hstr = Name) and (Freq > '');
    end;
  Until Eof(G^.LinkFile) or Find;

  if Find then
  begin
    i := 0;
    Repeat
      inc(i);
      Flag := (Freq = TNC[i]^.QRG_Akt) and (i = CrNr);
    Until Flag or (i >= TNC_Anzahl);
    Gate := i;
  end;

  LinkExists := Find;
  FiResult := CloseTxt(G^.LinkFile);
End;


Procedure RemoteLnk (* Kanal,T : Byte; Zeile : Str9 *);
Var   Bstr,
      Hstr  : String[80];
      Freq  : String[8];
      LZ,
      Flag  : Boolean;
      i,TNr : Byte;
Begin
  Flag := false;
  LZ := length(Zeile) > 0;
  GetMem(Lnk,SizeOf(Lnk^));

  S_PAC(Kanal,NU,false,M1 + B1 + InfoZeile(128) + M1 + ConstStr('-',75) + M1);

  for TNr := 1 to TNC_Anzahl do
  begin
    Freq := TNC[TNr]^.QRG_Akt;
    Lnk_Init(TNr,Freq);
    Lnk_Sort(1);

    for i := 1 to Lnk_Anz do
    begin
      if Lnk^[i].Ext and (not LZ or
         (LZ and (pos(Zeile,CutStr(Lnk^[i].Entry)) = 1))) then
      begin
        Hstr := CutStr(Lnk^[i].Entry);
        Bstr := GetConPfad(Hstr);
        Hstr := EFillStr(10,B1,Hstr);
        Hstr := B1 + Hstr + TncI + int_str(TNr) +
                DP + EFillStr(10,B1,Freq) + Bstr + M1;
        S_PAC(Kanal,NU,false,Hstr);
        Flag := true;
      end;
    end;
  end;

  FreeMem(Lnk,SizeOf(Lnk^));

  if Flag then
  begin
    if K[Kanal]^.TxLRet then Hstr := M1
                        else Hstr := M2;
    Hstr := Hstr + InfoZeile(6) + M1;
    S_PAC(Kanal,NU,false,Hstr);
  end else S_PAC(Kanal,NU,false,M1 + InfoZeile(253) + M2);
End;


Procedure LinkMod (* var Zeile : Str80 *);
Var  i,i1 : Byte;
Begin
  i := 0;
  if Lnk_Anz > 0 then
  Repeat
    inc(i);
    i1 := pos(RestStr(Lnk^[i].Entry)+B1,Zeile+B1);
    if (i1 > 0) and (RestStr(Lnk^[i].Entry) <> Zeile) then
    begin
      delete(Zeile,i1,length(RestStr(Lnk^[i].Entry)));
      Insert(LSym+CutStr(Lnk^[i].Entry),Zeile,i1);
      i := 0;
    end;
  Until i >= Lnk_Anz;
End;


Procedure SaveLinks (* Kanal,TNr : Byte; Freq : Str8 *);
Var  i     : Byte;
     f     : Text;
     a,b   : Integer;
     Old   : String[12];
     Hstr  : String[13];
     Lstr  : String[80];
     VC    : Char;
     First,
     Flag  : Boolean;

Begin
  Hstr := TncI + int_str(TNr) + DP + Freq;

  Old := ParmStr(1,Pkt ,LinkDatei) + 'OLD';
  a := 1;
  b := 0;
  File_Umbenennen(Sys1Pfad + LinkDatei,Sys1Pfad + Old,a,b);
  if a = 136 then
  begin
    Assign(f,Sys1Pfad + Old);
    FiResult := ResetTxt(f);
    FiResult := RewriteTxt(G^.LinkFile);

    First := false;
    Repeat
      Readln(f,Lstr);
      KillEndBlanks(Lstr);
      Flag := Lstr = Hstr;
      if Lstr > '' then First := true;
      if not Flag and First then Writeln(G^.LinkFile,Lstr);
    Until Eof(f) or Flag;

    if not Flag then for i := 1 to 2 do Writeln(G^.LinkFile);
    Writeln(G^.LinkFile,Hstr);

    for i := 1 to Lnk_Anz do
    begin
      if Lnk^[i].Ext then VC := 'ù'
                     else VC := B1;
      Writeln(G^.LinkFile,VC,EFillStr(10,B1,CutStr(Lnk^[i].Entry)),
                             RestStr(Lnk^[i].Entry));
    end;

    for i := 1 to 2 do Writeln(G^.LinkFile);

    if Flag then
    Repeat
      Readln(f,Lstr);
      KillEndBlanks(Lstr);
      if Lstr[0] > #0 then VC := Lstr[1]
                      else VC := #0;
      Flag := not(VC in [#0,B1,'ù']);
    Until Eof(f) or Flag;

    if Flag then Writeln(G^.LinkFile,Lstr);

    While not Eof(f) do
    begin
      Readln(f,Lstr);
      KillEndBlanks(Lstr);
      Writeln(G^.LinkFile,Lstr);
    end;

    FiResult := CloseTxt(f);
    FiResult := EraseTxt(f);
    FiResult := CloseTxt(G^.LinkFile);
  end;
End;


Procedure LinkLearn (* Kanal : Byte; Zeile : Str80 *);
Var    i,
       TNr  : Byte;
       Hstr : String[80];
       Flag : Boolean;
       KC   : Sondertaste;
       VC   : Char;


Begin
  with K[Kanal]^ do
  begin
    KillEndBlanks(Zeile);
    if Zeile > '' then
    begin
      GetMem(Lnk,SizeOf(Lnk^));
      TNr := K[Kanal]^.TncNummer;
      Lnk_Init(TNr,TNC[TNr]^.QRG_Akt);

      LinkMod(Zeile);
      Hstr := Zeile;
      While pos(B1,Hstr) > 0 do delete(Hstr,1,pos(B1,Hstr));
      delete(Hstr,1,pos(RSK,Hstr));
      Repeat
        Flag := false;

        G^.Fstr[7] := InfoZeile(236);
        G^.Fstr[9] := '"' + B1 + Zeile + B1 + '"';
        G^.Fstr[11] := B1 + InfoZeile(237);
        for i:=7 to 15 do
         G^.Fstx[i]:=2;
        Fenster(15);
        GetString(Hstr,Attrib[3],9,length(G^.Fstr[11])+3,11,KC,0,Ins);

        if KC = _Ret then
        begin
          While pos(B1,Hstr) > 0 do Hstr[pos(B1,Hstr)] := '-';
          i := 0;
          Repeat
            inc(i);
            Flag := CutStr(Lnk^[i].Entry) = Hstr;
          Until Flag or (i >= Lnk_Anz);

          if Flag then
          begin
            G^.Fstr[13] := '"' + Hstr + '" ' + InfoZeile(238);
            G^.Fstr[15] := '"' + copy(RestStr(Lnk^[i].Entry),1,78) + '" ';
            SetzeCursor(pos('[',G^.Fstr[13])+1,13);
            Fenster(15);
            Alarm;
            _ReadKey(KC,VC);
            VC := UpCase(VC);
            if (VC in YesMenge) or (KC = _Ret) then
            begin
              Lnk^[i].Entry := EFillStr(10,B1,Hstr) + Zeile;
            end else
            begin
              Flag := false;
              G^.Fstr[14] := '';
              Hstr := '';
              KC := _Nix;
            end;
            Cursor_Aus;
          end else
          begin
            inc(Lnk_Anz);
            Lnk^[Lnk_Anz].Entry := EFillStr(10,B1,Hstr) + Zeile;
            Flag := true;
          end;
        end;
      Until Flag or (KC = _Esc);

      if Flag then SaveLinks(Kanal,TNr,TNC[TNr]^.QRG_Akt);

      FreeMem(Lnk,SizeOf(Lnk^));
      ClrFenster;
      Neu_Bild;
    end else InfoOut(Kanal,0,1,InfoZeile(239));
  end;
End;
