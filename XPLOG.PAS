(*
Dieses Programm ist nicht von mir, sondern stammt von DL5FBD.
Es dient zum Ausdruck der TOP-Logbuchdatei (LOG.TOP).
Allerdings ist das Programm wenig getestet und muss gegebenfalls
angepasst werden.
*)

{LOGPRINT bietet folgende Moeglichkeiten:

        1. Formattierter Druck von SP.LOG auf EPSON-komp. Druckern

           Der Druck wird in Blaettern zu je 67 Zeilen formattiert und
           die 5 SP.LOG Kopfzeilen am Anfang jeder jedes Blatt ausgedruckt.

        2. Anpositionieren einer gewuenschten Druckseite und Druck der 
           Restdatei inklusiv dieser Seite.


Der Aufruf ist:

          LOGPRINT <Datei>                fuer kompletten Ausdruck einer SP.LOG

          LOGPRINT <Datei> (Druckseite)   fuer Ausdruck ab Seite (Druckseite)

Sofern die Environmentvariable SPDIR gesetzt ist, wird SP.LOG in der darin de-
finierten Directory gesucht. Ist SPDIR nicht gesetzt so wird in der aktuellen
Directory gesucht.

73 de Gerd Michael}


{-------------------------------------------------------------------------}
{LOGPRINT 22.07.90 DL5FBD                                                 }
{                                                                         }
{Druckutility zum Ausdruck der SP.LOG Datei                               }
{Erlaubt den Ausdruck von SP.LOG in Seiten formattiert wobei die          }
{Kopfzeilen am Anfang jeder Seite wiederholt werden.                      }
{                                                                         }
{Das Programm erlaubt die Positionierung auf eine gewuenschte Druckseite  }
{mittels eines Suchlaufs.                                                 }
{                                                                         }
{22.07.90 DL5FBD                                                          }
{-------------------------------------------------------------------------}

Program LOGPRT;

USES Printer;

CONST  TopOfForm    = 0;
       TextFenster  = 50;
       AnzKopfzeil  = 3;
       unwichtig    = 10;

VAR    Datei       : Text;
       Name        : STRING[70];
       Seite       : Word;
       Seiten      : Word;
       Zeilen      : Byte;
       I           : Byte;
       Test        : Integer;
       Zeile       : String[140];
       Start       : String[80];
       Ende        : String[80];
       CRLF        : String[2];
       SeitS       : String[5];
       Fett	   : String[10];
       Normal	   : String[10];
       Kopfzeile   : Array[1..5] of STRING;
       Formfeed    : String[1];


FUNCTION GetEnv (EnvVar : String) : String;

TYPE
  EnvPtr   = Word;

VAR
  Enviro   : ^EnvPtr;
  Offset   : Word;
  I        : Byte;
  S        : String;

BEGIN
  GetEnv := '';
  IF Length(EnvVar) = 0 THEN Exit;
  FOR I := 1 TO Length(EnvVar) DO EnvVar[I] := UpCase(EnvVar[I]);
  EnvVar := EnvVar + '=';
  Enviro := Ptr(PrefixSeg,$2C);
  Offset := 0;
  S := '';
  Repeat
    S:='';

    {Environmentstring komplett extrahieren}
    While Mem[Enviro^:Offset] > 0 DO
      BEGIN
        S := S+UpCase(Chr(Mem[Enviro^:Offset]));
        INC (Offset);
      END;

   {Ist die Environmentvariable vorhanden ??}
   {Dann Zuweisungsteil holen und beenden !}
    IF (Pos(EnvVar,S) = 1) THEN
      BEGIN 
        GetEnv := Copy(S,Pos('=',S)+1,Length(S));
        EXIT;
      END;

    Inc(Offset);

  {Endekennung Environmentvariablenbereich}
  Until       (Mem[Enviro^:Offset] = 0)
          AND (Mem[Enviro^:Offset+1] = 1)
          AND (Mem[Enviro^:Offset+2] = 0);
END;


Function GetDIR(Pfad:String):String;

VAR   Dummi  :String[70];

BEGIN
  Dummi:=GetEnv(Pfad);
  IF LENGTH(Dummi) >0 THEN Dummi:=Dummi+'\';
  GETDIR:=Dummi;
END;


Procedure DefiniereDruckervariable;

