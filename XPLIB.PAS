{⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
 ≥                                                                         ≥
 ≥                             X - P a c k e t                             ≥
 ≥                                                                         ≥
 ≥                                                                         ≥
 ≥  X P L I B . P A S    Bestandteil der XPACT1.PAS                        ≥
 ≥                                                                         ≥
 ≥ Library - Unit mit oft benîtigten Routinen                              ≥
 ¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ}



Function  Channel_ID (* Kanal : Byte) : Str5 *);
Var    Bstr : String[5];
Begin
  Bstr := TNC[K[Kanal]^.TncNummer]^.Ident;
  if length(Bstr) > 0 then Bstr := Bstr + B1;
  Channel_ID := Bstr;
End;


Procedure Warten;
Var  KC : Sondertaste;
     VC : Char;
Begin
  Repeat Until _Keypressed;
  _ReadKey(KC,VC);
End;


Procedure Triller;
Var  i : Byte;
Begin
  for i := 1 to 6 do
  begin
    Beep(600,50);
    Beep(800,50);
  end;
End;

PROCEDURE Warte (HdstlSec : WORD);
VAR wi : INTEGER;
    wstd1, wmin1, wsec1, wsec1001 : Word;
    wstd2, wmin2, wsec2, wsec1002 : Word;
    wrsec, wrstd, wrmin, wrsec100 : word;
BEGIN
    GETTIME (wstd1, wmin1, wsec1, wsec1001);
    wrsec100 := 0;
    wi := 0;
    WHILE wrsec100 < HdstlSec DO
          BEGIN
            wi := wi + 1;
            GETTIME (wstd2, wmin2, wsec2, wsec1002);
            wrstd := wstd2 - wstd1;
            wmin2 := wmin2 + (wrstd * 60);
            wrmin := wmin2 - wmin1;
            wsec2 := wsec2 + (wrmin * 60);
            wrsec := wsec2 - wsec1;
            wsec1002 := wsec1002 + (wrsec * 100);
            wrsec100 := wsec1002 - wsec1001;
          END;
END;


(*
Procedure Bimmel;
Const
 Ton : array[1..8] of integer =
   (670,530,595,400,400,595,670,530);

 PauseT : array[1..8] of byte =
   (40, 40, 40, 60, 40, 40, 40, 60);

 PauseN : array[1..8] of byte =
   (0, 0, 0, 60, 0, 0, 0, 0);

Var  i : Byte;
     kc: sondertaste;
     vc:char;

Begin
 I:=0;
  while (i<8) and (not keypressed) do
   begin
    inc(i);
    Sound_(Ton[i], PauseT[i]); Warte(PauseN[i]);
   end;
  if keypressed then _ReadKey(KC,VC);
End;
*)

Procedure Bimmel(kan:byte);

type
  BimmelTon = Record
   Ton, Lange : Word;
  end;

Const BT2: array[0..8] of bimmelton =
      ((Ton:670; Lange:40), (Ton:530; Lange:40), (Ton:595; Lange:40),
       (Ton:400; Lange:60), (Ton:0; Lange:60),
       (Ton:400; Lange:40), (Ton:595; Lange:40), (Ton:670; lange:40),
       (Ton:530; lange:60));

var BT: array[0..255] of bimmelton;
    f: text;
    s:string;

    j,i:byte;
    rem:boolean;
    kc: sondertaste;
    vc:char;
    fst:file;

Begin
s:='';
s:=int_str(kan);
rem:=false;

{$IFDEF Sound}
if Konfig.WavOut then
 begin
  s:='RING'+s;
  rem:=exists(Konfig.SpkVerz+s+'.wav');

  if rem then WavStream:=WavStream+#2+EFillStr(8,B1,s)
   else
    begin
     s:='RING';
     rem:=exists(Konfig.SpkVerz+s+'.wav');
     if rem then WavStream:=WavStream+#2+EFillStr(8,B1,s);
    end;
 end;


if Konfig.MidiOut then
 begin
  rem:=playmidi(konfig.spkverz+'RING'+s+'.MID');
  if not rem then rem:=playmidi(konfig.spkverz+'RING.MID');
 end;

{$ENDIF}

s:='';
if not rem then begin

fillchar(bt,sizeof(bt),0);
{$I-}
assign(f,Sys1Pfad+'RING.XP');
reset(f);
j:=0;
if ioresult=0 then
 begin
  while not eof(F) do
   begin
    Rem:=false;
    readln(f, s);
    if S[1]<>';' then
     begin
      BT[j].Ton := str_int(copy (s,1,pos(',',s)-1));
      delete (s,1,pos(',',s));
      BT[j].Lange := str_int(s);
      inc(j);
     end;
   end;
  close(F);
  if ioresult=0 then i:=0;
 end else for i:=0 to 8 do BT[i]:=BT2[i];
{$I+}

i:=0;

Repeat
  if (BT[i].Lange>0) then
  begin
   if (BT[i].Ton)>0 then Sound_(BT[i].Ton,BT[i].Lange)
   else warte(BT[i].Lange);
  end else i:=254;
  inc(i);
until (keypressed) or (i=255);

