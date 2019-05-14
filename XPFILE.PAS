{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P F I L E . P A S                                                    ³
 ³                                                                         ³
 ³ Verschiedene Dateibehandlungen                                          ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


Function  Compute_CRC (* CRC : Integer; Zeile : String) : Integer *);
Var     i,i1 : Byte;
        C    : Integer;
Begin
  C := CRC;
  for i := 1 to length(Zeile) do
  begin
    i1 := Ord(Zeile[i]);
    asm  mov al, i1;
         mov bx, C;
         mov cx, 8;
@schleif:
         rcl al, 1;
         rcl bx, 1;
         jnc @not_xor;
         xor bx, $1021;
@not_xor:
         loop @schleif;
         mov C, bx;
    end;
  end;
  Compute_CRC := C;
End;


Procedure FileInfo (* Kanal,Art : Byte; Groesse,Count,tGroesse,tCount : LongInt *);
Const  ArtStr  : Array[0..2] of String[2] = ('Rx','Tx','7+');

Var    i,Proz  : Byte;
       Lstr    : String[2];
       Bstr,
       Tstr,
       CoStr,
       GrStr   : String[8];
       Hstr    : String[78];
       AufFlag : Boolean;
       ChStr   : String[6];

   Function BinFlag(Art,TxRx_Bin : Byte) : Char;
   Begin
     if Art = 1 then
     begin
       Case TxRx_Bin of
         1 : BinFlag := 'T';
         2 : BinFlag := 'B';
         5 : BinFlag := 'A';
       end;
     end else
     begin
       Case TxRx_Bin of
         0 : BinFlag := 'T';
         1 : BinFlag := 'B';
         2,
         3 : BinFlag := 'A';
       end;
     end;
   End;

Begin
  with K[Kanal]^ do
  begin
    if not BackScroll(Kanal) and (DateiInfo > 0) and
       not(((RX_Save or FileSend) and SplSave) and (Art = 2)) then
    begin
      AufFlag := Aufwaerts;
      case Art of
        0 : begin     (* File-Rx *)
              Hstr := FName_aus_FVar(RxFile);
              Tstr := Rx_Time;
              Bstr := int_str(RX_Count);
              if RX_Bin in [1,2] then AufFlag := true;
              ChStr := B1 + LRK + BinFlag(1,RX_Bin) + RRK;
            end;
        1 : begin     (* File-Tx *)
              Hstr := FName_aus_FVar(TxFile);
              Tstr := Tx_Time;
              Bstr := int_str(TX_Count);
              ChStr := B1 + LRK + BinFlag(2,TX_Bin) + RRK;
            end;
        2 : begin     (* 7+ Rx *)
              Hstr := FName_aus_FVar(SplFile);
              Tstr := Spl_Time;
              Bstr := int_str(tCount);
              if SplCountLines then
              begin
                Groesse := Groesse div 69;
                Count := Count div 69;
              end;
            end;
      end;

      Lstr := copy(Hstr,1,2);
      Tstr := Time_Differenz(Tstr,Uhrzeit);
      Bstr := FileBaud(Tstr,Bstr);

      if Groesse > 0 then
      begin
        Proz := Byte(Round((Count / Groesse) * 100));
        if Proz > 100 then Proz := 100;
        if (Proz = 100) and (Count < Groesse) then Proz := 99;
        GrStr := SFillStr(8,B1,int_str(Groesse));
      end else
      begin
        Proz := 0;
        GrStr := B1 + ConstStr('-',6) + B1;
      end;

      if Art = 2 then
      begin
        if tGroesse > 0 then
        begin
          i := Byte(Round((tCount / tGroesse) * 100));
          if i > 100 then i := 100;
          if (i = 100) and (tCount < tGroesse) then i := 99;
        end else i := 0;
        ChStr := SFillStr(6,B1,LRK + int_str(i) + '%' + RRK);
        Lstr := '';
      end;

      While pos(BS,Hstr) > 0 do delete(Hstr,1,pos(BS,Hstr));
      Hstr := ArtStr[Art] + ChStr + B1 + Lstr + EFillStr(13,B1,Hstr);

      if AufFlag then CoStr := SFillStr(8,B1,int_str(Count))
                 else CoStr := SFillStr(8,B1,int_str(Groesse - Count));

      i := Proz div 10;
      Hstr := Hstr + SFillStr(3,B1,int_str(Proz)) + '%>';
      Hstr := Hstr + ConstStr(InfoZe[1],i) + ConstStr(InfoZe[2],10-i) + '< '
                   + SFillStr(5,B1,Bstr) + ' Baud  ' +
                   + EFillStr(10,B1,Tstr) +
                   + CoStr + '/' + GrStr;

      InfoOut(Kanal,0,0,Hstr);
      if DateiInfo = 2 then BoxZaehl := $FFFF;
    end;
  end;
End;


