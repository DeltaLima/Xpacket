{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  X P M A I L . P A S                                                    ³
 ³                                                                         ³
 ³ Mailpolling-Routinen (Pseudo-Forward)                                   ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}

Function GetS_Con(Kanal : Byte; Zeile : Str80) : Str80;
  Var   i : Byte;
  Begin
    with K[Kanal]^ do
    begin
      i := pos(RSK + Call + B1,Zeile + B1);
      if i > 0 then
      begin
        delete(Zeile,1,i-1);
        Zeile := RestStr(Zeile);
        While (pos(RSK,CutStr(Zeile)) = 0) and (length(Zeile) > 0) do
         Zeile := RestStr(Zeile);
      end;
      GetS_Con := Zeile;
    end;
End;

Procedure Link_Holen (* Var TNr : Byte; Var Port : Byte; Var CString : Str80 *);
Var    ConStr, Hstr : String[80];
       QRG, Call : Str10;
       VC   : Char;
       Flag,
       Extr : Boolean;
Begin
  FiResult := ResetTxt(G^.LinkFile);
 if FiResult=0 then
 begin
  Flag := false;
  While not Eof(G^.LinkFile) and not Flag do
  begin
    Readln(G^.LinkFile,Hstr);
    if (Pos(TncI,Hstr)=1) and (Pos(DP, Hstr)=5) then
     begin
      Port:=str_int(Copy(Hstr,4,1));
      QRG:=copy(Hstr,6,length(Hstr));
     end;
    delete(hstr,1,1);
    KillEndBlanks(Hstr);
    Call:=copy(HStr,1,pos(B1,hstr)-1);
    Flag:= upcasestr(Cstring)=upcaseStr(Call);
(*    Flag := (TncI + int_str(TNr) + DP + Freq) = Hstr; *)
  end;
 end;
 CString:='';
 FiResult := CloseTxt(G^.LinkFile);
 if flag then
  begin
   LinksVorbereiten(Port,QRG);
    CString:=GetConPfad(Call);
   LinksKillen;
  end;
{ KillStartBlanks(Cstring);}
End;

Function NextPollCmd : string;
var HStr:string;
begin
 HStr:='';
 if Pos(';', MailPolling)>0 then
  begin
   Hstr:=copy (Mailpolling,1,Pos(';',MailPolling)-1);
   Delete(MailPolling,1,Pos(';',MailPolling));
  end else
   begin
    Hstr:=MailPolling;
    MailPolling:='';
   end;
  NextPollCmd:=HStr;
  {Lesebefehl VORHER mit *+* markiert!}
end;

procedure MailSchliessen(*Kanal:Byte*);
var dum:boolean;
begin
 with K[Kanal]^ do
  begin
   CloseRxFile(Kanal,0);
   RX_Save := false;
   BoxZaehl:=5;
   RX_Bin := 0;
   RemoteSave := false;
  end;
end;

procedure CancelMailPoll (*Kanal:Byte*);
begin
PollStr:='';
 with K[kanal]^ do
  begin
   fwdgo:=false;
   fwd:=false;
   fwd_:=false;
   MailPolling:='';
   MailPrompt:='';
   MailRXCall:='';
   MailSynonym:='';
   MailSchliessen(Kanal);
  end;
end;


Procedure MailOeffnen(Kanal:Byte);
var path, dummy : string;
begin
 With K[Kanal]^ do
 begin
   Path := Konfig.MailVerz + MailRXCall + MsgExt;
   MsgToMe:=true;
   EigMail:=true;
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
      Dummy := M1 + InfoZeile(96) + B1+ EFillStr(10,B1,Call) +
      Datum + B2 + copy(Uhrzeit,1,5) + B1 + ZeitArt + M1;
      Dummy := Dummy + ConstStr('-',length(Dummy)) + M1;
      Write_RxFile(Kanal,Dummy);
     end;
    end;
end;


procedure StartMailPolling (*(Kanal, RXCall)*);
var path,
    dummy : String;
    Link,hstr : Str80;
    i,Port : byte;
    found,
    flag:boolean;
    CStr,
    Pstr: str10;
    User2 : User_Typ2;
    USeidx: User_idx;
    UsFile: file of user_typ2;
    USIdx : file of User_IDX;
    obf:integer;
begin
found:=false;
MailPolling:='';
Link:=rxcall;
PStr:=RxCall;

