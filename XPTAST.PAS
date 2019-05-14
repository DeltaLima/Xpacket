{⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
 ≥                                                                         ≥
 ≥                             X - P a c k e t                             ≥
 ≥                                                                         ≥
 ≥                                                                         ≥
 ≥  X P T A S T . P A S                                                    ≥
 ≥                                                                         ≥
 ≥ Auswerte-Unit der verschiedenen ESC-, ALT- und CTRL-Befehle             ≥
 ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ}


Function  ESC_Auswert (* (Zeile : Str9) : Byte *);
var       i,min,Nr : Byte;
          Found    : Boolean;
          Hstr     : String[9];


Begin
  Zeile := CutStr(Zeile);
  i := 0;
  Nr := 0;
  Repeat
    inc(i);
    Hstr := ParmStr(2,B1,G^.ESCP[i]);
    min := Byte(str_int(ParmStr(3,B1,G^.ESCP[i])));
    Found := (copy(Hstr,1,ord(Zeile[0])) = Zeile) and (ord(Zeile[0]) >= min);
  Until Found or (i >= maxESC);
  if Found then Nr := str_int(copy(G^.ESCP[i],1,2));
  ESC_Auswert := Nr;
End;


Procedure Auswert_CMD (* Kanal : Byte; InputZeile : Str80 *);
Var   Command : Byte;
      db, i3, i2 , AllTyp     : Byte;
      i,i1    : Integer;
      flagq,
      Flag    : Boolean;
      Bstr    : String;
      sloc,
      sqth,
      QTH1,
      QTH2    : string[31];
      KC      : Sondertaste;
      VC      : Char;
      udb     : user_typ2;
      L_I:longint;
      Entfg,Richtg,
      Oeslae,NoeBre : real;
      status : boolean;