Function  Zeit_to_Sek (* Zeile : str8) : LongInt *);
var  l : LongInt;
Begin
  if (Zeile[3] = DP) and (Zeile[6] = DP) then
  begin
    l := str_int(copy(Zeile,1,2)) * 3600;
    l := l + str_int(copy(Zeile,4,2)) * 60;
    l := l + str_int(copy(Zeile,7,2));
    Zeit_to_sek := l;
  end else Zeit_to_sek := 0;
End;


Function Time_Differenz (* Start,Stop : Str8) : Str8 *);
Var    l,l1 : LongInt;
       Bstr,
       Hstr : String[8];

Begin
  l  := Zeit_to_sek(Start);
  l1 := Zeit_to_sek(Stop);
  if l1 < l then l1 := l1 + 86400;
  l := l1 - l;
  Bstr := '';
  Hstr := int_str(l div 3600);
  While length(Hstr) < 2 do Hstr := '0' + Hstr;
  Bstr := Bstr + Hstr + DP;
  l := l mod 3600;
  Hstr := int_str(l div 60);
  While length(Hstr) < 2 do Hstr := '0' + Hstr;
  Bstr := Bstr + Hstr + DP;
  l := l mod 60;
  Hstr := int_str(l);
  While length(Hstr) < 2 do Hstr := '0' + Hstr;
  Time_Differenz := Bstr + Hstr;
End;


Function FileBaud (* ZeitStr,AnzStr : Str9) : Str9 *);
Var  l,l1 : LongInt;
Begin
  l := Zeit_to_sek(ZeitStr);
  if l = 0 then l := 1;
  l1 := str_int(AnzStr) * 8;
  FileBaud := int_str(Round(l1 / l));
End;


Procedure Kill_Save_File (* Kanal : Byte *);
var    Flag   : Boolean;
Begin
  with K[Kanal]^ do
  begin
    if ResetBin(SFile,T) = 0 then
    begin
      if Save then
      begin
        Seek(SFile,0);
        Truncate(SFile);
        G^.Fstr[15] := InfoZeile(299);
      end else
      begin
        FiResult := CloseBin(SFile);
        if EraseBin(SFile) = 0 then G^.Fstr[15] := InfoZeile(297)
                               else G^.Fstr[15] := InfoZeile(296);
      end;
    end else G^.Fstr[15] := InfoZeile(298);

    Alarm;
    G^.Fstr[15] := G^.Fstr[15] + '  ' + InfoZeile(78);
    Fenster(15);
    SetzeCursor(length(G^.Fstr[15])+2,15);
    Warten;
    Cursor_aus;
  end;
End;


Procedure Close_SaveFiles;
var   i : Byte;
Begin
  for i := 0 to maxLink do with K[i]^ do
  begin
    if Save    and (FileRec(SFile).Mode   <> fmClosed) then FiResult := CloseBin(SFile);
    if RX_Save and (FileRec(RxFile).Mode  <> fmClosed) then FiResult := CloseBin(RxFile);
    if SplSave and (FileRec(SplFile).Mode <> fmClosed) then FiResult := CloseBin(SplFile);
  end;
End;


Procedure Open_SaveFiles;
var   i : Byte;
Begin
  for i := 0 to maxLink do with K[i]^ do
  begin
    if Save and (FileRec(SFile).Mode = fmClosed) then
    begin
      if ResetBin(SFile,T) = 0 then Seek(SFile,FileSize(SFile)) else
      begin
        Save := false;
        Triller;
      end;
    end;

    if RX_Save and (FileRec(RxFile).Mode = fmClosed) then
    begin
      if ResetBin(RxFile,T) = 0 then Seek(RxFile,FileSize(RxFile)) else
      begin
        RX_Save := false;
        RX_Bin := 0;
        Triller;
      end;
    end;

    if SplSave and (FileRec(SplFile).Mode = fmClosed) then
    begin
      if ResetBin(SplFile,T) = 0 then Seek(SplFile,FileSize(SplFile)) else
      begin
        SplSave := false;
        Triller;
      end;
    end;
  end;
End;

