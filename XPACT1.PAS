{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  UNIT: X P A C T 1 . P A S                                              ³
 ³                                                                         ³
 ³ Programmcode, der staendig im RAM des Rechners geladen ist              ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


Unit XPACT1;
{$F+}
{-$DEFINE Sound}
Interface

Uses CRT,
     DOS,
     OVERLAY,
     MEMORY,

     XPDEFS,
     XPEMS,
     XPXMS;

(* Proceduren und Funtionen der XPSTR.PAS *)
Function  str_int(Zeile : Str10) : LongInt;
Function  int_str(i : LongInt) : str10;
Function  ConstStr(VC : Char; L : Byte) : Str80;
Function  RetStr(Zeile : String) : String;
Function  CutStr(Zeile : String) : String;
Function  RestStr(Zeile : String) : String;
Function  UpCaseStr (Zeile : String) : String;
Procedure KillEndBlanks(var Zeile : String);
Procedure KillStartBlanks(Var Zeile : String);  (* fhrende Leerz. l”schen *)
Function  ParmStr(Nr : Byte; VC : Char; Zeile : String) : String;
Function  SFillStr(Anz : Byte; VC : Char; Zeile : String) : String;
Function  EFillStr (Anz : Byte; VC : Char; Zeile : String) : String;
Function  CEFillStr (Anz : Byte; VC : Char; Zeile : String) : String; {gleich wie efill, nur wird bei berl„nge abgeschnitten}
Function  ZFillStr (Anz : Byte; VC : Char; Zeile : String) : String;
Function  Hex(Dezimal : LongInt; Stellenzahl : Byte) : Str8;
Function  Adr_absolut(Zeiger : Pointer) : LongInt;
Function  Pointer_Str(Zeiger : Pointer) : Str9;
Function  FormByte(Zeile : str11) : str11;
Function  Bin(Dezimal : LongInt ; Stellenzahl : Byte) : Str32;
Procedure Strip(Var Call: str9);                (* SSID entfernen *)


(* Proceduren und Funtionen der XPLIB.PAS *)
Procedure Fenster (H:Byte);
Procedure clrFenster;
Procedure Neu_Bild;
Procedure Status2;
Procedure Triller;
Procedure Bimmel(kan:byte);
Procedure C_Bell(call:str9; kan:byte);
Procedure D_Bell(kan:byte);
Procedure Daten_Bell;
Procedure Cursor_aus;
Procedure Cursor_ein;
Procedure Beep(Ton,Laenge : Word);
Function  Datum : Str11;
Procedure GetTime_ (VAR Hr, Mn, Sk, Sk100 : Word);
Function  Uhrzeit : Str8;
Function  Channel_ID (Kanal : Byte) : Str8;
Procedure Warten;
Procedure Alarm;
Procedure StatusOut(Kanal,x,Nr,Attr : Byte ; Zeile : str80; StZ : Byte);
Procedure NodeConnect(Kanal : Byte; Zeile : Str80);
Function  Exists(name : Str80) : Boolean;
Procedure Teil_Bild_Loesch(y,y1,Attr : Byte);
Procedure InfoOut(Kanal,AL,NewPic : Byte; Zeile : Str80);
Function  InfoZeile(Nr : Word) : Str80;
Procedure max_path_ermitteln;
Procedure WritePage(Kanal,X_Pos,Y_Pos,Attr,Aufruf : Byte ; Zeile : Str80);
Procedure WriteRam(X_Pos,Y_Pos,Attr,Aufruf : Byte ; Zeile : Str80);
Procedure WriteTxt(X_Pos,Y_Pos,Attr : Byte ; Zeile : Str80);
Procedure WriteBios(Kanal,X_Pos,Y_Pos,Attr,Aufruf : Byte ; Zeile : Str80);
Procedure WriteAttr(X_Pos,Y_Pos,Count,Attr,Aufruf : Byte);
Function  KanalFrei(Kanal : Byte) : Byte;
Function  Line_convert(Kanal,Art : Byte; Zeile : String) : String;
Procedure SetzeCursor(X,Y : ShortInt);
Procedure InitCursor(X,Y : ShortInt);
Procedure SetzeFlags(Kanal : Byte);
Procedure ScreenFill;
Procedure Check_Eig_Mail(von,bis : Byte);
Procedure EMS_Seite_einblenden(Kanal : Byte; Art : Byte);
Procedure Open_Scroll(Kanal : Byte);
Procedure Close_Scroll(Kanal : Byte);
Function  PhantasieCall : str9;
Procedure set_Hardwarecursor(Kanal : Byte);
Procedure SwitchChannel(Kanal : Byte);
Procedure SwitchKanal(VC : Char);
Procedure SwitchMonitor;
Function  FreeStr(Lw : char) : str11;
Function  V24(Kanal : Byte) : Byte;
Procedure ReInstall;
Procedure ColorItensity(CFlag : Boolean);
Function  ChAttr(Attr : Byte) : Byte;
Procedure Init_HardDrive;
Procedure New2BVec(Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP: Word); Interrupt;
Procedure Check_Loaded;
Procedure Exit_XP;
Procedure PRG_Stoppen(Nr : Byte);
Function  BackScroll(Kanal : Byte) : Boolean;
Procedure Call_DOS(Zeile : Str128);
Function  AppendTxt(Var f : Text) : Integer;
Function  ResetTxt(Var f : Text) : Integer;
Function  ResetBin(Var f : File; Fpos : LongInt) : Integer;
Function  RewriteTxt(Var f : Text) : Integer;
Function  RewriteBin(Var f : File; Fpos : LongInt) : Integer;
Function  CloseTxt(Var f : Text) : Integer;
Function  CloseBin(Var f : File) : Integer;
Function  EraseTxt(Var f : Text) : Integer;
Function  EraseBin(Var f : File) : Integer;
Procedure IdleDOS;
Procedure Verzoegern(Wert : Word);
Procedure LockIntFlag(Art : Byte);
Procedure Sound_ (Tonh, Lang : Integer);
Procedure Sprachwav;
Procedure StopWave_;

(* Proceduren und Funtionen der XPCHR.PAS *)
Procedure Chr_Darstell(Kanal : Byte; KC : Sondertaste; VC : char);
Procedure Chr_Cmd_Show(Kanal : Byte; KC : Sondertaste; VC : char);
Procedure Chr_Vor_Show(Kanal : Byte; KC : Sondertaste; VC : char);
Procedure ChangeXYST(Kanal,Art : Byte; Var X1,Y1,st : Byte);
Procedure Vor_Feld_Scroll(Kanal : Byte);
Procedure Vor_Dn_Scroll(Kanal : Byte);
Procedure Neu_BildVor(Kanal : Byte);
Procedure Soft_Cursor(Kanal : Byte);
Procedure Set_st_Szeile(Kanal,Art,st : Byte);
Procedure TX_Out(Kanal : Byte; All : Boolean);
Procedure Del_Wort(Var Zeile : Str80; X1 : Byte);
Procedure Cur_Wort(Zeile : Str80; KC : Sondertaste; Var X1 : Byte; XM : Byte);


(* Proceduren und Funtionen der XPTAST.PAS *)
Function  ESC_Auswert(Zeile : Str9) : Byte;
Procedure Auswert_CMD(Kanal : Byte; InputZeile : Str80);
Procedure Key_Active(Kanal : Byte; KC : Sondertaste; VC : char);


Implementation

Uses XPACT,

     XPOVR,
     XPOVR1,
     XPOVR2,
     XPOVR3,
     XPOVR4,
     xpovr5,
     xpovr6;


{$I XPSTR}
{$I XPLIB}
{$I XPCHR}
{$I XPTAST}

End.
