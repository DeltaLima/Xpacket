{⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
 ≥                                                                         ≥
 ≥                             X - P a c k e t                             ≥
 ≥                                                                         ≥
 ≥                                                                         ≥
 ≥  X P M R K . P A S                                                      ≥
 ≥                                                                         ≥
 ≥ Routinen zum Lesen und Schreiben des Merkerfiles  MERKER.TOP            ≥
 ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ}


Procedure Merker_Conn_Schreiben;
var  i,i1 : Byte;
     obf: Byte;
     CDat: File Of MemoCTyp;
     ConDat : ^MemoCTyp;

Begin
  ConDat:=NIL;
  GetMem(ConDat, SizeOf(MemoCTyp));
  Assign(CDat,Sys1Pfad + ConDatei);
  {$I-}
   Rewrite(CDat);
   obf:=ioresult;
  {$I+}
  if obf=0 then
  begin
  i:=1;
  while (i<=MaxLink) do
  begin
   if not K[i]^.connected then K[i]^.Call:='';
    ConDat^.Call:=K[i]^.Call;
    ConDat^.QSO_Date:=K[i]^.qso_date;
    ConDat^.Qso_begin:=k[i]^.QSO_Begin;
    condat^.ConText:=k[i]^.context;
    condat^.eingangskanal:=K[i]^.Einstiegskanal;
    condat^.ausgangskanal:=K[i]^.Ausstiegskanal;
    condat^.Gegenkanal:=K[i]^.Gegenkanal;
    ConDat^.HoldLauf:=K[i]^.HoldLauf;
    ConDat^.Hold:=K[i]^.Hold;
    ConDat^.HoldTime:=K[i]^.HoldTime;
    ConDat^.Holdstr:=K[i]^.Holdstr;
    condat^.userart:=k[i]^.UserArt;
    condat^.Sysart:=k[i]^.SysArt;
    condat^.SystemErkannt :=K[i]^.SystemErkannt;
    conDat^.OnAct:=K[i]^.OnAct;
    ConDat^.RemAll :=K[i]^.RemAll;
    ConDat^.SelfSysop:=K[i]^.SelfSysop;

    condat^.cv1:=1; condat^.cv2:=81;
    write(cdat, condat^);
   inc(i);
  end;
  {$I-}
  Close(CDat);
  obf:=ioresult;
  {$I+}
  end;
  FreeMem(ConDat, SizeOf(MemoCTyp));
End;


Procedure Merker_Conn_Lesen;
Var  obf,i : Byte;
     cdat:file of MemoCTyp;
     ConDat : ^MemoCTyp;


Begin
 ConDat:=NIL;
 GetMem(ConDat, SizeOf(MemoCTyp));
  Assign(CDat,Sys1Pfad + ConDatei);
  {$I-}
  Reset(Cdat);
  obf:=ioresult;
  if OBF = 0 then
  begin
  i:=0;
    while (i<MaxLink) and (not EOF(CDat)) do
    begin
    inc(i);
     read(CDat, ConDat^);
      if ConDat^.Call > '' then
      begin
        K[i]^.Einstiegskanal:=condat^.eingangskanal;
        K[i]^.Ausstiegskanal:=condat^.ausgangskanal;
        K[i]^.Gegenkanal:=condat^.Gegenkanal;
        K[i]^.Call := condat^.call;
        K[i]^.QSO_Date := ConDat^.Qso_Date;
        k[i]^.QSO_Begin := condat^.qso_begin;
        K[i]^.ConText := ConDat^.ConText;
        K[i]^.HoldLauf:= ConDat^.HoldLauf;
        K[i]^.Hold:= ConDat^.Hold;
        K[i]^.HoldTime:= ConDat^.HoldTime;
        K[i]^.Holdstr:= ConDat^.Holdstr;
        K[i]^.SysArt := condat^.sysart;
        K[i]^.UserArt := condat^.userart;
        K[i]^.SystemErkannt:=condat^.SystemErkannt;
        K[i]^.First_Frame:=false;
        K[i]^.RemAll:=ConDat^.RemAll ;
        K[i]^.SelfSysop:=ConDat^.SelfSysop;
        K[i]^.OnAct   := condat^.OnAct;
        if K[i]^.Onact <> '' then _OnAct:=true;
        if K[i]^.SysArt in [0..maxSCon] then K[i]^.SCon[K[i]^.SysArt] := true
                                    else K[i]^.SysArt := 0;
          if (K[i]^.SysArt = 11) and HoldDXc then
          begin
            DZeile := HoldDXcStr;
            Link_erhalter(i,DZeile);
            SetzeFlags(i);
          end;
          if K[i]^.Sysart in [1,2,3,4,5,11,12,14] then K[i]^.SCon[0]:=false else K[i]^.scon[0]:=true;
          {if not(K[i]^.UserArt in [1..maxUser]) then K[i]^.UserArt := 1;}
        K[i]^.connected := true;
        K[i]^.TermTimeOut:=Konfig.TTimeout * 60;
        K[i]^.NodeTimeOut:=NTimeout * 60;
      end;
    end;
    close(Cdat);
    obf:=ioresult;
  end;
  {$I+}
  FreeMem(ConDat, SizeOf(MemoCTyp));
End;




