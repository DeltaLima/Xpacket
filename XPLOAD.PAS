{⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
 ≥                                                                         ≥
 ≥                             X - P a c k e t                             ≥
 ≥                                                                         ≥
 ≥                                                                         ≥
 ≥  X P L O A D . P A S                                                    ≥
 ≥                                                                         ≥
 ≥ Routinen fÅr die Ladung der verschiedenen Systemfiles beim Start von    ≥
 ≥ TOP. Ebenfalls Initialisierung der TNCs.                                ≥
 ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ}


Procedure Emblem_Zeigen;
Var  i : Byte;
Begin
  i := 1;
  Assign(G^.TFile,SysPfad + EmbDatei);
  if ResetTxt(G^.TFile) > 0 then Abbruch_XP(6,'');
  Repeat
    inc(i);
    Readln(G^.TFile,DZeile);
    WriteTxt(1,i,StartColor,DZeile);
  Until Eof(G^.TFile);
{  FiResult := CloseTxt(G^.TFile); }
  close(G^.TFile);
  XCP := 3;
End;


Procedure Ini_Start_Tnc;
var   i,i1,
      dB,N,
      KA, KA2: Byte;
      l     : LongInt;
      Chan,
      Date  : String[11];
      Zeit  : String[8];
      Fstr  : String[3];
      Istr  : String[9];
      Hstr  : String[80];
      f     : File;

Begin
  Init_HardDrive;
  for i := 1 to maxLink do
  begin
    Assign(K[i]^.DBox,Konfig.TempVerz + DBoxDatei + SFillStr(3,'0',int_str(i)));
    if WishBoxLst and (K[i]^.SysArt in SysMenge) then OpenDBox(i);
  end;


{ABFRAGE ob tnc deaktiv ist !!!!! initialisierung prÅfen!!!!}


  for N := 1 to TNC_Anzahl do  (* alle angeschlossenen TNCs in den Hostmode schalten *)
  Begin
  TNC[N]^.AfuPort := Konfig.TNC[n].AfuPort;


