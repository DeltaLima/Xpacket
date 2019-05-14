{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P D I R .  P A S                                                     ³
 ³                                                                         ³
 ³ Directory-Anzeige                                                       ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


Function  GetBsFNr (Zeile : Str80) : Str20;
Var   f      : File;
      Hstr   : Array [0..3] of Byte;
      Magic,
      Result : Word;
Begin
  FillChar(Hstr,SizeOf(Hstr),0);
  Assign(f,Zeile);
  if ResetBin(f,1) = 0 then
  begin
    BlockRead(f,Hstr,SizeOf(Hstr),Result);
    FiResult := CloseBin(f);
    move(Hstr[0],Magic,SizeOf(Magic));
    if Magic = $6569 then
    begin
      Zeile := SFillStr(3,'0',int_str(Hstr[3])) + '/' +
               SFillStr(3,'0',int_str(Hstr[2]));
    end else Zeile := '';
  end else Zeile := '';
  GetBsFNr := Zeile;
End;


Function  FAttr (Attr : Byte) : Str4;
Var   Astr : String[4];
Begin
  Astr := ConstStr(Pkt,4);
  if Attr and ReadOnly = ReadOnly then Astr[1] := 'r';
  if Attr and Archive  = Archive  then Astr[2] := 'a';
  if Attr and SysFile  = SysFile  then Astr[3] := 's';
  if Attr and Hidden   = Hidden   then Astr[4] := 'h';
  FAttr := Astr;
End;


Function  FDate (FT : LongInt) : Str8;
Var    DT   : DateTime;
Begin
  UnpackTime(FT,DT);
  FDate := SFillStr(2,'0',int_str(DT.Day)) + Pkt +
           SFillStr(2,'0',int_str(DT.Month)) + Pkt +
           SFillStr(2,'0',copy(int_str(DT.Year),3,2));
End;


Function  FTime (FT : LongInt) : Str5;
Var    DT   : DateTime;
Begin
  UnpackTime(FT,DT);
  FTime := SFillStr(2,'0',int_str(DT.Hour)) + DP +
           SFillStr(2,'0',int_str(DT.Min));
End;


Procedure SortDir;
Var   x,i,j  : Integer;
      N      : Word;
      Change : Boolean;
      Hilf   : Dir_Typ;
Begin
  N := DirFiles;
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
          if Dir^[j].Name > Dir^[j+x].Name then
          begin
            Hilf := Dir^[j+x];
            Dir^[j+x] := Dir^[j];
            Dir^[j] := Hilf;
            j := j - x;
          end else Change := false;
        end;
        i := i + 1;
      end;
      x := x div 3;
    end;
  end;

  for i := 1 to DirFiles do if Dir^[i].Name[1] = ^A then
  begin
    delete(Dir^[i].Name,1,1);
    if Dir^[i].Name[1] = B1 then Dir^[i].Name[1] := Pkt;
  end;
End;


Procedure GetDirFiles (* Zeile : Str80; ax, Art : Byte *);
Var   srec  : SearchRec;
Begin
  FillChar(Dir^,SizeOf(Dir^),0);

  DirFiles := 0;
  DirSize := 0;

  FindFirst(Zeile,AnyFile,srec);
  While DosError = 0 do with srec do
  begin
    if Attr and Directory = Directory then
    begin
      if (Name <> Pkt) and (ax and Directory = Directory) then
      begin
        if Name = '..' then Name := ' .';
        inc(DirFiles);
        Dir^[DirFiles].Name := EFillStr(13,B1,^A + Name);

        if Name = ' .' then Dir^[DirFiles].Size := UpDir
                       else Dir^[DirFiles].Size := SubDir;

        Dir^[DirFiles].Attr := FAttr(Attr);
        Dir^[DirFiles].Date := FDate(Time);
        Dir^[DirFiles].Time := FTime(Time);
      end;
    end else
    if (ax > Directory) or (Attr and ax = ax) then
    begin
      inc(DirFiles);
      Dir^[DirFiles].Name := EFillStr(9,Pkt,ParmStr(1,Pkt,Name)) +
                             EFillStr(3,B1,ParmStr(2,Pkt,Name));
      Dir^[DirFiles].Size := SFillStr(8,B1,int_str(Size));
      DirSize := DirSize + Size;

      Dir^[DirFiles].Attr := FAttr(Attr);
      Dir^[DirFiles].Date := FDate(Time);
      Dir^[DirFiles].Time := FTime(Time);
    end;

    Findnext(srec);
  end; (* While do *)

  if Art = 1 then SortDir;
End;


Procedure GetDirec (Zeile : Str80);
Var   srec  : SearchRec;
Begin
  FindFirst(Zeile,Directory,srec);
  While DosError = 0 do with srec do
  begin
    if (Name <> Pkt) and (Attr and Directory = Directory) then
    begin
      if Name = '..' then Name := ' .';

      inc(DirFiles);
      Dir^[DirFiles].Name := EFillStr(13,B1,^A + Name);

      if Name = ' .' then Dir^[DirFiles].Size := UpDir
                     else Dir^[DirFiles].Size := SubDir;

      Dir^[DirFiles].Attr := FAttr(Attr);
      Dir^[DirFiles].Date := FDate(Time);
      Dir^[DirFiles].Time := FTime(Time);
    end;
    Findnext(srec);
  end; (* While do *)
  SortDir;
End;


Function GetDirStr(Nr : Word; Sp : Byte) : Str80;
Var      Hstr : String[80];
         Lstr : String[2];
Begin
  if Sp = 1 then Lstr := B2
            else Lstr := B1;
  Hstr := Dir^[Nr].Name + B1 +  Dir^[Nr].Size;
  if Sp = 1 then Hstr := Hstr + B2 + Dir^[Nr].Attr;
  if Sp < 3 then Hstr := Hstr + B2 + Dir^[Nr].Date + Lstr + Dir^[Nr].Time;
  GetDirStr := Hstr;
End;


Function MarkDirStr(Nr : Word; Sp : Byte) : Str80;
Var   ch : Char;
Begin
  if Dir^[Nr].Mark then ch := ''
                   else ch := B1;
  MarkDirStr := B1 + ch + GetDirStr(Nr,Sp);
End;


Procedure DirZeig (* Var Zeile : Str80; var Ch : char; QRet : Boolean *);
Const  Bofs = 1;
Var    X,yM,
       Bpos,
       Zmax   : Byte;
       Dpos   : Integer;
       w,w1,
       AnzM,
       Result : Word;
       Flag,
       Fertig : Boolean;
       KC     : Sondertaste;
       VC,
       VA     : Char;
       f      : Text;
       Mstr,
       Such,
       Mask,
       DrvFree,
       MName  : String[12];
       Hstr,
       Sstr,
       Pfad,
       XPfad  : String[80];


  Procedure CheckPfad;
  Begin
    Pfad := Zeile;
    if Pfad[length(Pfad)] = DP then Pfad := Pfad + BS;
    if Pfad[length(Pfad)] = BS then Pfad := Pfad + Joker;

    if length(pfad)>0 then
    begin
     While Pfad[length(Pfad)] <> BS do
     begin
       Mask := Pfad[length(Pfad)] + Mask;
       delete(Pfad,length(Pfad),1);
     end;
    end else Pfad:=Sys1Pfad;
    if mask='' then mask:='*.*';
  End;

  Procedure DirPage(beg : Word);
  Var      i : Byte;
  Begin
    for i := 1 to Zmax do WriteRam(1,i+Bofs,Attrib[2],1,EFillStr(80,B1,MarkDirStr(beg-1+i,1)));
    WriteRam(1,maxZ-1,Attrib[5],1,EFillStr(80,B1,B1 +
         int_str(DirFiles) + B1 + InfoZeile(141) + B1 +
         FormByte(int_str(DirSize)) + B1 + Bytes + B1 + B2 +
         InfoZeile(324) + B1 + DrvFree + B1 + Bytes));
    WriteRam(1,maxZ,Attrib[5],1,EFillStr(80,B1,B1+InfoZeile(1)));
  End;

  Procedure GetCursorLine;
  Begin
    WriteRam(1,Bpos+Bofs,Attrib[4],1,EFillStr(80,B1,MarkDirStr(Dpos,1)));
  End;

  Function GetFName (Nstr : Str12) : Str12;
  Var   Hstr : String[12];
  Begin
    if Nstr[1] <> Pkt then
    begin
      Hstr := copy(Nstr,1,8);
      While pos(Pkt,Hstr) > 0 do delete(Hstr,pos(Pkt,Hstr),1);
      Hstr := Hstr + copy(Nstr,9,4);
    end else Hstr := Nstr;
    KillEndBlanks(Hstr);
    GetFName := Hstr;
  End;

  Procedure InitStart(Art : Byte; Bstr : Str12);
  Var    w    : Word;
         Flag : Boolean;
         Vpos : Byte;
  Begin
    Vpos := Bpos;
    yM := 1;
    Bpos := 1;
    Dpos := 1;
    AnzM := 0;
    GetDirFiles(Pfad + Mask,AnyFile - Directory,0);
    GetDirec(Pfad + Joker);
    DrvFree := FreeStr(Pfad[1]);
    if Art = 1 then DirPage(Dpos);

    if Art = 2 then
    begin
      w := 0;
      Flag := false;
      While (w < DirFiles) and not Flag do
      begin
        inc(w);
        if Bstr = GetFName(Dir^[w].Name) then
        begin
          Flag := true;
          Dpos := w;
          Bpos := Vpos;
          if (Dpos < Bpos) or (DirFiles <= Zmax) then Bpos := Dpos;
          if ((DirFiles - Dpos + Bpos) < Zmax) and
             (DirFiles > Zmax) and
             (Dpos > Bpos) then Bpos := Zmax - (DirFiles - Dpos);
        end;
      end;
      DirPage(Dpos - Bpos + 1);
    end;
  End;

  Procedure CursorDn;
  Begin
    if Dpos < DirFiles then
    begin
      inc(Dpos);
      if Bpos < Zmax then inc(Bpos) else
      begin
        WriteAttr(1,yM+Bofs,80,Attrib[2],1);
        Scroll(Up,1,1+Bofs,Zmax+Bofs);
        WriteRam(1,Bpos+Bofs,Attrib[4],1,MarkDirStr(Dpos,1));
      end;
    end else Alarm;
  End;


Begin
  Moni_Off(0);
  DirScroll := true;
  NowFenster := false;
  Close_SaveFiles;
  GetMem(Dir,SizeOf(Dir^));

  Such := '';
  Mask := '';
  CheckPfad;

  Zmax := maxZ - 3;
  Fertig := false;
  X := 1;

  InitStart(1,'');

  WriteAttr(1,Bpos+Bofs,80,Attrib[4],1);

  Repeat
    InitCursor(X,Bpos+Bofs);

    WriteRam(1,1,Attrib[5],1,
     EFillStr(67,B1,B1+ '[' + Mask + ']' + B1 + Pfad) + EFillStr(13,B1,Such));

    WriteRam(61,maxZ-1,Attrib[5],1,EFillStr(20,B1,InfoZeile(155) + B1 + int_str(AnzM)));

    _ReadKey(KC,VC);

    if KC <> _Andere then Such := '';

    case KC of
      _Esc
       : begin
           Fertig := true;
           ch := #27;
         end;

      _Dn
       : CursorDn;

      _Up
       : if Dpos > 1 then
         begin
           dec(Dpos);
           if Bpos > 1 then dec(Bpos) else
           begin
             WriteAttr(1,yM+Bofs,80,Attrib[2],1);
             Scroll(Dn,1,1+Bofs,Zmax+Bofs);
             WriteRam(1,Bpos+Bofs,Attrib[4],1,MarkDirStr(Dpos,1));
           end;
         end else Alarm;

      _PgDn
       : if Dpos < DirFiles then
         begin
           if Dpos + Zmax - Bpos >= DirFiles then
           begin
             Dpos := DirFiles;
             Bpos := Zmax;
             if Bpos > DirFiles then Bpos := DirFiles;
           end else
           begin
             Dpos := Dpos + Zmax - 1;
             if Dpos + Zmax - 1 > DirFiles then Dpos := DirFiles - Zmax + Bpos;
             DirPage(Dpos - Bpos + 1);
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
             DirPage(Dpos - Bpos + 1);
           end;
         end else Alarm;

      _Home
       : if Dpos > 1 then
         begin
           Dpos := 1;
           Bpos := 1;
           DirPage(1);
         end else Alarm;

      _End
       : if Dpos < DirFiles then
         begin
           Dpos := DirFiles;
           Bpos := Zmax;
           if Bpos > DirFiles then Bpos := DirFiles;
           DirPage(Dpos - Bpos + 1);
         end else Alarm;

      _CtrlHome
       : begin
           Pfad := copy(Pfad,1,3);
           InitStart(1,'');
         end;

      _Right
       : if HardCur then
         begin
           if X < 80 then inc(X) else Alarm;
         end else Alarm;

      _Left
       : if HardCur then
         begin
           if X > 1 then dec(X) else Alarm;
         end else Alarm;

      _CtrlPgUp,
      _Ret
       : begin
           if KC = _CtrlPgUp then
           begin
             Bpos := 1;
             Dpos := 1;
           end;

           if (Dir^[Dpos].Size = SubDir) and (KC = _Ret) then
           begin
             Pfad := Pfad + Dir^[Dpos].Name;
             KillEndBlanks(Pfad);
             Pfad := Pfad + BS;
             InitStart(1,'');
           end else
           if Dir^[Dpos].Size = UpDir then
           begin
             delete(Pfad,length(Pfad),1);
             MName := '';
             if length(pfad)>0 then
             While Pfad[length(Pfad)] <> BS do
             begin
               MName := Pfad[length(Pfad)] + MName;
               delete(Pfad,length(Pfad),1);
             end;
             Bpos := Zmax;
             InitStart(2,MName);
           end else if (KC = _Ret) and QRet then
           begin
             Zeile := Pfad + GetFName(Dir^[Dpos].Name);
             Fertig := true;
           end else Alarm;
         end;

      _AltA
       : begin
           if AnzM > 0 then
           begin
             for w := 1 to DirFiles do
              if Dir^[w].Mark then Dir^[w].Mark := false;
             AnzM := 0;
           end else
           begin
             for w := 1 to DirFiles do
             begin
               if (pos(SubDir,Dir^[w].Size) = 0) and
                  (pos(UpDir,Dir^[w].Size) = 0) then
               begin
                 Dir^[w].Mark := true;
                 inc(AnzM);
               end;
             end;
           end;
           DirPage(Dpos - Bpos + 1);
         end;

      _AltB
       : if show > 0 then
         begin
           Open_SaveFiles;
           Alarm;
           WriteRam(1,Bpos+Bofs,Attrib[5],1,EFillStr(80,B1,B2+InfoZeile(159)));
           _ReadKey(KC,VC);
           if (KC = _Ret) or (UpCase(VC) in YesMenge) then
           begin
             if K[show]^.FileSend then FertigSenden(show);
             if (AnzM > 0) then
             begin
               for w := 1 to DirFiles do if Dir^[w].Mark then
               begin
                 Hstr := Pfad + GetFName(Dir^[w].Name);
                 WriteRam(1,Bpos+Bofs,Attrib[5],1,EFillStr(80,B1,B2 + Hstr));
                 BIN_TX_File_Sofort(show,Hstr);
                 Dir^[w].Mark := false;
               end;
               WriteRam(1,Bpos+Bofs,Attrib[5],1,
                EFillStr(80,B1,B2+int_str(AnzM)+B1+InfoZeile(122)));
               Verzoegern(EINT);
               AnzM := 0;
             end else if (pos(SubDir,Dir^[Dpos].Size) = 0) and
                         (pos(UpDir,Dir^[Dpos].Size) = 0) then
             begin
               Hstr := Pfad + GetFName(Dir^[Dpos].Name);
               WriteRam(1,Bpos+Bofs,Attrib[5],1,EFillStr(80,B1,B2+Hstr));
               BIN_TX_File_Sofort(show,Hstr);
               Verzoegern(EINT);
             end else Alarm;
             DirPage(Dpos - Bpos + 1);
           end else GetCursorLine;
           Close_SaveFiles;
         end else Alarm;

      _AltC
       : if (pos(UpDir,Dir^[Dpos].Size) = 0) or (AnzM > 0) then
         begin
           Mstr := GetFName(Dir^[Dpos].Name);
           Hstr := '';
           WriteRam(1,Bpos+Bofs,Attrib[5],1,EFillStr(80,B1,B2+InfoZeile(231)));
           GetString(Hstr,Attrib[5],60,length(InfoZeile(231))+4,Bpos+Bofs,KC,1,Ins);
           if KC <> _Esc then
           begin
             if AnzM > 0 then
             begin
               XPfad := Hstr;
               Result := 0;
               for w := 1 to DirFiles do if Dir^[w].Mark then
               begin
                 Hstr := GetFName(Dir^[w].Name) + B1 + XPfad + B1 + Pfad;
                 FileKopieren(Hstr);
                 if str_int(CutStr(Hstr)) = 1 then
                 begin
                   Dir^[w].Mark := false;
                   dec(AnzM);
                   inc(Result);
                 end;
               end;
               if AnzM > 0 then Alarm;
               WriteRam(1,Bpos+Bofs,Attrib[5],1,
                  EFillStr(80,B1,B2+int_str(Result) + B1 + InfoZeile(315)));
               Verzoegern(T500);
               DirPage(Dpos - Bpos + 1);
             end else
             begin
               if pos(SubDir,Dir^[Dpos].Size) > 0
                then Hstr := Joker + B1 + Hstr + B1 + Pfad + GetFName(Dir^[Dpos].Name) + BS
                else Hstr := GetFName(Dir^[Dpos].Name) + B1 + Hstr + B1 + Pfad;
               FileKopieren(Hstr);
               WriteRam(1,Bpos+Bofs,Attrib[5],1,EFillStr(80,B1,B2+Hstr));
               Verzoegern(EINT);
             end;
             InitStart(2,Mstr);
           end else GetCursorLine;
         end else Alarm;

      _AltD, _del
       : if AnzM > 0 then
         begin
           Alarm;
           WriteRam(1,Bpos+Bofs,Attrib[5],1,EFillStr(80,B1,B2+InfoZeile(319)));
           _ReadKey(KC,VC);
           if (KC = _Ret) or (UpCase(VC) in YesMenge) then
           begin
             for w := 1 to DirFiles do if Dir^[w].Mark then
             begin
               Assign(f,Pfad + GetFName(Dir^[w].Name));
               SetFAttr(f,$20);
               Result := EraseTxt(f);
             end;
             InitStart(1,'');
           end else GetCursorLine;
         end else
         begin
           Result := 255;
           if pos(SubDir,Dir^[Dpos].Size) > 0 then
           begin
             Alarm;
             WriteRam(1,Bpos+Bofs,Attrib[5],1,EFillStr(80,B1,B2+InfoZeile(327)));
             _ReadKey(KC,VC);
             if (KC = _Ret) or (UpCase(VC) in YesMenge) then
             begin
               Hstr := Pfad + GetFName(Dir^[Dpos].Name);
               DelAll(Hstr,Bpos+Bofs);
               if not PfadOk(0,Hstr) then Result := 0;
             end else
             begin
               Result := 1;
               GetCursorLine;
             end;
           end else

           if pos(UpDir,Dir^[Dpos].Size) = 0 then
           begin
             Assign(f,Pfad + GetFName(Dir^[Dpos].Name));
             GetFAttr(f,w);
             w := w and $07;
             if (w > 0) or SiAltK then
             begin
               Alarm;
               WriteRam(1,Bpos+Bofs,Attrib[5],1,EFillStr(80,B1,B2+InfoZeile(235)));
               _ReadKey(KC,VC);
               if (KC = _Ret) or (UpCase(VC) in YesMenge) then w := 0 else
               begin
                 w := 1;
                 Result := 1;
                 GetCursorLine;
               end;
             end;

             if w = 0 then
             begin
               SetFAttr(f,$20);
               if EraseTxt(f) = 0 then
               begin
                 Result := 0;
                 DirSize := DirSize - str_int(Dir^[Dpos].Size);
                 DrvFree := FreeStr(Pfad[1]);
               end;
             end;
           end else Alarm;

           if Result = 0 then
           begin
             for w := Dpos to DirFiles-1 do Dir^[w] := Dir^[w+1];
             FillChar(Dir^[DirFiles],SizeOf(Dir^[DirFiles]),0);
             dec(DirFiles);

             if Dpos > DirFiles then
             begin
               if Dpos > 1 then dec(Dpos);
               if Bpos > 1 then dec(Bpos);
             end;
             if ((DirFiles - Dpos + Bpos) < Zmax) and (Dpos > Bpos) then inc(Bpos);

             DirPage(Dpos - Bpos + 1);
           end else if Result = 255 then Alarm;
         end;

      _AltE
       : if Dir^[Dpos].Size[1] <> LRK then
         begin
           Mstr := GetFName(Dir^[Dpos].Name);
           ExecDOS(Konfig.EditVerz + B1 + Pfad + Mstr);
           InitStart(2,Mstr);
         end else Alarm;

      _AltF
       : begin
           WriteRam(1,Bpos+Bofs,Attrib[5],1,EFillStr(80,B1,B2+InfoZeile(54)));
           _ReadKey(KC,VC);
           if (KC = _Ret) or (UpCase(VC) in YesMenge) then
           begin
             K[show]^.WishBuf := true;
             S_PAC(show,NU,false,M1 + B1 + LRK + Mask + RRK + B1 + Pfad + M1);
             S_PAC(show,NU,false,B1 + ConstStr('=',44) + M1);
             if AnzM > 0 then w1 := 1
                         else w1 := Dpos;
             for w := w1 to DirFiles do
             begin
               if AnzM > 0 then
               begin
                 if Dir^[w].Mark then S_PAC(show,NU,false,B1 + GetDirStr(w,1) + M1);
               end else S_PAC(show,NU,false,B1 + GetDirStr(w,1) + M1);
             end;
             if AnzM > 0 then w := AnzM
                         else w := Word(DirFiles-Dpos+1);
             S_PAC(show,NU,false,B1 + ConstStr('-',44) + M1);
             S_PAC(show,NU,true,B1 + int_str(w) + B1 + Files + M2);
           end;
           GetCursorLine;
         end;

      _AltH
       : XP_Help(G^.OHelp[20]);

      _AltI
       : begin
           AnzM := 0;
           for w := 1 to DirFiles do
           begin
             if (pos(SubDir,Dir^[w].Size) = 0) and
                (pos(UpDir,Dir^[w].Size) = 0) then
             begin
               Dir^[w].Mark := not Dir^[w].Mark;
               if Dir^[w].Mark then inc(AnzM);
             end;
           end;
           DirPage(Dpos - Bpos + 1);
         end;

      _AltM
       : begin
           WriteRam(1,Bpos+Bofs,Attrib[5],1,EFillStr(80,B1,B2+InfoZeile(326)));
           GetString(Mask,Attrib[5],12,length(InfoZeile(326))+4,Bpos+Bofs,KC,3,Ins);
           if KC <> _Esc then
           begin
             if Mask = '' then Mask := Joker;
             InitStart(1,'');
           end else GetCursorLine;
         end;

      _AltN
       : begin
           Hstr := '';
           WriteRam(1,Bpos+Bofs,Attrib[5],1,EFillStr(80,B1,B2+InfoZeile(184)));
           GetString(Hstr,Attrib[5],60,length(InfoZeile(184))+3,Bpos+Bofs,KC,3,Ins);
           if KC <> _Esc then
           begin
             Mstr := Hstr;
             if pos(BS,Hstr) = 0 then Hstr := Pfad + Hstr;
             if MkSub(Hstr) then InitStart(2,Mstr) else
             begin
               Alarm;
               GetCursorLine;
             end;
           end else GetCursorLine;
         end;

      _AltO
       : begin
           Mstr := GetFName(Dir^[Dpos].Name);
           GetDir(0,Hstr);
           XPfad := Pfad;
           if length(XPfad) > 3 then delete(XPfad,length(XPfad),1);
           (*$I-*) ChDir(XPfad); (*$I+*)
           Result := IOResult;

           ExecDOS('');

           (*$I-*) ChDir(Hstr); (*$I+*)
           Result := IOResult;

           Flag := false;
           Repeat
             if not PfadOk(0,Pfad) then
             begin
               delete(Pfad,length(Pfad),1);
               While (length(Pfad) > 3) and (Pfad[length(Pfad)] <> BS)
                  do delete(Pfad,length(Pfad),1);
             end else Flag := true;
           Until Flag or (length(Pfad) <= 3);
           InitStart(2,Mstr);
         end;

      _AltL,
      _AltP
       : begin
           if KC = _AltL then Hstr := ''
                         else Hstr := Pfad;
           WriteRam(1,Bpos+Bofs,Attrib[5],1,EFillStr(80,B1,B2+InfoZeile(257)));
           GetString(Hstr,Attrib[5],60,length(InfoZeile(257))+4,Bpos+Bofs,KC,1,Ins);
           if KC <> _Esc then
           begin
             if length(Hstr) = 1 then Hstr := Hstr + DP;
             if Hstr[length(Hstr)] <> BS then Hstr := Hstr + BS;
             if PfadOk(0,Hstr) then
             begin
               Zeile := Hstr;
               Such := '';
               Mask := '';
               CheckPfad;
               InitStart(1,'');
             end else
             begin
               WriteRam(1,Bofs+Bpos,Attrib[4],1,
                EFillStr(80,B1,B2 + InfoZeile(75) + DP + B2 + Hstr));
               Alarm;
               Verzoegern(ZWEI);
               GetCursorLine;
             end;
           end else GetCursorLine;
         end;

      _AltR
       : if pos(UpDir,Dir^[Dpos].Size) = 0 then
         begin
           Hstr := GetFName(Dir^[Dpos].Name);
           WriteRam(1,Bpos+Bofs,Attrib[5],1,EFillStr(80,B1,B2+InfoZeile(4)));
           GetString(Hstr,Attrib[5],12,length(InfoZeile(4))+4,Bpos+Bofs,KC,0,Ins);
           if KC <> _Esc then
           begin
             Assign(f,Pfad + GetFName(Dir^[Dpos].Name));
             (*$I-*) Rename(f,Pfad + Hstr);  (*$I+*)
             if IOResult = 0 then
             begin
               if Dir^[Dpos].Size[1] <> LRK then
               begin
                 Hstr := EFillStr(9,Pkt,ParmStr(1,Pkt,Hstr)) +
                         EFillStr(3,B1,ParmStr(2,Pkt,Hstr));
               end else Hstr := EFillStr(12,B1,copy(Hstr,1,8));
               Dir^[Dpos].Name := Hstr;
             end else Alarm;
           end;
           GetCursorLine;
         end else Alarm;

      _AltS
       : begin
           WriteRam(1,Bofs+Bpos,Attrib[4],1,EFillStr(80,B1,B1+InfoZeile(142)));
           XPfad := Pfad;
           dec(XPfad[0]);
           While pos(BS,XPfad) > 0 do delete(XPfad,1,pos(BS,XPfad));
           While pos(DP,XPfad) > 0 do delete(XPfad,pos(DP,XPfad),1);
           XPfad := Konfig.SavVerz + XPfad + Pkt + 'DIR';
           GetString(XPfad,Attrib[4],60,9,Bofs+Bpos,KC,0,Ins);
           if KC <> _Esc then
           begin
             Assign(f,XPfad);
             Result := AppendTxt(f);
             if Result <> 0 then Result := RewriteTxt(f);
             if Result = 0 then
             begin
               Writeln(f,B1 + '[' + Mask + ']' + B1 + Pfad);
               Writeln(f,B1 + ConstStr('=',44));
               if AnzM > 0 then w1 := 1
                           else w1 := Dpos;
               for w := w1 to DirFiles do
               begin
                 if AnzM > 0 then
                 begin
                   if Dir^[w].Mark then Writeln(f,B1 + GetDirStr(w,1));
                 end else Writeln(f,B1 + GetDirStr(w,1));
               end;
               if AnzM > 0 then w := AnzM
                           else w := Word(DirFiles-Dpos+1);
               Writeln(f,B1 + ConstStr('-',44));
               Writeln(f,B1 + int_str(w) + B1 + Files);
               Writeln(f);
               FiResult := CloseTxt(f);
               InitStart(2,'');
             end else
             begin
               WriteRam(1,Bofs+Bpos,Attrib[4],1,
                EFillStr(80,B1,B2 + InfoZeile(75) + DP + B2 + XPFad));
               Alarm;
               Verzoegern(ZWEI);
             end;
           end;
           GetCursorLine;
         end;

      _AltT
       : if show > 0 then
         begin
           Open_SaveFiles;
           Alarm;
           WriteRam(1,Bpos+Bofs,Attrib[5],1,EFillStr(80,B1,B2+InfoZeile(159)));
           _ReadKey(KC,VC);
           if (KC = _Ret) or (UpCase(VC) in YesMenge) then
           begin
             if K[show]^.FileSend then FertigSenden(show);
             if (AnzM > 0) then
             begin
               for w := 1 to DirFiles do if Dir^[w].Mark then
               begin
                 Hstr := Pfad + GetFName(Dir^[w].Name);
                 WriteRam(1,Bpos+Bofs,Attrib[5],1,EFillStr(80,B1,B2 + Hstr));
                 TXT_TX_File_Sofort(show,Hstr);
                 Dir^[w].Mark := false;
               end;
               WriteRam(1,Bpos+Bofs,Attrib[5],1,
                EFillStr(80,B1,B2+int_str(AnzM)+B1+InfoZeile(122)));
               Verzoegern(EINT);
               AnzM := 0;
             end else if (pos(SubDir,Dir^[Dpos].Size) = 0) and
                         (pos(UpDir,Dir^[Dpos].Size) = 0) then
             begin
               Hstr := Pfad + GetFName(Dir^[Dpos].Name);
               WriteRam(1,Bpos+Bofs,Attrib[5],1,EFillStr(80,B1,B2+Hstr));
               TXT_TX_File_Sofort(show,Hstr);
               Verzoegern(EINT);
             end else Alarm;
             DirPage(Dpos - Bpos + 1);
           end else GetCursorLine;
           Close_SaveFiles;
         end else Alarm;

      _AltV
       : if Dir^[Dpos].Size[1] <> LRK then
         begin
           Mstr := GetFName(Dir^[Dpos].Name);
           ExecDOS(Konfig.ViewVerz + B1 + Pfad + Mstr);
           InitStart(2,Mstr);
         end else Alarm;

      _Alt7,
      _AltW
       : if (show > 0) and (AnzM > 0) then
         begin
           VA := Key[KC].Ze;
           Open_SaveFiles;
           Sstr := '';
           WriteRam(1,Bpos+Bofs,Attrib[5],1,ConstStr(B1,80));
           GetString(Sstr,Attrib[5],60,2,Bpos+Bofs,KC,0,Ins);
           if (KC = _Ret) and (Sstr > '') then
           begin
             if K[show]^.FileSend then FertigSenden(show);
             K[show]^.WishBuf := true;
             for w := 1 to DirFiles do if Dir^[w].Mark then
             begin
               if VA = Key[_Alt7].Ze then
               begin
                 Hstr := Get7PlFNr(Pfad + GetFName(Dir^[w].Name));
                 if Hstr > '' then Hstr := B1 + Hstr;
               end else Hstr := '';
               S_PAC(show,NU,false,Sstr + B1 + GetFName(Dir^[w].Name)+Hstr+M1);
               Hstr := Pfad + GetFName(Dir^[w].Name);
               WriteRam(1,Bpos+Bofs,Attrib[5],1,EFillStr(80,B1,B2 + Hstr));
               TXT_TX_File_Sofort(show,Hstr);
               Dir^[w].Mark := false;
               if not K[show]^.TxLRet then S_PAC(show,NU,false,M1);
               S_PAC(show,NU,true,^Z + M1);
             end;
             WriteRam(1,Bpos+Bofs,Attrib[5],1,
              EFillStr(80,B1,B2+int_str(AnzM)+B1+InfoZeile(122)));
             Verzoegern(EINT);
             AnzM := 0;
             DirPage(Dpos - Bpos + 1);
           end else GetCursorLine;
           Close_SaveFiles;
         end else Alarm;

      _Alt6,
      _AltZ
       : if (show > 0) and (AnzM > 0) then
         begin
           VA := Key[KC].Ze;
           Open_SaveFiles;
           Sstr := '';
           WriteRam(1,Bpos+Bofs,Attrib[5],1,ConstStr(B1,80));
           GetString(Sstr,Attrib[5],60,2,Bpos+Bofs,KC,0,Ins);
           if (KC = _Ret) and (Sstr > '') then
           begin
             if K[show]^.FileSend then FertigSenden(show);
             K[show]^.WishBuf := true;
             for w := 1 to DirFiles do if Dir^[w].Mark then
             begin
               if VA = Key[_Alt6].Ze then
               begin
                 Hstr := GetBsFNr(Pfad + GetFName(Dir^[w].Name));
                 if Hstr > '' then Hstr := B1 + Hstr;
               end else Hstr := '';
               S_PAC(show,NU,true,Sstr + B1 + GetFName(Dir^[w].Name)+Hstr+M1);
               Hstr := Pfad + GetFName(Dir^[w].Name);
               WriteRam(1,Bpos+Bofs,Attrib[5],1,EFillStr(80,B1,B2 + Hstr));
               BIN_TX_File_Sofort(show,Hstr);
               Dir^[w].Mark := false;
             end;
             WriteRam(1,Bpos+Bofs,Attrib[5],1,
              EFillStr(80,B1,B2+int_str(AnzM)+B1+InfoZeile(122)));
             Verzoegern(EINT);
             AnzM := 0;
             DirPage(Dpos - Bpos + 1);
           end else GetCursorLine;
           Close_SaveFiles;
         end else Alarm;

      _Andere
       : begin
           if VC = B1 then
           begin
             if (pos(SubDir,Dir^[Dpos].Size) = 0) and
                (pos(UpDir,Dir^[Dpos].Size) = 0) then
             begin
               Dir^[Dpos].Mark := not Dir^[Dpos].Mark;
               if Dir^[Dpos].Mark then inc(AnzM)
                                  else dec(AnzM);
               GetCursorLine;
               CursorDn;
             end else Alarm;
           end else

           begin
             Such := Such + UpCase(VC);
             w := 0;
             Flag := false;
             While (w < DirFiles) and not Flag do
             begin
               inc(w);
               if pos(Such,GetFName(Dir^[w].Name)) = 1 then
               begin
                 Flag := true;
                 Dpos := w;
                 if (Dpos < Bpos) or (DirFiles <= Zmax) then Bpos := Dpos;
                 if ((DirFiles - Dpos + Bpos) < Zmax) and
                    (DirFiles > Zmax) and
                    (Dpos > Bpos) then Bpos := Zmax - (DirFiles - Dpos);
               end;
             end;

             if not Flag then
             begin
               Alarm;
               Such := '';
             end else DirPage(Dpos - Bpos + 1);
           end;
         end;

      else Alarm;
    end;

    WriteAttr(1,yM+Bofs,80,Attrib[2],1);
    WriteAttr(1,Bpos+Bofs,80,Attrib[4],1);
    yM := Bpos;
  Until Fertig;

  FreeMem(Dir,SizeOf(Dir^));

  Open_SaveFiles;
  DirScroll := false;
  Moni_On;
End;


Procedure RemoteDir (* Kanal : Byte; Zeile : Str80 *);
Type    FeldPtr = array[1..maxDirRem] of String[43];

Var     SpAnz    : Byte;
        i,i1,ax  : Word;
        Free     : LongInt;
        BStr     : String[80];
        Path     : String[80];
        Fstr     : String[5];
        ch       : Char;

Begin
  Close_SaveFiles;
  Open_SaveFiles;

  GetMem(Dir,SizeOf(Dir^));
  SpAnz := 1;
  ax := AnyFile;
  KillendBlanks(Zeile);
  Bstr := RestStr(Zeile);

  if pos('/',Bstr) > 0 then While pos('/',Bstr) > 0 do
  begin
    i := pos('/',Bstr);
    if (i+1 >= length(Bstr)) and (i > 0) then
    begin
      case Bstr[i+1] of
        'F' : ax := AnyFile - Directory;
        'D' : ax := Directory;
        'S' : ax := SysFile;
        'H' : ax := Hidden;
        'R' : ax := ReadOnly;
        'A' : ax := Archive;
        '1',
        '2',
        '3' : SpAnz := str_int(Bstr[i+1]);
      end;
      delete(Bstr,i,2);
    end else delete(Bstr,i,1);
  end;

  Path := CutStr(Zeile);
  if Path[length(Path)] = BS then Path := Path + Joker;

  Fstr := ConstStr(B1,5);

  case SpAnz of
    1  : i := 40;
    2  : i := 80;
    3  : i := 70;
  end;

  Bstr := InfoZeile(169);
  S_PAC(Kanal,NU,false,M1 + ConstStr(B1,(i-length(Bstr)) div 2) + Bstr + M1);
  S_PAC(Kanal,NU,false,ConstStr(B1,(i-length(Bstr)) div 2) + ConstStr(GL,length(Bstr)) + M1);

  GetDirFiles(Path,ax,1);

  if DirFiles > 0 then
  begin
    Bstr := '';
    for i := 1 to DirFiles do
    begin
      if i mod SpAnz = 0
        then S_PAC(Kanal,NU,false,GetDirStr(i,SpAnz) + M1)
        else S_PAC(Kanal,NU,false,GetDirStr(i,SpAnz) + B2 + B2);
    end;
    if not K[Kanal]^.TxLRet then S_PAC(Kanal,NU,false,M1);
  end;
  S_PAC(Kanal,NU,false,M1 + InfoZeile(142) + B1 + Path + M1 +
                           int_str(DirFiles) + B1 + InfoZeile(141) + B1 +
                           FormByte(int_str(DirSize)) + B1 + Bytes + B3 +
                           InfoZeile(324) + B1 +
                           FreeStr(Path[1]) + B1 + Bytes + M1);

  FreeMem(Dir,SizeOf(Dir^));
End;


Procedure DelAll (* Pfad : Str80; Yp : Byte *);
Var  srec    : SearchRec;
     Vstr,
     Dstr    : String[80];
     Fl,Flag,
     NewVerz : Boolean;
     f       : Text;
     Result  : Word;
Begin
  Flag := false;
  NewVerz := true;
  Dstr := Pfad;
  GetDir(0,Vstr);
  (*$I-*) ChDir(copy(Pfad,1,3)); (*$I+*)
  Result := IOResult;

  While not Flag and not KeyPressed do with srec do
  begin
    if NewVerz then FindFirst(Pfad + BS + Joker,Directory,srec);
    NewVerz := false;

    if DosError = 0 then
    begin
      if Attr and Directory = Directory then
      begin
        if pos(Pkt,Name) <> 1 then
        begin
          Pfad := Pfad + BS + Name;
          NewVerz := true;
        end;
      end else
      begin
        Assign(f,Pfad + BS + Name);
        (*$I-*) SetFAttr(f,$00); (*$I+*)
        Result := IOResult;
        Result := EraseTxt(f);
        if (Result = 0) and (Yp > 0) then
          WriteRam(1,Yp,Attrib[5],1,EFillStr(80,B1,B2 + Pfad + BS + Name));
      end;
    end else
    begin
      Fl := false;
      (*$I-*) RmDir(Pfad); (*$I+*)
      Result := IOResult;
      if (Result = 0) and (Yp > 0) then
          WriteRam(1,Yp,Attrib[5],1,EFillStr(80,B1,B2 + Pfad));
      While (length(Pfad) > length(Dstr)) and (Pfad[length(Pfad)] <> BS) do
      begin
        delete(Pfad,length(Pfad),1);
        Fl := true;
      end;
      Flag := Dstr = Pfad;
      if Fl then delete(Pfad,length(Pfad),1);
      NewVerz := true;
    end;

    if not NewVerz then FindNext(srec);
  end;
  (*$I-*) ChDir(Vstr); (*$I+*)
  Result := IOResult;
End;


Function  Get7PlFNr (* Zeile : Str80 : Str20 *);
Begin
  Assign(G^.TFile,Zeile);
  if ResetTxt(G^.TFile) = 0 then
  begin
    Readln(G^.TFile,Zeile);
    FiResult := CloseTxt(G^.TFile);
    if (UpCaseStr(copy(Zeile,1,8)) = Meldung[11]) and
       (str_int(ParmStr(2,B1,Zeile)) > 0) and
       (str_int(ParmStr(4,B1,Zeile)) > 0) then
    begin
      Zeile := ParmStr(2,B1,Zeile) + '/' + ParmStr(4,B1,Zeile);
    end else Zeile := '';
  end else Zeile := '';
  Get7PlFNr := Zeile;
End;