if MailSynonym<>'' then Link:=MailSynonym
 else
  if not MailAusUDB then begin
   {$I-}
   assign(UsIDX, Sys1Pfad+UserIDX);
   reset(USIDX);
   obf:=ioresult;
   if obf=0 then
   begin
    Repeat
      read(UsIDX, USeIDX);
      CStr := USeidx.Call;
      Strip(CStr);
      found := cstr=PStr;
    until (Found) or (EOF(UsIDX));
    close(UsIDX);
   end;
   if found then
    begin
     assign(UsFile, Sys1Pfad+UserDatei);
     reset(UsFile);
     seek(UsFile, UseIDX.Pos);
     read(usfile, User2);
     close(usfile);
     obf:=ioresult;
     if user2.synonym<>'' then Link:=user2.Synonym;
    end;
    {$I+}
  end;
MailSynonym:='';
MailAusUDB:=false;
Link_Holen(Port,Link);
flag:=false;
i:=0;
repeat
 inc(i);
 if K[i]^.TNCNummer=Port then flag:=not K[i]^.connected;
until flag;
Kanal:=i;
if Flag then
begin
 with K[Kanal]^ do
 begin
  ACZeile:=link;
  {if connected then ACZeile := GetS_Con(Kanal,ACZeile);}
   if length(ACZeile) > 0 then
     begin
      fwd:=true;
      fwd_:=true;
      Auto_CON := true;
      Hstr := GetConStr(ACZeile);
      if not connected then Connect(Kanal,Hstr)
                       else S_PAC(Kanal,NU,true,Hstr + M1);
     end;
 end;
end; {if flag}
end;

procedure LinksVorbereiten(*Port:byte;QRG:Str10*);
begin
   GetMem(Lnk,SizeOf(Lnk^));
   Lnk_Init(Port,QRG);
end;


Procedure LinksKillen;
begin
 FreeMem(Lnk,SizeOf(Lnk^));
end;

Procedure MailPollGo (*Kanal : byte*);
var HStr:string;
    SStr:string;
    MPTyp:byte;
    Flag : Boolean;
begin
if MailPolling='' then
 begin
  if MailBoxCall<>'' then MailKillen (MailBoxCall, MailRXCall, 0);
  MailBoxCall:='';
  MailRXCall:='';
  NFwd:=false;
 end
 else NFwd:=true;
if MailPWWait then Sysop_Einloggen(Kanal,'');
if not MailPWWait then
 begin
  with K[kanal]^ do
  begin
   MailPrompt:='';
   hstr:=UpcaseStr(NextPollCmd);
   KillEndBlanks(Hstr);
   MPTyp:=0;
   flag:=true;
  repeat
   inc(MpTyp);
   flag:=Hstr=MailPollC[MPTyp];
  until (flag) or (MPTyp=MaxMailPollCmd);
  if (not flag) then MPtyp:=0;
  SStr:='';
  case MPTyp of
   1:MailPrompt:=UpcaseStr(MailPrompt_);
   2: begin
       SStr:=#13;
       _aus(Attrib[19],Kanal,m1);
      end;
   3:SStr:=MailRXCall;
   4: begin
       Sysop_Einloggen(Kanal,'');
       MailPWWait:=true;
      end;
   5: begin
       MailPrompt:=UpcaseStr(MailPWPrompt_);
       MailPWWait:=true;
      end;
  end;
  if MPTyp=0 then
   begin
    if pos('*+*',HStr)=1 then
     begin
      MailOeffnen(Kanal);
      delete(HStr,1,3);
     end;
    if pos('+*+',HStr)=1 then
     begin
{      MailSchliessen(Kanal);}
      delete(HStr,1,3);
     end;
    SStr:=Hstr;
   end;
  if SSTr<>'' then
   begin
    infoout(Kanal,0,0,SSTr);
    sstr:=sstr+m1;
    S_Pac(Kanal,NU,true,SStr);
   enD;
 end;
end;
end;





{****************************************}

Function OpenMailDatei (var MFile:MailDat) : word;
begin
{$I-}
 assign(MFile, sys1pfad+MailsDatei);
 reset(MFile);
 OpenMailDatei:=IoResult;
{$I+}
end;

Function CloseMailDatei (var MFile:MailDat) : word;
begin
{$I-}
 Close(MFile);
 CloseMailDatei:=IoResult;
{$I+}
end;


procedure GetMails;
var mfile:Maildat;
i:integer;
begin
 i:=OpenMailDatei(mfile);
 if i=0 then MailAnz:=FileSize(MFile);
 i:=CloseMailDatei(Mfile);
end;

Procedure MailsSortieren;
Var   x,i,j  : longInt;
      N      : longint;
      Change : Boolean;
      MFile : MailDat;
      MTyp, MTyp1, MTyp2, MTyp3 : Mail_Typ;

