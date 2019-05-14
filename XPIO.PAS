{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P I O .  P A S                                                       ³
 ³                                                                         ³
 ³ Verschiedene Routinen zum Ansprechen des TNC                            ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}
{** MailPolling: MZAR! suchen!}
{**** FšR Reconnect-Geschichte nach *RECONNECT suchen
      Fr Verschlsseln: *VERSCH}
(*   Eine HOSTMODE-Zeile an den TNC senden
     Format:   SendTNC(KanalNummer,Art(0=Text,1=Kommando),String)     *)
(* TNN!!! suchen fr TNN-Connect-Erweiterung *)

Procedure SendTNC (* Var Kanal : Byt; ,Art : Byte; Zeile : String) *);
var   Laenge  : char;
      Channel : char;
      V24Nr   : Byte;
      ch      : Char;
Begin
  if Pseudo then
  begin
    Channel := chr(Kanal);
    Kanal := 0;
  end else Channel := K[Kanal]^.TNCKanal;

  V24Nr := V24(Kanal);

  ClearV24Buffer;
  FillChar(K[Kanal]^.Response,SizeOf(K[Kanal]^.Response),0);

  if TNC[K[Kanal]^.TncNummer]^.TNC_im_Host then
  begin
    Laenge := chr(length(Zeile)-1);
    Switch_TNC(K[Kanal]^.TncNummer);
    IRQsLock;
    WriteAux(V24Nr,Channel + chr(Art) + Laenge);
    WriteAux(V24Nr,Zeile);
  end;
End;

Procedure TNCs_Pollen;
Begin
  if not TNC_Halt then
  begin
    inc(Poll);
    if Poll > TNC[PollTNr]^.Kbis then
    begin
      inc(PollTNr);
      if not TNC_used[PollTNr] then PollTNr := 1;
      Poll := TNC[PollTNr]^.Kvon;
      K[0]^.TncNummer := PollTNr;
      Kanal_Pollen(0);
    end;
    if Poll > 0 then with K[Poll]^ do
    begin
      if (C_Poll or Test or Ext_Poll or Kanal_benutz or not TNC_ReadOut) or
         (not TNC[TncNummer]^.ExtHost and (Pause = PollRate)) then Kanal_Pollen(Poll);
      inc(Pause);
      if Pause > PollRate then Pause := 0;
    end;
  end;
End;

Procedure Kanal_Pollen (* Kanal : Byte *);
Var  i,i1    : Byte;
     VC      : Char;
     Puffer  : Word;
     SFrame  : Byte;

Begin
  with K[Kanal]^ do
  Begin
    if (Kanal = 0) and TNC[TncNummer]^.ExtHost then
    begin
      Pseudo := true;
      Ausgabe := false;
      TxRxTNC(FF,1,'G');
      if Idle and (Response > '') then
      begin
        Idle_TCount := Idle_Tout;
        Idle_TMerk := TimerTick;
      end;
      for i := 1 to Ord(Response[0]) do
      begin
        VC := Chr(Byte(Ord(Response[i])-1));
        for i1 := TNC[TncNummer]^.Kvon to TNC[TncNummer]^.Kbis do
         if K[i1]^.TNCKanal = VC then K[i1]^.Ext_Poll := true;
      end;
    end;
    Ext_Poll := false;

    Get_Linkstatus(Kanal);

    if Kanal = 0 then
    begin
      Puffer := FreiePuffer(Kanal);
      for i1 := TNC[TncNummer]^.Kvon to TNC[TncNummer]^.Kbis do
          K[i1]^.BufToLow := Puffer < maxTncBuf;

      if (not K[show]^.BufExists or Test) and
         (((show = 0) and (Unproto = TncNummer)) or
          ((show > 0) and (TncNummer = K[show]^.TncNummer))) then
           begin
           { if Not OnlHelp then} StatusOut(show,73,1,Attrib[9],SFillStr(6,B1,'('+int_str(Puffer)+')'),2);
           end;
    end;

    if not TNC_ReadOut then
    begin
      While L_Status[1] + L_Status[2] > 0 do
      begin
        S_PAC(Kanal,CM,true,'G');
        Get_Linkstatus(Kanal);
      end;
    end else
    begin
      TncNix := false;
      Repeat
        S_PAC(Kanal,CM,true,'G');
      Until (not MonCode5 and _KeyPressed) or TncNix;
    end;

    if BufExists and (Kanal > 0) then
    begin
      if Test then SendTestBuffer(Kanal) else
      begin
        SFrame := L_Status[3];
        While BufExists and not _KeyPressed and
              ((MaxFrame > SFrame) or
               (TNC_Puffer and (FreiePuffer(Kanal) > minTncBuf))) do
        begin
          SendBuffer(Kanal);
          inc(SFrame);
        end;
      end;
    end;

    if XBin.TX and not FileSendWait then
     begin
      SFrame := L_Status[3];
        While (not FileSendWait) and (not _KeyPressed) and
              (MaxFrame > SFrame) do
        begin
          xbinSend(Kanal,true);
          inc(SFrame);
        end;
     end;

    if (FileSend) and (not FileSendWait) and (not Xbin.an) then
    Begin
      if not BufExists and TNC_Puffer and (TX_Bin <> 2) then
      Repeat
        Puffer := FreiePuffer(Kanal);
        if (Puffer > minTncBuf) then if FileSend then Send_File(Kanal,true);
      Until (Puffer <= minTncBuf) or _KeyPressed or not FileSend
      else begin
        SFrame := L_Status[3];
        While FileSend and not _KeyPressed and
              (Upload or (MaxFrame > SFrame) or WishBuf) do
        begin
          Send_File(Kanal,true);
          inc(SFrame);
        end;
      end;
    end;

    if not TNC_ReadOut and (Kanal = maxLink) then TNC_ReadOut := true;
  end; (* WITH ... *)
End;

Procedure Get_Linkstatus (* Kanal : Byte *);
Var   Pstr : String[14];
      Attr,
      i,i1 : Byte;
Begin
  with K[Kanal]^ do
  begin
    if Kanal = 0 then i1 := 2 else i1 := 6;
    Ausgabe := false;
    S_PAC(Kanal,CM,true,'L');

    for i := 1 to i1 do L_Status[i] := Byte(str_int(ParmStr(i,B1,Response)));

    if Kanal > 0 then
    begin
      Pstr := SFillStr(4,B1,'S'+int_str(L_Status[3])) +   { Send_Frames           }
              SFillStr(3,B1,'A'+int_str(L_Status[4])) +   { Schon gesendet Frames }
              SFillStr(4,B1,'T'+int_str(L_Status[5]));    { Tries                 }
      StatusOut(Kanal,59,1,Attrib[9],PStr,1);

      if TxBeepAck and FlagTxBeep and (L_Status[3] = 0) and (L_Status[4] = 0) then
      begin
        if Klingel then Beep(G^.TxPiepFreq,G^.TxPiepTime);
        FlagTxBeep := false;
      end;
      if TxBeepAck and ((L_Status[3] > 0) or (L_Status[4] > 0)) then FlagTxBeep := true;

{      if (L_STatus[3]>0) or (L_Status[4]>0) or (L_Status[5]>0) then TNC[TNCNummer]^.TXBedarf:=TRUE;}

      Attr := Attrib[13];
      if L_Status[6] in [1,7..15] then Attr := Attrib[7];
      StatusOut(Kanal,61,1,Attr,LinkStatus[L_Status[6]],2);
      C_Poll := L_Status[6] > 0;
    end;

  end;
End;

(* Tastatur solange abfragen, bis kein Zeichen mehr kommt *)
Procedure Check_Keyboard;
var     SK   : Sondertaste;
        VC   : char;
         i   : Byte;

  Procedure Tasten;
  begin
    KeyCheck := true;
    _ReadKey(SK,VC);
    KeyCheck := false;
    if not ScreenSTBY then
    begin
      polling := false;
      PollTime := TimerTick + KeyDelay;
      Key_Active(show,SK,VC);
    end else
     begin
       Neu_Bild;
       with K[show]^ do
        begin
         if ((RX_Bin>0) or (SplSave)) and (LstRXInfo<>'') then InfoOut(show,0,1,LstRXInfo);
         if (FileSend) and (LstTXInfo<>'') then InfoOut(show,0,1,LstTXInfo);
        end;
     end;
    if ScreenInit > 0 then ScreenTimer := ScreenInit;
  end;

Begin
  if not ch_aus then
  begin
    for i := 1 to maxLink do with K[i]^ do
    begin
      if CSelf = 10 then
      begin
        AutoZaehl := AutoToAnzJmp;
        CSelf := 3;
      end;
      if CSelf in [3,9] then Autozeile_Holen(i);
    end;
    if G^.Makro then While G^.Makro do Tasten
                else While _KeyPressed do Tasten;
  end else
  begin
    ch_aus := false;
    Key_Active(show,SK_out,VC_out);
  end;
  if not polling then if TimerTick > PollTime then polling := true;
End;

Procedure Rufz_TNC_init (* Kanal : Byte *);
Begin
  if Kanal > 0 then with K[Kanal]^ do
  begin
    if Test or Mo.MonActive or (Kanal = ConvHilfsPort) then
      S_PAC(Kanal,CM,true,'I' + B1 + PhantasieCall) else
    if not (connected or Kanal_benutz) then
    begin
      S_PAC(Kanal,CM,true,'I' + B1 + OwnCall);
      StatusOut(Kanal,4,1,Attrib[9],EFillStr(9,B1,OwnCall),1);
      StatusOut(Kanal,14,1,Attrib[9],ConstStr(B1,29),1);
    end;
  end;
End;

Procedure MH_Check (* TNC_Nr : Byte; Zeile : Str128 *);
Var   i,
      AnzDig   : Byte;
      MailFlag,
      FrUI,
      FrRej,
      DirDig   : Boolean;
      Rufz     : String[9];
      LongDig  : String[70];

  Procedure MH_Update(TNC_Nr : Byte);
  var   Stelle : Byte;
        found  : Boolean;
        i      : Byte;
  Begin
    if (G^.QRG_Anz > 0) and (AnzDig = 0) then
    begin
      i := 0;
      Repeat
        inc(i);
        found := (Rufz = G^.QRG[i].Call);
      Until found or (i = G^.QRG_Anz);
      if found then
      begin
        with TNC[TNC_Nr]^ do if QRG_Akt <> G^.QRG[i].QRG then
        begin
          QRG_Akt := G^.QRG[i].QRG;
          Status2;
          TicStr := ConstStr(B1,TL);
        end;
      end;
    end;

    Stelle := 0;
    Repeat
      inc(Stelle);
      found := (RufZ = MH^[Stelle].Call) and (TNC_Nr = MH^[Stelle].TNr);
    Until found or (Stelle = maxMH);

    if not found then
    begin
      { for i := maxMH-1 downto 1 do MH^[i+1] := MH^[i]; }
      move(MH^[1],MH^[2],(maxMH-1) * SizeOf(MH_Typ));
      Stelle := 1;
      FillChar(MH^[Stelle],SizeOf(MH_Typ),0);
    end;

    with MH^[Stelle] do
    begin
      Call := RufZ;
      Zeit := copy(Datum,4,8) + B1 + copy(Uhrzeit,1,5);
      Link := LongDig;
      Qrg  := TNC[TNC_Nr]^.QRG_Akt;
      TNr  := TNC_Nr;
      if FrRej then inc(Rej);
      if FrUI then inc(UIs);
    end;

    if (TicAnz > 0) and (LongDig = '') then with TNC[TNC_Nr]^ do if Tic then
    begin
      i := pos(Rufz + B1,TicStr + B1);
      if i > 0 then
      begin
        While TicStr[i] <> B1 do delete(TicStr,i,1);
        delete(TicStr,i,1);
      end else
      begin
        i := length(Rufz) + 1;
        delete(TicStr,Byte(TL+1-i),i);
      end;
      TicStr := Rufz + B1 + TicStr;
      i := TL;
      While (i > 0) and (TicStr[i] <> B1) do
      begin
        TicStr[i] := B1;
        dec(i);
      end;
      if show = 0 then TickerOut;
    end;
  End;

Begin

  LongDig := '';
  AnzDig := 0;
  DirDig := false;
  Zeile := RestStr(Zeile);
  Rufz := CutStr(Zeile);
  FrRej := pos(' ctl REJ',Zeile) > 0;
  FrUI := pos(' ctl UI',Zeile) > 0;
  i := pos(' ctl ',Zeile);
  Zeile := copy(Zeile,1,i-1);

  i := pos('*',Zeile);
  if i > 0 then
  begin
    DirDig := true;
    Zeile := copy(Zeile,1,i-1);
    delete(Zeile,1,pos(' via ',Zeile)+4);

    While pos(B1,Zeile) > 0 do
    begin
      LongDig := B1 + CutStr(Zeile) + LongDig;
      Zeile := RestStr(Zeile);
      inc(AnzDig);
    end;
    LongDig := CutStr(Zeile) + LongDig;
    inc(AnzDig);
  end;


  MH_Update(TNC_Nr);

  if DirDig then
  begin
    Rufz := CutStr(LongDig);
    LongDig := '';
    AnzDig := 0;
    FrRej := false;
    FrUI := false;
    MH_Update(TNC_Nr);
  end;
End;


Procedure Screen_aus (* Art : Byte *);
Var              i : Byte;
Begin
  if not ScreenSTBY then
  Begin
    if (show > 0) and not BackScroll(show) then
    Begin
      case Art of
        1 : dec(ScreenTimer);
        2 : ScreenTimer := 0;
      end;
      if ScreenTimer = 0 then
      begin
        Teil_Bild_Loesch(1,maxZ,0);
        ScreenSTBY := true;
      end;
    End else if Art = 2 then Alarm;
  End;
End;

Function Str_Int(Ein : String) : Longint;
Var Zahl : LongInt;
    Fehl : integer;