{
Procedure Neu_Name (* Kanal,Art : Byte; Call : str9; Name : str28 *);
var   Result : Word;
      B      : Byte;
      i,i1   : Integer;
      f      : Text;
      Hstr   : string[60];
      Bstr   : string[80];
      flag,
      Loesch : Boolean;
      User2 : User_Typ2;
Begin
  B := K[Kanal]^.Umlaut;
  Call := EFillStr(9,B1,UpCaseStr(Call));
  KillEndBlanks(Name);
  i := 1;
  File_Umbenennen(SysPfad + NamesDatei,SysPfad + TmpDatei,i,i1);
  Assign(f,SysPfad + TmpDatei);
  FiResult := ResetTxt(f);
  Assign(G^.TFile,SysPfad + NamesDatei);
  FiResult := RewriteTxt(G^.TFile);
  flag := false;
  Loesch := false;

  While not Eof(f) do
  begin
    Readln(f,Hstr);
    if not flag and (copy(Hstr,3,9) = Call) then
    begin
      flag := true;
      Hstr := Hex(B,1) + B1 + Call + DP + Name;
      Result := 1;
      if Name = '' then
      begin
        Result := 2;
        Loesch := true;
      end;
    end;
    if not flag and (copy(Hstr,3,9) > Call) and (Name <> '') then
    begin
      flag := true;
      Writeln(G^.TFile,Hex(B,1),B1,Call,DP,Name);
      Result := 0;
    end;
    if not Loesch then Writeln(G^.TFile,Hstr);
    Loesch := false;
  end; (* While *)

  if not flag then
  begin
    if Name > '' then Writeln(G^.TFile,Hex(B,1),B1,Call,DP,Name);
    flag := true;
    Result := 0;
    if Name = '' then
    begin
      Result := 3;
      Loesch := true;
    end;
  end;

  FiResult := CloseTxt(G^.TFile);
  FiResult := CloseTxt(f);
  FiResult := EraseTxt(f);
  case Result of
    0 : Bstr := InfoZeile(10);    (* Hinzu          *)
    1 : Bstr := InfoZeile(11);    (* ge„ndert       *)
    2 : Bstr := InfoZeile(250);   (* gel”scht       *)
    3 : Bstr := InfoZeile(251);   (* Nicht gefunden *)
    else Triller;
  end;
  Bstr := Name + B1 + '->' + B1 + Bstr;
  if Art = 1 then DZeile := Bstr else InfoOut(Kanal,0,1,Bstr);
  if (Result = 3) and (Art = 0) then Alarm;
End;
}
Procedure Neu_Name (* Kanal,Art : Byte; Call : str9; Name : str28 *);
var   Result : byte;
      B      : Byte;
      i,i1   : Integer;
      f      : Text;
      Hstr   : string[60];
      Bstr   : string[80];
      flag,
      Loesch : Boolean;
      User2 : User_Typ2;
Begin
  Fillchar(User2, sizeof(user2),0);
  User2.Umlaut := K[Kanal]^.Umlaut;
  User2.Call := UpCaseStr(K[kanal]^.Call);
  KillEndBlanks(Name);
  User2.Name:=Name;
  NeuNameSave(User2, Result);
  case Result of
    0 : Bstr := InfoZeile(10);    (* Hinzu          *)
    1 : Bstr := InfoZeile(11);    (* ge„ndert       *)
    2 : Bstr := InfoZeile(250);   (* gel”scht       *)
    3 : Bstr := InfoZeile(251);   (* Nicht gefunden *)
    10: Bstr := InfoZeile(370)+m1;
    else Triller;
  end;
  if result<>10 then
   begin
    Bstr := ParmStr(3,B1,infozeile(195))+': '+Name + B1 + '->' + B1 + Bstr;
    if Art = 1 then DZeile := Bstr else InfoOut(Kanal,0,1,Bstr);
    if (Result = 3) and (Art = 0) then Alarm;
   end else DZeile:=bstr;
End;



Function  GetName (* Kanal:Byte; Call:str9; var FlagByte:Byte; Con:Boolean) : Str40; *);
{ FlagByte: Modus der Umlautwandlung (wird zurueckgeliefert)        }
{ Con=true: alle Userdaten werden gesetzt, Name wird zurueckgegeben }
{ Con=false: nur Name wird zurueckgegeben                           }

Const  maxB = $F000;
Var    Flag,
       Found : Boolean;
       Nstr,
       Hstr  : String[60];
       Cstr,
       Pstr  : String[9];
       Zahl  : LongInt;
       User2 : User_Typ2;
       UsFile: file of user_typ2;
       i,obf:byte;