Begin
{if inUDB then WriteRam(1,3,Attrib[5],1,EFillStr(80,B1,B1+'Sortiere Datenbank ...'));}
GetMails;
i:=OpenMailDatei(MFile);
  N := MailAnz;
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
          Seek(MFile, j-1); read(MFile, MTyp1);
          Seek(MFile, j+x-1); read(MFile, MTyp2);
          if MTyp1.Boxcall > MTyp.BoxCall then
          begin
            MTyp3 := MTyp2;
            MTyp2 := MTyp1;
            MTyp1 := MTyp3;
            Seek(MFile, j-1); write(MFile, MTyp1);
            Seek(MFile, j+x-1); write(MFile, Mtyp2);
            j := j - x;
          end else Change := false;
        end;
        i := i + 1;
      end;
      x := x div 3;
    end;
  end;

{$I-}
 i:=closeMailDatei(MFile);
{$I+}
End;

Function MailsVorhanden (* : Boolean *);
var Anz:longint;
    check:word;
    MFile : MailDat;
    flag:boolean;
begin
 flag:=false;
 if OpenMailDatei(MFile)=0 then
  begin
   anz:=FileSize(Mfile);
   if Anz>0 then flag:=true;
   check:=CloseMailDatei(MFile);
  end;
 MailsVorhanden:=flag;
end;

Procedure MailVersucheRauf;
var MFile : MailDat;
    MTyp  : Mail_Typ;
    i     : longint;
begin
i:=0;
 if OpenMailDatei(MFile)=0 then
  begin
   if FileSize(MFile)>0 then
    begin
     seek(MFile, DPos-1);
     read(MFile, MTyp);
      if MTyp.Versuche<255 then inc(MTyp.Versuche);
     seek(MFile, DPos-1);
     write(MFile, MTyp);
    end;
     i:=CloseMailDatei(MFile);
  end;
end;



Procedure MailKillen (*Box, RX:Str10; DPos : longint*);
VAR Killed : Boolean;
    i:word;
    MFile : MailDat;
    MTyp  : Mail_Typ;
    Max,
    Lesen,
    schreiben : Longint;

begin
lesen:=0;
schreiben:=0;
Killed:=false;
 if DPOS=0 then
  begin
   if OpenMailDatei(MFile)=0 then
    begin
     Max:=FileSize(Mfile);
     while (not EOF(MFile)) and (lesen<Max) do
      begin
       seek(MFile,lesen);
       read(MFile, MTyp);
       inc (Lesen);
       if (MTyp.BoxCall=Box) and (Mtyp.ZielCall=RX) and (not Killed) then
        begin
         Killed:=true;
        end
        else
        begin
         seek (MFile,Schreiben);
         write(MFile, Mtyp);
         inc(Schreiben);
        end;
      end; {while not eof}
     seek (MFile,Schreiben);
     Truncate(MFile);
     i:=CloseMailDatei(MFile);
    end; {if openmail}
  end;
 if DPOS>0 then
  begin
   if OpenMailDatei(MFile)=0 then
    begin
     Max:=FileSize(Mfile);
     while (not EOF(MFile)) and (lesen<Max) do
      begin
       seek(MFile,lesen);
       read(MFile, MTyp);
       inc (Lesen);
       if (LESEN=Dpos) and (not Killed) then
        begin
         Killed:=true;
        end
        else
        begin
         seek (MFile,Schreiben);
         write(MFile, Mtyp);
         inc(Schreiben);
        end;
      end; {while not eof}
     seek (MFile,Schreiben);
     Truncate(MFile);
     i:=CloseMailDatei(MFile);
    end; {if openmail}
  end;
  MailInBox:=Mailsvorhanden;
end;



Procedure MailSpeichern (* Mail : Mail_typ *);
var i: longint;
    MFile: Maildat;
    MDat,
    MDatH : Mail_typ;
    Flag : boolean; {gespeichert?}

begin
 flag:=false;
{$i-}
 i:=-1;
 if OpenMailDatei(Mfile)=0 then
  begin
   While (not EOF(MFile)) and (not Flag) do
    begin
     inc(i);
     Read(MFile, MDat);
     if (MDat.BoxCall=Mail.BoxCall) and (MDat.ZielCall=Mail.ZielCall) then
      begin
       MDat.Datum:=Mail.Datum;
       MDat.Uhrzeit:=Mail.Uhrzeit;
       MDat.Port:=Mail.Port;
       Seek(MFile,i);
       Write(MFile,MDat);
       Flag:=true;
      end;
    end;
  end else REwrite(MFile); {if ioresult}
 if not Flag then write(MFile, Mail);
 i:=closeMailDatei(Mfile);
{$i+}
end;