begin
 Val (Ein, Zahl, Fehl);
 if Fehl > 0 then Zahl:=0;
 Str_Int:=Zahl;
end;

Function QuietPruefen(RS, RM:byte) : Boolean;
var DummyFlag : Boolean;
    ZZ : Byte;

begin
DummyFlag:=false;
 for ZZ:=1 to 3 do
  begin
   if (quietZeitG) and (konfig.QuietZt[zz].aktiv) then
    with Konfig.QuietZt[Zz] do
     begin
      if (RS > StdAnf) and (RS < StdEnd) then DummyFlag:=true;
      if (RS = STdAnf) and (StdAnf<>StdEnd) then
        if RM >= MinAnf then DummyFlag:=True;
      if (RS = StdEnd) and (StdAnf<>StdEnd) then
        if RM < MinEnd then DummyFlag:=true;

      if (StdAnf=StdEnd) and (RS=StdAnf) then
        if (RM < MinEnd) and (RM >= MinAnf) then DummyFlag:=true;

     end; {with}
  end; {for}
 QuietPruefen:=DummyFlag;
end;

Procedure Uhr_aus;
Var    Zeit  : String[8];
       j, i     : Byte;
       HStr  : Byte;
       QuietM: boolean;
       rstd,
       min2,
       rmin,
       sec2  : integer;
       rsec  : longint;
       h1, h2,
       mn1,mn2,
       s1,s2 : byte;
       srec  : SearchRec;
       Dummy : string;
       flag  : boolean;
       TNCflag : Boolean;

Begin
  Zeit := Uhrzeit;
  TNCFlag:=false;

{$IFDEF Sound}
if (length(WavStream)>0) then
begin
 sprachwav;
end else
  if not playing then StopWave_;
{$ENDIF}