{ Folgende Zeile entfernt, damit beim Abbrechen von //ring und //bell kein
  Tastendruck mehr verschluckt wird! //db1ras }
{ if keypressed then _ReadKey(KC,VC); }

end;
End;

Procedure StopWave_;
begin
{$IFDEF Sound}
if not Playing then
 begin
  if SoundBuffer<>NIL then StopWave;
  WavFileOpen:=False;
 end;
{$ENDIF}
end;

Procedure SprachWav;
var i:byte;
wavs:string;
begin
{$IFDEF Sound}
{Strip(Zeile);
for i:=1 to length(Zeile) do
 begin}
 wavs:='';
 if playing then wavfileopen:=true;
 if not playing then
  begin
   StopWAVE;
   wavs:=Konfig.Spkverz+WavStream[1];
   if WavStream[1]=#10 then Wavs:=Konfig.Spkverz+'10';
   if WavStream[1]=#11 then Wavs:=Konfig.Spkverz+'11';
   if WavStream[1]=#12 then Wavs:=Konfig.Spkverz+'12';
   if WavStream[1]=#13 then Wavs:=Konfig.Spkverz+'13';
   if WavStream[1]=#14 then Wavs:=Konfig.Spkverz+'14';
   if WavStream[1]=#15 then Wavs:=Konfig.Spkverz+'15';

   if wavstream[1]=#1 then {Connect-Bimmel}
    begin
     wavs:=Copy(WavStream,2,8);
     KillEndBlanks(wavs);
     delete(WavStream, 2,8);
     wavs:=Konfig.SpkVerz+wavs;
    end;

   if wavstream[1]=#2 then {Disconnect}
    begin
     wavs:=Copy(WavStream,2,8);
     KillEndBlanks(wavs);
     delete(WavStream, 2,8);
     wavs:=Konfig.SpkVerz+wavs;
    end;

   if wavstream[1]=#3 then {Reconnect}
    begin
     wavs:=Copy(WavStream,2,8);
     KillEndBlanks(wavs);
     delete(WavStream, 2,8);
     wavs:=Konfig.SpkVerz+wavs;
    end;

   if wavstream[1]=#4 then {Bimmel}
    begin
     wavs:=Copy(WavStream,2,8);
     KillEndBlanks(wavs);
     delete(WavStream, 2,8);
     wavs:=Konfig.SpkVerz+wavs;
    end;

   if wavstream[1]=#5 then {Weitercon-Bimmel}
    begin
     wavs:=Copy(WavStream,2,8);
     KillEndBlanks(wavs);
     delete(WavStream, 2,8);
     wavs:=Konfig.SpkVerz+wavs;
    end;

   playwave(wavs +'.wav');
   delete(wavstream, 1,1);
  end;
{repeat until not Playing;
 end;}
{$ENDIF}
end;



Procedure C_Bell;

type
  BimmelTon = Record
   Ton, Lange : Word;
  end;

Const BT2: array[0..8] of bimmelton =
      ((Ton:1400; Lange:5), (Ton:1000; Lange:5), (Ton:1800; Lange:5),
      (Ton:1400; Lange:5), (Ton:1000; Lange:5), (Ton:1800; Lange:5),
      (Ton:1400; Lange:5), (Ton:1000; Lange:5), (Ton:1800; Lange:5));

var BT: array[0..255] of bimmelton;
    f: text;
    s:string;
    j,i:byte;
    rem:boolean;
    kc: sondertaste;
    vc:char;
    fst:file;

Begin
s:=call;
strip(s);
rem:=false;

{$IFDEF Sound}
if Konfig.WavOut then
 begin
   rem:=exists(konfig.spkverz + s+'.WAV');
   if rem then WavStream:=WavStream+#1+EFillStr(8,B1,s)
    else
     begin
       s:='';
       s:=int_str(kan);
       s:='CBELL'+s;
       rem:=exists(konfig.spkverz + s + '.WAV');
       if rem then WavStream:=WavStream+#1+EFillStr(8,B1,s)
        else
         begin
          s:='CBELL';
          rem:=exists(konfig.spkverz+s+'.wav');
          if rem then WavStream:=WavStream+#1+EFillStr(8,B1,s)
         end;
     end;
 end;

If Konfig.MidiOut then
begin;
 s:=call;
 strip(s);
 rem:=playmidi(konfig.spkverz+s+'.MID');
 s:='';
 s:=int_str(kan);
 if not rem then rem:=playmidi(konfig.spkverz+'CBELL'+s+'.MID');
 if not rem then rem:=playmidi(konfig.spkverz+'CBELL.MID');
end;

{$ENDIF}

if not rem then
 begin
s:=call;
strip(s);

fillchar(bt,sizeof(bt),0);
{$I-}

assign(f,Sys1Pfad+s+'.CBL');
reset(f);
j:=0;
if ioresult=0 then
 begin
  while not eof(F) do
   begin
    Rem:=false;
    readln(f, s);
    if S[1]<>';' then
     begin
      BT[j].Ton := str_int(copy (s,1,pos(',',s)-1));
      delete (s,1,pos(',',s));
      BT[j].Lange := str_int(s);
      inc(j);
     end;
   end;
  close(F);
  if ioresult=0 then i:=0;
 end else for i:=0 to 8 do BT[i]:=BT2[i];
{$I+}
i:=0;

Repeat
  if (BT[i].Lange>0) then
  begin
   if (BT[i].Ton)>0 then Sound_(BT[i].Ton,BT[i].Lange)
   else warte(BT[i].Lange);
  end else i:=254;
  inc(i);
until (i=255);

{ Folgende Zeile entfernt, damit beim Connect kein Tastendruck mehr
  verschluckt wird! //db1ras }
{ if keypressed then _ReadKey(KC,VC); }
end;
End;


(*
Var  i : Byte;
Begin
 if (Klingel) then
 begin
  for i := 1 to 3 do
  begin
   sound_(1400,5);
   sound_(1000,5);
   sound_(1800,5);
  end;
 end;
End;
  *)

Procedure D_Bell;         (* Klingel beim Disconnect *)
var rem:boolean;
var s:string[5];
Begin
s:='';
s:=int_str(kan);
rem:=false;

{$IFDEF Sound}
if Konfig.WavOut then
 begin
  s:='dbell'+s;
  rem:=exists(Konfig.SpkVerz+s+'.wav');
  if rem then WavStream:=WavStream+#2+EFillStr(8,B1,s)
   else
    begin
     s:='DBELL';
     rem:=exists(Konfig.SpkVerz+s+'.wav');
     if rem then WavStream:=WavStream+#2+EFillStr(8,B1,s);
    end;
 end;

if Konfig.MidiOut then
 begin
  rem:=playmidi(konfig.spkverz+'DBELL'+s+'.MID');
  if not rem then rem:=playmidi(konfig.spkverz+'DBELL.MID');
end;

{$ENDIF}

if not rem then
 begin

   sound_(1800,5); warte(5);
   sound_(1400,5); warte(5);
   sound_(1000,5); warte(5);
 end;
End;


Procedure Daten_Bell;
Begin
  sound_(1800,5);
  sound_(1400,5);
  sound_(1800,5);
End;


Function Datum (* : Str11 *);
Var    Tag,
       WoTag,
       Monat,
       Jahr      : Word;
       TagStr,
       WoTagStr,
       MonatStr,
       JahrStr   : String[2];
       Dummy     : String[8];

Begin
  Dummy := Uhrzeit;

  TagStr := SFillStr(2,'0',int_str(Tag_));
  MonatStr := SFillStr(2,'0',int_str(Monat_));
  JahrStr := copy(int_str(Jahr_),3,2);

  WochenTag := ParmStr(WoTag_+1,B1,WeekDayStr);
  WotagStr := copy(WochenTag,1,2);

  Datum := WotagStr + B1 + TagStr + Pkt  + MonatStr + Pkt  + JahrStr;
End;

Procedure GetTime_ (* (Hr, Mn, Sk, Sk100 : Word) *) ;
var Flag:Boolean;
begin
  if RTC then
  begin
    Repeat
      Port[$70] := 10;
    Until Port[$71] and $80 = 0;

    Port[$70] := 11;
    Flag := (Port[$71] and 4) = 0;

    Port[$70] := 0; Sk := Port[$71];
    Port[$70] := 2; Mn  := Port[$71];
    Port[$70] := 4; Hr  := Port[$71];

    if Flag then
    begin
      Sk := (Sk shr 4) * 10 + Sk and 15;
      Mn  := (Mn  shr 4) * 10 + Mn  and 15;
      Hr  := (Hr  shr 4) * 10 + Hr  and 15;
    end;
  end else GetTime(Hr,Mn,Sk,Sk100);
end;

Function Uhrzeit (* : Str8 *);
Var
      Sek100,
      UtcStd   : Word;
      Flag     : Boolean;
      Hstr     : String[8];
      LTCheck  : Longint;
Begin
  GetTime_(Stunde,Minute,Sekunde,Sek100);
{$IFNDEF no_Netrom} {//db1ras}
  if (Konfig.MaxNodes>0) and (minute<>lminute) then
   begin
    lminute:=minute;
    LTCheck := PackDT;
    if ((LTCheck-LastLTCheck)>=150) and (not InNodeListe) then {alle 5 minuten prÅfen}
    begin
     LastLTCheck:=LTCheck;
     NodesLifeTime;
    end;
   end;
{$ENDIF}



  UtcStd := Stunde;
  UtcStd := UtcStd + 24 + ZeitDiff;
  While UtcStd > 23 do UtcStd := UtcStd - 24;

  Hstr := SFillStr(2,'0',int_str(Stunde)) + DP +
          SFillStr(2,'0',int_str(Minute)) + DP +
          SFillStr(2,'0',int_str(Sekunde)) + DP;

  UtcZeit := SFillStr(2,'0',int_str(UtcStd)) + copy(Hstr,3,6);
  Uhrzeit := Hstr;
End;


Function GetCursorSize : Integer; (* Liefert Cursorgroesse (aus PCT von DD6CV) *)
Var   r : Registers;
Begin
  r.AH := $03;
  intr($10,r);
  GetCursorSize := r.CX;
End;


Procedure SetCursorSize(Size : Integer); (* Setzt Cursorgroesse (aus PCT von DD6CV) *)
Var  r : Registers;
Begin
  r.AH := $01;
  r.CX := Size;
  intr($10,r);
End;


Procedure Cursor_aus;      (* Schaltet Cursor aus. (aus PCT von DD6CV) *)
Const CursorOffBit = 8192;
Begin
  SetCursorSize(GetCursorSize or CursorOffBit);
  Cursor_On := false;
End;


Procedure Cursor_ein;     (* Schaltet Cursor ein.  (aus PCT von DD6CV) *)
Const CursorOnMask = -8193;
Begin
  SetCursorSize(GetCursorSize and CursorOnMask);
  Cursor_On := true;
End;


Procedure Beep (* Ton,Laenge : Word*);
Begin
  if Laenge > 0 then
  begin
    Sound_(Ton,Laenge div 14);
  end;
End;


Procedure Fenster (* H:Byte *);
Var  i,x,y : Byte;
     Attr  : Byte;

Begin
  Attr := Attrib[3];
  x := 1;
  Teil_Bild_Loesch(7,h,Attr);
  x := 40-(length(G^.Fstr[7]) DIV 2);
  WriteRam(2,6,Attr,1,ConstStr('Õ',78));
  WriteRam(2,h+1,Attr,1,ConstStr('Õ',78));
  WriteRam(1,6,Attr,1,'…'); WriteRam(80,6,Attr,1,'ª');
  WriteRam(1,h+1,Attr,1,'»'); WriteRam(80,h+1,Attr,1,'º');
  for i:=7 to h do
   begin
    if i<> 8 then
     begin
      WriteRam(1,i,Attr,1,'∫');
      WriteRam(80,i,Attr,1,'∫');
     end
     else
      begin
       WriteRam(1,i,Attr,1,'«');  {'Ã');}
       WriteRam(80,i,Attr,1,'∂'); {'π');}
      end;
   end;
  WriteRam(x,7,Attr,1,G^.Fstr[7]);
  WriteRam(2,8,Attr,1,ConstStr('ƒ',78));   {Õ}
  for i := 9 to 20 do WriteRam(G^.Fstx[i],i,Attr,1,G^.Fstr[i]);
End;


Procedure clrFenster;
Var       i : Byte;
Begin
  for i := 7 to 20 do G^.Fstr[i] := '';
  for i := 7 to 20 do G^.Fstx[i] := 2;
End;


Procedure Status2;
Var   AByte,
      Beg,
      Ende,
      C,i,
      Z,UT : Byte;
      ch   : Char;
      Hstr : String[80];
      Xstr : String[6];
      Flag : Boolean;

Begin
 if not OnlHelp then
 begin
  i := 0;
  Repeat
    Flag := not (i in [Portstufe+1..Portstufe+10]) and K[i]^.connected;
    inc (i);
  Until (i > maxLink) or Flag;

  if Flag then ch := '*'
          else ch := B1;

  Hstr := ch;

  Beg := PortStufe + 1;
  Ende := Beg + 9;
  if Ende > maxLink then Ende := maxLink;
  for C := Beg to Ende do with K[C]^ do
  begin
    if (connected) then
    begin
      Xstr := Call;
      Strip(Xstr);
    end else
    if Test then Xstr := 'T (' + int_str(TestMerk) + ')' else
    begin
       Xstr := '  '; {#7+#7;}
       if c<10 then Xstr:=xstr+' ';
       xstr:=xstr+int_str(C)+'  '; {#7+#7};
    end;

    if Mo.MonActive then
    begin
      Xstr := CutStr(Mo.MonStr[1]);
      strip(Xstr);
    end;
    if (C > 0) and (C = ConvHilfsPort) then Xstr := 'SYSOP';
    Xstr := EFillStr(6,B1,Xstr);
    Hstr := Hstr + KStatTr;
    Hstr := Hstr + Xstr;
  end;
  Hstr := Hstr + KStatTr;
  Hstr := EFillStr(80,B1,Hstr);
  UT := K[show]^.UnStat;
  WriteRam(1,UT,Attrib[15],1,Hstr);
  if show = 0 then i := Unproto
              else i := K[show]^.TncNummer;
   WriteRam(73,UT,Attrib[30],1,SFillStr(8,B1,TNC[i]^.QRG_Akt));

  Z := 0;
  for C := Beg to Ende do
  begin
    inc(Z);
    with K[C]^ do
    begin
      if (show = C)
         then AByte := Attrib[17]
         else if (NochNichtGelesen) then AByte := Attrib[8]
         else if Mo.MonActive then AByte := Attrib[25]
         else if connected then AByte := Attrib[16]
         else AByte := Attrib[15];
      WriteAttr((Z*6)+Z-4,UT,6,AByte,1);
    end;
  end;

  if maxLink > 10 then for C := 1 to maxLink do with K[C]^ do
  begin
    if NochNichtGelesen and not (C in [(Portstufe+1)..(Portstufe+10)]) then
    begin
      Hstr := EFillStr(6,B1,'CH:' + int_str(C));
      Z := C mod 10;
      if Z = 0 then Z := 10;
      i := show mod 10;
      if i = 0 then i := 10;
      if Z <> i then AByte := Attrib[8]
                else AByte := Attrib[17];
      WriteRam((Z*6)+Z-4,UT,AByte,1,Hstr);
    end;
  end;
 end; {if not OnlHelp ... }
End;


Procedure Alarm;
Begin
  if Klingel then Beep(G^.Alarm_Freq,G^.Alarm_Time);
End;


Procedure StatusOut (* Kanal,x,Nr,Attr : Byte ; Zeile : string ; StZ : Byte *);
Var   N,Nx,i,Soz : Byte;
      FlagZeil   : String;

Begin
if Not OnlHelp then
 begin
  with K[Kanal]^ do
  begin
    N := (((NrStat[Nr]-1) * 40) + (2 * x) - 1);
    Nx := (NrStat[Nr]-1) * 40 + 1;

    if stz=1 then
     begin

      for i := 1 to ord(Zeile[0]) do
       begin
        StatZeile[N] := Zeile[i];
        inc(N);
        StatZeile[N] := chr(Attr);
        inc(N);
       end;
      end;
     if stz=2 then
       begin
        for i := 1 to ord(Zeile[0]) do
         begin
          FlagZeile[N] := Zeile[i];
          inc(N);
          FlagZeile[N] := chr(Attr);
          inc(N);
         end;
       end;
     if stz=3 then
       begin
        for i := 1 to ord(Zeile[0]) do
         begin
          FlagZeile2[N] := Zeile[i];
          inc(N);
          FlagZeile2[N] := chr(Attr);
          inc(N);
         end;
       end;

    if not ScreenSTBY then
    begin
      if (Kanal = show) and not DirScroll then
      begin
        if not Backscroll(show)  { and (nr <>1)}
         then
          begin
           move(StatZeile,Bild^[(ObStat-1)*160+1],160);
           move(FlagZeile,Bild^[(ObStat)*160+1],160);
           move(FlagZeile2,Bild^[(ObStat+1)*160+1],160);
          end;
      end;
    end;
  end;
 end; {if not onlhelp ...}
End;


Procedure NodeConnect (* Kanal : Byte; Zeile : Str80 *);
Var  i    : Byte;
     Bstr,
     Hstr : String[80];
Begin
  with K[Kanal]^ do
  begin
    Hstr := Zeile;
    if length(Zeile) > 1 then NodeCmd := false;
    Zeile := CutStr(Zeile);

    if Zeile > '' then
    begin
      Bstr := InfoZeile(216);
      while (Bstr > '') and not NodeCmd do
      begin
        if pos(Zeile,CutStr(Bstr)) = 1 then NodeCmd := true
                                       else Bstr := RestStr(Bstr);
      end;
      if NodeCmd then ConnectMerk := Hstr;
    end;
  end;
End;


Function  Exists (* name : Str80) : Boolean *);
Var       Datei  : Text;
          ExFlagi : Boolean;
          dummio : byte;
Begin
  ExFlagi:=false;
  if Name > '' then
  begin
   {$I-}
    Assign(Datei,name);
    Reset(Datei);
    if IOResult = 0 then
    begin
      Exflagi:= true;
    end else Exflagi:= false;
    close(Datei);
    dummio:=ioresult;
   {$I+}
  end else Exflagi:= false;
  Exists:=ExFlagi;
End;


Procedure Teil_Bild_Loesch (* y,y1,Attr : Byte *); (* Zeilen von y bis y1 lîschen *)
Begin
  if not ScreenSTBY then
  Asm   les  di, Bild

        mov  al, y
        dec  al
        mov  ah, 160
        mul  ah
        add  di, ax

        mov  al, y1
        mov  ah, 160
        mul  ah
        sub  ax, di
        mov  cx, ax

        mov  al, 32
        mov  ah, Attr             { Attribut laden  }
        shr  cx, 1
@Again:
        mov  [es:di], ax          { Zeichen mit Attr Åbertragen }
        add  di, 2
        Loop @Again

  end;
End;


Procedure InfoOut;    (* Kanal,AL,NewPic : Byte; Zeile : Str80 *)
Var     AMerk,
        Tr,x,l : Byte;
Begin
 if (not OnlHelp) and (not K[kanal]^.Mo.MonActive) then
  begin
  if length(Zeile) > 78 then Zeile[0] := Chr(78);
  if (K[Kanal]^.Rx_Bin>0) or (K[kanal]^.SPlSave) or (K[kanal]^.xbin.rx) then K[Kanal]^.LstRXInfo:=Zeile
      else K[Kanal]^.LstRXInfo:='';
  if (K[Kanal]^.FileSend) or (K[kanal]^.xbin.tx) then K[Kanal]^.LstTXInfo:=Zeile else K[Kanal]^.LstTXInfo:='';
  if (Kanal = show) and not BackScroll(Kanal) then
  begin
    if NewPic = 1 then Neu_Bild;
    if Kanal > 0 then Tr := K[Kanal]^.QBeg
                 else Tr := K[Kanal]^.UnStat + 1;
    if not HardCur and (length(Zeile) < 76) then Zeile := B1 + Zeile + B1;
    if volle_Breite then Zeile := EFillStr(78,B1,Zeile);
    l := length(Zeile);
    x := (80 - l) div 2;
    XL := x;
    XR := x + l + 2;
    WriteRam(x,Tr,15,1,'⁄' + ConstStr('ƒ',l) + 'ø');
    WriteRam(x,Tr+1,15,1,'≥' + Zeile + '≥');
    WriteAttr(x+1,Tr+1,l,Attrib[3],1);
    WriteRam(x,Tr+2,15,1,'¿' + ConstStr('ƒ',l) + 'Ÿ');
    if LastInfoFlag then
       WriteRam(x+1,Tr,15,1,B1+int_str(LastInfoOut^.KA[LastInfoCount])+B1);
    NowFenster := true;
    if (not K[Kanal]^.FileSend) and (K[Kanal]^.RX_Bin<1)
       and ((not K[kanal]^.xbin.rx) and (not K[kanal]^.xbin.tx)) then BoxZaehl := Box_Time
     else BoxZaehl:=0;
    NowCurBox := true;
    if (AL = 1) and Klingel then Beep(G^.PopFreq,G^.PopFreqTime);

    if not LastInfoFlag then
    begin
      for l := maxInfoOut-1 downto 1 do
      begin
        LastInfoOut^.IZ[l+1] := LastInfoOut^.IZ[l];
        LastInfoOut^.KA[l+1] := LastInfoOut^.KA[l];
      end;
      LastInfoCount := 0;
      LastInfoOut^.IZ[1] := Zeile;
      LastInfoOut^.KA[1] := Kanal;
      KillEndBlanks(LastInfoOut^.IZ[1]);
      KillStartBlanks(LastInfoOut^.IZ[1]);
    end;
    set_Hardwarecursor(Kanal);
    K[Kanal]^.MerkInfo := '';
  end else K[Kanal]^.MerkInfo := Zeile;
 end; {if not OnlHelp ... }
End;


Procedure max_path_ermitteln;
Var       Hstr : String[80];
Begin
  maxPath := 0;
  FiResult := ResetTxt(G^.LinkFile);
  Repeat
    Readln(G^.LinkFile,Hstr);
    if pos(DP,Hstr) > 0 then inc(maxPath);
  Until Eof(G^.LinkFile);
  FiResult := CloseTxt(G^.LinkFile);
End;


Procedure WriteAttr (* X_Pos,Y_Pos,Count,Attr,Aufruf : Byte *);
Begin
  if not ScreenSTBY then
  begin
    if not ((Aufruf = 0) and BackScroll(show)) then
    Asm   xor  ch, ch
          mov  cl, Count
          cmp  cl, 0
          je   @Ende

          les  di, Bild

          mov  al, Y_Pos
          dec  al
          mov  ah, 160
          mul  ah
          add  di, ax

          mov  al, X_Pos
          shl  al, 1
          dec  al
          xor  ah, ah
          add  di, ax

          mov  al, Attr         { Attribut laden, }
   @Again:
          mov  [es:di], al       { und schreiben }
          add  di, 2
          loop @Again
   @Ende:

    end;
  end;
End;


Procedure WritePage (* Kanal,X_Pos,Y_Pos,Attr,Aufruf : Byte ; Zeile : Str80 *);
Var  Attr1 : Byte;
     Zeile2:string;
     i,i2:byte;
     itab:byte;
     U_FArb_Green:Boolean;
Begin
 zeile2:='';
 itab:=8;
 for i:=1 to length(zeile) do
  begin                         {or (zeile[1]=^J)}
   if (itab=0) or (zeile[i]=#13) then itab:=8;
   dec(itab);
   if kanal>0 then
    begin
     if zeile[i]<>#9 then Zeile2:=zeile2+zeile[i]
                     else
                      begin
                        zeile2:=zeile2+efillstr(itab,B1,'');
                        itab:=9;
                      end;
    end else zeile2:=zeile;
  end;

  if not ScreenSTBY then
  begin
    if (Aufruf = 1) or (Kanal = show) then
    begin
      Attr1 := Attrib[1];
      AusStr := Zeile2;
      U_Farb_Green:=Not SoZeichen;



{     Asm   mov  si, Offset AusStr
            xor  ch, ch
            mov  cl, [ds:si]
            test cl, $FF
            jz   @Ende
            inc  si

            les  di, Bild

            mov  al, Y_Pos
            mov  ah, 160
            dec  al
            mul  ah
            mov  di, ax
            mov  al, X_Pos
            shl  al, 1
            dec  al
            dec  al
            xor  ah, ah
            add  di, ax
            cld
    @Again:
            mov  ah, Attr
            lodsb
            cmp  al, 32
            jae  @Weiter
            test al, $FF
            jz   @Weiter

            mov  ah, Attr1
            mov  bl, WCTRL
            test bl, $FF
            jz   @1
            add  al, 64
        @1:

   @Weiter:
            mov  [es:di], ax
            add  di, 2
            Loop @Again
    @Ende:}


    Asm   mov  si, Offset AusStr
            xor  ch, ch
            mov  cl, [ds:si]
            test cl, $FF
            jz   @Ende
            inc  si

            les  di, Bild

            mov  al, Y_Pos
            mov  ah, 160
            dec  al
            mul  ah
            mov  di, ax
            mov  al, X_Pos
            shl  al, 1
            dec  al
            dec  al
            xor  ah, ah
            add  di, ax
            cld

    @Again:
            mov  ah, Attr
            lodsb
            cmp  al, 32
            jae  @Weiter
            test al, $FF
            jz   @Weiter

            mov  bl, WCTRL
            test bl, $FF
            test U_FARB_GREEN, 1
            jz   @Weiter
            mov  ah, Attr1
            add  al, 64
            jz   @1
        @1:


   @Weiter:
            mov  [es:di], ax
            add  di, 2
            Loop @Again
    @Ende:


      end;
    end;
  end;
End;


{
Procedure WritePage (* Kanal,X_Pos,Y_Pos,Attr : Byte ; Zeile : Str80 *);
var Attr1,i   : Byte;
    ch        : char;
    Position  : Integer;
    aktuell   : Boolean;
Begin
  if not ScreenSTBY then
  begin
    if (Aufruf = 1) or (Kanal = show) then
    begin
      Position := pred(Y_Pos) * 160 + pred(X_Pos shl 1);
      for i := 1 to length(Zeile) do
      Begin
        ch := Zeile[i];
        if ch < #32 then
        begin
          Attr1 := Attrib[1];
          if WCTRL then ch := chr(ord(ch) + 64);
        end else Attr1 := Attr;
        Bild^[Position] := ch;
        inc(Position);
        Bild^[Position] := chr(Attr1);
        inc(Position);
      end;
    end;
  end;
End;
}


Procedure WriteRam (* X_Pos,Y_Pos,Attr,Aufruf : Byte; Zeile : Str80 *);
Begin
  if not ScreenSTBY then
  begin
    if not ((Aufruf = 0) and BackScroll(show)) then
    begin
      AusStr := Zeile;
      Asm   mov  si, Offset AusStr
            xor  ch, ch
            mov  cl, [ds:si]
            test cl, $FF
            jz   @Ende
            inc  si

            les  di, Bild

            mov  al, Y_Pos
            mov  ah, 160
            dec  al
            mul  ah
            mov  di, ax
            mov  al, X_Pos
            shl  al, 1
            sub  al, 2
            xor  ah, ah
            add  di, ax
            mov  ah, Attr

            cld
    @Again:
            lodsb
            mov  [es:di], ax
            add  di, 2
            Loop @Again
    @Ende:
      end;
    end;
  end;
End;

{
Procedure WriteRam(X_Pos,Y_Pos,Attr,Aufruf : Byte ; Zeile : Str80);
var i         : Byte;
    ch        : char;
    ch1       : char;
    Position  : Integer;
Begin
  if not ScreenSTBY then
  begin
    ch1 := chr(Attr);
    Position := (pred(Y_Pos) * 160) + pred(X_Pos shl 1);
    if not ((Aufruf = 0) and BackScroll(show)) then
    begin
      for i := 1 to ord(Zeile[0]) do
      Begin
        Bild^[Position] := Zeile[i];
        Position := Succ(Position);
        Bild^[Position] := ch1;
        Position := Succ(Position);
      end;
    end;
  end;
End;
}

Procedure WriteTxt (* X_Pos,Y_Pos,Attr : Byte; Zeile : Str80 *);
Begin
  AusStr := Zeile;
  Asm  mov  si, Offset AusStr
       xor  ch, ch
       mov  cl, [ds:si]
       test cl, $FF
       jz   @Ende
       inc  si

       les  di, Bild

       mov  al, Y_Pos
       mov  ah, 160
       dec  al
       mul  ah
       mov  di, ax
       mov  al, X_Pos
       shl  al, 1
       sub  al, 2
       xor  ah, ah
       add  di, ax
       mov  ah, Attr

       cld
@Again:
       lodsb
       mov  [es:di], ax
       add  di, 2
       Loop @Again
 @Ende:
  end;
End;


Procedure WriteBios (* Kanal,X_Pos,Y_Pos,Attr,Aufruf : Byte ; Zeile : Str80 *);
Var  i : Byte;
     r : Registers;
Begin
  if not ScreenSTBY then
  begin
    if (Aufruf = 1) or (Kanal = show) then
    begin
      for i := 1 to length(Zeile) do if Zeile[i] in [#0..#31] then Zeile[i] := B1;
      r.AH := $13;
      r.AL := $00;
      r.BH := $00;
      r.BL := Attr;
      r.CX := ord(Zeile[0]);
      r.DH := Y_Pos - 1;
      r.DL := X_Pos - 1;
      r.ES := Seg(Zeile[1]);
      r.BP := Ofs(Zeile[1]);
      Intr($10,r);
    end;
  end;
End;


Function  KanalFrei (* Kanal : Byte) : Byte *);
Var    Free : Boolean;
       i    : Integer;
Begin
  Free := false;
  i := maxLink;
  While not Free and (i > 0) do with K[i]^ do
  begin
    if not (Kanal_benutz or connected or Test or Mo.MonActive) and
       (i <> ConvHilfsPort) and
       ((Kanal = 0) or (Kanal > 0) and (Kanal <> i)) then
    begin
      Free := true;
      KanalFrei := i;
    end else dec(i);
  end;
  if not Free then KanalFrei := 0;
End;


Function Line_convert (* Kanal, Art : Byte; Zeile : String) : String *);
Var     i : Byte;
        zh:char;
Begin
  with K[Kanal]^ do
  begin
    if Umlaut = 2 then
    begin
      case Art of
        1 : For i := 1 to length(Zeile) do
            begin
            zh:=#0;
            case Zeile[i] of
              'é' : zh := '[';
              'ô' : zh := BS ;
              'ö' : zh := ']';
              'Ñ' : zh := '{';
              'î' : zh := '|';
              'Å' : zh := '}';
              '·' : zh := '~';

              '[' : zh := 'é';
              BS  : zh := 'ô';
              ']' : zh := 'ö';
              '{' : zh := 'Ñ';
              '|' : zh := 'î';
              '}' : zh := 'Å';
              '~' : zh := '·';


            end;
            if zh<>#0 then Zeile[i]:=zh;
           end;
        2 : For i := 1 to length(Zeile) do
            begin
            zh:=#0;
            case Zeile[i] of
              '[' : zh := 'é';
              BS  : zh := 'ô';
              ']' : zh := 'ö';
              '{' : zh := 'Ñ';
              '|' : zh := 'î';
              '}' : zh := 'Å';
              '~' : zh := '·';

              'é' : zh := '[';
              'ô' : zh := BS ;
              'ö' : zh := ']';
              'Ñ' : zh := '{';
              'î' : zh := '|';
              'Å' : zh := '}';
              '·' : zh := '~';

            end;
            if zH<>#0 then Zeile[i]:=zh;
           end;
      end;
    end

    else if Umlaut = 3 then
    begin
      case Art of
        1 : For i := 1 to length(Zeile) do
            case Zeile[i] of
              'é' : Zeile[i] := 'ƒ';
              'ô' : Zeile[i] := '÷';
              'ö' : Zeile[i] := '‹';
              'Ñ' : Zeile[i] := '‰';
              'î' : Zeile[i] := 'ˆ';
              'Å' : Zeile[i] := '¸';
              '·' : Zeile[i] := 'ﬂ';
            end;
        2 : For i := 1 to length(Zeile) do
            case Zeile[i] of
              'ƒ' : Zeile[i] := 'é';
              '÷' : Zeile[i] := 'ô';
              '‹' : Zeile[i] := 'ö';
              '‰' : Zeile[i] := 'Ñ';
              'ˆ' : Zeile[i] := 'î';
              '¸' : Zeile[i] := 'Å';
              'ﬂ' : Zeile[i] := '·';
            end;
        end;
      end;
    end;
  Line_convert := Zeile;
End;


Function InfoZeile;         (*  (Nr : Word) : String[80]  *)
Var   Hstr : String;
      i,x  : Word;
Begin
  Hstr := '';
  if nr<=maxmsgs then
   begin
    x := (MsgPos^[Nr+1] - MsgPos^[Nr]);
    move(Msg^[MsgPos^[Nr]],Hstr[1],x);
    Hstr[0] := chr(Byte(x));
   end else InfoOut(show,0,1,'WRONG VERSION: MSGS.XP!!!');
    InfoZeile := Platzhalter(Kanal2,Hstr);
End;


Procedure Neu_Bild;
Const  ScrMax = NeuBildRam + 1;
       RetMax = 60;

Type   ScreenPtr = array[0..ScrMax] of Byte;
       ReturnPtr = array[0..RetMax] of Word;

Var    Zeilen,i : Integer;
       Screen   : ^ScreenPtr;
       Return   : ^ReturnPtr;

  Procedure Picture(C,von,bis,Attr : Byte);
  Var   i1       : Integer;
        Farb,
        Z,J      : Byte;
        Groesse,
        P        : LongInt;
        Hstr     : String[80];
        ch       : char;
        i        : Word;
        NotPtr   : Pointer;
        RetPtr   : Pointer;

  Begin
    FillChar(Return^,SizeOf(Return^),0);
    FillChar(Screen^,SizeOf(Screen^),0);
    Return^[0] := ScrMax-1;
    if use_EMS then EMS_Seite_einblenden(C,Scr);

    if use_Vdisk then
    begin
      FiResult := ResetBin(ScrollFile,T);
      with K[C]^ do
      if NotPos + 1 < ScrMax then
      begin
        Seek(ScrollFile,Pos_im_Scr+(maxNotCh-ScrMax+NotPos));
        BlockRead(ScrollFile,Screen^[0],ScrMax-NotPos-1,i);
        Seek(ScrollFile,Pos_im_Scr);
        BlockRead(ScrollFile,Screen^[ScrMax-NotPos-1],NotPos,i);
      end else
      begin
        Seek(ScrollFile,Pos_im_Scr+(NotPos+1-ScrMax));
        BlockRead(ScrollFile,Screen^[0],ScrMax-1,i);
      end;
      FiResult := CloseBin(ScrollFile);
    end else

    if use_XMS then
    begin
      with K[C]^ do if NotPos + 1 < ScrMax then
      begin
        XMS_to_Data(@Screen^[0],XMS_Handle,Pos_im_Scr+(maxNotCh-ScrMax+NotPos),ScrMax-NotPos-1);
        XMS_to_Data(@Screen^[ScrMax-NotPos-1],XMS_Handle,Pos_im_Scr,NotPos);
      end else XMS_to_Data(@Screen^[0],XMS_Handle,Pos_im_Scr+(NotPos+1-ScrMax),ScrMax-1);
    end else
    begin
      with K[C]^ do if NotPos + 1 < ScrMax then
      begin
        move(NotCh[C]^[maxNotCh-ScrMax+NotPos],Screen^[0],ScrMax-NotPos-1);
        move(NotCh[C]^[0],Screen^[ScrMax-NotPos-1],NotPos);
      end else move(NotCh[C]^[NotPos+1-ScrMax],Screen^[0],ScrMax-1);
    end;

    Screen^[ScrMax-1] := 13;

    NotPtr := @Screen^[ScrMax-2];
    RetPtr := @Return^[0];
    Asm   cli
          push DS

          mov  cx, ScrMax
          dec  cx
          dec  cx
          xor  bl, bl

          lds  si, RetPtr
          les  di, NotPtr
          jmp  @Again
  @AddZ:
          add  si, 2
          mov  [ds:si], cx
          dec  cx
          inc  bl
          cmp  bl, RetMax
          jae  @Ende
  @Again:
          mov  al, [es:di]
          dec  di
          cmp  al, 13
          je   @AddZ
          Loop @Again
  @Ende:
          pop  DS
          mov  Z, bl
          sti
    end;


    (*
    Z := 0;
    for i := max-2 downto 0 do
    begin
      if (Screen^[i] = 13) and (Z < a) then
      begin
        inc(Z);
        RET[Z] := i;
      end;
    end;
    *)


    if Zeilen <= Z then Z := Zeilen;
    for i := 1 to Z do
    begin
      Hstr := '';
      Farb := ord(Screen^[Return^[i]+1]);
      if Farb = 254 then Farb := 13;
      J := Return^[i-1] - Return^[i] - 2;
      if J > 80 then J := 80;
      move(Screen^[Return^[i]+2],Hstr[1],J);
      Hstr[0] := chr(J);
      Teil_Bild_Loesch(bis+1-i,bis+1-i,Farb);
      WritePage(show,1,bis+1-i,Farb,0,Hstr);
    end;
    if (bis-Z) >= von then Teil_Bild_Loesch(von,bis-Z,Attr);
  end;

Begin
  NowFenster := false;
  NowCurBox := false;
  ScreenSTBY := false;
  SetzeFlags(show);
   Status2;

  GetMem(Screen,SizeOf(Screen^));
  GetMem(Return,SizeOf(Return^));

  if show = 0 then
  begin
    Zeilen := maxZ - K[0]^.UnStat;
    Picture(0,K[0]^.UnStat+1,maxZ,Attrib[29]);
    TickerOut;
  end else
  begin
    Zeilen := K[show]^.QEnd - K[show]^.QBeg + 1;
    Picture(show,K[show]^.QBeg,K[show]^.QEnd,Attrib[18]);
    Zeilen := maxZ - K[show]^.UnStat;
    if Zeilen > 0 then Picture(0,K[show]^.UnStat+1,maxZ,Attrib[29]);
  end;

  FreeMem(Return,SizeOf(Return^));
  FreeMem(Screen,SizeOf(Screen^));

  Neu_BildVor(show);
  Soft_Cursor(show);
  if HardCur then
  begin
    JumpRxZaehl := 0;
    JumpRxScr := true;
  end;
  notScroll := true;
  if not BackScroll(show) and (K[show]^.MerkInfo > '') then
    InfoOut(show,0,0,K[show]^.MerkInfo);
End;


Procedure SetzeFlags (* Kanal : Byte *);
Var  S, S3    : String[80];
     EigMail_:Boolean;
     i:Byte;
     kanstr:string;

  Procedure mS (Hstr : string);
  Begin
    if length(S)+Length(Hstr)>58 then S3:=S3+Hstr
      else S := S + Hstr;
  End;

Begin
 if not OnlHelp then
 begin
  with K[Kanal]^ do
  begin
    StatusOut(Kanal,1,1,Attrib[9],ConstStr(B1,60),2);
    StatusOut(Kanal,42,1,Attrib[9],ConstStr(B1,18),1);
    if (not Backscroll(show)) and (Kanal=show) then
      StatusOut(Kanal,61,1,Attrib[9],ConstStr(B1,20),3);
    StatusOut(Kanal,1,1,Attrib[9],ConstStr(B1,60),3);

    S := '';
    S3:= '';

    if Kanal > 0 then
    begin
      {ms('SYS:'+int_str(SysArt)+'User:'+int_str(UserArt));}
     { mS('CTxt:'+int_str(TNC[TncNummer]^.CTEXT)+' '); }
      if Einstiegskanal or AusstiegsKanal then
        mS('*'+int_str(GegenKanal)+'*  ');
      if Kopieren > 0 then
        mS('Copy>'+int_str(Kopieren)+' '); {AN: anzeige fÅr den kanal}
                                           {VON dem kopiert wird}
      if KopierenFm > 0 then
        mS('Copy<'+int_str(KopierenFm)+' '); {VON: anzeige fÅr den kanal}
                                             {AN DEN kopiert wird}
      if FileSend then mS('FileTx ');
      if RX_Bin > 0 then mS('FileRx ');
      if SplSave then
        mS('7+Save ')
      else if SPlus then
        mS('7+ ');
      if BufExists then mS('Buff ');

      if xbin.rx then ms('XBinRX ');
      if xbin.tx then ms('XBinTX ');
      if (XBin.An) and ((not XBin.RX) and (not Xbin.TX)) then ms('XBin ');

      if AutoBin then mS('ABin ');
      if RemAll then mS('RemSOp! ');
      If SelfSysop then ms('SysOp! ');
      if Ignore then mS('Ignore ');
      if not BinOut then mS('NoBin ');
      if SysopParm then mS('SOp? ');

      if Auto then mS('Remote '); {Stimmt tatsÑchlich ....}
      if Auto_CON then mS('c... ');
      if Rx_Beep then mS('RxBeep ');
      if Hold and not FileSend then mS('Hold ');
      if CSelf in [5,6] then mS('Auto? ')
                        else if CSelf > 0 then mS('Auto ');
      if Node then ms('Node ');
    end else
    {Kanal = 0}
    begin
      if CtrlBeep then mS('Beep ');
      if PacOut then mS('PLen ');
      if Time_stamp then mS('Time ');
{$IFNDEF no_Bake}       {//db1ras}
      if TNC[Unproto]^.Bake then mS('Bake ');
{$ENDIF}
      if NoBinMon then mS('NoBin ');
{$IFNDEF no_Bake}       {//db1ras}
      if MailBake then ms('MFrms ');
{$ENDIF}
    end;

    if TopBox then mS('XPBox ');
    if (_OnAct) and (OnAct='') then ms('OnAct ');
    if (_OnAct) and (OnAct<>'') then ms('OnAct! ');

    if RxComp then mS('RxComp('+int_str(RXKompRate)+'%) ');
    if TxComp then mS('TxComp('+int_str(TXKompRate)+'%) ');
    {if spcomp then ms('SP ');}

    if not RX_Save and Save then mS('Save ');
    if Umlaut > 0 then mS('Uml ');
    if Echo > 0 then mS('Echo ');
    if Klingel then mS('Bell ');
    if Print then if Drucker then mS('PTR:A ')
                             else mS('PRT: ');
    if G^.MakroLearn then mS('MakLearn ');
    if Fwd then MS('MPoll ');
    if VIPG THEN MS('VIP ');
    if SoZeichen then MS ('<'+#5+'> ');
    StatusOut(Kanal,2,1,Attrib[14],S,2);
    StatusOut(Kanal,2,1,Attrib[14],S3,3);

     s:='';
     if ((connected) or (TEST)) then
     begin
       if (SystemErkannt=AutoSysName[0]) then
       begin
        Case SysArt of
         3 :SystemErkannt:=AutoSysName[1];
       { 16:SystemErkannt:=AutoSysName[2]; Nicht einden - RMNC/PC-Unterschied!!}
         17,
         19:SystemErkannt:=AutoSysName[3];
         1 :SystemErkannt:=AutoSysName[4];
         18:SystemErkannt:=AutoSysName[5];
        end;
       end;
       if SysArt in [1..6,14] then S:='B' else
        if (SysArt in [7..13,15,16,18..20]) or (XPNodeC) then S:='N'
         else if ((Userart>0) and (SysArt=0)) or (SysArt>0) then S:='T';

     { if sysart in [1,3,16..18,19] then S:=S+SystemErkannt; }
       if sysart in [1,3,7,10,16..18,19] then S:=S+SystemErkannt; {//db1ras}
       if (sysArt>0) and (SystemErkannt='') then S:=S+':'+SNam[SysArt];
       if (sysArt=0) and (UserArt>0) then S:=S+':'+Unam[UserArt];
                      { connect}
      if (S='') and (System<>'') then S:='?:'+System;
     end;

      StatusOut(Kanal,43,1,Attrib[14],EfillStr(12,B1,S),1);

      EigMail_:=false;
      EigMail_:=EigMail;
      if Kanal=0 then
       begin
        EigMail_:=false;
        for I:=1 to maxLink do
         begin
          if K[i]^.EigMail then
            EigMail_:=true;
         end;
       end;

      S:='MAIL in '; {9}
      if MailInBox then
       begin
        S:=S+'Ext';
        if EigMail_ then S:=S+'&' else S:=S+' ';
       end;
       if EigMail_ then S:=S+'XP-';
       S:=S+'Box!';
       Versi:=Version;
        if ((MailInBox) or (EigMail_)) and ((Not Backscroll(Kanal)) and (Kanal=show)) then
         begin
           StatusOut(Kanal,61,1,Attrib[10],s,3);
           VErsi:=S;
         end
        else StatusOut(Kanal,61,1,Attrib[10],Version,3)

  end;
 end; {if not OnlHelp ... }
End;


Procedure ScreenFill; (* Bildschirm-Schoner *)
Var    X,Y : Byte;
Begin
  ScreenSTBY := false;
  Teil_Bild_Loesch(1,maxZ,0);
  ScreenSTBY := true;
  Repeat
    X := Random(70);
  Until X in [1..70];
  Repeat
    Y := Random(maxZ);
  Until Y in [1..maxZ];
  WriteTxt(X,Y,Attrib[15],BSXP);
End;


Procedure Check_Eig_Mail (* von,bis : Byte *);
Var   Hstr : String[9];
      i    : Byte;
Begin
  for i := von to bis do with K[i]^ do
  begin
    Hstr := OwnCall;
    strip(Hstr);
    if Exists(Konfig.MailVerz + Hstr + MsgExt) then
    begin
      if pos(Hstr,Eig_Mail_Zeile) = 0
      then Eig_Mail_Zeile := Eig_Mail_Zeile + B1 + Hstr;
      EigMail := true;
    end else EigMail := false;
  end;
End;


Procedure EMS_Seite_einblenden (* Kanal : Byte; Art : Byte  *);
Var       i : Byte;
Begin
  with K[Kanal]^ do
  begin
    if Art = Scr then for i := 0 to PagesAnz-1 do
                          EMS_Zuordnung(ScrHandle,i,PagesNot[i]);
    if Art = Vor then EMS_Zuordnung(VorHandle,0,Kanal);
    if EMS_Error <> 0 then Abbruch_XP(10,int_str(EMS_Error));
  end;
End;


Procedure Open_Scroll (* Kanal : Byte *);
Begin
  with K[Kanal]^ do
  begin
    FiResult := ResetBin(ScrollFile,T);
    Seek(ScrollFile,Pos_im_Scr + NotPos);
  end;
End;


Procedure Close_Scroll (* Kanal : Byte *);
Begin
  with K[Kanal]^ do
  begin
    NotPos := FilePos(ScrollFile) - Pos_im_Scr;
    FiResult := CloseBin(ScrollFile);
  end;
End;


Function  PhantasieCall; (* : str9 *)
Var     ch   : char;
        Hstr : String[9];
Begin
  Hstr := '';
  While length(Hstr) < 7 do
  begin
    ch := #0;
    While not (ch in ['A'..'Z']) do ch := chr(Random(Byte(90)));
    Hstr := Hstr + ch;
  end;
  Hstr[4] := chr(Random(Byte(9)) + 48);
  Hstr[7] := '-';
  Hstr := Hstr + int_str(Random(Byte(15)));
  PhantasieCall := Hstr;
End;


Procedure SetzeCursor (* X,Y : ShortInt *);
Begin
  if not Cursor_on then Cursor_Ein;
  X := Byte(X);
  Y := Byte(Y);
  if (CurX <> X) or (CurY <> Y) then GotoXY(X,Y);
  CurX := X;
  CurY := Y;
End;


Procedure InitCursor (* X,Y : ShortInt *);
Begin
  if HardCur then SetzeCursor(X,Y);
End;


Procedure set_Hardwarecursor (* Kanal : Byte *);
Var   i,i1,i2,i3 : Byte;
begin
  if HardCur then with K[Kanal]^ do
  begin
    i := QBeg + 1;
    i1 := 3;
    i3 := QEnd;
    if Kanal = 0 then
    begin
      i := UnStat + 2;
      i1 := 1;
      i3 := maxZ;
    end;
    if Braille80 then i2 := 80 else i2 := 1;

    if NowCurBox and not NoCurJump
      then SetzeCursor(XL,i)
      else if not TNC_ReadOut then
           begin
             if (Kanal = 0) then SetzeCursor(1,UnStat);
           end else if JumpRxScr and Win_Rout then
                    begin
                      if ShTab_Pressed then SetzeCursor(i1,ObStat)
                                       else SetzeCursor(i2,i3);
                    end else
                    begin
                      if Cmd then SetzeCursor(X1C,Y1C+Vofs)
                             else SetzeCursor(X1V,Y1V+Vofs);
                    end;
  end;
End;


Procedure SwitchChannel(Kanal : Byte);
Begin
  if Kanal > 0 then PortStufe := ((Kanal-1) div 10) * 10;
  show := Kanal;
  K[Kanal]^.NochNichtGelesen := false;
  K[Kanal]^.cmd:=false;
  Neu_Bild;
  with K[kanal]^ do
   begin
    if ((RX_Bin>0) or (SPlSave)) and (LstRXInfo<>'') then InfoOut(Kanal,0,1,LstRXInfo);
    if (FileSend) and (LstTXInfo<>'') then InfoOut(Kanal,0,1,LstTXInfo);
   end;
  UserInStatus(kanal);
End;


Procedure SwitchKanal (* VC : Char *);
Var   i,i1,i2 : Byte;
      Flag : Boolean;
Begin
  i := (ord(VC)-58);
  i1 := show;

  if maxLink > 10 then
  begin
    if i1 - PortStufe = i then
    begin
      if i1 + 10 <= maxLink then i1 := i1 + 10 else
      begin
        i1 := i;
        if i1 = 0 then i1 := maxLink;
      end;
    end else
    begin
      i1 := i + PortStufe;
      if i1 > maxLink then i1 := i;
    end;

    i2 := i1;
    Repeat
      if i2 + 10 <= maxLink then i2 := i2 + 10
                            else i2 := i;
      Flag := K[i2]^.NochNichtGelesen;
    Until Flag or (i2 = i1);
    if Flag then i1 := i2;
  end else i1 := i;

  if i1 > maxLink then i1 := maxLink;
  SwitchChannel(i1);
End;


Procedure SwitchMonitor;
Begin
  if show > 0 then
  begin
    ShowMerk := show;
    SwitchChannel(0);
  end else SwitchChannel(ShowMerk);
End;


Function  FreeStr (* Lw : char)  : str11 *);
Begin
  FreeStr := FormByte(int_str(DiskFree(ord(Lw)-64)));
End;


Function  V24 (* Kanal : Byte) : Byte *);
Begin
  V24 := TNC[K[Kanal]^.TncNummer]^.RS232;
End;


Procedure ReInstall;
Begin
  V24_Close;
  Port[$21] := Old_IntMask;
  Port[$20] := $C7;

  if use_EMS then EMS_Freigeben(ScrHandle);
  if Vor_im_EMS then EMS_Freigeben(VorHandle);
  if use_XMS then Free_XMS_Ram(XMS_Handle);

  NormVideo;
  ColorItensity(false);
  TextMode(StartVideoMode);
  ClrScr;
  Cursor_ein;
End;


Procedure ColorItensity (* CFlag : Boolean *);
var  r : Registers;
     i : Byte;
Begin
  if not Hercules then
  begin
    if CFlag then i := 0
             else i := 1;
    r.AX := $1003;
    r.BL := i;
    Intr($10,r);
  end;
End;


Function  ChAttr (* Attr : Byte ) : Byte *);
Begin
  if Attr = 13 then ChAttr := 254 else ChAttr := Attr;
End;


Procedure Init_HardDrive;
Var   r : Registers;
Begin
  r.AH := $0D;
  MsDos(r);
  HD_Read := 0;
End;


Procedure New2BVec;
Begin
  ES := Seg(TopString);
  DI := Ofs(TopString);
End;


{Ueberprueft, ob XP schon geladen ist}
Procedure Check_Loaded;
Var  r : Registers;
     p : ^String;
Begin
  r.ES := 0;
  r.DI := 0;
  Intr(TEI,r);
  p := Ptr(r.ES,r.DI);

  if (p <> nil) and (p^ = TopString) then
  begin
    Writeln(^G,'XPacket already loaded !');
    Halt;
  end;
End;


Procedure Exit_XP;
Begin
  ExitProc := OrigExit;
  ReInstall;
  GotoXY(1,25);
  Writeln(^G);
End;


Procedure PRG_Stoppen(Nr : Byte);
Begin
  ExitProc := OrigExit;
  Halt(Nr);
End;


Function  BackScroll (* Kanal : Byte) : Boolean *);
Begin
  with K[Kanal]^ do BackScroll := QsoScroll or BoxScroll or DirScroll;
End;


Procedure Call_DOS (* Zeile : Str128 *);
Begin
  SetIntVec(TEI,@New2Bvec);
  SetMemTop(Ptr(OvrHeapOrg,0));

  SwapVectors;
  Exec(GetEnv('COMSPEC'),Zeile);
  SwapVectors;

  SetMemTop(HeapEnd);
  OvrClearBuf;
  SetIntVec(TEI,Old2Bvec);
End;


Function  AppendTxt (* Var f : Text) : Integer *);
Begin
  {$I-} Append(f);
  AppendTxt := IOResult;
  {$I+}
End;


Function  ResetTxt (* Var f : Text) : Integer *);
Begin
  {$I-} Reset(f);
  ResetTxt := IOResult;
  {$I+}