Procedure MDatensatzHolen (Nr: longint; VAR Md:Mail_typ);
var MFile : MailDat;
    i:word;
begin
   i:=OpenMailDatei(MFile);
   if i=0 then
   begin
    seek(Mfile, Nr-1);
    read(Mfile, MD);
   end;
   i:=closeMailDatei(Mfile);
end;



Function MarkMailStr(Nr : longint; Sp : Byte) : Str80;
var UDummy : String[14];
    MUS    : String[80];
    MDat  : Mail_typ;

Begin
  if Nr>MailAnz then MarkMailStr :=''
   else
   begin
    MDatensatzHolen(nr, MDat);
    if nr>-1 then
    With Mdat do
     begin
      MUS := EfillStr(12,B1,BoxCall);
      MUS:=MUS+Efillstr(12,B1,ZielCall);
      MUS:=MUS+Efillstr(14,B1,Datum);
      MUS:=MUS+EfillStr(11,B1,Uhrzeit);
      MUS:=MUS+EfillStr(7,B1,Int_Str(Versuche));
      MUS:=MUS+EfillStr(2,B1,int_str(Port));
      MarkMailStr:=MUS;
     end;
   end;

End;

Function BoxCall (DP : longint) : str9;
var md:mail_typ;
begin
 MDatenSatzHolen(DP,Md);
 BoxCall:=Md.BoxCall;
 MailRXCall:=MD.ZielCall;
 MailBoxCall:=MD.BoxCall;
end;

Procedure MailsZeigen (* Kanal : Byte *);
Const  Bofs = 1;
Var    X : longint;
       yM,
       Bpos,
       Zmax   : Byte;
       fz:file;
       NeuDpos,
       SavDpos,
       Dpos   : longint;
       w,w1,
       AnzM,
       Result : longint;
       Flag,
       Fertig : Boolean;
       KC     : Sondertaste;
       VC,
       VA     : Char;
       f      : Text;
       Hstr,
       Sstr,
       Pfad,
       XPfad  : String[80];
       MHelp  : Mail_typ;



  Procedure DirPage(beg : Longint);
  Var      i : Byte;
  Begin
    for i := 1 to Zmax do WriteRam(1,i+Bofs,Attrib[2],1,EFillStr(80,B1,MarkMailStr(beg-1+i,1)));

    WriteRam(1,maxZ,Attrib[5],1,EFillStr(80,B1,B1+InfoZeile(49)));
  End;

  Procedure WartenSchirm;
  Var      i : Byte;
  Begin
    WriteRam(1,1,Attrib[5],1,EFillStr(80,B1,InfoZeile(47)));
    for i := 1 to Zmax do WriteRam(1,i+1,Attrib[2],1,EFillStr(80,B1,' '));

    WriteRam(1,3,Attrib[5],1,EFillStr(80,B1,B1+InfoZeile(230)));
    WriteRam(1,maxZ-1,Attrib[5],1,EFillStr(80,B1,InfoZeile(48)) );
    WriteRam(1,maxZ,Attrib[5],1,EFillStr(80,B1,B1+InfoZeile(49)));
  End;

  Procedure GetCursorLine;
  Begin
    WriteRam(1,Bpos+Bofs,Attrib[4],1,EFillStr(80,B1,MarkMailStr(Dpos,1)));
  End;

  Procedure RestAuflisten;
  var i: byte;
      i2:longint;
  Begin
   i2:=DPos;
   for i:=BPos to zmax do
    begin
     WriteRam(1,i+Bofs,Attrib[2],1,EFillStr(80,B1,MarkMailStr(i2,1)));
     inc(I2);
    end;
  End;

  Procedure InitStart(Art : Byte; Bstr : Str12);
  Var    w    : longint;

         Flag : Boolean;
         Vpos : Byte;
         call1,
         call2: string[8];
  Begin
   WartenSchirm;
    Vpos := Bpos;
    yM := 1;
    Bpos := 1;
    Dpos := 1;
    AnzM := 0;
    GetMails;
    if Art = 1 then
     begin
      DirPage(Dpos);
     end;
  End;

  Procedure CursorDn;
  Begin
    if Dpos < MailAnz then
    begin
      inc(Dpos);
      if Bpos < Zmax then inc(Bpos) else
      begin
        WriteAttr(1,yM+Bofs,80,Attrib[2],1);
        Scroll(Up,1,1+Bofs,Zmax+Bofs);
        WriteRam(1,Bpos+Bofs,Attrib[4],1,MarkMailStr(Dpos,1));
      end;
    end else Alarm;
  End;


