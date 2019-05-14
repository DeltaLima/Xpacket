{⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
 ≥                                                                         ≥
 ≥                             X - P a c k e t                             ≥
 ≥                                                                         ≥
 ≥                                                                         ≥
 ≥  X P T R X .  P A S                                                     ≥
 ≥                                                                         ≥
 ≥ Routinen fuer die Aussendung von Files                                  ≥
 ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ}


Procedure FileTxMenu (* Kanal : Byte *);
Const  ArtMax = 8;
Var    i    : Byte;
       KC   : Sondertaste;
       VC   : Char;
       Fehler,
       Flag : Boolean;
       X,Y,
       Art  : Byte;

Begin
  with K[Kanal]^ do
  begin
   if node then Wishbuf:=false;
    Moni_Off(0);
    Flag := false;
    for i := 9 to 15 do G^.Fstx[i] := 2;
    G^.Fstr[7] := InfoZeile(334);
    G^.Fstr[9] := InfoZeile(335);
    G^.Fstr[10] := InfoZeile(336);
    G^.Fstr[11] := InfoZeile(337);
    G^.Fstr[12] := InfoZeile(338);
    G^.FStr[13] := InfoZeile(339);

    if FileSendWait then Art := 5 else
    begin
      if FileSend then
      begin
        case TX_Bin of
          0 : Art := 1;
          1 : Art := 2;
          2,
          3 : Art := 3;
        end;
        if XBin.TX then Art:=5;
      end else
       if TNC_Puffer then Art := 6 else
        if WishBuf then Art := 7
                   else Art := 1;
    end;
    Repeat
      for i := 9 to 13 do
      begin
        G^.Fstr[i][vM+1] := B1;
        G^.Fstr[i][hM+1] := B1;
        G^.Fstr[i][vM] := B1;
        G^.Fstr[i][hM] := B1;
      end;

      if Art in [1..5] then
      begin
        X := vM;
        Y := Art + 8;
      end else
      begin
        X := hM;
        Y := Art + 4;
      end;