{$IFNDEF no_Netrom} {//db1ras}
  NodesSortieren;
{$ENDIF}

{$IFNDEF no_bake}               {//db1ras}
  TNC[N]^.MailBakenTimer:=MailBakenZeit+N-1;
{$ENDIF}
    K[0]^.TncNummer := N;
    Hstr := int_str(N) + Pkt + TncI + B1 + GL;
    if (TNC[N]^.RS232 = 5)
    then  M_aus(Attrib[28],EFillStr(65,B1,Hstr + PcxStr), 0) else
    begin
      if HwHs then Istr := 'NoIRQ'
              else Istr := 'IRQ'+ GL + int_str(COM[TNC[N]^.RS232].IRQ_Nr);

      if COM[TNC[N]^.RS232].FifoOn then i := 1
                                   else i := 0;

      M_aus(Attrib[28],EFillStr(65,B1,Hstr +
                 B1 + 'Ch'   + GL + EFillStr(2,B1,int_str(TNC[N]^.Channels)) +
                 B1 + 'COM'  + GL + int_str(TNC[N]^.RS232) +
                 B1 + 'Bd'   + GL + EFillStr(6,B1,int_str(COM[TNC[N]^.RS232].Baudrate)) +
                 B1 +          EFillStr(6,B1,Istr) +
                 B1 + 'Fifo' + GL + EFillStr(2,B1,int_str(i)) +
                 B1 + 'Po'   + GL + int_str(TNC[N]^.HF_Port) +
                 B1 + 'Mpx'  + GL + int_str(TNC[N]^.MPX) +
                 B1 + 'ID'   + GL + TNC[N]^.Ident +
                 B2), 0);
    end;
    if not TNC[N]^.TNC_im_Host then
    begin
      Switch_TNC(N);
{      tnc[n]^.tnc_im_host:=true;
      tncini(1);
      tnc[n]^.tnc_im_host:=false; }
      Switch_Hostmode(TNC[N]^.RS232,N);
      DRSI_Hostmode(N,0);
    end;
    M_aus(Attrib[28],InfoZeile(57) + ^J, 0);
  End;

  M_aus(Attrib[28],^J, 0);

  Hstr := '';

  for N := 1 to TNC_Anzahl do with TNC[N]^ do
  begin
    if Falc then for i := Kvon to Kbis do
    begin
      Ausgabe := false;
      S_PAC(i,CM,true,'@CCHAN ' + int_str(HF_Port));
    end;

    if TNC3 then for i := Kvon to Kbis do
    begin
      Ausgabe := false;
      S_PAC(i,CM,true,'#PORT' + int_str(HF_Port));
    end;

    if PCXD then
    begin
      for i := Kvon to Kbis do Hstr := Hstr + int_str(HF_Port);
      K[0]^.TncNummer := N;
      S_PAC(0,CM,true,'@PO '+ EFillStr(40,'-',Hstr));
    end;
  end;

{  TNC[N]^.TXBedarf:=False;
  TNC[N]^.TXGesperrt := TRUE;

  S_Pac(TNC[N]^.Kvon, cM, True, 'X 0'); }


  for KA := 0 to maxLink do
  begin
    with K[KA]^ do
    begin
      for N := 1 to 3 do StatusOut(KA,1,1,Attrib[9],ConstStr(B1,80),N);
      if KA > 0 then
      begin
        StatusOut(KA,1,1,Attrib[14],SFillStr(2,B1,int_str(KA)),1);
        if connected then
        begin
          AnyConnect := true;
          StatusOut(KA,4,1,Attrib[11],EFillStr(9,B1,Call),1);
          User_Name := GetName(KA,Call,dB,TRUE);
          UserInStatus(KA);
        end;

        Ausgabe := false;
        S_PAC(KA,CM,true,'C');

        if pos(' NOT ',Response) = 0 then
        begin
          if not connected then
          begin
            Kanal_benutz := true;
            ConText := Response;
            L_ON(KA,TncConStr + B1 + Response,false,false);
            AnyConnect := true;
          end;
        end else Begin
          {Connect ist zwischenzeitlich verlohren gegangen}
          connected := false;
          Auto_Init(KA);   {//db1ras}
        End;

        Check_Eig_Mail(KA,KA);
      end;
      if not connected then EraseBufferFile(ka);
      SetzeFlags(KA);
    end; (* with K[KA]^ do ... *)
  end;

  Date := Datum;
  Zeit := Uhrzeit;
  ZeitMerk := Zeit;

  for N := 1 to TNC_Anzahl do
  begin
    K[0]^.TncNummer := N;
    Ausgabe := false; S_PAC(0,CM,true,'K ' + copy(Date,4,8));
    Ausgabe := false; S_PAC(0,CM,true,'K ' + Zeit);
    Ausgabe := false; S_PAC(0,CM,true,'K1');

    Ausgabe := false;
    Pseudo := true;
    TxRxTNC(FF,1,'G');
    TNC[N]^.ExtHost := pos('INVALID',K[0]^.Response) = 0;
    if not TNC[N]^.ExtHost then Idle := false;
  end;

  multiTNC := (TNC_Anzahl > 1);

{  if TncINr > 0 then TncIniDatei := TncIniDatei + int_str(TncINr);
  TncIniDatei := TncIniDatei + Ext; }
  TncIni(0);

  Unproto := 1;
  K[0]^.TncNummer := Unproto;
  SetzeFlags(0);
  Unproto_darstellen;

  for N := 1 to TNC_Anzahl do
  begin
    K[0]^.TncNummer := N;
    Ausgabe := false;
    S_PAC(0,CM,true,'I');
    Istr := K[0]^.Response;
    Hstr := EFillStr(35,B1,int_str(N) + Pkt  + TncI + DP + B1 +
                           InfoZeile(146) + B1 + GL + B1 + Istr);
    if TNC[N]^.ExtHost then Hstr := Hstr + InfoZeile(52) + B1;
    i := TNC[N]^.RS232;
    M_aus(Attrib[28],Hstr +^J, 0);
  end;

  M_aus(Attrib[28],^J, 0);
  i1:=0;
  for KA := 1 to maxLink do
  Begin
    with K[KA]^ do
    Begin
     if tncnummer<>i1 then
      begin
       i1:=tncnummer;
       Ka2:=KA-1;
      end;
      Chan := SFillStr(2,B1,int_str(KA));
      if OwnCall = S_ch then
       begin
        OwnCall := Konfig.TNC[TNCNummer].INIA[1];

        if Konfig.TNC[TNCNummer].NodeKan > 0 then
        begin
         if Ka-KA2 > (Konfig.TNC[TNCNummer].MaxKan)-(Konfig.TNC[TNCNummer].NodeKan) then
         begin
          OwnCall:=Konfig.TNC[TNCNummer].INIA[2];
          Node:=True;
         end;
        end;
       end;

      Ausgabe := false;
      Rufz_TNC_init(KA);

      M_aus(Attrib[28],EFillStr(15,B1,LRK + Chan + RRK + DP + OwnCall), 0);
      if (KA mod 5) = 0 then M_aus(Attrib[28],^J, 0);
      if connected then
      begin
        if FirstConCh = 1 then FirstConCh := KA;
      end else
      if Mo.MonActive then
      begin
        Stat_MonitorCalls(KA);
      end else
      begin
        StatusOut(KA,4,1,Attrib[9],EFillStr(9,B1,OwnCall),1);
        StatusOut(KA,14,1,Attrib[9],ConstStr(B1,19),1);
      end;
    end;
  end;
  M_aus(Attrib[28],^J, 0);

  TNC_High_Channel_Init;

  if G^.Infostr > '' then
  begin
    _aus(Attrib[20],1,InfoZeile(97) + M1);
    _aus(Attrib[20],1,G^.InfoStr + M2);
    if Klingel then Beep(G^.RemPiepFreq,G^.RemPiepTime);
    G^.Infostr := '';
  end;

  if LogChk > 0 then
  begin
    Assign(f,Sys1Pfad + LogDatei + LngExt);
    if ResetBin(f,1) = 0 then
    begin
      l := FileSize(f);
      FiResult := CloseBin(f);
      if l > LogChk then
      begin
        _aus(Attrib[20],1,InfoZeile(29) + B1 +
                          FormByte(int_str(l)) + B1 + Bytes + M2);
        if Klingel then Beep(G^.RemPiepFreq,G^.RemPiepTime);
      end;
    end;
  end;

  if LogArt > 0 then
  begin
    Assign(G^.TFile,Sys1Pfad + LogDatei + LngExt);
    FiResult := ResetTxt(G^.TFile);
    if FiResult > 0 then FiResult := RewriteTxt(G^.TFile);
    FiResult := CloseTxt(G^.TFile);
  end;

  if Eig_Mail_Zeile > '' then
  begin
    InfoOut(1,0,1,InfoZeile(153) + Eig_Mail_Zeile);
    If Klingel then Triller;
  end;

  Assign(G^.TFile,Sys1Pfad + ConDatei);
  FiResult := EraseTxt(G^.TFile);
End;

Procedure TNC_High_Channel_Init;
var   i,i1 : Byte;
Begin
  for i := 1 to TNC_Anzahl do
  begin
    K[0]^.TncNummer := i;
    i1 := TNC[i]^.TncChannels;
    Repeat
      inc(i1);
      Pseudo := true;
      Ausgabe := false;
      TxRxTNC(i1,1,'I' + B1 + PhantasieCall);
    Until (i1 = FF) or (K[0]^.Response > '');
  end;
End;

Procedure Switch_Hostmode (* V24Nr,TNC_Nr : Byte *);
var   N,i,zhs  : Byte;
      w    : Word;
      Host,Flag : Boolean;
      ch   : Char;
      Hstr : String;

Begin
zhs:=0;
(*    for w:=1 to 10 do writeAux(V24Nr,#1);

    for i:=1 to 2 do
     begin
      clearV24Buffer;
      WriteAux(V24Nr,ESC+'JHOST0'+ M1);
      {Achtung: Steht noch ein M1 bzw. #13 vor ESC, sendet der TNC!!!}
      Wait_Read(V24Nr);
      Verzoegern(300);
     end;
*)
(* repeat
inc(zhs);  *)

  Host := false;

{  ClearV24Buffer;
  WriteAux(V24Nr,ESC+M1);
  Wait_Read(V24Nr);}

  ClearV24Buffer;
  WriteAux(V24Nr,^Q^X);
  {^Q^M^X statt JHOST0 geht auch anstatt ESC+M1, QX}
  Wait_Read(V24Nr);

  if V24Buffer[0] = 6 then
  begin
    WriteAux(V24Nr,^R^X);
    Wait_Read(V24Nr);
  end;

  ClearV24Buffer;
  WriteAux(V24Nr,ESC + 'E1'+ M1);
  Wait_Read(V24Nr);

  ClearV24Buffer;
  WriteAux(V24Nr,^X);
  Wait_Read(V24Nr);

  ClearV24Buffer;
  WriteAux(V24Nr,ESC);
  Wait_Read(V24Nr);

  if BufferPos>0 then inc(zhs,3);
(*  if BufferPos=0 then
   begin
    for i:=1 to 2 do
     begin
      clearV24Buffer;
      WriteAux(V24Nr,ESC+'JHOST0'+ M1);
      {Achtung: Steht noch ein M1 bzw. #13 vor ESC, sendet der TNC!!!}
      Wait_Read(V24Nr);
      Verzoegern(300);
     end;
   end;
until zhs>2; *)

  if BufferPos = 0 then
  begin
    if not ReSync(V24Nr) then Abbruch_XP(11,'')
                         else Host := true;
  end else ch := Chr(V24Buffer[0]);

  if not Host then
  begin
    i := 10;
    While (ch <> '*') and (i > 0) do
    begin
      Wait_Read(V24Nr);
      w := BufferPos;
      While (w > 0) and (ch <> '*') do
      begin
        dec(w);
        ch := Chr(V24Buffer[w]);
      end;
      if ch <> '*' then ClearV24Buffer;
      dec(i);
    end;

    if ch <> '*' then Abbruch_XP(14,int_str(V24Nr));
    ClearV24Buffer;
    WriteAux(V24Nr,'JHOST1' + M1);
    Wait_Read(V24Nr);
    Verzoegern(300);
  end;

  ClearV24Buffer;
End;

Procedure DRSI_Hostmode (* TNC_Nr,Art : Byte *);
Var  i,i1 : Byte;
Begin
  if Art = 0 then
  begin
    TNC[TNC_Nr]^.TNC_im_Host := true;
    i1 := TNC[TNC_Nr]^.DRSI;
    if i1 > 0 then
      for i := TNC_Nr+1 to TNC_Anzahl do
        if TNC[i]^.DRSI = i1 then TNC[i]^.TNC_im_Host := true;
  end;

  if Art = 1 then
  begin
    TNC[TNC_Nr]^.TNC_im_Host := false;
    i1 := TNC[TNC_Nr]^.DRSI;
    if i1 > 0 then
      for i := TNC_Nr+1 to TNC_Anzahl do
        if i1 = TNC[i]^.DRSI then TNC[i]^.TNC_im_Host := false;
  end;
End;


Procedure ConfigLesen;
var  i,i1,i2,i3,
     Ka,Error : Integer;
     m        : Word;
     flag     : Boolean;
     ch       : char;
     l        : LongInt;

Begin (* ConfigLesen *)



  if CFGNr > 0 then CfgDatei := CfgDatei + int_str(CFGNr);

{  WriteTxt(XCP,SZ1,StartColor,CfgDatei + Ext); }
{*** 1}
  gotoxy(1,20);
  writeln('    ⁄ ‹‹‹‹‹‹                                                              ø');
  writeln('    ¿ ﬂﬂﬂﬂﬂﬂ                                                              Ÿ');
  XCP := XCP + SZL;
  for i := 1 to MaxAnwesend do
  begin
   Anwesend[i] := NIL;
   GetMem(Anwesend[i], SizeOf(Anwesend[i]^));
   Anwesend[i]^.Call:='';
   Anwesend[i]^.Da:=False;
  end;
  Assign(G^.Config,Sys1Pfad + CfgDatei + Ext);
{  if ResetTxt(G^.Config) > 0 then Abbruch_XP(8,'');}

  {$I-} Reset(G^.Config); {$I+}
  if ioresult<>0 then Abbruch_XP(8,'');

  read(G^.config, Konfig);
  if Konfig.BackupTime=1 then Konfig.BackupTime:=2;
  TNC_Anzahl:=0;
  for i:=1 to maxTNC do
   begin

     if (konfig.tnc[i].art=0) and (i<maxTNC) then
      begin
       konfig.tnc[i]:=konfig.tnc[i+1];
       konfig.tnc[i+1].art:=0;
       konfig.tnc[i+1].maxkan:=0;
      end;
     if (konfig.tnc[i].art>0) then inc(TNC_Anzahl);
{     writeln(konfig.TNC[i].art,' ', konfig.tnc[i].baud);}
   end;
   i:=0;

  if Konfig.MaxLoginUser=0 then Konfig.MaxLoginUser:=3;
{$IFNDEF no_Netrom} {//db1ras}
  if Konfig.MaxNodes=0 then BCastKillen;
{$ENDIF}

  CRCNROM:=chr(Konfig.Teil1)+chr(Konfig.Teil2)+chr(Konfig.Teil3)+chr(Konfig.Teil4);

  Konfig.LifeTime:=Konfig.LifeTime*60;
  Config_TNC_Lesen;

  for i := 0 to maxKanal do
  begin
    K[i] := Nil;
    VorWrite[i] := Nil;
    NotCh[i] := Nil;
  end;

  for i := 0 to maxLink do   { Kanal-Record auf den Heap bringen }
  begin
    GetMem(K[i],SizeOf(K[i]^));
    FillChar(K[i]^,SizeOf(K[i]^),0);
    Var_Init(i);
  end;
  K_Record_on_Heap := true;

  Config_RAM_Lesen;
  GetMem(MH,maxMH * SizeOf(MH_Typ));
  FillChar(MH^,maxMH * SizeOf(MH_Typ),0);

                       { Zuordnung  TerminalkanÑle - TNC-KanÑle }
  for i := 1 to TNC_Anzahl do with TNC[i]^ do if Channels > 0 then
  begin
    for i1 := Kvon to Kbis do K[i1]^.TncNummer := i;
    if DRSI = 0 then
    begin
      for i1 := Kvon to Kbis do K[i1]^.TNCKanal := Chr(i1-Kvon+1);
      ExtHost := true;
    end else
    begin
      Ka := 0;
      for i1 := 1 to TNC_Anzahl do if not TNC[i1]^.ExtHost and
         (TNC[i]^.DRSI = TNC[i1]^.DRSI) and (TNC[i1]^.Channels > 0) then
      begin
        for i3 := TNC[i1]^.Kvon to TNC[i1]^.Kbis do
        begin
          inc(Ka);
          K[i3]^.TNCKanal := Chr(Ka);
        end;
        TNC[i1]^.ExtHost := true;
      end;
    end;
  end;
  for i1 := 1 to TNC_Anzahl do TNC[i1]^.ExtHost := false;

  Config_Verz_Lesen;
  Config_Allg_Lesen;
  Config_Sound_Lesen;

  if Nutze_XMS then use_XMS := XMS_Installed;

  if Nutze_EMS then
  begin
    use_EMS := EMS_Installiert;
    Vor_im_EMS := use_EMS;
  end;

{  if use_EMS then
  begin
    Writeln(G^.BootFile,EmsStr,'LIM-Version = ',EMS_Version shr 4,Pkt ,(EMS_Version and 15));
    Writeln(G^.BootFile,EmsStr,'Free = ',LongInt(EMS_FreieSeiten * 16),' Kb');
    Writeln(G^.BootFile,EmsStr,'Frame = ',Hex(EMS_Segment,4));
  end; }

{  if use_XMS then
  begin
    if HMA = 1 then Writeln(G^.BootFile,'HMA: Exist');
    DZeile := Hex(XMS_Version,3);
    insert(Pkt ,DZeile,2);
    Writeln(G^.BootFile,XmsStr,'Version = ',DZeile);
    DZeile := Hex(XMS_Treiber,3);
    insert(Pkt ,DZeile,2);
    Writeln(G^.BootFile,XmsStr,'Driver  = ',DZeile);
    Writeln(G^.BootFile,XmsStr,'Free = ',get_XMS_Free,' Kb');
  end; }

  if use_XMS then
  begin
    if (LongInt(get_XMS_Free) * 1024) > GesamtNotCh then
    begin
      use_VDisk := false;
      use_EMS := false;
    end else use_XMS := false;
  end;

  if use_EMS then
    if (EMS_FreieSeiten >= EMS_Pages_Ins) then
    begin
      use_VDisk := false;
    end else use_EMS := false;

  if not Vdisk_Exists then use_VDisk := false;

  if use_VDisk then
  begin
    {Writeln(G^.BootFile,RamStr,'Free Memory = ',}
     FormByte(int_str(DiskFree(ord(Vdisk[1])-64)));{,B1 + Bytes);}
    if (GesamtNotCh + 2048) > DiskFree(ord(Vdisk[1])-64)
       then use_VDisk := false;
  end;

  flag := false;

  if use_XMS then
  begin
  {  Writeln(G^.BootFile,XmsStr,GesamtNotCh div 1024,' Kb for Backscrollbuffer'); }
    XMS_Handle := get_XMS_Ram((GesamtNotCh div 1024) + 2);
    l := 0;
    GetMem(Page,maxNotChBuf);
    FillChar(Page^,maxNotChBuf,0);
    for i := 0 to maxLink do with K[i]^ do
    begin
      Pos_im_Scr := l;
      l := l + maxNotCh + 40;
      Data_to_XMS(@Page^[0],XMS_Handle,Pos_im_Scr,maxNotCh);
    end;
    FreeMem(Page,maxNotChBuf);
  end else
  if use_EMS then
  begin
{    Writeln(G^.BootFile,EmsStr,LongInt(EMS_Pages_Ins * 16),' Kb for Backscrollbuffer'); }
    ScrHandle := EMS_Belegen(EMS_Pages_Ins);
    for i := 0 to maxLink do with K[i]^ do
    begin
      NotCh[i] := Ptr(EMS_Segment,0);
      EMS_Seite_einblenden(i,Scr);
      FillChar(NotCh[i]^,maxNotCh,0);
    end;
  end else
  if use_VDisk then
  begin
  {  Writeln(G^.BootFile,RamStr,
          FormByte(int_str(GesamtNotCh+2048)),B1,Bytes,B1,'for Backscrollbuffer'); }
    ScrFile_erzeugen;
  end else
  begin
    if not HeapFrei(GesamtNotCh + MindestHeap) then
    begin
      flag := true;
      GesamtNotCh := 0;
      for i := 0 to maxLink do with K[i]^ do
      begin
        maxNotCh := NeuBildRam + 96;
        GesamtNotCh := GesamtNotCh + maxNotCh;
      end;
    end;
    if HeapFrei(GesamtNotCh + MindestHeap) then
    begin
     { if flag then Writeln(G^.BootFile,'Backscrollbuffer corrected !');}
      for i := 0 to maxLink do with K[i]^ do
      begin
        GetMem(NotCh[i],maxNotCh);
        FillChar(NotCh[i]^,maxNotCh,FF);
      end;
    end
    else Abbruch_XP(5,'Free RAM = ' + int_str(MaxAvail - MindestHeap) +
                       '     use = ' + int_str(GesamtNotCh) + B1 + Bytes);
  end;

  if Vor_im_EMS then Vor_im_EMS := ((EMS_FreieSeiten >= (maxLink + 1)));

  if Vor_im_EMS then
  begin
   { Writeln(G^.BootFile,EmsStr,LongInt(maxLink+1)*16,' Kb for TX-Write-Buffer');}
    VorHandle := EMS_Belegen(maxLink + 1);
    GesamtVorCh := 0;
    for i := 0 to maxLink do with K[i]^ do
    begin
      VorWrite[i] := Ptr(EMS_Segment,0);
      VorZeilen := 200;
      GesamtVorCh := GesamtVorCh + VorZeilen * 81;
      VorCmdZeilen := VorZeilen div 5;
    end;
  end else

  begin
    flag := false;
    if not HeapFrei(GesamtVorCh + MindestHeap) then
    begin
      flag := true;
      GesamtVorCh := 0;
      for i := 0 to maxLink do with K[i]^ do
      begin
        VorZeilen := 20;
        GesamtVorCh := GesamtVorCh + VorZeilen * 81;
        VorCmdZeilen := VorZeilen div 5;
      end;
    end;

    if HeapFrei(GesamtVorCh + MindestHeap) then
    begin
     { if flag then Writeln(G^.BootFile,'Tx-Write-Buffer corrected !');}
      for i := 0 to maxLink do with K[i]^ do GetMem(VorWrite[i],VorZeilen * 81);
    end else Abbruch_XP(9,'Free RAM = ' + int_str(MaxAvail - MindestHeap) +
                           '     use = ' + int_str(GesamtVorCh) + B1 + Bytes);
  end;

  for i := 0 to maxLink do with K[i]^ do
  begin
    if Vor_im_EMS then EMS_Seite_einblenden(i,Vor);
    FillChar(VorWrite[i]^,VorZeilen * 81,0);
    stC  := (VorZeilen - VorCmdZeilen) + 1;
    for i1 := stC to VorZeilen do VorWrite[i]^[i1] := CvCh;
  end;

  Config_BLIND_Lesen;

  Config_PRN_Lesen;
{  FiResult := CloseTxt(G^.Config);}
   close(G^.config);

  Assign(BuffFile,Konfig.TempVerz + BuffDatei);

  ScreenTimer := ScreenInit;
End;


Procedure Infos_Lesen;
var    Hstr    : String;
       i,i1,
       Anz,
       Groesse : Word;

Begin
{  WriteTxt(XCP,SZ1,StartColor,MsgsDatei);}
{*** 2}
  gotoxy(1,20);
  writeln('    ⁄ ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹                                                  ø');
  writeln('    ¿ ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ                                                  Ÿ');
  XCP := XCP + SZL;

  Msg := Nil;
  MsgPos := Nil;

  Anz := 0;
  Groesse := 0;
  Assign(G^.TFile,SysPfad + MsgsDatei);
  FiResult := ResetTxt(G^.TFile);
  Repeat
    Readln(G^.TFile,Hstr);
    Groesse := Groesse + ord(Hstr[0]);
    inc(Anz,2);
  Until Eof(G^.TFile);

  GetMem(Msg,Groesse);
  FillChar(Msg^,Groesse,0);

  GetMem(MsgPos,Anz);
  FillChar(MsgPos^,Anz,0);

  FiResult := ResetTxt(G^.TFile);
  i := 1;
  i1 := 1;
  Repeat
    MsgPos^[i1] := i;
    Readln(G^.TFile,Hstr);
    move(Hstr[1],Msg^[i],ord(Hstr[0]));
    i := i + ord(Hstr[0]);
    inc(i1);
  Until Eof(G^.TFile);
  FiResult := CloseTxt(G^.TFile);
  MaxMsgs:=i1-2;
  LastInfoOut := Nil;
  GetMem(LastInfoOut,SizeOf(LastInfoOut^));
  FillChar(LastInfoOut^,SizeOf(LastInfoOut^),0);
  for i := 1 to maxInfoOut do LastInfoOut^.IZ[i] := ConstStr(B1,4);

  History := Nil;
  GetMem(History,SizeOf(History^));
  FillChar(History^,SizeOf(History^),0);
End;


Procedure Strings_Lesen;
Begin
  G^.InfoDieBox  := InfoZeile(175) + B1;
  G^.UserDieBox  := InfoZeile(176) + B1;
  G^.InfoBayBox  := InfoZeile(177) + B1;
  G^.InfoTnc3Box := InfoZeile(178) + B3;
  G^.RubrikStr   := InfoZeile(179) + B1;

  G^.EzFileStr   := InfoZeile(180);
  G^.EzMsgStr    := InfoZeile(189);

  G^.RunElDir    := InfoZeile(268) + B1;
  G^.RunElFile   := InfoZeile(269) + B1;
  G^.RunElTree   := InfoZeile(270) + B1;
  G^.BinEL       := InfoZeile(271) + B1;
  G^.TxtEL       := InfoZeile(272) + B1;
  G^.DirEL       := InfoZeile(273) + B1;

  WeekDayStr := InfoZeile(86);
End;


Procedure AttributFile_Lesen;
var   i : Byte;
Begin
  if ColNr > 0 then AttrDatei := AttrDatei + int_str(ColNr);
  AttrDatei := AttrDatei + Pkt ;
{  WriteTxt(XCP,SZ1,StartColor,AttrDatei + LngExt);}
{*** 4}
  gotoxy(1,20);
  writeln('    ⁄ ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹                                         ø');
  writeln('    ¿ ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ                                         Ÿ');
  XCP := XCP + SZL;
  Assign(G^.TFile,Sys1Pfad + AttrDatei + LngExt);
  if ResetTxt(G^.TFile) <> 0 then Abbruch_XP(8,'');
  for i := 1 to maxAttr do
  begin
    Readln(G^.TFile,DZeile);
    Attrib[i] := str_int(CutStr(DZeile));
  end;
  Readln(G^.TFile,DZeile);
  HighCol := Byte(str_int(copy(DZeile,1,1))) = 1;
  FiResult := CloseTxt(G^.TFile);
End;

Procedure ESC_Lesen;
Var    i : Byte;
Begin
{  WriteTxt(XCP,SZ1,StartColor,EscDatei);}
 {*** 5}
   gotoxy(1,20);
  writeln('    ⁄ ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹                                      ø');
  writeln('    ¿ ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ                                      Ÿ');
  XCP := XCP + SZL;
  Assign(G^.TFile,SysPfad + EscDatei);
  if ResetTxt(G^.TFile) <> 0 then Abbruch_XP(8,'');
  i := 1;
  Repeat
    Readln(G^.TFile,G^.ESCP[i]);
    inc(i);
  Until Eof(G^.TFile);
  FiResult := CloseTxt(G^.TFile);
End;

Procedure QRG_Lesen;
Var   i    : Byte;
      Hstr : String[80];
      Freq : String[10];
Begin
  XCP := 3;
{  WriteTxt(XCP,SZ2,StartColor,QrgDatei);}
 {*** 6}
  gotoxy(1,20);
  writeln('    ⁄ ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹                               ø');
  writeln('    ¿ ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ                               Ÿ');
  XCP := XCP + SZL;

  Assign(G^.TFile,Sys1Pfad + QrgDatei);
  if ResetTxt(G^.TFile) <> 0 then Abbruch_XP(8,'');

  G^.QRG_Anz := 0;
  Repeat
    Readln(G^.TFile,Hstr);
    KillStartBlanks(Hstr);

    if copy(Hstr,1,1) <> LZ then
    begin
      Hstr := UpCaseStr(Hstr);
      Freq := CutStr(Hstr);
      Hstr := RestStr(Hstr);

      While Hstr > '' do
      begin
        inc(G^.QRG_Anz);
        G^.QRG[G^.QRG_Anz].CALL := CutStr(Hstr);
        G^.QRG[G^.QRG_Anz].QRG  := Freq;
        Hstr := RestStr(Hstr);
      end;
    end;

  Until (Eof(G^.TFile) or (G^.QRG_Anz >= maxQRG));
  FiResult := CloseTxt(G^.TFile);

  Assign(G^.LinkFile,Sys1Pfad + LinkDatei);
  FiResult := ResetTxt(G^.LinkFile);
  if FiResult > 0 then FiResult := RewriteTxt(G^.LinkFile);
  FiResult := CloseTxt(G^.LinkFile);

End;

Procedure REM_Lesen;
Var    tmi, mi,i    : Byte;
       Hstr : String[40];
       Remotes2: Array [1..maxREM] of REM_Type;
Begin
{  WriteTxt(XCP,SZ2,StartColor,RemDatei);}
{*** 7}
  gotoxy(1,20);
  writeln('    ⁄ ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹                       ø');
  writeln('    ¿ ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ                       Ÿ');
  XCP := XCP + SZL;

  Assign(G^.TFile,SysPfad + RemDatei);
  if ResetTxt(G^.TFile) <> 0 then Abbruch_XP(8,'');
  i := 1;
  Repeat
    Readln(G^.TFile,Hstr);
    KillStartBlanks(Hstr);
    KillEndBlanks(Hstr);
    if hstr<>'' then
    begin
    with G^.Remotes[i] do
    begin
      BefNr := str_int(CutStr(Hstr));
      Befehl := ParmStr(2,B1,Hstr);
      AnzCh := str_int(ParmStr(3,B1,Hstr));
      AnzPa := str_int(ParmStr(4,B1,Hstr));
      Level := str_int(ParmStr(5,B1,Hstr));
      LevelN:= str_int(ParmStr(6,B1,Hstr));
    end;
    inc(i);
    end;
  Until Eof(G^.TFile);
  FiResult := CloseTxt(G^.TFile);
  mi:=i-1;
  tmi:=1;

  for i:=1 to mi do
   begin
    if G^.Remotes[i].BefNr<>99 then
     begin
      Remotes2[G^.Remotes[i].BefNr]:=G^.Remotes[i];
      inc(tmi);
     end;
   end;

  for i:=1 to mi do
   begin
    if G^.Remotes[i].BefNr=99 then
     begin
      Remotes2[TMI]:=G^.Remotes[i];
      inc(tmi);
     end;
   end;

   for i:=1 to mi do
   G^.Remotes[i]:=Remotes2[i];


End;


Procedure PWD_Lesen;
Var   Hstr : String[80];
      Flag : Boolean;
Begin
  Assign(G^.TFile,Sys1Pfad + PwDatei);
  if ResetTxt(G^.TFile) = 0 then
  begin
{    WriteTxt(XCP,SZ2,StartColor,PwDatei);}
{*** 8}
  gotoxy(1,20);
  writeln('    ⁄ ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹                ø');
  writeln('    ¿ ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ                Ÿ');
    XCP := XCP + SZL;
    Repeat
      Readln(G^.TFile,Hstr);
      KillStartBlanks(Hstr);
      KillEndBlanks(Hstr);
      Flag := PWD = Hstr;
    Until Eof(G^.TFile) or Flag;
    If Flag then
    begin
      Readln(G^.TFile,Hstr);
      KillStartBlanks(Hstr);
      KillEndBlanks(Hstr);
      Priv_PassWord := EFillStr(80,'a',Hstr);
    end;
    FiResult := CloseTxt(G^.TFile);
  end;
End;


Procedure HELP_Lesen;
Var    i      : Byte;
       Hstr   : String[HlpRec];
       Result : Word;
       Found,
       EFlag  : Boolean;
Begin
  if not Exists(Konfig.TempVerz + THlpDatei) or HlpCompile then Help_Compile;
{  WriteTxt(XCP,SZ2,StartColor,EFillStr(80-XCP+1,B1,THlpDatei));}
{*** 9}
  gotoxy(1,20);
  writeln('    ⁄ ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹          ø');
  writeln('    ¿ ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ          Ÿ');
  XCP := XCP + SZL;
  Assign(G^.BFile,Konfig.TempVerz + THlpDatei);
  if ResetBin(G^.BFile,HlpRec) <> 0 then Abbruch_XP(8,'');
  Found := false;
  EFlag := false;
  Hstr := '';
  i := 0;
  Repeat
    if not Found or (Hstr = '') then
    begin
      BlockRead(G^.BFile,Hstr[1],1,Result);
      Hstr[0] := Chr(HlpRec);
      KillStartBlanks(Hstr);
      KillEndBlanks(Hstr);
      EFlag := Hstr = LZ;
      if not Found then
      begin
        Found := Hstr = OHelpStr;
        if Found then Hstr := '';
      end;
    end;

    if Found and not EFlag then
    begin
      if Hstr > '' then
      begin
        inc(i);
        G^.OHelp[i] := CutStr(Hstr);
        Hstr := RestStr(Hstr);
      end;
    end;
  Until Eof(G^.BFile) or EFlag or (i >= maxOHelp);

  FiResult := CloseBin(G^.BFile);
End;


Procedure TncIni (* Art : Byte *);
Var  N,bef,
     von,
     bis  : Byte;
     Hstr : String[4];
     Flag : Boolean;
Begin
{  Assign(G^.TFile,Sys1Pfad + TncIniDatei);
  if ResetTxt(G^.TFile) = 0 then }

  if 1=1 then
  begin

   if 1=1 then

      if 1=1 then
      begin
        von:=1; bis:=tnc_anzahl;

        if von > 0 then for N := von to bis do
        begin
        dzeile:='';
         for bef:= 1 to 17 do
          begin
           Case Bef of
            1..16:
             begin
              if (Bef in [1,2]) and (Art=0) then
               begin
                if (Konfig.TNC[N].IniA[bef]<>'') and ((bef=1) or (bef=2)) then
                      Konfig.TNC[N].IniA[bef]:='I '+Konfig.TNC[N].IniA[Bef];
               end;

              if art=0 then DZeile:=Konfig.TNC[N].iniA[bef]
                       else DZeile:=Konfig.TNC[N].DiniA[bef];
              if (Konfig.TNC[N].IniA[bef]<>'') and ((bef=1) or (bef=2)) then delete(Konfig.TNC[N].IniA[bef],1,2)
             end;
            17:
             begin
              if art=0 then DZeile:=Konfig.TNC[N].iniB
                       else DZeile:=Konfig.TNC[N].DiniB;
             end;
            end;

           while copy(dzeile,1,1)=#32 do delete(Dzeile,1,1);
           KillEndBlanks(Dzeile);

           if (Art = 0) and (Upcasestr(copy(DZeile,1,1)) = 'I') then
           begin
             DZeile := CutStr(RestStr(DZeile));
             TNC[N]^.HostCall := upcasestr(DZeile);
             DZeile := 'I ' + DZeile;
           end;
           K[0]^.TncNummer := N;
           if dzeile<>'' then S_PAC(0,CM,true,DZeile);
          end; {for bef ...}
        end;
      end;
{    Until  Eof(G^.TFile) or (copy(DZeile,1,1) = DP); }
   { FiResult := CloseTxt(G^.TFile); }
  end;

  if Art = 1 then for N := 1 to TNC_Anzahl do
  begin
    if TNC[N]^.TNC_im_Host then
    begin
      K[0]^.TncNummer := N;
      S_PAC(0,CM,true,'JHOST0');
      Verzoegern(300);
      ClearV24Buffer;
      DRSI_Hostmode(N,1);
    end;
  end;
End;


Procedure Abschluss_XP;
var      i    : Byte;
         Flag : Boolean;
Begin
  AnyConnect := false;
  for i := 1 to maxLink do if K[i]^.connected then AnyConnect := true;
  if (SSAV = 1) or ((SSAV = 2) and AnyConnect) then
  begin
    Puffer_schreiben;
  end else FiResult := EraseBin(BuffFile);

  Merker_Conn_Schreiben;
  Merker_File_schreiben;

  ReInstall;

  for i := 0 to maxLink do with K[i]^ do
  begin
    if Save then SaveFile(i);
    if WishBoxLst and (SysArt in SysMenge) then CloseDBox(i);
    if EraseChk > 0 then
    begin
      if ResetBin(DBox,1) = 0 then
      begin
        Flag := FileSize(DBox) > EraseChk;
        FiResult := CloseBin(DBox);
        if Flag then FiResult := EraseBin(DBox);
      end;
    end;
  end;

  if use_VDisk then
  begin
    if ResetBin(ScrollFile,T) = 0 then
    begin
      FiResult := CloseBin(ScrollFile);
      FiResult := EraseBin(ScrollFile);
    end;
  end;

  Writeln;
  Writeln('Ende ... ',Datum,B2,Uhrzeit);
  SetCBreak(BreakStatus);
End;

Procedure Abbruch_XP (* Nr : Byte; Zeile : Str80 *);
Var   i : Byte;
Begin
{  if TextRec(G^.Config).Mode <> fmClosed then FiResult := CloseTxt(G^.Config);}
{$I-} close(G^.config); i:=ioresult; i:=0; {$I+}
  if K_Record_on_Heap then Close_SaveFiles;
  ReInstall;
  SetzeCursor(1,25);
  Writeln(^G);
  Case Nr of
     1: Writeln('Fehler im File ',CfgDatei);
     2: Writeln('Falsche Interrupt-Nummer fÅr COM' + Zeile + ' !');
     3: Writeln('Falsche Baudrate fÅr COM ' + Zeile + ' !');
     4: Writeln('ERROR, Pfad nicht gefunden -> ' + Zeile);
     5: Writeln('Zuviel Scrollspeicher vergeben !',#10#13,Zeile);
     6: Writeln('Fehler mit Datei ',EmbDatei + ' !');
     7: Writeln('Pufferfiles fÅr Scroll konnte nicht erzeugt werden !');
     8: Writeln('File nicht gefunden, Programm abgebrochen !');
     9: Writeln('Zuviel Vorschreibspeicher vergeben !',#10#13,Zeile);
    10: Writeln('EMS-Fehler: ',EMS_errortext[str_int(Zeile)]);
    11: Writeln('Re-Synchronisation war leider nicht erfolgreich !');
    12: Writeln('TFPCR/X/DRSI-Treiber nicht gefunden !');
    13: Writeln('Schnittstelle fÅr COM-',Zeile,'  nicht installiert !');
    14: Writeln('Hostmodebetrieb des TNC an COM-',Zeile,' nicht mîglich !');
    15: Writeln('Zuviele KanÑle insgesamt vergeben, ',Zeile,' !');
  end;
  for i := 1 to maxZ do WriteAttr(1,i,80,TextAttr,1);
  PRG_Stoppen(0);
End;

Procedure ScrFile_erzeugen;
var       i      : Byte;
          l      : LongInt;
          Result : Word;
begin
  Assign(ScrollFile,VDisk + ScrollDatei);
  if RewriteBin(ScrollFile,T) = 0 then
  begin
    GetMem(Page,maxNotChBuf);
    FillChar(Page^,maxNotChBuf,0);
    l := 0;
    for i := 0 to maxLink do with K[i]^ do
    begin
      Pos_im_Scr := l;
      l := l + maxNotCh;
      BlockWrite(ScrollFile,Page^[0],maxNotCh,Result);
    end;
    FreeMem(Page,maxNotChBuf);
    FiResult := CloseBin(ScrollFile);
  end else Abbruch_XP(7,'');
end;

Function HeapFrei (* Bedarf : LongInt) : Boolean *);
Begin
  HeapFrei := MaxAvail > Bedarf;
End;

{Procedure LineRead (* Fstr : Str10 *);
var  Flag : Boolean;
     i    : Byte;
Begin
  Flag := false;
  i := 0;
  Repeat
    inc(i);
    While not Flag and not Eof(G^.Config) do
    begin
      Readln(G^.Config,DZeile);
      if copy(DZeile,1,length(Fstr)) = Fstr then
      begin
        Flag := true;
        delete(DZeile,1,pos(GL,DZeile));
      end;
    end;
    if not Flag then DZeile := '';
    if Eof(G^.Config) and not Flag then FiResult := ResetTxt(G^.Config);
  Until Flag or (i > 1);
End;
}

Function MakeString(Zahl:Integer) : String;
var mst:string;
begin
 str(Zahl, MSt);
 Makestring:=mst;
end;


Procedure Config_TNC_Lesen;
Const   PTNC    : String[5] = 'CFG:';

Var     at,T,i,i1,ta,t2,
        i2,i3   : Byte;
        TNC_Str : String[4];
        MpxNr   : Byte;
        HfPort  : Byte;
        ComNr   : Byte;
        TicFlag : Boolean;
        m       : LongInt;
        Flag    : Boolean;

Begin    {           1    2  3  4 5 6 7   8  9     10 11}
         {  CFG:TNC1=FALC,10,2M,0,3,1,3E8,10,115200,1,0 }

  for T:=1 to maxTNC do
    TNC[T]:=NIL;
  T2:=0;
  for T := 1 to maxTNC do
  begin
    at := Konfig.TNC[T].art;                      {>}
  if (konfig.tnc[t].art=0) or (konfig.TNC[t].maxKan=0)
     {and (konfig.TNC[t].maxKan<=MaxKanal)} then
   begin
     dzeile:=''
     end else
     begin
      dzeile:='WWL';
      inc(T2);

{    LineRead(PTNC + 'TNC' + int_str(T));}

    if dzeile<>'' then
    begin
      tnc_str:=tnc_art[Konfig.TNC[T].Art];

      if konfig.tnc[t].art=3 then  { TFPC }
      begin
        Interface_Exist;
        if not (DRSI_installed or TFPC_installed) then Abbruch_XP(12,'');
        ComNr := 5;
        MpxNr := 0;
      end else
      begin
        ComNr := Konfig.tnc[T].com;    { COM-Nummer }
        if not (ComNr in [1..4]) then Abbruch_XP(1,'');
      end;

      if ComNr in [1..4] then
      begin
        dzeile:='$'+Konfig.tnc[t].adresse;
        m := str_int(dzeile); { Basisadresse }
        if m > 0 then COM[ComNr].Base := m;

        case ComNr of
          1 : ComAdr1 := COM[1].Base;
          2 : ComAdr2 := COM[2].Base;
          3 : ComAdr3 := COM[3].Base;
          4 : ComAdr4 := COM[4].Base;
        end;

        m := Byte(Konfig.tnc[t].irq); { Interrupt-Nummer }
        if not (m in [0..15]) then Abbruch_XP(2,int_str(ComNr) + ' : ' + int_str(m));
        if m = 0 then HwHs := true;
        COM[ComNr].IRQ_Nr := m;

        case ComNr of
          1 : EoiPic1 := COM[1].IRQ_Nr > 7;
          2 : EoiPic2 := COM[2].IRQ_Nr > 7;
          3 : EoiPic3 := COM[3].IRQ_Nr > 7;
          4 : EoiPic4 := COM[4].IRQ_Nr > 7;
        end;

        m := LongInt(konfig.tnc[t].baud); { Baudrate }
        if (m < 1200) or (m > 115200) then Abbruch_XP(3,int_str(ComNr) + ' : ' + int_str(m));
        COM[ComNr].BaudRate := m;

        { FIFOs }
        if konfig.tnc[t].fifo then COM[ComNr].FifoCfg := $01
                 else COM[ComNr].FifoCfg := $00;
      end;

      HfPort := konfig.tnc[t].port; { HF-Portnummer }

      TicFlag := konfig.tnc[t].tickzeile;{ Tickerzeile }

      MpxNr  := konfig.tnc[t].multiplexnr; { Nummer am Multiplexer }
      if (not (MpxNr in [0..4]))    then Abbruch_XP(1,'');

      m := konfig.tnc[t].maxkan; { Kanalanzahl }

      if (m >= 0) and (maxLink <= maxKanal) then
      begin      { hier sollen ein paar KanÑle spendiert werden }
        TNC_used[T2] := true;
        {inc(TNC_Anzahl);}
        GetMem(TNC[T2],SizeOf(TNC[T2]^));
        FillChar(TNC[T2]^,SizeOf(TNC[T2]^),0);

        with TNC[T2]^ do
        begin
          {PortName:=konfig.tnc[t].portnam;}
          DRSI := 0;
          FALC := false;
          TNC3 := false;
          PCXD := false;
          ExtHost := false;
          TNC_im_Host := false;
          Kvon := 0;
          Kbis := 0;
{$IFNDEF no_Bake}       {//db1ras}
          Bake := false;
          BTimer := 20;
{$ENDIF}
          CText := 1;
          Info := 1;
          Aktuell := 1;
          QText := 1;
          Fix := 1;
          QRG_Akt := PseudoQRG;

          if TNC_Str = TNC_Art[4] then  { FALC }
          begin
            FALC := true;
            DRSI := 1;
            HF_PortStr := '@CCHAN' + B1 + int_str(HfPort);
          end;

          if TNC_Str = TNC_Art[2] then  { TNC3 }
          begin
            TNC3 := true;
            DRSI := 1;
            HF_PortStr := '#PORT' + B1 + int_str(HfPort);
          end;

          if (ComNr = 5) and DRSI_installed then
          begin
            PCXD := true;
            DRSI := 1;
            HF_PortStr := 'C' + B1 + int_str(HfPort) + DP;
          end;

          HF_Port := HfPort;
          Tic := TicFlag;
          if Tic then inc(TicAnz);
          TicStr := ConstStr(B1,TL);
          RS232 := ComNr;
          MPX := MpxNr;
          Ident := LRK + EFillStr(2,B1,konfig.tnc[t].identi) + RRK;
          HostCall := NoCall;
          Channels := m;
          TncChannels := m;
          if Channels > 0 then
          begin
            Kvon := maxLink + 1;
            Kbis := Kvon + Channels - 1;
          end;
        end;
        maxLink := maxLink + m;
        if (maxLink > maxKanal) then
         Abbruch_XP(15,LRK + int_str(maxLink) + '/' + int_str(maxKanal) + RRK);
      end;
    end;
   end;
  end;

  i1 := 1;
  for T := 1 to TNC_Anzahl do    { Zuordnung DRSI-Kennziffer }
  begin
    ComNr := TNC[T]^.RS232;
    MpxNr := TNC[T]^.MPX;
    Flag := false;

    if (TNC[T]^.DRSI > 0) and not TNC[T]^.ExtHost then
    begin
      for i := 1 to TNC_Anzahl do if (TNC[i]^.DRSI > 0) and
         not TNC[i]^.ExtHost then
      begin
        if (TNC[i]^.RS232 = ComNr) and (TNC[i]^.MPX = MpxNr) then
        begin
          TNC[i]^.DRSI := i1;
          TNC[i]^.ExtHost := true;
          Flag := true;
        end;
      end;
    end;
    if Flag then inc(i1);
  end;
  for T := 1 to TNC_Anzahl do TNC[T]^.ExtHost := false;

  for T := 1 to TNC_Anzahl do  { Feststellen, wieviel KanÑle der DRSI-TNC hat }
  begin
    i2 := TNC[T]^.DRSI;
    i3 := TNC[T]^.Channels;
    for i := 1 to TNC_Anzahl do if T <> i then
    begin
      if i2 = TNC[i]^.DRSI then i3 := i3 + TNC[i]^.Channels;
    end;
    TNC[T]^.TncChannels := i3;
  end;

End;

Procedure Config_Verz_Lesen;
Const Verz : String[5] = 'VERZ:';

var   i,i1,i2  : Integer;
      Flag     : Boolean;
      NrStr    : String[4];
      DrvStr   : String[2];
Begin
  DrvStr := copy(SysPfad,1,2);

{  LineRead(Verz + 'SAVE');}
 DZeile:=Konfig.SavVerz;
  if pos(BS,DZeile) = 1 then DZeile := DrvStr + DZeile;
  Konfig.SavVerz := UpCaseStr(CutStr(DZeile));
  if Konfig.SavVerz[length(Konfig.SavVerz)] <> BS then Konfig.SavVerz := Konfig.SavVerz + BS;
  if not PfadOk(1,Konfig.SavVerz) then Konfig.SavVerz := SysPfad;

 { LineRead(Verz + 'REM');}
  Dzeile:=konfig.RemVerz;
  if pos(BS,DZeile) = 1 then DZeile := DrvStr + DZeile;
  G^.Drive := UpCaseStr(CutStr(DZeile));
  if G^.Drive[length(G^.Drive)] <> BS then G^.Drive := G^.Drive + BS;
  if not PfadOk(0,G^.Drive) then G^.Drive := SysPfad;
  Ini_RemPath;
  G^.Merk_Drive := G^.Drive;

{  LineRead(Verz + 'MAIL');}
  Dzeile:=Konfig.MailVerz;
  if pos(BS,DZeile) = 1 then DZeile := DrvStr + DZeile;
  Konfig.MailVerz := UpCaseStr(CutStr(DZeile));
  if Konfig.MailVerz[length(Konfig.MailVerz)] <> BS then Konfig.MailVerz := Konfig.MailVerz + BS;
  if not PfadOk(1,Konfig.MailVerz) then Konfig.MailVerz := SysPfad;

{  LineRead(Verz + 'RUN');}
  Dzeile:=Konfig.RunVerz;
  if pos(BS,DZeile) = 1 then DZeile := DrvStr + DZeile;
  Konfig.RunVerz := UpCaseStr(CutStr(DZeile));
  if Konfig.RunVerz[length(Konfig.RunVerz)] <> BS then Konfig.RunVerz := Konfig.RunVerz + BS;
  if not PfadOk(1,Konfig.RunVerz) then Konfig.RunVerz := SysPfad;

  {LineRead(Verz + 'SPK');
  Dzeile:=
  if pos(BS,DZeile) = 1 then DZeile := DrvStr + DZeile;
  G^.SpkPfad := UpCaseStr(CutStr(DZeile));
  if G^.SpkPfad[length(G^.SpkPfad)] <> BS then G^.SpkPfad := G^.SpkPfad + BS;
  if not PfadOk(1,G^.SpkPfad) then G^.SpkPfad := SysPfad;
}
  {LineRead(Verz + 'BIN');}
  Dzeile:=Konfig.BinVerz;
  if pos(BS,DZeile) = 1 then DZeile := DrvStr + DZeile;
  Konfig.BinVerz := UpCaseStr(CutStr(DZeile));
  if Konfig.BinVerz[length(Konfig.BinVerz)] <> BS then Konfig.BinVerz := Konfig.BinVerz + BS;
  if not PfadOk(1,Konfig.BinVerz) then Konfig.BinVerz := SysPfad;

  {LineRead(Verz + '7PL');}
  Dzeile:=Konfig.SplVerz;
  if pos(BS,DZeile) = 1 then DZeile := DrvStr + DZeile;
  Konfig.splverz := UpCaseStr(CutStr(DZeile));
  if Konfig.splVerz[length(Konfig.SplVerz)] <> BS then Konfig.SplVerz := Konfig.SplVerz + BS;
  if not PfadOk(1,Konfig.SplVerz) then Konfig.SplVerz := SysPfad;

  {LineRead(Verz + 'TMP');}
  DZeile:=Konfig.TempVerz;
  if pos(BS,DZeile) = 1 then DZeile := DrvStr + DZeile;
  Konfig.TempVerz := UpCaseStr(CutStr(DZeile));
  if Konfig.TempVerz[length(Konfig.TempVerz)] <> BS then Konfig.TempVerz := Konfig.TempVErz + BS;
  if not PfadOk(1,Konfig.TempVErz) then Konfig.TempVerz := SysPfad;

  {LineRead(Verz + 'MAK');}
  Dzeile:=konfig.MakVerz;
  if pos(BS,DZeile) = 1 then DZeile := DrvStr + DZeile;
  Konfig.MakVerz := UpCaseStr(CutStr(DZeile));
  if Konfig.MakVerz[length(Konfig.MakVerz)] <> BS then Konfig.MakVerz := Konfig.MakVerz + BS;
  if not PfadOk(1,Konfig.MakVerz) then Konfig.MakVerz := SysPfad;

  if Konfig.spkVerz[length(Konfig.spkVerz)] <> BS then Konfig.spkVerz := Konfig.spkVerz + BS;
  if not PfadOk(1,Konfig.spkVerz) then Konfig.spkVerz := SysPfad;

  Flag := false;
   {LineRead(Verz + 'VDRV');}
   {DZeile:='';}
   DZeile:=Konfig.TempVerz;
  if (DZeile > '') and Vdisk_Exists then
  begin
    VDisk := DZeile; {UpCaseStr(copy(DZeile,1,1)) + DP + BS;}
    if not PfadOk(1,VDisk) then Flag := true;
  end else Flag := true;
  if Flag then
  begin
    Vdisk_Exists := false;
    VDisk := SysPfad[1] + DP + BS;
  end;

  {LineRead(Verz + 'CDRV');}
  Dzeile:=Konfig.CDRom;
  if DZeile > '' then
  begin
    RomDisk := DZeile + DP + BS;
    if PfadOk(0,RomDisk) then Rom_Exists := true;
  end;

  {LineRead(Verz + 'EDI');}
  {G^.Ext_Edi_Path := Konfig.EditVerz;} {UpCaseStr(CutStr(DZeile));}

{  LineRead(Verz + 'VIEW'); }
  {Konfig.ViewVerz := Konfig.ViewVerz;} {UpCaseStr(CutStr(DZeile));}
End;


Procedure Config_Allg_Lesen;
Const Allg : String[5] = 'ALLG:';
var iza : byte;

var   b        : Byte;
      w        : Word;
      i,i1,i2  : Integer;
      Flag     : Boolean;
      NrStr    : String[4];
      h1, h2   : str4;
Begin

  {LineRead(Allg + 'TIME');}

    ZeitArt := EFillStr(3,B1,Konfig.ZeitBez);
    ZeitDiff := Konfig.UTCDiff;;
    if (ZeitDiff < -23) or (ZeitDiff > 23) then ZeitDiff := 0;
    RTC := Konfig.Echtzeit;
    UseUTC := Konfig.UTCBenutzen;

{ LineRead(Allg + 'POP');}
  Box_Time := Konfig.PopupZeit;

{ LineRead(Allg + 'LIT'); }
  LockInt := Konfig.LockIRQ;


  {LineRead(Allg + 'SABF');}{sicherheitsabfragen j/n}

    SiAltD := Konfig.SichAbfr;
    SiAltK := SiAltD;

    G^.PromptStr := Konfig.PromptS;

    if (Konfig.NTimeout>0) and (konfig.NTimeout<10) then Konfig.NTimeout:=10;
    if (Konfig.TTimeout>0) and (Konfig.TTimeout<10) then Konfig.TTimeOut:=10;

    NTimeOut     := Konfig.NTimeOut;

    quietZeitG   := konfig.QuietZg;
    if Konfig.QuietDh then
     begin
      Quiet:=true;
      quietZeitG:=false;
     end;
    for iza := 1 to 3 do
     begin
      if konfig.quietzt[iza].stdanf=0 then h1:='0' else h1:='';
      if konfig.quietzt[iza].minanf=0 then h2:='0' else h2:='';
      quietztenan[iza]:=''; quietztenaus[iza]:='';
      quietZtenAn[iza]:=h1+int_str(Konfig.quietzt[iza].StdAnf)+ ':' +h2+int_str(Konfig.quietzt[iza].MinAnf);

      if konfig.quietzt[iza].stdend=0 then h1:='0' else h1:='';
      if konfig.quietzt[iza].minend=0 then h2:='0' else h2:='';
      quietZtenaus[iza]:=h1+int_str(Konfig.quietzt[iza].StdEND)+ ':' +h2+int_str(Konfig.quietzt[iza].MinEnd);

     end;

 {LineRead(Allg + 'IDLE');}
  idle := Konfig.IDLE;

  ScreenInit:=Konfig.ScrSavZ;

{$IFNDEF no_Bake}       {//db1ras}
  MailBakenZeit:=Konfig.MailFrameZeit;
  MailBake:=Konfig.OwnMailFr;
{$ENDIF}
End;

Procedure Config_PRN_Lesen;
Const   Druck : String[5] = 'PRN:';

var     i,i1,Anz : Byte;
        Hstr  : String[4];
Begin
  {LineRead(Druck + 'PORT');}

    PrtPort := Konfig.LPTNr;
    if not (PrtPort in [1..4]) then PrtPort := 1;
    if pos(Km,DZeile) > 0 then
       LPT_Base[PrtPort] := str_int('$' + Konfig.LPTAdr);
  LPT_vorhanden := LPT_Base[PrtPort] > 0;

  for i := 1 to 10 do
  begin
  {*} lptEsc[i]:='';
    {LineRead(Druck + 'PAR' + int_str(i-1));}
    Dzeile:='';
    if DZeile > '' then
    begin
      Hstr := ParmStr(1,Km,DZeile);
      Anz := ParmAnz;
      Hstr := '';
      if Anz in [1..20] then for i1 := 1 to Anz do
      begin
        Hstr := Hstr + chr(str_int(ParmStr(i1,Km,DZeile)));
      end;
      LptEsc[i] := Hstr;
    end;
  end;
End;

Procedure Config_RAM_Lesen;
Const  Ram   : String[4] = 'RAM:';

var    i     : Byte;
       maxCh : Word;
       maxSt : Byte;

  Procedure Berechnen(Kanal : Byte);
  Var    i1 : Integer;
  Begin
    with K[Kanal]^ do
    begin
      if maxNotCh mod 16 <> 0 then inc(PagesAnz);
      PagesAnz := PagesAnz + (maxNotCh div 16);
      EMS_Pages_Ins := EMS_Pages_Ins + PagesAnz;
      for i1 := 0 to PagesAnz-1 do PagesNot[i1] := EMS_Pages_Ins - PagesAnz + i1;
      maxNotCh := maxNotCh * 1024;
      if maxNotCh < NeuBildRam then maxNotCh := NeuBildRam + 96;
      GesamtNotCh := GesamtNotCh + maxNotCh;

      if not (VorZeilen in [10..maxVorZeilen]) then VorZeilen := 20;


      GesamtVorCh := GesamtVorCh + VorZeilen * 81;
      VorCmdZeilen := VorZeilen div 5;
    end;
  End;

Begin
  {LineRead(Ram + 'MH');}

    maxMH := Konfig.MH;
    if not (maxMH in [10..200]) then maxMH := 25;

  {LineRead(Ram + 'ALL');}
    maxCh := Konfig.BackScRam;
    maxSt := Konfig.VorschZRam;
    if maxCh > 63 then maxCh := 63;
    for i := 0 to maxLink do with K[i]^ do
    begin
      maxNotCh := maxCh;
      VorZeilen := maxSt;
      Berechnen(i);
    end;
  if Konfig.BufferDat then SSAV:=1 else SSAV:=0;
End;



Procedure Config_BLIND_Lesen;
Const  BLN : String[5] = 'BLND:';

var   i : Byte;
Begin
  HardCur  := Konfig.SoftHardC;

  Win_Rout := Konfig.WinRout;

  Win_Time := Konfig.WinRoutTime;

  Braille80 := Konfig.AchzigBrail;

   for i := 1 to maxLink do K[i]^.RX_Datenpieps := Konfig.RXBeepStart;

  WCTRL := Konfig.Steuerz;

  BLTON := Konfig.MarkTon;

  BiosOut := Konfig.AusgabeBios;
End;

Procedure Puffer_schreiben;
var       i,i1   : Integer;
          Result : Word;
          VorZ   : Word;
          CmdZ   : Word;
Begin
  if RewriteBin(BuffFile,T) = 0 then
  begin
    InfoOut(show,0,0,InfoZeile(98) + B1 + BuffDatei);
    GetMem(Page,maxNotChBuf);
    FillChar(Page^,maxNotChBuf,0);

    BlockWrite(BuffFile,maxLink,SizeOf(maxLink),Result);
    BlockWrite(BuffFile,Mon_Anz,SizeOf(Mon_Anz),Result);

    move(MH^,Page^,maxMH * SizeOf(MH_Typ));
    BlockWrite(BuffFile,Page^,maxMhRec * SizeOf(MH_Typ),Result);

    for i := 0 to maxLink do with K[i]^ do
    begin
      BlockWrite(BuffFile,NotPos,SizeOf(NotPos),Result);
      BlockWrite(BuffFile,RxLRet,SizeOf(RxLRet),Result);
      BlockWrite(BuffFile,X2,SizeOf(X2),Result);
      BlockWrite(BuffFile,Mo,SizeOf(Mo),Result);
      BlockWrite(BuffFile,BoxStr,SizeOf(BoxStr),Result);
      BlockWrite(BuffFile,NZeile,SizeOf(NZeile),Result);
      BlockWrite(BuffFile,ACMerk,SizeOf(ACMerk),Result);
      BlockWrite(BuffFile,CompZeile,SizeOf(CompZeile),Result);
      BlockWrite(BuffFile,SendZeile,SizeOf(SendZeile),Result);

      VorZ := VorZeilen - VorCmdZeilen;
      CmdZ := VorCmdZeilen;
      FillChar(Page^,maxNotChBuf,0);
      if Vor_im_EMS then EMS_Seite_einblenden(i,Vor);
      move(VorWrite[i]^[1],Page^,VorZ * 81);
      move(VorWrite[i]^[VorZ+1],Page^[maxVz*81+1],CmdZ * 81);
      BlockWrite(BuffFile,Page^,maxVorZeilen * 81,Result);

      if use_VDisk then
      begin
        FiResult := ResetBin(ScrollFile,T);
        Seek(ScrollFile,Pos_im_Scr);
        FillChar(Page^,maxNotChBuf,0);
        BlockRead(ScrollFile,Page^[0],maxNotCh,Result);
        FiResult := CloseBin(ScrollFile);
        BlockWrite(BuffFile,Page^,maxNotChBuf,Result);
      end else
      if use_XMS then
      begin
        FillChar(Page^,maxNotChBuf,0);
        XMS_to_Data(@Page^[0],XMS_Handle,Pos_im_Scr,maxNotCh);
        BlockWrite(BuffFile,Page^,maxNotChBuf,Result);
      end else
      begin
        if use_EMS then EMS_Seite_einblenden(i,Scr);
        FillChar(Page^,maxNotChBuf,0);
        move(NotCh[i]^,Page^,maxNotCh);
        BlockWrite(BuffFile,Page^,maxNotChBuf,Result);
      end;
    end;

    FreeMem(Page,maxNotChBuf);
    FiResult := CloseBin(BuffFile);
    Neu_Bild;
  end;
End;

Procedure Config_SOUND_Lesen;
begin
 {AdLibFM:=Str_int('$'+konfig.MidiADR);}
end;



Procedure Puffer_lesen;
var       i,i1   : Byte;
          max    : Byte;
          Result : Word;
          VorZ   : Word;
          CmdZ   : Word;
          w      : Word;
          Flag   : Boolean;
Begin
  if ResetBin(BuffFile,T) = 0 then
  begin
{    WriteTxt(XCP,SZ2,StartColor,BuffDatei); }
{*** 10}
  gotoxy(1,20);
  writeln('    ⁄ ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹     ø');
  writeln('    ¿ ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ     Ÿ');
    GetMem(Page,maxNotChBuf);
    FillChar(Page^,maxNotChBuf,0);

    BlockRead(BuffFile,max,SizeOf(maxLink),Result);
    if max > maxLink then max := maxLink;
    BlockRead(BuffFile,Mon_Anz,SizeOf(Mon_Anz),Result);

    BlockRead(BuffFile,Page^,maxMhRec * SizeOf(MH_Typ),Result);
    move(Page^,MH^,maxMH * SizeOf(MH_Typ));

    for i := 0 to max do with K[i]^ do
    begin
      BlockRead(BuffFile,NotPos,SizeOf(NotPos),Result);
      BlockRead(BuffFile,RxLRet,SizeOf(RxLRet),Result);
      BlockRead(BuffFile,X2,SizeOf(X2),Result);
      BlockRead(BuffFile,Mo,SizeOf(Mo),Result);
      BlockRead(BuffFile,BoxStr,SizeOf(BoxStr),Result);
      BlockRead(BuffFile,NZeile,SizeOf(NZeile),Result);
      BlockRead(BuffFile,ACMerk,SizeOf(ACMerk),Result);
      BlockRead(BuffFile,CompZeile,SizeOf(CompZeile),Result);
      BlockRead(BuffFile,SendZeile,SizeOf(SendZeile),Result);

      for i1 := 1 to 2 do with Mo do
      begin
        MonFirst[i1] := true;
        MonFrameNr[i1] := 0;
      end;

      VorZ := VorZeilen - VorCmdZeilen;
      CmdZ := VorCmdZeilen;
      if Vor_im_EMS then EMS_Seite_einblenden(i,Vor);
      FillChar(Page^,maxNotChBuf,0);
      BlockRead(BuffFile,Page^,maxVorZeilen * 81,Result);
      move(Page^,VorWrite[i]^[1],VorZ * 81);
      move(Page^[maxVz*81+1],VorWrite[i]^[VorZ+1],CmdZ * 81);

      Flag := NotPos > maxNotCh;
      if Flag then NotPos := 0;

      if use_VDisk then
      begin
        FillChar(Page^,maxNotChBuf,0);
        BlockRead(BuffFile,Page^,maxNotChBuf,Result);
        if Flag then FillChar(Page^,maxNotChBuf,0);
        FiResult := ResetBin(ScrollFile,T);
        Seek(ScrollFile,Pos_im_Scr);
        BlockWrite(ScrollFile,Page^[0],maxNotCh,Result);
        FiResult := CloseBin(ScrollFile);
      end else
      if use_XMS then
      begin
        FillChar(Page^,maxNotChBuf,0);
        BlockRead(BuffFile,Page^,maxNotChBuf,Result);
        if Flag then FillChar(Page^,maxNotChBuf,0);
        Data_to_XMS(@Page^[0],XMS_Handle,Pos_im_Scr,maxNotCh);
      end else
      begin
        if use_EMS then EMS_Seite_einblenden(i,Scr);
        FillChar(Page^,maxNotChBuf,0);
        BlockRead(BuffFile,Page^,maxNotChBuf,Result);
        if Flag then FillChar(Page^,maxNotChBuf,0);
        move(Page^,NotCh[i]^,maxNotCh);
      end;
    end;
    FiResult := CloseBin(BuffFile);
    FreeMem(Page,maxNotChBuf);

    for i := 0 to maxLink do with K[i]^ do
    begin
      if Vor_im_EMS then EMS_Seite_einblenden(i,Vor);
      for i1 := (VorZeilen - VorCmdZeilen) + 1 to VorZeilen do
      begin
        delete(VorWrite[i]^[i1],1,2);
        VorWrite[i]^[i1] := CvCh + VorWrite[i]^[i1];
      end;
    end;
  end;
  gotoxy(1,20);
{*** 11 }
  writeln('    ⁄ ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ ø');
  writeln('    ¿ ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ Ÿ');
End;


Procedure VorCurEnd;
Var  i     : Byte;
     CMerk : Boolean;
Begin
  for i := 0 to maxLink do with K[i]^ do
  begin
    CMerk := Cmd;
    Cmd := true;
    Chr_Cmd_Show(i,_CtrlPgDn,#255);
    if VorWrite[i]^[stC] <> CvCh then Chr_Cmd_Show(i,_Dn,#255);
    Cmd := false;
    Chr_Vor_Show(i,_CtrlPgDn,#255);
    if VorWrite[i]^[stV] > '' then Chr_Vor_Show(i,_Dn,#255);
    Cmd := CMerk;
  end;
end;

Procedure Interface_Exist;
Type  KArrayTyp = array [1..11] of Char;

Var   KPointer  : Pointer;
      KArray    : ^KArrayTyp;
      KStr      : String[11];
Begin
  if not (TFPC_Installed or DRSI_Installed) then
  begin
    Kiss_Int := $3F;
    Repeat
      Inc(Kiss_Int);
      GetIntVec(Kiss_Int,KPointer);
      KArray := KPointer;
      move(KArray^[1],Kstr[1],11);
      Kstr[0] := #11;

      if (pos(MatchTFPC,Kstr) = 4)  then TFPC_installed := true
      else if
         (pos(MatchDRSI1,Kstr) = 1) and
         (pos(MatchDRSI2,Kstr) = 6) then DRSI_installed := true;
    Until TFPC_installed or DRSI_installed or (Kiss_Int >= $FF);
  end;
End;


Procedure GenCrcTab;
Const  CRCBIT : Array [1..8] of Word = ($9188,$48C4,$2462,$1231,
                                        $8108,$4084,$2042,$1021);
       BITTAB : Array [1..8] of Byte = (128,64,32,16,8,4,2,1);

Var   i,i1 : Byte;

Begin
  for i := 0 to FF do
  begin
    G^.CrcFeld[i] := 0;
    for i1 := 1 to 8 do if (BITTAB[i1] and i) > 0 then
           G^.CrcFeld[i] := G^.CrcFeld[i] xor CRCBIT[i1];
  end;
END;


Procedure GenPrivPWD;
Var  i    : Byte;
     Hstr : String[80];
     f    : Text;
Begin
  Randomize;
  Hstr := '';
  Repeat
    i := Random(123);
    if i in [33,34,36..43,45..58,60..122] then Hstr := Hstr + Chr(i);
  Until length(Hstr) >= 80;
  Assign(f,Sys1Pfad + PwDatei);
  if AppendTxt(f) = 0 then
  begin
    Writeln(f);
    Writeln(f,PWD);
    Writeln(f,Hstr);
    FiResult := CloseTxt(f);
  end;
End;


Procedure UebergabeAuswert;
Var    Hstr    : String[80];
       Bstr    : String[80];
       i       : Byte;
       unknown : Boolean;

  Function Sequenz(s : Str60) : Boolean;
  begin
    if pos(s,Hstr) > 0 then
    begin
      unknown := false;
      Sequenz := true;
    end else Sequenz := false;
  end;

Begin
  Hstr := UpCaseStr(ParamZeile^);
  KillEndBlanks(Hstr);
  unknown := true;
  for i:=1 to MaxParm do
   if ParmCmd[i]=Hstr then unknown:=false;
  if Hstr='' then unknown:=false;
  if Sequenz(ParmCmd[1]) then Nutze_EMS := false;    (* NOEMS *)
  if Sequenz(ParmCmd[2]) then Nutze_XMS := false;    (* NOXMS *)
  if Sequenz(ParmCmd[3]) then Vdisk_Exists := false; (* NORAM *)
  if Sequenz(ParmCmd[4]) then OVRtoEMS := false;     (* NEOVR *)
  if Sequenz(ParmCmd[5]) then HwHs := true;          (* HS *)
  if Sequenz(ParmCmd[6]) then ColNr := str_int(Hstr[pos(ParmCmd[7],Hstr)+1]);  (* F *)
  if Sequenz(ParmCmd[7]) then CRC_PR_EXE := true;    (* CRC *)

{  if Sequenz(ParmCmd[10]) then                       (* NET *)
  begin
    Sys1Pfad := copy(Hstr,pos(ParmCmd[10],Hstr),80);
    delete(Sys1Pfad,1,3);
    Sys1Pfad := CutStr(Sys1Pfad);
    if Sys1Pfad[length(Sys1Pfad)] <> BS then Sys1Pfad := Sys1Pfad + BS;
  end; }
  if Sequenz(ParmCmd[8]) then                       (* VER *)
  begin
    Writeln;
    Writeln(Version + B2 + lastEdit);
    Halt(0);
  end;
  if Sequenz(ParmCmd[9]) then HlpCompile := true;   (* HLP *)
  if Sequenz(ParmCmd[10]) then GenPrivPWD;           (* PWD *)
  if Sequenz(ParmCMD[11]) then OVRtoXMS := false;     (* NXOVR *)
  if unknown then
  begin
    Writeln;
    for i := 1 to maxParm do
    begin
      Write(B3 + EFillStr(6,B1,ParmCmd[i]));
      if i mod 5 = 0 then Writeln;
    end;
    Writeln;
    Halt(0);
  end;
End;


Procedure Sicherung_Speichern; {Backup - Puffer, Con und Merker sichern, ohne Prog zu beenden}
var i:byte;
begin
if not backupbremsen then
begin
 BackUpLauf:=true;
   Cursor_Aus;
   G^.Fstr[7] := InfoZeile(458);
   G^.Fstx[11] := 3;
   Fenster(7);
   delay(100);
  AnyConnect := false;
  for i := 1 to maxLink do
   begin
    if K[i]^.connected then AnyConnect := true;
{    if (K[i]^.RXSave) or (K[i]^.Save) or (K[i]^.Splus and K[i]^.Splsave)}
   end;
  {if (SSAV = 1) or ((SSAV = 2) and AnyConnect) then
  begin}
    Puffer_schreiben;
{  end else FiResult := EraseBin(BuffFile);}
  Merker_Conn_Schreiben;
  Merker_File_schreiben;
  BackUpLauf:=false;
  clrFenster;
end; {if not backup_bremsen}
end;
