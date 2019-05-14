{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P M H .  P A S                                                       ³
 ³                                                                         ³
 ³ Routinen fr die MH-Liste                                               ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


Procedure MH_Sort (* Art : Byte *);
Var  x,i,j  : Integer;
     Change : Boolean;
     Hilf   : MH_Typ;
     N      : Word;
     flag   : Boolean;
     Hstr,
     Xstr   : String[14];

Begin
  N := maxMH;

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
            1 : begin
                  Hstr := copy(MHeard^[j+x].Zeit,7,2) + copy(MHeard^[j+x].Zeit,3,4) +
                          copy(MHeard^[j+x].Zeit,1,2) + copy(MHeard^[j+x].Zeit,9,6);
                  Xstr := copy(MHeard^[j].Zeit,7,2) + copy(MHeard^[j].Zeit,3,4) +
                          copy(MHeard^[j].Zeit,1,2) + copy(MHeard^[j].Zeit,9,6);
                  flag := Hstr > Xstr;
                end;
            2 : flag := (MHeard^[j+x].Rej  > MHeard^[j].Rej);
            3 : flag := (MHeard^[j+x].UIs  > MHeard^[j].UIs);
            4 : flag := (MHeard^[j+x].Call > MHeard^[j].Call);
            5 : flag := (MHeard^[j+x].Link > MHeard^[j].Link);
            6 : flag := (MHeard^[j+x].QRG  > MHeard^[j].QRG);
           else flag := false;
          end;

          if flag then
          begin
            move(MHeard^[j+x],Hilf,SizeOf(MH_Typ));
            move(MHeard^[j],MHeard^[j+x],SizeOf(MH_Typ));
            move(Hilf,MHeard^[j],SizeOf(MH_Typ));
            j := j - x;
          end else Change := false;
        end;
        i := i + 1;
      end;
      x := x div 3;
    end;
  end;

End;


Function GetMhStr(Art : Byte; MPos : Word) : Str80;
Var      Hstr : String[80];
Begin
  with MHeard^[MPos] do
  begin
    Hstr := '';
    if Art = 0 then
    begin
      if Call > '' then Hstr := B1 + copy(Zeit,1,5) + '-' + copy(Zeit,10,5) + B1 +
                                     SFillStr(3,B1,int_str(Rej)) + B1 +
                                     SFillStr(3,B1,int_str(UIs)) + B2 +
                                     EFillStr(10,B1,Call) + B1 +
                                     Link;
      Hstr := EFillStr(80,B1,Hstr);
    end;

    if Art = 1 then
    begin
      if Call > '' then Hstr := B1 + copy(Zeit,1,5) + '-'
                                    + copy(Zeit,10,5) + B1 +
                                      EFillStr(10,B1,Call) + B1 +
                                      Link;
    end;

    if Art = 2 then
    begin
      if Call > '' then Hstr := B1 + int_str(TNr) + SFillStr(9,B1,QRG) +
                                B1 + copy(Zeit,1,5) + '-' +
                                     copy(Zeit,10,5) + B1 +
                                     EFillStr(10,B1,Call) + B1 +
                                     Link;
    end;

    if Art = 3 then
    begin
      if Call > '' then Hstr := EFillStr(11,B1,Call);
    end;

    GetMhStr := Hstr;
  end;
End;


Procedure MH_QRG_Init(Freq : Str8);
Var  FreqMerk : String[8];
     i : Byte;
Begin
  FillChar(MHeard^,maxMH * SizeOf(MH_Typ),0);
  move(MH^,MHeard^,maxMH * SizeOf(MH_Typ));
  MH_Sort(6);

  FillChar(FreqList^,SizeOf(FreqList^),0);
  FreqMerk := '';
  FreqPos := 0;
  FreqCount := 0;

  for i := 1 to maxMH do
  begin
    if (FreqMerk <> MHeard^[i].QRG) and
       (MHeard^[i].QRG > '') and
       (FreqCount < maxQRG) then
    begin
      inc(FreqCount);
      FreqList^[FreqCount].QRG := MHeard^[i].QRG;
      FreqMerk := MHeard^[i].QRG;
      if Freq = MHeard^[i].QRG then FreqPos := FreqCount;
    end;
  end;
End;


Procedure MH_Init(Art,TNr : Byte; Freq : Str8);
Var    i    : Byte;
       Flag : Boolean;
Begin
  FillChar(MHeard^,maxMH * SizeOf(MH_Typ),0);
  move(MH^,MHeard^,maxMH * SizeOf(MH_Typ));

  MH_Anz := 0;
  for i := 1 to maxMH do
  begin
    Flag := false;
    if (MHeard^[i].Call > '') then
    begin
      case Art of
        0 : if (TNr = MHeard^[i].TNr) then
              if ((Freq > '') and (Freq = MHeard^[i].QRG)) or
                 (MHeard^[i].QRG = '') then Flag := true;

        1 : Flag := true;

        2 : if (TNr = MHeard^[i].TNr) then flag := true;
      end;

      if Flag then inc(MH_Anz)
              else FillChar(MHeard^[i],SizeOf(MHeard^[i]),0);
    end;
  end;
End;


Procedure MH_Show;
Const  Bofs = 3;

Var    TNr,i,i1,i2,
       Bpos      : Byte;
       Dpos      : Integer;
       w         : Word;
       yM,
       Zmax      : Byte;
       Flag,
       CurMH,
       Fertig    : Boolean;
       Hstr      : String[60];
       Save_Name : String[60];
       KC        : Sondertaste;
       VC        : Char;
       Such      : String[9];
       SArt      : Byte;
       MH_Save   : Text;
       Result    : Word;

  Procedure InitVar;
  Begin
    yM := 1;
    Bpos := 1;
    Dpos := 1;
    MH_Sort(SArt);
  End;

  Procedure MhPage(beg : Word);
  Var   i,i1 : Byte;
  Begin
    Teil_Bild_Loesch(4,maxZ-1,Attrib[2]);
    i1 := Zmax;
    if i1 > MH_Anz then i1 := MH_Anz;
    for i := 1 to i1 do
       WriteRam(1,i+Bofs,Attrib[2],0,EFillStr(80,B1,GetMhStr(0,beg-1+i)));
    WriteRam(30,1,Attrib[15],0,B1+ InfoZeile(328));
  End;

Begin
  NowFenster := false;
  Moni_Off(0);
  GetMem(MHeard,maxMH * SizeOf(MH_Typ));
  GetMem(FreqList,SizeOf(FreqList^));

  if (show = 0) then TNr := Unproto
                else TNr := K[show]^.TncNummer;

  if tnr=0 then tnr:=K[1]^.TNCNummer;

  MH_QRG_Init(TNC[TNr]^.QRG_Akt);
  MH_Init(0,TNr,TNC[TNr]^.QRG_Akt);
  SArt := 1;
  MH_Sort(SArt);
  InitVar;

  Such := '';
  Zmax := maxZ - (1 + Bofs);
  Fertig := false;
  CurMH := true;

  WriteRam(1,1,Attrib[15],0,ConstStr(B1,80));
  WriteRam(1,2,Attrib[2],0,EFillStr(80,B1,B1 + InfoZeile(227)));
  WriteRam(1,3,Attrib[2],0,ConstStr('Ä',80));
  WriteRam(1,maxZ,Attrib[15],0,EFillStr(80,B1,InfoZeile(228)));
  MhPage(Dpos);
  WriteAttr(1,Bpos+Bofs,80,Attrib[4],0);

  Repeat
    if CurMH then InitCursor(1,Bpos+Bofs)
             else InitCursor(1,1);

    WriteRam(60,1,Attrib[15],0,'Nr:' + SFillStr(3,B1,int_str(Dpos)));
    WriteRam(2,1,Attrib[15],0,TncI + int_str(MHeard^[Dpos].TNr) + DP +
                              EFillStr(10,B1,MHeard^[Dpos].QRG));
    WriteRam(71,1,Attrib[15],0,EFillStr(10,B1,Such));

    _ReadKey(KC,VC);

    if KC <> _Andere then Such := '';

    case KC of
      _Esc, _Del
       : Fertig := true;

      _Dn
       : if Dpos < MH_Anz then
         begin
           inc(Dpos);
           if Bpos < Zmax then inc(Bpos) else
           begin
             WriteAttr(1,Bofs+yM,80,Attrib[2],0);
             Scroll(Up,0,1+Bofs,Zmax+Bofs);
             WriteRam(1,Bofs+Bpos,Attrib[4],0,GetMhStr(0,Dpos));
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
             WriteRam(1,Bofs+Bpos,Attrib[4],0,GetMhStr(0,Dpos));
           end;
         end else Alarm;

      _PgDn
       : if Dpos < MH_Anz then
         begin
           if Dpos + Zmax - Bpos >= MH_Anz then
           begin
             Dpos := MH_Anz;
             Bpos := Zmax;
             if Bpos > MH_Anz then Bpos := MH_Anz;
           end else
           begin
             Dpos := Dpos + Zmax - 1;
             if Dpos + Zmax - 1 > MH_Anz then Dpos := MH_Anz - Zmax + Bpos;
             MhPage(Dpos - Bpos + 1);
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
             MhPage(Dpos - Bpos + 1);
           end;
         end else Alarm;

      _CtrlPgUp
       : if Dpos > 1 then
         begin
           Dpos := 1;
           Bpos := 1;
           MhPage(1);
         end else Alarm;

      _CtrlPgDn
       : if Dpos < MH_Anz then
         begin
           Dpos := MH_Anz;
           Bpos := Zmax;
           if Bpos > MH_Anz then Bpos := MH_Anz;
           MhPage(Dpos - Bpos + 1);
         end else Alarm;

      _CtrlHome
       : begin
           Dpos := Dpos - Bpos + 1;
           Bpos := 1;
         end;

      _CtrlEnd
       : if MH_Anz < Zmax then
         begin
           Dpos := MH_Anz;
           Bpos := MH_Anz;
         end else
         begin
           Dpos := Dpos + Zmax - Bpos;
           Bpos := Zmax;
         end;

      _Right
       : if FreqPos > 0 then
         begin
           i := 0;
           i1 := FreqPos;
           Repeat
             If FreqPos < FreqCount then inc(FreqPos)
                                    else FreqPos := 1;
             MH_Init(0,TNr,FreqList^[FreqPos].QRG);
             inc(i);
           Until (MH_Anz > 0) or (i > FreqCount);
           if (i1 = FreqPos) or (MH_Anz = 0) then Alarm;
           InitVar;
           MhPage(Dpos);
         end else Alarm;

      _Left
       : if FreqPos > 0 then
         begin
           i := 0;
           i1 := FreqPos;
           Repeat
             If FreqPos > 1 then dec(FreqPos)
                            else FreqPos := FreqCount;
             MH_Init(0,TNr,FreqList^[FreqPos].QRG);
             inc(i);
           Until (MH_Anz > 0) or (i > FreqCount);
           if (i1 = FreqPos) or (MH_Anz = 0) then Alarm;
           InitVar;
           MhPage(Dpos);
         end else Alarm;

      _CtrlRight
       : if MultiTNC then
         begin
           If TNr < Tnc_Anzahl then inc(TNr)
                               else TNr := 1;
           MH_Init(2,TNr,'');
           InitVar;
           MhPage(Dpos);
         end else Alarm;

      _CtrlLeft
       : if MultiTNC then
         begin
           If TNr > 1 then dec(TNr)
                      else TNr := Tnc_Anzahl;
           MH_Init(2,TNr,'');
           InitVar;
           MhPage(Dpos);
         end else Alarm;

      _ShDel
       : begin
           for i := 1 to MH_Anz do
           begin
             i1 := 0;
             Repeat
               inc(i1);
               if (MH^[i1].Call = MHeard^[i].Call) and
                  (MH^[i1].TNr = MHeard^[i].TNr) and
                  (MH^[i1].QRG = MHeard^[i].QRG) then
               begin
                 move(MH^[i1+1],MH^[i1],(maxMH-i1) * SizeOf(MH_Typ));
                 FillChar(MH^[maxMH],SizeOf(MH_Typ),0);
                 dec(MH_Anz);
               end;
             Until (i1 >= maxMH);
           end;

           Fertig := true;
         end;

      _ShTab
       : CurMH := not CurMH;

      _AltA
       : begin
           MH_Init(1,TNr,'');
           InitVar;
           MhPage(Dpos);
         end;

      _AltH
       : XP_Help(G^.OHelp[1]);

      _AltS
       : begin
           WriteRam(1,Bofs+Bpos,Attrib[4],0,EFillStr(80,B1,B1 + InfoZeile(142)));
           Save_Name := Konfig.SavVerz + 'MH.' + SFillStr(3,'0',int_str(TNr));
           GetString(Save_Name,Attrib[4],60,9,Bofs+Bpos,KC,0,Ins);
           if KC <> _Esc then
           begin
             Assign(MH_Save,Save_Name);
             Result := AppendTxt(MH_Save);
             if Result <> 0 then
             begin
               Result := RewriteTxt(MH_Save);
               if Result = 0 then
               begin
                 Writeln(MH_Save,B1,InfoZeile(227));
                 Writeln(MH_Save,ConstStr('-',70));
               end;
             end;
             if Result = 0 then
             begin
               for w := Dpos to MH_Anz do
               begin
                 Hstr := GetMhStr(0,w);
                 Writeln(MH_Save,Hstr);
               end;
               FiResult := CloseTxt(MH_Save);
             end else
             begin
               WriteRam(1,Bofs+Bpos,Attrib[4],1,
                EFillStr(80,B1,B1 + InfoZeile(75) + ':  ' + Save_Name));
               Alarm;
               Verzoegern(ZWEI);
             end;
           end;
           WriteRam(1,Bofs+Bpos,Attrib[4],0,GetMhStr(0,Dpos));
         end;

      _Alt0, _Alt1.._Alt5
       : begin
           case KC of
             _Alt0 : SArt := 6;
             _Alt1 : SArt := 1;
             _Alt2 : SArt := 2;
             _Alt3 : SArt := 3;
             _Alt4 : SArt := 4;
             _Alt5 : SArt := 5;
           end;
           MH_Sort(SArt);
           MhPage(Dpos - Bpos + 1);
         end;

      _Ret
       : begin
           Chr_Darstell(show,_Dn,#255);
           Hstr := MHeard^[Dpos].Call;
           KillEndBlanks(Hstr);
           Hstr := CvCh + 'C ' + Hstr + B1 + MHeard^[Dpos].Link;
           KillEndBlanks(Hstr);
           VorWrite[show]^[K[show]^.stC] := Hstr;
           Chr_Darstell(show,_Up,#255);
           SK_out := _Esc;
           ch_aus := true;
           fertig := true;
         end;

      _Andere
       : begin
           Such := Such + UpCase(VC);
           w := 0;
           Flag := false;
           While (w < MH_Anz) and not Flag do
           begin
             inc(w);
             if pos(Such,MHeard^[w].Call) = 1 then
             begin
               Flag := true;
               Dpos := w;
               if (Dpos < Bpos) or (MH_Anz <= Zmax) then Bpos := Dpos;
               if ((MH_Anz - Dpos + Bpos) < Zmax) and
                  (MH_Anz > Zmax) and (Dpos > Bpos)
                then Bpos := Zmax - (MH_Anz - Dpos);
             end;
           end;

           if not Flag then
           begin
             Alarm;
             Such := '';
           end else MhPage(Dpos - Bpos + 1);
         end;

      else Alarm;
    end;

    WriteAttr(1,Bofs+yM,80,Attrib[2],0);
    WriteAttr(1,Bofs+Bpos,80,Attrib[4],0);
    yM := Bpos;
  Until Fertig;

  FreeMem(FreqList,SizeOf(FreqList^));
  FreeMem(MHeard,maxMH * SizeOf(MH_Typ));
  Neu_Bild;
  Moni_On;
End;


Procedure RemoteMH (* Kanal,T : Byte; Zeile : Str9 *);
Var    i,i1,
       i2,i3,
       TNr    : Byte;
       ch     : Char;
       tnst   : String[4];
       Hstr   : String[80];
       TExist,
       flag,
       all,
       find,
       long   : Boolean;
       Freq   : String[8];

Begin
  GetMem(MHeard,maxMH * SizeOf(MH_Typ));
  GetMem(FreqList,SizeOf(FreqList^));

  TNr := K[Kanal]^.TncNummer;
  all := false;
  long := false;
  find := false;
  TExist := true;
  if str_int(Zeile[1])>0 then zeile:=' '+Zeile;
  all:=true;
for i:=1 to 8 do
   begin
    TNSt:= ' '+int_Str(i) + ' ';
    if pos(tnSt, Zeile)>0 then
     begin
      TNr:=i;
      all:=false;
      delete(Zeile, Pos(tnst,zeile),2);
     end;
   end;
  if Zeile[1]=' ' then delete(zeile,1,1);
  
  While pos('/',Zeile) > 0 do
  begin
    i := pos('/',Zeile);
    if i > 0 then
    begin
      case Zeile[i+1] of
        'L': long := true;
        {'A': all := true;}
       { '1'..Chr(maxTNC+48)
           : TNr := Byte(ord(Zeile[i+1])-48);}
      end;
      delete(Zeile,i,2);
    end;
  end;

  if TNr in [1..TNC_Anzahl] then
  begin
    Freq := TNC[TNr]^.QRG_Akt;
    MH_QRG_Init(Freq);

    Zeile := CutStr(Zeile);
    KillEndBlanks(Zeile);

    if Zeile > '' then
    begin
      all := false;
      find := true;
    end;

    S_PAC(Kanal,NU,false,M1);

    if not (find or all) then
    begin
      MH_Init(0,TNr,Freq);
      MH_Sort(1);
      if long then Hstr := InfoZeile(183)
              else Hstr := InfoZeile(92);

      Hstr := M1 + B1 + EFillStr(28,B1,Hstr) +
                         ConstStr(B1,10) +
                         TncI + int_str(TNr) + DP + Freq;

      S_PAC(Kanal,NU,false,Hstr);
      S_PAC(Kanal,NU,false,+ M1 + ConstStr('-',70) + M1);

      if MH_Anz > 0 then for i := 1 to MH_Anz do
      begin
        if long then Hstr := GetMhStr(1,i) + M1 else
        begin
          Hstr := GetMhStr(3,i);
          if (i mod 7 = 1) then Hstr := B1 + Hstr;
          if (i mod 7 = 0) or (i = MH_Anz) then
          begin
            KillEndBlanks(Hstr);
            Hstr := Hstr + M1;
          end;
        end;
        S_PAC(Kanal,NU,false,Hstr);
      end else S_PAC(Kanal,NU,false,B1+ InfoZeile(182) + M1);
      S_PAC(Kanal,NU,false,M1);
    end else

    begin
      MH_Init(1,TNr,'');
      MH_Sort(6);

      S_PAC(Kanal,NU,false,EFillStr(12,B1,B1+InfoZeile(93)) +
                          InfoZeile(183) + ConstStr(B1,10) + M1);
      S_PAC(Kanal,NU,false,ConstStr('-',77) + M1);

      i1 := 0;
      for i := 1 to MH_Anz do
      begin
        if (pos(Zeile,MHeard^[i].Call) = 1) or all then
        begin
          S_PAC(Kanal,NU,false,GetMhStr(2,i) + M1);
          inc(i1);
        end;
      end;
      if i1 = 0 then S_PAC(Kanal,NU,false,B1+InfoZeile(182) + M1);

    end;
  end else S_PAC(Kanal,NU,false,Star + InfoZeile(124) + M1);

  FreeMem(FreqList,SizeOf(FreqList^));
  FreeMem(MHeard,maxMH * SizeOf(MH_Typ));
End;
