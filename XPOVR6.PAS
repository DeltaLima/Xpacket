{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  UNIT: X P O V R 6 . P A S                                              ³
 ³                                                                         ³
 ³ Programmcode, der aus dem Overlayteil nachgeladen wird                  ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}


UNIT XPOVR6;
{$F+,O+}
{-$DEFINE Sound}
{-$DEFINE code}

Interface

Uses CRT,
     DOS,
     OVERLAY,

     XPEMS,
     XPXMS,
     XPDEFS;




Function STOPCompress (Kanal : Byte; Zeile : String; Code : Byte) : String;
Function STOPDeCompress (Kanal : Byte; Zeile2 : String; Code : Byte) : String;
Function  PackIt (Zeile : String) : String;
Function  UnPackIt (Zeile : String) : String;
Function  CodeIt (Kanal : Byte; Zeile : String; Code : Byte) : String;
Function  DeCodeIt (Kanal : Byte; Zeile : String; Code : Byte) : String;
Function  CodeStr (Kanal : Byte; Zeile : String) : String;
Function  DeCode (Kanal : Byte; Zeile : String) : String;
Function  GetCode (Call : Str9) : Word;
Function  PMak (Nr : Byte) : String;
Function DetectStopCode (LastBt, Cd1, Cd2 : Byte) : Boolean;

{XPWAV}
Procedure FindBlaster;
procedure PlayWave (FileName : String);
procedure StopWave;
procedure ExitWavePlayer;

Implementation

Uses  XPACT,
      XPACT1,

      XPOVR,
      XPOVR1,
      XPOVR2,
      XPOVR3,
      xpovr4,
      xpovr5;


{$I XPSTOP}

{$I XPWAV}

End.
