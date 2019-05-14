{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  UNIT: X P O V R 4 . P A S                                              ³
 ³                                                                         ³
 ³ Programmcode, der aus dem Overlayteil nachgeladen wird                  ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


UNIT XPOVR4;
{$F+,O+}
{-$DEFINE Sound}

Interface

Uses CRT,
     DOS,
     OVERLAY,

     XPEMS,
     XPXMS,
     XPDEFS;


(* Proceduren und Funtionen der XPREM.PAS *)
Procedure Remote(Kanal : Byte; Art : Integer; CZeile : Str80);
Procedure Send_Prompt(Kanal : Byte; Art : Integer);
Procedure Ch_Dir(Kanal : Byte; Var Zeile : Str80);
Function  REM_Auswert(Kanal, Art : Byte; Komm : Str80) : Byte;
Procedure TNC_Auswert(Kanal : Byte; Var TncKom, Doc : Str20);
Procedure Mk_Dir(Kanal : Byte; var Zeile : Str80);
Procedure Rm_Dir(Kanal : Byte; var Zeile : Str80);
Function  Call_Exist(Kanal,Art : Byte; Zeile : Str9) : Boolean;
Procedure SendToChannel(Kanal,Art,von,bis : Byte; Zeile : Str80);
Procedure Quit(Kanal : Byte);
Function  QSO_Time(Kanal : Byte) : Str20;
Function  Rom_Ready : Boolean;
Procedure REM_HelpLong(Kanal : Byte; IDstr : Str6);
Procedure ComputeRTF(Kanal : Byte; Zeile : Str80);

(* Proceduren und Funtionen der XPSCROL.PAS *)
Procedure Notiz_Zeigen(Kanal : Byte);
Procedure FileScroll(Kanal : Byte);
Procedure CheckSort(Kanal,Spalte,AnzSp : Byte; Dpos : LongInt; SC : Char);
Procedure OpenDBox(Kanal : Byte);
Procedure CloseDBox(Kanal : Byte);

Procedure Sprechen (Zeile : Str80) ;

Procedure SprachMenu;

Implementation

Uses  XPACT,
      XPACT1,

      XPOVR,
      XPOVR1,
      XPOVR2,
      XPOVR3,
      xpovr5,
      xpovr6;


{$I XPREM}
{$I XPSCROL}
{$I xpspeak}

End.
