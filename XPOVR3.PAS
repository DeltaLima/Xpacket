{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  UNIT: X P O V R 3 . P A S                                              ³
 ³                                                                         ³
 ³ Programmcode, der aus dem Overlayteil nachgeladen wird                  ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


UNIT XPOVR3;
{$F+,O+}

Interface

Uses CRT,
     DOS,
     OVERLAY,

     XPEMS,
     XPXMS,
     XPDEFS;


(* Proceduren und Funtionen der XPLINK.PAS *)
Procedure Lnk_Sort(Art : Byte);
Procedure Lnk_Init(TNr : Byte; Freq : Str8);
Procedure ALT_C_Connect(Kanal : Byte);
Function  GetConPfad(Rufz : Str9) : String;
Function  GetConStr(var Zeile : String) : Str80;
Function  LinkExists(Name : Str9; var Gate : Byte) : Boolean;
Procedure LinkMod(var Zeile : Str80);
Procedure RemoteLnk(Kanal,T : Byte; Zeile : Str9);
Procedure SaveLinks(Kanal,TNr : Byte; Freq : Str8);
Procedure LinkLearn(Kanal : Byte; Zeile : Str80);


(* Proceduren und Funtionen der XPCRC.PAS *)
Procedure CRC_Datei(var Zeile : Str80);
Procedure GetNetRom;


(* Proceduren und Funtionen der XPCOL.PAS *)
Procedure Color_Einstellung;

(* Proceduren und Funtionen der XPMON.PAS *)
Procedure Stat_MonitorCalls(Kanal : Byte);
Procedure Calls_Monitoren(Kanal : Byte; Zeile : Str80);
Procedure Init_Call_monitoren(Kanal : Byte; Zeile : Str80);
Procedure Cancel_Call_monitoren(Kanal : Byte);
Procedure FreeMonitorKanal(Var KA : Byte ; Zeile : Str80);


(* Proceduren und Funtionen der XPMRK.PAS *)
Procedure Merker_Conn_Schreiben;
Procedure Merker_Conn_Lesen;
Procedure Merker_File_Schreiben;
Procedure Merker_File_Lesen;


(* Proceduren und Funtionen der XPMAKRO.PAS *)
Procedure Makrozeile_holen;
Procedure Makro_Aktivieren(Zeile : Str60);
Procedure MakroInit;
Procedure Makro_Erlernen(SK : Sondertaste; VC : Char);
Procedure Makro_Open_LearnFile;

(* Proceduren und Funtionen der XPAUTO.PAS *)
Procedure Auto_Aktivieren(Kanal : Byte; Zeile : Str60);
Procedure Auto_Init(Kanal : Byte);
Procedure Autozeile_Holen(Kanal : Byte);
Function  AutoJmpZnNr(Kanal : Byte; Zeile : Str40) : Word;


(* Proceduren und Funtionen der XPPASS.PAS *)
Procedure Sysop_Einloggen(Kanal : Byte; Zeile : Str80);
Procedure Password_Auswert(Kanal : Byte; Zeile : String);
Procedure DieBox_PW_Scan(Kanal : Byte; Zeile : String);
Procedure Scan_PW_Array(Kanal : Byte);
Procedure BayBox_US_Scan(Kanal : Byte; Zeile : String);
Function  GetPwParm (Nr : Byte; Zeile : Str80) : Str20;
Function  Found_Pw_Call(Zeile : Str80; Cstr : Str9; AlStr:str9; AStr : Str6) : Boolean;
Function  PseudoPriv(Laenge : Byte; Pstr : Str20; Dstr : Str80) : Str80;
Function  Check_Parm(Zeile : String) : String;
Procedure RMNC_Auswert(Kanal : Byte; Zeile : Str80);
Procedure TheNet_SYS_Auswert(Kanal : Byte ; Zeile : String);
Procedure EZBOX_Auswert(Kanal : Byte; Zeile : Str80);



(* Proceduren und Funtionen der XPCONV.PAS *)
Procedure Conv_Tx_All (Kanal : Byte);
Procedure ConversTX (Kanal : Byte; All,Head : Boolean; Zeile : String);
Procedure ConversUser (Kanal : Byte);
Procedure ConversRemote (Kanal : Byte; Zeile : String);
Function ConversIni (Kanal : Byte; INI : Boolean) : Boolean;
Procedure ConversAuswert (Kanal,Nr : Byte);
Function  ConversCall(Kanal : Byte) : Str20;
Procedure ConversQuit(Kanal : Byte);


Implementation

Uses  XPACT,
      XPACT1,

      XPOVR,
      XPOVR1,
      XPOVR2,
      XPOVR4,
      XPOVR5,
      xpovr6;


{$I XPLINK}
{$I XPCRC}
{$I XPCOL}
{$I XPMON}
{$I XPMRK}
{$I XPMAKRO}
{$I XPAUTO}
{$I XPPASS}
{$I XPCONV}


End.