{  if TXOffen=0 then TXOffen:=1;
  if TXBed=0 then TXBed:=1;}

  if copy(Zeit,7,2) <> copy(ZeitMerk,7,2) then
  begin
   if (not BackupJetzt) and (BackupProc) then
    if ((str_int(copy(Zeit,4,2)) Mod Konfig.BackUpTime)=0) then
     begin
      BackupJetzt:=True;
     end;
   if (Konfig.BackUpTime>0) and (BackupProc) and (BackupJetzt) and (not BackupBremsen) then
   begin                                                     {and (not BackupBremsen)}
{    M_aus(Attrib[28],#13+'****Sicherung*** '+copy(zeit,4,2)+':'+int_str(Konfig.BackUpTime)+#13, 2);}
    Sicherung_Speichern;
    BackupProc:=false;
    BackupJetzt:=false;
   end;
  if (not BackupProc) and (Konfig.BackUpTime>0) and ((str_int(copy(Zeit,4,2)) Mod Konfig.BackUpTime)=Konfig.BackupTime-1)
      then BackupProc:=True;
{ _aus(Attrib[20],kanal,ZeitMerk +'<Merk | Zeit>'+Zeit + M1);}
(*
    {Beginn: TNC Zeit-Sharing}

      inc(TXZeit);
      if (TXZeit>TXZMax-1) and (TXZeit<250) then
       begin
        TXBed:=0;
          for i:=TXOffen+1 to MaxTNC do
           begin
            if (TNC_used[i]) and (TNC[i]^.TXBedarf) and (TXBed=0) then TXBed:=i;
           end; {for TXOffen}

          if TXBed=0 then
          begin
           for i:=1 to TXOffen do
            begin
             if (TNC_used[i]) and (TNC[i]^.TXBedarf) and (TXBed=0) then TXBed:=i;
            end;
          end;

          if TXBed=0 then TXBed:=TXOffen;

            if TXBed<>TXOffen then
             begin
              TNC[TXOffen]^.TXBedarf:=FAlse;
              TNC[TXOffen]^.TXGesperrt:=true;
              S_Pac(Tnc[TXOffen]^.Kvon, CM, TRUE, 'X0');
              TXZeit:=255-TXSicher+1;
             end else TXZeit:=1;
       end; {if txzeit>6}

      if (TXZeit=0) then
       begin

          TXOffen:=TXBed;

          TNC[TXOffen]^.txGesperrt:=false;
          TXZeit:=0;
          S_Pac(TNC[TXOffen]^.KVon, CM, true, 'X1');

      end; {if TXZeit}


      {Ende: TNC Zeit-Sharing}
*)


      rstd:=Str_Int(Copy(Zeit,1,2));
      rmin:=Str_Int(Copy(Zeit,4,2));



      if (rstd in [0,1,2]) and (not gotlastdt) and (copy(zeit,7,2)<>'00') then
       begin
       getdate(Jahr_,Monat_, Tag_, woTag_);
       {_aus(Attrib[20],kanal,'Datum2 geholt: '+int_str(Tag_)+'.'+int_str(monat_) + M1);}
       gotlastdt:=true;
       end;
      if rstd>2 then gotlastdt:=false;

      if quietZeitG then quiet:=QuietPruefen(Rstd, Rmin);
      quietM:=quiet;
      if QuietM<>Quiet then
      begin
       Klingel:=not quiet;
       SetzeFlags(show);
      end;

     RSEC:=0;

   h2:=Str_Int(Copy(Zeit,1,2));
   h1:=Str_Int(Copy(ZeitMerk,1,2));
   mn2:=Str_Int(Copy(Zeit,4,2));
   mn1:=Str_Int(Copy(ZeitMerk,4,2));
   s2:=Str_Int(Copy(Zeit,7,2));
   s1:=Str_Int(Copy(ZeitMerk,7,2));

    if h1<=h2 then rstd:=h2-h1;
    if h1>h2 then
     begin
      rstd:=24-h1;
      rstd:=rstd+(h2);
     end;
   rmin:=mn2-mn1;
   rsec:=s2-s1;
   rsec:=rsec+(rmin*60)+((rstd*60)*60);

    if NowFenster and (Box_Time > 0) then
       begin
      { BoxZaehl := Pred(BoxZaehl);    loesst Integer-Ueberlauf aus,  }
      {                                besser und schneller: //db1ras }
        Dec(BoxZaehl);
        if BoxZaehl <= 0 then Neu_Bild;
       end;

    if (not Quiet_Uhr) or (not Quiet) then StatusOut(show,13,4,Attrib[10],Zeit,1);
    if quiet and Quiet_Uhr then StatusOut(show, 13, 4, Attrib[10], '*QUIET* ', 1);

    Quiet_Uhr:=not Quiet_Uhr;
    if (not Scan_) or (not Quiet_Uhr) then StatusOut(show,61,1,Attrib[10],EFillStr(20,B1,Versi),3);
    if (Scan_) and (Quiet_Uhr) then StatusOut(show,61,1,Attrib[10],'* * * ! SCAN ! * * *',3);

    if ScreenSTBY then ScreenFill;

    if HardCur then if not JumpRxScr then
    begin
      JumpRxZaehl := pred(JumpRxZaehl);
      if JumpRxZaehl <= 0 then JumpRxScr := true;
    end;

    for i := 1 to maxLink do
    begin
     with K[i]^ do
     begin
     {NODE-TimeOut}
      if (Node) and (NTimeOut>0) then
       begin
        {NodeTimeOut:=NodeTimeOut-RSec;}
        dec(NodeTimeOut);
        if NodeTimeOut<1 then
         begin
          if Connected then begin
           s_pac(i,Nu,True,M2+'*TIMEOUT!*'+M1);
           S_PAC(i,CM,true,'D');
           {*} L_OFF(i);
           Rufz_TNC_init(i);
          end;
         end;
       end;

     {TERMINAL-TimeOut}
      if (not Node) and (Konfig.TTimeOut>0) then
       begin
        {TermTimeOut:=TermTimeOut-RSec;}
        dec(termTimeOut);
        if TermTimeOut<1 then
         begin
          if Connected then begin
           s_pac(i,Nu,True,m2+'*TIMEOUT!*'+M1);
           S_PAC(i,CM,true,'D');
           {*} L_OFF(i);
           Rufz_TNC_init(i);
          end;
         end;
       end;

      HoldLauf:=HoldLauf-rsec;
      if Hold and not (SPlsave or Xbin.TX or XBin.RX or FileSend or Einstiegskanal or AusstiegsKanal)
                and (HoldLauf<=0) then
        begin
          S_PAC(i,NU,true,HoldStr);
          if not HardCur then InfoOut(i,0,1,HoldStr);
          HoldLauf:=HoldTime * 60;
        end;
       if CSelf = 4 then
        begin
         dec(AutoWait);
         if AutoWait = 0 then CSelf := 3;
        end;
       end; {** with k... **}
      end;
    end;

    if copy(Zeit,4,2) <> copy(ZeitMerk,4,2) then
    Begin
      inc(LaufZeit);
      inc(NoActivity);
{$IFNDEF no_Bake}               {//db1ras}
      for i := 1 to TNC_Anzahl do
      begin

       with TNC[i]^ do
       begin
       Dec(MailBakenTimer);
       if (MailBake) and (MailBakenTimer=0) then
        begin
         K[0]^.TncNummer := i;
         S_PAC(0,CM,true,'C' + B1 + Konfig.OwnMailPfad);
         FindFirst(Konfig.MailVerz + S_ch + MsgExt,Archive,srec);
          flag:=false;
           if DosError = 0 then
             begin
              S_PAC(0,NU,false,InfoZeile(392)+B1);
              Dummy := '';
             end else Flag := true;
              While DosError = 0 do
               begin
                Dummy:=srec.Name;
                delete(Dummy,pos('.',Dummy),length(Dummy));
                S_PAC(0,NU,false,DUMMY+B1);
                Dummy := '';
               FindNext(srec);
              end;
         if not flag then S_PAC(0,NU,true,m1);
         S_PAC(0,CM,true,'C' + B1 + BPFad);

         MailBakenTimer:=MailBakenZeit;
        end;
       if Bake then
       begin
        if (LaufZeit mod BTimer) = 0 then
        begin
          K[0]^.TncNummer := i;
          S_PAC(0,CM,true,'C' + B1 + BPfad);
          if BCall<>'' then S_PAC(0,CM,true,'I' + B1 + BCALL);
          S_PAC(0,NU,true,BText);
          if BCall<>'' then
           begin
            S_PAC(0,CM,true,'I' + B1 + HostCall);
            for j:=1 to maxlink do Rufz_TNC_Init(j);
           end;
        end;
        if show = 0 then Unproto_darstellen;
       end;
       end;
      end;
{$ENDIF}

      for i := 1 to maxLink do with K[i]^do
      begin
        if CSelf = 1 then if AutoTime = copy(Zeit,1,5) then CSelf := 3;
        if CSelf = 2 then
        begin
          inc(AutoZyCount);
          if AutoZyCount >= AutoZyConst then CSelf := 3;
        end;
        if CSelf = 3 then AutoToAnz := AutoToMax;
        if (CSelf in [5,6]) and (AutoToCount > 0) then
        begin
          dec(AutoToCount);
          if AutoToCount = 0 then
          begin
            CSelf := 9;
            if AutoToAnz > 0 then
            begin
              dec(AutoToAnz);
              if AutoToAnz = 0 then CSelf := 10;
            end;
          end;
        end;



        {if Hold and not (FileSend or Einstiegskanal or AusstiegsKanal)
                and ((LaufZeit mod HoldTime) = 0) then}

        if Hold and not (FileSend or Einstiegskanal or AusstiegsKanal)
                and (HoldLauf<=0) then
        begin
          S_PAC(i,NU,true,HoldStr);
          if not HardCur then InfoOut(i,0,1,HoldStr);
          HoldLauf:=HoldTime * 60;
        end;

      end;

      if ScreenInit > 0 then Screen_aus(1);
    end;
    ZeitMerk := Zeit;
End;


(* TNC-Nachricht abholen und auswerten. Nur nach einem SendTNC ansprechen !!!  *)
Procedure GetTNC (* Kanal : Byte *);
var   j,i,i1,i2,
      iz,ix,
      Attr,
      TNC_Nr    : Byte;
      CheckAnwesend1,
      Flag      : Boolean;
      Datei     : Text;
      hcall,
      hcall2    : Str9;
      MailZeile,
      Bstr      : String;
      Dummy     : String;
      IdStr     : String[5];
      BinFrame2,
      BinFrame  : Boolean;
      Broadc1   : BroadCast;
      Broadc2   : BroadCast;


   Procedure Port_Ident(Kanal : Byte; var Col : Byte);
   var     HfPort,i : Byte;
           flag     : Boolean;
   Begin
     with K[Kanal]^ do
     begin
       i := pos(DP,Response);
       if i > 0 then
       begin
         HfPort := str_int(Response[i-1]);
         delete(Response,i-1,2);
         KillStartBlanks(Response);
         i := 1;
         flag := false;
         Repeat
           if (TNC[i]^.DRSI = TNC[K[Kanal]^.TncNummer]^.DRSI) and
              (TNC[i]^.HF_Port = HfPort) then flag := true else inc(i);
         Until flag or (i > TNC_Anzahl);
         if flag then Col := i
                 else Col := 1;
         IdStr := TNC[Col]^.Ident;
         if length(IdStr) > 0 then IdStr := EFillStr(5,B1,IdStr)
                              else IdStr := '';
       end else
       begin
         IdStr := Channel_Id(Kanal);
         Col := TncNummer;
       end;
     end;
   End;

   Function Rufzeichen(Zeiger : Integer) : Str9;
   Var i    : Integer;
       Bstr : Str9;
   Begin
     with K[0]^ do
     begin
       Bstr := '';
       for i := Zeiger to Zeiger + 5 do
         if Response[i] <> #64 then Bstr := Bstr + Chr(Ord(Response[i]) DIV 2);
       if (Ord(Response[Zeiger+6]) DIV 2) <> 48 then
       begin
         i := (Ord(Response[Zeiger+6]) DIV 2) - 48;
         if (i < 0) or (i > 15) then Bstr := Bstr + '-?'
         else if (i <> 0) then Bstr := Bstr + '-' + int_str(i);
       end;
     end;
     Rufzeichen := Bstr;
   End;

   Function Flags : Str8;
   Const Flag_str = 'CNMR';
   Var Bstr    : Str8;
       flgs, i : Integer;
   Begin
     with K[0]^ do
     begin
       Bstr := '';
       flgs := ord(Response[20]) SHR 4;
       for i := 1 to 4 do
       begin
         if flgs mod 2 <> 0 then Bstr := Copy(Flag_str, i, 1) + Bstr
                            else Bstr := '*' + Bstr;
         flgs := flgs SHR 1;
       end;
     end;
     Flags := B1 + Bstr + B1;
   End;

{$IFNDEF no_Netrom} {//db1ras}
  Procedure SaveBroadCast;
  Var BcDatNam : string[12];
      BCDat    : File of Broadcast;
      AnzNds,
      IOR      : word;
      DPs      : longint;
      donotsave: boolean;
      BCFlag   : boolean;

  begin
   AnzNds:=NodesAnzahl(TNC[Broadc1.Port]^.AfuPort);
   if TNC[Broadc1.Port]^.AfuPort then BCDatNam:=BCastHAM else BCDatnam:=BCastCB;
   assign (BCDat, sys1pfad+BCDatNam);
   BCFlag:=true;
   donotsave:=false;
   if BroadC1.SourceCall='' then BroadC1.SourceCall:=BroadC1.SourceAlias;
   if BroadC1.NodeCall='' then BroadC1.NodeCall:=BroadC1.NodeAlias;
   {$I-}
    reset(BCDat);
    ior:=ioresult;
    if ior<>0 then REwrite(BCDat);
    if ioresult<1 then ior:=ior;
    if (ior=0) and (anznds>0) then
     begin
      DPs:=0;
      bcflag:=false;
      while ((not EOF(BCDat)) and (not bcFlag)) do
       begin
        read(BCDat, BroadC2);
        if (BroadC1.NodeCall=BroadC2.NodeCall) and
           (BroadC1.NodeAlias=BroadC2.NodeAlias) then
           begin
            if (Broadc2.quality <= Broadc1.quality) then BCFlag:=true
              else
               begin
                bcflag:=true;
                doNotSave:=true;
               end;
           end;
        if not BCFlag then inc(DPs);
       end; {while}
       if BCFlag then seek(BCDat, Dps);
       if not BCFlag then
         if anznds<Konfig.MaxNodes then BCFlag:=true;
     end;

    if (BCFlag) and (not DoNotSave) and (BroadC1.NodeCall<>'') and (BroadC1.NodeAlias<>'') then
    begin
     {ior:=NodesAnzahl(TNC[Broadc1.Port]^.AfuPort);}
     write(BCDat, BroadC1);
     {ior:=NodesAnzahl(TNC[Broadc1.Port]^.AfuPort);}
     ior:=ior;
    end;
    doNotSave:=false;
    ior:=ioresult;
    Close(BCDat);
    ior:=ioresult;
    {ior:=NodesAnzahl(TNC[Broadc1.Port]^.AfuPort)}
    {$I+}
  end;
{$ENDIF}

Begin
  Kanal2:=kanal;
  if TNC[K[Kanal]^.TncNummer]^.TNC_im_Host then with K[Kanal]^ do
  begin
    TNC_Nr := V24(Kanal);

    get_Response(Kanal);
    CheckAnwesend1:=false;
    If not (OverRun or SynchError) then
    Case TNC_Code of
       0 : Begin  (* success, no info *)
             Response := '';
             Ausgabe := true;
             TncNix := true;
           End;
       1 : Begin  (* success with info (null-terminated) *)
             if TNC[TncNummer]^.DRSI > 0 then Port_ident(Kanal,ix)
                                         else IdStr := Channel_Id(Kanal);
             if Ausgabe then
             begin
               if TNC_ReadOut then InfoOut(Kanal,0,1,IdStr + Response)
                              else M_aus(Attrib[28],IdStr + Response +^J, Kanal);
             end;
             Ausgabe := true;
           End;
       2 : Begin  (* failure with info (null-terminated) *)
             if Ausgabe then InfoOut(Kanal,1,1,Channel_Id(Kanal) + Response);
             Ausgabe := true;
           End;
       3 : Begin    (* Link Status (null-terminated) *)
             if TNC[TncNummer]^.DRSI > 0 then Port_ident(Kanal,ix)
                                         else IdStr := Channel_Id(Kanal);

             If pos(LSM[1],Response) > 0 then
             Begin  (* BUSY fm ... *)
               if Fwd then CancelMailPoll(Kanal);
               delete(Response,1,12);
               Response := BusyStr + Response;
               _aus(Attrib[20],Kanal,Response + M1);
               Kanal_benutz := false;
               if AusstiegsKanal then
               begin
                 S_PAC(GegenKanal,NU,true,M2 + Response + M1);
                 Send_Prompt(GegenKanal,FF);
                 RemConInit(Kanal);
               end;
               Auto_CON := false;
               outside:=TRUE;
               Rufz_TNC_init(Kanal);
               SetzeFlags(Kanal);
             End else

             If pos(LSM[2],Response) > 0 then
             Begin  (* CONNECTED to ... *)
              SystemErkannt:='';
               if not Rekonnekt then
               begin
                 Rekonnekt := false;
                 Kanal_benutz := true;
                 L_ON(Kanal,Response,true,false);
                 Line_ON(Kanal);
               end else InfoOut(Kanal,1,1,'Reconnect to ' + Call);
             End else

             If pos(LSM[3],Response) > 0 then
             Begin  (* LINK RESET fm ... *)
               Response := RestStr(Response);
               _aus(Attrib[20],Kanal,Star + Response + M1);
               Kanal_benutz := true;
             End else

             If pos(LSM[4],Response) > 0 then
             Begin  (* LINK RESET to ... *)
               Response := RestStr(Response);
               _aus(Attrib[20],Kanal,Star + Response + M1);
               Kanal_benutz := true;
             End else

             If pos(LSM[5],Response) > 0 then
             Begin  (* DISCONNECTED *)
               Rekonnekt := false;
               if Conv.Active then ConversQuit(Kanal);
            {*} {muá bleiben!!} L_Off(Kanal);
               Rufz_TNC_init(Kanal);
               if EinstiegsKanal then
                begin
                 S_PAC(GegenKanal,CM,true,'D');
            {*>>} { L_off(GegenKanal);}
                end;
               if AusstiegsKanal then
               begin
                 if K[GegenKanal]^.RemConReady then
                 begin
                   S_PAC(GegenKanal,NU,false,M2 + ReconStr +
                         K[GegenKanal]^.OwnCall+M2);
                   Send_Prompt(GegenKanal,FF);
                 end;
                 RemConInit(Kanal);
               end;
             End else

             If pos(LSM[6],Response) > 0 then
             Begin  (* LINK FAILURE with ... *)
               if Fwd then CancelMailPoll(Kanal);
               if Conv.Active then ConversQuit(Kanal);
               if EinstiegsKanal then
                begin
                 S_PAC(GegenKanal,CM,true,'D');
             {*>>} {L_Off(GegenKanal);}
                end;
               if AusstiegsKanal then
               begin
                 if Auto_Con then S_PAC(GegenKanal,NU,false,M2 + FailStr + Ziel_Call + M1) else
                 begin
                   if connected
                    then S_PAC(GegenKanal,NU,false,M1 + ReconStr + K[GegenKanal]^.OwnCall+M1)
                    else S_PAC(GegenKanal,NU,false,M2 + Star + Response + M1);
                 end;
                 Send_Prompt(GegenKanal,FF);
                 RemConInit(Kanal);
               end;
          {*} L_Off(Kanal);
               Rufz_TNC_init(Kanal);
             End else

             If pos(LSM[7],Response) > 0 then
             Begin  (* CONNECT REQUEST fm ... *)
               if Klingel then Beep(600,70);
               InfoOut(show,1,1,Star + IdStr + Response);
             End else

             If pos(LSM[8],Response) > 0 then
             Begin  (* FRAME REJECT fm ... *)
               Response := RestStr(Response);
               _aus(Attrib[20],Kanal,Star + Response + M1);
             End else

             If pos(LSM[9],Response) > 0 then
             Begin  (* FRAME REJECT to ... *)
               Response := RestStr(Response);
               _aus(Attrib[20],Kanal,Star + Response + M1);
             End else
             Begin (* Unbekannt *)
               _aus(Attrib[20],Kanal,InfoZeile(106) + Response + M1);
             End;
           End;
       4 : Begin  (* Monitor header, no info (null-terminated) *)
             CheckAnwesend1:=true;
             if TNC[TncNummer]^.DRSI > 0 then
             begin
               Port_Ident(0,ix);      {Faktor COLOR-eintr„ge/TNC}
               ColMon := ColMonBeg + ix * 4 - 3;
               MH_Check(ix,Response);
             end else
             begin
               ix := TncNummer;
               ColMon := ColMonBeg + ix * 4 - 3;
               IdStr := Channel_Id(0);
               MH_Check(ix,Response);
             end;

             TNC_K := (pos(' - ',Response) > 0); (* K auf 2 gesetzt ? *)

             if Mon_Anz > 0 then
             begin
               for i := 1 to maxLink do with K[i]^.Mo do
               begin
                 if MonActive and MonDisAbr then
                   if (pos(MonStr[1]+B1,K[0]^.Response) > 0) or
                      (pos(MonStr[2]+B1,K[0]^.Response) > 0) then
                 begin
                   if (pos(' ctl DISC',K[0]^.Response) > 0) or
                      (pos(' ctl DM',K[0]^.Response) > 0) then
                   begin
                     _aus(Attrib[20],i,M1 + InfoZeile(437) + B1 +
                                       RestStr(K[0]^.Response) + M1);
                     Cancel_Call_monitoren(i);
                   end;
                 end;
               end;
             end;

             if Drucker then Write_Lpt(0,LptEsc[1]);
             Bstr := FormMonFr(ix,IdStr,Response);
             if (Time_stamp and not TNC_K) then Bstr := Bstr + B1 + '(' + Uhrzeit + ')';
             if not RxLRet then Bstr := ^J + Bstr;
             M_aus(Attrib[ColMon],Bstr + ^J, Kanal);
             if Drucker then Write_Lpt(0,LptEsc[2]);

(*             hcall2:=copy(Bstr,pos('fm ',Bstr)+3,9);
             if pos(' ',hcall2)>0 then delete(hcall2,Pos(' ',hcall2),length(hcall2));
             j:=0;
             if pos('-',hcall2)>0 then
             j:=str_int(Copy(Hcall2,Pos('-',Hcall2)+1,Pos('-',Hcall2)+3));
             strip(hcall2);
             i1:=0;
             while length(Hcall2)>0 do
              begin
               inc(i1);
               if not (hcall2[i1] in ['a'..'z', 'A'..'Z', '1'..'9','0']) then hcall2:='';
              end;

             if hcall2>'' then
             for i1:=1 to maxAnwesend do
             begin
              HCall:=Anwesend[i1]^.Call;
              strip(HCall);
              if hcall=hcall2 then
               for i:=0 to 15 do
                begin
                 if (j = Anwesend[i1]^.SSids[i]) then
                  begin
                   Anwesend[i1]^.da:=true;
                   Anwesend[i1]^.Call:=Hcall;
                   if i<>0 then Anwesend[i1]^.Call:=Anwesend[i1]^.Call+'-'+int_str(i);
                  end;
                end;
              if Anwesend[i1]^.da then Scan_:=true;
             end;*)

           End;
       5 : Begin  (* Monitor header with info (null-terminated) *)
             CheckAnwesend1:=true;
             if TNC[TncNummer]^.DRSI > 0 then
             begin
               Port_Ident(0,ix);
               ColMon := ColMonBeg + ix * 4 - 3;
               MH_Check(ix,Response);
             end else
             begin
               ix := TncNummer;
               ColMon := ColMonBeg + ix * 4 - 3;
               IdStr := Channel_Id(0);
               MH_Check(ix,Response);
             end;

             TNC_K := (pos(' - ',Response) > 0); (* K auf 2 gesetzt ? *)

             G^.HeaderStr := Response;

             if Drucker then Write_Lpt(0,LptEsc[1]);
             Bstr := FormMonFr(ix,IdStr,Response);

             NetRom:=false;
             if (pos(' pid CF', Bstr) > 0) then
              begin
               NetRom:=true;
               i := pos(' to ', Bstr);
               j := i;
               i := i - 1;
               while (Copy(Bstr, i, 1) <> ' ') and (i > 0) do i := i - 1;
               i := i + 1;
               G^.NRCall := Copy(Bstr, i, j - i);
              end;

              MailZeile:=UpcaseStr(Bstr);
              delete(mailzeile,1,Pos(' FM ', MailZeile)+3);
              MailFrFlag:=false;
               for i:=1 to 10 do
               begin
                if (Pos(UpcaseStr(MailFrame1+Konfig.MailFrame[i]+MailFrame2), MailZeile)>0) or
                   ((Pos(UpcaseStr(MailFrame1+Konfig.MailFrame[i]+' VIA'), MailZeile)>0) and
                   (Pos(UpcaseStr(MailFrame2), MailZeile)>0)) then
                    begin
                     MailFrFlag:=true;
                     Mail.BoxCall:=copy(Mailzeile,1,Pos(' ',Mailzeile)-1);
                     for i1:=1 to maxlink do if K[i1]^.owncall=Mail.BoxCall then
                      begin
                       Mail.Boxcall:='';
                       MailFrFlag:=false;
                      end;
                    end;
               end;

             if Time_stamp and not TNC_K then Bstr := Bstr + B1 + '(' + Uhrzeit + ')';
             if not RxLRet then Bstr := ^J + Bstr;
             M_aus(Attrib[ColMon],Bstr, Kanal);
             if Drucker then Write_Lpt(0,LptEsc[2]);

             MonCode5 := true;
           End;
       6 : If MonCode5 then    (* Monitor info (Byte count) *)

           if Not NetRom then Begin
             if MailFrFlag then
              begin
               MailZeile:=UpcaseStr(Response);
               i:=0;
                while i<maxlink do
                begin
                 inc(i);
                 HCall:=UpcaseStr(K[i]^.OwnCall);
                 if Pos (HCall, MailZeile)>0 then
                  begin
                   Mail.ZielCall:= HCall;
                   Mail.Uhrzeit := Uhrzeit;
                   Mail.Datum   := Datum;
                   Mail.Port    := K[kanal]^.TncNummer;
                   Mail.Versuche:= 0;
                   MailSpeichern (Mail);
                    sound_(2000,5);
                    MailInBox:=True;
                    SetzeFlags(show);
                  end;
                end; {while i<maxlink}
              end; {MailFrame}
             MonCode5 := false;
             BinFrame2:=false;
             i:=length(response);
             Repeat                     {0..5,15..25,27..31,}
               if ord(Response[i]) in BinMenge
                then BinFrame2 := true;
                 dec(i);
             Until BinFrame2 or (i < 1);

             if (BinFrame2) and (RxComp) then
              begin
               Response := DeCompress(Response, Kanal);
              end;

             if PacOut then M_aus(Attrib[ColMon],' (' + int_str(TNC_Count) + ')', Kanal);
             M_aus(Attrib[ColMon],^J, Kanal);
             inc(ColMon);

             Mon_Header_Auswerten;

             if Mon_Anz > 0 then
              for i := 1 to maxLink do with K[i]^.Mo do
               if MonActive and (MonNow[1] or MonNow[2]) then
               begin
                 TNC_Info(i,MonAttr,K[0]^.Response);
                 if K[0]^.TNC_Count > 255
                  then TNC_Info(i,MonAttr,K[0]^.Response256);
               end;

             if Drucker then Write_Lpt(Kanal,LptEsc[3]);

             BinFrame := false;
             if NoBinMon then
             begin
               i := length(Response);
               Repeat                    {0..5,15..25,27..31,}
                 if ord(Response[i]) in BinMenge
                  then BinFrame := true;
                 dec(i);
               Until BinFrame or (i < 1);

               if BinFrame then
               begin
                 Response := '<BIN';
                 if PacOut then Response := Response + RSK +^J
                           else Response := Response + B1 +
                                int_str(TNC_Count) + RSK +^J;
               end;
             end;

             M_aus(Attrib[ColMon],Response, Kanal);
             if not BinFrame and (TNC_Count > 255) then
               M_aus(Attrib[ColMon],Response256, Kanal);

             if Drucker then Write_Lpt(0,LptEsc[4]);
            end
{$IFNDEF no_Netrom} {//db1ras}
            else {NetRom}
             begin
              inc(ColMon, 2);
              fillChar(Broadc1, sizeOf(Broadc1), 0);
              fillChar(Broadc2, sizeOf(Broadc2), 0);
               if not RxLRet then Bstr := ^J
               else Bstr := '';
               if Response[1] = #255 then
               begin

                 BroadC1.Port :=K[kanal]^.TNCNummer;
                 Bstr := Bstr + '> '+InfoZeile(427)+' ';
                 if Response[2] <> B1 then
                 begin
                  i:=2;
                   while ((i<8) and (Response[i]<>B1)) do
                   begin
                    Broadc1.SourceCall := Broadc1.SourceCall + Response[i];
                    inc(i);
                   end;

                   if Pos('?', Broadc1.SourceCall)>0 then strip(Broadc1.SourceCall);
                   Bstr := Bstr + Broadc1.sourceCall+':';
                 end;
                 Broadc1.SourceAlias:=G^.NRcall;
                 if Pos('?', Broadc1.SourceAlias)>0 then strip(Broadc1.SourceAlias);
                 Bstr := bstr + Broadc1.sourceAlias + ' <' + M1;


                 if length(Response) < 10 then
                   Bstr := Bstr + '> '+InfoZeile(428)+' <' + M1;
                 M_aus(Attrib[ColMon], Bstr, Kanal);
                  i := 8;

                if length(Response)>9 then
                begin
                Broadc1.DatTime:=PackDT;
                 while (i+1) < length(Response) do
                 begin
                   Broadc1.NodeCall:=''; BroadC1.NodeAlias:='';
                   Bstr := '';
                   for j := i+7 to i+12 do
                     if Response[j] <> B1 then Broadc1.NodeCall := Broadc1.NodeCall + Response[j];
                     if Pos('?', Broadc1.NodeCall)>0 then strip(Broadc1.NodeCall);
                     Bstr:=bstr+Broadc1.NodeCall;
                   if Response[i+7] <> B1 then Bstr := Bstr + ':' else BroadC1.Nodealias:='';
                   BroadC1.NodeAlias:=Rufzeichen(i);
                   if Pos('?', Broadc1.NodeAlias)>0 then strip(Broadc1.NodeAlias);
                   Broadc1.quality:=ord(Response[i+20]);
                   Bstr := Bstr + Broadc1.nodealias;
                   Bstr := EfillStr(21, B1, Bstr) + 'via '
                                + efillstr(11,b1,Rufzeichen(i+13)) +
                                'quality: ' + sfillstr(3,b1,int_str(broadc1.quality)) + M1;
                   M_aus(Attrib[ColMon], b2+Bstr, Kanal); Inc(i, 21);

                   if Konfig.MaxNodes>0 then SaveBroadCast;
                 end; {while}
                end; {if lenght response}
               end else
               begin
                 Bstr := Bstr + '[' + Rufzeichen(1) + ' to '
                                    + Rufzeichen(8)
                              + ' LT:'+int_str(ord(Response[15])) + B1;
                 Case (ord(Response[20]) and 15) of
                   1: Begin
                        Bstr := Bstr + 'my-Idx:' + int_str(ord(Response[16])) + '/'
                                     + int_str(ord(Response[17])) + B1
                                     + Rufzeichen(22) + '@'
                                     + Rufzeichen(29) + Flags + '<Connect-Req.>]' + M1;
                      End;
                   2: Begin
                        Bstr := Bstr + 'ur-Idx:' + int_str(ord(Response[16])) + '/'
                                     + int_str(ord(Response[17])) + B1
                                     + 'my-Idx:' + int_str(ord(Response[18])) + '/'
                                     + int_str(ord(Response[19]))
                                     + Flags + '<Connect-Ack.>]' + M1;
                      End;
                   3: Begin
                        Bstr := Bstr + 'ur-Idx:' + int_str(ord(Response[16])) + '/'
                                     + int_str(ord(Response[17]))
                                     + Flags + '<Disconnect-Req.>]' + M1;
                      End;
                   4: Begin
                        Bstr := Bstr + 'ur-Idx:' + int_str(ord(Response[16])) + '/'
                                     + int_str(ord(Response[17]))
                                     + Flags + '<Disconnect-Ack.>]' + M1;
                      End;
                   5: Begin
                        Bstr := Bstr + 'ur-Idx:' + int_str(ord(Response[16])) + '/'
                                     + int_str(ord(Response[17])) + B1
                                     + 'Tx:' + int_str(ord(Response[18])) + B1
                                     + 'Rx:' + int_str(ord(Response[19]))
                                     + Flags + '<Info-Trans.>]' + M1;
                        M_aus(Attrib[ColMon], Bstr, kanal);
                        Dec(ColMon,1);
                        Bstr := Copy(Response, 21, length(Response) - 20);
                        if K[0]^.TNC_Count > 255 then Bstr := Bstr + K[0]^.Response256;
                        if Bstr[length(Bstr)] <> M1 then Bstr := Bstr + M1;
             BinFrame := false;

             i := length(Bstr);
               Repeat                    {0..5,15..25,27..31,}
                 if ord(Bstr[i]) in BinMenge
                  then BinFrame := true;
                 dec(i);
               Until BinFrame or (i < 1);

               if BinFrame then Bstr := DeCompress(Bstr, Kanal);

             if NoBinMon then
             begin
               if BinFrame then
               begin
               i := length(Bstr);
               BinFrame:=False;
               Repeat                    {0..5,15..25,27..31,}
                 if ord(Bstr[i]) in BinMenge
                  then BinFrame := true;
                 dec(i);
               Until BinFrame or (i < 1);
               end;

               if BinFrame then
               begin
                 Bstr := '<BIN';
                 if PacOut then Bstr := Bstr + RSK +^J
                           else Bstr := Bstr + B1 +
                                int_str(TNC_Count) + RSK +^J;
               end;
             end;
                      End;
                   6: Begin
                        Bstr := Bstr + 'ur-Idx:' + int_str(ord(Response[16])) + '/'
                                     + int_str(ord(Response[17])) + B1
                                     + 'Rx:' + int_str(ord(Response[19]))
                                     + Flags + '<Info-Ack.>]' + M1;
                      End;
                   else Begin
                          Bstr := Bstr + 'Type ' + int_str(ord(Response[20]) and 15) + ']' + M1;
                        End;
                 end;
                 M_aus(Attrib[ColMon], Bstr, kanal);
               end;

           End
{$ENDIF}
              ;

       7 : Begin (* Connected info (Byte count) *)
             TNC_Info(Kanal,Attrib[18],Response);
             if TNC_Count > 255 then TNC_Info(Kanal,Attrib[18],Response256);
           End;

    end;
if CheckAnwesend1 then
 begin
 checkAnwesend1:=false;
 Bstr:=Response;
{ _aus(Attrib[20],0,m1+'SCAN! '+BSTR+m1 );}
hcall2:=copy(Bstr,pos('fm ',Bstr)+3,9);
             if pos(' ',hcall2)>0 then delete(hcall2,Pos(' ',hcall2),length(hcall2));
             j:=0;
             if pos('-',hcall2)>0 then
             j:=str_int(Copy(Hcall2,Pos('-',Hcall2)+1,Pos('-',Hcall2)+3));
             strip(hcall2);
             i1:=0;
{         _aus(Attrib[20],0,m1+'Call1 *'+hcall2+'*'+m1 );}
             while i1<length(hcall2) do
              begin
               inc(i1);
               if not (hcall2[i1] in ['a'..'z', 'A'..'Z', '1'..'9','0']) then hcall2:='';
              end;
             i1:=0;

{           _aus(Attrib[20],0,m1+'Call2 '+hcall2+m1 ); }
             if hcall2>'' then
             for i1:=1 to maxAnwesend do
             begin
              HCall:=Anwesend[i1]^.Call;
              strip(HCall);
              i:=0;
              if hcall=hcall2 then
               for i:=0 to 15 do
                begin
                 if (j = Anwesend[i1]^.SSids[i]) then
                  begin
                   Anwesend[i1]^.da:=true;
                   Anwesend[i1]^.Call:=Hcall;
                   if i<>0 then Anwesend[i1]^.Call:=Anwesend[i1]^.Call+'-'+int_str(i);
                  end;
                end;
              if Anwesend[i1]^.da then Scan_:=true;
             end;
end; {CheckAnwesend}


  End;
End;


Procedure S_PAC (* Kanal,Art : Byte; All : Boolean; Zeile : String *);
Var  i,l,j : Byte;
     hstr2, hstr:string;
     XBFlag:boolean;
     SPStr : string;

  Procedure MakePaclenStr(Zeile : String);
  Begin
    with K[Kanal]^ do
    Repeat
      l := FF - length(SendZeile);
      SendZeile := SendZeile + copy(Zeile,1,l);
      delete(Zeile,1,l);
      While length(SendZeile) >= PacLen do
      begin
        if not BufExists and (Kanal > 0) and (BufToLow or WishBuf or Test) then
        begin
          OpenBufferFile(Kanal);
          SetzeFlags(Kanal);
        end;
        SPStr:=copy(SendZeile,1,PacLen);
        if (SPComp) and (TXComp) then SPStr:=SPCompress(SPStr, kanal);
        if (SPComp) and (TXComp) and (TEST) then SPStr:=EFillStr(PacLen, #0, spstr);
        if (BufExists) and ((not SPComp) or ((SPComp) and (Txcomp) and (TEST))) then WriteBuffer(Kanal,SPStr)
                     else TxRxTNC(Kanal,0,SPStr);
        spstr:='';
        delete(SendZeile,1,PacLen);
      end;
    Until Zeile = '';

  End;

 Procedure Senden (SZl : string; kan : Byte; All : Boolean);
 begin
  with k[kan]^ do
  begin
 {TNC[TNCNummer]^.TXBedarf:=true;}

       HoldLauf:=HoldTime * 60;

      { if (SPComp) or (G^.ZeilenwTX) then All:=true;}

       NodeTimeOut:=NTimeOut * 60;
       K[GegenKanal]^.NodeTimeOut:=NTimeOut * 60;
       TermTimeOut:=Konfig.TTimeOut * 60;
       K[GegenKanal]^.TermTimeOut:=Konfig.TTimeOut * 60;
{       _aus(Attrib[19],5,'Kanal: '+Int_str(Kanal)+' /Gegenkanal: '+int_str(Gegenkanal)+m1); }

      if Auto_CON then NodeConnect(Kanal,UpCaseStr(szl));
      l := Ord(szl[0]);
      if l > 0 then TxLRet := szl[l] = M1;

      if (EigFlag) or (FileFlag) or (RemFlag) then
      begin
         if Drucker then Write_Lpt(Kanal,LptEsc[7]);
         if EigFlag then if not RxLRet then _aus(Attrib[19],Kanal,M1);
         _aus(Attrib[19],Kanal,szl);
         if Drucker then Write_Lpt(Kanal,LptEsc[8]);
      end;
                 {and (length(szl)>0)}
      if (TxComp) and (length(szl)>0) then
      begin
        Repeat
          i := Ord(szl[0]);
          if i > maxCompPac then i := maxCompPac;
          if (not STOPComp) and (NOT SPComp) then MakePaclenStr(Compress(copy(szl,1,i), Kanal));
          if (SPComp) then
           begin
             MakePacLenStr(copy(szl,1,i));
           end;
          if (STopComp) then MakePaclenStr(StoPCompress(Kanal, copy(szl,1,i), StopCode));
          delete(szl,1,i);
        Until szl = '';
      end else{ if not G^.ZeilenwTX then} MakePaclenStr(szl);


    end;
end;

Begin
xbflag:=false;
  with K[Kanal]^ do
  begin
  if ((XBin.RX) or (XBin.TX)) and (art=NU) and (Copy(zeile,1,2)<>XProt) then
   begin
      xbflag:=true;
      sendzeile:=XBin.VorPuffer;
   end;

    if Art = CM then TxRxTNC(Kanal,CM,Zeile) else
    if Art = NU then
    begin
{     if (spcomp) and (TXComp) and (Test) then all:=true;}
      if length(Zeile)>0 then
       begin
        if (TX_Bin>1) or ((not G^.ZeilenwTX) ) then Senden (Zeile, kanal, all)
         else
          begin
           repeat
            all:=true;
            j:=Pos(#13,Zeile);
            hstr2:=copy(zeile,1,j);
            delete(zeile,1,j);
            if (j=0) and (zeile<>'') then
             begin
              hstr2:=Zeile+#13;
              zeile:='';
             end;
            senden (hstr2, kanal, all);

     if All and (length(SendZeile) > 0) then
      begin
       if (SPComp) and (TXComp) then SendZeile:=SpCompress(SendZeile,kanal);
        if not BufExists and (Kanal > 0) and (BufToLow or WishBuf or Test) then
        begin
          OpenBufferFile(Kanal);
          SetzeFlags(Kanal);
        end;
        if (BufExists) and ((not SPComp) or ((SPComp) and (TEST))) then WriteBuffer(Kanal,SendZeile)
                     else TxRxTNC(Kanal,0,SendZeile);
        SendZeile := '';
      end;




           until zeile='';
          end;

       end;
      if All and (length(SendZeile) > 0) then
      begin
       if (SPComp) and (TXComp) then SendZeile:=SpCompress(SendZeile,kanal);
        if not BufExists and (Kanal > 0) and (BufToLow or WishBuf or Test) then
        begin
          OpenBufferFile(Kanal);
          SetzeFlags(Kanal);
        end;
        if (BufExists) and ((not SPComp) or ((SPComp) and (TEST))) then WriteBuffer(Kanal,SendZeile)
                     else TxRxTNC(Kanal,0,SendZeile);
        SendZeile := '';
      end;


     if XBflag then
     begin
      XBin.VorPuffer:=sendzeile;
      sendzeile:='';
     end;
    end;
  end;
End;

Procedure TxRxTNC (* Kanal,Art : Byte; Zeile : String *);
Var   Merk : Boolean;
Begin
  Merk := Ausgabe;
  Ausgabe := false;

  if (Kanal = 0) and (TNC[K[0]^.TncNummer]^.DRSI > 0) and
     (K[0]^.TncAkt <> K[0]^.TncNummer) then
  begin
    K[0]^.TncAkt := K[0]^.TncNummer;
    SendTNC(Kanal,1,TNC[K[0]^.TncNummer]^.HF_PortStr);
    GetTNC(Kanal);
  end;

  Ausgabe := Merk;
  SendTNC(Kanal,Art,Zeile);
  GetTNC(Kanal);
End;


(*  Monitor-Status aller angeschlossenen TNCs feststellen und speichern,
    danach alle Monitore abschalten. *)
Procedure Moni_Off (* Art : Byte *);
Var   i : Byte;
Begin
  if MoniStaAnz = 0 then
  begin
    for i := 1 to TNC_Anzahl do with TNC[i]^ do
    begin
      K[0]^.TncNummer := i;
      Ausgabe := false;
      S_PAC(0,CM,true,'M');
      MoniStatus := K[0]^.Response;
    end;

    if (Mon_Anz = 0) or (Art = 1) then
     for i := 1 to TNC_Anzahl do with TNC[i]^ do
     begin
       K[0]^.TncNummer := i;
       S_PAC(0,CM,true,'MN');
     end;
  end;
  inc(MoniStaAnz);
End;

(* Monitor-Status bei allen TNCs wieder herstellen *)
Procedure Moni_On;
Var    i : Byte;
Begin
  if MoniStaAnz > 0 then dec(MoniStaAnz);
  if MoniStaAnz = 0 then
  begin
    for i := 1 to TNC_Anzahl do with TNC[i]^ do
    begin
      K[0]^.TncNummer := i;
      S_PAC(0,CM,true,'M' + B1 + MoniStatus);
    end;
  end;
End;


Procedure Check_Mld (* Kanal : Byte; Zeile : Str80 *);
var   i,j, AuSys : Byte;
      Flag : Boolean;
      hstr2,
      Hstr : String[80];
      Zeile2:string;
Begin
  Zeile2:=zeile;
  with K[Kanal]^ do
  begin
    NodeTimeOut:=NTimeOut * 60;
    K[GegenKanal]^.NodeTimeOut:=NTimeOut * 60;
    TermTimeOut:=Konfig.TTimeOut * 60;
    K[GegenKanal]^.TermTimeOut:=Konfig.TTimeOut * 60;

  { _aus(Attrib[19],5,'Kanal: '+Int_str(Kanal)+' /Gegenkanal: '+int_str(Gegenkanal)+m1); }

  { _aus(Attrib[19],Kanal,'#'+Zeile+M1); }
    if QSOZeilen<10 then QSOZeilen:=QSOZeilen+1;
    Zeile := UpCaseStr(Zeile);
    MldOk := 0;
    Flag := false;

    i := 0;

    Repeat
      inc(i);
      if (Zeile > '') and
         ((i in [1..3,5,18,28,29,35,43])
         and (pos(Meldung[i],Zeile) > 0))
         or ((i in [30,31,32,33,4,6..8,34,9,11..15,25,36,41,42])
         and (pos(Meldung[i],Zeile) = 1))
         or {,26,27 COMPC, 37-40=SPCOMP}
         ((i in [10,16,17,19..23,26,27, 37..40])
         and (Meldung[i] = Zeile))
         or ((i in [24])
         and (pos(Meldung[i],Zeile) = 1) and Conv.Active) then
      begin
        MldOk := i;
        Flag := true;
      end;
    Until ((Flag) and (mldok<>13)) or (i >= maxMld);

    if RemAll then i := 2
              else i := 1;

{    if mldok in [31..33] then
     begin
      i:=REM_Auswert (Kanal, i, Zeile2);
      if i<>254 then Remote(Kanal, i, Zeile2) else
       begin
        if not Mo.MonActive then
         begin
          S_PAC(Kanal,NU,false,InfoZeile(129) + Zeile2 + M1);
          Send_prompt(kanal, ff);
         end;
       end;
     end;}

    case MldOk of
     34: XBIN.An:=true;
    end;

    If MldOk=28 then SelfSysop:=true;

    If MldOk=29 then SelfSysop:=false;

    if MldOk in [28, 29] then setzeFlags(Kanal);

    if not Flag and (ExtMld > '') and (pos(ExtMld,Zeile) = 1) then
    begin
      Flag := true;
      ExtMldFlag := true;
    end;

    if (MldOk=8) and (not AutoBin) then S_PAC(kanal,NU,true,Meldung[10]+M1);

    if Flag and Conv.Active and not (MldOk in [5,30,6,24]) then Flag := false;

    if (MldOK=36) then
     begin
      {#REQUESTNAME:NQL#}
      hstr:='';
     end;



   { RecCheck:=true;       }  {and RecCheck}


   {***** HIER strzt rechner bei recon in 0box-8 ab!}

    if Flag and (MldOk in [5,6,30]) then
    begin
     if Fwd then CancelMailPoll(Kanal);
{      KillEndBlanks(zeile);
      While pos(B1,Zeile) > 0 do delete(zeile,1, pos(b1,zeile));
      if pos(DP,Zeile) > 0 then Zeile2 := ParmStr(1,DP,Zeile);
      if pos(DP,Zeile) > 0 then Zeile := ParmStr(2,DP,Zeile);
      Hstr := ACMerk;


      KillEndBlanks(Hstr);
      HSTR2:=hstr;
      while pos('-',Hstr)>0 do
       begin
         delete(Hstr,pos('-',Hstr),pos(B1,Hstr)-pos('-',Hstr));
       end;

      if (pos(RSK + Zeile + B1,Hstr) = 0) and (pos(RSK + Zeile2 + B1,Hstr) = 0) and
         (pos(RSK + Zeile + B1,Hstr2) = 0) and (pos(RSK + Zeile2 + B1,Hstr2) = 0)then
      begin
        Flag := false;
        MldOk := 0;
      end; }
    end;

    if not Flag then MldOk := 0;
  end;
{  _aus(Attrib[19],Kanal,'!'+Zeile+M1); }
End;


{***************}


Function XComp_Sammler (* Kanal: Byte; Zeile : String) : String*);
Var    i,i1,
       i2,l   : Byte;
       CZeile : String;
       BT: boolean;
Begin
CZeile:='';
  with K[Kanal]^ do
  begin
   if (RxComp) then
   begin
    if NOT SPComp then
    Repeat
      i := FF - length(CompZeile);
      i1 := length(Zeile);
      if i > i1 then i := i1;
      CompZeile := CompZeile + copy(Zeile,1,i);
      delete(Zeile,1,i);
      i := length(CompZeile);
      if i > 0 then
      begin
        i1 := Ord(CompZeile[1]);
        if i1 = FF then
        begin
          if i > 1 then i1 := Ord(CompZeile[2]);
          if i1 = FF then i1 := FF-2;
          dec(i);
          l := 2;
        end else l := 1;
        if i > i1 then
        begin
          CZeile := DeCompress(copy(CompZeile,1,i1+l), Kanal);
          CompZeile:='';
        (*  While CZeile > '' do
          begin
            i2 := pos(M1,CZeile);
            if i2 > 0 then
            begin
              XMeldeCompZ := XMeldeCompZ + copy(CZeile,1,i2-1);
              {Check_Mld(Kanal,MeldeCompZ);
              Connect_Info(Kanal,Attr,i2 >= length(CZeile),copy(CZeile,1,i2));}
              MldOk := 0;
              XMeldeCompZ := '';
              AutoCheckLn := false;
              delete(CZeile,1,i2);
            end else
            begin
              XMeldeCompZ := XMeldeCompZ + CZeile;
              {Connect_Info(Kanal,Attr,true,CZeile);}
              CZeile := '';
            end;
          end; *)
          delete(CompZeile,1,i1+l);
        end;
      end else i1 := FF;
     Until (Zeile = '') and (i <= i1)
     else
     begin

    CZeile:='';
    bt:=false;
    if (Zeile[1]=#255) then Bt:=true;
    if Bt then delete (Zeile,1,1);

    CompZeile:=CompZeile+Zeile;

    if (CompZeile[Length(Compzeile)]<>#13) and (Zeile[1]<>#255) then
     begin
      CZeile := SPDeCompress(CompZeile, Kanal); {if spcomp}
      CompZeile:='';
     end;

     if Bt then
      begin
       Czeile:=CompZeile;
       CompZeile:='';
      end;

(*          While CZeile > '' do
          begin
            i2 := pos(M1,CZeile);
            if i2 > 0 then
            begin
              MeldeCompZ := MeldeCompZ + copy(CZeile,1,i2-1);
              Check_Mld(Kanal,MeldeCompZ);
              Connect_Info(Kanal,Attr,i2 >= length(CZeile),copy(CZeile,1,i2));
              MldOk := 0;
              MeldeCompZ := '';
              AutoCheckLn := false;
              delete(CZeile,1,i2);
            end else
            begin
              MeldeCompZ := MeldeCompZ + CZeile;
              Connect_Info(Kanal,Attr,true,CZeile);
              CZeile := '';
            end;
          end; *)


     { CZeile:=SPDeCompress(Zeile, Kanal);}
     end;
   end;{ else Connect_Info(Kanal,Attr,FrEnd,Zeile);}
  end; {with kanal}
  XComp_Sammler:=CZeile;
End;


{=********************}




Procedure TNC_Info (* Kanal,Attr : Byte; Zeile : String *);
Var    i : Byte;
       NichtFWD:Boolean;
       XZeilen:string;
Begin
NICHTFwd:=false;
xzeilen:=zeile;
 if not FWD_ then PollStr:='';
  with K[Kanal]^ do
  begin
   NodeTimeOut:=NTimeOut * 60;
   K[GegenKanal]^.NodeTimeOut:=NTimeOut * 60;
   TermTimeOut:=Konfig.TTimeOut * 60;
   K[GegenKanal]^.TermTimeOut:=Konfig.TTimeOut * 60;
  if ((xbin.rx) or (Xbin.TX)) and (RXComp) then
   begin
    if KompressUpd then
     begin
      Zeile:='';
      MeldeZeile:='';
     end;
    xZeilen:=XComp_Sammler(Kanal, XZeilen);  {DeCompress(xZeilen, Kanal);}
   end;
  if (xbin.an) and (#0#255=copy(xzeilen,1,2)) then
    begin
     if xZeilen[3]=Data then xbinwrite (kanal, xZeilen);
     if xzeilen[3]=Comd then XBinCheck (kanal, xZeilen,0, '');
     {XBinCheck (kanal : Byte; XBinZ:string; DtPos:longint; XZeile:string);}
     xzeilen:='';
     Zeile:='';
     meldezeile:='';
    end;

   if (not connected) and (not Test) then sysart:=0;
    if not RxComp and KillEsc and (Mo.MonActive or SCon[11]) then
    begin
      While pos(E7m,Zeile) > 0 do delete(Zeile,pos(E7m,Zeile),4);
      While pos(E0m,Zeile) > 0 do delete(Zeile,pos(E0m,Zeile),4);
    end;

    While Zeile > '' do
    begin


      i := pos(M1,Zeile);


      if i > 0 then
      begin
        MeldeZeile := MeldeZeile + copy(Zeile,1,i-1);
        if fwdGO then PollStr := PollStr + copy(Zeile,1,i-1) +#13;
        {MZAR! Meldezeile= Alles bis zum n„chsten Return!!}
        Check_Mld(Kanal,MeldeZeile);


        if RxComp then
        begin
          if MldOk in [1,5,6,30,22] then
          begin
            RxComp := false;
            TxComp := false;
            CompZeile := '';
            MeldeCompZ := '';
          end else
          if MldOk = 23 then
          begin
            CompZeile := '';
            MeldeCompZ := '';
            MldOk := 0;
            delete(Zeile,1,i);
          end else MldOk := 0;
        end;

        Comp_Sammler(Kanal,Attr,i >= length(Zeile),copy(Zeile,1,i));
        MldOk := 0;
        MeldeZeile := '';
        AutoCheckLn := false;
        delete(Zeile,1,i);
      end else
      begin
        MeldeZeile := MeldeZeile + Zeile;
        if fwdGO then Pollstr:=Pollstr+Zeile;
        Comp_Sammler(Kanal,Attr,true,Zeile);
        Zeile := '';
      end;

    if (fwd) and (FwdGO) and (kanal>0) then
     begin

        repeat
         NichtFWD:=false;
         {PollStr:=PollStr+Zeile;}
         PollStr:=upcasestr(PollSTR);
          if (MailSStopPrompt_<>'') and (Pos(MailSStopPrompt_,PollStr)>1) then
           begin
            NichtFWD:=true;
            s_pac(kanal,NU,true,M1);
            _aus(Attrib[19],Kanal,m1);
            infoout(Kanal,0,0,'RETURN');
            delete(pollstr,1,Pos(MailSStopPrompt_,PollStr)+length(MailSStopPrompt_));
           end;
          if (not NichtFWD) and (MailPrompt='') and (not MailPWWait) then
           begin
            MailPollGo(Kanal, NichtFWD);
           end;
          if (not NichtFWD) and (not MailPWWait) and (MailPrompt<>'') and (Pos(MailPrompt, PollStr)>0) then
           begin
            MailPollGo(Kanal, NichtFWD);
            delete(pollstr,1,Pos(MailPrompt,PollStr)+length(MailPrompt_));
           end;
           if not NichtFWD then
            begin
             while pos(m1,PollStr)>0 do
             delete(PollStr,1,Pos(M1,PollStr));
            end;

        until (Pos(M1,PollStr)=0);
       end;

    end; {while}

  end;
End;


Procedure Comp_Sammler (* Kanal,Attr : Byte; FrEnd : Boolean; Zeile : String *);
Var    i,i1,
       i2,l   : Byte;
       CZeile : String;
       Bt:boolean;
Begin
  with K[Kanal]^ do
  begin
   if  rxcomp then
   begin
   if (not spComp) then
   begin

            if (mo.monactive) and (pos(meldung[21]+#13,zeile) in [1,2]) then
             begin
              delete(zeile,1,pos(meldung[21]+#13,compzeile)+length(meldung[21])+1);
              compzeile:='';
             end;
            if (mo.monactive) and (pos(meldung[27]+#13,zeile) in [1,2]) then
             begin
              delete(zeile,1,pos(meldung[27]+#13,zeile)+length(meldung[27])+1);
              compzeile:='';
             end;


    Repeat
      i := FF - length(CompZeile);
      i1 := length(Zeile);
      if i > i1 then i := i1;
      CompZeile := CompZeile + copy(Zeile,1,i);
      delete(Zeile,1,i);
      i := length(CompZeile);
      if i > 0 then
      begin
        i1 := Ord(CompZeile[1]);
        if i1 = FF then
        begin
          if i > 1 then i1 := Ord(CompZeile[2]);
          if i1 = FF then i1 := FF-2;
          dec(i);
          l := 2;
        end else l := 1;
        if i > i1 then
        begin

          if (not STOPComp) and (not SPComp) then
           begin

           {****************************}

          {  if (mo.monactive) and (pos(meldung[20]+#13,compzeile) in [1,2]) then
             begin
              delete(compzeile,1,pos(meldung[20]+#13,compzeile)+length(meldung[22])+1);
             end;

            if (mo.monactive) and (pos(meldung[22]+#13,compzeile) in [1,2]) then
             begin
              delete(compzeile,1,pos(meldung[22]+#13,compzeile)+length(meldung[22])+1);
             end;
            }
            {****************************}

            CZeile := DeCompress(copy(CompZeile,1,i1+l), Kanal);
           end;
          if (STOPComp) then CZeile := STOPDeCompress(Kanal, copy(CompZeile,1,i1+l), StopCode);
          if (SPComp) then CZeile := SPDeCompress(CompZeile, Kanal);

          While CZeile > '' do
          begin
            i2 := pos(M1,CZeile);
            if i2 > 0 then
            begin
              MeldeCompZ := MeldeCompZ + copy(CZeile,1,i2-1);
              Check_Mld(Kanal,MeldeCompZ);
              Connect_Info(Kanal,Attr,i2 >= length(CZeile),copy(CZeile,1,i2));
              MldOk := 0;
              MeldeCompZ := '';
              AutoCheckLn := false;
              delete(CZeile,1,i2);
            end else
            begin
              MeldeCompZ := MeldeCompZ + CZeile;
              Connect_Info(Kanal,Attr,true,CZeile);
              CZeile := '';
            end;
          end;
          delete(CompZeile,1,i1+l);
        end;
      end else i1 := FF;
    Until (Zeile = '') and (i <= i1);
   end else
    begin
    CZeile:='';
    bt:=false;
    if (Zeile[1]=#255) then Bt:=true;
    if Bt then delete (Zeile,1,1);

    CompZeile:=CompZeile+Zeile;

    if (CompZeile[Length(Compzeile)]<>#13) and (Zeile[1]<>#255) then
     begin
      CZeile := SPDeCompress(CompZeile, Kanal); {if spcomp}
      CompZeile:='';
     end;

     if Bt then
      begin
       Czeile:=CompZeile;
       CompZeile:='';
      end;

          While CZeile > '' do
          begin
            i2 := pos(M1,CZeile);
            if i2 > 0 then
            begin
              MeldeCompZ := MeldeCompZ + copy(CZeile,1,i2-1);
              Check_Mld(Kanal,MeldeCompZ);
              Connect_Info(Kanal,Attr,i2 >= length(CZeile),copy(CZeile,1,i2));
              MldOk := 0;
              MeldeCompZ := '';
              AutoCheckLn := false;
              delete(CZeile,1,i2);
            end else
            begin
              MeldeCompZ := MeldeCompZ + CZeile;
              Connect_Info(Kanal,Attr,true,CZeile);
              CZeile := '';
            end;
          end;

    end; {else SPComp}
   end else Connect_Info(Kanal,Attr,FrEnd,Zeile); {if rxcomp}
   end; {with}
End;

{Procedure FwdNext (Kanal:byte);
 var dummy,path:string;
begin}
{ with K[Kanal]^ do
  begin
   if (fwdmsgsholen=0) and (FwdStarted) then  S_PAC(Kanal,NU,true,'FF'+M1);
   if fwdMsgsHolen > 0 then
   begin
    Path := G^.MailPfad + OwnCall + MsgExt;
       FRxName := Path;
       if OpenTextFile(Kanal) then
         begin
          sound_(2000,50); delay(300);
           mldok:=0;
            RX_Count := 0;
            RX_TextZn := 0;
            RX_Laenge := 0;
            RX_Bin := 1;
            RX_Time := Uhrzeit;
            RX_Save := true;
            if node then Mail_sp:=true;
            RemoteSave := true;
             Dummy := M1 + InfoZeile(96) + ' ' + B1+ EFillStr(10,B1,Call) +
             Datum + B2 + copy(Uhrzeit,1,5) + B1 + ZeitArt + M1;
             Dummy := Dummy + ConstStr('-',length(Dummy)-2) + M1;
             Write_RxFile(Kanal,Dummy);
            end;
       if not FwdFS then
         begin
          S_PAC(Kanal,NU,true,'FF'+M1);
         end;
        dec(fwdMsgsHolen);
       end (*fwdMsgsHolen > 0*)
        else FwdStarted:=false;

    fwdnxt:=false;
    fwdFS:=false;
  end;
end;  }


{Procedure Forward (Kanal : Byte; Zeile : String);
var fw : integer;
fwdzeile: string;
begin}

    {Frameflicken einbauen. auf CR trimmen und im kanal-pointer
     ablegen. RX-Call rauspicken (2. Call im Fr./ParmStr 4!) und Mail ”ffnen.
     Rest l„uft bis zum ctrl-Z allene. danach FF senden, anstatt
     "Mail gespeichert" (nur wenn FWD=True!)}

{ with K[Kanal]^ do
  begin
    if fwd then
     begin
      FwdZeile:=UpcaseStr(Zeile);
      if (pos('_', FwdZeile)>0) and (not FwdStarted) then
       begin
        while pos('_', FwdZeile) > pos(' ', FwdZeile) do
         begin
          delete (FwdZeile, 1, pos(' ', FwdZeile));
         end;
        delete(FwdZeile, pos('_', FwdZeile), length(fwdZeile));
        inc(FwdMails);
       end;
      if (Pos('F>',Zeile)=1) and (FwdMails>0) then
       begin
        FwdZeile:='FS ';
        for fw:=1 to FwdMails do
          if fw=1 then FwdZeile:=FwdZeile + '+'
            else FwdZeile:=FwdZeile + '+';
        fwdMsgsHolen:=1;
        if FWdMails<>0 then
           S_PAC(Kanal,NU,true,FwdZeile+M1);
           FwdStarted:=true;
           FwdFS:=true;
        fwdNxt:=true;
        fwdMails:=0;
       end;
     end;
 end; with
end;      }



Procedure Connect_Info (* Kanal,Attr : Byte; FrEnd : Boolean; Zeile : String *);
var       i,i1,iz,j, AuSys: Integer;
          UmlFlag,    {Umlaute-flag empfangen?}
          KompFlag,   {Komp-flag empfangen?}
          NUN,
          Flag,
          BFlag,
          ReKon    : Boolean;
          Bstr     : String;
          Rufz     : String[9];
          FlagZ,
          Zusatz,
          MemZeile : String[80];
          Kenner   : Str32;
          profibox : boolean;

Begin
 nun:=false;
 with K[Kanal]^ do begin
  if First_Frame and (length(Zeile) > 1) and (not node) then begin
    Kompflag:=false;
    UmlFlag:=false;

  {**** Automatische Systemerkennung *****}
    XPNodeC:=false;
    Kenner:='';
    Autokenn:=false;
    AuSys:=0; SystemErkannt:=AutoSysName[0];
 {    _aus(Attrib[20],Kanal,'** '+SystemErkannt + '  -  '); }
    Zusatz:='';
    If (Kanal > 0) then
      begin
       For j:=1 to MaxAutoSys do
        begin
         if Pos(AutoSysKenner[j], Zeile) = 1 then
          begin
           AuSys:=j;
           SystemErkannt:=AutoSysName[AuSys];
           Zusatz:=Zeile;
           delete(Zusatz,1,length(AutoSysKenner[j]));
           if Pos('-',Zusatz)>0 then delete(Zusatz,Pos('-',Zusatz),length(Zusatz));
           if Pos(']',Zusatz)>0 then delete(Zusatz,Pos(']',Zusatz),length(Zusatz));
           if Pos(' ',Zusatz)>0 then delete(Zusatz,Pos(' ',Zusatz),length(Zusatz));
           if Zusatz[1]='N' then delete(Zusatz,1,1);
           Zusatz:=' '+Zusatz;
           SystemErkannt:=SystemErkannt+Zusatz;
           if (AuSys<>3) and (not node) then InfoOut(Kanal,0,1,InfoZeile(72)+SystemErkannt);
          end; {if pos autosysïkenner}
        end; {for }
        SystemErkannt:=AutoSysName[AuSys]+Zusatz;
        SetzeFlags(Kanal);
        Case AuSys of
         1: SysArt:=3;
       { 2: SysArt:=16; }
         2: {FlexNet-Passworterkennung //db1ras}
          Begin
            If Zeile[13]<'3' Then
              SysArt:=7 {RMNC}
            Else If (Zeile[13]='3') And (Zeile[15]<'3') Then
              SysArt:=7 {RMNC}
            Else If (Zeile[13]='3') And (Zeile[15]='3')
                    And (Zeile[16]<'g') Then
              SysArt:=7 {RMNC}
            Else
              SysArt:=10; {BN}
          End;
         3:
          begin
           Zusatz:='';
           SysArt:=17;
           if Pos(AutosysKenner[3]+NodeK,Zeile)>0 then XPNodeC:=true;
           FlagZ:=Zeile;
           delete(FlagZ,1,length(AutoSysKenner[3]));
           if Pos(DatenKenner, FlagZ)>0 then
            begin
             delete(FlagZ, 1, Pos(DatenKenner, FlagZ));
             if (FlagZ[1] in ['0'..'9']) then
              begin
               UmlFlag:=true;
               Umlaut:=str_int(FlagZ[1]);
               Zusatz:=' ('+InfoZeile(379)+')';
               delete(FlagZ, 1,1);
              end;
             if (Pos('C', flagZ)>0) and (not node) then
              begin
               KompFlag:=true;
               User_Komp:=str_int(FlagZ[Pos('C', FlagZ)+1])+1;
               if user_komp=2 then user_komp:=0;
              end;
            end else Zusatz:='';
           Zeile:=Line_Convert(Kanal,2,Zeile);
           if (not node) then InfoOut(Kanal,0,1,InfoZeile(72)+SystemErkannt+Zusatz);
           if (not Outside) and (not Node) and (not Ausstiegskanal) then
            begin
              Kenner:=AutoSysKenner[3];
              if node then Kenner:=Kenner + NodeK;

              Kenner:=Kenner+copy(Version,Pos(' ',Version)+1,Length(Version));
              zusatz:='';


              if (not UmlFlag) then Zusatz:=Zusatz+int_str(Umlaut);

              if (not KompFlag) and (User_Komp>0) and (not node) then Zusatz:=Zusatz+'C'+int_str(User_Komp-1);



              if zusatz<>'' then
               begin
                if (UmlFlag) then Zusatz:=int_str(Umlaut)+Zusatz;
                kenner:=kenner+'-'+zusatz;
               end;

              kenner:=kenner+']'+m1;
              if not xpnodec then S_PAC(Kanal,NU,true,Kenner);
             end;
          end;
         4: sysart:=1;
         5: Sysart:=18;
         6: begin
             SysArt:=21;
             Profibox:=false;
             Zusatz:=Zeile;
             delete(Zusatz,1,pos(Zusatz,'-'));
             delete(Zusatz,1,pos(Zusatz,'-'));
             if Zusatz[1] in ['1'..'9','0'] then profibox:=false else profibox:=true;
            end;
        end; {case}

      {_aus(Attrib[20],Kanal,+SystemErkannt +m1);}
      if (SCon[0]) and (((Sysart=21) and (not ProfiBox)) or ((SysArt=17) and (not XPNodec))) then RequestName(Kanal);
      if KompFlag then
       begin
       Case User_Komp of
        {2: CompC:=true;}
        3: SPComp:=True;
       end;

       if not (TxComp or RxComp) then
            begin
              {if (Kanal > 0) and (CompC) and (not SPComp) then
               begin
                S_PAC(Kanal,NU,true,M1 + Meldung[26] + M1);
                KompressUpd:=true;
                CompCUpdZahl:=0;
                Randomize;
                For i:=1 to 127 do
                begin
                 Kompression[i]:=random(127);
                 Kompression[i+127]:=Kompression[i] xor Comp_Key_Tab[I];
                end;
                Kompression[255]:=Kompression[1];
                FileSendWaitS:=fileSendWait;
                FileSendWait:=true;
               end;}


              if (Kanal > 0) and (not COMPC) and (not SPComp) then S_PAC(Kanal,NU,true,M1 + Meldung[19] + M1);
              if (Kanal > 0) and (not COMPC) and (SPComp) then S_PAC(Kanal,NU,true,M1 + Meldung[37] + M1);
              TxComp := true;
              Flag := true;
            end;

       end;

      SetzeFlags(Kanal);
      end; {if kanal>0}
    end;



    if (MailPWWait) and (fwd) and (FwdGo) then
     begin
      PollStr:='';
     end;

    if ScreenSTBY then Neu_Bild;
    ScreenTimer := ScreenInit;

    Flag := true;
    If Ignore And Auto_CON And (MldOk in [1..7,17,18,30,35,43]) Then  {//db1ras}
      Flag := false;
    if not Ignore then Flag := false;
    if (MldOk in [5,6,30,10]) then
     begin
      flag:=flag;
     end;
    if ((RX_Save and (RX_Bin in [2,5]) or (xbin.rx) or (XBin.TX)) and (MldOk in [5,6,30,10])) then
     begin
      Flag := false;
     end;
    if AusstiegsKanal and (MldOk in [5,6,30]) then Flag := false;
    if Flag then MldOk := 0;

    BFlag := true;
    if RxComp then MemZeile := MeldeCompZ
              else MemZeile := MeldeZeile;

    ReKon := false;

    if not TNC_ReadOut and RX_Datenpieps and Klingel then
    begin
     if (((Node) or (K[gegenkanal]^.Node)) and (Konfig.NodeSound)) or (not Node) then
      begin
       LockIntFlag(0);
       Daten_Bell;
       LockIntFlag(1);
       RX_Datenpieps := false;
      end;
    end;
    if not Ignore and WishBoxLst and (SysArt in SysMenge) and
       (Zeile[length(Zeile)] = M1) then
    begin
      BoxStr := MemZeile;
      Write_BoxStr(Kanal,0);
    end;
    if EinstiegsKanal and not Ignore and not RemConReady then
    begin
      S_PAC(GegenKanal,CM,true,'D');
      S_PAC(GegenKanal,CM,true,'G');
{*}       L_off(GegenKanal);
      RemConInit(GegenKanal);
      Rufz_TNC_init(GegenKanal);
      if length(MemZeile) = 0 then
      begin
        MldOk := 0;
        Send_Prompt(Kanal,FF);
        Exit;
      end;
    end;
    if AusstiegsKanal and (MldOk in [5,6,30]) then
    begin
 (*     Zeile := '';
      S_PAC(Kanal,CM,true,'D'); WELCHER SINN?!
       {*} L_off(kanal);
       Rufz_TNC_init(Kanal); *)
       Rekon:=true;
    end;
    if (RX_Save) or ((xbin.rx) and (mldok in [5,6,30,10])) then
    begin
      if not BinOut then BFlag := false;
      if ((RX_Bin = 5) or (xbin.rx)) and (MldOk in [5,6,30,10]) then
      begin
        if not (Xbin.an) then Write_RxFile(Kanal,MemZeile);
        if (xbin.rx) then XBinWrite(Kanal, '');
        BFlag := true;
      end else
      begin
        if RX_Bin = 1 then BFlag := true;
        Write_RxFile(Kanal,Zeile);
      end;
    end else                          {#BIN#}          {#XBIN#}
    if (AutoBinOn) and (AutoBin) and ((MldOk = 8) or (MldOk =34)) then
    begin
      {if mldok=8 then} OpenBinFile(Kanal,MemZeile);
      {if mldok=34 then OpenXBinFile (Kanal, MemZeil);}
    end else
    begin
      if (RX_Bin in [3,4]) and (MldOk in [5,6,30,10]) then
      begin
        RX_Bin := 0;
        S_Aus(Kanal,3,M1 + Star + InfoZeile(41) + M1);
        S_PAC(Kanal,NU,true,'');
        SetzeFlags(Kanal);
      end;
    end;
    if SPlus and (RX_Bin = 0) then
    begin
      if (MldOk = 11) and ((length(MemZeile) > 69) or (length(MemZeile) < 65)) then MldOk := 0;
      if SplSave and (MldOk in [1,5,6,30,10,11,14,41]) then Close_7Plus(Kanal);
      if SplSave then
      begin
        Write_SplFile(Kanal,Zeile);
        if not BinOut then BFlag := false;
      end;

      if (MldOk in [11,14,41]) and not SplSave then
      begin
        Open_Close_7Plus(Kanal,MemZeile);
        if SplSave then
        begin
          Write_SplFile(Kanal,MemZeile + M1);
          if not BinOut then BFlag := true;
        end;
      end;
      if SplSave and (MldOk in [12,15,42]) then
      begin
        Open_Close_7Plus(Kanal,MemZeile);
        if not BinOut then
        begin
          Zeile := MemZeile + M1;
          BFlag := true;
        end;
      end;
    end;

    if Drucker then Write_Lpt(Kanal,LptEsc[5]);

    if BFlag then _aus(Attr,Kanal,Zeile);
{TEST!}
    if WeFlag then
    begin
      WeFlag := false;
      _aus(Attrib[20],Kanal,DZeile);
    end;

    if WishDXC and (MldOk = 4) and (Mo.MonActive or SCon[11]) then
    begin
      Bstr := MemZeile;
      Compute_QTH(Bstr);
      if Bstr > '' then _aus(Attrib[29],Kanal,Bstr + M1);
    end;
    if Drucker then Write_Lpt(Kanal,LptEsc[6]);

    if CSelf > 0 then
    begin
      if (CSelf = 5) and (Auto1Zeile > '') and not AutoCheckLn and
         (pos(Auto1Zeile,UpCaseStr(MemZeile)) > 0) then
      begin
        AutoCheckLn := true;
        if AutoArt = 1 then
        begin
          Auto1Zeile := '';
          AutoArt := 2;
        end else CSelf := 8;
      end;

      if (CSelf = 5) and not AutoCheckLn and
         (pos(AutoZeile,UpCaseStr(MemZeile)) > 0) then
         begin
           CSelf := 7;
           AutoCheckLn := true;
         end;

      if (CSelf = 5) and (AutoToCount > 0) then AutoToCount := AutoToConst;

      if CSelf = 8 then
      begin
        Auto1Zeile := '';
        AutoJmpRet[AutoJmpPtr] := AutoZaehl;
        inc(AutoJmpPtr);
        if AutoJmpPtr > maxAutoJmpPtr then AutoJmpPtr := 1;
        AutoZaehl := AutoJump;
        CSelf := 7;
      end;
      if CSelf = 7 then Autozeile_Holen(Kanal);
    end;


    if First_Frame and (length(Zeile) > 1) and (not node) then
    begin

      if sysart in [1..5,14] then
       begin
        AutoKenn:=true;
        scon[sysart]:=true;
        if WishBoxLst then BoxListe(Kanal);
       end;

      if not Ausstiegskanal then
      begin
        if SCon[1] then DieBox_PW_Scan(Kanal,Zeile);
        if SCon[2] and ExtMldFlag then BayBox_US_Scan(Kanal,Zeile);
      end;
      First_Frame := false;
      ExtMld := '';
      ExtMldFlag := false;
    end;

    if RTF and (MldOk = 25) then
     begin
      ComputeRTF(Kanal,MemZeile);
      nun:=true;
     end;

    if (Kanal <> show) and
       not(EinstiegsKanal or AusstiegsKanal or NochNichtGelesen
       Or Ignore) and   {//db1ras}
       (not Conv.Active or (Conv.Active and (Kanal = ConvHilfsPort))) then
    begin     (* Signalisieren, dass neuer Text gekommen ist *)
      if rx_bin<1 then NochNichtGelesen := true;
      Status2;
      If (Klingel) and (TNC_ReadOut) and (RX_Bin<1) and
         (not Mo.MonActive or (Mo.MonActive and Mo.MonSignal)) then
          begin
           if (not Node) or ((Node) and (Konfig.NodeSound)) then Daten_Bell;
          end;
    end;

    if Conv.Active then
    begin
      if (MldOk in [5,6,30]) then ConversQuit(Kanal);
      if MldOk = 24 then
      begin
        if not FrEnd then ConversTX(Kanal,true,false,'');
        ConversRemote(Kanal,MemZeile);
      end else if Zeile <> M1 then
      begin
        ConversTX(Kanal,FrEnd,false,Zeile);
        inc(Conv.Count);
      end;
      if FrEnd then Conv.Count := 0;
    end;
    if AusstiegsKanal and Auto_CON and (MldOk in [1,2,3,5,6,30]) then
    begin
      S_PAC(GegenKanal,NU,false,M2 + FailStr + Ziel_Call + M1);
      Send_Prompt(GegenKanal,FF);
      S_PAC(Kanal,CM,true,'D');
      {*} L_off(Kanal);
      RemConInit(Kanal);
      Rufz_TNC_init(Kanal);
    end;

    if not (AusstiegsKanal or EinstiegsKanal) then
    begin
      if ((FileSend) or (xbin.tx)) and (MldOk = 10) and (TX_Bin <> 2) then
      begin
        FiResult := CloseBin(TxFile);
        FileSend := false;
        if xbin.TX then CloseXBinProt(kanal);
        xbin.tx:=false;
        xbin.an:=false;
        xbin.rtxok:=true;
        AutoBinOn:=AutoBin;
        BoxZaehl:=5;
        S_Aus(Kanal,3,M1 + Star + InfoZeile(107) + M1);
        S_PAC(Kanal,NU,true,Meldung[10]+M1);
        SetzeFlags(Kanal);
      end;

      ReKon := false;

      if not Ignore and not Mo.MonActive then
      begin
        if MldOk in [5,6,30,35] then
        begin
          NodeCmd := true;
          ReKon := true;
        end;
      end;

      if Auto_CON and (MldOk in [1,2,3,5,6,30,35,43]) then
      begin
        Auto_CON := false;
        InfoOut(show,1,1,InfoZeile(119) + B1 + int_str(Kanal) + DP + B1 + InfoZeile(154));
        CancelMailPoll(Kanal);
      end;
    end;
                                                    {TNN!!!}
    if ((NodeCmd and not Ignore) or (Auto_CON) or (SysArt=8)) and (MldOk in [5,6,30,7,18,35]) then
    begin
      if Rekon and (LogArt = 2) then
       begin
        LogBuchEintrag(Kanal,0);
        if Fwd then CancelMailPoll(Kanal);
       end;
      MemZeile := UpCaseStr(MemZeile);
      KillEndBlanks(MemZeile);
      NodeCmd := false;
      NodeCon := true;

      {*RECONNECT}
      if (rekon) and (Pos(' VIA ', Memzeile)=0) then
      begin
      if (Pos(DP,MemZeile)=0) or (Pos(DP,MemZeile)>Pos(B1, MemZeile)) then
       begin
        if (Pos(DP,MemZeile)>Pos(B1, MemZeile)) then
         While (Pos(DP,MemZeile)>Pos(B1, MemZeile)) do
          MemZeile := RestStr(MemZeile)
        else
         While (pos(B1,MemZeile) > 0) do
          MemZeile := RestStr(MemZeile);
        end;

      if (Pos(DP,MemZeile)>0) and (Pos(DP,MemZeile)<Pos(B1, MemZeile)) then
       delete (MemZeile, Pos(B1, Memzeile), length(memzeile));

      if pos(DP,MemZeile) > 0 then MemZeile := ParmStr(2,DP,MemZeile);
      if not ((ord(Memzeile[length(Memzeile)])) in [48..57,65..90,97..122]) then
               delete(Memzeile, length(memzeile),1);
      end
      else
       begin
        delete(Memzeile,Pos(' VIA ', Memzeile),Length(Memzeile)-Pos(' VIA ',memzeile)+1);
        While pos(B1,MemZeile) > 0 do
         MemZeile := RestStr(MemZeile)
       end;
      Flag := Auto_CON;

{      sound (3000); delay(1500); nosound;}

      L_ON(Kanal,TncConStr + B1+ MemZeile,false,Rekon);
      Bstr := MemZeile;
              {or speek}
      if (morsen) and not Flag then
      begin
        Rufz := Bstr;
        Strip(Bstr);

        if morsen and ((ReKon and ReconMorsen) or (not ReKon and ConMorsen)) then
        begin
          Verzoegern(10 * MPause);
          Morse(Kanal,Bstr);
        end;

{        if Speek and ((ReKon and ReconVoice) or (not ReKon and ConVoice))
         then Sprechen(Rufz); }

        ReKon := false;
      end;
      if AusstiegsKanal and not K[GegenKanal]^.RemConReady
          and not Auto_CON then K[GegenKanal]^.RemConReady := true;
    end;

    if not Ignore then
    begin
      if SysopParm then Password_Auswert(Kanal,Zeile);
      if Priv_Modus then  (*  //priv wurde bereits empfangen. Jetzt die  *)
      begin               (*  Antwort auswerten                          *)
        Priv_Modus := false;
        Nun:=true;
        if pos(Priv_Errechnet,copy(Zeile,1,80)) > 0 then
         begin
          RemAll := true;
          S_PAC(Kanal,NU,true,M1 + InfoZeile(99)+' ' + Meldung[28] + M1);
         end;
        SetzeFlags(Kanal);
      end;
    end;

    if Kopieren > 0 then S_PAC(Kopieren,NU,FrEnd,Zeile);

    if EinstiegsKanal or (AusstiegsKanal and not FoundCall) then
    begin
      K[GegenKanal]^.WishBuf := true;
      S_PAC(GegenKanal,NU,FrEnd,Zeile);
    end;

    if not (Ignore or Mo.MonActive or Conv.Active) and
            ((MldOk = 13) or (K[Kanal]^.Node)) and ((length(MemZeile) > 2) or (K[Kanal]^.Node)) then
    begin
      if FileSend then FertigSenden(Kanal);

      if not (Auto or EinstiegsKanal or AusstiegsKanal) then
         S_PAC(Kanal,NU,true,InfoZeile(120) + M1);

      if Auto and TNC_ReadOut and
         not (SplSave or (SysArt in SysMenge) or (WishDXC and SCon[11])) then
      Begin
        RemFlag := Echo in [4..7];
        if RemAll then i1 := 2
                  else i1 := 1;
        if not node then delete(MemZeile,1,2);
        KillEndBlanks(MemZeile);

        if (mail_sp) or ((not node) and (length(MemZeile) = 0)) then
         begin
          unknown := true
         end
        else
        begin
          i := REM_Auswert(Kanal,i1,MemZeile);
          if (Einstiegskanal and (i = 1)) or not Einstiegskanal
             then
             if (not Ausstiegskanal) then Remote(Kanal,i,MemZeile);
          if unknown then
          begin
            val(CutStr(MemZeile),i,i1);
            if (i1 = 0) and (i in [0..maxLink]) then
            begin
              unknown := false;
              if i = 0 then SendToChannel(Kanal,0,1,maxLink,MemZeile)
                       else SendToChannel(Kanal,0,i,i,MemZeile);
            end;
          end;
        end;
        if mail_sp then unknown:=false;
        if not Node then MemZeile:=dps + MemZeile;
        MemZeile := B1 + Memzeile;
        MemZeile:= UpCaseStr(MemZeile);
        if nun then unknown:=false;
        if unknown then
         begin
          S_PAC(Kanal,NU,false,InfoZeile(112) + MemZeile + M1);
          if Node then
           begin
            inc(UnknownCount);
            if (3-UnknownCount)=1 then S_PAC(Kanal,NU,false,+M1+InfoZeile(425));
            S_PAC(Kanal,NU,false,M1);
            if UnknownCount=3 then
             begin
              S_PAC(kanal,CM,true,'D');
              unknownCount:=0;
             end;
           end else S_PAC(Kanal,NU,false,M1);
         end else UnknownCount:=0;
        if notRC then
        begin
          S_PAC(Kanal,NU,false,InfoZeile(129) + MemZeile + M1);
          _aus(Attrib[20],Kanal,InfoZeile(300) + M1);
        end;

        if ParmWrong then S_PAC(Kanal,NU,false,InfoZeile(174) + MemZeile + M1);
        if unknown or notRC or ParmWrong then Send_Prompt(Kanal,FF);
        unknown := false;
        notRC := false;
        ParmWrong := false;
        RemFlag := false;
      end;
    end;

    if FileSend and (TX_Bin in [2,3]) then
    Begin
      if (MldOk in [6,10]) then    { #ABORT# }
      begin
        FiResult := CloseBin(TxFile);
        FileSend := false;
        AutoBinOn:=AutoBin;
        SetzeFlags(Kanal);
        if mldok=10 then S_PAC(Kanal,NU,true,M1 + InfoZeile(107) + M1)
         else S_PAC(Kanal,NU,true, M1);
      end;
      if MldOk = 9 then TX_Bin := 3;   { #OK# }
    End;

     if (MldOk=9) and (XBin.An) then
      begin
       filesend:=false;
       xbin.tx:=true;
       xbin.rtxok:=true;
       TX_Bin:=0;
       delete(Zeile,1,4);
       if (zeile[length(zeile)]=#13) then delete(zeile,length(zeile),1);
       if length(zeile)>3 then
        begin
          seek(TXFile, str_int(zeile));
          tx_count:=str_int(zeile);
        end;
      end;
                             {,26,27 *VERSCH}
    if MldOk in [19,20,21,22,26,27] then Compress_Ein_Aus(Kanal);
    case mldok of
    31..33:
        begin
         if Zeile[6]<>#32 then insert(#32,Zeile,6);
         if Zeile[length(zeile)]=#13 then delete(Zeile,Length(zeile),1);
         i:=REM_Auswert (Kanal, i, Zeile);
         if i<>254 then Remote(Kanal, i, Zeile) else
          begin
           if not Mo.MonActive then
            begin
             S_PAC(Kanal,NU,false,InfoZeile(129) + Zeile + M1);
             Send_prompt(kanal, ff);
            end;
          end;
        end;
    36: begin
        {#REQUESTNAME:NQL# - '-'=Senden, '+'=NICHT senden!}
        if (konfig.reqnam) and (not NODE) then
        begin
         BSTR:='';
         if Zeile[length(Meldung[36])+1]='+' then
          if Konfig.PersName<>'' then BSTR:=Meldung[32]+b1+Konfig.Persname+#13;
         if Zeile[length(Meldung[36])+2]='+' then
          if Konfig.PersQTH<>'' then BSTR:=Bstr+Meldung[33]+b1+Konfig.PersQTH+#13;
         if Zeile[length(Meldung[36])+3]='+' then
          if Konfig.PersLoc<>'' then BSTR:=Bstr+Meldung[31]+b1+Konfig.PersLOC+#13;
         S_PAC(kanal,NU,true,BSTR+M1);
        end;
        end;
    37: begin {//COMP ON}
          spcomp:=true;
          txcomp:=false;
          rxcomp:=true;
          CompZeile := '';
          MeldeCompZ := '';
          S_PAC(kanal,NU,true,Meldung[39]+M1);
          txcomp:=true;
          if TxComp and (PacLen > maxCompPac) then PacLen := maxCompPac;
          setzeflags(Kanal);
         end;
     38: begin {//COMP OFF}
          spcomp:=true;
          txcomp:=true;
          rxcomp:=false;
          S_PAC(kanal,NU,true,Meldung[40]+M1);
          txcomp:=false;
          spcomp:=false;
          setzeflags(Kanal);
         end;
     39: begin {//COMP 1}
          spcomp:=true;
          txcomp:=true;
          rxcomp:=true;
          CompZeile := '';
          MeldeCompZ := '';
          if TxComp and (PacLen > maxCompPac) then PacLen := maxCompPac;
          setzeflags(Kanal);
         end;
     40: begin {//COMP 0}
          spcomp:=false;
          txcomp:=false;
          rxcomp:=false;
          setzeflags(Kanal);
         end;
    end;


    if not RX_Save then Mail_sp:=false;
  end;

End;

Function FreiePuffer (* Kanal : Byte) : Word *);
Begin
  with K[Kanal]^ do
  begin
    Ausgabe := false;
    TxRxTNC(Kanal,1,'@B');
    FreiePuffer := Word(str_int(Response));
  end;
End;

Function  QuerCheck (* Zeile : String) : Word *);
Var  i,l : Byte;
     w : Word;
Begin
  l := ord(Zeile[0]);
  w := l;
  for i := 1 to l do w := w + ord(Zeile[i]);
  QuerCheck := w;
End;


Procedure Mon_Header_Auswerten;
Var  i,i1,i2,
     iz,iNr,
     fNr       : Byte;
     FehlFrame,
     IFr,UFr   : Boolean;
     Hstr      : String[25];
     Bstr      : String[80];
     Fstr      : String[50];
Begin
  if Mon_Anz > 0 then
  begin
    iNr := pos(IFrame,G^.HeaderStr);
    IFr := iNr > 0;
    if IFr then
    begin
      iNr := pos(IFrame,G^.HeaderStr) + 7;
      iNr := str_int(G^.HeaderStr[iNr]);
    end;
    UFr := pos(UFrame,G^.HeaderStr) > 0;
    Hstr := ParmStr(2,B1,G^.HeaderStr) + zu +
            ParmStr(4,B1,G^.HeaderStr) + B1;

    for i := 1 to maxLink do with K[i]^ do
    begin
      if Mo.MonActive then
      begin
        for i1 := 1 to 2 do Mo.MonNow[i1] := false;
        if Mo.MonBeide then iz := 2 else iz := 1;
        for i1 := 1 to iz do
        begin
          if pos(Mo.MonStr[i1]+B1,Hstr) > 0 then
          begin
            if Mo.MonFirst[i1] then Mo.MonFrameNr[i1] := iNr;

            FehlFrame := Mo.MonIFr and IFr and Mo.MonStrict and
                           (iNr <> Mo.MonFrameNr[i1]) and
                           (QuerCheck(K[0]^.Response) <> Mo.MonCtrl[i1][iNr]);

            if (Mo.MonUFr and UFr) or FehlFrame or
               (Mo.MonIFr and IFr and
               (not Mo.MonStrict or (iNr = Mo.MonFrameNr[i1]))) then
            begin
              Mo.MonCtrl[i1][iNr] := QuerCheck(K[0]^.Response);

              if FehlFrame then
              begin
                fNr := Mo.MonFrameNr[i1];
                Mo.MonFrameNr[i1] := iNr;
                Fstr := B1 + InfoZeile(170);
                While fNr <> iNr do
                begin
                  Fstr := Fstr + B1 + 'I' + int_str(fNr);
                  inc(fNr);
                  if fNr > 7 then fNr := 0;
                end;
              end;

              inc(Mo.MonFrameNr[i1]);
              if Mo.MonFrameNr[i1] > 7 then Mo.MonFrameNr[i1] := 0;

              if (Hstr <> Mo.MonLast) or FehlFrame then
              begin
                if not RxLRet then _aus(Mo.MonAttr,i,M1);
                if Mo.MonHCall then
                begin
                  Bstr := Hstr;
                  KillEndBlanks(Bstr);
                  if not Mo.MonEHCall then Bstr := CutStr(Bstr);
                  Bstr := LSK + Bstr + RSK + DP;
                  if IFr then Bstr := Bstr + B1 + LRK + 'I' + int_str(iNr) + RRK;
                  if FehlFrame then
                  begin
                    Bstr[1] := S_ch;
                    Bstr := Bstr + Fstr;
                  end;
                  _aus(Attrib[19],i,Bstr + M1);

                end;
              end;

              Mo.MonAttr := Attrib[25+i1];
              Mo.MonLast := Hstr;
              Mo.MonNow[i1] := true;
            end;
            Mo.MonFirst[i1] := false;
          end;
        end;
      end;
    end;
  end;
End;


Procedure TickerOut;
Var    i,i1,Attr : Byte;
Begin
  if TicAnz > 0 then
  begin
    i1 := 0;
    for i := 1 to Tnc_Anzahl do with TNC[i]^ do if Tic then
    begin
      inc(i1);
      Attr := Attrib[ColMonBeg + i * 4];
      WriteRam(1,i1,Attr,1,int_str(i) + DP + B1 + TicStr);
    end;
  end;
End;


Function  FormMonFr (* TNr : Byte; Hstr : Str5; Zeile : String) : String *);
Var    i : Byte;
Begin
  if ModMonFr then
  begin
    delete(Zeile,1,3);
    i := pos(B1+'to'+B1,Zeile);
    Zeile[i] := RSK;
    delete(Zeile,i+1,3);

    i := pos(B1+'via'+B1,Zeile);
    if i > 0 then delete(Zeile,i,4);

    i := pos(B1+'ctl'+B1,Zeile);
    if i > 0 then delete(Zeile,i,4);

    i := pos(B1+'pid'+B1,Zeile);
    if i > 0 then delete(Zeile,i,4);
  end;
  if MonID = 1 then Zeile := Hstr + Zeile;
  if MonID = 2 then Zeile := int_str(TNr) + DP + Zeile;
  FormMonFr := Zeile;
End;