{
Procedure Merker_File_Schreiben;
Var       i,i1  : Integer;
          Kanal : Byte;
          Hstr  : String[80];

Begin
  Assign(G^.TFile,Sys1Pfad + MerkDatei + Ext);
  if RewriteTxt(G^.TFile) = 0 then
  Begin
    Writeln(G^.TFile,LZ);
    for i := 1 to maxTNC do if TNC_used[i] then with TNC[i]^ do
    begin
      if BText = '' then BText := 'CQ';
      Writeln(G^.TFile,Rrtn,i,':BT=',BText);
      if BPfad = '' then BPfad := 'ALL';
      Writeln(G^.TFile,Rrtn,i,':BP=',BPfad);
      if Bake then Write(G^.TFile,Rrtn,i,Rpar,GL,'1,')
              else Write(G^.TFile,Rrtn,i,Rpar,GL,'0,');
      Write(G^.TFile,BTimer,Km);
      Write(G^.TFile,CText,Km);
      Write(G^.TFile,Info,Km);
      Write(G^.TFile,Aktuell,Km);
      Write(G^.TFile,QText,Km);
      Write(G^.TFile,Fix,Km);
      Writeln(G^.TFile,QRG_Akt);
    end else
    begin
      Writeln(G^.TFile,Rrtn,i,':BT=','CQ');
      Writeln(G^.TFile,Rrtn,i,':BP=','ALL');
      Writeln(G^.TFile,Rrtn,i,Rpar,GL,'0,20,1,1,1,1,1');
    end;

    Writeln(G^.TFile,LZ);

    for Kanal := 0 to maxLink do
    Begin
      Writeln(G^.TFile,LZ);
      with K[Kanal]^ do
      begin
        if Kanal > 0 then
        begin
          if OwnCall = '*' then OwnCall := TNC[TncNummer]^.HostCall;
          Writeln(G^.TFile,Rrch,Kanal,':CALL=',OwnCall);
          if AutoZyConst > 0 then
             Writeln(G^.TFile,Rrch,Kanal,':AUTO=',AutoZyConst);
        end;

        Writeln(G^.TFile,Rrch,Kanal,
         Rpar + GL,MaxFrame,Km,PacLen,Km,ObStat,Km,UnStat,Km,UmlautMerk);

        if RX_Save then
        begin
          CloseRxFile(Kanal,1);
          Writeln(G^.TFile,Rrch,Kanal,':RXS=',FRxName);
          RX_Save := false;
          RX_Bin := 0;
        end;

        if Save then
        begin
          FiResult := CloseBin(SFile);
          Writeln(G^.TFile,Rrch,Kanal,':SAV=',FName_aus_FVar(SFile));
          Save := false;
        end;

        if SPlus and SplSave then
        begin
          Writeln(G^.TFile,Rrch,Kanal,':7PL=',FName_aus_FVar(SplFile),' ',
                  Spl_gLaenge,' ',Spl_gCount,' ',Spl_tLaenge,' ',Spl_tCount);
          FiResult := CloseBin(SplFile);
          SplSave := false;
        end;

        Write(G^.TFile,Rrch,Kanal,':FLAG=');

        if Umlaut > 0 then     Write(G^.TFile,'U',Umlaut);
        if Echo > 0 then       Write(G^.TFile,'E',Echo);
        if not Gross then      Write(G^.TFile,'Y');

        if Kanal > 0 then
        begin
          if Auto then         Write(G^.TFile,'F');
          if TopBox then       Write(G^.TFile,'M');
          if Rx_Beep then      Write(G^.TFile,'Ï');
          if morsen then       Write(G^.TFile,'C');
          if TxBeepAck then    Write(G^.TFile,'Q');
       (*   if Speek then        Write(G^.TFile,'P'); *)
          if AutoBin then      Write(G^.TFile,'$');
          if SPlus then        Write(G^.TFile,'+');
          if TxComp then       Write(G^.TFile,'¯');
          if RxComp then       Write(G^.TFile,'˜');
          if NoCurJump then    Write(G^.TFile,'ˆ');
          if Node then         Write(G^.TFile,'N');
          AutoBinOn := AutoBin;
        end else
        begin
          if Klingel then      Write(G^.TFile,'K');
          if CtrlBeep then     Write(G^.TFile,'G');
          if Time_stamp then   Write(G^.TFile,'T');
          if PacOut then       Write(G^.TFile,'L');
          if ZeigeRET then     Write(G^.TFile,'R');
          if ConMorsen then    Write(G^.TFile,'O');
          if ReconMorsen then  Write(G^.TFile,'D');
(*          if ConVoice then     Write(G^.TFile,'A');
          if ReconVoice then   Write(G^.TFile,'J'); *)
          if GlobalTrenn then  Write(G^.TFile,'H');
          if BinOut then       Write(G^.TFile,'i');
          if Ins then          Write(G^.TFile,'Z');
          if NoBinMon then     Write(G^.TFile,'!');
          if RX_TX_Win then    Write(G^.TFile,'&');
        end;
        Writeln(G^.TFile);
      end;
    end;
    Writeln(G^.TFile,LZ);
    Writeln(G^.TFile,LZ);

    Hstr := '';
    for i := 1 to 10 do Hstr := Hstr + int_str(G^.SETL[i]) + Km;
    Hstr := Hstr + int_str(SETNr);
    Writeln(G^.TFile,Rrgl,Rsetl,GL,Hstr);

    if Idle_Pos then i := 1
                else i := 0;
    Hstr := int_str(i) + Km + int_str(Idle_Anz) + Km + int_str(Idle_Tout);
    Writeln(G^.TFile,Rrgl,Ridle,GL,Hstr);

    Writeln(G^.TFile,Rrgl,Rmfreq,GL,G^.TonHoehe);
    if _VGA then i := 1
            else i := 0;
    Writeln(G^.TFile,Rrgl,Rega,GL,int_str(i));
    Writeln(G^.TFile,Rrgl,Rplen,GL,MPause);
    Writeln(G^.TFile,Rrgl,Rsynch,GL,Resync_Z);
    Writeln(G^.TFile,Rrgl,Rcnr,GL,CNr);
(*    Writeln(G^.TFile,Rrgl,Rvsp,GL,VSpeed); *)
    Writeln(G^.TFile,Rrgl,Rinfo,GL,G^.InfoStr);
    FiResult := CloseTxt(G^.TFile);
  end;
End;
}

