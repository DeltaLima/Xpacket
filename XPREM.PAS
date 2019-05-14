{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P R E M . P A S                                                      ³
 ³                                                                         ³
 ³ Routinen fr die Remotesteuerung  (//Befehle)                           ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}
{remote1: 1-27; remote2: 28-50; remote3: 51-..}

Procedure Remote1 (Kanal : Byte; Art : Integer; CZeile : Str80);
Var   i,i1,i2,
      ix      : Integer;
      dB,Tn,C,
      Anz     : Byte;
      Bstr,
      Dummy   : String;
      P       : String[4];
      Komm    : String[80];
      Path    : String[80];
      Rufz    : String[6];
      RufzStr : String[9];
      Hstr    : String[9];
      eigenc,
      CBFrei,
      Flag    : Boolean;
      Parm    : Array[1..3] of String[60];
      L_I     : Longint;


Begin
  with K[Kanal]^ do
  begin
   killstartblanks(CZeile);
   killendblanks(Czeile);
    Komm := UpCaseStr(CZeile);
    for i := 1 to 3 do Parm[i] := '';
    Dummy := ParmStr(1,B1,Komm);
    Anz := Byte(ParmAnz - 1);
    i1 := Anz;
    if Anz > 3 then i1 := 3;
    for i := 1 to i1 do Parm[i] := ParmStr(i,B1,RestStr(Komm));
    Rufz := Call;
    strip(Rufz);
    if (node) and (not RemAll) and ((art in NodeCmds)=false) and
       (art>0) and (art<100) then art:=111;
    case Art of
      1: if Anz = 0 then ParmWrong := true else     {* CONNECT *}
         Begin
           if not Test then
           begin
           CBFrei:=true;
           if not (TNC[tncnummer]^.AfuPort) and (Konfig.CBFilter)then
           begin
            hstr:=RestStr(komm);
            for i:=1 to Anz do
             begin
              if (length(Parm[i])=1) and ((Parm[i][1] in ['0','1','2','3','4','5','6','7','8','9'])) then
               CBFrei:=CBFrei
               else if not CBCallCheck(Parm[i]) then CBFrei:=FALSE;
             end;
           end;
            if CBFrei then
            begin
             FreiKanal := 0;
             FreiKanalSuch(Kanal,RestStr(Komm));
             Case FreiKanal of
               0  : S_PAC(Kanal,NU,false,M1 + Star + InfoZeile(123) + M1);
              253 : S_PAC(Kanal,NU,false,M1 + Star + InfoZeile(426) + M1);
              254 : S_PAC(Kanal,NU,false,M1 + Star + InfoZeile(282) + M1);
               FF : S_PAC(Kanal,NU,false,M1 + Star + InfoZeile(124) + M1);
              else if FreiKanal in [1..maxLink] then
                   begin
                   eigenc:=false;
                   for i:=1 to maxlink do
                     begin
                      rufz :=UpcaseStr(K[i]^.OwnCall);
                       Strip(rufz);
                      rufzstr:=UpcaseStr(Parm[1]);
                      if length(rufzstr)=1 then rufzstr:=upcasestr(parm[2]);
                       Strip(rufzstr);
                      if rufz=rufzstr then EigenC:=true;
                     end;
                     if not eigenc then
                     begin
                      GegenKanal := FreiKanal;
                      NeuCall := RestStr(Komm);
                      RemoteCall := Call;
                      EinstiegsKanal := true;
                      NochNichtGelesen := false;
                      Remote_Connect_Aufbauen(Kanal,NeuCall);
                      K[GegenKanal]^.GegenKanal := Kanal;
                      K[GegenKanal]^.AusstiegsKanal := true;
                      K[GegenKanal]^.NochNichtGelesen := false;
                      K[GegenKanal]^.Ziel_Call := Parm[1];
                      SetzeFlags(Kanal);
                     end else s_pac(kanal, NU, true, M1+'LOOP DETECTED!!'+M1);{eigenc}
                   end;
             end;
             if not (Freikanal in [1..maxLink]) then Send_Prompt(Kanal,FF);
            end else
             begin
              S_PAC(Kanal,NU,false,M1 + InfoZeile(441) + M1); {CBFRei}
              Send_Prompt(Kanal,FF);
             end;
           end else
           begin
             S_PAC(Kanal,NU,false,M1 + InfoZeile(181) + M1);
             Send_Prompt(Kanal,FF);
           end;
         End;

      2: Begin  (* Cstatus *)
           Bstr := EFillStr(61,B1,B1 + InfoZeile(125)) + ZeitArt;
           Bstr := M1 + Bstr + M1 + ConstStr('-',length(Bstr)) + M1;
           S_PAC(Kanal,NU,false,Bstr);
           for ix := 1 to maxLink do
           if (K[ix]^.connected) and
           ((TNC[K[ix]^.tncnummer]^.AfuPort)=(TNC[K[kanal]^.tncnummer]^.AfuPort))then
           begin
             Bstr := SFillStr(3,B1,int_str(ix)) + B1;
             if (ix = show) then Bstr[1] := RSK;
             Bstr := Bstr + EFillStr(11,B1,K[ix]^.OwnCall)
                          + EFillStr(4,B1,int_str(K[ix]^.TncNummer))
                          + EFillStr(10,B1,K[ix]^.Call)
                          + EFillStr(30,B1,K[ix]^.User_Name)
                          + K[ix]^.QSO_Begin + M1;
             S_PAC(Kanal,NU,false,Bstr);
           end;
           S_PAC(Kanal,NU,false,M1);
         end;

      3: Begin  (* Directory *);
           Bstr := '';
           if pos('/',Parm[1]) > 0 then
           begin
             Dummy := '';
             Bstr := Parm[1];
           end else Dummy := Parm[1];

           Dummy := MakePathName(Kanal,Flag,Dummy);
           if Flag then RemoteDir(Kanal,Dummy + B1 + Bstr + B1 + Parm[2] + B1 + Parm[3])
                   else S_PAC(Kanal,NU,false,InfoZeile(240) + B1 + Dummy + M1);
         End;

      4: Begin    (* Name *)
           if Anz > 0 then
           begin              {UCALL}
             Neu_Name(Kanal,1,Call,RestStr(CZeile));
             S_PAC(Kanal,NU,true,DZeile + M1);
             User_Name := RestStr(CZeile);
             UserInStatus(Kanal);
           end else ParmWrong := true;
         End;

      5: Begin   (* Info *)
           {if einstiegskanal then s_pac(kanal, nu, true, m1+'EINSTIEGSKANAL'+m1);
           if ausstiegskanal then s_pac(kanal, nu, true, m1+'ausSTIEGSKANAL'+m1);}

           TXT_Senden(Kanal,1,0);
         End;
      6: RemoteLnk(Kanal,T,Parm[1]);    (* Links *)

      7: Begin  (* Mheard *)
           RemoteMH(Kanal,T,Parm[1] + B1+ Parm[2] + B1+ Parm[3]);
         End;

      8: Begin  (* Show *)
           case Anz of
             0 : ParmWrong := true;
             1 : begin
                   WishBuf := true;
                   {S_PAC(Kanal,NU,false,M1 + InfoZeile(5) + M1 + ConstStr('-',29) + M1);}
                   {Bstr := GetName(Kanal,Parm[1],db,False);}
                   if not UserShow(Kanal,Parm[1]) then S_PAC(Kanal,NU,false,EFillStr(9,B1,Parm[1])+': '+ InfoZeile(137) + M1);
                 end;
           end;
         End;

      9: Begin    (* Convers *);
           Case Anz of
            0 : begin
                  ConversUser(Kanal);
                  S_PAC(Kanal,NU,false,InfoZeile(267) + M1);
                  Send_Prompt(Kanal,FF);
                end;
            1 : begin
                  i := Byte(str_int(Parm[1]));
                  if i in ConvMenge then
                  begin
                    Conv.Chan := i;
                    if ConversIni(Kanal,true) then
                     begin
                      S_PAC(Kanal,NU,true,Star + InfoZeile(246) + M1);
                      ConversUser(Kanal);
                      ConversTX(Kanal,true,true,Plus + InfoZeile(245) + M1);
                     end else
                      begin
                       Conv.Chan:=0;
                       Conv.AfuStatus:=0;
                       S_PAC(kanal, NU, TRUE, Conv.Fehler+m1);
                      end;
                  end else ParmWrong := true;
                end;
           end;
         End;

     10: Quit(Kanal);             (* Quit *)

     11,
     12,
     13:
         Begin    (* R + RBIN + RPRG *)
           case Anz of
            0 : ParmWrong := true;
        1,2,3 : begin
                  Path := MakePathName(Kanal,Flag,Parm[1]);
                  if Flag then
                  begin
                    Assign(TxFile,Path);
                    if ResetBin(TxFile,T) = 0 then
                    Begin
                      RemFlag := false;
                      TX_Bin := Art - 11;
                      TX_Laenge := FileSize(TxFile);
                      if (Anz in [2,3]) then FileSendVon(Kanal,RestStr(RestStr(Komm)));
                      TX_Count := 0;
                      TX_CRC := 0;
                      FileSend := true;
                      FileSendRem := true;
                      TX_Time := Uhrzeit;
                      SetzeFlags(Kanal);
                      if TX_Bin = 2 then S_PAC(Kanal,NU,true,MakeBinStr(Kanal,Path));
                    end else
                    begin
                      S_PAC(Kanal,NU,false,InfoZeile(144) + B1 + Path + M1);
                      Send_Prompt(Kanal,FF);
                    end;
                  end else
                  begin
                    S_PAC(Kanal,NU,false,InfoZeile(240) + B1 + Path + M1);
                    Send_Prompt(Kanal,FF);
                  end;
                end;
           end;
         End;

     14: If not Rx_Save then  (* WRITE *)
         Begin
           if Anz = 1 then
           begin
             if SaveNameCheck(0,Parm[1]) then
             begin
               Path := RemPath + Parm[1];
               if PfadOk(1,RemPath) then
               begin
                 if not Exists(Path) then
                 begin
                   FRxName := Path;
                   Assign(RXFile,FRxName);
                   if RewriteBin(RXFile,1) = 0 then
                   begin
                     RX_Count := 0;
                     RX_TextZn := 0;
                     RX_Laenge := 0;
                     RX_Bin := 1;
                     RX_Time := Uhrzeit;
                     Rx_Save := true;
                     RemoteSave := true;
                     S_PAC(Kanal,NU,true,Parm[1] + B1 + InfoZeile(145) + M1);
                   end else Send_Prompt(Kanal,FF);
                 end else
                 begin
                   S_PAC(Kanal,NU,false,Parm[1] + B1 + InfoZeile(149) + M1);
                   Send_Prompt(Kanal,FF);
                 end;
               end else
               begin
                 S_PAC(Kanal,NU,false,InfoZeile(75) + DP + B2 + Path + M2);
                 Send_Prompt(Kanal,FF);
               end;
             end else
             begin
               S_PAC(Kanal,NU,false,InfoZeile(147) + B1 + Parm[1] + M1 + InfoZeile(152) + M1);
               Send_Prompt(Kanal,FF);
             end;
           end else ParmWrong := true;
         End else
         Begin
           S_PAC(Kanal,NU,false,InfoZeile(43) + M1);
           Send_Prompt(Kanal,FF);
         End;

     15: If not Rx_Save then  (* WBIN *)
         Begin
           if Anz = 1 then
           begin
             if SaveNameCheck(0,Parm[1]) then
             begin
               Path := RemPath + Parm[1];
               if PfadOk(1,RemPath) then
               begin
                 if not Exists(Path) then
                 begin
                   FRxName := Path;
                   Assign(RXFile,FRxName);
                   if RewriteBin(RXFile,1) = 0 then
                   begin
                     RX_Save := true;
                     RX_Bin := 2;
                     RX_Count := 0;
                     RX_CRC := 0;
                     RX_Time := Uhrzeit;
                     RemoteSave := true;
                     Ignore := true;
                     SetzeFlags(Kanal);
                     Dummy := Parm[1] + B1 + InfoZeile(150) + B1 + InfoZeile(283) + M1;
                     S_PAC(Kanal,NU,true,Dummy);
                   end else Send_Prompt(Kanal,FF);
                 end else
                 begin
                   S_PAC(Kanal,NU,false,Parm[1] + B1 + InfoZeile(149) + M1);
                   Send_Prompt(Kanal,FF);
                 end;
               end else
               begin
                 S_PAC(Kanal,NU,false,InfoZeile(75) + DP + B2 + Path + M2);
                 Send_Prompt(Kanal,FF);
               end;
             end else
             begin
               S_PAC(Kanal,NU,false,InfoZeile(147) + B1 + Parm[1] + M1 + InfoZeile(152) + M1);
               Send_Prompt(Kanal,FF);
             end;
           end else ParmWrong := true;
         End else
         Begin
           S_PAC(Kanal,NU,false,InfoZeile(43) + M1);
           Send_Prompt(Kanal,FF);
         End;

     16, (* WPRG *)
     17: (* WAUTO *)
         If not Rx_Save then
         Begin
           if Anz = 1 then
           begin
             if SaveNameCheck(0,Parm[1]) then
             begin
               Path := RemPath + Parm[1];
               if PfadOk(1,RemPath) then
               begin
                 if not Exists(Path) then
                 begin  (* alles klar, File ist nicht da *)
                   AutoBinOn := true;
                   RX_Bin := 4;
                   FRxName := Path;
                   SetzeFlags(Kanal);
                   Dummy := Parm[1] + B1 + InfoZeile(150) + M1;
                   S_PAC(Kanal,NU,true,Dummy);
                 end else
                 begin
                   S_PAC(Kanal,NU,false,Parm[1] + B1 + InfoZeile(149) + M1);
                   Send_Prompt(Kanal,FF);
                 end;
               end else
               begin
                 S_PAC(Kanal,NU,false,InfoZeile(75) + DP + B2 + Path + M2);
                 Send_Prompt(Kanal,FF);
               end;
             end else
             begin
               S_PAC(Kanal,NU,false,InfoZeile(147) + B1 + Parm[1] + M1 + InfoZeile(152) + M1);
               Send_Prompt(Kanal,FF);
             end;
           end else ParmWrong := true;
         End else
         Begin
           S_PAC(Kanal,NU,false,InfoZeile(43) + M1);
           Send_Prompt(Kanal,FF);
         End;

     18: Begin    (* TNC *)
           i2 := Anz;
           case i2 of
             0 : TNC_Parm(Kanal,1);
           1,2 : begin
                   P := Parm[1];
                   Bstr := '';
                   TNC_Auswert(Kanal,P,Bstr);
                   if P > '' then
                   begin
                     Ausgabe := false;
                     if i2 = 2 then S_PAC(Kanal,CM,true,P + Parm[2]);
                     Ausgabe := false;
                     S_PAC(Kanal,CM,true,P);
                     S_PAC(Kanal,NU,false,LRK + P + RRK + B1 + Bstr + DP + B1 + Response + M1);
                   end else ParmWrong := true;
                 end;
           end;
         End;

     19: Begin    (* MYCALL *)
           Case Anz of
             0 : S_PAC(Kanal,NU,false,CutStr(InfoZeile(225)) + DP + B1 + OwnCall + M1);
             1 : begin
                   i := str_int(Parm[1]);
                   if i > 0 then
                   begin
                     if i in [1..maxLink]
                     then S_PAC(Kanal,NU,false,InfoZeile(225) + B1 + int_str(i) + DP + B1 + K[i]^.OwnCall + M1)
                     else ParmWrong := true;
                   end else
                   begin
                     OwnCall := Parm[1];
                     S_PAC(Kanal,NU,false,InfoZeile(276) + B1 + Parm[1] + M1);
                   end;
                 end;
             2 : begin
                   i := str_int(Parm[1]);
                   if i in [1..maxLink] then
                   begin
                     K[i]^.OwnCall := Parm[2];
                     Rufz_TNC_init(i);
                     S_PAC(Kanal,NU,false,'MYCALL - Port '+ int_str(i) + DP + B1 + K[i]^.OwnCall + M1);
                   end else ParmWrong := true;
                 end;
           end;
         End;

     20: Begin   (* Paclen  *)
           ix := Byte(str_int(RestStr(Komm)));
           if ix in [1..FF] then Paclen := ix;
           S_PAC(Kanal,NU,false,'PacLen = ' + int_str(PacLen) + M1);
         End;

     21: If Anz = 1 then   (* CDROM *)
         Begin
           if Rom_Exists and Rom_Ready then
           begin
             if (Parm[1] = ON) then
             begin
               if not use_RomLw then RemPath := RomDisk;
               use_RomLw := true;
               S_PAC(Kanal,NU,false,InfoZeile(321) + B1 + RemPath + M1);
             end;
             if (Parm[1] = OFF) then
             begin
               if use_RomLw then RemPath := G^.Drive;
               use_RomLw := false;
               S_PAC(Kanal,NU,false,InfoZeile(322) + B1 + RemPath + M1);
             end;
           end else S_PAC(Kanal,NU,false,InfoZeile(323) + M1);
         End else ParmWrong := true;

     22: Begin   (* CD *)
           Bstr := Parm[1];
           Ch_Dir(Kanal,Bstr);
           S_PAC(Kanal,NU,false,Bstr + M1);
         End;

     23: Begin   (* Umlaut *)
           if (Anz = 0) or
              ((Anz = 1) and (Byte(str_int('$'+Parm[1])) in UmlMenge)) then
           begin
             i := Byte(str_int('$'+Parm[1]));
             if (Anz = 1) and (i in UmlMenge) then Umlaut := i;
             SetzeFlags(Kanal);

             case Umlaut of
               0 : Bstr := InfoZeile(210);
               1 : Bstr := InfoZeile(211);
               2 : Bstr := InfoZeile(212);
               3 : Bstr := InfoZeile(213);
             end;

             Bstr := M1 + Bstr + M1;
             S_PAC(Kanal,NU,false,Bstr);
           end else ParmWrong := true;
         End;

     24: Begin  (* RC *)
           RC_update(Kanal, Komm);
           if Komm <> S_ch then S_PAC(Kanal,NU,false,Komm + M1)
                           else RC_Alle(Kanal,1);
         End;

     25: Begin    (* RAUTO *)
           if (Anz > 0) then
           begin
             RemFlag := false;

             Dummy := RestStr(Komm);
             GetMem(Dir,SizeOf(Dir^));

             While Dummy > '' do
             begin
               Path := MakePathName(Kanal,Flag,CutStr(Dummy));
               if Flag then
               begin
                 GetDirFiles(Path,AnyFile - Directory,1);
                 if DirFiles > 0 then
                 begin
                   Bstr := Path;
                   While (length(Bstr) > 0) and (Bstr[length(Bstr)] <> BS)
                      do delete(Bstr,length(Bstr),1);
                   for i := 1 to DirFiles do
                   begin
                     Path := Bstr + Dir^[i].Name;
                     While pos('..',Path) > 0 do delete(Path,pos('..',Path),1);
                     BIN_TX_File_Sofort(Kanal,Path);
                   end;
                 end else S_PAC(Kanal,NU,false,InfoZeile(144) + B1 + Path + M1);
               end else S_PAC(Kanal,NU,false,InfoZeile(240) + B1 + Path + M1);
               Dummy := RestStr(Dummy);
             end;

             FreeMem(Dir,SizeOf(Dir^));
           end else ParmWrong := true;
         End;

     26: Begin
           S_PAC(Kanal,NU,true,'');
           if TxComp then S_PAC(Kanal,NU,true,M1 + Meldung[22] + M1);
           if node then S_PAC(Kanal,NU,true,'73!'+#13);
           S_PAC(Kanal,CM,true,'D'); (* Disc ohne Verabschiedungstext *)
         End;

     27: if Anz > 0 then  (* DELETE File loeschen *)
         Begin
           Path := MakePathName(Kanal,Flag,Parm[1]);
           if Flag then
           begin
             if Exists(Path) then
             begin
               Dummy := Path;
               Delete_Datei(Dummy);
               S_PAC(Kanal,NU,false,M1 + Dummy + M1);
             end else S_PAC(Kanal,NU,false,M1 + InfoZeile(162) + DP + B1 + Parm[1] + M1);
           end else S_PAC(Kanal,NU,false,InfoZeile(240) + B1 + Path + M1);
         End else ParmWrong := true;



    254: notRC := true;

     FF: ParmWrong := true;

    else
      unknown := true;

    end;
    if (not ParmWrong) and (not notRC) and (not unknown) then Send_Prompt(Kanal,Art);
    if Node then begin
     for i:=1 to MaxAutoSys do
     begin
      if Pos(UpcaseStr(AutoSysKenner[i]), UpcaseStr(CZeile))>0 then unknown:=false;
     end;
     if (node) then
      begin
       if czeile='' then
        begin
         unknown:=false;
         ParmWrong:=false;
        end;
       if Art=111 then
        begin
         S_PAC(Kanal,NU,false,InfoZeile(21) + M1);
         Send_Prompt(Kanal,FF);
         unknown:=false;
         parmwrong:=false;
        end;
       if Mail_SP then unknown:=false;
       if not RX_Save then Mail_sp:=false;
      end;
    end;
  end;
End;


{**********remote2  28-50 ***********************}


Procedure Remote2 (Kanal : Byte; Art : Integer; CZeile : Str80);
Var   i,i1,i2,
      ix      : Integer;
      dB,Tn,C,
      Anz     : Byte;
      Bstr,
      Dummy   : String;
      P       : String[4];
      Komm    : String[80];
      Path    : String[80];
      Rufz    : String[6];
      srec    : SearchRec;
      flagq,
      Flag    : Boolean;
      Parm    : Array[1..3] of String[60];

Begin
  with K[Kanal]^ do
  begin
   killstartblanks(CZeile);
   killendblanks(Czeile);
    Komm := UpCaseStr(CZeile);
    for i := 1 to 3 do Parm[i] := '';
    Dummy := ParmStr(1,B1,Komm);
    Anz := Byte(ParmAnz - 1);
    i1 := Anz;
    if Anz > 3 then i1 := 3;
    for i := 1 to i1 do Parm[i] := ParmStr(i,B1,RestStr(Komm));
    Rufz := Call;
    strip(Rufz);
    if (node) and (not RemAll) and ((art in NodeCmds)=false) and
       (art>0) and (art<100) then art:=111;
    case Art of

     28,
     29,
     30: Begin
           case Art of
             28 : P := 'O';
             29 : P := 'N';
             30 : P := 'T';
           end;
           Bstr := '';
           TNC_Auswert(Kanal,P,Bstr);
           if P > '' then
           begin
             Ausgabe := false;
             if Anz > 0 then S_PAC(Kanal,CM,true,P + Parm[1]);
             Ausgabe := false;
             S_PAC(Kanal,CM,true,P);
             S_PAC(Kanal,NU,false,LRK + P + RRK + B1 + Bstr + DP + B1 + Response + M1);
           end else ParmWrong := true;
         End;

     31,32: begin
     flagq:=quiet;
     if ((VIP_) and (VIPG)) then quiet:=false;
     KLingel:=not quiet;
     if quiet then S_PAC(Kanal,NU,false,InfoZeile(60) + M1);
     if not quiet then
      begin
        if (Klingel) then    (* Ring * / * Bell *)
         begin
          if (BellCount=3) then S_Pac(Kanal, NU, False, InfoZeile(439) +m1)
          else
          begin
           inc(BellCount);
           Bimmel(kanal);
           quiet:=flagq;
           Klingel:=not quiet;
           {Triller;}
           S_PAC(Kanal,NU,false,InfoZeile(59) + M1);
          end;
         End else S_PAC(Kanal,NU,false,InfoZeile(60) + M1);
        end; {quiet}
         end;

     33: S_PAC(Kanal,NU,false,M1 + Pfeil + Version   (* VERSION *)
                             +M1 +
                             Pfeil + InfoZeile(109) + B2 +
                             lastEdit + M2);
     34, (* RMAIL *)
     35, (* KMAIL *)
     36, (* LMAIL *)
     37: (* SMAIL *)
         If TopBox then
         Begin
           Flag := false;
           Case Art of
           34: begin         (* RMAIL *)
                 if Anz >= 1 then Dummy := Parm[1] else Dummy := Rufz;
                 Strip(Dummy);
                 Dummy := Konfig.MailVerz + Dummy + MsgExt;
                 if Exists(Dummy) then SF_Text(Kanal,Dummy)
                                  else Flag := true;
               end;
           35: begin         (* KMAIL *)
                 if Anz >= 1 then Dummy := Parm[1] else Dummy := Rufz;
                 Strip(Dummy);
                 Dummy := Konfig.MailVerz + Dummy + MsgExt;
                 if Exists(Dummy) then
                 begin
                   KillFile(Dummy);
                   S_PAC(Kanal,NU,false,M1 + InfoZeile(134) +M2);
                   Eig_Mail_Zeile := '';
                   Check_Eig_Mail(1,maxLink);
                   SetzeFlags(show);
                 end else Flag := true;
               end;
           36: begin             (* LMAIL *)
                 Dummy := '';
                 if Anz < 1 then
                 begin
                   FindFirst(Konfig.Mailverz + S_ch + MsgExt,Archive,srec);
                   if DosError = 0 then
                   begin
                     Dummy := InfoZeile(265);
                     Dummy := M1 + Dummy + M1 + ConstStr('-',length(Dummy));
                     S_PAC(Kanal,NU,false,Dummy + M1);
                     Dummy := '';
                   end else Flag := true;
                   While DosError = 0 do
                   begin
                     if (length(Dummy) + 7) >= 79 then
                     begin
                       S_PAC(Kanal,NU,false,Dummy + M1);
                       Dummy := '';
                     end;
                     Dummy := Dummy + EFillStr(7,B1,copy(srec.Name,1,pos(Pkt,srec.Name)-1));
                     FindNext(srec);
                   end;
                   if Dummy <> '' then S_PAC(Kanal,NU,false,Dummy + M1);
                 end else
                 begin
                   Dummy := Parm[1];
                   Strip(Dummy);
                   Dummy := Konfig.Mailverz + Dummy + MsgExt;
                   if Exists(Dummy) then S_PAC(Kanal,NU,false,M1 + InfoZeile(266) +
                                                             B1 + Parm[1] + M1)
                                    else Flag := true;
                 end;
               end;
           37: if not RX_Save then
               begin
                 if Anz = 1 then
                 begin
                   if SaveNameCheck(0,Parm[1]) then
                   begin
                     i := pos(Pkt,Parm[1]);
                     if i > 0 then Parm[1] := copy(Parm[1],1,i-1);
                     strip(Parm[1]);
                     Path := Konfig.Mailverz + Parm[1] + MsgExt;
                     for i := 1 to maxLink do
                     begin
                       Dummy := K[i]^.OwnCall;
                       Strip(Dummy);
                       if Parm[1] = Dummy then MsgToMe := true;
                     end;
                     FRxName := Path;
                     if OpenTextFile(Kanal) then
                     begin
                       RX_Count := 0;
                       RX_TextZn := 0;
                       RX_Laenge := 0;
                       RX_Bin := 1;
                       RX_Time := Uhrzeit;
                       RX_Save := true;
                       if node then Mail_sp:=true;
                       RemoteSave := true;
                       Dummy := M1 + InfoZeile(105) + B1+ EFillStr(10,B1,Call) +
                                Datum + B2 + copy(Uhrzeit,1,5) + B1 + ZeitArt + M1;
                       Dummy := Dummy + ConstStr('-',length(Dummy)) + M1;
                       Write_RxFile(Kanal,Dummy);
                       S_PAC(Kanal,NU,true,Parm[1] + B1 + InfoZeile(145) + M1);
                     end else Send_Prompt(Kanal,FF);
                     SetzeFlags(Kanal);
                   end else
                   begin
                     S_PAC(Kanal,NU,false,InfoZeile(147) + B1 + Parm[1] + M1 + InfoZeile(148) + M1);
                     Send_Prompt(Kanal,FF);
                   end;
                 end else ParmWrong := true;
               end else
               begin
                 S_PAC(Kanal,NU,false,InfoZeile(43) + M1);
                 Send_Prompt(Kanal,FF);
               end;
           end;
           if Flag then S_PAC(Kanal,NU,false,M1 + InfoZeile(133) + M2);
         End else S_PAC(Kanal,NU,false,InfoZeile(252) + M2);

     38: If Anz = 2 then  (* Rename *)
         Begin
           i := 0;
           File_Umbenennen(RemPath + Parm[1],RemPath + Parm[2],i,i2);
           if i2 = 3 then Dummy := Parm[1] + B1 + 'in' + B1 + Parm[2] else Dummy := Parm[i2];
           S_PAC(Kanal,NU,false,M1 + InfoZeile(i) + B1 + Dummy +M2);
         End else ParmWrong := true;

     39: S_PAC(Kanal,NU,false,M1 + InfoZeile(279) + B1 + Datum + B2 +  (* DATE *)
                              Uhrzeit + B1 + ZeitArt + M2);

     40: if Anz >= 2 then         (* Copy *)
         Begin
           Dummy := Parm[1] + B1 + Parm[2] + B1 + RemPath;
           FileKopieren(Dummy);
           S_PAC(Kanal,NU,false,M1 + Dummy + M2);
         End else ParmWrong := true;

     41: If Anz > 0 then  (* CRC *)
         Begin
           Path := MakePathName(Kanal,Flag,Parm[1]);
           if Flag then
           begin
             if Exists(Path) then
             begin
               Dummy := Path + B1 + RestStr(RestStr(Komm));
               KillEndBlanks(Dummy);
               CRC_Datei(Dummy);
               S_PAC(Kanal,NU,true,M1 + Dummy + M2);
             end else S_PAC(Kanal,NU,true,M1 + InfoZeile(162) + DP + B1 + Parm[1] + M2);
           end else S_PAC(Kanal,NU,true,InfoZeile(240) + B1 + Path + M1);
         End else ParmWrong := true;

     42: Begin  (* Priv-Befehl empfangen und vorbereiten *)
           Randomize;
           Dummy := '';
           Priv_Errechnet := '';
           i := 0;
           While i < 5 do
           begin
             i1 := random(61);
             if (i1 in [1..60]) and (pos(int_str(i1) + B1,Dummy) = 0) then
             begin
               Dummy := Dummy + int_str(i1) + B1;
               Priv_Errechnet := Priv_Errechnet + Priv_PassWord[i1];
               inc(i);
             end;
           end;
           KillEndBlanks(Dummy);
           S_PAC(Kanal,NU,true,OwnCall + '> ' + Dummy + M1);
           Priv_Modus := true;
         End;

     43: If Anz = 1 then        (* MD *)
         Begin
           Mk_Dir(Kanal,Komm);
           S_PAC(Kanal,NU,false,Komm + M2);
         End else ParmWrong := true;

     44: If Anz = 1 then        (* RD *)
         Begin
           Rm_Dir(Kanal,Komm);
           S_PAC(Kanal,NU,false,Komm + M2);
         End else ParmWrong := true;

     45: Begin     (* DRIVE *)
           Komm := RestStr(Komm);
           if Anz = 0 then S_PAC(Kanal,NU,false,InfoZeile(201) + B1 +
              copy(RemPath,1,2) + M1) else
           if length(Komm) = 2 then
           begin
             if PfadOk(0,Komm) then
             begin
               if pos(DP,Komm) = 0 then Komm := Komm + DP;
               RemPath := Komm + BS;
               S_PAC(Kanal,NU,false,InfoZeile(202) + B1 + Komm + M1);
             end else S_PAC(Kanal,NU,false,InfoZeile(203) + B1 + Komm + M1);
           end else ParmWrong := true;
         End;

     46: If Anz > 0 then        (* DOS *)
         Begin
           Komm := RestStr(Komm);
           Dummy := Komm + B1 + RSK + B1 + Konfig.TempVerz + DosBild;
           S_PAC(Kanal,NU,true,InfoZeile(53) + M2);
           GetDir(0,Bstr);
           ChDir(copy(RemPath,1,length(RemPath)-1));
           DosAufruf(Dummy,2);
           ChDir(BS);
           ChDir(Bstr);
           if Dummy = OK then
           begin
             if Exists(Konfig.TempVerz + DosBild) then
             begin
               SF_Text(Kanal,Konfig.TempVerz + DosBild);
               KillFile(Konfig.TempVerz + DosBild);
             end;
           end else S_PAC(Kanal,NU,false,InfoZeile(166) + B1 + Komm + M2);
         End else ParmWrong := true;

     47: Begin  (* Help *)
           case Anz of
             0 : begin
                   WishBuf := true;
                   REM_HelpLong(Kanal,G^.OHelp[16]);
                 end;
             1 : begin
                   if RemAll then i1 := 2
                             else i1 := 1;
                   ix := REM_Auswert(Kanal,i1,Parm[1]);
                   case ix of
                    1..98
                    : begin
                       if (not node) or ((node) and (ix in nodecmds)) or ((node) and (Remall)) then
                        begin
                         WishBuf := true;
                         S_PAC(Kanal,NU,false,M2);
                         REM_Help(Kanal,ix);
                        end
                        else S_PAC(Kanal,NU,false,InfoZeile(207) + parm[1] +M2);
                      end;
                    99
                    : S_PAC(Kanal,NU,false,M1 + InfoZeile(214) + Parm[1] + M2);
                    254
                    : S_PAC(Kanal,NU,false,M1 + InfoZeile(207) + Parm[1] + M2);
                 else begin
                        if Exists(Konfig.RunVerz + Parm[1] + DocExt)
                        then SF_Text(Kanal,Konfig.RunVerz + Parm[1] + DocExt)
                        else S_PAC(Kanal,NU,false,M1 + InfoZeile(206) + Parm[1] +M2);
                      end;
                   end;
                 end;
           end;
         End;

       48: begin         { PORTS }
          S_PAC(Kanal,NU, false, m1+infoZeile(20)+M2);
          for i:=1 to 8 do
           if TNC_used[i] then S_Pac(Kanal, NU, false, ' '+int_Str(i)+': '+Konfig.TNC[i].PortNam+M1);
          {Send_Prompt(Kanal,FF);}
         end;


     49: If Anz = 0 then ParmWrong := true    (* ECHO *)
                    else S_PAC(Kanal,NU,true,RestStr(CZeile) + M1);

     50,62: If Kanal > 0 then      (* LAUFZEIT / RTT *)
         Begin
           RTF := true;
           S_PAC(Kanal,NU,true,M1 + InfoZeile(222) + B1 + Meldung[25] + Uhrzeit + M1);
         End;


    254: notRC := true;

     FF: ParmWrong := true;

    else
      unknown := true;

    end;
    if (not ParmWrong) and (not notRC) and (not unknown) then Send_Prompt(Kanal,Art);
    if Node then begin
     for i:=1 to MaxAutoSys do
     begin
      if Pos(UpcaseStr(AutoSysKenner[i]), UpcaseStr(CZeile))>0 then unknown:=false;
     end;
     if (node) then
      begin
       if czeile='' then
        begin
         unknown:=false;
         ParmWrong:=false;
        end;
       if Art=111 then
        begin
         S_PAC(Kanal,NU,false,InfoZeile(21) + M1);
         Send_Prompt(Kanal,FF);
         unknown:=false;
         parmwrong:=false;
        end;
       if Mail_SP then unknown:=false;
       if not RX_Save then Mail_sp:=false;
      end;
    end;
  end;
End;





{*********** Remotes3 *************}

Procedure Remote3 (Kanal : Byte; Art : Integer; CZeile : Str80);
Var   i,i1,i2,
      ix      : Integer;
      dB,Tn,C,
      Anz     : Byte;
      Bstr,
      Dummy   : String;
      P       : String[4];
      Komm    : String[80];
      Path    : String[80];
      Rufz    : String[6];
      Hstr    : String[9];
      flagq,
      Flag    : Boolean;
      Parm    : Array[1..3] of String[60];
      Udb     : User_typ2;
      L_I     : Longint;
      ENTFG,
      RICHTG : REAL;
      STATUS : Boolean;
      OESLAE,NOEBRE:real;

Begin
  with K[Kanal]^ do
  begin
   killstartblanks(CZeile);
   killendblanks(Czeile);
    Komm := UpCaseStr(CZeile);
    for i := 1 to 3 do Parm[i] := '';
    Dummy := ParmStr(1,B1,Komm);
    Anz := Byte(ParmAnz - 1);
    i1 := Anz;
    if Anz > 3 then i1 := 3;
    for i := 1 to i1 do Parm[i] := ParmStr(i,B1,RestStr(Komm));
    Rufz := Call;
    strip(Rufz);
    if (node) and (not RemAll) and ((art in NodeCmds)=false) and
       (art>0) and (art<100) then art:=111;
    case Art of

     51: TXT_Senden(Kanal,2,0);         (* Aktuell *)

     52: If Anz = 0 then
         Begin
           WishBuf := true;
           S_PAC(Kanal,NU,false,M1);
           Send_Hilfe(Kanal,G^.OHelp[30]);
           S_PAC(Kanal,NU,true,'');
         End else ParmWrong := true;

     53: begin {* LOCator}
          if Anz > 0 then
           begin
             FillChar(udb,SizeOf(udb),0);
             Udb.Locator:=RestStr(upcaseStr(CZeile));
             User_loc:=udb.locator;
                       {UCALL}
             udb.Call:=call;
             userinstatus(kanal);
             PutUser(Udb,c,2,L_I,false);
             case c of
              0: s_pac(Kanal, NU, true, ParmStr(5,B1,infozeile(195))+': '+udb.LOCator+' -> '+InfoZeile(10)+m1);
              1: s_pac(Kanal, NU, true, ParmStr(5,B1,infozeile(195))+': '+udb.LOCator+' -> '+InfoZeile(11)+m1);
              10:s_pac(Kanal, NU, true, InfoZeile(370)+m2);
             end;
           end else ParmWrong := true;

         end;

     54: begin {* QTH}
          if Anz > 0 then
           begin
             FillChar(udb,SizeOf(udb),0);
             Udb.QTH:=RestStr(CZeile);
             User_QTH:=udb.qth;
                       {UCALL}
             udb.Call:=call;
             UserInStatus(kanal);
             PutUser(Udb,c,3,L_I,false);
             case c of
              0: s_pac(Kanal, NU, true, ParmStr(4,B1,infozeile(195))+': '+udb.QTH+' -> '+InfoZeile(10)+m1);
              1: s_pac(Kanal, NU, true, ParmStr(4,B1,infozeile(195))+': '+udb.QTH+' -> '+InfoZeile(11)+m1);
              10:s_pac(Kanal, NU, true, InfoZeile(370)+m2);
             end;
           end else ParmWrong := true;
         end;

     55: begin {* PErsonal}
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
         end;

     56: begin {* ACTion *}
          S_pac(kanal, nu, false, M1+int_str(NoActivity)+ ' '+infozeile(393)+m1);
         end;
     57: begin {* ONACTiv *}
           OnAct:=Parm[1];
           if OnAct<>'' then
            begin
             S_pac(kanal, nu, false, M1+'* '+OnAct+ ' '+infozeile(394)+m1);
             _OnAct:=true;
            end
           else
            begin
             S_pac(kanal, nu, false, M1+infozeile(396)+m1);
             _ONAct:=false;
             for i:=1 to maxlink do
              if k[i]^.Onact<>'' then _Onact:=true;
            end;
         end;

     58: Begin  {* CALCLOC *}
          if Anz<>0 then
           begin
            flag:=false;
            parmwrong:=false;

            if (anz=1) then
             begin
              if (pos('/',Parm[1])>0) or (Konfig.persLoc<>'') then flag:=true else ParmWrong:=true;
              if flag then Parm[2]:=Konfig.persLoc;
             end;


            if not ParmWrong then
             begin
              QTH_Pruefen(Parm[1],Oeslae,NoeBre,status);
              Parm[1]:= WINKEL_IN_NEU(OESLAE,NOEBRE);
             end;

            if Flag then
             begin
              S_pac(kanal, nu, false,m1+InfoZeile(411)+B1+Parm[1]+m1);
             end;

            if (Parm[1]<>'') then
             begin
              QTH_Pruefen(Parm[2],Oeslae,NoeBre,status);
              Parm[2]:= WINKEL_IN_NEU(OESLAE,NOEBRE);
              QTH_ENTFG_RICHTG(Parm[1],Parm[2],ENTFG,RICHTG,STATUS);
              str(Richtg:0:1,hstr);
              hstr:=SFillStr(6,B1,hstr);
              S_pac(kanal, nu, false,m1+InfoZeile(406)+B1+Parm[1]+' > '+Parm[2]+hstr+b1+InfoZeile(407)+m1);
              QTH_ENTFG_RICHTG(parm[2],Parm[1],ENTFG,RICHTG,STATUS);
              str(Richtg:0:1,hstr);
              hstr:=SFillStr(6,B1,hstr);
              S_pac(kanal, nu, false,InfoZeile(406)+B1+Parm[2]+' > '+Parm[1]+hstr+B1+InfoZeile(407)+m1);
              str(entfg:0:1,hstr);
              S_pac(kanal, nu, false,InfoZeile(408)+b1+hstr+' km'+m1);
             end;
           end else ParmWrong:=true;
         end;

{$IFNDEF no_Netrom} {//db1ras}
     59: REMNodesListen (Kanal, CZeile); (* NODES *)

     60: REMRoutesListen(Kanal, CZeile); (* ROUTES *)
{$ENDIF}

     61:
         Begin    (* RXBIN *)
            if anz>0 then
             begin
                  Path := MakePathName(Kanal,Flag,Parm[1]);
                  if Flag then
                  begin
                    Assign(TxFile,Path);
                    if ResetBin(TxFile,T) = 0 then
                    Begin
                      RemFlag := false;
                      TX_Bin := 2;
                      TX_Laenge := FileSize(TxFile);
                      TX_Count := 0;
                      TX_CRC := 0;
                      FileSend := true;
                      FileSendRem := true;
                      TX_Time := Uhrzeit;
                      xbin.an:=true;
                      SetzeFlags(Kanal);
                      if TX_Bin = 2 then S_PAC(Kanal,NU,true,MakeBinStr(Kanal,Path));
                    end else
                    begin
                      S_PAC(Kanal,NU,false,InfoZeile(144) + B1 + Path + M1);
                      Send_Prompt(Kanal,FF);
                    end;
                  end else
                  begin
                    S_PAC(Kanal,NU,false,InfoZeile(240) + B1 + Path + M1);
                    Send_Prompt(Kanal,FF);
                  end;
           end else parmwrong:=true;
         End;



     99: Begin      (* Runfile suchen und wenn vorhanden dann starten *)
           if SaveNameCheck(0,CutStr(Komm)) then
           begin
             Dummy := Konfig.RunVerz + Komm;

             Flag := false;
             i := 0;
             Repeat
               inc(i);
               Flag := Exists(CutStr(Dummy) + DExt[i]);
             Until Flag or (i >= 3);

             if Flag then
             begin
               Dummy := CutStr(Dummy) + DExt[i] + B1 + RestStr(Dummy);
               KillEndBlanks(Dummy);
               GetDir(0,Bstr);
               ChDir(copy(Konfig.RunVerz,1,length(Konfig.RunVerz)-1));
               Dummy := Dummy + B1 + RSK + B1 + Konfig.TempVErz + DosBild;
               DosAufruf(Dummy,0);
               ChDir(BS);
               ChDir(Bstr);
               if Dummy = OK then
               begin
                 if Exists(Konfig.TempVerz + DosBild) then
                 begin
                   SF_Text(Kanal,Konfig.TempVerz + DosBild);
                   KillFile(Konfig.TempVerz + DosBild);
                 end;
               end else S_PAC(Kanal,NU,false,InfoZeile(166) + B1 + Komm + M2);
               Send_Prompt(Kanal,FF);
             end else unknown := true;
           end else unknown := true;
         End;

    254: notRC := true;

     FF: ParmWrong := true;

    else
      unknown := true;

    end;
    if (not ParmWrong) and (not notRC) and (not unknown) then Send_Prompt(Kanal,Art);
    if Node then begin
     for i:=1 to MaxAutoSys do
     begin
      if Pos(UpcaseStr(AutoSysKenner[i]), UpcaseStr(CZeile))>0 then unknown:=false;
     end;
     if (node) then
      begin
       if czeile='' then
        begin
         unknown:=false;
         ParmWrong:=false;
        end;
       if Art=111 then
        begin
         S_PAC(Kanal,NU,false,InfoZeile(21) + M1);
         Send_Prompt(Kanal,FF);
         unknown:=false;
         parmwrong:=false;
        end;
       if Mail_SP then unknown:=false;
       if not RX_Save then Mail_sp:=false;
      end;
    end;
  end;
End;






Procedure Remote (* Kanal : Byte; Art : Integer; CZeile : Str80 *);
begin
 if art<28 then Remote1 (Kanal, Art, CZeile);

 if (art=62) or ((art>27) and (art<51)) then Remote2 (Kanal, Art, CZeile);

 if (art>50) and (art<>62) then Remote3 (Kanal, Art, CZeile);
end;



Procedure Send_Prompt (* Kanal,Art : Byte *);
var    Flag : Boolean;
       i    : Byte;
Begin
  with K[Kanal]^ do
  begin
   if not FWD then
   begin
    Flag := false;
    i := 1;
    While not Flag and (i <= maxPrompt) do
    begin
      if Art = Prompts[i] then Flag := true;
      inc(i);
    end;
    if Flag then S_PAC(Kanal,NU,true,M1 + Platzhalter(Kanal,G^.PromptStr) + M1);
   end; {FWD}
  end;
End;


Procedure Ch_Dir (* Kanal : Byte; Var Zeile : str80 *);
Var       Hstr : String[80];
Begin
  with K[Kanal]^ do
  begin
    if Zeile > '' then
    begin{(pos(DP,Zeile) = 0) and                         }
      if (Zeile <> Pkt) then
      begin
        Hstr := RemPath;

        if Pos('..', Zeile) > 0 then
        begin
          if length(Hstr) > 3 then
          begin
            delete(Hstr,length(Hstr),1);
            While Hstr[length(Hstr)] <> BS do delete(Hstr,length(Hstr),1);
          end;
        end else

        if Zeile = BS then
        begin
          Hstr := copy(RemPath,1,3)
        end else

        if pos(BS,Zeile) = 1 then
        begin
          Hstr := copy(RemPath,1,2) + Zeile + BS;
        end else Hstr := Hstr + Zeile + BS;
        if (pos(DP,Zeile) > 0) then
         begin
          HSTR:=Zeile;
          if Hstr[length(hstr)]<>BS then Hstr:=Hstr+BS;
         end;
        if pos(Konfig.RemVerz,hstr)>0 then {else InfoZeile 240}
        begin
         if PfadOk(0,Hstr) then
         begin
          if (pos(G^.Drive,Hstr) > 0) or RemAll or use_RomLw then
          begin
            RemPath := Hstr;
            Zeile := InfoZeile(184) + B1 + RemPath;
          end else Zeile := InfoZeile(320) + B1 + Hstr;
         end else Zeile := InfoZeile(185) + B1 + Hstr;
        end else Zeile := InfoZeile(240) + B1 + Hstr;
   {*}end else Zeile := InfoZeile(194) + B1 + Zeile;
    end else Zeile := InfoZeile(186) + B1 + RemPath;
  end;
End;


Function  REM_Auswert (* Kanal, Art : Byte; Komm : Str80) : Byte; *);
Const     FNot = 254;
Var       Anz,
          BNr    : Byte;
          Nr,i,
          RC,min : Word;
          Rufz   : String[6];
          Cstr,
          Hstr   : String[12];
          Bstr   : String[19];
          Found,
          Pwrong,
          Para   : Boolean;
Begin
  Para := false;
  Pwrong := false;

  Komm := UpCaseStr(Komm);
  Hstr := ParmStr(1,B1,Komm);
  Anz := Byte(ParmAnz - 1);

  BNr := 0;
  Repeat
    inc(BNr);
    Cstr := G^.Remotes[BNr].Befehl;
    min := G^.Remotes[BNr].AnzCh;
    Found := (copy(Cstr,1,length(Hstr))=Hstr) and (length(Hstr) >= min);
  Until Found or (BNr >= maxREM);

  if (not K[Kanal]^.Mo.MonActive) and (K[Kanal]^.MldOk in [31..33]) then found:=true;
  Case K[Kanal]^.MldOK of
   31: BNr:=53;
   32: BNr:=4;
   33: BNr:=54;
  end;

  if Found and (Anz > 0) and (Art = 1) then
  begin
    i := G^.Remotes[BNr].AnzPa;
    if (Anz = i) then Para := true;
    if (((i = 0) or (Anz > i)) and (i <> 9)) and (BNr<>54) then
    begin
      Found := false;
      Pwrong := true;
    end;
  end;

  if Found then
  begin
    Nr := G^.Remotes[BNr].BefNr;
    if Art = 1 then
    begin
      if K[kanal]^.node then RC := G^.Remotes[BNr].LevelN
                        else RC := G^.Remotes[BNr].Level;
      if K[Kanal]^.RemoteAus[nr] then RC:=0;
      case RC of
        0 : REM_Auswert := Nr;
        1 : if Para and Call_Exist(Kanal,1,'')
              then REM_Auswert := Nr
              else if Para then REM_Auswert := FNot
                           else REM_Auswert := Nr;
        2 : if Call_Exist(Kanal,1,'') then REM_Auswert := Nr
                                      else REM_Auswert := FNot;
        3 : if Para then REM_Auswert := FNot
                    else REM_Auswert := Nr;
        4 : if Para then REM_Auswert := FNot
                    else if Call_Exist(Kanal,1,'') then REM_Auswert := Nr
                                                   else REM_Auswert := FNot;
        5 : REM_Auswert := FNot;
        else REM_Auswert := FNot;
      end;
    end else REM_Auswert := Nr;
  end else if Pwrong then REM_Auswert := FF
                     else REM_Auswert := 0;
  if Call_Exist(Kanal,2,'') then REM_Auswert := FNot;
End;

Procedure TNC_Auswert (* Kanal: Byte; Var TncKom, Doc : Str20 *);
var       i     : Byte;
          Found : Boolean;
          Bstr  : String[8];
          Hstr  : String[80];
          TncNr : Byte;
Begin
  TncNr := K[Kanal]^.TncNummer;
  Assign(G^.TFile,SysPfad + TncDatei);
  FiResult := ResetTxt(G^.TFile);
  Repeat
    Readln(G^.TFile,Hstr);
    KillStartBlanks(Hstr);

    i := pos(GL,Hstr);
    if i > 0 then
    begin
      Bstr := copy(Hstr,1,i-1);
      KillEndBlanks(Bstr);
      delete(Hstr,1,i);
      KillStartBlanks(Hstr);
      Found := ((pos('A',Bstr) > 0) or (pos(int_str(TncNr),Bstr) > 0)) and
                (CutStr(Hstr) = TncKom);
      if Found then
      begin
        TncKom := CutStr(Hstr);
        Doc := RestStr(Hstr);
      end;
    end;
  Until Found or Eof(G^.TFile);
  FiResult := CloseTxt(G^.TFile);
  if not Found then
  begin
    TncKom := '';
    Doc := '';
  end;
End;

Procedure Mk_Dir (* Kanal : Integer; var Zeile : str80 *);
Begin
  with K[Kanal]^ do
  begin
    Zeile := RestStr(Zeile);
    (*$I-*) MkDir(RemPath + Zeile); (*$I+*)
    if IOResult = 0 then
    begin
      Zeile := InfoZeile(197) + B1 + RemPath + Zeile + BS;
    end else Zeile := InfoZeile(198) + B1 + RemPath + Zeile + BS;
  end;
End;

Procedure Rm_Dir (* Kanal : Integer; var Zeile : str80 *);
Begin
  with K[Kanal]^ do
  begin
    Zeile := RestStr(Zeile);
    (*$I-*) RmDir(RemPath + Zeile); (*$I+*)
    if IOResult = 0 then
    begin
      Zeile := InfoZeile(199) + B1 + RemPath + Zeile + BS;
    end else Zeile := InfoZeile(200) + B1 + RemPath + Zeile + BS;
  end;
End;


Function  Call_Exist (* Kanal,Art : Byte; Zeile : Str9) : Boolean *);
var       i,m  : Byte;
          Cstr,
          Hstr,
          Rufz : String[6];
          Bstr : String[20];
          Privat,
          Flag,
          Flag1 : Boolean;
Begin
  Flag := false;
  Flag1 := false;
  Rufz := K[Kanal]^.Call;
  Strip(Rufz);
  Strip(Zeile);

  if Rufz > '' then
  begin
    Assign(G^.TFile,Sys1Pfad + CallDatei);
    FiResult := ResetTxt(G^.TFile);
   if FiResult=0 then
   begin
    Repeat
      Readln(G^.TFile,Bstr);
      Bstr := upcasestr(CutStr(Bstr));
      case Art of
        1 : Flag := Bstr = RFR;
        2 : Flag := Bstr = RNOT;
        3 : Flag := Bstr = CNOT;
        4 : Flag := Bstr = GNOT;
        5 : Flag := Bstr = CCAN;
      end;
    Until Eof(G^.TFile) or Flag;

    Privat:=false;

    if Flag then
    begin
      Repeat
        Flag := false;
        Readln(G^.TFile,Bstr);
        Bstr := UpcaseStr(Bstr);
        Hstr := CutStr(Bstr);
        Strip(Hstr);
        if ((Art = 5) and (length(BSTR)>0)) then
         begin
          Hstr := RestStr(Bstr);
          m := Byte(str_int(Hstr));
          if (M=K[kanal]^.TNCNummer) then
           begin
            Privat:=true;
            hstr:=CutStr(BSTR);
            strip(Hstr);
            if (Hstr = Rufz) then Flag:=true;
           end;
         end
         else
        if (Art = 3) and (Hstr = Rufz) then
        begin
          Hstr := RestStr(Bstr);
          m := Byte(str_int(Hstr));
          if m = 0 then Flag := true else
          begin
            i := 0;
            Repeat
              inc(i);
              with K[i]^ do if connected and not Test and (i <> Kanal) then
              begin
                Cstr := Call;
                Strip(Cstr);
                if Cstr = Rufz then
                begin
                  dec(m);
                  Flag := m = 0;
                end;
              end;
            Until Flag or (i >= maxLink);
          end;
        end else

        if Art = 4 then
        begin
          if pos(S_ch,Hstr) > 1 then
          begin
            Hstr := copy(Hstr,1,pos(S_ch,Hstr)-1);
            Flag := pos(Hstr,Rufz) = 1;
            Flag1 := pos(Hstr,Zeile) = 1;
          end else
          begin
            Flag := Hstr = Rufz;
            Flag1 := Hstr = Zeile;
          end;

          if Flag then
          begin
            m := Byte(str_int(RestStr(Bstr)));
            if FreiKanal<=maxlink then
             i := K[FreiKanal]^.TncNummer
            else i:=254;
            Flag := (i = m) or (m = 0);
          end;

          if Flag1 then
          begin
            m := Byte(str_int(RestStr(Bstr)));
            i := K[Kanal]^.TncNummer;
            Flag := (i = m) or (m = 0);
          end;

        end else Flag := Hstr = Rufz;
      Until Flag or Eof(G^.TFile) or (copy(Bstr,1,1) = LZ);
    end;
    if (art=5) and (not Privat) then flag:=true;
    FiResult := CloseTxt(G^.TFile);
   end else
    begin
     Hstr:=' FR:'+int_Str(firesult)+' ';
     Hstr:=Hstr+' Art:'+int_str(art);
     InfoOut(SHOW,1,1,'CALLS.XP-FEHLER!!!!!!!! Kanal: '+int_str(kanal)+Hstr);
    end;
  end;

  Call_Exist := Flag;
End;

Procedure SendToChannel (* Kanal,Art,von,bis : Byte; Zeile : str80 *);
var     i,
        Channel : Byte;
        Hstr    : String[16];
        flag,
        Einzel  : Boolean;
Begin
  with K[Kanal]^ do
  begin
    flag := true;
    Einzel := (von = bis);
    Zeile := RestStr(Zeile);
    if Art = 1 then Channel := 99 else Channel := Kanal;
    for i := von to bis do
    begin
      if (Channel <> i) and (K[i]^.connected) and
         (not K[i]^.Rx_Save) and (not K[i]^.FileSend) then
       if ((not K[i]^.Einstiegskanal) and (not K[i]^.AusstiegsKanal))
           OR (K[i]^.SCon[0]) then
      begin
       if not (k[i]^.sysart in [1..16,18..20]) then
       begin
        if Art = 0 then Hstr := Call + B1 + LRK + int_str(Kanal) + RRK + DP
                   else Hstr := '';
        if tnc[tncnummer]^.afuport=tnc[k[i]^.tncnummer]^.afuport then S_PAC(i,NU,true,Hstr + Zeile + M1);
        flag := false;
       end;
      end else
      begin
        if Einzel and (Art = 0) then
        begin
          S_PAC(Kanal,NU,false,M1 + Star + InfoZeile(90) + M1);
          Send_Prompt(Kanal,FF);
        end;
      end;
    end;
    if flag then
    begin
      if not Einzel and (Art = 0) then
      begin
        S_PAC(Kanal,NU,false,M1 + Star + InfoZeile(91) + M1);
        Send_Prompt(Kanal,FF);
      end;
      if Art = 1 then
      begin
        InfoOut(Kanal,1,1,InfoZeile(121));
       { Send_Prompt(Kanal,FF);}
      end;
    end;
  end;
End;

Procedure Quit (* Kanal : Byte *);
Begin
  with K[Kanal]^ do
  begin
   if not node then
    begin
     TXT_Senden(Kanal,4,0);
     S_PAC(Kanal,NU,true,'');
     if TxComp then S_PAC(Kanal,NU,true,M1 + Meldung[22] + M1);
    end else S_PAC(Kanal,NU,true,'73!'+#13);
    S_PAC(Kanal,CM,true,'D');
  end;
End;


Function  QSO_Time (* Kanal : Byte) : Str20 *);
Var   i,i1,i2 : Integer;
      ZeitStr : String[5];
      Bstr    : String[80];
Begin
  with K[Kanal]^ do
  begin
    i := (60 * (str_int(copy(QSO_Begin,1,2))) + str_int(copy(QSO_Begin,4,2)));
    i1 := (60 * (str_int(copy(Uhrzeit,1,2))) + str_int(copy(Uhrzeit,4,2)));
    if i1 < i then i1  := i1 + 1440;
    i2 := i1 - i;
    ZeitStr := int_str(i2 div 60);
    if length(ZeitStr) < 2 then ZeitStr := '0' + ZeitStr;
    ZeitStr := ZeitStr + DP + int_str(i2 mod 60);
    if length(ZeitStr) < 5 then insert('0',ZeitStr,4);
    Bstr := ZeitStr;
    QSO_Time := Bstr;
  end;
End;


Function Rom_Ready (* : Boolean *);
Var   Hstr : String[80];
Begin
  GetDir(0,Hstr);
  (*$I-*) ChDir(RomDisk); (*$I+*)
  Rom_Ready := (IOResult = 0);
  ChDir(Hstr);
End;


Procedure REM_HelpLong (* Kanal : Byte; IDstr : Str6 *);
Var   i,i1,i2 : Byte;
      Hstr    : String[80];
Begin
  with K[Kanal]^ do
  begin
    if HeapFrei(SizeOf(Hlp^)) then
    begin
      GetMem(Hlp,SizeOf(Hlp^));
      Hlp_Laden(IDstr);

      if RemAll then i2 := 2
                else i2 := 1;

      S_PAC(Kanal,NU,false,M1 + InfoZeile(208) + M1);
      S_PAC(Kanal,NU,false,ConstStr('-',60) + M1);

      for i := 1 to Hlp_Anz do if Hlp^[i].ID > '' then
      begin
        Hstr := CutStr(Hlp^[i].Entry);
        if pos(DpS,Hstr) = 1 then
        begin
          delete(Hstr,1,2);
          i1 := REM_Auswert(Kanal,i2,Hstr);
          if ((node) and (not(i1 in nodecmds)) and (not Remall)) then i1:=0;
          if i1 in RemMenge then
          begin
            Hstr := Line_convert(Kanal,1,Hlp^[i].Entry);
            KillEndBlanks(Hstr);
            if (Node) and (Pos('//', HStr)>0) then delete(HStr,pos('//', Hstr), 2);
            S_PAC(Kanal,NU,false,B1 + Hstr + M1);
          end;
        end;
      end; {for i=}

      Hstr:=InfoZeile(243);
      if (Node) and (Pos('//', HStr)>0) then delete(HStr,pos('//', Hstr), 2);
      S_PAC(Kanal,NU,false,M1 + HSTR);
      S_PAC(Kanal,NU,false,M2);

      FreeMem(Hlp,SizeOf(Hlp^));
    end;
  end;
End;


Procedure ComputeRTF (* Kanal : Byte; Zeile : Str80 *);
Begin
  with K[Kanal]^ do
  begin
    RTF := false;
    delete(Zeile,1,length(Meldung[25]));
    if length(Zeile) = 8 then
    begin
      Zeile := Time_Differenz(Zeile,Uhrzeit);
      EigFlag := true;
      S_PAC(Kanal,NU,true,M1 + InfoZeile(18) + B1 + Zeile + M1);
      EigFlag := false;
    end;
  end;
End;