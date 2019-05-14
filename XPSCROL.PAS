{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P S C R O L . P A S                                                  ³
 ³                                                                         ³
 ³ Routinen fr den Backscroll des QSO-Fensters (Hauptbildschirm)          ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


Procedure Notiz_Zeigen (* Kanal : Byte *);

Type      RetPtr    = array[-1..maxNotLines+2] of Word;
          AttPtr    = array[-1..maxNotLines+2] of Boolean;

Var       Groesse   : LongInt;
          Zeilen,
          abline,
          von,bis,
          i,i1,P,a,
          X,Y,XB,
          Result    : Integer;
          StartPage,
          StopPage,
          Z         : Word;
          b,Nx,
          AMark,
          AMerk     : Byte;
          MoStr     : String[80];
          Save_Name : String[60];
          Suchstr   : String[30];
          ablineStr : String[19];
          BlStr,
          Zstr      : String[2];
          KC        : Sondertaste;
          VC        : Char;
          NSave     : Text;
          RetFlag,
          gefunden,
          fertig,
          Flag,
          PFlag,
          VorEdit,
          MarkBlock,
          NowBlock,
          NowZlnMerk,
          CurObStat : Boolean;
          RET       : ^RetPtr;
          BlAttr    : ^AttPtr;

Label Nochmal,
      Nochmal1;

  Procedure GetRam;
  Var    i : Word;
  Begin
    if not MarkBlock then
    begin
      GetMem(BlAttr,Zeilen);
      FillChar(BlAttr^,Zeilen,0);
      for i := 1 to Zeilen do BlAttr^[i] := false;
      MarkBlock := true;
    end;
  End;

  Function Eig(Nr : Word) : Str2;
  Begin
    if (Kanal > 0) and (Page^[RET^[Nr]+1] = Attrib[19]) then Eig := EchoCh
                                                        else Eig := '';
  End;

  Function Eig2(Nr : Word) : Str2;      {//db1ras}
  Begin
    If (Kanal > 0) and (Page^[RET^[Nr]+1] = Attrib[19]) then
      Eig2 := EchoCh + EchoCh
    Else
      Eig2 := EchoCh + B1;
  End;

  Procedure Array_updaten(Kanal : Byte);
  Var    NotPtr,
         CRPtr     : Pointer;
         max       : Word;
         ZL        : Integer;
  Begin
    with K[Kanal]^ do
    begin
      FillChar(Page^,maxNotCh,0);
      if use_EMS then EMS_Seite_einblenden(Kanal,Scr);

      if use_Vdisk then
      begin
        FiResult := ResetBin(ScrollFile,T);

        Seek(ScrollFile,Pos_im_Scr + NotPos);
        Blockread(ScrollFile,Page^[0],maxNotCh-1-NotPos,Z);

        Seek(ScrollFile,Pos_im_Scr);
        Blockread(ScrollFile,Page^[maxNotCh-1-NotPos],NotPos,Z);

        FiResult := CloseBin(ScrollFile);
      end else
      if use_XMS then
      begin
        XMS_to_Data(@Page^[0],XMS_Handle,Pos_im_Scr+NotPos,maxNotCh-1-NotPos);
        XMS_to_Data(@Page^[maxNotCh-1-NotPos],XMS_Handle,Pos_im_Scr,NotPos);
      end else
      begin
        move(NotCh[Kanal]^[NotPos],Page^[0],maxNotCh-1-NotPos);
        move(NotCh[Kanal]^[0],Page^[maxNotCh-1-NotPos],NotPos);
      end;
      Page^[maxNotCh-1] := 13;
      max := maxNotCh;
    end;

    NotPtr := @Page^[0];
    CRPtr := @RET^[1];

    asm  push ds
         mov  cx, max
         mov  bx, 0
         mov  dx, 0
         les  di, CRPtr
         lds  si, NotPtr
         jmp  @Weiter
    @CR:
         mov  [es:di], bx
         add  di, 2
         inc  dx
         jmp  @Again
@Weiter:
         mov  al, [ds:si]
         cmp  al, 13
         je   @CR
 @Again:
         inc  si
         inc  bx
         Loop @Weiter
         pop  ds
         mov  ZL, dx
    end;
    Zeilen := ZL; {***}

    (*
    for ZL := 0 to K[Kanal]^.maxNotCh-1 do
    begin
      if Page^[ZL] = 13 then
      begin
        inc(Zeilen);
        RET^[Zeilen] := ZL;
      end;
    end;
    *)

    dec(Zeilen);
    if Zeilen <= 0 then Zeilen := 1;
  end;


  Function BringZeile(Kanal : Byte; Nr : Integer) : String;
  var      P    : Word;
           Hstr : String;
           Ze   : Byte;
  begin
    with K[Kanal]^ do
    begin
      Hstr := '';
      for P := (RET^[Nr]+2) to (RET^[Nr+1]-1) do
      begin
        Ze := Page^[P];
        if Ze in [1..8,10..31] then
        begin
          Ze := Ze + 64;
          Hstr := Hstr + '^';
        end;
        Hstr := Hstr + chr(Ze);
      end;
      BringZeile := Hstr;
    end;
  end;

  Procedure Zeig(Kanal,von,bis : Byte; PLine : Integer);
  var       i,i1,j,
            Attr   : Byte;
            Hstr   : String[80];
  Begin
    i1 := 0;
    if Zeilen > 1 then for i := von to bis do
    begin
      Attr := Page^[RET^[PLine+i1]+1];
      if Attr = 254 then Attr := 13;
      if (MarkBlock and BlAttr^[PLine+i1]) or ((i = Y) and not MarkBlock)
         then Attr := Attrib[4];
      FillChar(Hstr[1],80,32);
      Hstr[0] := Chr(80);
      j := Byte(RET^[PLine+i1+1] - RET^[PLine+i1] - 2);
      if j > 80 then j := 80;
      move(Page^[RET^[PLine+i1]+2],Hstr[1],j);
      WritePage(Kanal,1,i,Attr,0,Hstr);
      inc(i1);
    end;
  End;

  Procedure CursorUp(Kanal : Byte);
  Begin
    if abline + Y - von > 1 then
    begin
      dec(Y);
      if Y < von then
      begin
        Y := von;
        dec(abline);
        Scroll(Dn,1,von,bis);
      end;
      Zeig(Kanal,Y,Y+1,abline + Y - von);
    end;
  End;

  Procedure CursorDown(Ka : Byte);
  Var   Merk : Integer;
        Flag : Boolean;
  Begin
    Flag := false;
    if (K[Ka]^.NeueZeilen > 0) and not MarkBlock and
       not ((abline < (Zeilen - bis + von)) or (Y < bis)) then
    begin
      Merk := Zeilen;
      Array_updaten(Ka);
      abline := abline - (K[Ka]^.NeueZeilen - (Zeilen-Merk));
      K[Ka]^.ScrZlnMerk := Word(K[Ka]^.ScrZlnMerk + K[Ka]^.NeueZeilen);
      K[Ka]^.NeueZeilen := 0;

      if (abline < 1) and (Zeilen > bis - von) then
      begin
        abline := 1;
        Y := von;
        Zeig(Ka,von,bis,abline);
        Flag := true;
      end;
    end;

    If (abline + (Y-von) < Zeilen) and not Flag then
    begin
      inc(Y);
      if Y > bis then
      begin
        Y := bis;
        inc(abline);
        Scroll(Up,1,von,bis);
      end;
      Zeig(Ka,Y-1,Y,abline + (Y-1) - von);
    end;
  End;

  Procedure NewBild;
  Begin
    if abline > 0 then Zeig(Kanal,von,bis,abline)
                  else Zeig(Kanal,Y,bis,abline + Y-von);
  End;

  Procedure CancelBlock;
  Begin
    if MarkBlock then
    begin
      FreeMem(BlAttr,Zeilen);
      MarkBlock := false;
      StartPage := 0;
      StopPage := 0;
      Cursor_aus;
    end;
    NewBild;
  End;

Begin
  with K[Kanal]^ do
  begin
   BackupBremsen:=true;
    Nx := (NrStat[2]-1) * 20 + 1;
    ScrZlnMerk := Word(ScrZlnMerk + NeueZeilen);
    NeueZeilen := 0;
    Neu_Bild;
    RetFlag := false;
    VorEdit := false;
    QsoScroll := true;
    CurObStat := false;
    MarkBlock := false;
    NowBlock := false;
    NowZlnMerk := false;
    StartPage := 0;
    StopPage := 0;
    XB := 1;
    if Braille80 then X := 80 else X := 1;
    Zeilen := 0;
    RET := Nil;
    Page := Nil;
{***}{   GetMem(RET,(maxNotLines+4)*2); }
     {   FillChar(RET^,SizeOf(RET),0);  }
     {   GetMem(Page,maxNotCh+86);      }
    GetMem(RET,maxNotLines*2);       {//db1ras}
    FillChar(RET^,SizeOf(RET^),0);   {//db1ras}
    GetMem(Page,maxNotCh);           {//db1ras}

    Array_updaten(Kanal);

    if Kanal > 0 then
    begin
      von := QBeg;   bis := QEnd;
    end else
    begin
      von := UnStat + 1;   bis := maxZ;
    end;
    abline := Zeilen - (bis - von);
    Y := bis;
    Zeig(Kanal,Y,Y,abline + Y - von);
    WriteAttr(1,Y,80,Attrib[4],1);
    Fertig := false;
    SuchStr := '';

Nochmal:
             {NX+1}
    WriteRam(61,ObStat+2,Attrib[9],1,ConstStr(B1,19));
    Repeat
      i := ((Zeilen + 1) - abline) - (Y - von);
      i1 := abline + (Y-von);  {*****}
      if MarkBlock then BlStr := S_ch
                   else BlStr := B1;
      if MarkBlock and BlAttr^[i1] then
      begin
        BlStr := 'þ' + BlStr;
        if not NowBlock and BlTon then Beep(G^.BLockAnfFreq,G^.BlockPiep1Time);
        NowBlock := true;
      end else
      begin
        BlStr := B1 + BlStr;
        if NowBlock and BlTon then Beep(G^.BLockEndFreq,G^.BlockPiep2Time);
        NowBlock := false;
      end;
      abLineStr := SFillStr(4,B1,int_str(i)) + '/' + int_str(Zeilen) + BlStr;
              {nx+1}
      WriteRam(61,ObStat+2,Attrib[9],1,EFillStr(9,B1,ablineStr));
      if HardCur and not VorEdit then
      begin
        if CurObStat then SetzeCursor(X,ObStat+2)
                     else SetzeCursor(X,Y);
      end else if MarkBlock then SetzeCursor(XB,Y);

      Repeat
        if TimerTick > PollTime then
        begin
          Uhr_aus;
                  {Nx+12}
{**}      WriteRam(72,ObStat+2,Attrib[9],1,EFillStr(8,B1,LRK + int_str(NeueZeilen) + RRK));
          TNCs_Pollen;
          if notScroll then
          begin
            notScroll := false;
            if abline > 0 then Zeig(Kanal,von,bis,abline)
                          else Zeig(Kanal,Y,bis,abline + Y-von);
          end;
        end;
      Until _KeyPressed;
      _ReadKey(KC,VC);
      PollTime := TimerTick + KeyDelay;

      if VorEdit then
      begin
        if KC in [_Esc,_PgUp,_Alt0,_F11] then
        begin
          VorEdit := false;
          Zeig(Kanal,Y,Y,abline + Y-von);
        end else
        if KC in [_AltA.._AltY,_AltZ,_Home,_ShIns,_ShTab,_End,_Ins.._Ret,_Back,_Nix]
         then Key_Active(Kanal,KC,VC)
         else Alarm;
      end else
      case KC of
         _Up : CursorUp(Kanal);

         _Dn : CursorDown(Kanal);

       _Home : begin
                 if ScrZlnMerk >= Zeilen then ScrZlnMerk := Zeilen - 1;
                 if ScrZlnMerk > (bis - von) then Y := von
                                             else Y := bis - ScrZlnMerk;
                 i := abline;
                 abline := Zeilen - ScrZlnMerk + von - Y;
                 if abline > 0 then Zeig(Kanal,von,bis,abline) else
                 begin
                   abline := i;
                   Y := bis - ScrZlnMerk + 1;
                   if Y > bis then Y := bis;
                   Zeig(Kanal,Y,bis,abline + Y - von);
                 end;
               end;

       _End  : begin
                 ScrZlnMerk := Word(Zeilen - abline - Y + von);
                 NowZlnMerk := true;
               end;

       _PgUp : begin        { Page up     }
                 if abline > 0 then
                 begin
                   abline := abline - (bis-von);
                   if HardCur then Y := von + 1;
                   if abline <= 0 then
                   begin
                     abline := 1;
                     Y := von;
                   end;
                   Zeig(Kanal,von,bis,abline);
                 end;{ else
                 begin
                   Y := bis - Zeilen + 1;
                   Zeig(Kanal,Y,bis,abline + Y-von);
                 end; }
               end;

       _PgDn : begin        { Page down   }
                 PFlag := false;
                 if (NeueZeilen > 0) and not MarkBlock and
                    (abline + bis - von > Zeilen - bis + von) then
                 begin
                   i := Zeilen;
                   Array_updaten(Kanal);
                   abline := abline - (NeueZeilen - (Zeilen-i));
                   ScrZlnMerk := Word(ScrZlnMerk + NeueZeilen);
                   NeueZeilen := 0;

                   if (abline < 1) and (Zeilen > bis - von) then
                   begin
                     abline := 1;
                     Y := von;
                     Zeig(Kanal,von,bis,abline);
                     PFlag := true;
                   end;
                 end;

                 if not PFlag then if abline > 0 then
                 begin
                   abline := abline + (bis-von);
                   if HardCur then Y := von + 1;
                   if abline > (Zeilen - (bis - von)) then
                   begin
                     abLine := Zeilen - (bis - von);
                     Y := bis;
                   end;
                   Zeig(Kanal,von,bis,abline);
                 end else
                 begin
                   Y := bis;
                   Zeig(Kanal,Y-Zeilen+1,Y,1);
                 end;
               end;

   _CtrlPgUp : begin        { ^PageUp     }
                 if abline > 0 then
                 begin
                   abline := 1;
                   Y := von;
                   Zeig(Kanal,von,bis,abline);
                 end else
                 begin
                  { Y := bis - Zeilen + 1;
                   Zeig(Kanal,Y,bis,abline + Y-von);}
                 end;
               end;

   _CtrlPgDn : begin        { ^PageDn     }
                 if abline > 0 then
                 begin
                   abLine := Zeilen - (bis - von);
                   Y := bis;
                   Zeig(Kanal,von,bis,abline);
                 end else
                 begin
                   Y := bis;
                   Zeig(Kanal,Y-Zeilen+1,Y,1);
                 end;
               end;

   _CtrlHome : begin
                 if abline > 0 then
                 begin
                   Y := von;
                   Zeig(Kanal,von,bis,abline);
                 end else
                 begin
                   Y := bis - Zeilen + 1;
                   Zeig(Kanal,Y,bis,abline + Y-von);
                 end;
               end;

    _CtrlEnd : begin        { ^Ende }
                 if abline > 0 then
                 begin
                   Y := bis;
                   Zeig(Kanal,von,bis,abline);
                 end else
                 begin
                   Y := bis;
                   Zeig(Kanal,Y-Zeilen+1,Y,1);
                 end;
               end;

       _ShUp : if abline + (Y-von) > 1 then
               begin
                 GetRam;
                 if BlAttr^[abline + (Y-von)] then
                 begin
                   BlAttr^[abline + (Y-von)] := false;
                 end else
                 if BlAttr^[abline + (Y-von)-1] then
                 begin
                   BlAttr^[abline + (Y-von)-1] := false;
                 end else BlAttr^[abline + (Y-von)] := true;
                 CursorUp(Kanal);
               end;

       _ShDn : if abline + (Y-von) < Zeilen then
               begin
                 GetRam;
                 if BlAttr^[abline + (Y-von)] then
                 begin
                   BlAttr^[abline + (Y-von)] := false;
                 end else
                 if BlAttr^[abline + (Y-von)+1] then
                 begin
                   BlAttr^[abline + (Y-von)+1] := false;
                 end else BlAttr^[abline + (Y-von)] := true;
                 CursorDown(Kanal);
               end;

    _ShRight : begin
                 GetRam;
                 BlAttr^[abline + (Y-von)] := not BlAttr^[abline + (Y-von)];
                 Zeig(Kanal,Y,Y,abline + Y-von);
               end;

       _Alt1 : StartPage := abline + (Y-von);

       _Alt2 : if StartPage > 0 then
               begin
                 GetRam;
                 StopPage := abline + (Y-von);
                 if StartPage > StopPage then
                 begin
                   i := StopPage;
                   StopPage := StartPage;
                   StartPage := i;
                 end;
                 for i := StartPage to StopPage do BlAttr^[i] := true;
                 StartPage := 0;
                 NewBild;
               end else Alarm;

     _AltF, _AltN :
               If ((Zeilen + 1) - abline) - (Y - von) > 1 then
               begin
                 if (KC = _AltN) and (Suchstr > '') then goto Nochmal1;
                 WriteRam(1,Y,Attrib[4],1,EFillStr(80,B1,InfoZeile(7)));
                 GetString(Suchstr,Attrib[4],30,45,Y,KC,0,Ins);
                 Suchstr:=upcasestr(Suchstr);
                 if KC <> _Esc then
                 begin
       Nochmal1:
                   i := abline + (Y-von) +1;
                   gefunden := false;
                   Repeat
                     gefunden := pos(Suchstr,UpCaseStr(BringZeile(Kanal,i))) > 0;
                     inc(i);
                   Until gefunden or (i > Zeilen);
                   if gefunden then
                   begin
                     if (i > Zeilen - (bis - von)) and ((Zeilen-i) < (bis-Y)) then
                     begin
                       abline := Zeilen - (bis - von);
                       Y := ((i - abline) + von) - 1;
                     end else  abline := (i - Y) + (von - 1);
                     if abline > 0 then Zeig(Kanal,von,bis,abline)
                                   else Zeig(Kanal,Y,bis,abline + Y-von);
                     if Klingel then Beep(1500,30);
                   end else
                   begin
                     Teil_Bild_Loesch(Y,Y,Attrib[4]);
                     WriteRam(10,Y,Attrib[4],1,InfoZeile(9));
                     Alarm;
                     Verzoegern(ZWEI);
                   end;
                 end;
                 if abline > 0 then Zeig(Kanal,von,bis,abline)
                               else Zeig(Kanal,bis-Zeilen+1,bis,1);
                 VC := #255;
                 goto Nochmal;
               end else Alarm;

       _Ret,
       _AltZ : if Zeilen > 1 then
               begin
                 if KC = _AltZ then Zstr := '> ' else Zstr := '';
                 if Vor_im_EMS then EMS_Seite_einblenden(Kanal,Vor);
                 if RetFlag then Chr_Vor_Show(Kanal,_Alt7,#255);
                 VorWrite[Kanal]^[stV] := Zstr + BringZeile(Kanal,abline + (Y-von));
                 Chr_Vor_Show(Kanal,_End,#255);
                 RetFlag := true;
                 CursorDown(Kanal);
                 goto Nochmal;
               end else Alarm;

       _AltG : begin
                 SysopParm := true;
                 PassRetry := 1;
                 PassRight := 1;
                 SysopArt := LRK + CutStr(User_Name) + RRK;
                 MoStr := BringZeile(Kanal,abline + (Y-von));
                 if pos(RSK,MoStr) = 0 then MoStr := RSK + MoStr;
                 Password_Auswert(Kanal,MoStr + M1);
               end;

       _AltH : XP_Help(G^.OHelp[19]);

       _AltM : if Kanal = 0 then
               begin
                 MoStr := BringZeile(Kanal,abline + (Y-von));

                 i := pos(LRK,MoStr);
                 i1 := pos(LRK + B1,MoStr);
                 if (i = 1) and (i1 = 4) then delete(MoStr,1,5);

                 i := pos(fm,MoStr);
                 i1 := pos(zu,MoStr);
                 if (i > 0) and (i1 > i) then
                 begin
                   delete(MoStr,i1,3);
                   delete(MoStr,1,i+2);
                 end;

                 i := pos(DP,MoStr);
                 if i = 2 then delete(MoStr,1,2);

                 i := pos(RSK,MoStr);
                 if i <= 10 then MoStr[i] := B1;
                 FreeMonitorKanal(b,ParmStr(1,B1,MoStr) + B1 + ParmStr(2,B1,MoStr));
                 if b > 0 then
                 begin
                   Calls_Monitoren(b,ParmStr(1,B1,MoStr) + B1 + ParmStr(2,B1,MoStr));
                   if abline > 0 then Zeig(Kanal,von,bis,abline)
                                 else Zeig(Kanal,bis-Zeilen+1,bis,1);
                 end else Alarm;
               end else Alarm;

       _AltP : begin
                 if (LPT_vorhanden and not LPT_Error(PrtPort)) then
                 begin
                   if MarkBlock then
                   begin
                     for i := 1 to Zeilen do if BlAttr^[i] then
                      Write_Drucker(Kanal,Eig(i) + BringZeile(Kanal,i) + M1);
                     CancelBlock;
                   end else for i := abline + (Y-von) to Zeilen do
                       Write_Drucker(Kanal,Eig(i) + BringZeile(Kanal,i) + M1);
                 end else
                 begin
                   WriteRam(1,Y,Attrib[4],1,EFillStr(80,B1,InfoZeile(290)));
                   Alarm;
                   Verzoegern(ZWEI);
                 end;
                 Zeig(Kanal,Y,Y,abline + Y-von);
                 VC := #255;
                 goto Nochmal;
               end;

       _AltS : Begin   { Saven }
                 WriteRam(1,Y,Attrib[4],1,EFillStr(80,B1,B1+InfoZeile(142)+B1));
                 Save_Name := Konfig.SavVerz + 'SCR.'+ SFillStr(3,'0',int_str(Kanal));
                 GetString(Save_Name,Attrib[4],60,9,Y,KC,1,Ins);
                 if KC <> _Esc then
                 begin
                   Assign(NSave,Save_Name);
                   Result := AppendTxt(NSave);
                   if Result <> 0 then Result := RewriteTxt(NSave);
                   if Result = 0 then
                   begin
                     if MarkBlock then
                     begin
                       for i := 1 to Zeilen do
                        if BlAttr^[i] then Writeln(NSave,Eig(i),BringZeile(Kanal,i));
                       CancelBlock;
                     end else for i := abline + (Y-von) to Zeilen do
                                       Writeln(NSave,Eig(i),BringZeile(Kanal,i));
                     FiResult := CloseTxt(NSave);
                   end else
                   begin
                     WriteRam(1,Y,Attrib[4],1,EFillStr(80,B1,B1 +
                                  InfoZeile(75) + DP + B2 + Save_Name));
                     Alarm;
                     Verzoegern(ZWEI);
                   end;
                 end;
                 VC := #255;
                 Zeig(Kanal,Y,Y,abline + Y-von);
               end;

       _AltW : Begin   { Kopie //db1ras}
                 Flag := false;
                 WriteRam(1,Y,Attrib[4],1,EFillStr(80,B1,
                          B1+InfoZeile(460)+B1));
                 GetString(UeberNr,Attrib[4],2,length(InfoZeile(460))+3,
                           Y,KC,0,Flag);
                 a := str_int(UeberNr);
                 If KC = _Ret Then Begin
                   If a in [0..maxLink] Then Begin
                     If K[a]^.connected or K[a]^.Test Then Begin
                       K[a]^.EigFlag := true;
                       K[a]^.WishBuf := true;
                       If MarkBlock Then Begin
                         For i := 1 To Zeilen Do
                           If BlAttr^[i] Then
                             S_PAC(a,NU,false,Eig2(i)+BringZeile(Kanal,i)+M1);
                         CancelBlock;
                       End Else
                         For i := abline + (Y-von) To Zeilen Do
                           S_PAC(a,NU,false,Eig2(i)+BringZeile(Kanal,i)+M1);
                       S_PAC(a,NU,true,'');
                       K[a]^.EigFlag := false;
                     End;
                   End Else
                     Alarm;
                 End;
                 VC := #255;
                 Zeig(Kanal,Y,Y,abline + Y-von);
               End;

      _ShTab : begin
                 CurObStat := not CurObStat;
                 if CurObStat then X := ((NrStat[2]-1)*20)+1 else X := 80;
               end;

     _Tab    : CancelBlock;

     _Ins    : begin
                 VorEdit := true;
                 WriteRam(1,Y,Attrib[4],1,ConstStr(#24,80));
                 Chr_Vor_Show(Kanal,_Nix,#255);
               end;

   _F1.._F10,
   _F12      : begin
                 ch_aus := true;
                 SK_out := KC;
                 VC_out := VC;
                 Fertig := true;
               end;

        _Del, _Esc
             : Fertig := true;

     _Andere : Alarm;
        else Alarm;
      end;      (* case *)
    Until Fertig;
    if MarkBlock then FreeMem(BlAttr,Zeilen);
    if ZlnMerk and not NowZlnMerk then ScrZlnMerk := Word(Zeilen - abline - Y + von);
{***}{   FreeMem(Page,maxNotCh+86);      }
     {   FreeMem(RET,(maxNotLines+4)*2); }
    FreeMem(Page,maxNotCh);      {//db1ras}
    FreeMem(RET,maxNotLines*2);  {//db1ras}
    QsoScroll := false;
    Cursor_aus;
    if HardCur then JumpRxScr := true;
    Neu_Bild;
  end;
  BackupBremsen:=false;
End;


Procedure FileScroll (* Kanal : Byte *);
var     KC        : Sondertaste;
        VC,
        Hch       : Char;
        Lines     : ^MbxTypPtr;
        A,X,Y,
        maxY,
        minY,
        Nx,
        Attr,
        XMerk,
        Spalte,
        AnzSp,
        Yofs      : Byte;
        maxL,
        Result    : Word;
        i,i1,
        Lpos,
        Fpos,
        MFpos,
        FSize,
        Zmax,
        MmaxL     : LongInt;
        HLstr     : MbxZeile;
        Bstr,
        Hstr      : String[80];
        Save_Name : String[60];
        SuchStr   : String[30];
        Ende,
        Found,
        update,
        RetFlag,
        New_Lines,
        CurObStat,
        UpScroll,
        Fail,
        VorEdit,
        First     : Boolean;
        BoxSave   : Text;


  Function  MakeStr(Zeile : MbxZeile; Art : Byte; var Col : Byte) : StrBox;
  var   Hstr : String[BoxRec];
  Begin
    move(Zeile,Hstr[1],BoxRec);
    Hstr[0] := Chr(BoxRec);
    Col := Ord(Hstr[81]);
    case Art of
      0 : Hstr[0] := Chr(80);
      1 : delete(Hstr,1,83);
      2 : Hstr := copy(Hstr,82,2);
    end;
    MakeStr := Hstr;
  End;

  Procedure DoPage(von,bis : Byte);
  var  i,i1 : LongInt;
       Hstr : String[80];
  begin
    i1 := Lpos - Y + von;
    for i := von to bis do
    begin
      Hstr := MakeStr(Lines^[i1],0,Attr);
      WriteRam(1,i+Yofs,Attr,1,Hstr);
      inc(i1);
    end;
  end;

  Procedure Updaten(Kanal : Byte);
  var  l : LongInt;
  Begin
    with K[Kanal]^ do
    begin
      Seek(DBox,MFpos);
      for l := 1 to MmaxL do BlockWrite(DBox,Lines^[l],1,Result);
      update := false;
    end;
  End;

  Procedure HoleLines(Kanal : Byte; Stelle : LongInt);
  var   l      : LongInt;
        Result : Word;
  Begin
    with K[Kanal]^ do
    begin
      if update then Updaten(Kanal);
      FillChar(Lines^,SizeOf(Lines^),0);
      l := 1;
      Seek(DBox,Stelle);
      While not Eof(DBox) and (l <= maxL) do
      begin
        BlockRead(DBox,Lines^[l],1,Result);
        inc(l);
      end;
      MFpos := Stelle;
      MmaxL := maxL;
    end;
  End;

  Procedure CursorDown(Kanal : Byte);
  Begin
    with K[Kanal]^ do
    begin
      if (Fpos + Lpos) < FSize then
      begin
        DoPage(Y,Y);
        if Lpos < maxL then inc(Lpos) else
        begin
          Fpos := Fpos + maxL - Zmax + 1;
          Lpos := Zmax;
          if Fpos + maxL > FSize then
          begin
            Lpos := maxL + Fpos + Zmax - FSize;
            Fpos := FSize - maxL;
          end;
          HoleLines(Kanal,Fpos);
        end;
        if Y < Zmax then inc(Y) else
        begin
          Scroll(Up,1,minY,maxY);
          DoPage(Y,Y);
        end;
      end else Alarm;
    end;
  End;

  Procedure CursorUp(Kanal : Byte);
  Begin
    with K[Kanal]^ do
    begin
      if (Fpos + Lpos > 1) then
      begin
        DoPage(Y,Y);
        if Lpos > 1 then dec(Lpos) else
        begin
          Fpos := Fpos - maxL + Zmax - 1;
          Lpos := maxL - Zmax + 1;
          if Fpos < 0 then
          begin
            Lpos := Fpos + 1 - Zmax + maxL;
            Fpos := 0;
          end;
          HoleLines(Kanal,Fpos);
        end;
        if Y > 1 then dec(Y) else
        begin
          Scroll(Dn,1,minY,maxY);
          DoPage(Y,Y);
        end;
      end else Alarm;
    end;
  End;

  Procedure MakeRead(Kanal,Art : Byte; var FFlag : Boolean);
  var   VwStr  : String[80];
        Nstr   : String[12];
        RubStr : String[12];
        Astr   : String[2];
        Typ,
        A,b    : Byte;

    Procedure MakeTransfer;
    Begin
      VwStr := TrStr + B1 + RubStr + B1 + Nstr + B1;
      if Typ in [1,14] then VwStr := VwStr + RSK + B1;
      WriteRam(1,Y+Yofs,Attrib[4],1,ConstStr(B1,80));
      GetString(VwStr,Attrib[4],60,2,Y+Yofs,KC,3,Ins);
      if KC <> _Esc then
      begin
        Lines^[Lpos][b] := RepCh;
        A := Attrib[19];
      end else FFlag := true;
    End;

  Begin
    with K[Kanal]^ do
    begin
      VwStr := '';
      FFlag := false;
      b := 80;
      Hstr := MakeStr(Lines^[Lpos],0,Attr);
      Astr := MakeStr(Lines^[Lpos],2,Attr);
      Typ := Ord(Astr[2]);

      case Typ of
        1: begin (* DBOX *)
             case Astr[1] of
              'C': begin  (* CHECK-Eintrag *)
                     RubStr := MakeStr(Lines^[Lpos],1,Attr);
                     KillEndBlanks(Rubstr);
                     Nstr := ParmStr(4,B1,Hstr);
                     if length(Nstr) > 8 then
                     begin
                       Nstr := copy(Nstr,9,4);
                       While copy(Nstr,1,1) = Pkt do delete(Nstr,1,1);
                     end else Nstr := ParmStr(1,B1,Hstr);

                     case Art of
                       0: begin  (* R ABC X *)
                            A := Attrib[19];
                            VwStr := ReadStr + B1 + RubStr + B1 + Nstr;
                            Lines^[Lpos][b] := ReadCh;
                          end;
                       1: begin (* E ABC X *)
                            A := Attrib[20];
                            VwStr := EraseStr + B1 + RubStr + B1 + Nstr;
                            Lines^[Lpos][b] := EraseCh;
                          end;
                       2: begin (* SETL ABC X #Y *)
                            A := Attrib[20];
                            VwStr := SetStr + B1 + RubStr + B1 + Nstr +
                                     B1 + LZ + int_str(G^.SETL[SETNr]);
                            Lines^[Lpos][b] := SetCh;
                          end;
                       7: begin  (* REP ABC X *)
                            A := Attrib[19];
                            VwStr := RepStr + B1 + RubStr + B1 + Nstr;
                            Lines^[Lpos][b] := RepCh;
                          end;
                      11: begin  (* TR ABC X > ... *)
                            MakeTransfer;
                          end;
                       else FFlag := true;
                     end;
                   end;
              'L': begin  (* LIST-Eintrag *)
                     RubStr := MakeStr(Lines^[Lpos],1,Attr);
                     KillEndBlanks(RubStr);
                     Nstr := ParmStr(1,B1,Hstr);
                     case Art of
                       0: begin  (* R ABC X *)
                            A := Attrib[19];
                            VwStr := ReadStr + B1 + RubStr + B1 + Nstr;
                            Lines^[Lpos][b] := ReadCh;
                          end;
                       1: begin  (* E ABC X *)
                            A := Attrib[20];
                            VwStr := EraseStr + B1 + RubStr + B1 + Nstr;
                            Lines^[Lpos][b] := EraseCh;
                          end;
                       2: begin  (* SETL ABC X #Y *)
                            A := Attrib[20];
                            VwStr := SetStr + B1 + RubStr + B1 + Nstr +
                                     B1 + LZ + int_str(G^.SETL[SETNr]);
                            Lines^[Lpos][b] := SetCh;
                          end;
                       7: begin  (* REP ABC X *)
                            A := Attrib[19];
                            VwStr := RepStr + B1 + RubStr + B1 + Nstr;
                            Lines^[Lpos][b] := RepCh;
                          end;
                      11: begin  (* TR ABC X > ... *)
                            MakeTransfer;
                          end;
                       else FFlag := true;
                     end;
                   end;
              'R': begin  (* EL-Eintr„ge, Dateien *)
                     case Art of
                       4 : VwStr := BinStr;  (* EL B *)
                       5 : VwStr := BsStr;   (* EL BS *)
                       6 : VwStr := PlusStr; (* EL 7 *)
                      else VwStr := Readstr; (* EL R *)
                     end;
                     A := Attrib[19];
                     VwStr := RunStr + B1 + ElStr + B1 + VwStr + B1 + ParmStr(1,B1,Hstr);
                     Lines^[Lpos][b] := ReadCh;
                   end;
              'V': begin  (* EL-Eintr„ge, Verzeichnisse *)
                     A := Attrib[19];
                     VwStr := RunStr + B1 + ElStr + B1 + DirStr + B1 + CutStr(Hstr); (* EL D *)
                     Lines^[Lpos][b] := ReadCh;
                   end;
              else FFlag := true;
             end;
           end;

        2: begin (* BBOX *)
             case Astr[1] of
              'C': begin  (* CHECK-Eintrag *)
                     RubStr := MakeStr(Lines^[Lpos],1,Attr);
                     KillEndBlanks(Rubstr);
                     Nstr := ParmStr(4,B1,Hstr);
                     if length(Nstr) > 8 then
                     begin
                       Nstr := copy(Nstr,9,4);
                       While copy(Nstr,1,1) = Pkt do delete(Nstr,1,1);
                     end else Nstr := ParmStr(1,B1,Hstr);

                     case Art of
                       0: begin  (* R ABC X *)
                            A := Attrib[19];
                            VwStr := ReadStr + B1 + RubStr + B1 + Nstr;
                            Lines^[Lpos][b] := ReadCh;
                          end;
                       1: begin (* E ABC X *)
                            A := Attrib[20];
                            VwStr := EraseStr + B1 + RubStr + B1 + Nstr;
                            Lines^[Lpos][b] := EraseCh;
                          end;
                       2: begin (* SETL ABC X #Y *)
                            A := Attrib[20];
                            VwStr := SetStr + B1 + RubStr + B1 + Nstr +
                                     B1 + LZ + int_str(G^.SETL[SETNr]);
                            Lines^[Lpos][b] := SetCh;
                          end;
                       7: begin  (* REP ABC X *)
                            A := Attrib[19];
                            VwStr := RepStr + B1 + RubStr + B1 + Nstr;
                            Lines^[Lpos][b] := RepCh;
                          end;
                       9: begin  (* K ABC X *)
                            A := Attrib[19];
                            VwStr := KbStr + B1 + RubStr + B1 + Nstr;
                            Lines^[Lpos][b] := KbCh;
                          end;
                      11: begin  (* TR ABC X ... *)
                            MakeTransfer;
                          end;
                       else FFlag := true;
                     end;
                   end;
              'L': begin  (* LIST-Eintrag *)
                     RubStr := MakeStr(Lines^[Lpos],1,Attr);
                     KillEndBlanks(RubStr);
                     Nstr := ParmStr(1,B1,Hstr);
                     case Art of
                       0: begin  (* R ABC X *)
                            A := Attrib[19];
                            VwStr := ReadStr + B1 + RubStr + B1 + Nstr;
                            Lines^[Lpos][b] := ReadCh;
                          end;
                       1: begin  (* E ABC X *)
                            A := Attrib[20];
                            VwStr := EraseStr + B1 + RubStr + B1 + Nstr;
                            Lines^[Lpos][b] := EraseCh;
                          end;
                       2: begin  (* SETL ABC X #Y *)
                            A := Attrib[20];
                            VwStr := SetStr + B1 + RubStr + B1 + Nstr +
                                     B1 + LZ + int_str(G^.SETL[SETNr]);
                            Lines^[Lpos][b] := SetCh;
                          end;
                       7: begin  (* REP ABC X *)
                            A := Attrib[19];
                            VwStr := RepStr + B1 + RubStr + B1 + Nstr;
                            Lines^[Lpos][b] := RepCh;
                          end;
                       9: begin  (* K ABC X *)
                            A := Attrib[19];
                            VwStr := KbStr + B1 + RubStr + B1 + Nstr;
                            Lines^[Lpos][b] := KbCh;
                          end;
                      11: begin  (* TR ABC X ... *)
                            MakeTransfer;
                          end;
                       else FFlag := true;
                     end;
                   end;
              'R': begin  (* EL-Eintr„ge, Dateien *)
                     case Art of
                       4 : VwStr := BinStr;  (* EL B *)
                       5 : VwStr := BsStr;   (* EL BS *)
                       6 : VwStr := PlusStr; (* EL 7 *)
                      else VwStr := Readstr; (* EL R *)
                     end;
                     A := Attrib[19];
                     VwStr := ElStr + B1 + VwStr + B1 + ParmStr(1,B1,Hstr);
                     Lines^[Lpos][b] := ReadCh;
                   end;
              'V': begin  (* EL-Eintr„ge, Verzeichnisse *)
                     A := Attrib[19];
                     VwStr := ElStr + B1 + DirStr + B1 + CutStr(Hstr); (* EL D *)
                     Lines^[Lpos][b] := ReadCh;
                   end;
              else FFlag := true;
             end;
           end;

        3: begin (* FBOX *)
             case Astr[1] of
              'C': begin  (* CHECK-Eintrag *)
                     KillStartBlanks(Hstr);
                     Nstr := CutStr(Hstr);
                     case Art of
                       0: begin  (* R XXX *)
                            A := Attrib[19];
                            VwStr := ReadStr + B1 + Nstr;
                            Lines^[Lpos][b] := ReadCh;
                          end;
                       1: begin (* E XXX *)
                            A := Attrib[20];
                            VwStr := EraseStr + B1 + Nstr;
                            Lines^[Lpos][b] := EraseCh;
                          end;
                       else FFlag := true;
                     end; {art}
                   end; {C}
              end;  {case astr}
           end; {3}

        4: begin (* WBOX *)
             case Astr[1] of
              'C': begin  (* CHECK-Eintrag *)
                     KillStartBlanks(Hstr);
                     Nstr := CutStr(Hstr);
                     case Art of
                       0: begin  (* R XXX *)
                            A := Attrib[19];
                            VwStr := ReadStr + B1 + Nstr;
                            Lines^[Lpos][b] := ReadCh;
                          end;
                       1: begin (* E XXX *)
                            A := Attrib[20];
                            VwStr := EraseStr + B1 + Nstr;
                            Lines^[Lpos][b] := EraseCh;
                          end;
                       else FFlag := true;
                     end;
                   end;
              else FFlag := true;
             end;
           end;

        5: begin (* EBOX *)
             case Astr[1] of
              'L': begin  (* LIST-Eintrag *)
                     KillStartBlanks(Hstr);
                     Nstr := CutStr(Hstr);
                     case Art of
                       0: begin (* R XXX *)  (* RB XXX *)
                            A := Attrib[19];
                            if UpCaseStr(ParmStr(8,B1,Hstr)) = 'D'
                             then VwStr := RBinStr + B1 + Nstr
                             else VwStr := ReadStr + B1 + Nstr;
                            Lines^[Lpos][b] := ReadCh;
                          end;
                       1: begin   (* K XXX *)
                            A := Attrib[20];
                            VwStr := KillStr + B1 + Nstr;
                            Lines^[Lpos][b] := EraseCh;
                          end;
                       8: begin   (* U XXX *)
                            A := Attrib[19];
                            VwStr := UnprStr + B1 + Nstr;
                            Lines^[Lpos][b] := ReadCh;
                          end;
                      10: begin   (* CRC XXX *)
                            A := Attrib[19];
                            VwStr := CrcStr + B1 + Nstr;
                            Lines^[Lpos][b] := ReadCh;
                          end;
                       else FFlag := true;
                     end;
                   end;
              else FFlag := true;
             end;
           end;

       14: begin (* TBOX *)
             case Astr[1] of
              'C': begin  (* CHECK-Eintrag *)
                     RubStr := MakeStr(Lines^[Lpos],1,Attr);
                     KillEndBlanks(Rubstr);
                     Nstr := ParmStr(4,B1,Hstr);
                     if length(Nstr) > 8 then
                     begin
                       Nstr := copy(Nstr,9,4);
                       While copy(Nstr,1,1) = Pkt do delete(Nstr,1,1);
                     end else Nstr := ParmStr(1,B1,Hstr);

                     case Art of
                       0: begin  (* R ABC X *)
                            A := Attrib[19];
                            VwStr := ReadStr + B1 + RubStr + B1 + Nstr;
                            Lines^[Lpos][b] := ReadCh;
                          end;
                       1: begin (* E ABC X *)
                            A := Attrib[20];
                            VwStr := EraseStr + B1 + RubStr + B1 + Nstr;
                            Lines^[Lpos][b] := EraseCh;
                          end;
                       2: begin (* SETL ABC X #Y *)
                            A := Attrib[20];
                            VwStr := SetStr + B1 + RubStr + B1 + Nstr +
                                     B1 + LZ + int_str(G^.SETL[SETNr]);
                            Lines^[Lpos][b] := SetCh;
                          end;
                       7: begin  (* REP ABC X *)
                            A := Attrib[19];
                            VwStr := RepStr + B1 + RubStr + B1 + Nstr;
                            Lines^[Lpos][b] := RepCh;
                          end;
                      11: begin  (* TR ABC X > ... *)
                            MakeTransfer;
                          end;
                       else FFlag := true;
                     end;
                   end;
              'L': begin  (* LIST-Eintrag *)
                     RubStr := MakeStr(Lines^[Lpos],1,Attr);
                     KillEndBlanks(RubStr);
                     Nstr := ParmStr(1,B1,Hstr);
                     case Art of
                       0: begin  (* R ABC X *)
                            A := Attrib[19];
                            VwStr := ReadStr + B1 + RubStr + B1 + Nstr;
                            Lines^[Lpos][b] := ReadCh;
                          end;
                       1: begin  (* E ABC X *)
                            A := Attrib[20];
                            VwStr := EraseStr + B1 + RubStr + B1 + Nstr;
                            Lines^[Lpos][b] := EraseCh;
                          end;
                       2: begin (* SETL ABC X #Y *)
                            A := Attrib[20];
                            VwStr := SetStr + B1 + RubStr + B1 + Nstr +
                                     B1 + LZ + int_str(G^.SETL[SETNr]);
                            Lines^[Lpos][b] := SetCh;
                          end;
                       7: begin  (* REP ABC X *)
                            A := Attrib[19];
                            VwStr := RepStr + B1 + RubStr + B1 + Nstr;
                            Lines^[Lpos][b] := RepCh;
                          end;
                      11: begin  (* TR ABC X > ... *)
                            MakeTransfer;
                          end;
                       else FFlag := true;
                     end;
                   end;
              else FFlag := true;
             end;
           end;
        else FFlag := true;
      end;

      if not FFlag then
      begin
        if not RetFlag then Chr_Vor_Show(Kanal,_Alt8,#255)
                       else Chr_Vor_Show(Kanal,_Andere,^J);
        VorWrite[Kanal]^[stV] := VwStr;
        update := true;
        Lines^[Lpos][81] := Chr(A);
        Chr_Vor_Show(Kanal,_End,#255);
        RetFlag := true;
        DoPage(1,Zmax);
      end;
    end;
  End;

  Function NoHeader(Zeile : MbxZeile) : Boolean;
  var  Attr : Byte;
  Begin
    NoHeader := pos('ù ',MakeStr(Zeile,0,Attr)) <> 1;
  End;


Begin
BackupBremsen:=true;
  with K[Kanal]^ do
  begin
    Neu_Bild;
    if not ChkLstOpen then OpenDBox(Kanal);
    BoxScroll := true;
    if Vor_im_EMS then EMS_Seite_einblenden(Kanal,Vor);
    if Braille80 then X := 80 else X := 1;
    Y := 1;
    Ende := false;
    VorEdit := false;
    Nx := (NrStat[2]-1) * 20 + 1;
    Fpos := 0;
    Lpos := 1;
    SuchStr := '';
    CurObStat := false;
    First := true;
    New_Lines := false;
    update := false;
    RetFlag := false;
    UpScroll := false;
    Yofs := QBeg - 1;
    minY := QBeg;
    maxY := QEnd;
    Zmax := QEnd - QBeg + 1;
    Teil_Bild_Loesch(minY,maxY,Attrib[18]);
    KC := _CtrlPgDn;
    VC := #255;

    Repeat
      if not First then
      begin
        Repeat
          if TimerTick > PollTime then
          begin
            New_Lines := false;
            Uhr_aus;
            TNCs_Pollen;
            if (FSize <= (QEnd - QBeg + 5)) and (NewChkLst > 0) then New_Lines := true;
          end;
        Until New_Lines or _KeyPressed;
        if not New_Lines then _ReadKey(KC,VC);
      end;
      PollTime := TimerTick + KeyDelay;

      Fail := false;

      if FSize <= maxMbxLines then maxL := FSize
                              else maxL := maxMbxLines;
      if FSize <= Zmax then Zmax := FSize
                       else Zmax := QEnd - Yofs;
      if maxL <= Zmax then Zmax := maxL;
      maxY := Zmax + Yofs;

      if First then
      begin
        GetMem(Lines,SizeOf(Lines^));
        FillChar(Lines^,SizeOf(Lines^),0);
        if FSize = 0 then
        begin
          First := false;
          HoleLines(Kanal,0);
          DoPage(1,Zmax);
        end;
      end;

      if New_Lines then
      begin
        New_Lines := false;
        KC := _Tab;
      end;

      if NewChkLst > 0 then
      begin
        HoleLines(Kanal,Fpos);
        NewChkLst := 0;
      end;

      if VorEdit then
      begin
        if KC in [_Esc,_PgUp,_Alt0,_F11] then
        begin
          VorEdit := false;
          DoPage(Y,Y);
        end else
        if KC in [_AltA.._AltY,_AltZ,_Home,_ShIns, _ShTab,_End,_Ins.._Ret,_Back,_Nix]
         then Key_Active(Kanal,KC,VC)
         else Alarm;
      end else
      case KC of
      _Andere : begin
                  if UpCase(VC) in [' ','K','L','R','D','B','S','T','7','C','U'] then
                  begin
                    if NoHeader(Lines^[Lpos]) then
                    case UpCase(VC) of
                      ' ' : MakeRead(Kanal,0,Fail);  (* R... 123 *)

                      'T' : MakeRead(Kanal,11,Fail); (* TR IBM 123 *)

                      'K' : MakeRead(Kanal,9,Fail);  (* K IBM 123 *)
                      'L' : MakeRead(Kanal,2,Fail);  (* SETL IBM 123 *)
                      'R' : MakeRead(Kanal,7,Fail);  (* REP IBM 123 *)

                      'D' : MakeRead(Kanal,3,Fail);  (* EL D *)
                      'B' : MakeRead(Kanal,4,Fail);  (* EL B *)
                      'S' : MakeRead(Kanal,5,Fail);  (* EL BS *)
                      '7' : MakeRead(Kanal,6,Fail);  (* EL 7 *)

                      'C' : MakeRead(Kanal,10,Fail); (* CRC 12345 *)
                      'U' : MakeRead(Kanal,8,Fail);  (* U 12345 *)
                    end else Fail := true;

                    if not Fail then
                    begin
                      if UpScroll then CursorUp(Kanal)
                                  else CursorDown(Kanal);
                    end else
                    begin
                      Alarm;
                      DoPage(Y,Y);
                    end;
                  end else if (VC = ^Y) then
                  begin
                    FillChar(Lines^[Lpos],79,B1);
                    update := true;
                    DoPage(Y,Y);
                  end else Alarm;
                end;

        _Back : begin
                  UpScroll := not UpScroll;
                  if UpScroll
                  then WriteRam(1,Y+Yofs,Attrib[4],1,EFillStr(80,B1,ConstStr(B1,20) + InfoZeile(87)))
                  else WriteRam(1,Y+Yofs,Attrib[4],1,EFillStr(80,B1,ConstStr(B1,20) + InfoZeile(88)));
                  Verzoegern(700);
                  DoPage(Y,Y);
                end;

        _Del,
        _Esc  : Ende := true;

        _Tab  : begin
                  HoleLines(Kanal,Fpos);
                  DoPage(1,Zmax);
                end;

        _Ret  : begin
                  if not RetFlag then
                  begin
                    if NoHeader(Lines^[Lpos]) then
                    begin
                      MakeRead(Kanal,0,Fail);
                      if Fail then Alarm;
                    end else Alarm;
                  end;
                  if RetFlag then
                  begin
                    Chr_Vor_Show(Kanal,_Ret,#13);
                    RetFlag := false;
                  end;
                end;

        _F11,
        _Alt1..
        _Alt5 : begin
                  if KC = _F11 then
                  begin
                    KC := _Alt4;
                    VC := #123;
                  end;
                  if update then Updaten(Kanal);
                  Hstr := MakeStr(Lines^[Lpos],2,Attr);
                  Hch := Hstr[1];
                  if Hch in ['L','C'] then
                  begin
                    WriteRam(1,Y+Yofs,Attrib[4],1,EFillStr(80,B1,ConstStr(B1,20) + InfoZeile(39)));
                    Hstr := MakeStr(Lines^[Lpos],0,Attr);

                    A := ord(VC) - 119;

                    Bstr := ParmStr(A,B1,Hstr);
                    if A = 1 then Spalte := 1
                             else Spalte := ParmPos;
                    Bstr := ParmStr(A+1,B1,Hstr);
                    AnzSp := Byte(ParmPos - Spalte);

                    FreeMem(Lines,SizeOf(Lines^));
                    CheckSort(Kanal,Spalte,AnzSp,Fpos + Lpos - 1,Hch);
                    GetMem(Lines,SizeOf(Lines^));
                    HoleLines(Kanal,Fpos);
                    DoPage(1,Zmax);
                  end else Alarm;
                end;

         _Ins : begin
                  VorEdit := true;
                  WriteRam(1,Y+Yofs,Attrib[4],1,ConstStr(#24,80));
                  Chr_Vor_Show(Kanal,_Nix,#255);
                end;

        _AltC : begin
                  Hstr := MakeStr(Lines^[Lpos],0,Attr);
                  KillEndBlanks(Hstr);
                  VorWrite[Kanal]^[stV] := Hstr;
                  Chr_Vor_Show(Kanal,_End,#255);
                  Chr_Vor_Show(Kanal,_Alt7,#255);
                  if UpScroll then CursorUp(Kanal)
                              else CursorDown(Kanal);
                end;

        _AltE : if NoHeader(Lines^[Lpos]) then
                begin
                  MakeRead(Kanal,1,Fail);
                  if not Fail then
                  begin
                    if UpScroll then CursorUp(Kanal)
                                else CursorDown(Kanal);
                  end else Alarm;
                end else Alarm;

        _AltH : XP_Help(G^.OHelp[29]);

        _AltF,
        _AltN : begin
                  if (KC = _AltF) or ((KC = _AltN) and (SuchStr = '')) then
                  begin
                    WriteRam(1,Y+Yofs,Attrib[4],1,EFillStr(80,B1,InfoZeile(7)));
                    GetString(Suchstr,Attrib[4],30,45,Y+Yofs,KC,0,Ins);
                  end;
                  if (KC <> _Esc) and (SuchStr > '') then
                  begin
                    Suchstr:=UpcaseStr(Suchstr);
                    Found := false;
                    Seek(DBox,Fpos + Lpos);
                    While not Found and not Eof(DBox) do
                    begin
                      BlockRead(DBox,HLstr,1,Result);
                      Hstr := UpCaseStr(MakeStr(HLstr,0,Attr));
                      Found := pos(SuchStr,Hstr) > 0;
                    end;
                    if Found then
                    begin
                      Fpos := FilePos(DBox) - Lpos;
                      if Fpos + maxL > FSize then
                      begin
                        Lpos := FilePos(DBox) + maxL - FSize;
                        Fpos := FSize - maxL;
                      end;
                      HoleLines(Kanal,Fpos);
                      if Lpos + Zmax - Y > maxL then Y := Lpos + Zmax - maxL;
                      DoPage(1,Zmax);
                    end else
                    begin
                      Seek(DBox,Fpos);
                      Alarm;
                    end;
                  end;
                  DoPage(Y,Y);
                end;

        _AltP : begin
                  if (LPT_vorhanden and (not LPT_Error(PrtPort))) then
                  begin
                    Seek(DBox,Fpos + Lpos - 1);
                    While not Eof(DBox) do
                    begin
                      BlockRead(DBox,HLstr,1,Result);
                      Hstr := MakeStr(HLstr,0,Attr);
                      KillEndBlanks(Hstr);
                      Write_Drucker(Kanal,Hstr +M1);
                    end;
                    Seek(DBox,Fpos);
                  end else
                  begin
                    WriteRam(1,Y+Yofs,Attrib[4],1,EFillStr(80,B1,InfoZeile(290)));
                    Alarm;
                    Verzoegern(ZWEI);
                  end;
                  DoPage(Y,Y);
                end;

        _AltS : begin
                  WriteRam(1,Y+Yofs,Attrib[4],1,EFillStr(80,B1,B1+InfoZeile(142)+B1));
                  Save_Name := Konfig.SavVerz + 'BOX'+ int_str(Kanal) + '.TXT';
                  GetString(Save_Name,Attrib[4],60,9,Y+Yofs,KC,1,Ins);
                  if KC <> _Esc then
                  begin
                    Assign(BoxSave,Save_Name);
                    Result := AppendTxt(BoxSave);
                    if Result <> 0 then Result := RewriteTxt(BoxSave);
                    if Result = 0 then
                    begin
                      Seek(DBox,Fpos + Lpos - 1);
                      While not Eof(DBox) do
                      begin
                        BlockRead(DBox,HLstr,1,Result);
                        Hstr := MakeStr(HLstr,0,Attr);
                        KillEndBlanks(Hstr);
                        Writeln(BoxSave,Hstr);
                      end;
                      FiResult := CloseTxt(BoxSave);
                      Seek(DBox,Fpos);
                    end else
                    begin
                      WriteRam(1,Y+Yofs,Attrib[4],1,EFillStr(80,B1,B1 +
                                        InfoZeile(75) + DP + B2 + Save_Name));
                      Alarm;
                      Verzoegern(ZWEI);
                    end;
                  end;
                  DoPage(Y,Y);
                end;

       _AltF1.._AltF10
              : SETNr := Ord(VC) - 103;

      _CtrlF1 : if G^.SETL[SETNr] > 0 then dec(G^.SETL[SETNr])
                                      else Alarm;

      _CtrlF2 : if G^.SETL[SETNr] < 365 then inc(G^.SETL[SETNr])
                                        else Alarm;

       _Right : if X < 80 then inc(X) else Alarm;

        _Left : if X > 1 then dec(X) else Alarm;

          _Up : CursorUp(Kanal);

          _Dn : CursorDown(Kanal);

        _PgUp : if (Y > 1) or (Fpos + Lpos > 1) then
                begin
                  Lpos := Lpos - Zmax + 1;

                  if Lpos - Y + 1 < 1 then
                  begin
                    Fpos := Fpos - maxL + Lpos + Zmax - Y;
                    Lpos := maxL - Zmax + Y;
                    if Fpos < 0 then
                    begin
                      Lpos := Lpos + Fpos;
                      Fpos := 0;
                    end;
                    HoleLines(Kanal,Fpos);
                  end;

                  if Lpos - Y + 1 < 1 then
                  begin
                    Lpos := 1;
                    Y := 1;
                  end;

                  DoPage(1,Zmax);
                end else Alarm;

        _PgDn : if (Y < Zmax) or (Fpos + Lpos < FSize) then
                begin
                  Lpos := Lpos + Zmax - 1;

                  if Lpos + Zmax - Y > maxL then
                  begin
                    Fpos := Fpos + Lpos - Y;
                    Lpos := Y;
                    if Fpos + maxL > FSize then
                    begin
                      Lpos := Fpos + maxL - FSize + Y;
                      Fpos := FSize - maxL;
                    end;
                    HoleLines(Kanal,Fpos);
                  end;

                  if Lpos + Zmax - Y > maxL then
                  begin
                    Lpos := maxL;
                    Y := Zmax;
                  end;
                  DoPage(1,Zmax);
                end else Alarm;

    _CtrlPgUp : if (Y > 1) or (Fpos + Lpos > 1) then
                begin
                  Fpos := 0;
                  Lpos := 1;
                  Y := 1;
                  HoleLines(Kanal,Fpos);
                  DoPage(1,Zmax);
                end else Alarm;

    _CtrlPgDn : if (Y < Zmax) or (Fpos + Lpos < FSize) or First then
                begin
                  First := false;
                  Fpos := FSize - maxL;
                  Lpos := maxL;
                  Y := Zmax;
                  HoleLines(Kanal,Fpos);
                  DoPage(1,Zmax);
                end else Alarm;

        _Home : begin
                  Fpos := BoxZlnMerk;
                  Lpos := 1;
                  Y := 1;
                  if Fpos + maxL > FSize then
                  begin
                    Lpos := Fpos + maxL - FSize + Y;
                    Fpos := FSize - maxL;
                  end;
                  if Lpos + Zmax - Y > maxL then Y := Lpos + Zmax - maxL;
                  HoleLines(Kanal,Fpos);
                  DoPage(1,Zmax);
                end;

        _End  : BoxZlnMerk := Fpos + Lpos - 1;

    _CtrlHome : begin
                  DoPage(Y,Y);
                  Lpos := Lpos - Y + 1;
                  Y := 1;
                end;

     _CtrlEnd : begin
                  DoPage(Y,Y);
                  Lpos := Lpos + Zmax - Y;
                  Y := Zmax;
                end;

       _ShTab : begin
                  CurObStat := not CurObStat;
                  if CurObStat then
                  begin
                    Xmerk := X;
                    X := ((NrStat[2]-1)*20)+1
                  end else X := XMerk;
                end;

       _ShDel : begin
                if (fpos+lpos-1 > 0) then
                 begin
                  Fpos := 0;
                  Lpos := 1;
                  Y := 1;
                  Seek(DBox,0);
                  Truncate(DBox);
                  FSize := 0;
                  BoxZlnMerk := 0;
                  FillChar(Lines^,SizeOf(Lines^),0);
                  Teil_Bild_Loesch(minY,maxY,Attrib[18]);
                 end;
                end;

         _Nix : ;

           else Alarm;
      end;

      WriteAttr(1,Y+Yofs,80,Attrib[4],1);
      if HardCur and not VorEdit then
      begin
        if CurObStat then SetzeCursor(X,ObStat+2)
                     else SetzeCursor(X,Y+Yofs);
      end;
      Hstr := MakeStr(Lines^[Lpos],1,Attr);
      KillEndBlanks(Hstr);
              {Nx+1}
      WriteRam(61,ObStat+2,Attrib[9],1,
       EFillStr(19,B1,EFillStr(9,B1,Hstr) +
                       SFillStr(5,B1,int_str(Fpos+Lpos)) +
                       SFillStr(4,B1,int_str(G^.SETL[SETNr])) ));
    Until Ende;

    if update then Updaten(Kanal);
    if not (SysArt in SysMenge) then CloseDBox(Kanal);
    FreeMem(Lines,SizeOf(Lines^));
    BoxScroll := false;
    Neu_Bild;
  end;
backupBremsen:=false;
End; {FileScroll}

Procedure CheckSort (* Kanal,Spalte,AnzSp : Byte; Dpos : LongInt; SC : Char *);
Const  maxSLines = 3000;

Type   LinePtr  = Array [1..maxSLines] of ^MbxZeile;

var    SFeld  : ^LinePtr;
       Mpos,
       Bpos,
       Epos   : LongInt;
       Hstr   : String[BoxRec];
       Hs     : MbxZeile;
       RFlag,
       bigger : Boolean;
       SC_Pos : Byte;
       maxS,
       i,Zx,
       Result : Word;
       Temp1,
       Temp2  : File;

  Procedure DBox_in_Buffer(Kanal : Byte);
  begin
    with K[Kanal]^ do
    begin
      Zx := 0;
      While (Zx < maxS) and (FilePos(DBox) <= Epos) do
      begin
        inc(Zx);
        BlockRead(DBox,SFeld^[Zx]^,1,Result);
      end;
      bigger := FilePos(DBox) <= Epos;
    end;
  end;

  Procedure SortBuffer(N : Word);
  Var  x,i,j  : Integer;
       Change : Boolean;
       CPtr   : Pointer;
  Begin
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
            if copy(SFeld^[j]^,Spalte,AnzSp) >
               copy(SFeld^[j+x]^,Spalte,AnzSp) then
            begin
              CPtr := SFeld^[j+x];
              SFeld^[j+x] := SFeld^[j];
              SFeld^[j] := CPtr;
              j := j - x;
            end else Change := false;
          end;
          i := i + 1;
        end;
        x := x div 3;
      end;
    end;
  End;

Begin
  with K[Kanal]^ do
  begin
    SC_Pos := 82;
    Mpos := Dpos;
    Seek(DBox,Mpos);
    Repeat
      BlockRead(DBox,Hstr[1],1,Result);
      if Hstr[SC_Pos] = SC then inc(Mpos);
    Until Eof(DBox) or (Hstr[SC_Pos] <> SC);

    if Mpos > Dpos then
    begin
      dec(Mpos);
      Epos := Mpos;
      Repeat
        Seek(DBox,Mpos);
        BlockRead(DBox,Hstr[1],1,Result);
        if Hstr[SC_Pos] = SC then dec(Mpos);
      Until (Mpos < 0) or (Hstr[SC_Pos] <> SC);
      Bpos := Mpos + 1;

      maxS := 0;
      GetMem(SFeld,SizeOf(SFeld^));
      While (MaxAvail > 1000) and (maxS < maxSLines) do
      begin
        inc(maxS);
        GetMem(SFeld^[maxS],SizeOf(MbxZeile));
        FillChar(SFeld^[maxS]^,SizeOf(MbxZeile),0);
      end;

      Seek(DBox,Bpos);
      DBox_in_Buffer(Kanal);
      SortBuffer(Zx);

      if bigger then
      begin
        Assign(Temp1,Konfig.TempVErz + Tmp1Datei);
        FiResult := RewriteBin(Temp1,BoxRec);
        Assign(Temp2, Konfig.TempVerz + Tmp2Datei);
        FiResult := RewriteBin(Temp2,BoxRec);

        for i := 1 to Zx do BlockWrite(Temp1,SFeld^[i]^,1,Result);

        Repeat
          DBox_in_Buffer(Kanal);
          SortBuffer(Zx);
          i := 1;
          Seek(Temp1,0);
          if not Eof(Temp1) then
          begin
            BlockRead(Temp1,Hs,1,Result);
            RFlag := true;
          end else RFlag := false;

          Repeat
            if (not Eof(Temp1) or RFlag) and (i <= Zx) then
            begin
              if copy(SFeld^[i]^,Spalte,AnzSp) < copy(Hs,Spalte,AnzSp) then
              begin
                BlockWrite(Temp2,SFeld^[i]^,1,Result);
                inc(i);
              end else
              begin
                BlockWrite(Temp2,Hs,1,Result);
                if not Eof(Temp1) then
                begin
                  BlockRead(Temp1,Hs,1,Result);
                  RFlag := true;
                end else RFlag := false;
              end;
            end;

            if not RFlag and Eof(Temp1) then
            begin
              While i <= Zx do
              begin
                BlockWrite(Temp2,SFeld^[i]^,1,Result);
                inc(i);
              end;
            end;

            if i > Zx then
            begin
              if RFlag then BlockWrite(Temp2,Hs,1,Result);
              While not Eof(Temp1) do
              begin
                BlockRead(Temp1,Hs,1,Result);
                BlockWrite(Temp2,Hs,1,Result);
              end;
            end else
          Until Eof(Temp1) and (i > Zx);

          if bigger then
          begin
            FiResult := CloseBin(Temp1);
            FiResult := EraseBin(Temp1);

            FiResult := CloseBin(Temp2);
            Rename(Temp2,Konfig.TempVerz + Tmp1Datei);

            Assign(Temp1, Konfig.TempVerz + Tmp1Datei);
            FiResult := ResetBin(Temp1,BoxRec);

            Assign(Temp2, Konfig.TempVerz + Tmp2Datei);
            FiResult := RewriteBin(Temp2,BoxRec);
          end;
        Until not bigger;

        Seek(DBox,Bpos);
        Seek(Temp2,0);
        While not Eof(Temp2) do
        begin
          BlockRead(Temp2,Hs,1,Result);
          BlockWrite(DBox,Hs,1,Result);
        end;

        FiResult := CloseBin(Temp1);
        FiResult := CloseBin(Temp2);
        FiResult := EraseBin(Temp1);
        FiResult := EraseBin(Temp2);
      end else
      begin
        Seek(DBox,Bpos);
        for i := 1 to Zx do BlockWrite(DBox,SFeld^[i]^,1,Result);
      end;
      for i := 1 to maxS do FreeMem(SFeld^[i],SizeOf(MbxZeile));
      FreeMem(SFeld,SizeOf(SFeld^));
    end;
  end;
End;


Procedure OpenDBox (* Kanal : Byte *);
Begin
  with K[Kanal]^ do
  begin
    if not ChkLstOpen then
    begin
      if ResetBin(DBox,BoxRec) > 0 then FiResult := RewriteBin(DBox,BoxRec);
      FSize := FileSize(DBox);
      ChkLstOpen := true;
    end;
  end;
End;

Procedure CloseDBox(Kanal : Byte);
Var  Result : Word;
Begin
  with K[Kanal]^ do
  begin
    if ChkLstOpen then
    begin
      FiResult := CloseBin(DBox);
      ChkLstOpen := false;
    end;
  end;
End;