Begin
{  INUdb:=true;}
  Moni_Off(0);
  DirScroll := true;
  NowFenster := false;
  Zmax := maxZ - 3;
  Fertig := false;
  X := 1;

  InitStart(1,'');
  WriteAttr(1,Bpos+Bofs,80,Attrib[4],1);

  Repeat
    InitCursor(X,Bpos+Bofs);
    hstr:=int_Str(DPos);
    if MailAnz=0 then hstr:='0';
    WriteRam(1,maxZ-1,Attrib[5],1,EFillStr(80,B1,InfoZeile(48)+' '+hstr+'/'+int_str(MailAnz)));
    WriteRam(1,1,Attrib[5],1,EFillStr(80,B1,InfoZeile(47)));
     GetCursorLine;
    _ReadKey(KC,VC);


    case KC of
      _Esc
       : begin
           Fertig := true;
         end;

      _Dn
       : CursorDn;

      _Up
       : if Dpos > 1 then
         begin
           dec(Dpos);
           if Bpos > 1 then dec(Bpos) else
           begin
             WriteAttr(1,yM+Bofs,80,Attrib[2],1);
             Scroll(Dn,1,1+Bofs,Zmax+Bofs);
             WriteRam(1,Bpos+Bofs,Attrib[4],1,MarkMailStr(Dpos,1));
           end;
         end else Alarm;

      _PgDn
       : if Dpos < MailAnz then
         begin
           if Dpos + Zmax - Bpos >= MailAnz then
           begin
             Dpos := MailAnz;
             Bpos := Zmax;
             if Bpos > MailAnz then Bpos := MailAnz;
           end else
           begin
             Dpos := Dpos + Zmax - 1;
             if Dpos + Zmax - 1 > MailAnz then Dpos := MailAnz - Zmax + Bpos;
             DirPage(Dpos - Bpos + 1);
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
             DirPage(Dpos - Bpos + 1);
           end;
         end else Alarm;

      _Home
       : if Dpos > 1 then
         begin
           Dpos := 1;
           Bpos := 1;
           DirPage(1);
         end else Alarm;

      _End
       : if Dpos < MailAnz then
         begin
           Dpos := MailAnz;
           Bpos := Zmax;
           if Bpos > MailAnz then Bpos := MailAnz;
           DirPage(Dpos - Bpos + 1);
         end else Alarm;


      _Ret
       : begin
          if (not fwd_) and (MailAnz>0) then
           begin
            MailVersucheRauf (DPos);
            StartMailPolling(Kanal,BoxCall(Dpos));
            Fertig:=true;
           end else alarm;
         end;

      _altd, _del
       : begin
          if MailAnz>0 then
          begin
           SavDpos:=Dpos;
           if (SiAltD) then
            begin
             WriteRam(1,Bpos+Bofs,Attrib[5],1,EFillStr(80,B1,B2+InfoZeile(224)));
             _ReadKey(KC,VC);
            end;
           if (KC = _Ret) or (UpCase(VC) in YesMenge) or (not SiAltD) then
           begin
            userkilled:=dpos;
            MailKillen('','',DPOS);
           { InitStart(1,'');}
            GetMails;
            if MailAnz>savDpos then
             begin
              DPos:=SavDpos;

              if ((MailAnz-dpos)<ZMax) and (MailAnz>=ZMax) then
               begin
                BPos:=ZMax-(MailAnz-dPos);
                DirPage(Dpos-Bpos+1);
               end else RestAuflisten;
             end
             else
              begin
               DPOs:=MailAnz;
               BPos:=ZMax;
               if MailAnz<ZMax then BPos:=MailAnz;

               if MailAnz<1 then
                begin
                 Bpos:=1;
                 Dpos:=1;
                end;
               DirPage(Dpos-Bpos+1);
              end;
           { yM := 1;
            AnzM := 0;
            BPos:=1;
            DirPage(Dpos);}
           end;
         end;
         end;

      _AltH
       : XP_Help(G^.OHelp[93   ]);

     { _ALTS
       : begin
          BoxSuchen(DPOs,'');
          BPos:=1;
          DirPage(Dpos);
         end;}


      else Alarm;
    end;

    WriteAttr(1,yM+Bofs,80,Attrib[2],1);
    WriteAttr(1,Bpos+Bofs,80,Attrib[4],1);
    yM := Bpos;
  Until Fertig;
  DirScroll := false;
  Moni_On;
  InUDB:=false;
End;