Begin
  with K[Kanal]^ do
  begin
    if Kanal = 0 then K[0]^.TncNummer := Unproto;
    delete(InputZeile,1,1);
    KillStartBlanks(InputZeile);
    KillEndBlanks(InputZeile);
    Command := ESC_Auswert(UpCaseStr(InputZeile));

    Case Command of
     0 : Begin               (* Kein ESC-Befehl *)
           if Kanal = 0 then K[0]^.TncNummer := Unproto;
           if (length(InputZeile) > 0) and not
              (UpCase(InputZeile[1]) in ['C','D','I','O','Q','J','T'])
                then S_PAC(Kanal,CM,true,InputZeile) else Alarm;
         End;

     1 : MH_Show;                  (* MHeard *)

     2 : Begin                     (* PacLen *)
          if (not xbin.rx) and (not xbin.tx) then
          begin
           if pos(B1,InputZeile) > 0 then
           begin
             i := Integer(str_int(RestStr(InputZeile)));
             if (i > 0) and (i < 256) then PacLen := i;
           end;
           InfoOut(Kanal,0,1,InfoZeile(13) + ' = ' + int_str(PacLen));
          end else InfoOut(Kanal,0,1,'Paclen nicht wÑhrend XBin RX/TX umstellbar!');
         End;

     3 : if (Kanal > 0) and (pos(B1,InputZeile) > 0) and connected then
         Begin                        (* CALL - Kommando *)
           ESC_Call:=true;
           InputZeile := UpCaseStr(InputZeile);
           NodeCon := true;
           L_ON(Kanal,TncConStr+B1+ParmStr(2,B1,InputZeile),false,true);
           ESC_Call:=false;
         End else Alarm;

     4 : Begin                 (* CLEARSCREEN, CLS *)
           if pos('ALL', upcasestr(reststr(inputzeile)))>0 then
            begin
             for i:=1 to maxlink do _aus(Attrib[18],i,conststr(M1,60));
            end else
           if Kanal > 0 then _aus(Attrib[18],Kanal,ConstStr(M1,60))
                        else Alarm;
         End;

     5 : Begin                      (* @UPLOAD, nur fÅr Falcon *)
           S_PAC(Kanal,CM,true,InputZeile);
           if pos(TncInvStr,Response) = 0 then Upload := true;
         End;

     6 : ZeigeRET := not ZeigeRET;      (* CRRET *)

     7 : if not (Test or Mo.MonActive) and      (* Connect *)
            not((Kanal = ConvHilfsPort) and Conv.Active) and
            not (connected)
         then Connect(Kanal,InputZeile) else Alarm;

     8 : Begin                      (* DIR *)
           InputZeile := RestStr(UpCaseStr(InputZeile));
           if pos(DP,InputZeile) = 0 then
               InputZeile := Konfig.SavVerz + InputZeile;
           DirZeig(InputZeile,VC,true);
           if VC <> Esc then VorWrite[Kanal]^[stV] :=
                             VorWrite[Kanal]^[stV] + InputZeile;
           Cursor_aus;
           Neu_Bild;
         End;

     9 : Begin                          (* POLL *)
           TNC_Halt := not TNC_Halt;
           if TNC_Halt then InfoOut(Kanal,0,1,InfoZeile(255))
                       else InfoOut(Kanal,0,1,InfoZeile(205));
         End;

     10: Begin   (* Logbuch *)
           Teil_Bild_Loesch(1,maxZ,0);
           ExecDOS(Konfig.ViewVerz + B1 + Sys1Pfad + LogDatei + LngExt);
           Neu_Bild;
         End;

     11: If Idle then Idle_Einstellen(Kanal,InputZeile)   (* IDLE *)
                 else
                  begin
                   Alarm;
                   InfoOut(Kanal,0,1,'IDLE AUS')
                  end;

     12: Auswert_Kopieren(Kanal,InputZeile);   (* COPY *)

     13: If pos(B1,InputZeile) > 0    (* ALL *)
            then
             begin
             AllTyp:=0;
              if length(Parmstr(2, B1, InputZeile))=1 then
               begin
                BStr:=InputZeile;
                BStr:=RestStr(Bstr);
                if UpcaseStr(BStr[1])='T' then AllTyp:=1;
                if UpcaseStr(Bstr[1])='N' then AllTyp:=2;
                if AllTyp>0 then delete(InputZeile,Pos(B1, InputZeile),2);
               end;
              if allTyp=0 then SendToChannel(Kanal,1,1,maxLink,InputZeile);
              if allTyp=1 then {Wenns an Terms soll}
               begin
                for i:=1 to maxLink do
                 if (not K[i]^.Node) and (K[i]^.connected) Then SendToChannel(Kanal,1,i,i,InputZeile);
               end;
              if allTyp=2 then {Wenns an Nodes soll}
               begin
                for i:=1 to maxLink do
                 if (K[i]^.Node) and (K[i]^.connected) Then SendToChannel(Kanal,1,i,i,InputZeile);
               end;
             end
           else Alarm;

     14: Begin              (* LMAIL *)
           Eig_Mail_Zeile := '';
           Check_Eig_Mail(1,maxLink);
           if Eig_Mail_Zeile <> ''
           then InfoOut(Kanal,0,1,InfoZeile(153) + Eig_Mail_Zeile)
           else InfoOut(Kanal,1,1,InfoZeile(133));
         End;

     15,
     16: If Kanal > 0 then     (* MaxFrame *)
         Begin
           if pos(B1,InputZeile) > 0 then
           begin
             i := Integer(str_int(RestStr(InputZeile)));
             if (i > 0) and (i < 8) then
             begin
               MaxFrame := i;
               S_PAC(Kanal,CM,true,'O' + int_str(MaxFrame));
             end else Alarm;
           end;
           InfoOut(Kanal,0,1,InfoZeile(318) + ' = ' + int_str(MaxFrame));
         End else Alarm;

     17: InfoOut(Kanal,1,1,InfoZeile(15));  (* QRES - Kommando *)

     18: begin                           {* quiet *}
           InputZeile:=upcaseStr(InputZeile);
           if (not QuietZeitG) and (pos('/T', INPUTZeile)=0) then
            begin
             Quiet:=not Quiet;
             if pos('ON', InputZeile)>0 then Quiet:=true;
             if pos('OFF', InputZeile)>0 then Quiet:=false;
             Klingel:=not quiet;
             SetzeFlags(Kanal);
               Bstr:=infozeile(46)+' ';
                if Quiet then infoOut(Kanal,0,1,Bstr+iNFOZeile(76))
                 else
                  begin
                   infoOut(Kanal,0,1,Bstr+iNFOZeile(77));
                   quiet_uhr:=false;
                  end;
             end; {not zeitg}

           if (QuietZeitG) and (pos('/T', InputZeile)=0) then
            begin
             Quiet:=false;
             QuietZeitG:=false;
             infoOut(Kanal,0,1,iNFOZeile(44)+' '+InfoZeile(77));
            end;
           if (pos('/T', InputZeile)>0) then
            begin
                QuietZeitG:=true;
                infoOut(Kanal,0,1,iNFOZeile(44)+' '+InfoZeile(76));
            end;
          end;

     19: Begin                         (* DOS *)
           InputZeile := RestStr(UpCaseStr(InputZeile));
           Moni_Off(1);
           DosAufruf(InputZeile,1);
           if InputZeile <> 'OK' then InfoOut(Kanal,1,1,InfoZeile(166));
           Moni_On;
         End;

     20: If pos(B1,InputZeile) <> 0 then InfoOut(Kanal,1,1,InfoZeile(16)) else
         begin                    (* D - Kommando *)
           if Kanal = 0 then K[0]^.TncNummer := Unproto;
           S_PAC(Kanal,CM,true,'D');
         End;

