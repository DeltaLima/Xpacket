{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P L I B 1 . P A S                                                    ³
 ³                                                                         ³
 ³ Library - Unit mit oft ben”tigten Routinen                              ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}

Function CheckXP161 (Kanal:byte) : Boolean;
var Ver1, Ver2:byte;
hst:string;
begin
 with K[kanal]^ do
  begin
   if Pos(AutoSysName[3], SystemErkannt)>0 then
    begin
     hst:=SystemErkannt;
     delete(hst, 1, Pos(AutoSysName[3], hst)+1);
     delete(hst, 1, Pos(' ', hst));
     ver1:=str_int(copy (hst, 1, pos('.',hst)-1));
     delete(hst, 1, pos('.',hst));
     KillendBlanks(hst);
     if not (hst[length(hst)] in ['0'..'9']) then ver2:=str_int(copy (hst, 1,length(hst)-1))
                                        else ver2:=str_int(copy (hst, 1,length(hst)));
    end else Ver1:=0;
  end;
  if ((Ver1=1) and (Ver2>60)) or (Ver1>1) then CheckXP161:=true else CheckXP161:=false;
end;


Function PackDT : longint;
   var dt:datetime;
       dummy:word;
       PDT:longint;
begin
    {year,Month,Day,Hour,Min,Sec: Word;}
    {gepackte zeit wird auf nur 2 sekunden genau!!}
    with DT do
    begin

    if stunde>0 then gotLastHr:=false;
     if (stunde=0) and (not gotLastHr) then
      begin
       getdate(Jahr_,Monat_, Tag_, WoTag_);
       gotLastHr:=true;
      end;
     Year:=Jahr_; Month:=Monat_; Day:=Tag_;
     hour:=Stunde;
     Min :=Minute;
     Sec :=Sekunde;
     {gettime_(Hour, Min, Sec, dummy);}
    end;
   packTime(DT, PDT);
   PackDT:=PDT;
end;



Procedure Editor;
var    KC    : Sondertaste;
Begin
{  G^.Fstr[7] := InfoZeile(66);
  G^.Fstr[9] := InfoZeile(168);
  G^.Fstr[12] := InfoZeile(67);
  G^.Fstr[15] := InfoZeile(68);
  Fenster;
  GetString(G^.Edi_Name,Attrib[3],60,8,15,KC,2,Ins);
  clrFenster;
  if KC <> _Esc then
  begin }
    Teil_Bild_Loesch(1,maxZ,0);
    Cursor_ein;
    ExecDOS(Konfig.EditVerz); { + ' ' + G^.Edi_Name);}
    Cursor_aus;
{  end;   }
  Neu_Bild;
End;


Procedure Link_erhalter (* Kanal : Byte; var Zeile : str80 *);
var   i    : Byte;
      Hstr : String[3];
Begin
  with K[Kanal]^ do
  begin
    if Zeile > '' then
    begin
      HoldStr := RestStr(Zeile);
      for i := 1 to length(HoldStr) do
      case HoldStr[i] of
        BS  : HoldStr[i] := M1;
        '#' : HoldStr[i] := B1;
      end;
      i := Byte(str_int(CutStr(Zeile)));
      if i in [1..99] then
      begin
        Hold := true;
        HoldTime := i;
        HoldLauf:=i * 60;
        Zeile := InfoZeile(160) + B1 + HoldStr;
      end else Zeile := InfoZeile(161) + B1 + CutStr(Zeile);
    end else
    begin
      Hold := false;
      Zeile := InfoZeile(151);
    end;
  if Not Connected then
   begin
    Zeile:=InfoZeile(19);
    Hold:=false;
    HoldTime:=0;
    HoldLauf:=0;
   end;
  end;
End;

Procedure RC_Update (* (Kanal : Byte; var Zeile : String[80]) *);
Var       i,i1,
          Nr    : Byte;
          Nstr  : String[1];
          HStr2,
          Hstr  : String[20];
          Flag,
          Found : Boolean;
          Found2:boolean;
          Lnorm, Lnod : byte;
Begin
 Lnod:=10;

  Nstr := '';
  Zeile := RestStr(Zeile);
  Flag := false;
  Found := false;
  found2:= false;


  if Zeile > '' then
  begin
    if pos(B1,Zeile) > 0 then
    begin
      Hstr := RestStr(Zeile);
      if (length(Hstr) > 0) and (Hstr[1] in ['0'..'5']) then
      begin
        Lnorm := str_int(Hstr[1]);
        Flag := true;
        NStr:=RestStr(Hstr);
      end;

      if (length(NSTr) > 0) and (NStr[1] in ['0'..'5']) then
      begin
        Lnod := str_int(NStr[1]);
        Flag := true;
      end;
    end;

    Hstr := CutStr(Zeile);

    Nr := REM_Auswert(show,2,Hstr);
    if Nr in [1..100] then
    begin
      i := 0;
      Repeat
        inc(i);
        i1 := G^.Remotes[i].BefNr;
        if (i1 = Nr) and (pos(Hstr,G^.Remotes[i].Befehl) = 1) then
        begin
         Found2:=true;
          if (Flag) and (Lnod=10) then
           begin
            if not K[Kanal]^.node then
             begin
              G^.Remotes[i].Level := LNorm;

             end else
             begin
              G^.Remotes[i].LevelN := Lnorm;
             end;
            Found := true;
           end;
          if (Flag) and (Lnod<10) then
            begin
              G^.Remotes[i].Level := Lnorm;
              G^.Remotes[i].LevelN := Lnod;
              Found := true;
            end;
         end;
      Until Found or (i >= maxREM);

      if Flag and Found then
      begin
       i1:=i;
        Assign(G^.TFile,SysPfad + RemDatei);
        if RewriteTxt(G^.TFile) = 0 then
        begin
          for i := 1 to maxREM do if G^.Remotes[i].BefNr > 0 then
          begin
            Hstr := SFillStr(2,B1,int_str(G^.Remotes[i].BefNr)) + B1 +
                    EFillStr(9,B1,G^.Remotes[i].Befehl) +
                    int_str(G^.Remotes[i].AnzCh) + B1 +
                    int_str(G^.Remotes[i].AnzPa) + B1 +
                    int_str(G^.Remotes[i].Level) + B1 +
                    int_str(G^.Remotes[i].LevelN);

            Writeln(G^.TFile,Hstr);
          end;
          FiResult := CloseTxt(G^.TFile);
        end;
      end;
    end else Zeile := InfoZeile(130);
  end else Zeile := S_ch;

  if found2 then
   begin
    hstr:=ParmStr(1,b1,zeile);
    Zeile := upcasestr(hstr) + ':' +
             B1 + 'Terminal ' + int_str(G^.Remotes[i1].Level);
     if Nr in NodeCMDs then Zeile:=Zeile+B1 + '- Node ' + int_str(G^.Remotes[i1].LevelN)
      else Zeile:=Zeile +b1+'- '+InfoZeile(21);
   end;
End;


Procedure File_Umbenennen (* alt,neu : String[80]; var Ueber,Art : Integer *);
var       f,f1 : File;
Begin
  Assign(f,alt);
  Assign(f1,neu);
  if Exists(alt) then
  begin
    if (Ueber = 1) then KillFile(neu);
    if Exists(neu) then
    begin
      Ueber := 135;    { Neuer Name existiert bereits }
      Art := 2;
    end else
    begin
      Rename(f,neu);
      Ueber := 136;    { File wurde umbenannt }
      Art := 3;
    end;
  end else
  begin
    Ueber := 144;      { Alter Name existert berhaupt nicht }
    Art := 1;
  end;
End;