Procedure Merker_File_Schreiben;
Var       i,i1  : Integer;
          OBF,
          Kanal : Byte;
          Hstr  : String[80];
          Memo  : ^MemoTyp;
          MDat  : file of MemoTyp;

Begin
{  GetMem(Memo,SizeOf(Memotyp));}
Memo:=NIL;
New(Memo);

  FillChar(Memo^, SizeOf(Memotyp), 0);
  Assign(MDat,Sys1Pfad + MerkDatei + Ext);
 {$I-}
 Rewrite(MDat);
 OBF:=IOResult;
 {$I+}
 memo^.v1:=MerkV1; memo^.v2:=MerkV2;   {//db1ras}
  if OBF = 0 then
  Begin
   for i := 1 to MaxTNC do with Memo^.TNC[i] do
    begin
     if TNC_Used[i] then
     begin
      if TNC[i]^.BText = '' then TNC[i]^.BText := 'CQ';
      if TNC[i]^.BPfad = '' then TNC[i]^.BPfad := 'ALL';
      Bake    := TNC[i]^.Bake;
      BPfad   := TNC[i]^.BPfad;
      BText   := TNC[i]^.BTEXT;
      BTimer  := TNC[i]^.btimer;
      BCall   := TNC[i]^.bcall;
      CText   := TNC[i]^.ctext;
      Info    := TNC[i]^.info;
      Aktuell := TNC[i]^.aktuell;
      QText   := TNC[i]^.qtext;
      Fix     := TNC[i]^.fix;
      QRG_Akt := TNC[i]^.qrg_akt;
      if ctext<1 then ctext:=1;
      if info<1 then info:=1;
      if aktuell<1 then aktuell:=1;
      if qtext<1 then qtext:=1;
      if fix<1 then fix:=1;
     end;
    end;


    for Kanal := 0 to maxLink do
    Begin
      with K[Kanal]^ do
      begin
        if Kanal > 0 then
        begin
          if OwnCall = '*' then OwnCall := TNC[TncNummer]^.HostCall;
          IF Kanal> Maxlink then Owncall:='';
          Memo^.Kanal[Kanal].OwnCall := Owncall;
          Memo^.Kanal[Kanal].AutoZyConst := AutoZyConst;
        end;

         Memo^.Kanal[Kanal].MaxFrame  := MaxFrame;
         Memo^.Kanal[Kanal].PacLen    := PacLen;
         Memo^.Kanal[Kanal].ObStat    := ObStat;
         Memo^.Kanal[Kanal].UnStat    := UnStat;
         Memo^.Kanal[Kanal].UmlautMerk:= UmlautMerk;
       { if (connected) or Mo.MonActive then }   {//db1ras}
         Memo^.Kanal[kanal].ignore := ignore;

        Memo^.Kanal[Kanal].FRxName:='';
        if RX_Save then
        begin
          if not BackUpLauf then
           begin
            CloseRxFile(Kanal,1);
            RX_Save := false;
            RX_Bin := 0;
           end;
           Memo^.Kanal[Kanal].FRxName:=FRXName;

        end;

        Memo^.Kanal[Kanal].SaveFName:='';
        if Save then
        begin
          if not BackUpLauf then
           begin
            FiResult := CloseBin(SFile);
            Save := false;
           end;
          Memo^.Kanal[Kanal].SaveFName:=FName_aus_FVar(SFile);
        end;

        Memo^.Kanal[Kanal].SPLFName    :='';
        if SPlus and SplSave then
        begin
          Memo^.Kanal[Kanal].SPLFName    := FName_aus_FVar(SplFile);
          Memo^.Kanal[Kanal].Spl_gLaenge := Spl_glaenge;
          Memo^.Kanal[Kanal].Spl_gCount  := spl_gcount;
          Memo^.Kanal[Kanal].Spl_tLaenge := spl_tlaenge;
          Memo^.Kanal[Kanal].Spl_tCount  := spl_Tcount;
          if not BackUpLauf then
           begin
            FiResult := CloseBin(SplFile);
            SplSave := false;
           end;
        end;

        Memo^.Kanal[Kanal].Umlaut := Umlaut;
        Memo^.Kanal[Kanal].Echo   := Echo;
        if SysTextEcho then Memo^.Kanal[kanal].Echo:=Memo^.Kanal[kanal].Echo+100;
        Memo^.Global.Gross  := Gross;

          Memo^.Kanal[Kanal].Auto:=Auto;
          Memo^.Global.TopBox := TopBox;
          Memo^.Kanal[Kanal].Rx_Beep := RX_Beep;
          Memo^.Global.morsen := morsen;
          Memo^.Kanal[Kanal].TxBeepAck := TXBeepAck;
       (*   if Speek then        Write(G^.TFile,'P'); *)
          Memo^.Kanal[Kanal].AutoBin := AutoBin;
          Memo^.Kanal[Kanal].SPlus := Splus;
          Memo^.Kanal[Kanal].TxComp := TXComp;
          Memo^.Kanal[Kanal].RxComp := RXComp;
          Memo^.Kanal[Kanal].CompC := CompC;
          Memo^.kanal[kanal].StopComp:=StopComp;
          memo^.kanal[kanal].StopCode := StopCode;
          memo^.kanal[kanal].SpComp := SpComp;
          Memo^.Kanal[kanal].KompressUpd := KompressUpd;
          Memo^.Kanal[Kanal].CompCUpdZahl := CompCUpdZahl;
          for i := 1 to 255 do
           Memo^.Kanal[Kanal].Kompression[i] := Kompression[i];
          Memo^.Kanal[Kanal].NoCurJump := NoCurJump;
          Memo^.Kanal[Kanal].Node := Node;
      AutoBinOn := AutoBin;

          {//db1ras}
          Memo^.Kanal[Kanal].CSelf          := CSelf        ;
          Memo^.Kanal[Kanal].AutoZeile      := AutoZeile    ;
          Memo^.Kanal[Kanal].Auto1Zeile     := Auto1Zeile   ;
          Memo^.Kanal[Kanal].AutoTime       := AutoTime     ;
          Memo^.Kanal[Kanal].AutoZaehl      := AutoZaehl    ;
          Memo^.Kanal[Kanal].AutoJump       := AutoJump     ;
          Memo^.Kanal[Kanal].AutoZyConst    := AutoZyConst  ;
          Memo^.Kanal[Kanal].AutoZyCount    := AutoZyCount  ;
          Memo^.Kanal[Kanal].AutoWait       := AutoWait     ;
          Memo^.Kanal[Kanal].AutoToConst    := AutoToConst  ;
          Memo^.Kanal[Kanal].AutoToCount    := AutoToCount  ;
          Memo^.Kanal[Kanal].AutoToAnz      := AutoToAnz    ;
          Memo^.Kanal[Kanal].AutoToMax      := AutoToMax    ;
          Memo^.Kanal[Kanal].AutoToAnzJmp   := AutoToAnzJmp ;
          Memo^.Kanal[Kanal].AutoChMerk     := AutoChMerk   ;
          Memo^.Kanal[Kanal].AutoArt        := AutoArt      ;
          Memo^.Kanal[Kanal].AutoCheckLn    := AutoCheckLn  ;
          Memo^.Kanal[Kanal].AutoJmpPtr     := AutoJmpPtr   ;
          For i:=1 To maxAutoJmpPtr Do
            Memo^.Kanal[Kanal].AutoJmpRet[i]:= AutoJmpRet[i];

          Memo^.Global.Klingel := Klingel;
          Memo^.Global.CtrlBeep := CtrlBeep;
          Memo^.Global.Time_stamp := Time_Stamp;
          Memo^.Global.PacOut := PacOut;
          Memo^.Global.ZeigeRET := ZeigeRet;
          Memo^.Global.ConMorsen := ConMorsen;
          Memo^.Global.ReconMorsen := ReconMorsen;
(*          if ConVoice then     Write(G^.TFile,'A');
          if ReconVoice then   Write(G^.TFile,'J'); *)
          Memo^.Global.GlobalTrenn := GlobalTrenn;
          Memo^.Global.BinOut := BinOut;
          Memo^.Global.Ins := Ins;
          Memo^.Global.NoBinMon := NoBinMon;
          Memo^.Global.RX_TX_Win := RX_TX_Win;
      end;
    end;
    Hstr := '';
    for i := 1 to 10 do Memo^.Global.Setl[i]:=G^.SETL[i];
    Memo^.Global.SetNr:=SETNr;

    Memo^.global.Speak:=speek;
    if vspeed<1 then vspeed:=40;
    Memo^.global.SpeakSpeed:=Vspeed;


    Memo^.Global.Idle_Pos := Idle_Pos;
    Memo^.Global.Idle_Anz := Idle_anz;
    Memo^.Global.Idle_Tout := Idle_Tout;

    Memo^.Global.TonHoehe:=G^.TonHoehe;

    Memo^.Global._VGA := _vga;
    Memo^.Global.MPause:=MPause;
    Memo^.Global.Resync_Z:=Resync_Z;
    Memo^.Global.CNr:=CNr;
    Memo^.Global.VIP:=VIPG;
    Memo^.Global.SoZeichen:=SoZeichen;
    Memo^.Global.StatusModus:=G^.StatusModus;
    Memo^.Global.ZeilenwTX := G^.ZeilenwTX;
(*    Writeln(G^.TFile,Rrgl,Rvsp,GL,VSpeed); *)
    Memo^.Global.InfoStr:=G^.InfoStr;
    write(mdat, Memo^);
    {$I-}
    Close(MDat);
    obf:=ioresult;
    {$I+}
  end;
Dispose(Memo);
{FreeMem(Memo,SizeOf(Memotyp));}
End;


Procedure Merker_File_Lesen;   {//db1ras}

{$IFDEF ReadOldMemo}   {//db1ras}
Procedure Altes_Merker_File_Lesen;
Var     Result : Word;
        Hstr   : String[10];
        i,i1,
        i2,C   : Integer;
        Memo   : ^OldMemoTyp;
        MDat   : File of OldMemoTyp;
        OBF    : Byte;

{for i := 1 to maxTNC do if TNC_used[i] then with TNC[i]^ do}

Begin
  Assign(Mdat,Sys1Pfad + MerkDatei + Ext);
  {$I-}
  Reset(MDat);
  obf:=ioresult;
  {$I+}
  if obf = 0 then begin
    Memo:=NIL;
    New(Memo);
{    WriteTxt(XCP,SZ1,StartColor,MerkDatei + Ext);}
{*** 3}
    gotoxy(1,20);
    writeln('    ⁄ ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹                                          ø');
    writeln('    ¿ ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ                                          Ÿ');
    XCP := XCP + SZL;

    read(MDat, Memo^);

    for i := 1 to MaxTNC do if TNC_used[i] then
     begin
      with TNC[i]^ do
       begin
        Btext := Memo^.TNC[i].btext;
        BPfad := Memo^.TNC[i].bpfad;

        Bake := Memo^.TNC[i].Bake;
        BTimer := Memo^.TNC[i].Btimer;
        if BTimer = 0 then BTimer := 20;
        BCall:=Memo^.TNC[i].BCall;
        CText := Memo^.TNC[i].ctext;
        Info := Memo^.TNC[i].info;
        Aktuell := Memo^.TNC[i].aktuell;
        QText := Memo^.TNC[i].qtext;
        Fix := Memo^.TNC[i].fix;
        QRG_Akt := Memo^.TNC[i].qrg_akt;
        if QRG_Akt = '' then QRG_Akt := PseudoQRG;
       end;
    end;
    c:=-1;
    while (C < MaxLink) do
    begin
     inc(c);
     K[c]^.OwnCall := '*';
     K[c]^.Umlaut := Memo^.Kanal[c].Umlaut;
     if c=0 then k[c]^.RxComp:= Memo^.Kanal[c].RXComp;
     if Memo^.Kanal[c].OwnCall<>'' then
      with K[C]^ do
      begin
        if C > 0 then
        begin
          OwnCall:=Memo^.Kanal[c].owncall;
          AutoZyConst := Memo^.Kanal[c].AutoZyConst;
          if AutoZyConst > 0 then CSelf := 2;
        end;

          MaxFrame := Memo^.Kanal[c].MaxFrame;
          if not (MaxFrame in [1..7]) then MaxFrame := 1;
          PacLen := Memo^.Kanal[c].PacLen;
          if not (PacLen in [1..FF]) then PacLen := FF;
          ObStat := Memo^.Kanal[c].OBStat;
          UnStat := Memo^.Kanal[c].UnStat;
          UmlautMerk := Memo^.Kanal[c].UmlautMerk;
          if not (UmlautMerk in UmlMenge) then UmlautMerk := 0;

          FRxName := Memo^.Kanal[c].FRxName;
        if FRXName <>'' then
        begin
          if OpenTextFile(C) then
          begin
            RX_Count := 0;
            RX_Laenge := 0;
            RX_Bin := 0;
            RX_Save := true;
            FTxName := G^.Drive;
          end;
        end
        else
        begin
          FRxName := Konfig.SavVerz + TxtName + SFillStr(3,'0',int_str(C));
          FTxName := Konfig.SavVerz;
        end;

        SvName := Memo^.Kanal[c].SaveFName;
        if SvName<>'' then
        begin
          Assign(SFile,SvName);
          Result := ResetBin(SFile,T);
          if Result = 0 then Seek(SFile,FileSize(SFile))
                        else Result := RewriteBin(SFile,T);
          if Result = 0 then Save := true;
        end else
        begin
          SvName := Konfig.SavVerz + SaveName + SFillStr(3,'0',int_str(C));
        end;

        if Memo^.Kanal[c].SplFName > '' then
        begin
          Assign(SplFile,Memo^.Kanal[c].SPlFName);
          if ResetBin(SplFile,T) = 0 then
          begin
            Seek(SplFile,FileSize(SplFile));
            SPlus := true;
            SplSave := true;
            Spl_gLaenge := Memo^.Kanal[c].SPl_glaenge;
            Spl_gCount := Memo^.Kanal[c].spl_gcount;
            Spl_tLaenge := Memo^.Kanal[c].spl_tlaenge;
            Spl_tCount := Memo^.Kanal[c].Spl_TCount;
          end;
        end;


          echo := Memo^.Kanal[c].Echo;
          if echo>99 then
           begin
            Echo:=Echo-100;
            SysTextEcho:=true;
           end;




          if C > 0 then
          begin

            Auto         := Memo^.Kanal[c].Auto;
            RX_Beep      := Memo^.Kanal[c].RX_Beep;

            TxBeepAck    := Memo^.Kanal[C].TxBeepAck;
        {    Speek        := (pos('P',DZeile) > 0);}
            AutoBin      := Memo^.Kanal[c].AutoBin;
            SPlus        := Memo^.Kanal[c].SPlus;
            if K[c]^.connected then   {unsinnig, da immer true  //db1ras}
             begin
              TxComp       := Memo^.Kanal[c].TXComp;
              RxComp       := Memo^.Kanal[c].RXComp;
              StopComp     := Memo^.Kanal[c].StopComp;
              StopCode     := Memo^.Kanal[c].StopCode;
              SPComp       := Memo^.Kanal[c].SPComp;
              CompC:=Memo^.Kanal[c].CompC;
              KompressUpd:=Memo^.Kanal[c].KompressUpd;
              CompCUpdZahl:=Memo^.Kanal[c].CompCUpdZahl;
              for i := 1 to 255 do
               Kompression[i]:=Memo^.Kanal[c].Kompression[i];
             end;
            NoCurJump    := Memo^.Kanal[C].NoCurJump;
            Node         := Memo^.Kanal[c].Node;
            {if (connected) or (Mo.MonActive) then }ignore       := memo^.Kanal[c].ignore;
          end;

      end;
    end;

     for i := 1 to 10 do G^.SETL[i] := Memo^.Global.Setl[i];
     SETNr := Memo^.Global.setnr;
     if not (SETNr in [1..10]) then SETNr := 1;
      Klingel      := Memo^.Global.Klingel;
      CtrlBeep     := Memo^.Global.CtrlBeep;
      Time_Stamp   := Memo^.Global.Time_Stamp;
      PacOut       := Memo^.Global.PacOut;
      ZeigeRET     := Memo^.Global.ZeigeRet;
      ConMorsen    := Memo^.Global.ConMorsen;
      ReconMorsen  := Memo^.Global.ReconMorsen;
{            ConVoice     := (pos('A',DZeile)  > 0);
            ReconVoice   := (pos('J',DZeile)  > 0);}
       GlobalTrenn  := Memo^.Global.GlobalTrenn;
       BinOut       := Memo^.Global.BinOut;
       Ins          := Memo^.Global.ins;
       NoBinMon     := Memo^.Global.NoBinMon;
       RX_TX_Win    := Memo^.Global.RX_TX_win;
       morsen       := Memo^.Global.morsen;
       TopBox       := Memo^.Global.TopBox;
    Gross := Memo^.Global.Gross;
    Idle_Pos := Memo^.Global.idle_pos;
    Idle_Anz := Memo^.Global.idle_anz;
    Idle_Tout := Memo^.Global.Idle_Tout;
    G^.TonHoehe := Memo^.Global.TonHoehe;
    VIPG := Memo^.Global.VIP;
    SoZeichen := Memo^.Global.SoZeichen;
    _VGA := Memo^.Global._vga;
    MPause := Memo^.Global.MPause;
    Resync_Z := Memo^.Global.Resync_Z;
    CNr := Memo^.Global.Cnr;

    VSpeed:=memo^.global.speakspeed;
    speek:=memo^.global.speak;

{    MerkRead(Rrgl + Rvsp);
    if DZeile > '' then VSpeed := Word(str_int(DZeile));}

    G^.InfoStr := Memo^.Global.InfoStr;
    G^.StatusModus := Memo^.Global.StatusModus;
    G^.ZeilenwTX   := Memo^.Global.ZeilenwTX;

    {$I-}
    Close(MDat);
    obf:=Ioresult;
    {$I+}
    Dispose(Memo);
  end else   (* If IOResult ... *)
  begin
    for i := 0 to maxLink do with K[i]^ do
    begin
      FRxName := G^.Drive + Txt + int_str(i) + Ext;
      FTxName := G^.Drive;
    end;
  end;
End;
{$ENDIF}

Procedure Neues_Merker_File_Lesen;
Var     Result : Word;
        Hstr   : String[10];
        i,i1,
        i2,C   : Integer;
        Memo   : ^MemoTyp;
        MDat   : File of MemoTyp;
        OBF    : Byte;

{for i := 1 to maxTNC do if TNC_used[i] then with TNC[i]^ do}

Begin
  Assign(Mdat,Sys1Pfad + MerkDatei + Ext);
  {$I-}
  Reset(MDat);
  obf:=ioresult;
  {$I+}

  if obf = 0 then
  begin
    Memo:=NIL;
    New(Memo);
{    WriteTxt(XCP,SZ1,StartColor,MerkDatei + Ext);}
{*** 3}
    gotoxy(1,20);
    writeln('    ⁄ ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹                                          ø');
    writeln('    ¿ ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ                                          Ÿ');
    XCP := XCP + SZL;

    read(MDat, Memo^);

    for i := 1 to MaxTNC do if TNC_used[i] then
     begin
      with TNC[i]^ do
       begin
        Btext := Memo^.TNC[i].btext;
        BPfad := Memo^.TNC[i].bpfad;

        Bake := Memo^.TNC[i].Bake;
        BTimer := Memo^.TNC[i].Btimer;
        if BTimer = 0 then BTimer := 20;
        BCall:=Memo^.TNC[i].BCall;
        CText := Memo^.TNC[i].ctext;
        Info := Memo^.TNC[i].info;
        Aktuell := Memo^.TNC[i].aktuell;
        QText := Memo^.TNC[i].qtext;
        Fix := Memo^.TNC[i].fix;
        QRG_Akt := Memo^.TNC[i].qrg_akt;
        if QRG_Akt = '' then QRG_Akt := PseudoQRG;
       end;
    end;
    c:=-1;
    while (C < MaxLink) do
    begin
     inc(c);
     K[c]^.OwnCall := '*';
     K[c]^.Umlaut := Memo^.Kanal[c].Umlaut;
     if c=0 then k[c]^.RxComp:= Memo^.Kanal[c].RXComp;
     if Memo^.Kanal[c].OwnCall<>'' then
      with K[C]^ do
      begin
        if C > 0 then
        begin
          OwnCall:=Memo^.Kanal[c].owncall;
          AutoZyConst := Memo^.Kanal[c].AutoZyConst;
          if AutoZyConst > 0 then CSelf := 2;
        end;

          MaxFrame := Memo^.Kanal[c].MaxFrame;
          if not (MaxFrame in [1..7]) then MaxFrame := 1;
          PacLen := Memo^.Kanal[c].PacLen;
          if not (PacLen in [1..FF]) then PacLen := FF;
          ObStat := Memo^.Kanal[c].OBStat;
          UnStat := Memo^.Kanal[c].UnStat;
          UmlautMerk := Memo^.Kanal[c].UmlautMerk;
          if not (UmlautMerk in UmlMenge) then UmlautMerk := 0;

          FRxName := Memo^.Kanal[c].FRxName;
        if FRXName <>'' then
        begin
          if OpenTextFile(C) then
          begin
            RX_Count := 0;
            RX_Laenge := 0;
            RX_Bin := 0;
            RX_Save := true;
            FTxName := G^.Drive;
          end;
        end
        else
        begin
          FRxName := Konfig.SavVerz + TxtName + SFillStr(3,'0',int_str(C));
          FTxName := Konfig.SavVerz;
        end;

        SvName := Memo^.Kanal[c].SaveFName;
        if SvName<>'' then
        begin
          Assign(SFile,SvName);
          Result := ResetBin(SFile,T);
          if Result = 0 then Seek(SFile,FileSize(SFile))
                        else Result := RewriteBin(SFile,T);
          if Result = 0 then Save := true;
        end else
        begin
          SvName := Konfig.SavVerz + SaveName + SFillStr(3,'0',int_str(C));
        end;

        if Memo^.Kanal[c].SplFName > '' then
        begin
          Assign(SplFile,Memo^.Kanal[c].SPlFName);
          if ResetBin(SplFile,T) = 0 then
          begin
            Seek(SplFile,FileSize(SplFile));
            SPlus := true;
            SplSave := true;
            Spl_gLaenge := Memo^.Kanal[c].SPl_glaenge;
            Spl_gCount := Memo^.Kanal[c].spl_gcount;
            Spl_tLaenge := Memo^.Kanal[c].spl_tlaenge;
            Spl_tCount := Memo^.Kanal[c].Spl_TCount;
          end;
        end;


          echo := Memo^.Kanal[c].Echo;
          if echo>99 then
           begin
            Echo:=Echo-100;
            SysTextEcho:=true;
           end;




          if C > 0 then
          begin

            Auto         := Memo^.Kanal[c].Auto;
            RX_Beep      := Memo^.Kanal[c].RX_Beep;

            TxBeepAck    := Memo^.Kanal[C].TxBeepAck;
        {    Speek        := (pos('P',DZeile) > 0);}
            AutoBin      := Memo^.Kanal[c].AutoBin;
            SPlus        := Memo^.Kanal[c].SPlus;
            if K[c]^.connected then {unsinnig, da immer true   //db1ras}
             begin
              TxComp       := Memo^.Kanal[c].TXComp;
              RxComp       := Memo^.Kanal[c].RXComp;
              StopComp     := Memo^.Kanal[c].StopComp;
              StopCode     := Memo^.Kanal[c].StopCode;
              SPComp       := Memo^.Kanal[c].SPComp;
              CompC:=Memo^.Kanal[c].CompC;
              KompressUpd:=Memo^.Kanal[c].KompressUpd;
              CompCUpdZahl:=Memo^.Kanal[c].CompCUpdZahl;
              for i := 1 to 255 do
               Kompression[i]:=Memo^.Kanal[c].Kompression[i];
             end;
            NoCurJump    := Memo^.Kanal[C].NoCurJump;
            Node         := Memo^.Kanal[c].Node;
            {if (connected) or (Mo.MonActive) then }
            ignore       := memo^.Kanal[c].ignore;
          end;

          {//db1ras}
          CSelf          := Memo^.Kanal[c].CSelf        ;
          AutoZeile      := Memo^.Kanal[c].AutoZeile    ;
          Auto1Zeile     := Memo^.Kanal[c].Auto1Zeile   ;
          AutoTime       := Memo^.Kanal[c].AutoTime     ;
          AutoZaehl      := Memo^.Kanal[c].AutoZaehl    ;
          AutoJump       := Memo^.Kanal[c].AutoJump     ;
          AutoZyConst    := Memo^.Kanal[c].AutoZyConst  ;
          AutoZyCount    := Memo^.Kanal[c].AutoZyCount  ;
          AutoWait       := Memo^.Kanal[c].AutoWait     ;
          AutoToConst    := Memo^.Kanal[c].AutoToConst  ;
          AutoToCount    := Memo^.Kanal[c].AutoToCount  ;
          AutoToAnz      := Memo^.Kanal[c].AutoToAnz    ;
          AutoToMax      := Memo^.Kanal[c].AutoToMax    ;
          AutoToAnzJmp   := Memo^.Kanal[c].AutoToAnzJmp ;
          AutoChMerk     := Memo^.Kanal[c].AutoChMerk   ;
          AutoArt        := Memo^.Kanal[c].AutoArt      ;
          AutoCheckLn    := Memo^.Kanal[c].AutoCheckLn  ;
          AutoJmpPtr     := Memo^.Kanal[c].AutoJmpPtr   ;
          For i:=1 To maxAutoJmpPtr Do
            AutoJmpRet[i]:= Memo^.Kanal[c].AutoJmpRet[i];
      end;
    end;

     for i := 1 to 10 do G^.SETL[i] := Memo^.Global.Setl[i];
     SETNr := Memo^.Global.setnr;
     if not (SETNr in [1..10]) then SETNr := 1;
      Klingel      := Memo^.Global.Klingel;
      CtrlBeep     := Memo^.Global.CtrlBeep;
      Time_Stamp   := Memo^.Global.Time_Stamp;
      PacOut       := Memo^.Global.PacOut;
      ZeigeRET     := Memo^.Global.ZeigeRet;
      ConMorsen    := Memo^.Global.ConMorsen;
      ReconMorsen  := Memo^.Global.ReconMorsen;
{            ConVoice     := (pos('A',DZeile)  > 0);
            ReconVoice   := (pos('J',DZeile)  > 0);}
       GlobalTrenn  := Memo^.Global.GlobalTrenn;
       BinOut       := Memo^.Global.BinOut;
       Ins          := Memo^.Global.ins;
       NoBinMon     := Memo^.Global.NoBinMon;
       RX_TX_Win    := Memo^.Global.RX_TX_win;
       morsen       := Memo^.Global.morsen;
       TopBox       := Memo^.Global.TopBox;
    Gross := Memo^.Global.Gross;
    Idle_Pos := Memo^.Global.idle_pos;
    Idle_Anz := Memo^.Global.idle_anz;
    Idle_Tout := Memo^.Global.Idle_Tout;
    G^.TonHoehe := Memo^.Global.TonHoehe;
    VIPG := Memo^.Global.VIP;
    SoZeichen := Memo^.Global.SoZeichen;
    _VGA := Memo^.Global._vga;
    MPause := Memo^.Global.MPause;
    Resync_Z := Memo^.Global.Resync_Z;
    CNr := Memo^.Global.Cnr;

    VSpeed:=memo^.global.speakspeed;
    speek:=memo^.global.speak;

{    MerkRead(Rrgl + Rvsp);
    if DZeile > '' then VSpeed := Word(str_int(DZeile));}

    G^.InfoStr := Memo^.Global.InfoStr;
    G^.StatusModus := Memo^.Global.StatusModus;
    G^.ZeilenwTX   := Memo^.Global.ZeilenwTX;

    {$I-}
    Close(MDat);
    obf:=Ioresult;
    {$I+}
    Dispose(Memo);
  end else   (* If IOResult ... *)
  begin
    for i := 0 to maxLink do with K[i]^ do
    begin
      FRxName := G^.Drive + Txt + int_str(i) + Ext;
      FTxName := G^.Drive;
    end;
  end;
End;

{$IFDEF ReadOldMemo}   {//db1ras}
Var     MVer    : File of Char;
        v1,v2   : Char;
        sv1,sv2 : String[2];
        Memo    : String;
        obf     : Byte;
{$ENDIF}

Begin (* Merker_File_Lesen *)

{$IFDEF ReadOldMemo}   {//db1ras}
  Assign(MVer,Sys1Pfad + MerkDatei + Ext);
  {$I-}
  Reset(MVer);
  obf:=ioresult;
  {$I+}
  If obf = 0 Then Begin
    Read(MVer, v1,v2);
    {$I-}
    Close(MVer);
    obf:=Ioresult;
    {$I+}
    If (v1<>Chr(MerkV1)) Or (v2<>Chr(MerkV2)) Then Begin
      If (v1=Chr(OldMerkV1)) And (v2=Chr(OldMerkV2)) Then
        Altes_Merker_File_Lesen;
      Str(Ord(v1),sv1);
      Str(Ord(v2),sv2);
      Memo:=Sys1Pfad+MerkDatei+Ext+' '+Sys1Pfad+MerkDatei+'.'+sv1+sv2;
      FileKopieren(Memo);
    { Rename(MVer,Sys1Pfad+MerkDatei+'.'+sv1+sv2); }
    End Else
{$ENDIF}

      Neues_Merker_File_Lesen;

{$IFDEF ReadOldMemo}   {//db1ras}
  End Else
    Neues_Merker_File_Lesen;
{$ENDIF}

End;