{      if Art= 9 then
       begin
        x:=vm;
        y:=art+8;
       end;}

      G^.Fstr[Y][X] := A_ch;

      if HardCur then SetzeCursor(X+1,Y);

      if FileSend then
      begin
        case TX_Bin of
          0 : G^.Fstr[9][vM+1] := X_ch;
          1 : G^.Fstr[10][vM+1] := X_ch;
          2 : G^.Fstr[11][vM+1] := 'x';
          3 : G^.Fstr[11][vM+1] := X_ch;
        end;
      end;

      if FileSendWait then G^.Fstr[9][hM+1] := X_ch;
      if TNC_Puffer then G^.Fstr[10][hM+1] := X_ch;
      if WishBuf then G^.Fstr[11][hM+1] := X_ch;
      if BufExists then G^.Fstr[12][hM+1] := X_ch;
      {if XBin.AN then G^.FSTR[13]:='XBIN AN ' else G^.Fstr[13]:='XBIN Aus';}

      {G^.Fstr[13] := '';}
      G^.Fstr[14] := '';
      G^.Fstr[15] := '';
      Fenster(15);

      _ReadKey(KC,VC);
      Case KC of
        _Esc : Flag := true;

       _AltH : XP_Help(G^.OHelp[22]);

        _Ret : ;

         _F1 : Art := 1; {text}
         _F2 : Art := 2; {bin}
         _F3 : Art := 3; {autobin}
         _F4 : Art := 4; {autobin sof}
         _F5 : Art := 5; {xbin}
         _F6 : Art := 6; {ftx anhalten}
         _F7 : Art := 7; {tnc-puffer}
         _F8 : Art := 8; {ZWP anlegen}
         _F9 : Art := 9; {ZWP lîschen}
        _F10 : Alarm;

         _Up : if Art > 1  then dec(Art)
                           else Alarm;

         _Dn : if Art < ArtMax then inc(Art)
                               else Alarm;

      _Right : if Art < ArtMax  then
               begin
                 Art := Art + 4;
                 if Art > ArtMax then Art := ArtMax;
               end else Alarm;

       _Left : if Art > 1 then
               begin
                 if Art <= 4 then Art := 1
                             else Art := Art - 4;
               end else Alarm;

         else Alarm;
      End;

      if KC in [_F1.._F9,_Ret] then
      case Art of
        1,
        2,
        3,
        4,
        5 : begin
            if Art=5 then XBin.AN:=true;
             if (not FileSend) and (not SPlSave) and (RX_bin=0) then
             begin
              case Art of
                1 : G^.Fstr[9][vM] := S_ch;
                2 : G^.Fstr[10][vM] := S_ch;
                3 : G^.Fstr[11][vM] := S_ch;
                4 : G^.Fstr[12][vM] := S_ch;
                5 : G^.Fstr[13][vM] := S_ch;
              end;
              Fenster(15);
              if art=5 then art:=3;
              Datei_Senden(Kanal,Art);
              if FileSend then
               begin
                Flag := true;
               end else if xbin.an then art:=5;
             end else Alarm;
            end;

        6 : if (FileSend) and (not XBin.TX) then
             begin
              if (not XBin.TX) then FileSendWait := not FileSendWait
              else
               begin
                xbinWait:=not XBinWait;
                {if not FileSendWait then
                 begin
                  FileSendWait:=true;
                 end;}
               end;
             end
             else Alarm;

        7 : begin
             if not TNC_Puffer then
              begin
               Fehler:=false;
               For i:=1 to maxlink do
                if K[i]^.TNC_Puffer then Fehler:=true;
               if not fehler then
                  TNC_Puffer := not TNC_Puffer
               else Alarm;
              end else TNC_Puffer := not TNC_Puffer;
            end;

        8 : if not node then WishBuf := not WishBuf else Alarm;

        9 : If BufExists then EraseBufferFile(Kanal);
      end;

      SetzeFlags(Kanal);
    Until Flag;


    if (filesend) and (XBin.AN) then TNC_Puffer:=false;
    {bei XBIN-protokoll unbedingt vorzeitiges senden an TNC verbieten,
    zwecks PrÅfsummenerstellung und FramezÑhler!!}


    ClrFenster;
    Neu_Bild;
    Moni_On;
  end;
End;


Procedure Datei_Senden (* Kanal : Byte; Art : Byte *);
Var       Hstr   : String[80];
          abByte : Boolean;
          KC     : Sondertaste;
          Flag   : Boolean;
Begin
  if Kanal > 0 then with K[Kanal]^ do
  begin
   xbin.rtxok:=true;
    if FileSend then
    begin
      FileSend := false;
      BoxZaehl:=5;
      FiResult := CloseBin(TxFile);
      S_PAC(Kanal,NU,true,'');
      TNC_Puffer := false;
    end else
    begin
      Flag := false;
      Case Art of
       1 : TX_Bin := 0;
       2 : TX_Bin := 1;
       3 : TX_Bin := 2;
       4 : begin
             TX_Bin := 2;
             Flag := true;
           end;
      End;
      G^.Fstr[14]:=InfoZeile(204);
      Fenster(15);
      GetString(FTxName,Attrib[3],60,2,15,KC,1,Ins);
      G^.Fstr[14]:='';
      Fenster(15);
      if KC <> _Esc then
      begin
        if pos(B1,FTxName) > 0 then
        begin
          Hstr := RestStr(FTxName);
          FTxName := CutStr(FTxName);
          abByte := true;
        end else abByte := false;
        FTxName := UpCaseStr(FTxName);
        if pos(DP,FTxName) = 0 then FTxName := Konfig.SavVerz + FTxName;
        if SaveNameCheck(1,FTxName) then Assign(TxFile,FTxName)
                                    else Assign(TxFile,'###***##');
        if ResetBin(TxFile,T) = 0 then
        begin  (* File vorhanden *)
          TX_Laenge := FileSize(TxFile);
          TX_Count := 0;
          TX_Time := Uhrzeit;
          if abByte then FileSendVon(Kanal,Hstr);
          abByte := false;
          FileSend := true;
          if TX_Bin = 2 then
          begin   (* Bei Auto-Bin-Send die FilelÑnge Åbertragen *)
            Hstr := MakeBinStr(Kanal,FTxName);
            if paclen<30 then paclen:=30;
            TX_CRC := 0;
            S_PAC(Kanal,NU,not Flag,Hstr);
            if Flag then TX_Bin := 3;
          end;
        end else
        begin  (* File nicht vorhanden *)
          Alarm;
          G^.Fstr[15] := FTxName + B1 + InfoZeile(157) + B2 + InfoZeile(78);
          Fenster(15);
          SetzeCursor(length(G^.Fstr[15])+2,15);
          Warten;
          Cursor_aus;
        end;
      end;
    end;
  end else Alarm;