End;


Function  ResetBin (* Var f : File; Fpos : LongInt) : Integer *);
Begin
  {$I-} Reset(f,Fpos);
  ResetBin := IOResult;
  {$I+}
End;


Function  RewriteTxt (* Var f : Text) : Integer *);
Begin
  {$I-} Rewrite(f);
  RewriteTxt := IOResult;
  {$I+}
End;


Function  RewriteBin (* Var f : File; Fpos : LongInt) : Integer *);
Begin
  {$I-} Rewrite(f,Fpos);
  RewriteBin := IOResult;
  {$I+}
End;


Function  CloseTxt (* Var f : File) : Integer *);
Begin
  {$I-} Close(f);
  CloseTxt := IOResult;
  {$I+}
End;


Function  CloseBin (* Var f : File) : Integer *);
Begin
   {$I-} Close(f);
  CloseBin := IOResult;
  {$I+}
End;


Function  EraseTxt (* Var f : File) : Integer *);
Begin
  {$I-} Erase(f);
  EraseTxt := IOResult;
   {$I+}
End;


Function  EraseBin (* Var f : File) : Integer *);
Begin
  {$I-} Erase(f);
  EraseBin := IOResult;
  {$I+}
End;


Procedure IdleDOS;
Var  r : Registers;
Begin
  r.AX := $1680;
  Intr($2F,r);
End;


Procedure Verzoegern (* Wert : Word *);
Begin
  Delay(Word(Round(Wert * DelayCor)));
End;


Procedure LockIntFlag (* Art : Byte *);
Begin
  if LockInt then
  begin
    if Art = 0 then Inline($FA)
               else Inline($FB);
  end;
End;

Procedure Sound_ (* Tonh, Lang : Integer *);
begin
 if (not quiet) then begin
 Sound(TonH); warte(Lang); NoSound;
 end;
end;