Begin
  CRLF  :=chr(13)+chr(10);		{Zeilenabschluss CR+LF}
  Formfeed:=chr(12);                    {Seitenvorschub}
  Start :=chr(27)+'@';			{Drucker-Reset}
  {Start :=Start+chr(27)+chr(25)+'T'+'1';}{Druckbeginn Einzelblatteinzug Zeile 1}
  Start :=Start+chr(27)+chr(15);	{Eliteschrift 96 Zeichen/Zeile}
  {Start :=Start+chr(27)+'l'+chr(1);}	{Heftrand 1 Zeichen}
  Ende  :=chr(27)+'@';			{Drucker-Reset}
  Fett  :=chr(27)+'E';			{Fettschrift ein}
  Normal:=chr(27)+'F';			{Fettschrift aus}
END;


Procedure Druckstring(AusZeile :String);

VAR K  :Byte;
    Z  :CHAR;
Begin

  FOR K:=1 TO LENGTH(AusZeile) DO
    BEGIN
      Z:=AusZeile[K];
      Repeat
        {$I-} Write(LST,Z); {$I+}
      Until IOResult=0;
    END;
END;


Procedure DruckKopf;

   Begin
       Begin
         DruckString(Fett+Name+'    ');
         STR(Seite,SeitS);
         DruckString('Seite: '+SeitS+CRLF);
         Writeln(crlf,crlf);
         Writeln(Name+'    Seite: '+SeitS);
         FOR I:=1 to AnzKopfZeil-1 DO
           BEGIN
             Druckstring(Kopfzeile[I]+CRLF);
             Writeln(Kopfzeile[I]);
           END;
         Druckstring(Normal);
         Zeilen:=AnzKopfZeil;
       END;
   END;

BEGIN

  DefiniereDruckervariable;

  IF ParamCount>=1 THEN Name:=ParamStr(1)
  ELSE
    BEGIN
      Writeln;
      Writeln('LOGPRINT  - Formattierter Ausdruck der SP-Log-Datei');
      Writeln('            22.07.90 DL5FBD');
      Writeln;
      Writeln('Aufruf:     LOGPRINT <Dateiname> [Druckseite]');
      Writeln;
      Halt;
    END;

  Assign(Datei,GETDIR('SPDIR')+Name);
  {$I-} Reset(Datei); {$I+}
  If IOResult<>0 THEN
    BEGIN
      Writeln;
      Writeln(GETDIR('SPDIR'),Name,' nicht gefunden!');
      Writeln;
      Halt;
    END;

  FOR I:=1 to unwichtig DO Readln(Datei);
  FOR I:=1 to AnzKopfZeil-1 DO Readln(Datei,Kopfzeile[I]);

  DruckString(Start);

  IF ParamCount=2 THEN
    BEGIN
      Zeile:=ParamStr(2);
      VAL(Zeile,Seite,Test);
      IF Test <>0 THEN
        BEGIN
          Writeln;
          Writeln('Fehlerhafte Druckseitenangabe!');
          Writeln;
          Halt;
        END;
      Seite:=Seite-1
    END
  ELSE Seite:=0;

  IF Seite>0 THEN
    BEGIN
      Seiten:=0;
      Writeln;
      Repeat
        INC(Seiten);
        Write('Positionierung steht auf Seite ',Seiten+1,CHR(13));
        Zeilen:=AnzKopfZeil;

        Repeat
          Readln(Datei,Zeile);
          INC(Zeilen);
        Until (Eof(Datei)) OR (Zeilen=Textfenster);

      Until Eof(Datei) OR (Seiten=Seite);

      IF Eof(Datei) THEN
        BEGIN
          Writeln;
          Writeln('Fehlerabbruch! Das Ende der Logdatei wurde vor der');
          Writeln('               Leseposition der Druckseite erreicht!');
          Writeln;
          Halt;
        END;
    END;

  Repeat                                 { Druckschleife }

    IF TopOfForm>0 THEN For I:=1 TO TopOfForm DO DruckString(CRLF);

    INC(Seite);
    Zeilen:=0;

    DruckKopf;                           {Kopfzeile bei Zusatzparametern}

    Repeat                               { Seitenschleife }
      Readln(Datei,Zeile);
      Druckstring (Zeile);
      Druckstring (CRLF);
      Writeln(Zeile);
      INC(Zeilen);
    Until (Zeilen=TextFenster) OR Eof(Datei);

    IF Zeilen=TextFenster THEN
      Begin
      Druckstring(Formfeed);             { Seitenvorschub }
      End;

  Until Eof(Datei);

  Druckstring(Formfeed);                 { Seitenvorschub }

  DruckString(Ende);

  FiResult := CloseBin(Datei);
END.
