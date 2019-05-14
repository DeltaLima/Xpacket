{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  UNIT: X P O V R 2 . P A S                                              ³
 ³                                                                         ³
 ³ Programmcode, der aus dem Overlayteil nachgeladen wird                  ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


UNIT XPOVR2;
{$F+,O+}
Interface

Uses CRT,
     DOS,

     XPEMS,
     XPXMS,
     XPDEFS;


(* Proceduren und Funtionen der XPLOAD.PAS *)
Procedure Emblem_Zeigen;
Procedure Ini_Start_Tnc;
Procedure Switch_Hostmode(V24Nr,TNC_Nr : Byte);
Procedure TNC_High_Channel_Init;
Procedure DRSI_Hostmode(TNC_Nr,Art : Byte);
Procedure Configlesen;
Procedure Infos_Lesen;
Procedure Strings_Lesen;
Procedure AttributFile_Lesen;
Procedure ESC_Lesen;
Procedure QRG_Lesen;
Procedure REM_Lesen;
Procedure PWD_Lesen;
Procedure HELP_Lesen;
Procedure TncIni(Art : Byte);
Procedure Abschluss_XP;
Procedure Sicherung_Speichern;
Procedure Abbruch_XP(Nr : Byte; Zeile : str80);
Procedure ScrFile_erzeugen;
{Procedure LineRead(Fstr : Str10);}
Function  HeapFrei(Bedarf : LongInt) : Boolean;
Procedure Config_Verz_Lesen;
Procedure Config_Allg_Lesen;
Procedure Config_TNC_Lesen;
Procedure Config_PRN_Lesen;
Procedure Config_RAM_Lesen;
Procedure Config_BLIND_Lesen;
Procedure Config_SOUND_Lesen;
Procedure Puffer_schreiben;
Procedure Puffer_lesen;
Procedure VorCurEnd;
Procedure Interface_Exist;
Procedure GenCrcTab;
Procedure GenPrivPWD;
Procedure UebergabeAuswert;


(* Proceduren und Funtionen der XPDOS.PAS *)
Procedure DosAufruf(Var Zeile : Str128; Art : Byte);
Procedure ExecDOS(Zeile : Str128);
Procedure DosBildSave(Zeilen : Byte);
Procedure StoreHeap;
Procedure LoadHeap;
Function  Zeilen_ermitteln : Byte;
Procedure Switch_VGA_Mono;
Procedure Ini_TNC_Text(Art : Byte);


(* Proceduren und Funtionen der XPHELP.PAS *)
Procedure Hlp_Laden(Istr : Str6);
Procedure XP_Help(IDstr : Str6);
Procedure REM_Help(Kanal : Byte; HNr : Byte);
Procedure Send_Hilfe(Kanal : Byte; IDstr : Str6);
Procedure Help_Compile;


Implementation

Uses  XPACT,
      XPACT1,

      XPOVR,
      XPOVR1,
      XPOVR3,
      XPOVR4,
      xpovr5,
      xpovr6;


{$I XPLOAD}
{$I XPDOS}
{$I XPHELP}


End.