End;


Procedure FileSendVon (* Kanal : Byte; Zeile : Str40 *);
Var  von,bis  : LongInt;
     Hstr     : String[20];

  Function  Pos_ZlNr(Kanal : Byte; ZNr : LongInt) : LongInt;
  Var  i,
       Result : Word;
       ir,iz  : LongInt;
       Hstr   : String;
  Begin
    with K[Kanal]^ do
    begin
      iz := 0;
      ir := 0;
      Seek(TxFile,0);
      While not Eof(TxFile) and (ir < ZNr) do
      begin
        BlockRead(TxFile,Hstr[1],FF,Result);
        Hstr[0] := Chr(Result);
        for i := 1 to Result do
        begin
          if ir < ZNr then inc(iz);
          if Hstr[i] = M1 then inc(ir);
        end;
      end;
      Pos_ZlNr := iz;
    end;
  End;

Begin
  with K[Kanal]^ do
  begin
    Hstr := CutStr(Zeile);
    if Hstr > '' then
    begin
      if copy(Hstr,1,1) = '$' then
      begin
        delete(Hstr,1,1);
        von := Pos_ZlNr(Kanal,str_int(Hstr)-1);
      end else von := str_int(Hstr);
    end else von := 0;

    Hstr := RestStr(Zeile);
    if Hstr > '' then
    begin
      if copy(Hstr,1,1) = '$' then
      begin
        delete(Hstr,1,1);
        bis := Pos_ZlNr(Kanal,str_int(Hstr));
      end else bis := str_int(Hstr);
    end else bis := TX_Laenge - 1;

    if (von < 0) or (von >= TX_Laenge) then von := 0;
    if (bis <= 0) or (bis >= TX_Laenge) or (bis < von) then bis := TX_Laenge - 1;

    TX_Laenge := bis - von + 1;
    Seek(TxFile,von);
  end;
End;


Procedure Send_File (* Kanal : Byte; OFlag : Boolean; *);
Var   Zeile      : String;
      Hstr       : String[9];
      i,l        : Byte;
      ch         : Char;
      FileEnde   : Boolean;
      Result     : Word;
      XBTrans    : Boolean;
      DatPos    : longint;