Begin
with K[Kanal]^ do
 begin
   FBBStreng:=False;
   VIP_:=False;
   PacLen:=Konfig.PacLenStd;
   MaxFrame:=Konfig.MaxFrameStd;
   System:='';
   Hstr:='0';
   User_QTH:='';
   User_Loc:='';
   User_Komp:=0;
   user_autopw:=false;
 end;
  Found := false;
  Flag := false;
  Nstr := '';
  KillEndBlanks(Call);
  Pstr := Call;
  K[kanal]^.User_QTH:='';
  K[kanal]^.User_Loc:='';
  {K[kanal]^.ucall:='';}
  found:=UserSuchRoutine(Call, Zahl, TRUE,false);  {ACHTUMG: Ergebnis 'ZAHL' eines zu groá!!}
  if found then
   begin
    Datensatzholen (Zahl,User2);
    with K[Kanal]^ do
     begin

      if con then
       begin
        if pos(user2.Alias,Call)>0 then Alias:=user2.call
                                   else Alias:=user2.Alias;
        FBBStreng:=User2.FBBStreng_;
        VIP_:=User2.VIP;
        PacLen:=User2.Paclen;
        MaxFrame:=user2.maxframes;
        System:=user2.System;
        stopcode:=user2.stopcode;
        {UCall := User2.Call;}
        User_QTH := User2.QTH;
        User_Loc  := User2.Locator;
        User_AutoPW    := user2.AutoBOXPassw;
        User_Komp:=user2.kompression;
        KillEndBlanks(System);
        KillStartBlanks(System);
        UserArt:=0;
        for i:=1 to maxUser do
          if upcasestr(System)=UNam[i] then UserArt:=i;
        Hstr:=int_str(user2.Umlaut);
        for i:=1 to maxrem do
         if g^.Remotes[i].Befehl<>'' then RemoteAus[i]:=User2.RemAusnahmen[i];
        if (fwd) and (ACZeile='') then
         begin
          MailPrompt_:=UpcaseStr(user2.Prompt);
          MailPWPrompt_:=UpcaseStr(user2.PwPrompt);
          MailSStopPrompt_:=UPcaseStr(user2.SStopPrompt);
          MailPolling:=user2.vorbereitung;
          KillEndBlanks(MailPolling);
          if Mailpolling[Length(MailPolling)]<>';' then MailPolling:=Mailpolling+';';
          Mailpolling:=MailPolling+'*+*'+user2.MailLesen;
          KillEndBlanks(MailPolling);
          if Mailpolling[Length(MailPolling)]<>';' then MailPolling:=Mailpolling+';';
          Mailpolling:=MailPolling+User2.MailKillen;
          KillEndBlanks(MailPolling);
          if Mailpolling[Length(MailPolling)]<>';' then MailPolling:=Mailpolling+';';
          Mailpolling:=MailPolling+user2.Nachbereitung;
          KillEndBlanks(MailPolling);
          if Mailpolling[Length(MailPolling)]<>';' then MailPolling:=Mailpolling+';';
          Mailpolling:=MailPolling+user2.ByeBye;
          MailPolling:=upcaseStr(MailPolling);
         end;
         FlagByte := Byte(str_int('$'+ Hstr));
          if not (FlagByte in UmlMenge) then FlagByte := 0;
       end;
       GetName:=user2.Name;
     end;
    end
    else begin
      Flagbyte:=0;
      Getname:='';
    end;
   { if K[kanal]^.ucall='' then K[kanal]^.ucall:=k[kanal]^.call;}
end;

{
Function  GetName (* Kanal : Byte; Call : str9; var FlagByte : Byte) : Str40; *);
Const  maxB = $F000;
Var    Flag,
       Found : Boolean;
       Nstr,
       Hstr  : String[60];
       Cstr,
       Pstr  : String[9];
       Zahl  : LongInt;
Begin
  Found := false;
  Flag := false;
  Nstr := '';
  KillEndBlanks(Call);
  Pstr := Call;
  Strip(Pstr);
  Assign(G^.TFile,SysPfad + NamesDatei);
  FiResult := ResetTxt(G^.TFile);
  Repeat
    Readln(G^.TFile,Hstr);
    Cstr := CutStr(copy(Hstr,3,9));
    Strip(Cstr);

    if Pstr = Cstr then
    begin
      if Call = CutStr(copy(Hstr,3,9)) then Found := true;
      if not Flag or Found then
      begin
        FlagByte := Byte(str_int('$'+ Hstr[1]));
        if not (FlagByte in UmlMenge) then FlagByte := 0;
        delete(Hstr,1,pos(DP,Hstr));
        KillEndBlanks(Hstr);
        Nstr := Hstr;
        Flag := true;
      end;
    end;
  Until Found or Eof(G^.TFile);

  if Nstr > '' then GetName := Nstr else
  begin
    GetName := '';
    FlagByte := K[Kanal]^.UmlautMerk;
  end;
  FiResult := CloseTxt(G^.TFile);
end;

}
Procedure ZUmbruch (VAR Zeile : string);
 var Zei2, Zei3 : string;
     t,p       : byte;
     umb,
     Spa        :boolean;

begin
 Zei2:='';
 if length(Zeile)>80 then
  begin
   p:=80;
    while length(zeile)>80 do
     begin
      umb:=false; t:=81;
      While (t > 1) and (not umb) do
       begin
        dec(t);
        if (t < 2) or (Zeile[t] in UmMenge) then
         begin
            if t < 2 then t:=80;
            spa:=false;
            umb:=true;
            if Zeile[t] = #32 then spa:=true;
            if spa then Zeile[t]:=#13;
            Zei3:='';
            Zei3:=copy(Zeile, 1, t);
             delete(Zeile, 1, t);
            Zei2:=Zei2+Zei3;
            if not spa then Zei2:=Zei2+#13;
         end;
       end;
     end;
    Zei2:=Zei2+Zeile;
    Zeile:=Zei2;
  end;
end;


Function  Platzhalter (* Kanal : Byte; Zeile : String) : String *);
var    i,j,Nr : Byte;
       zeile2,
       Hstr2,
       Hstr : String;
       Bstr : String;
       Bef  : String[6];
       Fuell: byte;
       FuBit: Boolean;
       CDat : text;
       ZZaehl, Zzeil : integer;
       CZeil: string;

