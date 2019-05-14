{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³                                                                         ³
 ³                             X - P a c k e t                             ³
 ³                                                                         ³
 ³                                                                         ³
 ³  UNIT: X P E M S . P A S                                                ³
 ³                                                                         ³
 ³ Routinen fr die EMS-Verwaltung.                                        ³
 ³                                                                         ³
 ³ Abschrift mit leichten nderungen aus der Fachzeitschrift               ³
 ³            " DOS - International "                                      ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}

Unit XPEMS;
{$F+}

Interface

Uses DOS;

{ Globale Vereinbarungen fr Konstanten }

Const
       {
       EMS_NoError               = 0;
       EMS_DriverError           = 1;
       EMS_HardwareError         = 2;
       EMS_InvalidHandle         = 3;
       EMS_InvalidFunction       = 4;
       EMS_NoHandlesAvail        = 5;
       EMS_NoPageAvail           = 6;
       EMS_InvalidPageNumber     = 7;
       EMS_InvalidPage           = 8;
       EMS_MappingNotSaved       = 9;
       EMS_MappingAlreadySaved   = 10;
       EMS_NoEMSAvail            = 11;
       }

       EMS_errortext : array[0..11] of string[40] =
                       ('Keinen Fehler erkannt',
                        'Fehler im EMS-Treiber',
                        'Fehler in der EMS-Hardware',
                        'Ungltiges EMS-Handle',
                        'Ungltige EMS-Funktionsnummer',
                        'Keine EMS-Handles verfgbar',
                        'Keine freien EMS-Seiten verfgbar',
                        'Falsche EMS-Seitenzahl',
                        'Ungltige EMS-Seitennummer',
                        'EMS-Mapping kann nicht gesichert werden',
                        'EMS-Mapping ist bereits gesichert',
                        'Kein EMS-Treiber installiert');

{ Globale Typ-Definitionen }

Type EMS_Handle = Word;
     EMS_Seite  = Byte;
     EMS_SeiteImFenster = 0..3;
     EMS_AlleHandles = array[0..255] of record
                                          Handle,
                                          SeitenAnzahl : Word;
                                        end;

{ Globale Variablen-Definitionen }

Var EMS_Segment     : Word;
    EMS_Error       : Byte;
    EMS_Installiert : Boolean;
    EMS_Fenster     : array[0..3] of Word;


Function  EMS_Status : Byte;
Function  EMS_GesamtSeiten : Word;
Function  EMS_FreieSeiten : Word;
Function  EMS_Belegen(Anzahl : Word) : EMS_Handle;
Procedure EMS_Zuordnung(Handle : EMS_Handle; Fensterseite : EMS_SeiteImFenster; Seite : EMS_Seite);
Procedure EMS_Freigeben(Handle : EMS_Handle);
Function  EMS_Version : Byte;
Procedure EMS_ZuordnungSichern(Handle : EMS_Handle);
Procedure EMS_ZuordnungEntsichern(Handle : EMS_Handle);
Function  EMS_HandleAnzahl : Word;
Function  EMS_BelegteSeiten(Handle : EMS_Handle) : Word;
Procedure EMS_AlleHandlesFeststellen(var tab : EMS_AlleHandles);
Procedure Init_EMS;

Implementation

Type EMS_Kopf = record
                  dummy : array[1..9] of Byte;
                  name  : string[8];
                end;

     EMS_Zeiger = ^EMS_Kopf;

var  cpu : Registers;
     I   : Byte;

Procedure Fehler(code : Byte);
Begin
  Case code of
    $80 : EMS_Error := 0;
    $81 : EMS_Error := 1;
    $83 : EMS_Error := 2;
    $84 : EMS_Error := 3;
    $85 : EMS_Error := 4;
    $87 : EMS_Error := 5;
    $88 : EMS_Error := 6;
    $8A : EMS_Error := 7;
    $8C : EMS_Error := 8;
    $8D : EMS_Error := 9;
  end;
End;

Function get_EMS_Window : Word;
Begin
  cpu.ah := $41;
  Intr($67,cpu);
  if cpu.ah <> 0 then
  begin
    Fehler(cpu.ah);
    get_EMS_Window := 0;
  end else
  begin
    EMS_Error := 0;
    get_EMS_Window := cpu.bx;
  end;
End;

Function get_EMS_Installiert : Boolean;
Const id : string = 'EMMXXXX0';
var kopf  : EMS_Zeiger;
    flag  : Boolean;
    Index : Byte;

Begin
  cpu.ah := $35;
  cpu.al := $67;
  MsDos(cpu);
  kopf := Ptr(cpu.es,0);
  flag := true;
  index := 1;
  Repeat
    if kopf^.name[index] <> id[index] then flag := false;
    inc(index);
  Until (index = 9) or (flag = false);
  get_EMS_Installiert := flag;