Begin

  FileEnde := false;
  Zeile := '';
  with K[Kanal]^ do
  Begin
   XBTrans:=(XBIN.AN) and (TX_BIN=3);
    FileFlag := (TX_Bin = 0) and (Echo in [2,3,6,7]);
    if TX_Bin <> 2 then
    Begin
      if TxComp then l := maxCompPac
                else l := FF;

      if XBTrans then l:=paclen-8;
      if xbtrans and txcomp then l:=paclen-10;
      if xbtrans then DatPos:=filepos(TXFile);
      BlockRead(TxFile,Zeile[1],l,Result);
      if (TX_Count + Result) > TX_Laenge then Result := TX_Laenge - TX_Count;

      Zeile[0] := chr(Byte(Result));
      if XBTRANS then Zeile:=XBinStr(Kanal, Zeile, DatPos)+Zeile;

      {if XBTrans then Zeile[0] := chr(Byte(Result+7));}

      TX_Count := TX_Count + Result;
      IF (TX_Count >= TX_Laenge) then FileEnde := true;


      if TX_Bin = 0 then           (* Textfile senden *)
      Begin
        While pos(^J,Zeile) > 0 do delete(Zeile,pos(^J,Zeile),1);
        While pos(^Z,Zeile) > 0 do delete(Zeile,pos(^Z,Zeile),1);
        for i := 1 to length(Zeile) do
        case Zeile[i] of
              ^I  : ;
              M1  : ;
          #1..#31 : Zeile[i] := '^';
        end;
        Zeile := Line_convert(Kanal,1,Zeile);
      end else TX_CRC := Compute_CRC(TX_CRC,Zeile);

      S_PAC(Kanal,NU,false,Zeile);
      FileInfo(Kanal,1,TX_Laenge,TX_Count,0,0);

      if FileEnde then
      Begin
        TNC_Puffer := false;
        FileSend := false;
        Result := Word(TX_CRC);
        boxzaehl:=5;
        FiResult := CloseBin(TxFile);
        if not DirScroll then SetzeFlags(Kanal);
        case TX_Bin of
          0 : begin
                if FileSendRem then Send_Prompt(Kanal,FF)
                               else S_PAC(Kanal,NU,true,'');
              end;

          1 : begin
                _aus(Attrib[20],Kanal,M2 + InfoZeile(100) + M1);
                S_PAC(Kanal,NU,true,'');
                if FileSendRem then S_PAC(Kanal,CM,true,'D');
              end;

          3 : begin
                Hstr := Time_Differenz(TX_Time,Uhrzeit);
                Zeile := FName_aus_FVar(TxFile);
                While pos(BS,Zeile) > 0 do delete(Zeile,1,pos(BS,Zeile));

                Zeile := M1 + B1 + InfoZeile(102) + B1 +
                         EFillStr(14,B1,Zeile) + InfoZeile(100) +
                         int_str(Result) + B2 + LRK + Hex(Result,4) + B1 +
                         BdStr + FileBaud(Hstr,int_str(TX_Count)) + B2 +
                         LRK + Hstr + RRK + M1;

                if OFlag then _aus(Attrib[20],Kanal,Zeile);
              {  if FileSendRem then
                begin }

                 {//db1ras}
                 if SysArt = 3 then {FBB}
                   S_PAC(Kanal,NU,true,M1)
                 else begin
                   if (SysArt in [0,17,21]) and not XBin.An then begin
                     {XP, PROFI}
                     S_PAC(Kanal,NU,false,Zeile);
                     Send_Prompt(Kanal,FF);
                   end else if XBin.An then begin
                     S_pac(kanal,NU,TRUE,'');
                     s_pac(kanal,nu,true,xprot+COMD+chr(TRASK));

                     xbin.framenr:=0;
                     xbin.ok:=false;
                     xbin.pdat:=false;
                     xbin.datpos:=0;
                     xbin.retries:=0;
                   end else
                     S_PAC(Kanal,NU,true,'');
                 end;
               { end else S_PAC(Kanal,NU,true,''); }
              end;
        end;
        FileSendRem := false;
      End;
    End;
    FileFlag := false;
  End;
End;


Procedure SF_Text (* Kanal : Byte; Zeile : Str80 *);
var    f      : Text;
       i      : Byte;
       Hstr   : String;
Begin
  with K[Kanal]^ do
  begin
    Assign(f,Zeile);
    if ResetTxt(f) = 0 then
    begin
      WishBuf := true;
      While not Eof(f) do
      begin
        Readln(f,Hstr);
        Hstr := Line_convert(Kanal,1,Platzhalter(Kanal,Hstr)) + M1;
        S_PAC(Kanal,NU,false,Hstr);
      end;
      FiResult := CloseTxt(f);
    end else S_PAC(Kanal,NU,true,InfoZeile(114) + B1 + Zeile + B1 + InfoZeile(115) +M1);
  end;
End;


Procedure TXT_Senden (* Kanal,Art,FNr : Byte *);
Var    Hstr    : String;
       EndText,
       First,
       Flag,
       FixFlag : Boolean;
       TNr     : String[1];
       GegCall : String[6];
       Kenner  : Str32;

  Function  FindLine(TncStr,ArtStr,CallStr : Str9) : Boolean;
  Var   Find : Boolean;
        Tstr : String[4];
        Cstr,
        Rstr : String[9];
  Begin
    Tstr := copy(TncStr,1,3) + 'A';
    Repeat
      Readln(G^.TFile,Hstr);
      KillEndBlanks(Hstr);
      Find := (pos(TncStr + ArtStr,Hstr) = 1) or (pos(TStr + ArtStr,Hstr) = 1);
      if Find and (RestStr(Hstr) > '') then
      begin
        Find := false;
        Repeat
          Hstr := RestStr(Hstr);
          Rstr := CutStr(Hstr);
          if Rstr[length(Rstr)] = '-' then
          begin
            delete(Rstr,length(Rstr),1);
            Cstr := copy(CallStr,1,length(Rstr));
          end else Cstr := CallStr;
          Find := Cstr = Rstr;
        Until Find or (length(Hstr) = 0);
      end;

    Until Find or Eof(G^.TFile);
    FindLine := Find;
  End;

Begin
  with K[Kanal]^ do
  begin
    Assign(G^.TFile,Sys1Pfad + TxtDatei);
    if ResetTxt(G^.TFile) = 0 then
    begin
      Hstr := '';
      Flag := false;
      First := true;
      FixFlag := false;
      TNr := int_str(TncNummer);
      GegCall := Call;
      Strip(GegCall);

      case Art of
       1 : begin   (* INFO *)
             Flag := FindLine(TncI + TNr,TInf + int_str(TNC[TncNummer]^.Info),OwnCall);
           end;
       2 : begin   (* AKTUELL *)
             Flag := FindLine(TncI + TNr,TAkt + int_str(TNC[TncNummer]^.Aktuell),OwnCall);
           end;
       3 : begin   (* CTEXT *)
             Flag := FindLine(TncI + TNr,TCtx + int_str(TNC[TncNummer]^.CText),OwnCall);
           end;
       4 : begin   (* QTEXT *)
             Flag := FindLine(TncI + TNr,TQtx + int_str(TNC[TncNummer]^.QText),OwnCall);
           end;
       5 : begin   (* FIX *)
             Flag := FindLine(TncI + TNr,TFix + int_str(FNr) + GL +
                              int_str(TNC[TncNummer]^.FIX),OwnCall);
             FixFlag := Flag;
           end;
       6 : begin   (* GRT *)
             Flag := FindLine(TncI + TNr,TGrt,GegCall);
             GrtFlag := Flag;
           end;
      end;

      if Flag then
      begin

        if FixFlag then
        begin
          if Vor_im_EMS then EMS_Seite_Einblenden(Kanal,Vor);
          Set_st_Szeile(Kanal,1,1);
          if VorWrite[Kanal]^[stV] <> '' then
          begin
            Vor_Feld_Scroll(Kanal);
            Vor_Dn_Scroll(Kanal);
          end;
        end;

        EndText:=False;

        if (Art=3) or (art=6) then
         begin
           {Kenner:=AutoSysKenner[3]+copy(Version,Pos(' ',Version)+1,Length(Version));
           if node then Kenner:=Kenner + NodeK + M1
              else Kenner:=Kenner+ ']' + M1; }
           Kenner:=AutoSysKenner[3];
           if node then Kenner:=Kenner + NodeK;
           Kenner:=Kenner+copy(Version,Pos(' ',Version)+1,Length(Version))+DatenKenner+int_str(Umlaut);
           if ((user_komp=1) or (user_komp=3)) and (not node) then kenner:=kenner+'C'+int_str(user_komp-1);
           kenner:=kenner+']'+m1;
           S_PAC(Kanal,NU,false,Kenner);
          end;

       EigFlag := SysTextEcho;
       While (not Eof(G^.TFile)) and (Not EndText) do
        begin
          Readln(G^.TFile,Hstr);
          if (pos('#ENDE#',UpcaseStr(Hstr)) > 0) then EndText:=true;
          if Not EndText then
          begin
            Hstr := Line_convert(Kanal,1,Platzhalter(Kanal,Hstr));
            if FixFlag then
            begin
              if not First then
              begin
                Set_st_Szeile(Kanal,0,stV);
                Vor_Feld_Scroll(Kanal);
              end;
              First := false;
              VorWrite[Kanal]^[stV] := Hstr;
              Chr_Vor_Show(Kanal,_End,#255);
              Chr_Vor_Show(Kanal,_Andere,#255);
            end else
             begin
               S_PAC(Kanal,NU,FALSE,Hstr + M1);
             end;
          end;
         end; {while}
      end;
      FiResult := CloseTxt(G^.TFile);
      EigFlag:=false;
    end;
    if art= 3 then RequestName(Kanal);
  end;
End;

Procedure RequestName (* (Kanal) *);
var hstr:String;
begin
 with k[kanal]^ do
  if (not node) and ((not einstiegskanal) and (not ausstiegskanal)) then
  if (not reqName) and (konfig.ReqNam) then
  begin
      hstr:='';
      if User_Name='' then hstr:=hstr+'+' else hstr:=hstr+'-';
      if User_QTH='' then hstr:=hstr+'+' else hstr:=hstr+'-';
      if User_LOC='' then hstr:=hstr+'+' else hstr:=hstr+'-';
      hstr:=Meldung[36]+hstr+'#';
      if pos('+', hstr)>0 then s_pac(kanal, nu, true, hstr+#13);
      reqName:=true;
  end;
end;

Procedure BIN_TX_File_Sofort (* Kanal : Byte ; Zeile : Str80 *);
Var   Bstr     : String[80];
      RResult,
      WResult  : Word;
      HeapFree : LongInt;

Begin
  with K[Kanal]^ do
  begin
    Assign(TxFile,Zeile);
    if ResetBin(TxFile,T) = 0 then
    begin
     FileSend := true;
      TX_Laenge := FileSize(TxFile);

      if TxComp then
      begin
        TX_Count := 0;
        TX_CRC := 0;
        TX_Bin := 3;
        TX_Time := Uhrzeit;
        WishBuf := true;
        S_PAC(Kanal,NU,false,MakeBinStr(Kanal,Zeile));
        FertigSenden(Kanal);
      end else
      begin
        WishBuf := true;
        if not BufExists then OpenBufferFile(Kanal);
        Bstr := MakeBinStr(Kanal,Zeile);
        BlockWrite(BufFile,Bstr[1],length(Bstr),RResult);

        HeapFree := MaxAvail;
        if HeapFree > FA00 then HeapFree := FA00;
        if HeapFree > TX_Laenge then HeapFree := TX_Laenge;

        GetMem(BFeld,HeapFree);
        FillChar(BFeld^,HeapFree,0);
        Seek(BufFile,FileSize(BufFile));

        Repeat
          BlockRead(TxFile,BFeld^,HeapFree,RResult);
          if RResult > 0 then TxLRet := BFeld^[RResult] = 13;
          BlockWrite(BufFile,BFeld^,RResult,WResult);
        Until RResult = 0;

        FreeMem(BFeld,HeapFree);
        FiResult := CloseBin(TxFile);
        FileSend := false;
      end;
    end;
  end;
End;


Procedure TXT_TX_File_Sofort (* Kanal : Byte ; Zeile : Str80 *);
Begin
  with K[Kanal]^ do
  begin
    Assign(TxFile,Zeile);
    if ResetBin(TxFile,T) = 0 then
    begin
      FileSend := true;
      TX_Laenge := FileSize(TxFile);
      TX_Count := 0;
      TX_CRC := 0;
      TX_Bin := 0;
      TX_Time := Uhrzeit;
      FertigSenden(Kanal);
    end;
  end;
End;


Procedure FertigSenden (* Kanal : Byte *);
Begin
  with K[Kanal]^ do
  begin
    WishBuf := true;
    Repeat
      if TX_Bin = 2 then inc(TX_Bin);
      Send_File(Kanal,false);
    Until not FileSend;
  end;
End;
