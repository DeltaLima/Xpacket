{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  UNIT: X P O V R 1 . P A S                                              ³
 ³                                                                         ³
 ³ Programmcode, der aus dem Overlayteil nachgeladen wird                  ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


UNIT XPOVR1;
{$F+,O+}
Interface

Uses CRT,
     DOS,

     XPEMS,
     XPXMS,
     XPDEFS;


(* Proceduren und Funtionen der XPFILE.PAS *)
Function  Compute_CRC(CRC : Integer; Zeile : String) : Integer;
Procedure FileInfo(Kanal,Art : Byte; Groesse,Count,tGroesse,tCount : LongInt);
Function  Zeit_to_Sek(Zeile : Str8) : LongInt;
Function  Time_Differenz(Start,Stop : Str8) : Str8;
Function  FileBaud(ZeitStr,AnzStr : Str9) : Str9;
Procedure Kill_Save_File(Kanal : Byte);
Procedure Close_SaveFiles;
Procedure Open_SaveFiles;
Procedure Neu_Name(Kanal,Art : Byte; Call : str9; Name : str28);
Function  GetName(Kanal : Byte; Call : Str9; var FlagByte : Byte; Con:Boolean) : Str40;
Function  Platzhalter(Kanal : Byte; Zeile : String) : String;
Function  MakeBinStr(Kanal : Byte; Zeile : Str80) : Str80;
Function  FName_aus_FVar(var f : File) : Str80;
Function  SaveNameCheck(Art : Byte; Zeile : Str80) : Boolean;
Function  MakePathName(Kanal : Byte; Var DFlag : Boolean; Zeile : Str80) : Str80;
Function  FNameOK(Zeile : Str80) : Boolean;
Function  PfadOk(Art : Byte; Zeile : Str80) : Boolean;
Function  MkSub(Pfad : Str80) : Boolean;
Procedure KillFile(Zeile : Str80);
Procedure Ini_RemPath;
Procedure File_Bearbeiten(Kanal : Byte; Zeile : Str80);


(* Proceduren und Funtionen der XPFRX.PAS *)
Procedure FileRxMenu(Kanal : Byte);
Procedure Datei_Empfangen(Kanal : Byte; Art : Byte);
Function  OpenTextFile(Kanal : Byte) : Boolean;
Procedure OpenBinFile(Kanal : Byte; Zeile : Str80);
Procedure Write_RxFile(Kanal : Byte; Zeile : String);
Procedure CloseRxFile(Kanal,Art : Byte);
Procedure SaveFile(Kanal : Byte);
Procedure Write_SFile(Kanal : Byte; Zeile : String);
Function  SvFRxCheck(Kanal : Byte; Zeile : Str60; Name : Str12) : Str60;


(* Proceduren und Funtionen der XPFTX.PAS *)
Procedure FileTxMenu(Kanal : Byte);
Procedure Datei_Senden(Kanal : Byte; Art : Byte);
Procedure FileSendVon(Kanal : Byte; Zeile : Str40);
Procedure Send_File(Kanal : Byte; OFlag : Boolean);
Procedure SF_Text(Kanal : Byte; Zeile : Str80);
Procedure TXT_Senden(Kanal,Art,FNr : Byte);
Procedure RequestName(Kanal:Byte);
Procedure BIN_TX_File_Sofort(Kanal : Byte; Zeile : Str80);
Procedure TXT_TX_File_Sofort(Kanal : Byte; Zeile : Str80);
Procedure FertigSenden(Kanal : Byte);


(* Proceduren und Funtionen der XP7PL.PAS *)
Procedure Open_Close_7Plus(Kanal : Byte; Zeile : Str80);
Procedure Close_7Plus(Kanal : Byte);
Procedure Write_SplFile(Kanal : Byte; Zeile : String);


(* Proceduren und Funtionen der XPBUF.PAS *)
Procedure OpenBufferFile(Kanal : Byte);
Procedure WriteBuffer(Kanal : Byte; Zeile : String);
Procedure SendBuffer(Kanal : Byte);
Procedure EraseBufferFile(Kanal : Byte);
Procedure SendTestBuffer(Kanal : Byte);


(* Proceduren und Funtionen der XPDIR.PAS *)
Procedure GetDirFiles(Zeile : Str80; ax, Art : Byte);
Procedure DirZeig(Var Zeile : Str80; var Ch : char; QRet : Boolean);
Procedure RemoteDir(Kanal : Byte; Zeile : Str80);
Procedure DelAll(Pfad : Str80; Yp : Byte);
Function  Get7PlFNr(Zeile : Str80) : Str20;

(* Proceduren und Funktionen der XPCOPY.PAS *)
Procedure FileKopieren(Var Zeile : String);
Procedure Delete_Datei(Var Zeile : Str80);


Implementation

Uses  XPACT,
      XPACT1,

      XPOVR,
      XPOVR2,
      XPOVR3,
      XPOVR4,
      xpovr5,
      xpovr6;


{$I XPFILE}
{$I XPFRX}
{$I XPFTX}
{$I XP7PL}
{$I XPBUF}
{$I XPDIR}
{$I XPCOPY}

End.