Begin
Fuell:=0;
zeile2:='';
FuBit:=false;
  with K[Kanal]^ do
  begin

    While (pos('#',Zeile) > 0) and (length(Zeile) >= (pos('#',Zeile)+5) ) do
    begin
     Nr:=0;
     Bstr := '';

      i := pos('#',Zeile);

      Bef := copy(Zeile,i,6);

      Bef:=UpcaseStr(Bef);

      For j:=1 to MaxCmds do
             if Bef=TextCmd[j] then Nr:=j;
      If Nr=29 then Nr:=0;

      If (pos(TextCmd[29],UpcaseStr(Zeile))>0) and (Bef[length(bef)]='#') then
      begin
       Nr:=29;
       Fuell:=Str_Int(copy(Bef,4,2));
       FuBit:=True;
      end;


      if Nr > 0 then
        begin
          delete(Zeile,i,6);
          Bstr:=copy(Zeile, 1, i-1);
          delete(Zeile, 1, i-1);
        end
        else
         begin
          Bstr:=copy(zeile, 1, i);
          delete(Zeile, 1, i);
         end;

      hstr:='';

      Case Nr of
        1 : Hstr := Uhrzeit;
        2 : Hstr := Datum;
        3 : Hstr := User_Name;
        4 : Hstr := int_str(Kanal);
        5 : Hstr := Call;
        6 : Hstr := Platzhalter(Kanal,G^.PromptStr);
        7 : Hstr := Zeitart;
        8 : Hstr := OwnCall;
        9 : Hstr := TNC[TncNummer]^.Ident;
       10 : Hstr := Version;
       11 : Hstr := lastEdit;
       12 : Hstr := copy(Uhrzeit,1,5);
       13 : Hstr := RestStr(Datum);
       14 : Hstr := CutStr(Datum);
       15 : if User_Name = '' then Hstr := Call
                              else Hstr := User_Name;
       16 : if User_Name = '' then Hstr := InfoZeile(131)
                              else Hstr := '';
       17 : Hstr := ^G;
       18 : Hstr := M1;
       19 : Hstr := int_str(TncNummer);
       20 : If K[Kanal]^.Node then HSTR:='Node' else Hstr:='Terminal';
       21 : begin
              Hstr := Call;
              Strip(Hstr);
            end;
       22 : Hstr := WochenTag;
       23 : Hstr := ^Z;
       24 : Hstr := QSO_Begin;
       25 : Hstr := QSO_Time(Kanal);
       26 : Hstr := int_str(CNr);
       27 : begin
              Hstr := OwnCall;
              Strip(Hstr);
            end;
       28 : Hstr := TNC[TncNummer]^.QRG_Akt;
     { 29 : hstr:=EFillStr(Fuell,B1,Hstr); } {Space-Befehl}
       30 : begin
             {#TEXT#}
             assign(CDat, sys1pfad+CooDatei);
             {$I-}
              reset(Cdat);
             {$I+}
             if ioResult<>0 then
              begin
                Hstr:='';
              end else
                begin
                 Randomize;
                 Hstr:='';
                 Hstr2:='';
                 {$I-}
                  Readln(cdat, Czeil);
                 {$I+}
                  ZZeil:=Random(Str_Int(copy(Czeil,2,3))-1)+1;
                  ZZaehl:=0;
                  While (not EOF(Cdat)) and (ZZaehl<ZZeil) and (IOResult=0) do
                   begin
                    {$I-}
                     Readln(cdat, CZeil);
                     if (IoResult=0) and (length(CZeil)>0) then Hstr2:=Czeil;
                     If IOResult<>0 then CZeil:=Hstr2;
                    {$I+}
                    inc(Zzaehl);
                    if Zzaehl=Zzeil then HSTR:=CZeil;
                   end;
                  if (EOF(Cdat)) or (IOResult>0) then
                   begin
                    HSTR:=HStr2;
                   end;
                 {$I-}
                  Close(CDat);
                 {$I+}
                 ZUmbruch (Hstr);
                end;
            end;
       31: if not node then Hstr:='//' else Hstr:='';
       32: Hstr:=Konfig.TNC[TncNummer].PortNam;
       33: if User_QTH='' then Hstr:=InfoZeile(397);
       34: if User_LOC='' then Hstr:=InfoZeile(398);
       35: HStr:=int_str(NoActivity)+ ' '+infozeile(393);
       36: if (not node) and ((not Klingel) and (Quiet) and ((not k[kanal]^.Vip_) or (not VIPG)))
            then Hstr:=InfoZeile(438);
      end;

       if (FuBit) and (Nr<>29) then hstr:=EFillStr(Fuell,B1,Hstr);
       if Nr<>29 then FuBit:=false;
       Bstr := Bstr + Hstr;
       Zeile2:= Zeile2 + Bstr;
    end;

  end;
  zeile:=zeile2+zeile;
  Platzhalter := Zeile;
End;


Function  MakeBinStr (* Kanal : Byte; Zeile : Str80) : Str80 *);
var   Hstr  : String[80];
      hstr2:str8;
      TxPos,
      FTime : LongInt;
      i     : Byte;