{$IFNDEF no_Bake}               {//db1ras}
Procedure BakenMenu;
Const  ArtMax = 5;
Var    i,
       TNr  : Byte;
       KC   : Sondertaste;
       VC   : Char;
       Flag : Boolean;
       X,Y,
       Art  : Byte;
       Hstr : String[4];

Begin
  Moni_Off(0);;
  if show = 0 then TNr := Unproto
              else TNr := K[show]^.TncNummer;
  Flag := false;
  for i := 9 to 15 do G^.Fstx[i] := 2;
  G^.Fstr[7] := InfoZeile(73);

  G^.Fstr[9] := InfoZeile(58);
  G^.Fstr[10] := InfoZeile(61);
  G^.Fstr[11] := InfoZeile(62);
  G^.Fstr[12] := InfoZeile(63);
  G^.Fstr[13] := InfoZeile(64);
  G^.Fstr[14] := InfoZeile(65);

  Art := 5;

  Repeat
    for i := 9 to 14 do
    begin
      G^.Fstr[i][vM+1] := B1;
      G^.Fstr[i][hM+1] := B1;
      G^.Fstr[i][vM] := B1;
      G^.Fstr[i][hM] := B1;
    end;

    if Art in [1..6] then
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

    delete(G^.Fstr[9],vM+1,1);
    insert(int_str(TNr),G^.Fstr[9],vM+1);
    if TNC[TNr]^.Bake then G^.Fstr[13][vM+1] := X_ch;

{    G^.Fstr[14] := '';}
    G^.Fstr[15] := '';
    Fenster(15);

    _ReadKey(KC,VC);
    Case KC of
      _Esc : Flag := true;

     _AltH : XP_Help(G^.OHelp[3]);

      _Ret : ;

       _F1 : Art := 1;
       _F2 : Art := 2;
       _F3 : Art := 3;
       _F4 : Art := 4;
       _F5 : Art := 5;
       _F6 : Art := 6;
       _F7,
       _F8,
       _F9,
      _F10 : Alarm;

       _Up : if Art > 1  then dec(Art)
                         else Alarm;

       _Dn : if Art < ArtMax then inc(Art)
                             else Alarm;
   _Andere : case VC of
               B1:;
               else Alarm;
             end;
       else Alarm;
    End;

    if (KC in [_F1.._F6,_Ret]) or ((KC = _Andere) and (VC = B1)) then
    case Art of
      1 : begin
            G^.Fstr[9][vM] := S_ch;
            Fenster(15);
            Hstr := '';
            GetString(Hstr,Attrib[3],1,2,15,KC,0,Ins);
            if KC <> _Esc then
            begin
              i := Byte(str_int(Hstr));
              if i in [1..Tnc_Anzahl] then TNr := i
                                      else Alarm;
            end;
          end;
      2 : begin
            G^.Fstr[10][vM] := S_ch;
            Fenster(15);
            Hstr := int_str(TNC[TNr]^.BTimer);
            GetString(Hstr,Attrib[3],4,2,15,KC,0,Ins);
            if KC <> _Esc then
            begin
              TNC[TNr]^.BTimer := Word(str_int(Hstr));
              if TNC[TNr]^.BTimer < MinBake then TNC[TNr]^.BTimer := DefBake;
            end;
          end;
      3 : begin
            G^.Fstr[11][vM] := S_ch;
            Fenster(15);
            GetString(TNC[TNr]^.BPFad,Attrib[3],78,2,15,KC,0,Ins);
          end;
      4 : begin
            G^.Fstr[12][vM] := S_ch;
            Fenster(15);
            GetString(TNC[TNr]^.BText,Attrib[3],78,2,15,KC,0,Ins);
          end;
      5 : begin
            TNC[TNr]^.Bake := not TNC[TNr]^.Bake;
            Flag := true;
          end;
      6 : begin
            G^.Fstr[14][vM] := S_ch;
            Fenster(15);
            GetString(TNC[TNr]^.BCall,Attrib[3],10,2,15,KC,0,Ins);
          end;
    end;

    SetzeFlags(0);
  Until Flag;

  ClrFenster;
  Neu_Bild;
  Moni_On;
End;
{$ENDIF}


Procedure Tschuess (* Kanal : Integer *);  (* Programm-Ende mit ALT-X *)
var    ch : char;
       KC : Sondertaste;
       i  : Integer;
Begin
 if SiAltD then
  begin
  G^.Fstr[7] := InfoZeile(84);
  G^.Fstx[11] := 20;
  G^.Fstr[11] := InfoZeile(85);
  Fenster(15);
  SetzeCursor(length(G^.Fstr[11])+G^.Fstx[11]-2,11);
  clrFenster;
{  if Klingel then Morse(Kanal,'þ'); }

  Repeat
    _ReadKey(KC,Ch);
    case KC of
      _AltH   : XP_Help(G^.OHelp[23]);
      _Ret    : QRT := true;
      _Andere : begin
                  Ch := UpCase(Ch);
                  QRT := Ch in YesMenge;
                end;
    end;
  Until QRT or (not QRT and (KC <> _AltH));
  if not QRT then Neu_Bild;
 end else QRT:=true;
  Cursor_Aus;
END;


Procedure TschuessFenster;
Begin
  Cursor_Aus;
  G^.Fstr[7] := Version;
  G^.Fstx[11] := 25;
  G^.Fstr[11] := InfoZeile(38);
  G^.Fstx[13] := 34;
  G^.Fstr[13] := InfoZeile(39);
  Fenster(15);
  clrFenster;
End;

Procedure TestCheck (* Kanal : Byte; Zeile : Str80 *);
var   i,j : Byte;
Begin
  with K[Kanal]^ do
  begin
    if Test then
    begin
     BellCount:=0;
     K[TestMerk]^.BellCount:=0;
     EraseBufferFile(Kanal);
     EraseBufferFile(TestMerk);
      SystemErkannt:='';
      RX_Save:=false;
      K[TestMerk]^.RX_Save:=false;
      K[Kopieren]^.KopierenFm:=0;
      KopierenFm:=0;
      Kopieren:=0;
      _aus(Attrib[20],Kanal,M1 + InfoZeile(191) + M1);
      _aus(Attrib[20],TestMerk,M1 + InfoZeile(191) + M1);
      if Klingel then
      begin
        Beep(G^.C1_Ton,G^.C1_TonTime);
        Verzoegern(100);
        Beep(G^.C1_Ton,G^.C1_TonTime);
      end;
      S_PAC(TestMerk,CM,true,'I ' + K[TestMerk]^.OwnCall);
      S_PAC(Kanal,CM,true,'I ' + OwnCall);
      K[TestMerk]^.Umlaut := K[TestMerk]^.UmlautMerk;
      Umlaut := UmlautMerk;
      StatusOut(Kanal,14,1,Attrib[12],EFillStr(29,B1,' '),1);
      StatusOut(TestMerk,14,1,Attrib[12],EFillStr(29,B1,' '),1);
      StatusOut(TestMerk,4,1,Attrib[9],EFillStr(9,B1,K[TestMerk]^.OwnCall),1);
      StatusOut(Kanal,4,1,Attrib[9],EFillStr(9,B1,OwnCall),1);
      K[TestMerk]^.TestMerk := 0;
      K[TestMerk]^.Test := false;
      K[TestMerk]^.Call := '';
      K[TestMerk]^.SCon[0] := false;
      K[TestMerk]^.SystemErkannt:='';
      K[TestMerk]^.SCon[0] := false;
      K[TestMerk]^.RemAll:=false;
      Call := '';
      Test := false;
      RemAll:=false;
      K[TestMerk]^.TxComp := false;
      K[TestMerk]^.RxComp := false;
      K[TestMerk]^.CompC  :=false;
      K[TestMerk]^.KompressUpd:=false;
      for j:=1 to 255 do
       begin
        K[TestMerk]^.Kompression[j]:=0;
       end;
      TestMerk := 0;
      TxComp := false;
      RxComp := false;
      CompC  :=false;
      KompressUpd:=false;
      for j:=1 to 255 do
       begin
        Kompression[j]:=0;
       end;
    end else if not connected and not Kanal_Benutz and (Kanal > 0) then
    begin
      i := Byte(str_int(RestStr(Zeile)));
      if not (i in [1..maxLink]) or K[i]^.Kanal_benutz or K[i]^.connected or
         K[i]^.Mo.MonActive or (i = ConvHilfsPort) then i := KanalFrei(Kanal);
      if i > 0 then
      begin
       First_Frame:=true;
        TestMerk := i;
        Test := true;
        SCon[0] := true;
        TxComp := false;
        RxComp := false;
        CompC  :=false;
        KompressUpd:=false;
        for j:=1 to 255 do
         begin
          Kompression[j]:=0;
         end;
        K[i]^.TxComp := false;
        K[i]^.RxComp := false;
        K[i]^.CompC  :=false;
        K[i]^.KompressUpd:=false;
        for j:=1 to 255 do
         begin
          K[i]^.Kompression[j]:=0;
         end;
        K[i]^.SCon[0] := true;
        K[i]^.TestMerk := Kanal;
        K[i]^.Test := true;
        K[i]^.First_Frame:=true;

        BellCount:=0;
        K[i]^.BellCount:=0;

        QSO_Date := Datum;
        K[TestMerk]^.QSO_Date := Datum;

        QSO_Begin := copy(Uhrzeit,1,5);
        K[TestMerk]^.QSO_Begin := copy(Uhrzeit,1,5);

        S_PAC(TestMerk,CM,true,'I ' + PhantasieCall);
        S_PAC(Kanal,CM,true,'I ' + + PhantasieCall);

        K[TestMerk]^.Call := OwnCall;

        Call := K[TestMerk]^.OwnCall;

        K[TestMerk]^.UmlautMerk := K[TestMerk]^.Umlaut;
        K[TestMerk]^.User_Name := GetName(TestMerk,K[TestMerk]^.Call,K[TestMerk]^.Umlaut, TRUE);
        RX_Save:=false;
        K[TestMerk]^.RX_Save:=false;
        UmlautMerk := Umlaut;
        User_Name := GetName(Kanal,Call,Umlaut, TRUE);

        UserInStatus(Kanal);

        StatusOut(TestMerk,4,1,Attrib[11],EFillStr(9,B1,K[TestMerk]^.Call),1);
        StatusOut(Kanal,4,1,Attrib[11],EFillStr(9,B1,Call),1);
        _aus(Attrib[20],Kanal,M1 + InfoZeile(190) + B1 + LRK + int_str(TestMerk) + RRK + M1);
        _aus(Attrib[20],TestMerk,M1 + InfoZeile(190) + B1 + LRK + int_str(Kanal) + RRK + M1);

        K[TestMerk]^.RemAll:=true;
        RemAll:=True;

        if Klingel then
        begin
          Beep(G^.C2_Ton,G^.C2_TonTime);
          Verzoegern(100);
          Beep(G^.C2_Ton,G^.C2_TonTime);
        end;
        Txt_Senden(TestMerk,6,0);
        if not GrtFlag then Txt_Senden(TestMerk,3,0);
        S_PAC(TestMerk,NU,true,'');
      end else InfoOut(show,1,1,InfoZeile(94));
    end else InfoOut(Kanal,1,1,InfoZeile(193));
    Status2;
  end;
 SetzeFlags(Kanal)
End;

Procedure UserInStatus (* Kanal : Byte *);              {//db1ras}
Var   hstr         :  String[60];
      entfg,richtg :  Real;
      status       :  Boolean;
      entf         :  String[14];

Begin
  hstr:='';
  With k[kanal]^ Do Begin
    If connected Then Begin
      hstr:=User_Name+B1+User_QTH;
      If Length(hstr) > 28 Then
        hstr:=Copy(hstr,1,27)+'~'
      Else If Length(hstr)+7 <= 28 Then
        hstr:=hstr+B1+User_Loc;
      QTH_ENTFG_RICHTG(User_Loc,Konfig.PersLoc,entfg,richtg,status);
      If status=true Then Begin
        Str(entfg:0:1,entf);
        If Length(hstr+entf)+3 <= 28 Then
          hstr:=hstr+B1+entf+'km'
        Else Begin
          Str(entfg:0:0,entf);
          If Length(hstr+entf)+3 <= 28 Then
            hstr:=hstr+B1+entf+'km';
        End;
      End;

    {fuehrende Leerzeichen entfernen (vorhanden, wenn kein Name/QTH bekannt)}
      While Pos(B1,hstr)=1 Do
        hstr:=Copy(hstr,2,Length(hstr)-1);

    End;

    If Not Mo.MonActive Then
      StatusOut(Kanal,14,1,Attrib[12],EFillStr(29,B1,hstr),1);
  End;
  SetzeFlags(Kanal);
End;


Procedure Connect (* Kanal : Byte; Zeile : Str80 *);
var    Hstr : String[9];
       i,i1 : Byte;
Begin
  with K[Kanal]^ do
  begin
    Zeile := UpCaseStr(Zeile);
    if Kanal = 0 then K[0]^.TncNummer := Unproto
                 else Outside := false;
    if length(Zeile) > 1 then Ausgabe := false;
    S_PAC(Kanal,CM,true,'C' + B1 + RestStr(Zeile));
    i := 0;
    if not connected then While (pos('ALREADY',Response) > 0) and (i < 15) do
    begin
      inc(i);
      Ausgabe := false;
      S_PAC(Kanal,CM,true,'I');
      Hstr := Response;
      Strip(Hstr);
      Hstr := Hstr + '-' + int_str(i);
      S_PAC(Kanal,CM,true,'I' + B1 + Hstr);
      Ausgabe := false;
      S_PAC(Kanal,CM,true,'C' + B1 + RestStr(Zeile));
    end;
    Rekonnekt := connected;
    ConnectMerk := Zeile;
    if length(Zeile) > 1 then Kanal_benutz := true;
    if Kanal = 0 then Unproto_darstellen;
  end;
End;


Procedure S_Aus (* Kanal,Art : Byte; Zeile : String *);
Begin
  with K[Kanal]^ do
  begin
    if Art in [1,3] then S_PAC(Kanal,NU,false,Zeile);
    if Art in [2,3] then _aus(Attrib[19],Kanal,Zeile);
  end;
End;


Procedure RC_Alle (* Kanal,Art : Byte *); (* Ausgabe aller Remote-RC's *)
var    i,i1 : Byte;
       Hstr : String[20];
Begin
  S_Aus(Kanal,Art,M1 + ConstStr(B1,21) + InfoZeile(173) + M2);
  i1 := 1;
  for i := 1 to maxREM do if G^.Remotes[i].BefNr > 0 then
  begin
    Hstr := EFillStr(9,Pkt ,G^.Remotes[i].Befehl) +
            int_str(G^.Remotes[i].Level)+'/'+
            int_str(G^.Remotes[i].LevelN) + B1;

    if i1 mod 6 = 0 then
    begin
      KillEndBlanks(Hstr);
      Hstr := Hstr + M1;
    end;
    S_Aus(Kanal,Art,Hstr);
    inc(i1);
  end;
  S_Aus(Kanal,Art,M2);
End;


Procedure TNC_Parm (* Kanal,Art : Byte *);
var    i,i1 : Word;
       Bstr : String[8];
       Hstr : String[80];
Begin
  with K[Kanal]^ do
  begin
    S_Aus(Kanal,Art,M1 + ConstStr(B1,21) + InfoZeile(40) + M2);
    i := 1;
    Assign(G^.TFile,SysPfad + TncDatei);
    FiResult := ResetTxt(G^.TFile);
    Repeat
      Readln(G^.TFile,Hstr);
      KillStartBlanks(Hstr);
      i1 := pos('=',Hstr);
      if i1 > 0 then
      begin
        Bstr := copy(Hstr,1,i1-1);
        KillEndBlanks(Bstr);
        if (pos('A',Bstr) > 0) or (pos(int_str(TncNummer),Bstr) > 0) then
        begin
          delete(Hstr,1,i1);
          KillStartBlanks(Hstr);

          Ausgabe := false;
          S_PAC(Kanal,CM,true,CutStr(Hstr));
          Hstr := LRK + EFillStr(5,B1,CutStr(Hstr) + RRK) +
                        EFillStr(12,B1,RestStr(Hstr)) + ': '+
                        EFillStr(16,B1,Response);

          if length(Hstr) > 36 then
          begin
            KillEndBlanks(Hstr);
            Hstr := Hstr + M1;
            if i mod 2 = 0 then
            begin
              Hstr := M1 + Hstr;
              inc(i);
            end;
          end else
          begin
            if i mod 2 = 0 then
            begin
              KillEndBlanks(Hstr);
              Hstr := Hstr + M1;
            end;
            inc(i);
          end;
          S_Aus(Kanal,Art,Hstr);
        end;
      end;
    Until Eof(G^.TFile);
    FiResult := CloseTxt(G^.TFile);
    S_Aus(Kanal,Art,M2);
  end;
End;


Procedure GetVideoMode;
Begin
  if VideoSeg = SegHGC then
  begin
    StartColor := 15;
    Hercules := true;
  end else
  begin
    Color := true;
    StartColor := 127; {31 original (blau/weiá),116 grau/rot }
    Hercules := false;
  end;
End;


Procedure Umlautstatus_Aendern (* Kanal : Byte *);
Const  ArtMax = 4;
Var    i    : Byte;
       KC   : Sondertaste;
       VC   : Char;
       Flag : Boolean;
       X,Y,
       Art  : Byte;
       udb:user_typ2;
       l_i:longint;
       c:byte;

Begin
  with K[Kanal]^ do
  begin
    Moni_Off(0);;
    Flag := false;
    for i := 9 to 15 do G^.Fstx[i] := 3;
    G^.Fstr[7] := InfoZeile(260);
    G^.Fstr[10] := InfoZeile(261);
    G^.Fstr[11] := InfoZeile(262);
    G^.Fstr[12] := InfoZeile(263);
    G^.Fstr[13] := InfoZeile(264);
    for i:=9 to 13 do G^.fstx[i]:=5;
    Art := 1;

    Repeat
      for i := 10 to 13 do
      begin
        G^.Fstr[i][vM+1] := B1;
        G^.Fstr[i][vM] := B1;
      end;

      X := vM;
      Y := Art + 9;

      G^.Fstr[Y][X] := A_ch;

      if HardCur then SetzeCursor(X+1,Y);

      if Umlaut = 1 then G^.Fstr[10][vM+1] := X_ch;
      if Umlaut = 2 then G^.Fstr[11][vM+1] := X_ch;
      if Umlaut = 3 then G^.Fstr[12][vM+1] := X_ch;

      G^.Fstr[9] := '';
      G^.Fstr[14] := '';
      G^.Fstr[15] := '';
      Fenster(15);

      _ReadKey(KC,VC);
      Case KC of
        _Esc : Flag := true;

       _AltH : XP_Help(G^.OHelp[24]);

        _Ret :;

         _F1 : Art := 1;
         _F2 : Art := 2;
         _F3 : Art := 3;
         _F4 : Art := 4;
         _F5,
         _F6,
         _F7,
         _F8,
         _F9,
        _F10 : Alarm;

         _Up : if Art > 1  then dec(Art)
                           else Alarm;

         _Dn : if Art < ArtMax then inc(Art)
                               else Alarm;
     _Andere : case VC of
                 B1:;
                 else Alarm;
               end;

         else Alarm;
      End;

      if (KC in [_F1.._F4,_Ret]) or ((KC = _Andere) and (VC = B1)) then
      case Art of
        1 : begin
              G^.Fstr[10][vM] := S_ch;
              if Umlaut <> 1 then Umlaut := 1
                             else Umlaut := 0;
            end;
        2 : begin
              G^.Fstr[11][vM] := S_ch;
              if Umlaut <> 2 then Umlaut := 2
                             else Umlaut := 0;
            end;
        3 : begin
              G^.Fstr[12][vM] := S_ch;
              if Umlaut <> 3 then Umlaut := 3
                             else Umlaut := 0;
            end;
        4 : if connected and (User_Name > '') and not Test then
            begin
              {Neu_Name(Kanal,0,Call,User_Name);}
                        {ucall}
              udb.call:=call;
              udb.umlaut:=umlaut;
              PutUser(Udb,c,4,L_I,false);
            end else Alarm;
      end;

      SetzeFlags(Kanal);
    Until Flag;

    if not connected then UmlautMerk := Umlaut;
    ClrFenster;
    Neu_Bild;
    Moni_On;
  end;
End;


Procedure Echo_Menue (* Kanal : Byte *);
Const  ArtMax = 5;
Var    i    : Byte;
       KC   : Sondertaste;
       VC   : Char;
       AllCh,
       Flag : Boolean;
       X,Y,
       Art  : Byte;

Begin
AllCh:=true;
  with K[Kanal]^ do
  begin
    Moni_Off(0);;
    Flag := false;
    for i := 9 to 15 do G^.Fstx[i] := 18;
    G^.Fstr[7] := InfoZeile(74);
    G^.Fstr[9] := InfoZeile(79);
    G^.Fstr[10] := InfoZeile(80);
    G^.Fstr[11] := InfoZeile(81);
    G^.Fstr[12] := InfoZeile(82);
    G^.FStr[13] := InfoZeile(83);

    Art := 1;

    Repeat
      for i := 9 to 13 do
      begin
        G^.Fstr[i][vM+1] := B1;
        G^.Fstr[i][vM] := B1;
      end;

      X := vM;
      Y := Art + 8;
      G^.Fstr[Y][X] := A_ch;

      if HardCur then SetzeCursor(X+1,Y);

      if Echo in [1,3,5,7] then G^.Fstr[9][vM+1] := X_ch;
      if Echo in [2,3,6,7] then G^.Fstr[10][vM+1] := X_ch;
      if Echo in [4..7]    then G^.Fstr[11][vM+1] := X_ch;
      if SysTextEcho then G^.Fstr[12][vM+1] := X_ch;
      if AllCh then G^.Fstr[13][vM+1] := X_ch;

      G^.Fstr[14] := '';
      G^.Fstr[15] := '';
      Fenster(15);

      _ReadKey(KC,VC);
      Case KC of
        _Esc : Flag := true;

       _AltH : XP_Help(G^.OHelp[5]);

        _Ret :;

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
     _Andere : case VC of
                 B1:;
                 else Alarm;
               end;

         else Alarm;
      End;

      if (KC in [_F1.._F5,_Ret]) or ((KC = _Andere) and (VC = B1)) then
      case Art of
        1 : if Echo in [1,3,5,7] then Echo := Echo - 1
                                 else Echo := Echo + 1;

        2 : if Echo in [2,3,6,7] then Echo := Echo - 2
                                 else Echo := Echo + 2;

        3 : if Echo in [4..7]    then Echo := Echo - 4
                                 else Echo := Echo + 4;
        4 : SysTextEcho:=not SysTextEcho;
        5 : AllCh:=not AllCh;
      end;

      SetzeFlags(Kanal);
    Until Flag;
    if AllCH then
     begin
      for i:=1 to maxlink do
       begin
        if i<>kanal then
         begin
          K[i]^.Echo:=K[kanal]^.Echo;
          K[i]^.SysTextEcho:=K[kanal]^.SysTextEcho;
         end;
       end;
     end;

    ClrFenster;
    Neu_Bild;
    Moni_On;
  end;
End;


Function LPT_Error (* (Nr : Byte) : Boolean *);
Begin
  LPT_Error := ((Port[LPT_Base[Nr] + $01] and $B8) <> $98);
End;

(* Den String 'Zeile' an den Drucker schicken                          *)
(* Steuerzeichen an den Drucker muessen schon vorher gesendet werden ! *)
Procedure Write_Lpt (* Kanal : Byte; Zeile : Str20 *);
var     Fehler   : Integer;
        i        : Byte;
        TimeOut,
        TimeMerk : LongInt;
        Flag     : Boolean;

  Procedure Druckerfehler(B : Byte);
  var   l,
        TimeOut  : LongInt;
        KC       : Sondertaste;
        VC       : Char;
        Flag,
        Fehler   : Boolean;
        Code     : Byte;
  begin
    TimeOut := 0;
    l := TimerTick;
    Repeat
      Code := Port[LPT_Base[PrtPort]+$01];
      Flag := Code and B = B;
      Fehler := Code and $38 <> $18;
      if l <> TimerTick then
      begin
        inc(TimeOut);
        l := TimerTick;
      end;
    Until Flag or Fehler or (TimeOut > Lpt_TimeOut);
    if (TimeOut > Lpt_TimeOut) or Fehler then
    begin
      InfoOut(Kanal,1,1,InfoZeile(291));
      _ReadKey(KC,VC);
      if UpCase(VC) in YesMenge then PrtFailure := true;
    end;
  end;

Begin
  if not PrtFailure then
  begin
    i := 0;
    Flag := false;
    While not Flag and (i < length(Zeile)) do
    begin
      inc(i);
      Druckerfehler($80);
      if not PrtFailure then
      begin
        Port[LPT_Base[PrtPort]] := Ord(Zeile[i]);
        Port[LPT_Base[PrtPort] + $02] := Port[LPT_Base[PrtPort] + $02] or $01;
        Port[LPT_Base[PrtPort] + $02] := Port[LPT_Base[PrtPort] + $02] and $FE;
        Druckerfehler($40);
      end;
    end;
  end;
End;

Procedure LptEscSeq(* Kanal : Byte; Zeile : Str80 *);
Var   Hstr : String[20];
Begin
  if LPT_vorhanden then
  begin
    Hstr := '';
    while Zeile > '' do
    begin
      Hstr := Hstr + chr(str_int(CutStr(Zeile)));
      Zeile := RestStr(Zeile);
    end;
    Write_Lpt(Kanal,Hstr);
  end else InfoOut(Kanal,1,1,InfoZeile(292));
End;

Procedure Lpt_On_Off (* Kanal : Byte *);
Var  i    : Byte;
     D_ON : Boolean;
Begin
  with K[Kanal]^ do
  begin
    if Drucker then
    begin
      Write_Lpt(Kanal,LptEsc[10]);
      Drucker := false;
      Print := false;
      PrtFailure := false;
    end else
    begin
      if LPT_vorhanden then
      begin
        D_ON := false;
        for i := 0 to maxLink do if K[i]^.Drucker then D_On := true;
        if not D_ON then
        begin
          if not LPT_Error(PrtPort) then
          begin
            Drucker := true;
            Print := true;
            Write_Lpt(Kanal,LptEsc[9]);
          end else InfoOut(Kanal,1,1,InfoZeile(290));
        end else Alarm;
      end else InfoOut(Kanal,1,1,InfoZeile(292));
    end;
    for i := 0 to maxLink do SetzeFlags(i);
  end;
End;

Procedure Write_Drucker (* Kanal : Byte; Zeile : String *);
var  i      : Integer;
     ch     : char;
Begin
  if not PrtFailure then with K[Kanal]^ do
  Begin
    Zeile := Line_Convert(Kanal,2,Zeile);
    for i := 1 to length(Zeile) do
    Begin
      ch := Zeile[i];
      if (D_Spalte > 80) and (ch <> #13) then
      Begin
        Write_Lpt(Kanal,^J +M1);
        D_Spalte := 1;
      End;
      case ch of
       ^J,
       M1  : Begin
               if (Kanal = 0) then
               Begin
                 if D_Spalte <> 1 then Write_Lpt(Kanal,^J +M1);
               End else Write_Lpt(Kanal,^J +M1);
               D_Spalte := 1;
             End;
       #127: ;
       #0..#31
           : ;
       else  Begin
               Write_Lpt(Kanal,ch);
               inc(D_Spalte);
             End;
      end;
    End;
  End;
End;

Procedure Vorschreib_Uebergabe;
var   VC    : char;
      Hstr  : String[80];
      KC    : Sondertaste;
      a,i   : Integer;
      Flag  : Boolean;
Begin
  Hstr := '';
  Flag := false;
  i := K[show]^.QBeg + 1;
  WriteRam(1,K[show]^.Y1V+K[show]^.VBeg-1,Attrib[5],0,VorWrite[show]^[K[show]^.stV]);
  WriteRam(1,i,Attrib[5],0,EFillStr(80,B1,InfoZeile(51)));
  GetString(UeberNr,Attrib[5],2,length(InfoZeile(51))+1,i,KC,0,Flag);
  a := str_int(UeberNr);
  if KC = _Ret then
  begin
    if (a in [0..maxLink]) and (a <> show) then
    begin
      with K[show]^ do
      begin
        Hstr := VorWrite[show]^[stV];
        if Vor_im_EMS then EMS_Seite_Einblenden(a,Vor);
        Vor_Feld_Scroll(a);
        Vor_Dn_Scroll(a);
        VorWrite[a]^[K[a]^.stV] := Hstr;
        Chr_Darstell(a,_Alt8,#255);
        Chr_Darstell(a,_End,#255);
        if Vor_im_EMS then EMS_Seite_Einblenden(show,Vor);
        VorWrite[show]^[stV] := '';
        Chr_Darstell(show,_Dn,#255);
      end;
    end else Alarm;
  end;
  Neu_Bild;
End;


Procedure Vorschreib_Such (Kanal : Byte);
var i,i1    : Integer;
    KC      : Sondertaste;
    Hstr    : String[80];
    Suchstr : String[20];
    gefunden: Boolean;

Begin
  with K[Kanal]^ do
  begin;
    gefunden := false;
    Suchstr := '';
    Hstr := B1 + InfoZeile(42) + B1;
    WriteRam(1,VBeg,Attrib[5],0,EFillStr(80,B1,Hstr));
    GetString(Suchstr,Attrib[5],20,length(Hstr)+1,VBeg,KC,0,Ins);
    if KC <> _Esc then
    begin
      i := stV;
      Repeat
        i1 := pos(Suchstr,UpCaseStr(VorWrite[Kanal]^[i]));
        if i1 > 0 then gefunden := true;
        inc(i);
      Until (gefunden) or (i = (VorZeilen - VorCmdZeilen)+1);
      if gefunden then
      begin
        dec(i); Neu_Bild; X1V := i1; Y1V := 2;
        if i = 1 then Y1V := 1;
        if i = (VorZeilen - VorCmdZeilen) then Y1V := 3;
        stV := i;
        InfoOut(Kanal,1,1,InfoZeile(8));
      end else InfoOut(Kanal,1,1,InfoZeile(9));
    end else Neu_Bild;
    Chr_Darstell(Kanal,_Andere,#255);
  end;
End;


Procedure Belog_Eintrag (* Kanal : Byte *);
Var  Hstr : String[80];
     Bstr : String[20];
     KC   : Sondertaste;
Begin
  with K[Kanal]^ do
  begin
    Bstr := '';
    Hstr := B1 + InfoZeile(26) + B1;
    WriteRam(1,VBeg,Attrib[5],0,EFillStr(80,B1,Hstr));
    GetString(Bstr,Attrib[5],20,length(Hstr)+1,VBeg,KC,0,Ins);
    if KC <> _Esc then
    begin
      LogMerker := Bstr;
      BeLogEintr := Bstr > '';
    end;
    Neu_Bild;
  end;
End;

PROCEDURE BoxListe (* Kanal : Byte *);
begin
with K[Kanal]^ do
 begin
  if not BoxListeErg then
  begin
   OpenDBox(Kanal);
   BoxStr := EFillStr(79,GPkt,GPkt + B1 + 'Connect to' + B1 +
             Call + DP + B1 + User_Name + B1 + GPkt + B1 +
             'Login' + DP + B1 + WochenTag + B1 +
              copy(Datum,4,8) + B1 + copy(Uhrzeit,1,5) + B1) +
              B1 + Chr(Attrib[20]);
    Rubrik := ConstStr(B1,8);
    Write_BoxStr(Kanal,1);
    BoxlisteErg:=True;
   end;
 end;
end;


{Setzt SysArt und SCon aus dem System-String des uebergebenen Kanals        }
{liefert true zurueck, wenn SysArt <> 0                            //db1ras }
Function SetzeSysArt (* (Kanal : Byte) : Boolean *);
Var  Flag      : Boolean;
     i,
     OldSysArt : Byte;

Begin
  With k[Kanal]^ Do Begin
    OldSysArt:=SysArt;
    SysArt:=0;
    SCon[0]:=false;
    If Not node Then
      For i:=1 to maxSCon Do Begin
        SCon[i]:=false;
        If Pos(SNam[i],UpCaseStr(System))=1 Then
          SysArt:=i;
      End;

    SCon[SysArt]:=true;

    If SysArt<>OldSysArt Then
      SystemErkannt:='';

    If SysArt=0 Then
      SetzeSysArt:=false
    Else
      SetzeSysArt:=true;

  End;
End;


Procedure L_ON (* Kanal:Byte; Zeile:Str128; Connect_out,ReKon:Boolean *);
var i          : Byte;
    callst,
    ZStr       : String;
    Hs         : string[8];
    FlagS,
    FlagQ,
    Flag       : Boolean;
    AuSyst     : Byte;

Begin
  with K[Kanal]^ do
  Begin

   BellCount:=0;
   SystemErkannt:='';
   if (Fwd) and (acZeile='') then fwdGo:=true;
   FTxName := Konfig.SavVerz;
   FRxName := Konfig.SavVerz;
   SPRxCount:=0;
   SPRxSoll:=0;
   TX_CRC:=0;
   RX_CRC:=0;
   ReqName:=False;
   if not ESC_Call then CompC:=false;
   BoxListeErg:=false;



   NodeTimeOut:=NTimeout*60;
   TermTimeOut:=Konfig.TTimeout * 60;
    if ScreenSTBY then
    begin
      ScreenSTBY := false;
      ScreenTimer := ScreenInit;
      Neu_Bild;
    End;

    TNC_K := false;
    i := pos(' - ',Zeile);
    if i > 0 then  (* TNC V2.1c hat Uhrzeit gesendet *)
    begin
      TNC_K := true;
      TNC_Date := copy(Zeile,i+3,8);
      if TNC_Date[3] = '/'       (* amerikanisches Format *)
         then TNC_Date := copy(TNC_Date,4,2) + Pkt  + copy(TNC_Date,1,2) +
                                               Pkt  + copy(TNC_Date,7,2);
      TNC_Date := GetWeekDay(TNC_Date) + B1 + TNC_Date;
      TNC_Time := copy(Zeile,i+12,8);
      delete(Zeile,i,20); (* Datum/Uhrzeit abschneiden *)
    end;

    if show <> Kanal then NochNichtGelesen := true
                     else NochNichtGelesen := false;
    Zeile := RestStr(Zeile);

    callst := ParmStr(3,B1,Zeile);
    call   := copy(callst, pos(':',CallSt) +1,length(callst));
    StatusOut(Kanal,4,1,Attrib[11],EFillStr(9,B1,Call),1);
    connected := true;

    If not ESC_Call Then First_Frame := true;   {//db1ras}
    DBoxScaned := false;
    DieBoxPW := '';
    Hold := false;

    if WishBoxLst and (SysArt in SysMenge) then
    begin
      SysArt := 0;
      if not BoxScroll then CloseDBox(Kanal);
    end;

{    if rekon then
     begin}
      Sysart:=0;

      AutoKenn:=False;
      SystemErkannt:='';
 {    end;  }

     AuSyst:=SysArt;

    UmlautMerk := Umlaut;
    User_Name := GetName(Kanal,Call,Umlaut,TRUE);


    Flag:=SetzeSysArt(Kanal);   {ersetzt folgendes   //db1ras}
(*  Flag := false;
    for i := 0 to maxSCon do SCon[i] := false;

  if not node then
   begin
    SysArt := 0;
    i:=0;
    Repeat
     inc(SysArt);
      if pos(SNam[SysArt],UpCaseStr(System)) = 1 then
      begin
        Flag := true;
        SCon[SysArt] := true;
        i:=SysArt;
      end
       else
        begin
         Scon[sysArt]:=false;
        end;
    Until (SysArt = maxSCon);

    SysArt:=i;
   end else SysArt:=0; {if not node}

   for i:=1 to Sysart-1 do Scon[sysArt]:=false; {?????????????????? //db1ras}
*)
    if AutoKenn then
     begin
      flag:=true;
      SysArt:=AuSyst;
      scon[SysArt]:=true;
     end;


    if Flag then
    Case SysArt of
      1,2,3,4,5,
      14: begin
            if SysArt = 2 then
            begin
              Zstr := Call;
              Strip(Zstr);
              ExtMld := Zstr + '>';
            end;

            if WishBoxLst then BoxListe(Kanal);
          end;

      11: if HoldDXc then
          begin
            Zstr := HoldDXcStr;
            Link_erhalter(Kanal,Zstr);
            SetzeFlags(Kanal);
          end;

      12: S_PAC(Kanal,NU,true,M1);

    end else
    begin
      SysArt := 0;
      SCon[0] := true;
    end;

    if Rekon then
    begin
      ConnectMerk := '';
      i := pos('>' + Call + B1,ACMerk + B1);
      if i > 0 then
      begin
        While (i > 0) and (ACMerk[i] <> B1) do dec(i);
        Zstr := copy(ACMerk,1,i);
        KillEndBlanks(Zstr);
        delete(ACMerk,1,i);
        Zstr := Zstr + B1 + CutStr(ACMerk) + B1;
        ACMerk := RestStr(ACMerk);
        While (length(ACMerk) > 0) and (pos('>',CutStr(ACMerk)) = 0) do
        begin
          Zstr := Zstr + CutStr(ACMerk) + B1;
          ACMerk := RestStr(ACMerk);
        end;
        KillStartBlanks(Zstr);
        KillEndBlanks(Zstr);
        ACMerk := Zstr + B1;
      end;
    end else
    begin
      While pos(M1,ConnectMerk) > 0 do
        delete(ConnectMerk,pos(M1,ConnectMerk),1);
      i := pos(B1,ConnectMerk);
      if i > 0 then ConnectMerk[i] := '>';
      KillEndBlanks(ConnectMerk);
      ACMerk := ACMerk + ConnectMerk + B1;
      ConnectMerk := '';
    end;

    RemAll := false;

    SetzeFlags(Kanal);
    UserInStatus(Kanal);
    if Connect_Out then
    begin
      QSO_Date := Datum;
      QSO_Begin := copy(Uhrzeit,1,5);
    end;
    if not TNC_ReadOut and TNC_K then
    begin
      QSO_Date := TNC_Date;
      QSO_Begin := TNC_Time;
    end;
{****fehlerquelle?}
    if Connect_out then
    begin
      S_PAC(Kanal,CM,true,'O' + int_str(MaxFrame));
      ConText := RestStr(RestStr(Zeile));
      _aus(Attrib[20],Kanal,Star + Zeile);
      if TNC_ReadOut or TNC_K then _aus(Attrib[20],Kanal,
                            B1 + LRK + QSO_Date + B1 + QSO_Begin + RRK);
      _aus(Attrib[20],Kanal,M1);
      if Auto_CON and (show = Kanal) then _aus(Attrib[20],Kanal,M1);
    end;
    Status2;

    flagq:=quiet;
    if ((VIP_) and (VIPG)) then quiet:=false;
    Klingel:=not quiet;
                               {OR SPEEK}
    if TNC_ReadOut and (Klingel) then
    begin
      if not Auto_CON then
      begin
        if NodeCon then
        begin
          if ReKon and Klingel then
          begin
          FlagS:=False;
          if (not NodE) or ((Node) and (Konfig.NodeSound)) then
          begin
           hs:='RBELL';
          {$IFDEF Sound}
           if Konfig.WavOut and Exists(konfig.spkverz+hs+'.WAV') then
            begin
             WavStream:=WavStream+#3+EFillStr(8,B1,hs);
             FlagS:=True;
            end;

           If Konfig.MidiOut and Exists(Konfig.SpkVerz+'RBELL.MID') then Flags:=playmidi(konfig.spkverz+'RBELL.MID');
          {$ENDIF}

           if not FlagS then
            begin
             Beep(G^.C1_TON,G^.C1_TonTime);
             Verzoegern(100);
             Beep(G^.C2_Ton,G^.C2_TonTime);
            end;
            if speek then {sprachwav(call);}sprechen(call);
          end;
          end else
          if Klingel then
          if (not NodE) or ((Node) and (Konfig.NodeSound)) then
          begin
           FlagS:=False;
           hs:='WBELL';
           {$IFDEF Sound}
           if Konfig.WavOut and Exists(konfig.spkverz+hs+'.WAV') then
            begin
             WavStream:=WavStream+#3+EFillStr(8,B1,hs);
             FlagS:=True;
            end;

           If Konfig.MidiOut and Exists(Konfig.SpkVerz+'WBELL.MID') then Flag:=playmidi(konfig.spkverz+'WBELL.MID');
           {$ENDIF}

           if not FlagS then
             begin
              Beep(G^.C2_Ton,G^.C2_TonTime);
              Verzoegern(100);
              Beep(G^.C1_Ton,G^.C1_TonTime);
             end;
              if speek then {sprachwav(call);} sprechen(call);
          end;
          NodeCon := false;
        end else
        begin

          if  Klingel then
           begin
            if ((not NodE) and (not K[gegenkanal]^.node)) or ((Node) and (Konfig.NodeSound)) then C_Bell(call,kanal);
           end;
                    {or speek}
         if ((morsen) or (speek)) and (Outside) then
          if ((not NodE) and(not K[gegenkanal]^.node )) or ((Node) and (Konfig.NodeSound)) then
          begin
            ZStr := Call;
            Strip(ZStr);
            if morsen then
            begin
              Verzoegern(10 * MPause);
              Morse(Kanal,ZStr);
            end;
            if Speek then {sprachwav(call); }Sprechen(Call);
          end;
        end;
      end;
    end;
    quiet:=flagq;
    klingel:=not quiet;
    if Auto_CON then
    begin
      Outside := false;
      if ACZeile = '' then
      begin
        FoundCall := false;
        Auto_CON := false;
        if AusstiegsKanal then
        begin
          Ignore := true;
          K[GegenKanal]^.Ignore := true;
        end;
        if ((not Node) and (not K[gegenkanal]^.node)) or ((node) and (konfig.nodesound)) then C_Bell(call, kanal);

        if morsen then
        begin
          Verzoegern(10 * MPause);
          ZStr := Call;
          Strip(ZStr);
          Morse(Kanal,ZStr);
        end;
        if Speek then {sprachwav(call);} Sprechen(Call);
      end;
      if Auto_CON then
      begin
        Zstr := GetConStr(ACZeile);
        S_PAC(Kanal,NU,true,ZStr + M1);
        if not AusstiegsKanal then InfoOut(Kanal,0,1,Zstr);
      end;
    end;

  end;
  SetzeFlags(Kanal);
  UserAnwesend;

  if (k[kanal]^.user_autopw) and (not k[kanal]^.node) then
   begin
    sysop_einloggen(kanal,'');
    {K[kanal]^.user_autopw:=false;}
   end;

End;

Procedure L_Off (* Kanal : Byte *);
Var   i : Byte;
Begin
  with K[Kanal]^ do
  Begin
  BellCount:=0;
  EraseBufferFile(Kanal);
    if fwd then
     begin
      MailPolling:='';
      fwd_:=false;
      MailPrompt_:='';
      MailRXCall:='';
     end;
    fwdGo:=false;
    fwd:=false;
    reqname:=false;
    OnAct:='';
    FTxName := Konfig.SavVerz;
    FRxName := Konfig.SavVerz;
    TX_CRC:=0;
    RX_CRC:=0;
    Response := RestStr(Response);
    TNC_K := false;
    i := pos(' - ',Response);
    if i > 0 then
    Begin
      (* TNC V2.1c hat Uhrzeit gesendet *)
      TNC_K := true;
      TNC_Date := copy(Response,i+3,8);
      if TNC_Date[3] = '/' then (* amerikanisches Format *)
        TNC_Date := copy(TNC_Date,4,2) + Pkt  + copy(TNC_Date,1,2) +
                    Pkt  + copy(TNC_Date,7,2);
      TNC_Date := GetWeekDay(TNC_Date) + B1 + TNC_Date;
      TNC_Time := copy(Response,i+12,8);
      delete(Response,i,20);
    End;
    QSO_End := copy(Uhrzeit,1,5);
    if not TNC_ReadOut and TNC_K then QSO_End := copy(TNC_Time,1,5);
    if X2 > 1 then _aus(Attrib[20],Kanal,M1);
  {*****fehlerquelle}
    _aus(Attrib[20],Kanal,Star + Response);
    Kanal_benutz := false;
    if (TNC_ReadOut or TNC_K) and connected
      then _aus(Attrib[20],Kanal,B1 + LRK + QSO_Date + B1 + QSO_End + RRK);
    _aus(Attrib[20],Kanal,M2);

    if (FileSend) or (XBin.TX) then
    begin
      FiResult := CloseBin(TxFile);
      FileSend := false;
    end;

    if (RX_Save) or (XBin.RX) then
    begin
      CloseRxFile(Kanal,1);
      RX_Save := false;
      RX_Bin := 0;
      AutoBinOn := AutoBin;
    end;
    if RX_Bin > 0 then
    begin
      RX_Bin := 0;
      AutoBinOn := AutoBin;
    end;



    if connected then
    Begin
      if (SysArt in SysMenge) and not BoxScroll then CloseDBox(Kanal);
      for i := 0 to maxSCon do SCon[i] := false;
      connected := false;
      FoundCall := false;
      NodeCon := false;
      Status2;
      if TNC_ReadOut or TNC_K then
      begin
        if Klingel and TNC_ReadOut then
          if ((not node) and (not K[gegenkanal]^.node)) or ((node) and (konfig.nodesound)) then D_Bell(kanal);
        if LogArt > 0 then LogBuchEintrag(Kanal,1);
      end;
    end; (* if connected ... *)

    Close_7Plus(Kanal);
    Umlaut := UmlautMerk;
    Outside := true;
    Auto_CON := false;
    ACZeile := '';
    ACMerk := '';
    FoundCall := false;
    Hold := false;
    RemAll := false;
    Fwd  := false;
    {FwdStarted:=false;}
    SelfSysop:=False;
    MsgToMe := false;
    TxComp := false;
    RxComp := false;
    spcomp:=false;
    CompC  :=false;
    STOPComp:=false;
    KompressUpd:=false;
    for i:=1 to 255 do
     begin
      Kompression[i]:=0;
     end;
    DBoxScaned := false;
    DieBoxPW := '';
    SysopParm := false;
    RTF := false;
    Upload := false;
    use_RomLw := false;
    RemPath := G^.Drive;
    TNC_Puffer := false;
    {EraseBufferFile(Kanal);}
    if Conv.Active then ConversIni(Kanal,false);;
{    Ignore := false;}
    SendZeile := '';
    NodeTimeOut := NTimeOut * 60;
    MeldeCompZ := '';
    MeldeZeile := '';
    ExtMld := '';
    ExtMldFlag := false;
    K[Kopieren]^.KopierenFm:=0;
    KopierenFm:=0;
    Kopieren := 0;
    SysArt := 0;
    UserArt := 0;
    {Comp_Key [Kanal] := false;}
    SystemErkannt:='';
    QSOZeilen:=0;
    FileSendWait := false;
    AutoBinOn := AutoBin;
    for i := 1 to maxLink do if K[i]^.Kopieren = Kanal then K[i]^.Kopieren := 0;
    Auto_Init(Kanal);
    xbin.an:=false;
    xbin.rx:=false;
    xbin.tx:=false;
    xbin.frameNr:=0;
    xbin.ok:=false;
    xbin.retries:=0;
    xbin.eof:=false;
    SetzeFlags(Kanal);
    BoxZaehl:=Box_Time;
    if xbin.pdat then CloseXBinProt(Kanal);

  End; (* WITH K[Kanal] ... *)
  _OnAct:=false;
  for i:=1 to maxlink do
  if K[i]^.OnAct<>'' then _OnAct:=true;
  Rufz_TNC_init(Kanal);
  UserAnwesend;
End; {L_Off}

Procedure LogBuchEintrag (* Kanal,Art : Byte *);
var    i      : Byte;
       Ch     : Char;
       Result : Integer;
Begin
  with K[Kanal]^ do
  begin
    if QSO_Date > '' then
    begin
      if Art = 0 then QSO_End := copy(Uhrzeit,1,5);
      Assign(G^.TFile,Sys1Pfad + LogDatei + LngExt);
      Result := AppendTxt(G^.TFile);
      if Result = 0 then
      begin
        i := pos(' via ',ConText);
        if i > 0 then
        begin
          delete(ConText,i+2,2);
          if length(ConText) > 50 then ConText := copy(ConText,1,50);
        end;
        if outside then Ch := S_ch
                   else Ch := B1;
        if not BeLogEintr then LogMerker := User_Name;
        Writeln(G^.TFile,QSO_Date,B2,QSO_Begin,'-',QSO_End,B2,
                         SFillStr(9,B1,TNC[TncNummer]^.QRG_Akt),B1,
                         SFillStr(2,B1,int_str(Kanal)),
                         Ch,B2,Call,ConstStr(B1,9-length(Call)),B2,
                         LogMerker,ConstStr(B1,20-length(LogMerker)),B2,
                         OwnCall,ConstStr(B1,9-length(OwnCall)),' > ',ConText);
        FiResult := CloseTxt(G^.TFile);

        if Art = 1 then
        begin
          LogMerker := '';
          BeLogEintr := false;
        end;
      end else InfoOut(Kanal,0,1,InfoZeile(45) + B1 + Int_Str(Result) + B1);
    end;
  end;
End;

Procedure Line_ON (* Kanal : Byte *);
Var  Bstr : String[80];
     Hstr : String[9];
     sec1, sec2 : string[9];
     i,ULogin:byte;
Begin
  with K[Kanal]^ do
  begin
    if AusstiegsKanal and not FoundCall then
    begin
      K[GegenKanal]^.RemConReady := true;
      Ignore := true;
      K[GegenKanal]^.Ignore := true;
      S_PAC(GegenKanal,NU,true,M1 + ConStr + Call + M1);
    end;

    inc(CNr);
    _aus(Attrib[20],Kanal,InfoZeile(223) + B1+ int_str(CNr) + M1);

    if (Konfig.CBFilter) and (not TNC[TncNummer]^.AfuPort) then
     begin
      if not (CBCallCheck(Call)) then
       begin
        S_PAC(Kanal,NU,true,InfoZeile(441) + M1);
        S_PAC(Kanal,CM,true,'D');

        _aus(Attrib[20],Kanal,InfoZeile(441) + M1);
        exit;
       end;
     end;

    if Outside and TNC_ReadOut then
    begin (* Conn. "von aussen" *)
     if Node then
     begin
     ulogin:=0;
      sec2:=Call; strip(sec2);
      for i:=1 to maxlink do
       begin
        sec1:=K[i]^.Call; strip(Sec1);
        if (K[i]^.Node) and (K[i]^.connected) and (sec1=Sec2) then inc(ULogin);
       end;
       if ulogin>Konfig.MaxLoginUser then
        begin
         S_PAC(Kanal,NU,true,InfoZeile(440) + M1);
         S_PAC(Kanal,CM,true,'D');
         exit;
        end;
     end;
      if Call_Exist(Kanal,3,'') then
      begin
        S_PAC(Kanal,NU,true,InfoZeile(116) + M1);
        S_PAC(Kanal,CM,true,'D');
        exit;
      end else
      if NOT Call_Exist(Kanal,5,'') then
      begin
        S_PAC(Kanal,NU,true,InfoZeile(433) + M1);
        S_PAC(Kanal,CM,true,'D');
        exit;
      end;

      if not AusstiegsKanal then
      begin
        TXT_Senden(Kanal,6,0);
        if not GrtFlag then TXT_Senden(Kanal,3,0);
        Hstr := Call;
        Strip(Hstr);
        if TopBox and (Exists(Konfig.MailVerz + Hstr + MsgExt)) then
        begin
          S_PAC(Kanal,NU,false,^G+M1+InfoZeile(110)+M2+InfoZeile(111)+M2);
          Send_Prompt(Kanal,FF);
        end;
        S_PAC(Kanal,NU,true,'');
      end;
    end; (* Outside *)
  end;
End;


Procedure FreiKanalSuch (* Kanal : Byte; Zeile : Str80 *);
var   i     : Integer;
      found : Boolean;
      Hstr  : String[80];
      Cross : Byte;

begin
 Gate:=0;
  found := false;
  KillEndBlanks(Zeile);
  Hstr := Zeile;
  While pos(B1,Hstr) > 0 do Hstr := RestStr(Hstr);
  if str_int(Hstr) > 0 then Gate := str_int(Hstr);
  if (str_int(Zeile[1]) > 0) and (Zeile[2]=B1) then Gate := str_int(Zeile[1]);

  if Gate=0 then
  begin
    Zeile := CutStr(Zeile);
    if LinkExists(Zeile,Cross) then
    begin
      Gate := Cross;
      found := true;
    end else Gate := K[Kanal]^.TncNummer;
  end;

  i := maxLink;
  Repeat
    if (not K[i]^.Test) and (not K[i]^.connected) and (K[i]^.TncNummer = Gate) and
       (not K[i]^.Kanal_benutz) and (not K[i]^.Mo.MonActive) then FreiKanal := i;
    dec(i);
  Until (FreiKanal > 0) or (i < 1);
  if Gate > Tnc_Anzahl then FreiKanal := FF else

  {wenn Gate AFU contra CB l„uft, mit kanal 253 abs„gen!}


   if (FreiKanal > 0) and Call_Exist(Kanal,4,CutStr(Zeile)) then FreiKanal := 254;
{  s_pac(kanal,nu,false,'Gate:'+int_str(gatE)+'   Eing:':int_str(K[kanal]^.TncNummer));
  if TNC[K[kanal]^.TncNummer]^.AfuPort then s_pac(kanal,nu,false,' AFU ');
  s_pac(kanal,nu,false,'   Out:':int_str(K[kanal]^.TncNummerGate));
  if TNC[K[kanal]^.TncNummer]^.AfuPort then s_pac(kanal,nu,false,' AFU ');
 }
  if FreiKanal in [1..maxLink] then
  if TNC[K[kanal]^.TncNummer]^.AfuPort<>TNC[gate]^.AfuPort then
   begin
    freikanal:=253;
   end;
  K[FreiKanal]^.FoundCall := found;
  Gate := 0;
end;

Procedure Remote_Connect_Aufbauen (* Kanal : Byte; Zeile : Str80 *);
var i       : Integer;
    Xstr    : String[9];
    ok      : Boolean;
    i1      : Byte;
    AutoCon : Boolean;
    SSID_org:byte;
    SSID_neu:byte;

begin
  KillEndBlanks(Zeile);
  i := length(Zeile);
  AutoCon := (K[K[Kanal]^.GegenKanal]^.FoundCall and
             (K[Kanal]^.GegenKanal > 0));

  if (i > 1) and (Zeile[i-1] = B1) then
  begin
    if str_int(Zeile[i]) in [1..Tnc_Anzahl] then delete(Zeile,i-1,2);
    KillEndBlanks(Zeile);
  end;

  if (i > 1) and (Zeile[2] = B1) then
  begin
    if str_int(Zeile[1]) in [1..Tnc_Anzahl] then delete(Zeile,1,2);
    KillEndBlanks(Zeile);
  end;

  if AutoCon then NeuCall := CutStr(Zeile)
             else NeuCall := Zeile;

{ ALTE SSID-PROZEDUR}
  Xstr := RemoteCall;
{  Strip(RemoteCall);
  RemoteCall := RemoteCall + '-' + int_str(15 - str_int(ParmStr(2,'-',xstr)));}
{****}
  SSID_org:=str_int(ParmStr(2,'-',xstr));
  SSID_neu:=15-SSID_org;
  if SSID_neu=0 then SSID_neu:=9;

  Strip(RemoteCall);
  RemoteCall := RemoteCall + '-' + int_str(SSID_neu);

{****}
  K[FreiKanal]^.Kanal_benutz := true;
  S_PAC(FreiKanal,CM,true,'I '+ RemoteCall);
  with K[FreiKanal]^ do if FoundCall then
  begin
    GetMem(Lnk,SizeOf(Lnk^));
    Lnk_Init(TncNummer,TNC[TncNummer]^.QRG_Akt);
    ACZeile := GetConPfad(NeuCall);
    FreeMem(Lnk,SizeOf(Lnk^));
    Auto_CON := true;
    Zeile := GetConStr(ACZeile);
    Connect(FreiKanal,Zeile);
  end else
  begin
    K[FreiKanal]^.Outside := false;
    Connect(FreiKanal,'C' + B1 + NeuCall);
  end;
  S_PAC(Kanal,NU,true,Star + InfoZeile(138) + int_str(FreiKanal) +
      B2 + InfoZeile(139) + int_str(K[FreiKanal]^.TncNummer) +
      ' ('+Konfig.TNC[K[freikanal]^.TNCNummer].PortNam+')' + m1 );
end;

Procedure RemConInit; (* Kanal : Byte; *)
Begin
  with K[Kanal]^ do
  begin
    with K[GegenKanal]^ do
    begin
      EinstiegsKanal := false;
      AusstiegsKanal := false;
      RemConReady := false;
      Ignore := false;
      SetzeFlags(GegenKanal);
      GegenKanal := 0;
    end;

    EinstiegsKanal := false;
    AusstiegsKanal := false;
    RemConReady := false;
    Ignore := false;
    GegenKanal := 0;

    SetzeFlags(Kanal);
  end;
End;


(* Das Unproto-Rufzeichen in der Statuszeile darstellen *)
(* Wurde ge„ndert, weil ein zu langes Unproto den Rest der Statuszeile
   berschrieben hat - elegantere L”sung de DJ0HC *)

Procedure Unproto_darstellen;
var  i    : Integer;
     Hstr : String[19];
Begin
  K[0]^.TncNummer := Unproto;
  Ausgabe := false;
  S_PAC(0,CM,true,'C');
  i := pos('via',K[0]^.Response);
  if i > 0 then Hstr := copy(K[0]^.Response,1,i-1) else
                Hstr := K[0]^.Response;
  Hstr := Channel_ID(0) + Hstr;
  StatusOut(0,2,1,Attrib[9],EFillStr(19,B1,Hstr),1);
End;

Procedure Terminal_Kanal (* Kanal : Byte; Anz : ShortInt *);
Begin
  case Anz of
     1 : if Kanal < maxLink then SwitchChannel(Kanal+1) else Alarm;
    -1 : if Kanal > 0 then SwitchChannel(Kanal-1) else Alarm;
    10 : if Kanal > 0 then
         begin
           if (Kanal+10) <= maxLink then SwitchChannel(Kanal+10) else Alarm;
         end else
         begin
           if multiTNC then
           begin
             inc(Unproto);
             if Unproto > TNC_Anzahl then unproto := 1;
             Unproto_darstellen;
             Neu_Bild;
           end else Alarm;
         end;
   -10 : if Kanal > 0 then
         begin
           if (Kanal-10) > 0 then SwitchChannel(Kanal-10) else Alarm;
         end else
         begin
           if multiTNC then
           begin
             dec(Unproto);
             if Unproto < 1 then unproto := TNC_Anzahl;
             Unproto_darstellen;
             Neu_Bild;
           end else Alarm;
         end;
  end;
End;

Procedure Trennzeilen (* Kanal : Byte; KC : SonderTaste *);
var   i,i1,
      Art  : Byte;
      Flag : Boolean;
Begin
  with K[Kanal]^ do
  begin
    Flag := RX_TX_Win;
    if Flag then Change_WIN;

    case KC of
      _ShHome : if Flag and (Kanal > 0) then Art := 2 else Art := 1;
      _ShEnd  : if Flag and (Kanal > 0) then Art := 1 else Art := 2;
      _ShPgUp : Art := 3;
      _ShPgDn : Art := 4;
          else  Art := 0;
    end;

    case Art of
     1 : if ((Kanal > 0) and (ObStat > 3)) or
            ((Kanal = 0) and (ObStat > (TicAnz + 3))) then
         begin               (* obere TrennZeile nach oben *)
           if Kanal = 0 then i1 := TicAnz else i1 := 0;
           dec(ObStat);
           if Y1C + i1 >= ObStat then if Y1C > 1 then dec(Y1C) else inc(stC);
           if Y1V + i1 >= ObStat then if Y1V > 1 then dec(Y1V) else inc(stV);
         end else Alarm;

     2 : if (ObStat <= VorZeilen - VorCmdZeilen) and
             ((ObStat+5 < UnStat) or (Kanal = 0) and (ObStat+4 < maxZ)) then
         begin       (* obere TrennZeile nach unten *)
           inc(ObStat);
           if stC - VorZeilen + VorCmdZeilen - Y1C > 0
            then if Y1C < VorCmdZeilen then inc(Y1C);
           if stV-Y1V > 0 then inc(Y1V);
         end else Alarm;

     3 : if Kanal > 0 then    (* untere TrennZeile nach oben *)
         begin
           if UnStat > ObStat + 5 then
           begin
             dec(UnStat);
             if UnStat = maxZ-1 then UnStat := maxZ-2;
           end else Alarm;
         end else Alarm;

     4 : if Kanal > 0 then    (* untere TrennZeile nach unten *)
         begin
           if UnStat < maxZ then
           Begin
             inc(UnStat);
             if UnStat = maxZ-1 then UnStat := maxZ;
           End else Alarm;
         end else Alarm;

    end;

    if GlobalTrenn and (Kanal > 0) then
    begin
      K[0]^.ObStat := ObStat;
      for i := 1 to maxLink do
      begin
        K[i]^.ObStat := ObStat;
        K[i]^.UnStat := UnStat;
      end;
    end;

    Fenster_Berechnen;
    if Flag then Change_WIN;
    Neu_Bild;
  end;
End;

Procedure Fenster_Berechnen;
Var   i : Byte;
Begin
  for i := 0 to maxLink do with K[i]^ do
  begin
    if i > 0 then
    begin
      if RX_TX_Win then
      begin
        VBeg := ObStat + 3; {+2}
        VEnd := UnStat - 1;
        QBeg := 1;
        QEnd := ObStat - 1;
      end else
      begin
        VBeg := 1;
        VEnd := ObStat - 1;
        QBeg := ObStat + 3; {+2}
        QEnd := UnStat - 1;
      end;
    end else
    begin
      if ObStat <= (TicAnz + 2) then
      begin
        ObStat := TicAnz + 4;   {+3}
        UnStat := ObStat + 3;   {+2}
      end;
      VBeg := TicAnz + 1;
      VEnd := ObStat - 1;
      UnStat := ObStat + 3;    {+2}
      QBeg := 0;
      QEnd := 0;
    end;
    Vofs := VBeg - 1;
  end;
End;

Procedure Change_WIN;
Var  i,zv,zq : Byte;
Begin
  for i := 1 to maxLink do with K[i]^ do
  begin
   {unStat}
    zv := VEnd - VBeg;
    zq := QEnd - QBeg - 2;
    if RX_TX_Win then
    begin
     {vorschreib nach oben, qso nach unten}
      VBeg := 1;
      VEnd := VBeg + zv;
      ObStat := VEnd + 1;
      QBeg := ObStat + 3; {+2}
      QEnd := UnStat - 1;
    { VBeg := 1;
      VEnd := VBeg + zv -1 ;
      ObStat := VEnd + 1;
      QBeg := ObStat + 3; +2
      QEnd := QBeg + zq - 1;}
    end else
    begin
      {vorschreib nac unten, qso nach oben}
      QBeg := 1;
      QEnd := QBeg + zq +2;
      ObStat := QEnd + 1;
      VBeg := ObStat + 3;  {+1}
      VEnd := UnStat-1;
    { QBeg := 1;
      QEnd := QBeg + zq - 1;
      ObStat := QEnd + 1;
      VBeg := ObStat + 2;  +1
      VEnd := VBeg + zv;}
    end;
    Vofs := VBeg-1;
  end;
  RX_TX_Win := not RX_TX_Win;
End;


Procedure ClearVorBuffer (* Kanal : Byte *);
var   i : Byte;
Begin
  with K[Kanal]^ do
  begin
    if Vor_im_EMS then EMS_Seite_Einblenden(Kanal,Vor);
    if cmd then
      for i := VorZeilen-VorCmdZeilen+1 to VorZeilen do
               VorWrite[Kanal]^[i][0] := Chr(2)
    else for i := 1 to VorZeilen-VorCmdZeilen do VorWrite[Kanal]^[i] := '';
    Chr_Darstell(Kanal,_CtrlPgUp,#255);
  end;
End;

Procedure ClearScrBuffer (* Kanal : Byte *);
var     Result : Word;
Begin
  with K[Kanal]^ do
  begin
    GetMem(Page,maxNotCh);
    FillChar(Page^,maxNotCh,0);
    if use_Vdisk then
    begin
      FiResult := ResetBin(ScrollFile,T);
      Seek(ScrollFile,Pos_im_Scr);
      BlockWrite(ScrollFile,Page^[0],maxNotCh,Result);
      FiResult := CloseBin(ScrollFile);
    end else if use_XMS then
    begin
      Data_to_XMS(@Page^[0],XMS_Handle,Pos_im_Scr,maxNotCh);
    end else if use_EMS then
    begin
      EMS_Seite_einblenden(Kanal,Scr);
      move(Page^,NotCh[Kanal]^,maxNotCh);
    end else move(Page^,NotCh[Kanal]^,maxNotCh);
    FreeMem(Page,maxNotCh);
    X2 := 1;
    NotPos := 0;
    NZeile := '';
    RxLRet := true;
    Neu_Bild;
  end;
End;

(*Function GetWeekDay ( * Dstr : Str8) : Str2 * );
var   Tag,Monat,Jahr,
      i,x,y,z,Fehler  : Integer;
Begin
  val(copy(Dstr,1,2),Tag,Fehler);
  if Fehler = 0 then val(copy(Dstr,4,2),Monat,Fehler);
  if Fehler = 0 then val(copy(Dstr,7,2),Jahr,Fehler);
  if Fehler = 0 then
  begin
    Jahr := Jahr + 2000;
    if Monat > 2 then Monat := Monat - 2 else
    begin
      Monat := Monat + 10;
      Jahr := Jahr - 1;
    end;
    x := Jahr mod 100;
    z := Jahr div 100;
    y := (13 * Monat - 1) div 5 + x div 4 + z div 4;
    i := (x + y + Tag - 2 * z) mod 7;
    if (i >= 0) and (i <= 6)
      then GetWeekDay := copy(ParmStr(i+1,B1,WeekDayStr),1,2)
      else GetWeekDay := 'xx';
  end else GetWeekDay := 'xx';
End;
*)

Function GetWeekDay (* Dstr : Str8) : Str2 *);
var   Tag,Monat,Jahr,
      i,x,y,z,Fehler  : Integer;
      hStr            : String[3];
Begin
  val(copy(Dstr,1,2),Tag,Fehler);
  if Fehler = 0 then val(copy(Dstr,4,2),Monat,Fehler);
  if Fehler = 0 then val(copy(Dstr,7,2),Jahr,Fehler);
  if Fehler = 0 then
  begin
    Jahr := Jahr + 2000;
    if (Monat <= 2) then begin
      dec(Jahr);
      Monat := Monat + 12;
    end;
    x := trunc(365.25*Jahr) + trunc(30.6001*(Monat+1)) + trunc(Jahr/400);
    y := x - trunc(Jahr/100) - 712286 + Tag;
    i := y mod 7;
    if ((i>=0) AND (i<7)) then
      GetWeekDay := copy(ParmStr(i+1,B1,WeekDayStr),1,2)
    else GetWeekDay := 'xx';
  end else GetWeekDay := 'NU';
End;


Procedure Compress_Ein_Aus (* Kanal : Byte *);
var i:byte;
Begin

  with K[Kanal]^ do
  begin
   spcomp:=False;
    if ( (MldOk = 19) or (MldOk = 26) ) and (not RxComp) then
    begin
      RxComp := true;
      if (not TxComp) and (MldOk = 19) then
       begin
        S_PAC(Kanal,NU,true,M1 + Meldung[21] + M1);
        if StopCode>0 then StopComp:=true;
       end;
      if (not TxComp) and (MldOk = 26) then
       begin
        if mo.Monactive then
         begin
          S_PAC(Kanal,NU,true,M1 + Meldung[27] + M1);
          CompC := true;
          KompressUpd:=true;
          CompCUpdZahl:=0;
          TXComp:=true
         end else
          begin
           s_pac(kanal, CM, true, 'D');
           rxcomp:=false;
          end;
        end;
       if (mldok=19) and (not TXComp) then TXComp:=true;

    end else if ((MldOk = 20) and RxComp) or ((MldOk=20) and CompC and (TxComp)) then
    begin
      if TxComp then S_PAC(Kanal,NU,true,M1 + Meldung[22] + M1);
      RxComp := false;
      TxComp := false;
      for i:=1 to 255 do
       begin
        Kompression[i]:=0;
       end;

      CompC:=false;
      KompressUpd:=false;
      {Comp_Key[Kanal]:=false;}
      MeldeZeile := '';
    end else if ( (MldOk = 21) or (MldOk = 27) ) and not RxComp then
    begin
      RxComp := true;
      if (not Mo.MonActive) and (MldOk = 27) then s_pac(kanal, CM, true, 'D');
      {if MldOk=27 then Comp_Key[Kanal] := true;}
    end else if (MldOk = 22) and RxComp then
    begin
      for i:=1 to 255 do
       begin
        Kompression[i]:=0;
       end;
      CompC:=false;
      KompressUpd:=false;
      RxComp := false;
      {Comp_Key[Kanal]:=false;}
      TxComp := false;
      MeldeZeile := '';
    end;

    if RxComp then
    begin
      CompZeile := '';
      MeldeCompZ := '';
    end;

    if TxComp then
    begin
      if PacLen > maxCompPac then PacLen := maxCompPac;
    end;

    SetzeFlags(Kanal);
  end;
End;


Procedure CompressMenu (* Kanal : Byte *);
Const  ArtMax = 8;
Var    i    : Byte;
       KC   : Sondertaste;
       VC   : Char;
       AFlag,
       Flag : Boolean;
       X,Y,
       Art  : Byte;
       stopline:string;
       hstr: string[6];

Begin
  with K[Kanal]^ do
  begin
    if (SysArt=0) and (UserArt=2) then SPComp:=true;
    Moni_Off(0);;
    Flag := false;
    AFlag := false;
    for i := 9 to 17 do G^.Fstx[i] := 20;
    G^.Fstr[7] := InfoZeile(340);
    G^.Fstr[10] := InfoZeile(341);
    G^.Fstr[11] := InfoZeile(342);
    G^.Fstr[12] := InfoZeile(343);
    G^.Fstr[13] := InfoZeile(344);
    G^.Fstr[14] := InfoZeile(345);
    stopline:=infoZeile(348);

    if Mo.MonActive then begin
     G^.Fstr[15] := InfoZeile(346);
     g^.fstr[16] := InfoZeile(347);
     g^.fstr[17] := stopLine+' Code: '+int_str(StopCode);
    end
     else
      begin
       g^.fstr[15]:=infozeile(347);
       g^.fstr[16] := stopLine+' Code: '+int_str(StopCode);
      end;


    if not (TxComp or RxComp) then Art := 1 else
     if TxComp and RxComp then Art := 2 else
      if TxComp then Art := 3 else
       if RxComp then Art := 4
                 else Art := 1;
    if ((not RXComp) and (not TXComp)) and (stopcode>0) then StopComp:=true;
    Repeat
      for i := 10 to 17 do
      begin
        G^.Fstr[i][vM+1] := B1;
        G^.Fstr[i][vM] := B1;
      end;

      X:=vm; Y:=Art+9;
      if (not mo.monActive) and (art in [7,8]) then y:=y-1;

      G^.Fstr[Y][X] := A_ch;

      if HardCur then SetzeCursor(X+1,Y);

      if TxComp then G^.Fstr[12][vM+1] := X_ch;
      if RxComp then G^.Fstr[13][vM+1] := X_ch;
{*}   If CompC then G^.Fstr[15][vm+1] := X_ch;
      if SPComp then
       begin
        if Mo.MonActive then G^.Fstr[16][vm+1] := X_ch
          else G^.Fstr[15][vm+1] := X_ch;
       end;
      If StopComp then
       begin
        {G^.Fstr[17][vm+1] := X_ch;}
        if Mo.MonActive then G^.Fstr[17][vm+1] := X_ch
          else G^.Fstr[16][vm+1] := X_ch;
       end;
{*}  { G^.FSTR[15]:='';}
      G^.Fstr[9] := '';
      Fenster(17);

      _ReadKey(KC,VC);
      Case KC of
       _AltH : XP_Help(G^.OHelp[25]);
        _Esc : Flag := true;

        _Ret : ;

         _F1 : Art := 1;
         _F2 : Art := 2;
         _F3 : Art := 3;
         _F4 : Art := 4;
         _F5 : Art := 5;
{*}      _F6 : if not mo.Monactive then
                begin
                 ALARM;
                 KC:=_F10;
                 Art:=1;
                end else Art:=6;
{*}      _F7: Art:=7;
         _F8 :Art:=8;
         _F9,
        _F10 : Alarm;

         _Up,_Left : begin
                       if Art > 1  then dec(Art)
                           else Art:=ArtMax;
                       if (not Mo.MonActive) and (Art=6) then art:=5;
                     end;

         _Dn, _Right : if Art < ArtMax then inc(Art)
                               else Art:=1;

{      _Right : if Art < ArtMax  then
               begin
                 Art := Art + 4;
                 if Art > ArtMax then Art := ArtMax;
               end else Alarm;

       _Left : if Art > 1 then
               begin
                 if Art <= 4 then Art := 1
                             else Art := Art - 4;
               end else Alarm;                   }

     _Andere :;

         else Alarm;
      End;

      if (art=6) and (not Mo.MonActive) then art:=7;

      if (KC in [_F1.._F8,_Ret]) or (VC = B1) then
      case Art of
        1 : if not (TxComp or RxComp) then
            begin
              if (Kanal > 0) and (CompC) and (not SPComp) then
               begin
                S_PAC(Kanal,NU,true,M1 + Meldung[26] + M1);
                KompressUpd:=true;
                CompCUpdZahl:=0;
                FileSendWaitS:=fileSendWait;
                FileSendWait:=true;
               end;


              if (Kanal > 0) and (not COMPC) and (not SPComp) then S_PAC(Kanal,NU,true,M1 + Meldung[19] + M1);
              if (Kanal > 0) and (not COMPC) and (SPComp) then S_PAC(Kanal,NU,true,M1 + Meldung[37] + M1);
              TxComp := true;
              Flag := true;
            end;
        2 : if TxComp and RxComp then
            begin
              if (Kanal > 0) and (not SPComp) then S_PAC(Kanal,NU,true,M1 + Meldung[20] + M1);
              if (Kanal > 0) and (SPComp) then S_PAC(Kanal,NU,true,M1 + Meldung[38] + M1);
              TxComp := false;
              KompressUpd:=false;
              Flag := true;
            end;
        3 : TxComp := not TxComp;
        4 : begin
              RxComp := not RxComp;
              AFlag := true;
            end;
        5 : if TxComp and (Kanal > 0) then
            begin
              TxComp := false;
              S_PAC(Kanal,NU,true,M1 + Meldung[23] + M1);
              TxComp := true;
              Flag := true;
            end else Alarm;
        6 : begin
             CompC:=not CompC;
             if compc then spcomp:=false;
             {If Comp_Key[Kanal] then Comp_Key[Kanal] := false
                else Comp_Key[Kanal] := true;}
            end;
        7 : begin
             SPComp:=not SPComp;
             if spcomp then compc:=false;
            end;
        8 : begin
             StopComp:=not StopComp;
             if (StopComp) and ((Mo.MonActive) or (Kanal=0))then
              begin
               hstr:=int_str(StopCode);
               GetString(hstr,Attrib[3],5,8,17,KC,1,Ins);
               StopCode:=str_int(hstr);
               if Mo.MonActive then g^.fstr[17] := stopLine+' Code: '+int_str(StopCode)
                 else g^.fstr[16] := stopLine+' Code: '+int_str(StopCode);

              end;
            end;
      end;


      SetzeFlags(Kanal);
    Until Flag;

    if AFlag then
    begin
      CompZeile := '';
      MeldeCompZ := '';
    end;
    if TxComp and (PacLen > maxCompPac) then PacLen := maxCompPac;
    ClrFenster;
    Neu_Bild;
    Moni_On;
    if (not TXComp) and (not RxComp) then
     begin
      CompC := False;
      SPComp:=false;
      STOPComp:=False;
     end;
  end;
End;


Procedure Morse_Menue (* Kanal : Byte *);
Const  ArtMax = 6;
Var    i    : Byte;
       KC   : Sondertaste;
       VC   : Char;
       Flag : Boolean;
       X,Y,
       Art  : Byte;
       w    : Word;
       Hstr : String[70];


Begin
  with K[Kanal]^ do
  begin
    Moni_Off(0);;
    Flag := false;
    for i := 9 to 15 do G^.Fstx[i] := 20;
    G^.Fstr[7] := InfoZeile(418);

    G^.Fstr[9] := InfoZeile(419);
    G^.Fstr[10] := InfoZeile(420);
    G^.Fstr[11] := InfoZeile(421);
    G^.Fstr[12] := InfoZeile(422);
    G^.Fstr[13] := InfoZeile(423);
    G^.Fstr[14] := InfoZeile(424);

    Art := 1;

    Repeat
      for i := 9 to 14 do
      begin
        G^.Fstr[i][vM+1] := B1;
     {   G^.Fstr[i][hM+1] := B1; }
        G^.Fstr[i][vM] := B1;
     {   G^.Fstr[i][hM] := B1;  }
      end;

      if Art in [1..6] then
      begin
        X := vM;
        Y := Art + 8;
      end else
      begin
        X := hM;
        Y := Art + 3;
      end;
      G^.Fstr[Y][X] := A_ch;

      if HardCur then SetzeCursor(X+1,Y);

      if morsen then G^.Fstr[9][vM+1] := X_ch;
      if ConMorsen then G^.Fstr[10][vM+1] := X_ch;
      if ReconMorsen then G^.Fstr[11][vM+1] := X_ch;

      G^.Fstr[15] := '';
      Fenster(15);

      _ReadKey(KC,VC);
      Case KC of
        _Esc : Flag := true;

       _AltH : XP_Help(G^.OHelp[4]);

        _Ret : ;

         _F1 : Art := 1;
         _F2 : Art := 2;
         _F3 : Art := 3;
         _F4 : Art := 4;
         _F5 : Art := 5;
         _F6 : Art := 6;
         _F7,
         _F8,
         _F9,
        _F10 : Alarm;

         _Up : if Art > 1  then dec(Art)
                           else Alarm;

         _Dn : if Art < ArtMax then inc(Art)
                               else Alarm;

      _Right : if Art < ArtMax then
               begin
                 Art := Art + 5;
                 if Art > ArtMax then Art := ArtMax;
               end else Alarm;

       _Left : if Art > 1 then
               begin
                 if Art <= 5 then Art := 1
                             else Art := Art - 5;
               end else Alarm;

     _Andere : case VC of
                 B1:;
                 else Alarm;
               end;
         else Alarm;
      End;

      if (KC in [_F1.._F6,_Ret]) or ((KC = _Andere) and (VC = B1)) then
      case Art of
        1 : begin
              morsen := not morsen;
            end;
        2 : begin
              ConMorsen := not ConMorsen;
            end;
        3 : begin
              ReconMorsen := not ReconMorsen;
            end;
        4 : begin
              G^.Fstr[12][vM] := S_ch;
              Fenster(15);
              w := Word(6000 div MPause);
              Hstr := int_str(w);
              GetString(Hstr,Attrib[3],3,2,15,KC,0,Ins);
              if KC <> _Esc then
              begin
                w := Word(str_int(Hstr));
                if (w > 29) and (w < 300) then
                begin
                  MPause := Word(6000 div w);
                  Morse(Kanal,OwnCall);
                end else Alarm;
              end;
            end;
        5 : begin
              G^.Fstr[13][vM] := S_ch;
              Fenster(15);
              Hstr := int_str(G^.TonHoehe);
              GetString(Hstr,Attrib[3],5,2,15,KC,0,Ins);
              if KC <> _Esc then
              begin
                w := Word(str_int(Hstr));
                if w > 99 then
                begin
                  G^.TonHoehe := w;
                  Morse(Kanal,OwnCall);
                end else Alarm;
              end;
            end;
        6 : begin
              G^.Fstr[9][hM] := S_ch;
              Fenster(15);
              Hstr := '';
              GetString(Hstr,Attrib[3],70,2,15,KC,0,Ins);
              if KC <> _Esc then Morse(Kanal,Hstr);
            end;
      end;

    Until Flag;

    ClrFenster;
    Neu_Bild;
    Moni_On;
  end;
End;


Procedure Voice_Menue (* Kanal : Byte *);
Const  ArtMax = 5;
Var    i    : Byte;
       KC   : Sondertaste;
       VC   : Char;
       Flag : Boolean;
       X,Y,
       Art  : Byte;
       w    : Word;
       Hstr : String[70];


Begin
{  with K[Kanal]^ do
  begin
    Moni_Off(0);;
    Flag := false;
    for i := 9 to 15 do G^.Fstx[i] := 2;
    G^.Fstr[7] := InfoZeile(352);

    G^.Fstr[9] := InfoZeile(353);
    G^.Fstr[10] := InfoZeile(354);
    G^.Fstr[11] := InfoZeile(355);
    G^.Fstr[12] := InfoZeile(356);
    G^.Fstr[13] := InfoZeile(357);

    Art := 1;

    Repeat
      for i := 9 to 13 do
      begin
        G^.Fstr[i][vM+1] := B1;
        G^.Fstr[i][hM+1] := B1;
        G^.Fstr[i][vM] := B1;
        G^.Fstr[i][hM] := B1;
      end;

      X := vM;
      Y := Art + 8;

      G^.Fstr[Y][X] := A_ch;

      if HardCur then SetzeCursor(X+1,Y);

      if Speek then G^.Fstr[9][vM+1] := X_ch;
      if ConVoice then G^.Fstr[10][vM+1] := X_ch;
      if ReconVoice then G^.Fstr[11][vM+1] := X_ch;

      G^.Fstr[14] := '';
      G^.Fstr[15] := '';
      Fenster;

      _ReadKey(KC,VC);
      Case KC of
        _Esc : Flag := true;

       _AltH : XP_Help(G^.OHelp[2]);

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


     _Andere : case VC of
                 B1:;
                 else Alarm;
               end;
         else Alarm;
      End;

      if (KC in [_F1.._F5,_Ret]) or ((KC = _Andere) and (VC = B1)) then
      case Art of
        1 : begin
              Speek := not Speek;
            end;
        2 : begin
              ConVoice := not ConVoice;
            end;
        3 : begin
              ReconVoice := not ReconVoice;
            end;
        4 : begin
              G^.Fstr[12][vM] := S_ch;
              Fenster;
              Hstr := int_str(VSpeed);
              GetString(Hstr,Attrib[3],3,2,15,KC,0,Ins);
              if KC <> _Esc then
              begin
                w := Word(str_int(Hstr));
                if (w > 1) and (w < FFFF) then
                begin
                  VSpeed := w;
                  Sprechen(OwnCall);
                end else Alarm;
              end;
            end;
        5 : begin
              G^.Fstr[13][vM] := S_ch;
              Fenster;
              Hstr := '';
              GetString(Hstr,Attrib[3],70,2,15,KC,0,Ins);
              if KC <> _Esc then Sprechen(Hstr);
            end;
      end;

    Until Flag;

    ClrFenster;
    Neu_Bild;
    Moni_On;
  end; }
End;

Procedure Text_Einstellung (* Kanal : Byte *);
Const  ArtMax = 5;
Var    i,j,h : Byte;
       KC    : Sondertaste;
       VC    : Char;
       IFlag,
       Flag  : Boolean;
       X,Y,
       Art   : Byte;
       Hstr  : String[3];
       Zeile : string;

Begin
  with K[Kanal]^ do
  begin
    Moni_Off(0);;
    Flag := false;
    IFlag := false;
    for i := 9 to 15 do G^.Fstx[i] := 30;

    G^.Fstr[7] := InfoZeile(349);

    Art := 1;

    Repeat
     y:=Art+9;
     x:=vm;

      if HardCur then SetzeCursor(X+1,Y);

      G^.Fstr[10]  := InfoZeile(350)+ B1 + int_str(TNC[TncNummer]^.CText);
      G^.Fstr[11] := InfoZeile(351)+ B1 + int_str(TNC[TncNummer]^.Info);
      G^.Fstr[12] := InfoZeile(352)+ B1 + int_str(TNC[TncNummer]^.Aktuell);
      G^.Fstr[13] := InfoZeile(353)+ B1 + int_str(TNC[TncNummer]^.QText);
      G^.Fstr[14] := InfoZeile(354)+ B1 + int_str(TNC[TncNummer]^.Fix);

      G^.Fstr[Y][X] := A_ch;

      G^.Fstr[9] := '';
      G^.Fstr[15] := '';
      Fenster(15);

      _ReadKey(KC,VC);
      Case KC of
        _Esc : Flag := true;

       _AltH : XP_Help(G^.OHelp[9]);

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

     _Andere : case VC of
                 B1:;
                 else Alarm;
               end;
         else Alarm;
      End;

      if (KC in [_F1.._F5,_Ret]) or ((KC = _Andere) and (VC = B1)) then
      begin
        case Art of
          1 : begin
                G^.Fstr[10][vM] := S_ch;
                Hstr := int_str(TNC[TncNummer]^.CText);
              end;
          2 : begin
                G^.Fstr[11][vM] := S_ch;
                Hstr := int_str(TNC[TncNummer]^.Info);
              end;
          3 : begin
                G^.Fstr[12][vM] := S_ch;
                Hstr := int_str(TNC[TncNummer]^.Aktuell);
              end;
          4 : begin    {12}
                G^.Fstr[13][vM] := S_ch;
                Hstr := int_str(TNC[TncNummer]^.QText);
              end;
          5 : begin    {13}
                G^.Fstr[14][vM] := S_ch;
                Hstr := int_str(TNC[TncNummer]^.Fix);
              end;
        end;

        Fenster(15);
        GetString(Hstr,Attrib[3],3,2,15,KC,0,IFlag);
        if KC <> _Esc then
        begin
          i := Byte(str_int(Hstr));
          case Art of
            1 : TNC[TncNummer]^.CText := i;
            2 : TNC[TncNummer]^.Info := i;
            3 : TNC[TncNummer]^.Aktuell := i;
            4 : TNC[TncNummer]^.QText := i;
            5 : TNC[TncNummer]^.Fix := i;
          end;
        end;
      end;

    Until Flag;

    ClrFenster;
    Neu_Bild;
    Moni_On;
  end;
End;


Procedure QRG_Einstellen (* Kanal : Byte; Zeile : Str8 *);
Const  Bofs = 2;
Var    TNr,i,i1,i2,
       Bpos      : Byte;
       Dpos      : Integer;
       w         : Word;
       yM,
       Zmax      : Byte;
       Flag,
       Cursor,
       Fertig    : Boolean;
       Hstr      : String[60];
       KC        : Sondertaste;
       VC        : Char;
       Such      : String[9];

  Procedure InitVar;
  Begin
    yM := 1;
    Bpos := 1;
    Dpos := 1;
  End;

  Function GetQrgStr(QPos : Word) : Str80;
  Begin
    GetQrgStr := B1 + EFillStr(79,B1,EFillStr(10,B1,G^.QRG[QPos].CALL) +
                                 GL + B1 + G^.QRG[QPos].QRG);
  End;

  Procedure QrgPage(beg : Word);
  Var   i,i1 : Byte;
  Begin
    Teil_Bild_Loesch(3,maxZ-1,Attrib[2]);
    i1 := Zmax;
    if i1 > G^.QRG_Anz then i1 := G^.QRG_Anz;
    for i := 1 to i1 do
       WriteRam(1,i+Bofs,Attrib[2],0,EFillStr(80,B1,GetQrgStr(beg-1+i)));
  End;

Begin
  if Kanal = 0 then TNr := Unproto
               else TNr := K[Kanal]^.TncNummer;

  if Zeile > '' then
  begin
    TNC[TNr]^.QRG_Akt := UpCaseStr(Zeile);
    TNC[TNr]^.TicStr := ConstStr(B1,TL);
    Status2;
  end else
  begin
    NowFenster := false;
    Moni_Off(0);;
    InitVar;

    Such := '';
    Zmax := maxZ - (1 + Bofs);
    Fertig := false;
    Cursor := true;

    WriteRam(1,1,Attrib[15],0,EFillStr(80,B1,B1 + InfoZeile(229)));
    WriteRam(1,2,Attrib[2],0,ConstStr('Ä',80));
    WriteRam(1,maxZ,Attrib[15],0,ConstStr(B1,80));
    QrgPage(Dpos);
    WriteAttr(1,Bpos+Bofs,80,Attrib[4],0);

    Repeat
      if Cursor then InitCursor(1,Bpos+Bofs)
                else InitCursor(1,1);

      WriteRam(60,1,Attrib[15],0,'Nr:' + SFillStr(3,B1,int_str(Dpos)));
      WriteRam(71,1,Attrib[15],0,EFillStr(10,B1,Such));

      _ReadKey(KC,VC);

      if KC <> _Andere then Such := '';

      case KC of
        _Esc, _Del
         : Fertig := true;

        _AltH
         : XP_Help(G^.OHelp[8]);

        _Dn
         : if Dpos < G^.QRG_Anz then
           begin
             inc(Dpos);
             if Bpos < Zmax then inc(Bpos) else
             begin
               WriteAttr(1,Bofs+yM,80,Attrib[2],0);
               Scroll(Up,0,1+Bofs,Zmax+Bofs);
               WriteRam(1,Bofs+Bpos,Attrib[4],0,GetQrgStr(Dpos));
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
               WriteRam(1,Bofs+Bpos,Attrib[4],0,GetQrgStr(Dpos));
             end;
           end else Alarm;

        _PgDn
         : if Dpos < G^.QRG_Anz then
           begin
             if Dpos + Zmax - Bpos >= G^.QRG_Anz then
             begin
               Dpos := G^.QRG_Anz;
               Bpos := Zmax;
               if Bpos > G^.QRG_Anz then Bpos := G^.QRG_Anz;
             end else
             begin
               Dpos := Dpos + Zmax - 1;
               if Dpos + Zmax - 1 > G^.QRG_Anz then Dpos := G^.QRG_Anz - Zmax + Bpos;
               QrgPage(Dpos - Bpos + 1);
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
               QrgPage(Dpos - Bpos + 1);
             end;
           end else Alarm;

        _CtrlPgUp
         : if Dpos > 1 then
           begin
             Dpos := 1;
             Bpos := 1;
             QrgPage(1);
           end else Alarm;

        _CtrlPgDn
         : if Dpos < G^.QRG_Anz then
           begin
             Dpos := G^.QRG_Anz;
             Bpos := Zmax;
             if Bpos > G^.QRG_Anz then Bpos := G^.QRG_Anz;
             QrgPage(Dpos - Bpos + 1);
           end else Alarm;

        _CtrlHome
         : begin
             Dpos := Dpos - Bpos + 1;
             Bpos := 1;
           end;

        _CtrlEnd
         : if G^.QRG_Anz < Zmax then
           begin
             Dpos := G^.QRG_Anz;
             Bpos := G^.QRG_Anz;
           end else
           begin
             Dpos := Dpos + Zmax - Bpos;
             Bpos := Zmax;
           end;

        _ShTab
         : Cursor := not Cursor;

        _Ret
         : begin
             TNC[TNr]^.QRG_Akt := G^.QRG[Dpos].QRG;
             TNC[TNr]^.TicStr := ConstStr(B1,TL);
             fertig := true;
           end;

        _Andere
         : begin
             Such := Such + UpCase(VC);
             w := 0;
             Flag := false;
             While (w < G^.QRG_Anz) and not Flag do
             begin
               inc(w);
               if pos(Such,G^.QRG[w].CALL) = 1 then
               begin
                 Flag := true;
                 Dpos := w;
                 if (Dpos < Bpos) or (G^.QRG_Anz <= Zmax) then Bpos := Dpos;
                 if ((G^.QRG_Anz - Dpos + Bpos) < Zmax) and
                    (G^.QRG_Anz > Zmax) and (Dpos > Bpos)
                  then Bpos := Zmax - (G^.QRG_Anz - Dpos);
               end;
             end;

             if not Flag then
             begin
               Alarm;
               Such := '';
             end else QrgPage(Dpos - Bpos + 1);
           end;

        else Alarm;
      end;

      WriteAttr(1,Bofs+yM,80,Attrib[2],0);
      WriteAttr(1,Bofs+Bpos,80,Attrib[4],0);
      yM := Bpos;
    Until Fertig;

    Neu_Bild;
    Moni_On;
  end;
End;


Procedure Verschiedene_Einstellungen (* Kanal : Byte *);
Const  ArtMax = 14;
Var    i      : Byte;
       KC     : Sondertaste;
       VC     : Char;
       RemAll_,
       Flag,
       Flag1  : Boolean;
       maxz_,
       X,Y,
       Art    : Byte;
       staAnz : array[0..2] of Str80;

Begin
  with K[Kanal]^ do
  begin
    RemAll_ := RemAll;
    Moni_Off(0);;
    Flag := false;
    Flag1 := false;

    for i := 9 to 16 do G^.Fstx[i] := 3;
    G^.Fstr[7] := InfoZeile(355);
    G^.Fstr[10] := InfoZeile(356);
    G^.Fstr[11] := InfoZeile(357);
    G^.Fstr[12] := InfoZeile(358);
    G^.Fstr[13] := InfoZeile(359);
    G^.Fstr[14] := InfoZeile(360);
    G^.FStr[15] := InfoZeile(361);

     StaAnz[0]:=infoZeile(362);
     Staanz[1]:=infoZeile(363);
     staanz[2]:=infoZeile(364);

    Art := 1;

    Repeat

     G^.Fstr[16]:=staanz[G^.StatusModus];


      for i := 10 to 15 do
      begin
        G^.Fstr[i][vM+1] := B1;
        G^.Fstr[i][hM+1] := B1;
        G^.Fstr[i][vM] := B1;
        G^.Fstr[i][hM] := B1;
      end;

      if Art in [1..5,16] then
      begin
        X := vM;
        Y := Art + 9;
        if art=11 then y:=6+9;
      end else
      begin
        X := hM;
        Y := Art + 4;
        if art=12 then y:=6+9;
      end;
      G^.Fstr[Y][X] := A_ch;

      if HardCur then SetzeCursor(X+1,Y);

      if FileSend then
      begin
        case TX_Bin of
          0 : G^.Fstr[10][vM+1] := X_ch;
          1 : G^.Fstr[12][vM+1] := X_ch;
          2 : G^.Fstr[11][vM+1] := 'x';
          3 : G^.Fstr[11][vM+1] := X_ch;
        end;
      end;

      if _VGA then G^.Fstr[10][vM+1] := X_ch;
      if (Kanal > 0) and TxBeepAck then G^.Fstr[11][vM+1] := X_ch;
      if (Kanal > 0) and Rx_Beep then G^.Fstr[12][vM+1] := X_ch;
      if CtrlBeep then G^.Fstr[13][vM+1] := X_ch;
      if (Kanal > 0) and Auto then G^.Fstr[14][vM+1] := X_ch;
      if VIPG then G^.FStr[15][vM+1] := X_Ch;

      if ((Kanal = 0) and NoBinMon) or
         ((Kanal > 0) and not BinOut) then G^.Fstr[10][hM+1] := X_ch;
      if TopBox then G^.Fstr[11][hM+1] := X_ch;
      if (Kanal > 0) and RemAll then G^.Fstr[12][hM+1] := X_ch;
      if (Kanal > 0) and SPlus then G^.Fstr[13][hM+1] := X_ch;
      if (Kanal > 0) and AutoBin then G^.Fstr[14][hM+1] := X_ch;
      if SoZeichen then G^.FStr[15][hM+1] := X_Ch;
      if G^.ZeilenwTX then G^.FStr[16][hM+1] := X_Ch;

      G^.Fstr[9] := '';

      Fenster(16);

      _ReadKey(KC,VC);
      Case KC of
        _Esc : Flag := true;

       _AltH : XP_Help(G^.OHelp[26]);

        _Ret : ;

         _F1 : Art := 1;
         _F2 : Art := 2;
         _F3 : Art := 3;
         _F4 : Art := 4;
         _F5 : Art := 5;
         _F6 : Art := 6;
         _F7 : Art := 7;
         _F8 : Art := 8;
         _F9 : Art := 9;
        _F10 : Art := 10;
        _CTRLF1: ART:=11;
        _CTRLF2: ART:=12;
        _CTRLF3: Art:=13;
        _CTRLF4: Art:=14;

         _Up : if Art > 1  then dec(Art)
                           else Alarm;

         _Dn : if Art < ArtMax then inc(Art)
                               else Alarm;

      _Right : if Art < ArtMax  then
               begin
                 Art := Art + 5;
                 if Art > ArtMax then Art := ArtMax;
               end else Alarm;

       _Left : if Art > 1 then
               begin
                 if Art <= 5 then Art := 1
                             else Art := Art - 5;
               end else Alarm;

     _Andere : case VC of
                 B1:;
                 else Alarm;
               end;

         else Alarm;
      End;

      if (KC in [_F1.._F10,_ctrlF1,_ctrlF2,_ctrlF3, _CTRLF4,_Ret]) or ((KC = _Andere) and (VC = B1)) then
      case Art of
        1 : begin
              maxZ_:=maxZ;
              _VGA := not _VGA;
              LastModeStore := LastMode;
              switch_VGA_Mono;
              ColorItensity(HighCol);
              maxZ := Hi(WindMax) + 1;
              if not _VGA then if maxZ <> 25 then maxZ := 25;

              Flag1 := RX_TX_Win;
              if Flag1 then Change_WIN;

              for i := 0 to maxLink do with K[i]^ do
              begin
                {ObStat := 5;}
                if i = 0 then UnStat := ObStat + 1
                         else UnStat := maxZ - (maxz_ - Unstat);
                        {else UnStat := maxZ - 2;}
               { stC := (VorZeilen - VorCmdZeilen) + 1;}
                X1C := 3;
                {Y1C := 1;}
                {stV := 1;}
                X1V := 1;
                {Y1V := 1;}
              end;

              Fenster_Berechnen;
              if Flag1 then Change_WIN;

              Cursor_aus;
              Flag := true;
            end;

        2 : if Kanal > 0 then
            begin
              TxBeepAck := not TxBeepAck;
              if TxBeepAck and Klingel then
               Beep(G^.TxPiepFreq,G^.TxPiepTime);
            end else Alarm;

        3 : if Kanal > 0 then Rx_Beep := not Rx_Beep
                         else Alarm;

        4 : CtrlBeep := not CtrlBeep;

        5 : if Kanal > 0 then Auto := not Auto
                         else Alarm;

        6 : if Kanal = 0 then NoBinMon := not NoBinMon
                         else BinOut := not BinOut;

        7 : TopBox := not TopBox;

        8 : if Kanal > 0 then RemAll := not RemAll
                         else Alarm;

        9 : If Kanal > 0 then
            begin
              if SplSave then Close_7Plus(Kanal)
                         else SPlus := not SPlus;
            end else Alarm;

       10 : If Kanal > 0 then
            begin
              AutoBin := not AutoBin;
            end else Alarm;

       11 : VIPG:=not VIPG;

       12 : SoZeichen := Not SoZeichen;

       13 : begin
             inc (G^.StatusModus);
             if G^.StatusModus > 2 then G^.StatusModus:=0;
            end;

       14 : G^.ZeilenwTX := not G^.ZeilenwTX;

      end;

      SetzeFlags(Kanal);
    Until Flag;
    ClrFenster;

    if RemAll_ <> RemAll then
     begin
      if RemAll then S_PAC(Kanal,NU,true,InfoZeile(416)+' '+Meldung[28]+M1)
                else S_PAC(Kanal,NU,true,InfoZeile(417)+' '+Meldung[29]+M1);
     end;

    Neu_Bild;
    Moni_On;
  end;
  UserInStatus(Kanal);
End;


Procedure Alt_Disc (* Kanal : Byte *);
Var  KC   : Sondertaste;
     VC   : Char;
     Flag : Boolean;
Begin
  Flag := false;
  if SiAltD then
  begin
    InfoOut(Kanal,1,1,InfoZeile(167));
    _ReadKey(KC,VC);
    VC := UpCase(VC);
    if (KC =_Ret) or (VC in YesMenge) then Flag := true;
    Neu_Bild;
  end else Flag := true;
  if Flag then S_PAC(Kanal,CM,true,'D');
End;


Procedure Auswert_Kopieren (* Kanal : Byte; Zeile : Str80 *);
Var  i    : Byte;
     Flag : Boolean;
Begin
  with K[Kanal]^ do
  begin
   K[Kopieren]^.KopierenFm := 0;
    if Kanal > 0 then
    begin
      Flag := pos(LZ,Zeile) > 0;
      if Flag then delete(Zeile,pos(LZ,Zeile),1);

      Zeile := RestStr(UpCaseStr(Zeile));
      if Zeile > '' then
      begin
        i := Byte(str_int(Zeile));
        if (i in [1..maxLink]) and K[i]^.connected then
        begin
          Kopieren := i;
          K[i]^.KopierenFm := Kanal;
        end else
        begin
          K[Kopieren]^.KopierenFm := 0;
          K[KopierenFm]^.Kopieren := 0;
          Kopieren := 0;
          KopierenFm:=0;
          if i > 0 then InfoOut(Kanal,1,1,InfoZeile(301));
        end;
      end else
      begin
{        if Kopieren > 0 then
        begin }
          K[Kopieren]^.KopierenFm := 0;
          K[KopierenFm]^.Kopieren := 0;
          Kopieren := 0;
          KopierenFm:=0;
        {  K[Kopieren]^.KopierenFm := 0;
          Kopieren := 0; }
{        end else Alarm; }
      end;
      SetzeFlags(Kanal);
    End else Alarm;
  end;
End;


Procedure Idle_Einstellen (* Kanal : Byte; Zeile : Str20 *);
Var  i : Integer;
Begin
  Zeile := RestStr(Zeile);
  if Zeile > '' then
  begin
    i := Integer(str_int(CutStr(Zeile)));
    Idle_Pos := i >= 0;
    if not Idle_Pos then i := i * -1;
    Idle_Anz := i;
    Zeile := RestStr(Zeile);
    if Zeile > '' then
    begin
      Idle_Tout := Word(str_int(Zeile));
    end;
    Idle_Count := 0;
    Idle_TCount := 0;
  end;
  i := Idle_Anz;
  if not Idle_Pos then i := i * -1;
  InfoOut(Kanal,0,1,int_str(i) + B2 + int_str(Idle_Tout));
End;


Procedure Remote_Emulieren(Kanal : Byte; Zeile : Str80);
Var   Bstr : String[80];
      Flag : Boolean;
Begin
  with K[Kanal]^ do
  begin
    if Kanal > 0 then
    begin
      Zeile := RestStr(Zeile);
      Flag := RemAll;
      RemAll := true;
      Check_Mld(Kanal,Zeile);
      if RxComp then
      begin
        Bstr := MeldeCompZ;
        MeldeCompZ := Zeile;
      end else
      begin
        Bstr := MeldeZeile;
        MeldeZeile := Zeile;
      end;
      Connect_Info(Kanal,Attrib[20],true,Zeile + M1);
      MldOk := 0;
      if RxComp then MeldeCompZ := Bstr
                else MeldeZeile := Bstr;
      RemAll := Flag;
    end else InfoOut(Kanal,1,1,InfoZeile(192));
  end;
End;


Procedure GetString(* var S     : Str80;
                          Attr,
                          L,X,Y : Byte;
                      var TC    : Sondertaste;
                          Art   : Byte;
                      var Ins   : Boolean *);
Var
      i,P   : Byte;
      VC,
      VC1   : Char;
      KC    : Sondertaste;
      gr    : char;
   {   Gross : Boolean;}


  Procedure InitS;
  Begin
    VC1 := #255;
    if L > (SizeOf(S) - 1) then L := SizeOf(S) - 1;
    P := length(S);
    if Art = 3 then Art := 0
               else While (P > 0) and (s[P] <> BS) do dec(P);
    inc(P);
  End;

Begin
{  Gross := true;}
  HistoryCount := 0;
  FillChar(History^[maxHistory+1],SizeOf(History^[1]),0);
  if Ins then gr := '_' else gr := Pkt;
  InitS;
  Repeat
    if length(S) > L then S := copy(S,1,L);
    WriteRam(X,Y,Attr,1,S + ConstStr(gr,L - Length(S)));
    SetzeCursor(X+P-1,Y);
    _ReadKey(KC,VC);
    if Gross then VC := UpCase(VC);
    case KC of
      _Andere    : Case VC of
                    #32..#254
                      : if (P <= L) and ((length(S) < L) or not Ins) then
                        begin
                          Insert(VC,S,P);
                          inc(P);
                          if not Ins then delete(S,P,1);
                        end else Alarm;
                    ^T: Del_Wort(S,P);
                    ^Y: begin
                          P := 1;
                          S := '';
                        end;
                   end;
      _AltK      : Gross := not Gross;
        _F2      : if (Art > 0) and not Backscroll(show) then
                   begin
                     if pos(':\',S) <> 2 then S := Konfig.SavVerz;
                     if not PfadOk(0,copy(S,1,3)) then S := copy(SysPfad,1,3);
                     if pos(S_ch,S) = 0 then
                     begin
                       While (S[length(S)] <> BS) and (length(S) > 0) do
                       delete(S,length(S),1);
                       S := S + Joker;
                     end;
                     Cursor_aus;
                     DirZeig(S,VC1,true);
                     if (VC1 <> ESC) and (Art = 2) then exit;
                     Neu_Bild;
                     Fenster(15);
                     InitS;
                   end;
   _F1,_F3.._F10 : if Art > 0 then
                   begin
                     case KC of
                       _F1 : S := copy(S,1,P-1) + UpCaseStr(copy(Datum,4,2) +
                                  copy(Datum,1,2) + copy(Uhrzeit,1,2) +
                                  copy(Uhrzeit,4,2) + Pkt  +
                                  SFillStr(3,'0',int_str(show)));
                       _F3 : S := SysPfad;
                       _F4 : S := Konfig.SavVerz;
                       _F5 : S := G^.Merk_Drive;
                       _F6 : S := Konfig.MailVerz;
                       _F7 : S := Konfig.RunVerz;
                       _F8 : S := Konfig.BinVerz;
                       _F9 : S := Konfig.SplVerz;
                      _F10 : S := Konfig.SavVerz + SaveName + SFillStr(3,'0',int_str(show));
                     end;
                     InitS;
                   end;
       _Ins      : begin     (* INS *)
                     Ins := not Ins;
                     if Ins then gr := '_' else gr := Pkt ;
                   end;
      _Left      : if P > 1 then dec(P);
     _Right      : if P <= Length(S) then inc(P);
      _Home      : P := 1;
       _End      : P := Length(S) + 1;
       _Del      : if P <= Length(S) then Delete(S,P,1);
  _CtrlLeft,
  _CtrlRight     : begin
                     Cur_Wort(S,KC,P,1);
                   end;
      _AltH      : XP_Help(G^.OHelp[18]);
      _Back      : if P > 1 then
                   begin
                     Delete(S,P-1,1);
                     dec(P);
                   end;
        _Up      : begin
                   if not inudb then
                    begin
                    if HistoryCount < maxHistory then
                    begin
                      if HistoryCount = 0 then History^[maxHistory+1] := S;
                      inc(HistoryCount);
                      S := History^[HistoryCount];
                      InitS;
                    end else Alarm;
                    end; {if not inudb}
                   end;
       _Dn       : begin
                    if not inudb then
                    begin
                     if HistoryCount > 0 then
                     begin
                       dec(HistoryCount);
                       if HistoryCount = 0 then S := History^[maxHistory+1]
                                           else S := History^[HistoryCount];
                       InitS;
                     end else Alarm;
                    end; {if not inudb}
                   end;

      _Ret       : begin
                     move(History^[1],History^[2],SizeOf(History^[1])*(maxHistory-1));
                     History^[1] := S;
                   end;
    end;  (* of case *)
  Until (KC in [_Ret,_Esc]) or ((inudb)and (kc in UDBExit));
  TC := KC;
  Cursor_aus;
END;

Function CBCallCheck (* CBCall : Str9) : Function *);
 var hstr1 : Str9;
     Flag1 : Boolean;
begin
 {
 CB-Call-System in Deutschland:

 Freigegeben: DAA200 bis DRZ999

 Ausgegrenzt sind folgende:
  DBA200 - DBA999
  DBR200 - DBR999
  DEA200 - DEA999
  DER200 - DER999

 Info: DAKfCBNF, RZ-Stelle, Edgar (DHF600)
 }

 Strip (CBCall);
 flag1:=false;
 if length(CBCall)=6 then
  begin
   hstr1:=copy (cbcall,4,3);
   if str_int(hstr1)>199 then
    begin
     hstr1:=CBCall;
     delete(hstr1,4,3);
     if hstr1[1]='D' then
      begin
       delete(hstr1,1,1);
       if hstr1[1] in ['A'..'R'] then
        begin
         if hstr1[2] in ['A'..'Z'] then
          begin
           flag1:=true;
           if (hstr1='BA') or
              (hstr1='BR') or
              (hstr1='EA') or
              (hstr1='ER') then flag1:=false;
          end else flag1:=false;
        end else flag1:=false;
      end else flag1:=false;
    end else flag1:=false;
  end else flag1:=false;
 CBCallCheck := Flag1;
end;