{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P H E L P . P A S                                                    ³
 ³                                                                         ³
 ³ Routinen fr die Hilfe durch ALT-H aus TOP                              ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


Procedure Hlp_Laden (* Istr : Str6 *);
Var  Nstr   : String[6];
     Hstr   : String[HlpRec];
     Result : Word;
     Flag,
     Find   : Boolean;
Begin
  FillChar(Hlp^,SizeOf(Hlp^),0);
  Hlp_Anz := 0;
  Flag := false;
  KillEndBlanks(Istr);
  Assign(G^.BFile,Konfig.TempVerz + THlpDatei);
  if ResetBin(G^.BFile,HlpRec) = 0 then
  begin
    Hlp_ZlnNr := str_int(Istr);
    if Hlp_ZlnNr > 0 then
    begin
      dec(Hlp_ZlnNr);
      Seek(G^.BFile,Hlp_ZlnNr);
      Repeat
        BlockRead(G^.BFile,Hstr[1],1,Result);
        Hstr[0] := Chr(HlpRec);
        Flag := LZ = copy(Hstr,1,1);
        if not Flag then
        begin
          inc(Hlp_Anz);
          Nstr := copy(Hstr,1,6);
          KillEndBlanks(Nstr);
          if Nstr > '' then
          begin
            Hlp^[Hlp_Anz].ID := Nstr;
            Hlp^[Hlp_Anz].Attr := Attrib[31];
          end else Hlp^[Hlp_Anz].Attr := Attrib[2];
          Hlp^[Hlp_Anz].Sp7 := Hstr[7];
          delete(Hstr,1,7);
          Hlp^[Hlp_Anz].Entry := Hstr;
        end;
      Until Flag or (Hlp_Anz >= maxHelpZln) or Eof(G^.BFile);
    end;
    FiResult := CloseBin(G^.BFile);
  end;
End;


Procedure XP_Help (* IDstr : Str6 *);
Const  Bofs = 1;
       Kl   = '[ ]';

Type   AnwTyp = Record
                  IDk : String[6];
                  Dmp : Integer;
                  Bmp : Byte;
                End;

Var    i,i1,i2,
       xc,yc,
       Klpos,
       Bpos,
       yM,aM,
       Zmax      : Byte;
       show2     : byte;
       Dpos      : Integer;
       w         : Word;
       Flag,
       CurSh,
       CurFlag,
       Fertig    : Boolean;
       Vstr      : String[6];
       Hstr      : String[80];
       Save_Name : String[60];
       Such      : String[80];
       KC        : Sondertaste;
       VC        : Char;
       Result    : Word;
       OldBild   : ^BildPtr;
       HlpAnw    : Array [1..maxHlpAnw] of AnwTyp;
       HlpAnwPtr : Byte;

  Procedure StepHlpAnw (AnId : Str6; Dpar : Integer; Bpar : Byte);
  Var  i    : Byte;
       Flag : Boolean;
  Begin
    Flag := false;
    i := 0;
    While not Flag and (i < maxHlpAnw) do
    begin
      inc(i);
      if HlpAnw[i].IDk = AnId then
      begin
        Flag := true;
        move(HlpAnw[1],HlpAnw[i],SizeOf(HlpAnw[1]));
      end;
    end;

    if not Flag then move(HlpAnw[1],HlpAnw[2],SizeOf(HlpAnw[1])*(maxHlpAnw-1));
    HlpAnw[1].IDk := AnId;
    HlpAnw[1].Dmp := Dpar;
    HlpAnw[1].Bmp := Bpar;
  End;

  Procedure HlpPage(beg : Word);
  Var   i,i1 : Byte;
  Begin
    Teil_Bild_Loesch(2,maxZ-1,Attrib[2]);
    i1 := Zmax;
    if i1 > Hlp_Anz then i1 := Hlp_Anz;
    for i := 1 to i1 do
       WriteRam(1,i+Bofs,Hlp^[beg-1+i].Attr,1,
         EFillStr(80,B1,B1+Hlp^[beg-1+i].Entry));
    yM := 0;
  End;

Begin
  if HeapFrei(SizeOf(Hlp^) + SizeOf(OldBild^)) then
  begin
{    OnlHelp:=true;
    Show2:=show;
    show:=0; }
    NowFenster := false;
    Moni_Off(0);
    GetMem(Hlp,SizeOf(Hlp^));
    GetMem(OldBild,SizeOf(OldBild^));

    move(Bild^,OldBild^,SizeOf(OldBild^));

    CurFlag := Cursor_On;
    xc := WhereX;
    yc := WhereY;
    Cursor_Aus;


    Bpos := 1;
    Dpos := 1;

    HlpAnwPtr := 0;
    FillChar(HlpAnw,SizeOf(HlpAnw),0);
    Hlp_Laden(IDstr);

    Such := '';
    Zmax := maxZ - (1 + Bofs);
    Fertig := false;
    CurSh := true;

    Hstr := B1 + InfoZeile(56);
    Klpos := pos(Kl,Hstr);
    WriteRam(1,1,Attrib[15],1,ZFillStr(80,B1,InfoZeile(55)));
    WriteRam(1,maxZ,Attrib[15],1,EFillStr(80,B1,Hstr));
    HlpPage(Dpos);
    yM := 1;
    aM := Hlp^[Dpos].Attr;
    WriteAttr(1,Bpos+Bofs,80,Attrib[4],1);

    Repeat
      if CurSh then InitCursor(1,Bpos+Bofs)
               else InitCursor(1,1);

      WriteRam(71,1,Attrib[15],1,EFillStr(10,B1,Such));
      if (Klpos > 0) then
      begin
        if (Hlp^[Dpos].ID > '') then
        begin
          WriteRam(Klpos+1,maxZ,Attrib[15],1,X_ch);
          WriteRam(Klpos+5,maxZ,Attrib[15],1,EFillStr(10,B1,LRK + Hlp^[Dpos].ID + RRK));
        end else
        begin
          WriteRam(Klpos+1,maxZ,Attrib[15],1,B1);
          WriteRam(Klpos+5,maxZ,Attrib[15],1,EFillStr(10,B1,B1));
        end;
        WriteRam(74,maxZ,Attrib[15],1, SFillStr(7,B1,LRK + int_str(Hlp_ZlnNr + Dpos) + RRK));
      end;

      _ReadKey(KC,VC);

      if KC <> _Andere then Such := '';

      case KC of
        _Esc, _Del
         : Fertig := true;

        _Dn
         : if Dpos < Hlp_Anz then
           begin
             inc(Dpos);
             if Bpos < Zmax then inc(Bpos) else
             begin
               WriteAttr(1,Bofs+yM,80,aM,1);
               Scroll(Up,1,1+Bofs,Zmax+Bofs);
               WriteRam(1,Bofs+Bpos,Attrib[4],1,EFillStr(80,B1,B1+Hlp^[Dpos].Entry));
             end;
           end else Alarm;

        _Up
         : if Dpos > 1 then
           begin
             dec(Dpos);
             if Bpos > 1 then dec(Bpos) else
             begin
               WriteAttr(1,Bofs+yM,80,aM,1);
               Scroll(Dn,1,1+Bofs,Zmax+Bofs);
               WriteRam(1,Bofs+Bpos,Attrib[4],1,EFillStr(80,B1,B1+Hlp^[Dpos].Entry));
             end;
           end else Alarm;

        _Left
         : if (HlpAnwPtr < maxHlpAnw) and (HlpAnw[HlpAnwPtr+1].IDk > '') then
           begin
             inc(HlpAnwPtr);
             IDstr := HlpAnw[HlpAnwPtr].IDk;
             Hlp_Laden(IDstr);
             Dpos := HlpAnw[HlpAnwPtr].Dmp;
             Bpos := HlpAnw[HlpAnwPtr].Bmp;
             Such := '';
             HlpPage(Dpos - Bpos + 1);
           end else Alarm;

        _PgDn
         : if Dpos < Hlp_Anz then
           begin
             if Dpos + Zmax - Bpos >= Hlp_Anz then
             begin
               Dpos := Hlp_Anz;
               Bpos := Zmax;
               if Bpos > Hlp_Anz then Bpos := Hlp_Anz;
             end else
             begin
               Dpos := Dpos + Zmax - 1;
               if Dpos + Zmax - 1 > Hlp_Anz then Dpos := Hlp_Anz - Zmax + Bpos;
               HlpPage(Dpos - Bpos + 1);
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
               HlpPage(Dpos - Bpos + 1);
             end;
           end else Alarm;

        _CtrlPgUp
         : if Dpos > 1 then
           begin
             Dpos := 1;
             Bpos := 1;
             HlpPage(1);
           end else Alarm;

        _CtrlPgDn
         : if Dpos < Hlp_Anz then
           begin
             Dpos := Hlp_Anz;
             Bpos := Zmax;
             if Bpos > Hlp_Anz then Bpos := Hlp_Anz;
             HlpPage(Dpos - Bpos + 1);
           end else Alarm;

        _CtrlHome
         : begin
             Dpos := Dpos - Bpos + 1;
             Bpos := 1;
           end;

        _CtrlEnd
         : if Hlp_Anz < Zmax then
           begin
             Dpos := Hlp_Anz;
             Bpos := Hlp_Anz;
           end else
           begin
             Dpos := Dpos + Zmax - Bpos;
             Bpos := Zmax;
           end;

        _ShTab
         : CurSh := not CurSh;

        _F1.._F5, _F10, _AltH
         : begin
             case KC of
               _F1   : Vstr := G^.OHelp[12];
               _F2   : Vstr := G^.OHelp[13];
               _F3   : Vstr := G^.OHelp[14];
               _F4   : Vstr := G^.OHelp[15];
               _F5   : Vstr := G^.OHelp[16];
               _F10  : Vstr := G^.OHelp[11];
               _AltH : Vstr := G^.OHelp[28];
               else  Vstr := '';
             end;

             if Vstr > '' then
             begin
               StepHlpAnw(IDstr,Dpos,Bpos);
               Hlp_Laden(Vstr);
               IDstr := Vstr;
               HlpAnwPtr := 0;
               yM := 1;
               Bpos := 1;
               Dpos := 1;
               Such := '';
               HlpPage(1);
             end else Alarm;
           end;

        _AltS
         : begin
             WriteRam(1,Bofs+Bpos,Attrib[4],1,EFillStr(80,B1,B1 + 'Pfad =' + B1));
             Save_Name := Konfig.SavVerz + 'HELP.' + TxtExt;
             GetString(Save_Name,Attrib[4],60,9,Bofs+Bpos,KC,0,Ins);
             if KC <> _Esc then
             begin
               Assign(G^.TFile,Save_Name);
               Result := AppendTxt(G^.TFile);
               if Result <> 0 then Result := RewriteTxt(G^.TFile);
               if Result = 0 then
               begin
                 for w := Dpos to Hlp_Anz do
                 begin
                   Hstr := Hlp^[w].Entry;
                   Writeln(G^.TFile,Hstr);
                 end;
                 FiResult := CloseTxt(G^.TFile);
               end else
               begin
                 WriteRam(1,Bofs+Bpos,Attrib[4],1,
                  EFillStr(80,B1,B1 + InfoZeile(75) + DP + B2 + Save_Name));
                 Alarm;
                 Verzoegern(ZWEI);
               end;
             end;
             WriteRam(1,Bofs+Bpos,Attrib[4],1,EFillStr(80,B1,B1+Hlp^[Dpos].Entry));
           end;

        _Ret
         : begin
             Vstr := Hlp^[Dpos].ID;
             if Vstr > '' then
             begin
               StepHlpAnw(IDstr,Dpos,Bpos);
               Hlp_Laden(Vstr);
               IDstr := Vstr;
               HlpAnwPtr := 0;
               yM := 1;
               Bpos := 1;
               Dpos := 1;
               Such := '';
               HlpPage(1);
             end else Alarm;
           end;

        _Andere
         : begin
             Such := Such + UpCase(VC);
             w := 0;
             Flag := false;
             While (w < Hlp_Anz) and not Flag do
             begin
               inc(w);
               if pos(Such,Hlp^[w].Entry) = 1 then
               begin
                 Flag := true;
                 Dpos := w;
                 if (Dpos < Bpos) or (Hlp_Anz <= Zmax) then Bpos := Dpos;
                 if ((Hlp_Anz - Dpos + Bpos) < Zmax) and
                    (Hlp_Anz > Zmax) and (Dpos > Bpos)
                  then Bpos := Zmax - (Hlp_Anz - Dpos);
               end;
             end;

             if not Flag then
             begin
               Alarm;
               Such := '';
             end else HlpPage(Dpos - Bpos + 1);
           end;

        else Alarm;
      end;

      if yM > 0 then WriteAttr(1,Bofs+yM,80,aM,1);
      WriteAttr(1,Bofs+Bpos,80,Attrib[4],1);
      yM := Bpos;
      aM := Hlp^[Dpos].Attr;
    Until Fertig;

    move(OldBild^,Bild^,SizeOf(OldBild^));
    FreeMem(OldBild,SizeOf(OldBild^));
    FreeMem(Hlp,SizeOf(Hlp^));

    Cursor_Aus;
    if CurFlag then
    begin
      GotoXY(xc,yc);
      Cursor_Ein;
    end;
    Moni_On;
  {  show:=show2;
    OnlHelp:=false;
    SwitchChannel (show);
    SetzeFlags(show); }
  end else Alarm;
  OnlHelp:=false;
End;


Procedure REM_Help (* Kanal : Byte; HNr : Byte *);
Var  i     : Byte;
     w     : Word;
     IDstr : String[10];
     Hstr  : String[80];
Begin
  with K[Kanal]^ do
  begin
    i := Byte(HlpRemBeg-1+HNr);
    if i in [1..maxOHelp] then
    begin
      IDstr := G^.OHelp[i];
      if HeapFrei(SizeOf(Hlp^)) then
      begin
        GetMem(Hlp,SizeOf(Hlp^));
        Hlp_Laden(IDstr);
        for w := 1 to Hlp_Anz do
        begin
         if Hlp^[w].Sp7 = DP then
          begin
           Hstr:=Hlp^[w].Entry;
           if (Node) and (Pos('//', HStr)>0) then delete(HStr,pos('//', Hstr), 2);
           S_PAC(Kanal,NU,false,B1 + Hstr + M1);
          end;
        end;
        FreeMem(Hlp,SizeOf(Hlp^));
      end;
    end;
  end;
End;


Procedure Send_Hilfe (* Kanal : Byte; IDstr : Str6 *);
Var   w    : Word;
      Hstr : String[80];
Begin
  with K[Kanal]^ do
  begin
    if HeapFrei(SizeOf(Hlp^)) then
    begin
      GetMem(Hlp,SizeOf(Hlp^));
      Hlp_Laden(IDstr);
      for w := 1 to Hlp_Anz do if Hlp^[w].Sp7 = DP then
      begin
        Hstr := Line_convert(Kanal,1,Hlp^[w].Entry);
        KillEndBlanks(Hstr);
        S_PAC(Kanal,NU,false,B1 + Hstr + M1);
      end;
      FreeMem(Hlp,SizeOf(Hlp^));
    end;
  end;
End;


Procedure Help_Compile;
Var  l,Hlpl : LongInt;
     w,
     Result : Word;
     X7     : Byte;
     Nstr   : String[6];
     Bstr,
     Hstr   : String[HlpRec];
     Flag,
     EFlag  : Boolean;
     HlpNr  : ^HlpNrPtr;
     BalkSt : str8;
     BalkZa : Byte;
     z1,z2  : char;
     BalkK  : Boolean;


  Procedure HlpAnzeige(l : LongInt);
  Begin
    BalkSt:='';
    if not Balkk then
     begin
      inc(BalkZa);
      z1:='²';
      z2:='°';
     end
      else begin
            dec(BalkZa);
            z2:='²';
            z1:='°';
           end;
    if BalkZa=6 then Balkk:=true;
    if BalkZa=1 then Balkk:=false;
    BalkSt:=SFillStr(BalkZa,z1,BalkSt);
    WriteTxt(X7,SZ2,StartColor,EFillStr(6,z2,BalkSt));
{    WriteTxt(X7,SZ2,StartColor,EFillStr(6,B1,int_str(l))); }
  End;


  Function NrExists(Kstr : Str6) : Word;
  Var  z    : Word;
       Flag : Boolean;
  Begin
    z := 0;
    Flag := false;
    if Kstr > '' then
    Repeat
      inc(z);
      if CutStr(HlpNr^[z]) = Kstr then Flag := true;
    Until Flag or (z >= maxHlpNr);

    if Flag then NrExists := z
            else NrExists := 0;
  End;

Begin
BalkZa:=0;
BalkK:=false;
  Hstr := HelpDatei + B1 + GL + RSK + B1 + THlpDatei + B1;
  WriteTxt(30,SZ2,StartColor,Hstr);
  X7 := 30 + length(Hstr);
  Assign(G^.TFile,SysPfad + HelpDatei);
  if ResetTxt(G^.TFile) = 0 then
  begin
    GetMem(HlpNr,SizeOf(HlpNr^));
    FillChar(HlpNr^,SizeOf(HlpNr^),0);
    Assign(G^.BFile,Konfig.TempVerz + THlpDatei);
    if RewriteBin(G^.BFile,HlpRec) = 0 then
    begin
      l := 0;
      w := 0;
      While not Eof(G^.TFile) do
      begin
        inc(l);
        if ((l mod 50)=0) then HlpAnzeige(l);
        Readln(G^.TFile,Hstr);
        if pos(DP,Hstr) = 1 then
        begin
          inc(w);
          delete(Hstr,1,1);
          if w <= maxHlpNr then
            HlpNr^[w] := EFillStr(7,B1,CutStr(Hstr)) +
            SFillStr(6,'0',int_str(l));
          Hstr := ConstStr(B1,HlpRec);
          BlockWrite(G^.BFile,Hstr[1],1,Result);
        end else
        begin
          Hstr := EFillStr(HlpRec,B1,Hstr);
          BlockWrite(G^.BFile,Hstr[1],1,Result);
        end;
      end;
      Hlpl := FilePos(G^.BFile);
      if Hlpl = 0 then Hlpl := 1;
      FiResult := CloseBin(G^.BFile);
    end;
    FiResult := CloseTxt(G^.TFile);

    if ResetBin(G^.BFile,HlpRec) = 0 then
    begin
      Flag := false;
      EFlag := false;
      Repeat
        dec(l);
        if ((l mod 50)=0) then HlpAnzeige(l);
        BlockRead(G^.BFile,Hstr[1],1,Result);
        Hstr[0] := Chr(HlpRec);
        KillEndBlanks(Hstr);
        if Hstr = LZ then EFlag := true;
        KillStartBlanks(Hstr);
        if (Hstr > '') and not EFlag then
        begin
          if Flag then
          begin
            Bstr := ConstStr(B1,7);
            While Hstr > '' do
            begin
              Nstr := CutStr(Hstr);
              w := NrExists(Nstr);
              if w > 0 then Bstr := Bstr + RestStr(HlpNr^[w]) + B3
                       else Bstr := Bstr + ConstStr('0',7) + B3;
              Hstr := RestStr(Hstr);
            end;
            Bstr := EFillStr(HlpRec,B1,Bstr);
            Seek(G^.BFile,FilePos(G^.BFile)-1);
            BlockWrite(G^.BFile,Bstr[1],1,Result);
          end else if (OHelpStr = Hstr) then Flag := true;
        end;
      Until Eof(G^.BFile) or EFlag;

{      Writeln(G^.Bootfile);}

      While not Eof(G^.BFile) do
      begin
        dec(l);
        if ((l mod 50)=0) then HlpAnzeige(l);
        BlockRead(G^.BFile,Hstr[1],1,Result);
        Hstr[0] := Chr(HlpRec);
        Nstr := copy(Hstr,1,6);
        KillEndBlanks(Nstr);
        w := NrExists(Nstr);
        if w > 0 then
        begin
          Seek(G^.BFile,FilePos(G^.BFile)-1);
          delete(Hstr,1,6);
          Hstr := RestStr(HlpNr^[w]) + Hstr;
          BlockWrite(G^.BFile,Hstr[1],1,Result);
        end else
        begin
          if (Nstr > '') and (Nstr <> LZ) then
          begin
            Alarm;
            WriteTxt(7,SZ2+1,StartColor,Hstr);
            KillEndBlanks(Hstr);
            {Writeln(G^.Bootfile,Hstr);}
          end;
        end;
      end;
      FiResult := CloseBin(G^.BFile);
    end;
    FreeMem(HlpNr,SizeOf(HlpNr^));
  end;
writetxt(30,sz2,startcolor,'                                           ');
End;