{$IFNDEF no_Bake}       {//db1ras}
     21: BakenMenu;             (* BAKE *)
{$ENDIF}

     22,65: If Kanal > 0 then      (* LAUFZEIT / RTT *)
         Begin
           RTF := true;
           S_PAC(Kanal,NU,true,M1 + InfoZeile(222) + B1 + Meldung[25] + Uhrzeit + M1);
         End else Alarm;

     23: Begin  (* NAME - Namen zur Liste addieren *)
          if connected or test then
          begin
           InputZeile := RestStr(InputZeile);
           Bstr := Call;
           {if connected then Bstr := Call else
           begin
             Bstr := CutStr(UpCaseStr(InputZeile));
             InputZeile := RestStr(InputZeile);
           end;}
           Neu_Name(Kanal,0,Bstr,InputZeile);
           User_Name := InputZeile;
           if connected then UserInStatus(kanal);
          end;
         End;

     24: Begin                           (* Trenn *)
           GlobalTrenn := not GlobalTrenn;
           If GlobalTrenn then InfoOut(Kanal,0,1,InfoZeile(277))
                          else InfoOut(Kanal,0,1,InfoZeile(278));
         End;

     25: Begin        (* I - Call fÅr den Kanal eingeben *)
           InputZeile := RestStr(UpCaseStr(InputZeile));
           if InputZeile = '' then S_PAC(Kanal,CM,true,'I') else
           if Kanal > 0 then
           begin
            bstr:=inputzeile;
            strip(bstr);
            for i:=1 to length(bstr) do
             if not (chr(ord(bstr[i])) in ['a'..'z','A'..'Z','1'..'9','0']) then flag:=false;
             if flag then
              begin
               S_PAC(Kanal,CM,true,'I ' + InputZeile);
               if pos(TncInvStr,Response) = 0 then
               begin
                 OwnCall := InputZeile;
                 Rufz_TNC_init(Kanal);
               end;
              end else InfoOut(Kanal,0,1,InfoZeile(443));
           end else Alarm;
         End;

     26: Morse_Menue(Kanal);         (* Morsen *)

     27: if not (connected or Test) and (Kanal > 0) and    (* Monitor *)
            (Kanal <> ConvHilfsPort)
            then Calls_Monitoren(Kanal,RestStr(UpCaseStr(InputZeile)))
            else Alarm;

     28: If (Kanal > 0) then Echo_Menue(Kanal) else Alarm;     (* Echo *)

     29: Color_Einstellung;                    (* COLOR *)

     30: Auto_Aktivieren(Kanal,InputZeile);    (* AUTO *)

     31: Begin                                 (* SHOWNAME *)
           InputZeile := UpCaseStr(RestStr(InputZeile));
            bstr:='';
             if UserSuchRoutine(inputzeile, L_I, TRUE, false) then
             begin
               Datensatzholen (L_I,Udb);
               Bstr:=UDb.Name;
               SQTH:=Udb.qth;
               SLoc:=Udb.Locator;
             end;
             if BStr<>'' then
              begin
               if SQTH='' then SQTH:=InfoZeile(390);
               if Sloc='' then SLoc:=InfoZeile(391);
               InfoOut(Kanal,0,1,InputZeile + ' : ' + Bstr+', '+SQTH+', '+SLoc)
             end else InfoOut(Kanal,1,1,InputZeile + ' : ' + InfoZeile(137));
         End;

     32: G^.InfoStr := RestStr(InputZeile);    (* Remark *)

     33: if (connected) or (test) then Remote_Emulieren(Kanal,InputZeile); (* Send // *)

     34: Begin      (* Channel *);
           i := str_int(RestStr(InputZeile));
           if i in [0..maxLink] then SwitchChannel(i)
                                else Alarm;
         End;

     35: begin
{          _aus(Attrib[18],Kanal,'TE'+chr(9)+'st');}
          TestCheck(Kanal,InputZeile);           (* Test *)
         end;

     36: Begin              (* KMAIL *)
           Bstr := UpCaseStr(RestStr(InputZeile));
           if Bstr = '' then Bstr := OwnCall;
           Strip(Bstr);
           Bstr := Bstr + MsgExt;
           if Exists(Konfig.MailVerz + Bstr) then
           begin
             KillFile(Konfig.Mailverz + Bstr);
             InfoOut(Kanal,1,1,InfoZeile(134));
             Eig_Mail_Zeile := '';
             Check_Eig_Mail(1,maxLink);
           end else InfoOut(Kanal,1,1,InfoZeile(133) + ' (' + Bstr + ')');
         End;

     37: Belog_Eintrag(Kanal);                  (* BELOG *)

     38: File_Bearbeiten(Kanal,InputZeile);     (* FILE *)

     39: If (connected or Test) and (Kanal > 0) (* PRIV *)
          then Sysop_Einloggen(Kanal,InputZeile)
          else Alarm;

     40,
     41,
     42: Begin  (* Retry *) (* IPoll *) (* TXDELAY *)
           Case Command of
             40 : Bstr := 'N';
             41 : Bstr := '@I';
             42 : Bstr := 'T';
           end;
           Bstr := Bstr + RestStr(UpCaseStr(InputZeile));
           S_PAC(Kanal,CM,true,Bstr);
         End;

     43: If Kanal > 0 then   (* RCMD *)
         Begin
           InputZeile := UpCaseStr(InputZeile);
           RC_Update(Kanal, InputZeile);
           if InputZeile <> '*' then
                       InfoOut(Kanal,0,1,InputZeile)
                       else RC_Alle(Kanal,2);
         End else Alarm;

     44: QRG_Einstellen(Kanal,RestStr(InputZeile));

     45: Begin              (* RMAIL *)
           if pos(B1,InputZeile) > 0
              then Bstr := RestStr(InputZeile)
              else Bstr := OwnCall;
           strip(Bstr);
           Bstr := Bstr + MsgExt;
           if Exists(Konfig.MailVerz + Bstr) then
           begin
             Teil_Bild_Loesch(1,maxZ,0);
             Cursor_ein;
             ExecDOS(Konfig.ViewVerz + B1 + Konfig.MailVerz + Bstr);
             Cursor_aus;
             Neu_Bild;
           end else InfoOut(Kanal,1,1,InfoZeile(133) + ' (' + Bstr + ')');
         End;

     46: Begin     (*  ABORT *)
           S_PAC(Kanal,NU,true,M1 + Meldung[10] + M1);
           BoxZaehl:=5;
             if (TX_Bin>0) or (xbin.an) then
              begin
                FiResult := CloseBin(TxFile);
                FileSend := false;
                TX_Bin:=0;
              end;
             {if RX_Bin>0 then
              begin
               FiResult := CloseBin(RxFile);
               FiResult := EraseBin(RxFile);
               RX_Bin := 0;
               RX_Save := false;
               Remotesave := false;
              end;}
              if xbin.an then CloseXBinProt(kanal);
              xbin.tx:=false;
              {xbin.rx:=false;}
              xbin.an:=false;
              xbin.eof:=false;
              xbin.rtxok:=true;
             AutoBinOn := AutoBin;
             SetzeFlags(Kanal);
         End;

     47: Begin                                   (* HOLD *)
           InputZeile := RestStr(InputZeile);
           Link_erhalter(Kanal,InputZeile);
           SetzeFlags(Kanal);
           InfoOut(Kanal,0,1,InputZeile);
         End;

     48: If not G^.MakroLearn then              (* MAKRO *)
         Begin
           MakroInit;
           Makro_Aktivieren(RestStr(InputZeile));
         End else InfoOut(Kanal,1,1,InfoZeile(284));

     49: Text_Einstellung(Kanal);               (* TEXT *)

     50: if kanal > 0 then TNC_Parm(Kanal,2)
           else alarm;                          (* TNC *)


     51: if Kanal > 0 then                      (* WINDOW *)
         Begin
           Change_WIN;
           Neu_Bild;
         End else Alarm;

     52: ConversAuswert(Kanal,str_int(RestStr(InputZeile)));  (* Convers *)

     53: LptEscSeq(Kanal,RestStr(InputZeile));

     54: begin
           if Kanal > 0 then Node := not Node;
           SetzeFlags(Kanal);
           Bstr:='Node ';
           if Node then BSTR:=Bstr+InfoZeile(76)
              else Bstr:=Bstr+InfoZeile(77);
           InfoOut(Kanal,0,1,BSTR);
         end;

     55: if kanal > 0 then
           begin
              MailsZeigen(kanal);
              Neu_Bild;
         end;

     56: begin (* SCAN *)
          i1:=0;
          db:=9;
          if Scan_ then
          for i:=1 to maxAnwesend do
           if Anwesend[i]^.Da then
            begin
              inc(i1);
              if i1=1 then InfoOut(Kanal,0,1,infoZeile(302));
              G^.Fstr[db]:=G^.Fstr[db]+EFillStr(10,b1,Anwesend[i]^.Call);
              if (i1 mod 7)=0 then inc(db);
             end;
          if i1=0 then InfoOut(Kanal,0,1,infoZeile(303))
          else
           begin
            for i := 9 to 20 do G^.Fstx[i] := 4;
            G^.Fstr[7] := InfoZeile(302);
            if db<19 then db:=db+2 else inc(db);
            G^.FStr[db]:=InfoZeile(454);
            Fenster(db);
            flag:=false;
            repeat
             _ReadKey(KC,VC);
             if KC=_F1 then
              begin
               flag:=not flag;
               if flag then G^.FStr[db][G^.Fstx[db]-1]:='X'
                else G^.FStr[db][G^.Fstx[db]-1]:=B1;
               Fenster(Db);
              end;
            until KC=_ESC;
            if flag then
             begin
              for i:=1 to maxanwesend do Anwesend[i]^.da:=false;
              Scan_:=false;
             end;
            ClrFenster;
            Neu_Bild;
           end;
         end;

     57: begin (* QTH *)
          if connected or test then
          begin
           FillChar(udb,SizeOf(udb),0);
           Udb.QTH:=RestStr(InputZeile);
           user_qth:=udb.qth;
           udb.Call:=call;
           PutUser(Udb,db,3,L_I,false);
           if connected then Begin
             InfoOut(Kanal,0,1,ParmStr(4,B1,infozeile(195))+': '+user_qth);
             UserInStatus(kanal);         {//db1ras}
           End;
          end;
         end;
     58: begin (* LOCator *)
         if connected or test then
          begin
           FillChar(udb,SizeOf(udb),0);
           Udb.Locator:=RestStr(upcaseStr(InputZeile));
           user_loc:=udb.locator;
           udb.Call:=call;
           PutUser(Udb,db,2,L_I,false);
           if connected then Begin
             InfoOut(Kanal,0,1,ParmStr(5,B1,infozeile(195))+': '+user_loc);
             UserInStatus(kanal);         {//db1ras}
           End;
          end;
         end;

     59: begin (* CalcLoc *)
           Bstr:=reststr(InputZeile);
           qth1:=Parmstr(1,B1,Bstr);
           qth2:=Parmstr(2,B1,Bstr);
            flag:=false;

            if (qth1<>'') and (qth2='') then
              if (pos('/',qth1)>0) then flag:=true;

            QTH_Pruefen(QTH1,Oeslae,NoeBre,status);
            QTH1:= WINKEL_IN_NEU(OESLAE,NOEBRE);

            if Flag then
             begin
              _aus(Attrib[19],Kanal,m1+InfoZeile(411)+B1+qth1+m2);
             end;

            if QTH2<>'' then
             begin
              QTH_Pruefen(QTH2,Oeslae,NoeBre,status);
              qth2:= WINKEL_IN_NEU(OESLAE,NOEBRE);
              QTH_ENTFG_RICHTG(qth1,qth2,ENTFG,RICHTG,STATUS);
              str(Richtg:0:1,Bstr);
              Bstr:=SFillStr(6,B1,Bstr);
              _aus(Attrib[19],Kanal,m1+InfoZeile(406)+B1+qth1+' > '+qth2+bstr+b1+InfoZeile(407)+m1);
              QTH_ENTFG_RICHTG(qth2,qth1,ENTFG,RICHTG,STATUS);
              str(Richtg:0:1,bstr);
              bstr:=SFillStr(6,B1,bstr);
              _aus(Attrib[19],Kanal,InfoZeile(406)+B1+qth2+' > '+qth1+bstr+B1+InfoZeile(407)+m1);
              str(entfg:0:1,bstr);
              _aus(Attrib[19],Kanal,InfoZeile(408)+b1+bstr+' km'+m2);
             end;
         end; {59}
     60: begin
         for i:= 1 to maxlink do
          begin
           with K[i]^ do
           begin
            if TNCNummer<>i2 then
             begin
              i2:=TNCNummer;
              i3:=i-1;
             end;
            if Konfig.TNC[TNCNummer].INIA[1]<>'' then
              OwnCall:=Konfig.TNC[TNCNummer].INIA[1];
            Node:=false;
            if Konfig.TNC[TNCNummer].NodeKan > 0 then
            begin
             if i-i3 > (Konfig.TNC[TNCNummer].MaxKan)-
                       (Konfig.TNC[TNCNummer].NodeKan) then
             begin
               if Konfig.TNC[TNCNummer].INIA[2]<>'' then
                 OwnCall:=Konfig.TNC[TNCNummer].INIA[2];
               Node:=True;
             end;
            end;
           end;{with}
          Rufz_TNC_init(i);
          end; {for}
       end; {60}

     61: begin {PErsonal}
          flagq:=false;
          flagq:=CheckXP161 (kanal);
          if Konfig.persname<>'' then
           begin
            if flagq then
              s_pac(Kanal, NU, False, Meldung[32]+' '+Konfig.PersName+m1)
             else s_pac(Kanal, NU, False, '//N '+Konfig.PersName+m1);
           end;
          if Konfig.PersLoc <>'' then
           begin
             if flagq then s_pac(Kanal, NU, False, Meldung[31]+' '+Konfig.PersLoc+m1)
            else s_pac(Kanal, NU, False, '//LOC '+Konfig.PersLoc+m1);
           end;
          if Konfig.PersQTH <>'' then
           begin
             if flagq then s_pac(Kanal, NU, false, Meldung[33]+' '+Konfig.PersQTH+m1)
            else s_pac(Kanal, NU, false, '//QTH '+Konfig.PersQTH+m1);
           end;
          if (Konfig.persname<>'') or (Konfig.PersLoc <>'') or (Konfig.PersQTH <>'') then
           s_pac(kanal, nu, true, M1)
          else
           begin
            s_pac(kanal, nu, false, InfoZeile(415)+m1);
            Send_Prompt(Kanal,FF);
           end;
         end; {61 pers}

{$IFNDEF no_Netrom} {//db1ras}
      62:begin { * Nodes * }
          NodeListen(TNC[TNCNummer]^.AfuPort);
          Neu_bild;
         end; {62 Nodes}
{$ENDIF}

      63:begin {* SPEAK *}
          sprachmenu;
         end;
      64:begin {* BACKUP *}
          qth1:=parmStr(2, B1, InputZeile);
          if (qth1<>'') then
           begin
            if qth1='?' then InfoOut(Kanal,0,1,InfoZeile(457)+' '+int_str(Konfig.BackUpTime))
             else
              begin
               i:=str_int(qth1);
               if (i>1) and (i<201) then Konfig.BackUpTime:=i;
               if qth1='0' then Konfig.BackupTime:=0;
               InfoOut(Kanal,0,1,InfoZeile(457)+' '+int_str(Konfig.BackupTime));
              end;
           end else  Sicherung_Speichern;
         end;

      66:If Kanal > 0 then Begin {* IGNORE *}   {//db1ras}
           If pos('ON', UpCaseStr(InputZeile))>0 Then
             Ignore:=true
           Else If pos('OFF',UpCaseStr(InputZeile))>0 Then
             Ignore:=false
           Else
             Ignore := not Ignore;
           if Ignore then InfoOut(Kanal,0,1,InfoZeile(30))
                     else InfoOut(Kanal,0,1,InfoZeile(31));
           SetzeFlags(Kanal);
         End;

    end; (* Case Command of *)
  end;
End;


Procedure Key_Active (* Kanal : Byte; KC : Sondertaste; VC : Char *);
Var   i,i1  : Integer;
      w     : Word;
      D_ON,
      Flag  : Boolean;
      Hstr  : String[80];
      Ch    : Char;
      CallUDB:Str9;

Begin

  if not (kc in [_altx,_F1,_F2,_f3,_f4,_f5,_f6,_f7,_f8,_f9,_f10]) then
   begin
    NoActivity:=0;
    if (_OnAct) then
     begin
      _OnAct:=false;
      for i:=1 to MaxLink do
       begin
        if K[i]^.OnAct<>'' then
         begin
          if (not k[kanal]^.FileSend) or (k[kanal]^.RX_bin=0) or (not k[kanal]^.SPlSave)
             then S_pac(i, nu, true, K[i]^.OnAct+ ' '+M1+infozeile(395)+m2);
          K[i]^.OnAct:='';
         end;
       end;
     end;
   end;
  with K[Kanal]^ do
  begin
    if Vor_im_EMS then EMS_Seite_Einblenden(Kanal,Vor);

    if HardCur and NowCurBox then
    begin
      NowCurBox := false;
      JumpRxScr := true;
    end;

    ScreenTimer := ScreenInit;  (* Bildschirm-Schoner wieder hochsetzen *)

    if HardCur and not (KC in [_F1.._F10,_PgUp,_ShTab,_AltX]) then
    begin
      JumpRxZaehl := Win_Time;
      JumpRxScr := false;
    end;

    Case KC of

      _Andere
      : Case VC of
          'Ñ','î','Å','é','ô','ö','·'
              : if Umlaut <> 1 then Chr_Darstell(Kanal,KC,VC) else
                begin
                  case VC of
                   'Ñ' : Chr_Darstell(Kanal,KC,'a');
                   'î' : Chr_Darstell(Kanal,KC,'o');
                   'Å' : Chr_Darstell(Kanal,KC,'u');
                   'é' : Chr_Darstell(Kanal,KC,'A');
                   'ô' : Chr_Darstell(Kanal,KC,'O');
                   'ö' : Chr_Darstell(Kanal,KC,'U');
                   '·' : begin
                           Chr_Darstell(Kanal,KC,'s');
                           Chr_Darstell(Kanal,KC,'s');
                         end;
                  end;
                  if VC <> '·' then Chr_Darstell(Kanal,_Andere,'e');
                end;
          else  Chr_Darstell(Kanal,KC,VC);
        end;

      _F12,_AltM
      : SwitchMonitor;

      _F1.._F10   (* Bildschirmseiten umschalten *)
      : SwitchKanal(VC);

      _ShRight
      : Terminal_Kanal(Kanal,1);

      _ShLeft
      : Terminal_Kanal(Kanal,-1);

      _ShDn
      : Terminal_Kanal(Kanal,10);

      _ShUp
      : Terminal_Kanal(Kanal,-10);

      _PgDn
      : If Kanal > 0 then Screen_aus(2) else
        Begin
          if multiTNC then
          begin
            Repeat
              inc(Unproto);
              if Unproto > maxTNC then unproto := 1;
            Until TNC_used[Unproto];
            Unproto_darstellen;
            Status2;
            SetzeFlags(0);
          end else Alarm;
        End;

      _ShTab
      : begin
          ShTab_Pressed := not ShTab_Pressed;
           if not ShTab_Pressed then JumpRxScr := true;
        end;

      _ShIns
      : ClearVorBuffer(Kanal);

      _ShDel
      : ClearScrBuffer(Kanal);

      _ShHome,                   (* obere TrennZeile nach oben *)
      _ShEnd,                    (* obere TrennZeile nach unten *)
      _ShPgUp,                   (* untere TrennZeile nach oben *)
      _ShPgDn                    (* untere TrennZeile nach unten *)
      : Trennzeilen(Kanal,KC);

      _Fuenf
      : Neu_Bild;

      _Alt1
      : Begin
          If LastInfoCount < maxInfoOut then inc(LastInfoCount) else Alarm;
          LastInfoFlag := true;
          InfoOut(Kanal,0,1,LastInfoOut^.IZ[LastInfoCount]);
          LastInfoFlag := false;
        End;

      _Alt2
      : Begin
          If LastInfoCount > 1 then dec(LastInfoCount) else Alarm;
          If LastInfoCount < 1 then LastInfoCount := 1;
          LastInfoFlag := true;
          InfoOut(Kanal,0,1,LastInfoOut^.IZ[LastInfoCount]);
          LastInfoFlag := false;
        End;

      _ALT5
      : begin
         UserZeigen(Kanal, CallUDB);
         Neu_Bild;
         if mailAusUDB then
          begin
           StartMailPolling(Kanal,CallUDB);
          end;
        end;

     _ALT6
      : begin
         MailsZeigen(Kanal);
         Neu_Bild;
        end;
     _ALT7
      : begin
{$IFNDEF no_Netrom} {//db1ras}
         NodeListen(TNC[TNCNummer]^.AfuPort);
         Neu_bild;
{$ENDIF}
        end;

      _Alt9
      : if HardCur then NoCurJump := not NoCurJump else Alarm;

      _AltA
      : Begin
          i := Kanal;
          Repeat
            inc(i);
            if i > maxLink then i := 0;
          Until (i = Kanal) or K[i]^.connected or K[i]^.Mo.MonActive;
          if i <> Kanal then SwitchChannel(i);
        End;

      _AltB
      : Begin
          Klingel := not Klingel;
             Quiet:=not Klingel;
               hstr:=infozeile(46)+' ';
                if Quiet then infoOut(Kanal,0,1,hstr+iNFOZeile(76))
                 else
                  begin
                   infoOut(Kanal,0,1,hstr+iNFOZeile(77));
                   quiet_uhr:=false;
                  end;
          SetzeFlags(Kanal);
        End;

      _AltD
      : If C_Poll then Alt_Disc(Kanal)
                  else Alarm;

      _AltE
      : FileRxMenu(Kanal);

      _AltF
      : Begin
          Hstr := Konfig.SavVerz;
          DirZeig(Hstr,Ch,false);
          Neu_Bild;
        End;

      _AltG
      : If Test then SwitchChannel(TestMerk) else
         if ConvHilfsPort > 0 then SwitchChannel(ConvHilfsPort) else
          if Einstiegskanal or AusstiegsKanal then SwitchChannel(GegenKanal)
                                              else Alarm;

      _AltH
      : if Cmd then XP_Help(G^.OHelp[12])
               else XP_Help(G^.OHelp[11]);

      _AltI
      : If Kanal > 0 then
        Begin
          Ignore := not Ignore;
          if Ignore then InfoOut(Kanal,0,1,InfoZeile(30))
                    else InfoOut(Kanal,0,1,InfoZeile(31));
          SetzeFlags(Kanal);
        End;

      _AltL
      : If Kanal = 0 then
        Begin
          PacOut := not PacOut;
          SetzeFlags(Kanal);
        End else Alarm;

      _AltN
      : If Kanal > 0 then for i := 1 to length(User_Name) do
        Begin
          VC := User_Name[i];
          Chr_Darstell(Kanal,_Andere,VC);
        End;

      _AltP
      : Lpt_On_Off(Kanal);

      _AltR
      : Neu_Bild;

      _AltS
      : begin
          if connected then FileTxMenu(Kanal)
            else InfoOut(Kanal,0,1,InfoZeile(19));
        end;

      _AltU
      : Begin
          Umlautstatus_Aendern(Kanal);
          SetzeFlags(Kanal);
        End;

      _AltV
      : Verschiedene_Einstellungen(Kanal);

      _AltZ
      : Begin
          for i := 1 to maxLink do K[i]^.NochNichtGelesen := false;
          Neu_Bild;
        end;

      else if not Cmd then
      begin
        Case KC of

          _PgUp
          : begin
             Notiz_Zeigen(Kanal);
             with K[show]^ do
              begin
               if ((RX_Bin>0) or (SplSave)) and (LstRXInfo<>'') then InfoOut(show,0,1,LstRXInfo);
               if (FileSend) and (LstTXInfo<>'') then InfoOut(show,0,1,LstTXInfo);
              end;
            end;

          _AltF1.._AltF12,
          _CtrlF1.._CtrlF12
          : If not G^.MakroLearn then
            Begin
              MakroInit;
              Makro_Aktivieren(Key[KC].Ta + KeyExt);
            End else InfoOut(Kanal,1,1,InfoZeile(284));

          _ShF1.._ShF10
          : if (not FileSend) and (not SPlSave) and (RX_bin=0) then TXT_Senden(Kanal,5,Ord(VC)-83)
               else InfoOut(Kanal,0,1,InfoZeile(25));  (* Festspeicher ausgeben *)

          _Key2
          : if MPort > 0 then
            Begin
              S_PAC(MPort,CM,true,'I '+ K[MPort]^.OwnCall);
              MPort := 0;
            End;

          _Nix  :;

          _Alt0,
          _F11
          : If WishBoxLst and
               Exists(Konfig.TempVErz + DBoxDatei + SFillStr(3,'0',int_str(Kanal)))
              then
               begin
                 FileScroll(Kanal);
                 with K[show]^ do
                  begin
                   if ((RX_Bin>0) or (SplSave)) and (LstRXInfo<>'') then InfoOut(show,0,1,LstRXInfo);
                   if (FileSend) and (LstTXInfo<>'') then InfoOut(show,0,1,LstTXInfo);
                  end;
               end
              else Alarm;

          _Alt3
          : Makro_Open_Learnfile;

          _Alt4
          : If (Kanal > 0) then LinkLearn(Kanal,ACMerk)
                           else Alarm;

          _AltC

          : If (Kanal > 0) then ALT_C_Connect(Kanal)
                           else Alarm;
          _AltJ
          : if Einer_st then Chr_Vor_Show(Kanal,_Alt9,VC)
                        else Alarm;

          _AltK
          : if (not FileSend) and (not SPlSave) and (RX_bin=0) then CompressMenu(Kanal)
              else InfoOut(Kanal,0,1,InfoZeile(25));

          _AltO
          : Vorschreib_Such(Kanal);

          _AltQ
          : Begin
              WriteRam(1,1,Attrib[5],0,'Alt-Q' + B2);
              SetzeCursor(7,1);
              _ReadKey(KC,VC);
              AltQFlag := true;
              Chr_Darstell(Kanal,KC,VC);
              Cursor_Aus;
              Neu_Bild;
            End;

          _AltT
          : Begin
              if Kanal = 0 then
              Begin
                Time_Stamp := not Time_Stamp;
                SetzeFlags(0);
              End else
              begin
                Hstr := Datum + B1 + Uhrzeit;
                for i := 1 to length(Hstr) do
                begin
                  VC := Hstr[i];
                  Chr_Darstell(Kanal,_Andere,VC);
                end;
              end;
            End;

          _AltW
          : Vorschreib_Uebergabe;

          _AltX
          : Tschuess(Kanal);     (* Programm-Ende mit ALT-X *)

          else Chr_Vor_Show(Kanal,KC,VC);

        end;  (* Case of *)
      end else Chr_Cmd_Show(Kanal,KC,VC);
    end;
    set_Hardwarecursor(Kanal);
  end;
End;