Begin
  with K[Kanal]^ do
  begin
    TxPos := FilePos(TxFile);
    KillEndBlanks(Zeile);
    Hstr := Zeile + B1 + SFillStr(1,'0',int_str(TxPos)) + B1 +
            int_str(TxPos + TX_Laenge - 1);

    FiResult := CloseBin(TxFile);
    CRC_Datei(Hstr);
    FiResult := ResetBin(TxFile,T);
    GetFtime(TxFile,FTime);
    Seek(TxFile,TxPos);

    i := 1;
    While (length(Hstr) > 0) and (not (Hstr[1] in ['0'..'9'])) do delete(Hstr,1,1);
    While (length(Hstr) > 0) and (Hstr[i] in ['0'..'9']) do inc(i);

    if Not XBIn.AN then HSTR2:=Meldung[8] else HSTR2:=Meldung[34];
    Hstr := HSTR2 + int_str(TX_Laenge) + '#|' + copy(Hstr,1,i-1) +
            '#$' + Hex(FTime,8) + '#' + copy(Zeile,1,2) + BS;

    i := length(Zeile);
    While (i > 0) and (not(Zeile[i] in [BS,DP])) do dec(i);
    delete(Zeile,1,i);

    if SCon[1] or SCon[2] or not TxLRet then Hstr := M1 + Hstr;
    MakeBinStr := Hstr + Zeile + M1;
  end;
End;


Function  FName_aus_FVar (* var f : File) : Str80 *);
Var    Hstr : String[80];
       i    : Byte;
Begin
  move(FileRec(f).Name,Hstr[1],80);
  i := 1;
  While (Hstr[i] > #0) and (i < 80) do inc(i);
  Hstr[0] := Chr(i-1);
  KillEndBlanks(Hstr);
  FName_aus_FVar := Hstr;
End;


Function SaveNameCheck (* Art : Byte; Zeile : Str80) : Boolean *);
Var    i    : Byte;
       Flag : Boolean;
Begin
  Flag := true;
  if Art = 1 then
  begin
    While pos(DP,Zeile) > 0 do delete(Zeile,1,pos(DP ,Zeile));
    While pos(BS,Zeile) > 0 do delete(Zeile,1,pos(BS,Zeile));
  end;
  if not FNameOK(Zeile) then Flag := false;
  if pos(Pkt,Zeile) = 0  then Zeile := Zeile + Pkt;
  if pos(Pkt, Zeile)>9 then
   begin
    Zeile[7]:='~'; Zeile[8]:='1';
    repeat
     delete(Zeile,9,1);
    until Zeile[9]='.';
   end;
  for i := 1 to length(Zeile) do
      if not (Zeile[i] in ['™','š','Ž','á','A'..'Z','0'..'9','!','#','%','&','.',
                           '(',')','-','@','^','_','{','}','$','~'])
                           then Flag := false;
  i := pos(Pkt,Zeile);
  if (i > 9) or (i < 2) then Flag := false;
  delete(Zeile,1,i);
  if (pos(Pkt,Zeile) > 0) or (length(Zeile) > 3) then Flag := false;
  SaveNameCheck := Flag;
End;

Function  MakePathName (* Kanal : Byte; Var DFlag : Boolean; Zeile : Str80) : Str80 *);
var hstr:str80;
Begin
  with K[Kanal]^ do
  begin
   hstr:=rempath;
    DFlag := false;
    if (pos(DP,Zeile) = 0) and (pos(BS,Zeile) <> 1) then Zeile := RemPath + Zeile;
    if pos(BS,Zeile) = 1 then Zeile := copy(RemPath,1,2) + Zeile;

    if Pos('..', Zeile) > 0 then
        begin
          if length(Hstr) > 3 then
          begin
            delete(Hstr,length(Hstr),1);
            While Hstr[length(Hstr)] <> BS do delete(Hstr,length(Hstr),1);
          end;
          zeile:=hstr;
        end;


    if not RemAll then
    begin
      if (pos(G^.Drive,Zeile) = 1) or
         (use_RomLw and (pos(RomDisk,Zeile) = 1)) then DFlag := true;
    end else DFlag := true;

    if not FNameOk(Zeile) then DFlag := false;
    MakePathName := Zeile;
  end;
End;


Function FNameOK (* Zeile : Str80) : Boolean *);
Var   i    : Byte;
      Flag : Boolean;
Begin
  i := 0;
  Flag := true;

  While pos(Pkt,Zeile) > 0 do
  begin
    i := pos(Pkt,Zeile);
    Zeile[i] := BS;
  end;

  if i = 0 then i := length(Zeile) + 2
           else inc(i);
  Zeile := copy(BS+Zeile+BS,1,i);

  for i := 1 to maxNoneName do
   if pos(BS+NoneNames[i]+BS,Zeile) > 0 then Flag := false;
  FNameOK := Flag;
