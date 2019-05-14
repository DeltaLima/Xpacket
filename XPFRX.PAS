{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P F R X .  P A S                                                     ³
 ³                                                                         ³
 ³ Routinen fuer die Speicherung von Savefiles                             ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


Procedure FileRxMenu (* Kanal : Byte *);
Const  ArtMax = 5;
Var    i    : Byte;
       KC   : Sondertaste;
       VC   : Char;
       Flag : Boolean;
       X,Y,
       Art  : Byte;

Begin
  with K[Kanal]^ do
  begin
    Moni_Off(0);
    Flag := false;
    for i := 9 to 15 do G^.Fstx[i] := 2;
    G^.Fstr[7] := InfoZeile(329);
    G^.Fstr[9] := InfoZeile(330);
    G^.Fstr[10] := InfoZeile(331);
    G^.Fstr[11] := InfoZeile(332);
    G^.Fstr[12] := InfoZeile(333);

    case RX_Bin of
      1 : Art := 1;
      2 : Art := 2;
      3,
      4,
      5 : Art := 3;
     else Art := 4;
    end;

    Repeat
      for i := 9 to 12 do
      begin
        G^.Fstr[i][vM+1] := B1;
        G^.Fstr[i][hM+1] := B1;
        G^.Fstr[i][vM] := B1;
        G^.Fstr[i][hM] := B1;
      end;

      if Art in [1..4] then
      begin
        X := vM;
        Y := Art + 8;
      end else
      begin
        X := hM;
        Y := Art + 4;
      end;
      G^.Fstr[Y][X] := A_ch;

      if HardCur then SetzeCursor(X+1,Y);

      case RX_Bin of
        1 : G^.Fstr[9][vM+1] := X_ch;
        2 : G^.Fstr[10][vM+1] := X_ch;
        3,
        4 : G^.Fstr[11][vM+1] := 'x';
        5 : G^.Fstr[11][vM+1] := X_ch;
      end;

      if Save then G^.Fstr[12][vM+1] := X_ch;

      G^.Fstr[13] := '';
      G^.Fstr[14] := '';
      G^.Fstr[15] := '';
      Fenster(15);

      _ReadKey(KC,VC);
      Case KC of
        _Esc : Flag := true;

        _Ret : ;

         _F1 : Art := 1;
         _F2 : Art := 2;
         _F3 : Art := 3;
         _F4 : Art := 4;
         _F5 : Art := 5;
         _F6,
         _F7,
         _F8,
         _F9,
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

       _AltH : XP_Help(G^.OHelp[21]);

         else Alarm;
      End;

      if KC in [_F1.._F5,_Ret] then
      case Art of
        1,
        2,
        3 : begin
              case Art of
                1 : G^.Fstr[9][vM] := S_ch;
                2 : G^.Fstr[10][vM] := S_ch;
                3 : G^.Fstr[11][vM] := S_ch;
              end;
              Fenster(15);
              Datei_Empfangen(Kanal,Art);
              if RX_Bin > 0 then Flag := true;
            end;

        4 : begin
              G^.Fstr[12][vM] := S_ch;
              SaveFile(Kanal);
              if Save then Flag := true;
            end;

        5 : Kill_Save_File(Kanal);
      end;

      SetzeFlags(Kanal);
    Until Flag;
    ClrFenster;
    Neu_Bild;
    Moni_On;
  end;
End;


Procedure Datei_Empfangen (* Kanal : Byte; Art : Byte *);
Var       Flag,
          Fehler  : Boolean;
          l,
          Size    : LongInt;
          KC      : Sondertaste;
          SizeStr : String[10];
          Hstr    : String[60];
          i       : Byte;
Begin
  if Kanal > 0 then with K[Kanal]^ do
  begin
    if RX_Save then
    begin
      Size := FilePos(RXFile);
      CloseRxFile(Kanal,1);
      if Size < 1 then FiResult := EraseBin(RXFile);
      RemoteSave := false;
      Ignore := false;
      RX_Save := false;
      RX_Bin := 0;
      AutoBinOn := AutoBin;
      BoxZaehl:=5;
    end else
    begin
      if RX_Bin = 0 then
      begin
        Fehler := false;
        Flag := false;
        Remotesave := false;
        RX_Bin := Art;
        G^.Fstr[14]:=InfoZeile(204);
        Fenster(15);

        GetString(FRxName,Attrib[3],60,2,15,KC,1,Ins);
        if KC <> _Esc then
        begin
          FRxName := SvFRxCheck(Kanal,FRxName,TxtName);

          if not PfadOk(1,FRxName) then
          begin
            Hstr := FRxName;
            While Hstr[length(Hstr)] <> BS do delete(Hstr,length(Hstr),1);
            Flag := MkSub(Hstr) and PfadOk(1,FRxName);
          end else Flag := true;

          if Flag then
          begin
            if RX_Bin = 1 then         (* Textfile *)
            begin
              if OpenTextFile(Kanal) then
              begin
                RX_Count := 0;
                RX_Laenge := 0;
                RX_TextZn := 0;
                RX_Time := Uhrzeit;
                RX_Save := true;
              end else Fehler := true;
            end else

            if RX_Bin = 2 then   (* Bin„r *)
            begin
              Assign(RXFile,FRxName);
              if ResetBin(RxFile,T) = 0 then
              begin    (* File vorhanden !!! *)
                SizeStr := int_str(FileSize(RXFile));
                G^.Fstr[14] := FRxName + B1 + InfoZeile(156);
                G^.Fstr[15] := InfoZeile(286) + B1+ FormByte(SizeStr) + B3 + InfoZeile(287);
                Size := FileSize(RXFile);
                if Size mod 1000 < 300 then Size := Size - 1000;
                if Size < 0 then Size := 0;
                SizeStr := int_str((Size div 1000) * 1000);
                Fenster(15);
                Alarm;
                GetString(SizeStr,Attrib[3],10,length(G^.Fstr[15])+3,15,KC,3,Ins);
                if KC <> _Esc then
                begin
                  Size := str_int(SizeStr);
                  if Size < 0 then Size := 0;
                  if Size < FileSize(RXFile) then
                  begin
                    Seek(RXFile,Size);
                    Truncate(RXFile);
                    if Size > 0 then
                    begin
                      VorWrite[Kanal]^[stV] := VorWrite[Kanal]^[stV] + B1 + SizeStr;
                      Chr_Vor_Show(Kanal,_End,#255);
                    end;
                  end;
                  RX_CRC := 0;
                  RX_Count := 0;
                  RX_Laenge := 0;
                  RX_Save := true;
                end else
                begin
                  FiResult := CloseBin(RXFile);
                  RX_Bin := 0;
                end;
              end else
              begin   (* alles klar, File ist nicht da *)
                if RewriteBin(RXFile,T) = 0 then
                begin
                  RX_CRC := 0;
                  RX_Count := 0;
                  RX_Laenge := 0;
                  RX_Save := true;
                end else Fehler := true;
              end;
            end else

            if RX_Bin = 3 then     (* Auto-Bin„r *)
            begin
              if Exists(FRxName) then
              begin    (* File vorhanden !!! *)
                Assign(RXFile,FRxName);
                FiResult := ResetBin(RxFile,T);
                Size := FileSize(RXFile);
                FiResult := CloseBin(RxFile);
                l := Size;
                SizeStr := int_str(l);
                G^.Fstr[14] := FRxName + B1 + InfoZeile(156);
                G^.Fstr[15] := InfoZeile(286) + B1+ FormByte(SizeStr) + B3 + InfoZeile(287);
                if l mod 1000 < 300 then l := l - 1000;
                if l < 0 then l := 0;
                SizeStr := int_str((l div 1000) * 1000);
                Fenster(15);
                Alarm;
                GetString(SizeStr,Attrib[3],10,length(G^.Fstr[15])+3,15,KC,3,Ins);
                if KC <> _Esc then
                begin
                  l := str_int(SizeStr);
                  if l < 0 then l := 0;
                  if l < Size then
                  begin
                    RX_Count := l;
                    if l > 0 then
                    begin
                      VorWrite[Kanal]^[stV] := VorWrite[Kanal]^[stV] + B1 + SizeStr;
                      Chr_Vor_Show(Kanal,_End,#255);
                    end;
                  end else RX_Count := Size;
                end else RX_Bin := 0;
              end else AutoBinOn := true; (* alles klar, File ist nicht da *)
            end else RX_Bin := 0;
          end else Fehler := true;
        end else RX_Bin := 0;

        if Fehler then
        begin
          RX_Bin := 0;
          Alarm;
          G^.Fstr[15] := FRxName + B2 + InfoZeile(75) + B2 + InfoZeile(78);
          Fenster(15);
          SetzeCursor(length(G^.Fstr[15])+2,15);
          Warten;
        end;
        Cursor_aus;
      end else RX_Bin := 0;
    end;
  end else Alarm;
End;


Function OpenTextFile (* Kanal : Byte) : Boolean *);
Var   Result : Word;
Begin
  with K[Kanal]^ do
  begin
    Assign(RXFile,FRxName);
    Result := ResetBin(RxFile,T);
    if Result = 0 then Seek(RXFile,FileSize(RXFile))
                  else Result := RewriteBin(RxFile,T);
    OpenTextFile := Result = 0;
  end;
End;


Procedure OpenBinFile (* Kanal : Byte; Zeile : Str80 *);
Var  i, ier : Byte;
     Free : LongInt;
     XFsize:longint;
     xfile : file of byte;
     FlagPkt:Boolean;
     Schnibbel:string[10];

  Function NewName(Kanal,Art : Byte; NStr : Str12) : Str25;
  var   i    : Byte;
        Ext  : String[4];
        Sstr : String[8];
        Hstr : String[12];
        Flag : Boolean;

  begin
    Hstr := K[Kanal]^.Call;
    Strip(Hstr);
    i := 0;

    if Art = 0 then
    begin
      Repeat
        inc(i);
        Sstr := int_str(i) + Hstr;
        Flag := not Exists(Konfig.BinVerz + Sstr + BS + Nstr);
      Until Flag or (i > 250);
      if Flag then
      begin
        if MkSub(Konfig.BinVerz + Sstr) then NewName := Sstr + BS + Nstr;
      end else
      begin
        Ext := Pkt + ParmStr(2,Pkt,Nstr);
        Repeat
          inc(i);
        Until not Exists(Konfig.BinVerz + Hstr + SFillStr(2,'0',int_str(i)) + Ext);
        NewName := Hstr + SFillStr(2,'0',int_str(i)) + Ext;
      end;
    end;

    if Art = 1 then
    begin
      Repeat
        inc(i);
        Ext := Pkt + SFillStr(3,'0',int_str(i));
      Until not Exists(Konfig.BinVerz + Hstr + Ext);
      NewName := Hstr + Ext;
    end;
  end;

Begin
  with K[Kanal]^ do
  begin
    KillEndBlanks(Zeile);
    Zeile := UpCaseStr(Zeile);

    { #BIN#818#|32501#$1AC785A4#A:\TREMEX\VIRUS.TXT }
    { #BIN#205453#|55561#$1EB98723?#fpac391.Lzh }

    if not (XBIN.An) then delete(Zeile,1,5) else delete(Zeile,1,6);

    i := pos('#',Zeile);
    if i = 0 then i := length(Zeile)
             else dec(i);
    if i > 0 then RX_Laenge := LongInt(str_int(copy(Zeile,1,i)))
             else RX_Laenge := 0;

    if RX_laenge > 0 then
    begin
      Free := DiskFree(ord(FRxName[1])-64);
      if (Free + FFFF) > RX_Laenge then
      begin
        if pos(Pipe,Zeile) > 0 then
        begin
          delete(Zeile,1,pos(Pipe,Zeile));
          i := pos(LZ,Zeile);
          if i > 0 then
          begin
            RX_Soll_CRC := Word(str_int(copy(Zeile,1,i-1)));
            delete(Zeile,1,i);
          end else RX_Soll_CRC := 0;
        end else RX_Soll_CRC := 0;

        if (pos('$',Zeile) = 1) and (pos(LZ,Zeile) in [10,11]) then
        begin
          RX_Date := str_int(copy(Zeile,1,9));
          delete(Zeile,1,pos(LZ,Zeile));
        end else RX_Date := 0;
        xfsize:=0;
        if RX_Bin = 0 then
        begin
          While pos(DP,Zeile) > 0 do delete(Zeile,1,pos(DP,Zeile));
          While pos(BS,Zeile) > 0 do delete(Zeile,1,pos(BS,Zeile));

        {**Check fr berl„nge}
          flagpkt:=false;
          if pos(Pkt,Zeile) = 0  then
           begin
            Zeile := Zeile + Pkt;
            flagpkt:=true;
           end;

          if pos(Pkt, Zeile)>9 then
           begin
            Zeile[7]:='~';
            ier:=0;
            repeat
             inc(ier);
             Schnibbel:=int_str(ier);
             Zeile[8]:=Schnibbel[1];
            until (not Exists(Konfig.BinVerz + Zeile)) or (ier>8);
            repeat
             delete(Zeile,9,1);
            until Zeile[9]='.';
           end; {>9}

         if (length(zeile)-pos(pkt, Zeile))>3 then
          begin
           repeat
            delete(Zeile, length(zeile), 1);
           until (length(zeile)-pos(pkt, Zeile))<=3;
          end;
          if FlagPkt then delete(Zeile, length(zeile), 1);
          FlagPkt:=false;
   {**Check fr berl„nge Ende}

          if SaveNameCheck(0,Zeile) then
          begin
            if pos(Pkt,Zeile) > 0 then
            begin
              if Exists(Konfig.BinVerz + Zeile) then
               begin
                if xbin.an then
                 begin
                  assign(xfile, Konfig.BinVerz+Zeile);
                  reset(XFile);
                  xfsize:=filesize(XFile);
                  if (rx_laenge>xfsize) and (xFsize>1999) then
                   begin
                    xfsize:=xfsize-1000
                   end else xfsize:=0;
                  close(XFile);
                 end;
                 if (not xbin.an) or (xfsize=0) then Zeile := NewName(Kanal,0,Zeile);
               end;
            end else Zeile := NewName(Kanal,1,Zeile);
          end else Zeile := NewName(Kanal,1,Zeile);
          FRxName := Konfig.BinVerz + Zeile;
        end;

        Assign(RXFile,FRxName);

        if RX_Bin = 0 then
        begin
          RemoteSave := true;
          if (not XBin.An) or (XFsize=0) then FiResult := RewriteBin(RXFile,T);
        end;

        if RX_Bin = 3 then
        begin
          FiResult := ResetBin(RXFile,T);
          if FiResult = 0 then
          begin
            Seek(RXFile,RX_Count);
            Truncate(RXFile);
          end else FiResult := RewriteBin(RXFile,T);
        end;

        if RX_Bin = 4 then
        begin
          RemoteSave := true;
          FiResult := RewriteBin(RXFile,T);
        end;

        if FiResult = 0 then
        begin
          if not FileSend then
          begin
            if (not xbin.an) or ((xbin.an) and (xfsize=0)) then
             begin
             S_PAC(Kanal,NU,true,Meldung[9] + M1);   { #OK# }
             InfoOut(Kanal,0,1,Meldung[9]);
             XBin.FrameNr:=0;
            end;

            if (xbin.an) and (xfsize>0) then
             begin
              XBin.FrameNr:=0;
              S_PAC(Kanal,NU,true,Meldung[9] + int_str(xFsize)+ M1);
              reset(RXFile, T);
              Seek(RXFile,xfsize);
              Truncate(RXFile);
              InfoOut(Kanal,0,1,Meldung[9]+Int_Str(XFsize));
              rx_Count:=xfsize;
             end;

            if xbin.an then xbin.rx:=true;
          end;
          if not xbin.rx then
           begin
            RX_Save := true;
            Ignore := true;
           end;
          xbin.rtxOK:=true;
          RX_Time := Uhrzeit;
          RX_Count := 0;
          RX_TextZn := 0;
          RX_CRC := 0;
          if not XBin.An then RX_Bin := 5 else XBin.RX:=true;
        end else
        begin
          S_Aus(Kanal,3,M1 + Meldung[10] + M1);  { #ABORT# }
          S_PAC(Kanal,NU,true,'');
        end;
      end else
      begin
        RX_Bin := 0;
        RemoteSave := false;
        Ignore := false;
        S_Aus(Kanal,3,M1 + Meldung[10] + M1);  { #ABORT# }
        S_PAC(Kanal,NU,true,'');
        SetzeFlags(Kanal);
      end;
    end;
  if xbin.an then rx_bin:=0;
  end;
End;


Procedure Write_RxFile (* Kanal : Byte; Zeile : String *);
Var     i,i1   : Integer;
        Free   : LongInt;
        DatPos:longint;
        Result : Word;
        Hstr   : String[80];
        VC     : Char;
        Bstr   : String;
        XBinRX : string;

Begin
  with K[Kanal]^ do
  Begin
    case RX_Bin of

     1 : begin           (* normales Textfile *)
           if RemoteSave and (MldOk in [16,17]) then
           begin
             CloseRxFile(Kanal,0);
             RX_Save := false;
             BoxZaehl:=5;
             RX_Bin := 0;
             RemoteSave := false;
             If Not FWD then
              S_Aus(Kanal,3,M1 + InfoZeile(117) + B1 +
                 int_Str(RX_TextZn) + B1 + InfoZeile(118)+ M1);
             if MsgToMe then
             begin
               MsgToMe := false;
               Eig_Mail_Zeile := '';
               Check_Eig_Mail(1,maxLink);
               if Eig_Mail_Zeile > '' then
               begin
                 InfoOut(show,0,1,InfoZeile(153) + Eig_Mail_Zeile);
                 If Klingel then Triller;
               end;
             end;
             Ignore := false;
             SetzeFlags(Kanal);
             Send_Prompt(Kanal,FF);
           end else
           if RemoteSave and (MldOk = 10) then
           begin
             CloseRxFile(Kanal,0);
             RX_Save := false;
             BoxZaehl:=5;
             RX_Bin := 0;
             RemoteSave := false;
             Ignore := false;
             if EraseBin(RXFile) = 0
              then S_Aus(Kanal,3,M1 + Star + InfoZeile(41) + M1);
             SetzeFlags(Kanal);
             Send_Prompt(Kanal,FF);
           end else
           begin
             RX_Count := RX_Count + length(Zeile);
             Zeile := Line_Convert(Kanal,2,Zeile);
             Bstr := '';
             for i := 1 to length(Zeile) do
             Begin
               VC := Zeile[i];
               case VC of
                ^I  : Bstr := Bstr + VC;
                M1  : begin
                        Bstr := Bstr + #13 + #10;
                        inc(RX_TextZn);
                      end;

                #1..#31
                    : Bstr := Bstr + '^' + chr(ord(VC)+64);

                  ^Z :;
                 #0  :;
                 #127:;

                else  Bstr := Bstr + VC;
               end;

               if (length(Bstr) > 250) or (i = length(Zeile)) then
               begin
                 BlockWrite(RXFile,Bstr[1],length(Bstr),Result);
                 Bstr := '';
               end;
             End;

             FileInfo(Kanal,0,0,RX_Count,0,0);
           end;
         end;

     2 : begin  (* normales Bin„rfile-Empfangen *)
           BlockWrite(RXFile,Zeile[1],length(Zeile),Result);
           RX_Count := RX_Count + length(Zeile);
           FileInfo(Kanal,0,0,RX_Count,0,0);
         end;

     5 : begin  (* Automatischer Bin„rfile-Empfang *)
           if MldOk in [5,6,10] then
           begin
             if MldOk = 10 then
             begin
               FiResult := CloseBin(RxFile);
               FiResult := EraseBin(RxFile);
               S_PAC(Kanal,NU,false,InfoZeile(41) + M1);
               Send_Prompt(Kanal,FF);
             end else CloseRxFile(Kanal,1);
             RX_Bin := 0;
             RX_Save := false;
             BoxZaehl:=5;
             Remotesave := false;
             Ignore := false;
             AutoBinOn := AutoBin;
             SetzeFlags(Kanal);
           end else
           begin
             if xbin.an then
              begin
               if length(zeile)>8 then
               begin
                XBinRX := copy (Zeile, 1, 8);
                delete (Zeile,1,8);
               end else
                begin
                 XBinRX := Zeile;
                 zeile:='';
                end;
               DatPos:=filePos(RXFile);
               XBinCHECK(Kanal, XBinRX, DatPos, Zeile);
              end;
             i1 := length(Zeile);
             if (RX_Count + i1) > RX_Laenge then i1 := Byte(RX_Laenge - RX_Count);
             BlockWrite(RXFile,Zeile[1],i1,Result);
             RX_CRC := Compute_CRC(RX_CRC,copy(Zeile,1,Result));
             RX_Count := RX_Count + i1;
             FileInfo(Kanal,0,RX_Laenge,RX_Count,0,0);

             if RX_Count >= RX_Laenge then
             begin
               CloseRxFile(Kanal,0);
               Result := Word(RX_CRC);
               RX_Save := false;
               BoxZaehl:=5;
               RX_Bin := 0;
               AutoBinOn := AutoBin;
               Ignore := false;
               SetzeFlags(Kanal);

               Hstr := Time_Differenz(RX_Time,Uhrzeit);
               Zeile := FName_aus_FVar(RxFile);
               While pos(BS,Zeile) > 0 do delete(Zeile,1,pos(BS,Zeile));

             { Zeile := M1 + B1 + InfoZeile(103) + B1 + }
               Zeile := B1 + InfoZeile(103) + B1 + {//db1ras}
                        EFillStr(14,B1,Zeile) + InfoZeile(100) +
                        int_str(Result) + B2 + LRK + Hex(Result,4) + B1 +
                        BdStr + FileBaud(Hstr,int_str(RX_Count)) + B2 +
                        LRK + Hstr + RRK + M1;

               if (RX_Soll_CRC > 0) and (Result <> RX_Soll_CRC)
                then Zeile := Zeile + B1 + InfoZeile(113) + ^G + M1;
             {  Zeile := Zeile + M1; }

               {//db1ras}
               if SysArt in [0,17,21] then begin {XP, PROFI}
                 S_PAC(Kanal,NU,false,Zeile);
                 Send_Prompt(Kanal,FF);
               end else if SysArt = 3 then {FBB}
                 S_PAC(Kanal,NU,true,M1);

               Remotesave := false;
               if RxComp then MeldeCompZ := ''
                         else MeldeZeile := '';
               DZeile := Zeile;
               WeFlag := true;
             end;
           end;
         end;
    end; (* case RX_Bin of ... *)
  End; (* with ... do *)
End;


Procedure CloseRxFile (* Kanal,Art : Byte *);
Var    dt : DateTime;
Begin
  with K[Kanal]^ do
  begin
    if ((RX_Bin = 5) or (Xbin.An)) and (RX_Date > 0) then
    begin
      if Art = 1 then
      begin
        UnpackTime(RX_Date,dt);
        dt.Year := dt.Year + 50;
        PackTime(dt,RX_Date);
      end;
      SetFTime(RxFile,RX_Date);
    end;
    FiResult := CloseBin(RxFile);
  end;
End;


Procedure SaveFile (* Kanal : Byte *);
var     Result : Word;
        Hstr   : String[60];
        KC     : Sondertaste;
        Flag   : Boolean;
Begin
  with K[Kanal]^ do
  begin
    if Save then
    begin
      Save := false;
      FiResult := CloseBin(SFile);
    end else
    begin
      Flag := false;
      Fenster(15);
      GetString(SvName,Attrib[3],60,2,15,KC,1,Ins);
      svname:=upcasestr(SvName);
      if KC <> _Esc then
      begin
        SvName := SvFRxCheck(Kanal,SvName,SaveName);

        if not PfadOk(1,SvName) then
        begin
          Hstr := SvName;
          While Hstr[length(Hstr)] <> BS do delete(Hstr,length(Hstr),1);
          Flag := MkSub(Hstr) and PfadOk(1,SvName);
        end else Flag := true;

        if Flag then
        begin
          Assign(SFile,SvName);
          Result := ResetBin(SFile,T);
          If Result = 0 then Seek(SFile,FileSize(SFile))
                        else if Result = 2 then Result := RewriteBin(SFile,T);
          if Result in [0,2] then Save := true;
        end;

        if not Save then
        begin
          Alarm;
          G^.Fstr[15] := InfoZeile(295) + B2 + InfoZeile(78);
          Fenster(15);
          SetzeCursor(length(G^.Fstr[15])+2,15);
          Warten;
          Cursor_aus;
        end else SvLRet := true;
      end;
    end;
  end;
End;


Procedure Write_SFile (* Kanal : Byte; Zeile : String *);
Var     i      : Byte;
        Result : Word;
        VC     : Char;
        Flag   : Boolean;
        Hstr   : String;

Begin
  Flag := K[Kanal]^.EigFlag or K[Kanal]^.FileFlag or K[Kanal]^.RemFlag;

  Zeile := Line_Convert(Kanal,2,Zeile);
  Hstr := '';
  for i := 1 to length(Zeile) do
  Begin
    VC := Zeile[i];

    if Flag and (Kanal > 0) and K[Kanal]^.SvLRet then Hstr := Hstr + EchoCh + B1;
    K[Kanal]^.SvLRet := false;

    case VC of
     ^I  : Hstr := Hstr + VC;
     ^J  : if Kanal = 0 then Hstr := Hstr + #13 + #10;
     M1  : begin
             if (Kanal = 0) and ZeigeRET then Hstr := Hstr + '^' + chr(ord(^J)+64);
             Hstr := Hstr + #13 + #10;
             K[Kanal]^.SvLRet := true;
           end;
      ^Z :;
     #0  :;
     #127:;
     #1..#31
         : Hstr := Hstr + '^' + chr(ord(VC)+64)
     else  Hstr := Hstr + VC;
    end;

    if (length(Hstr) > 250) or (i = length(Zeile)) then
    begin
      BlockWrite(K[Kanal]^.SFile,Hstr[1],length(Hstr),Result);
      Hstr := '';
    end;
  End;
End;


Function SvFRxCheck (* Kanal : Byte; Zeile : Str60; Name : Str12) : Str60 *);
Begin
  if (Zeile = '') or (Zeile[length(Zeile)] = BS) or not SaveNameCheck(1,Zeile)
   then Zeile := Konfig.SavVerz + Name + SFillStr(3,'0',int_str(Kanal));
  if pos(Pkt,Zeile) = 0 then Zeile := Zeile + Pkt + SFillStr(3,'0',int_str(Kanal));
  if pos(DP,Zeile) = 0 then Zeile := Konfig.SavVerz + Zeile;
  SvFRxCheck := Zeile;
End;