End;

Function EMS_Status : Byte;
Begin
  cpu.ah := $40;
  Intr($67,cpu);
  EMS_Status := cpu.ah;
  if cpu.ah <> 0 then Fehler(cpu.ah) else EMS_Error := 0;
End;

Function EMS_GesamtSeiten : Word;
Begin
  cpu.ah := $42;
  Intr($67,cpu);
  if cpu.ah = 0 then
  begin
    EMS_Error := 0;
    EMS_GesamtSeiten := cpu.dx;
  end else
  begin
    Fehler(cpu.ah);
    EMS_GesamtSeiten := 0;
  end;
End;

Function EMS_FreieSeiten : Word;
Begin
  cpu.ah := $42;
  Intr($67,cpu);
  if cpu.ah = 0 then
  begin
    EMS_Error := 0;
    EMS_FreieSeiten := cpu.bx;
  end else
  begin
    Fehler(cpu.ah);
    EMS_FreieSeiten := 0;
  end;
end;

Function EMS_Belegen(anzahl : Word) : EMS_Handle;
Begin
  cpu.ah := $43;
  cpu.bx := anzahl;
  Intr($67,cpu);
  if cpu.ah = 0 then
  begin
    EMS_Error := 0;
    EMS_Belegen := cpu.dx;
  end else
  begin
    Fehler(cpu.ah);
    EMS_Belegen := 0;
  end;
End;

Procedure EMS_Zuordnung(Handle : EMS_Handle; Fensterseite : EMS_SeiteImFenster; Seite : EMS_Seite);
Begin
  cpu.ah := $44;
  cpu.al := Fensterseite;
  cpu.bx := Seite;
  cpu.dx := Handle;
  Intr($67,cpu);
  if cpu.ah = 0 then EMS_Error := 0 else Fehler(cpu.ah);
End;

Procedure EMS_Freigeben(Handle : EMS_Handle);
Begin
  cpu.ah := $45;
  cpu.dx := Handle;
  Intr($67,cpu);
  if cpu.ah = 0 then EMS_Error := 0 else Fehler(cpu.ah);
End;

Function EMS_Version : Byte;
Begin
  cpu.ah := $46;
  Intr($67,cpu);
  if cpu.ah = 0 then
  begin
    EMS_Error := 0;
    EMS_Version := cpu.al;
  end else
  begin
    Fehler(cpu.ah);
    EMS_Error := 0;
  end;
End;

Procedure EMS_ZuordnungSichern(Handle : EMS_Handle);
Begin
  cpu.ah := $47;
  cpu.dx := Handle;
  Intr($67,cpu);
  if cpu.ah = 0 then EMS_Error := 0 else Fehler(cpu.ah);
End;

Procedure EMS_ZuordnungEntsichern(Handle : EMS_Handle);
Begin
  cpu.ah := $48;
  cpu.dx := Handle;
  Intr($67,cpu);
  if cpu.ah = 0 then EMS_Error := 0 else Fehler(cpu.ah);
End;

Function EMS_HandleAnzahl : Word;
Begin
  cpu.ah := $4B;
  Intr($67,cpu);
  if cpu.ah = 0 then
  begin
    EMS_Error := 0;
    EMS_HandleAnzahl := cpu.bx;
  end else
  begin
    Fehler(cpu.ah);
    EMS_HandleAnzahl := 0;
  end;
End;

Function EMS_BelegteSeiten(Handle : EMS_Handle) : Word;
Begin
  cpu.ah := $4C;
  cpu.dx := Handle;
  Intr($67,cpu);
  if cpu.ah = 0 then
  begin
    EMS_Error := 0;
    EMS_BelegteSeiten := cpu.bx;
  end else
  begin
    Fehler(0);
    EMS_BelegteSeiten := 0;
  end;
End;

Procedure EMS_AlleHandlesFeststellen(var tab : EMS_AlleHandles);
var  I : Byte;

Begin
  for I := 0 to 255 do
  begin
    tab[i].Handle := 0;
    tab[i].SeitenAnzahl := 0;
  end;
  cpu.ah := $4D;
  cpu.es := Seg(tab);
  cpu.di := Ofs(tab);
  Intr($67,cpu);
  if cpu.ah = 0 then EMS_Error := 0 else Fehler(cpu.ah);
End;

Procedure Init_EMS;
Begin
  EMS_Installiert := get_EMS_Installiert;
  if EMS_Installiert then
  begin
    EMS_Segment := get_EMS_Window;
    for I := 0 to 3 do EMS_Fenster[I] := EMS_Segment + I*1024;
  end else EMS_Error := 11;
End;

End.