End;


Function  PfadOk (* (Art : Byte; Zeile : Str80) : Boolean *);
Var       f      : Text;
          Hstr   : String[80];
          Result : Word;
Begin
  case Art of
    0 : begin
          if Zeile<>'' then
           begin
            GetDir(0,Hstr);
            if Zeile[length(Zeile)] = BS then delete(Zeile,length(Zeile),1);
            (*$I-*) ChDir(Zeile); (*$I+*)
            Result := IOResult;
            PfadOk := (Result = 0);
            ChDir(Hstr);
           end else PfadOK:=False;
        end;
    1 : begin
          if pos(Pkt,Zeile) = 0 then
          begin
            if Zeile[length(Zeile)] <> BS then Zeile := Zeile + BS;
            Zeile := Zeile + Testname;
          end;
          if not Exists(Zeile) then
          begin
            Assign(f,Zeile);
            Result := RewriteTxt(f);
            if Result = 0 then
            begin
              FiResult := CloseTxt(f);
              FiResult := EraseTxt(f);
              PfadOk := true;
            end else PfadOk := false;
          end else PfadOk := true;
        end;
  end;
End;


Function  MkSub (* Pfad : Str80) : Boolean *);
Var   Hstr,
      Merk    : String[80];
      Z,i     : Byte;
      Result  : Word;

Begin
  Pfad := UpCaseStr(Pfad);
  KillEndBlanks(Pfad);
  While Pfad[length(Pfad)] = BS do delete(Pfad,length(Pfad),1);
  Merk := Pfad;
  if pos(DP+BS,Pfad) = 2 then
  begin
    Z := 0;
    Hstr := '';
    Pfad := Pfad + BS;
    While length(Pfad) > 0 do
    begin
      inc(Z);
      i := pos(BS,Pfad);
      Hstr := Hstr + copy(Pfad,1,i-1);
      if Z > 1 then
      begin
        (*$I-*) MkDir(Hstr); (*$I+*)
        Result := IOResult;
      end;
      Hstr := Hstr + BS;
      delete(Pfad,1,i);
    end;
  end else
  begin
    (*$I-*) MkDir(Pfad); (*$I+*)
    Result := IOResult;
  end;
  Pfad := Merk;
  MkSub := PfadOk(1,Pfad);
End;


Procedure KillFile (* Zeile : Str80 *);
Var   f      : Text;
      Result : Word;
Begin
  Assign(f,Zeile);
  FiResult := EraseTxt(f);
End;


Procedure Ini_RemPath;
Var    i : Byte;
Begin
  for i := 0 to maxLink do K[i]^.RemPath := G^.Drive;
End;


Procedure File_Bearbeiten (* Kanal : Byte; Zeile : Str80 *);
Const  ArtMax = 5;
Var    KC   : Sondertaste;
       VC   : Char;
       Flag : Boolean;
       i,
       X,Y,
       Art  : Byte;
       w    : Word;
       Hstr : String[80];

  Procedure Menu;
  Var  i : Byte;
  Begin
    for i := 9 to 15 do G^.Fstx[i] := 13;
    G^.Fstr[7] := InfoZeile(66);
    G^.Fstr[10] := InfoZeile(67);
    G^.Fstr[11] := InfoZeile(68);
    G^.Fstr[12] := InfoZeile(69);
    G^.Fstr[13] := InfoZeile(70);
    G^.Fstr[14] := InfoZeile(71);
    G^.Fstr[9] := '';
    G^.Fstr[15] := '';
  End;

