{
Verteilung der Hilfe-Nummern und Textmarkierungen:

1   #SETUP#    - Allgemeine Setup-Meldungen

>> Hilfen <<
2   #EDITOR#   - Editor-Hilfe
3   #TNC#      - TNC-Haupteinstellungen
4   #TNCINI#   - TNC-Initialisierung
5   #TNCDeIni# - TNC-Deini
6   #DIRS#     - Verzeichnisse
7   #VER#      - Verschiedenes
8   #MAIL#     - Mailframes
9   #RAM#      - Speicheroptionen
10  #PRT#      - Drucker
11  #BLIND#    - Blindensetup

>> Auswahlen <<
15  #RESP#     - Responses (ja, nein ...)
20  #TNCS#     - TNC-Setup
21  #TNCI#     - TNC-Ini/deini fÅr Setup
30  #DIRT#     - Dir-Screen
40  #VERT#     - Verschiedenes-Screen
50  #MAIL#     - Mailframe-auswertung
60  #RAMT#     - Speicher-Screen
70  #PRTT#     - Druck-Screen
80  #BLINDT#     - Blinden-Screen
90             - PERSînliches
100            - SOUND

255 #MAIN#     - HauptmenÅ
}

Program XPackSet;

{-$Define Sound}
USES Dos, CRT, strings, XPSetTas
{$IFDEF Sound} {//db1ras}
     , SBDet
{$ENDIF}
     ;

CONST
   ConfigDat = 'CONFIG.XP';
   MaxHilfeZeilen = 66;
   kennst = 'XPacket-Configuration-File. Do NOT edit!';


Texte : array[0..26] of string[20] =
('#Nox#',
'#SETUP#',  '#EDITOR#',
'#TNC#',     '#TNCINI#',
'#TNCDEINI#','#DIRS#',
'#VER#',     '#MAIL#',
'#RAM#',     '#PRT#',
'#BLIND#',   '#QUIET#',
'#RESP#',    '#TNCS#',
'#TNCI#',    '#DIRT#',
'#VERT#',    '#MAILSC#',
'#RAMT#',    '#PRTT#',
'#BLINDT#',  '#PERST#',
'#PERSH#',   '#MAIN#',
'#SOUND#',   '#SOUNDH#');



   ESC    = #27;
   maxhmenu=10;
   maxtnc = 8;
   x      = 2;
   xml    =26;
   yml    =5;
   xtnc   =25;
   ytnc   =3;
   ytid    =4;
   xtid    =6;
   xverz  = 2;
   yverz  = 7;
   yver   = 3;
   xver   = 23;

   xper   = 17;
   yper   = 7;

   xsp    =27;
   ysp    =10;
   ybld   = 7;
   xbld   = 25;
   xdr    = 30;
   ydr    = 11;
   xsn    = 25;
   ysn    = 11;
   y      = 7;
   nohhg  = Darkgray;
   highvg = black;
   highhg = white;
   specvg = white;
      TNC_Art      : Array[0..4] of String[4] =
                            ('----',
                            'TNC2','TNC3','TFPC','FALC');


TYPE
   str2=string[2];
   str8=string[8];
   str10=string[10];
   str80=string[80];
   str20=string[20];
   str30=string[30];
   str70=string[70];
   strk = string[41];

        TNC_Konf   = Record {1.73/1.80}
                      Art         : Byte;   {tfpcx, tnc ....}
                      MaxKan      : Byte;
                      NodeKan     : Byte;
                      Identi      : Str2;
                      Port        : Byte;
                      Tickzeile   : Boolean;
                      Com,
                      IRQ         : Byte;
                      Adresse     : Str8;
                      Baud        : Longint;
                      AfuPort,
                      Fifo        : Boolean;
                      MultiplexNr : Byte;
                      PortNam     : str20;
                      IniA        : array[1..16] of str30;
                      IniB        : str70;
                      DIniA       : array[1..16] of str30;
                      DIniB       : str70;
                      TX_X0,                 {TNC-Command TX-Sperre AN}
                      TX_X1       : string[5];{TNC-Command TX-Sperre AUS}
                      TX_Bundle   : Byte; {BÅndel-Nummer um fÅr mehrere Antennen Sets zuzulassen}
                     end;


        QuietZeit   = Record
                       StdAnf, MinAnf,
                       StdEnd, MinEnd  : Byte;
                       Aktiv : boolean;
                      end;

        QuietZeiten = Array[1..3] of QuietZeit;

        Sich_Rec18   = Record
                        QSOAblauf,
                        Dateien,
                        User,
                        Shutdown : Boolean;
                      end;

         Konfig_Rec = Record {1.74}
                       kenner: strk;
                       TNC  : array[1..MaxTnc] of TNC_KONF;
                       RemVerz,
                       SavVerz,
                       MailVerz : String;
                       Teil1 : byte;
                       RunVerz,
                       BinVerz,
                       SPlVerz,
                       MakVerz,
                       ViewVerz,
                       EditVerz,
                       SPKVerz,
                       TempVerz : str80;
                       Teil5 : byte;
                       CDRom    : Char;
                       ZeitBez : str8;
                       UTCDiff : integer;
                       teil2 : byte;
                       UTCBenutzen,
                       Echtzeit : Boolean;
                       PopupZeit : integer;
                       LockIRQ   : Boolean;
                       SichAbfr  : Boolean;
                       IDLE      : Boolean;
                       ScrSavZ   : Byte;
                       PromptS   : Str30;
                       NTimeOut,
                       TTimeOut,
                       MaxFrameStd,
                       PacLenStd,
                       MaxNodes,
                       Lifetime  : integer;
                       Teil4     : byte;
                       version   : integer;

                       QuietDH,
                       QuietZG   : Boolean;
                       QuietZt   : QuietZeiten;


                       MH        : Byte;
                       BackScRam : Byte;
                       VorschZRam: Byte;
                       BufferDat : Boolean;

                       LPTNr     : Byte;
                       LPTAdr    : Str8;

                       SoftHardC,
                       WinRout    : Boolean;
                       WinRoutTime: Byte;
                       RXBeepStart,
                       AchzigBrail,
                       Steuerz,
                       MarkTon,
                       AusgabeBios: Boolean;
                       Teil3      : Byte;
                       MailFErl   : Boolean;
                       MailFrame  : array[1..10] of str10;
                       OwnMailFr  : Boolean;
                       OwnMailPfad: String[50];
                       MailFrameZeit : Byte;

                       PersName,
                       PersQTH    : string[30];
                       PersLoc    : string[10];

                       CBFilter   : Boolean;
                       ReqNam     : Boolean;
                       NodeSound  : Boolean;
                       MaxLoginUser : Byte;

                       Sicherheit : Sich_Rec18;

                       WavOut, MidiOut, WavSprach, bool4, bool5, bool6 : boolean;
                       BackupTime, SBHiDMA, SBLoDMA, SBIRQ, byte5, byte6 : byte;
                       MidiADR, SBBaseADR, word3, word4, word5, word6 : word;

                      end;




  Screen              = ARRAY [1..2000] OF
     RECORD
      Zeichen : CHAR;
      Attribut : BYTE;
    END;

  BildZeiger          = ^Screen;
  TextPuffer_ = array[1..65000] of char;

VAR
 CBFilterStatus:boolean;
 BreakStatus:boolean;
  TextPuffer : ^textPuffer_;
  TextPuff:Pchar;
  PufferLang,
  Result : word;
  RespT  : array [1..5] of string[10];
  HelpNr:integer;
  HelpB : array[1..60] of String[77];
  HilfeThemen : array [1..120] of LongINt;
  HZeil:integer;
  helpeditor,
  HelpSETUP    : Array[1..52] of String[77];

  RespN,
  HEditorN,
  HSetupN: byte;
  HMenN:byte;

  HDAT:file;
  BDAT:file of byte;
  Datei: File of Konfig_Rec;
  dateiw: file of byte;
  datsize:longint;
  Register:Registers;
  HMIt : Array[1..maxhmenu] of string[25];
  cen,can,cse,
  CursorEnde, CursorAnf, CursorSeite : Word;

  Konfig12:Konfig_Rec;
  Konfig : Konfig_Rec;

  i      : Integer;
  S      : String;
  Mono      : Screen ABSOLUTE $B000 : 0000;
  Color     : Screen ABSOLUTE $B800 : 0000;
  ch:char;
  confok,
  HilfeRSaved:boolean;
  Bildspeicher,
  Rahmen,
  HilfeRahmen,
  EditorHilfe,
  HauptMenu : BildZeiger;
  Item:Byte;
  Tau:Byte;
  dirs:boolean;

  HelpDatDa : Boolean;


Function  int_str (i : LongInt) : Str10;
Var   Hstr  : String[10];
Begin
  str(i,Hstr);
  int_str := Hstr;
End;



Function  Hex (Dezimal : LongInt; Stellenzahl : Byte) : Str8;
Const HexChars  : Array [0..15] of Char = ('0','1','2','3','4','5','6','7',
                                           '8','9','A','B','C','D','E','F');
Var    Stelle : Byte;
Begin
  if (Stellenzahl > 8) then Stellenzahl := 8;
  Hex := '        ';
  Hex[0] := Chr(Stellenzahl);
  for Stelle := Stellenzahl downto 1 do
  begin
    Hex[Stelle] := HexChars[Dezimal and $0F];
    Dezimal := Dezimal shr 4;
  end;
End;


function UpC(Zeile:string):string;
var z:byte;
    uz:string;
begin
uz:='';
 for z:=1 to length(zeile) do
   uz:=uz+upcase(zeile[z]);
 upc:=uz;
end;


Function EndFill(MaxZ : Byte; Zch : Char; FillSt : string) : string;var ifi:byte;
begin
while length(FillSt)<MaxZ do
 begin
  FillSt:=FillSt+Zch;
 end;
 EndFill:=FillSt;
end;


Procedure IThema (Kap : LongInt);
var Zaehler:longint;
    Hstr:string[77];
begin
 HZeil:=0;
 Zaehler:=0;
{ repeat
  Readln(hdat,hstr);
  inc(Zaehler);
 until (Zaehler=HilfeThemen[kap]) or (EOF(HDat));

if not EOF(Hdat) then}
Zaehler:=HilfeThemen[kap];
while TextPuffer^[Zaehler]<>#13 do inc(Zaehler);
inc(Zaehler);
 repeat

{ Readln(hdat,hstr);}
hstr:='';
 while TextPuffer^[Zaehler]<>#13 do
  begin
   inc(Zaehler);
   if TextPuffer^[Zaehler]<>#13 then Hstr:=Hstr+TextPuffer^[zaehler];
  end;
  inc(Zaehler);
 if (Pos('#END#',Upc(Hstr))<>1) and (Pos('#REM',Upc(hstr))<>1) then
 begin
  case KAP of
       20: begin
            inc(HZeil);
            if hzeil<20 then HelpB[HZeil]:=EndFill(25,' ',Hstr)
             else HelpB[HZeil]:=EndFill(16,' ',Hstr);
           end;
       21: begin
            inc(HZeil);
            HelpB[HZeil]:=EndFill(25,' ',Hstr);
           end;
       30: begin
            inc(HZeil);
            HelpB[HZeil]:=EndFill(18,' ',Hstr);
           end;
       40: begin
            inc(HZeil);
            HelpB[HZeil]:=EndFill(25,' ',Hstr);
           end;
       50: begin
            inc(HZeil);
            HelpB[HZeil]:=EndFill(22,' ',Hstr);
           end;
       60: begin
            inc(HZeil);
            HelpB[HZeil]:=EndFill(25,' ',Hstr);
           end;
       70: begin
            inc(HZeil);
            HelpB[HZeil]:=EndFill(15,' ',Hstr);
           end;
       80: begin
            inc(HZeil);
            HelpB[HZeil]:=EndFill(25,' ',Hstr);
           end;
       90: begin
            inc(HZeil);
            HelpB[HZeil]:=EndFill(15,' ',Hstr);
           end;
       100: begin
            inc(HZeil);
            HelpB[HZeil]:=EndFill(24,' ',Hstr);
           end;
      else begin
            inc(Hzeil);
            HelpB[hzeil]:=hstr;
           end;
      end;
 end;
 until (upc(HStr)='#END#');
end;


Procedure Alarm;
begin
 sound(1400);delay(20);nosound;
end;


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


Function GDir : String;
 var d:byte;
     pf:string;

begin
{ Getdir(0,p);}
 PF:=ParamStr(0);
 while ((PF[length(PF)]<>'\') and (PF<>'')) do
  begin
   delete(PF,length(PF),1);
  end;
 if PF[length(PF)]='\' then delete(PF,length(PF),1);
 GDir:=PF;
end;

Function  SubExists (Name : string;EVVerz:Boolean) : boolean;
var   Datei : Text;
      sex   : boolean;
begin
  if not EVVerz then Name := Name + '\$$TEST$$.$$$';
  Assign(Datei,Name);
  {$I-} if not evverz then Rewrite(Datei) else reset(Datei); {$I+}
  if IOResult = 0 then
  begin
    close(Datei);
    if not evverz then erase(Datei);
    SEx := true;
  end else SEx := false;
  SubExists:=sex;
end;


Procedure RenDir (ODirSt, NDirSt : string);
var df : file;
begin
 assign (df, OdirSt);
 rename(df, NdirSt);
end;


function MDir(Pfad:string; EVVerz:Boolean) : boolean;
begin
if not subexists(Pfad, EVVerz) then
 begin
  {$I-}
  { Get directory name from command line }
  MkDir(pfad);
   if IOResult <> 0 then
    begin
     WriteLn(helpSetup[18]+': ',Pfad);
     mdir:=false;
   end
  else
  begin
    WriteLn(helpSetup[19]+': ', Pfad);
    mdir:=true;
   end;
 end else writeln(helpSetup[20]+': ', Pfad);
end;



FUNCTION FarbMon : BOOLEAN;
VAR Regs_ : REGISTERS;
BEGIN
    INTR ($11, Regs_);
    IF Regs_.ax AND $30 = $30 THEN
       FarbMon := FALSE
    ELSE
       FarbMon := TRUE;
END;

{*****************************************************}

Function Balken(AnzZ:Byte;Zc:char):String;
var blk:string;
    blz:byte;
begin
 blk:='';
 for blz:=1 to AnzZ do
  blk:=blk+Zc;
 Balken:=blk;
end;

PROCEDURE SaveBild (VAR Bild : BildZeiger);
BEGIN
    IF FarbMon THEN
       Bild^ := Color
    ELSE
       Bild^ := Mono;
END;

{*****************************************************}

PROCEDURE LadeBild (Bild : BildZeiger);
BEGIN
    IF FarbMon THEN
       Color := Bild^
    ELSE
       Mono := Bild^;
END;


PROCEDURE CursorTest;

BEGIN
    Register.ah := $0F;
    INTR ($10, Register);
    CursorSeite := Register.BH;
    Register.ah := $03;
    Register.BH := CursorSeite;
    INTR ($10, Register);
    CursorAnf := Register.ch;
    CursorENDe := Register.cl;
END;



{*****************************************************}

PROCEDURE CursorAus;

VAR Register : REGISTERS;

BEGIN
    Register.ah := $01;
    Register.BH := CursorSeite;
    Register.ch := $20;
    Register.cl := $0;
    INTR ($10, Register);
END;

{*****************************************************}

PROCEDURE CursorEin;

VAR Register : REGISTERS;

BEGIN
    Register.ah := $01;
    Register.ch := CursorAnf;
    Register.cl := CursorENDe;
    Register.BH := CursorSeite;
    INTR ($10, Register);

END;


PROCEDURE CursorBlock;

VAR Register : REGISTERS;

BEGIN
    Register.ah := $01;
    CursorAnf := 1;
    CursorENDe := 7;
    IF NOT FarbMon THEN
       CursorENDe := 13;
    Register.ch := CursorAnf;
    Register.cl := CursorENDe;
    INTR ($10, Register);

END;

{*****************************************************}

PROCEDURE CursorStrich;

VAR Register : REGISTERS;

BEGIN
    Register.ah := $01;
    CursorAnf := 6;
    CursorENDe := 7;
    IF NOT FarbMon THEN
       BEGIN
         CursorAnf := 12;
         CursorENDe := 13;
       END;
    Register.ch := CursorAnf;
    Register.cl := CursorENDe;
    INTR ($10, Register);

END;

{*****************************************************}


PROCEDURE FARBE (Vorn, Hinten : BYTE);
BEGIN
    TEXTCOLOR (Vorn);
    TEXTBACKGROUND (Hinten);
END;

PROCEDURE TextZent (Txt : STRING;
  xl, xr, y : INTEGER);

VAR
  j, k, i, xmax : INTEGER;

BEGIN
    xmax := xr - xl;
    i := LENGTH (Txt);
    j := xmax - i;
    j := j DIV 2;
    GOTOXY (xl + j, y);
    WRITE (Txt);
END;

Function MakeString(Zahl:Integer) : String;
var mst:string;
begin
 str(Zahl, MSt);
 Makestring:=mst;
end;

Function MakeInt(Zch:string) : integer;
var Za, feh: integer;
begin
 val(Zch, Za, feh);
 MakeInt:=za;
end;


PROCEDURE Help(Edit : Boolean; VorHelp:Integer);
const yh=1;
var tsa   :char;
    min, max, ordnung,
    ih    :byte;
    Hscreen,
    raus  :boolean;

begin
min:=1;

{case ih of
  3: begin
      Ordnung:=HTNCN
     end;
  4: ordnung:=HTncIniN;
  5: ordnung:=htncdeinin;
  6: ordnung:=hdirsn;
  7: ordnung:=HverN;
  8: ordnung:=hmailN;
  9: ordnung:=hramn;
  10: ordnung:=hprtn;
  11: ordnung:=hblindN;
  12: ordnung:=hquietN;
end;}

Hscreen:=true;
cursoraus;
SaveBild(EditorHilfe);
 farbe(highvg,highhg);
   IThema(HelpNr);
 HelpB[hzeil+1]:='';
 if Edit then
  begin
   max:=HZeil;
   for ordnung:=1 to HEditorN do
    HelpB[Hzeil+ordnung+1]:=HelpEditor[ordnung];
   HZeil:=max+HEditorN+1;
  end;
 ordnung:=HZeil;
 max:=ordnung;
if ordnung>22 then max:=22;
if not HilfeRSaved then
 begin
  gotoxy(1,1);
  write('…'+BAlken(78,'Õ')+'ª');

  for ih:=1 to 22 do
    write('∫'+balken(78,' ')+'∫');

  write('»'+BAlken(78,'Õ')+'º');
  textzent(' '+helpSetup[1]+' ',1,80,1);
  SaveBild(HilfeRahmen);
  HilfeRSaved:=true;
 end else LadeBild(HilfeRahmen);
repeat
 if Hscreen then
  begin
   window(1,1,80,25); gotoxy(1,24);
   write('»'+BAlken(78,'Õ')+'º');
   textzent(' '+helpSetup[3]+' ',1,80,24);
   window(2,2,79,23); clrscr;
   for ih:=min to max-1 do
     writeln(helpb[ih]);
    write(helpb[max]);
   end;

  tsa:=taste;
  raus:=true;
  Hscreen:=true;
  case Tsa of
   Pgdn: begin
          if max<ordnung then
           begin
            min:=min+22;
            max:=max+22;
            if max>ordnung then max:=ordnung;
           end else
            begin
             alarm;
              HScreen:=false;
            end;
         end;
   Pgup: begin
          if min>1 then
           begin
            min:=min-22;
            max:=min+21;
            if max>ordnung then max:=ordnung;
           end else
            begin
             alarm;
              HScreen:=false;
            end;
         end;
  end;

  if (Tsa=PgUp) or (tsa=PgDn) then
   begin
    raus:=false;
    {Hscreen:= not Hscreen; }
   end;

 until raus;
window(1,1,80,25);
if VorHelp<>0 then IThema(VorHelp);
LadeBild(EditorHilfe);
end;






PROCEDURE Editor(VAR Zeile:String;xe,ye,Stellen:Byte;Gross,spaces:Boolean;VAR T:Char;VH:integer);
var xpo     : integer;
    zeilang : integer;
    einfuegen,
    korrekt : boolean;
    zaeh    : integer;
    hzeil   : string;
begin
 xpo:=1;
 einfuegen:=false;
 CursorBlock;
 zeilang:=length(zeile);
 Repeat
  gotoxy(xe-1+xpo,ye);
  t:=taste;
  gotoxy(xe,ye);
  korrekt:=false;
  case t of
   F1: begin
        Help(true,VH);
        gotoxy(xe-1+xpo,ye);
        cursorein;
       end;
   Einf: begin
          einfuegen := not einfuegen;
          if einfuegen then CursorStrich else CursorBlock;
         end;
   cslt: begin
          dec(xpo);
          if xpo<1 then
           begin
            xpo:=1;
            alarm
           end;
         end;
   csrt: begin
          inc(xpo);
          if xpo>stellen then begin
            xpo:=stellen;
            alarm
          end;
         end;
   Pos1: begin
          xpo:=1;
         end;
   Ende: begin
          if xpo<zeilang+1 then xpo:=zeilang+1;
          if xpo>stellen then xpo:=stellen;
         end;
   #8: begin
        if (xpo>1) and (zeilang<>0) then
         begin
          hzeil:='';
          for zaeh:=1 to length(zeile) do
           if zaeh<>xpo-1 then hzeil:=hzeil+Zeile[zaeh];
          Zeile:=hzeil;
          dec(xpo);
          farbe(highvg,highhg);
          gotoxy(xe,ye); write(zeile+' ');
          dec(zeilang);
         end else Alarm;
       end;
   Entf: begin
        if (zeilang<>0) then
         begin
          hzeil:='';
          for zaeh:=1 to length(zeile) do
           if zaeh<>xpo then hzeil:=hzeil+Zeile[zaeh];
          Zeile:=hzeil;
          farbe(highvg,highhg);
          gotoxy(xe,ye); write(zeile+' ');
          dec(zeilang);
         end else Alarm;
       end;
  end;
  if (not spaces) and (T=#32) then t:=#1;
  if (T in [#32..#126, #129..#165]) then
   begin
      if Gross then T:=Upcase(T);
      if einfuegen then
      begin
      if ((xpo<=Stellen) and (zeilang<stellen)) then
       begin
        zeilang:=length(zeile);
        if (einfuegen) and (zeilang>0) and (xpo<=zeilang) then
         begin
          hzeil:='';
          for zaeh:=1 to zeilang do
           begin
            if zaeh=xpo then hzeil:=hzeil+t;
            hzeil:=hzeil+zeile[zaeh];
           end;
          zeile:=hzeil;
         end else zeile:=zeile+t;
        farbe(highvg,highhg);
        write(zeile);
        inc(xpo);
        inc(zeilang);
        zeilang:=length(zeile);
       end else alarm;
       end; {if einfuegen}
      if not einfuegen then
       begin
        if (zeilang<xpo) and (xpo<=stellen) then
         begin
          zeile:=zeile+t;
          if xpo<stellen then inc(xpo);
          zeilang:=length(zeile);
          farbe(highvg,highhg);
          write(zeile);
         end
        else begin
              if xpo<=zeilang then zeile[xpo]:=t else alarm;
              if xpo<stellen then inc(xpo);
              farbe(highvg,highhg);
              write(zeile);
             end;
       end;
    if xpo>Stellen then xpo:=Stellen;
   end;
 Until T in [ESC, PgUp, PgDn, CR, CSDn, CSUp, TAB, Shift_Tab];
 cursorstrich;
 cursorAus;
end;



Procedure InitVar;
 var tn:byte;
     verz:string;
begin
verz:=gdir;
FillChar(Konfig,SizeOf(Konfig),0);
with Konfig do
 begin
  Kenner:=kennst;
  for tn:=1 to maxtnc do
   begin
     if tn=1 then TNC[tn].Art        :=1
     else TNC[tn].Art        :=0;
     TNC[tn].MaxKan     :=10;
     TNC[tn].NodeKan     :=0;
     TNC[tn].Identi     :='XP';
     TNC[tn].Port       := 0;
     TNC[tn].Tickzeile  :=false;
     TNC[tn].Com        :=1;
     TNC[tn].IRQ        :=4;
     TNC[tn].Adresse    :='3F8';
     TNC[tn].Baud       :=9600;
     TNC[tn].Fifo       :=False;
     TNC[tn].MultiplexNr:=0;
     tnc[tn].PortNam    :='TNC-Port '+MakeString(tn);
     TNC[tn].AfuPort    :=false;
     for i:=1 to 16 do tnc[tn].IniA[i]:='';
     for i:=1 to 16 do tnc[tn].DIniA[i]:='';
     tnc[tn].IniA[1]:='XP0TER';
     tnc[tn].IniA[2]:='XP0NOD';
     tnc[tn].IniA[3]:='C XP';
     tnc[tn].IniA[4]:='@T3 30000';
     tnc[tn].iniA[5]:='M UISC';
     tnc[tn].iniA[6]:='W 10';
     tnc[tn].iniA[7]:='F 300';
     tnc[tn].iniA[8]:='T 25';
     tnc[tn].iniA[9]:='@T2 150';
     tnc[tn].iniA[10]:='P 80';
     tnc[tn].iniA[11]:='N 20';
     tnc[tn].iniA[11]:='X 1';
     tnc[tn].IniB:='U 0';
     tnc[tn].DIniB:='U 1 Sri, Terminal im DOS.';
    end;

     RemVerz:=  Verz+'\REMOTE';
     SavVerz:=  Verz+'\SAVE';
     MailVerz:= VErz+'\MAIL';
     RunVerz:=  Verz+'\RUN';
     tempVerz:=  Verz+'\TMP';
     BinVerz:=  Verz+'\BIN';
     SPlVerz:=  Verz+'\7PLUS';
     MakVerz:=  Verz+'\MAKRO';
     ViewVerz:= Verz+'\VIEWER\VIEW.EXE';
     EditVerz:= Verz+'\EDITOR\EDITOR.EXE';
     spkverz:=  verz+'\SPK';
     CDRom   := 'R';

     ZeitBez    := 'MEZ';
     UTCDiff    := -1;
     UTCBenutzen:= false;
     Echtzeit   := true;
     PopupZeit  := 5;
     LockIRQ    := FALSE;
     SichAbfr   := TRUE;
     IDLE       := FALSE;
     ScrSavZ    := 5;
     PromptS    := '#CALL# de #MCAL#>';
     NTimeOut   := 30;
     TTimeOut   := 0;
     MaxFrameStd := 2;
     PacLenStd  := 230;
     MaxNodes   := 30;
     Lifetime   := 90;

     MH         := 30;
     BackScRam  := 4;
     VorschZRam := 20;
     BufferDat  := false;

     LPTNr     := 1;
     LPTAdr    := '3BC';

     SoftHardC   := false;
     WinRout     := false;
     WinRoutTime := 1;
     RXBeepStart := TRUE;
     AchzigBrail := True;
     Steuerz     := True;
     MarkTon     := True;
     AusgabeBios := FAlse;

     MailFErl    := true;
     for i:=1 to 10 do MailFrame[i]:='';
     MailFrame[1]:='MAIL';

     OwnMailFr := True;
     OwnMailPfad := 'MAIL';
     MailFrameZeit := 60;

     MaxLoginUser := 3;
     ReqNam:=true;

     quietDH:=false;
     quietzg:=false;
     for i:=1 to 3 do
      begin
       QuietZt[i].StdAnf:=12;
       QuietZt[i].minanf:=0;
       QuietZt[i].minend:=0;
       QuietZt[i].Stdend:=12;
       quietzt[i].aktiv:=false;
      end;
     PersName:='';
     PersLoc:='';
     PersQTH:='';
 end;
end;





Procedure DirCheck;
begin
 writeln;writeln;
 farbe(white,black);
 writeln(helpSetup[21]+':');
 writeln;
with konfig do
 begin
  dirs:=mdir (RemVerz,false);
  dirs:=mdir (SavVerz,false);
  dirs:=mdir (MailVerz,false);
  dirs:=mdir (RunVerz,false);
  dirs:=mdir (BinVerz,false);
  dirs:=mdir (splVerz,false);
  dirs:=mdir (makVerz,false);
  dirs:=mdir (TempVerz,false);
 writeln;
 writeln;
 writeln(helpSetup[22]+':');
 writeln;
 if not SubExists(ViewVerz,true) then writeln(viewverz+' '+helpSetup[23]+'!')
   else writeln(viewverz+' '+helpSetup[24]+'.');
 if not SubExists(editVerz,true) then writeln(editverz+' '+helpSetup[23]+'!')
   else writeln(editverz+' '+helpSetup[24]+'.');
 end;
 writeln;
end;



Procedure HMenu(VAR It:Byte; Var Tast:Char);
var italt:byte;
    flagy:boolean;
begin
italt:=it;
Repeat
flagy:=false;
 CursorAus;
 farbe(white, black);
 TextZent(Balken(25,' '),2,80,y+2+italt);
 TextZent(HMIt[itAlt],2,80,y+2+italt);
 italt:=it;
 farbe(highvg, highhg);
 TextZent(Balken(25,' '),2,80,y+2+it);
 TextZent(HMIt[it],2,80,y+2+it);
 if (Konfig.PersName='') or (Konfig.PersLoc='') or (Konfig.PersQTH='') then
  begin
   flagy:=true;
   it:=9;
   tast:=CR;
  end;
 if not flagy then Tast:=taste;
 Case Tast Of
  CsDn,
  CsRt: It:=it+1;
  CsUp,
  CsLt: It:=It-1;
  Pos1: It:=1;
  Ende: It:=maxhmenu;
 end;
 if it>maxhmenu then it:=1;
 if it<1 then it:=maxhmenu;
until (Tast=ESC) or (Tast=CR);
CursorEin;
end;


Procedure TNCIniDeini(Ini : Boolean);
var x, y:Byte;
    Tast:char;
    Eingabe:string;
    Ausw:Byte;
    Lang:Byte;

begin
eingabe:='';
 farbe(white,Black);
 clrscr;
 ladebild(Rahmen);
 if ini then begin
  Textzent(helpSetup[10]+' '+MakeString(Tau),2,80,ytid-2);
  textzent(endfill(length(helpSetup[10])+2,'Õ',eingabe),2,80,ytid-1);
  farbe(Specvg, black);
  textzent(helpSetup[8],2,80,23);
 end
 else begin
  Textzent(helpSetup[11]+' '+MakeString(Tau),2,80,ytid-2);
  textzent(endfill(length(helpSetup[11])+2,'Õ',eingabe),2,80,ytid-1);
  farbe(Specvg, black);
  textzent(helpSetup[8],2,80,23);
 end;
 farbe(white,black);
 y:=ytid-1; x:=xtid;
 gotoxy(x,y+2); write(HelpB[17]+':');
 gotoxy(x,y+4); write(HelpB[18]+':');
 farbe(highvg,highhg);
 for i:=1 to 16 do
  begin
    y:=y+2;
    if i=9 then
     begin
      y:=ytid+1;
      x:=xtid+40;
     end;

    if (i in [1,2]) and (ini) then gotoxy(x+18,y) else gotoxy(x,y);
    if (i in [1,2]) and (ini) then write(Balken(12,' ')) else write(Balken(30,' '));
    if (i in [1,2]) and (ini) then gotoxy(x+18,y) else gotoxy(x,y);
    if ini then write(Konfig.TNC[tau].INIA[i])
           else write(Konfig.TNC[tau].DINIA[i]);
  end;
  gotoxy(xtid,y+2);
  write(Balken(70,' '));
  gotoxy(xtid,y+2);
  if ini then write(Konfig.TNC[tau].inib)
  else write(Konfig.TNC[tau].Dinib);

  Ausw:=1;


  repeat
   {Tast:=Taste;}
   Case Tast of
    F1:Help(false,0);
    cr,csdn,tab:
     begin
      inc(Ausw);
      if Ausw>17 then Ausw:=1;
     end;
    csUP,shift_tab:
     begin
      Dec(Ausw);
      if Ausw<1 then Ausw:=17;
     end;
   end;

   Case Ausw of
    1,2,3,4,5,6,7,8:
     begin
      y:=0;
      for i:=1 to Ausw do y:=y+2;
      y:=y+ytid-1;
      x:=xtid;
      lang:=30;
      if ini then eingabe:=Konfig.tnc[tau].IniA[Ausw]
             else eingabe:=Konfig.tnc[tau].DIniA[Ausw]
     end;
    9..16:
     begin
      y:=0;
      for i:=9 to Ausw do y:=y+2;
      y:=y+ytid-1;
      x:=xtid+40;
      lang:=30;
      if ini then eingabe:=Konfig.tnc[tau].Inia[i]
             else eingabe:=Konfig.tnc[tau].DInia[i];
     end;
    17:
     begin
      y:=ytid+17;
      x:=xtid;
      lang:=70;
      if ini then eingabe:=Konfig.tnc[tau].IniB
             else eingabe:=Konfig.tnc[tau].DInib
     end;
   end;


   if (Ausw in [1,2]) and (ini) then
    begin
     repeat
      if eingabe='#' then
       begin
        eingabe:='';
         if (ausw in [1,2]) and (ini) then gotoxy(xtid+18,ytid-1+(ausw*2));
         if (ausw in [1,2]) and (ini) then write(Balken(12,' '));
       end;
      Editor(eingabe,x+18,y,12,true,false,Tast,0);
      i:=0;
      if eingabe<>'#' then
      while (Length(eingabe)>i) do
       begin
        inc(i);
        if not (eingabe[i] in ['A'..'Z', 'a'..'z', '1'..'9', '0', '-']) then eingabe:='#';
       end;
     until eingabe<>'#';
    end;
   if (ini) and (AUsw >2) then Editor(eingabe,x,y,lang,false,true,Tast,0);
   if not ini then Editor(eingabe,x,y,lang,false,true,Tast,0);


   Case Ausw of
    1..16: begin
      if ini then Konfig.tnc[tau].IniA[Ausw]:=eingabe
             else Konfig.tnc[tau].DIniA[Ausw]:=eingabe;
     end;
    17:
     begin
      if ini then Konfig.tnc[tau].IniB:=eingabe
             else Konfig.tnc[tau].DInib:=eingabe;
     end;
   end;
  until Tast=ESC;
end;


Procedure tncMaske(tau:byte; stat:Byte);        {//db1ras}
  var dummy:string;
Begin
  farbe(white,black);
  If stat=0 Then Begin
    dummy:='';
    IThema(20);
    clrscr;
    ladebild(Rahmen);
    TEXTZent(helpSetup[9]+' '+MakeString(Tau),2,80,ytnc-1);
    TextZent(EndFill(length(helpSetup[9])+2,'Õ',dummy),2,80,ytnc);
  End;
  With Konfig Do Begin
    gotoxy(xtnc,ytnc+1); writeln(helpb[1]+': ',TNC_Art[TNC[tau].Art]);
    If TNC[tau].Art=0 Then
      farbe(DarkGray,black);
    gotoxy(xtnc,ytnc+2); writeln(helpb[2]+': ',TNC[tau].IDenti);
    gotoxy(xtnc,ytnc+3); writeln(helpb[3]+': ',TNC[Tau].Port);
    gotoxy(xtnc,ytnc+4); writeln(helpb[4]+': ',TNC[tau].MaxKan);
    gotoxy(xtnc,ytnc+5); writeln(helpb[5]+': ');
    gotoxy(xtnc+27,ytnc+5);
    if TNC[tau].Tickzeile then write (respt[1]) else write(RespT[2]);

    If TNC[tau].Art=3 Then
      farbe(DarkGray,black);
    gotoxy(xtnc,ytnc+6); writeln(helpb[6]+': ',TNC[tau].COM);
    gotoxy(xtnc,ytnc+7); writeln(helpb[7]+': ',TNC[tau].Adresse);
    gotoxy(xtnc,ytnc+8); writeln(helpb[8]+': ',TNC[tau].irq);
    gotoxy(xtnc,ytnc+9); writeln(helpb[9]+': ',TNC[tau].Baud);
    gotoxy(xtnc,ytnc+10);writeln(helpb[10]+': ',TNC[tau].Multiplexnr);
    gotoxy(xtnc,ytnc+11);write  (helpb[11]+': ');
    if TNC[tau].Fifo then write(respt[1]) else write(RespT[2]);

    If TNC[tau].Art=3 Then
      farbe(white,black);
    gotoxy(xtnc,ytnc+12);write(helpb[12]+': ',konfig.tnc[tau].portnam);
    gotoxy(xtnc,ytnc+13);write(helpb[13]+': ',konfig.tnc[tau].NodeKan,' ');
    gotoxy(Xtnc, ytnc+14); write(HelpB[16]+': ');
    if TNC[tau].AfuPort then write(respt[1]) else write(RespT[2]);
    gotoxy(xtnc, ytnc+15); write(HelpB[14]);
    gotoxy(xtnc, ytnc+16); write(HelpB[15]);
    If TNC[tau].Art=0 Then
      farbe(white,black);
  End;
  If stat=0 Then Begin
    textzent(helpSetup[7],2,80,21);
    farbe(specvg,black);
    textzent(helpSetup[4],2,80,22);
    textzent(helpSetup[8],2,80,23);
    farbe(white,black);
  End;
End;


PROCEDURE TNCSet;
var tast:char;
    fuel:byte;
    Ausw, Auswa : Byte;
    Change:boolean;

begin
HelpNr:=3;
 with Konfig do
  begin
 Ausw:=1;
 farbe(white, black);
 clrscr;
 cursoraus;
 {COM, IRq; ADR, Tick, Art, MaxKan, Multiplex, Fifo, Port, Baud, ID}

 tncmaske(tau,0);
 farbe(highvg,highhg);
 gotoxy(xtnc+27,ytnc+1);write(tnc_art[tnc[tau].art]);
 change:=true;
 repeat
  if (Ausw<>2) and (ausw<>7) and (ausw<>12) then tast:=taste;
  Auswa:=ausw;
    Case Tast of
     Pgdn:
      begin
       Tau:=tau+1;
       if Tau>8 then Tau:=1;
       tncMaske(Tau,0);
       farbe(highvg,highhg);
       gotoxy(xtnc+27,ytnc+1);write(tnc_art[tnc[tau].art]);
       Ausw:=1;
      end;
     PgUp:
      begin
       Tau:=tau-1;
       if Tau<1 then Tau:=8;
       tncMaske(Tau,0);
       farbe(highvg,highhg);
       gotoxy(xtnc+27,ytnc+1);write(tnc_art[tnc[tau].art]);
       Ausw:=1;
      end;
     CsDn, Tab:
      begin
         If tnc[tau].art<>0 Then Begin                           {//db1ras}
           Ausw:=Ausw+1;
           if Ausw>16 then Ausw:=1;
           If (tnc[tau].art=3) And (Ausw=6) Then Ausw:=12;       {//db1ras}
           Change:=true;
         End;
      end;
     CR:
      begin
       if (Ausw<>15) and (Ausw<>16) And (tnc[tau].art<>0) then   {//db1ras}
        begin
         Ausw:=Ausw+1;
         if Ausw>16 then Ausw:=1;
         If (tnc[tau].art=3) And (Ausw=6) Then Ausw:=12;         {//db1ras}
         Change:=true;
         tast:=#1;
        end;
      end;
     CsUp, Shift_Tab:
      begin
         If tnc[tau].art<>0 Then Begin                           {//db1ras}
           Ausw:=Ausw-1;
           if Ausw<1 then Ausw:=16;
           If (tnc[tau].art=3) And (Ausw=11) Then Ausw:=5;       {//db1ras}
           Change:=true;
         End;
      end;
     end;

  if Change then
   begin
    change:=false;
    farbe(white,black);
    gotoxy(xtnc+27,ytnc+Auswa);
    case AuswA of
     1: write(tnc_art[tnc[tau].art]);
     2: write(tnc[tau].identi+'  ');
     3: write(tnc[tau].port);
     4: write(tnc[tau].maxkan,' ');
     5: if TNC[tau].Tickzeile then write (RespT[1]) else write(RespT[2]);
     6: write(tnc[tau].com);
     7: write(tnc[tau].adresse+'   ');
     8: write(tnc[tau].irq,'  ');
     9: write(tnc[tau].baud,'  ');
     10:write(tnc[tau].MultiplexNr);
     11:begin
         if tnc[tau].Fifo then write(RespT[1]) else write(RespT[2]);
        end;
     12:begin
         write(balken(21,' '));
         gotoxy(xtnc+27,ytnc+Auswa);
         write(tnc[tau].PortNam);
        end;
     13: write(tnc[tau].NodeKan,'  ');
     14: if tnc[tau].AfuPort then write(RespT[1]) else write(RespT[2]);
     15: begin
          gotoxy(xtnc,ytnc+auswa);
          Write(HelpB[14]);
         end;

     16: begin
          gotoxy(xtnc,ytnc+auswa);
          Write(HelpB[15]);
         end;
    end;
    farbe(highhg,black);
{    textzent(Balken(78,' '),2,80,21);}
    textzent(Balken(78,' '),2,80,22);
    textzent(Balken(78,' '),2,80,23);
    farbe(highvg, highhg);
    gotoxy(xtnc+27,ytnc+Ausw);
    case Ausw of
     1: begin
         write(tnc_art[tnc[tau].art]);
         farbe(specvg,black);
         textzent(helpSetup[4],2,80,22);
         textzent(helpSetup[8],2,80,23);
        end;
     2: begin
         write(tnc[tau].identi);
         farbe(specvg,black);
         textzent(helpSetup[8],2,80,23);
        end;
     3: begin
         write(tnc[tau].port);
         farbe(specvg,black);
         textzent(helpSetup[4],2,80,22);
         textzent(helpSetup[8],2,80,23);
        end;
     4,13: begin
         write(tnc[tau].maxkan);
         farbe(specvg,black);
         textzent(helpSetup[5],2,80,22);
         textzent(helpSetup[8],2,80,23);
        end;
     5: begin
         if TNC[tau].Tickzeile then write (RespT[1]) else write(RespT[2]);
         farbe(specvg,black);
         textzent(helpSetup[4],2,80,22);
         textzent(helpSetup[8],2,80,23);
        end;
     6: begin
         write(tnc[tau].com);
         farbe(specvg,black);
         textzent(helpSetup[4],2,80,22);
         textzent(helpSetup[8],2,80,23);
        end;
     7: begin
         write(tnc[tau].adresse);
         farbe(specvg,black);
         textzent(helpSetup[8],2,80,23);
        end;
     8: begin
         write(tnc[tau].irq);
         farbe(specvg,black);
         textzent(helpSetup[5],2,80,22);
         textzent(helpSetup[8],2,80,23);
        end;
     9: begin
         write(tnc[tau].baud);
         farbe(specvg,black);
         textzent(helpSetup[4],2,80,22);
         textzent(helpSetup[8],2,80,23);
        end;
     10: begin
         write(tnc[tau].MultiplexNr);
         farbe(specvg,black);
         textzent(helpSetup[4],2,80,22);
         textzent(helpSetup[8],2,80,23);
        end;
     11:begin
         if tnc[tau].Fifo then write(RespT[1]) else write(RespT[2]);
         farbe(specvg,black);
        { textzent('Fifo-UnterstÅtzung.',2,80,22);}
         textzent(helpSetup[4],2,80,22);
         textzent(helpSetup[8],2,80,23);
        end;
     12:begin
         write(balken(20,' '));
         gotoxy(xtnc+27,ytnc+Ausw);
         write(tnc[tau].PortNam);
         farbe(specvg,black);
         textzent(helpSetup[8],2,80,23);
        end;
     14: begin
         if tnc[tau].AfuPort then write(RespT[1]) else write(RespT[2]);
         farbe(specvg,black);
        { textzent('Fifo-UnterstÅtzung.',2,80,22);}
         textzent(helpSetup[4],2,80,22);
         textzent(helpSetup[8],2,80,23);
         end;
     15: begin
          gotoxy(xtnc, ytnc+ausw);
          write(Helpb[14]);
          farbe(specvg,black);
          textzent(helpSetup[6],2,80,22);
          textzent(helpSetup[8],2,80,23);
         end;
     16: begin
          gotoxy(xtnc, ytnc+ausw);
          write(Helpb[15]);
          farbe(specvg,black);
          textzent(helpSetup[6],2,80,22);
          textzent(helpSetup[8],2,80,23);
         end;
    end;
   end;

  if (Tast=cr) and (Ausw=15) then
   begin
     HelpNr:=4;
     TNCIniDeini(true);
     TNCMaske(tau,0);
     farbe(highvg,highhg);
     gotoxy(xtnc, ytnc+15); write(HelpB[14]);
     farbe(specvg,black);
     textzent(helpSetup[6],2,80,23);
     HelpNr:=3;
    end;
  if (Tast=cr) and (Ausw=16) then
   begin
    HelpNr:=5;
    TNCIniDeini(false);
    TNCMaske(tau,0);
     farbe(highvg,highhg);
     gotoxy(xtnc, ytnc+16); write(HelpB[15]);
     farbe(specvg,black);
     textzent(helpSetup[6],2,80,23);
     HelpNr:=3;
   end;

  If Ausw=1 then
   begin
    Case Tast of
     CsRt:
      begin
       Tnc[tau].art:=tnc[tau].art+1;
       if tnc[tau].art>4 then tnc[tau].art:=0;
       tncMaske(tau,1);    {//db1ras}
      end;
     CsLt:
      begin
       if tnc[tau].art=0 then tnc[tau].art:=4 else
         Tnc[tau].art:=tnc[tau].art-1;
       tncMaske(tau,1);    {//db1ras}
      end;
    end;
   if tnc[tau].art>4 then tnc[tau].art:=0;
   farbe(highvg,highhg);
   gotoxy(xtnc+27,ytnc+ausw);write(tnc_art[tnc[tau].art]);
   end; {if Ausw=1}

   If Ausw=2 then
   begin
    cursorein;
    farbe(highvg, highhg);
    Editor(tnc[tau].identi,xtnc+27,ytnc+ausw,2,True,false,Tast,20);
    cursoraus;
   end;

   if Ausw=3 then
   begin
   case tast of
     cslt: begin
            if tnc[tau].port=0 then tnc[tau].port:=10;
            if tnc[tau].port>0 then dec(tnc[tau].port);
           end;
     CsRt: begin
            inc(tnc[tau].port);
            if tnc[tau].port>9 then tnc[tau].port:=0;
           end;
     end;
   farbe(highvg,highhg);
   gotoxy(xtnc+27,ytnc+ausw);write(tnc[tau].Port);
   end; {if Ausw=3}

   if Ausw=4 then
    begin
     Case Tast of
      Csrt:
       begin
        if TNC[tau].MaxKan<60 then inc(TNC[tau].MaxKan)
         else Alarm;
       end;
      Ctrl_Csrt:
       begin
        if tnc[tau].maxkan=60 then alarm;
        if (tnc[tau].maxkan>50) and (tnc[tau].maxkan<60) then tnc[tau].maxkan:=60;
        if TNC[tau].MaxKan<51 then TNC[tau].MaxKan:=tnc[tau].maxkan+10;
       end;
      Cslt:
       begin
        if TNC[tau].MaxKan>1 then dec(TNC[tau].MaxKan)
         else Alarm;
       end;
      Ctrl_Cslt:
       begin
        if tnc[tau].MaxKan<=1 then alarm;
        if tnc[tau].MaxKan<11 then TNC[tau].MaxKan:=1;
        if TNC[tau].MaxKan>10 then TNC[tau].MaxKan:=tnc[tau].maxkan-10;
       end;
     end; {Case}
     farbe(highvg,highhg);
     gotoxy(xtnc+27,ytnc+Ausw);
     fuel:=0;
     if tnc[tau].MaxKan<10 then fuel:=fuel+1;
     write(tnc[tau].MaxKan,Balken(fuel,' '));
     if TNC[tau].MaxKan<TNC[tau].NodeKan then TNC[tau].NodeKan:=TNC[tau].MaxKan;
     farbe(white, black);
{**!!ytnc!!**}  gotoxy(xtnc+27,ytnc+13);
     write(tnc[tau].NodeKan,'  ');
    end; {ausw=4}

   if Ausw=5 then
    begin
     Case Tast of
      CsRt, CsLt:
       begin
        TNC[tau].Tickzeile:= not TNC[tau].Tickzeile;
        farbe(highvg,highhg);
        gotoxy(xtnc+27,ytnc+Ausw);
        if TNC[tau].Tickzeile then write (RespT[1]) else write(RespT[2]);
       end;
      end;
    end; {if Ausw=5}

   if Ausw=6 then
   begin
    case tast of
     cslt: begin
            dec(tnc[tau].com);
            if tnc[tau].com=0 then tnc[tau].com:=4;
           end;
     CsRt: begin
            inc(tnc[tau].com);
            if tnc[tau].com>4 then tnc[tau].com:=1;
           end;
     end;
   farbe(highvg,highhg);
   gotoxy(xtnc+27,ytnc+ausw);write(tnc[tau].com);
   end; {if Ausw=6}

   If Ausw=7 then
   begin
    cursorein;
    farbe(highvg, highhg);
    Editor(tnc[tau].adresse,xtnc+27,ytnc+ausw,3,True,false,Tast,20);
    cursoraus;
   end;

   if Ausw=8 then
    begin
     Case Tast of
      Csrt:
       begin
        if TNC[tau].irq<15 then inc(TNC[tau].irq)
         else Alarm;
       end;
      Ctrl_Csrt:
       begin
        if TNC[tau].irq=15 then alarm;
        if tnc[tau].irq>5 then tnc[tau].irq:=15;
        if TNC[tau].irq<6 then TNC[tau].irq:=tnc[tau].irq+10;
       end;
      Cslt:
       begin
        if TNC[tau].irq>0 then dec(TNC[tau].irq)
         else Alarm;
       end;
      Ctrl_Cslt:
       begin
        if tnc[tau].irq=0 then alarm;
        if tnc[tau].irq<10 then TNC[tau].irq:=0;
        if TNC[tau].irq>9 then TNC[tau].irq:=tnc[tau].irq-10;
       end;
     end; {Case}
     farbe(highvg,highhg);
     gotoxy(xtnc+27,ytnc+Ausw);
     fuel:=0;
     if tnc[tau].irq<10 then fuel:=fuel+1;
     write(tnc[tau].irq,Balken(fuel,' '));
    end; {ausw=8}

   if Ausw=9 then
    begin
     Case Tast of
      CsRt:
       begin
        Case (TNC[Tau].Baud div 10) of
          120: TNC[tau].Baud:= 2400;
          240: TNC[tau].Baud:= 4800;
          480: TNC[tau].Baud:= 7200;
          720: TNC[tau].Baud:= 9600;
          960: TNC[tau].Baud:= 14400;
          1440: TNC[tau].Baud:= 19200;
          1920: TNC[tau].Baud:= 28800;
          2880: TNC[tau].Baud:= 38400;
          3840: TNC[tau].Baud:= 57600;
          5760: TNC[tau].Baud:= 76800;
          7680: TNC[tau].Baud:= 115200;
          11520: TNC[tau].Baud:= 1200;
         end;
       end;
      Cslt:
       begin
        Case (TNC[Tau].Baud div 10) of
          120: TNC[tau].Baud:= 115200;
          240: TNC[tau].Baud:= 1200;
          480: TNC[tau].Baud:= 2400;
          720: TNC[tau].Baud:= 4800;
          960: TNC[tau].Baud:= 7200;
          1440: TNC[tau].Baud:= 9600;
          1920: TNC[tau].Baud:= 14400;
          2880: TNC[tau].Baud:= 19200;
          3840: TNC[tau].Baud:= 28800;
          5760: TNC[tau].Baud:= 38400;
          7680: TNC[tau].Baud:= 57600;
          11520: TNC[tau].Baud:= 76800;
         end;
       end;
      end;
     farbe(highvg,highhg);
     gotoxy(xtnc+27,ytnc+Ausw);
     fuel:=0;
     if tnc[tau].baud<100000 then fuel:=fuel+1;
     if tnc[tau].baud<10000 then fuel:=fuel+1;
     write(tnc[tau].Baud,Balken(fuel,' '));
    end; {if Ausw=9}

    if Ausw=10 then
   begin

   case tast of
     cslt: begin
            if tnc[tau].multiplexnr=0 then tnc[tau].multiplexnr:=5;
            if tnc[tau].multiplexnr>0 then dec(tnc[tau].multiplexnr);
           end;
     CsRt: begin
            inc(tnc[tau].multiplexnr);
            if tnc[tau].multiplexnr>4 then tnc[tau].multiplexnr:=0;
           end;
     end;
   farbe(highvg,highhg);
   gotoxy(xtnc+27,ytnc+ausw);write(tnc[tau].multiplexnr);
   end; {if Ausw=10}

   if Ausw=11 then
    begin
     Case Tast of
      CsRt, CsLt:
       begin
        TNC[tau].Fifo:= not TNC[tau].fifo;
        farbe(highvg,highhg);
        gotoxy(xtnc+27,ytnc+Ausw);
        if TNC[tau].fifo then write (RespT[1]) else write(RespT[2]);
       end;
      end;
    end; {if Ausw=11}

   If Ausw=12 then
   begin
    cursorein;
    farbe(highvg, highhg);
    Editor(tnc[tau].PortNam,xtnc+27,ytnc+ausw,20,false,true,Tast,20);
    cursoraus;
   end;

   if Ausw=13 then
    begin
     Case Tast of
      Csrt:
       begin
        if TNC[tau].NodeKan<TNC[tau].MaxKan then inc(TNC[tau].NodeKan)
         else Alarm;
       end;
      Ctrl_Csrt:
       begin
        if tnc[tau].NodeKan=Tnc[tau].MaxKan then alarm;
        if (tnc[tau].NodeKan>(Tnc[tau].MaxKan-10)) and (tnc[tau].NodeKan<Tnc[tau].MaxKan) then
          tnc[tau].NodeKan:=Tnc[tau].MaxKan;
        if TNC[tau].NodeKan<(Tnc[tau].MaxKan-9) then TNC[tau].NodeKan:=tnc[tau].NodeKan+10;
       end;
      Cslt:
       begin
        if TNC[tau].NodeKan>0 then dec(TNC[tau].NodeKan)
         else Alarm;
       end;
      Ctrl_Cslt:
       begin
        if tnc[tau].NodeKan<=1 then alarm;
        if tnc[tau].NodeKan<11 then TNC[tau].NodeKan:=0;
        if TNC[tau].NodeKan>10 then TNC[tau].NodeKan:=tnc[tau].NodeKan-10;
       end;
     end; {Case}
     farbe(highvg,highhg);
     gotoxy(xtnc+27,ytnc+Ausw);
     fuel:=0;
     if tnc[tau].NodeKan<10 then fuel:=fuel+1;
     write(tnc[tau].NodeKan,Balken(fuel,' '));
    end; {ausw=13}
    if Ausw=14 then
    begin
     Case Tast of
      CsRt, CsLt:
       begin
        TNC[tau].AfuPort:= not TNC[tau].AfuPort;
        farbe(highvg,highhg);
        gotoxy(xtnc+27,ytnc+Ausw);
        if TNC[tau].AfuPort then write (RespT[1]) else write(RespT[2]);
       end;
      end;
    end; {if Ausw=14}


   if Tast=f1 then begin
    Help(false,20);
    IThema(20);
   end;

 until Tast=ESC;
end; {with konfig ..}
end;
procedure verzeichnisse;
var Ausw,
    Auswa:byte;
    tast:char;
    change:boolean;
    eingabe:string;

begin
IThema(30);
eingabe:='';
HelpNr:=6;
farbe(white,black);
clrscr;
ladebild(rahmen);

Textzent(helpSetup[12],2,80,yverz-3);
textzent(endfill(length(helpSetup[12]),'Õ',eingabe),2,80,yverz-2);
textzent(helpSetup[8],2,80,23);

gotoxy(1,yverz+1);
with konfig do
begin
{!DIRT}
gotoxy(2,yverz+1);writeln(HelpB[1]+': '+RemVerz);
gotoxy(2,yverz+2);writeln(helpB[2]+': '+SavVerz);
gotoxy(2,yverz+3);writeln(helpB[3]+': '+MailVerz);
gotoxy(2,yverz+4);writeln(helpB[4]+': '+RunVerz);
gotoxy(2,yverz+5);writeln(helpB[5]+': '+BinVerz);
gotoxy(2,yverz+6);writeln(HelpB[6]+': '+splverz);
gotoxy(2,yverz+7);writeln(HelpB[7]+': '+makverz);
gotoxy(2,yverz+8);writeln(HelpB[8]+': '+tempverz);
gotoxy(2,yverz+9);writeln(HelpB[9]+': '+viewverz);
gotoxy(2,yverz+10);writeln(HelpB[10]+': '+editverz);
gotoxy(2,yverz+11);writeln(HelpB[11]+': '+spkverz);
gotoxy(2,yverz+12);writeln(HelpB[12]+': '+CDRom);
farbe(specvg,black);
change:=false;
Ausw:=1;
repeat
if Change then
 begin

  Farbe(white,black);

  gotoxy(xverz+20, yverz+auswa);
  write(Balken(58,' '));
  gotoxy(xverz+20, yverz+auswa);
 change:=false;
    case auswa of
    1: write(remverz);
    2: write(savverz);
    3: write(Mailverz);
    4: write(Runverz);
    5: write(Binverz);
    6: write(SPlverz);
    7: write(Makverz);
    8: write(TempVerz);
    9: write(Viewverz);
    10: write(Editverz);
    11: write(SPKVerz);
    12: write(CDRom);
   end;
   farbe(specvg,black);

end;

Auswa:=Ausw;

   farbe(highvg,highhg);
   gotoxy(xverz+20, yverz+ausw);
   if ausw<>12 then write(Balken(58,' '));
   gotoxy(xverz+20, yverz+ausw);
   case ausw of
    1: begin
        write(remverz);
        Editor(remverz,xverz+20,yverz+ausw,58,true,false,tast,0);
        if remverz[length(remverz)]='\' then delete(remverz,length(remverz),1);
       end;
    2: begin
        write(savverz);
        Editor(savverz,xverz+20,yverz+ausw,58,true,false,tast,0);
        if savverz[length(savverz)]='\' then delete(savverz,length(savverz),1);
       end;
    3: begin
        write(Mailverz);
        Editor(Mailverz,xverz+20,yverz+ausw,58,true,false,tast,0);
        if mailverz[length(mailverz)]='\' then delete(mailverz,length(mailverz),1);
       end;
    4: begin
        write(Runverz);
        Editor(Runverz,xverz+20,yverz+ausw,58,true,false,tast,0);
        if runverz[length(runverz)]='\' then delete(runverz,length(runverz),1);
       end;
    5: begin
        write(Binverz);
        Editor(Binverz,xverz+20,yverz+ausw,58,true,false,tast,0);
        if binverz[length(binverz)]='\' then delete(binverz,length(binverz),1);
       end;
    6: begin
        write(SPlverz);
        Editor(Splverz,xverz+20,yverz+ausw,58,true,false,tast,0);
        if splverz[length(splverz)]='\' then delete(splverz,length(splverz),1);
       end;
    7: begin
        write(Makverz);
        Editor(Makverz,xverz+20,yverz+ausw,58,true,false,tast,0);
        if makverz[length(makverz)]='\' then delete(makverz,length(makverz),1);
       end;
    8: begin
        write(TempVerz);
        Editor(TempVerz,xverz+20,yverz+ausw,58,true,false,tast,0);
        if makverz[length(Tempverz)]='\' then delete(Tempverz,length(Tempverz),1);
       end;
    9: begin
        write(Viewverz);
        Editor(Viewverz,xverz+20,yverz+ausw,58,true,false,tast,0);
        if viewverz[length(viewverz)]='\' then delete(viewverz,length(viewverz),1);
       end;
    10: begin
        write(Editverz);
        Editor(Editverz,xverz+20,yverz+ausw,58,true,false,tast,0);
        if editverz[length(editverz)]='\' then delete(editverz,length(editverz),1);
       end;
    11: begin
        write(spkverz);
        Editor(spkverz,xverz+20,yverz+ausw,58,true,false,tast,0);
        if spkverz[length(spkverz)]='\' then delete(spkverz,length(spkverz),1);
       end;
    12: begin
        write(CDRom);
        Eingabe:=CDROM;
        Editor(eingabe,xverz+20,yverz+ausw,1,true,false,tast,0);
        CDROM:=Eingabe[1];
       end;
   end;



   case Tast of
   f1: help(false,0);
    CR, TAB, CSDn:
      begin
       Ausw:=Ausw+1;
       if Ausw>12 then Ausw:=1;
       change:=true;
      end;
     CsUp, Shift_Tab:
      begin
       Ausw:=Ausw-1;
       if Ausw<1 then Ausw:=12;
       change:=true;
      end;
     end;
until Tast=ESC;
end; {with}
end;

Procedure quietEinstellungen;
var tast : char;
    eingabe: string;
    i : byte;
    ausw, a:byte;
begin
with Konfig do
begin
 eingabe:='';
 helpNr:=12;
 farbe (white, black);
 clrscr;
 ladebild(rahmen);
  Textzent(helpSetup[2],2,80,yver-2);
 textzent(endfill(length(helpSetup[2]),'Õ',eingabe),2,80,yver-1);

 gotoxy(xver,yver+1); write(Helpb[13]+': ');
 if QuietDh then writeln(RespT[1]) else writeln(RespT[2]);

 gotoxy(xver,yver+2); write(helpb[14]+': ');
 if quietzg then writeln(RespT[1]) else writeln(RespT[2]);

 gotoxy(xver,yver+3); write(helpb[15]+': ');
 for i:=1 to 3 do
  begin
   gotoxy(xver+27, yver+i+2);
   if quietzt[i].StdAnf<10 then write('0');
   write(Quietzt[i].StdAnf,':');

   if quietzt[i].minanf<10 then write('0');
   write(quietzt[i].MinAnf,' - ');

   if quietzt[i].stdend<10 then write('0');
   write(quietzt[i].StdEnd,':');

   if quietzt[i].minend<10 then write('0');
   write(quietzt[i].MinEnd);
   end;

ausw:=1; a:=0;
repeat
   farbe(white, black);
   for i:=1 to 3 do
    begin
     gotoxy(xver+27, yver+i+2);
     farbe(white, black);
     if (i=1) and (ausw=3) then farbe(highvg, highhg);
     if (i=2) and (ausw=7) then farbe(highvg, highhg);
     if (i=3) and (ausw=11) then farbe(highvg, highhg);
     if quietzt[i].StdAnf<10 then write('0');
     write(Quietzt[i].StdAnf);
     farbe(white, black);
     write(':');

     if (i=1) and (ausw=4) then farbe(highvg, highhg);
     if (i=2) and (ausw=8) then farbe(highvg, highhg);
     if (i=3) and (ausw=12) then farbe(highvg, highhg);
     if quietzt[i].minanf<10 then write('0');
     write(quietzt[i].MinAnf);
     farbe(white, black);
     write(' - ');

     if (i=1) and (ausw=5) then farbe(highvg, highhg);
     if (i=2) and (ausw=9) then farbe(highvg, highhg);
     if (i=3) and (ausw=13) then farbe(highvg, highhg);
     if quietzt[i].stdend<10 then write('0');
     write(quietzt[i].StdEnd);
     farbe(white, black);write(':');

     if (i=1) and (ausw=6) then farbe(highvg, highhg);
     if (i=2) and (ausw=10) then farbe(highvg, highhg);
     if (i=3) and (ausw=14) then farbe(highvg, highhg);
     if quietzt[i].minend<10 then write('0');
     write(quietzt[i].MinEnd);
     farbe(white, black);
     if quietzt[i].aktiv then write(' '+Respt[3]) else write(' '+respt[4]);
    end;

   if ausw=1 then farbe(highvg, highhg);
   gotoxy(xver+27,yver+1);
   if QuietDh then writeln(RespT[1]) else writeln(RespT[2]);
   farbe(white, black);

   if ausw=2 then farbe(highvg, highhg);
   gotoxy(xver+27,yver+2);
   if quietzg then writeln(RespT[1]) else writeln(RespT[2]);
   farbe(white,black);
   textzent(BAlken(78,' '),2,80,21);
   textzent(BAlken(78,' '),2,80,22);
   textzent(BAlken(78,' '),2,80,23);
   case ausw of
    1,2: begin
           textzent(helpSetup[4],2,80,22);
           textzent(helpSetup[8],2,80,23);
          end;
    3..14: begin
           textzent(helpSetup[5],2,80,21);
           textzent(helpSetup[36],2,80,22);
           textzent(helpSetup[8],2,80,23);
          end;
     end;
 tast:=taste;
   case Tast of
  F1 : help(false,40);
  CR,tab,CsDn: inc(ausw);
  shift_tab,csup: dec(ausw);
 end;
  if ausw>14 then ausw:=1;
 if ausw<1 then ausw:=14;

 A:=0;
 if ausw in [3..6] then a:=1;
 if ausw in [7..10] then a:=2;
 if ausw in [11..14] then a:=3;




 case ausw of
  1: begin
      case Tast of
       CsLt, CsRt: quietdh:=not quietDh;
      end;
     end;
  2: begin
      case Tast of
       CsLt, CsRt: quietzg:=not quietzg;
      end;
     end;

  3,7,11: begin
      case Tast of
       #32: QuietZt[A].Aktiv:=not QuietZt[a].aktiv;
       CsRt: if quietzt[a].stdanf<23 then inc(quietzt[a].stdanf)
                 else quietzt[a].stdanf:=0;
       Cslt: if quietzt[a].StdAnf>0 then dec(quietzt[a].Stdanf)
                else quietzt[a].stdanf:=23;
       Ctrl_CsLt:
          begin
           if quietzt[a].StdAnf<10 then quietzt[a].stdAnf:=quietzt[a].stdanf+24-10
            else quietzt[a].StdAnf:=quietzt[a].StdAnf-10
          end;
       Ctrl_CsRt:
          begin
           if quietzt[a].StdAnf>13 then quietzt[a].stdAnf:=quietzt[a].stdanf-24+10
            else quietzt[a].StdAnf:=quietzt[a].StdAnf+10
          end;
       end;

  end; {3,7,11}

  5,9,13: begin
      case Tast of
       #32: QuietZt[A].Aktiv:=not QuietZt[a].aktiv;

       CsRt: if quietzt[a].stdEnd<23 then inc(quietzt[a].stdEnd)
                 else quietzt[a].stdend:=0;
       Cslt: if quietzt[a].stdEnd>0 then dec(quietzt[a].stdEnd)
                else quietzt[a].stdend:=23;
       Ctrl_CsLt:
          begin
           if quietzt[a].stdEnd<10 then quietzt[a].stdEnd:=quietzt[a].stdend+24-10
            else quietzt[a].stdEnd:=quietzt[a].stdEnd-10
          end;
       Ctrl_CsRt:
          begin
           if quietzt[a].stdEnd>13 then quietzt[a].stdEnd:=quietzt[a].stdend-24+10
            else quietzt[a].stdEnd:=quietzt[a].stdEnd+10
          end;

      end;
     end;  {5,9,13}

     4,8,12: begin
      case Tast of
       #32: QuietZt[A].Aktiv:=not QuietZt[a].aktiv;

       CsRt: if quietzt[a].MinAnf<60 then inc(quietzt[a].MinAnf)
                 else alarm;
       Cslt: if quietzt[a].MinAnf>0 then dec(quietzt[a].MinAnf)
                else quietzt[a].minAnf:=59;
       Ctrl_CsLt:
          begin
           if quietzt[a].MinAnf<10 then quietzt[a].MinAnf:=quietzt[a].minanf+60-10
            else quietzt[a].MinAnf:=quietzt[a].MinAnf-10
          end;
       Ctrl_CsRt:
          begin
           if quietzt[a].MinAnf>49 then quietzt[a].MinAnf:=quietzt[a].minanf-60+10
            else quietzt[a].MinAnf:=quietzt[a].MinAnf+10
          end;

      end;
      if quietzt[a].MinAnf=60 then quietzt[a].MinAnf:=0;
     end;  {4,8,12}

     6,10,14: begin
      case Tast of
       #32: QuietZt[A].Aktiv:=not QuietZt[a].aktiv;

       CsRt: if quietzt[a].minend<60 then inc(quietzt[a].minend)
                 else alarm;
       Cslt: if quietzt[a].minend>0 then dec(quietzt[a].minend)
                else quietzt[a].minend:=59;
       Ctrl_CsLt:
          begin
           if quietzt[a].minend<10 then quietzt[a].minend:=quietzt[a].minend+60-10
            else quietzt[a].minend:=quietzt[a].minend-10
          end;
       Ctrl_CsRt:
          begin
           if quietzt[a].minend>49 then quietzt[a].minend:=quietzt[a].minend-60+10
            else quietzt[a].minend:=quietzt[a].minend+10
          end;

      end;
      if quietzt[a].minend=60 then quietzt[a].minend:=0;
     end;  {6,10,14}



  enD; {ausw}

until Tast=ESC
end; {with kofnig}
end;


procedure Verschiedenes;
var Ausw, auswa:byte;
    Tast:char;
    eingabe:string;
    fuel:byte;
    flagge,
    change:boolean;
    seite:byte;
    swechsel:boolean;
begin
eingabe:='';
HelpNr:=7;
ithema(40);
seite:=1;
swechsel:=true;
with konfig do
begin

cursorAus;
  change:=true;
Ausw:=1; Auswa:=1;
 repeat
  if swechsel then
   begin
    if seite=1 then
     begin
      change:=true;
      ausw:=1;
      farbe (white, black);
      clrscr;
      ladebild(rahmen);
      Textzent(helpSetup[13],2,80,yver-1);
      textzent(endfill(length(helpSetup[13]),'Õ',eingabe),2,80,yver);

     gotoxy(xver,yver+1); writeln(helpb[1]+': '+ZeitBez);
     gotoxy(xver,yver+2); writeln(helpb[2]+': ',UTCDiff);
     gotoxy(xver,yver+3); write(helpb[3]+': ');
      if utcbenutzen then writeln(RespT[1]) else writeln(RespT[2]);
     gotoxy(xver,yver+4); write(helpb[4]+': ');
      if echtzeit then writeln(RespT[1]) else writeln(RespT[2]);
     gotoxy(xver,yver+5); writeln(helpb[5]+': ',PopUpZeit);
     gotoxy(xver,yver+6); write(helpb[6]+': ');
      if lockirq then writeln(RespT[1]) else writeln(RespT[2]);
     gotoxy(xver,yver+7); write(helpb[7]+': ');
      if sichabfr then writeln(RespT[1]) else writeln(RespT[2]);
     gotoxy(xver,yver+8); write(helpb[8]+': ');
      if idle then writeln(RespT[1]) else writeln(RespT[2]);
     gotoxy(xver,yver+9); writeln(helpb[9]+': ',scrsavz);
    gotoxy(xver,yver+10);writeln(helpb[10]+': '+PromptS);
    gotoxy(xver,yver+11);writeln(helpb[11]+': ',NTimeOut);
    gotoxy(xver,yver+12);writeln(helpb[16]+': ',TTimeOut);
    gotoxy(xver,yver+13);writeln(helpb[17]+': ',MaxFrameStd);
    gotoxy(xver,yver+14);writeln(helpb[18]+': ',PacLenStd);
    GotoXy(Xver,yver+15);writeln(helpb[19]+': ',MaxNodes);
    GotoXy(Xver,yver+16);writeln(helpb[20]+': ',Lifetime);
    gotoxy(xver,yver+17);writeln(helpb[12]); {quiet-einst}
    end;
    if seite=2 then
     begin
      change:=True;
      ausw:=18;
      farbe (white, black);
      clrscr;
      ladebild(rahmen);
      Textzent(helpSetup[13],2,80,yver-1);
      textzent(endfill(length(helpSetup[13]),'Õ',eingabe),2,80,yver);
      gotoxy(xver,yver+1); write(helpb[21]+': ');
        if ReqNam then writeln(RespT[1]) else writeln(respt[2]);
      gotoxy(xver,yver+2); write(helpb[22]+': ');
        if NodeSound then writeln(RespT[1]) else writeln(respt[2]);
      gotoxy(xver,yver+3); writeln(helpb[23]+': ',MaxLoginUser);
      gotoxy(xver,yver+4); write(helpb[24]+': ');
        if CBFilter then writeln(RespT[1]) else writeln(respt[2]);

     end;
   end;


  if ((ausw<>1) and (ausw<>10) and (not Swechsel)) then tast:=taste;

  swechsel:=false;

  auswa:=ausw;
  flagge:=false;
  if (Auswa=17) and (tast=cr) then
   begin
    flagge:=true;
    tast:=#1;
   end;
  case tast of
   f1:help(false,40);
   cr, csdn, tab:
    begin
       change:=true;
       ausw:=ausw+1;
       if (ausw>17) and (Seite=1) then ausw:=1;
       if (Ausw>21) and (Seite=2) then ausw:=18;
    end;
   csup, shift_tab:
    begin
     change:=true;
     ausw:=ausw-1;
     if (ausw=0) and (Seite=1) then ausw:=17;
     if (ausw=17) and (Seite=2) then ausw:=21;
    end;
  end;
  if change then
   begin
    change:=false;
    farbe(white,black);
    textzent(Balken(78,' '),2,79,22);
    textzent(Balken(78,' '),2,79,23);
    if seite=1 then gotoxy(xver+27,yver+auswa) else gotoxy(xver+27, yver+auswa-17);
    farbe(white,black);
    case auswa of
     1: write(ZeitBez+'   ');
     2: write(UTCDiff,'   ');
     3: if utcbenutzen then write(RespT[1]) else write(RespT[2]);
     4: if echtzeit then write(RespT[1]) else write(RespT[2]);
     5: write(PopUpZeit,'  ');
     6: if lockirq then write(RespT[1]) else write(RespT[2]);
     7: if sichabfr then write(RespT[1]) else write(RespT[2]);
     8: if idle then write(RespT[1]) else write(RespT[2]);
     9: write(scrSavZ,'   ');
    10: begin
          Write(Balken(30,' '));
          gotoxy(xver+27,yver+auswa);
          write(PromptS)
        end;
    11:  write(NTimeOut,'  ');
    12:  write(TTimeOut,'  ');
    13:  write(MaxFrameStd,'  ');
    14:  write(PacLenStd,'  ');
    15:  write(MaxNodes ,'  ');
    16:  write(LifeTime ,'  ');
    17: begin
         gotoxy(xver,yver+17);
         write(helpb[12]);
        end;
    18: if ReqNam then write(RespT[1]) else write(RespT[2]);
    19: if NodeSound then write(RespT[1]) else write(RespT[2]);
    20: write(MaxLoginUser,'    ');
    21: if CBFilter then write(RespT[1]) else write(RespT[2]);
    end;
   end;
   if Seite=1 then gotoxy(xver+27,yver+ausw) else gotoxy(xver+27, yver+ausw-17);
   farbe(highvg, highhg);
   case ausw of
     1:begin
        write(Balken(3,' '));
        gotoxy(xver+27,yver+ausw);
        write(ZeitBez);
        farbe(specvg,black);
        textzent(helpSetup[8]+' - '+helpsetup[3],2,80,23);
       end;
     2: begin
         write(Balken(3,' '));
         gotoxy(xver+27,yver+ausw);
         write(UTCDiff);
         farbe(specvg,black);
         textzent(helpSetup[5],2,80,22);
         textzent(helpSetup[8]+' - '+helpsetup[3],2,80,23);
        end;
     3: begin
         if UTCBenutzen then write(RespT[1]) else write(RespT[2]);
         farbe(specvg,black);
         textzent(helpSetup[4],2,80,22);
         textzent(helpSetup[8]+' - '+helpsetup[3],2,80,23);
        end;
     4: begin
         if echtzeit then write(RespT[1]) else write(RespT[2]);
         farbe(specvg,black);
         textzent(helpSetup[4],2,80,22);
         textzent(helpSetup[8]+' - '+helpsetup[3],2,80,23);
        end;
     5: begin
         write(Balken(2,' '));
         gotoxy(xver+27,yver+ausw);
         write(PopUpZeit);
         farbe(specvg,black);
         textzent(helpSetup[5],2,80,22);
         textzent(helpSetup[8]+' - '+helpsetup[3],2,80,23);
        end;
     6: begin
         if lockirq then write(RespT[1]) else write(RespT[2]);
         farbe(specvg,black);
         textzent(helpSetup[4],2,80,22);
         textzent(helpSetup[8]+' - '+helpsetup[3],2,80,23);
        end;
     7: begin
         if sichabfr then write(RespT[1]) else write(RespT[2]);
         farbe(specvg,black);
         textzent(helpSetup[4],2,80,22);
         textzent(helpSetup[8]+' - '+helpsetup[3],2,80,23);
        end;
     8: begin
         if idle then write(RespT[1]) else write(RespT[2]);
         farbe(specvg,black);
         textzent(helpSetup[4],2,80,22);
         textzent(helpSetup[8]+' - '+helpsetup[3],2,80,23);
        end;
     9: begin
        write(Balken(2,' '));
        gotoxy(xver+27,yver+ausw);
        write(ScrSavZ);
        farbe(specvg,black);
        textzent(helpSetup[5],2,80,22);
        textzent(helpSetup[8]+' - '+helpsetup[3],2,80,23);
     end;
    10: begin
        write(Balken(30,' '));
        gotoxy(xver+27,yver+ausw);
        write(PromptS);
        farbe(specvg,black);
        textzent(helpSetup[8]+' - '+helpsetup[3],2,80,23);
     end;
     11:begin
        write(Balken(3,' '));
        gotoxy(xver+27,yver+ausw);
        write(NTimeOut);
        farbe(specvg,black);
        textzent(helpSetup[5],2,80,22);
        textzent(helpSetup[8]+' - '+helpsetup[3],2,80,23);
     end;
     12:begin
        write(Balken(3,' '));
        gotoxy(xver+27,yver+ausw);
        write(TTimeOut);
        farbe(specvg,black);
        textzent(helpSetup[5],2,80,22);
        textzent(helpSetup[8]+' - '+helpsetup[3],2,80,23);
     end;
     13:begin
        write(Balken(1,' '));
        gotoxy(xver+27,yver+ausw);
        write(MaxFrameStd);
        farbe(specvg,black);
        textzent(helpSetup[5],2,80,22);
        textzent(helpSetup[8]+' - '+helpsetup[3],2,80,23);
     end;
     14,15,16:begin
        write(Balken(3,' '));
        gotoxy(xver+27,yver+ausw);
        write(PacLenStd);
        farbe(specvg,black);
        textzent(helpSetup[5],2,80,22);
        textzent(helpSetup[8]+' - '+helpsetup[3],2,80,23);
     end;

     17:begin
        gotoxy(xver,yver+ausw);
        write(helpb[12]);
        farbe(specvg, black);
        {textzent(helpSetup[6],2,80,23);}
        textzent(helpSetup[6]+' - '+helpsetup[3],2,80,23);
      end;
     18:begin
         if ReqNam then write(RespT[1]) else write(RespT[2]);
         farbe(specvg,black);
         textzent(helpSetup[4],2,80,22);
         textzent(helpSetup[6]+' - '+helpsetup[3],2,80,23);
        end;
     19:begin
         if NodeSound then write(RespT[1]) else write(RespT[2]);
         farbe(specvg,black);
         textzent(helpSetup[4],2,80,22);
         textzent(helpSetup[6]+' - '+helpsetup[3],2,80,23);
        end;

     20:begin
         write(MaxLoginUser);
         if MaxLoginUser<10 then write(' ');
         farbe(specvg,black);
         textzent(helpSetup[5],2,80,22);
         textzent(helpSetup[6]+' - '+helpsetup[3],2,80,23);
        end;

     21:begin
         if CBFilter then write(RespT[1]) else write(RespT[2]);
         farbe(specvg,black);
         textzent(helpSetup[4],2,80,22);
         textzent(helpSetup[6]+' - '+helpsetup[3],2,80,23);
        end;


  end; {change}

  if Ausw=1 then
   begin
    CursorEin;
    farbe(highvg,highhg);
    Editor(Zeitbez,xver+27,yver+ausw,3,true,false,tast,40);
    farbe(white,black);
    cursorAus;
   end;

    if Ausw=2 then
    begin
     Case Tast of
      Csrt:
       begin
        if utcdiff<12 then inc(utcdiff)
         else Alarm;
       end;
      Ctrl_Csrt:
       begin
        if utcdiff=12 then alarm;
        if (utcdiff>2) and (utcdiff<12) then utcdiff:=12;
        if utcdiff<3 then utcdiff:=utcdiff+10;
       end;
      Cslt:
       begin
        if utcdiff>-12 then dec(utcdiff)
         else Alarm;
       end;
      Ctrl_Cslt:
       begin
        if utcdiff=-12 then alarm;
        if utcdiff<-2 then utcdiff:=-12;
        if utcdiff>-3 then utcdiff:=utcdiff-10;
       end;
     end; {Case}
     farbe(highvg,highhg);
     gotoxy(xver+27,yver+Ausw);
     fuel:=0;
     fuel:=3-length(makestring(utcdiff));
     write(utcdiff,Balken(fuel,' '));
    end; {ausw=2}

    if Ausw=3 then
    begin
     case Tast of
      CsLt, CsRt: UTCBenutzen:=not utcbenutzen;
     end;
     farbe(highvg,highhg);
     gotoxy(xver+27,yver+ausw);
     if UtcBenutzen then Write(RespT[1]) else write(RespT[2]);
    end; {ausw=3}

   if Ausw=4 then
    begin
     case Tast of
      CsLt, CsRt: Echtzeit:=not Echtzeit;
     end;
     farbe(highvg,highhg);
     gotoxy(xver+27,yver+ausw);
     if Echtzeit then Write(RespT[1]) else write(RespT[2]);
    end; {ausw=4}

   if Ausw=5 then
    begin
     Case Tast of
      Csrt:
       begin
        if PopUpZeit<30 then inc(popupzeit)
         else Alarm;
       end;
      Ctrl_Csrt:
       begin
        if PopUpZeit=30 then alarm;
        if (PopUpZeit>20) and (PopUpZeit<30) then PopUpZeit:=30;
        if popupzeit<21 then popupzeit:=popupzeit+10;
       end;
      Cslt:
       begin
        if popupzeit>0 then dec(popupzeit)
         else Alarm;
       end;
      Ctrl_Cslt:
       begin
        if PopUpZeit=0 then alarm;
        if PopUpZeit<10 then PopUpZeit:=0;
        if PopUpZeit>9 then Popupzeit:=popupzeit-10;
       end;
     end; {Case}
     farbe(highvg,highhg);
     gotoxy(xver+27,yver+Ausw);
     fuel:=0;
     if popupzeit<10 then fuel:=fuel+1;
     write(popupzeit,Balken(fuel,' '));
    end; {ausw=5}

    if Ausw=6 then
    begin
     case Tast of
      CsLt, CsRt: Lockirq:=not Lockirq;
     end;
     farbe(highvg,highhg);
     gotoxy(xver+27,yver+ausw);
     if Lockirq then Write(RespT[1]) else write(RespT[2]);
    end; {ausw=6}

    if Ausw=7 then
    begin
     case Tast of
      CsLt, CsRt: sichabfr:=not sichabfr;
     end;
     farbe(highvg,highhg);
     gotoxy(xver+27,yver+ausw);
     if sichabfr then Write(RespT[1]) else write(RespT[2]);
    end; {ausw=7}

    if Ausw=8 then
    begin
     case Tast of
      CsLt, CsRt: idle:=not idle;
     end;
     farbe(highvg,highhg);
     gotoxy(xver+27,yver+ausw);
     if idle then Write(RespT[1]) else write(RespT[2]);
    end; {ausw=8}

    if Ausw=9 then
    begin
     Case Tast of
      Csrt:
       begin
        if ScrSavZ<30 then inc(ScrSavZ)
         else Alarm;
       end;
      Ctrl_Csrt:
       begin
        if ScrSavZ=30 then alarm;
        if (ScrSavZ>20) and (ScrSavZ<30) then ScrSavZ:=30;
        if ScrSavZ<21 then ScrSavZ:=ScrSavZ+10;
       end;
      Cslt:
       begin
        if ScrSavZ>0 then dec(ScrSavZ)
         else Alarm;
       end;
      Ctrl_Cslt:
       begin
        if ScrSavZ=0 then alarm;
        if ScrSavZ<10 then ScrSavZ:=0;
        if ScrSavZ>9 then ScrSavZ:=ScrSavZ-10;
       end;
     end; {Case}
     farbe(highvg,highhg);
     gotoxy(xver+27,yver+Ausw);
     fuel:=0;
     if ScrSavZ<10 then fuel:=fuel+1;
     write(ScrSavZ,Balken(fuel,' '));
    end; {ausw=9}


    if Ausw=10 then
     begin
      Editor(PromptS,xver+27,yver+ausw,30,false,true,Tast,40);
      cursorAus;
     end; {10}

    if Ausw=11 then
    begin
     Case Tast of
      Csrt:
       begin
        if NTimeOut<120 then inc(NTimeOut)
         else Alarm;
        if (NTimeOut>0) and (NtimeOut<10) then NTimeOut:=10;
       end;
      Ctrl_Csrt:
       begin
        if NTimeOut=120 then alarm;
        if (NTimeOut>110) and (NTimeOut<120) then NTimeOut:=120;
        if NTimeOut<111 then NTimeOut:=NTimeOut+10;
        if (NTimeOut>0) and (NtimeOut<10) then NTimeOut:=10;
       end;
      Cslt:
       begin
        if NTimeOut>0 then dec(NTimeOut)
         else Alarm;
        if (NTimeOut>0) and (NtimeOut<10) then NTimeOut:=0;
       end;
      Ctrl_Cslt:
       begin
        if NTimeOut=0 then alarm;
        if NTimeOut<10 then NTimeOut:=0;
        if NTimeOut>9 then NTimeOut:=NTimeOut-10;
        if (NTimeOut>0) and (NtimeOut<10) then NTimeOut:=0;
       end;
     end; {Case}
     farbe(highvg,highhg);
     gotoxy(xver+27,yver+Ausw);
     fuel:=0;
     if NTimeOut<100 then fuel:=fuel+1;
     if NTimeOut<10 then fuel:=fuel+1;
     write(NTimeOut,Balken(fuel,' '));
    end; {ausw=11}

    if Ausw=12 then
    begin
     Case Tast of
      Csrt:
       begin
        if TTimeOut<120 then inc(TTimeOut)
         else Alarm;
        if (TTimeOut>0) and (TTimeout<10) then TTimeOut:=10;
       end;
      Ctrl_Csrt:
       begin
        if TTimeOut=120 then alarm;
        if (TTimeOut>110) and (TTimeOut<120) then TTimeOut:=120;
        if TTimeOut<111 then TTimeOut:=TTimeOut+10;
       end;
      Cslt:
       begin
        if TTimeOut>0 then dec(TTimeOut)
         else Alarm;
        if (TTimeout>0) and (TTimeout<10) then TTimeOut:=0;
       end;
      Ctrl_Cslt:
       begin
        if TTimeOut=0 then alarm;
        if TTimeOut<10 then TTimeOut:=0;
        if TTimeOut>9 then TTimeOut:=TTimeOut-10;
        if (TTimeout>0) and (TTimeout<10) then TTimeOut:=0;
       end;
     end; {Case}
     farbe(highvg,highhg);
     gotoxy(xver+27,yver+Ausw);
     fuel:=0;
     if TTimeOut<100 then fuel:=fuel+1;
     if TTimeOut<10 then fuel:=fuel+1;
     write(TTimeOut,Balken(fuel,' '));
    end; {ausw=12}

   if Ausw=13 then
    begin
     Case Tast of
      Csrt:
       begin
        if MaxFrameStd<7 then inc(MaxFrameStd)
         else Alarm;
       end;
      Cslt:
       begin
        if MaxFrameStd>1 then dec(MaxFrameStd)
         else Alarm;
       end;
     end; {Case}
     farbe(highvg,highhg);
     gotoxy(xver+27,yver+Ausw);
     write(MaxFrameStd);
    end; {ausw=13}

    if Ausw=14 then
    begin
     Case Tast of
      Csrt:
       begin
        if paclenstd<252 then inc(paclenstd)
         else Alarm;
       end;
      Ctrl_Cslt:
       begin
        if paclenstd=10 then alarm;
        if paclenstd>19 then paclenstd:=paclenstd-10 else paclenstd:=10;
       end;
      Ctrl_Csrt:
       begin
        if paclenstd=252 then alarm;
        if paclenstd<=242 then paclenstd:=paclenstd+10 else paclenstd:=252;
       end;
      Cslt:
       begin
        if paclenstd>10 then dec(paclenstd)
         else Alarm;
       end;
     end; {Case}
     farbe(highvg,highhg);
     gotoxy(xver+27,yver+Ausw);
     write(paclenstd);
    end; {ausw=14}


    if Ausw=15 then
    begin
     Case Tast of
      Csrt:
       begin
        if MaxNodes=0 then MaxNodes:=9;
        if MaxNodes<400 then inc(MaxNodes)
         else Alarm;
       end;
      Ctrl_Csrt:
       begin
        if MaxNodes=400 then alarm;
        if (MaxNodes>390) and (MaxNodes<400) then MaxNodes:=400;
        if MaxNodes<391 then MaxNodes:=MaxNodes+10;
       end;
      Cslt:
       begin
        if Maxnodes=0 then alarm;
        if MaxNodes>10 then dec(MaxNodes)
         else MaxNodes:=0;
       end;
      Ctrl_Cslt:
       begin
        if MaxNodes=0 then alarm;
        if MaxNodes=10 then MaxNodes:=0;
        if (MaxNodes<20) and (MaxNodes>10) then MaxNodes:=10;
        if MaxNodes>19 then MaxNodes:=MaxNodes-10;
       end;
     end; {Case}
     farbe(highvg,highhg);
     gotoxy(xver+27,yver+Ausw);
     fuel:=0;
     if MaxNodes<100 then fuel:=fuel+1;
     if MaxNodes<10 then fuel:=fuel+1;
     write(MaxNodes,Balken(fuel,' '));
    end; {ausw=15}


    if Ausw=16 then
    begin
     Case Tast of
      Csrt:
       begin
        if LifeTime<240 then inc(LifeTime)
         else Alarm;
       end;
      Ctrl_Csrt:
       begin
        if LifeTime=240 then alarm;
        if (LifeTime>230) and (LifeTime<240) then LifeTime:=240;
        if LifeTime<231 then LifeTime:=LifeTime+10;
       end;
      Cslt:
       begin
        if LifeTime>20 then dec(LifeTime)
         else Alarm;
       end;
      Ctrl_Cslt:
       begin
        if LifeTime=20 then alarm;
        if LifeTime<30 then LifeTime:=20;
        if LifeTime>29 then LifeTime:=LifeTime-10;
       end;
     end; {Case}
     farbe(highvg,highhg);
     gotoxy(xver+27,yver+Ausw);
     fuel:=0;
     if LifeTime<100 then fuel:=fuel+1;
     if LifeTime<10 then fuel:=fuel+1;
     write(LifeTime,Balken(fuel,' '));
    end; {ausw=16}



    if (Ausw=17) and (flagge) then
     begin
      SaveBild(BildSpeicher);
      quietEinstellungen;
      farbe (white, black);
      clrscr;
      ladebild(BildSpeicher);
     end;


    if Ausw=18 then
    begin
     case Tast of
      CsLt, CsRt: ReqNam:=not ReqNam;
     end;
     farbe(highvg,highhg);
     gotoxy(xver+27,yver+ausw-17);
     if reqnam then Write(RespT[1]) else write(RespT[2]);
    end; {ausw=18}

   if Ausw=19 then
    begin
     case Tast of
      CsLt, CsRt: NodeSound:=not NodeSound;
     end;
     farbe(highvg,highhg);
     gotoxy(xver+27,yver+ausw-17);
     if NodeSound then Write(RespT[1]) else write(RespT[2]);
    end; {ausw=19}

   if Ausw=20 then
    begin
     Case Tast of
      Csrt:
       begin
        if MaxLoginUser=10 then Alarm;
        if MaxLoginUser<10 then inc(MaxLoginUser);
       end;
      Ctrl_Csrt:
       begin
        if MaxLoginUser=10 then alarm;
        if MaxLoginUser<10 then MaxLoginUser:=10;
       end;
      Cslt:
       begin
        if MaxLoginUser=1 then alarm;
        if MaxLoginUser>1 then dec(MaxLoginUser)
       end;
      Ctrl_Cslt:
       begin
        if MaxLoginUser=1 then alarm;
        if (MaxLoginUser>1) and (MaxLoginUser<=10) then MaxLoginUser:=1;
       end;
     end; {Case}
     farbe(highvg,highhg);
     gotoxy(xver+27,yver+Ausw-17);
     fuel:=0;
     if MaxLoginUser<10 then fuel:=fuel+1;
     write(MaxLoginUser,Balken(fuel,' '));
    end; {ausw=20}

   if Ausw=21 then
    begin
     case Tast of
      CsLt, CsRt: CBFilter:=not CBFilter;
     end;
     farbe(highvg,highhg);
     gotoxy(xver+27,yver+ausw-17);
     if CBFilter then Write(RespT[1]) else write(RespT[2]);
    end; {ausw=21}

  case tast of
   PgUp : if Seite>1 then
    begin
     dec(Seite);
     swechsel:=true;
     change:=true;
    end;
   PgDn : if Seite<2 then
    begin
     inc(Seite);
     swechsel:=true;
     change:=true;
    end;
  end;

 until tast=esc;
end; {with}
end;

procedure speicher;
var fuel,auswa, ausw : byte;
    tast:char;
    change:boolean;
    eingabe:string;
begin
ithema(60);
eingabe:='';
HelpNr:=9;
farbe(white,black);
clrscr;
ladebild(rahmen);
with konfig do
 begin
auswa:=1; ausw:=1; change:=false;

Textzent(helpSetup[15],2,80,yml-1);
textzent(endfill(length(helpSetup[15]),'Õ',eingabe),2,80,yml);
{!RAMT}
gotoxy(xsp,ysp+1); write(helpb[1]+': ',mh);
gotoxy(xsp,ysp+2); write(helpb[2]+': ',backscram);
gotoxy(xsp,ysp+3); write(helpb[3]+': ',vorschzram);
gotoxy(xsp,ysp+4); write(helpb[4]+': ');
  if BufferDat then write(RespT[1]) else write(RespT[2]);
gotoxy(xsp,ysp+5); write(helpb[5]+': ',BackUpTime);
farbe(highvg, highhg);
gotoxy(xsp+27,ysp+auswa);
write(balken(3,' '));
gotoxy(xsp+27,ysp+auswa);
write(mh);
farbe(specvg,black);
textzent(helpSetup[5],2,80,22);
textzent(helpSetup[8],2,80,23);
cursoraus;

repeat
tast:=taste;
auswa:=ausw;
case Tast of
 f1:help(false,0);
 Tab, CsDn, CR:
   begin
    Ausw:=Ausw+1;
    if Ausw>5 then Ausw:=1;
    change:=true;
   end;
 Shift_Tab, Csup:
   begin
    Ausw:=Ausw-1;
    if Ausw<1 then Ausw:=5;
    change:=true;
   end;
end;
if change then
 begin
  change:=false;
  farbe(white, black);
  gotoxy(xsp+27,ysp+auswa);
  write(balken(5,' '));
  gotoxy(xsp+27,ysp+auswa);
  case auswa of
   1: write(mh);
   2: write(BackscRam);
   3: write(VorschZRam);
   4: if BufferDat then write(RespT[1]) else write(RespT[2]);
   5: write(BackupTime);
  end;
  textzent(Balken(78,' '),2,79,22);
  textzent(Balken(78,' '),2,79,23);
  farbe(highvg, highhg);
  gotoxy(xsp+27,ysp+ausw);
  if ausw=2 then write(balken(2,' ')) else write(balken(3,' '));
  gotoxy(xsp+27,ysp+ausw);
  case ausw of
   1: begin
       write(mh);
       farbe(specvg,black);
       textzent(helpSetup[5],2,80,22);
       textzent(helpSetup[8],2,80,23);
      end;
   2: begin
       writE(backscram);
       farbe(specvg,black);
       textzent(helpSetup[4],2,80,22);
       textzent(helpSetup[8],2,80,23);
      end;
   3,5: begin
       write(vorschzram);
       farbe(specvg,black);
       textzent(helpSetup[5],2,80,22);
       textzent(helpSetup[8],2,80,23);
      end;
   4: begin
       if BufferDat then write(RespT[1]) else write(RespT[2]);
       farbe(specvg,black);
       textzent(helpSetup[4],2,80,22);
       textzent(helpSetup[8],2,80,23);
      end;
  end;
 end; {change}

if Ausw=1 then
    begin
     Case Tast of
      Csrt:
       begin
        if mh<200 then inc(mh)
         else Alarm;
       end;
      Ctrl_Csrt:
       begin
        if mh=200 then alarm;
        if (mh>190) and (mh<200) then mh:=200;
        if mh<191 then mh:=mh+10;
       end;
      Cslt:
       begin
        if mh>10 then dec(mh)
         else Alarm;
       end;
      Ctrl_Cslt:
       begin
        if mh=10 then alarm;
        if mh<35 then mh:=10;
        if mh>34 then mh:=mh-10;
       end;
     end; {Case}
     farbe(highvg,highhg);
     gotoxy(xsp+27,ysp+Ausw);
     fuel:=0;
     if mh<100 then fuel:=fuel+1;
     write(mh,Balken(fuel,' '));
    end; {ausw=1}

    if Ausw=2 then
    begin
     Case Tast of
      Csrt: begin
             case backscram of
              4: backscRam:=8;
              8: backscRam:=16;
             16: backscRam:=32;
             32: backscRam:=64;
             64: backscRam:=4;
             end;
            end;
      Cslt: begin
             case backscram of
              4: backscRam:=64;
              8: backscRam:=4;
             16: backscRam:=8;
             32: backscRam:=16;
             64: backscRam:=32;
             end;
            end;
    end;
    gotoxy(xsp+27,ysp+ausw);
    farbe(highvg,highhg);
    fuel:=0;
    if backscram<10 then fuel:=1;
    write(backscram,balken(fuel,' '));
   end;

   if Ausw=3 then
    begin
     Case Tast of
      Csrt:
       begin
        if vorschzram<200 then inc(vorschzram)
         else Alarm;
       end;
      Ctrl_Csrt:
       begin
        if vorschzram=200 then alarm;
        if (vorschzram>190) and (vorschzram<200) then vorschzram:=200;
        if vorschzram<191 then vorschzram:=vorschzram+10;
       end;
      Cslt:
       begin
        if vorschzram>10 then dec(vorschzram)
         else Alarm;
       end;
      Ctrl_Cslt:
       begin
        if vorschzram=10 then alarm;
        if vorschzram<20 then vorschzram:=10;
        if vorschzram>19 then vorschzram:=vorschzram-10;
       end;
     end; {Case}
     farbe(highvg,highhg);
     gotoxy(xsp+27,ysp+Ausw);
     fuel:=0;
     if vorschzram<100 then fuel:=fuel+1;
     write(vorschzram,Balken(fuel,' '));
    end; {ausw=3}

    if Ausw=4 then
     begin
      if Tast in [CsRt, CsLt] then BufferDat:=not BufferDat;
      farbe(highvg,highhg);
      gotoxy(xsp+27,ysp+Ausw);
      if BufferDat then write(RespT[1]) else write(RespT[2]);
     end;

    if Ausw=5 then
    begin
     Case Tast of
      Csrt:
       begin
        if BackUpTime<200 then inc(BackUpTime)
         else Alarm;
        If BackupTime=1 then BackupTime:=2;
       end;
      Ctrl_Csrt:
       begin
        if BackUpTime=200 then alarm;
        if (BackUpTime>190) and (BackUpTime<200) then BackUpTime:=200;
        if BackUpTime<191 then BackUpTime:=BackUpTime+10;
       end;
      Cslt:
       begin
        if BackUpTime>0 then dec(BackUpTime);
         if BackupTime=0 then Alarm;
        if BackupTime=1 then BackupTime:=0;
       end;
      Ctrl_Cslt:
       begin
        if BackUpTime>=10 then BackUpTime:=BackupTime-10 else alarm;
        if BackupTime=1 then BackupTime:=0;
       end;
     end; {Case}
     farbe(highvg,highhg);
     gotoxy(xsp+27,ysp+Ausw);
     fuel:=0;
     if BackUpTime<100 then fuel:=fuel+1;
     write(BackUpTime,Balken(fuel,' '));
    end; {ausw=5}

until tast=esc;
end; {with}
end;


procedure drucker;
var auswa,ausw,fuel:byte;
    change:boolean;
    Tast:char;
    eingabe:string;
begin
ithema(70);
eingabe:='';
HelpNr:=10;
with konfig do
 begin
  farbe(white,black);
  CursorAus;
  clrscr;
  ladebild(rahmen);

  Textzent(helpSetup[16],2,80,ydr-3);
  textzent(endfill(length(helpSetup[16]),'Õ',eingabe),2,80,ydr-2);
{!PRTT}
  gotoxy(xdr,ydr+1); write(helpb[1]+': ',LPtNr);
  gotoxy(xdr,ydr+2); write(helpb[2]+': ',LPtAdr);
  farbe(highvg,highhg);
  gotoxy(xdr+17,ydr+1);write(LPTNr);
  farbe(specvg,black);
  textzent(helpSetup[4],2,80,22);
  textzent(helpSetup[8],2,80,23);
  Change:=false;
  Ausw:=1;
  repeat
  if ausw<>2 then tast:=taste;
   auswa:=ausw;
   Case Tast of
    f1:help(false,0);
    cr,tab,csdn:
     begin
      inc(ausw);
      if Ausw>2 then Ausw:=1;
      Change:=true;
     end;
    csUp,shift_tab:
     begin
      dec(ausw);
       if Ausw<1 then Ausw:=2;
       Change:=true;
     end;
   end; {case tast}
   if change then
    begin
     change:=false;
     farbe(white,black);
     gotoxY(xdr+17,ydr+auswa);
     case Auswa of
      1: write(lptNr);
      2: write(lptAdr+'   ');
     end; {case auswa}
    farbe(highvg,highhg);
     gotoxY(xdr+17,ydr+ausw);
    case Ausw of
      1: begin
          write(lptNr);
          farbe(specvg,black);
          textzent(helpSetup[4],2,80,22);
        end;
      2: begin
          write(balken(3,' '));
          gotoxY(xdr+17,ydr+ausw);
          write(lptAdr);
          farbe(specvg,black);
          textzent(balken(73,#32),2,80,22);
         end;
     end; {case ausw}
    end; {change}
   if Ausw=1 then
   begin
    case tast of
     cslt: begin
            dec(lptNr);
            if lptnr=0 then lptnr:=3;
           end;
     CsRt: begin
            inc(lptNr);
            if lptnr>3 then lptnr:=1;
           end;
     end;
     farbe(highvg,highhg);
     gotoxy(xdr+17,ydr+ausw);
     write(lptnr);
   end;
   If Ausw=2 then
    begin
     cursorEin;
     Editor(lptadr,xdr+17,ydr+ausw,3,true,false,tast,0);
     CursorAus;
    end;
  until tast=esc;


 end;{with}
end;

procedure MailFrameSet;
var mfs, auswa, x,y, ausw : byte;
    change: boolean;
    eingabe:string;
    fuel:byte;
    tast:char;

begin
ithema(50);
eingabe:='';
HelpNr:=8;
with konfig do
 begin
  auswa:=1;
  ausw:=1;
  change:=false;
  farbe (white, black);
  clrscr;
  ladebild(rahmen);

  Textzent(helpSetup[14],2,80,yml-2);
  textzent(endfill(length(helpSetup[14]),'Õ',eingabe),2,80,yml-1);

 end;
 y:=yml;
 x:=xml;
{!Mailt}
 gotoxy(x,yml); write(helpb[1]+': ');
 farbe(highvg,highhg);
  if Konfig.MailFErl then write(RespT[1]) else write(RespT[2]);
 farbe(specvg,black);
 textzent(helpSetup[4],2,79,22);
 textzent(helpSetup[8],2,79,23);
cursorAus;
 farbe(highvg, highhg);
 for mfs:=1 to 10 do
  begin
   y:=y+2;
   if mfs=6 then
    begin
     y:=yml+2;
     x:=x+19;
    end;
   gotoxy(x,y);
   write(Balken(10,' '));
   gotoxy(x,y); write(Konfig.MailFrame[mfs]);
  end;

  farbe(white,black); gotoxy(xml, y+2); write(HelpB[2]+': ');
   if Konfig.OwnMailFr then write(RespT[1]) else write(RespT[2]);

  farbe(white,black); gotoxy(xml, y+3); write(HelpB[4]+': ',Konfig.MailFrameZeit);
  gotoxy(xml,y+4); write(HelpB[3]+': ');

  gotoxy(xml,y+5);
  farbe(highvg, highhg); write(EndFill(50,' ',Konfig.OwnMailPfad));

 repeat
  if ausw=1 then
   begin
    farbe(highvg,highhg);
    gotoxy(xml+24,yml+ausw-1);
    if Konfig.MailFErl then write(RespT[1]) else write(RespT[2]);
    cursorAus;

   end;
    if ausw in [1,12,13] then tast:=taste;
  case Tast of
   f1:help(false,50);
   CsDn,CR, Tab: begin
     inc(Ausw);
     change:=true;
    end;
   CSUp,Shift_Tab: begin
     dec(Ausw);
     change:=true;
    end;
  end;
  if Ausw>14 then Ausw:=1;
  if Ausw<1 then Ausw:=14;
  if Ausw in [2,11,12,13,14] then
   begin
    farbe(white ,black);
    gotoxy(xml+24,yml);
    if Konfig.MailFErl then write(RespT[1]) else write(RespT[2]);
    gotoxy(xml+24, yml+12);
    if Konfig.OwnMailFr then write(RespT[1]) else write(RespT[2]);
    gotoxy(xml+24, yml+13);
     write(Konfig.MailFrameZeit,'  ');
    farbe(specvg,black);
    textzent(Balken(77,' '),2,79,22);
    textzent(helpSetup[8],2,79,23);
   end;
  if Ausw=1 then
   begin
    if change then
     begin
      change:=false;
      farbe(specvg, black);
      textzent(helpSetup[4],2,79,22);
      textzent(helpSetup[8],2,79,23);
     end;
    case Tast of
     csrt,cslt: Konfig.MailFErl:=not Konfig.MailFErl;
    end;
    farbe(highvg, highhg);
    gotoxy(xml+24, yml+Ausw-1);
    if Konfig.MailFErl then write(RespT[1]) else write(RespT[2]);
   end;

  if Ausw in [2..11] then
   begin
    y:=yml;
    x:=xml;
    for mfs:=1 to ausw-1 do
     begin
      y:=y+2;
      if mfs=6 then
       begin
        x:=x+19;
        y:=yml+2;
       end;
     end;
    Editor(Konfig.MailFrame[Ausw-1],x,y,10,true,false,Tast,50);
   end;

   if Ausw=12 then
   begin
    if change then
     begin
      change:=false;
      farbe(specvg, black);
      textzent(helpSetup[4],2,79,22);
      textzent(helpSetup[8],2,79,23);
     end;
    case Tast of
     csrt,cslt: Konfig.OwnMailFr:=not Konfig.OwnMailFr;
    end;
    farbe(highvg, highhg);
    gotoxy(xml+24, yml+12);
    if Konfig.OwnMailFr then write(RespT[1]) else write(RespT[2]);
   end; {12}

   if Ausw=13 then
    begin
     Case Tast of
      Csrt:
       begin
        if Konfig.MailFrameZeit<120 then inc(Konfig.MailFrameZeit)
         else Alarm;
       end;
      Ctrl_Csrt:
       begin
        if Konfig.MailFrameZeit=120 then alarm;
        if (Konfig.MailFrameZeit>110) and (Konfig.MailFrameZeit<120) then Konfig.MailFrameZeit:=120;
        if Konfig.MailFrameZeit<111 then Konfig.MailFrameZeit:=Konfig.MailFrameZeit+10;
       end;
      Cslt:
       begin
        if Konfig.MailFrameZeit>1 then dec(Konfig.MailFrameZeit)
         else Alarm;
       end;
      Ctrl_Cslt:
       begin
        if Konfig.MailFrameZeit=10 then alarm;
        if Konfig.MailFrameZeit<20 then Konfig.MailFrameZeit:=10;
        if Konfig.MailFrameZeit>19 then Konfig.MailFrameZeit:=Konfig.MailFrameZeit-10;
       end;
     end; {Case}
     farbe(highvg,highhg);
     gotoxy(xml+24,yml+13);
     fuel:=0;
     if Konfig.MailFrameZeit<100 then fuel:=fuel+1;
     write(Konfig.MailFrameZeit,Balken(fuel,' '));
    end; {ausw=13}

   if Ausw=14 then
    begin
     gotoxy(xml, yml+15); farbe(highvg, highhg); write(EndFill(50,' ',Konfig.OwnMailPfad));
     Editor(Konfig.OwnMailPfad,xml,yml+15,50,true,true,Tast,50);
    end;
 until tast=ESC;
end;

procedure Sound;
var eingabe:string;
change:boolean;
ausw,auswa:byte;
tast:char;
neu,
fehl:integer;
begin
{$IFDEF Sound}
ithema(100);
eingabe:='';
HelpNr:=14;
with konfig do
 begin
  farbe(white,black);
  CursorAus;
  clrscr;
  ladebild(rahmen);

  Textzent(helpSetup[38],2,80,ysn-3);
  textzent(endfill(length(helpSetup[38]),'Õ',eingabe),2,80,ysn-2);

  farbe(white,black);
  gotoxy(xsn, ysn+1); write(helpb[1]+':');
  farbe(highvg,highhg);
   gotoxy(xsn+26, ysn+1); if WavOut then write(RespT[1]) else write(RespT[2]);

  farbe(white,black);
  gotoxy(xsn, ysn+2); write(helpb[2]+':') ;
  gotoxy(xsn+26, ysn+2); if WavSprach then write(RespT[1]) else write(RespT[2]);

  gotoxy(xsn, ysn+3); write(helpb[3]+':') ;
  gotoxy(xsn+26, ysn+3); if MidiOut then write(RespT[1]) else write(RespT[2]);

  if MidiADR=0 then MidiADR:=904;
  gotoxy(xsn, ysn+4); write(helpb[4]+': ', Hex(MidiADR,3));

  gotoxy(xsn, ysn+5); write(helpb[5]+': ', Hex(SBBaseADR,3));
  gotoxy(xsn, ysn+6); write(helpb[6]+': ', SBLoDMA);
  gotoxy(xsn, ysn+7); write(helpb[7]+': ', SBHiDMA);
  gotoxy(xsn, ysn+8); write(helpb[8]+': ', SBIRQ);


  farbe(specvg,black);
  textzent(helpSetup[4],2,80,22); {rechts/links}
  textzent(helpSetup[39],2,80,23);
  Change:=false;
  Ausw:=1;
  repeat
  if (ausw<4) or (Ausw>5) then tast:=taste;
   auswa:=ausw;
   Case Tast of
    f1:help(false,0);
    f2:begin
        SBDetect(SBBaseADR, SBHiDMA, SBLoDMA, SBIRQ);
        if SBBaseADR = 0 then
         begin
         farbe(White,black);
          gotoxy(xsn+26,ysn+5); write('?   ');
          gotoxy(xsn+26,ysn+6); write('? ');
          gotoxy(xsn+26,ysn+7); write('? ');
          gotoxy(xsn+26,ysn+8); write('? ');
         end else
         begin
          farbe(White,black);
          gotoxy(xsn+26,ysn+5); write(Hex(SBBaseADR,3));
          gotoxy(xsn+26,ysn+6); write(SBLoDMA);
          gotoxy(xsn+26,ysn+7); write(SBHiDMA);
          gotoxy(xsn+26,ysn+8); write(SBirq);
         end;
        end;
    cr,tab,csdn:
     begin
      inc(ausw);
      if Ausw>8 then Ausw:=1;
      Change:=true;
     end;
    csUp,shift_tab:
     begin
      dec(ausw);
       if Ausw<1 then Ausw:=8;
       Change:=true;
     end;
   end; {case tast}
   if change then
    begin
     change:=false;
     farbe(white,black);
     gotoxY(xsn+26,ysn+auswa);
     case Auswa of
      1: if WavOut then write(RespT[1]) else write(RespT[2]);
      2: if WavSprach then write(RespT[1]) else write(RespT[2]);
      3: if MidiOut then write(RespT[1]) else write(RespT[2]);
      6: write(endfill(2,#32,int_Str(SBLoDMA)));
      7: write(endfill(2,#32,int_str(SBHiDMA)));
      8: write(endfill(2,#32, int_str(SBIRQ)));
     end; {case auswa}
    farbe(highvg,highhg);
    gotoxY(xsn+26,ysn+ausw);
    case Ausw of
      1: begin
          if WAVOut then write(RespT[1]) else write(RespT[2]);
          farbe(white,black);
          textzent(helpSetup[4],2,80,22); {rechts/links}
        end;
      2: begin
          if WAVSprach then write(RespT[1]) else write(RespT[2]);
          farbe(white,black);
          textzent(helpSetup[4],2,80,22); {rechts/links}
         end;
      3: begin
          if MidiOut then write(RespT[1]) else write(RespT[2]);
          farbe(white,black);
          textzent(helpSetup[4],2,80,22); {rechts/links}
         end;
      4: begin
          farbe(white,black);
          textzent(balken(73,#32),2,80,22);
          farbe(highvg,highhg);
          gotoxY(xsn+26,ysn+ausw);
          write(balken(3,' '));
          gotoxY(xsn+26,ysn+ausw);
          eingabe:=HEX(MidiADR,3);
          write(eingabe);
          Editor(eingabe,xsn+26,ysn+ausw,3,true,false,Tast,0);
          eingabe:='$'+eingabe;
          VAL(eingabe, Neu, Fehl);
          if Fehl=0 then MidiADR:=neu
           else eingabe:=HEX(MidiADR,3);
          farbe(white,black);
          if eingabe[1]='$' then delete(eingabe,1,1);
          write(eingabe);
          farbe(specvg,black);
         end;
        5: begin
          farbe(white,black);
          textzent(balken(73,#32),2,80,22);
          gotoxY(xsn+26,ysn+ausw);
          farbe(highvg,highhg);
          write(balken(3,' '));
          gotoxY(xsn+26,ysn+ausw);
          eingabe:=HEX(SBBaseADR,3);
          write(eingabe);
          Editor(eingabe,xsn+26,ysn+ausw,3,true,false,Tast,0);
          eingabe:='$'+eingabe;
          VAL(eingabe, Neu, Fehl);
          if Fehl=0 then SBBaseADR:=neu
           else eingabe:=HEX(SBBaseADR,3);
          farbe(white,black);
          if eingabe[1]='$' then delete(eingabe,1,1);
          write(eingabe);
          farbe(specvg,black);
         end;
        6: begin
             write(endfill(2,#32,int_Str(SBLoDMA)));
             farbe(white,black);
             textzent(helpSetup[4],2,80,22); {rechts/links}
           end;
        7: begin
             write(endfill(2,#32,int_str(SBHiDMA)));
             farbe(white,black);
             textzent(helpSetup[4],2,80,22); {rechts/links}
           end;
        8: begin
            write(endfill(2,#32, int_str(SBIRQ)));
            farbe(white,black);
            textzent(helpSetup[4],2,80,22); {rechts/links}
           end;
     end; {case ausw}
    end; {change}

   farbe(highvg,highhg);

   if Ausw=1 then
   begin
    case tast of
     cslt, csrt, #32: WavOut:=not WavOut;
    end;
     farbe(highvg,highhg);
     gotoxy(xsn+26,ysn+ausw);
     if WavOut then write(RespT[1]) else write(RespT[2]);
     if WavOut and MidiOut then MidiOUt:=False;
   end;
   If Ausw=2 then
    begin
     case tast of
      cslt, csrt, #32: WavSprach:=not WavSprach;
     end;
     farbe(highvg,highhg);
     gotoxy(xsn+26,ysn+ausw);
     if WavSprach then write(RespT[1]) else write(RespT[2]);
    end;
   If Ausw=3 then
    begin
     farbe(highvg,highhg);
     case tast of
      cslt, csrt, #32: MidiOut:=not MidiOut;
     end;
      gotoxy(xsn+26,ysn+ausw);
     if MidiOut then write(RespT[1]) else write(RespT[2]);
     if WavOut and MidiOut then WAVOUt:=False;
    end;
    If Ausw=6 then
    begin
     farbe(highvg,highhg);
     case tast of
      csrt: if SBLoDMA<10 then inc(SBLoDMA) else Alarm;
      cslt: if SBLoDMA>1 then dec(SBLoDMA) else ALARM;
     end;
      gotoxy(xsn+26,ysn+ausw);
      write(endfill(2,#32,int_Str(SBLoDMA)));
    end;
    If Ausw=7 then
    begin
     farbe(highvg,highhg);
     case tast of
      csrt: if SBHiDMA<10 then inc(SBHiDMA) else Alarm;
      cslt: if SBHiDMA>1 then dec(SBHiDMA) else ALARM;
     end;
      gotoxy(xsn+26,ysn+ausw);
      write(endfill(2,#32,int_str(SBHiDMA)));
    end;
    If Ausw=8 then
    begin
     farbe(highvg,highhg);
     case tast of
      csrt: if SBIRQ<15 then inc(SBIRQ) else Alarm;
      cslt: if SBIRQ>1 then dec(SBIRQ) else ALARM;
     end;
      gotoxy(xsn+26,ysn+ausw);
      write(endfill(2,#32, int_str(SBIRQ)));
    end;
  until tast=esc;


 end;{with}
 {$ENDIF}
end;

procedure blinde;
var auswa, ausw : byte;
    change: boolean;
    fuel:byte;
    tast:char;
    eingabe:string;
begin
iThema(80);
HelpNr:=11;
with konfig do
begin
eingabe:='';
auswa:=1;
ausw:=1;
change:=false;
farbe (white, black);
clrscr;
ladebild(rahmen);
{!BLNT}
  Textzent(helpSetup[17],2,80,ybld-3);
  textzent(endfill(length(helpSetup[17]),'Õ',eingabe),2,80,ybld-2);

gotoxy(xbld,ybld+1); write(helpb[1]+': ');
  if SoftHardC then write(RespT[1]) else write(RespT[2]);

gotoxy(xbld,ybld+2); write(helpb[2]+': ');
  if WinRout then write(RespT[1]) else write(RespT[2]);

gotoxy(xbld,ybld+3); write(helpb[3]+': ',WinRoutTime);

gotoxy(xbld,ybld+4); write(helpb[4]+': ');
  if RXBeepStart then write(RespT[1]) else write(RespT[2]);

gotoxy(xbld,ybld+5); write(helpb[5]+': ');
  if AchzigBrail then write(RespT[1]) else write(RespT[2]);

gotoxy(xbld,ybld+6); write(helpb[6]+': ');
  if SteuerZ then write(RespT[1]) else write(RespT[2]);

gotoxy(xbld,ybld+7); write(helpb[7]+': ');
  if MarkTon then write(RespT[1]) else write(RespT[2]);

gotoxy(xbld,ybld+8); write(helpb[8]+': ');
  if ausgabeBios then write(RespT[1]) else write(RespT[2]);

farbe(specvg, black);
textzent(helpSetup[4],2,80,22);
textzent(helpSetup[8],2,80,23);
farbe(highvg,highhg);
gotoxy(xbld+27,ybld+ausw);
if softhardC then write(RespT[1]) else write(RespT[2]);
cursorAus;

 repeat
  tast:=taste;
   auswa:=ausw;
   case tast of
    f1:help(false,80);
    csdn, cr, tab:
      begin
       inc(ausw);
       change:=true;
       if ausw>8 then ausw:=1;
      end;
    csup, shift_tab:
      begin
       dec(ausw);
       change:=true;
       if ausw<1 then ausw:=8;
      end;
   end; {case tast}

   if change then
    begin
     farbe(white,black);
     textzent(Balken(78,' '),2,79,22);
     textzent(Balken(78,' '),2,79,23);
     gotoxy(xbld+27,ybld+auswa);
     change:=false;
     case auswa of
      1: if softhardC then write(RespT[1]) else write(RespT[2]);
      2: if Winrout then write(RespT[1]) else write(RespT[2]);
      3: write(WinRoutTime,'   ');
      4: if RXBeepStart then write(RespT[1]) else write(RespT[2]);
      5: if AchzigBrail then write(RespT[1]) else write(RespT[2]);
      6: if SteuerZ then write(RespT[1]) else write(RespT[2]);
      7: if MarkTon then write(RespT[1]) else write(RespT[2]);
      8: if AusgabeBios then write(RespT[1]) else write(RespT[2]);
     end;
     farbe(highvg,highhg);
     gotoxy(xbld+27,ybld+ausw);
     case ausw of
      1: begin
          if softhardC then write(RespT[1]) else write(RespT[2]);
          farbe(specvg, black);
          textzent(helpSetup[4],2,80,22);
          textzent(helpSetup[8],2,80,23);
         end;
      2: begin
          if Winrout then write(RespT[1]) else write(RespT[2]);
          farbe(specvg, black);
          textzent(helpSetup[4],2,80,22);
          textzent(helpSetup[8],2,80,23);
         end;
      3: begin
          write(balken(2,' '));
          gotoxy(xbld+27,ybld+ausw);
          write(WinRoutTime,'   ');
          farbe(specvg, black);
          textzent(helpSetup[5],2,80,22);
          textzent(helpSetup[8],2,80,23);
         end;
      4:begin
         if RXBeepStart then write(RespT[1]) else write(RespT[2]);
         farbe(specvg, black);
         textzent(helpSetup[4],2,80,22);
         textzent(helpSetup[8],2,80,23);
        end;
      5: begin
          if AchzigBrail then write(RespT[1]) else write(RespT[2]);
          farbe(specvg, black);
          textzent(helpSetup[4],2,80,22);
          textzent(helpSetup[8],2,80,23);
         end;
      6: begin
          if SteuerZ then write(RespT[1]) else write(RespT[2]);
          farbe(specvg, black);
          textzent(helpSetup[4],2,80,22);
          textzent(helpSetup[8],2,80,23);
         end;
      7: begin
          if MarkTon then write(RespT[1]) else write(RespT[2]);
          farbe(specvg, black);
          textzent(helpSetup[4],2,80,22);
          textzent(helpSetup[8],2,80,23);
         end;
      8: begin
          if AusgabeBios then write(RespT[1]) else write(RespT[2]);
          farbe(specvg, black);
          textzent(helpSetup[4],2,80,22);
          textzent(helpSetup[8],2,80,23);
         end;
     end;

    end; {change}

   if Ausw=1 then
    begin
     case Tast of
      CsLt, CsRt: softhardc:=not softhardc;
     end;
     farbe(highvg,highhg);
     gotoxy(xbld+27,ybld+ausw);
     if Softhardc then Write(RespT[1]) else write(RespT[2]);
    end; {ausw=1}

    if Ausw=2 then
    begin
     case Tast of
      CsLt, CsRt: WinRout:=not Winrout;
     end;
     farbe(highvg,highhg);
     gotoxy(xbld+27,ybld+ausw);
     if WinRout then Write(RespT[1]) else write(RespT[2]);
    end; {ausw=2}

   if Ausw=3 then
    begin
     Case Tast of
      Csrt:
       begin
        if winrouttime<30 then inc(winrouttime)
         else Alarm;
       end;
      Ctrl_Csrt:
       begin
        if winrouttime=30 then alarm;
        if (winrouttime>20) and (winrouttime<30) then winrouttime:=30;
        if winrouttime<21 then winrouttime:=winrouttime+10;
       end;
      Cslt:
       begin
        if winrouttime>1 then dec(winrouttime)
         else Alarm;
       end;
      Ctrl_Cslt:
       begin
        if winrouttime=1 then alarm;
        if winrouttime<11 then winrouttime:=1;
        if winrouttime>11 then winrouttime:=winrouttime-10;
       end;
     end; {Case}
     farbe(highvg,highhg);
     gotoxy(xbld+27,ybld+Ausw);
     fuel:=0;
     if winrouttime<10 then fuel:=fuel+1;
     write(winrouttime,Balken(fuel,' '));
    end; {ausw=3}

    if Ausw=4 then
    begin
     case Tast of
      CsLt, CsRt: RXBeepStart:=not rxbeepstart;
     end;
     farbe(highvg,highhg);
     gotoxy(xbld+27,ybld+ausw);
     if rxbeepstart then Write(RespT[1]) else write(RespT[2]);
    end; {ausw=4}

    if Ausw=5 then
    begin
     case Tast of
      CsLt, CsRt: AchzigBrail:=not AchzigBrail;
     end;
     farbe(highvg,highhg);
     gotoxy(xbld+27,ybld+ausw);
     if AchzigBrail then Write(RespT[1]) else write(RespT[2]);
    end; {ausw=5}

    if Ausw=6 then
    begin
     case Tast of
      CsLt, CsRt: Steuerz:=not Steuerz;
     end;
     farbe(highvg,highhg);
     gotoxy(xbld+27,ybld+ausw);
     if Steuerz then Write(RespT[1]) else write(RespT[2]);
    end; {ausw=6}

    if Ausw=7 then
    begin
     case Tast of
      CsLt, CsRt: MarkTon:=not MarkTon;
     end;
     farbe(highvg,highhg);
     gotoxy(xbld+27,ybld+ausw);
     if MarkTon then Write(RespT[1]) else write(RespT[2]);
    end; {ausw=7}

    if Ausw=8 then
    begin
     case Tast of
      CsLt, CsRt: ausgabeBios:=not AusgabeBios;
     end;
     farbe(highvg,highhg);
     gotoxy(xbld+27,ybld+ausw);
     if AusgabeBios then Write(RespT[1]) else write(RespT[2]);
    end; {ausw=8}

 until tast=esc;
end; {with}
end; {blinde}

procedure Persoenliches;
var tast : char;
    eingabe: string;
    i : byte;
    ausw, a:byte;
begin
with Konfig do
begin
 IThema(90);
 eingabe:='';
 helpNr:=13;
 farbe (white, black);
 tast:=#1;
 clrscr;
 ladebild(rahmen);
  Textzent(helpSetup[37],2,80,yper-3);
 textzent(endfill(length(helpSetup[37]),'Õ',eingabe),2,80,yper-2);

 gotoxy(xper,yper+1); write(Helpb[1]+': '+PersName);

 gotoxy(xper,yper+2); write(helpb[2]+': '+PersLoc);

 gotoxy(xper,yper+3); write(helpb[3]+': '+PersQTH);
textzent(helpSetup[8],2,80,23);
textzent(helpB[4],2,80,yper+7);
ausw:=1; a:=0;
repeat
   farbe(white, black);

 case Tast of
  F1 : help(false,13);
  CR,tab,CsDn: inc(ausw);
  shift_tab,csup: dec(ausw);
 end;
  if ausw>3 then ausw:=1;
 if ausw<1 then ausw:=3;

 case ausw of
  1: begin
       farbe (highvg, highhg); gotoxy(xper+17,yper+1); write(EndFill(30,' ',Konfig.PersName));
       Editor(Konfig.PersName,xper+17,yper+1,30,false,true,Tast,0);
       farbe (white, black); gotoxy(xper+17,yper+1); write(EndFill(30,' ',Konfig.PersName));
     end;
  2: begin
        farbe (highvg, highhg); gotoxy(xper+17,yper+2); write(EndFill(10,' ',Konfig.PersLoc));
        Editor(Konfig.PersLoc,xper+17,yper+2,10,true,false,Tast,0);
        farbe (white, black); gotoxy(xper+17,yper+2); write(EndFill(10,' ',Konfig.PersLoc));
     end;
  3: begin
       farbe (highvg, highhg); gotoxy(xper+17,yper+3); write(EndFill(30,' ',Konfig.PersQTH));
       Editor(Konfig.PersQTH,xper+17,yper+3,30,false,true,Tast,0);
       farbe (white, black); gotoxy(xper+17,yper+3); write(EndFill(30,' ',Konfig.PersQTH));
     end;
  enD; {ausw}

until Tast=ESC
end; {with kofnig}
end;

Procedure KonfigSpeichern;
begin
 konfig.Version:=174;
{$I-}

    Assign(Datei,ConfigDat);
  Konfig.teil1:=ord('3');
  Konfig.teil2:=ord('2');
  Konfig.teil3:=ord('3');
  Konfig.teil4:=ord('6');
    rewrite(Datei);
    Konfig.Kenner:=kennst;
    write(Datei, Konfig);
    if ioresult <>0 then writeln(helpSetup[25]);
    Close(Datei);
{$I+}
end;
(*
Function CBCallCheck (CBCall : String) : Boolean ;
 var hstr1 : String;
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
   hstr1:=copy (Hstr1,3,3);
   if str_int(hstr1)>199 then
    begin
     delete(hstr1,3,3);
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
*)
Procedure Abschluss;
var Tast:Char;
cbflag : Boolean;
cbi:byte;
begin
 farbe(white,black);
 clrscr;
 textzent(helpSetup[26],2,80,10);
 textzent(helpSetup[27],2,80,12);
 writeln;
 cursoraus;
 tast:=taste;
 case Tast of
  Cr,'j','J':
   begin
    clrscr;
    writeln(helpSetup[28]);
    KonfigSpeichern;
    DirCheck;
   end else begin
     clrscr;
     writeln(helpSetup[29]);
     writeln;
     Konfig.CBFilter:=CBFilterStatus;
     end;
  end;{case}
 if Konfig.CBFilter then
  begin
   writeln;
   writeln ('   ACHTUNG: CB-Call-Filter auf CB-Ports aktiv!');
   writeln;
   writeln ('   Diese Verordnung wurde au·er Kraft gesetzt, daher besteht');
   writeln ('   kein Sinn, diesen Filter weiterhin zu nuten!');
   writeln;
   writeln ('   Stand: 20.10.1999');
   writeln;
   writeln ('   Bitte eine Taste drÅcken ...');
   tast:=taste;
   writeln;
  end;
end;

Function TexteLesen : Boolean;
var
    Hstr:String[77];
    HTZeile:longint;
    fireup: integer;
    itl,
    TArt: Byte;
    DatDa,
    KFlag,           {kopf gefunden}
    LFlag : Boolean; {leerzeile}
begin
 HEditorN:=0;

 HSetupN:=0;
 RespN:=0;
  fireup:=0;
  HSetupN:=0;
  HMenN:=0;
 {$I-}
  Assign(BDat, 'XPSETHLP.XP');
  reset(BDAT);
  Pufferlang:=FileSize(BDAT);
  Close(BDAT);
  TextPuffer:=nil;
  GetMem(TextPuffer,sizeof(TextPuffer^));
  FillChar(TextPuffer^,SizeOf(TextPuffer^),0);
  Assign(Hdat,'XPSETHLP.XP');
  reset(HDat,1);
 DatDa:=false;
 if IORESULT=0 then
 begin
  DatDa:=true;
  clrscr;
  write('Loading XPACKSET ');
  PufferLang:=FileSize(HDAT);
  BlockRead(HDat, TextPuffer^, SizeOf(TextPuffer^), Result);


HTZeile:=0;
tart:=0;
 while  HTZeile<Result do
  begin
  if (HTZeile mod 20)=0 then write('>');
  LFlag:=false; Kflag:=false;
  inc(HTZeile);
    Hstr:='';
  while (TextPuffer^[HTZeile]<>#13) and (HTZeile<Result) do
   begin
    inc(HTZeile);
    if TextPuffer^[htzeile]<>#13 then hstr:=hstr+TextPuffer^[htzeile];
   end;

  if (Pos('#END#', Upc(Hstr))=1) then
   begin
    TART:=0;
    LFlag:=true;
   end;
  if (Pos('#REM#', Upc(Hstr))=1) or (Hstr='') then LFlag:=true;
  i:=0;

 if not LFLag then
 begin
   if TART=0 then
     while (i<27) And (pos(Texte[i],Hstr)=0) do Inc(i); { i<27 als erstes, }
     { da sonst bei i=27 der Ausdruck pos(Texte[27],Hstr) eine Bereichs-   }
     { ueberschreitung ausloesst.                                 //db1ras }
   case i of
   1: begin
       TArt:=1;
       LFlag:=true;
      end;
   2: begin
       TArt:=2;
       LFlag:=true;
      end;
   3: begin
       TART:=0;
       HilfeThemen[3]:=HTZeile;
       LFlag:=true;
      end;
   4: begin
       TART:=0;
       HilfeThemen[4]:=HTZeile;
       LFlag:=true;
      end;

   5: begin
       TART:=0;
       HilfeThemen[5]:=HTZeile;
       LFlag:=true;
      end;

   6: begin
       TART:=0;
       HilfeThemen[6]:=HTZeile;
       LFlag:=true;
      end;
   7: begin
       TART:=0;
       HilfeThemen[7]:=HTZeile;
       LFlag:=true;
      end;
   8: begin
       TART:=0;
       HilfeThemen[8]:=HTZeile;
       LFlag:=true;
      end;
   9: begin
       TART:=0;
       HilfeThemen[9]:=HTZeile;
       LFlag:=true;
      end;
   10:begin
       TART:=0;
       HilfeThemen[10]:=HTZeile;
       LFlag:=true;
      end;
   11:begin
       TART:=0;
       HilfeThemen[11]:=HTZeile;
       LFlag:=true;
      end;
   12:begin
       TART:=0;
       HilfeThemen[12]:=HTZeile;
       LFlag:=true;
      end;
   13:begin
       TART:=15;
       LFlag:=true;
      end;
   14:begin
       TART:=0;
       HilfeThemen[20]:=HTZeile;
       LFlag:=true;
      end;
   15:begin
       TART:=0;
       HilfeThemen[21]:=HTZeile;
       LFlag:=true;
      end;
   16:begin
       TART:=0;
       HilfeThemen[30]:=HTZeile;
       LFlag:=true;
      end;
   17:begin
       TART:=0;
       HilfeThemen[40]:=HTZeile;
       LFlag:=true;
      end;
   18:begin
       TART:=0;
       HilfeThemen[50]:=HTZeile;
       LFlag:=true;
      end;
   19:begin
       TART:=0;
       HilfeThemen[60]:=HTZeile;
       LFlag:=true;
      end;
   20:begin
       TART:=0;
       HilfeThemen[70]:=HTZeile;
       LFlag:=true;
      end;
   21:begin
       TART:=0;
       HilfeThemen[80]:=HTZeile;
       LFlag:=true;
      end;
   22:begin
       TART:=0;
       HilfeThemen[90]:=HTZeile;
       LFlag:=true;
      end;
   23:begin
       TART:=0;
       HilfeThemen[13]:=HTZeile;
       LFlag:=true;
      end;
   25:begin
       TART:=0;
       HilfeThemen[100]:=HTZeile;
       LFlag:=true;
      end;
   26:begin
       TART:=0;
       HilfeThemen[14]:=HTZeile;
       LFlag:=true;
      end;
   24:begin
       TArt:=255;
       LFlag:=true;
      end;
   end;{case}
end; {if not Lflag}

   if (not Lflag) and (not KFlag) then
    begin
     case TArt of
      1: begin
          inc (HSetupN);
          helpSetup[HSetupN]:=Hstr;
         end;
      2: begin
          inc (HEditorN);
          helpeditor[HEditorN]:=Hstr;
         end;
      15: begin
           inc(RespN);
           RespT[respn]:=endfill(4,' ',Hstr);
          end;
      255: begin
            inc(HMenN);
            HMIt[HMenN]:=Hstr;
           end;
     end; {case Tart}
    end;
  end; {ehile eof}
 end; {ioresult}

 TexteLesen:=DatDa;
 close(hdat);
 fireup:=ioresult;
 {$I+}

 writeln;

end;




procedure Lese17;
begin
  {$I-}
  Assign(Datei,ConfigDat);
  reset(Datei);
  read(Datei, Konfig);
  if Konfig.MaxLoginUser=0 then Konfig.MaxLoginUser:=3;
  CBFilterStatus:=Konfig.CBFilter;
  close(Datei);
  {$I+}
  if ioresult<>0 then confok:=false;
end;

begin
  CheckBreak := false;                { kein Abbruch durch ctrl-C }
  GetCBreak(BreakStatus);             { Break-Status holen und retten }
  SetCBreak(false);                   { Break off }
farbe(white,black);
clrscr;
HilfeRSaved:=false;
i:=0;
HelpDatDa:=TexteLesen;
if HelpDatDa then
 begin
CURSORTEST;
can:=cursoranf;
cen:=cursorende;
cse:=cursorseite;
 item:=1;
 Tau:=1;
 InitVar;
 confok:=false;

 {filesize checken - file of byte!}

 {$I-}
   Assign(Dateiw,ConfigDat);
   reset(Dateiw);
   datsize:=filesize(Dateiw);
   close(dateiw);
    I:=Ioresult;
 {$I+}
                 {11167 ALTE 1.70!!}
   if (datsize=11388) then {*** Config 1.73/1.80 11283 ***}
   begin
    confok:=true;
    Lese17;
{    konfigspeichern;}
    if Konfig.Version<>174 then ConfOK:=false;
   end;
  if Konfig.Kenner<>Kennst then confok:=false;
  if not confok then writeln(helpSetup[33]);


  if (not confok) then
   begin
    i:=ioresult;
    {$I-}
    writeln;
    writeln(helpSetup[30]);
    farbe(white,black);
    alarm;
    INitVar;
    cursoraus;
    warte(200);
    KonfigSpeichern;
    cursorein;
    {$I+}
   end else konfigSpeichern;
if Konfig.LifeTime>240 then Konfig.LifeTime:=240;
if Konfig.BackupTime=1 then Konfig.BackupTime:=2;
 new(hauptmenu);
 new(EditorHilfe);
 new(rahmen);
 new(HilfeRahmen);
 new(BildSpeicher);

 Farbe(white, black);
 clrscr;
 gotoxy(1,1);
 write('…');
 for i:=1 to 78 do write('Õ');
 write('ª');
 gotoxy(1,24);

 write('»');
 for i:=1 to 78 do write('Õ');
 write('º');
 for i:=2 to 23 do
  begin
   gotoxy(1,i);
   write('∫');
   gotoxy(80,i);
   write('∫');
  end;
 gotoxy(2,1); write('XPacket V1.81b7(as)');
 {$ifndef Sound}
 write(' - NoSound');
 {$Endif}
savebild(Rahmen);
  textzent('X P a c k e t - S e t u p',2,80,y);
  Textzent('ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ',2,80,y+1);
  {$IFNDEF Sound}
  HMIt[8]:=HMIt[8]+'-N/A';
  {$ENDIF}
  for i:=1 to maxhmenu do
   Textzent(HMIt[i],2,80,y+2+i);
  CursorAus;
  SaveBild(HauptMenu);
  CursorEin;
  konfig.kenner:=kennst;
  Repeat
   HMenu(Item,ch);
   if ch=esc then ch:=#1;
   Tau:=1;
   if ch=cr then
    begin
      case Item of
       1:TncSet;
       2:Verzeichnisse;
       3:Verschiedenes;
       4:MailFrameSet;
       5:Speicher;
       6:Drucker;
       7:Blinde;
      {$ifdef Sound}
       8:Sound;
      {$Endif}
      {$IFnDef Sound}
       8:Alarm;
      {$Endif}
       9:Persoenliches;
       10: begin
          Abschluss;
          ch:=esc;
          end;
      end;
    end;
   if ch<>esc then LadeBild(HauptMenu);
  Until Ch=esc;

 writeln(helpSetup[31]);
 cursoranf:=can;
 cursorende:=cen;
 cursorseite:=cse;
 cursorein;
 dispose (hauptmenu);
 dispose(Hilferahmen);
 dispose(rahmen);
 dispose (EditorHilfe);
 FreeMem(TextPuffer, sizeof(TextPuffer^));
end {helpdatda}
 else writeln(helpSetup[32]);
  SetCBreak(BreakStatus);                   { Break ZurÅck }
end.

{
HelpSetup-Array-Verteilung:
===========================
4  Auswahl Cursor r/l
5  Auswahl Cursor r/l und CTRL-Curs
6  Mehr mait Return
7
8  Hilfe mit F1
9  TNC-Setup öberschrift
10 TNC-Ini öberschrift
11 TNC DeIni öberschrift
12 Verzeichnisse öberschr
13 Verschiedenes öberschr
14 Mailframe öberschr
15 Speicher öberschr
16 Drucker öberschrift
17 Blinden öberschrift
18 Verz. nicht erstellt
19 Verz erstellt
20 Verz exist. bereits
21 Xpack legt verz an
22 XP prÅft (fÅr View/Edit)
23 existiert nicht (fÅr View/edit)
24 vorhanden (fÅr View/edit)
25 Fehler beim Speichern
26 Soll gespeichert werden?
27 J/Enter fÅr Ja ...
28 Konfig wird gespeichert
29 Konfig wird nicht gespeichert
30 Fehler beim Laden
31 XPSet ist beendet
32 XPSETHLP.XP nicht gefunden
33 Falsche Version von CONFIG.XP
34 Config Version 1.1/1.2x
35 Alte Konfiguration wird importiert.
36 Zeiten aktivieren/deaktivieren space