Begin
  with K[Kanal]^ do
  begin
    Flag := false;

    Zeile := RestStr(UpCaseStr(Zeile));
    Hstr := CutStr(Zeile);

    if Hstr = FileParm[1] then Art := 1 else
     if Hstr = FileParm[2] then Art := 2 else
      if Hstr = FileParm[3] then Art := 3 else
       if Hstr = FileParm[4] then Art := 4 else
        if Hstr = FileParm[5] then Art := 5 else
        begin
          Art := 0;
          Zeile := '';
        end;

    Zeile := RestStr(Zeile);

    if Art = 0 then
    begin
      Menu;
      Art := 1;

      Repeat
        for i := 10 to 14 do
        begin
          G^.Fstr[i][vM+1] := B1;
          G^.Fstr[i][vM] := B1;
        end;

        X := vM;
        Y := Art + 9;
        G^.Fstr[Y][X] := A_ch;

        if HardCur then SetzeCursor(X+1,Y);

        G^.Fstr[9] := '';
        G^.Fstr[15] := '';
        Fenster(15);

        _ReadKey(KC,VC);
        Case KC of
          _Esc : begin
                   Art := 0;
                   Flag := true;
                 end;

         _AltH : XP_Help(G^.OHelp[7]);

          _Ret : Flag := true;

           _F1 : begin
                   Art := 1;
                   Flag := true;
                 end;

           _F2 : begin
                   Art := 2;
                   Flag := true;
                 end;

           _F3 : begin
                   Art := 3;
                   Flag := true;
                 end;

           _F4 : begin
                   Art := 4;
                   Flag := true;
                 end;

           _F5 : begin
                   Art := 5;
                   Flag := true;
                 end;

           _Up : if Art > 1  then dec(Art)
                             else Alarm;

           _Dn : if Art < ArtMax then inc(Art)
                                 else Alarm;
       _Andere : case VC of
                   B1 : Flag := true;
                   else Alarm;
                 end;
           else Alarm;
        End;
      Until Flag;
      ClrFenster;
    end;

    VC := #0;

    if (Art > 1) and ((pos(Pkt,Zeile) = 0) or (pos(S_ch,Zeile) > 0)) then
    begin
      if Zeile = '' then Zeile := Konfig.SavVerz;
      if (Zeile[length(Zeile)] <> BS) and (pos(S_ch,Zeile) = 0)
       then Zeile := Zeile + BS;
      DirZeig(Zeile,VC,true);
      if VC <> Esc then
      begin
        VorWrite[Kanal]^[K[Kanal]^.stC] := S_ch + B1 +
          UpCaseStr(ParmStr(2,B1,VorWrite[Kanal]^[K[Kanal]^.stC]) + B1 +
          FileParm[Art] + B1 + Zeile);
      end;
      Cursor_aus;
      Neu_Bild;
    end;

    if VC <> Esc then
    begin
      if Art = 1 then
      begin
        Menu;
        G^.Fstr[10][vM] := S_ch;
        Fenster(15);;
        if Zeile > '' then Hstr := Zeile
                      else Hstr := Konfig.SavVerz + VorWriteDatei +
                           SFillStr(3,'0',int_str(Kanal));
        GetString(Hstr,Attrib[3],60,2,15,KC,1,Ins);
        if KC <> _Esc then
        begin
          Assign(G^.TFile,Hstr);
          FiResult := ResetTxt(G^.TFile);
          if FiResult = 0 then
          begin
            FiResult := CloseTxt(G^.TFile);
            FiResult := AppendTxt(G^.TFile);
          end else FiResult := RewriteTxt(G^.TFile);

          if FiResult = 0 then
          begin
            for w := 1 to VorZeilen - VorCmdZeilen do
            begin
              Hstr := VorWrite[Kanal]^[w];
              While pos(#26,Hstr) > 0 do
              begin
                i := pos(#26,Hstr);
                Hstr[i] := 'Z';
                insert('^',Hstr,i);
              end;
              Writeln(G^.TFile,Hstr);
            end;
            Flag := true;
            FiResult := CloseTxt(G^.TFile);
          end else Alarm;
        end;
        Neu_Bild;
      end else

      if Art = 2 then
      begin
        if Exists(Zeile) then
        begin
          Assign(G^.TFile,Zeile);
          FiResult := ResetTxt(G^.TFile);
          if Vor_im_EMS then EMS_Seite_einblenden(Kanal,Vor);
          for w := 1 to VorZeilen - VorCmdZeilen do
           Readln(G^.TFile,VorWrite[Kanal]^[w]);
          FiResult := CloseTxt(G^.TFile);
        end else Alarm;
        Neu_Bild;
      end else

      if Art = 3 then
      begin
        if Exists(Zeile) then
        begin
          Assign(G^.TFile,Zeile);
          FiResult := ResetTxt(G^.TFile);
          Write_Notiz(Kanal);
          While not Eof(G^.TFile) do
          begin
            Readln(G^.TFile,NZeile);
            KillEndBlanks(NZeile);
            NZeile := M1 + chr(ChAttr(Attrib[20])) + copy(NZeile,1,80);
            Write_Notiz(Kanal);
          end;
          FiResult := CloseTxt(G^.TFile);
          _aus(Attrib[20],Kanal,M1);
        end else Alarm;
        Neu_Bild;
      end else

      if Art = 4 then
      begin
        Moni_Off(0);
        Teil_Bild_Loesch(1,maxZ,0);
        Cursor_ein;
        if pos(BS,Zeile) = 0 then Zeile := Konfig.SavVerz + Zeile;
        Zeile := UpCaseStr(Zeile);
        ExecDOS(Konfig.EditVerz + B1 + Zeile);
        Cursor_aus;
        Moni_On;
        Neu_Bild;
      end else

      if Art = 5 then
      begin
        if Exists(CutStr(Zeile)) then
        begin
          CRC_Datei(Zeile);
          InfoOut(Kanal,0,1,Zeile);
        end else InfoOut(Kanal,1,1,CutStr(Zeile) + DP + B1 + InfoZeile(162));
      end else Neu_Bild;
    end;
    ClrFenster;
  end;
End;

